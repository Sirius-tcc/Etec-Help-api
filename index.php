<?php
    header("Access-Control-Allow-Credentials: true");header("Access-Control-Max-Age: 1000");
    header("Access-Control-Allow-Headers: X-Requested-With, Content-Type, Origin, Cache-Control, Pragma, Authorization, Accept, Accept-Encoding");
    header("Access-Control-Allow-Methods: PUT, POST, GET, OPTIONS, DELETE");
    header("Cache-Control: no-cache, no-store, must-revalidate");// limpa o cache
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=utf-8");

    require_once 'classes/Helper.php';
    require_once 'classes/Student.php';
    require_once 'classes/auth/Auth.php';
    require_once 'classes/Video.php';
    require_once 'classes/Topic.php';
    require_once 'classes/Help.php';
    require_once 'classes/Chat.php';
    require_once 'classes/Adm.php';
    require_once 'classes/custom/ConstVariable.php';

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
                            'sucess' => true,
                            'data' => $return
                        ));
        
                    }else{
                        return json_encode(array(
                            'sucess' => false,
                            'data' => 'Método inexistente!'
                        ));
                    }
        
        
                }else{
                    return json_encode(array(
                        'sucess' => false,
                        'data' => 'Classe inexistente!'
                    ));
                }
            }catch(Exception $e){
                return json_encode(array(
                    'sucess' => false,
                    'data' => $e->getMessage()
                ));
            }
            
        }


    }



    if (!empty($_REQUEST)) {
        echo Rest::open($_REQUEST);
    }else {
        echo json_encode(array(
            'sucess' => false,
            'data' => 'Nenhuma resposta'
        ));
    }