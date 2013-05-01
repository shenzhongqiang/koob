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

        //onclick event
        $('select[name="catalog"]').change(function() {
            self.fill_subcat();
        });
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
    }
};


