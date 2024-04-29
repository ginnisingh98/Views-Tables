--------------------------------------------------------
--  DDL for Package Body AR_GTA_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_GTA_REPORTS_PKG" AS
--$Header: ARGRREPB.pls 120.0.12010000.3 2010/01/19 08:47:28 choli noship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     ARRREPB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|      This package is used to generate Golden Tax Adaptor reports.     |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      FUNCTION  Get_Ar_Trx                                             |
--|      FUNCTION  Get_Gt_Trxs                                            |
--|      PROCEDURE Generate_Mapping_Rep                                   |
--|      PROCEDURE Compare_Header                                         |
--|      PROCEDURE Compare_Lines                                          |
--|      PROCEDURE Get_Unmatched_Lines                                    |
--|      PROCEDURE Generate_Discrepancy_Xml                               |
--|      PROCEDURE Generate_Discrepancy_Rep                               |
--|      PROCEDURE Generate_Consol_Mapping_Rep                            |
--|      PROCEDURE Get_Consolidation_Trx                                  |
--|      PROCEDURE Get_Consolidated_Trxs                                  |
--|                                                                       |
--| HISTORY                                                               |
--|     05/08/05          Qiang Li         Created                        |
--|     05/17/05          Donghai Wang     Add procedures:                |
--|                                            Compare_Header             |
--|                                            Compare_Lines              |
--|                                            Get_Unmatched_Lines        |
--|                                            Generate_Discrepancy_Xml   |
--|                                            Generate_Discrepancy_Rep   |
--|     09/27/05           Qiang Li         Add function:                 |
--|                                            Get_Gt_Tax_Reg_Count       |
--|     25/11/05          Donghai Wang    modify procedure Compare_Header |
--|                                       ,Compare_Lines,                 |
--|                                       ,Get_Unmatched_Lines  and       |
--|                                       Generate_Discrepancy_Xml        |
--|                                       according to ebtax functionality|
--|   30/11/05           Donghai Wang    Update procedure Compare_Header  |
--|   01/12/05           Qiang Li        Update Generate_Mapping_Rep      |
--|   05/12/05           Qiang Li        Update Generate_Mapping_Rep      |
--|                                      Update Get_Gt_Trx                |
--|                                      Update Get_Ar_Trx                |
--|                                      Rename Get_Gt_Tax_Reg_Count to   |
--|                                      Get_Gt_Count                     |
--|  07/02/06            Qiang Li        Update FUNCTION Get_Ar_Trx       |
--|  06/03/06            Donghai Wang    Update Compare_Header,           |
--|                                      Compare_Lines,Get_Unmatched_lines|
--|                                      Generate_Discrepancy_Xml,        |
--|                                      Generate_Discrepancy_Rep for     |
--|                                      Adding fnd log                   |
--|  06/18/07           Donghai Wang    Update the procedure compare_lines|
--|                                      to fix bug 6132187               |
--|  07/05/07           Allen Yang      Update procedure compare_header   |
--|                                      to fix bug 6147067               |
--|  01/02/08           Subba           Updated procedure compare_header  |
--|                                     for R12.1
--| 13-May-2009   Yao Zhang             Fix bug#5604079 FOR FOREIGN CURR. |
--|                                     TRXN, DISCREPANCY SHOWN DUE TO CURR|.
--|                                     ROUNDING ISSU                     |
--|  25-Jul-2009        Allen Yang      Add functions and procedure:      |
--|                                         Generate_Consol_Mapping_Rep   |
--|                                         Get_Consolidation_Trx         |
--|                                         Get_Consolidated_Trxs         |
--|                                     for bug 8605196: ENHANCEMENT FOR  |
--|                                     GOLDEN TAX ADAPTER R12.1.2        |
--| 10-Aug-2009     Yao Zhang       Modified for bug# 8765631 R12.1.2     |
--| 14-July-2009    Yao Zhang       Fix bug#	8766075 GTA INVOICE MAPPING REPORT ERROR|
--| 19-Aug-2009     Yao Zhang  modified for bug#8809860 'Continue' can not be used in pl/sql package
--| 02-Sep-2009     Allen Yang      modified for bug 8848696
--| 23-Sep-2009     Yao Zhang fix bug#8289585 TST1211.ST:THE GOLDEN TAX DISCREPANCY|
--| 24-Sep-2009     Allen Yang          Modified function Get_Ar_Trx to   |
--|                                     fix bug 8920326                   |
--+======================================================================*/

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Gt_Count                        Public
--
--  DESCRIPTION:
--
--    This function get GT trxs count in a given
--    AR transaction
--  PARAMETERS:
--      In:  p_ar_trx_header_id        AR transaction header id
--           p_fp_tax_reg_num          first party tax registration number
--           P_Gt_Inv_Date_From        Golden Tax Invoice Date from
--           P_Gt_Inv_Date_To          Golden Tax Invoice Date to
--           P_Gt_Inv_Num_From         Golden Tax Invoice Number from
--           P_Gt_Inv_Num_To	         Golden Tax Invoice Number to
--     Out:
--
--  Return: VARCHAR2
--
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           27-Sep-05   	Qiang Li        Created.
--           05-Dec-05    Qiang Li        Rename to get_gt_count
--                                        Add four new parameters
--
--===========================================================================
FUNCTION Get_Gt_Count
( p_ar_trx_header_id IN NUMBER
, p_fp_tax_reg_num   IN VARCHAR2
, P_Gt_Inv_Date_From IN DATE
, P_Gt_Inv_Date_To   IN DATE
, P_Gt_Inv_Num_From  IN VARCHAR2
, P_Gt_Inv_Num_To	   IN VARCHAR2
)
RETURN VARCHAR2
IS
l_procedure_name    VARCHAR2(40):='Get_Gt_Count';
l_dbg_level         NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_proc_level        NUMBER:=FND_LOG.LEVEL_PROCEDURE;

l_count  NUMBER:=0;
BEGIN
  --logging for debug
  IF (l_proc_level>=l_dbg_level)
  THEN
    FND_LOG.string( l_proc_level
                  , G_MODULE_PREFIX||l_procedure_name||'.begin'
                  , 'enter function'
                  );
  END IF;

  SELECT
    COUNT(*)
  INTO
    l_count
  FROM
    AR_Gta_Trx_Headers_All Gt
  WHERE Gt.Ra_Trx_Id = p_ar_trx_header_id
    AND Source='GT'
    AND Status='COMPLETED'
    AND (Gt_Invoice_Number NOT BETWEEN p_Gt_Inv_Num_From
                                  AND p_Gt_Inv_Num_To
    OR Gt_Invoice_Date NOT BETWEEN p_Gt_Inv_Date_From
                                AND p_Gt_Inv_Date_To
    OR Fp_Tax_Registration_Number <> NVL(p_fp_tax_reg_num
                                        ,Fp_Tax_Registration_Number)
                                        );

  --logging for debug
  IF (l_proc_level>=l_dbg_level)
  THEN
    FND_LOG.string( l_proc_level
                  , G_MODULE_PREFIX||l_procedure_name||'.end'
                  , 'end function'
                  );
  END IF;

  IF (l_count>0)
  THEN
    RETURN 'YES';
  ELSE
    RETURN 'NO';
  END IF;


END Get_Gt_Count;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Ar_Trx                        Public
--
--  DESCRIPTION:
--
--    This function get xml data of AR transaction.
--
--  PARAMETERS:
--      In:  p_org_id                  Operating unit id
--           p_ar_trx_header_id        AR transaction header id
--           p_fp_tax_reg_num          first party tax registration number
--           P_Gt_Inv_Date_From        Golden Tax Invoice Date from
--           P_Gt_Inv_Date_To          Golden Tax Invoice Date to
--           P_Gt_Inv_Num_From         Golden Tax Invoice Number from
--           P_Gt_Inv_Num_To	         Golden Tax Invoice Number to
--     Out:
--
--  Return: XMLTYPE
--
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           05/08/05   	Qiang Li        Created.
--           09/27/05     Qiang Li        Add new parameter p_fp_tax_reg_num
--           05-Dec-2005  Qiang Li        add four new parameters
--           07-Feb-2006  Qiang Li        Change data type of p_fp_tax_reg_num
--                                        to Varchar2
--           24-Sep-2009  Allen Yang      modified to fix bug 8920326.
--===========================================================================
FUNCTION Get_Ar_Trx
( p_ar_trx_header_id IN NUMBER
, p_org_id           IN NUMBER
, p_fp_tax_reg_num   IN VARCHAR2
, P_Gt_Inv_Date_From IN DATE
, P_Gt_Inv_Date_To   IN DATE
, P_Gt_Inv_Num_From  IN VARCHAR2
, P_Gt_Inv_Num_To	   IN VARCHAR2
)
RETURN XMLTYPE
IS
l_procedure_name    VARCHAR2(40):='Get_Ar_Trx';
l_dbg_level         NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_proc_level        NUMBER:=FND_LOG.LEVEL_PROCEDURE;

l_ret_xmlelement Xmltype;
BEGIN
    --logging for debug
    IF (l_proc_level>=l_dbg_level)
    THEN
      FND_LOG.string( l_proc_level
                    , G_MODULE_PREFIX||l_procedure_name||'.begin'
                    , 'enter function'
                    );
    END IF;
    IF AR_Gta_Trx_Util.Check_Taxcount_Of_Artrx(P_Org_Id, p_ar_trx_header_id)
    THEN

      SELECT Xmlforest(
             ract.Trx_Number                                   AS "ARInvoiceNo"
            ,Get_Gt_Count
            ( p_ar_trx_header_id
            , p_fp_tax_reg_num
            , P_Gt_Inv_Date_From
            , P_Gt_Inv_Date_To
            , P_Gt_Inv_Num_From
            , P_Gt_Inv_Num_To
            )                                                   AS "Split"
            --yao zhang modified for bug8766075
            -- ,bat.name                                         AS "ARSource"
             ,bas.name                                           AS "ARSource"
             -- modified by Allen Yang 24-Sep-2009 for bug 8920326
             -----------------------------------------------------------------
             ,al.meaning                                        AS "ARClass"
             --,CTT.TYPE                                           AS "ARClass"
             ------------------------------------------------------------------
            ,ar_gta_trx_util.To_Xsd_Date_String(ract.Trx_Date) AS "ARDate"
            ,RAC_BILL_PARTY.PARTY_NAME                          AS "ARCustomer"
            ,AR_Gta_Trx_Util.Get_Arinvoice_Amount
             ( P_Org_Id
             , ract.Customer_Trx_Id
             )                                                  AS "ARAmount"
            ,AR_Gta_Trx_Util.Get_Arinvoice_Tax_Amount
             ( P_Org_Id
             , ract.Customer_Trx_Id
             )                                                  AS "ARTaxAmount"
            ,AR_Gta_Trx_Util.Get_Arinvoice_Amount
             ( P_Org_Id
             , ract.Customer_Trx_Id
             )
             +AR_Gta_Trx_Util.Get_Arinvoice_Tax_Amount
             ( P_Org_Id
             , ract.Customer_Trx_Id
             )                                                  AS "ARTotalAmount"
            )
      INTO
        L_Ret_Xmlelement
      FROM
        Ra_Customer_Trx_all ract
       --yao zhang modified for bug8766075
       -- , ra_batches_all bat
      ,RA_BATCH_SOURCES_ALL bas
      , Ra_Cust_Trx_Types_all ctt
      , Hz_Cust_Accounts RAC_BILL
      , Hz_Parties RAC_BILL_PARTY
      -- added by Allen Yang 24-Sep-2009 for bug 8920326
      ----------------------------------------------------
      , AR_LOOKUPS al
      ----------------------------------------------------

      WHERE Customer_Trx_Id           = P_Ar_Trx_Header_Id
        AND ract.CUST_TRX_TYPE_ID     = ctt.CUST_TRX_TYPE_ID
        AND ract.org_id               = ctt.org_id
       --yao zhang modified for bug8766075
       --AND ract.batch_id             = bat.batch_id(+)
        AND ract.batch_source_id      = bas.BATCH_SOURCE_ID(+)
        AND ract.org_id               =bas.org_id
        AND ract.bill_to_customer_id  = RAC_BILL.CUST_ACCOUNT_ID
        AND RAC_BILL.party_id         = RAC_BILL_PARTY.Party_Id
        -- added by Allen Yang 24-Sep-2009 for bug 8920326
        ----------------------------------------------------------
        AND ctt.TYPE = al.LOOKUP_CODE
        AND al.LOOKUP_TYPE = 'INV/CM'
        ----------------------------------------------------------
        ;
    ELSE
      SELECT Xmlforest(
             ract.Trx_Number                             AS "ARInvoiceNo"
             ,Get_Gt_Count
             ( p_ar_trx_header_id
             , p_fp_tax_reg_num
             , P_Gt_Inv_Date_From
             , P_Gt_Inv_Date_To
             , P_Gt_Inv_Num_From
             , P_Gt_Inv_Num_To
             )                                                   AS "Split"
            --yao zhang modified for bug8766075
            -- ,bat.name                                         AS "ARSource"
             ,bas.name                                           AS "ARSource"
             -- modified by Allen Yang 24-Sep-2009 for bug 8920326
             -----------------------------------------------------------------
             --,CTT.TYPE                                           AS "ARClass"
             ,al.meaning                                          AS "ARClass"
             -----------------------------------------------------------------
             ,ar_gta_trx_util.To_Xsd_Date_String(ract.Trx_Date) AS "ARDate"
             ,RAC_BILL_PARTY.PARTY_NAME                          AS "ARCustomer"
             ,''                                                 AS "ARAmount"
             ,''                                                 AS "ARTaxAmount"
             ,''                                                 AS "ARTotalAmount"
             )
      INTO
        L_Ret_Xmlelement
      FROM
        Ra_Customer_Trx_all ract
       --yao zhang modified for bug8766075
       -- , ra_batches_all bat
      ,RA_BATCH_SOURCES_ALL bas
      , Ra_Cust_Trx_Types_all ctt
      , Hz_Cust_Accounts RAC_BILL
      , Hz_Parties RAC_BILL_PARTY
      -- added by Allen Yang 24-Sep-2009 for bug 8920326
      -----------------------------------------------------
      , AR_LOOKUPS al
      -----------------------------------------------------

      WHERE Customer_Trx_Id           = P_Ar_Trx_Header_Id
        AND ract.CUST_TRX_TYPE_ID     = ctt.CUST_TRX_TYPE_ID
        AND ract.org_id               = ctt.org_id
       --yao zhang modified for bug8766075
       --AND ract.batch_id             = bat.batch_id(+)
        AND ract.batch_source_id      = bas.BATCH_SOURCE_ID(+)
        AND ract.org_id               =bas.org_id
        AND ract.bill_to_customer_id  = RAC_BILL.CUST_ACCOUNT_ID
        AND RAC_BILL.party_id         = RAC_BILL_PARTY.Party_Id
        -- added by Allen Yang 24-Sep-2009 for bug 8920326
        -------------------------------------------------------
        AND al.LOOKUP_TYPE = 'INV/CM'
        AND ctt.TYPE = al.LOOKUP_CODE
        -------------------------------------------------------
        ;


    END IF;

    --logging for debug
    IF (l_proc_level>=l_dbg_level)
    THEN
      FND_LOG.string( l_proc_level
                    , G_MODULE_PREFIX||l_procedure_name||'.end'
                    , 'end function'
                    );
    END IF;

    RETURN L_Ret_Xmlelement;
  END Get_Ar_Trx;



--==========================================================================
--  FUNCTION NAME:
--
--    Get_Gt_Trxs                        Public
--
--  DESCRIPTION:
--
--    This function get XML data of Golden Tax transactions
--
--  PARAMETERS:
--      In:  p_org_id                  Operating unit id
--           p_ar_trx_header_id        AR transaction header id
--           p_Tax_Registration_Number First party tax registration number
--           P_Gt_Inv_Date_From        Golden Tax Invoice Date from
--           P_Gt_Inv_Date_To          Golden Tax Invoice Date to
--           P_Gt_Inv_Num_From         Golden Tax Invoice Number from
--           P_Gt_Inv_Num_To	         Golden Tax Invoice Number to
--
--     Out:
--
--  Return: XMLTYPE
--
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           05/08/05   	Qiang Li        Created.
--           05/12/05     Qiang Li        add five new parameters
--
--===========================================================================
  FUNCTION Get_Gt_Trxs
  ( P_Ar_Trx_Header_Id        IN NUMBER
  , P_Org_Id                  IN NUMBER
  , p_Tax_Registration_Number IN VARCHAR2
  , P_Gt_Inv_Date_From        IN DATE
  , P_Gt_Inv_Date_To          IN DATE
  , P_Gt_Inv_Num_From         IN VARCHAR2
  , P_Gt_Inv_Num_To	          IN VARCHAR2
  )
  RETURN Xmltype
  IS
  l_procedure_name    VARCHAR2(40):='Get_Gt_Trxs';
  l_dbg_level         NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
	l_proc_level        NUMBER:=FND_LOG.LEVEL_PROCEDURE;

  l_Ret_Xmlelement Xmltype;
  l_count          NUMBER;
  BEGIN
    --logging for debug
    IF (l_proc_level>=l_dbg_level)
    THEN
      FND_LOG.string( l_proc_level
                    , G_MODULE_PREFIX||l_procedure_name||'.begin'
                    , 'enter function'
                    );
    END IF;

    -- get GT invoices count for a given ar transaction
    SELECT
      COUNT(*)
    INTO
      l_count
    FROM
      ar_gta_trx_headers_all
    WHERE Ra_Trx_Id=P_Ar_Trx_Header_Id
      AND Source='GT'
      AND Status='COMPLETED'
      AND Gt_Invoice_Number BETWEEN p_Gt_Inv_Num_From
                                   AND p_Gt_Inv_Num_To
      AND Gt_Invoice_Date BETWEEN p_Gt_Inv_Date_From
                                 AND p_Gt_Inv_Date_To
      AND Fp_Tax_Registration_Number=NVL(p_Tax_Registration_Number
                                        ,Fp_Tax_Registration_Number
                                        );

    -- get GT invoices XML data for a given ar transaction
    SELECT Xmlelement("GTInvoices",
                Xmlconcat(Xmlelement("Count",l_count)
              , Xmlagg(Xmlelement("GTInvoice",Xmlforest
              ( Gt_Invoice_Number                                    AS "InvoiceNo"
              , ar_gta_trx_util.To_Xsd_Date_String(Gt_Invoice_Date) AS "Date"
              , Bill_To_Customer_Name                                AS "Customer"
              , Gt_Invoice_Net_Amount                                AS "Amount"
              , Gt_Invoice_Tax_Amount                                AS "TaxAmount"
              , Gt_Invoice_Net_Amount + Gt_Invoice_Tax_Amount        AS "TotalAmount"
              )
              ))))
    INTO
      l_Ret_Xmlelement
    FROM
      AR_Gta_Trx_Headers_all
    WHERE Ra_Trx_Id=P_Ar_Trx_Header_Id
      AND Source='GT'
      AND Status='COMPLETED'
      AND Gt_Invoice_Number BETWEEN p_Gt_Inv_Num_From
                                   AND p_Gt_Inv_Num_To
      AND Gt_Invoice_Date BETWEEN p_Gt_Inv_Date_From
                                 AND p_Gt_Inv_Date_To
      AND Fp_Tax_Registration_Number=NVL(p_Tax_Registration_Number
                                        ,Fp_Tax_Registration_Number
                                        );

    --logging for debug
    IF (l_proc_level>=l_dbg_level)
    THEN
      FND_LOG.string( l_proc_level
                    , G_MODULE_PREFIX||l_procedure_name||'.end'
                    , 'end function'
                    );
    END IF;

    RETURN l_Ret_Xmlelement;
  END Get_Gt_Trxs;



--==========================================================================
--  PROCEDURE NAME:
--
--    Generate_Mapping_Rep                Public
--
--  DESCRIPTION:
--
--    This procedure generate mapping report data
--
--  PARAMETERS:
--      In:   p_fp_tax_reg_num         First Party Tax Registration Number
--            p_org_id                 Operating unit id
--            p_trx_source             Transaction source,GT or AR
--            p_customer_id            Customer id
--            p_gt_inv_num_from        GT invoice number low range
--            p_gt_inv_num_to          GT invoice number high range
--            p_gt_inv_date_from       GT invoice date low range
--            p_gt_inv_date_to         GT invoice date high range
--            p_ar_inv_num_from        AR invoice number low range
--            p_ar_inv_num_to          AR invoice number high range
--            p_ar_inv_date_from       AR invoice date low range
--            p_ar_inv_date_to         AR invoice date high range
--     Out:
--
--
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           05/08/05    Qiang Li   Created.
--           27-Sep-2005 Qiang Li   Add a new parameter fp_tax_reg_number.
--           05-Dec-2005 Qiang Li   Update the logic to just display the
--                                  coincidental GT invoice
--===========================================================================
  Procedure Generate_Mapping_Rep
  ( P_Org_Id	          IN	NUMBER
  , p_fp_tax_reg_num    IN  VARCHAR2
  , P_Trx_Source	      IN	NUMBER
  , P_Customer_Id       IN	NUMBER
  , P_Gt_Inv_Num_From   IN	VARCHAR2
  , P_Gt_Inv_Num_To	    IN	VARCHAR2
  , P_Gt_Inv_Date_From  IN	DATE
  , P_Gt_Inv_Date_To	  IN	DATE
  , P_Ar_Inv_Num_From 	IN	VARCHAR2
  , P_Ar_Inv_Num_To	    IN	VARCHAR2
  , P_Ar_Inv_Date_From	IN	DATE
  , P_Ar_Inv_Date_To	  IN	DATE
  )
  IS
  l_procedure_name    VARCHAR2(40):='Generate_Mapping_Rep';
  l_no_data_message   VARCHAR2(500);
  l_Ar_Trx_Id         AR_Gta_Trx_Headers.Ra_Trx_Id%TYPE;
  l_Parameter         Xmltype;
  l_Summary           Xmltype;
  L_gt_currency       Xmltype;
  l_Ar_Trx            Xmltype;
  l_Gt_Invoices       Xmltype;
  l_ar_trxs           xmltype;
  l_Report            Xmltype;
  l_Ar_Rows           NUMBER;
  I                   NUMBER;
  l_Gt_Rows           NUMBER;
  l_no_data_flag      VARCHAR2(1):='N';

  l_Gt_Inv_Num_From   VARCHAR2(30);
  l_Gt_Inv_Num_To     VARCHAR2(30);
  l_Gt_Inv_Date_From  DATE;
  l_Gt_Inv_Date_To    DATE;
  l_Ar_Inv_Num_From   VARCHAR2(20);
  l_Ar_Inv_Num_To     VARCHAR2(20);
  l_Ar_Inv_Date_From  DATE;
  l_Ar_Inv_Date_To    DATE;
  l_gt_cur            VARCHAR2(100);

  l_dbg_level         NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
	l_proc_level        NUMBER:=FND_LOG.LEVEL_PROCEDURE;

  CURSOR C_cur IS
  SELECT
    sysp.gt_currency_code
  FROM
    ar_gta_system_parameters_all sysp
  WHERE sysp.org_id = P_Org_Id;

  CURSOR C_Trx_Ids IS
  SELECT
    DISTINCT Gt.Ra_Trx_Id
  FROM
    AR_Gta_Trx_Headers_All Gt
   ,Ra_Customer_Trx_All     Ar
  WHERE Gt.Ra_Trx_Id=Ar.Customer_Trx_Id
    AND Gt.Org_Id=P_Org_Id
    AND Gt.Fp_Tax_Registration_Number=NVL(p_fp_tax_reg_num
                                         ,Gt.Fp_Tax_Registration_Number
                                         )
    AND Ar.Batch_Source_Id=NVL(P_Trx_Source,Ar.Batch_Source_Id)
    AND Ar.Bill_To_Customer_Id =  NVL(P_Customer_Id,Ar.Bill_To_Customer_Id)
    AND Gt.Source='GT'
    AND Gt.Status='COMPLETED'
    AND Gt.Gt_Invoice_Number BETWEEN l_Gt_Inv_Num_From
                                 AND l_Gt_Inv_Num_To
    AND Gt.Gt_Invoice_Date BETWEEN l_Gt_Inv_Date_From
                               AND l_Gt_Inv_Date_To
    AND Ar.Trx_Number BETWEEN l_Ar_Inv_Num_From
                          AND l_Ar_Inv_Num_To
    AND Ar.Trx_Date BETWEEN l_Ar_Inv_Date_From
                        AND l_Ar_Inv_Date_To;


  BEGIN
    --logging for debug
    IF (l_proc_level>=l_dbg_level)
    THEN
      FND_LOG.string( l_proc_level
                    , G_MODULE_PREFIX||l_procedure_name||'.begin'
                    , 'enter procedure'
                    );
    END IF;

    l_Gt_Inv_Num_From:=Nvl(P_Gt_Inv_Num_From,'  ');
    l_Gt_Inv_Num_To:=Nvl(P_Gt_Inv_Num_To,'zzz');
    l_Gt_Inv_Date_From:=Nvl(P_Gt_Inv_Date_From,To_Date('1900-01-01'
                                                      ,'Rrrr-Mm-Dd'
                                                      )
                           );
    l_Gt_Inv_Date_To:=Nvl(P_Gt_Inv_Date_To,To_Date('2100-12-31'
                                                  ,'Rrrr-Mm-Dd')
                                                  );
    l_Ar_Inv_Num_From:=Nvl(P_Ar_Inv_Num_From,' ');
    l_Ar_Inv_Num_To:=Nvl(P_Ar_Inv_Num_To,'zzz');
    l_Ar_Inv_Date_From:=Nvl(P_Ar_Inv_Date_From,To_Date('1900-01-01'
                                                      ,'Rrrr-Mm-Dd'
                                                      )
                           );
    l_Ar_Inv_Date_To:=Nvl(P_Ar_Inv_Date_To,To_Date('2100-12-31'
                                                  ,'Rrrr-Mm-Dd'
                                                  )
                         );

    --Get Gt Invoice Rows
    SELECT
      COUNT(*)
    INTO
      l_Gt_Rows
    FROM
      AR_Gta_Trx_Headers Gt
     ,Ra_Customer_Trx     Ar
    WHERE Gt.Ra_Trx_Id=Ar.Customer_Trx_Id
      AND Gt.Org_Id=P_Org_Id
      AND Gt.Fp_Tax_Registration_Number=NVL(p_fp_tax_reg_num
                                           ,Gt.Fp_Tax_Registration_Number
                                           )
      AND Ar.Batch_Source_Id=NVL(P_Trx_Source,Ar.Batch_Source_Id)
      AND Ar.Bill_To_Customer_Id = NVL(P_Customer_Id
                                      ,Ar.Bill_To_Customer_Id
                                      )
      AND Gt.Source='GT'
      AND Gt.Status='COMPLETED'
      AND Gt.Gt_Invoice_Number BETWEEN l_Gt_Inv_Num_From
                                   AND l_Gt_Inv_Num_To
      AND Gt.Gt_Invoice_Date BETWEEN l_Gt_Inv_Date_From
                                 AND l_Gt_Inv_Date_To
      AND Ar.Trx_Number BETWEEN l_Ar_Inv_Num_From
                            AND l_Ar_Inv_Num_To
      AND Ar.Trx_Date BETWEEN l_Ar_Inv_Date_From
                          AND l_Ar_Inv_Date_To;

    OPEN C_Trx_Ids;
    FETCH C_Trx_Ids INTO L_Ar_Trx_Id;
    I:=0;

    WHILE C_Trx_Ids%FOUND LOOP
      I:=I+1;

      L_Ar_Trx:=Get_Ar_Trx( P_Ar_Trx_Header_Id => L_Ar_Trx_Id
                          , P_Org_Id           => P_Org_Id
                          , p_fp_tax_reg_num   => p_fp_tax_reg_num
                          , P_Gt_Inv_Date_From => l_Gt_Inv_Date_From
                          , P_Gt_Inv_Date_To   => l_Gt_Inv_Date_To
                          , P_Gt_Inv_Num_From  => l_Gt_Inv_Num_From
                          , P_Gt_Inv_Num_To	   => l_Gt_Inv_Num_To
                          );
      L_Gt_Invoices:=Get_Gt_Trxs( P_Ar_Trx_Header_Id        => L_Ar_Trx_Id
                                , P_Org_Id                  => p_Org_Id
                                , p_Tax_Registration_Number => p_fp_tax_reg_num
                                , P_Gt_Inv_Date_From        => l_Gt_Inv_Date_From
                                , P_Gt_Inv_Date_To          => l_Gt_Inv_Date_To
                                , P_Gt_Inv_Num_From         => l_Gt_Inv_Num_From
                                , P_Gt_Inv_Num_To	          => l_Gt_Inv_Num_To
                                );

      SELECT
        Xmlconcat(l_ar_trxs,Xmlelement( "Invoice"
                                      , Xmlconcat(L_Ar_Trx,L_Gt_Invoices)))
      INTO
        l_ar_trxs
      FROM
        dual;

      FETCH C_Trx_Ids INTO L_Ar_Trx_Id;
    END LOOP;

    CLOSE C_Trx_Ids;

    --Get Ar Invoice Rows
    L_Ar_Rows:=I;

    IF (L_Ar_Rows=0) AND
       (l_Gt_Rows=0)
    THEN
      l_no_data_flag:='Y';
    END IF;

    --Generate Parameter Section
    SELECT
      Xmlelement("Parameters",Xmlforest
      ( ar_gta_trx_util.Get_OperatingUnit(P_Org_Id)      AS "OperationUnit"
      , p_fp_tax_reg_num                                  AS "TaxRegistrationNumber"
      , ar_gta_trx_util.Get_AR_Batch_Source_Name
      ( P_Org_Id
      , P_Trx_Source)                                     AS "TransactionSource"
      , ar_gta_trx_util.Get_Customer_Name(P_Customer_Id) AS "ARCustomerName"
      , P_Gt_Inv_Num_From                                 AS "GTInvoiceNumFrom"
      , P_Gt_Inv_Num_To                                   AS "GTInvoiceNumTo"
      , ar_gta_trx_util.To_Xsd_Date_String(P_Gt_Inv_Date_From)  AS "GTDateFrom"
      , ar_gta_trx_util.To_Xsd_Date_String(P_Gt_Inv_Date_To)    AS "GTDateTo"
      , P_Ar_Inv_Num_From                                 AS "ARTrxNumberFrom"
      , P_Ar_Inv_Num_To                                   AS "ARTrxNumberTo"
      , ar_gta_trx_util.To_Xsd_Date_String(P_Ar_Inv_Date_From)  AS "ARTrxDateFrom"
      , ar_gta_trx_util.To_Xsd_Date_String(P_Ar_Inv_Date_TO)    AS "ARTrxDateTo"))
    INTO
      l_Parameter
    FROM DUAL;

    --Generate Summary Section
    SELECT
      Xmlelement("Summary", Xmlforest
                          ( L_Ar_Rows AS "NumOfARTrxs"
                          , L_Gt_Rows AS "NumOfGTInvoices"
                          )
                )
    INTO
      L_Summary
    FROM
      DUAL;

    --Generate Golden Tax Currency Section
    OPEN C_cur;
    FETCH C_cur INTO l_gt_cur;
    CLOSE C_cur;

    SELECT
      Xmlelement("RepCurr", l_gt_cur)
    INTO
      L_gt_currency
    FROM
      DUAL;

    --Generate Reports Xml Data
    IF l_no_data_flag='Y'
    THEN
      FND_MESSAGE.SET_NAME('AR','AR_GTA_NO_DATA_FOUND');
      l_no_data_message := FND_MESSAGE.GET();

      SELECT Xmlelement( "MappingReport", Xmlconcat
             ( Xmlelement("ReportFailed",'N')
             , Xmlelement("FailedWithParameters",'Y')
             , Xmlelement("FailedMsgWithParameters",l_no_data_message)
             , Xmlelement("RepDate",ar_gta_trx_util.To_Xsd_Date_String(SYSDATE))
             , L_Parameter
             ))
      INTO
        L_Report
      FROM
        DUAL;
    ELSE

      SELECT Xmlelement( "MappingReport", Xmlconcat
             ( Xmlelement("ReportFailed",'N')
             , Xmlelement("FailedWithParameters",'N')
             , Xmlelement("RepDate",ar_gta_trx_util.To_Xsd_Date_String(SYSDATE))
             , L_Parameter
             , L_Summary
             , L_gt_currency
             , xmlelement("Invoices",l_ar_trxs)
             ))
      INTO
        L_Report
      FROM
        DUAL;
    END IF;

    ar_gta_trx_util.output_conc(L_Report.Getclobval());

    --logging for debug
    IF (l_proc_level>=l_dbg_level)
    THEN
      FND_LOG.string( l_proc_level
                    , G_MODULE_PREFIX||l_procedure_name||'.end'
                    , 'end procedure'
                    );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF(Fnd_Log.Level_Unexpected >= Fnd_Log.G_Current_Runtime_Level)
      THEN
        Fnd_Log.String( Fnd_Log.Level_Unexpected
                      , G_MODULE_PREFIX || l_procedure_name || '.Other_Exception '
                      , Sqlcode||Sqlerrm);
      END IF;

  END Generate_Mapping_Rep;

