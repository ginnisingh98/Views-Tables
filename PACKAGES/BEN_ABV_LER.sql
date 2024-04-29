--------------------------------------------------------
--  DDL for Package BEN_ABV_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ABV_LER" AUTHID CURRENT_USER as
/* $Header: beabvtrg.pkh 115.6 2003/12/18 02:45:36 hmani ship $ */
TYPE g_abv_ler_rec is RECORD
(ASSIGNMENT_ID NUMBER
,BUSINESS_GROUP_ID NUMBER
,VALUE NUMBER
,ASSIGNMENT_BUDGET_VALUE_ID NUMBER
,EFFECTIVE_START_DATE DATE
,EFFECTIVE_END_DATE DATE
);

procedure ler_chk(p_old IN g_abv_ler_rec
                 ,p_new IN g_abv_ler_rec
                 ,p_effective_date in date default null );
end;

 

/
