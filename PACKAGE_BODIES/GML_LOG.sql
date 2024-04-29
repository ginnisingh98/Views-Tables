--------------------------------------------------------
--  DDL for Package Body GML_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_LOG" AS
/* $Header: GMLTRLGB.pls 115.4 2002/12/04 23:32:05 uphadtar ship $ */

/*========================================================================
|  PROCEDURE:    po_tran                                                 |
|                                                                        |
|  DESCRIPTION:  This procedure selects all the rows in the purchasing   |
|                interface table which are successfully processed        |
|                or errored out and writes them into the purchasing      |
|                transaction log table. Then it deletes all those        |
|                rows from the purchasing interface table. This procedure|
|                also incrementally inserts into cpg_oragems_arch table  |
|                rows from cpg_oragems_mapping                           |
|                                                                        |
|  MODIFICATION: Kenny Jiang     11/24/97        Created                 |
========================================================================*/


PROCEDURE po_tran
IS
  err_num         NUMBER;
  err_msg         VARCHAR2(100);
  v_archival_date DATE;

  CURSOR  archival_date_cur IS
    SELECT  MAX(time_stamp)
    FROM    cpg_oragems_arch;
BEGIN

 /* INSERT INTO cpg_purchasing_arch
    SELECT *
    FROM   cpg_purchasing_interface
    WHERE  invalid_ind IN ('Y', 'P'); */

 INSERT INTO cpg_purchasing_arch(
  TRANSACTION_ID         ,
  TRANSACTION_TYPE       ,
  ORGN_CODE              ,
  PO_NO                  ,
  BPO_NO                 ,
  PO_STATUS              ,
  PO_HEADER_ID           ,
  PO_LINE_ID             ,
  PO_LINE_LOCATION_ID    ,
  PO_DISTRIBUTION_ID     ,
  PO_RELEASE_ID          ,
  RELEASE_NUM            ,
  BUYER_CODE             ,
  PO_ID                  ,
  BPO_ID                 ,
  BPO_RELEASE_NUMBER     ,
  OF_PAYVEND_SITE_ID     ,
  OF_SHIPVEND_SITE_ID    ,
  PO_DATE                ,
  PO_TYPE                ,
  FROM_WHSE              ,
  TO_WHSE                ,
  RECV_DESC              ,
  RECV_LOCT              ,
  RECVADDR_ID            ,
  SHIP_MTHD              ,
  SHIPPER_CODE           ,
  OF_FRTBILL_MTHD        ,
  OF_TERMS_CODE          ,
  BILLING_CURRENCY       ,
  PURCHASE_EXCHANGE_RATE ,
  MUL_DIV_SIGN           ,
  CURRENCY_BGHT_FWD      ,
  POHOLD_CODE            ,
  CANCELLATION_CODE      ,
  FOB_CODE               ,
  ICPURCH_CLASS          ,
  VENDSO_NO              ,
  PROJECT_NO             ,
  REQUESTED_DLVDATE      ,
  SCHED_SHIPDATE         ,
  REQUIRED_DLVDATE       ,
  AGREED_DLVDATE         ,
  DATE_PRINTED           ,
  EXPEDITE_DATE          ,
  REVISION_COUNT         ,
  IN_USE                 ,
  PRINT_COUNT            ,
  LINE_NO                ,
  LINE_STATUS            ,
  LINE_ID                ,
  BPO_LINE_ID            ,
  APINV_LINE_ID          ,
  ITEM_NO                ,
  GENERIC_ID             ,
  ITEM_DESC              ,
  ORDER_QTY1             ,
  ORDER_QTY2             ,
  ORDER_UM1              ,
  ORDER_UM2              ,
  RECEIVED_QTY1          ,
  RECEIVED_QTY2          ,
  NET_PRICE              ,
  EXTENDED_PRICE         ,
  PRICE_UM               ,
  QC_GRADE_WANTED        ,
  MATCH_TYPE             ,
  TEXT_CODE              ,
  TRANS_CNT              ,
  EXPORTED_DATE          ,
  LAST_UPDATE_DATE       ,
  CREATED_BY             ,
  CREATION_DATE          ,
  LAST_UPDATED_BY        ,
  LAST_UPDATE_LOGIN      ,
  DELETE_MARK            ,
  INVALID_IND            ,
  REL_COUNT              ,
  CONTRACT_NO            ,
  CONTRACT_VALUE         ,
  CONTRACT_END_DATE      ,
  CONTRACT_START_DATE    ,
  AMOUNT_PURCHASED       ,
  ACTIVITY_IND           ,
  CONTRACT_QTY           ,
  ITEM_UM                ,
  QTY_PURCHASED          ,
  STD_QTY                ,
  RELEASE_INTERVAL       ,
  BPO_STATUS             ,
  BPOHOLD_CODE           ,
  CLOSURE_CODE           ,
  MAX_RELS_QTY           ,
  ORGNADDR_ID            ,
  SOURCE_SHIPMENT_ID     ,
  PURCH_CATEGORY_ID )
 SELECT *
    FROM   cpg_purchasing_interface
    WHERE  invalid_ind IN ('Y', 'P');

  DELETE FROM cpg_purchasing_interface
  WHERE  invalid_ind IN ('Y', 'P');

  /* Insert rows from cpg_oragems_mapping to cpg_oragems_arch*/

  OPEN  archival_date_cur;
  FETCH archival_date_cur INTO  v_archival_date;
  IF (v_archival_date IS NOT NULL) THEN
    -- BEGIN - Bug 2100687 - Put explicit INSERT and SELECT clause
    INSERT INTO cpg_oragems_arch
    (
    PO_HEADER_ID         ,
    PO_LINE_ID           ,
    PO_LINE_LOCATION_ID  ,
    PO_ID                ,
    LINE_ID              ,
    PO_NO                ,
    BPO_ID               ,
    BPO_LINE_ID          ,
    RELEASE_NUM          ,
    PO_RELEASE_ID        ,
    PO_STATUS            ,
    TRANSACTION_TYPE     ,
    TIME_STAMP           ,
    LAST_UPDATE_LOGIN    ,
    LAST_UPDATE_DATE     ,
    LAST_UPDATED_BY      ,
    CREATED_BY           ,
    CREATION_DATE
    )
    SELECT
    PO_HEADER_ID         ,
    PO_LINE_ID           ,
    PO_LINE_LOCATION_ID  ,
    PO_ID                ,
    LINE_ID              ,
    PO_NO                ,
    BPO_ID               ,
    BPO_LINE_ID          ,
    RELEASE_NUM          ,
    PO_RELEASE_ID        ,
    PO_STATUS            ,
    TRANSACTION_TYPE     ,
    TIME_STAMP           ,
    LAST_UPDATE_LOGIN    ,
    LAST_UPDATE_DATE     ,
    LAST_UPDATED_BY      ,
    CREATED_BY           ,
    CREATION_DATE
    FROM   cpg_oragems_mapping
    WHERE  time_stamp > nvl(v_archival_date,sysdate);
  ELSE
    INSERT INTO cpg_oragems_arch
    (
    PO_HEADER_ID         ,
    PO_LINE_ID           ,
    PO_LINE_LOCATION_ID  ,
    PO_ID                ,
    LINE_ID              ,
    PO_NO                ,
    BPO_ID               ,
    BPO_LINE_ID          ,
    RELEASE_NUM          ,
    PO_RELEASE_ID        ,
    PO_STATUS            ,
    TRANSACTION_TYPE     ,
    TIME_STAMP           ,
    LAST_UPDATE_LOGIN    ,
    LAST_UPDATE_DATE     ,
    LAST_UPDATED_BY      ,
    CREATED_BY           ,
    CREATION_DATE
    )
    SELECT
    PO_HEADER_ID         ,
    PO_LINE_ID           ,
    PO_LINE_LOCATION_ID  ,
    PO_ID                ,
    LINE_ID              ,
    PO_NO                ,
    BPO_ID               ,
    BPO_LINE_ID          ,
    RELEASE_NUM          ,
    PO_RELEASE_ID        ,
    PO_STATUS            ,
    TRANSACTION_TYPE     ,
    TIME_STAMP           ,
    LAST_UPDATE_LOGIN    ,
    LAST_UPDATE_DATE     ,
    LAST_UPDATED_BY      ,
    CREATED_BY           ,
    CREATION_DATE
    FROM   cpg_oragems_mapping;
    -- END - Bug 2100687
  END IF;

  CLOSE archival_date_cur;

EXCEPTION

  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20000, err_msg);

END po_tran;

END GML_LOG;

/
