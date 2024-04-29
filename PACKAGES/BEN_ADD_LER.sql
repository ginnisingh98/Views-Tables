--------------------------------------------------------
--  DDL for Package BEN_ADD_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ADD_LER" AUTHID CURRENT_USER as
/* $Header: beaddtrg.pkh 115.6 2002/06/03 04:55:11 pkm ship     $ */
TYPE g_add_ler_rec is RECORD
(PERSON_ID NUMBER
,BUSINESS_GROUP_ID NUMBER
,DATE_FROM DATE
,DATE_TO DATE
,PRIMARY_FLAG VARCHAR2(30)
,POSTAL_CODE VARCHAR2(30)
,REGION_2 VARCHAR2(120)   -- modified size from 70 to 120, Bug 2383576
,ADDRESS_TYPE VARCHAR2(30)
,ADDRESS_ID NUMBER
);

procedure ler_chk(p_old IN g_add_ler_rec
                 ,p_new IN g_add_ler_rec
                 ,p_effective_date in date default null );
end;

 

/
