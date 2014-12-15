var timeout = 300;
var closetimer = 0;
var ddmenuitem = 0;

function showSubmenu() {  
    canceltimer();
    hide();
    ddmenuitem = $(this).children('ul').css('visibility', 'visible');

    //if there is a drop-down
    if ( $(this).children('ul').length > 0 ) {
        var mainHoverCSS = {'border': 'solid #888',
                           'border-width': '4px 4px 0 4px',
                           'background': '#FEFEFE',
                           'color': '#333'};
        var linkHoverCSS = {'color': '#08C',
                            'text-shadow': 'none'};
        $(this).css(mainHoverCSS);
        $(this).children('span').css({'color': '#333',
                                'text-shadow': 'none'});
        $(this).find('a').css(linkHoverCSS) //change list link colors
        // $(this).find('.arrow-down').css('visibility', 'hidden');
    }
}

function hide() {
    if(ddmenuitem) {
        ddmenuitem.css('visibility', 'hidden');
    }

    var mainHoverCSS = {'text-shadow': '0px 2px 3px #222',
                        'border': 'solid #31559F',
                        'border': 'solid #444',
                        'border-width': '4px 4px 0 4px',
                        'background': '#444'};
    var linkCSS = {'color': '#EAFFED',
                   'text-shadow': '0px 2px 3px #222'};
    var mainNav = $('.top-nav > .autonav > ul').children('li');

    mainNav.css(mainHoverCSS);
    mainNav.children('span').css({'color': '#EAFFED',
                                  'text-shadow': '0px 2px 3px #222'});    
    mainNav.find('a').css(linkCSS)
    $('.arrow-down').css('visibility', 'visible');
}

function timer() {
    closetimer = window.setTimeout(hide, timeout);
}

function canceltimer() {  
    if(closetimer) {  
        window.clearTimeout(closetimer);
        closetimer = null;
    }
}

function linkEnter() {
    if ($(this).parents('li').length > 1 ) {
        $(this).css({'color': '#005580'});
    }
    else if ($(this).parent().find('a').length > 1 ) {
        $(this).css({'color': '#005580'});
    }
}

function linkOut() {
    if ($(this).parents('li').length > 1 ) {
        $(this).css({'color': '#08C'});
    }
    else if ($(this).parent().find('a').length > 1 ) {
        $(this).css({'color': '#08C'});
    }
}

$(document).ready(function() { 
    $('.top-nav > .autonav > ul').children('li').hover(showSubmenu, timer)
    $('.top-nav > .autonav > ul').children('li').find('a').hover(linkEnter, linkOut);
    $('.top-nav > .autonav > ul > li > a.nav-dropdown').click(function (e) {
      e.preventDefault();
      return false;
    });
});

document.onclick = hide;
