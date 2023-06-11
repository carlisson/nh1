function hide_header() {
    var LOGO = document.getElementById("logo");
    var LIMG = document.getElementById("logo_image");
    var ACT = document.getElementById("action_button");
    if (ACT.href == "none:" && LIMG.src == "none:") {
        LOGO.style.display = "none";
    } else {
        if (ACT.href == "none:") {
            ACT.style.display = "none";
        }
        if (LIMG.src == "none:") {
            LIMG.style.display = "none";
        }
    }
}
function hide_faq() {
    document.faqs=0
    document.querySelectorAll('.faq .card').forEach(function(el) {
        document.faqs = document.faqs + 1;
        console.log(document.faqs);
        console.log(el.childNodes);

        aux = el.getElementsByTagName("p");
        aux[0].id = 'faqd_' + document.faqs;
        aux[0].style.display = 'none';

        aux = el.getElementsByTagName("b");
        aux[0].id = 'd_' + document.faqs;
        aux[0].addEventListener("click", function() {
            targ = document.getElementById('faq' + this.id);
            if (targ.style.display == "none") {
                targ.style.display = "block";
            } else {
                targ.style.display = "none";
            }
        });
    });
}
