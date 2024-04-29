--------------------------------------------------------
--  DDL for Package JAI_CMN_RGM_TAX_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RGM_TAX_DIST_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rgm_dist.pls 120.10.12010000.2 2008/10/17 09:49:00 jmeena ship $ */
/***************************************************************************************************
CREATED BY       : ssumaith
CREATED DATE     : 11-JAN-2005
ENHANCEMENT BUG  : 4068911
PURPOSE          : To get the balances , to insert records into repository
CALLED FROM      : JAI_RGM_SETTLEMENT_PKG , JAIRGMDT.fmb , JAIRGMDT.fmb
CHANGE HISTORY
1.   01-NOV-2006  SACSETHI FOR BUG#5631784. FILE VERSION 120.5

		  FORWARD PORTING BUG FROM 11I BUG 4742259
		  NEW ENH: TAX COLLECTION AT SOURCE IN RECEIVABLES
		  Changes -

			Object Type   Object Name    Change                 Description
			----------------------------------------------------------------+
			Procedure     Get_balances   Column Added           Column P_ITEM_CLASSIFICATION  is added
23/04/2007	  bduvarag for the Bug#5879769, file version 120.6
		  Forward porting the changes done in 11i bug#5694855

7-June-2007        ssawant for bug 5662296
		   Forward porting R11 bug 5642053 to R12 bug 5662296.

22-jun2007   kunkumar made changes for 6127194 file version 120.9
                   Added two sh_cess parameters to create_io_register_entry
24-Jul-2007	 CSahoo for bug#6268513, File Version 120.2.12000000.3
						 Corrected the GSCC error.
14-OCT-2008  JMEENA for bug#7445742
			 Incorporate the changes of bug#6835541
***************************************************************************************************/
 procedure get_balances(p_request_id          Number                ,
                        p_balance_date        date                  ,
                        p_called_from         varchar2              ,
                        p_regime_id           Number   Default NULL ,
                        p_regn_no             varchar2 default NULL ,
                        p_regn_id             number   default NULL ,
                        p_org_id              number   default NULL ,
                        p_org_type            varchar2 default NULL ,
                        p_settlement_id       number   default NULL ,
			P_ITEM_CLASSIFICATION VARCHAR2 DEFAULT NULL ,-- Added by sacsethi for bug 5631784 on 30-01-2007
                        p_transfer_type       VARCHAR2 default NULL ,/*Bug 5879769 bduvarag*/
                        p_service_type_code   VARCHAR2 default NULL ,/*Bug 5879769 bduvarag*/
			p_location_id         NUMBER   DEFAULT NULL /*added by ssawant for bug 5662296*/
                        );

 procedure insert_records_into_register(
                                         p_repository_id OUT NOCOPY NUMBER   ,
                                         p_regime_id                  NUMBER   ,
                                         p_from_party_type            VARCHAR2 ,
                                         p_from_party_id              NUMBER   ,
                                         p_from_locn_id               NUMBER   ,
                                         p_from_tax_type              VARCHAR2 ,
                                         p_from_trx_amount            NUMBER   ,
                                         p_to_party_type              VARCHAR2 ,
                                         p_to_party_id                NUMBER   ,
                                         p_to_tax_type                VARCHAR2 ,
                                         p_to_trx_amount     IN OUT NOCOPY NUMBER   ,
                                         p_to_locn_id                 NUMBER   ,
                                         p_called_from                VARCHAR2 ,
                                         p_trx_date                   DATE     ,
                                         p_acct_req                   VARCHAR2 ,
                                         p_source                     VARCHAR2 ,
                                         P_SOURCE_TRX_TYPE            VARCHAR2 ,
                                         P_SOURCE_TABLE_NAME          VARCHAR2 ,
                                         p_source_doc_id              NUMBER   ,
                                         p_settlement_id              NUMBER   ,
                                         p_reference_id               NUMBER   ,
                                         p_process_flag OUT NOCOPY VARCHAR2 ,
                                         p_process_message OUT NOCOPY VARCHAR2 ,
                                         p_accounting_date            Date ,
                                       p_from_service_type          VARCHAR2 default null, -- bduvarag for Bug 5694855
                                       p_to_service_type            VARCHAR2 default null -- bduvarag for Bug 5694855

                                        );

