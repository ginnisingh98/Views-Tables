--------------------------------------------------------
--  DDL for Package GL_GLXRLSEG_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRLSEG_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRLSEGS.pls 120.0 2007/12/27 15:19:16 vijranga noship $ */
	P_SEGMENT_NAME	varchar2(30);
	P_STRUCT_NUM	number;
	P_CONC_REQUEST_ID	number;
	COA_NAME	varchar2(30);
	APROMPT	varchar2(80);
	APRINTSWITCH	varchar2(1);
	VSETID	number;
	PAPROMPT	varchar2(80);
	SEGMENT_TYPE	varchar2(32767);
	PVSETID	number;
	POSITION	number;
	POST_POSITION	number;
	BUDGET_POSITION	number;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function COA_NAME_p return varchar2;
	Function APROMPT_p return varchar2;
	Function APRINTSWITCH_p return varchar2;
	Function VSETID_p return number;
	Function PAPROMPT_p return varchar2;
	Function SEGMENT_TYPE_p return varchar2;
	Function PVSETID_p return number;
	Function POSITION_p return number;
	Function POST_POSITION_p return number;
	Function BUDGET_POSITION_p return number;
END GL_GLXRLSEG_XMLP_PKG;


/
