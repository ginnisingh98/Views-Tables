--------------------------------------------------------
--  DDL for Package BOM_SET_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_SET_CONTEXT" --- AUTHID CURRENT_USER
/* $Header: BOMSCTXS.pls 115.0 2003/09/25 05:47:29 djebar noship $*/
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--    BOMSCTXS.pls
--
--  DESCRIPTION
--
--      Package Bom_Set_Context
--	This will be used for setting the values in context STRUCT_TYPE_CTX
--
--  NOTES
--
--  HISTORY
--
--  24-SEP-2003 Deepak Jebar      Initial Creation
--
AS
   PROCEDURE set_struct_type_context(p_struct_type IN VARCHAR2 DEFAULT NULL);
   PROCEDURE set_application_id;
   PROCEDURE set_application_id(p_appl_resp_id IN NUMBER);
END Bom_Set_Context;

 

/