--==========================================================================
--  PROCEDURE NAME:
--
--      Compare_Header                Public
--
--  DESCRIPTION:
--
--   This Procedure Compare Ar, Gta, Gt Headers AND Input Difference Record
--   Compared Columns Include: "Amount", "Tax Amount", "Customer Name",
--  "Bank Name Account" and "Tax Payer Id"
--
--  PARAMETERS:
--      In:   p_org_id                 Operating unit id
--            p_ar_header_id           AR Transaction id
--
--     Out:   x_has_difference
--
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           05/17/05   	Donghai  Wang        Created.
--           11/25/05     Donghai  Wang        modify code to follow ebtax
--                                             requirement
--          30/12/05      Donghai  Wang        Update cursor c_ar_header to
--                                             modify table names
--           03/04/05     Donghai  Wang        Add FND Log
--           07/05/07       Allen  Yang        Modify code to fix bug 6147067
--           01/02/08       Subba Updated code for R12.1
--           05-Aug-2009  Yao Zhang   Fix bug#8765631 Modified.
--===========================================================================
PROCEDURE Compare_Header
( p_org_id               IN         NUMBER
, p_ar_header_id	 IN	    NUMBER
, x_has_difference	 OUT NOCOPY BOOLEAN
)
IS
l_ar_header_id               NUMBER
                             :=p_ar_header_id;

l_org_id                     hr_all_organization_units.organization_id%TYPE
                             :=p_org_id;

l_ar_amount                  NUMBER;
l_ar_amount_disp             VARCHAR2(50);
l_ar_taxamount               NUMBER;
l_ar_taxamount_disp          VARCHAR2(50);
l_ar_customer_id             ra_customer_trx_all.bill_to_customer_id%TYPE;
l_ar_customer_name           hz_parties.party_name%TYPE;
l_ar_taxpayer_id             hz_parties.jgzz_fiscal_code%TYPE;
l_ar_customer_bank_account   VARCHAR2(360);
l_ar_customer_address        VARCHAR2(4000);
l_ar_customer_address_phone  VARCHAR2(4000);
l_ar_customer_phone          hz_contact_points.phone_number%TYPE;
l_gta_amount                 NUMBER;
l_gta_taxamount              NUMBER;
l_gta_customer_name          ar_gta_trx_headers_all.bill_to_customer_name%TYPE;
l_gta_taxpayer_id            ar_gta_trx_headers_all.tp_tax_registration_number%TYPE;
l_gta_customer_bank_account  ar_gta_trx_headers_all.bank_account_name_number%TYPE;
l_gta_customer_address_phone ar_gta_trx_headers_all.customer_address_phone%TYPE;
l_gta_trx_number             ar_gta_trx_headers_all.gta_trx_number%TYPE;
l_gta_amount_sum             NUMBER;
l_gta_amount_sum_disp        VARCHAR2(50);
l_gta_taxamount_sum          NUMBER;
l_gta_taxamount_sum_disp     VARCHAR2(50);
l_gta_trx_number_con         VARCHAR2(4000);
l_gt_amount                  NUMBER;
l_gt_taxamount               NUMBER;
l_gt_customer_name           ar_gta_trx_headers_all.bill_to_customer_name%TYPE;
l_gt_taxpayer_id             ar_gta_trx_headers_all.tp_tax_registration_number%TYPE;
l_gt_customer_bank_account   ar_gta_trx_headers_all.bank_account_name_number%TYPE;
l_gt_customer_address_phone  ar_gta_trx_headers_all.customer_address_phone%TYPE;
l_gt_amount_sum              NUMBER;
l_gt_amount_sum_disp         VARCHAR2(50);
l_gt_taxamount_sum           NUMBER;
l_gt_taxamount_sum_disp      VARCHAR2(50);
l_gt_invoice_number          ar_gta_trx_headers_all.gt_invoice_number%TYPE;
l_gt_invoice_number_con      VARCHAR2(4000);
l_gta_header_id              NUMBER;
l_ar_mask_bank               VARCHAR2(50);
l_amount_discrepancy         VARCHAR2(40);
l_taxamount_discrepancy      VARCHAR2(40);
l_has_difference             BOOLEAN;

l_amount_attr                fnd_lookup_values.meaning%TYPE;
l_taxamount_attr             fnd_lookup_values.meaning%TYPE;
l_cust_name_attr             fnd_lookup_values.meaning%TYPE;
l_bank_name_account_attr     fnd_lookup_values.meaning%TYPE;
l_address_phone_attr         fnd_lookup_values.meaning%TYPE;
l_taxpayer_id_attr           fnd_lookup_values.meaning%TYPE;

l_ar_customer_bank_account_m  VARCHAR2(360);
l_gta_customer_bank_account_m ar_gta_trx_headers_all.bank_account_name_number%TYPE;
l_gt_customer_bank_account_m  ar_gta_trx_headers_all.bank_account_name_number%TYPE;
l_ar_bank_name                ce_bank_branches_v.bank_name%TYPE;
l_ar_branch_name              ce_bank_branches_v.bank_branch_name%TYPE;
l_ar_bank_account_num         ce_bank_accounts.bank_account_num%TYPE;
l_ar_bank_account_name        ce_bank_accounts.bank_account_name%TYPE;

l_api_name                    VARCHAR2(50):='Compare_Header';
l_dbg_msg                     VARCHAR2(100);
l_error_msg                   VARCHAR2(4000);

l_gta_loop_count              NUMBER;

--Added by Allen to fix issue #1 & #2 in bug 6147067
l_gta_amount_loop_count       NUMBER;

--Added by Subba for R12.1

l_gta_invoice_type            VARCHAR2(1);
l_gta_invoice_type_name       VARCHAR2(80);
l_gt_invoice_type             VARCHAR2(1);
l_gt_invoice_type_name        VARCHAR2(80);

l_invoicetype_attr            fnd_lookup_values.meaning%TYPE;
l_gta_status                  VARCHAR2(15);--Yao Zhang add for bug#8765631
l_csldt_flag                  VARCHAR2(1);


CURSOR c_ar_header IS
SELECT
--commented by Donghai due to ebtax functionality
 /*AR_GTA_TRX_UTIL.Get_Arinvoice_Amount(rct.customer_trx_id
                                       ,rct.invoice_currency_code
                                       ,rct.trx_date
                                       ,l_org_id) amount
, AR_GTA_TRX_UTIL.Get_Arinvoice_Tax_Amount(rct.customer_trx_id
                                           ,rct.invoice_currency_code
                                           ,rct.trx_date
                                           ,l_org_id) tax_amount*/
  rct.bill_to_customer_id
--Yao Zhang modified for bug#8765631
,decode(RAC_BILL_PARTY.Known_As
                        ,null,RAC_BILL_PARTY.PARTY_NAME
                        ,RAC_BILL_PARTY.Known_As)  customer_name
--commented by Donghai due to ebtax functionality
--, rac_bill_party.jgzz_fiscal_code taxpayer_id
, DECODE(RAA_BILL.CUST_ACCT_SITE_ID,
                        NULL,
                        NULL,
                        decode(RAA_BILL_LOC.Address_Lines_Phonetic,
                               null,
                        ARH_ADDR_PKG.ARXTW_FORMAT_ADDRESS(RAA_BILL_LOC.ADDRESS_STYLE,
                                                          RAA_BILL_LOC.ADDRESS1,
                                                          RAA_BILL_LOC.ADDRESS2,
                                                          RAA_BILL_LOC.ADDRESS3,
                                                          RAA_BILL_LOC.ADDRESS4,
                                                          RAA_BILL_LOC.CITY,
                                                          RAA_BILL_LOC.COUNTY,
                                                          RAA_BILL_LOC.STATE,
                                                          RAA_BILL_LOC.PROVINCE,
                                                          RAA_BILL_LOC.POSTAL_CODE,
                                                          FT_BILL.TERRITORY_SHORT_NAME),
                                                          RAA_BILL_LOC.Address_Lines_Phonetic))  customer_address
FROM
  ra_customer_trx_all     rct
 ,hz_parties              rac_bill_party
 ,hz_cust_accounts        rac_bill
 --,ap_bank_accounts        apba
 --,ap_bank_branches        apb
 ,hz_cust_site_uses_all   su_bill
 ,hz_party_sites          raa_bill_ps
 ,hz_cust_acct_sites_all  raa_bill
 ,hz_locations            raa_bill_loc
 ,fnd_territories_vl      ft_bill
WHERE rct.customer_trx_id=l_ar_header_id
  AND rct.bill_to_customer_id=rac_bill.cust_account_id
  AND rac_bill.party_id=rac_bill_party.party_id
 -- AND rct.customer_bank_account_id=apba.bank_account_id(+)
 -- AND apba.bank_branch_id=apb.bank_branch_id(+)
  AND rct.bill_to_site_use_id=su_bill.site_use_id
  AND su_bill.cust_acct_site_id=raa_bill.cust_acct_site_id
  AND raa_bill.party_site_id=raa_bill_ps.party_site_id
  AND raa_bill_loc.location_id=raa_bill_ps.location_id
  AND raa_bill_loc.country=ft_bill.territory_code(+);

-- Commented by Allen to fix issue #2 in bug 6147067
CURSOR c_gta_headers IS
SELECT
  /*AR_GTA_TRX_UTIL.Get_Gtainvoice_Amount(gta.gta_trx_header_id)
  amount
, AR_GTA_TRX_UTIL.Get_Gtainvoice_Tax_Amount(gta.gta_trx_header_id)
  taxamount,
  */
  gta.bill_to_customer_name
  customer_name
, gta.tp_tax_registration_number
  tax_registration_number
, gta.bank_account_name_number
  customer_bank_account
, gta.customer_address_phone
  customer_address_phone
, gta.gta_trx_number
,gta.invoice_type invoice_type   --added by subba.
,lk.meaning invoice_type_name    --added by subba.
,gta.status--Yao Zhang add for bug#8765631
FROM
  ar_gta_trx_headers gta, fnd_lookup_values_vl lk   --added by subba.
WHERE gta.ra_trx_id=l_ar_header_id
  AND gta.source='AR'
  AND (gta.status='COMPLETED' OR gta.status='CONSOLIDATED')--Yao Zhang modified for bug#8765631
  AND gta.latest_version_flag='Y'
  AND gta.invoice_type = lk.lookup_code     --added by subba for R12.1
  AND lk.lookup_type='AR_GTA_INVOICE_TYPE';


CURSOR c_gt_headers IS
SELECT
  AR_GTA_TRX_UTIL.Get_Gtainvoice_Amount(gt.gta_trx_header_id)
  amount
, AR_GTA_TRX_UTIL.Get_Gtainvoice_Tax_Amount(gt.gta_trx_header_id)
  taxamount
, gt.bill_to_customer_name
  customer_name
, gt.tp_tax_registration_number
  tax_registration_number
, gt.bank_account_name_number
  customer_bank_account
, gt.customer_address_phone
  customer_address_phone
, gt.gt_invoice_number
, gt.invoice_type invoice_type
, lk.meaning invoice_type_name
FROM
  ar_gta_trx_headers gt,
  fnd_lookup_values_vl lk     --added by Subba for R12.1
WHERE gt.gta_trx_number=l_gta_trx_number
  AND gt.source='GT'
  AND gt.invoice_type = lk.lookup_code
  AND lk.lookup_type='AR_GTA_INVOICE_TYPE';


--This cursor is added by Allen to fix issue #2 in bug 6147067.
CURSOR c_gta_amounts IS
SELECT
  AR_GTA_TRX_UTIL.Get_Gtainvoice_Amount(gta.gta_trx_header_id)
  amount
, AR_GTA_TRX_UTIL.Get_Gtainvoice_Tax_Amount(gta.gta_trx_header_id)
  taxamount
, gta.gta_trx_number
FROM
  ar_gta_trx_headers gta
WHERE gta.ra_trx_id=l_ar_header_id
  AND gta.source='AR'
  AND gta.status<>'CANCELLED'
  AND gta.latest_version_flag='Y';


l_dbg_level         NUMBER         :=FND_LOG.G_Current_Runtime_Level;
l_proc_level        NUMBER         :=FND_LOG.Level_Procedure;

BEGIN

  --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.begin'
                  ,'Enter procedure'
                  );


    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'l_ar_header_id '||l_ar_header_id
                  );

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'l_org_id '||l_org_id
                  );



  END IF;  --( l_proc_level >= l_dbg_level)


  l_ar_mask_bank:=FND_PROFILE.Value('CE_MASK_INTERNAL_BANK_ACCT_NUM');

 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                  ,'l_ar_mask_bank '||l_ar_mask_bank
                  );
  END IF;  --( l_proc_level >= l_dbg_level)



  l_has_difference:=FALSE;

  -- To get meaning of header level attribute lookup code
  SELECT
    flv.meaning
  INTO
    l_amount_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='AMOUNT';

  SELECT
    flv.meaning
  INTO
    l_taxamount_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='VAT_TAX_AMOUNT';

  SELECT
    flv.meaning
  INTO
    l_cust_name_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='CUSTOMER_NAME';

  SELECT
    flv.meaning
  INTO
    l_bank_name_account_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='BANK_NAME_ACCOUNT';

  SELECT
    flv.meaning
  INTO
    l_address_phone_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='ADDRESS_PHONE_NUMBER';

  --added by Subba for R12.1

  SELECT
    flv.meaning
  INTO
    l_invoicetype_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='INVOICE_TYPE';


