--------------------------------------------------------
--  DDL for Package JAI_AR_RGM_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AR_RGM_PROCESSING_PKG" 
/* $Header: jai_ar_rgm_proc.pls 120.3 2007/05/14 14:19:13 csahoo ship $ */

/***********************************************************************************************************************************************
Created By       : aiyer
Created Date     : 27-jan-2005
Enhancement Bug  : 4146634
Purpose          : Process the Service Tax AR records (Invoices,Credit memo's and Cash Receipts Applications) and populate
                   the jai_rgm_trx_refs and jai_rgms_trx_records appropriately.
Called From      : jai_rgm_trx_processing.process_batch

                   Dependency Due To The Current Bug :
                   This object has been newly created with AUTHID CURRENT_USER as a part of the service tax enhancement.
                   Needs to be always released along with the bug 4146708.

Change History: -
=================
1  20-Feb-2005  aiyer - Bug # 4193633 - File Version# 115.1
   Issue
    The tax earned and unearned discount are not getting apportioned properly of service type of taxes and hence the India - Service Tax concurrent
    ends up in a warning for records with these issues

   Fix
    The procedure get_ar_tax_disc_accnt has been modified for the fix of this bug.
    Please refer the change history of the package body for the details of this bug

   Dependency Due To This Bug:
    Dependency exists due to specification change of the current procedure.
    Always sent the following packages together:-

    1. jai_rgm_process_ar_taxes_pkg_s.sql          (115.1)
    2. jai_rgm_process_ar_taxes_pkg_b.sql          (115.1)
    3. jai_rgm_trx_recording_pkg_s.sql version     (115.1)
    4. jai_rgm_trx_recording_pkg_b.sql version     (115.1)


2. 08-Jun-2005  Version 116.1 jai_ar_rgm_proc -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.


3.   14-May-2005      CSahoo for bug#5879769. File Version 120.3
											Forward porting of 11i BUG#5694855
	    								SERVICE TAX BY INVENTORY ORGANIZATION AND SERVICE TYPE SOLUTION

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent         Dependency On Files       Version   Author   Date         Remarks
Of File                              On Bug/Patchset
jai_rgm_process_ar_taxes_pkg_b.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
115.1                  4146634       IN60105D2 +                                            Aiyer   27-Jan-2005   4146708 is the release bug
                                     4146708                                                                      for SERVICE/CESS enhancement release

----------------------------------------------------------------------------------------------------------------------------------------------------
********************************************************************************************************************************************************/

