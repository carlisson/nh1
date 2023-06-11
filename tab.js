function hide_header() {
    document.faqs=0
    document.querySelectorAll('.faq .card-body').forEach(function(el) {
        document.faqs = document.faqs + 1;
        console.log(document.faqs);
        console.log(el.childNodes);

        aux = el.getElementsByTagName("p");
        aux[0].id = 'faqd_' + document.faqs;
        aux[0].style.display = 'none';

        aux = el.getElementsByTagName("h3");
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
