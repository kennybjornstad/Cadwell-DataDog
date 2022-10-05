Param(
    [Parameter(ValueFromPipeline=$True)]
    $newdashboardJSON
)

# This script must be called from Install-Datadog.ps1
Function CheckForParentScript {
    Set-Location -Path $PSScriptRoot
    if (!($DependencyCheck)) {
        .\Install-Datadog.ps1
    } #exit
} CheckForParentScript

#Had to add this line to get rid of "The underlying connection was closed: An unexpected error occurred on a send." error
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13  

$CadLinkFullPath = Get-Package -Name "CadLink Server" | Select-Object -ExpandProperty FullPath -ErrorAction SilentlyContinue
#$CadLinkFullPath = "C:\Program Files\Cadwell\CadLinkServerService"
$CadLinkInstallDir = $CadLinkFullPath.Remove(1)
$LOWERCASECadLinkInstallDir = $CadLinkInstallDir.ToLower()

Write-Host ""
Write-Host "Step 5"
Write-Host "Creating dashboard for $($customerNumber) - $($customerName) ($($ServerName))" -ForegroundColor Yellow
    
$newdashboardJSON = "{
    `"title`": `"$($customerNumber) - $($customerName) Dashboard ($($ServerName))`",
    `"description`": `"Default CadLink Server dashboard for Cadwell customers.`",
    `"widgets`": [
        {
            `"id`": 7717010941458886,
            `"layout`": {
                `"x`": 0,
                `"y`": 0,
                `"width`": 11,
                `"height`": 12
            },
            `"definition`": {
                `"type`": `"image`",
                `"url`": `"`",
                `"sizing`": `"contain`",
                `"margin`": `"sm`",
                `"has_background`": true,
                `"has_border`": true,
                `"vertical_align`": `"center`",
                `"horizontal_align`": `"center`"
            }
        },
        {
            `"id`": 7072346792392538,
            `"layout`": {
                `"x`": 100,
                `"y`": 0,
                `"width`": 21,
                `"height`": 12
            },
            `"definition`": {
                `"title`": `"CadLink Windows Service (#Threads)`",
                `"title_size`": `"16`",
                `"title_align`": `"left`",
                `"type`": `"query_value`",
                `"requests`": [
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"query1`"
                            }
                        ],
                        `"conditional_formats`": [
                            {
                                `"comparator`": `"<`",
                                `"palette`": `"white_on_green`",
                                `"value`": 200
                            },
                            {
                                `"comparator`": `">=`",
                                `"palette`": `"white_on_yellow`",
                                `"value`": 200
                            },
                            {
                                `"comparator`": `">=`",
                                `"palette`": `"white_on_red`",
                                `"value`": 400
                            }
                        ],
                        `"response_format`": `"scalar`",
                        `"queries`": [
                            {
                                `"aggregator`": `"last`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query1`",
                                `"query`": `"avg:system.processes.threads{process_name:cadlinkserverwindowsservice,host:$($ServerName)}`"
                            }
                        ]
                    }
                ],
                `"autoscale`": true,
                `"precision`": 2,
                `"timeseries_background`": {
                    `"type`": `"area`"
                }
            }
        },
        {
            `"id`": 3994403748729576,
            `"layout`": {
                `"x`": 78,
                `"y`": 0,
                `"width`": 21,
                `"height`": 12
            },
            `"definition`": {
                `"title`": `"CadLink Windows Service (%CPU)`",
                `"title_size`": `"16`",
                `"title_align`": `"left`",
                `"type`": `"query_value`",
                `"requests`": [
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"query1`"
                            }
                        ],
                        `"conditional_formats`": [
                            {
                                `"comparator`": `"<`",
                                `"palette`": `"white_on_green`",
                                `"value`": 30
                            },
                            {
                                `"comparator`": `">=`",
                                `"palette`": `"white_on_yellow`",
                                `"value`": 30
                            },
                            {
                                `"comparator`": `">=`",
                                `"palette`": `"white_on_red`",
                                `"value`": 60
                            }
                        ],
                        `"response_format`": `"scalar`",
                        `"queries`": [
                            {
                                `"query`": `"avg:system.processes.cpu.normalized_pct{host:$($ServerName),process_name:cadlinkserverwindowsservice}`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query1`",
                                `"aggregator`": `"last`"
                            }
                        ]
                    }
                ],
                `"autoscale`": true,
                `"precision`": 2
            }
        },
        {
            `"id`": 5384379552238118,
            `"layout`": {
                `"x`": 56,
                `"y`": 0,
                `"width`": 21,
                `"height`": 12
            },
            `"definition`": {
                `"title`": `"Total %CPU`",
                `"title_size`": `"16`",
                `"title_align`": `"center`",
                `"type`": `"query_value`",
                `"requests`": [
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"query1 + query2`"
                            }
                        ],
                        `"conditional_formats`": [
                            {
                                `"comparator`": `"<`",
                                `"palette`": `"white_on_green`",
                                `"value`": 40
                            },
                            {
                                `"comparator`": `">=`",
                                `"palette`": `"white_on_yellow`",
                                `"value`": 40
                            },
                            {
                                `"comparator`": `">=`",
                                `"palette`": `"white_on_red`",
                                `"value`": 60
                            }
                        ],
                        `"response_format`": `"scalar`",
                        `"queries`": [
                            {
                                `"query`": `"avg:system.cpu.user{host:$($ServerName)}`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query1`",
                                `"aggregator`": `"avg`"
                            },
                            {
                                `"query`": `"avg:system.cpu.system{host:$($ServerName)}`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query2`",
                                `"aggregator`": `"avg`"
                            }
                        ]
                    }
                ],
                `"autoscale`": true,
                `"precision`": 2
            }
        },
        {
            `"id`": 3172675956776158,
            `"layout`": {
                `"x`": 96,
                `"y`": 13,
                `"width`": 47,
                `"height`": 16
            },
            `"definition`": {
                `"title`": `"CadLink Windows Service (%RAM)`",
                `"title_size`": `"16`",
                `"title_align`": `"left`",
                `"show_legend`": false,
                `"legend_layout`": `"auto`",
                `"legend_columns`": [
                    `"avg`",
                    `"min`",
                    `"max`",
                    `"value`",
                    `"sum`"
                ],
                `"type`": `"timeseries`",
                `"requests`": [
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"query1`"
                            }
                        ],
                        `"response_format`": `"timeseries`",
                        `"queries`": [
                            {
                                `"query`": `"avg:system.processes.mem.pct{host:$($ServerName),process_name:cadlinkserverwindowsservice}`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query1`"
                            }
                        ],
                        `"style`": {
                            `"palette`": `"dog_classic`",
                            `"line_type`": `"solid`",
                            `"line_width`": `"normal`"
                        },
                        `"display_type`": `"line`"
                    }
                ],
                `"yaxis`": {
                    `"include_zero`": true,
                    `"scale`": `"linear`",
                    `"label`": `"`",
                    `"min`": `"auto`",
                    `"max`": `"auto`"
                }
            }
        },
        {
            `"id`": 4901083184775742,
            `"layout`": {
                `"x`": 122,
                `"y`": 0,
                `"width`": 21,
                `"height`": 12
            },
            `"definition`": {
                `"title`": `"CadLink Windows Service (%RAM)`",
                `"title_size`": `"16`",
                `"title_align`": `"left`",
                `"type`": `"query_value`",
                `"requests`": [
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"query1`"
                            }
                        ],
                        `"conditional_formats`": [
                            {
                                `"comparator`": `"<`",
                                `"palette`": `"white_on_green`",
                                `"value`": 30
                            },
                            {
                                `"comparator`": `">=`",
                                `"palette`": `"white_on_yellow`",
                                `"value`": 30
                            },
                            {
                                `"comparator`": `">=`",
                                `"palette`": `"white_on_red`",
                                `"value`": 60
                            }
                        ],
                        `"response_format`": `"scalar`",
                        `"queries`": [
                            {
                                `"query`": `"avg:system.processes.mem.pct{host:$($ServerName),process_name:cadlinkserverwindowsservice}`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query1`",
                                `"aggregator`": `"last`"
                            }
                        ]
                    }
                ],
                `"autoscale`": true,
                `"precision`": 2
            }
        },
        {
            `"id`": 2533876706874448,
            `"layout`": {
                `"x`": 0,
                `"y`": 30,
                `"width`": 47,
                `"height`": 16
            },
            `"definition`": {
                `"title`": `"CadLink Windows Service (IOPS)`",
                `"title_size`": `"16`",
                `"title_align`": `"left`",
                `"show_legend`": false,
                `"legend_layout`": `"auto`",
                `"legend_columns`": [
                    `"avg`",
                    `"min`",
                    `"max`",
                    `"value`",
                    `"sum`"
                ],
                `"type`": `"timeseries`",
                `"requests`": [
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"query1`"
                            }
                        ],
                        `"response_format`": `"timeseries`",
                        `"queries`": [
                            {
                                `"query`": `"avg:system.processes.iowrite_bytes_count{host:$($ServerName),process_name:cadlinkserverwindowsservice}.as_count()`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query1`"
                            }
                        ],
                        `"style`": {
                            `"palette`": `"dog_classic`",
                            `"line_type`": `"solid`",
                            `"line_width`": `"normal`"
                        },
                        `"display_type`": `"line`"
                    },
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"query1`"
                            }
                        ],
                        `"response_format`": `"timeseries`",
                        `"on_right_yaxis`": false,
                        `"queries`": [
                            {
                                `"query`": `"avg:system.processes.ioread_bytes_count{host:$($ServerName),process_name:cadlinkserverwindowsservice}.as_count()`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query1`"
                            }
                        ],
                        `"style`": {
                            `"palette`": `"dog_classic`",
                            `"line_type`": `"solid`",
                            `"line_width`": `"normal`"
                        },
                        `"display_type`": `"line`"
                    }
                ],
                `"yaxis`": {
                    `"include_zero`": true,
                    `"scale`": `"linear`",
                    `"label`": `"`",
                    `"min`": `"auto`",
                    `"max`": `"auto`"
                }
            }
        },
        {
            `"id`": 1358896327013374,
            `"layout`": {
                `"x`": 96,
                `"y`": 47,
                `"width`": 47,
                `"height`": 16
            },
            `"definition`": {
                `"title`": `"Storage - Used vs Total (Device $($CadLinkInstallDir))`",
                `"title_size`": `"16`",
                `"title_align`": `"left`",
                `"show_legend`": false,
                `"legend_layout`": `"auto`",
                `"legend_columns`": [
                    `"avg`",
                    `"min`",
                    `"max`",
                    `"value`",
                    `"sum`"
                ],
                `"type`": `"timeseries`",
                `"requests`": [
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"query1`"
                            },
                            {
                                `"formula`": `"query2`"
                            }
                        ],
                        `"response_format`": `"timeseries`",
                        `"on_right_yaxis`": false,
                        `"queries`": [
                            {
                                `"query`": `"avg:system.disk.total{host:$($ServerName),device:$($LOWERCASECadLinkInstallDir):} by {device}`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query1`"
                            },
                            {
                                `"query`": `"avg:system.disk.used{host:$($ServerName),device:$($LOWERCASECadLinkInstallDir):} by {device}`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query2`"
                            }
                        ],
                        `"style`": {
                            `"palette`": `"cool`",
                            `"line_type`": `"solid`",
                            `"line_width`": `"normal`"
                        },
                        `"display_type`": `"area`"
                    }
                ],
                `"yaxis`": {
                    `"include_zero`": true,
                    `"scale`": `"linear`",
                    `"label`": `"`",
                    `"min`": `"auto`",
                    `"max`": `"auto`"
                }
            }
        },
        {
            `"id`": 8644146759391606,
            `"layout`": {
                `"x`": 48,
                `"y`": 30,
                `"width`": 47,
                `"height`": 16
            },
            `"definition`": {
                `"title`": `"Network throughput`",
                `"title_size`": `"16`",
                `"title_align`": `"left`",
                `"show_legend`": false,
                `"legend_layout`": `"auto`",
                `"legend_columns`": [
                    `"avg`",
                    `"min`",
                    `"max`",
                    `"value`",
                    `"sum`"
                ],
                `"type`": `"timeseries`",
                `"requests`": [
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"query1`"
                            }
                        ],
                        `"response_format`": `"timeseries`",
                        `"queries`": [
                            {
                                `"query`": `"avg:system.net.bytes_sent{host:$($ServerName)} by {host}`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query1`"
                            }
                        ],
                        `"style`": {
                            `"palette`": `"purple`",
                            `"line_type`": `"solid`",
                            `"line_width`": `"normal`"
                        },
                        `"display_type`": `"line`"
                    },
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"-query1`"
                            }
                        ],
                        `"response_format`": `"timeseries`",
                        `"queries`": [
                            {
                                `"query`": `"avg:system.net.bytes_rcvd{host:$($ServerName)} by {host}`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query1`"
                            }
                        ],
                        `"style`": {
                            `"palette`": `"green`",
                            `"line_type`": `"solid`",
                            `"line_width`": `"normal`"
                        },
                        `"display_type`": `"line`"
                    }
                ],
                `"yaxis`": {
                    `"include_zero`": true,
                    `"scale`": `"linear`",
                    `"label`": `"`",
                    `"min`": `"auto`",
                    `"max`": `"auto`"
                }
            }
        },
        {
            `"id`": 5653388910232868,
            `"layout`": {
                `"x`": 12,
                `"y`": 0,
                `"width`": 21,
                `"height`": 12
            },
            `"definition`": {
                `"title`": `"Processes`",
                `"title_size`": `"16`",
                `"title_align`": `"center`",
                `"time`": {
                    `"live_span`": `"5m`"
                },
                `"type`": `"query_value`",
                `"requests`": [
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"query1`"
                            }
                        ],
                        `"conditional_formats`": [
                            {
                                `"comparator`": `"<`",
                                `"palette`": `"white_on_green`",
                                `"value`": 128
                            }
                        ],
                        `"response_format`": `"scalar`",
                        `"queries`": [
                            {
                                `"query`": `"sum:system.proc.count{host:$($ServerName)}`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query1`",
                                `"aggregator`": `"avg`"
                            }
                        ]
                    }
                ],
                `"precision`": 0
            }
        },
        {
            `"id`": 6858073640130550,
            `"layout`": {
                `"x`": 34,
                `"y`": 0,
                `"width`": 21,
                `"height`": 12
            },
            `"definition`": {
                `"title`": `"Free RAM`",
                `"title_size`": `"16`",
                `"title_align`": `"center`",
                `"type`": `"query_value`",
                `"requests`": [
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"query1`"
                            }
                        ],
                        `"conditional_formats`": [
                            {
                                `"comparator`": `">`",
                                `"palette`": `"white_on_green`",
                                `"value`": 2
                            },
                            {
                                `"comparator`": `">=`",
                                `"palette`": `"white_on_yellow`",
                                `"value`": 1.5
                            },
                            {
                                `"comparator`": `"<`",
                                `"palette`": `"white_on_red`",
                                `"value`": 1.5
                            }
                        ],
                        `"response_format`": `"scalar`",
                        `"queries`": [
                            {
                                `"query`": `"avg:system.mem.free{host:$($ServerName)}`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query1`",
                                `"aggregator`": `"avg`"
                            }
                        ]
                    }
                ],
                `"autoscale`": true,
                `"precision`": 2
            }
        },
        {
            `"id`": 4528888829483686,
            `"layout`": {
                `"x`": 17,
                `"y`": 64,
                `"width`": 108,
                `"height`": 48
            },
            `"definition`": {
                `"title`": `"Event Log`",
                `"title_size`": `"16`",
                `"title_align`": `"left`",
                `"type`": `"event_stream`",
                `"query`": `"source:event_viewer host:$($ServerName) env:prod`",
                `"tags_execution`": `"and`",
                `"event_size`": `"l`"
            }
        },
        {
            `"id`": 5417988967638802,
            `"layout`": {
                `"x`": 48,
                `"y`": 13,
                `"width`": 47,
                `"height`": 16
            },
            `"definition`": {
                `"title`": `"Total %CPU`",
                `"title_size`": `"16`",
                `"title_align`": `"left`",
                `"show_legend`": false,
                `"legend_layout`": `"auto`",
                `"legend_columns`": [
                    `"avg`",
                    `"min`",
                    `"max`",
                    `"value`",
                    `"sum`"
                ],
                `"type`": `"timeseries`",
                `"requests`": [
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"query1 + query2`"
                            }
                        ],
                        `"response_format`": `"timeseries`",
                        `"queries`": [
                            {
                                `"query`": `"avg:system.cpu.user{host:$($ServerName)} by {host}`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query1`"
                            },
                            {
                                `"query`": `"avg:system.cpu.system{host:$($ServerName)} by {host}`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query2`"
                            }
                        ],
                        `"style`": {
                            `"palette`": `"dog_classic`",
                            `"line_type`": `"solid`",
                            `"line_width`": `"normal`"
                        },
                        `"display_type`": `"line`"
                    }
                ],
                `"yaxis`": {
                    `"min`": `"0`",
                    `"max`": `"100`"
                },
                `"markers`": [
                    {
                        `"value`": `"60 < y < 100`",
                        `"display_type`": `"error dashed`"
                    },
                    {
                        `"value`": `"40 < y < 60`",
                        `"display_type`": `"warning dashed`"
                    }
                ]
            }
        },
        {
            `"id`": 8765053703176480,
            `"layout`": {
                `"x`": 0,
                `"y`": 47,
                `"width`": 47,
                `"height`": 16
            },
            `"definition`": {
                `"title`": `"CadLink Windows Service (#Threads)`",
                `"title_size`": `"16`",
                `"title_align`": `"left`",
                `"show_legend`": false,
                `"legend_layout`": `"auto`",
                `"legend_columns`": [
                    `"avg`",
                    `"min`",
                    `"max`",
                    `"value`",
                    `"sum`"
                ],
                `"type`": `"timeseries`",
                `"requests`": [
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"query1`"
                            }
                        ],
                        `"response_format`": `"timeseries`",
                        `"queries`": [
                            {
                                `"query`": `"avg:system.processes.threads{process_name:cadlinkserverwindowsservice,host:$($ServerName)} by {host}`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query1`"
                            }
                        ],
                        `"style`": {
                            `"palette`": `"dog_classic`",
                            `"line_type`": `"solid`",
                            `"line_width`": `"normal`"
                        },
                        `"display_type`": `"line`"
                    }
                ],
                `"yaxis`": {
                    `"include_zero`": true,
                    `"scale`": `"linear`",
                    `"label`": `"`",
                    `"min`": `"auto`",
                    `"max`": `"auto`"
                },
                `"markers`": [
                    {
                        `"value`": `"0 < y < 309`",
                        `"display_type`": `"ok dashed`"
                    },
                    {
                        `"value`": `"310 < y < 349`",
                        `"display_type`": `"warning dashed`"
                    },
                    {
                        `"value`": `"y > 350`",
                        `"display_type`": `"error dashed`"
                    }
                ]
            }
        },
        {
            `"id`": 4960936844884918,
            `"layout`": {
                `"x`": 0,
                `"y`": 13,
                `"width`": 47,
                `"height`": 16
            },
            `"definition`": {
                `"title`": `"CadLink Windows Service (%CPU)`",
                `"title_size`": `"16`",
                `"title_align`": `"left`",
                `"show_legend`": true,
                `"legend_layout`": `"auto`",
                `"legend_columns`": [
                    `"avg`",
                    `"min`",
                    `"max`",
                    `"value`",
                    `"sum`"
                ],
                `"type`": `"timeseries`",
                `"requests`": [
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"query1`"
                            }
                        ],
                        `"response_format`": `"timeseries`",
                        `"queries`": [
                            {
                                `"query`": `"avg:system.processes.cpu.normalized_pct{process_name:cadlinkserverwindowsservice,host:$($ServerName)} by {host}`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query1`"
                            }
                        ],
                        `"style`": {
                            `"palette`": `"dog_classic`",
                            `"line_type`": `"solid`",
                            `"line_width`": `"normal`"
                        },
                        `"display_type`": `"line`"
                    }
                ]
            }
        },
        {
            `"id`": 8845924960084788,
            `"layout`": {
                `"x`": 48,
                `"y`": 47,
                `"width`": 47,
                `"height`": 16
            },
            `"definition`": {
                `"title`": `"CadLink Windows Service (Wall Time) **Requires APM**`",
                `"title_size`": `"16`",
                `"title_align`": `"left`",
                `"show_legend`": true,
                `"legend_layout`": `"auto`",
                `"legend_columns`": [
                    `"avg`",
                    `"min`",
                    `"max`",
                    `"value`",
                    `"sum`"
                ],
                `"type`": `"timeseries`",
                `"requests`": [
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"query1`"
                            }
                        ],
                        `"response_format`": `"timeseries`",
                        `"queries`": [
                            {
                                `"search`": {
                                    `"query`": `"env:prod service:cadlinkserverservice`"
                                },
                                `"data_source`": `"profiles`",
                                `"compute`": {
                                    `"metric`": `"@prof_dotnet_wall_time`",
                                    `"aggregation`": `"avg`"
                                },
                                `"name`": `"query1`",
                                `"indexes`": [
                                    `"*`"
                                ],
                                `"group_by`": [
                                    {
                                        `"facet`": `"service`",
                                        `"sort`": {
                                            `"metric`": `"@prof_dotnet_wall_time`",
                                            `"aggregation`": `"avg`",
                                            `"order`": `"desc`"
                                        },
                                        `"limit`": 10
                                    }
                                ]
                            }
                        ],
                        `"style`": {
                            `"palette`": `"dog_classic`",
                            `"line_type`": `"solid`",
                            `"line_width`": `"normal`"
                        },
                        `"display_type`": `"line`"
                    }
                ]
            }
        },
        {
            `"id`": 1666283354265998,
            `"layout`": {
                `"x`": 96,
                `"y`": 30,
                `"width`": 47,
                `"height`": 16
            },
            `"definition`": {
                `"title`": `"CadLink Windows Service (Total RAM)`",
                `"title_size`": `"16`",
                `"title_align`": `"left`",
                `"show_legend`": false,
                `"legend_layout`": `"auto`",
                `"legend_columns`": [
                    `"avg`",
                    `"min`",
                    `"max`",
                    `"value`",
                    `"sum`"
                ],
                `"type`": `"timeseries`",
                `"requests`": [
                    {
                        `"formulas`": [
                            {
                                `"formula`": `"query1`"
                            }
                        ],
                        `"response_format`": `"timeseries`",
                        `"queries`": [
                            {
                                `"query`": `"avg:system.processes.mem.rss{host:$($ServerName),process_name:cadlinkserverwindowsservice}`",
                                `"data_source`": `"metrics`",
                                `"name`": `"query1`"
                            }
                        ],
                        `"style`": {
                            `"palette`": `"dog_classic`",
                            `"line_type`": `"solid`",
                            `"line_width`": `"normal`"
                        },
                        `"display_type`": `"line`"
                    }
                ],
                `"yaxis`": {
                    `"include_zero`": true,
                    `"scale`": `"linear`",
                    `"label`": `"`",
                    `"min`": `"auto`",
                    `"max`": `"auto`"
                }
            }
        }
    ],
    `"template_variables`": [],
    `"layout_type`": `"free`",
    `"is_read_only`": false,
    `"notify_list`": [],
    `"id`": `"3t9-iva-xjn`"
}"

$newdashboardheaders = @{
    "DD-API-KEY" = $apikey
    "DD-APPLICATION-KEY" = $appkey
    "Content-Type" = "application/json"
}

$newdashboardparams = @{
    Uri = "https://api.datadoghq.com/api/v1/dashboard"
    Method = "POST"
    Headers = $newdashboardheaders
    Body = $newdashboardJSON
}  
   
$global:new_Dashboard_Response = Invoke-RestMethod @newdashboardparams
Write-Host "Done" -ForegroundColor Cyan
$new_Dashboard_Response | Out-File .\Dashboard-Response.txt
