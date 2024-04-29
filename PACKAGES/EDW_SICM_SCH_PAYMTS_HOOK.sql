--------------------------------------------------------
--  DDL for Package EDW_SICM_SCH_PAYMTS_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_SICM_SCH_PAYMTS_HOOK" AUTHID CURRENT_USER as
/* $Header: FIIASPHS.pls 120.0 2002/08/24 04:49:07 appldev noship $ */

  FUNCTION Pre_Fact_Collect(p_object_name varchar2) RETURN BOOLEAN;

END  EDW_SICM_SCH_PAYMTS_HOOK;

 

/
