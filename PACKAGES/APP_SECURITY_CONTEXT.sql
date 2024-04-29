--------------------------------------------------------
--  DDL for Package APP_SECURITY_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."APP_SECURITY_CONTEXT" AUTHID CURRENT_USER AS
/* $Header: ahmpascs.pls 115.1 2001/09/18 13:08:29 pkm ship      $ */
-- DESCRIPTION: Creates the app_security_context package

   PROCEDURE Set_empno(sec_group_id NUMBER);
END;

 

/
