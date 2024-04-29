--------------------------------------------------------
--  DDL for Package EDW_SICM_INV_ON_HOLD_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_SICM_INV_ON_HOLD_HOOK" AUTHID CURRENT_USER as
/* $Header: FIIAIHHS.pls 120.0 2002/08/24 04:40:33 appldev noship $ */

  FUNCTION Pre_Fact_Collect(p_object_name varchar2) RETURN BOOLEAN;

END EDW_SICM_INV_ON_HOLD_HOOK;

 

/
