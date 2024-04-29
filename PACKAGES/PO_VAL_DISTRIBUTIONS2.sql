--------------------------------------------------------
--  DDL for Package PO_VAL_DISTRIBUTIONS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VAL_DISTRIBUTIONS2" AUTHID CURRENT_USER AS
  -- $Header: PO_VAL_DISTRIBUTIONS2.pls 120.7.12010000.12 2014/08/08 18:24:52 sbontala ship $

  PROCEDURE amount_ordered(p_id_tbl              IN po_tbl_number,
                           p_amount_ordered_tbl  IN po_tbl_number,
                           p_order_type_code_tbl IN po_tbl_varchar30,
  		           p_distribution_type_tbl  IN po_tbl_varchar30, -- PDOI for Complex PO Project
                           x_results             IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                           x_result_type         OUT NOCOPY VARCHAR2);

  PROCEDURE quantity_ordered(p_id_tbl               IN po_tbl_number,
                             p_quantity_ordered_tbl IN po_tbl_number,
                             p_order_type_code_tbl  IN po_tbl_varchar30,
			     p_distribution_type_tbl  IN po_tbl_varchar30, -- PDOI for Complex PO Project
                             x_results              IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                             x_result_type          OUT NOCOPY VARCHAR2);

  PROCEDURE destination_org_id(p_id_tbl             IN po_tbl_number,
                               p_dest_org_id_tbl    IN po_tbl_number,
                               p_ship_to_org_id_tbl IN po_tbl_number,
                               x_results            IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                               x_result_type        OUT NOCOPY VARCHAR2);

  PROCEDURE deliver_to_location_id(p_id_tbl                     IN po_tbl_number,
                                   p_deliver_to_location_id_tbl IN po_tbl_number,
                                   p_ship_to_org_id_tbl         IN po_tbl_number,
                                   x_result_set_id              IN OUT NOCOPY NUMBER,
                                   x_result_type                OUT NOCOPY VARCHAR2);

  PROCEDURE deliver_to_person_id(p_id_tbl                   IN po_tbl_number,
                                 p_deliver_to_person_id_tbl IN po_tbl_number,
                                 x_result_set_id            IN OUT NOCOPY NUMBER,
                                 x_result_type              OUT NOCOPY VARCHAR2);

  PROCEDURE destination_type_code(p_id_tbl                      IN po_tbl_number,
                                  p_dest_type_code_tbl          IN po_tbl_varchar30,
                                  p_ship_to_org_id_tbl          IN po_tbl_number,
                                  p_item_id_tbl                 IN po_tbl_number,
                                  p_txn_flow_header_id_tbl      IN po_tbl_number,
                                  p_accrue_on_receipt_flag_tbl  IN po_tbl_varchar1,
                                  p_value_basis_tbl             IN po_tbl_varchar30,
                                  p_purchase_basis_tbl		    IN po_tbl_varchar30,   --bug7644072
                                  p_expense_accrual_code        IN po_system_parameters.expense_accrual_code%TYPE,
                                  p_loc_outsourced_assembly_tbl IN po_tbl_number,
				  p_consigned_flag_tbl          IN po_tbl_varchar1,   --<<Bug#19379838 >>
                                  x_result_set_id               IN OUT NOCOPY NUMBER,
                                  x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                  x_result_type                 OUT NOCOPY VARCHAR2);

  PROCEDURE destination_subinv(p_id_tbl                      IN po_tbl_number,
                               p_destination_subinv_tbl      IN po_tbl_varchar30,
                               p_dest_type_code_tbl          IN po_tbl_varchar30,
                               p_item_id_tbl                 IN po_tbl_number,
                               p_ship_to_org_id_tbl          IN po_tbl_number,
                               p_loc_outsourced_assembly_tbl IN po_tbl_number,
                               x_result_set_id               IN OUT NOCOPY NUMBER,
                               x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                               x_result_type                 OUT NOCOPY VARCHAR2);

  PROCEDURE wip_entity_id(p_id_tbl                  IN po_tbl_number,
                          p_wip_entity_id_tbl       IN po_tbl_number,
                          p_wip_rep_schedule_id_tbl IN po_tbl_number,
                          p_dest_type_code_tbl      IN po_tbl_varchar30,
                          p_destination_org_id_tbl  IN po_tbl_number,
                          x_result_set_id           IN OUT NOCOPY NUMBER,
                          x_results                 IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                          x_result_type             OUT NOCOPY VARCHAR2);

  PROCEDURE prevent_encumbrance_flag(p_id_tbl                 IN po_tbl_number,
                                     p_prevent_encum_flag_tbl IN po_tbl_varchar1,
                                     p_dest_type_code_tbl     IN po_tbl_varchar30,
				     p_distribution_type_tbl  IN po_tbl_varchar30, -- PDOI for Complex PO Project
				     p_wip_entity_id_tbl      IN po_tbl_number,    /*  Encumbrance Project  */
                                     x_results                IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                     x_result_type            OUT NOCOPY VARCHAR2);
  --Bug 18907904
  PROCEDURE gl_encumbered_date(
                              p_id_tbl                  IN po_tbl_number,
                              p_gl_date_tbl             IN po_tbl_date,
                              p_set_of_books_id         IN NUMBER,
                              p_po_encumberance_flag    IN VARCHAR2,
                              x_results                 IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                              x_result_type             OUT NOCOPY VARCHAR2);

  PROCEDURE charge_account_id(p_id_tbl                  IN po_tbl_number,
                              p_charge_account_id_tbl   IN po_tbl_number,
                              p_gl_date_tbl             IN po_tbl_date,
                              p_chart_of_account_id     IN NUMBER,
                              x_result_set_id           IN OUT NOCOPY NUMBER,
                              x_result_type             OUT NOCOPY VARCHAR2);

  PROCEDURE budget_account_id(p_id_tbl                  IN po_tbl_number,
                              p_budget_account_id_tbl   IN po_tbl_number,
                              p_gl_date_tbl             IN po_tbl_date,
                              p_dest_type_code_tbl      IN po_tbl_varchar30,
 		              p_distribution_type_tbl   IN po_tbl_varchar30, -- PDOI for Complex PO Project
                              p_chart_of_account_id     IN NUMBER,
                              p_po_encumberance_flag    IN VARCHAR2,
                              p_wip_entity_id_tbl       IN po_tbl_number,    /*  Encumbrance Project  */
                              x_result_set_id           IN OUT NOCOPY NUMBER,
                              x_result_type             OUT NOCOPY VARCHAR2);

  PROCEDURE account_id(p_id_tbl                  IN po_tbl_number,
                       p_account_id_tbl          IN po_tbl_number,
                       p_gl_date_tbl             IN po_tbl_date,
                       p_chart_of_account_id     IN NUMBER,
                       p_message_name            IN varchar2,
                       p_column_name             IN varchar2,
                       p_token_name              IN varchar2,
                       x_result_set_id           IN OUT NOCOPY NUMBER,
                       x_result_type             OUT NOCOPY VARCHAR2);

  PROCEDURE project_acct_context(p_id_tbl               IN po_tbl_number,
                                 p_project_acct_ctx_tbl IN po_tbl_varchar30,
                                 p_project_id_tbl       IN po_tbl_number,
                                 p_task_id_tbl          IN po_tbl_number,
                                 p_exp_type_tbl         IN po_tbl_varchar30,
                                 p_exp_org_id_tbl       IN po_tbl_number,
                                 x_results              IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                 x_result_type          OUT NOCOPY VARCHAR2);

  PROCEDURE project_info(p_id_tbl                    IN po_tbl_number,
                         p_project_acct_ctx_tbl      IN po_tbl_varchar30,
                         p_dest_type_code_tbl        IN po_tbl_varchar30,
                         p_project_id_tbl            IN po_tbl_number,
                         p_task_id_tbl               IN po_tbl_number,
                         p_expenditure_type_tbl      IN po_tbl_varchar30,
                         p_expenditure_org_id_tbl    IN po_tbl_number,
                         p_ship_to_org_id_tbl        IN po_tbl_number,
                         p_need_by_date_tbl          IN po_tbl_date,
                         p_promised_date_tbl         IN po_tbl_date,
                         p_expenditure_item_date_tbl IN po_tbl_date,
                         p_ship_to_ou_id             IN NUMBER,
                         p_deliver_to_person_id_tbl  IN po_tbl_number,
                         p_agent_id_tbl              IN po_tbl_number,
                         p_txn_flow_header_id_tbl    IN po_tbl_number,
                         p_org_id_tbl                IN po_tbl_number, --<PDOI Enhancement Bug#17063664>
                         x_results                   IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                         x_result_type               OUT NOCOPY VARCHAR2);

  PROCEDURE tax_recovery_override_flag(p_id_tbl                     IN po_tbl_number,
                                       p_recovery_override_flag_tbl IN po_tbl_varchar1,
                                       p_allow_tax_rate_override    IN VARCHAR2,
									   x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                       x_result_type                OUT NOCOPY VARCHAR2);
