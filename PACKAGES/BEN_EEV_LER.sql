--------------------------------------------------------
--  DDL for Package BEN_EEV_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EEV_LER" AUTHID CURRENT_USER as
/* $Header: beeevtrg.pkh 115.2 2003/02/13 06:26:38 rpgupta ship $ */
TYPE g_eev_ler_rec is RECORD
(ELEMENT_ENTRY_VALUE_ID NUMBER
,SCREEN_ENTRY_VALUE VARCHAR2(60)
);

procedure ler_chk(p_old IN g_eev_ler_rec
                 ,p_new IN g_eev_ler_rec);
end;

 

/