--commented by Donghai due to ebtax functionality
 /* SELECT
    flv.meaning
  INTO
    l_taxpayer_id_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='TAX_PAYER_ID';*/




  --Get AR Attribute Value
  OPEN  c_ar_header;

  --commented by Donghai due to ebtax functionality
  FETCH c_ar_header
   INTO --l_ar_amount
        --,l_ar_taxamount
        l_ar_customer_id
       ,l_ar_customer_name
     --   ,l_ar_taxpayer_id
       ,l_ar_customer_address
       ;

  CLOSE c_ar_header;

  --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                  ,'l_ar_customer_id '||l_ar_customer_id
                  );

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                  ,'l_ar_customer_name '||l_ar_customer_name
                  );

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                  ,'l_ar_customer_address '||l_ar_customer_address
                  );


  END IF;  --( l_proc_level >= l_dbg_level)



   --Get taxable amount and tax amount of AR transaction
   --First check if current AR transaction have AR lines with multiple VAT tax
   --lines per GT currency code and VAT tax type defined on GTA 'system
   --options form.If 'Yes', then will set NULL to the variables, if 'No',
   --then return exact taxable amount and tax amount

  IF AR_GTA_TRX_UTIL.Check_Taxcount_Of_Artrx
            (p_org_id           =>     l_org_id
            ,p_customer_trx_id  =>     l_ar_header_id
            )
  THEN
    l_ar_amount:=AR_GTA_TRX_UTIL.Get_Arinvoice_Amount
            (p_org_id           =>     l_org_id
            ,p_customer_trx_id  =>     l_ar_header_id
            );

    l_ar_taxamount:=AR_GTA_TRX_UTIL.Get_Arinvoice_Tax_Amount
            (p_org_id               =>  l_org_id
            ,p_customer_trx_id      =>  l_ar_header_id
            );
  ELSE
    l_ar_amount:='';
    l_ar_taxamount:='';
  END IF;  --AR_GTA_TRX_UTIL.Check_Taxcount_Of_Artrx.....

  --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                  ,'l_ar_amount '||l_ar_amount
                  );

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                  ,'l_ar_taxamount '||l_ar_taxamount
                  );


  END IF;  --( l_proc_level >= l_dbg_level)




  --Get Bank account name and number of a specific AR transaction
  AR_GTA_TRX_UTIL.Get_Bank_Info
         (p_customer_trx_id   =>   l_ar_header_id
         ,p_org_id            =>   l_org_id
         ,x_bank_name         =>   l_ar_bank_name
         ,x_bank_branch_name  =>   l_ar_branch_name
         ,x_bank_account_name =>   l_ar_bank_account_name
         ,x_bank_account_num  =>   l_ar_bank_account_num
         );
  l_ar_customer_bank_account:=l_ar_bank_name||' '||
                              l_ar_branch_name||' '||l_ar_bank_account_num;


  l_ar_customer_phone:=AR_GTA_TRX_UTIL.Get_Primary_Phone_Number
                                (p_customer_id => l_ar_customer_id
                                );



  --To generate ar customer address phone
  IF l_ar_customer_phone IS NOT NULL
  THEN
    l_ar_customer_address_phone:=l_ar_customer_address||' '||
                                 l_ar_customer_phone;
  ELSE
    l_ar_customer_address_phone:=l_ar_customer_address;
  END IF;  --l_ar_customer_phone IS NOT NULL

  --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                  ,'l_ar_customer_bank_account '||l_ar_customer_bank_account
                  );

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                  ,'l_ar_customer_address_phone '||l_ar_customer_address_phone
                  );


  END IF;  --( l_proc_level >= l_dbg_level)

  --Added by Allen to fix issue #2 in bug 6147067
  --To accumulate GTA invoice amount, tax amount and concatenate GTA invoice number.

  l_gta_amount_sum:=0;
  l_gta_taxamount_sum:=0;
  l_gta_trx_number_con:='';
  l_gta_amount_loop_count:=0;

  OPEN c_gta_amounts;
  FETCH c_gta_amounts
   INTO l_gta_amount
       ,l_gta_taxamount
       ,l_gta_trx_number
       ;

  WHILE c_gta_amounts%FOUND
  LOOP
    l_gta_amount_loop_count:=l_gta_amount_loop_count+1;

    --Log for debug
    IF( l_proc_level >= l_dbg_level)
    THEN
       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gta_amount_loop_count '||l_gta_amount_loop_count||','
                      ||'l_gta_amount_sum '||l_gta_amount_sum||','
                      ||'l_gta_taxamount_sum '||l_gta_taxamount_sum||','
                      ||'l_gta_trx_number_con '||l_gta_trx_number_con
                     );
    END IF;  --( l_proc_level >= l_dbg_level)

    --To accumulate GTA invoice amount
    l_gta_amount_sum:=l_gta_amount_sum+l_gta_amount;

    --To accumulate GTA invoice tax amount
    l_gta_taxamount_sum:=l_gta_taxamount_sum+l_gta_taxamount;

    --To concatenate GTA invoice number
    IF (l_gta_trx_number_con IS NULL)
    THEN
       l_gta_trx_number_con:=l_gta_trx_number;
    ELSE
       l_gta_trx_number_con:=l_gta_trx_number_con||','||l_gta_trx_number;
    END IF;  --(l_gta_trx_number_con IS NULL)

    FETCH c_gta_amounts
     INTO l_gta_amount
         ,l_gta_taxamount
         ,l_gta_trx_number
         ;

  END LOOP; --c_gta_amounts%FOUND
  CLOSE c_gta_amounts;


   --compare AR header with GTA header and GT header

   --Commented by Allen to fix issue #2 in bug 6147067
   --l_gta_amount_sum:=0;
   --l_gta_taxamount_sum:=0;
   --l_gta_trx_number_con:='';
   l_gt_amount_sum:=0;
   l_gt_taxamount_sum:=0;
   l_gt_invoice_number_con:='';

   l_gta_loop_count:=0;

   OPEN c_gta_headers;
   FETCH c_gta_headers
    INTO --l_gta_amount
        --,l_gta_taxamount,
         l_gta_customer_name
        ,l_gta_taxpayer_id
        ,l_gta_customer_bank_account
        ,l_gta_customer_address_phone
        ,l_gta_trx_number
	,l_gta_invoice_type      --added by subba for R12.1
	,l_gta_invoice_type_name
  ,l_gta_status--Yao Zhang add for bug#8765631
        ;

   WHILE c_gta_headers%FOUND
   LOOP

     l_gta_loop_count:=l_gta_loop_count+1;
     IF(l_csldt_flag IS NULL AND l_gta_status='CONSOLIDATED')
     THEN
       l_csldt_flag:='Y';
     END IF;

     --log for debug
     IF( l_proc_level >= l_dbg_level)
     THEN
       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gta_loop_count '||l_gta_loop_count
                     );

       /*Commented by Allen to fix issue #2 in bug 6147067
       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gta_amount '||l_gta_amount
                     );

       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gta_taxamount '||l_gta_taxamount
                     );
       */

       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gta_customer_name '||l_gta_customer_name
                     );

       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gta_taxpayer_id '||l_gta_taxpayer_id
                     );

       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gta_customer_bank_account '||
                       l_gta_customer_bank_account
                     );

       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gta_customer_address_phone '||
                       l_gta_customer_address_phone
                     );

       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gta_trx_number '||l_gta_trx_number
                     );
   --added by subba for R12.1

      FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gta_invoice_type '||l_gta_invoice_type
                     );


     END IF;  --( l_proc_level >= l_dbg_level)

     --To get related GT invoice to current GTA invoice
     --Yao Zhang add for bug#8765631
     l_gt_amount:=NULL;
     l_gt_taxamount:=NULL;
     l_gt_customer_name:=NULL;
     l_gt_taxpayer_id:=NULL;
     l_gt_customer_bank_account:=NULL;
     l_gt_customer_address_phone:=NULL;
     l_gt_invoice_number:=NULL;
     l_gt_invoice_type:=NULL;
     l_gt_invoice_type_name:=NULL;
     --yao zhang add end
     OPEN c_gt_headers;
     FETCH c_gt_headers
      INTO l_gt_amount
          ,l_gt_taxamount
          ,l_gt_customer_name
          ,l_gt_taxpayer_id
          ,l_gt_customer_bank_account
          ,l_gt_customer_address_phone
          ,l_gt_invoice_number
	  ,l_gt_invoice_type          --added by subba for R12.1
	  ,l_gt_invoice_type_name
          ;
     CLOSE c_gt_headers;

     IF( l_proc_level >= l_dbg_level)
     THEN

       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gt_amount '||l_gt_amount
                     );

       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gt_taxamount '||l_gt_taxamount
                     );

       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gt_customer_name '||l_gt_customer_name
                     );

       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gt_taxpayer_id '||l_gt_taxpayer_id
                     );

       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gt_customer_bank_account '||
                       l_gt_customer_bank_account
                     );

       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gt_customer_address_phone '||
                       l_gt_customer_address_phone
                     );

       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gt_invoice_number '||l_gt_invoice_number
                     );

       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                     ,'l_gt_invoice_type '||l_gt_invoice_type
                     );


     END IF;  --( l_proc_level >= l_dbg_level)


     --Commented by Allen to fix issue #2 in bug 6147067

     --To accumulate GTA invoice amount and tax amount
     --l_gta_amount_sum:=l_gta_amount_sum+l_gta_amount;
     --l_gta_taxamount_sum:=l_gta_taxamount_sum+l_gta_taxamount;

     --To accumulate GT invoice amount and tax amount
     l_gt_amount_sum:=l_gt_amount_sum+nvl(l_gt_amount,0);
     l_gt_taxamount_sum:=l_gt_taxamount_sum+nvl(l_gt_taxamount,0);

     --To concatenate GTA invoice number
     /*
     IF (l_gta_trx_number_con IS NULL)
     THEN
       l_gta_trx_number_con:=l_gta_trx_number;
     ELSE
       l_gta_trx_number_con:=l_gta_trx_number_con||','||l_gta_trx_number;
     END IF;  --(l_gta_trx_number_con IS NULL)
     */

     --To concatenate GT invoice number
     IF (l_gt_invoice_number_con IS NULL)
     THEN
       l_gt_invoice_number_con:=l_gt_invoice_number;
     ELSE
       l_gt_invoice_number_con:=l_gt_invoice_number_con||','||
                                l_gt_invoice_number;
     END IF; --(l_gt_invoice_number_con IS NULL)

     --To compare customer name

     --Updated by Allen to fix issue#1 in bug 6147067
     --Add trim() function to avoid the discrepancy caused by space character
     l_ar_customer_name:=trim(l_ar_customer_name);
     l_gta_customer_name:=trim(l_gta_customer_name);
     l_gt_customer_name:=trim(l_gt_customer_name);
     /*fnd_file.PUT_LINE(fnd_file.LOG,'l_ar_customer_name:'||l_ar_customer_name);
    -- fnd_file.PUT_LINE(fnd_file.LOG,'l_gta_customer_name:'||l_gta_customer_name);
    -- fnd_file.PUT_LINE(fnd_file.LOG,'l_gt_customer_name'||l_gt_customer_name);*/
     IF (nvl(l_ar_customer_name,' ')<>nvl(l_gta_customer_name,' ')) OR
        --Yao Zhang Modified for bug#8765631
        ((nvl(l_ar_customer_name,' ')<>nvl(l_gt_customer_name,' '))AND l_gta_status='COMPLETED')
     THEN

       --Insert this discrepancy record to temp table ar_gta_difference_temp
       INSERT INTO ar_gta_difference_temp(type
                                         ,ar_header_id
                                         ,attribute
                                         ,ar_value
                                         ,gta_invoice_num
                                         ,gta_value
                                         ,gt_invoice_num
                                         ,gt_value
                                         ,discrepancy
                                         )
                                   VALUES('HEADER'
                                         ,l_ar_header_id
                                         ,l_cust_name_attr
                                         ,l_ar_customer_name
                                         ,l_gta_trx_number
                                         ,l_gta_customer_name
                                         ,l_gt_invoice_number
                                         ,l_gt_customer_name
                                         ,'-'
                                         );
       l_has_difference:=TRUE;
     END IF;  --l_ar_customer_name<>l_gta_customer_name) OR ......

 --added by subba for R12.1, check to see the discrepancy of Invoice_type

     IF (l_gta_invoice_type IS NOT NULL
         AND  l_gt_invoice_type IS NOT NULL
         AND l_gta_invoice_type <> l_gt_invoice_type
         AND l_gta_status='COMPLETED')--Yao Zhang add for bug#8765631
     THEN

                     --Insert this discrepancy record to temp table ar_gta_difference_temp

            INSERT INTO ar_gta_difference_temp(type
	                                        ,ar_header_id
						,attribute
						,ar_value
						,gta_invoice_num
						,gta_value
                                                ,gt_invoice_num
						,gt_value
						,discrepancy )

                                          VALUES('HEADER'
					        ,l_ar_header_id
						,l_invoicetype_attr
						,l_gta_invoice_type_name
                                                ,l_gta_trx_number
						,l_gta_invoice_type_name
						,l_gt_invoice_number
                                                ,l_gt_invoice_type_name
						,'-'
						);

             l_has_difference:=TRUE;

      END IF;  --l_gta_invoice_type IS NOT NULL AND....


     --To compare bank name account

     --Updated by Allen to fix issue#1 in bug 6147067
     --Add trim() function to avoid the discrepancy caused by space character
     l_ar_customer_bank_account:=trim(l_ar_customer_bank_account);
     l_gta_customer_bank_account:=trim(l_gta_customer_bank_account);
     l_gt_customer_bank_account:=trim(l_gt_customer_bank_account);

     IF (nvl(l_ar_customer_bank_account,' ')<>nvl(l_gta_customer_bank_account,' '))   OR
         ((nvl(l_ar_customer_bank_account,' ')<>nvl(l_gt_customer_bank_account,' ')) AND l_gta_status='COMPLETED')
         /*l_ar_customer_bank_account IS NOT NULL                    AND
         l_gta_customer_bank_account IS NOT NULL
        ) OR
        (l_ar_customer_bank_account IS NULL                        AND
         l_gta_customer_bank_account IS NOT NULL
        ) OR
        (l_ar_customer_bank_account IS NOT NULL                    AND
         l_gta_customer_bank_account IS NULL
        ) OR
        (l_ar_customer_bank_account<>l_gt_customer_bank_account    AND
         l_ar_customer_bank_account IS NOT NULL                    AND
         l_gt_customer_bank_account IS NOT NULL
        ) OR
        (l_ar_customer_bank_account IS NULL                        AND
         l_gt_customer_bank_account IS NOT NULL
        ) OR
        (l_ar_customer_bank_account IS NOT NULL                    AND
         l_gt_customer_bank_account IS NULL*/

     THEN


      IF l_ar_customer_bank_account IS NOT NULL
      THEN

        --To mask ar bank name account according to
        --profile AR_MASK_BANK_ACCOUNT_NUMBERS
        SELECT
          DECODE( NVL(l_ar_mask_bank, 'FIRST FOUR VISIBLE')
                ,'FIRST FOUR VISIBLE', RPAD('*'
                                           ,LENGTH(l_ar_customer_bank_account)
                                           ,'*'
                                           )
                ,'LAST FOUR VISIBLE',LPAD('*'
                                          ,LENGTHB(l_ar_customer_bank_account)
                                          , '*'
                                           )
                , 'NO MASK',l_ar_customer_bank_account
                )
        INTO
          l_ar_customer_bank_account_m
        FROM
          dual;
      ELSE
        l_ar_customer_bank_account_m:='';
      END IF; --l_ar_customer_bank_account IS NOT NULL


      IF l_gta_customer_bank_account IS NOT NULL
      THEN
        --To mask gta bank name account according to
        --profile AR_MASK_BANK_ACCOUNT_NUMBERS
        SELECT
          DECODE( NVL(l_ar_mask_bank, 'FIRST FOUR VISIBLE')
                , 'FIRST FOUR VISIBLE', RPAD('*'
                                            ,LENGTH(l_gta_customer_bank_account)
                                            , '*'
                                            )
                , 'LAST FOUR VISIBLE', LPAD('*'
                                           ,LENGTHB(l_gta_customer_bank_account)
                                           , '*'
                                            )
                 , 'NO MASK',l_gta_customer_bank_account
                 )
        INTO
          l_gta_customer_bank_account_m
        FROM
          dual;
      ELSE
        l_gta_customer_bank_account_m:='';
      END IF; --l_gta_customer_bank_account IS NOT NULL

      IF l_gt_customer_bank_account IS NOT NULL
      THEN
        --To mask gt bank name account according to
        --profile AR_MASK_BANK_ACCOUNT_NUMBERS
        SELECT
          DECODE( NVL(l_ar_mask_bank, 'FIRST FOUR VISIBLE')
                , 'FIRST FOUR VISIBLE', RPAD('*'
                           ,LENGTH(l_gt_customer_bank_account)
                           , '*'
                           )
                , 'LAST FOUR VISIBLE', LPAD('*'
                                           ,LENGTHB(l_gt_customer_bank_account)
                                           , '*'
                                           )
                , 'NO MASK',l_gt_customer_bank_account
                )
        INTO
          l_gt_customer_bank_account_m
        FROM
          dual;
      ELSE
        l_gt_customer_bank_account_m:='';
      END IF;  --l_gt_customer_bank_account IS NOT NULL


       --Insert this discrepancy record to temp table ar_gta_difference_temp
       INSERT INTO ar_gta_difference_temp(type
                                         ,ar_header_id
                                         ,attribute
                                         ,ar_value
                                         ,gta_invoice_num
                                         ,gta_value
                                         ,gt_invoice_num
                                         ,gt_value
                                         ,discrepancy
                                         )
                                   VALUES('HEADER'
                                         ,l_ar_header_id
                                         ,l_bank_name_account_attr
                                         ,l_ar_customer_bank_account_m
                                         ,l_gta_trx_number
                                         ,l_gta_customer_bank_account_m
                                         ,l_gt_invoice_number
                                         ,l_gt_customer_bank_account_m
                                         ,'-'
                                         );
       l_has_difference:=TRUE;
     END IF;  --(l_ar_customer_bank_account<>l_gta_customer_bank_account)
              --OR (l_ar_customer_bank_account<>l_gt_customer_bank_account)

     --To compare address and phone number

     --Updated by Allen to fix issue#1 in bug 6147067
     --Add trim() function to avoid the discrepancy caused by space character
     l_ar_customer_address_phone        := trim(l_ar_customer_address_phone);
     l_gta_customer_address_phone       := trim(l_gta_customer_address_phone);
     l_gt_customer_address_phone        := trim(l_gt_customer_address_phone);
     --Yao modified for bug#8765631
     IF (nvl(l_ar_customer_address_phone,' ')<>nvl(l_gta_customer_address_phone,' '))     OR
        ((nvl(l_ar_customer_address_phone,' ')<>nvl(l_gt_customer_address_phone,' ')) AND l_gta_status='COMPLETED')
         /*l_ar_customer_address_phone IS NOT NULL                       AND
         l_gta_customer_address_phone IS NOT NULL
        ) OR
        (l_ar_customer_address_phone IS NOT NULL                       AND
         l_gta_customer_address_phone IS NULL
        ) OR
        (l_ar_customer_address_phone IS NULL                           AND
         l_gta_customer_address_phone IS NOT NULL
        ) OR
        (l_ar_customer_address_phone<>l_gt_customer_address_phone      AND
         l_ar_customer_address_phone IS NOT NULL                       AND
         l_gt_customer_address_phone IS NOT NULL
        ) OR
        (l_ar_customer_address_phone IS NOT NULL                       AND
         l_gt_customer_address_phone IS NULL
        ) OR
        (l_ar_customer_address_phone IS NULL                           AND
         l_gt_customer_address_phone IS NOT NULL
        )*/
     THEN


       --Insert this discrepancy record to temp table ar_gta_difference_temp

       INSERT INTO ar_gta_difference_temp(type
                                         ,ar_header_id
                                         ,attribute
                                         ,ar_value
                                         ,gta_invoice_num
                                         ,gta_value
                                         ,gt_invoice_num
                                         ,gt_value
                                         ,discrepancy
                                         )
                                   VALUES('HEADER'
                                         ,l_ar_header_id
                                         ,l_address_phone_attr
                                         ,l_ar_customer_address_phone
                                         ,l_gta_trx_number
                                         ,l_gta_customer_address_phone
                                         ,l_gt_invoice_number
                                         ,l_gt_customer_address_phone
                                         ,'-'
                                         );
       l_has_difference:=TRUE;
     END IF;  --(l_ar_customer_address_phone<>l_gta_customer_address_phone)
              --OR (l_ar_customer_address_phone<>l_gt_customer_address_phone)

     --commented by Donghai due to ebtax functionality
     --To compare tax payer ID
    /* IF (l_ar_taxpayer_id<>l_gta_taxpayer_id      AND
         l_ar_taxpayer_id IS NOT NULL             AND
         l_gta_taxpayer_id IS NOT NULL
        ) OR
        (l_ar_taxpayer_id IS NOT NULL             AND
         l_gta_taxpayer_id IS NULL
        ) OR
        (l_ar_taxpayer_id IS NULL                 AND
         l_gta_taxpayer_id IS NOT NULL
        ) OR
        (l_ar_taxpayer_id<>l_gt_taxpayer_id       AND
         l_ar_taxpayer_id IS NOT NULL             AND
         l_gta_taxpayer_id IS NOT NULL
        ) OR
        (l_ar_taxpayer_id IS NOT NULL             AND
         l_gta_taxpayer_id IS NULL
        ) OR
        (l_ar_taxpayer_id IS NULL                 AND
         l_gta_taxpayer_id IS NOT NULL
        )
     THEN
       --Insert this discrepancy record to temp table ar_gta_difference_temp
       INSERT INTO ar_gta_difference_temp(type
                                         ,ar_header_id
                                         ,attribute
                                         ,ar_value
                                         ,gta_invoice_num
                                         ,gta_value
                                         ,gt_invoice_num
                                         ,gt_value
                                         ,discrepancy
                                         )
                                   VALUES('HEADER'
                                         ,l_ar_header_id
                                         ,l_taxpayer_id_attr
                                         ,l_ar_taxpayer_id
                                         ,l_gta_trx_number
                                         ,l_gta_taxpayer_id
                                         ,l_gt_invoice_number
                                         ,l_gt_taxpayer_id
                                         ,'-'
                                         );
       l_has_difference:=TRUE;
     END IF;  --(l_ar_taxpayer_id<>l_gta_taxpayer_id)
              --OR (l_ar_taxpayer_id<>l_gt_taxpayer_id)
     */



     --To compare tax registration number on GTA and GT
     --If tax registration number on GTA header lever is different from
     --that on GT header level,then mark all lines belong to corresponding
     --GTA invoice and GT invoice as unmatched,saying 'matched_flag='N'

     --Updated by Allen to fix issue#1 in bug 6147067
     --Add trim() function to avoid the discrepancy caused by space character

     l_gta_taxpayer_id:=trim(l_gta_taxpayer_id);
     l_gt_taxpayer_id:=trim(l_gt_taxpayer_id);

     IF ((l_gta_taxpayer_id<>l_gt_taxpayer_id)AND l_gta_status='COMPLETED')--Yao Zhang add for bug#8765631
     THEN
       --update lines belong to GTA invoice
       UPDATE
         ar_gta_trx_lines_all gta_line
       SET
         gta_line.matched_flag='N'
       WHERE gta_line.gta_trx_header_id=
                  (SELECT
                     gta_header.gta_trx_header_id
                   FROM
                     ar_gta_trx_headers_all gta_header
                   WHERE gta_header.source='AR'
                     AND gta_header.gta_trx_number=l_gta_trx_number
                  )
         AND gta_line.enabled_flag='Y';

       --update lines belong to GT invoice
        UPDATE ar_gta_trx_lines_all gt_line
          SET gt_line.matched_flag='N'
          WHERE gt_line.gta_trx_header_id=
                  (SELECT
                     gt_header.gta_trx_header_id
                   FROM
                     ar_gta_trx_headers_all gt_header
                   WHERE gt_header.source='GT'
                     AND gt_header.gta_trx_number=l_gta_trx_number
                   );
     END IF;  --(l_gta_taxpayer_id<>l_gt_taxpayer_id)


     --Commented by Allen to fix issue #2 in bug 6147067
     FETCH c_gta_headers
     INTO --l_gta_amount
         --,l_gta_taxamount,
          l_gta_customer_name
         ,l_gta_taxpayer_id
         ,l_gta_customer_bank_account
         ,l_gta_customer_address_phone
         ,l_gta_trx_number
         ,l_gta_invoice_type              --added by Subba.
         ,l_gta_invoice_type_name
         ,l_gta_status--Yao Zhang add for bug#8765631
         ;

   END LOOP; --c_gta_headers%FOUND
   CLOSE c_gta_headers;

   --compare amount
   IF (nvl(l_ar_amount,0)<>nvl(l_gta_amount_sum,0)) OR
      (nvl(l_ar_amount,0)<>nvl(l_gt_amount_sum,0) AND l_csldt_flag IS NULL)--Yao Modified for bug#8765631
   THEN

     IF l_ar_amount IS NULL
     THEN
       l_amount_discrepancy:='-';
     ELSE
       --To compute discrepancy of amount (GT-AR)
       l_amount_discrepancy:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id => p_org_id
                                                                    ,p_amount => l_gt_amount_sum-l_ar_amount
                                                                    );
     END IF; --l_ar_amount IS NULL

     --Format Amount
     l_ar_amount_disp:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id => p_org_id
                                                             ,p_amount => l_ar_amount
                                                             );

     l_gta_amount_sum_disp:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id => p_org_id
                                                                   ,p_amount => l_gta_amount_sum
                                                                   );

     l_gt_amount_sum_disp:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id => p_org_id
                                                                  ,p_amount =>l_gt_amount_sum
                                                                  );

     --Insert this discrepancy record to temp table ar_gta_difference_temp
     INSERT INTO ar_gta_difference_temp(type
                                       ,ar_header_id
                                       ,attribute
                                       ,ar_value
                                       ,gta_invoice_num
                                       ,gta_value
                                       ,gt_invoice_num
                                       ,gt_value
                                       ,discrepancy
                                       )
                                 VALUES('HEADER'
                                       ,l_ar_header_id
                                       ,l_amount_attr
                                       ,l_ar_amount_disp
                                       ,l_gta_trx_number_con
                                       ,l_gta_amount_sum_disp
                                       ,l_gt_invoice_number_con
                                       ,l_gt_amount_sum_disp
                                       ,l_amount_discrepancy
                                       );
     l_has_difference:=TRUE;
   END IF;  --(l_ar_amount<>l_gta_amount_sum) OR (l_ar_amount<>l_gt_amount_sum)

   IF (nvl(l_ar_taxamount,0)<>nvl(l_gta_taxamount_sum,0)) OR
      (nvl(l_ar_taxamount,0)<>nvl(l_gt_taxamount_sum,0) AND l_csldt_flag IS NULL)
   THEN

     IF l_ar_taxamount IS NULL
     THEN
       l_taxamount_discrepancy:='-';
     ELSE
       --To compute discrepancy of tax amount (GT-AR)
       l_taxamount_discrepancy:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id   => p_org_id
                                                                       ,p_amount   => l_gt_taxamount_sum-l_ar_taxamount
                                                                       );
     END IF;  -- l_ar_taxamount IS NULL

     --Format Amount
     l_ar_taxamount_disp:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id => p_org_id
                                                                 ,p_amount => l_ar_taxamount
                                                                 );

     l_gta_taxamount_sum_disp:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id => p_org_id
                                                                      ,p_amount => l_gta_taxamount_sum
                                                                      );

     l_gt_taxamount_sum_disp:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id => p_org_id
                                                                     ,p_amount => l_gt_taxamount_sum
                                                                     );


     --Insert this discrepancy record to temp table ar_gta_difference_temp
     INSERT INTO ar_gta_difference_temp(type
                                       ,ar_header_id
                                       ,attribute
                                       ,ar_value
                                       ,gta_invoice_num
                                       ,gta_value
                                       ,gt_invoice_num
                                       ,gt_value
                                       ,discrepancy
                                       )
                                 VALUES('HEADER'
                                       ,l_ar_header_id
                                       ,l_taxamount_attr
                                       ,l_ar_taxamount_disp
                                       ,l_gta_trx_number_con
                                       ,l_gta_taxamount_sum_disp
                                       ,l_gt_invoice_number_con
                                       ,l_gt_taxamount_sum_disp
                                       ,l_taxamount_discrepancy
                                       );
     l_has_difference:=TRUE;
   END IF;--(l_ar_taxamount<>l_gta_tax_amount_sum)
          --OR (l_ar_taxamount<>l_gt_taxamount_sum)

   x_has_difference:=l_has_difference;

--log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.end'
                  ,'Exit procedure');


  END IF;  --( l_proc_level >= l_dbg_level)

EXCEPTION
  WHEN OTHERS THEN
    IF(l_proc_level >= l_dbg_level)
    THEN
      l_error_msg:=SQLCODE||':'||SQLERRM;
      FND_LOG.String( l_proc_level
                    , g_module_prefix || l_api_name || '. Other_Exception '
                    , l_error_msg
                    );


      END IF;   --(FND_LOG.Level_Unexpected >= FND_LOG.G_Current_Runtime_Level)

    IF c_gta_headers%ISOPEN
    THEN
      CLOSE c_gta_headers;
    END IF;--c_gta_headers%ISOPEN
    RAISE;
END Compare_Header;

--==========================================================================
--  PROCEDURE NAME:
--
--      Compare_Lines                Public
--
--  DESCRIPTION:
--
--      This Procedure Compare Ar, Gta, Gt Lines And Input Difference Record
--      Compared Columns Include: "Goods Description", "Line Amount",
--      "Vat Line Tax", "Vat Tax Rate", "Quantity", "Unit Price" And "Uom"
--
--  PARAMETERS:
--      In:   p_org_id                 Operating unit id
--            p_ar_header_id           AR Transaction id
--
--     Out:   x_has_difference
--
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           05/17/05   	Donghai  Wang        Created.
--           11/25/05     Donghai  Wang        modify code to follow ebtax
--                                             requirement
--           03/04/05     Donghai  Wang        Add FND Log
--           06/28/06     Donghai  Wang        Fix the bug 5263009
--           07/21/06     Donghai  Wang        Fix the bug 5381833
--           06/18/07     Donghai  Wang        Fix the bug 6132187
--           13-MAY-2009  Yao Zhang Changed for bug 5604079
--           06-Aug-2009  Yao Zhang Changed for bug#8765631
--           19-Aug-2009  Yao Zhang  modified for bug#8809860
--           23-Sep-2009  Yao Zhang fix bug#8289585
--===========================================================================
PROCEDURE Compare_Lines
( p_org_id	            IN	        NUMBER
, p_ar_header_id	    IN	        NUMBER
, x_validated_lines         OUT NOCOPY  NUMBER
, x_ar_matching_lines       OUT NOCOPY  NUMBER
, x_ar_partially_import     OUT NOCOPY  NUMBER
, x_has_difference	    OUT NOCOPY	BOOLEAN
)
IS
l_org_id                      hr_all_organization_units.organization_id%TYPE
                              :=p_org_id;
l_ar_header_id                ra_customer_trx_all.customer_trx_id%TYPE
                              :=p_ar_header_id;
l_has_difference              BOOLEAN;
l_ar_line_id                  ra_customer_trx_lines_all.customer_trx_line_id%TYPE;
l_ar_line_number              ra_customer_trx_lines_all.line_number%TYPE;
l_ar_goods_description        ra_customer_trx_lines_all.description%TYPE;
l_ar_line_amount              NUMBER;
l_ar_line_amount_disp         VARCHAR2(50);
l_ar_vat_line_tax             NUMBER;
l_ar_vat_line_tax_disp        VARCHAR2(50);
l_ar_vat_tax_rate             NUMBER;
l_ar_quantity                 NUMBER;
l_ar_unit_price               NUMBER;
l_ar_unit_price_disp          VARCHAR2(50);
l_ar_uom                      ra_customer_trx_lines_all.uom_code%TYPE;
l_ar_tax_reg_number           zx_registrations.registration_number%TYPE;
l_gta_trx_number              ar_gta_trx_headers_all.gta_trx_number%TYPE;
l_gta_line_number             ar_gta_trx_lines_all.line_number%TYPE;
l_gta_goods_description       ra_customer_trx_lines_all.description%TYPE;
l_gta_line_amount             NUMBER;
l_gta_vat_line_tax            NUMBER;
l_gta_vat_tax_rate            NUMBER;
l_gta_quantity                NUMBER;
l_gta_unit_price              NUMBER;
l_gta_unit_price_disp         VARCHAR2(50);
l_gta_uom                     ra_customer_trx_lines_all.uom_code%TYPE;
l_gta_line_amount_sum         NUMBER;
l_gta_line_amount_sum_disp    VARCHAR2(50);
l_gta_line_taxamount_sum      NUMBER;
l_gta_line_taxamount_sum_disp VARCHAR2(50);
l_gta_line_quantity_sum       NUMBER;
l_gta_tax_reg_number          ar_gta_trx_headers_all.tp_tax_registration_number%TYPE;
l_matched_flag                ar_gta_trx_lines_all.matched_flag%TYPE;
l_matched_flag_total          ar_gta_trx_lines_all.matched_flag%TYPE;
l_goods_description_attr      fnd_lookup_values.meaning%TYPE;
l_line_amount_attr            fnd_lookup_values.meaning%TYPE;
l_vat_line_tax_attr           fnd_lookup_values.meaning%TYPE;
l_vat_tax_rate_attr           fnd_lookup_values.meaning%TYPE;
l_quantity_attr               fnd_lookup_values.meaning%TYPE;
l_unit_price_attr             fnd_lookup_values.meaning%TYPE;
l_tax_reg_number_attr         fnd_lookup_values.meaning%TYPE;
l_unmatched_attr              VARCHAR2(100);
l_uom_attr                    fnd_lookup_values.meaning%TYPE;
l_gt_value                    VARCHAR2(500);

--Change length of the variable l_gt_invoice_number to 4000 to fix bug 6132187
--l_gt_invoice_number           ar_gta_trx_headers_all.gt_invoice_number%TYPE;
l_gt_invoice_number           VARCHAR2(4000);
--------------------------------------------------

l_gta_trx_number_con          VARCHAR2(4000);
l_gt_invoice_number_con       VARCHAR2(4000);
l_gta_line_number_con         VARCHAR2(4000);
l_validated_lines             NUMBER;
l_ar_matching_line_flag       VARCHAR2(1);
l_ar_matching_lines           NUMBER;
l_gta_lines_not_enabled_count NUMBER;
l_ar_partially_import         NUMBER;

l_api_name                    VARCHAR2(50):='Compare_Lines';
l_dbg_msg                     VARCHAR2(100);
l_error_msg                   VARCHAR2(4000);