AS

  procedure get_regime_info        (   p_regime_code                           JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE                                ,
                         p_tax_type_code                         JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE                               ,
                         p_regime_id OUT NOCOPY JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                                  ,
                         p_error_flag OUT NOCOPY VARCHAR2                                                    ,
                         p_error_message OUT NOCOPY VARCHAR2
                     );

  procedure get_ar_tax_disc_accnt   (    p_receivable_application_id             AR_RECEIVABLE_APPLICATIONS_ALL.RECEIVABLE_APPLICATION_ID%TYPE   ,
                         p_org_id                                AR_RECEIVABLES_TRX_ALL.ORG_ID%TYPE                              ,
                                             p_total_disc_amount                     JAI_RGM_TRX_REFS.DISCOUNTED_AMOUNT%TYPE                         ,
                         p_tax_ediscounted OUT NOCOPY AR_RECEIVABLE_APPLICATIONS_ALL.TAX_EDISCOUNTED%TYPE             ,
                         p_earned_disc_ccid OUT NOCOPY AR_RECEIVABLES_TRX_ALL.CODE_COMBINATION_ID%TYPE                 ,
                         p_tax_uediscounted OUT NOCOPY AR_RECEIVABLE_APPLICATIONS_ALL.TAX_UEDISCOUNTED%TYPE            ,
                         p_unearned_disc_ccid OUT NOCOPY AR_RECEIVABLES_TRX_ALL.CODE_COMBINATION_ID%TYPE                 ,
                         p_process_flag OUT NOCOPY VARCHAR2                                                        ,
                         p_process_message OUT NOCOPY VARCHAR2
                    );

  procedure populate_inv_cm_references  (   p_regime_id           IN    JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                    ,
                                            p_organization_type       IN    JAI_RGM_PARTIES.ORGANIZATION_TYPE%TYPE              ,
                                            p_from_date           IN    DATE                              ,
                                            p_to_date           IN    DATE                              ,
                                            p_org_id            IN    RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE                 ,
                                            p_batch_id            IN    JAI_RGM_TRX_REFS.BATCH_ID%TYPE                  ,
                                            p_source            IN    varchar2, --File.Sql.35 Cbabu  jai_constants.SOURCE_AR%TYPE                  ,
                                            p_process_flag OUT NOCOPY VARCHAR2                            ,
                                            p_process_message OUT NOCOPY VARCHAR2,
                                            p_organization_id IN JAI_RGM_PARTIES.ORGANIZATION_ID%TYPE DEFAULT NULL
                                        );

  procedure delete_non_existant_cm      ( p_regime_id          IN  JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                  ,
                                          p_organization_type  IN  JAI_RGM_PARTIES.ORGANIZATION_TYPE%TYPE      ,
                                          p_from_date          IN  DATE                                        ,
                                          p_to_date            IN  DATE                                        ,
                                          p_org_id             IN  RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE             ,
                                          p_source             IN  varchar2, --File.Sql.35 Cbabu  jai_constants.SOURCE_AR%TYPE                ,
                                          p_batch_id           IN  JAI_RGM_TRX_REFS.BATCH_ID%TYPE              ,
                                          p_process_flag OUT NOCOPY VARCHAR2                                    ,
                                          p_process_message OUT NOCOPY VARCHAR2
                                       ,p_organization_id   IN JAI_RGM_PARTIES.ORGANIZATION_ID%TYPE DEFAULT NULL );

  procedure populate_cm_app             (   p_regime_id          IN  JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                  ,
                                            p_organization_type  IN  JAI_RGM_PARTIES.ORGANIZATION_TYPE%TYPE      ,
                                            p_from_date          IN  DATE                                        ,
                                            p_to_date            IN  DATE                                        ,
                                            p_org_id             IN  RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE             ,
                                            p_source             IN  varchar2, --File.Sql.35 Cbabu  jai_constants.SOURCE_AR%TYPE        ,
                                            p_batch_id           IN  JAI_RGM_TRX_REFS.BATCH_ID%TYPE              ,
                                            p_process_flag OUT NOCOPY VARCHAR2                                    ,
                                            p_process_message OUT NOCOPY VARCHAR2
                                       ,p_organization_id JAI_RGM_PARTIES.ORGANIZATION_ID%TYPE DEFAULT NULL );

  procedure populate_receipt_records    (   p_regime_id          IN  JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                  ,
                                            p_organization_type  IN  JAI_RGM_PARTIES.ORGANIZATION_TYPE%TYPE      ,
                                            p_from_date          IN  DATE                                        ,
                                            p_to_date            IN  DATE                                        ,
                                            p_org_id             IN  RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE             ,
                                            p_source             IN  varchar2, --File.Sql.35 Cbabu  JAI_CONSTANTS.SOURCE_AR%TYPE        ,
                                            p_batch_id           IN  JAI_RGM_TRX_REFS.BATCH_ID%TYPE              ,
                                            p_process_flag OUT NOCOPY VARCHAR2                                    ,
                                            p_process_message OUT NOCOPY VARCHAR2
                                        ,p_organization_id IN JAI_RGM_PARTIES.ORGANIZATION_ID%TYPE DEFAULT NULL);

  procedure process_records             (   p_regime_id          IN  JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                  ,
                                            p_organization_type  IN  JAI_RGM_PARTIES.ORGANIZATION_TYPE%TYPE      ,
                                            p_from_date          IN  DATE                                        ,
                                            p_to_date            IN  DATE                                        ,
                                            p_org_id             IN  RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE             ,
                                            p_batch_id           IN  JAI_RGM_TRX_REFS.BATCH_ID%TYPE              ,
                                            p_process_flag OUT NOCOPY VARCHAR2                                    ,
                                            p_process_message OUT NOCOPY VARCHAR2																	,
                                            p_organization_id     IN JAI_RGM_PARTIES.ORGANIZATION_ID%TYPE DEFAULT NULL /*5879769*/
                                        );

END jai_ar_rgm_processing_pkg ;

/
