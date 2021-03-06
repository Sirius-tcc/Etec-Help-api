<?php

    require_once 'Connection.php';

    
    class Helper {
        private $con;
        private $IMAGE_PATH_HTTP;
        private $IMAGE_PATH = 'uploads/images/helper/';


        function __construct()
        {
            $this->con = Connection::getConnection();
            
            $const = new ConstVariable();
            $this->IMAGE_PATH_HTTP = "$const->baseUrl" . "$this->IMAGE_PATH";
        }


        public function list()
        {
            if(
                isset($_GET['subject'])   && 
                $_GET['subject'] != ''
            ){
                $subject = $_GET['subject'];
                // filtrar helper por 
                $sql = "SELECT code, photo, name, surname, bio, email FROM vwHelper
                        LEFT JOIN tbMateriaHelper
                        ON tbMateriaHelper.cod_helper = vwHelper.code
                        LEFT JOIN tbMateria
                        ON tbMateria.cod_materia = tbMateriaHelper.cod_materia
                        WHERE tbMateria.nome_materia = '$subject'";

            }else{ 
                $sql = "SELECT * FROM vwHelper"; 
            }
            
            $sql = $this->con->prepare($sql);

            $sql->execute();

            $result = array();

            while($row = $sql->fetch(PDO::FETCH_ASSOC)){

                $row['code'] = (int) $row['code'];
                $row['photo'] = $row['photo'] === null ? $row['photo'] : $this->IMAGE_PATH_HTTP.$row['photo'];

                // pegar as ajudas dadas por cada helper
                $helps= "SELECT COUNT(tbAjuda.cod_helper) as helps FROM vwHelper 
                INNER JOIN tbAjuda
                ON tbAjuda.cod_helper = vwHelper.code
                WHERE vwHelper.code =" .  $row['code'] . " AND tbAjuda.cod_status = 2";
                $helps = $this->con->prepare($helps);
                $helps->execute();
                $row['helps'] = (int) $helps->fetch(PDO::FETCH_ASSOC)['helps'];

                // pegar as matérias do helper
                $subj = "SELECT subject FROM vwSubjectHelpers WHERE helper_code = ". $row['code'] ." ";
                $subj = $this->con->prepare($subj);
                $subj->execute();

                $subjects = array();

                while($sub = $subj->fetch(PDO::FETCH_ASSOC)) {
                    $subjects[] = $sub['subject'];
                }

                $row['subjects'] = $subjects;

                
                // pegar as estrelas
                $classification = "CALL sp_show_classification_helper(" .  $row['code'] . ")";
                $classification = $this->con->prepare($classification);
                $classification->execute();

                $row['classification'] = (int) $classification->fetch(PDO::FETCH_ASSOC)['classification'];

                $result[] = $row;
            }

            if(!$result){ throw new Exception("Nenhum Helper cadastrado"); }

            return $result;
        }


        public function show($id)
        {
            $sql = "SELECT * FROM vwHelper WHERE code = $id";
            $sql = $this->con->prepare($sql);

            $sql->execute();

            $result = array();

            while($row = $sql->fetch(PDO::FETCH_ASSOC)){
                $row['code'] = (int) $row['code'];
                $row['photo'] = $row['photo'] === null ? $row['photo'] : $this->IMAGE_PATH_HTTP.$row['photo'];


                // pegar as matérias do helper
                $subj = "SELECT subject FROM vwSubjectHelpers WHERE helper_code = ". $row['code'] ." ";
                $subj = $this->con->prepare($subj);
                $subj->execute();

                $subjects = array();

                while($sub = $subj->fetch(PDO::FETCH_ASSOC)) {
                    $subjects[] = $sub['subject'];
                }

                $row['subjects'] = $subjects;

                
                // pegar as estrelas
                $classification = "CALL sp_show_classification_helper(" .  $row['code'] . ")";
                $classification = $this->con->prepare($classification);
                $classification->execute();


                $row['classification'] = (int) $classification->fetch(PDO::FETCH_ASSOC)['classification'];

                $result[] = $row;
            }

            if(!$result){
                throw new Exception("Nenhum helper com esse id");
            }

            return $result;
        }

        public function upload_profile($id)
        {
            $imageUploaded = $_FILES['helper_photo'];
            $uploadImage = new UploadImage( 
                $id, 
                $imageUploaded, 
                $this->IMAGE_PATH 
            );
            return $uploadImage->upload('sp_save_photo_helper_name');

        }

        public function create()
        {
            $json = file_get_contents("php://input");

            if($json != ''){
                $array_data = array();
    
                $array_data = json_decode($json, true);
                
            
                $name = $array_data['name'];
                $surname = $array_data['surname'];
                $email = $array_data['email'];  
                $password = sha1( $array_data['password'] );
    
                try {
                    $sql = "CALL sp_create_helper('$name', '$surname', '$email', '$password')";

                    $this->con->exec($sql);
    
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
        }


        public function update($id)
        {
            $json = file_get_contents("php://input");


            if($json != ''){
                $array_data = array();

                $array_data = json_decode($json, true);

                if($array_data != null) {

                    $name = $array_data['name'];
                    $surname = $array_data['surname'];
                    $bio = $array_data['bio'];
                    $email = $array_data['email'];  
                    
                    try{
                        $sql = "CALL sp_update_helper($id, '$name', '$surname', '$bio', '$email')";
        
                        $this->con->exec($sql);
        
                        return 'Atualização realizada com sucesso';
        
                    } catch(Exception $e) {

                        if($e->getCode() == "42S02"){ throw new Exception("Id do Helper não existe."); }

                        throw new Exception('Erro ao atualizar os dados do banco. Erro: ' . $e->getMessage());
                    }
                }else{
                    throw new Exception('Erro ao decodificar o arquivo json. Verifique se ele foi passado corretamente.');
                }
            }else{
                throw new Exception('empty json');
            }

        }


        public function delete($id)
        {
            try{
                $profile_photo = $this->IMAGE_PATH . $id . "." . "png";
                
                if (file_exists($profile_photo)) {
                    unlink($profile_photo);
                }
                
                $sql = "CALL sp_delete_helper($id)";

                $this->con->exec($sql);

                return 'Exclusão realizada com sucesso';

            }catch(Exception $e){
                if($e->getCode() == "42S02"){ throw new Exception("Id do Helper não existe."); }

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
                        $sql = "SELECT cod_helper AS code
                                FROM tbHelper WHERE senha_helper = '$password' AND email_helper = '$email'";

                        $sql = $this->con->prepare($sql);

                        $sql->execute();
                        $user = $sql->fetch(PDO::FETCH_ASSOC);

                        if(!$user) { throw new Exception("Email ou senha incorretos"); }

                        $user['code'] = (int) $user['code'];
                        
                        $id = $user['code'];
                        $type = "helper";
                        
                        $auth = new Auth();

                        return $auth->createToken( $id, $type );

                    }catch(Exception $e){ 
                        throw new Exception( $e->getMessage());
                    }

                }

            }
        }
        

        public function create_subject_helper($id) {
            $json = file_get_contents("php://input");
            if( $json != '' ){

                $data = array();
                $data = json_decode($json, true);
                
                if($data != null) { 
                    $subject_code = $data['subject_code'];

                    try {
                        $sql = "CALL sp_create_subject_helper($id, $subject_code)";

                        $this->con->exec($sql);
        
                        return 'Cadastro realizado com sucesso';
    
                    }catch(Exception $e){
                        if($e->getCode() == "42S02") {
                            throw new Exception('Essa matéria já é cadastrado!');
                        }
    
                        throw new Exception("Erro ao cadastrar " . $e->getMessage());
                    }

                } else {
                    throw new Exception('Erro ao decodificar o arquivo json. Verifique se ele foi passado corretamente.');
                }
 
            }else{
                throw new Exception('No empty json');
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
                        $sql = "CALL sp_check_helper('$email')";
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

        public function delete_subject($helper_code){

            $json = file_get_contents("php://input");
            
            if(trim($json) != '')
            {
                $array_data = array();
                $array_data = json_decode($json, true);

                if ($array_data != null)
                {

                    $subject_code = $array_data['subject_code'];  

                    try{
                
                        $sql = "CALL sp_delete_subject($helper_code, $subject_code)";
        
                        $this->con->exec($sql);
        
                        return 'Exclusão realizada com sucesso';
        
                    }catch(Exception $e){
                        if($e->getCode() == "42S02"){ throw new Exception("Id do Helper não existe ou matéria"); }
                        
                        throw new Exception('Erro ao deletar usuário. Erro: ' . $e->getMessage());
                    }

                } else {
                    throw new Exception('Erro ao decodificar o arquivo json. Verifique se ele foi passado corretamente.');
                }
            }else{
                throw new Exception('No empty json');
            }
        }
    }

    
    

    /*
      SELECT code, photo, name, surname, bio, email FROM vwHelper
LEFT JOIN tbMateriaHelper
ON tbMateriaHelper.cod_helper = vwHelper.code
LEFT JOIN tbMateria
ON tbMateria.cod_materia = tbMateriaHelper.cod_materia
WHERE tbMateria.nome_materia = 'Programação'*/

