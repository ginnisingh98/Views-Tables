--------------------------------------------------------
--  DDL for Package Body ICX_GET_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_GET_ORDER" AS
/* $Header: ICXGETOB.pls 115.0 99/07/17 03:17:31 porting ship $ */

function GET_PO_NUMBER (
		IN_HEAD_ID number
) return VARCHAR2 is
CODE_ID VARCHAR2(20);
begin
select
  SEGMENT1
  into CODE_ID
  from PO_HEADERS_ALL POHEAD
  where 	PO_HEADER_ID = IN_HEAD_ID
  ;
  return CODE_ID;
end GET_PO_NUMBER;

function GET_REQ_NUMBER (
		IN_HEAD_ID number
) return VARCHAR2 is
CODE_ID VARCHAR2(20);
begin
select
  SEGMENT1
  into CODE_ID
  from PO_REQUISITION_HEADERS_ALL
  where 	REQUISITION_HEADER_ID = IN_HEAD_ID
  ;
  return CODE_ID;
end GET_REQ_NUMBER;

function GET_SO_NUMBER (
		IN_HEAD_ID number
) return VARCHAR2 is
CODE_ID VARCHAR2(20);
begin
select
  SEGMENT1
  into CODE_ID
  from MTL_SALES_ORDERS
  where 	SALES_ORDER_ID = IN_HEAD_ID
  ;
  return CODE_ID;
end GET_SO_NUMBER;

function GET_WIP_NUMBER (
		IN_HEAD_ID number
) return VARCHAR2 is
CODE_ID VARCHAR2(240);
begin
select
  WIP_ENTITY_NAME
  into CODE_ID
  from WIP_ENTITIES
  where 	WIP_ENTITY_ID = IN_HEAD_ID
  ;
  return CODE_ID;
end GET_WIP_NUMBER;

END ICX_GET_ORDER;

/
