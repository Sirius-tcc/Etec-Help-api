<?php
    include('custom/UploadVideo.php');

    class Video {

        private $VIDEO_PATH = 'uploads/videos/';
        private $ICON_PATH = 'uploads/images/icon/';
        private $VIDEO_PATH_HTTP;
        private $ICON_PATH_HTTP;

        function __construct()
        {
            $this->con = Connection::getConnection();
            $const = new ConstVariable();
            
            $this->VIDEO_PATH_HTTP = "$const->baseUrl" . "$this->VIDEO_PATH";
            $this->ICON_PATH_HTTP = "$const->baseUrl" . "$this->ICON_PATH";
        }


        public function list($topic)
        {
            if(strlen($topic) == 0){
                $sql = "SELECT * FROM vwVideos";
            }else {
                $sql = "SELECT * FROM vwVideos WHERE topic = '$topic' or topic_code = ". (int) $topic ."";
            }
            
            $sql = $this->con->prepare($sql);

            $sql->execute();


            $result = array();
            while($row = $sql->fetch(PDO::FETCH_ASSOC)){
                $row['code'] = (int) $row['code'];
                $row['url'] = $this->VIDEO_PATH_HTTP.$row['url'];
                $row['icon'] = $this->ICON_PATH_HTTP.$row['icon'];
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
                $row['icon'] = $this->ICON_PATH_HTTP.$row['icon'];

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

        public function update($id)
        {
            $json = file_get_contents("php://input");

            
            if( $json != '' ){

                $data = array();
                $data = json_decode($json, true);

                
                if($data != null){ 

                    $title = $data['title'];

                    try {
                        $sql = "CALL sp_update_video($id, '$title')";

                        $sql = $this->con->prepare($sql);

                        $sql->execute();

                        return 'Video alterado com sucesso!';

                    }catch (Exception $e ){
                        if($e->getCode() == "42S02"){ throw new Exception("Este video não existe."); }

                        throw new Exception('Erro ao alterar video. Erro: ' . $e->getMessage());
                    }

                }else{
                    throw new Exception('Erro ao decodificar o arquivo json. Verifique se ele foi passado corretamente.');
                }
 
            }else{
                throw new Exception('No empty json');
            }

        }

        public function create_view($code_video)
        {

            try {
                $sql = "INSERT tbView(data_hora_view, cod_video)
                VALUES ( CURRENT_TIMESTAMP, $code_video)";
                
                $sql = $this->con->prepare($sql);
                $sql->execute();
                return 'vizualização contada!';
            }catch (Exception $e){
                throw new Exception('Erro:' . $e->getMessage());
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

        public function topic($subject)
        {
            $sql = "SELECT cod_topico as code ,nome_topico as name  FROM tbTopico WHERE cod_materia = '$subject'";

            $sql = $this->con->prepare($sql);

            $sql->execute();


            $result = array();
            while($row = $sql->fetch(PDO::FETCH_ASSOC)){
                
                $result[] = $row;
            }

            if(!$result){
                throw new Exception("Nenhum video cadastrado");
            }

            return $result;
        }


    }


   