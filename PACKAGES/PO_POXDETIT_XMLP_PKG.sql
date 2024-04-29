--------------------------------------------------------
--  DDL for Package PO_POXDETIT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXDETIT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXDETITS.pls 120.1 2007/12/25 10:55:25 krreddy noship $ */
	P_title	varchar2(50);
	P_ACTIVE_INACTIVE	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_FLEX_ITEM	varchar2(800);
	P_STRUCT_NUM	varchar2(40);
	P_FLEX_ACC	varchar2(31000);
	P_FLEX_CAT	varchar2(31000);
	P_FLEX_ASS	varchar2(800);
	P_buyer_name	varchar2(80);
	P_WHERE_CAT	varchar2(1000);
	P_category_from	varchar2(900);
	P_category_to	varchar2(900);
	P_WHERE_ITEM	varchar2(1000);
	P_item_from	varchar2(900);
	P_item_to	varchar2(900);
	P_ORDERBY	varchar2(40);
	P_ORDERBY_CAT	varchar2(298);
	P_ORDERBY_ITEM	varchar2(298);
	P_qty_precision	number;
	ORG_ID	varchar2(40);
	P_act_inact_disp	varchar2(80);
	P_item_cross_ref	varchar2(40);
	P_ITEM_STRUCT_NUM	varchar2(40);
	P_ASS_STRUCT_NUM	varchar2(40);
	P_OFA_STATUS	varchar2(32767);
	P_CST_STATUS	varchar2(32767);
	P_fa_installed	number;
	P_acat_struct_num	number;
	ORGANIZATION_ID	varchar2(40);
	P_CHART_OF_ACCOUNTS_ID	number;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function orderby_clauseFormula return VARCHAR2  ;
	procedure get_precision  ;
	function get_p_struct_num return boolean  ;
	function C_OFA_dynamicFormula return VARCHAR2  ;
	function C_OFA_WhereFormula return VARCHAR2  ;
	function C_CST_SELECTFormula return VARCHAR2  ;
	function C_CST_FROMFormula return VARCHAR2  ;
	function C_CST_WHEREFormula return VARCHAR2  ;
	function noteformula(item_note_datatype_id in number, item_note_media_id in number) return char  ;
	l_INDUSTRY       VARCHAR2(100);
        l_ORACLE_SCHEMA VARCHAR2(100);
        temp boolean;
END PO_POXDETIT_XMLP_PKG;


/
