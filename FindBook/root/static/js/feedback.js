var feedback = {
    init: function() {
        var self = this;
        $('#form-fdbk').submit(function(e) {
            e.preventDefault();
            var index_open_time = $('input[name="index_open_time"]').val();
            var search_resp_time = $('input[name="search_resp_time"]').val();
            var search_result_quality = $('input[name="search_result_quality"]').val();
            var ui_quality = $('input[name="ui_quality"]').val();
            var other_suggestions = $('textarea[name="other_suggestions"]').val();
            var data = {
                index_open_time: index_open_time,
                search_resp_time: search_resp_time,
                search_result_quality: search_result_quality,
                ui_quality: ui_quality,
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
