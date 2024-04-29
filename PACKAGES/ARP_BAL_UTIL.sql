--------------------------------------------------------
--  DDL for Package ARP_BAL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_BAL_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARTUBALS.pls 120.3 2005/10/31 17:58:31 ramenon ship $ */

FUNCTION get_line_balance( p_customer_trx_line_id IN Number,
                           p_extended_amount IN Number
                             DEFAULT NULL,
                           p_cm_customer_trx_line_id IN
                             number
                             DEFAULT NULL )
                           RETURN NUMBER;



FUNCTION get_line_cm( p_prev_customer_trx_line_id IN Number)
                           RETURN NUMBER;



FUNCTION get_commitment_balance( p_customer_trx_id      IN   Number,
                                 p_class                IN   Varchar2,
                                 p_so_source_code       IN  varchar2,
                                 p_oe_installed_flag    IN  varchar2)
                           RETURN NUMBER;


FUNCTION calc_commitment_balance( p_customer_trx_id      IN  Number,
                                 p_class                IN Varchar2,
                                 p_include_oe_trx_flag  IN  varchar2,
                                 p_oe_installed_flag    IN  varchar2,
                                 p_so_source_code       IN  varchar2 )
                           RETURN NUMBER;


FUNCTION get_trx_balance( p_customer_trx_id        IN  Number,
                          p_open_receivables_flag  IN  Varchar2)
                           RETURN NUMBER;


PROCEDURE transaction_balances(p_customer_trx_id             IN  Number,
                               p_open_receivables_flag       IN  Varchar2,
                               p_exchange_rate               IN  Number,
                               p_mode                        IN VARCHAR2,
                               p_currency_mode               IN VARCHAR2,
                               p_line_original              OUT NOCOPY NUMBER,
                               p_line_remaining             OUT NOCOPY NUMBER,
                               p_tax_original               OUT NOCOPY NUMBER,
                               p_tax_remaining              OUT NOCOPY NUMBER,
                               p_freight_original           OUT NOCOPY NUMBER,
                               p_freight_remaining          OUT NOCOPY NUMBER,
                               p_charges_original           OUT NOCOPY NUMBER,
                               p_charges_remaining          OUT NOCOPY NUMBER,
                               p_line_discount              OUT NOCOPY NUMBER,
                               p_tax_discount               OUT NOCOPY NUMBER,
                               p_freight_discount           OUT NOCOPY NUMBER,
                               p_charges_discount           OUT NOCOPY NUMBER,
                               p_total_discount             OUT NOCOPY NUMBER,
                               p_total_original             OUT NOCOPY NUMBER,
                               p_total_remaining            OUT NOCOPY NUMBER,
                               p_line_receipts              OUT NOCOPY NUMBER,
                               p_tax_receipts               OUT NOCOPY NUMBER,
                               p_freight_receipts           OUT NOCOPY NUMBER,
                               p_charges_receipts           OUT NOCOPY NUMBER,
                               p_total_receipts             OUT NOCOPY NUMBER,
                               p_line_credits               OUT NOCOPY NUMBER,
                               p_tax_credits                OUT NOCOPY NUMBER,
                               p_freight_credits            OUT NOCOPY NUMBER,
                               p_total_credits              OUT NOCOPY NUMBER,
                               p_line_adjustments           OUT NOCOPY NUMBER,
                               p_tax_adjustments            OUT NOCOPY NUMBER,
                               p_freight_adjustments        OUT NOCOPY NUMBER,
                               p_charges_adjustments        OUT NOCOPY NUMBER,
                               p_total_adjustments          OUT NOCOPY NUMBER,
                               p_aline_adjustments          OUT NOCOPY NUMBER,
                               p_atax_adjustments           OUT NOCOPY NUMBER,
                               p_afreight_adjustments       OUT NOCOPY NUMBER,
                               p_acharges_adjustments       OUT NOCOPY NUMBER,
                               p_atotal_adjustments         OUT NOCOPY NUMBER,
                               p_base_line_original         OUT NOCOPY NUMBER,
                               p_base_line_remaining        OUT NOCOPY NUMBER,
                               p_base_tax_original          OUT NOCOPY NUMBER,
                               p_base_tax_remaining         OUT NOCOPY NUMBER,
                               p_base_freight_original      OUT NOCOPY NUMBER,
                               p_base_freight_remaining     OUT NOCOPY NUMBER,
                               p_base_charges_original      OUT NOCOPY NUMBER,
                               p_base_charges_remaining     OUT NOCOPY NUMBER,
                               p_base_line_discount         OUT NOCOPY NUMBER,
                               p_base_tax_discount          OUT NOCOPY NUMBER,
                               p_base_freight_discount      OUT NOCOPY NUMBER,
                               p_base_total_discount        OUT NOCOPY NUMBER,
                               p_base_total_original        OUT NOCOPY NUMBER,
                               p_base_total_remaining       OUT NOCOPY NUMBER,
                               p_base_line_receipts         OUT NOCOPY NUMBER,
                               p_base_tax_receipts          OUT NOCOPY NUMBER,
                               p_base_freight_receipts      OUT NOCOPY NUMBER,
                               p_base_charges_receipts      OUT NOCOPY NUMBER,
                               p_base_total_receipts        OUT NOCOPY NUMBER,
                               p_base_line_credits          OUT NOCOPY NUMBER,
                               p_base_tax_credits           OUT NOCOPY NUMBER,
                               p_base_freight_credits       OUT NOCOPY NUMBER,
                               p_base_total_credits         OUT NOCOPY NUMBER,
                               p_base_line_adjustments      OUT NOCOPY NUMBER,
                               p_base_tax_adjustments       OUT NOCOPY NUMBER,
                               p_base_freight_adjustments   OUT NOCOPY NUMBER,
                               p_base_charges_adjustments   OUT NOCOPY NUMBER,
                               p_base_total_adjustments     OUT NOCOPY NUMBER,
                               p_base_aline_adjustments     OUT NOCOPY NUMBER,
                               p_base_atax_adjustments      OUT NOCOPY NUMBER,
                               p_base_afreight_adjustments  OUT NOCOPY NUMBER,
                               p_base_acharges_adjustments  OUT NOCOPY NUMBER,
                               p_base_atotal_adjustments    OUT NOCOPY NUMBER
                             );


