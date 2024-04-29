--------------------------------------------------------
--  DDL for Package Body BIS_RG_FIX_AKFLEX_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RG_FIX_AKFLEX_DATA" as
/* $Header: BISVAFXB.pls 115.4 2002/11/19 19:04:06 kiprabha noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile:~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      BIS_SCHEDULE_PVT
--                                                                        --
--  DESCRIPTION:  Private package to move the AK region flex field data
--                for Report Regions from global data elements context to
--                BIS PM Viewer context                                   --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                --
--  02-25-00   amkulkar   Initial creation                                --
----------------------------------------------------------------------------
PROCEDURE FIX_AK_REGIONITEMS
(
 x_return_code    OUT  NOCOPY NUMBER
,x_return_status  OUT  NOCOPY VARCHAR2
)
IS
   CURSOR c_repregions IS
   SELECT substr(web_html_call,
                 instr(web_html_call, '''',1,1) + 1,
                 instr(web_html_call, '''',1,2) -
                 instr(web_html_call, '''',1,1) - 1) region_code
   FROM  fnd_form_functions
   WHERE upper(web_html_call) like 'BISVIEWER.SHOWREPORT%';
   l_count  NUMBER := 0;
BEGIN
   FOR c_rec IN c_repregions LOOP
       UPDATE ak_region_items
       SET attribute_category='BIS PM Viewer'
       WHERE region_code=c_rec.region_code;
       l_Count := l_count+1;
   END LOOP;
   --x_return_Status := to_char(l_Count) || ' records updated in ak_region_items table  ';
EXCEPTION
WHEN OTHERS THEN
     x_return_code := SQLCODE;
     x_return_status := SQLERRM;
END;
PROCEDURE FIX_AK_REGIONS
(
 x_return_code    OUT  NOCOPY NUMBER
,x_return_status  OUT  NOCOPY VARCHAR2
)
IS
   CURSOR c_repregions IS
   SELECT substr(web_html_call,
                 instr(web_html_call, '''',1,1) + 1,
                 instr(web_html_call, '''',1,2) -
                 instr(web_html_call, '''',1,1) - 1) region_code
   FROM  fnd_form_functions
   WHERE upper(web_html_call) like 'BISVIEWER.SHOWREPORT%';
   l_count  NUMBER := 0;
BEGIN
   FOR c_rec IN c_repregions LOOP
       UPDATE ak_regions
       SET attribute_category='BIS PM Viewer'
       WHERE region_code=c_rec.region_code;
       l_count := l_count + 1;
   END LOOP;
   x_return_status := l_count || ' records updated in ak_regions table  ';
EXCEPTION
WHEN OTHERS THEN
     x_return_code := SQLCODE;
     x_return_status := SQLERRM;
END;
END BIS_RG_FIX_AKFLEX_DATA;

/
