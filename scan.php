<?php
 class Scan {
            // Creating some properties (variables tied to an object)
            public $clientID;
            public $started;
            public $ticks=0;
            // Assigning the values
            public function __construct($clientID, $started) {
              $this->clientID = $clientID;
              $this->started = $started;
            }
            
            // Creating a method (function tied to an object)
        //    public function greet() {
        //        return "Hello, my name is " . $this->firstname . " " . $this->lastname . ". Nice to meet you! :-)";
            }
 
 class basechardata{
     public $systemX;
     public $systemY;
     public $systemZ;
     public $shipX;
     public $shipY;
     public $systemname;
    
     public function __construct() {
         $this->systemX = 0;
         $this->systemY = 0;
         $this->systemZ = 0;
         $this->shipX = 0;
         $this->shipY = 0;
         $this->systemname = "";
     }
 }
?>