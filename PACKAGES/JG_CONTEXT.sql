--------------------------------------------------------
--  DDL for Package JG_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_CONTEXT" AUTHID CURRENT_USER AS
/* $Header: jgzzscxs.pls 120.2 2005/07/29 23:05:04 appradha ship $ */
PROCEDURE initialize;

PROCEDURE name_value (name VARCHAR2, value VARCHAR2);
END jg_context;

 

/
