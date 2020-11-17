<?php
    require_once('Connection.php');
    include('custom/UploadImage.php');
    
    class Student {
        private $con;
        private $IMAGE_PATH_HTTP;
        private $IMAGE_PATH = 'uploads/images/student/';


        function __construct() 
        {
            $this->con = Connection::getConnection();
            $const = new ConstVariable();
            $this->IMAGE_PATH_HTTP = "$const->baseUrl" . "$this->IMAGE_PATH";
        }

        public function list()
        {
            $sql = "SELECT * FROM vwEstudantes";

            $sql = $this->con->prepare($sql);

            $sql->execute();


            $result = array();
            while($row = $sql->fetch(PDO::FETCH_ASSOC)){
                $row['code'] = (int) $row['code'];
                $row['photo'] = $row['photo'] === null ? $row['photo'] : $this->IMAGE_PATH_HTTP.$row['photo'];
                $result[] = $row;
            }

            if(!$result){
                throw new Exception("Nenhum estudante cadastrado");
            }

            return $result;
        }


        public function show($id)
        {
            $sql = "SELECT * FROM vwEstudantes WHERE code = $id";

            $sql = $this->con->prepare($sql);

            $sql->execute();

            $result = array();

            while($row = $sql->fetch(PDO::FETCH_ASSOC)){
                $row['code'] = (int) $row['code'];
                $row['photo'] = $row['photo'] === null ? $row['photo'] : $this->IMAGE_PATH_HTTP.$row['photo'];
                $result[] = $row;
            }

            if(!$result){
                throw new Exception("Nenhum estudante com esse id");
            }

            return $result;
        }

        
        public function create() 
        {
            $json = file_get_contents("php://input");

            if($json != ''){
                $array_data = array();
                $array_data = json_decode($json, true);

                if ($array_data != null){

                    $name = $array_data['name'];
                    $surname = $array_data['surname'];
                    $email = $array_data['email'];
                    $password = sha1($array_data['password']);

                    try{
                        $sql = "CALL sp_create_estudante ('$name', '$surname', '$email', '$password')";
                        $sql = $this->con->prepare($sql);

                        $sql->execute();

                        return 'Cadastro realizado com sucesso';
        
                    }catch(Exception $e){
                        if($e->getCode() == "42S02"){
                            throw new Exception('E-mail já cadastrado!');
                        }
                        throw new Exception("Erro ao cadastrar " . $e->getMessage());
                    }

                    }else{
                        throw new Exception('No json found');
                    }

                }else{
                    throw new Exception('Erro ao decodificar o arquivo json. Verifique se ele foi passado corretamente.');
                }
                
            
        }
       

        public function upload_profile($id)
        {
            $imageUploaded = $_FILES['student_photo'];

            $uploadImage = new UploadImage( 
                $id, 
                $imageUploaded, 
                $this->IMAGE_PATH 
            );

            return $uploadImage->upload('sp_save_photo_estudante_name');

        }


        public function update($id)
        {
            $json = file_get_contents("php://input");

            if(trim($json) != ''){
                $array_data = array();

                $array_data = json_decode($json, true);

                if ($array_data != null){
                    $name = $array_data['name'];
                    $surname = $array_data['surname'];
                    $email = $array_data['email'];
    
                    try{
                        $sql = "CALL sp_update_estudante($id, '$name', '$surname', '$email')";
                        $this->con->exec($sql);
    
                        return 'Atualização realizada com sucesso';
        
                    } catch(Exception $e) {
                        if($e->getCode() == "42S02"){ throw new Exception("Id do Estudante não existe."); }
                        throw new Exception( 'Erro ao atualizar os dados do banco. Erro: ' . $e->getMessage() );
                    }

                }else{
                    throw new Exception('Erro ao decodificar o arquivo json. Verifique se ele foi passado corretamente.');
                }
                
                
            }else{
                throw new Exception('Não foi passado o arquivo json');
            }
        }


        public function delete($id)
        {
            try{
                $profile_photo = $this->IMAGE_PATH . $id . "." . "png";
                
                if (file_exists($profile_photo)) {
                    unlink($profile_photo);
                }

                $sql = "CALL sp_delete_student($id)";
                $this->con->exec($sql);

                return 'Exclusão realizada com sucesso';

            }catch(Exception $e){
                
                if($e->getCode() == "42S02"){ throw new Exception("Usuário não existe."); }

                throw new Exception('Erro ao deletar usuário. Erro: ' . $e->getMessage());
            }
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
                        $sql = "SELECT cod_estudante AS code, nome_estudante AS name, email_estudante AS email FROM 
                        tbEstudante WHERE senha_estudante = '$password' AND email_estudante = '$email'";

                        $sql = $this->con->prepare($sql);

                        $sql->execute();
                        
                        $user = $sql->fetch(PDO::FETCH_ASSOC);

                        if(!$user) { throw new Exception("Email ou senha incorretos"); }

                        $user['code'] = (int) $user['code'];
                        
                        $id = $user['code'];
                        $name = $user['name'];
                        $email = $user['email'];
                        $type = "student";
                        
                        $auth = new Auth();


                        return $auth->createToken( $id, $name, $email, $type );

                    }catch(Exception $e){ 
                        throw new Exception( $e->getMessage());
                    }

                }

            }
        }

        public function checkLogin()
        {
            $json = file_get_contents("php://input");

            if(trim($json) != '')
            {
                $array_data = array();
                $array_data = json_decode($json, true);
                if ($array_data != null)
                {
                    $email = $array_data['email'];

                    try{
                        $sql = "CALL sp_check_estudante('$email')";
                        $sql = $this->con->prepare($sql);
                        $sql->execute();

                        return "Sucesso: Email não existente no banco de dados";

                    }catch(Exception $e){ 
                        if($e->getCode()=="42S02"){throw new Exception("Email já existente");}
                        throw new Exception( $e->getMessage());
                    }

                }

            }else{
                throw new Exception("No json found");
            }

        }

    }
