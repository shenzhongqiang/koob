var feedback = {
    init: function() {
        var self = this;
        $('#form-fdbk').submit(function(e) {
            e.preventDefault();
            var other_suggestions = $('textarea[name="other_suggestions"]').val();
            var data = {
                other_suggestions: other_suggestions
            };
            $.ajax({
                type: "POST",
                url: "/feedback/add",
                data: data,
                success: function(resp) {
                    if(resp.success == 1) {
                        $('#thx-modal').modal('show');
                    }
                }
            });
        });
    }
};