--Added for fixing the bug 5381833
l_tax_type_code               zx_lines.tax_type_code%TYPE;
l_gt_currency_code            fnd_currencies.currency_code%TYPE;
l_no_value                    VARCHAR2(1):='-';
--------------------------------------
l_order_number              ra_customer_trx_lines_all.interface_line_attribute1%TYPE;
l_om_line_id                ra_customer_trx_lines_all.interface_line_attribute1%TYPE;
l_discount_adjustment_id    ra_customer_trx_lines_all.interface_line_attribute11%TYPE;
l_price_adjustment_id       ra_customer_trx_lines_all.interface_line_attribute1%TYPE;
l_ar_line_context           ra_customer_trx_lines_all.interface_line_context%TYPE;
l_adjustment_type           OE_PRICE_ADJUSTMENTS.list_line_type_code%TYPE;
l_discount_amount           ar_gta_trx_lines_all.discount_amount%TYPE;
l_discount_tax_amount       ar_gta_trx_lines_all.discount_tax_amount%TYPE;
l_discount_cust_trx_line_id ra_customer_trx_lines_all.customer_trx_line_id%TYPE;


CURSOR c_ar_lines IS
SELECT
  rctl.customer_trx_line_id
 ,rctl.line_number
 ,rctl.description                  goods_description
 ,rctl.quantity_invoiced            quantity
 ,rctl.unit_selling_price           unit_price
 ,rctl.uom_code                     uom
 --Yao add for bug#8765631
 ,rctl.interface_line_context
 ,rctl.interface_line_attribute1
 ,rctl.interface_line_attribute6
 ,rctl.interface_line_attribute11
 --Yao add end
FROM
  ra_customer_trx_lines rctl
WHERE rctl.customer_trx_id=l_ar_header_id
  AND rctl.line_type='LINE';

CURSOR c_gta_lines IS
SELECT
  jgth.gta_trx_number
 ,jgth.tp_tax_registration_number
 ,jgtl.line_number
 ,jgtl.item_description
 --Yao modified for bug8765631
 ,(jgtl.amount+nvl(jgtl.discount_amount,0)) amount
 ,(jgtl.tax_amount+nvl(jgtl.discount_tax_amount,0)) discount_amount
 ,jgtl.tax_rate
 ,jgtl.quantity
 ,jgtl.unit_price
 ,jgtl.uom
 ,jgtl.matched_flag
FROM
  ar_gta_trx_headers     jgth
 ,ar_gta_trx_lines_all   jgtl
WHERE jgth.ra_trx_id=l_ar_header_id
  AND jgth.source='AR'
  AND (jgth.status='COMPLETED' OR jgth.status='CONSOLIDATED')
  AND jgth.latest_version_flag='Y'
  AND jgtl.gta_trx_header_id=jgth.gta_trx_header_id
  AND jgtl.ar_trx_line_id=l_ar_line_id
  AND jgtl.enabled_flag='Y'
  ORDER BY jgth.gta_trx_number;

CURSOR c_gta_lines_not_enabled IS
SELECT
  COUNT(*)
FROM
  ar_gta_trx_headers    jgth
 ,ar_gta_trx_lines_all  jgtl
WHERE jgth.ra_trx_id=l_ar_header_id
  AND jgth.source='AR'
  AND jgth.status='COMPLETED'
  AND jgth.latest_version_flag='Y'
  AND jgtl.gta_trx_header_id=jgth.gta_trx_header_id
  AND jgtl.ar_trx_line_id=l_ar_line_id
  AND jgtl.enabled_flag='N';

CURSOR c_gt_invoice_number IS
SELECT
  jgth.gt_invoice_number
FROM
  ar_gta_trx_headers_all jgth
WHERE jgth.source='GT'
  AND jgth.gta_trx_number=l_gta_trx_number;

CURSOR c_missing_ar_line IS
SELECT
  jgth.gta_trx_number
 ,jgtl.line_number
FROM
  ar_gta_trx_headers       jgth
 ,ar_gta_trx_lines_all     jgtl
WHERE jgth.ra_trx_id=l_ar_header_id
  AND jgth.source='AR'
  AND jgth.status='COMPLETED'
  AND jgth.latest_version_flag='Y'
  AND jgtl.gta_trx_header_id=jgth.gta_trx_header_id
  AND NOT EXISTS (SELECT
                    rctl.customer_trx_line_id
                  FROM
                    ra_customer_trx_lines rctl
                  WHERE rctl.customer_trx_id=l_ar_header_id
                    AND rctl.customer_trx_line_id=jgtl.ar_trx_line_id
                 );

--Add this cursor to fix bug 5381833
CURSOR c_tax_type_code
IS
SELECT
  vat_tax_type_code
 ,gt_currency_code
FROM
  ar_gta_system_parameters_all
WHERE org_id=p_org_id;

--Add this cursor to fix bug 5381833
CURSOR c_not_transferred_ar_lines
IS
SELECT
  rctl.customer_trx_line_id   ar_line_id
 ,rctl.line_number            ar_line_num
FROM
  ra_customer_trx_lines rctl
WHERE rctl.customer_trx_id=l_ar_header_id
  --Yao add to fix bug#8765631 to exclude discount line
  AND NOT EXISTS (  SELECT opa.list_line_type_code
                      FROM oe_price_adjustments opa
                      WHERE rctl.interface_line_context='ORDER ENTRY'
                        AND opa.price_adjustment_id = rctl.interface_line_attribute11
                        AND opa.list_line_type_code='DIS')
  AND EXISTS (SELECT
                zl.trx_line_id
              FROM
                zx_lines zl
              WHERE zl.application_id = 222
                AND zl.trx_id=l_ar_header_id
                AND zl.trx_level_type='LINE'
                AND zl.entity_code='TRANSACTIONS'
                AND zl.trx_line_id=rctl.customer_trx_line_id
                AND zl.tax_type_code=l_tax_type_code
                AND zl.tax_currency_code=l_gt_currency_code
                AND zl.event_class_code IN ('INVOICE'
                                           ,'CREDIT_MEMO'
                                           ,'DEBIT_MEMO'
                                           )
             )
  AND NOT EXISTS (SELECT
                    jgtl.ar_trx_line_id
                  FROM
                    ar_gta_trx_headers       jgth
                   ,ar_gta_trx_lines_all     jgtl
                  WHERE jgth.ra_trx_id=l_ar_header_id
                    AND jgth.source='AR'
                    AND jgtl.gta_trx_header_id=jgth.gta_trx_header_id
                    AND jgtl.ar_trx_line_id=rctl.customer_trx_line_id
                 );

--Yao Zhang Add for bug#8605196 to support discount line
--c_discount_lines used to query discount lines for ar transaction line.
CURSOR c_discount_lines(l_line_id IN NUMBER) IS
       SELECT opa.price_adjustment_id
         FROM oe_price_adjustments opa
        WHERE opa.line_id = l_line_id
          AND opa.list_line_type_code = 'DIS';

l_dbg_level         NUMBER       :=FND_LOG.G_Current_Runtime_Level;
l_proc_level        NUMBER       :=FND_LOG.Level_Procedure;
l_ar_loop_count     NUMBER;
l_gta_loop_count    NUMBER;
l_conversion_rate  ra_customer_trx_all.exchange_rate%type;--Yao Zhang add for bug#5604079


BEGIN

--log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.begin'
                  ,'Enter procedure'
                  );

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'l_ar_header_id '||l_ar_header_id
                  );

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'l_org_id '||l_org_id
                  );



   END IF;  --( l_proc_level >= l_dbg_level)


--uncomment for bug#8289585
 --Yao Zhang add for bug#5604079
 select exchange_rate into l_conversion_rate
 from  ra_customer_trx_all
 where customer_trx_id=l_ar_header_id;
 --Yao Zhang add end
  -- To get meaning of line level attribute lookup code
  SELECT
    flv.meaning
  INTO
    l_goods_description_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='GOODS_DESCRIPTION';

  SELECT
    flv.meaning
  INTO
    l_line_amount_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='LINE_AMOUNT';

  SELECT
    flv.meaning
  INTO
    l_vat_line_tax_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='VAT_TAX_AMOUNT';

  SELECT
    flv.meaning
  INTO
    l_vat_tax_rate_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='VAT_TAX_RATE';

  SELECT
    flv.meaning
  INTO
    l_quantity_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='QUANTITY';

  SELECT
    flv.meaning
  INTO
    l_unit_price_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='UNIT_PRICE';

  SELECT
    flv.meaning
  INTO
    l_uom_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='UOM';

  SELECT
    flv.meaning
  INTO
    l_tax_reg_number_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='TAX_REGISTRATION_NUMBER';

  FND_MESSAGE.Set_Name(APPLICATION => 'AR'
                      ,NAME =>'AR_GTA_REFER_UNMATCH_LINE'
                      );
  l_unmatched_attr:=FND_MESSAGE.Get;


  --Get Vat tax type and GT currency code defined in GTA system options form
  --for current operating unit
  OPEN c_tax_type_code;
  FETCH c_tax_type_code INTO l_tax_type_code,l_gt_currency_code;
  CLOSE c_tax_type_code;
  --To initialize variables
  l_validated_lines:=0;
  l_ar_matching_lines:=0;
  l_ar_partially_import:=0;

  l_ar_loop_count:=0;


  --Get AR Line information
  OPEN c_ar_lines;
  LOOP
  FETCH c_ar_lines
   INTO l_ar_line_id
       ,l_ar_line_number
       ,l_ar_goods_description
       --commented by Donghai due to ebtax functionality
       --,l_ar_line_amount
       --,l_ar_vat_line_tax
       --,l_ar_vat_tax_rate
       ,l_ar_quantity
       ,l_ar_unit_price
       ,l_ar_uom
     --add by Yao for bug#8605196 to support discount line
       ,l_ar_line_context
       ,l_order_number
       ,l_om_line_id
       ,l_price_adjustment_id;
  EXIT WHEN c_ar_lines%NOTFOUND;
   --c_ar_lines%FOUND
     --fnd_file.PUT_LINE(fnd_file.LOG,'l_ar_line_context'||l_ar_line_context);
     --fnd_file.PUT_LINE(fnd_file.LOG,'l_price_adjustment_id'||l_price_adjustment_id);

     --The following code is added by Yao to fix bug#8765631
    l_adjustment_type:=null;
    l_discount_amount:=NULL;
    l_discount_tax_amount:=NULL;

    IF(l_ar_line_context='ORDER ENTRY'AND l_price_adjustment_id<>0)
    THEN
      BEGIN
        SELECT opa.list_line_type_code
          INTO l_adjustment_type
          FROM oe_price_adjustments opa
         WHERE opa.price_adjustment_id = l_price_adjustment_id;
      EXCEPTION
        WHEN  no_data_found THEN
             CLOSE c_ar_lines;
             RAISE;
      END;
      --Yao Zhang comment for bug#8809860
      /*IF l_adjustment_type='DIS'
      THEN
         CONTINUE;
      END IF;/*l_adjustment_type='DIS'*/
     END IF;/*(l_interface_line_context='ORDER ENTRY'AND l_price_adjustment_id<>0)*/

      --The following code is added by Yao Zhang for bug#8605196 to support discount line
      IF(l_ar_line_context='ORDER ENTRY' and l_price_adjustment_id=0)
      THEN--the original transction line
        --fnd_file.PUT_LINE(fnd_file.LOG,'NormalLine with discount'||l_om_line_id);
        OPEN c_discount_lines(l_om_line_id);
        LOOP
          FETCH c_discount_lines INTO l_discount_adjustment_id;
          EXIT WHEN c_discount_lines%NOTFOUND;
         --calculate discount amount
          SELECT rctl.revenue_amount + nvl(l_discount_amount, 0),
                 rctl.customer_trx_line_id
            INTO l_discount_amount, l_discount_cust_trx_line_id
            FROM ra_customer_trx_lines_all rctl
           WHERE rctl.customer_trx_id = l_ar_header_id
             AND rctl.line_type = 'LINE'
             AND rctl.interface_line_attribute11 =
                 l_discount_adjustment_id;
       -- fnd_file.PUT_LINE(fnd_file.LOG,'l_discount_amount IN CURSOR:'||l_discount_amount);
         --Calculate the discount tax amount
          SELECT tax.tax_amt_tax_curr + nvl(l_discount_tax_amount, 0)
            INTO l_discount_tax_amount
            FROM zx_lines tax
           WHERE tax.trx_line_id = l_discount_cust_trx_line_id
             AND tax.entity_code = 'TRANSACTIONS'
             AND application_id = 222
             AND tax.trx_level_type = 'LINE'
             AND tax.tax_currency_code = l_gt_currency_code
             AND tax.tax_type_code = l_tax_type_code
             AND tax.trx_id = l_ar_header_id;
       -- fnd_file.PUT_LINE(fnd_file.LOG,'l_discount_tax_amount IN CURSOR:'||l_discount_tax_amount);
            END LOOP;/*c_discount_lines*/
            CLOSE c_discount_lines;
     END IF;/*(l_interface_line_context='ORDER ENTRY' and l_price_adjustment_id=0)*/
    IF l_adjustment_type IS NULL OR l_adjustment_type <>'DIS'
    THEN
    l_ar_matching_line_flag:='';
    l_ar_tax_reg_number:='';
    l_ar_line_amount:=0;
    l_ar_vat_line_tax:=0;
    l_ar_vat_tax_rate:=0;

    --To summary the number of validated lines
    l_validated_lines:=l_validated_lines+1;
    l_gta_line_amount_sum:=0;
    l_gta_line_taxamount_sum:=0;
    l_gta_line_quantity_sum:=0;
    l_matched_flag_total:='Y';
    l_gta_trx_number_con:='';
    l_gt_invoice_number_con:='';
    l_gta_line_number_con:='';

    l_ar_loop_count:=l_ar_loop_count+1;

    --Yao Zhang add for bug#5604079
    IF l_conversion_rate IS NOT NULL
    THEN l_ar_unit_price:=round(l_ar_unit_price*l_conversion_rate,2);
    END IF;

    --log for debug
    IF( l_proc_level >= l_dbg_level)
    THEN

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_ar_loop_count '||l_ar_loop_count
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_ar_line_id '||l_ar_line_id
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_ar_line_number '||l_ar_line_number
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_ar_goods_description '||l_ar_goods_description
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_ar_quantity '||l_ar_quantity
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_ar_unit_price '||l_ar_unit_price
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_ar_uom '||l_ar_uom
                    );

   END IF;  --( l_proc_level >= l_dbg_level)

    --First check if current AR line have multiple tax lines per VAT tax
    --type and GT currency code defined on GTA 'system options' form,
    --if 'YES', then set NULL to tax registration number,taxable amount,
    --tax amount and tax rate, if 'No', then give exact values to tax
    --registration number, taxable amount,tax amount and tax rate.
    IF AR_GTA_TRX_UTIL.Check_Taxcount_Of_Arline
                          (p_org_id               => l_org_id
                          ,p_customer_trx_line_id => l_ar_line_id
                          )
    THEN
      --Third party tax registration number
      l_ar_tax_reg_number:=AR_GTA_TRX_UTIL.Get_Arline_Tp_Taxreg_Number
                                       (p_org_id               => l_org_id
                                       ,p_customer_trx_id      => l_ar_header_id
                                       ,p_customer_trx_line_id => l_ar_line_id
                                       );
      --taxable amount of AR line
      l_ar_line_amount:=AR_GTA_TRX_UTIL.Get_Arline_Amount
                                       (p_org_id                => l_org_id
                                       ,p_customer_trx_line_id  => l_ar_line_id
                                       )+ nvl(l_discount_amount,0);
      --tax amount of AR line
      l_ar_vat_line_tax:=AR_GTA_TRX_UTIL.Get_Arline_Vattax_Amount
                                       (p_org_id                => l_org_id
                                       ,p_customer_trx_line_id  => l_ar_line_id
                                       )+nvl(l_discount_tax_amount,0);
      --tax rate of AR line
      l_ar_vat_tax_rate:=AR_GTA_TRX_UTIL.Get_Arline_Vattax_Rate
                                       (p_org_id                => l_org_id
                                       ,p_customer_trx_line_id  => l_ar_line_id
                                       );

    ELSE
      l_ar_tax_reg_number:='';
      l_ar_line_amount:='';
      l_ar_vat_line_tax:='';
      l_ar_vat_tax_rate:='';
    END IF;  --AR_GTA_TRX_UTIL.Check_Taxcount_Of_Arline

    --log for debug
    IF( l_proc_level >= l_dbg_level)
    THEN

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_ar_tax_reg_number '||l_ar_tax_reg_number
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_ar_line_amount '||l_ar_line_amount
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_ar_vat_line_tax '||l_ar_vat_line_tax
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_ar_vat_tax_rate '||l_ar_vat_tax_rate
                    );




   END IF;  --( l_proc_level >= l_dbg_level)

   l_gta_loop_count:=0;

    OPEN c_gta_lines;
    LOOP
    FETCH c_gta_lines
     INTO l_gta_trx_number
         ,l_gta_tax_reg_number
         ,l_gta_line_number
         ,l_gta_goods_description
         ,l_gta_line_amount
         ,l_gta_vat_line_tax
         ,l_gta_vat_tax_rate
         ,l_gta_quantity
         ,l_gta_unit_price
         ,l_gta_uom
         ,l_matched_flag;
    EXIT WHEN c_gta_lines%NOTFOUND;
    l_gta_loop_count:=l_gta_loop_count+1;

    --log for debug
    IF( l_proc_level >= l_dbg_level)
    THEN

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_gta_loop_count '||l_gta_loop_count
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_gta_trx_number '||l_gta_trx_number
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_gta_tax_reg_number '||l_gta_tax_reg_number
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_gta_line_number '||l_gta_line_number
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_gta_vat_line_tax '||l_gta_vat_line_tax
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_gta_vat_tax_rate '||l_gta_vat_tax_rate
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_gta_quantity '||l_gta_quantity
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_gta_unit_price '||l_gta_unit_price
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_gta_uom '||l_gta_uom
                    );

      FND_LOG.String(l_proc_level
                    ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                    ,'l_matched_flag '||l_matched_flag
                    );





   END IF;  --( l_proc_level >= l_dbg_level)


      l_ar_matching_line_flag:='Y';

      --accumulate line amount, quantity, line tax amount for all gta invoice
      --line against an AR invoice line.
      --Yao modified for bug#8765631

      l_gta_line_amount_sum:=l_gta_line_amount_sum+l_gta_line_amount;
      l_gta_line_taxamount_sum:=l_gta_line_taxamount_sum+l_gta_vat_line_tax;
      l_gta_line_quantity_sum:=l_gta_line_quantity_sum+l_gta_quantity;

      --log for debug
      IF( l_proc_level >= l_dbg_level)
      THEN

        FND_LOG.String(l_proc_level
                      ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                      ,'l_gta_line_amount_sum '||l_gta_line_amount_sum
                      );

        FND_LOG.String(l_proc_level
                      ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                      ,'l_gta_line_taxamount_sum '||l_gta_line_taxamount_sum
                      );

        FND_LOG.String(l_proc_level
                      ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                      ,'l_gta_line_quantity_sum '||l_gta_line_quantity_sum
                      );


      END IF;    --( l_proc_level >= l_dbg_level)

      OPEN c_gt_invoice_number;
      FETCH c_gt_invoice_number INTO l_gt_invoice_number;
      CLOSE c_gt_invoice_number;

     --log for debug
      IF( l_proc_level >= l_dbg_level)
      THEN

        FND_LOG.String(l_proc_level
                      ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                      ,'l_gt_invoice_number '||l_gt_invoice_number
                      );
      END IF;    --( l_proc_level >= l_dbg_level)

      --To concate GTA Trx NUmber
      IF (l_gta_trx_number_con IS NULL)
      THEN
        l_gta_trx_number_con:=l_gta_trx_number;
      ELSIF (instr(l_gta_trx_number_con,l_gta_trx_number)=0)
      THEN
        l_gta_trx_number_con:=l_gta_trx_number_con||','||l_gta_trx_number;
      END IF;  --(l_gta_trx_number_con IS NULL)

      --log for debug
      IF( l_proc_level >= l_dbg_level)
      THEN

        FND_LOG.String(l_proc_level
                      ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                      ,'l_gta_trx_number_con '||l_gta_trx_number_con
                      );
      END IF;    --( l_proc_level >= l_dbg_level)

      --To concate GT invoice number
      IF (l_gt_invoice_number_con IS NULL)
      THEN
        l_gt_invoice_number_con:=l_gt_invoice_number;
      ELSIF (instr(l_gt_invoice_number_con,l_gt_invoice_number)=0)
      THEN
        l_gt_invoice_number_con:=l_gt_invoice_number_con||','||l_gt_invoice_number;
      END IF;  --(l_gt_invoice_number_con IS NULL)

      --log for debug
      IF( l_proc_level >= l_dbg_level)
      THEN

        FND_LOG.String(l_proc_level
                      ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                      ,'l_gt_invoice_number_con '||l_gt_invoice_number_con
                      );
      END IF;    --( l_proc_level >= l_dbg_level)

      --To concate GTA line number
      IF (l_gta_line_number_con IS NULL)
      THEN
        l_gta_line_number_con:=l_gta_line_number;
      ELSE
        l_gta_line_number_con:=l_gta_line_number_con||','||l_gta_line_number;
      END IF;  --(l_gta_line_number_con IS NULL)


      --log for debug
      IF( l_proc_level >= l_dbg_level)
      THEN

        FND_LOG.String(l_proc_level
                      ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                      ,'l_gta_line_number_con '||l_gta_line_number_con
                      );
      END IF;    --( l_proc_level >= l_dbg_level)

      IF l_matched_flag='N'
      THEN
        l_matched_flag_total:='N';
      END IF;  --l_matched_flag='N'



      --Compare third party tax registration number between AR line and GTA line
      IF (
          (l_ar_tax_reg_number<>l_gta_tax_reg_number) AND
          (l_ar_tax_reg_number IS NOT NULL)
         ) OR
         (l_ar_tax_reg_number IS NULL)
      THEN
        IF (l_matched_flag='Y')
        THEN
          l_gt_value:=l_gta_tax_reg_number;
        ELSE
          l_gt_invoice_number:='-';
         -- l_gt_value:=l_unmatched_attr;
        END IF;    --(l_matched_flag='Y')

        --insert discrepancy record into temp table ar_gta_difference_temp
        INSERT INTO ar_gta_difference_temp(TYPE
                                          ,ar_header_id
                                          ,ar_line_id
                                          ,ATTRIBUTE
                                          ,ar_line_num
                                          ,ar_value
                                          ,gta_invoice_num
                                          ,gta_line_num
                                          ,gta_value
                                          ,gt_invoice_num
                                          ,gt_value
                                          )
                                    VALUES('LINE'
                                          ,l_ar_header_id
                                          ,l_ar_line_id
                                          ,l_tax_reg_number_attr
                                          ,l_ar_line_number
                                          ,l_ar_tax_reg_number
                                          ,l_gta_trx_number
                                          ,l_gta_line_number
                                          ,l_gta_tax_reg_number
                                          ,l_gt_invoice_number
                                          ,l_gt_value
                                          );

        l_ar_matching_line_flag:='N';
        l_has_difference:=TRUE;

      --Add folllowing logic for fix the issue#4 in the bug 5263009
      --if tax registration number of line match with GTA's,
      --but GTA dosen't match GT, then ar line should be regarded as
      -- not maching.
      ELSE
        IF (l_matched_flag='N')
        THEN
          l_ar_matching_line_flag:='N';
          l_has_difference:=TRUE;
        END IF; -- (l_matched_flag='N')
      END IF; --((l_ar_tax_reg_number<>l_gta_tax_reg_number)......

      --compare goods descripiton between AR line and GTA line
      IF (l_ar_goods_description<>l_gta_goods_description)
      THEN
        IF (l_matched_flag='Y')
        THEN
          l_gt_value:=l_gta_goods_description;
        ELSE
          l_gt_invoice_number:='-';
          --l_gt_value:=l_unmatched_attr;
        END IF;    --(l_matched_flag='Y')

        --insert discrepancy record into temp table ar_gta_difference_temp
        INSERT INTO ar_gta_difference_temp(TYPE
                                          ,ar_header_id
                                          ,ar_line_id
                                          ,ATTRIBUTE
                                          ,ar_line_num
                                          ,ar_value
                                          ,gta_invoice_num
                                          ,gta_line_num
                                          ,gta_value
                                          ,gt_invoice_num
                                          ,gt_value
                                          )
                                    VALUES('LINE'
                                          ,l_ar_header_id
                                          ,l_ar_line_id
                                          ,l_goods_description_attr
                                          ,l_ar_line_number
                                          ,l_ar_goods_description
                                          ,l_gta_trx_number
                                          ,l_gta_line_number
                                          ,l_gta_goods_description
                                          ,l_gt_invoice_number
                                          ,l_gt_value
                                          );

        l_ar_matching_line_flag:='N';
        l_has_difference:=TRUE;

     --Add folllowing logic for fix the issue#4 in the bug 5263009
      --if goods descripiton of line match with GTA's,
      --but GTA dosen't match GT, then ar line should be regarded as
      -- not maching.
      ELSE
        IF (l_matched_flag='N')
        THEN
          l_ar_matching_line_flag:='N';
          l_has_difference:=TRUE;
        END IF; -- (l_matched_flag='N')
      END IF; --(l_ar_goods_description<>l_gta_goods_description)

      --compare VAT Tax Rate
      IF (l_ar_vat_tax_rate<>l_gta_vat_tax_rate)
      THEN
       IF (l_matched_flag='Y')
        THEN
          l_gt_value:=l_gta_vat_tax_rate;
        ELSE
          l_gt_invoice_number:='-';
         -- l_gt_value:=l_unmatched_attr;
        END IF;    --(l_matched_flag='Y')

        --insert discrepancy record into temp table ar_gta_difference_temp
        INSERT INTO ar_gta_difference_temp(TYPE
                                          ,ar_header_id
                                          ,ar_line_id
                                          ,ATTRIBUTE
                                          ,ar_line_num
                                          ,ar_value
                                          ,gta_invoice_num
                                          ,gta_line_num
                                          ,gta_value
                                          ,gt_invoice_num
                                          ,gt_value
                                          )
                                    VALUES('LINE'
                                          ,l_ar_header_id
                                          ,l_ar_line_id
                                          ,l_vat_tax_rate_attr
                                          ,l_ar_line_number
                                          ,l_ar_vat_tax_rate
                                          ,l_gta_trx_number
                                          ,l_gta_line_number
                                          ,l_gta_vat_tax_rate
                                          ,l_gt_invoice_number
                                          ,l_gt_value
                                          );
        l_ar_matching_line_flag:='N';
        l_has_difference:=TRUE;

     --Add folllowing logic for fix the issue#4 in the bug 5263009
      --if VAT Tax Rate of line match with GTA's,
      --but GTA dosen't match GT, then ar line should be regarded as
      -- not maching.
      ELSE
        IF (l_matched_flag='N')
        THEN
          l_ar_matching_line_flag:='N';
          l_has_difference:=TRUE;
        END IF; -- (l_matched_flag='N')
      END IF; --(l_ar_vat_tax_rate<>l_gta_vat_tax_rate)



      --Compare Unit Price
      IF (l_ar_unit_price<>l_gta_unit_price)
      THEN
       IF (l_matched_flag='Y')
        THEN
          l_gt_value:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id => p_org_id
                                                             ,p_amount => l_gta_unit_price
                                                             );
        ELSE
          l_gt_invoice_number:='-';
          --l_gt_value:=l_unmatched_attr;
        END IF;    --(l_matched_flag='Y')

        --Fomrat Amount
        l_ar_unit_price_disp:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id => p_org_id
                                                                     ,p_amount => l_ar_unit_price
                                                                     );
        l_gta_unit_price_disp:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id => p_org_id
                                                                      ,p_amount => l_gta_unit_price
                                                                      );

        --insert discrepancy record into temp table ar_gta_difference_temp
        INSERT INTO ar_gta_difference_temp(TYPE
                                          ,ar_header_id
                                          ,ar_line_id
                                          ,ATTRIBUTE
                                          ,ar_line_num
                                          ,ar_value
                                          ,gta_invoice_num
                                          ,gta_line_num
                                          ,gta_value
                                          ,gt_invoice_num
                                          ,gt_value
                                          )
                                    VALUES('LINE'
                                          ,l_ar_header_id
                                          ,l_ar_line_id
                                          ,l_unit_price_attr
                                          ,l_ar_line_number
                                          ,l_ar_unit_price_disp
                                          ,l_gta_trx_number
                                          ,l_gta_line_number
                                          ,l_gta_unit_price_disp
                                          ,l_gt_invoice_number
                                          ,l_gt_value
                                          );
        l_ar_matching_line_flag:='N';
        l_has_difference:=TRUE;
      --Add folllowing logic for fix the issue#4 in the bug 5263009
      --if Unit Price of line match with GTA's,
      --but GTA dosen't match GT, then ar line should be regarded as
      -- not maching.
      ELSE
        IF (l_matched_flag='N')
        THEN
          l_ar_matching_line_flag:='N';
          l_has_difference:=TRUE;
        END IF; -- (l_matched_flag='N')
      END IF; --(l_ar_unit_price<>l_gta_unit_price)

      --Compare UOM
      IF (l_ar_uom<>l_gta_uom)
      THEN
       IF (l_matched_flag='Y')
        THEN
          l_gt_value:=l_gta_uom;
        ELSE
          l_gt_invoice_number:='-';
         -- l_gt_value:=l_unmatched_attr;
        END IF;    --(l_matched_flag='Y')

        --insert discrepancy record into temp table ar_gta_difference_temp
        INSERT INTO ar_gta_difference_temp(TYPE
                                          ,ar_header_id
                                          ,ar_line_id
                                          ,ATTRIBUTE
                                          ,ar_line_num
                                          ,ar_value
                                          ,gta_invoice_num
                                          ,gta_line_num
                                          ,gta_value
                                          ,gt_invoice_num
                                          ,gt_value
                                          )
                                    VALUES('LINE'
                                          ,l_ar_header_id
                                          ,l_ar_line_id
                                          ,l_uom_attr
                                          ,l_ar_line_number
                                          ,l_ar_uom
                                          ,l_gta_trx_number
                                          ,l_gta_line_number
                                          ,l_gta_uom
                                          ,l_gt_invoice_number
                                          ,l_gt_value
                                          );

        l_ar_matching_line_flag:='N';
        l_has_difference:=TRUE;

      --Add folllowing logic for fix the issue#4 in the bug 5263009
      --if UOM of line match with GTA's,
      --but GTA dosen't match GT, then ar line should be regarded as
      -- not maching.
      ELSE
        IF (l_matched_flag='N')
        THEN
          l_ar_matching_line_flag:='N';
          l_has_difference:=TRUE;
        END IF; -- (l_matched_flag='N')
      END IF; --(l_ar_uom<>l_gta_uom)
      END LOOP;--c_gta_lines%FOUND
      CLOSE c_gta_lines;

      --compare quantity
      IF (l_ar_quantity<>l_gta_line_quantity_sum) AND
         (l_gta_trx_number_con IS NOT NULL)  --To validate that current AR line
                                             -- was already transferred to GTA
      THEN

        IF (l_matched_flag_total='Y')
        THEN
          l_gt_invoice_number:=l_gt_invoice_number_con;
          l_gt_value:=l_gta_line_quantity_sum;

        ELSE
          l_gt_invoice_number:='-';
         -- l_gt_value:=l_unmatched_attr;
        END IF;  --(l_matched_flag_sum='Y')


         --insert discrepancy record into temp table ar_gta_difference_temp
        INSERT INTO ar_gta_difference_temp(TYPE
                                          ,ar_header_id
                                          ,ar_line_id
                                          ,ATTRIBUTE
                                          ,ar_line_num
                                          ,ar_value
                                          ,gta_invoice_num
                                          ,gta_line_num
                                          ,gta_value
                                          ,gt_invoice_num
                                          ,gt_value
                                          )
                                    VALUES('LINE'
                                          ,l_ar_header_id
                                          ,l_ar_line_id
                                          ,l_quantity_attr
                                          ,l_ar_line_number
                                          ,l_ar_quantity
                                          ,l_gta_trx_number_con
                                          ,l_gta_line_number_con
                                          ,l_gta_line_quantity_sum
                                          ,l_gt_invoice_number
                                          ,l_gt_value
                                          );
        l_ar_matching_line_flag:='N';
        l_has_difference:=TRUE;

      --Add folllowing logic for fix the issue#4 in the bug 5263009
      --if quantity of ar line match with GTA's,
      --but GTA dosen't match GT, then ar line should be regarded as
      -- not maching.
      ELSE
        IF (l_matched_flag_total='N')
        THEN
          l_ar_matching_line_flag:='N';
          l_has_difference:=TRUE;
        END IF; -- (l_matched_flag_total='N')

      END IF; --(l_ar_quantity<>l_gta_line_quantity_sum)

      --compare Line Amount
      --Yao modified for bug#8765631
      --fnd_file.PUT_LINE(fnd_file.LOG,'l_ar_line_amount'||nvl(l_ar_line_amount,0));
      --fnd_file.PUT_LINE(fnd_file.LOG,'l_gta_line_amount_sum'||nvl(l_gta_line_amount_sum,0));
      IF (nvl(l_ar_line_amount,0)<>nvl(l_gta_line_amount_sum,0)) AND
         (l_gta_trx_number_con IS NOT NULL)  --To validate that current
                                             --AR line was already transferred
                                             -- to GTA
      THEN
        IF (l_matched_flag_total='Y')
        THEN
          l_gt_invoice_number:=l_gt_invoice_number_con;
          l_gt_value:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id => p_org_id
                                                             ,p_amount => l_gta_line_amount_sum
                                                             );

        ELSE
          l_gt_invoice_number:='-';
         -- l_gt_value:=l_unmatched_attr;
        END IF;  --(l_matched_flag_sum='Y')

        --Format Amount
        l_ar_line_amount_disp:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id => p_org_id
                                                                      ,p_amount => l_ar_line_amount
                                                                      );
        l_gta_line_amount_sum_disp:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id => p_org_id
                                                                           ,p_amount => l_gta_line_amount_sum
                                                                           );

        --insert discrepancy record into temp table ar_gta_difference_temp
        INSERT INTO ar_gta_difference_temp(TYPE
                                          ,ar_header_id
                                          ,ar_line_id
                                          ,ATTRIBUTE
                                          ,ar_line_num
                                          ,ar_value
                                          ,gta_invoice_num
                                          ,gta_line_num
                                          ,gta_value
                                          ,gt_invoice_num
                                          ,gt_value
                                          )
                                    VALUES('LINE'
                                          ,l_ar_header_id
                                          ,l_ar_line_id
                                          ,l_line_amount_attr
                                          ,l_ar_line_number
                                          ,l_ar_line_amount_disp
                                          ,l_gta_trx_number_con
                                          ,l_gta_line_number_con
                                          ,l_gta_line_amount_sum_disp
                                          ,l_gt_invoice_number
                                          ,l_gt_value
                                          );
        l_ar_matching_line_flag:='N';
        l_has_difference:=TRUE;

      --Add folllowing logic for fix the issue#4 in the bug 5263009
      --if amount of AR line match with GTA's,
      --but GTA dosen't match GT, then ar line should be regarded as
      -- not maching.
      ELSE
        IF (l_matched_flag_total='N')
        THEN
          l_ar_matching_line_flag:='N';
          l_has_difference:=TRUE;
        END IF; -- (l_matched_flag_total='N')
      END IF; --(l_ar_line_amount<>l_gta_line_amount_sum)

      --compare VAT Line Tax
      --Yao modified for bug#8765631
      IF (nvl(l_ar_vat_line_tax,0)<>nvl(l_gta_line_taxamount_sum,0)) AND
         (l_gta_trx_number_con IS NOT NULL)  --To validate that current AR
                                             --line was already transferred
                                             --to GTA
      THEN
        IF (l_matched_flag_total='Y')
        THEN
          l_gt_invoice_number:=l_gt_invoice_number_con;
          l_gt_value:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id => p_org_id
                                                             ,p_amount => l_gta_line_taxamount_sum
                                                             );

        ELSE
          l_gt_invoice_number:='-';
          --l_gt_value:=l_unmatched_attr;
        END IF;  --(l_matched_flag_sum='Y')

        --Format Amount
        l_ar_vat_line_tax_disp:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id => p_org_id
                                                                       ,p_amount => l_ar_vat_line_tax
                                                                       );
        l_gta_line_taxamount_sum_disp:=AR_GTA_TRX_UTIL.Format_Monetary_Amount(p_org_id => p_org_id
                                                                              ,p_amount => l_gta_line_taxamount_sum
                                                                              );

        --insert discrepancy record into temp table ar_gta_difference_temp
        INSERT INTO ar_gta_difference_temp(TYPE
                                          ,ar_header_id
                                          ,ar_line_id
                                          ,ATTRIBUTE
                                          ,ar_line_num
                                          ,ar_value
                                          ,gta_invoice_num
                                          ,gta_line_num
                                          ,gta_value
                                          ,gt_invoice_num
                                          ,gt_value
                                          )
                                    VALUES('LINE'
                                          ,l_ar_header_id
                                          ,l_ar_line_id
                                          ,l_vat_line_tax_attr
                                          ,l_ar_line_number
                                          ,l_ar_vat_line_tax_disp
                                          ,l_gta_trx_number_con
                                          ,l_gta_line_number_con
                                          ,l_gta_line_taxamount_sum_disp
                                          ,l_gt_invoice_number
                                          ,l_gt_value
                                          );
        l_ar_matching_line_flag:='N';
        l_has_difference:=TRUE;

      --Add folllowing logic for fix the issue#4 in the bug 5263009
      --if VAT Line Tax of AR line match with GTA's,
      --but GTA dosen't match GT, then ar line should be regarded as
      -- not maching.
      ELSE
        IF (l_matched_flag_total='N')
        THEN
          l_ar_matching_line_flag:='N';
          l_has_difference:=TRUE;
        END IF; -- (l_matched_flag_total='N')
      END IF; --(l_ar_vat_line_tax<>l_line_gta_taxamount_sum)

      --To summary ar lines that have matching data with GTA nad GT
      IF l_ar_matching_line_flag='Y'
      THEN
        l_ar_matching_lines:=l_ar_matching_lines+1;
      END IF;  --l_ar_matching_line_flag:='Y'

      --To judge if this ar line is partially imported
      OPEN c_gta_lines_not_enabled;
      FETCH c_gta_lines_not_enabled INTO l_gta_lines_not_enabled_count;
      CLOSE c_gta_lines_not_enabled;


      IF l_gta_lines_not_enabled_count>0
      THEN
        l_ar_partially_import:=l_ar_partially_import+1;
      END IF;  --l_gta_lines_not_enabled_count>0
      --yao add for bug#8809860
      END IF;--IF l_adjustment_type is null or l_adjustment_type <>'dis'
   END LOOP;
   CLOSE c_ar_lines;

   --To deal with missing ar line if any
   OPEN c_missing_ar_line;
   FETCH c_missing_ar_line INTO l_gta_trx_number,l_gta_line_number;
   WHILE c_missing_ar_line%FOUND
   LOOP

     --log for debug
     IF( l_proc_level >= l_dbg_level)
     THEN

       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.phase'
                     ,'c_missing_ar_line'
                     );
     END IF;    --( l_proc_level >= l_dbg_level)


     OPEN c_gt_invoice_number;
     FETCH c_gt_invoice_number INTO l_gt_invoice_number;
     CLOSE c_gt_invoice_number;

     --To Insert GTA trx number and GT invoice number that missed ar line to
     -- temp table ar_gta_difference_temp
     INSERT INTO ar_gta_difference_temp(TYPE
                                       ,ar_header_id
                                       ,ar_line_num
                                       ,gta_invoice_num
                                       ,gta_line_num
                                       ,gt_invoice_num
                                       )
                                  VALUES('MISSING_AR_LINE'
                                       ,l_ar_header_id
                                       ,l_no_value
                                       ,l_gta_trx_number
                                       ,l_gta_line_number
                                       ,l_gt_invoice_number
                                       );
     l_has_difference:=TRUE;
     FETCH c_missing_ar_line INTO l_gta_trx_number,l_gta_line_number;


   END LOOP;  --c_missing_ar_line%FOUND

   CLOSE c_missing_ar_line;

   --Add the following logic for fixing issue #2 in the bug 5381833
   --Any AR line that have VAT tax lines and were added after current
   --AR transaction was transferred to GTA should be listed in the
   --section "Missing AR Line" as well.
   FOR l_not_transferred_ar_line IN c_not_transferred_ar_lines
   LOOP
     --log for debug
     IF( l_proc_level >= l_dbg_level)
     THEN

       FND_LOG.String(l_proc_level
                     ,G_MODULE_PREFIX||'.'||l_api_name||'.phase'
                     ,'c_not_transferred_ar_lines'
                     );
     END IF;    --( l_proc_level >= l_dbg_level)

     INSERT INTO ar_gta_difference_temp(TYPE
                                       ,ar_header_id
                                       ,ar_line_id
                                       ,ar_line_num
                                       ,gta_invoice_num
                                       ,gta_line_num
                                       ,gt_invoice_num
                                       )
                                  VALUES('MISSING_AR_LINE'
                                       ,l_ar_header_id
                                       ,l_not_transferred_ar_line.ar_line_id
                                       ,l_not_transferred_ar_line.ar_line_num
                                       ,l_no_value
                                       ,l_no_value
                                       ,l_no_value
                                       );
     l_has_difference:=TRUE;
   END LOOP;  --l_not_transferred_ar_line IN c_not_transferred_ar_lines

   --Give values to output parameters
   x_validated_lines:=l_validated_lines;
   x_ar_matching_lines:=l_ar_matching_lines;
   x_ar_partially_import:=l_ar_partially_import;
   x_has_difference:=l_has_difference;

  --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.returned_value'
                  ,'x_validated_lines '||l_validated_lines
                  );

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.returned_value'
                  ,'x_ar_matching_lines '||l_ar_matching_lines
                  );

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.returned_value'
                  ,'x_ar_partially_import '||l_ar_partially_import
                  );

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.end'
                  ,'Exit procedure'
                  );




  END IF;  --( l_proc_level >= l_dbg_level)

