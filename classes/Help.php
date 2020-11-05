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
            $sql = "SELECT * FROM vwAjuda";

            $sql = $this->con->prepare($sql);

            $sql->execute();


            $result = array();
            while($row = $sql->fetch(PDO::FETCH_ASSOC)) {
                $row['help_code'] = (int) $row['help_code'];
                $row['helper_code'] = (int) $row['helper_code'];
                $row['student_code'] = (int) $row['student_code'];
                $row['subject_code'] = (int) $row['student_code'];
               
                $result[] = $row;
            }

            if(!$result){ throw new Exception("Nenhuma ajuda."); }

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

    }

    /*
        SELECT titulo_ajuda as title,
        descricao_ajuda as description,
        classificacao_ajuda as classification,
        data_ajuda as date,
        horario_ajuda as hour,
        local_ajuda as local,
        cod_materia as subject,
        cod_estudante as student,
        cod_helper as helper,
        cod_status as status
        from tbAjuda
    */ 