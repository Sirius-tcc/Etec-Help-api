<?php
    require_once('Connection.php');

    class Topic {

        private $IMAGE_PATH = "uploads/images/icon/";
        private $IMAGE_PATH_HTTP = "http://localhost/Coisas/backend/uploads/images/icon/";


        function __construct() 
        {
            $this->con = Connection::getConnection();
        }


        public function list($subject)
        {
            $sql = "SELECT * FROM vwTopico WHERE subject = '$subject'";

            $sql = $this->con->prepare($sql);

            $sql->execute();


            $result = array();
            while($row = $sql->fetch(PDO::FETCH_ASSOC)){
                $row['code'] = (int) $row['code'];
                $row['icon'] = $this->IMAGE_PATH_HTTP . $row['icon'];
                $result[] = $row;
            }

            if(!$result){
                throw new Exception("Nenhum tópico chamado $subject");
            }

            return $result;
        }


        public function create($subject)
        {
            
           if(
                isset($_FILES['icon']) &&
                isset($_POST['name']) &&
                isset($_POST['subject_code']) 
            ){
                $icon = $_FILES['icon'];
                $name = $_POST['name'];
                $subject_code = (int) $_POST['subject_code'];


                try{
                    $sql = "CALL sp_create_topic('$name', $subject_code)";

                    $sql = $this->con->prepare($sql);

                    $sql->execute();

                    $id = "SELECT MAX(cod_topico) as id FROM tbTopico";
                    $id = $this->con->prepare($id);
                    $id->execute();
                    $id = $id->fetch(PDO::FETCH_ASSOC)['id'];

                    $imageUploaded = $icon;
                    $uploadImage = new UploadImage( 
                        $id, 
                        $imageUploaded, 
                        $this->IMAGE_PATH,
                        'svg'
                    );

                    $uploadImage->upload('sp_save_photo_topic_name');

                    return 'Cadastro realizado com sucesso';

                }catch(Exception $e){
                    if($e->getCode() == "42S02"){
                        throw new Exception('Este código do tópico não existe.');
                    }

                    throw new Exception("Erro ao cadastrar " . $e->getMessage());
                }

            }else{
                throw new Exception('Erro: Algum valor passado não está setado.');
            }

                
        }

    }