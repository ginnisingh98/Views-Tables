--------------------------------------------------------
--  DDL for Package JAI_CMN_RGM_VAT_ACCNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RGM_VAT_ACCNT_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rgm_vat.pls 120.1.12010000.3 2010/04/21 03:10:54 haoyang ship $ */
/*****************************************************************************************************************************************************************
Created By       : aiyer
Created Date     : 17-Mar-2005
Enhancement Bug  : 4247989
Purpose          : Process the VAT Tax AR records (Invoice,Debit Memo and Credit memo) and populate the jai_rgms_trx_records and gl_interface appropriately.
Called From      : India VAT Invoice Number/Accouting Concurrent Program:-
                   =====================================================
                   Procedure

                   AR Invoice Completion:-
				   =======================
                    Trigger ja_in_loc_ar_hdr_update_trg for Invoice and Debit Memo
					Trigger ja_in_loc_ar_hdr_update_trg_vat for Credit Memo


                   Dependency Due To The Current Bug :
                   This object has been newly created with as a part of the VAT enhancement.
				   Needs to be always released along with the bug 4247989.Lot of Datamodel changes in this enhancement.
				   For details refer base bug 4245089



1. 08-Jun-2005  Version 116.1 jai_cmn_rgm_vat -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

2. 02-Apr-2010  Allen Yang modified for bug 9485355 (12.1.3 non-shippable Enhancement)
    added parameter p_order_line_id in procedure process_order_invoice
    Version 120.1.12010000.2
3. 20-Apr-2010  Allen Yang modified for bug 9602968
   Modified procedure definition of process_order_invoice added 'DEFAULT NULL' for p_order_line_id
   Version 120.1.12010000.3


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent         Dependency On Files       Version   Author   Date         Remarks
Of File                              On Bug/Patchset
jai_cmn_rgm_vat_accnt_pkg_pkg_s.sql.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
115.0                  4247989       IN60106 +                                            Aiyer   17-Mar-2005   4146708 is the release bug for SERVICE/CESS
                                     4146708 +                                                                             enhancement.
									 4245089																	 4245089 - Base bug for VAT Enhancement.

----------------------------------------------------------------------------------------------------------------------------------------------------


*****************************************************************************************************************************************************************/

p_record_debug     VARCHAR2(3); -- File.Sql.35 by Brathod := jai_constants.yes	; --
gv_transaction_type_dflt  CONSTANT VARCHAR2(3) := 'INV' ;

PROCEDURE record_debug_messages
(
  p_message VARCHAR2
);

PROCEDURE process_order_invoice
(
  p_regime_id               IN      JAI_RGM_DEFINITIONS.REGIME_ID%TYPE										           ,
  p_source                  IN      VARCHAR2															                   ,
  p_organization_id         IN      JAI_OM_WSH_LINES_ALL.ORGANIZATION_id%TYPE						   ,
  p_location_id             IN      JAI_OM_WSH_LINES_ALL.LOCATION_ID%TYPE							     ,
  p_delivery_id             IN      JAI_OM_WSH_LINES_ALL.DELIVERY_ID%TYPE							     ,
  -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
  -- 20-Apr-2010, add 'DEFAULT NULL' by Allen Yang for bug 9602968, begin
  p_order_line_id           IN      JAI_OM_WSH_LINES_ALL.ORDER_LINE_ID%TYPE  DEFAULT NULL  ,
  -- 20-Apr-2010, add 'DEFAULT NULL' by Allen Yang for bug 9602968, end
  -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
  p_customer_trx_id         IN      RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE							   ,
  p_transaction_type        IN      RA_CUST_TRX_TYPES.TYPE%TYPE, -- DEFAULT 'INV'   /* This parameter is used only for AR Accounting */ File.Sql.35 by Brathod
  p_vat_invoice_no          IN      JAI_OM_WSH_LINES_ALL.VAT_INVOICE_NO%TYPE						   ,
	p_default_invoice_date    IN      DATE                                                     ,
	p_batch_id                IN      NUMBER  															                   ,
  p_called_from             IN      VARCHAR2										  					                 ,
  p_debug                   IN      VARCHAR2,   -- DEFAULT 'N'	 File.Sql.35 by Brathod
  p_process_flag    OUT NOCOPY      VARCHAR2															                   ,
  p_process_message OUT NOCOPY      VARCHAR2
) ;

END  jai_cmn_rgm_vat_accnt_pkg;

/
