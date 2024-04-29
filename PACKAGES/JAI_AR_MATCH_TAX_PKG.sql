--------------------------------------------------------
--  DDL for Package JAI_AR_MATCH_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AR_MATCH_TAX_PKG" 
/* $Header: jai_ar_match_tax.pls 120.8.12010000.2 2010/01/27 09:15:18 erma ship $ */
AUTHID CURRENT_USER AS
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     jai_ar_match_tax.pls                                              |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     This package is mainly used for posting the                       |
--|     taxes, VAT/excise invoice num to base AR table.                   |
--|                                                                       |
--| TDD REFERENCE                                                         |
--|        The procedure "display_vat_invoice_no" is referenced by        |
--|        the "VAT Invoice Number on AR Invoice Technical Design.doc"    |
--|                                                                       |
--|                                                                       |
--| PURPOSE                                                               |
--|     PROCEDURE process_batch                                           |
--|     PROCEDURE process_from_order_line                                 |
--|     PROCEDURE process_manual_invoice                                  |
--|     PROCEDURE acct_inclu_taxes                                        |
--|     PROCEDURE display_vat_invoice_no is used for updating the         |
--|     reference field in AR transaction workbench to show the           |
--|     VAT/Excise invoice numbers                                        |
--|                                                                       |
--| HISTORY                                                               |
--|     08-Jun-2005  Version 116.1 jai_ar_match_tax -Object is Modified   |
--|                  to refer to New DB Entity names in place of Old DB   |
--|                  Entity Names as required for CASE COMPLAINCE.        |
--|                                                                       |
--|     25-Apr-2007  cbabu for Bug#6012570 (5876390), File Version        |
--|                  120.2 (115.3) FP: Project billing implementation.    |
--|                                                                       |
--|     21-Aug-2007  brathod for Bug# 6012570, File Version 120.6         |
--|                  Reimplemented the Project Billing changes by         |
--|                  removing the comments                                |
--|                                                                       |
--|     19-Jan-2010  Bo Li for VAT/Excise Number shown in AR workbench ER |
--|                  Add a procedure display_vat_invoice_no and           |
--|                  Bug 9303168# can  be tracked                         |
--|                                                                       |
--+======================================================================*/

  PROCEDURE process_batch (
      ERRBUF OUT NOCOPY VARCHAR2,
      RETCODE OUT NOCOPY VARCHAR2,
      P_ORG_ID   IN NUMBER,
      p_all_orgs IN Varchar2
      ,p_debug   in varchar2 default 'N'
     --commented by kunkumar for bug#6066813
     , p_called_from  IN VARCHAR2  default null /* parameter added for bug#6012570 (5876390) */ -- revoked the comments for 6012570
  );

  PROCEDURE process_from_order_line(
          p_customer_trx_id  IN     NUMBER                                ,
	  p_debug                       IN          VARCHAR2 DEFAULT 'N',
          p_process_status              OUT NOCOPY  VARCHAR2,
          p_process_message             OUT NOCOPY  VARCHAR2
            );

  PROCEDURE process_manual_invoice(ERRBUF OUT NOCOPY VARCHAR2,
         RETCODE OUT NOCOPY VARCHAR2,
         P_CUSTOMER_TRX_ID  IN NUMBER,
         P_LINK_LINE_ID IN NUMBER);
/*Start commented by kunkumar for bug#6066813
   following function added for bug#6012570 (5876390) */ -- revoked the comments, 6012570
  function is_this_projects_context(pv_context in varchar2) return varchar2;
 -- End commented by kunkumar*/


  -- Added by Jia Li on tax inclusive computation on 2007/11/30
  ------------------------------------------------------
  PROCEDURE acct_inclu_taxes
  ( pn_customer_trx_id  IN  NUMBER
  , pn_org_id           IN  NUMBER
  , pn_cust_trx_type_id IN  NUMBER
  , xv_process_flag     OUT NOCOPY VARCHAR2
  , xv_process_message  OUT NOCOPY VARCHAR2
  );
  ------------------------------------------------------

  --==========================================================================
--  PROCEDURE NAME:
--    Display_Vat_Invoice_No                        Public
--
--  DESCRIPTION:
--    This procedure is written that update the ra_customer_trx_all ct_reference column
--  to display the VAT/Excise Number in AR
--
--  ER NAME/BUG#
--    VAT/Excise Number shown in AR transaction workbench'
--    Bug 9303168
--
--  PARAMETERS:
--      In:  pn_customer_trx_id            Indicates the customer trx id
--           pv_excise_invoice_no          Indicates the excise invoice number
--           pv_vat_invoice_no             Indicates vat invoice number
--
--
--  DESIGN REFERENCES:
--       TD named "VAT Invoice Number on AR Invoice Technical Design.doc" has been
--     referenced in the section 6.1
--
--  CALL FROM
--       JAI_AR_MATCH_TAX_PKG.process_batch
--       JAI_AR_TRX.update_excise_invoice_no
--       JAI_AR_TRX.update_reference
--
--  CHANGE HISTORY:
--  19-Jan-2010                Created by Bo Li

--==========================================================================
  -- Added by Bo Li for VAT/Excise Number shown in AR workbench on 19-JAN-2010 and in Bug 9303168# ,Begin
  -------------------------------------------------------------------------------------------------------
  PROCEDURE display_vat_invoice_no
  ( pn_customer_trx_id   IN NUMBER
  , pv_excise_invoice_no IN VARCHAR2
  , pv_vat_invoice_no    IN VARCHAR2
  );
  --------------------------------------------------------------------------------------------------------
  -- Added by Bo Li for VAT/Excise Number shown in AR workbench on 19-JAN-2010 Bug 9303168# can,End
END jai_ar_match_tax_pkg;

/
