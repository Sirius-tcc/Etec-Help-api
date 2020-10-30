<?php
    include('Custom/UploadVideo.php');

    class Video {

        private $VIDEO_PATH = 'uploads/videos/';
        private $VIDEO_PATH_HTTP = 'http://localhost/Coisas/backend/uploads/videos/';


        function __construct()
        {
            $this->con = Connection::getConnection();
        }


        public function list()
        {
            $sql = "SELECT * FROM vwVideos";

            $sql = $this->con->prepare($sql);

            $sql->execute();


            $result = array();
            while($row = $sql->fetch(PDO::FETCH_ASSOC)){
                $row['code'] = (int) $row['code'];
                $row['url'] = $this->VIDEO_PATH_HTTP.$row['url'];
                $result[] = $row;
            }

            if(!$result){
                throw new Exception("Nenhum video cadastrado");
            }

            return $result;
        }


        public function show($id)
        {
            $sql = "SELECT * FROM vwVideos WHERE code = $id";
            $sql = $this->con->prepare($sql);

            $sql->execute();

            $result = array();

            while($row = $sql->fetch(PDO::FETCH_ASSOC)){
                $row['code'] = (int) $row['code'];
                $row['url'] = $this->VIDEO_PATH_HTTP.$row['url'];
                $result[] = $row;
            }

            if(!$result){
                throw new Exception("Nenhum video cadastrado com esse id.");
            }

            return $result;
        }


        public function create()
        {
           
           if(
               isset($_FILES['video']) &&
               isset($_POST['title']) &&
               isset($_POST['description']) &&
               isset($_POST['code_topic']) 
           ){
                $video = $_FILES['video'];
                $title = $_POST['title'];
                $description = $_POST['description'];
                $code_topic = $_POST['code_topic'];

                try {
                    $sql = "INSERT INTO tbVideo(titulo_video, descricao_video, cod_topico) 
                    VALUE( '$title', '$description', '$code_topic' )";
                    $sql = $this->con->prepare($sql);
                    $sql->execute();

                    $id = "SELECT MAX(code) as id FROM vwVideos";
                    $id = $this->con->prepare($id);
                    $id->execute();
                    $id = $id->fetch(PDO::FETCH_ASSOC)['id'];
                    
                    
                    $uploadImage = new UploadVideo( 
                        $id, 
                        $video, 
                        $this->VIDEO_PATH
                    );

                    return $uploadImage->upload();

                }catch (Exception $e ){
                    throw new Exception('Erro ao criar usuário. Erro: ' . $e->getMessage());
                }

           }
        }


        public function delete($id)
        {
            try{
                $video = $this->VIDEO_PATH . $id . "." . "mp4";
                
                if (file_exists($video)) {
                    unlink($video);
                }

                $sql = "CALL sp_delete_video($id)";
                $this->con->exec($sql);

                return 'Exclusão realizada com sucesso';

            }catch(Exception $e){
                
                if($e->getCode() == "42S02"){ throw new Exception("Video não existe."); }

                throw new Exception('Erro ao deletar usuário. Erro: ' . $e->getMessage());
            }
        }


    }


   