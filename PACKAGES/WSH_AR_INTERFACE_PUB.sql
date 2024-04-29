--------------------------------------------------------
--  DDL for Package WSH_AR_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_AR_INTERFACE_PUB" AUTHID CURRENT_USER as
/* $Header: WSHARMGS.pls 115.1 99/07/16 08:17:51 porting ship $ */
--
-- Package
--   WSH_AR_INTERFACE_PUB
-- Purpose
--   Stub routine using which client might NULL out some of Mandatory
--   grouping Rule Columns
-- History
--   04-FEB-97	ANEOGI	Created

  --
  -- PUBLIC VARIABLES
  --
  TYPE cintTabTyp IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
  TYPE cnameTabTyp IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  TYPE cvalTabTyp IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;

  -- name of the columns which will passed and the value could be modified to NULL

  col_comments          CONSTANT varchar2(30) := 'COMMENTS';
  col_cr_mthd_acct_rule CONSTANT varchar2(30) := 'CREDIT_METHOD_FOR_ACCT_RULE';
  col_cr_mthd_install  CONSTANT varchar2(30)  := 'CREDIT_METHOD_FOR_INSTALLMENTS';
  col_hdr_attr1         CONSTANT varchar2(30) := 'HEADER_ATTRIBUTE1';
  col_hdr_attr2         CONSTANT varchar2(30) := 'HEADER_ATTRIBUTE2';
  col_hdr_attr3         CONSTANT varchar2(30) := 'HEADER_ATTRIBUTE3';
  col_hdr_attr4         CONSTANT varchar2(30) := 'HEADER_ATTRIBUTE4';
  col_hdr_attr5         CONSTANT varchar2(30) := 'HEADER_ATTRIBUTE5';
  col_hdr_attr6         CONSTANT varchar2(30) := 'HEADER_ATTRIBUTE6';
  col_hdr_attr7         CONSTANT varchar2(30) := 'HEADER_ATTRIBUTE7';
  col_hdr_attr8         CONSTANT varchar2(30) := 'HEADER_ATTRIBUTE8';
  col_hdr_attr9         CONSTANT varchar2(30) := 'HEADER_ATTRIBUTE9';
  col_hdr_attr10        CONSTANT varchar2(30) := 'HEADER_ATTRIBUTE10';
  col_hdr_attr11        CONSTANT varchar2(30) := 'HEADER_ATTRIBUTE11';
  col_hdr_attr12        CONSTANT varchar2(30) := 'HEADER_ATTRIBUTE12';
  col_hdr_attr13        CONSTANT varchar2(30) := 'HEADER_ATTRIBUTE13';
  col_hdr_attr14        CONSTANT varchar2(30) := 'HEADER_ATTRIBUTE14';
  col_hdr_attr15        CONSTANT varchar2(30) := 'HEADER_ATTRIBUTE15';
  col_hdr_attr_cat      CONSTANT varchar2(30) := 'HEADER_ATTRIBUTE_CATEGORY';
  col_orig_bill_contact_id CONSTANT varchar2(30):='ORIG_SYSTEM_BILL_CONTACT_ID';
  col_orig_bill_cust_id CONSTANT varchar2(30) := 'ORIG_SYSTEM_BILL_CUSTOMER_ID';
  col_orig_ship_contact_id CONSTANT varchar2(30):='ORIG_SYSTEM_SHIP_CONTACT_ID';
  col_purchase_order    CONSTANT varchar2(30) := 'PURCHASE_ORDER';
  col_reason_code       CONSTANT varchar2(30) := 'REASON_CODE';


  --
  -- PUBLIC FUNCTIONS
  --

  -- Name
  --   wsh_ar_null_grouping_cols
  -- Purpose
  --   It passes the column names in the first parameters and their existing
  --   values in the 2nd parameter. User could check the names and NULL out
  --   any of those column values.
  -- Arguments
  --   col_names
  --   col_values

    PROCEDURE wsh_ar_null_group_cols(
	  col_names                       IN     cnameTabTyp,
	  col_values                      IN OUT cvalTabTyp);


END WSH_AR_INTERFACE_PUB;

 

/
