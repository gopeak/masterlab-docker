<?php

$user = 'root';
$pass = 'root';
$server = '172.24.0.103';

$dbh = new PDO( "mysql:host=$server", $user, $pass );
$dbs = $dbh->query( 'SHOW DATABASES' );

while( ( $db = $dbs->fetchColumn( 0 ) ) !== false )
{
    echo $db.'<br>';
}