EXCEPTION
  WHEN OTHERS THEN
    IF(l_proc_level >= l_dbg_level)
    THEN
      l_error_msg:=SQLCODE||':'||SQLERRM;
      FND_LOG.String( l_proc_level
                    , G_Module_Prefix || l_api_name || '. Other_Exception '
                    , l_error_msg);


    END IF;  --(l_proc_level >= l_dbg_level)
    RAISE;
END Compare_Lines;


--==========================================================================
--  PROCEDURE NAME:
--
--      Get_Unmatched_Lines                Public
--
--  DESCRIPTION:
--
--      This Procedure Get Gta, Gt Unmatched Lines And Input Difference Record
--
--
--  PARAMETERS:
--      In:   p_org_id                 Operating unit id
--            p_ar_header_id           AR Transaction id
--
--     Out:   x_has_difference
--
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           05/17/05   	Donghai  Wang        Created.
--           11/25/05     Donghai  Wang        modify code to follow ebtax
--                                             requirement
--           03/04/05     Donghai  Wang        Add FND Log
--           07/21/06     Donghai  Wang        Fix bug 5193632
--           10-Aug-2009  Yao Zhang       Modified for bug# 8765631
--==========================================================================
PROCEDURE Get_Unmatched_Lines
( p_org_id	        IN	   NUMBER
, p_ar_header_id	IN	   NUMBER
, x_has_difference	OUT NOCOPY BOOLEAN
)
IS

l_org_id            hr_all_organization_units.organization_id%TYPE
                    :=p_org_id;
l_ar_header_id      ra_customer_trx_all.customer_trx_id%TYPE
                    :=p_ar_header_id;
l_has_difference    BOOLEAN;
l_api_name          VARCHAR2(50)
                    :='Get_Unmatched_Lines';
l_dbg_msg           VARCHAR2(100);

--Add following variables for fixing the bug 5193632
l_source_gta        VARCHAR2(100);
l_source_gt         VARCHAR2(100);
----------------------------------------------------

CURSOR c_gta_unmatched_line IS
SELECT
  gta_header.gta_trx_number
 ,gta_header.tp_tax_registration_number
 ,gta_line.line_number
 ,gta_line.item_description
 ,gta_line.item_model
 ,gta_line.unit_price
 ,gta_line.quantity
 ,gta_line.uom_name
 ,gta_line.amount
 ,gta_line.tax_amount
 ,gta_line.tax_rate
FROM
  ar_gta_trx_headers gta_header
 ,ar_gta_trx_lines   gta_line
WHERE gta_header.ra_trx_id=l_ar_header_id
  AND gta_header.source='AR'
  AND gta_header.status='COMPLETED'
  AND gta_header.latest_version_flag='Y'
  AND gta_line.gta_trx_header_id=gta_header.gta_trx_header_id
  AND gta_line.enabled_flag='Y'
  AND gta_line.matched_flag='N';

l_gta_unmatched_line c_gta_unmatched_line%ROWTYPE;


CURSOR c_gt_unmatched_line IS
SELECT
  gt_header.gt_invoice_number
 ,gt_header.tp_tax_registration_number
 ,gt_line.line_number
 ,gt_line.item_description
 ,gt_line.item_model
 ,gt_line.unit_price
 ,gt_line.quantity
 ,gt_line.uom_name
 ,gt_line.amount
 ,gt_line.tax_amount
 ,gt_line.tax_rate
FROM
  ar_gta_trx_headers gt_header
 ,ar_gta_trx_lines   gt_line
WHERE gt_header.ra_trx_id=l_ar_header_id
  AND gt_header.source='GT'
  AND gt_line.gta_trx_header_id=gt_header.gta_trx_header_id
  AND gt_line.matched_flag='N'
  --Yao Zhang add for bug#8765631
  AND gt_line.discount_flag='0';

l_gt_unmatched_line c_gt_unmatched_line%ROWTYPE;
l_dbg_level         NUMBER         :=FND_LOG.G_Current_Runtime_Level;
l_proc_level        NUMBER         :=FND_LOG.Level_Procedure;

BEGIN

--log for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.begin'
                  ,'Enter procedure'
                  );
  END IF;  --(l_proc_level >= l_dbg_level)

--log for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_org_id '||p_org_id
                  );

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_header_id '||p_ar_header_id
                  );
  END IF;  --(l_proc_level >= l_dbg_level)

  --Fix the bug 5193632 to get translated source name
  --Of Golden Tax Adaptor and Golden Tax System
  FND_MESSAGE.Set_Name('AR','AR_GTA_SOURCE_GTA');
  l_source_gta:=FND_MESSAGE.Get;

  FND_MESSAGE.Set_Name('AR','AR_GTA_SOURCE_GT');
  l_source_gt:=FND_MESSAGE.Get;



  OPEN c_gta_unmatched_line;
  FETCH c_gta_unmatched_line INTO l_gta_unmatched_line;

  WHILE c_gta_unmatched_line%FOUND
  LOOP

    --INSERT unmatched GTA lines belong to current AR to temp
    --table ar_gta_unmatched_temp
    INSERT INTO ar_gta_unmatched_temp(source
                                     ,ar_header_id
                                     ,invoice_number
                                     ,tp_tax_registration_number
                                     ,line_number
                                     ,item_name
                                     ,model
                                     ,unit_price
                                     ,quantity
                                     ,uom
                                     ,line_amount
                                     ,tax_rate
                                     ,vat_line_tax
                                     )
                               VALUES(l_source_gta
                                     ,l_ar_header_id
                                     ,l_gta_unmatched_line.gta_trx_number
                                     ,l_gta_unmatched_line.tp_tax_registration_number
                                     ,l_gta_unmatched_line.line_number
                                     ,l_gta_unmatched_line.item_description
                                     ,l_gta_unmatched_line.item_model
                                     ,l_gta_unmatched_line.unit_price
                                     ,l_gta_unmatched_line.quantity
                                     ,l_gta_unmatched_line.uom_name
                                     ,l_gta_unmatched_line.amount
                                     ,l_gta_unmatched_line.tax_rate
                                     ,l_gta_unmatched_line.tax_amount
                                     );
    l_has_difference:=TRUE;
    FETCH c_gta_unmatched_line INTO l_gta_unmatched_line;
  END LOOP;  --c_gta_unmatched_line%FOUND

  CLOSE c_gta_unmatched_line;

  OPEN c_gt_unmatched_line;
  FETCH c_gt_unmatched_line INTO l_gt_unmatched_line;

  WHILE c_gt_unmatched_line%FOUND
  LOOP

    --INSERT unmatched GT lines belong to current AR to temp
    --table ar_gta_unmatched_temp
    INSERT INTO ar_gta_unmatched_temp(source
                                     ,ar_header_id
                                     ,invoice_number
                                     ,tp_tax_registration_number
                                     ,line_number
                                     ,item_name
                                     ,model
                                     ,unit_price
                                     ,quantity
                                     ,uom
                                     ,line_amount
                                     ,tax_rate
                                     ,vat_line_tax
                                     )
                               VALUES(l_source_gt
                                     ,l_ar_header_id
                                     ,l_gt_unmatched_line.gt_invoice_number
                                     ,l_gt_unmatched_line.tp_tax_registration_number
                                     ,l_gt_unmatched_line.line_number
                                     ,l_gt_unmatched_line.item_description
                                     ,l_gt_unmatched_line.item_model
                                     ,l_gt_unmatched_line.unit_price
                                     ,l_gt_unmatched_line.quantity
                                     ,l_gt_unmatched_line.uom_name
                                     ,l_gt_unmatched_line.amount
                                     ,l_gt_unmatched_line.tax_rate
                                     ,l_gt_unmatched_line.tax_amount
                                     );
    l_has_difference:=TRUE;
    FETCH c_gt_unmatched_line INTO l_gt_unmatched_line;
  END LOOP;  --c_gt_unmatched_line%FOUND

  CLOSE c_gt_unmatched_line;

  x_has_difference:=l_has_difference;


--log for debug
  IF ( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.end'
                  ,'Exit procedure'
                  );
  END IF;  --( l_proc_level >= l_dbg_level )

EXCEPTION
  WHEN OTHERS THEN
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                    , G_Module_Prefix || l_api_name || '. Other_Exception '
                    , SQLCODE||':'||SQLERRM);
    END IF;  --(l_proc_level >= l_dbg_level)
    RAISE;
END Get_Unmatched_Lines;


--==========================================================================
--  PROCEDURE NAME:
--
--      Generate_Discrepancy_Xml               Public
--
--  DESCRIPTION:
--
--       This Procedure is used to generate XML element content
--       for disrcepancy report output
--
--
--  PARAMETERS:
--     In:  p_org_id                     Operating unit id
--          p_gta_batch_num_from         GTA batch number low range
--          p_gta_batch_num_to           GTA batch number high range
--          p_ar_transaction_type        AR transaction type
--          p_cust_num_from              Customer Number low range
--          p_cust_num_to                Customer Number high range
--          p_cust_name_from             Customer Name low range
--          p_cust_name_to               Customer Name high range
--          p_gl_period                  GL period name
--          p_gl_date_from               GL period date low range
--          p_gl_date_to                 GL period date high range
--          p_ar_trx_batch_from          AR Transaction name low range
--          p_ar_trx_batch_to            AR Transaction name high range
--          p_ar_trx_num_from            AR Transaction number low range
--          p_ar_trx_num_to              AR Transaction number high range
--          p_ar_trx_date_from           AR Transaction date low range
--          p_ar_trx_date_to             AR Transaction date high range
--          p_ar_doc_num_from            AR transaction document
--                                       sequence low range
--          p_ar_doc_num_to              AR transaction document sequence high
--                                       range
--          p_original_curr_code         Currency code on AR transaction
--          p_primary_sales              Primary salesperson
--          p_validated_lines_total      the number of ar lines that have been
--                                       validated by the report
--          p_ar_matching_lines_total    the number of ar lines that exactly
--                                       match with GTA invoice
--                                       and GT invoice
--          p_ar_partially_import_total  ar lines are not fully imported to GT
--
--    Out:  x_output
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           05/17/05   	Donghai  Wang        Created.
--           11/25/05     Donghai  Wang        modify code to follow ebtax
--                                             requirement
--           03/04/05     Donghai  Wang        Add FND Log
--           06/28/06     Donghai  Wang        Fix the bug 5263009
--           07/21/06     Donghai  Wang        Fix the bug 5381833
--           09/14/06     Donghai  Wang        format output date to XSD date
--                                             format to fix the bug 5521629
--           10-Aug-2009  Yao Zhang    Modified for bug 8765631
--==========================================================================
PROCEDURE Generate_Discrepancy_Xml
( p_org_id	                  IN	NUMBER
, p_gta_batch_num_from	          IN	VARCHAR2
, p_gta_batch_num_to              IN	VARCHAR2
, p_ar_transaction_type	          IN	NUMBER
, p_cust_num_from	          IN	VARCHAR2
, p_cust_num_to	                  IN	VARCHAR2
, p_cust_name_id	          IN	NUMBER
, p_gl_period	                  IN	VARCHAR2
, p_gl_date_from	          IN	DATE
, p_gl_date_to	                  IN	DATE
, p_ar_trx_batch_from	          IN	VARCHAR2
, p_ar_trx_batch_to	          IN	VARCHAR2
, p_ar_trx_num_from	          IN	VARCHAR2
, p_ar_trx_num_to	          IN	VARCHAR2
, p_ar_trx_date_from	          IN	DATE
, p_ar_trx_date_to	          IN	DATE
, p_ar_doc_num_from	          IN	VARCHAR2
, p_ar_doc_num_to	          IN	VARCHAR2
, p_original_curr_code	          IN	VARCHAR2
, p_primary_sales	          IN	NUMBER
, p_validated_lines_total         IN    NUMBER
, p_ar_matching_lines_total       IN    NUMBER
, p_ar_partially_import_total     IN    NUMBER
, x_output                        OUT   NOCOPY XMLTYPE
)
IS
l_operating_unit            hr_operating_units.name%TYPE;
l_customer_name             hz_parties.party_name%TYPE;
l_primary_sales_name        ra_salesreps_all.name%TYPE;
l_customer_id               hz_cust_accounts.cust_account_id%TYPE
                            :=p_cust_name_id;
l_ar_header_id              ra_customer_trx_all.customer_trx_id%TYPE;
l_gta_batch_num_from        ar_gta_trx_headers_all.gta_batch_number%TYPE
                            :=p_gta_batch_num_from;
l_gta_batch_num_to          ar_gta_trx_headers_all.gta_batch_number%TYPE
                            :=p_gta_batch_num_to;
l_ar_transaction_type       ra_cust_trx_types_all.name%TYPE;
l_cust_num_from             hz_cust_accounts.account_number%TYPE
                            :=p_cust_num_from;
l_cust_num_to               hz_cust_accounts.account_number%TYPE
                            :=p_cust_num_to;
l_gl_period                 gl_periods.period_name%TYPE
                            :=p_gl_period;
