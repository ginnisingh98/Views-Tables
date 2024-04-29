--------------------------------------------------------
--  DDL for Package CSTPPACQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPACQ" AUTHID CURRENT_USER AS
/* $Header: CSTPACQS.pls 120.1.12010000.2 2010/05/01 11:30:48 lchevala ship $ */

PROCEDURE acq_cost_processor(
        i_period        IN      NUMBER,
        i_start_date    IN      DATE,
        i_end_date      IN      DATE,
        i_cost_type_id  IN      NUMBER,
        i_cost_group_id IN      NUMBER,
        i_user_id       IN      NUMBER,
        i_login_id      IN      NUMBER,
        i_req_id        IN      NUMBER,
        i_prog_id       IN      NUMBER,
        i_prog_appl_id  IN      NUMBER,
        o_err_num       OUT NOCOPY     NUMBER,
        o_err_code      OUT NOCOPY     VARCHAR2,
        o_err_msg       OUT NOCOPY     VARCHAR2,
        i_source_flag   IN      NUMBER  DEFAULT 1,
        i_receipt_no    IN      NUMBER  DEFAULT NULL,
        i_invoice_no    IN      NUMBER  DEFAULT NULL,
        i_adj_account   IN      NUMBER  DEFAULT NULL);

FUNCTION get_nqr(
	i_transaction_id 	IN 	NUMBER,
        i_source_flag           IN      NUMBER,
        i_start_date            IN      DATE,
        i_end_date              IN      DATE,
        i_res_flag              IN      NUMBER,
	o_err_num		OUT NOCOPY	NUMBER) RETURN NUMBER;

PROCEDURE get_charge_allocs (
        i_hdr           IN      NUMBER,
        i_item_dist     IN      NUMBER,
        i_start_date    IN      DATE,
        i_end_date      IN      DATE,
        i_res_flag      IN      NUMBER,
        i_user_id       IN      NUMBER,
        i_login_id      IN      NUMBER,
        i_req_id        IN      NUMBER,
        i_prog_id       IN      NUMBER,
        i_prog_appl_id  IN      NUMBER,
        o_err_num               OUT NOCOPY     NUMBER,
        o_err_code              OUT NOCOPY     VARCHAR2,
        o_err_msg               OUT NOCOPY     VARCHAR2);

Procedure get_charge_allocs_for_acqadj(
        i_hdr           IN      NUMBER,
        i_item_dist     IN      NUMBER,
        l_start_date    IN      DATE,
        l_end_date      IN      DATE,
        i_user_id       IN      NUMBER,
        i_login_id      IN      NUMBER,
        i_req_id        IN      NUMBER,
        i_prog_id       IN      NUMBER,
        i_prog_appl_id  IN      NUMBER,
        o_err_num               OUT NOCOPY     NUMBER,
        o_err_code              OUT NOCOPY     VARCHAR2,
        o_err_msg               OUT NOCOPY     VARCHAR2);


PROCEDURE compute_acq_cost (
        i_header        IN      NUMBER,
        i_nqr           IN      NUMBER,
        i_po_line_loc   IN      NUMBER,
        i_po_price      IN      NUMBER,
        i_primary_uom   IN      VARCHAR2,
        i_rate          IN      NUMBER,
        i_po_uom        IN      VARCHAR2,
        i_item          IN      NUMBER,
        i_user_id       IN      NUMBER,
        i_login_id      IN      NUMBER,
        i_req_id        IN      NUMBER,
        i_prog_id       IN      NUMBER,
        i_prog_appl_id  IN      NUMBER,
        o_err_num               OUT NOCOPY     NUMBER,
        o_err_code              OUT NOCOPY     VARCHAR2,
        o_err_msg               OUT NOCOPY     VARCHAR2);

Procedure compute_acq_cost_acqadj(
        i_header        IN      NUMBER,
        i_nqr           IN      NUMBER,
        i_po_line_loc   IN      NUMBER,
        i_po_price      IN      NUMBER,
        i_primary_uom   IN      VARCHAR2,
        i_rate          IN      NUMBER,
        i_po_uom        IN      VARCHAR2,
        i_item          IN      NUMBER,
        i_pac_period_id IN      NUMBER,
        i_cost_group_id IN      NUMBER,
        i_org_id        IN      NUMBER,
        i_cost_type_id  IN      NUMBER,
        i_adj_account   IN      NUMBER,
        i_user_id       IN      NUMBER,
        i_login_id      IN      NUMBER,
        i_req_id        IN      NUMBER,
        i_prog_id       IN      NUMBER,
        i_prog_appl_id  IN      NUMBER,
        o_err_num               OUT NOCOPY     NUMBER,
        o_err_code              OUT NOCOPY     VARCHAR2,
        o_err_msg               OUT NOCOPY     VARCHAR2);


