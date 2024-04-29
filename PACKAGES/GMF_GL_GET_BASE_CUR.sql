--------------------------------------------------------
--  DDL for Package GMF_GL_GET_BASE_CUR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GL_GET_BASE_CUR" AUTHID CURRENT_USER as
/* $Header: gmfbascs.pls 115.0 99/07/16 04:14:58 porting shi $ */
	function GET_BASE_CUR ( PORG_ID NUMBER)
			return varchar2;
END GMF_GL_GET_BASE_CUR;

 

/
