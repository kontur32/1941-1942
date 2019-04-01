module namespace view = "http://dbx.iro37.ru/1941-1942/";

import module namespace html = "http://www.iro37.ru/xquery/lib/html";
declare %private variable $view:wikiApiPath := "http://localhost:8984/1941-1942/api/v0/pictures/category/";


declare 
  %rest:path ( "/1941-1942/v/gallery/category/{$category}/pages/{$page}" )
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
  let $item := serialize( doc( "src/gallery.Item.html" ) )
  
  let $imgItems := 
    for $item in $result//page
    let $fields := 
      map{
        "title" : $item/@title/data(),
        "url" : $item/imageinfo/ii/@url/data(),
        "thumburl" : $item/imageinfo/ii/@thumburl/data(),
        "descriptionurl" : $item/imageinfo/ii/@descriptionurl/data(),
        "parsedcomment" :  substring-before ($item/imageinfo/ii/@parsedcomment/data(), "<a" )
      }
    let $a := html:fillHtmlTemplate( $item, $fields )
    return 
      $a
  let $main := serialize( doc( "src/gallery.Main.html" ) )
  return
   html:fillHtmlTemplate( $main, map{ "категория" : $category, "изображение" : $imgItems} )


};


declare 
  %rest:path ( "/1941-1942/v/gallery/category2/{$category}" )
  %output:method ("xhtml")
function view:start2 ( $category ) {
  let $p := "http://1941-1942.ru/wiki/api.php?action=query&amp;format=xml&amp;prop=categories%7Cinfo&amp;generator=allpages&amp;cllimit=500&amp;inprop=url&amp;gapnamespace=6&amp;gapfilterredir=all&amp;gaplimit=1000"

let $r := fetch:xml( $p )
return
<html>
  <head>
        <meta charset="utf-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>Grid Gallery</title>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"/>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/baguettebox.js/1.10.0/baguetteBox.min.css" />
        <link rel="stylesheet" href="/static/1941-1942/grid-gallery.css"/>
    </head>
  <body>
    <section class="gallery-block cards-gallery">
	    <div class="container">
	        <div class="heading">
	          <h2>{ $category }</h2>
	        </div>
	        <div class="row">
    {
      for $r1 in $r//page
      count $c
      let $cl := string-join ( $r1/categories/cl/@title/data() )
      where matches ( $cl, $category )
      let $picURL := $r1/@canonicalurl/data()
      
      let $r2 := fetch:xml ($picURL)
      let $URL := "http://1941-1942.ru" || $r2//div[ @class="fullImageLink" ]/a/img/@src/data()
      let $title := substring-after( $r2//h1/text(), "Файл:" )
      let $content := $r2//div[ @id="mw-imagepage-content" ]/div/p/text()
      return
        <div class="col-md-6 col-lg-4">
	                <div class="card border-0 transform-on-hover">
	                	<a class="lightbox" href="{ $URL }">
	                		<img src="{ $URL }" style="object-fit: cover; height: 330px; object-position: 0 0;" alt="{ $title }" class="card-img-top"/>
	                	</a>
	                    <div class="card-body">
	                        <h6><a href="#">{ $title }</a></h6>
	                        <p class="text-muted card-text">{ $content }</p>
	                    </div>
	                </div>
	            </div>
    }
    </div>
    </div>
    </section>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/baguettebox.js/1.10.0/baguetteBox.min.js"></script>
    <script src="/static/1941-1942/baguetteBox.js"></script>
  </body>
  </html>
};