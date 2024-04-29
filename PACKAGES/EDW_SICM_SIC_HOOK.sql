--------------------------------------------------------
--  DDL for Package EDW_SICM_SIC_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_SICM_SIC_HOOK" AUTHID CURRENT_USER AS
/* $Header: FIISICHS.pls 120.0 2002/08/24 05:01:16 appldev noship $ */

  FUNCTION POST_DIM_COLLECT(p_object_name varchar2) RETURN BOOLEAN;

END EDW_SICM_SIC_HOOK;

 

/
