module namespace api = "http://dbx.iro37.ru/1941-1942/pictures/category/";

declare %private variable $api:wikiApiPath := "http://1941-1942.ru/wiki/api.php";

declare 
  %rest:path ( "/1941-1942/api/v0/pictures/category/{$category}" )
  %rest:query-param( "offset", "{ $offset }", "1" )
  %rest:query-param( "limit", "{ $limit }", "10" )
  %rest:query-param( "width", "{ $width }", "-1" )
  %output:method ("xml")
function api:pictures.Category ( 
  $category as xs:string, 
  $offset as xs:integer, 
  $limit as xs:integer,
  $width as xs:integer ) {
  let $cmparam := 
    map{
      "action" : "query",
      "format" : "xml",
      "list" : "categorymembers",
      "cmtitle" : "Категория:" || $category,
      "cmdir" : "ascending",
      "cmprop" : "ids|title",
      "cmnamespace" : "6",
      "cmlimit" : "100"    
    }
  let $cmquery := web:create-url(  $api:wikiApiPath , $cmparam )
  let $cmresult := fetch:xml( $cmquery )
  
  return
    <api batchcomplete="">
      <query>
        <pages>{
          for $imgID in $cmresult/api/query/categorymembers/cm[ position() >= $offset and position() <= $offset + $limit -1 ]/@pageid/data()
          return
            let $iiparam := 
            map{
              "action" : "query",
              "format" : "xml",
              "pageids" : $imgID,
              "prop" : "imageinfo",
              "iiprop" : "parsedcomment|url",
              "iiurlwidth" : $width    
            }
          let $iiquery := web:create-url(  $api:wikiApiPath , $iiparam )
          let $iiresult := fetch:xml( $iiquery )
          return
           $iiresult/api/query/pages/page
         }
       </pages>
     </query>
    </api>
};

declare 
  %rest:path ( "/1941-1942/api/v0/pictures/category/{$category}/csv" )
  %rest:query-param( "offset", "{$offset}", "1" )
  %rest:query-param( "limit", "{$limit}", "10" )
  %output:method ("csv")
function api:start ( $category as xs:string, $offset as xs:integer, $limit as xs:integer ) {
  
  let $cmparam := 
    map{
      "action" : "query",
      "format" : "xml",
      "list" : "categorymembers",
      "cmtitle" : "Категория:" || $category,
      "cmprop" : "title",
      "cmnamespace" : "6",
      "cmlimit" : "100"    
    }
  let $q := web:create-url(  $api:wikiApiPath , $cmparam )
  let $r := fetch:xml( $q )
  return
  <csv>
  {
     for $rec in $r/api/query/categorymembers/cm[ position() >= $offset and position() <= $offset + $limit -1 ]/@title/data()
     return
       <record>
         <entry>{ $rec }</entry>
       </record>  
  }
  </csv>
};