$('#model-confirm').on('shown.bs.modal', function () {
    $('#bElim').trigger('focus')
})

// $(".dropdown-menu li a").click(function(){
//     $(this).parents(".dropdown").find('.btn').html($(this).text() + ' <span class="caret"></span>');
//     $(this).parents(".dropdown").find('.btn').val($(this).data('value'));
// });