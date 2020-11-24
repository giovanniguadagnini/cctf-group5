<html>

<body>
    <?php
    $myFile = "/tmp/request.log";
    $fh = fopen($myFile, 'a');

    fwrite($fh, "===================================\n");
    foreach ($_GET as $key => $value) {
        fwrite($fh, $key . " => " . $value . "\n");
    }
    
    $MAX_INT_DB = 2147483647;
    if(isset($_GET["user"]))
        $user = htmlentities($_GET["user"]);
    else
        $user = "";

    if(isset($_GET["pass"]))
        $pass = htmlentities($_GET["pass"]);
    else
        $pass = "";    

    if(isset($_GET["drop"]))
        $choice = htmlentities($_GET["drop"]);
    else
        $choice = ""; 

    if(isset($_GET["amount"]))
        $amount = intval($_GET["amount"]);
    else
        $amount = 0;

    $mysqli = new mysqli('localhost', 'php_user', '|AttackersWontFindOut@', 'ctf2');
    if (!$mysqli) {
        die('Could not connect: ' . $mysqli->error());
    }
    $url = "process.php?user=$user&pass=$pass&drop=balance";
    if ($choice == 'register') {
        $stm = $mysqli->prepare("INSERT INTO users (user, pass) VALUES (?, ?)");
        $stm->bind_param("ss", $user, $pass);
        $stm->execute() or die($stm->error());
        $result = $stm->get_result();

        print "User $user successfully!";

        die('<script type="text/javascript">window.location.href="' . $url . '"; </script></body></html>');
    } else if ($choice == 'balance') {  
        /* CHECK USER PASSWORD */
        $stm = $mysqli->prepare("SELECT pass FROM users WHERE user = ?");
        $stm->bind_param("s", $user);
        $stm->execute() or die($stm->error());
        $result = $stm->get_result();
        $row = $result->fetch_array();
        if($row['pass'] != $pass){
            exit("User don't exist in the system or the combination user and password used is wrong, retry!");
        }

        $stm = $mysqli->prepare("SELECT * FROM transfers WHERE user = ? ORDER BY id DESC LIMIT 10");
        $stm->bind_param("s", $user);
        $stm->execute() or die($stm->error());
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

        print "<tr><td>Total</td><td>" . getUserBalance($mysqli, $user) . "</td></tr></table>";
        print "Back to <a href='index.php'>home</a>";
    } else if ($choice == 'deposit') {

        if($amount < 0){
            exit("Impossible to deposit a negative amount!");
        }else if($amount > $MAX_INT_DB){
            exit("Impossible to deposit this amount (too big for the type used)!");
        }else if(gettype($amount) != "integer"){
            exit("Impossible to deposit an amount that is not an integer.");
        }

        //The overflow should only be in the database since php in 64bit architecture have a bigger max value (9223372036854775807)
        if($amount > $MAX_INT_DB || $amount < 0 || gettype($amount) != "integer"){
            exit("Impossible to deposit this amount (overflow detected).");
        }

        $stm = $mysqli->prepare("INSERT INTO transfers (user,amount) values (?, ?)");
        $stm->bind_param("si", $user, $amount);
        $stm->execute() or die($stm->error());
        $result = $stm->get_result();

        print("Deposit of $amount for user $user completed successfully!");

        die('<script type="text/javascript">window.location.href="' . $url . '"; </script></body></html>');
    } else if ($choice == 'withdraw') {

        if($amount < 0){
            exit("Impossible to witdraw a negative amount!");
        }else if($amount > $MAX_INT_DB){
            exit("Impossible to witdraw this amount (too big for the type used)!");
        }else if(gettype($amount) != "integer"){
            exit("Impossible to witdraw an amount that is not an integer.");
        }

        $user_amount = getUserBalance($mysqli, $user);

        if($user_amount == 0){
            exit("Impossible to witdraw money if the user has a balance equal to 0.");
        } else if($user_amount < $amount){
            exit("Impossible to witdraw an amount of money bigger that the user balance.");
        }

        $new_amount = -$amount;

        //The overflow should only be in the database since php in 64bit architecture have a bigger max value (9223372036854775807)
        if($new_amount < -$MAX_INT_DB || $new_amount > 0 || gettype($new_amount) != "integer"){
            exit("Impossible to withraw this amount (overflow detected).");
        }

        $stm = $mysqli->prepare("INSERT INTO transfers (user,amount) values (?, ?)"); //Check how to remove money
        $stm->bind_param("si", $user, $new_amount);
        $stm->execute() or die($stm->error());
        $result = $stm->get_result();

        print("Withdraw of $amount for user $user completed successfully!");

        die('<script type="text/javascript">window.location.href="' . $url . '"; </script></body></html>');
    } else {
        print "The specified operation is not allowed!";
        die('<script type="text/javascript">window.location.href="' . $url . '"; </script></body></html>');
    }

    # Log data for scoring
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
    
    function getUserBalance($mysqli, $user){
        $stm = $mysqli->prepare("SELECT SUM(amount) as amount FROM transfers where user = ? ");
        $stm->bind_param("s", $user);
        $stm->execute() or die($stm->error());
        $result = $stm->get_result();

        $row = $result->fetch_array();
        $amount = $row['amount'];  
        
        return $amount;
    }

    ?>

</body>

</html>