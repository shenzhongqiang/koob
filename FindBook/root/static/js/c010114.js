var book={init:function(){var b=[],a;for(a in tags)b.push('<option value="'+a+'">'+a+"</option>");b=b.join("");$('select[name="catalog"]').html(b);this.fill_subcat();$('select[name="catalog"]').on("change",this.fill_subcat);$("#btn-load").on("click",this.load_book)},fill_subcat:function(){for(var b=$('select[name="catalog"]').val(),b=tags[b],a=[],c=0;c<b.length;c++)a.push('<option value="'+b[c]+'">'+b[c]+"</option>");b=a.join("");$('select[name="subcat"]').html(b)},load_book:function(){var b=$('input[name="isbn"]').val();
b?$.ajax({type:"GET",url:"/dbapi/get_book/"+b,success:function(a){if(0==a.success)alert("Error: "+a.msg);else{a=a.book;var c=0==a.rating?8:a.rating;$('input[name="title"]').val(a.title);$('input[name="author"]').val(a.author);$('input[name="translator"]').val(a.translator);$('input[name="publisher"]').val(a.publisher);$('input[name="pubdate"]').val(a.pubdate);$('input[name="pages"]').val(a.pages);$('input[name="rating"]').val(c);c=a.img_url.split(".").pop();c=b+"."+c;$('input[name="pic"]').val(c);
$('textarea[name="description"]').val(a.description);$('textarea[name="author_intro"]').val(a.author_intro);$('img[alt="img-book"]').attr("src",a.img_url)}}}):alert("must input isbn")}};var search={init:function(){$("#srch-q").focus()}};var tag={init:function(){}};var feedback={init:function(){$("#form-fdbk").submit(function(b){b.preventDefault();b={other_suggestions:$('textarea[name="other_suggestions"]').val()};$.ajax({type:"POST",url:"/feedback/add",data:b,success:function(a){1==a.success&&$("#thx-modal").modal("show")}})})}};