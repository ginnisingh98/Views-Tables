--------------------------------------------------------
--  DDL for Package PER_PERRPRPH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERRPRPH_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERRPRPHS.pls 120.1 2007/12/06 11:33:32 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_SESSION_DATE1 varchar2(240);
	P_CONC_REQUEST_ID	number;
	P_POS_STRUCTURE_VERSION_ID	number;
	P_PARENT_POSITION_ID	number;
	P_HOLDER_FLAG	varchar2(30);
	C_BUSINESS_GROUP_NAME	varchar2(60);
	C_REPORT_SUBTITLE	varchar2(60);
	C_POS_HIERARCHY_NAME	varchar2(30);
	C_VERSION	number;
	C_VERSION_START_DATE	date;
	C_VERSION_END_DATE	date;
	C_PARENT_POSITION_NAME	varchar2(240);
	C_HOLDERS_SHOWN	varchar2(30);
	C_SESSION_DATE	date;
	function BeforeReport return boolean  ;
	function c_nameformula(parent_position_id in number) return varchar2  ;
	function c_count_subordsformula(parent_position_id in number) return number  ;
	function c_count_subords1formula(subordinate_position_id in number) return number  ;
	--function c_count_child_posformula(parent_position_id in number) return number  ;
	function c_count_child_posformula(arg_parent_position_id in number) return number  ;
	function c_count_holdersformula(parent_position_id in number) return number  ;
	function c_count_holders1formula(subordinate_position_id in number) return number  ;
	function AfterReport return boolean  ;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_POS_HIERARCHY_NAME_p return varchar2;
	Function C_VERSION_p return number;
	Function C_VERSION_START_DATE_p return date;
	Function C_VERSION_END_DATE_p return date;
	Function C_PARENT_POSITION_NAME_p return varchar2;
	Function C_HOLDERS_SHOWN_p return varchar2;
	Function C_SESSION_DATE_p return date;
END PER_PERRPRPH_XMLP_PKG;

/
