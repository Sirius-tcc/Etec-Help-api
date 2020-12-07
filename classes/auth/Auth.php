<?php

    class Auth {

        private $key =  '40028922-3t3c-h3lp-4pl1c4t10n-k3y-40028922';


        public function createToken($id, $type ) 
        {
            
             //Header Token
             $header = [
                 'typ' => 'JWT',
                 'alg' => 'HS256'
             ];

             //Payload - Content
             $payload = [
                 'id' => $id,
                 'type' => $type,
             ];

             //JSON
             $header = json_encode($header);
             $payload = json_encode($payload);

             //Base 64
             $header = $this->base64urlEncode($header);
             $payload = $this->base64urlEncode($payload);

             //Sign
             $sign = hash_hmac('sha256', $header . "." . $payload, $this->key, true);
             $sign = $this->base64urlEncode($sign);

             //Token
             $token = $header . '.' . $payload . '.' . $sign;

             return $token;
             
        }

        public function checkAuth()
        {
            $http_header = apache_request_headers();

            if (isset($http_header['Authorization']) && $http_header['Authorization'] != null) {
                $bearer = explode (' ', $http_header['Authorization']);
                //$bearer[0] = 'bearer';
                //$bearer[1] = 'token jwt';


                $token = explode('.', $bearer[1]);

                if( sizeof($token) !== 3){ return false; }
                
                $header = $token[0];
                $payload = $token[1];
                $sign = $token[2];

                

                //Conferir Assinatura
                $valid = hash_hmac('sha256', $header . "." . $payload, $this->key, true);
                $valid = $this->base64urlEncode($valid);

                if ($sign === $valid) {
                    return true;
                }
            }

            return false;
        }


        private function base64urlEncode($data)
        {
            // First of all you should encode $data to Base64 string
            $b64 = base64_encode($data);

            // Make sure you get a valid result, otherwise, return FALSE, as the base64_encode() function do
            if ($b64 === false) {
                return false;
            }

            // Convert Base64 to Base64URL by replacing “+” with “-” and “/” with “_”
            $url = strtr($b64, '+/', '-_');

            // Remove padding character from the end of line and return the Base64URL result
            return rtrim($url, '=');
        }

        private function base64url_decode($data, $strict = false)
        {
            // Convert Base64URL to Base64 by replacing “-” with “+” and “_” with “/”
            $b64 = strtr($data, '-_', '+/');
            // Decode Base64 string and return the original data
            return base64_decode($b64, $strict);
        }
    }


    //return json_decode($this->base64url_decode($teste[1]));
