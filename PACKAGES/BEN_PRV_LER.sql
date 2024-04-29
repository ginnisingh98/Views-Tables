--------------------------------------------------------
--  DDL for Package BEN_PRV_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRV_LER" AUTHID CURRENT_USER as
/* $Header: beprvtrg.pkh 115.5 2003/12/18 02:46:28 hmani ship $ */
TYPE g_prv_ler_rec is RECORD
(PRTT_ENRT_RSLT_ID NUMBER
,PRTT_RT_VAL_ID   NUMBER
,BUSINESS_GROUP_ID NUMBER
,RT_STRT_DT        DATE
,RT_END_DT         DATE
,CMCD_RT_VAL       NUMBER(15,2)
,ANN_RT_VAL        NUMBER(15,2)
,RT_VAL            NUMBER
,RT_OVRIDN_FLAG    VARCHAR2(30)
,RT_OVRIDN_THRU_DT DATE
,ELCTNS_MADE_DT    DATE
,TX_TYP_CD         VARCHAR2(30)
,ACTY_TYP_CD       VARCHAR2(30)
,PER_IN_LER_ID     NUMBER
,ACTY_BASE_RT_ID   NUMBER
,PRTT_RT_VAL_STAT_CD VARCHAR2(30)
);

procedure ler_chk(p_old IN g_prv_ler_rec
                 ,p_new IN g_prv_ler_rec
                 ,p_effective_date IN date );
end;

 

/
