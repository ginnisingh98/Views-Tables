--------------------------------------------------------
--  DDL for Package JAI_AP_TDS_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_TDS_PROCESSING_PKG" AUTHID CURRENT_USER as
/* $Header: jai_ap_tds_prc.pls 120.2.12000000.1 2007/07/24 06:55:18 rallamse ship $ */
/* ----------------------------------------------------------------------------
 FILENAME      : jai_ap_tds_prc.pls

 Created By    : Aparajita

 Created Date  : 21-jul-2005

 Bug           :

 Purpose       : Revamp of TDS certificate and eTDS reporting.

 Called from   : Concurrents,
                 JAIATDSP -  India - Process TDS Payments
                 JAIATDSC -  India - Generate TDS Certificates

 CHANGE HISTORY:
 -------------------------------------------------------------------------------
 S.No      Date         Author and Details
 -------------------------------------------------------------------------------
  1.       21/7/2005    Created by Aparajita for bug#4448293. Version#115.0.

                        Cleanup of TDS certificate and eTDS reporting.
 2.     29/03/2007   bduvarag for bug#5647725,File version 120.1
                       Forward porting the changes done in 11i bug#5647215

 3. 12-06-2007 sacsethi for bug 6119195 file version 120.6

                R12RUP03-ST1: INDIA - PROCESS TDS PAYMENTS GIVES ERROR MESSAGE WHILE SUBMITTING

		Probelem - After execution of Concurrent India TDS Payments , some concurrent execution
		           error was coming - FDPSTP failed due to ORA-01861: literal does not match format string

                Solution - This problem was due to procedure process_tds_payments , Argument pd_tds_payment_from_date ,
		           pd_tds_payment_to_date parameter was of date type , whcih we made it as varchar2 and
			   create two variable with name ld_tds_payment_to_date ,ld_tds_payment_from_date

---------------------------------------------------------------------------- */


  procedure process_tds_payments
  (
    errbuf                              out            nocopy    varchar2,
    retcode                             out            nocopy    varchar2,
    pd_tds_payment_from_date            in             varchar2,  --Date 12-jun-2007 sacsethi for bug 6119195
    pd_tds_payment_to_date              in             varchar2,  --Date 12-jun-2007 sacsethi for bug 6119195
    pv_org_tan_num                      in             varchar2,
    p_section_type                      in             varchar2,/*bduvarag for Bug#5647725*/
    pv_tds_section                      in             varchar2  default null,
    pn_tds_authority_id                 in             number    default null,
    pn_tds_authority_site_id            in             number    default null,
    pn_vendor_id                        in             number    default null,
    pn_vendor_site_id                   in             number    default null,
    pv_regenerate_flag                  in             varchar2  default 'N'
  );

 procedure process_tds_certificates
  (
    errbuf                              out            nocopy    varchar2,
    retcode                             out            nocopy    varchar2,
    pd_tds_payment_from_date            in             varchar2,     --Date 12-jun-2007 sacsethi for bug 6119195
    pd_tds_payment_to_date              in             varchar2,
    pv_org_tan_num                      in             varchar2,
    p_section_type                      in             varchar2,/*bduvarag for Bug#5647725*/
    pv_tds_section                      in             varchar2  default null,
    pn_tds_authority_id                 in             number    default null,
    pn_tds_authority_site_id            in             number    default null,
    pn_vendor_id                        in             number    default null,
    pn_vendor_site_id                   in             number    default null
  );

end jai_ap_tds_processing_pkg;
 

/
