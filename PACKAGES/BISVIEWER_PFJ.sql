--------------------------------------------------------
--  DDL for Package BISVIEWER_PFJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BISVIEWER_PFJ" AUTHID CURRENT_USER as
/* $Header: BISPFJS.pls 115.14 2002/12/23 18:41:20 kiprabha ship $ */

FUNCTION pieDataSet (inputStr IN VARCHAR2, pGraphDataPoints in varchar2, pGraphLegend in out NOCOPY varchar2)
RETURN VARCHAR2;

function  buildChartApplet ( pAppletWidth in number,
                             pAppletHeight in number,
                             pFrameYaxis  in number,
                             pFrameHeight in number,
                             pGraphStyle  in varchar2,
                             pGraphyaxis  in varchar2,
                             pGraphTitle  in varchar2,
                             pGraphLegend in varchar2,
                             pXaxisLabel  in varchar2,
                             pGraphValue  in varchar2,
                             pGraphDataPoints in varchar2,
                             pGraphName in varchar2 default null,
                             pRequestType in varchar2 default null,
                             pScheduleId in number default null,
			     pDeltaFontSize  in number default 0,
			     pFontType  in varchar2 default 'Dialog',
			     -- mdamle 09/07/01 - Add Graph Number poplist
			     pFileId    in number default null
                           ) return  varchar2;

end bisviewer_pfj;

 

/
