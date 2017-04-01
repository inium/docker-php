<?php 
/**
 * PDO example
 * @see https://www.w3schools.com/php/php_mysql_connect.asp
 */
$servername = getenv('DB_PORT_3306_TCP_ADDR');
$username = "root";
$password = getenv('DB_ENV_MYSQL_ROOT_PASSWORD');

try {
  $conn = new PDO("mysql:host=$servername", $username, $password);
  // set the PDO error mode to exception
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
  echo "Connected successfully"; 
}
catch(PDOException $e)
{
  echo "Connection failed: " . $e->getMessage();
}

?>