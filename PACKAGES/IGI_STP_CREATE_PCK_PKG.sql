--------------------------------------------------------
--  DDL for Package IGI_STP_CREATE_PCK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_STP_CREATE_PCK_PKG" AUTHID CURRENT_USER AS
-- $Header: igistpcs.pls 120.3.12000000.3 2007/09/24 05:05:37 gkumares ship $
PROCEDURE feed_packages  (p_batch_id                in number,
                          l_package_id              in number,
                          l_package_num             in number,
                          l_org_id                  in number,
                          l_stp_id                  in number,
                          l_site_id                 in number,
                          l_amount                  in number,
                          l_trx_number              in varchar2,
                          l_reference               in varchar2,
                          l_netting_trx_type_id     in number,
                          l_ccid                    in number,
                          l_application             in varchar2,
                          l_trx_type_class          in varchar2,
                          l_currency_code           in varchar2,
                          l_exchange_rate           in number,
                          l_exchange_rate_type      in varchar2,
                          l_exchange_date           in date);

 PROCEDURE Delete_Candidates (p_user_id             in number);

 PROCEDURE Netting          (p_batch_id             in number,
                             p_package_id           in number,
                             p_netting_trx_type_id  in number);

 PROCEDURE AP_Only_Netting (p_batch_id              in number,
                            p_package_id            in number,
                            p_netting_trx_type_id   in number,
                            p_contra_party_id       in number,
                            p_contra_amount         in number,
                            p_org_id                in number);

 PROCEDURE Submit_Netting (l_batch_id               in number,
                           l_contra_party_id        in number,
                           l_contra_amount          in number,
                           l_org_id                 in number);
 PROCEDURE pay_excess_netting (p_batch_id             in number,
                               package_id             in number,
                               p_netting_trx_type_id  in number,
                               p_org_id               in number);
 PROCEDURE sup_reimb_netting (p_batch_id             in number,
                              package_id             in number,
                              p_netting_trx_type_id  in number,
                              p_org_id               in number);

END IGI_STP_CREATE_PCK_PKG;

 

/
