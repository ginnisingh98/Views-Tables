--------------------------------------------------------
--  DDL for Package Body PA_CRL_FAXFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CRL_FAXFACE" AS
/* $Header: PACRLFAB.pls 120.2 2005/08/18 14:34:02 dlanka ship $ */

 PROCEDURE create_crl_fa_mass_additions
             (x_accounting_date                  IN DATE,
              x_add_to_asset_id                  IN NUMBER,
              x_amortize_flag                    IN VARCHAR2,
              x_asset_category_id                IN NUMBER,
	      x_asset_key_ccid			 IN NUMBER,
              x_asset_number                     IN VARCHAR2,
              x_asset_type                       IN VARCHAR2,
              x_assigned_to                      IN NUMBER,
              x_book_type_code                   IN VARCHAR2,
              x_create_batch_date                IN DATE,
              x_create_batch_id                  IN NUMBER,
              x_date_placed_in_service           IN DATE,
              x_depreciate_flag                  IN VARCHAR2,
              x_description                      IN VARCHAR2,
              x_expense_code_combination_id      IN NUMBER,
              x_feeder_system_name               IN VARCHAR2,
              x_fixed_assets_cost                IN NUMBER,
              x_fixed_assets_units               IN NUMBER,
              x_location_id                      IN NUMBER,
              x_mass_addition_id             IN OUT NOCOPY NUMBER,
              x_merged_code                      IN VARCHAR2,
              x_merge_prnt_mass_additions_id     IN NUMBER,
              x_new_master_flag                  IN VARCHAR2,
              x_parent_mass_addition_id          IN NUMBER,
              x_payables_code_combination_id     IN NUMBER,
              x_payables_cost                    IN NUMBER,
              x_payables_units                   IN NUMBER,
              x_posting_status                   IN VARCHAR2,
              x_project_asset_line_id            IN NUMBER,
              x_project_id                       IN NUMBER,
              x_queue_name                       IN VARCHAR2,
              x_split_code                       IN VARCHAR2,
              x_split_merged_code                IN VARCHAR2,
              x_split_prnt_mass_additions_id     IN NUMBER,
              x_task_id                          IN NUMBER,
              x_inventorial_flag		 IN VARCHAR2,
	      x_invoice_number                   IN VARCHAR2,
              x_vendor_number                 IN VARCHAR2,
              x_po_vendor_id                  IN NUMBER,
              x_po_number                     IN VARCHAR2,
              x_invoice_date                  IN DATE,
              x_invoice_created_by            IN NUMBER,
              x_invoice_updated_by            IN NUMBER,
              x_invoice_id                    IN NUMBER,
              x_payables_batch_name           IN VARCHAR2,
              x_ap_dist_line_number           IN NUMBER,
	      x_err_stage                    IN OUT NOCOPY VARCHAR2,
	      x_err_code                     IN OUT NOCOPY NUMBER
             )
 IS

 BEGIN
    null;
END create_crl_fa_mass_additions;

END PA_CRL_FAXFACE;

/
