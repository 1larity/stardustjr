<?php

DEFINE('DBUSER', 'Playeraccount');
DEFINE('DBPW', 'akira01');
DEFINE('DBHOST', 'localhost');
DEFINE('DBNAME', 'test');


function updateplanets()
{
    try {
        $dbh = new PDO("mysql:host=" . DBHOST . ";dbname=" . DBNAME, DBUSER, DBPW);
        
        // select solarsystems with players in them
        $sql = "SELECT x,y,z,sysname, player_account_UID FROM playercharsinsystem WHERE online ='1'";
        $result = $dbh->query($sql);
        foreach ($result as $row)
       //     echo ("found player in system" . $row['sysname']);
        // we need the accountname so we update the correct client
        $usersql = "SELECT account_id from player_account WHERE UID='" . $row['player_account_UID'] . "'";
    //    echo ($usersql . "\n");
        $userresult = $dbh->query($usersql);
        $userrow = $userresult->fetch();
        //echo ("user " . $userrow['account_id'] . "\n");
        $user = $userrow['account_id'];
        {
            
            // select the planets in the system
            $planetsql = "Select * FROM system_resources WHERE x ='" . $row['x'] . "' and y='" . $row['y'] . "' and z='" . $row['z'] . "'";
            $planetresult = $dbh->query($planetsql);
            foreach ($planetresult as $planetrow) {
                //echo ("processing structure \n" . $planetrow['structname']);
                // don't rotate suns
                if ($planetrow['angularvelocity'] != 0) {
                    orbit($planetrow['sysx'], $planetrow['sysy'], $planetrow['angle'], $planetrow['angularvelocity'], $planetrow['orbit'], $planetrow['uid'], $dbh, $user);
                }
            }
        }

    } catch (PDOException $e) {
        //echo $e->getMessage();
    }
}

function orbit($x, $y, $angle, $av, $radius, $uid, &$dbh, $user)
{
    // probably should use sun pos here
    $centreX = 1000;
    $centreY = 1000;
    // get new theta
    $angle = $angle + $av;
    //echo (" angle " . $angle . " av " . $av . "newangle " . $angle . "\n");
    // reset any planet over one orbit to start position + offset
    if ($angle > 360) {
        $angle = 360 - $angle;
    }
    
    $resultX = $centreX + $radius * cos($angle);
    $resultY = $centreY + $radius * sin($angle);
    // newPosition= nextArcStep($centreX, $centreY, $orbit , $angle);
    $orbitsql = "UPDATE structures set sysx=" . $resultX . ", sysy=" . $resultY . ", angle=" . $angle . " WHERE UID='" . $uid . "'";
    //echo ($orbitsql . "\n");
    $stmt = $dbh->prepare($orbitsql);
    $stmt->execute();
    sendPlayerOrbitData($resultX, $resultY, $user, $uid);
    // db update here
}

?>