--------------------------------------------------------
--  DDL for Package AR_ARATAPPM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARATAPPM_PKG" AUTHID CURRENT_USER AS
/*$Header: ARATAPPMS.pls 120.0.12010000.2 2009/03/25 15:18:38 vsanka noship $*/

/*
*  Automatic Cash Application Execution Report
*
*  Created by		: 	vsanka
*  Creation Date	:	03-24-09
*  Description		:	Utilities of ARATAPPM XML Pub Report.
*/

      p_org_id               NUMBER;
      p_receipt_no_l         VARCHAR2(50);
      p_receipt_no_h         VARCHAR2(50);
      p_batch_name_l         VARCHAR2(50);
      p_batch_name_h         VARCHAR2(50);
      p_min_unapp_amt        NUMBER;
      p_receipt_date_l       VARCHAR2(50);
      p_receipt_date_h       VARCHAR2(50);
      p_receipt_method_l     VARCHAR2(50);
      p_receipt_method_h     VARCHAR2(50);
      p_customer_name_l      VARCHAR2(50);
      p_customer_name_h      VARCHAR2(50);
      p_customer_no_l        VARCHAR2(50);
      p_customer_no_h        VARCHAR2(50);
      p_total_workers        NUMBER;

      l_no_receipts_processed     number;
      l_no_remit_lines_processed  number;
      l_no_remit_lines_autoapply  number;
      l_hit_ratio                 number;
      l_no_remit_lines_suggested  number;
      l_org_name                  VARCHAR2(50);

      function BeforeReport return boolean  ;
      function GetMessage (token VARCHAR2) return VARCHAR2;

END AR_ARATAPPM_PKG;

/
