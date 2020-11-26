<html>

<body>
    <?php
    $myFile = "/tmp/request.log";
    $fh = fopen($myFile, 'a');

    fwrite($fh, "===================================\n");
    foreach ($_GET as $key => $value) {
        fwrite($fh, $key . " => " . $value . "\n");
    }
    
    // Defined to check if the variable is not bigger than sql integer
    $MAX_INT_DB = 2147483647;
    
    //Check if the user setted all the variables
    if(isset($_GET["user"])){
        $user = htmlentities($_GET["user"]);
        if(strlen($user) > 20){
            fclose($fh);
            exit("Username is too big. </body></html>");
        }
    } else {
        // Since no username has been provided block the execution
        fclose($fh);
        exit("No username provided </body></html>");
    }
    
    if(isset($_GET["pass"])){
        $pass = $_GET["pass"];
    } else {
        fclose($fh);
        exit("No password provided </body></html>");
    }

    if(isset($_GET["drop"])){
        $choice = htmlentities($_GET["drop"]);
    } else {
        $choice = ""; 
    }

    if(isset($_GET["amount"])){
        $amount = intval($_GET["amount"]);
    } else {
        $amount = 0;
    }

    // Connect to the database
    $mysqli = new mysqli('localhost', 'php_user', '|AttackersWontFindOut@', 'ctf2');
    if (!$mysqli) {
        fclose($fh);
        exit('Could not connect: ' . $mysqli->error());
    }

    $url = "process.php?user=$user&pass=$pass&drop=balance";
    
    // Using the parameter $choise to perform the different operations
    if ($choice == 'register') {
        $stm = $mysqli->prepare("INSERT INTO users (user, pass) VALUES (?, ?)");
        $stm->bind_param("ss", $user, password_hash($pass, PASSWORD_DEFAULT));

        if ($stm->execute() == false){
            closeDBandFile($stm->error); //In case of error print the error and close the connection with file and mysql 
        }

        $result = $stm->get_result();

        print "User $user successfully!";
        closeDBandFile('<script type="text/javascript">window.location.href="' . $url . '"; </script>');
    } else if ($choice == 'balance' && checkUserCredentials($user, $pass) == true) {  
        // Limit balance to the last 10 user operations
        $stm = $mysqli->prepare("SELECT * FROM transfers WHERE user = ? ORDER BY id DESC LIMIT 10");
        $stm->bind_param("s", $user);

        if ($stm->execute() == false){
            closeDBandFile($stm->error); //In case of error print the error and close the connection with file and mysql 
        }

        $result = $stm->get_result();

        $sum = 0;
        print "<h1>Balance and transfer history of last 10 transactions for $user</h1>";
        print "<table border=1><tr><th>Action</th><th>Amount</th></tr>";
        while ($row = $result->fetch_array()) {
            $amount = $row['amount'];
            if ($amount < 0) {
                $action = "Withdrawal";
            } else {
                $action = "Deposit";
            }
            print "<tr><td>" . $action . "</td><td>" . $amount . "</td></tr>";
        }

        print "<tr><td>Total</td><td>" . getUserBalance($user) . "</td></tr></table>";
        print "Back to <a href='index.php'>home</a>";
    } else if ($choice == 'deposit' && checkUserCredentials($user, $pass) == true) {
        
        // Check if the amount inserted from the user is positive, smaller than the maximum int in the db and if it's really and integer 
        if($amount < 0){
            closeDBandFile("Impossible to deposit a negative amount!");
        }else if($amount > $MAX_INT_DB){
            closeDBandFile("Impossible to deposit this amount (too big for the type used)!");
        }else if(gettype($amount) != "integer"){
            closeDBandFile("Impossible to deposit an amount that is not an integer.");
        }

        $stm = $mysqli->prepare("INSERT INTO transfers (user,amount) values (?, ?)");
        $stm->bind_param("si", $user, $amount);

        if ($stm->execute() == false){
            closeDBandFile($stm->error); //In case of error print the error and close the connection with file and mysql 
        }
        
        $result = $stm->get_result();

        print("Deposit of $amount for user $user completed successfully!");
        closeDBandFile('<script type="text/javascript">window.location.href="' . $url . '"; </script>');
    } else if ($choice == 'withdraw' && checkUserCredentials($user, $pass) == true) {

        // Check if the amount inserted from the user is positive, smaller than the maximum int in the db and if it's really and integer
        if($amount < 0){
            closeDBandFile("Impossible to witdraw a negative amount!");
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

        // Invert the amount
        $new_amount = -$amount;

        $stm = $mysqli->prepare("INSERT INTO transfers (user,amount) values (?, ?)"); //Check how to remove money
        $stm->bind_param("si", $user, $new_amount);
        
        if ($stm->execute() == false){
            closeDBandFile($stm->error); //In case of error print the error and close the connection with file and mysql 
        }
        
        $result = $stm->get_result();

        print("Withdraw of $amount for user $user completed successfully!");
        closeDBandFile('<script type="text/javascript">window.location.href="' . $url . '"; </script>');
    } else {
        print "The specified operation is not allowed!";
        closeDBandFile('<script type="text/javascript">window.location.href="' . $url . '"; </script>');
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

    // Close connection to file and mysql
    $mysqli->close();
    fclose($fh);

    /*
    * Close the connection to file and mysql if an error or something bad happen
    * $message Message to insert as content in the page
    */
    function closeDBandFile($message){
        $GLOBALS['mysqli']->close();
        fclose($GLOBALS['fh']);
        exit($message . " </body><html>");
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
            closeDBandFile($stm->error); //In case of error print the error and close the connection with file and mysql 
        }

        $result = $stm->get_result();
        $row = $result->fetch_array();
        $amount = $row['amount'];  
        
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
            closeDBandFile($stm->error); //In case of error print the error and close the connection with file and mysql 
        }

        $result = $stm->get_result();
        $row = $result->fetch_array();
        if(!password_verify($pass, $row['pass'])){
            closeDBandFile("User doesn't exist in the system or the combination user and password used is wrong, retry!");
            return false;
        }

        return true;
    }

    ?>

</body>

</html>