--Bug16208248
  PROCEDURE charge_account_id_null(p_id_tbl                  IN po_tbl_number,
                                   p_charge_account_id_tbl   IN po_tbl_number,
                                   x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                   x_result_type             OUT NOCOPY VARCHAR2);
  --Bug 16856753
   PROCEDURE charge_account_id_full(
                           p_id_tbl                  IN              po_tbl_number,
                           p_charge_account_id_tbl   IN              po_tbl_number,
	                       p_sob_id_tbl              IN              po_tbl_number,
                           x_results                 IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                           x_result_type             OUT NOCOPY      VARCHAR2);

    -- <PDOI Enhancement Bug#17063664>
    PROCEDURE oke_contract_line_id( p_id_tbl                IN              po_tbl_number,
                                    p_oke_con_line_id       IN              po_tbl_number,
                                    p_oke_con_hdr_id        IN              po_tbl_number,
                                    x_result_set_id         IN OUT NOCOPY   NUMBER,
                                    x_result_type           OUT NOCOPY      VARCHAR2) ;

    -- <PDOI Enhancement Bug#17063664>
    PROCEDURE oke_contract_del_id(p_id_tbl                IN              po_tbl_number,
                                  p_oke_con_del_id        IN              po_tbl_number,
                                  p_oke_con_line_id       IN              po_tbl_number,
                                  x_result_set_id         IN OUT NOCOPY   NUMBER,
                                  x_result_type           OUT NOCOPY      VARCHAR2) ;


END PO_VAL_DISTRIBUTIONS2;

/
