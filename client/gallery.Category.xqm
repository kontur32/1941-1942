module namespace view = "http://dbx.iro37.ru/1941-1942/";

import module namespace html = "http://www.iro37.ru/xquery/lib/html";
declare %private variable $view:wikiApiPath := "http://localhost:8984/1941-1942/api/v0/pictures/category/";

declare 
  %rest:path ( "/1941-1942/galleries/categories/{$category}/pages/{$page}" )
  %output:method ("xhtml")
function view:galleryCategory ( $category, $page as xs:integer ) {
  let $param := 
      map {
        "offset" : $page*12-11,
        "limit" : 12,
        "width" : 330
      }
  let $request := web:create-url( $view:wikiApiPath || iri-to-uri($category), $param)
  let $result := fetch:xml(  $request  )
  let $itemTpl := serialize( doc( "src/gallery.Item.html" ) )
  
  let $imgItems := 
    for $item in $result//page
    let $fields := 
      map{
        "title" : substring-after( $item/@title/data(), ":" ),
        "url" : $item/imageinfo/ii/@url/data(),
        "thumburl" : $item/imageinfo/ii/@thumburl/data(),
        "descriptionurl" : $item/imageinfo/ii/@descriptionurl/data(),
        "parsedcomment" :  substring-before ($item/imageinfo/ii/@parsedcomment/data(), "<a" )
      }
    let $a := html:fillHtmlTemplate( $itemTpl, $fields )
    return 
      $a
  let $main := serialize( doc( "src/gallery.Main.html" ) )
  return
     html:fillHtmlTemplate( $main, map{ "категория" : $category, "изображение" : $imgItems} )
};