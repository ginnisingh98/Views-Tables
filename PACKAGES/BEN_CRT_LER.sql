--------------------------------------------------------
--  DDL for Package BEN_CRT_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CRT_LER" AUTHID CURRENT_USER as
/* $Header: becrttrg.pkh 115.9 2003/12/18 02:45:46 hmani ship $*/
TYPE g_crt_ler_rec is RECORD
(PERSON_ID NUMBER
,BUSINESS_GROUP_ID NUMBER
,APLS_PERD_STRTG_DT DATE
,APLS_PERD_ENDG_DT DATE
,CRT_ORDR_TYP_CD VARCHAR2(30)
,rcvd_dt           date
,pl_id             number
,pl_typ_id         number
,crt_ordr_id       number
);

procedure ler_chk(p_old IN g_crt_ler_rec
                 ,p_new IN g_crt_ler_rec
                 ,p_effective_date in date );
end;

 

/
