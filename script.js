var $body = $("body");
var $whisper = $("#whisper");
var minutes = 10;
var delay = minutes * 60000;

isArray = function(obj) {
    return obj[0] != undefined
};

hasKey = function (obj, key) {
    return obj[key] != undefined
};

loadImages = function () {
    $.get("http://" + location.hostname + ":1337/random", function (data) {
        var parsed = JSON.parse(data);
        if (isArray(parsed)) {
            var urls = parsed;
            var $img;
            var loadingClass = "j19n1d9j12d";
            $whisper.removeClass("show");
            if (urls.length % 2 != 0) {
                whisper("Course corrected.")
                urls.push(urls[0]);
            }
            $.each(urls, function (i, url) {
                $img = $("<img/>", { src: url, "class": loadingClass });
                $body.append($img);
                $img.hide();
                if (i > 10) {
                    return false;
                }
            });
            setTimeout(function () {
                $("." + loadingClass).fadeIn().removeClass(loadingClass);
                $('html, body').animate({ scrollTop: $img.offset().top }, 5000)
            },2000);
        } else {
            if (hasKey(parsed,"updateMsg")) {
                whisper(parsed["updateMsg"]);
                $("#stop").click();
                setTimeout(function () {
                    $("#start").click();
                },5000);
            }
        }
    });
};

whisper = function (msg) {
    $("#whisper").text(msg).addClass("show");
};

loadIntervalId = 0;
$("#next").click(function () {
    loadImages();
    clearInterval(loadIntervalId);
    loadIntervalId = setInterval(loadImages, delay);
}).click();

