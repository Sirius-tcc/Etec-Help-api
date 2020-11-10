<?php 
    class ConstVariable 
    {
        public $localhost;
        public $port;
        public $host;
        public $baseUrl;
        
        function __construct()
        {
            $this->localhost = "localhost";
            $this->port = "8080";
            $this->host = "$this->localhost:$this->port";
            $this->baseUrl = "$this->host/Coisas/backend/";
        }
        
    }