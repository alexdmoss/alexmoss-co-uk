jQuery(document).ready(function (e) {
    /* Contacts Form */
    $(function () {
        $('#contacts').find('input,select,textarea').jqBootstrapValidation({
            preventSubmit: true,
            submitError: function ($form, event, errors) {
            },
            submitSuccess: function ($form, e) {
                e.preventDefault()
                var submitButton = $('button[type=submit]', $form)
                // if you're copying this code, the API below still won't work even though you have the URL + API Key ;)
                $.ajax({
                    type: 'POST',
                    crossDomain: true,
                    url: 'https://contact.alexos.dev/api/email/moss.work',
                    headers: {
                        'API-Key': 'a47aa6.224e7324f63c300ee95d20231aeba3be',
                    },
                    data: $form.serialize(),
                    beforeSend: function (xhr, opts) {
                        if ($('#_email', $form).val()) {
                            xhr.abort()
                        } else {
                            submitButton.html('Sending ...')
                            submitButton.prop('disabled', 'disabled')
                        }
                    }
                }).done(function (data) {
                    submitButton.html('Thanks!')
                    submitButton.prop('disabled', true)
                })
            },
            filter: function () {
                return $(this).is(':visible')
            }
        })
    })
})
$('#name').focus(function () {
    $('#success').html('')
})