l_ar_trx_batch_from         ra_batches_all.name%TYPE
                            :=p_ar_trx_batch_from;
l_ar_trx_batch_to           ra_batches_all.name%TYPE
                            :=p_ar_trx_batch_to;
l_ar_trx_num_from           ra_customer_trx_all.trx_number%TYPE
                            :=p_ar_trx_num_from;
l_ar_trx_num_to             ra_customer_trx_all.trx_number%TYPE
                            :=p_ar_trx_num_to;
l_ar_doc_num_from           VARCHAR2(15)
                            :=p_ar_doc_num_from;
l_ar_doc_num_to             VARCHAR2(15)
                            :=p_ar_doc_num_to;
l_original_curr_code        fnd_currencies.currency_code%TYPE
                            :=p_original_curr_code;
l_gl_date_from_f            VARCHAR2(50);
l_gl_date_to_f              VARCHAR2(50);
l_ar_trx_date_from_f        VARCHAR2(50);
l_ar_trx_date_to_f          VARCHAR2(50);
l_report_date               VARCHAR2(50);
l_ar_diff_count             NUMBER;
l_missing_artrx_count       NUMBER;
l_dbg_msg                   VARCHAR2(100);
l_no_data_found_msg         VARCHAR2(500);
l_validated_lines_total     NUMBER
                            :=p_validated_lines_total;
l_ar_matching_lines_total   NUMBER
                            :=p_ar_matching_lines_total;
l_ar_partially_import_total NUMBER
                            :=p_ar_partially_import_total;
l_ar_line_notmatching_total NUMBER;
l_ar_missingtrx_total       NUMBER;
l_parameter_xml             XMLTYPE;
l_summary_xml               XMLTYPE;
l_report_xml                XMLTYPE;
l_ar_trx_header_id          ra_customer_trx_all.customer_trx_id%TYPE;
l_gta_header_xml_tmp        XMLTYPE;
l_gta_header_xml            XMLTYPE;
l_gta_line_xml_tmp          XMLTYPE;
l_gta_line_xml              XMLTYPE;
l_missing_line_xml_tmp      XMLTYPE;
l_missing_line_xml          XMLTYPE;
l_unmatched_line_xml_tmp    XMLTYPE;
l_unmatched_line_xml        XMLTYPE;
l_xml_null                  XMLTYPE;
l_ar_invoice_xml            XMLTYPE;
l_ar_invoice_xml_tmp        XMLTYPE;
l_missing_artrx_xml_tmp     XMLTYPE;
l_missing_artrx_xml         XMLTYPE;
l_base_currency             ar_gta_system_parameters_all.gt_currency_code%TYPE;

l_api_name                  VARCHAR2(50)
                            :='Generate_Discrepancy_Xml';
l_error_msg                 VARCHAR2(4000);
l_no_char                   VARCHAR2(1)
                            :='N';
l_ar_trx_date               VARCHAR2(50);
--Yao Zhang add for bug#8765631
l_consolidate_count         NUMBER;
l_description               VARCHAR2(1000);
--Yao Zhang add end


CURSOR c_operating_unit IS
SELECT
  otl.name
FROM
  hr_all_organization_units    o
 ,hr_all_organization_units_tl otl
 WHERE o.organization_id = otl.organization_id
   AND otl.language = userenv('LANG')
   AND o.organization_id = p_org_id;

CURSOR c_ar_transaction_type IS
SELECT
  name
FROM
  ra_cust_trx_types_all
WHERE cust_trx_type_id=p_ar_transaction_type;

CURSOR c_customer_name IS
SELECT
  hp.party_name
FROM
  hz_cust_accounts hca
 ,hz_parties       hp
WHERE hca.cust_account_id=l_customer_id
  AND hp.party_id=hca.party_id;

CURSOR c_primary_salesrep_name IS
SELECT
  name
FROM
  ra_salesreps_all
WHERE salesrep_id=p_primary_sales;


CURSOR c_ar_diff_count IS
SELECT
  count(*)
FROM
  ar_gta_ar_difference_temp;

CURSOR c_missing_artrx_count IS
SELECT
  COUNT(*)
FROM
  ar_gta_missing_artrx_temp;


CURSOR c_ar_difference IS
SELECT
  adt.customer_trx_id
 ,adt.trx_number
 ,adt.trx_date
 ,adt.customer_name
 ,adt.invoice_currency_code
FROM
  ar_gta_ar_difference_temp adt;

l_ar_difference              c_ar_difference%ROWTYPE;

/*Comment this part out for fix the bug 5263009
CURSOR c_ar_line_notmatching IS
SELECT
  COUNT(DISTINCT ar_line_id)
FROM
  ar_gta_difference_temp
WHERE TYPE='LINE';
*/

CURSOR c_gta_header_xml IS
SELECT XMLELEMENT("Difference"
                  ,XMLFOREST(attribute              AS "ARAttribute"
                            ,ar_value               AS "ARValue"
                            ,gta_invoice_num        AS "GTAInvoiceNum"
                            ,gta_value              AS "GTAValue"
                            ,gt_invoice_num         AS "GT_InvoiceNum"
                            ,gt_value               AS "GT_Value"
                            ,discrepancy            AS "Discrepancy"
                            )
                 )
FROM
  ar_gta_difference_temp
WHERE ar_header_id=l_ar_header_id
  AND type='HEADER';



CURSOR c_gta_line_xml IS
SELECT
  XMLELEMENT("Difference"
            ,XMLFOREST(attribute        AS "ARAttribute"
                      ,ar_line_num      AS "ARLineNum"
                      ,ar_value         AS "ARValue"
                      ,gta_invoice_num  AS "GTAInvoiceNum"
                      ,gta_line_num     AS "GTALineNum"
                      ,gta_value        AS "GTAValue"
                      ,gt_invoice_num   AS "GT_InvoiceNum"
                      ,gt_line_num      AS "GT_LineNum"
                      ,gt_value         AS "GT_Value"
                      )
            )
FROM
  ar_gta_difference_temp
WHERE ar_header_id=l_ar_header_id
  AND type='LINE';

--Update the cursor for fixing the bug 5381833
--Add the the column "ar_line_num     AS "ARLineNum""
--in the XMLFOREST function
CURSOR c_missing_line_xml IS
SELECT
  XMLELEMENT("Difference"
            ,XMLFOREST(ar_line_num     AS "ARLineNum"
                      ,gta_invoice_num AS "GTAInvoiceNum"
                      ,gta_line_num    AS "GTALineNum"
                      ,gt_invoice_num  AS "GT_InvoiceNum"
                      )
            )
FROM
  ar_gta_difference_temp
WHERE ar_header_id=l_ar_header_id
  AND TYPE='MISSING_AR_LINE';

CURSOR c_unmatched_line_xml IS
SELECT
  XMLELEMENT("Line"
            ,XMLFOREST(source                       AS "Source"
                      ,invoice_number               AS "InvoiceNum"
                      ,tp_tax_registration_number   AS "TaxRegNum"
                      ,line_number                  AS "LineNum"
                      ,item_name                    AS "ItemName"
                      ,model                        AS "Model"
                      ,unit_price                   AS "UnitPrice"
                      ,quantity                     AS "Quantity"
                      ,uom                          AS "UOM"
                      ,line_amount                  AS "LineAmount"
                      ,tax_rate                     AS "TaxRate"
                      ,vat_line_tax                 AS "VatLineTax"
                      )
           )

FROM
  ar_gta_unmatched_temp
WHERE ar_header_id=l_ar_header_id
  ORDER BY source DESC;

CURSOR c_missing_artrx_xml IS
SELECT
  XMLELEMENT("Invoice"
            ,XMLFOREST(record_number     AS "InvoiceNumber"
                      ,ar_trx_number     AS "OriginalARTrxNum"
                      ,gta_trx_number    AS "GTAInvoiceNumber"
                      ,gt_invoice_number AS "GT_InvoiceNum"
                      ,gt_invoice_amount AS "GT_InvoiceAmount"
                      )
            )
FROM
  ar_gta_missing_artrx_temp;

CURSOR c_base_currency IS
SELECT
  gt_currency_code
FROM
  ar_gta_system_parameters_all
WHERE
  org_id=p_org_id;


l_dbg_level                       NUMBER        :=FND_LOG.G_Current_Runtime_Level;
l_proc_level                      NUMBER        :=FND_LOG.Level_Procedure;


BEGIN

--log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.begin'
                  ,'Enter procedure');
  END IF;  --( l_proc_level >= l_dbg_level)


--log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_org_id '||p_org_id);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_gta_batch_num_from '||p_gta_batch_num_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_gta_batch_num_to '||p_gta_batch_num_to);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_transaction_type '||p_ar_transaction_type);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_cust_num_from	 '||p_cust_num_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_cust_num_to	 '||p_cust_num_to);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_cust_name_id	 '||p_cust_name_id);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_gl_period	 '||p_gl_period);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_gl_date_from	 '||p_gl_date_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_gl_date_to	 '||p_gl_date_to);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_trx_batch_from	 '||p_ar_trx_batch_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_trx_batch_to	 '||p_ar_trx_batch_to);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_trx_num_from	 '||p_ar_trx_num_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_trx_num_to	 '||p_ar_trx_num_to);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_trx_date_from	 '||p_ar_trx_date_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_trx_date_to	 '||p_ar_trx_date_to);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_doc_num_from	 '||p_ar_doc_num_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_doc_num_to	 '||p_ar_doc_num_to);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_original_curr_code	 '||p_original_curr_code);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_primary_sales	 '||p_primary_sales);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_validated_lines_total	 '||p_validated_lines_total);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_matching_lines_total	 '||p_ar_matching_lines_total);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_partially_import_total	 '
                  ||p_ar_partially_import_total
                  );
  END IF;  --( l_proc_level >= l_dbg_level)


  --
  --prepare parameter
  --

  --Get Operating Unit Name
  OPEN c_operating_unit;
  FETCH c_operating_unit INTO l_operating_unit;
  CLOSE c_operating_unit;

  --Get Custome Name
  OPEN c_customer_name;
  FETCH c_customer_name INTO l_customer_name;
  CLOSE c_customer_name;

  --Get AR Transaction Type name
  OPEN c_ar_transaction_type;
  FETCH c_ar_transaction_type INTO l_ar_transaction_type;
  CLOSE c_ar_transaction_type;

  --Get Primary Salesperson Name
  OPEN c_primary_salesrep_name;
  FETCH c_primary_salesrep_name INTO l_primary_sales_name;
  CLOSE c_primary_salesrep_name;

  --Bug 5521629
  --Format date to XSD Date format
  l_gl_date_from_f:=AR_GTA_TRX_UTIL.To_Xsd_Date_String(p_gl_date_from);
  l_gl_date_to_f:=AR_GTA_TRX_UTIL.To_Xsd_Date_String(p_gl_date_to);
  l_ar_trx_date_from_f:=AR_GTA_TRX_UTIL.To_Xsd_Date_String(p_ar_trx_date_from);
  l_ar_trx_date_to_f:=AR_GTA_TRX_UTIL.To_Xsd_Date_String(p_ar_trx_date_to);
  l_report_date:=AR_GTA_TRX_UTIL.To_Xsd_Date_String(SYSDATE);

  --generate xml elements for Parameters
  SELECT
     xmlforest( l_operating_unit        AS "OperationUnit"
               ,l_gta_batch_num_from    AS "BatchNumFrom"
               ,l_gta_batch_num_to      AS "BatchNumTo"
               ,l_ar_transaction_type   AS "TransactionType"
               ,l_cust_num_from         AS "CustomerNumberFrom"
               ,l_cust_num_to           AS "CustomerNumberTo"
               ,l_customer_name         AS "CustomerName"
               ,l_gl_period             AS "GLPeriod"
               ,l_gl_date_from_f        AS "GLDateFrom"
               ,l_gl_date_to_f          AS "GLDateTo"
               ,l_ar_trx_batch_from     AS "TransactionBatchFrom"
               ,l_ar_trx_batch_to       AS "TransactionBatchTo"
               ,l_ar_trx_num_from       AS "TransactionNumberFrom"
               ,l_ar_trx_num_to         AS "TransactionNumberTo"
               ,l_ar_trx_date_from_f    AS "TransactionDateFrom"
               ,l_ar_trx_date_to_f      AS "TransactionDateTo"
               ,l_ar_doc_num_from       AS "DocNumberFrom"
               ,l_ar_doc_num_to         AS "DocNumberTo"
               ,l_original_curr_code    AS "OriginalCurrency"
               ,l_primary_sales_name    AS "PrimarySalesPerson"
               )
  INTO
    l_parameter_xml
  FROM dual;

  --To calculate total number of AR transactions that have discrepancy
  OPEN c_ar_diff_count;
  FETCH c_ar_diff_count INTO l_ar_diff_count;
  CLOSE c_ar_diff_count;

  --To Calculate total number of GTA invoice that miss AR transaction
  OPEN c_missing_artrx_count;
  FETCH c_missing_artrx_count INTO l_missing_artrx_count;
  CLOSE c_missing_artrx_count;

  IF  (l_ar_diff_count=0) AND
      (l_missing_artrx_count=0)   --No Data Found
  THEN
    --Get Message For No Data Found
    FND_MESSAGE.Set_Name('AR','AR_GTA_NO_DATA_FOUND');
    l_no_data_found_msg:=FND_MESSAGE.Get;

    --To generat report xml with message no data found
    SELECT
      xmlelement("DiscrepancyReport"
                ,xmlforest(l_report_date       AS "RepDate"
                          ,'N'                 AS "ReportFailed"
                          ,l_parameter_xml     AS "Parameters"
                          ,'Y'                 AS "FailedWithParameters"
                          ,l_no_data_found_msg AS "FailedMsgWithParameters"
                          )
               )
    INTO
      l_report_xml
    FROM
      dual;

  ELSE
    --
    --Generate xml for summary section
    --

    --To calculate total AR transaction lines with discrepancy
    --within AR, GTA and GT
    /*Comment this part out to fix the bug 5263009
    OPEN c_ar_line_notmatching;
    FETCH c_ar_line_notmatching INTO l_ar_line_notmatching_total;
    CLOSE c_ar_line_notmatching;*/

    --Add this part to fix the bug 5263009
    --To calculate number of AR lines that don't match with related GT lines
    l_ar_line_notmatching_total:=l_validated_lines_total-l_ar_matching_lines_total;


    --To calculate   total AR transactions originally existing, but
    --being deleted after transferred into GTA

    l_ar_missingtrx_total:=l_missing_artrx_count;


    SELECT
      XMLFOREST(l_validated_lines_total       AS "NumOfARLines"
               ,l_ar_matching_lines_total     AS "NumOfLinesMatch"
               ,l_ar_line_notmatching_total   AS "NumOfLinesNoMatch"
               ,l_ar_partially_import_total   AS "NumOfNotToGT"
               ,l_ar_missingtrx_total         AS "NumOfMissingAR"
               )
    INTO
      l_summary_xml
    FROM
      dual;

   --To get base currency
   OPEN c_base_currency;
   FETCH c_base_currency INTO l_base_currency;
   CLOSE c_base_currency;


    --To Genrete XML for HeaderLevel by each AR tranaction
    OPEN c_ar_difference;
    FETCH c_ar_difference INTO l_ar_difference;
    WHILE c_ar_difference%FOUND
    LOOP
      l_ar_header_id:=l_ar_difference.customer_trx_id;
      l_description:=NULL;
      --the following code is added by Yao Zhang for bug#8765631
      SELECT COUNT(*)
      INTO l_consolidate_count
        FROM ar_gta_trx_headers
       WHERE ra_trx_id = l_ar_header_id
         AND status = 'CONSOLIDATED';
      IF l_consolidate_count>0
      THEN
      fnd_message.set_name('AR'
                          ,'AR_GTA_DISC_AR_GT_CON');
      l_description:=fnd_message.get();
      END IF;
      IF l_ar_difference.invoice_currency_code IS NULL
      THEN
      fnd_message.set_name('AR'
                          ,'AR_GTA_DISC_GTA_GT_CON');
      l_description:=fnd_message.get();
      END IF;
      --Yao Zhang add end;

      --To empty xml variable
      l_gta_header_xml:=l_xml_null;
      l_gta_header_xml_tmp:=l_xml_null;
      OPEN c_gta_header_xml;
      FETCH c_gta_header_xml INTO l_gta_header_xml_tmp;
      WHILE c_gta_header_xml%FOUND
      LOOP
        IF l_gta_header_xml IS NULL
        THEN
          l_gta_header_xml:=l_gta_header_xml_tmp;
        ELSE
            SELECT
              XMLCONCAT(l_gta_header_xml
                       ,l_gta_header_xml_tmp
                       )
            INTO
              l_gta_header_xml
            FROM
              dual;
        END IF;  --l_gta_header_xml IS NULL
        FETCH c_gta_header_xml INTO l_gta_header_xml_tmp;
      END LOOP;  --c_gta_header_xml%FOUND
      CLOSE c_gta_header_xml;


      --To empty xml variable
      l_gta_line_xml:=l_xml_null;
      l_gta_line_xml_tmp:=l_xml_null;

      --To Generate XML for LineLevel by each AR transaction
      OPEN c_gta_line_xml;
      FETCH c_gta_line_xml INTO l_gta_line_xml_tmp;
      WHILE c_gta_line_xml%FOUND
      LOOP
        IF l_gta_line_xml IS NULL
        THEN
          l_gta_line_xml:=l_gta_line_xml_tmp;
        ELSE
           SELECT
             XMLCONCAT(l_gta_line_xml
                      ,l_gta_line_xml_tmp
                      )
           INTO
             l_gta_line_xml
           FROM
             dual;
        END IF;  --l_gta_line_xml IS NULL
        FETCH c_gta_line_xml INTO l_gta_line_xml_tmp;
      END LOOP;  --c_gta_line_xml%FOUND
      CLOSE c_gta_line_xml;

      --To empty xml variable
      l_missing_line_xml:=l_xml_null;
      l_missing_line_xml_tmp:=l_xml_null;

      --To Generate XML for Missing AR Line by each AR transaction
      OPEN c_missing_line_xml;
      FETCH c_missing_line_xml INTO l_missing_line_xml_tmp;
      WHILE c_missing_line_xml%FOUND
      LOOP
        IF l_missing_line_xml IS NULL
        THEN
          l_missing_line_xml:=l_missing_line_xml_tmp;
        ELSE
          SELECT
            XMLCONCAT(l_missing_line_xml
                     ,l_missing_line_xml_tmp
                     )
          INTO
           l_missing_line_xml
          FROM
            dual;
        END IF;  --l_missing_line_xml IS NULL
        FETCH c_missing_line_xml INTO l_missing_line_xml_tmp;
      END LOOP;  --c_missing_line_xml%FOUND
      CLOSE c_missing_line_xml;

      --To empty xml variable
      l_unmatched_line_xml:=l_xml_null;
      l_unmatched_line_xml_tmp:=l_xml_null;

      --To Generate XML for Missing AR Line by each AR transaction
      OPEN c_unmatched_line_xml;
      FETCH c_unmatched_line_xml INTO l_unmatched_line_xml_tmp;
      WHILE c_unmatched_line_xml%FOUND
      LOOP
        IF l_unmatched_line_xml IS NULL
        THEN
          l_unmatched_line_xml:=l_unmatched_line_xml_tmp;
        ELSE
          SELECT
            XMLCONCAT(l_unmatched_line_xml
                     ,l_unmatched_line_xml_tmp
                     )
          INTO
            l_unmatched_line_xml
          FROM
            dual;
        END IF;  --l_unmatched_line_xml IS NULL
        FETCH c_unmatched_line_xml INTO l_unmatched_line_xml_tmp;
      END LOOP;  --c_unmatched_line_xml%FOUND
      CLOSE c_unmatched_line_xml;

      --To Generate XML for current AR Trnasaction


      --Bug 5521629
       --Format date to XSD Date formate
      l_ar_trx_date:=AR_GTA_TRX_UTIL.To_Xsd_Date_String(l_ar_difference.trx_date);
      SELECT
        XMLELEMENT("Invoice"
                  ,XMLFOREST
                     (l_ar_difference.trx_number            AS "ARInvoiceNo"
                     ,l_ar_trx_date                         AS "ARDate"
                     ,l_ar_difference.customer_name         AS "Customer"
                     ,l_ar_difference.invoice_currency_code AS "OriginalCurrency"
                     ,l_description                         AS "Description"--Yao Zhang add for bug#8765631
                     ,l_gta_header_xml                      AS "HeaderLevel"
                     ,l_gta_line_xml                        AS "LineLevel"
                     ,l_missing_line_xml                    AS "MissARLine"
                     ,l_unmatched_line_xml                  AS "UnmatchedLines"
                     )
                  )
      INTO l_ar_invoice_xml_tmp
      FROM
        dual;

      IF l_ar_invoice_xml IS NULL
      THEN
        l_ar_invoice_xml:=l_ar_invoice_xml_tmp;
      ELSE
        SELECT
          XMLCONCAT(l_ar_invoice_xml
                   ,l_ar_invoice_xml_tmp
                   )
        INTO
          l_ar_invoice_xml
        FROM dual;
      END IF;  --l_ar_invoice_xml IS NULL
      FETCH c_ar_difference INTO l_ar_difference;
    END LOOP; --c_ar_difference%found
    CLOSE c_ar_difference;


   --To generate xml for missed AR transacitons
   OPEN c_missing_artrx_xml;
   FETCH c_missing_artrx_xml INTO l_missing_artrx_xml_tmp;
   WHILE c_missing_artrx_xml%FOUND
   LOOP
     IF l_missing_artrx_xml IS NULL
     THEN
       l_missing_artrx_xml:=l_missing_artrx_xml_tmp;
     ELSE
       SELECT
         XMLCONCAT(l_missing_artrx_xml
                  ,l_missing_artrx_xml_tmp
                  )
       INTO
         l_missing_artrx_xml
       FROM
         dual;
     END IF;--l_missing_artrx_xml IS NULL

     FETCH c_missing_artrx_xml INTO l_missing_artrx_xml_tmp;
   END LOOP;--c_missing_artrx_xml%FOUND
   CLOSE c_missing_artrx_xml;

   --To Generate xml for whole report
   SELECT
     XMLELEMENT("DiscrepancyReport"
              ,XMLFOREST(l_report_date        AS "RepDate"
                        ,l_no_char            AS "ReportFailed"
                        ,l_parameter_xml      AS "Parameters"
                        ,l_no_char            AS "FailedWithParameters"
                        ,l_summary_xml        AS "Summary"
                        ,l_base_currency      AS "RepCurr"
                        ,l_ar_invoice_xml     AS "Invoices"
                        ,l_missing_artrx_xml  AS "MissingInvoices"
                        )
              )
   INTO
     l_report_xml
   FROM
     dual;
  END IF; -- (l_ar_diff_count=0) AND (l_missing_artrx_count=0)



  x_output:=l_report_xml;

  --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.end'
                  ,'Exit procedure');
  END IF;  --( l_proc_level >= l_dbg_level)


EXCEPTION
  WHEN OTHERS THEN
    IF (l_proc_level >= l_dbg_level)
    THEN
      l_error_msg:=SQLCODE||':'||SQLERRM;
      FND_LOG.String( l_proc_level
                    , G_Module_Prefix || l_api_name || '. Other_Exception '
                    , l_error_msg);



     END IF;  --(l_proc_level >= l_dbg_level)
     RAISE;
END Generate_Discrepancy_Xml;

--==========================================================================
--  PROCEDURE NAME:
--
--      Generate_Discrepancy_Rep               Public
--
--  DESCRIPTION:
--
--       This Procedure Generate Discrepancy Report Data
--
--
--  PARAMETERS:
--      In:  p_org_id                 Operating unit id
--           p_gta_batch_num_from     GTA batch number low range
--           p_gta_batch_num_to       GTA batch number high range
--           p_ar_transaction_type    AR transaction type
--           p_cust_num_from          Customer Number low range
--           p_cust_num_to            Customer Number high range
--           p_cust_name_from         Customer Name low range
--           p_cust_name_to           Customer Name high range
--           p_gl_period              GL period name
--           p_gl_date_from           GL period date low range
--           p_gl_date_to             GL period date high range
--           p_ar_trx_batch_from      AR Transaction name low range
--           p_ar_trx_batch_to        AR Transaction name high range
--           p_ar_trx_num_from        AR Transaction number low range
--           p_ar_trx_num_to          AR Transaction number high range
--           p_ar_trx_date_from       AR Transaction date low range
--           p_ar_trx_date_to         AR Transaction date high range
--           p_ar_doc_num_from        AR transaction document sequence
--                                    low range
--           p_ar_doc_num_to          AR transaction document sequence
--                                    high range
--           p_original_curr_code     Currency code on AR transaction
--           p_primary_sales          Primary salesperson
--
--    Out:
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           05/17/05   	Donghai  Wang        Created.
--           03/04/05     Donghai  Wang        Add FND Log
--           05-Aug-2009  Yao Zhang Fix bug#8765631 Modified
--==========================================================================
PROCEDURE Generate_Discrepancy_Rep
( p_org_id	                  IN	NUMBER
, p_gta_batch_num_from	      IN	VARCHAR2
, p_gta_batch_num_to          IN	VARCHAR2
, p_ar_transaction_type	      IN	NUMBER
, p_cust_num_from	            IN	VARCHAR2
, p_cust_num_to	              IN	VARCHAR2
, p_cust_name_id	            IN	NUMBER
, p_gl_period	                IN	VARCHAR2
, p_gl_date_from	            IN	VARCHAR2
, p_gl_date_to	              IN	VARCHAR2
, p_ar_trx_batch_from	        IN	VARCHAR2
, p_ar_trx_batch_to	          IN	VARCHAR2
, P_ar_trx_num_from	          IN	VARCHAR2
, p_ar_trx_num_to	            IN	VARCHAR2
, p_ar_trx_date_from	        IN	VARCHAR2
, p_ar_trx_date_to	          IN	VARCHAR2
, p_ar_doc_num_from	          IN	VARCHAR2
, p_ar_doc_num_to	            IN	VARCHAR2
, p_original_curr_code	      IN	VARCHAR2
, p_primary_sales	            IN	NUMBER
)
IS
l_org_id	                  NUMBER
                            :=p_org_id;
l_gta_batch_num_from	      VARCHAR2(30)
                            :=p_gta_batch_num_from;
l_gta_batch_num_to	        VARCHAR2(30)
                            :=p_gta_batch_num_to;
l_ar_transaction_type	      NUMBER
                            :=p_ar_transaction_type;
l_cust_num_from	            VARCHAR2(30)
                            :=p_cust_num_from;
l_cust_num_to	              VARCHAR2(30)
                            :=p_cust_num_to;
l_cust_id                   NUMBER(15)
                            :=p_cust_name_id;
l_gl_period	                VARCHAR2(30)
                            :=p_gl_period;
l_gl_date_from	            VARCHAR2(20)
                            :=p_gl_date_from;
l_gl_date_from_d            DATE;
l_gl_date_to	              VARCHAR2(20)
                            :=p_gl_date_to;
l_gl_date_to_d              DATE;
l_ar_trx_batch_from	        VARCHAR2(30)
                            :=p_ar_trx_batch_from;
l_ar_trx_batch_to	          VARCHAR2(30)
                            :=p_ar_trx_batch_to;
l_ar_trx_num_from	          VARCHAR2(30)
                            :=p_ar_trx_num_from;
