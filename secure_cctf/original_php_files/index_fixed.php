<html>
  <head>
    <title>Bank - Login page</title>
  </head>
  <body>

  <form action="process.php" method="get">
    Username: <input type="text" name="user"><br />
    Password: <input type="text" name="pass"><br />
    Amount: <input type="text" name="amount"><br />
    Action: <select name='drop'>
      <option value='balance'>Balance and transfer history</option>
      <option value='register'>Register</option>
      <option value='deposit'>Deposit</option>
      <option value='withdraw'>Withdraw</option>
    </select><br />
    <input type="submit"><br />
  </form>

  </body>
</html>
