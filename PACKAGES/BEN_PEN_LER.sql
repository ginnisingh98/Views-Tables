--------------------------------------------------------
--  DDL for Package BEN_PEN_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PEN_LER" AUTHID CURRENT_USER as
/* $Header: bepentrg.pkh 115.3 2003/12/18 02:46:14 hmani ship $ */
TYPE g_pen_ler_rec is RECORD
(PERSON_ID NUMBER
,PRTT_ENRT_RSLT_ID NUMBER
,BUSINESS_GROUP_ID NUMBER
,ENRT_CVG_STRT_DT DATE
,ENRT_CVG_THRU_DT DATE
,BNFT_AMT  NUMBER
,EFFECTIVE_START_DATE DATE
,EFFECTIVE_END_DATE DATE
);

procedure ler_chk(p_old IN g_pen_ler_rec
                 ,p_new IN g_pen_ler_rec
                 ,p_effective_date IN date default NULL );
end;

 

/