l_ar_trx_num_to	            VARCHAR2(30)
                            :=p_ar_trx_num_to;
l_ar_trx_date_from	        VARCHAR2(20)
                            :=p_ar_trx_date_from;
l_ar_trx_date_from_d        DATE;
l_ar_trx_date_to	          VARCHAR2(20)
                            :=p_ar_trx_date_to;
l_ar_trx_date_to_d          DATE;
l_ar_doc_num_from	          VARCHAR2(30)
                            :=p_ar_doc_num_from;
l_ar_doc_num_to	            VARCHAR2(30)
                            :=p_ar_doc_num_from;
l_original_curr_code	      VARCHAR2(30)
                            :=p_original_curr_code	;
l_primary_sales	            NUMBER
                            :=p_primary_sales;
l_ar_trx_header_id          NUMBER;
l_header_difference         BOOLEAN;
l_line_difference           BOOLEAN;
l_has_unmatched             BOOLEAN;
l_xml_output                XMLTYPE;
l_ar_trx_number             ra_customer_trx_all.trx_number%TYPE;
l_ar_trx_date               ra_customer_trx_all.trx_date%TYPE;
l_ar_customer_name          hz_parties.party_name%TYPE;
l_ar_currency_code          ra_customer_trx_all.invoice_currency_code%TYPE;
l_missing_artrx_seq         NUMBER;
l_gta_trx_number_missing    VARCHAR2(2000);
l_gt_invoice_number_missing VARCHAR2(2000);
l_gt_invoice_amount_missing NUMBER;
l_ar_trx_number_missing     ra_customer_trx_all.trx_number%TYPE;

l_delimiter                 VARCHAR2(1)
                            :=',';
l_validated_lines           NUMBER;
l_validated_lines_total     NUMBER;
l_ar_matching_lines         NUMBER;
l_ar_matching_lines_total   NUMBER;
l_ar_partially_import       NUMBER;
l_ar_partially_import_total NUMBER;

l_api_name                  VARCHAR2(50)
                            :='Generate_Discrepancy_Rep';
l_dbg_msg                   VARCHAR2(100);

l_gta_consolidation_flag    ar_gta_trx_headers_all.consolidation_flag%TYPE;


CURSOR c_trx_header IS
SELECT DISTINCT
  gta.ra_trx_id
 ,ct.trx_number
 ,ct.trx_date
 ,rac_bill_party.party_name    customer_name
 ,ct.invoice_currency_code
FROM
  ar_gta_trx_headers             gta
 ,ra_customer_trx_all             ct
 ,hz_cust_accounts                rac_bill
 ,hz_parties                      rac_bill_party
 ,ra_cust_trx_line_gl_dist_all    gd
 ,ra_batches_all                  rb
WHERE gta.ra_trx_id=ct.customer_trx_id(+)
  AND rb.batch_id(+)=ct.batch_id
  AND gta.source='AR'
  AND(gta.status='COMPLETED' OR gta.status='CONSOLIDATED')--Yao Zhang Modified for bug#8765631
  AND gta.latest_version_flag='Y'
  AND gta.org_id=l_org_id
  AND ((gta.gta_batch_number>=l_gta_batch_num_from) OR
      (l_gta_batch_num_from IS NULL))
  AND ((gta.gta_batch_number<=l_gta_batch_num_to) OR
      (l_gta_batch_num_to IS NULL))
  AND ((ct.cust_trx_type_id=l_ar_transaction_type) OR
      (l_ar_transaction_type IS NULL))
  AND ct.bill_to_customer_id=rac_bill.cust_account_id(+)
  AND rac_bill.party_id = rac_bill_party.party_id(+)
  AND ((rac_bill.account_number>=l_cust_num_from) OR
      (l_cust_num_from IS NULL))
  AND ((rac_bill.account_number<=l_cust_num_to) OR
      (l_cust_num_to IS NULL))
  AND ((ct.bill_to_customer_id=l_cust_id) OR
      (l_cust_id IS NULL))
  AND ((gta.ra_gl_period=l_gl_period) OR
      (l_gl_period IS NULL))
  AND ct.customer_trx_id = gd.customer_trx_id(+)
  AND 'REC' = gd.account_class(+)
  AND 'Y' = gd.latest_rec_flag(+)
  AND ((gd.gl_date>=l_gl_date_from_d) OR
      (l_gl_date_from_d IS NULL ))
  AND ((gd.gl_date<=l_gl_date_to_d) OR
      (l_gl_date_to_d IS NULL))
  AND ((rb.name>=l_ar_trx_batch_from) OR
      (l_ar_trx_batch_from IS null))
  AND ((rb.name<=l_ar_trx_batch_to) OR
      (l_ar_trx_batch_to IS NULL))
  AND ((ct.trx_number>=l_ar_trx_num_from) OR
      (l_ar_trx_num_from IS NULL))
  AND ((ct.trx_number<=l_ar_trx_num_to) OR
      (l_ar_trx_num_to IS NULL))
  AND ((ct.trx_date>=l_ar_trx_date_from_d) OR
      (l_ar_trx_date_from_d IS NULL))
  AND ((ct.trx_date<=l_ar_trx_date_to_d) OR
      (l_ar_trx_date_to_d IS NULL))
  AND ((ct.doc_sequence_value>=l_ar_doc_num_from) OR
      (l_ar_doc_num_from IS NULL))
  AND ((ct.doc_sequence_value<=l_ar_doc_num_to) OR
      (l_ar_doc_num_to IS NULL))
  AND ((ct.invoice_currency_code=l_original_curr_code) OR
      (l_original_curr_code IS NULL))
  AND ((ct.primary_salesrep_id=l_primary_sales) OR
      (l_primary_sales IS null))
  --Yao Zhang add for bug#8765631
  AND (gta.consolidation_flag IS NULL OR gta.consolidation_flag='1');

l_trx_header                      c_trx_header%ROWTYPE;


CURSOR c_missing_artrx IS
SELECT
  gth.gta_trx_number
 ,gth.ra_trx_number
 ,gth.gt_invoice_number
 ,gth.gta_trx_header_id
FROM
  ar_gta_trx_headers gth
WHERE gth.SOURCE='AR'--Yao Zhang add for bug#8765631
  AND (gth.status='COMPLETED' OR gth.status='CONSOLIDATED')
  AND gth.ra_trx_id=l_ar_trx_header_id;
      --gth.SOURCE='GT'
CURSOR c_ar_trx_number_missing IS
SELECT
  DISTINCT gth.ra_trx_number
FROM
  ar_gta_trx_headers gth
WHERE gth.SOURCE='AR'--Yao Zhang add for bug#8765631
  AND (gth.status='COMPLETED' OR gth.status='CONSOLIDATED')
  AND gth.ra_trx_id=l_ar_trx_header_id;
     --gth.SOURCE='GT'
--The following code is added by Yao for bug#8765631
CURSOR c_consolidated_invs IS
SELECT gta.gta_trx_header_id
      ,gta.gta_trx_number
      ,gta.ra_gl_date
      ,gta.BILL_TO_CUSTOMER_NAME customer_name
  FROM ar_gta_trx_headers          gta
 WHERE gta.consolidation_flag = '0'
   AND gta.status = 'COMPLETED'
   AND gta.SOURCE = 'AR'
   AND gta.org_id = l_org_id
   AND gta.latest_version_flag = 'Y'
   AND ((gta.gta_batch_number >= l_gta_batch_num_from) OR
       (l_gta_batch_num_from IS NULL))
   AND ((gta.gta_batch_number <= l_gta_batch_num_to) OR
       (l_gta_batch_num_to IS NULL))
   AND l_ar_transaction_type IS NULL
   AND ((gta.BILL_TO_CUSTOMER_NUMBER>= l_cust_num_from) OR
       (l_cust_num_from IS NULL))
   AND ((gta.BILL_TO_CUSTOMER_NUMBER <= l_cust_num_to) OR
       (l_cust_num_to IS NULL))
   AND ((gta.BILL_TO_CUSTOMER_ID = l_cust_id) OR (l_cust_id IS NULL))
   AND ((gta.ra_gl_period = l_gl_period) OR (l_gl_period IS NULL))
   AND ((gta.ra_gl_date >= l_gl_date_from_d) OR (l_gl_date_from_d IS NULL))
   AND ((gta.ra_gl_date <= l_gl_date_to_d) OR (l_gl_date_to_d IS NULL))
   AND l_ar_trx_batch_from IS NULL
   AND l_ar_trx_batch_to IS NULL
   AND l_ar_trx_num_from IS NULL
   AND l_ar_trx_num_to IS NULL
   AND l_ar_trx_date_from_d IS NULL
   AND l_ar_trx_date_to_d IS NULL
   AND l_ar_doc_num_from IS NULL
   AND l_ar_doc_num_to IS NULL
   AND l_original_curr_code IS NULL
   AND l_primary_sales IS NULL;

l_consolidated_inv           c_consolidated_invs%ROWTYPE;
l_consolidated_inv_header_id NUMBER;
l_consolidated_difference    BOOLEAN;
--Yao Zhang add end;
l_missing_artrx_rec               c_missing_artrx%ROWTYPE;
l_dbg_level                       NUMBER     :=FND_LOG.G_Current_Runtime_Level;
l_proc_level                      NUMBER     :=FND_LOG.Level_Procedure;


BEGIN

  --Logging for debug
  IF (l_proc_level>=l_dbg_level)
  THEN
    FND_LOG.string(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.begin'
                  ,'Enter procedure'
                  );
  END IF;  --(l_proc_level>=l_proc_level)

--log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_org_id '||p_org_id);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_gta_batch_num_from '||p_gta_batch_num_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_gta_batch_num_to '||p_gta_batch_num_to);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_transaction_type '||p_ar_transaction_type);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_cust_num_from	 '||p_cust_num_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_cust_num_to	 '||p_cust_num_to);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_cust_name_id	 '||p_cust_name_id);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_gl_period	 '||p_gl_period);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_gl_date_from	 '||p_gl_date_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_gl_date_to	 '||p_gl_date_to);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_trx_batch_from	 '||p_ar_trx_batch_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_trx_batch_to	 '||p_ar_trx_batch_to);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_trx_num_from	 '||p_ar_trx_num_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_trx_num_to	 '||p_ar_trx_num_to);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_trx_date_from	 '||p_ar_trx_date_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_trx_date_to	 '||p_ar_trx_date_to);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_doc_num_from	 '||p_ar_doc_num_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_ar_doc_num_to	 '||p_ar_doc_num_to);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_original_curr_code	 '||p_original_curr_code);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.parameters'
                  ,'p_primary_sales	 '||p_primary_sales);

  END IF;  --( l_proc_level >= l_dbg_level)

   --Initialization
   l_missing_artrx_seq:=0;

   --Convert canonical date format to pl/sql date
   l_gl_date_from_d:=FND_DATE.Canonical_To_Date(l_gl_date_from);
   l_gl_date_to_d:=FND_DATE.Canonical_To_Date(l_gl_date_to);
   l_ar_trx_date_from_d:=FND_DATE.Canonical_To_Date(l_ar_trx_date_from);
   l_ar_trx_date_to_d:=FND_DATE.Canonical_To_Date(l_ar_trx_date_to);

   l_validated_lines_total:=0;
   l_ar_matching_lines_total:=0;
   l_ar_partially_import_total:=0;

   OPEN c_trx_header;

   FETCH c_trx_header INTO l_trx_header;


   WHILE c_trx_header%FOUND
   LOOP

      l_ar_trx_header_id:=l_trx_header.ra_trx_id;
      l_ar_trx_number:=l_trx_header.trx_number;
      l_ar_trx_date:=l_trx_header.trx_date;
      l_ar_customer_name:=l_trx_header.customer_name;
      l_ar_currency_code:=l_trx_header.invoice_currency_code;

      --Logging for debug
      IF (l_proc_level>=l_dbg_level)
      THEN
        FND_LOG.string(l_proc_level
                      ,G_MODULE_PREFIX||'.'||l_api_name||'.phase'
                      ,'c_trx_header'
                      );

        FND_LOG.string(l_proc_level
                      ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                      ,'l_ar_trx_header_id '||l_ar_trx_header_id
                      );

        FND_LOG.string(l_proc_level
                      ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                      ,'l_ar_trx_number '||l_ar_trx_number
                      );

        FND_LOG.string(l_proc_level
                      ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                      ,'l_ar_trx_date '||l_ar_trx_date
                      );


        FND_LOG.string(l_proc_level
                      ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                      ,'l_ar_customer_name '||l_ar_customer_name
                      );

        FND_LOG.string(l_proc_level
                      ,G_MODULE_PREFIX||'.'||l_api_name||'.variables'
                      ,'l_ar_currency_code '||l_ar_currency_code
                      );
      END IF;  --(l_proc_level>=l_proc_level)



      --Compare if AR missing - start
      IF (l_ar_trx_header_id IS NOT NULL) AND
         (l_ar_trx_number IS NULL) AND
         (l_ar_trx_date IS NULL) AND
         (l_ar_customer_name IS NULL) AND
         (l_ar_currency_code IS NULL)
      THEN                   --Missing AR transaction
      --{
        --
        --To calculate total INVOICE AMOUNT(no tax) by each ar transaction
        --To concatenate GTA invoice numbers
        --To concatenate VAT invoice numbers
        --
        l_gta_trx_number_missing:='';
        l_gt_invoice_number_missing:='';
        l_gt_invoice_amount_missing:=0;
        OPEN c_missing_artrx;
        FETCH c_missing_artrx INTO l_missing_artrx_rec;
        WHILE c_missing_artrx%FOUND
        LOOP
          IF (l_gta_trx_number_missing IS NULL)
          THEN
            l_gta_trx_number_missing:=l_missing_artrx_rec.gta_trx_number;
          ELSE
            l_gta_trx_number_missing:=l_gta_trx_number_missing||l_delimiter||
                                      l_missing_artrx_rec.gta_trx_number;
          END IF;  -- l_gta_trx_number_missing is null


          IF (l_gt_invoice_number_missing IS NULL)
          THEN
            l_gt_invoice_number_missing:=l_missing_artrx_rec.gt_invoice_number;
          ELSE
            l_gt_invoice_number_missing:=l_gt_invoice_number_missing||
                                         l_delimiter||
                                         l_missing_artrx_rec.gt_invoice_number;
          END IF; -- l_gt_invoice_number_missing IS NULL


          l_gt_invoice_amount_missing :=l_gt_invoice_amount_missing +
                                        AR_GTA_TRX_UTIL.Get_Gtainvoice_Amount
                                         (l_missing_artrx_rec.gta_trx_header_id
                                         );

          FETCH c_missing_artrx INTO l_missing_artrx_rec;
        END LOOP;  --WHILE c_missing_artrx%FOUND

        CLOSE c_missing_artrx;


        l_missing_artrx_seq:=l_missing_artrx_seq+1;


        --Get number of missed AR transaciton
        OPEN c_ar_trx_number_missing;
        FETCH c_ar_trx_number_missing INTO l_ar_trx_number_missing;
        CLOSE c_ar_trx_number_missing;

        INSERT INTO ar_gta_missing_artrx_temp(record_number
                                         ,gta_trx_number
                                         ,ar_trx_number
                                         ,gt_invoice_number
                                         ,gt_invoice_amount
                                         )
                                   VALUES(l_missing_artrx_seq
                                         ,l_gta_trx_number_missing
                                         ,l_ar_trx_number_missing
                                         ,l_gt_invoice_number_missing
                                         ,l_gt_invoice_amount_missing
                                         );
     --}
     ELSE
     --{

        l_validated_lines:=0;
        l_ar_matching_lines:=0;
        l_ar_partially_import:=0;


        Compare_Header( p_org_id            =>p_org_id
                      , p_ar_header_id      =>l_ar_trx_header_id
                      , x_has_difference    =>l_header_difference
                      );

        Compare_Lines( p_org_id              =>p_org_id
                     , p_ar_header_id        =>l_ar_trx_header_id
                     , x_validated_lines     =>l_validated_lines
                     , x_ar_matching_lines   =>l_ar_matching_lines
                     , x_ar_partially_import =>l_ar_partially_import
                     , x_has_difference      =>l_line_difference
                     );

        Get_Unmatched_Lines( p_org_id        =>p_org_id
                           , p_ar_header_id  =>l_ar_trx_header_id
                           , x_has_difference=>l_has_unmatched
                           );

        IF (l_header_difference OR l_line_difference OR l_has_unmatched)
        THEN
          INSERT INTO ar_gta_ar_difference_temp(customer_trx_id
                                               ,trx_number
                                               ,trx_date
                                               ,customer_name
                                               ,invoice_currency_code
                                               )
                                         VALUES(l_ar_trx_header_id
                                               ,l_ar_trx_number
                                               ,l_ar_trx_date
                                               ,l_ar_customer_name
                                               ,l_ar_currency_code
                                               );

        END IF; --(l_header_difference OR l_line_difference OR l_has_unmatched)

        --To calculate the number of validated AR transaction lines
        l_validated_lines_total:=l_validated_lines_total+l_validated_lines;

        --To calculate the number of AR lines that match with both GTA and GT
        l_ar_matching_lines_total:=l_ar_matching_lines_total+
                                   l_ar_matching_lines;



        --To calculatee the number of AR transaction lines that are split into
        --multiple GTA and GT lines, and some split lines not imported into GT.
        l_ar_partially_import_total:=l_ar_partially_import_total+
                                     l_ar_partially_import;

      --}
      END IF;  --"Compare if AR missing" end

      FETCH c_trx_header INTO l_trx_header;
   END LOOP;

   CLOSE c_trx_header;
   --the following code is added by Yao for bug#8765631
   OPEN c_consolidated_invs;
   LOOP
   FETCH c_consolidated_invs INTO l_consolidated_inv;
   EXIT WHEN c_consolidated_invs%NOTFOUND;
   Compare_Consolidated_Inv(p_org_id         =>p_org_id
                           ,p_gta_header_id  =>l_consolidated_inv.gta_trx_header_id
                           ,x_has_difference =>l_consolidated_difference
                           );
   IF l_consolidated_difference
   THEN
   INSERT INTO ar_gta_ar_difference_temp(customer_trx_id
                                               ,trx_number
                                               ,trx_date
                                               ,customer_name
                                               ,invoice_currency_code
                                               )
                                         VALUES(l_consolidated_inv.gta_trx_header_id
                                               ,l_consolidated_inv.gta_trx_number
                                               ,l_consolidated_inv.ra_gl_date
                                               ,l_consolidated_inv.customer_name
                                               ,NULL
                                               );
   END IF;
   END LOOP;
   CLOSE c_consolidated_invs;
   --Yao Zhang add end;


   --Call Generate_Discrepancy_Xml to generate XML statements
   Generate_Discrepancy_Xml
          ( p_org_id	                  =>l_org_id
          , p_gta_batch_num_from	      =>l_gta_batch_num_from
          , p_gta_batch_num_to          =>l_gta_batch_num_to
          , p_ar_transaction_type	      =>l_ar_transaction_type
          , p_cust_num_from	            =>l_cust_num_from
          , p_cust_num_to	              =>l_cust_num_to
          , p_cust_name_id	            =>l_cust_id
          , p_gl_period	                =>l_gl_period
          , p_gl_date_from              =>l_gl_date_from_d
          , p_gl_date_to                =>l_gl_date_to_d
          , p_ar_trx_batch_from         =>l_ar_trx_batch_from
          , p_ar_trx_batch_to           =>l_ar_trx_batch_to
          , P_ar_trx_num_from           =>l_ar_trx_num_from
          , p_ar_trx_num_to             =>l_ar_trx_num_to
          , p_ar_trx_date_from	        =>l_ar_trx_date_from_d
          , p_ar_trx_date_to	          =>l_ar_trx_date_to_d
          , p_ar_doc_num_from	          =>l_ar_doc_num_from
          , p_ar_doc_num_to	            =>l_ar_doc_num_to
          , p_original_curr_code	      =>l_original_curr_code
          , p_primary_sales	            =>l_primary_sales
          , p_validated_lines_total     =>l_validated_lines_total
          , p_ar_matching_lines_total   =>l_ar_matching_lines_total
          , p_ar_partially_import_total =>l_ar_partially_import_total
          , x_output                    =>l_xml_output
          );


  --Output xml script

  FND_FILE.Put_Line(FND_FILE.Output,'<?xml version="1.0" encoding="UTF-8"?>');
  AR_GTA_TRX_UTIL.Output_Conc(l_xml_output.Getclobval);

  --Logging for debug

  IF (l_proc_level>=l_dbg_level)
  THEN
    FND_LOG.string(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_api_name||'.end'
                  ,'Exit Procedure'
                  );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(l_proc_level>=l_dbg_level)
    THEN
      Fnd_Log.String( l_proc_level
                    , G_Module_Prefix || l_api_name || '. Other_Exception '
                    , Sqlcode||':'||Sqlerrm);

    END IF;
    RAISE;
END Generate_Discrepancy_Rep;

--==========================================================================
--  PROCEDURE NAME:
--
--      Generate_Consol_Mapping_Rep               Public
--
--  DESCRIPTION:
--
--       This procedure generates Invoice Consolidation Mapping Report data.
--
--
--  PARAMETERS:
--      In:  p_org_id                 Operating unit id
--           p_gl_period              GL period
--           p_customer_num_from      Customer number low range
--           p_customer_num_to        Customer number high range
--           p_customer_name_from     Customer name low range
--           p_customer_name_to       Customer name high range
--           p_consol_trx_num_from    Consolidated invoice number low range
--           p_consol_trx_num_to      Consolidated invoice number high range
--           p_invoice_type           Invoice type
--
--    Out:
--
--  DESIGN REFERENCES:
--      GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--      25-Jul-2009  	Allen Yang        Created.
--      02-Sep-2009   Allen Yang        Modified for bug 8848696
--==========================================================================
Procedure Generate_Consol_Mapping_Rep
( p_org_Id	            IN   NUMBER
, p_gl_period           IN   VARCHAR2
, p_customer_num_from   IN   VARCHAR2
, p_customer_num_to     IN   VARCHAR2
, p_customer_name_from  IN   VARCHAR2
, p_customer_name_to    IN   VARCHAR2
, p_consol_trx_num_from IN   VARCHAR2
, p_consol_trx_num_to   IN   VARCHAR2
, p_invoice_type        IN   VARCHAR2
)
IS
/* Note: Due to FD change, the meaning of words 'consolidation' and 'consolidated'
         has been reversed in code.
   consolidated  -- invoice which consists of several consolidation invoices
   consolidation -- invoice which is consolidated into a consolidated invoice
*/
l_procedure_name        VARCHAR2(40):='Generate_Consol_Mapping_Rep';
l_no_data_message       VARCHAR2(500);
l_consolidation_trx_id  AR_Gta_Trx_Headers.GTA_TRX_HEADER_ID%TYPE;
l_Parameter             Xmltype;
l_consolidation_trx     Xmltype;
l_consolidated_trxs     Xmltype;
l_consolidation_trxs    Xmltype;
l_report                Xmltype;
l_consolidation_rows    NUMBER;
i                       NUMBER;
l_consolidated_rows     NUMBER;
l_no_data_flag          VARCHAR2(1):='N';

l_consol_trx_num_from   AR_Gta_Trx_Headers_All.CONSOLIDATION_TRX_NUM%TYPE
                        := p_consol_trx_num_from;
l_consol_trx_num_to     AR_Gta_Trx_Headers_All.CONSOLIDATION_TRX_NUM%TYPE
                        := p_consol_trx_num_to;
l_customer_num_from     AR_Gta_Trx_Headers_All.BILL_TO_CUSTOMER_NUMBER%TYPE
                        := p_customer_num_from;
l_customer_num_to       AR_Gta_Trx_Headers_All.BILL_TO_CUSTOMER_NUMBER%TYPE
                        := p_customer_num_to;
l_customer_name_from    AR_Gta_Trx_Headers_All.BILL_TO_CUSTOMER_NAME%TYPE
                        := p_customer_name_from;
l_customer_name_to       AR_Gta_Trx_Headers_All.BILL_TO_CUSTOMER_NAME%TYPE
                        := p_customer_name_to;
l_invoice_type          AR_Gta_Trx_Headers_All.INVOICE_TYPE%TYPE
                        := p_invoice_type;

-- added by Allen Yang for bug 8848696 02-Sep-2009
l_invoice_type_disp     FND_LOOKUP_VALUES_VL.MEANING%TYPE;
-- end added by Allen Yang

l_dbg_level             NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_proc_level            NUMBER:=FND_LOG.LEVEL_PROCEDURE;

CURSOR c_consolidation_trx_ids IS
SELECT
  GTA_TRX_HEADER_ID
FROM
  AR_Gta_Trx_Headers_All
WHERE ORG_ID = p_org_id
  AND RA_GL_PERIOD =  NVL(p_gl_period, RA_GL_PERIOD)
  AND SOURCE = 'AR'
  AND CONSOLIDATION_FLAG = '0'
  AND BILL_TO_CUSTOMER_NUMBER BETWEEN NVL(l_customer_num_from
                                         ,BILL_TO_CUSTOMER_NUMBER)
                                  AND NVL(l_customer_num_to
                                         ,BILL_TO_CUSTOMER_NUMBER)
  AND BILL_TO_CUSTOMER_NAME BETWEEN NVL(l_customer_name_from
                                       ,BILL_TO_CUSTOMER_NAME)
                                AND NVL(l_customer_name_to
                                       ,BILL_TO_CUSTOMER_NAME)
  AND GTA_TRX_NUMBER BETWEEN NVL(l_consol_trx_num_from, GTA_TRX_NUMBER)
                         AND  NVL(l_consol_trx_num_to, GTA_TRX_NUMBER)
  AND INVOICE_TYPE = NVL(l_invoice_type, INVOICE_TYPE)
ORDER BY
  BILL_TO_CUSTOMER_NAME
 ,TP_TAX_REGISTRATION_NUMBER
 ,INVOICE_TYPE
 ,RA_GL_PERIOD
 ,CUSTOMER_ADDRESS_PHONE
 ,BANK_ACCOUNT_NAME
 ,BANK_ACCOUNT_NUMBER
 ,GTA_TRX_NUMBER;

