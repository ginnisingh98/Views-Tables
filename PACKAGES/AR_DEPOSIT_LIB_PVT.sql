--------------------------------------------------------
--  DDL for Package AR_DEPOSIT_LIB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_DEPOSIT_LIB_PVT" AUTHID CURRENT_USER AS
/* $Header: ARXDEPLS.pls 115.6 2003/08/27 01:04:07 anukumar noship $    */
--These package variables contain the profile option values.

pg_profile_batch_source       NUMBER;
pg_profile_trxln_excpt_flag   VARCHAR2(240);
pg_profile_doc_seq            VARCHAR2(240);
pg_profile_enable_cc          VARCHAR2(240);
pg_profile_cc_rate_type       VARCHAR2(240);
pg_profile_dsp_inv_rate       VARCHAR2(240);
pg_profile_def_x_rate_type    VARCHAR2(240);
pg_deposit_date               date;

 --*** to get the Id' based on value and entity
FUNCTION Get_Id(  p_entity        IN  VARCHAR2,
                  p_value         IN  VARCHAR2,
                  p_return_status OUT NOCOPY VARCHAR2
               )
               RETURN VARCHAR2 ;


FUNCTION Get_Ship_Via( p_bill_to_customer_id    IN NUMBER,
                       p_bill_to_location       IN VARCHAR2,
                       p_ship_to_customer_id    IN NUMBER,
                       p_ship_to_location       IN VARCHAR2,
                       p_return_status          OUT NOCOPY VARCHAR2
                       )
                       RETURN VARCHAR2 ;

FUNCTION Get_FOB_POINT( p_bill_to_customer_id    IN  NUMBER,
                        p_bill_to_location       IN  VARCHAR2,
                        p_ship_to_customer_id    IN  NUMBER,
                        p_ship_to_location       IN  VARCHAR2,
                        p_return_status          OUT NOCOPY VARCHAR2
                       )
                       RETURN VARCHAR2;

FUNCTION Get_Territory_id(p_bill_to_customer_id    IN  NUMBER,
                          p_bill_to_location       IN  VARCHAR2,
                          p_ship_to_customer_id    IN  NUMBER,
                          p_ship_to_location       IN  VARCHAR2,
                          p_salesrep_id            IN  NUMBER,
                          p_deposit_date           IN  Date ,
                          p_return_status          OUT NOCOPY VARCHAR2
                         )
                         RETURN NUMBER;

FUNCTION Get_Cross_Validated_Id( p_entity        IN  VARCHAR2,
                                 p_number_value  IN  VARCHAR2,
                                 p_name_value    IN  VARCHAR2,
                                 p_return_status OUT NOCOPY VARCHAR2
                                )
                                RETURN VARCHAR2 ;

FUNCTION GET_CONTACT_ID( p_customer_id         IN NUMBER,
                         p_person_first_name   IN VARCHAR2,
                         p_person_last_name    IN VARCHAR2,
                         p_return_status       OUT NOCOPY VARCHAR2
                        )
                        RETURN VARCHAR2 ;


FUNCTION Get_Site_Use_Id(
     p_customer_id    IN  hz_cust_acct_sites.cust_account_id%TYPE,
     p_location       IN  hz_cust_site_uses.location%TYPE,
     p_site_use_code1 IN  hz_cust_site_uses.site_use_code%TYPE DEFAULT NULL,
     p_site_use_code2 IN  hz_cust_site_uses.site_use_code%TYPE DEFAULT  NULL,
     p_return_status  OUT NOCOPY VARCHAR2)
RETURN hz_cust_site_uses.site_use_id%type ;

