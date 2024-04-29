--------------------------------------------------------
--  DDL for Package ARP_ETAX_SERVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ETAX_SERVICES_PKG" AUTHID CURRENT_USER AS
/* $Header: AREBTSRS.pls 120.4.12010000.3 2009/12/23 13:36:05 spdixit ship $ */

FUNCTION Calculate( p_customer_trx_id IN NUMBER,
                    p_cust_trx_line_id IN NUMBER,
                    p_action IN VARCHAR2,
                    p_line_level_action IN VARCHAR2) RETURN BOOLEAN;

PROCEDURE populate_ebt_plsql_tables(
                p_customer_trx_id IN NUMBER,
                p_customer_trx_line_id  IN NUMBER,
                p_event_type_code IN VARCHAR2,
                p_event_class_code IN VARCHAR2,
                p_line_level_action IN VARCHAR2,
	  	p_tax_amount  IN NUMBER DEFAULT NULL );

PROCEDURE set_line_flags(
              p_customer_trx_line_id        IN  NUMBER,
              p_line_rec                    IN  ra_customer_trx_lines%rowtype,
              p_inventory_item_changed      OUT NOCOPY boolean,
              p_memo_line_changed           OUT NOCOPY boolean,
              p_quantity_changed            OUT NOCOPY boolean,
              p_extended_amount_changed     OUT NOCOPY boolean,
              p_tax_exempt_flag_changed     OUT NOCOPY boolean,
              p_tax_exempt_reason_changed   OUT NOCOPY boolean,
              p_tax_exempt_cert_changed     OUT NOCOPY boolean,
              p_tax_code_changed            OUT NOCOPY boolean,
              p_warehouse_flag_changed      OUT NOCOPY boolean,
              p_ship_to_changed             OUT NOCOPY boolean );

PROCEDURE delete_tax_f_ctl_id( p_customer_trx_line_id IN Number);

FUNCTION Mark_Tax_Lines_Deleted( p_customer_trx_line_id IN Number,
                                p_customer_trx_id      IN Number)
                        RETURN BOOLEAN;

PROCEDURE before_update_line(
              p_customer_trx_line_id   IN Number,
              p_line_rec               IN ra_customer_trx_lines%rowtype,
              p_recalc_tax            OUT NOCOPY BOOLEAN );

PROCEDURE before_delete_line(
              p_customer_trx_line_id IN Number,
              p_customer_trx_id      IN Number);

PROCEDURE print_ebt_plsql_vars;

PROCEDURE Line_det_factors ( p_customer_trx_line_id IN Number,
                             p_customer_trx_id      IN Number,
                             p_mode                 IN VARCHAR2,
			     p_tax_amount           IN NUMBER DEFAULT NULL);

PROCEDURE Header_det_factors ( p_customer_trx_id  IN Number,
                               p_mode             IN VARCHAR2,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2 );

PROCEDURE Calculate_tax (p_customer_trx_id IN NUMBER,
                         p_action IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2 );

FUNCTION Get_Tax_Action (p_customer_trx_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE Override_Tax_Lines ( p_customer_trx_id   IN NUMBER,
                               p_action            IN VARCHAR2,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2,
                               p_event_id          IN NUMBER,
                               p_override_status   IN VARCHAR2);

FUNCTION is_tax_update_allowed (p_customer_trx_id IN NUMBER) RETURN BOOLEAN;

PROCEDURE validate_for_tax ( p_customer_trx_id IN NUMBER,
                             p_error_mode      IN VARCHAR2,
                             p_valid_for_tax   OUT NOCOPY VARCHAR2,
                             p_number_of_errors OUT NOCOPY NUMBER);

PROCEDURE update_exchange_info (p_customer_trx_id    IN NUMBER,
                                p_exchange_rate      IN NUMBER,
                                p_exchange_date      IN DATE,
                                p_exchange_rate_type IN VARCHAR2);

PROCEDURE copy_inv_tax_dists(p_customer_trx_id IN number);

END ARP_ETAX_SERVICES_PKG;


/
