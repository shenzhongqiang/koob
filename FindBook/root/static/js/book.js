var book = {
    init: function() {
        var self = this;
        var option_cat_a = [];
        for(var key in tags) {
            option_cat_a.push('<option value="' + key + '">' + key + '</option>');
        }
        var option_cat = option_cat_a.join('');
        $('select[name="catalog"]').html(option_cat);
        self.fill_subcat();

        $('select[name="catalog"]').on('change', self.fill_subcat);

        $('#btn-load').on('click', self.load_book);
    },
    fill_subcat: function() {
        var catalog = $('select[name="catalog"]').val();
        var subcat_a = tags[catalog];
        var option_subcat_a = [];
        for(var i=0; i< subcat_a.length; i++) {
            option_subcat_a.push('<option value="' + subcat_a[i] + '">' + subcat_a[i] + '</option>');
        }
        var option_subcat = option_subcat_a.join('');
        $('select[name="subcat"]').html(option_subcat);
    },
    load_book: function() {
        var isbn = $('input[name="isbn"]').val();
        if(!isbn) {
            alert("must input isbn");
            return;
        }
        var url = '/dbapi/get_book/' + isbn;
        $.ajax({
            type: 'GET',
            url: url,
            success: function(data) {
                var success = data.success;
                if(success == 0) {
                    alert("Error: " + data.msg); 
                    return;
                }

                var book = data.book;
                $('input[name="title"]').val(book.title);
                $('input[name="author"]').val(book.author);
                $('input[name="translator"]').val(book.translator);
                $('input[name="publisher"]').val(book.publisher);
                $('input[name="pubdate"]').val(book.pubdate);
                $('input[name="pages"]').val(book.pages);
                $('input[name="rating"]').val(book.rating);
                
                var img_url = book.img_url;
                var ext = img_url.split(".").pop();
                var pic = isbn + "." + ext;
                $('input[name="pic"]').val(pic);
                $('textarea[name="description"]').val(book.description);
                $('textarea[name="author_intro"]').val(book.author_intro);
                $('img[alt="img-book"]').attr('src', book.img_url);
            }
        });
    }
};