PROCEDURE Default_deposit_ids(
     x_salesrep_id   		    IN OUT NOCOPY  NUMBER,
     p_salesrep_name 		    IN      VARCHAR2  DEFAULT NULL,
     x_term_id     		    IN OUT  NOCOPY    NUMBER ,
     p_term_name     		    IN      VARCHAR2  DEFAULT NULL,
     x_batch_source_id              IN OUT NOCOPY  NUMBER,
     p_batch_source_name            IN      ra_batch_sources.name%type,
     x_cust_trx_type_id             IN OUT NOCOPY  NUMBER,
     p_cust_trx_type                IN      varchar2,
     x_bill_to_customer_id          IN OUT NOCOPY  NUMBER,
     x_bill_to_customer_site_use_id IN OUT NOCOPY  hz_cust_site_uses.site_use_id%TYPE,
     p_bill_to_customer_name        IN      hz_parties.party_name%TYPE,
     p_bill_to_customer_number      IN
                        hz_cust_accounts.account_number%TYPE,
     p_bill_to_location             IN OUT NOCOPY  hz_cust_site_uses.location%type,
     x_bill_to_contact_id           IN OUT NOCOPY  NUMBER,
     p_bill_to_contact_first_name   IN      VARCHAR2,
     p_bill_to_contact_last_name    IN      VARCHAR2,
     x_ship_to_customer_id          IN OUT NOCOPY  NUMBER,
     x_ship_to_customer_site_use_id IN OUT NOCOPY  hz_cust_site_uses.site_use_id%TYPE,
     p_ship_to_customer_name        IN      hz_parties.party_name%TYPE,
     p_ship_to_customer_number      IN
                        hz_cust_accounts.account_number%TYPE,
     p_ship_to_location             IN OUT NOCOPY  hz_cust_site_uses.location%type,
     x_ship_to_contact_id           IN OUT NOCOPY  NUMBER,
     p_ship_to_contact_first_name   IN      VARCHAR2,
     p_ship_to_contact_last_name    IN      VARCHAR2,
     p_usr_currency_code            IN      fnd_currencies_vl.name%TYPE,
     p_usr_exchange_rate_type       IN
                       gl_daily_conversion_types.user_conversion_type%TYPE,
     x_currency_code                IN OUT NOCOPY  ar_cash_receipts.currency_code%TYPE,
     x_exchange_rate_type           IN OUT NOCOPY
                       ar_cash_receipts.exchange_rate_type%TYPE,
     x_remit_to_address_id          IN OUT NOCOPY  NUMBER ,
     p_cust_location_site_num       IN      VARCHAR2,
     x_sold_to_customer_id          IN OUT NOCOPY  NUMBER,
     p_sold_to_customer_name        IN      VARCHAR2,
     p_sold_to_customer_number      IN      VARCHAR2,
     x_paying_customer_id           IN OUT NOCOPY  NUMBER ,
     x_paying_customer_site_use_id  IN OUT NOCOPY  hz_cust_site_uses.site_use_id%TYPE,
     p_paying_customer_name         IN      VARCHAR2,
     p_paying_customer_number       IN      VARCHAR2,
     p_paying_location              IN      VARCHAR2,
     x_receipt_method_id            IN OUT NOCOPY  NUMBER ,
     p_receipt_method_name          IN OUT NOCOPY  VARCHAR2,
     x_cust_bank_account_id         IN OUT NOCOPY  NUMBER,
     p_cust_bank_account_name       IN      VARCHAR2,
     p_cust_bank_account_number     IN      VARCHAR2,
     x_memo_line_id                 IN OUT NOCOPY  NUMBER,
     p_memo_line_name               IN      VARCHAR2,
     x_inventory_id                 IN OUT NOCOPY  NUMBER,
     p_deposit_number               IN  VARCHAR2,
     p_deposit_date                 IN  DATE,
     p_return_status                OUT NOCOPY     VARCHAR2
                              );


PROCEDURE Get_deposit_Defaults(
          p_currency_code          IN OUT NOCOPY
                           ra_customer_trx.invoice_currency_code%TYPE,
          p_exchange_rate_type     IN OUT NOCOPY
                           ra_customer_trx.exchange_rate_type%TYPE,
          p_exchange_rate          IN OUT NOCOPY ra_customer_trx.exchange_rate%TYPE,
          p_exchange_rate_date     IN OUT NOCOPY ra_customer_trx.exchange_date%TYPE,
          p_start_date_commitmenmt IN OUT NOCOPY DATE,
          p_end_date_commitmenmt   IN OUT NOCOPY DATE,
          p_amount                 IN OUT NOCOPY ar_cash_receipts.amount%TYPE,
          p_deposit_date           IN OUT NOCOPY DATE,
          p_gl_date                IN OUT NOCOPY DATE,
          p_bill_to_customer_id    IN     NUMBER,
          p_bill_to_site_use_id    IN     NUMBER,
          p_ship_to_customer_id    IN     NUMBER,
          p_ship_to_site_use_id    IN     NUMBER,
          p_salesrep_id            OUT NOCOPY    NUMBER,
          p_bill_to_contact_id     OUT NOCOPY    NUMBER,
          p_called_from            IN     VARCHAR2,
          p_return_status          OUT NOCOPY    VARCHAR2
           );

PROCEDURE  get_doc_seq(p_application_id    IN     NUMBER,
                      p_document_name      IN     VARCHAR2,
                      p_sob_id             IN     NUMBER,
                      p_met_code	   IN     CHAR,
                      p_trx_date           IN     DATE,
                      p_doc_sequence_value IN OUT NOCOPY NUMBER,
                      p_doc_sequence_id    OUT NOCOPY    NUMBER,
                      p_return_status      OUT NOCOPY    VARCHAR2
                      );

PROCEDURE Validate_Desc_Flexfield(
                          p_desc_flex_rec  IN OUT NOCOPY  ar_deposit_api_pub.attr_rec_type,
                          p_desc_flex_name IN      VARCHAR2,
                          p_return_status  IN OUT NOCOPY  varchar2
                         );
END ar_deposit_lib_pvt;

 

/
