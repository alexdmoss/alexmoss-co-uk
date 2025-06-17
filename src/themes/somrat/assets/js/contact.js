jQuery(document).ready(function (e) {
    /* Contacts Form */
    $(function () {
        $('#contacts').find('input,select,textarea').jqBootstrapValidation({
            preventSubmit: true,
            submitError: function ($form, event, errors) {
            },
            submitSuccess: function ($form, e) {
                e.preventDefault()
                let submitButton = $('button[type=submit]', $form)
                // if you're copying this code, the API below still won't work even though you have the URL + API Key ;)
                $.ajax({
                    type: 'POST',
                    crossDomain: true,
                    url: 'https://contact.alexos.dev/api/email/alexmoss.co.uk',
                    headers: {
                        'API-Key': 'ec9349.86220fb9055348fb4ac8dfb4f1a0adc7',   // gitleaks:allow
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
