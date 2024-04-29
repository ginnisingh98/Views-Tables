--------------------------------------------------------
--  DDL for Package BEN_PPS_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PPS_LER" AUTHID CURRENT_USER as
/* $Header: bepsptrg.pkh 120.0.12000000.1 2007/01/19 22:29:16 appldev noship $*/
--
-- Bug 1805328 : Added FINAL_PROCESS_DATE
--
TYPE g_pps_ler_rec is RECORD
(PERSON_ID NUMBER
,BUSINESS_GROUP_ID NUMBER
,DATE_START DATE
,ACTUAL_TERMINATION_DATE DATE
,LEAVING_REASON VARCHAR2(30)
,ADJUSTED_SVC_DATE DATE
,ATTRIBUTE1 VARCHAR2(150)
,ATTRIBUTE2 VARCHAR2(150)
,ATTRIBUTE3 VARCHAR2(150)
,ATTRIBUTE4 VARCHAR2(150)
,ATTRIBUTE5 VARCHAR2(150)
,FINAL_PROCESS_DATE DATE
,PERIOD_OF_SERVICE_ID NUMBER
);

procedure ler_chk(p_old            in g_pps_ler_rec
                 ,p_new            in g_pps_ler_rec
                 ,p_event          in varchar2
                 ,p_effective_date in date);


 -- this is added to avoid the life event created for termination while reversing the termination
 -- this is to be removed when the HR fix the bug
 ben_pps_evt_chk  number := 0 ;

end;

 

/
