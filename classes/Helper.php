<?php

    require_once 'Connection.php';

    // helper salt password  = sha1( name + surname + password )
    
    class Helper {
        private $con;

        function __construct() {
            $this->con = Connection::getConnection();
        }



        public function list(){
            $sql = "SELECT cod_helper as 'code', foto_helper as 'photo', nome_helper as 'name', sobrenome_helper as 'surname', biografia_helper as 'bio', classificacao_helper as 'classification', email_helper as 'email', ajudas_dadas_helper as 'helps'
            from tbHelper";
            
            $sql = $this->con->prepare($sql);

            $sql->execute();

            $result = array();
            while($row = $sql->fetch(PDO::FETCH_ASSOC)){
                $row['code'] = (int) $row['code'];
                $row['classification'] = (int) $row['classification'];
                $row['helps'] = (int) $row['helps'];
                
                $result[] = $row;
            }

            if(!$result){
                throw new Exception("Nenhum Helper cadastrado");
            }

            return $result;
        }


        public function create(){
            $json = file_get_contents("php://input");

            if($json != ''){
                $array_data = array();
    
                $array_data = json_decode($json, true);
                
            
                $name = $array_data['name'];
                $surname = $array_data['surname'];
                $bio = $array_data['bio'];
                $classification = $array_data['classification'];
                $email = $array_data['email'];  
                $helps = $array_data['helps'];  
                $password = sha1($email . $array_data['password']);
    
                try {
                    $sql = "INSERT INTO tbHelper(nome_helper , sobrenome_helper , biografia_helper, classificacao_helper, email_helper, ajudas_dadas_helper, senha_helper) VALUES ('$name', '$surname', '$bio', $classification, '$email', $helps, '$password')";

                    $this->con->exec($sql);
    
                    return 'Cadastro realizado com sucesso';
                    
                }catch(Exception $e){
                    throw new Exception('Erro ao cadastrar. Erro: ' . $e->getMessage());
                }

            }else{
                throw new Exception('no json found');
            }
        }


        public function update($id){
            $json = file_get_contents("php://input");


            if($json != ''){
                $array_data = array();

                $array_data = json_decode($json, true);

                $name = $array_data['name'];
                $surname = $array_data['surname'];
                $bio = $array_data['bio'];
                $classification = $array_data['classification'];
                $email = $array_data['email'];  
                $helps = $array_data['helps'];  
                $password =  sha1($email . $array_data['password']);
    
                try{

                    $sql = "UPDATE tbHelper 
                    SET nome_helper='$name',
                    sobrenome_helper = '$surname',
                    biografia_helper = '$bio',
                    classificacao_helper = $classification,
                    email_helper = '$email',
                    ajudas_dadas_helper = $helps,
                    senha_helper = '$password'
                    WHERE cod_helper = $id";
    
                    $this->con->exec($sql);
    
                    return 'Atualização realizada com sucesso';
    
                } catch(Exception $e) {
                    throw new Exception('Erro ao atualizar os dados do banco. Erro: ' . $e->getMessage());
                }
                
            }else{
                throw new Exception('empty json');
            }

        }


        public function delete($id){
            try{
                $sql = "DELETE FROM tbHelper WHERE cod_helper = $id";
                $this->con->exec($sql);

                return 'Exclusão realizada com sucesso';

            }catch(Exception $e){
                throw new Exception('Erro ao deletar usuário. Erro: ' . $e->getMessage());
            }
        }
    

        

    }

    
    