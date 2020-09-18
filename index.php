<?php
    header("Cache-Control: no-cache, no-store, must-revalidate"); // limpa o cache
    header("Access-Control-Allow-Origin: *");
    header('Content-Type: application/json; charset=utf-8');

    require_once 'classes/Helper.php';

    class Rest {

        public function open($request){
            $url = explode('/',$request['url']);

            
            $class = ucfirst($url[0]);


            array_shift($url);
            $method = $url[0];


            $params = array();
            
            array_shift($url);
            $params = $url;
        

            try{
                if (class_exists($class)){
                
                    if(method_exists($class, $method)){
                        $return = call_user_func_array(array(new $class, $method), $params);
        
                        return json_encode(array(
                            'status' => 'sucess',
                            'data' => $return
                        ));
        
                    }else{
                        return json_encode(array(
                            'status' => 'error',
                            'data' => 'Método inexistente!'
                        ));
                    }
        
        
                }else{
                    return json_encode(array(
                        'status' => 'error',
                        'data' => 'Classe inexistente!'
                    ));
                }
            }catch(Exception $e){
                return json_encode(array(
                    'status' => 'error',
                    'data' => $e->getMessage()
                ));
            }
            
        }


    }



    if (!empty($_REQUEST)) {
        echo Rest::open($_REQUEST);
        
    }else {
        echo json_encode(array(
            'status' => 'error',
            'data' => 'Nenhuma resposta'
        ));
    }