<?php 


    class UploadImage {

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
        private $extension;

        private $allowed = array('jpg', 'jpeg', 'png', 'svg');


        function __construct($id, $file, $filePath, $extension='png') {
            $this->con = Connection::getConnection();
            
            $this->id = $id;
            $this->file = $file;
            $this->filePath = $filePath;

            $this->extension = $extension;

            
            $this->fileName = $this->file['name'];
            $this->fileTmpName = $this->file['tmp_name'];
            $this->fileSize = $this->file['size'];
            $this->fileError = $this->file['error'];
            $this->fileType = $this->file['type'];

            $this->fileExt = explode('.' , $this->fileName);
            $this->fileActualExt = strtolower(end($this->fileExt)); 
        }


        public function upload( $procedure ) {


            if (in_array($this->fileActualExt, $this->allowed)) {

                if($this->fileError === 0){

                    if($this->fileSize < 1000000){

                        try{
                            $fileNameNew = $this->id . "." . $this->extension;

                            $filePath = $this->filePath . $fileNameNew;
                            
                            $sql = "CALL $procedure($this->id, '$fileNameNew')";

                            $this->con->exec($sql);


                            move_uploaded_file($this->fileTmpName, $filePath);

                            return 'Imagem inserida com sucesso!';

                        } catch (Exception $e) {
                            if($e->getCode() == "42S02"){ throw new Exception("Usuário não existe."); }

                            throw new Exception("Erro ao cadastrar imagem " . $e->getMessage());
                        }
                        
                    }else {

                        throw new Exception('Imagem muito grande. Faça upload de uma imagem com um tamanho menor que 1GB');
                    }

                }else{
                    throw new Exception('Erro ao fazer upload da imagem!');
                } 

            }else {
                throw new Exception('Você não pode fazer upload de um arquivo desse tipo.');
            }
        }


    }