PROCEDURE get_summary_trx_balances( p_customer_trx_id       IN Number,
                              p_open_receivables_flag       IN Varchar2,
                              p_line_original              OUT NOCOPY NUMBER,
                              p_line_remaining             OUT NOCOPY NUMBER,
                              p_tax_original               OUT NOCOPY NUMBER,
                              p_tax_remaining              OUT NOCOPY NUMBER,
                              p_freight_original           OUT NOCOPY NUMBER,
                              p_freight_remaining          OUT NOCOPY NUMBER,
                              p_charges_original           OUT NOCOPY NUMBER,
                              p_charges_remaining          OUT NOCOPY NUMBER,
                              p_total_original             OUT NOCOPY NUMBER,
                              p_total_remaining            OUT NOCOPY NUMBER );


FUNCTION get_applied_com_balance( p_customer_trx_id       IN Number,
                                  p_mode                  IN VARCHAR2)
                                RETURN NUMBER;

FUNCTION Line_Level_Activity ( p_customer_trx_id IN Number)
                                 RETURN BOOLEAN;

PROCEDURE trx_line_balances (
      p_customer_trx_id
           IN RA_CUSTOMER_TRX.CUSTOMER_TRX_ID%TYPE  DEFAULT NULL,
      p_line_num               IN         NUMBER DEFAULT NULL,
      p_group_id               IN         NUMBER DEFAULT NULL,
      p_exchange_rate          IN         NUMBER,
      p_line_original          OUT NOCOPY NUMBER,
      p_tax_original           OUT NOCOPY NUMBER,
      p_base_line_original     OUT NOCOPY NUMBER,
      p_base_tax_original      OUT NOCOPY NUMBER,
      p_total_original         OUT NOCOPY NUMBER,
      p_base_total_original    OUT NOCOPY NUMBER,
      p_line_receipts          OUT NOCOPY NUMBER,
      p_tax_receipts           OUT NOCOPY NUMBER,
      p_line_discount          OUT NOCOPY NUMBER,
      p_tax_discount           OUT NOCOPY NUMBER,
      p_base_line_receipts     OUT NOCOPY NUMBER,
      p_base_tax_receipts      OUT NOCOPY NUMBER,
      p_base_line_discount     OUT NOCOPY NUMBER,
      p_base_tax_discount      OUT NOCOPY NUMBER,
      p_freight_original       OUT NOCOPY NUMBER,
      p_base_freight_original  OUT NOCOPY NUMBER,
      p_freight_receipts       OUT NOCOPY NUMBER,
      p_charges_receipts       OUT NOCOPY NUMBER,
      p_base_charges_receipts  OUT NOCOPY NUMBER,
      p_base_freight_receipts  OUT NOCOPY NUMBER,
      p_freight_discount       OUT NOCOPY NUMBER,
      p_base_freight_discount  OUT NOCOPY NUMBER,
      p_total_receipts         OUT NOCOPY NUMBER,
      p_base_total_receipts    OUT NOCOPY NUMBER,
      p_total_discount         OUT NOCOPY NUMBER,
      p_base_total_discount    OUT NOCOPY NUMBER,
      p_line_remaining         OUT NOCOPY NUMBER,
      p_tax_remaining          OUT NOCOPY NUMBER,
      p_freight_remaining      OUT NOCOPY NUMBER,
      p_charges_remaining      OUT NOCOPY NUMBER,
      p_total_remaining        OUT NOCOPY NUMBER,
      p_base_line_remaining    OUT NOCOPY NUMBER,
      p_base_tax_remaining     OUT NOCOPY NUMBER,
      p_base_freight_remaining OUT NOCOPY NUMBER,
      p_base_charges_remaining OUT NOCOPY NUMBER,
      p_base_total_remaining   OUT NOCOPY NUMBER,
      p_line_credits           OUT NOCOPY NUMBER,
      p_tax_credits            OUT NOCOPY NUMBER,
      p_freight_credits        OUT NOCOPY NUMBER,
      p_total_credits          OUT NOCOPY NUMBER,
      p_base_line_credits      OUT NOCOPY NUMBER,
      p_base_tax_credits       OUT NOCOPY NUMBER,
      p_base_freight_credits   OUT NOCOPY NUMBER,
      p_base_total_credits     OUT NOCOPY NUMBER,
      p_line_adjustments          OUT NOCOPY NUMBER,
      p_tax_adjustments           OUT NOCOPY NUMBER,
      p_freight_adjustments       OUT NOCOPY NUMBER,
      p_charges_adjustments       OUT NOCOPY NUMBER,
      p_total_adjustments         OUT NOCOPY NUMBER,
      p_base_line_adjustments     OUT NOCOPY NUMBER,
      p_base_tax_adjustments      OUT NOCOPY NUMBER,
      p_base_freight_adjustments  OUT NOCOPY NUMBER,
      p_base_charges_adjustments  OUT NOCOPY NUMBER,
      p_base_total_adjustments    OUT NOCOPY NUMBER
                             );

END ARP_BAL_UTIL;

 

/
