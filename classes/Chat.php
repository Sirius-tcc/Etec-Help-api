<?php
    
    class Chat {
        private $con;

        function __construct()
        {
            $this->con = Connection::getConnection();
        }

        public function sendMessage()
        {
            $json = file_get_contents("php://input");

            if($json != ''){
                $data = array();
    
                $data = json_decode($json, true);
                
                $menssage = $data['menssage'];
                $helper_code = $data['helper_code'];
                $student_code = $data['student_code'];
                $user = $data['user'];
    
                try {
                    $sql = "CALL sp_create_message( '$menssage', $helper_code, $student_code, '$user' )";

                    $this->con->exec($sql);
    
                    return 'Mensagem enviada';

                }catch(Exception $e){
                    throw new Exception("Erro ao enviar " . $e->getMessage());
                }

            }else{
                throw new Exception('No json found');
            }

        }


        public function Messages()
        {
            if (
                !isset($_GET['student']) || 
                !isset($_GET['helper'])
            ){ throw new Exception("Parâmetros helper ou student não foram passados!"); }
            

            $helper_code = $_GET['helper'];
            $student_code = $_GET['student'];
            

            $sql = "SELECT * FROM vwMensagens 
                    WHERE student_code = $student_code AND
                    helper_code = $helper_code
            ";
            
            $sql = $this->con->prepare($sql);

            $sql->execute();

            $result = array();

            while($row = $sql->fetch(PDO::FETCH_ASSOC)){

                $row['code'] = (int) $row['code'];
                $row['student_code'] = (int) $row['student_code'];
                $row['helper_code'] = (int) $row['helper_code'];

                $row['date'] = $this->dateMessage($row['date']);
                $row['time'] = $this->timeMessage($row['time']);


                $const = new ConstVariable();

                if ($row['user'] == 'helper'){
                    $user = "SELECT photo, name FROM vwHelper WHERE code = " . $row['helper_code'];
                    $path = 'uploads/images/helper/';
                }else{
                    $user = "SELECT photo, name FROM vwEstudantes WHERE code = " . $row['student_code'];
                    $path = 'uploads/images/student/';
                }

                $user = $this->con->prepare($user);
                $user->execute();
                $user = $user->fetch(PDO::FETCH_ASSOC);

                $row['name'] = $user['name'];
                $row['photo'] = $user['photo'] === null ? $user['photo'] : $const->baseUrl.$path.$user['photo'];

                $result[] = $row;
            }

            if(!$result){ throw new Exception("Nenhuma mensagem"); }

            return $result;
        }

        public function listHelperChat( $helper_code )
        {
            $sql = "SELECT DISTINCT student_code, tbEstudante.foto_estudante as photo, tbEstudante.nome_estudante as name FROM vwMensagens 
            LEFT JOIN tbEstudante
            ON tbEstudante.cod_estudante = vwMensagens.student_code
            WHERE helper_code = $helper_code
            ORDER BY code DESC";


            $sql = $this->con->prepare($sql);
            $sql->execute();

            $result = array();

            $const = new ConstVariable();

            $path = 'uploads/images/student/';

            while($row = $sql->fetch(PDO::FETCH_ASSOC))
            {
                $row['student_code'] = (int) $row['student_code'];
                $row['photo'] = $row['photo'] === null ? $row['photo'] : $const->baseUrl.$path.$row['photo'];

                $result[] = $row;
            }

            return $result;
        }

        public function listStudentChat( $student_code )
        {
            $sql = "SELECT DISTINCT helper_code, tbHelper.foto_helper as photo,
                    tbHelper.nome_helper as name FROM vwMensagens 
                    LEFT JOIN tbHelper
                    ON tbHelper.cod_helper = vwMensagens.helper_code
                    WHERE student_code = $student_code
                    ORDER BY code DESC";

            $sql = $this->con->prepare($sql);
            $sql->execute();

            $result = array();

            $const = new ConstVariable();

            while($row = $sql->fetch(PDO::FETCH_ASSOC))
            {
                $row['helper_code'] = (int) $row['helper_code'];
                
                $path = 'uploads/images/helper/';
                $row['photo'] = $row['photo'] === null ? $row['photo'] : $const->baseUrl.$path.$row['photo'];

                $result[] = $row;
            }

            return $result;
        }


        private function dateMessage($date)
        {
            date_default_timezone_set('America/Sao_Paulo');

            $Date = date("d/m/Y", strtotime($date));

            $date = explode('/', $Date)[0];
            $today = explode('/', date("d/m/Y"))[0];

            if($date === $today){
                $dt = "hoje";
            }else if((int) $date === ($today - 1)){
                $dt = "ontem";
            }else{
                $dt = $Date;
            }

            return $dt;
        }


        private function timeMessage($time)
        {
            $time =  explode(':', $time);
            $time = $time[0] . ":" . $time[1];

            return $time;
        }

    }
