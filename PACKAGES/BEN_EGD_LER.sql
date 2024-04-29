--------------------------------------------------------
--  DDL for Package BEN_EGD_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EGD_LER" AUTHID CURRENT_USER as
/* $Header: beegdtrg.pkh 120.0.12000000.1 2007/01/19 04:53:50 appldev noship $ */
TYPE g_egd_ler_rec is RECORD
(DPNT_PERSON_ID NUMBER
,BUSINESS_GROUP_ID NUMBER
,ELIG_STRT_DT DATE
,ELIG_THRU_DT DATE
,DPNT_INELIG_FLAG VARCHAR2(30)
,OVRDN_FLAG  VARCHAR2(30)
,CREATE_DT DATE
,OVRDN_THRU_DT DATE
,ELIG_DPNT_ID NUMBER
,INELG_RSN_CD VARCHAR2(30)
,ELIG_PER_ELCTBL_CHC_ID NUMBER
,PER_IN_LER_ID  NUMBER
,ELIG_PER_ID    NUMBER
,ELIG_PER_OPT_ID NUMBER
,ELIG_CVRD_DPNT_ID NUMBER
);

procedure ler_chk(p_old            in g_egd_ler_rec
                 ,p_new            in g_egd_ler_rec
                 ,p_effective_date in date);
end;

 

/
