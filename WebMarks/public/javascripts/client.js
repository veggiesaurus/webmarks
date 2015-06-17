$(document).bind('mobileinit', initFunction);

//ie8 console fix
if (!window.console) console = { log: function () { } };


function initFunction()
{
    //disable zooming
    $.extend($.mobile.zoom, {locked:true,enabled:false});
    //loading screen
    $.mobile.loader.prototype.options.text = "Loading";
    $.mobile.loader.prototype.options.textVisible = true;
    $.mobile.loader.prototype.options.theme = "a";
    $.mobile.loader.prototype.options.html = "";  	
    console.log("client init");
}

window.onload = function ()
{
    console.log("Loaded data");
    if (courseName && hists && hists != -1)
    {
        console.log("Displaying hists");
        chartBins(courseName, hists)
    }
    else
        console.log("No hists to display");
}

function chartBins(courseName, hists)
{

    //create the histogram with empty values
    var xVals = ["0-9  ", "10-19  ", "20-29  ", "30-39  ", "40-49  ", "50-59  ", "60-69  ", "70-79  ", "80-89  ", "90-100  "];
    
    var chartSeries = []
    for (i in hists)
        chartSeries.push({ name: hists[i].categoryName, data: [hists[i].hist00, hists[i].hist10, hists[i].hist20, hists[i].hist30, hists[i].hist40, hists[i].hist50, hists[i].hist60, hists[i].hist70, hists[i].hist80, hists[i].hist90] });
    console.log(chartSeries);
    chart = new Highcharts.Chart({
        chart: {
            borderColor: '#000000',
            borderWidth: 1,
            renderTo: 'chart_container',
            marginBottom: 110,
            animation: true,
            type: 'column'
        },
        credits: {
            enabled: false
        },
        title: {
            text: courseName
        },
        subtitle: {
            text: 'Class Distribution'
        },
        legend: {
            align: 'center',
            verticalAlign: 'bottom',
            //x: -10,
            y: 0,
            floating: true
        },
        xAxis: {
            categories: xVals,
            labels: { align: "center", y: 50, rotation: -90 }
        },
        yAxis: {
            min: 0,
            title: {
                text: 'Count'
            }
        },        
        tooltip:
        {
            backgroundColor:
            {
                linearGradient: [0, 0, 0, 60],
                stops: [
                [0, '#FFFFFF'],
                [1, '#E0E0E0']
                ]
            },
            borderWidth: 2,
            borderColor: '#000',
            style:
            {
                color: '#333333',
                padding: '5px'
            }

        },
        plotOptions:
        {
            series: {
                borderWidth: 1,
                borderColor: 'black',
                animation: true
            },
            column:
            {
                pointPadding: 0.05,
                groupPadding: 0.1,
                borderWidth: 1
            }
        },
        series: chartSeries,
    });
    chart.redraw();
}