PROCEDURE get_acq_cost (
   	i_cost_group_id 	IN 	NUMBER,
   	i_txn_id 		IN 	NUMBER,
   	i_cost_type_id 		IN 	NUMBER,
	i_wip_inv_flag		IN	VARCHAR2,
	o_acq_cost		OUT NOCOPY	NUMBER,
        o_err_num               OUT NOCOPY	NUMBER,
        o_err_code              OUT NOCOPY	VARCHAR2,
        o_err_msg               OUT NOCOPY	VARCHAR2);

FUNCTION get_rcv_tax (
	i_rcv_txn_id	IN 	NUMBER)
RETURN NUMBER ;

FUNCTION get_po_rate (
        i_rcv_txn_id        IN         NUMBER)
RETURN NUMBER ;

/*BUG9495449*/
FUNCTION get_rcv_rate (
        i_rcv_txn_id        IN         NUMBER)
RETURN NUMBER ;

FUNCTION get_net_undel_qty(
        i_transaction_id        IN      NUMBER,
        i_end_date              IN      DATE)
RETURN NUMBER;

Procedure Insert_into_acqhdr_tables(
              i_header_id                IN  NUMBER,
              i_cost_group_id            IN  NUMBER,
              i_cost_type_id             IN  NUMBER,
              i_period_id                IN  NUMBER,
              i_rcv_transaction_id       IN  NUMBER,
              i_net_quantity_received    IN  NUMBER,
              i_total_quantity_invoiced  IN  NUMBER,
              i_quantity_at_po_price     IN  NUMBER,
              i_total_invoice_amount     IN  NUMBER,
              i_amount_at_po_price       IN  NUMBER,
              i_total_amount             IN  NUMBER,
              i_costed_quantity          IN  NUMBER,
              i_acquisition_cost         IN  NUMBER,
              i_po_line_location_id      IN  NUMBER,
              i_po_unit_price            IN  NUMBER,
              i_primary_uom              IN VARCHAR2,
              i_rec_exchg_rate           IN  NUMBER,
              i_last_update_date         IN  DATE,
              i_last_updated_by          IN  NUMBER,
              i_creation_date            IN  DATE,
              i_created_by               IN  NUMBER,
              i_request_id               IN  NUMBER,
              i_program_application_id   IN  NUMBER,
              i_program_id               IN  NUMBER,
              i_program_update_date      IN  DATE,
              i_last_update_login        IN  NUMBER,
              i_source_flag              IN  NUMBER,
              o_err_num                 OUT NOCOPY  NUMBER,
              o_err_msg                 OUT NOCOPY VARCHAR2 );

Procedure Insert_into_acqdtls_tables (
                      i_header_id                   IN  NUMBER,
                      i_detail_id                   IN  NUMBER,
                      i_source_type                 IN  VARCHAR2,
                      i_po_line_location_id         IN  NUMBER,
                      i_parent_distribution_id      IN  NUMBER,
                      i_distribution_num            IN  NUMBER,
                      i_level_num                   IN  NUMBER,
                      i_invoice_distribution_id     IN  NUMBER,
                      i_parent_inv_distribution_id  IN  NUMBER,
                      i_allocated_amount            IN  NUMBER,
                      i_parent_amount               IN  NUMBER,
                      i_amount                      IN  NUMBER,
                      i_quantity                    IN  NUMBER,
                      i_price                       IN  NUMBER,
                      i_line_type                   IN  VARCHAR2,
                      i_last_update_date            IN  DATE,
                      i_last_updated_by             IN  NUMBER,
                      i_creation_date               IN  DATE,
                      i_created_by                  IN  NUMBER,
                      i_request_id                  IN  NUMBER,
                      i_program_application_id      IN  NUMBER,
                      i_program_id                  IN  NUMBER,
                      i_program_update_date         IN  DATE,
                      i_last_update_login           IN  NUMBER,
                      i_source_flag                 IN  NUMBER,
                      o_err_num                     OUT NOCOPY NUMBER,
                      o_err_msg                     OUT NOCOPY VARCHAR2);

Procedure Acquisition_cost_adj_processor(
        ERRBUF          OUT NOCOPY     VARCHAR2,
        RETCODE         OUT NOCOPY     NUMBER,
        i_legal_entity  IN      NUMBER,
        i_cost_type_id  IN      NUMBER,
        i_period        IN      NUMBER,
        i_end_date      IN      VARCHAR2,
        i_cost_group_id IN      NUMBER,
        i_source_flag   IN      NUMBER,
        i_run_option    IN      NUMBER,
        i_receipt_dummy IN      VARCHAR2,
        i_receipt_no    IN      NUMBER,
        i_invoice_dummy IN      VARCHAR2,
        i_invoice_no    IN      NUMBER,
        i_chart_of_ac_id IN     NUMBER,
        i_adj_account_dummy IN  NUMBER,
        i_adj_account   IN      NUMBER
        );


--pragma restrict_references(get_rcv_tax, WNDS, WNPS, RNPS);
--pragma restrict_references(get_po_rate, WNDS, WNPS, RNPS);

END CSTPPACQ;

/
