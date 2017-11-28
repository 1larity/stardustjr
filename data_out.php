<?php
//main queries and messages for clients
function sendPlayerSolarSystemData($iClientID,$systemX,$systemY,$systemZ, $dbh){
    $sql = "SELECT * FROM system_resources WHERE x ='".$systemX. "' and y='".$systemY."' and z='".$systemZ."'";
    writelog("solar system query ".$sql);
    
    $result = $dbh->query($sql);
    writelog("system data rows:".$result->rowcount());
    foreach ($result as $row)
    {
        writelog ($row['structname'] . " " .$row['angle']."\n");
        $worldStateMessage = new NetworkMessage();
        $worldStateMessage->AddNetworkMessageInteger(9001) // Message identifier for solar system data
        //add current data to net message
        ->AddNetworkMessageString($row['structname'])
        ->AddNetworkMessageInteger($row['orbit'])
        ->AddNetworkMessageFloat($row['angularvelocity'])
        ->AddNetworkMessageFloat($row['sysx'])
        ->AddNetworkMessageFloat($row['sysy'])
        ->AddNetworkMessageFloat($row['angle'])
        ->AddNetworkMessageInteger($row['uid'])
        ->Send($iClientID);
    }
    //  $row = $result->fetch();
}

//send meesage to client that user is known
function sendwelcomeknownplayer($iClientID){
    writelog("Player match at login, sending welcome to id ".$iClientID);
    $newUser = new NetworkMessage();
    $newUser->AddNetworkMessageInteger(9009) // Message identifier for unknown user
    ->AddNetworkMessageString( 'Welcome Back')
    ->Send($iClientID);
}
//send updated orbit data to player
function sendPlayerOrbitData($resultX,$resultY,$iClientID,$planetID){
    $newUser = new NetworkMessage();
    $newUser->AddNetworkMessageInteger(9002) // Message identifier for unknown user
    ->AddNetworkMessageInteger($planetID)
    ->AddNetworkMessageFloat($resultX)
    ->AddNetworkMessageFloat($resultY)
    ->Send($iClientID);
}

//send message to client that the user has not been recognised
function sendunknownplayerwecome($iClientID){
    writelog("no player name match at login");
    $newUser = new NetworkMessage();
    $newUser->AddNetworkMessageInteger(9009) // Message identifier for unknown user
    ->AddNetworkMessageString( 'Unknown user')
    ->Send($iClientID);
}

function sendbasechardata($iClientID, $dbh,$UID){
    $sql = "SELECT * FROM playercharsinsystem WHERE player_account_UID ='".$UID. "'";
    writelog("base character data query ".$sql);
    
    $result = $dbh->query($sql);
    $row = $result->fetch();
    
    writeLog( 'Player selected: UID ' . $row['player_account_UID'] .' - Name'. $row['firstname']);
    writeLog('systemname is '.$row['sysname']);
    //send data
    $characterData = new NetworkMessage();
    $characterData->AddNetworkMessageInteger(9007) // Message identifier for character data
    //add firstname from DB
    ->AddNetworkMessageString( $row['firstname'])
    //add surname from DB
    ->AddNetworkMessageString( $row['surname'])
    //add ship co-ords from DB
    ->AddNetworkMessageInteger( $row['sysx'])
    ->AddNetworkMessageInteger( $row['sysy'])
    //add credits from DB
    ->AddNetworkMessageInteger( $row['bluecredits'])
    ->AddNetworkMessageInteger( $row['redcredits'])
    ->AddNetworkMessageInteger( $row['greencredits'])
    ->Send($iClientID);
   
    //clunky return value because PHP doesn't support multiple constructors :p
    $result = new basechardata();
    $result->systemX=$row['x'];
    $result->systemY=$row['y'];
    $result->systemZ=$row['z'];
    $result->shipX=$row['sysx'];
    $result->shipY=$row['sysy'];
    $result->systemname=$row['sysname'];
    return $result;
}
?>