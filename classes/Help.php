<?php
    require_once 'Connection.php';

    class Help {

        private $con;

        function __construct()
        {
            $this->con = Connection::getConnection();
        }


        public function list()
        {

            if(
                isset($_GET['helper_code']) && 
                isset($_GET['student_code'])  
            ) {
                $helper_code = $_GET['helper_code'];
                $student_code = $_GET['student_code'];
                
                $sql = "SELECT * FROM vwAjuda 
                        WHERE helper_code = $helper_code AND 
                        student_code = $student_code
                        ORDER BY help_code DESC";
            }else{
                $sql = "SELECT * FROM vwAjuda WHERE status_code = 2 ORDER BY help_code ";
            }

            $sql = $this->con->prepare($sql);

            $sql->execute();


            $result = array();
            while($row = $sql->fetch(PDO::FETCH_ASSOC)) {
                $row['help_code'] = (int) $row['help_code'];
                $row['helper_code'] = (int) $row['helper_code'];
                $row['student_code'] = (int) $row['student_code'];
                $row['subject_code'] = (int) $row['subject_code'];
                $row['classification'] = (int) $row['classification'];
                $row['date'] = implode('/', array_reverse(explode('-', $row['date'] )));
            
                $result[] = $row;
            }

            if(!$result){ throw new Exception("Nenhuma ajuda."); }

            return $result;
        }


        public function show($id)
        {
            $sql = "SELECT * FROM vwAjuda WHERE help_code = $id";

            $sql = $this->con->prepare($sql);

            $sql->execute();


            $result = array();
            while($row = $sql->fetch(PDO::FETCH_ASSOC)) {
                $row['help_code'] = (int) $row['help_code'];
                $row['helper_code'] = (int) $row['helper_code'];
                $row['student_code'] = (int) $row['student_code'];
                $row['subject_code'] = (int) $row['student_code'];
                $row['classification'] = (int) $row['classification'];
               
                $result[] = $row;
            }

            if(!$result){ throw new Exception("Nenhuma ajuda com esse id."); }

            return $result;
        }


        public function create()
        {
            $json = file_get_contents("php://input");

            if($json != ''){
                $array_data = array();
    
                $array_data = json_decode($json, true);
                
                $title = $array_data['title'];
                $description = $array_data['description'];
                $date = $array_data['date'];
                $time = $array_data['time'];  
                $local = $array_data['local'];
                $subject = $array_data['subject'];
                $student = $array_data['student'];
                $helper = $array_data['helper'];
                $status = $array_data['status'];
    
                try {
                    $sql = "CALL sp_create_help( '$title', '$description', '$date', '$time', '$local', $subject, $student, $helper, $status )";

                    $this->con->exec($sql);
    
                    return 'Ajuda cadastrada com sucesso';

                }catch(Exception $e){
                    throw new Exception("Erro ao cadastrar " . $e->getMessage());
                }

            }else{
                throw new Exception('No json found');
            }
        }

        public function classification($id)
        {
            $json = file_get_contents("php://input"); 

            if($json != ''){
                $array_data = array();
    
                $array_data = json_decode($json, true);

                $stars = $array_data['stars'];
                try {
                    $sql = "CALL sp_set_classification($id, $stars)";

                    $this->con->exec($sql);
    
                    return 'Classificação cadastrada com sucesso';

                }catch(Exception $e){
                    if($e->getCode() == "42S02"){ throw new Exception("Classificação já foi feita."); }

                    throw new Exception("Erro ao cadastrar " . $e->getMessage());
                }

            }else{
                throw new Exception('No json found');
            }
        }

        public function status($id)
        {
            $json = file_get_contents("php://input"); 

            if($json != ''){
                $array_data = array();
    
                $array_data = json_decode($json, true);

                $status_code = $array_data['status_code'];
                try {
                    $sql = "UPDATE tbAjuda
                    SET cod_status = $status_code
                    WHERE cod_ajuda = $id";

                    $this->con->exec($sql);
    
                    return 'Status atualizado com sucesso';

                }catch(Exception $e){
                    throw new Exception("Erro ao cadastrar " . $e->getMessage());
                }

            }else{
                throw new Exception('No json found');
            }
        }

        public function locations(){
            $sql = "SELECT cod_local as code, nome_local as name FROM tbLocal";

            $sql = $this->con->prepare($sql);

            $sql->execute();


            $result = array();
            while($row = $sql->fetch(PDO::FETCH_ASSOC)) {
                $row['code'] = (int) $row['code'];
                $result[] = $row;
            }

            return $result;
        }

    }
