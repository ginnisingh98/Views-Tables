--------------------------------------------------------
--  DDL for Package BEN_ECD_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ECD_LER" AUTHID CURRENT_USER as
/*$Header: beecdtrg.pkh 120.1.12000000.1 2007/01/19 03:49:38 appldev noship $*/
TYPE g_ecd_ler_rec is RECORD
(PRTT_ENRT_RSLT_ID NUMBER
,ELIG_CVRD_DPNT_ID NUMBER
,DPNT_PERSON_ID    NUMBER
,BUSINESS_GROUP_ID NUMBER
,EFFECTIVE_START_DATE DATE
,EFFECTIVE_END_DATE DATE
--,CVRD_FLAG VARCHAR2(30)
,CVG_STRT_DT DATE
,CVG_THRU_DT DATE
,OVRDN_FLAG VARCHAR2(30)
,OVRDN_THRU_DT DATE
);
procedure ler_chk(p_old IN g_ecd_ler_rec
                 ,p_new IN g_ecd_ler_rec
                 ,p_effective_date IN date default NULL );
end;

 

/
