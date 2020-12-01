<html>
    <head>
        <title>Bank - Reserved Area</title>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
        <style>
            table th { text-align: center; }
            .table { margin: auto; width: 50% !important; }
            h1 { text-align: center; }
            h2 { text-align: center; }
            .menu { text-align: center; }
            .menu ul { display:inline-table; }
            .menu li { display:inline; }
        </style>
    </head>
    <body>
        <?php
        
        // Define the filename fo the log
        $myFile = "/tmp/request.log";
        $myLog = "/tmp/request_only.log";

        // Open the files for the log operations
        $fh_myLog = fopen($myFile, 'a') or exit("Problem during the opening operations for the /tmp/request.log file.</body></html>");
        $fh = fopen($myFile, 'a') or exit("Problem during the opening operations for the /tmp/request_only.log file.</body></html>");

        // Log for scoring section
        fwrite($fh, "===================================\n");
        fwrite($fh_myLog, "===================================\n");
        foreach ($_GET as $key => $value) {
            fwrite($fh, $key . " => " . $value . "\n");
            if($key == "user" || $key == "pass" || $key == "drop" || $key == "amount"){ // Added to log only the requests used from the webapp
                fwrite($fh_myLog, $key . " => " . $value . "\n");
            }
        }
        // END log for scoring section
        
        // Defined to check if the variable is not bigger than sql integer
        $MAX_INT_DB = 2147483647;
        
        // Input validation, checkss if the user setted all the variables
        if(isset($_GET["user"])){
            $user = htmlentities($_GET["user"]); // Avoid problems with special characters in the username (in the specific xss reflected)
            if(strlen($user) > 40){ //Check if the username can be stored in the database
                fclose($fh);
                fclose($fh_myLog);
                exit("Username is too big. </body></html>");
            }
            if($user == ""){
                fclose($fh);
                fclose($fh_myLog);
                exit("Username param is empty. </body></html>");
            }
        } else {
            // Since no username has been provided stop the execution
            fclose($fh);
            fclose($fh_myLog);
            exit("No username provided </body></html>");
        }
        
        if(isset($_GET["pass"])){
            $pass = $_GET["pass"]; // Password is not checked against problems, since it's never printed in the page and also since it's used only inside a hash function
            if(strlen($pass) < 10){
                fclose($fh);
                fclose($fh_myLog);
                exit("Password too short! Please use a password longer than 10 characters.</body></html>");
            }
        } else {
            fclose($fh);
            fclose($fh_myLog);
            exit("No password provided </body></html>");
        }

        if(isset($_GET["drop"])){
            $choice = htmlentities($_GET["drop"]); // Escape of strange characters
        } else {
            $choice = ""; // If not set any operation will be applied to the account
        }

        if(isset($_GET["amount"])){
            $amount = intval($_GET["amount"]); // In case the user try to insert a string/char in this field the intval translate into 0 so no problem
        } else {
            $amount = 0; // In case is not set that will be automatically assigned 0
        }

        // Connect to the database and if the connection fails exit from the page evaluation
        $mysqli = new mysqli('localhost', 'php_user', '|AttackersWontFindOut@', 'ctf2');
        if (!$mysqli) {
            fclose($fh);
            fclose($fh_myLog);
            exit('Could not connect: ' . $mysqli->error() . "</body></html>");
        }

        // Automatically process the link in case is needed (Avoid xss reflected on pass field)
        $url_balance = "process.php?user=$user&pass=".htmlentities($pass)."&drop=balance";
        
        // Using the parameter $choise to perform the different operations
        if ($choice == 'register') {
            $stm = $mysqli->prepare("INSERT INTO users (user, pass) VALUES (?, ?)");
            $stm->bind_param("ss", $user, password_hash($pass, PASSWORD_DEFAULT)); // The password is stored in the database as the digest generated from the php function

            if ($stm->execute() == false){
                closeDBandFile($stm->error); // In case of error print the error and close the connection with files and mysql 
            }

            //$result = $stm->get_result(); //Uncomment and use if needed

            print "User $user registered successfully!";
            closeDBandFile("<a href='$url_balance'>Load balance page</a>");
        } else if ($choice == 'balance' && checkUserCredentials($user, $pass) == true) {

            printUserInfo($user);  

            // Check if pageno variable is setted
            if (isset($_GET['pageno'])) {
                $pageno = intval($_GET['pageno']);
                if(gettype($pageno) != "integer"){ //Should never match this condition
                    closeDBandFile("Impossible to use pagination with a non numeric index.");
                }else if($pageno == 0){ // Case in which pageno is a string and is converted to 0, then will be assigned to 1 that is the minimum 
                    $pageno = 1;
                }
            } else {
                $pageno = 1; // If isn't setted than set as 1
            }

            $no_of_records_per_page = 25; //Define the number of record to be displayed in the list

            // Calculate the number of pages using the number of records
            $stm = $mysqli->prepare("SELECT COUNT(*) as count FROM transfers WHERE user = ?");
            $stm->bind_param("s", $user);

            if ($stm->execute() == false){
                closeDBandFile($stm->error); // In case of error print the error and close the connection with files and mysql 
            }

            // Calculate the number of total pages
            $result = $stm->get_result();
            $row = $result->fetch_array();
            $total_rows = $row['count']; 
            $total_pages = ceil($total_rows / $no_of_records_per_page); 
            
            if($pageno > $total_pages){ // If the attacker try to use a pageno bigger than the maximum (Calculated from the db) put the value as the maximum
                $pageno = $total_pages;
            }
            $offset = ($pageno-1) * $no_of_records_per_page; // Calculate the offset in order to know which row to print in a page

            // Retrieve the record form the database limiting the result
            $stm2 = $mysqli->prepare("SELECT amount FROM transfers WHERE user = ? LIMIT ?,?");
            $stm2->bind_param("sii", $user, $offset, $no_of_records_per_page);

            if ($stm2->execute() == false){
                closeDBandFile($stm2->error); // In case of error print the error and close the connection with files and mysql 
            }

            // Get the result list from the query execution
            $result2 = $stm2->get_result();

            print "<h2>Balance and transfer history</h2>";
            print "<div class='container-fluid'>";
            print "<table class='table table-bordered table-striped text-center'><thead><tr><th>Action</th><th>Amount</th></tr></thead><tbody>";
            while ($row = $result2->fetch_array()) {
                $amount = $row['amount'];
                if ($amount < 0) {
                    $action = "Withdrawal";
                } else {
                    $action = "Deposit";
                }
                print "<tr><td>" . $action . "</td><td>" . $amount . "</td></tr>";
            }
            print "</tbody></table>";
            print "</div>";

            // Setup of the variable and GUI used to navigate the transfers
            $prev_page = $pageno - 1;
            $next_page = $pageno + 1;
            print "<div class='menu'><ul class='pagination'>";
            print "<li><a href='$url_balance&pageno=1'>First</a></li>";
            if($prev_page >= 1){
                print "<li><a href='$url_balance&pageno=$prev_page'>Prev</a></li>";
            }
            if($next_page < $total_pages){
                print "<li><a href='$url_balance&pageno=$next_page'>Next</a></li>";
            }
            print "<li><a href='$url_balance&pageno=$total_pages'>Last</a></li>";
            print "</ul></div><br/>"; 

            // Retrive the user balance and show it in the page
            print "<h2>User balance: " . getUserBalance($user) . "</h2><br />";

            print "Back to <a href='index.php'>home</a>";
        } else if ($choice == 'deposit' && checkUserCredentials($user, $pass) == true) {

            printUserInfo($user);
            
            // Check if the amount inserted from the user is positive, smaller than the maximum int in the db and if it's really and integer 
            if($amount <= 0){
                closeDBandFile("Impossible to deposit a negative or equal to 0 amount!");
            }else if($amount > $MAX_INT_DB){
                closeDBandFile("Impossible to deposit this amount (too big for the type used)!");
            }else if(gettype($amount) != "integer"){
                closeDBandFile("Impossible to deposit an amount that is not an integer.");
            }

            // In case there are no problems with the value that insert the amount in the database
            $stm = $mysqli->prepare("INSERT INTO transfers (user,amount) values (?, ?)");
            $stm->bind_param("si", $user, $amount);

            if ($stm->execute() == false){
                closeDBandFile($stm->error); // In case of error print the error and close the connection with files and mysql 
            }
            
            //$result = $stm->get_result(); // Uncomment if needed

            print("<br>Deposit of $amount for user $user completed successfully!<br />");
            closeDBandFile("<a href='$url_balance'>Load balance page</a>");
        } else if ($choice == 'withdraw' && checkUserCredentials($user, $pass) == true) {

            printUserInfo($user);

            // Check if the amount inserted from the user is positive, smaller than the maximum int in the db and if it's really and integer
            if($amount <= 0){
                closeDBandFile("Impossible to witdraw a negative or equal to 0 amount!");
            }else if($amount > $MAX_INT_DB){
                closeDBandFile("Impossible to witdraw this amount (too big for the type used)!");
            }else if(gettype($amount) != "integer"){
                closeDBandFile("Impossible to witdraw an amount that is not an integer.");
            }

            // Get the user balance in order to check if applying the witdraw the balance become negative
            $user_amount = getUserBalance($user);

            // Check that the user can perform the withdraw operation
            if($user_amount == 0){
                closeDBandFile("Impossible to witdraw money if the user has a balance equal to 0.");
            } else if($user_amount < $amount){
                closeDBandFile("Impossible to witdraw an amount of money bigger that the user balance.");
            }

            // Invert the amount since it's a withdraw
            $new_amount = -$amount;

            // In case there are no problems with the value that insert the amount in the database
            $stm = $mysqli->prepare("INSERT INTO transfers (user,amount) values (?, ?)");
            $stm->bind_param("si", $user, $new_amount);
            
            if ($stm->execute() == false){
                closeDBandFile($stm->error); // In case of error print the error and close the connection with files and mysql 
            }
            
            //$result = $stm->get_result(); // Uncomment if needed

            print("<br>Withdraw of $amount for user $user completed successfully!<br />");
            closeDBandFile("<a href='$url_balance'>Load balance page</a>");
        } else {
            printUserInfo($user);
            print "<br>The specified operation is not allowed!<br />";
            print "<br>Back to <a href='index.php'>home</a><br />";
        }

        // Log data for scoring
        $query = "SELECT * FROM transfers";
        $result = $mysqli->query($query);
        fwrite($fh, "TRANSFERS\n");
        while ($row = $result->fetch_array()) {
            fwrite($fh, $row['user'] . " " . $row['amount'] . "\n");
        }
        
        $query = "SELECT * FROM users";
        $result = $mysqli->query($query);
        fwrite($fh, "USERS\n");
        while ($row = $result->fetch_array()) {
            fwrite($fh, $row['user'] . " " . $row['pass'] . "\n");
        }
        // END Log data for scoring

        // Close connection to file and mysql
        $mysqli->close();
        fclose($fh);
        fclose($fh_myLog);

        /*
        * Print welcome message when user is registered 
        * $user username to set in the message
        */
        function printUserInfo($user){
            print "<h1>Welcome $user</h1><br />";
        }

        /*
        * Close the connection to file and mysql if an error or something bad happen
        * $message Message to insert as content in the page
        */
        function closeDBandFile($message){
            $GLOBALS['mysqli']->close();
            fclose($GLOBALS['fh']);
            fclose($GLOBALS['fh_myLog']);
            print "$message<br />";
            exit("Back to <a href='index.php'>home</a><br />" . " </body><html>");
        }
        
        /*
        * Get the user balance from the database
        * $user Username of the user we need to recover the balance
        * return balance of the user
        */
        function getUserBalance($user){
            $stm = $GLOBALS['mysqli']->prepare("SELECT SUM(amount) as amount FROM transfers where user = ? ");
            $stm->bind_param("s", $user);

            if ($stm->execute() == false){
                closeDBandFile($stm->error); // In case of error print the error and close the connection with files and mysql 
            }

            $result = $stm->get_result(); // Retrieve the information from the database
            $row = $result->fetch_array();
            $amount = $row['amount'];  

            // If the result set is empty than set the amount to 0
            if(!$amount){
                $amount = 0;
            }
            
            return $amount;
        }

        /*
        * Check the user credential, in the specific retrieve the digest of the password and checks it with password_verify function
        * $user Username of the user we need to check the credentials
        * $pass Password inserted
        * return outcome of the password digest check
        */
        function checkUserCredentials($user, $pass){
            $stm = $GLOBALS['mysqli']->prepare("SELECT pass FROM users WHERE user = ?");
            $stm->bind_param("s", $user);

            if ($stm->execute() == false){
                closeDBandFile($stm->error); // In case of error print the error and close the connection with files and mysql 
            }

            $result = $stm->get_result();
            $row = $result->fetch_array();
            if(!password_verify($pass, $row['pass'])){ // Password is check using the digest verification funciton of php
                closeDBandFile("User doesn't exist in the system or the combination user and password used is wrong, retry!");
                return false;
            }

            return true;
        }

        ?>

    </body>

</html>