BEGIN
  --logging for debug
  IF (l_proc_level>=l_dbg_level)
  THEN
    FND_LOG.string( l_proc_level
                  , G_MODULE_PREFIX||l_procedure_name||'.begin'
                  , 'enter procedure');
  END IF; --(l_proc_level>=l_dbg_level)

  --Get Consolidation Invoice Rows
  SELECT
    COUNT(*)
  INTO
    l_consolidation_rows
  FROM
    AR_Gta_Trx_Headers
  WHERE ORG_ID = p_org_id
    AND RA_GL_PERIOD =  NVL(p_gl_period, RA_GL_PERIOD)
    AND Source = 'AR'
    AND CONSOLIDATION_FLAG = '0'
    AND BILL_TO_CUSTOMER_NUMBER BETWEEN NVL(l_customer_num_from
                                          , BILL_TO_CUSTOMER_NUMBER)
                                    AND NVL(l_customer_num_to
                                          , BILL_TO_CUSTOMER_NUMBER)
    AND BILL_TO_CUSTOMER_NAME BETWEEN NVL(l_customer_name_from
                                        , BILL_TO_CUSTOMER_NAME)
                                  AND NVL(l_customer_name_to
                                        , BILL_TO_CUSTOMER_NAME)
    AND CONSOLIDATION_TRX_NUM BETWEEN NVL(l_consol_trx_num_from
                                           , CONSOLIDATION_TRX_NUM)
                                     AND NVL(l_consol_trx_num_to
                                           , CONSOLIDATION_TRX_NUM)
    AND INVOICE_TYPE = NVL(l_invoice_type, INVOICE_TYPE);

  OPEN c_consolidation_trx_ids;
  FETCH c_consolidation_trx_ids INTO l_consolidation_trx_id;

  i:=0;
  WHILE c_consolidation_trx_ids%FOUND LOOP
    i:=i+1;
    l_consolidation_trx := get_consolidation_trx(p_trx_header_id =>
                                                 l_consolidation_trx_id);
    l_consolidated_trxs := get_consolidated_trxs(p_trx_header_id  =>
                                                 l_consolidation_trx_id);
    SELECT
      Xmlconcat(l_consolidation_trxs
              , Xmlelement("Invoice"
              , Xmlconcat(l_consolidation_trx
                        , l_consolidated_trxs)))
    INTO
      l_consolidation_trxs
    FROM DUAL;

    FETCH c_consolidation_trx_ids INTO l_consolidation_trx_id;
  END LOOP; --c_consolidation_trx_ids%FOUND
  CLOSE c_consolidation_trx_ids;

  --Get Consolidated Invoice Rows
  l_consolidated_rows:=i;
  IF (l_consolidation_rows =0) AND (l_consolidated_rows =0)
  THEN
    l_no_data_flag:='Y';
  END IF; -- (l_consolidation_rows =0) AND (l_consolidated_rows =0)

  -- added by Allen Yang 02-Sep-2009 for bug 8848696
  ---------------------------------------------------------------
  BEGIN
    SELECT meaning
    INTO l_invoice_type_disp
    FROM FND_LOOKUP_VALUES_VL
    WHERE lookup_type = 'AR_GTA_INVOICE_TYPE'
      AND lookup_code = p_invoice_type;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.String(fnd_log.LEVEL_EXCEPTION,
                         G_MODULE_PREFIX || l_procedure_name,
                         'No data found ');
      END IF;
      RAISE;
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.String(fnd_log.LEVEL_EXCEPTION,
                         G_MODULE_PREFIX || l_procedure_name,
                         'Other exception');
      END IF;
      RAISE;
  END;
  ---------------------------------------------------------------

  --Generate Parameter Section
  SELECT
    Xmlelement("Parameters"
             , Xmlforest( ar_gta_trx_util.Get_OperatingUnit(p_org_id)
                                                 AS "OperationUnit"
                        , p_gl_period            AS "GLPeriod"
                        , p_customer_num_from    AS "CustNumFrom"
                        , p_customer_num_to      AS "CustNumTo"
                        , p_customer_name_from   AS "CustNameFrom"
                        , p_customer_name_to     AS "CustNameTo"
                        , p_consol_trx_num_from  AS "ConsolTrxNumFrom"
                        , p_consol_trx_num_to    AS "ConsolTrxNumTo"
                        -- modified by Allen Yang 02-Sep-2009 for bug 8848696
                        --, p_invoice_type         AS "InvoiceType"))
                        , l_invoice_type_disp      AS "InvoiceType"))
                        -- end modified by Allen Yang
  INTO
    l_parameter
  FROM DUAL;

  --Generate Reports Xml Data
  IF l_no_data_flag='Y'
  THEN
    FND_MESSAGE.SET_NAME('AR','AR_GTA_NO_DATA_FOUND');
    l_no_data_message := FND_MESSAGE.GET();

    SELECT Xmlelement("ConsolidationMappingReport"
                    , Xmlconcat(Xmlelement("ReportFailed",'N')
                              , Xmlelement("FailedWithParameters",'Y')
                              , Xmlelement("FailedMsgWithParameters"
                                         , l_no_data_message)
                              , Xmlelement("RepDate"
                                , ar_gta_trx_util.To_Xsd_Date_String(SYSDATE))
                              , l_parameter))
    INTO
      l_report
    FROM DUAL;
  ELSE
    SELECT Xmlelement("ConsolidationMappingReport"
                    , Xmlconcat(Xmlelement("ReportFailed",'N')
                               , Xmlelement("FailedWithParameters",'N')
                               , Xmlelement("RepDate"
                                 ,ar_gta_trx_util.To_Xsd_Date_String(SYSDATE))
                               , l_parameter
                               , xmlelement("Invoices", l_consolidation_trxs)))
    INTO
      l_report
    FROM DUAL;
  END IF; --l_no_data_flag='Y'

  ar_gta_trx_util.output_conc(l_report.getclobval());

  --logging for debug
  IF (l_proc_level>=l_dbg_level)
  THEN
    FND_LOG.string( l_proc_level
                  , G_MODULE_PREFIX||l_procedure_name||'.end'
                  , 'end procedure');
  END IF; --l_proc_level>=l_dbg_level

EXCEPTION
  WHEN OTHERS THEN
    IF(Fnd_Log.Level_Unexpected >= Fnd_Log.G_Current_Runtime_Level)
    THEN
      Fnd_Log.String( Fnd_Log.Level_Unexpected
                    , G_MODULE_PREFIX || l_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; --Fnd_Log.Level_Unexpected >= Fnd_Log.G_Current_Runtime_Level

END Generate_Consol_Mapping_Rep;

--==========================================================================
--  PROCEDURE NAME:
--
--      Get_Consolidation_Trx               Public
--
--  DESCRIPTION:
--
--       This procedure returns XML data for a given consolidated invoice.
--
--
--  PARAMETERS:
--      In:  p_trx_header_id          invoice header identifier
--
--
--      Out:
--
--  DESIGN REFERENCES:
--      GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--      25-Jul-2009  	Allen Yang        Created.
--      25-Aug-2009   Allen Yang        Modified for bug 8809860
--      02-Sep-2009   Allen Yang        Modified for bug 8848696
--==========================================================================
FUNCTION Get_Consolidation_Trx(p_trx_header_id	  IN  NUMBER)
RETURN XMLTYPE
IS
/* Note: Due to FD change, the meaning of words 'consolidation' and 'consolidated'
         has been reversed in code.
   consolidated  -- invoice which consists of several consolidation invoices
   consolidation -- invoice which is consolidated into a consolidated invoice
*/
l_procedure_name    VARCHAR2(40):='Get_Consolidation_Trx';
l_dbg_level         NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_proc_level        NUMBER:=FND_LOG.LEVEL_PROCEDURE;
l_ret_xmlelement    Xmltype;

BEGIN
  --logging for debug
  IF (l_proc_level>=l_dbg_level)
  THEN
    FND_LOG.string( l_proc_level
                  , G_MODULE_PREFIX||l_procedure_name||'.begin'
                  , 'enter procedure');
  END IF; --(l_proc_level>=l_dbg_level)

  -- modified by Allen Yang 02-Sep-2009 for bug 8848696
  ---------------------------------------------------------------------------
  /*
  SELECT Xmlforest(
         GTA_TRX_NUMBER                          AS "ConsolidationTrxNum"
       , CUSTOMER_ADDRESS_PHONE                  AS "CustAddressPhone"
       , RA_GL_PERIOD                            AS "GLPeriod"
       , BILL_TO_CUSTOMER_NAME                   AS "CustomerName"
       , TP_TAX_REGISTRATION_NUMBER              AS "TaxRegistrationNum"
       , INVOICE_TYPE                            AS "InvoiceType"
       , BANK_ACCOUNT_NAME                       AS "BankName"
       , BANK_ACCOUNT_NUMBER                     AS "BankAccountNum"
       -- modified by Allen Yang 25-Aug-2009 for bug 8809860
       --, ar_gta_trx_util.Get_Gtainvoice_Amount(p_header_id =>
       --                                         p_trx_header_id) AS "Amount")
       , ar_gta_trx_util.Get_Gtainvoice_Amount(p_trx_header_id) AS "Amount")
       -- end modified by Allen
  INTO
    l_ret_xmlelement
  FROM  AR_GTA_TRX_HEADERS_ALL
  WHERE GTA_TRX_HEADER_ID = p_trx_header_id;
  */
  SELECT Xmlforest(
         JGTHA.GTA_TRX_NUMBER                          AS "ConsolidationTrxNum"
       , JGTHA.CUSTOMER_ADDRESS_PHONE                  AS "CustAddressPhone"
       , JGTHA.RA_GL_PERIOD                            AS "GLPeriod"
       , JGTHA.BILL_TO_CUSTOMER_NAME                   AS "CustomerName"
       , JGTHA.TP_TAX_REGISTRATION_NUMBER              AS "TaxRegistrationNum"
       , FLTV.MEANING                                  AS "InvoiceType"
       , JGTHA.BANK_ACCOUNT_NAME                       AS "BankName"
       , JGTHA.BANK_ACCOUNT_NUMBER                     AS "BankAccountNum"
       -- modified by Allen Yang 25-Aug-2009 for bug 8809860
       --, ar_gta_trx_util.Get_Gtainvoice_Amount(p_header_id =>
       --                                         p_trx_header_id) AS "Amount")
       , ar_gta_trx_util.Get_Gtainvoice_Amount(p_trx_header_id) AS "Amount")
       -- end modified by Allen
  INTO
    l_ret_xmlelement
  FROM  AR_GTA_TRX_HEADERS_ALL JGTHA
      , FND_LOOKUP_VALUES_VL FLTV
  WHERE GTA_TRX_HEADER_ID = p_trx_header_id
    AND FLTV.LOOKUP_TYPE = 'AR_GTA_INVOICE_TYPE'
    AND JGTHA.INVOICE_TYPE = FLTV.LOOKUP_CODE;
  -----------------------------------------------------------------------------

  --logging for debug
  IF (l_proc_level>=l_dbg_level)
  THEN
    FND_LOG.string( l_proc_level
                  , G_MODULE_PREFIX||l_procedure_name||'.end'
                  , 'end procedure');
  END IF; --l_proc_level>=l_dbg_level

  RETURN l_ret_xmlelement;

EXCEPTION
  WHEN OTHERS THEN
    IF(Fnd_Log.Level_Unexpected >= Fnd_Log.G_Current_Runtime_Level)
    THEN
      Fnd_Log.String( Fnd_Log.Level_Unexpected
                    , G_MODULE_PREFIX || l_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; --Fnd_Log.Level_Unexpected >= Fnd_Log.G_Current_Runtime_Level
END Get_Consolidation_Trx;

--==========================================================================
--  PROCEDURE NAME:
--
--      Get_Consolidated_Trxs               Public
--
--  DESCRIPTION:
--
--      For a given consolidated invoice, get xml data of its
--      consolidation invoices.
--
--
--  PARAMETERS:
--      In:  p_trx_header_id          invoice header identifier
--
--
--      Out:
--
--  DESIGN REFERENCES:
--      GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--      25-Jul-2009  	Allen Yang        Created.
--      25-Aug-2009   Allen Yang        Modified for bug 8809860
--==========================================================================
FUNCTION Get_Consolidated_Trxs(p_trx_header_id	  IN  NUMBER)
RETURN XMLTYPE
IS
/* Note: Due to FD change, the meaning of words 'consolidation' and 'consolidated'
         has been reversed in code.
   consolidated  -- invoice which consists of several consolidation invoices
   consolidation -- invoice which is consolidated into a consolidated invoice
*/
l_procedure_name    VARCHAR2(40):='Get_Consolidated_Trxs';
l_dbg_level         NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_proc_level        NUMBER:=FND_LOG.LEVEL_PROCEDURE;
l_ret_xmlelement    Xmltype;

BEGIN
  --logging for debug
  IF (l_proc_level>=l_dbg_level)
  THEN
    FND_LOG.string( l_proc_level
                  , G_MODULE_PREFIX||l_procedure_name||'.begin'
                  , 'enter procedure');
  END IF; --(l_proc_level>=l_dbg_level)

  SELECT Xmlelement("ConsolidatedInvoices"
                   , Xmlagg(Xmlelement("ConsolidatedInvoice"
                      ,Xmlforest(jgtha.RA_GL_PERIOD AS "ConsolidatedGLPeriod"
                                ,jgtha.GTA_TRX_NUMBER AS "ConsolidatedTrxNum"
                                ,jgtha.RA_TRX_NUMBER  AS "ARTrxNum"
                                ,rctt.NAME            AS "ARTrxType"
                                ,ar_gta_trx_util.Get_Gtainvoice_Amount
                                -- modified by Allen Yang 25-Aug-2009 for bug 8809860
                                --(p_header_id =>p_trx_header_id)
                                (jgtha.GTA_TRX_HEADER_ID)
                                -- end modified by Allen
                                                   AS "ConsolidatedAmount"))))
  INTO
    l_ret_xmlelement
  FROM
    AR_Gta_Trx_Headers_all jgtha
  , ra_customer_trx_all     rcta
  , ra_cust_trx_types       rctt
  WHERE jgtha.CONSOLIDATION_FLAG = '1'
    AND jgtha.SOURCE = 'AR'
    AND jgtha.Status='CONSOLIDATED'
    AND jgtha.CONSOLIDATION_TRX_NUM =
        (SELECT GTA_TRX_NUMBER
           FROM AR_Gta_Trx_Headers_all
          WHERE GTA_TRX_HEADER_ID = p_trx_header_id)
    AND rctt.CUST_TRX_TYPE_ID = rcta.CUST_TRX_TYPE_ID
    AND rcta.CUSTOMER_TRX_ID = jgtha.RA_TRX_ID;


  --logging for debug
  IF (l_proc_level>=l_dbg_level)
  THEN
    FND_LOG.string( l_proc_level
                  , G_MODULE_PREFIX||l_procedure_name||'.end'
                  , 'end procedure');
  END IF; --l_proc_level>=l_dbg_level

  RETURN l_ret_xmlelement;

EXCEPTION
  WHEN OTHERS THEN
    IF(Fnd_Log.Level_Unexpected >= Fnd_Log.G_Current_Runtime_Level)
    THEN
      Fnd_Log.String( Fnd_Log.Level_Unexpected
                    , G_MODULE_PREFIX || l_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; --Fnd_Log.Level_Unexpected >= Fnd_Log.G_Current_Runtime_Level
END Get_Consolidated_Trxs;
--==========================================================================
--  PROCEDURE NAME:
--
--      Compare_Consolidated_Inv                Public
--
--  DESCRIPTION:
--
--   This Procedure Compare completed consolidated_invs with gt invoice
--
--  PARAMETERS:
--      In:   p_org_id                 Operating unit id
--            p_gta_header_id          GTA invoice header id
--
--     Out:   x_has_difference
--
--
--  DESIGN REFERENCES:
--
--
--  CHANGE HISTORY:
--
--           09-Aug-2009  Yao Zhang   Created.
--===========================================================================
PROCEDURE Compare_Consolidated_Inv
(p_org_id         NUMBER
,p_gta_header_id  NUMBER
,x_has_difference OUT NOCOPY	BOOLEAN
) IS
l_procedure_name             VARCHAR2(50):='Compare_Consolidated_Inv';
l_org_id                     NUMBER;
l_gta_header_id              NUMBER;
l_gta_amount                 NUMBER;
l_gta_taxamount              NUMBER;
l_gta_customer_name          ar_gta_trx_headers_all.bill_to_customer_name%TYPE;
l_gta_taxpayer_id            ar_gta_trx_headers_all.tp_tax_registration_number%TYPE;
l_gta_customer_bank_account  ar_gta_trx_headers_all.bank_account_name_number%TYPE;
l_gta_customer_address_phone ar_gta_trx_headers_all.customer_address_phone%TYPE;
l_gta_invoice_type           ar_gta_trx_headers_all.invoice_type%TYPE;
l_gta_invoice_type_name      VARCHAR2(80);
l_gta_trx_number             ar_gta_trx_headers_all.gta_trx_number%TYPE;

l_gt_amount                  NUMBER;
l_gt_taxamount               NUMBER;
l_gt_customer_name           ar_gta_trx_headers_all.bill_to_customer_name%TYPE;
l_gt_taxpayer_id             ar_gta_trx_headers_all.tp_tax_registration_number%TYPE;
l_gt_customer_bank_account   ar_gta_trx_headers_all.bank_account_name_number%TYPE;
l_gt_customer_address_phone  ar_gta_trx_headers_all.customer_address_phone%TYPE;
l_gt_invoice_type            ar_gta_trx_headers_all.invoice_type%TYPE;
l_gt_invoice_type_name       VARCHAR2(80);
l_gt_invoice_number          ar_gta_trx_headers_all.gt_invoice_number%TYPE;
l_gt_trx_number             ar_gta_trx_headers_all.gta_trx_number%TYPE;

l_amount_attr                fnd_lookup_values.meaning%TYPE;
l_taxamount_attr             fnd_lookup_values.meaning%TYPE;
l_cust_name_attr             fnd_lookup_values.meaning%TYPE;
l_bank_name_account_attr     fnd_lookup_values.meaning%TYPE;
l_address_phone_attr         fnd_lookup_values.meaning%TYPE;
l_taxpayer_id_attr           fnd_lookup_values.meaning%TYPE;
l_invoicetype_attr            fnd_lookup_values.meaning%TYPE;

l_has_difference             BOOLEAN;


CURSOR c_gta_headers IS
SELECT
  AR_GTA_TRX_UTIL.Get_Gtainvoice_Amount(gta.gta_trx_header_id)
  amount
, AR_GTA_TRX_UTIL.Get_Gtainvoice_Tax_Amount(gta.gta_trx_header_id)
  taxamount
, gta.bill_to_customer_name
  customer_name
, gta.tp_tax_registration_number
  tax_registration_number
, gta.bank_account_name_number
  customer_bank_account
, gta.customer_address_phone
  customer_address_phone
, gta.gta_trx_number
,gta.invoice_type invoice_type
,lk.meaning invoice_type_name
FROM
  ar_gta_trx_headers gta, fnd_lookup_values_vl lk
WHERE gta.gta_trx_header_id=l_gta_header_id
  AND gta.invoice_type = lk.lookup_code
  AND lk.lookup_type='AR_GTA_INVOICE_TYPE';

CURSOR c_gt_headers IS
SELECT ar_gta_trx_util.get_gtainvoice_amount(gt.gta_trx_header_id) amount,
       ar_gta_trx_util.get_gtainvoice_tax_amount(gt.gta_trx_header_id) taxamount,
       gt.bill_to_customer_name customer_name,
       gt.tp_tax_registration_number tax_registration_number,
       gt.bank_account_name_number customer_bank_account,
       gt.customer_address_phone customer_address_phone,
       gt.gt_invoice_number,
       gt.invoice_type invoice_type,
       lk.meaning invoice_type_name
  FROM ar_gta_trx_headers gt, fnd_lookup_values_vl lk
 WHERE gt.gta_trx_number IN
       (SELECT gta_trx_number
          FROM ar_gta_trx_headers gta
         WHERE gta.gta_trx_header_id = l_gta_header_id)
   AND gt.SOURCE = 'GT'
   AND gt.invoice_type = lk.lookup_code
   AND lk.lookup_type = 'AR_GTA_INVOICE_TYPE';

BEGIN

  --logging for debug
IF(Fnd_Log.Level_Unexpected >= Fnd_Log.G_Current_Runtime_Level)
THEN
    FND_LOG.string( Fnd_Log.Level_Unexpected
                  , G_MODULE_PREFIX||l_procedure_name||'.begin'
                  , 'enter procedure');
  END IF; --(l_proc_level>=l_dbg_level)

  l_org_id:=p_org_id;
  l_gta_header_id:=p_gta_header_id;
  l_has_difference:=FALSE;

  -- To get meaning of header level attribute lookup code
  SELECT
    flv.meaning
  INTO
    l_amount_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='AMOUNT';

  SELECT
    flv.meaning
  INTO
    l_taxamount_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='VAT_TAX_AMOUNT';

  SELECT
    flv.meaning
  INTO
    l_cust_name_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='CUSTOMER_NAME';

  SELECT
    flv.meaning
  INTO
    l_bank_name_account_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='BANK_NAME_ACCOUNT';

  SELECT
    flv.meaning
  INTO
    l_address_phone_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='ADDRESS_PHONE_NUMBER';

  SELECT
    flv.meaning
  INTO
    l_invoicetype_attr
  FROM
    fnd_lookup_values_vl flv
  WHERE flv.lookup_type='AR_GTA_DISCREPANCY_ATTRIBUTE'
    AND flv.lookup_code='INVOICE_TYPE';



OPEN c_gta_headers;
LOOP
FETCH c_gta_headers INTO
         l_gta_amount
        ,l_gta_taxamount
        ,l_gta_customer_name
        ,l_gta_taxpayer_id
        ,l_gta_customer_bank_account
        ,l_gta_customer_address_phone
        ,l_gta_trx_number
	      ,l_gta_invoice_type
	      ,l_gta_invoice_type_name;
EXIT WHEN c_gta_headers%NOTFOUND;
END LOOP;
CLOSE c_gta_headers;

OPEN c_gt_headers;
LOOP
FETCH c_gt_headers INTO
         l_gt_amount
        ,l_gt_taxamount
        ,l_gt_customer_name
        ,l_gt_taxpayer_id
        ,l_gt_customer_bank_account
        ,l_gt_customer_address_phone
        ,l_gt_invoice_number
	      ,l_gt_invoice_type
	      ,l_gt_invoice_type_name;
EXIT WHEN c_gt_headers%NOTFOUND;
END LOOP;
CLOSE c_gt_headers;
--compare amount
IF l_gta_amount<>l_gt_amount
THEN
  INSERT INTO ar_gta_difference_temp(type
                                     ,ar_header_id
                                     ,attribute
                                     ,ar_value
                                     ,gta_invoice_num
                                     ,gta_value
                                     ,gt_invoice_num
                                     ,gt_value
                                     ,discrepancy
                                     )
                               VALUES('HEADER'
                                     ,l_gta_header_id
                                     ,l_amount_attr
                                     ,NULL
                                     ,l_gta_trx_number
                                     ,l_gta_amount
                                     ,l_gt_invoice_number
                                     ,l_gt_amount
                                     ,l_gta_amount-l_gt_amount
                                     );
     l_has_difference:=TRUE;
END IF;
--compare tax amount
IF l_gta_taxamount<>l_gt_taxamount
THEN
  INSERT INTO ar_gta_difference_temp(type
                                     ,ar_header_id
                                     ,attribute
                                     ,ar_value
                                     ,gta_invoice_num
                                     ,gta_value
                                     ,gt_invoice_num
                                     ,gt_value
                                     ,discrepancy
                                     )
                               VALUES('HEADER'
                                     ,l_gta_header_id
                                     ,l_taxamount_attr
                                     ,NULL
                                     ,l_gta_trx_number
                                     ,l_gta_taxamount
                                     ,l_gt_invoice_number
                                     ,l_gt_taxamount
                                     ,l_gta_taxamount-l_gt_taxamount
                                     );
     l_has_difference:=TRUE;
END IF;
--compare customer name
IF trim(l_gta_customer_name)<>TRIM(l_gt_customer_name)
THEN
  INSERT INTO ar_gta_difference_temp(type
                                     ,ar_header_id
                                     ,attribute
                                     ,ar_value
                                     ,gta_invoice_num
                                     ,gta_value
                                     ,gt_invoice_num
                                     ,gt_value
                                     ,discrepancy
                                     )
                               VALUES('HEADER'
                                     ,l_gta_header_id
                                     ,l_cust_name_attr
                                     ,NULL
                                     ,l_gta_trx_number
                                     ,l_gta_customer_name
                                     ,l_gt_invoice_number
                                     ,l_gt_customer_name
                                     ,NULL
                                     );
     l_has_difference:=TRUE;
END IF;
--compare tax_payer_id
IF trim(l_gta_taxpayer_id)<>TRIM(l_gt_taxpayer_id)
THEN
  INSERT INTO ar_gta_difference_temp(type
                                     ,ar_header_id
                                     ,attribute
                                     ,ar_value
                                     ,gta_invoice_num
                                     ,gta_value
                                     ,gt_invoice_num
                                     ,gt_value
                                     ,discrepancy
                                     )
                               VALUES('HEADER'
                                     ,l_gta_header_id
                                     ,l_taxpayer_id_attr
                                     ,NULL
                                     ,l_gta_trx_number
                                     ,l_gta_taxpayer_id
                                     ,l_gt_invoice_number
                                     ,l_gt_taxpayer_id
                                     ,NULL
                                     );
     l_has_difference:=TRUE;
END IF;

--compare customer_bank_account
IF trim(l_gta_customer_bank_account)<>TRIM(l_gt_customer_bank_account)
THEN
  INSERT INTO ar_gta_difference_temp(type
                                     ,ar_header_id
                                     ,attribute
                                     ,ar_value
                                     ,gta_invoice_num
                                     ,gta_value
                                     ,gt_invoice_num
                                     ,gt_value
                                     ,discrepancy
                                     )
                               VALUES('HEADER'
                                     ,l_gta_header_id
                                     ,l_bank_name_account_attr
                                     ,NULL
                                     ,l_gta_trx_number
                                     ,l_gta_customer_bank_account
                                     ,l_gt_invoice_number
                                     ,l_gt_customer_bank_account
                                     ,NULL
                                     );
     l_has_difference:=TRUE;
END IF;

--compare customer address phone
IF trim(l_gta_customer_address_phone)<>TRIM(l_gt_customer_address_phone)
THEN
  INSERT INTO ar_gta_difference_temp(type
                                     ,ar_header_id
                                     ,attribute
                                     ,ar_value
                                     ,gta_invoice_num
                                     ,gta_value
                                     ,gt_invoice_num
                                     ,gt_value
                                     ,discrepancy
                                     )
                               VALUES('HEADER'
                                     ,l_gta_header_id
                                     ,l_address_phone_attr
                                     ,NULL
                                     ,l_gta_trx_number
                                     ,l_gta_customer_address_phone
                                     ,l_gt_invoice_number
                                     ,l_gt_customer_address_phone
                                     ,NULL
                                     );
     l_has_difference:=TRUE;
END IF;

--compare invoice type
IF trim(l_gta_invoice_type_name)<>TRIM(l_gt_invoice_type_name)
THEN
  INSERT INTO ar_gta_difference_temp(type
                                     ,ar_header_id
                                     ,attribute
                                     ,ar_value
                                     ,gta_invoice_num
                                     ,gta_value
                                     ,gt_invoice_num
                                     ,gt_value
                                     ,discrepancy
                                     )
                               VALUES('HEADER'
                                     ,l_gta_header_id
                                     ,l_invoicetype_attr
                                     ,NULL
                                     ,l_gta_trx_number
                                     ,l_gta_invoice_type_name
                                     ,l_gt_invoice_number
                                     ,l_gt_invoice_type_name
                                     ,NULL
                                     );
     l_has_difference:=TRUE;
END IF;

x_has_difference:=l_has_difference;
EXCEPTION
  WHEN OTHERS THEN
    IF(Fnd_Log.Level_Unexpected >= Fnd_Log.G_Current_Runtime_Level)
    THEN
      Fnd_Log.String( Fnd_Log.Level_Unexpected
                    , G_MODULE_PREFIX || l_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; --Fnd_Log.Level_Unexpected >= Fnd_Log.G_Current_Runtime_Level

END Compare_Consolidated_Inv;

END AR_GTA_REPORTS_PKG;

/
