--------------------------------------------------------
--  DDL for Package EDW_SICM_HOLD_DATA_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_SICM_HOLD_DATA_HOOK" AUTHID CURRENT_USER as
/* $Header: FIIAHDHS.pls 120.0 2002/08/24 04:40:22 appldev noship $ */

  FUNCTION Pre_Fact_Collect(p_object_name varchar2) RETURN BOOLEAN;

END EDW_SICM_HOLD_DATA_HOOK;

 

/
