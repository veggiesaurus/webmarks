//ie8 console fix
if (!window.console) console = { log: function () { } };


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

var previousGlyphElemId;

function changeGlyph(elemId, oldGlyph, newGlyph) 
{
    if (previousGlyphElemId!==elemId)
    {
        $(previousGlyphElemId).toggleClass(oldGlyph);
        $(previousGlyphElemId).toggleClass(newGlyph);
    }
    $(elemId).toggleClass(oldGlyph);
    $(elemId).toggleClass(newGlyph);
    previousGlyphElemId = elemId;
}

function chartBins(courseName, hists)
{

    //x values
    var xVals = ["0-9  ", "10-19  ", "20-29  ", "30-39  ", "40-49  ", "50-59  ", "60-69  ", "70-79  ", "80-89  ", "90-100  "];
    
    //create entries for each category
    var chartSeries = []
    for (i in hists)
        chartSeries.push({ name: hists[i].categoryName, data: [hists[i].hist00, hists[i].hist10, hists[i].hist20, hists[i].hist30, hists[i].hist40, hists[i].hist50, hists[i].hist60, hists[i].hist70, hists[i].hist80, hists[i].hist90] });
    chart = new Highcharts.Chart({
        chart: {
            borderColor: '#b2dbfb',
            borderWidth: 2,
            borderRadius: 3,
            renderTo: 'chart_container',
            marginBottom: 110,
            animation: true,
            type: 'column',
            style: {
                fontFamily: '"Roboto","Helvetica Neue",Helvetica,Arial,sans-serif'
            }
        },
        colors: ['#2196F3', '#4CAF50', '#e51c23', '#e08600', '#b2dbfb', '#64E572', '#FF9655', '#FFF263', '#6AF9C4'],
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
            y: 0,
            floating: true
        },
        xAxis: {
            categories: xVals,
            labels: { align: "center", y: 30, rotation: -90 }
        },
        yAxis: {
            min: 0,
            title: {
                text: 'Count',
                style: {
                    fontSize: '15px'
                }
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
            borderWidth: 1,
            borderColor: '#b2dbfb',
            style:
            {
                color: '#333333',
                padding: '5px'
            }

        },
        plotOptions:
        {
            series: {
                borderWidth: 0,
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
