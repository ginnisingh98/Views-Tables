--------------------------------------------------------
--  DDL for Package BEN_PBB_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PBB_LER" AUTHID CURRENT_USER as
/* $Header: bepbbtrg.pkh 115.4 2003/12/18 02:46:04 hmani ship $ */
TYPE g_pbb_ler_rec is RECORD
(PERSON_ID NUMBER
,PER_BNFTS_BAL_ID NUMBER
,BUSINESS_GROUP_ID NUMBER
,EFFECTIVE_START_DATE DATE
,EFFECTIVE_END_DATE DATE
,VAL NUMBER
,BNFTS_BAL_ID NUMBER
);

procedure ler_chk(p_old IN g_pbb_ler_rec
                 ,p_new IN g_pbb_ler_rec
                 ,p_effective_date IN date default NULL );
end;

 

/
