 <?php
/*** mysql hostname ***/
$hostname = 'localhost';

/*** mysql username ***/
$username = 'Playeraccount';

/*** mysql password ***/
$password = 'akira01';

try {
    $dbh = new PDO("mysql:host=$hostname;dbname=test", $username, $password);
    /*** echo a message saying we have connected ***/
    echo 'You Connected to database<br />';

    /*** The SQL SELECT statement ***/
    $sql = "SELECT * FROM news";
    foreach ($dbh->query($sql) as $row)
        {
        print $row['news_title'] .' - '. $row['news_text'] . '<br />';
        }

    /*** close the database connection ***/
    $dbh = null;
}
catch(PDOException $e)
    {
    echo $e->getMessage();
    }
?>
