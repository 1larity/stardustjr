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
            public function greet() {
                return "Hello, my name is " . $this->firstname . " " . $this->lastname . ". Nice to meet you! :-)";
            }
 }
?>