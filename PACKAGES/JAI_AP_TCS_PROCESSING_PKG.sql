--------------------------------------------------------
--  DDL for Package JAI_AP_TCS_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_TCS_PROCESSING_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ap_tcs_prc.pls 120.1.12000000.1 2007/07/24 06:55:14 rallamse noship $ */

/*  */

/* ----------------------------------------------------------------------------
 FILENAME      : jai_ap_tcs_prc.pls

 Created By    : Bala ji

 Created Date  : 02-FEB-2007

 Bug           : 5631784

 Purpose       : Solution for TCS

 Called from   : Concurrents,
                 JAIATCSC -  India - Generate TCS Certificates

 CHANGE HISTORY:
 -------------------------------------------------------------------------------
 S.No      Date         Author and Details
 -------------------------------------------------------------------------------
  1.       01/02/2007    Created by Bgowrava for forward porting bug#5631784. Version#120.0.
                        This was Directly created from 11i version 115.0
                        Solution for TCS

---------------------------------------------------------------------------- */

  PROCEDURE generate_tcs_certificates
    (
      errbuf                              out            nocopy    varchar2,
      retcode                             out            nocopy    varchar2,
      pd_rgm_from_date                    in             varchar2,
      pd_rgm_to_date                      in             varchar2,
      pv_org_tan_num                      in             varchar2,
      pn_tax_authority_id                 in             number    ,
      pn_tax_authority_site_id            in             number    default null,
      pn_customer_id                        in             number    default null,
      pn_customer_site_id                   in             number    default null
  );

END jai_ap_tcs_processing_pkg;
 

/
