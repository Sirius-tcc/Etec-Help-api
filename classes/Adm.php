<?php 
    require_once 'Connection.php';

    class Adm{ 
        function __construct()
        {
            $this->con = Connection::getConnection();            
        }

        public function login() 
        {
        
            $json = file_get_contents("php://input");

            if(trim($json) != '')
            {
                $array_data = array();
                $array_data = json_decode($json, true);

                if ($array_data != null)

                {
                    $email = $array_data['email'];
                    $password = sha1($array_data['password']);
                    try{
                        $sql = "SELECT cod_admin AS code
                                FROM tbAdmin WHERE senha_admin = '$password' AND email_admin = '$email'";

                        $sql = $this->con->prepare($sql);

                        $sql->execute();
                        $user = $sql->fetch(PDO::FETCH_ASSOC);

                        if(!$user) { throw new Exception("Email ou senha incorretos"); }

                        $user['code'] = (int) $user['code'];
                        
                        $id = $user['code'];
                        $type = "adm";
                        
                        $auth = new Auth();

                        return $auth->createToken( $id, $type );

                    }catch(Exception $e){ 
                        throw new Exception( $e->getMessage());
                    }

                }

            }
        }
    }