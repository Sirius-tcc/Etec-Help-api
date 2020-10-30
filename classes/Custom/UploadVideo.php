<?php 

    class UploadVideo {

        private $id;
        
        private $file;

        private $filePath;

        private $fileName;
        private $fileTmpName;
        private $fileSize;
        private $fileError;
        private $fileType;
        private $con;

        private $fileExt;
        private $fileActualExt;

        private $allowed = array('mp4');


        function __construct($id, $file, $filePath) {
            $this->con = Connection::getConnection();
            
            $this->id = $id;
            $this->file = $file;
            $this->filePath = $filePath;

            $this->fileName = $this->file['name'];
            $this->fileTmpName = $this->file['tmp_name'];
            $this->fileSize = $this->file['size'];
            $this->fileError = $this->file['error'];
            $this->fileType = $this->file['type'];

            $this->fileExt = explode('.' , $this->fileName);
            $this->fileActualExt = strtolower(end($this->fileExt)); 
        }

        public function upload() {
            if (in_array($this->fileActualExt, $this->allowed)) {
                if($this->fileError === 0){
                        try{
                            $fileNameNew = $this->id . "." .$this->fileActualExt;

                            $filePath = $this->filePath . $fileNameNew;

                            $sql = "UPDATE tbVideo
                            SET url_video = '$fileNameNew'
                            WHERE cod_video = $this->id";

                            $this->con->exec($sql);

                            move_uploaded_file($this->fileTmpName, $filePath);

                            return 'Video cadastrado com sucesso!';

                        } catch (Exception $e) {
                            if($e->getCode() == "42S02"){ throw new Exception("Usuário não existe."); }

                            throw new Exception("Erro ao cadastrar video " . $e->getMessage());
                        }
                        

                }else{
                    throw new Exception('Erro ao fazer upload do video');
                } 

            }else {
                throw new Exception('Você não pode fazer upload de um arquivo desse tipo.');
            }
        }


    }
