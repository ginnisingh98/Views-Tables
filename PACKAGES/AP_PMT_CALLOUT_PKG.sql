--------------------------------------------------------
--  DDL for Package AP_PMT_CALLOUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PMT_CALLOUT_PKG" AUTHID CURRENT_USER AS
/*$Header: apcnfrms.pls 120.7.12010000.3 2009/02/13 12:19:38 sanjagar ship $ */

   FUNCTION get_user_rate
    ( p_base_currency_code      in varchar2,
      p_payment_currency_code   in varchar2,
      p_checkrun_id             in number) return number;


   FUNCTION get_base_amount
    ( p_base_currency_code      in varchar2,
      p_payment_currency_code   in varchar2,
      p_checkrun_id             in number,
      p_exchange_rate_type      in varchar2,
      p_base_currency_mac       in number,
      p_payment_amount          in number,
      p_base_currency_precision in number,
      p_exchange_date           in date) return number;



   PROCEDURE documents_payable_rejected
     ( p_api_version            IN  NUMBER,
       p_init_msg_list          IN  VARCHAR2,
       p_commit                 IN  VARCHAR2,
       x_return_status          OUT nocopy  VARCHAR2,
       x_msg_count              OUT nocopy NUMBER,
       x_msg_data               OUT nocopy VARCHAR2,
       p_rejected_docs_group_id IN  NUMBER);


   PROCEDURE payments_completed
     ( p_api_version             IN  NUMBER,
       p_init_msg_list           IN  VARCHAR2,
       p_commit                  IN  VARCHAR2,
       x_return_status           OUT nocopy VARCHAR2,
       x_msg_count               OUT nocopy NUMBER,
       x_msg_data                OUT nocopy VARCHAR2,
       p_completed_pmts_group_id IN  NUMBER);

   PROCEDURE payments_cleared
     ( p_api_version            IN  NUMBER,
       p_init_msg_list          IN  VARCHAR2,
       p_commit                 IN  VARCHAR2,
       x_return_status          OUT nocopy VARCHAR2,
       x_msg_count              OUT nocopy  NUMBER,
       x_msg_data               OUT  nocopy VARCHAR2,
       p_group                  IN  NUMBER);

   PROCEDURE payments_uncleared
     ( p_api_version            IN  NUMBER,
       p_init_msg_list          IN  VARCHAR2,
       p_commit                 IN  VARCHAR2,
       x_return_status          OUT nocopy VARCHAR2,
       x_msg_count              OUT nocopy NUMBER,
       x_msg_data               OUT nocopy VARCHAR2,
       p_group                  IN  NUMBER);

   PROCEDURE payment_voided
     ( p_api_version            IN  NUMBER,
       p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
       p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
       p_payment_id             IN  NUMBER,
       p_void_date              IN  DATE,
  --     p_accounting_date        IN  DATE, /* Bug 4775938 */
       x_return_status          OUT nocopy VARCHAR2,
       x_msg_count              OUT nocopy NUMBER,
       x_msg_data               OUT nocopy VARCHAR2);

   PROCEDURE ap_JapanBankChargeHook(
                p_api_version    IN  NUMBER,
                p_init_msg_list  IN  VARCHAR2,
                p_commit         IN  VARCHAR2,
                x_return_status  OUT nocopy VARCHAR2,
                x_msg_count      OUT nocopy NUMBER,
                x_msg_data       OUT nocopy VARCHAR2);


   /* Bug 6756063: Added the following procedures to sync
      up the status of the Payment in Payables and IBY when
      Stop has been initiated and released. */

   PROCEDURE payment_stop_initiated
     ( p_payment_id             IN  NUMBER,
       p_stopped_date           IN  DATE,   --Bug 6957071
       p_stopped_by             IN  NUMBER,  --Bug 6957071
       x_return_status          OUT nocopy VARCHAR2,
       x_msg_count              OUT nocopy NUMBER,
       x_msg_data               OUT nocopy VARCHAR2);

   PROCEDURE payment_stop_released
     ( p_payment_id             IN  NUMBER,
       x_return_status          OUT nocopy VARCHAR2,
       x_msg_count              OUT nocopy NUMBER,
       x_msg_data               OUT nocopy VARCHAR2);

   /* End of fix for bug 6756063 */

   /* Bug7530046 Added a new procedure to implement the hook that IBY calls
      to decide whether voiding of a payment is allowed or not. */

    PROCEDURE void_payment_allowed
     ( p_api_version            IN  NUMBER,
       p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
       p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
       p_payment_id             IN  NUMBER,
       x_return_flag            OUT nocopy VARCHAR2,
       x_return_status          OUT nocopy VARCHAR2,
       x_msg_count              OUT nocopy NUMBER,
       x_msg_data               OUT nocopy VARCHAR2);


END AP_PMT_CALLOUT_PKG;

/
