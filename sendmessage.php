 <?php
/* https://www.callmebot.com/blog/whatsapp-from-php/ 
  Envia Mensagens pelo whatsapp 
  Adaptar para ser chamado pelo script
 * above, which is before the header() call */


    function send_whatsapp($message="Node backup done!"){
    $phone="+49123123123";  // Enter your phone number here
    $apikey="123456";       // Enter your personal apikey received in step 3 above

    $url='https://api.callmebot.com/whatsapp.php?source=php&phone='.$phone.'&text='.urlencode($message).'&apikey='.$apikey;

    if($ch = curl_init($url))
    {
        curl_setopt ($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt ($ch, CURLOPT_SSL_VERIFYPEER, 0);
        $html = curl_exec($ch);
        $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        // echo "Output:".$html;  // you can print the output for troubleshooting
        curl_close($ch);
        return (int) $status;
    }
    else
    {
        return false;
    }
}

?>
