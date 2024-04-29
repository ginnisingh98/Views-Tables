--------------------------------------------------------
--  DDL for Package PO_POXRQOBO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXRQOBO_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRQOBOS.pls 120.3 2007/12/25 11:53:10 krreddy noship $ */
 P_title varchar2(50);
 P_CONC_REQUEST_ID number;
 P_FLEX_ITEM varchar2(800);
 P_FLEX_CAT varchar2(3100);
 P_CREATION_DATE_FROM varchar2(40);
 P_CREATION_DATE_TO varchar2(40);
 P_REQUESTOR varchar2(40);
 P_SUBINVENTORY_TO varchar2(40);
 P_SUBINVENTORY_FROM varchar2(40);
 P_QTY_PRECISION number;
 QTY_PRECISION varchar2(100);
 P_STRUCT_NUM number;
 P_OE_STATUS varchar2(1);
 P_CR_INSTALLED varchar2(100);
 function BeforeReport return boolean ;
 function AfterReport return boolean  ;
 function get_p_struct_num return boolean  ;
 function C_backorderedFormula return VARCHAR2  ;
 function C_whereFormula return VARCHAR2  ;
 function C_fromFormula return VARCHAR2  ;
 function g_requisitiongroupfilter(backordered in number) return boolean  ;
 function C_ship_quantityFormula return VARCHAR2  ;
END PO_POXRQOBO_XMLP_PKG;


/
