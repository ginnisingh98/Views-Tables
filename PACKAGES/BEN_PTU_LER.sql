--------------------------------------------------------
--  DDL for Package BEN_PTU_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PTU_LER" AUTHID CURRENT_USER as
/* $Header: beptutrg.pkh 115.6 2003/12/18 02:46:49 hmani ship $ */
TYPE g_ptu_ler_rec is RECORD
(PERSON_ID NUMBER
,PERSON_TYPE_USAGE_ID NUMBER
,BUSINESS_GROUP_ID NUMBER
,PERSON_TYPE_ID NUMBER
,EFFECTIVE_START_DATE DATE
,EFFECTIVE_END_DATE DATE
);

procedure ler_chk(p_old IN g_ptu_ler_rec
                 ,p_new IN g_ptu_ler_rec
                 ,p_effective_date in date default null);
end;

 

/