procedure delete_records(p_request_id number);
g_start_date constant date := to_date('01/03/2004','dd/mm/yyyy'); /* This variable is used to store the start date*/
ln_rounding_precision constant number := 4;
-- added, Harshita for Bug 5096787
/* Can be removed..
Added the changes of bug#6835541 by JMEENA for bug#7445742
Removed the comment as it is removed in the mainline version 120.11 for bug#6835541 */
PROCEDURE insert_records_into_temp(
     p_request_id          NUMBER   ,
     p_regime_id           NUMBER   ,
     p_party_type          VARCHAR2 ,
     p_party_id            NUMBER   ,
     p_location_id         NUMBER   ,
     p_bal_date            DATE     ,
     p_tax_type            VARCHAR2 ,
     p_debit_amt           NUMBER   ,
     p_credit_amt          NUMBER   ,
     p_pla_balance         NUMBER default null,
     p_service_type_code   VARCHAR2 DEFAULT NULL -- Bug6835541 Added by Lakshmi Gopalsami (JMEENA bug#7445742)
                                    ) ;

  PROCEDURE calculate_balances_for_io
  (p_regime_id     number ,
   p_balance_date  date   ,
   p_request_id    number,
   p_service_type_code   VARCHAR2 DEFAULT NULL -- Bug6835541 Added by Lakshmi Gopalsami (JMEENA bug#7445742)
  )  ;

PROCEDURE punch_settlement_id
  ( p_regime_id       number ,
    p_settlement_id   number ,
    p_regn_id         number ,
    p_balance_date    date  ,
    p_tan_no          VARCHAR2 DEFAULT NULL, /*6835541*/ --(JMEENA bug#7445742)
    p_org_id          NUMBER    default NULL, /*6835541*/
    p_location_id     NUMBER    default NULL, /*6835541*/
    p_item_classification VARCHAR2 DEFAULT NULL, /*6835541*/
    p_regn_no         VARCHAR2  default NULL  /*6835541*/
  ) ;


PROCEDURE calculate_balances_for_ou
(p_regime_id     number    ,
 p_balance_date  date      ,
 p_request_id    number    ,
 p_org_id        number    ,
 p_org_type      varchar2  ,
 p_regn_id       number    ,
 p_regn_no       varchar2  ,
 p_settlement_id number    ,
 p_called_from   varchar2  ,
 p_location_id   NUMBER DEFAULT NULL, -- Bug6835541 Added by Lakshmi Gopalsami (JMEENA bug#7445742)
 p_service_type_code   VARCHAR2 DEFAULT NULL -- Bug6835541 Added by Lakshmi Gopalsami (JMEENA bug#7445742)
) ;
/*check and remove the above
*/
PROCEDURE create_io_register_entry (
  p_register_type                 IN  JAI_RGM_REGISTRATIONS.ATTRIBUTE_VALUE%TYPE                            ,
  p_tax_type                      IN  VARCHAR2                                                      ,
  p_organization_id               IN  JAI_CMN_RG_23AC_II_TRXS.organization_id%TYPE                       ,
  p_location_id                   IN  JAI_CMN_RG_23AC_II_TRXS.location_id%TYPE                           ,
  p_cr_basic_ed                   IN  JAI_CMN_RG_23AC_II_TRXS.cr_basic_ed%TYPE                           ,
  p_cr_additional_ed              IN  JAI_CMN_RG_23AC_II_TRXS.cr_additional_ed%TYPE                      ,
  p_cr_other_ed                   IN  JAI_CMN_RG_23AC_II_TRXS.cr_other_ed%TYPE                           ,
  p_dr_basic_ed                   IN  JAI_CMN_RG_23AC_II_TRXS.dr_basic_ed%TYPE                           ,
  p_dr_additional_ed              IN  JAI_CMN_RG_23AC_II_TRXS.dr_additional_ed%TYPE                      ,
  p_dr_other_ed                   IN  JAI_CMN_RG_23AC_II_TRXS.dr_other_ed%TYPE                           ,
  p_excise_invoice_no             IN  JAI_CMN_RG_23AC_II_TRXS.excise_invoice_no%TYPE                     ,
  p_remarks                       IN  JAI_CMN_RG_23AC_II_TRXS.remarks%TYPE                               ,
  p_vendor_id                     IN  JAI_CMN_RG_23AC_II_TRXS.vendor_id%TYPE                             ,
  p_vendor_site_id                IN  JAI_CMN_RG_23AC_II_TRXS.vendor_site_id%TYPE                        ,
  p_transaction_date              IN  JAI_CMN_RG_23AC_II_TRXS.transaction_date%TYPE                      ,
  p_charge_account_id             IN  JAI_CMN_RG_23AC_II_TRXS.charge_account_id%TYPE                     ,
  p_other_tax_credit              IN  JAI_CMN_RG_23AC_II_TRXS.other_tax_credit%TYPE                      ,
  p_other_tax_debit               IN  JAI_CMN_RG_23AC_II_TRXS.other_tax_debit%TYPE                       ,
  p_transaction_type              IN  VARCHAR2                                                      ,
  p_transaction_source            IN  VARCHAR2                                                      ,
  p_called_from                   IN  VARCHAR2                                                      ,
  p_simulate_flag                 IN  VARCHAR2                                                      ,
  p_debit_amt                     IN  JAI_CMN_RG_OTHERS.DEBIT%TYPE                                      ,
  p_credit_amt                    IN  JAI_CMN_RG_OTHERS.CREDIT%TYPE                                     ,
  p_sh_cess_debit_amt IN JAI_CMN_RG_OTHERS.DEBIT%TYPE,--Added by kunkumar for bug#6127194
  p_sh_cess_credit_amt  IN JAI_CMN_RG_OTHERS.CREDIT%TYPE,--Added by kunkumar for bug#6127194
  p_inventory_item_id             IN  JAI_CMN_RG_23AC_II_TRXS.INVENTORY_ITEM_ID%TYPE                     ,
  p_receipt_id                    IN  JAI_CMN_RG_23AC_II_TRXS.RECEIPT_REF%TYPE            Default NULL    ,
  p_receipt_date                  IN  JAI_CMN_RG_23AC_II_TRXS.receipt_date%TYPE          Default NULL    ,
  p_excise_invoice_date           IN  JAI_CMN_RG_23AC_II_TRXS.excise_invoice_date%TYPE   Default NULL    ,
  p_customer_id                   IN  JAI_CMN_RG_23AC_II_TRXS.customer_id%TYPE           Default NULL    ,
  p_customer_site_id              IN  JAI_CMN_RG_23AC_II_TRXS.customer_site_id%TYPE      Default NULL    ,
  p_register_id_part_i            IN  JAI_CMN_RG_23AC_II_TRXS.register_id_part_i%TYPE    Default NULL    ,
  p_reference_num                 IN  JAI_CMN_RG_23AC_II_TRXS.reference_num%TYPE         Default NULL    ,
  p_rounding_id                   IN  JAI_CMN_RG_23AC_II_TRXS.rounding_id%TYPE           Default NULL    ,
  p_ref_document_id               IN  JAI_CMN_RG_PLA_TRXS.ref_document_id%TYPE                Default NULL    ,
  p_ref_document_date             IN  JAI_CMN_RG_PLA_TRXS.ref_document_date%TYPE              Default NULL    ,
  p_dr_invoice_id                 IN  JAI_CMN_RG_PLA_TRXS.DR_INVOICE_NO%TYPE                  Default NULL    ,
  p_dr_invoice_date               IN  JAI_CMN_RG_PLA_TRXS.dr_invoice_date%TYPE                Default NULL    ,
  p_bank_branch_id                IN  JAI_CMN_RG_PLA_TRXS.bank_branch_id%TYPE                 Default NULL    ,
  p_entry_date                    IN  JAI_CMN_RG_PLA_TRXS.entry_date%TYPE                     Default NULL    ,
  p_vendor_cust_flag              IN  JAI_CMN_RG_PLA_TRXS.vendor_cust_flag%TYPE               Default NULL    ,
  p_process_flag                  OUT NOCOPY VARCHAR2                                               ,
  p_process_message               OUT NOCOPY VARCHAR2
                                   ) ;

FUNCTION f_get_io_register ( p_party_id           JAI_RGM_BALANCE_T.PARTY_ID%TYPE    ,
                             p_from_party_type    JAI_RGM_BALANCE_T.PARTY_TYPE%TYPE  ,
                             p_to_party_type      JAI_RGM_BALANCE_T.PARTY_TYPE%TYPE
                           )
RETURN VARCHAR2 ;
-- ended, Harshita for Bug 5096787
end jai_cmn_rgm_tax_dist_pkg;

/
