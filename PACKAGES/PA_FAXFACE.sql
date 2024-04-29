--------------------------------------------------------
--  DDL for Package PA_FAXFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FAXFACE" AUTHID CURRENT_USER AS
/* $Header: PAFAXS.pls 120.7.12010000.3 2009/07/14 12:04:27 sgottimu ship $ */

   -- Standard who
   x_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_date        NUMBER(15) := FND_GLOBAL.USER_ID;
   x_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   -- Commented out for bug 5401326 x_request_id              NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   x_request_id              NUMBER(15);
   x_program_application_id  NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   x_program_id              NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;

   -- Variable used by the set_ and get_inservice_thru_date functions.
   x_in_service_thru_date	DATE;
   G_debug_mode VARCHAR2(1);  -- Fix for bug : 4878878

   PROCEDURE set_in_service_thru_date (x_passed_thru_date IN DATE);

   FUNCTION check_required_segment (structnum in number) return varchar2;

   FUNCTION get_in_service_thru_date RETURN DATE;
   --This function is used by the pa_cp_generate_asset_v to enable
   --the view's where clause to use a parameter passed to the report.
   --pragma RESTRICT_REFERENCES (get_in_service_thru_date, WNDS, WNPS );

   FUNCTION Initialize RETURN NUMBER;

   FUNCTION get_group_level_task_id
		( x_task_id    IN NUMBER,
                   x_top_task_id IN NUMBER,
		  x_project_id IN NUMBER)
   RETURN NUMBER ;

   --pragma RESTRICT_REFERENCES (get_group_level_task_id, WNDS, WNPS );

   FUNCTION get_asset_category_id
		( x_doc_header_id               IN NUMBER,
		  x_doc_line_num                IN NUMBER,
		  x_doc_dist_id                 IN NUMBER,
                  x_transaction_source          IN VARCHAR2)
   RETURN NUMBER;

--   pragma RESTRICT_REFERENCES (get_asset_category_id, WNDS, WNPS );

/* Added for bug 1280252 */
   FUNCTION is_project_eligible(p_project_id IN NUMBER
                                ,p_capital_event_id IN NUMBER
                                ) RETURN BOOLEAN;

   PROCEDURE get_asset_id
		( x_project_id               IN NUMBER,
		  x_system_linkage_function  IN VARCHAR2,
                  x_grp_level_task_id        IN NUMBER,
                  x_asset_category_id        IN NUMBER,
                  x_line_type                IN VARCHAR2,
                  x_capital_event_id         IN NUMBER,
                  x_asset_id                 OUT NOCOPY NUMBER,
                  x_num_asset_assigned       OUT NOCOPY NUMBER);

   PROCEDURE get_asset_attributes
		( x_project_asset_id                IN  NUMBER,
		  x_depreciation_expense_ccid    IN OUT NOCOPY NUMBER,
		  x_err_stage        IN OUT NOCOPY VARCHAR2,
		  x_err_code         IN OUT NOCOPY NUMBER);

   PROCEDURE find_assets_to_be_reversed
                 (x_project_id                IN         NUMBER,
		          x_asset_found               IN OUT NOCOPY     BOOLEAN,
                  x_capital_event_id          IN         NUMBER,
                  x_err_stage                 IN OUT NOCOPY     VARCHAR2,
                  x_err_code                  IN OUT NOCOPY     NUMBER);

   PROCEDURE check_asset_to_be_reversed
                 (x_proj_asset_line_detail_id IN         NUMBER,
		  x_asset_found               IN OUT NOCOPY     BOOLEAN,
                  x_err_stage                 IN OUT NOCOPY     VARCHAR2,
                  x_err_code                  IN OUT NOCOPY     NUMBER);

   PROCEDURE check_proj_asset_lines
                 (x_proj_asset_line_detail_id IN         NUMBER,
		  x_line_found                IN OUT NOCOPY     BOOLEAN,
                  x_err_stage                 IN OUT NOCOPY     VARCHAR2,
                  x_err_code                  IN OUT NOCOPY     NUMBER);

   PROCEDURE update_line_details
                 (x_proj_asset_line_detail_id IN         NUMBER,
                  x_err_stage                 IN OUT NOCOPY     VARCHAR2,
                  x_err_code                  IN OUT NOCOPY     NUMBER);

   PROCEDURE update_expenditure_items
                 (x_proj_asset_line_detail_id IN         NUMBER,
		  x_revenue_distributed_flag  IN         VARCHAR2,
                  x_err_stage                 IN OUT NOCOPY     VARCHAR2,
                  x_err_code                  IN OUT NOCOPY     NUMBER);

   PROCEDURE update_asset_cost
                 (x_project_asset_id          IN         NUMBER,
		  x_grouped_cip_cost          IN         NUMBER,
		  x_capitalized_cost          IN         NUMBER,
                  x_err_stage                 IN OUT NOCOPY     VARCHAR2,
                  x_err_code                  IN OUT NOCOPY     NUMBER);

   PROCEDURE create_project_asset_lines
              (x_description                   IN VARCHAR2,
               x_project_asset_id              IN NUMBER,
               x_project_id                    IN NUMBER,
               x_task_id                       IN NUMBER,
               x_cip_ccid                      IN NUMBER,
               x_asset_cost_ccid               IN NUMBER,
               x_original_asset_cost           IN NUMBER,
               x_current_asset_cost            IN NUMBER,
               x_project_asset_line_detail_id  IN NUMBER,
               x_gl_date                       IN DATE,
               x_transfer_status_code          IN VARCHAR2,
	       x_transfer_rejection_reason     IN VARCHAR2,
               x_amortize_flag                 IN VARCHAR2,
               x_asset_category_id             IN NUMBER,
               x_rev_proj_asset_line_id        IN NUMBER,
	       x_rev_from_proj_asset_line_id   IN NUMBER,
	       x_invoice_number                IN VARCHAR2,
               x_vendor_number                 IN VARCHAR2,
               x_po_vendor_id                  IN NUMBER,
               x_po_number                     IN VARCHAR2,
               x_invoice_date                  IN DATE,
               x_invoice_created_by            IN NUMBER,
               x_invoice_updated_by            IN NUMBER,
               x_invoice_id                    IN NUMBER,
               x_payables_batch_name           IN VARCHAR2,
               x_ap_dist_line_number           IN NUMBER, -- R12 changes
               x_invoice_distribution_id       IN NUMBER,
               x_orig_asset_id                 IN Number,
               x_line_type                     IN VARCHAR2,
               x_capital_event_id              IN NUMBER,
               x_retirement_cost_type          IN VARCHAR2,
               x_err_stage                  IN OUT NOCOPY VARCHAR2,
               x_err_code                   IN OUT NOCOPY NUMBER);

   PROCEDURE reverse_asset_lines
                 (x_project_id                IN         NUMBER,
                  x_capital_event_id          IN         NUMBER,
                  x_err_stage                 IN OUT NOCOPY     VARCHAR2,
                  x_err_code                  IN OUT NOCOPY     NUMBER);

   PROCEDURE get_proj_asset_id
		 (x_project_id                IN         NUMBER,
		  x_task_id                   IN         NUMBER,
		  x_project_asset_id          IN OUT NOCOPY     NUMBER,
                  x_err_stage                 IN OUT NOCOPY     VARCHAR2,
                  x_err_code                  IN OUT NOCOPY     NUMBER);

   PROCEDURE delete_proj_asset_line
		 (x_project_asset_line_id     IN         NUMBER,
                  x_err_stage                 IN OUT NOCOPY     VARCHAR2,
                  x_err_code                  IN OUT NOCOPY     NUMBER);

   PROCEDURE delete_proj_asset_line_details
		 (x_project_asset_line_detail_id IN         NUMBER,
                  x_err_stage                    IN OUT NOCOPY     VARCHAR2,
                  x_err_code                     IN OUT NOCOPY     NUMBER);

   PROCEDURE delete_asset_lines
                 (x_project_id                IN         NUMBER,
                  x_capital_event_id          IN         NUMBER,
                  x_err_stage                 IN OUT NOCOPY     VARCHAR2,
                  x_err_code                  IN OUT NOCOPY     NUMBER);

   PROCEDURE create_proj_asset_line_details
              (x_expenditure_item_id           IN NUMBER,
               x_line_num                      IN NUMBER,
               x_project_asset_line_detail_id  IN NUMBER,
	       x_cip_cost                      IN NUMBER,
	       x_reversed_flag                 IN VARCHAR2,
               x_err_stage                  IN OUT NOCOPY VARCHAR2,
               x_err_code                   IN OUT NOCOPY NUMBER);

   PROCEDURE fetch_vi_info ( /*Start of changes for Bug 7428263  */
                             /* x_invoice_id 	        IN Number, */
                             x_ref2       	        IN Number,
			                 /* x_ap_dist_line_number	IN Number, */
			                 x_ref3             	IN Number,
			                 x_ref4                 IN Number,
			                 x_transaction_source   IN VARCHAR2,
			                 /*End of changes for Bug 7428263  */
			                 x_employee_id		OUT NOCOPY Number,
			                 x_invoice_num		OUT NOCOPY VARCHAR2,
                             x_vendor_number            OUT NOCOPY VARCHAR2,
                             x_po_vendor_id             OUT NOCOPY NUMBER,
                             x_po_number                OUT NOCOPY VARCHAR2,
                             x_invoice_date             OUT NOCOPY DATE,
                             x_invoice_created_by       OUT NOCOPY NUMBER,
                             x_invoice_updated_by       OUT NOCOPY NUMBER,
                             x_payables_batch_name      OUT NOCOPY VARCHAR2,
                             x_err_stage                IN OUT NOCOPY VARCHAR2,
                             x_err_code                 IN OUT NOCOPY NUMBER);

   PROCEDURE generate_proj_asset_lines
	        ( x_project_id                IN  NUMBER,
	          x_in_service_date_through   IN  DATE,
	          x_common_tasks_flag         IN  VARCHAR2,
             	  x_pa_date                   IN  DATE,
                  x_capital_cost_type_code    IN  VARCHAR2 ,
                  x_cip_grouping_method_code  IN  VARCHAR2 ,
                  x_OVERRIDE_ASSET_ASSIGNMENT IN VARchar2,
                  x_VENDOR_INVOICE_GROUPING_CODE IN varchar2,
                  x_capital_event_id       IN  NUMBER,
                  x_line_type              IN  VARCHAR2,
		  x_ledger_id              IN  NUMBER,
                  x_err_stage              IN OUT NOCOPY VARCHAR2,
                  x_err_code               IN OUT NOCOPY NUMBER);

  PROCEDURE summarize_proj
                        ( errbuf                 IN OUT NOCOPY VARCHAR2,
			  retcode                IN OUT NOCOPY VARCHAR2,
			  x_project_num_from        IN  VARCHAR2,
			  x_project_num_to          IN  VARCHAR2,
			  x_in_service_date_through IN  DATE,
			  x_common_tasks_flag       IN  VARCHAR2,
           	          x_pa_date                 IN  DATE
                          ,x_capital_event_id       IN  NUMBER DEFAULT NULL
                         , x_debug_mode IN VARCHAR2	 -- Fix for bug : 4878878
			);
   PROCEDURE mark_asset_lines_for_xfer
		( x_project_id              IN  NUMBER,
		  x_in_service_date_through IN  DATE,
          x_line_type               IN  VARCHAR2,
		  x_rowcount             IN OUT NOCOPY NUMBER,
		  x_err_stage            IN OUT NOCOPY VARCHAR2,
		  x_err_code             IN OUT NOCOPY NUMBER);

   PROCEDURE mark_reversing_lines(x_project_id    IN  NUMBER,
                                x_capital_event_id IN  NUMBER,
                                x_line_type        IN  VARCHAR2,
		                        x_err_stage       IN OUT NOCOPY  VARCHAR2,
		                        x_err_code        IN OUT NOCOPY  NUMBER);

   PROCEDURE update_asset_capitalized_flag
                 (x_project_asset_id          IN         NUMBER,
		  x_capitalized_flag          IN         VARCHAR2,
                  x_err_stage                 IN OUT NOCOPY     VARCHAR2,
                  x_err_code                  IN OUT NOCOPY     NUMBER);

   PROCEDURE update_asset_adjustment_flag
                 (x_project_asset_id          IN         NUMBER,
		  x_adjustment_flag           IN         VARCHAR2,
		  x_adjustment_type	      IN 	 VARCHAR2,
                  x_err_stage                 IN OUT NOCOPY     VARCHAR2,
                  x_err_code                  IN OUT NOCOPY     NUMBER);

   PROCEDURE check_asset_id_in_FA
                 (x_project_asset_id          IN         NUMBER,
		  x_asset_id_in_FA            IN OUT NOCOPY     NUMBER,
		  x_num_asset_found           IN OUT NOCOPY     NUMBER,
		  x_book_type_code	      IN	 VARCHAR2,
		  x_date_placed_in_service    IN OUT NOCOPY	 DATE,
                  x_err_stage                 IN OUT NOCOPY     VARCHAR2,
                  x_err_code                  IN OUT NOCOPY     NUMBER);
   PROCEDURE reject_lines_check1
		 (x_rows_rejected        IN OUT NOCOPY NUMBER,
		  x_err_stage            IN OUT NOCOPY VARCHAR2,
		  x_err_code             IN OUT NOCOPY NUMBER);


   PROCEDURE update_asset_lines
                 (x_proj_asset_line_id        IN     NUMBER,
		  x_transfer_rejection_reason IN     VARCHAR2,
		  x_transfer_status_code      IN     VARCHAR2,
		  x_amortize_flag             IN     VARCHAR2,
                  x_err_stage                 IN OUT NOCOPY VARCHAR2,
                  x_err_code                  IN OUT NOCOPY NUMBER);

   PROCEDURE create_fa_mass_additions
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
	      x_invoice_number                IN VARCHAR2,
              x_vendor_number                 IN VARCHAR2,
              x_po_vendor_id                  IN NUMBER,
              x_po_number                     IN VARCHAR2,
              x_invoice_date                  IN DATE,
              x_invoice_created_by            IN NUMBER,
              x_invoice_updated_by            IN NUMBER,
              x_invoice_id                    IN NUMBER,
              x_payables_batch_name           IN VARCHAR2,
              x_ap_dist_line_number           IN NUMBER, -- R12 changes
              x_invoice_distribution_id       IN NUMBER, -- R12 changes
              x_parent_asset_id               IN NUMBER,
              x_manufacturer_name             IN VARCHAR2,
              x_model_number                  IN VARCHAR2,
              x_serial_number                 IN VARCHAR2,
              x_tag_number                    IN VARCHAR2,
	      x_err_stage                    IN OUT NOCOPY VARCHAR2,
	      x_err_code                     IN OUT NOCOPY NUMBER
             );

   PROCEDURE interface_asset_lines
		( x_project_id              IN  NUMBER,
		  x_asset_type              IN  VARCHAR2,
		  x_in_service_date_through IN  DATE,
		  x_reversed_line_flag      IN  VARCHAR2,
		  x_err_stage            IN OUT NOCOPY VARCHAR2,
		  x_err_code             IN OUT NOCOPY NUMBER);

  PROCEDURE interface_assets
            ( errbuf                 IN OUT NOCOPY VARCHAR2,
			  retcode                IN OUT NOCOPY VARCHAR2,
			  x_project_num_from        IN  VARCHAR2,
			  x_project_num_to          IN  VARCHAR2,
			  x_in_service_date_through IN  DATE
			);

/*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
  PROCEDURE get_depreciation_expense
              (x_project_asset_id       IN  NUMBER,
			  x_book_type_code          IN  VARCHAR2,
			  x_asset_category_id       IN  NUMBER,
              x_date_placed_in_service  IN  DATE,
              x_in_deprn_expense_ccid   IN  NUMBER,
              x_out_deprn_expense_ccid  IN OUT NOCOPY NUMBER,
       	      x_err_stage               IN OUT NOCOPY VARCHAR2,
    	      x_err_code                IN OUT NOCOPY NUMBER
			);


  PROCEDURE interface_ret_asset_lines
		( x_project_id           IN  NUMBER,
		  x_err_stage            IN OUT NOCOPY VARCHAR2,
		  x_err_code             IN OUT NOCOPY NUMBER);



   PROCEDURE no_event_projects
                ( x_project_id IN NUMBER,                 /*bug 5758490*/
                  x_in_service_date_through IN DATE,
                  x_err_stage            IN OUT NOCOPY VARCHAR2,
                  x_err_code             IN OUT NOCOPY  NUMBER);
 /*  End of Automatic asset capitalization changes */


  PROCEDURE summarize_xface
                        ( errbuf                 IN OUT NOCOPY VARCHAR2,
			  retcode                IN OUT NOCOPY VARCHAR2,
			  x_project_num_from        IN  VARCHAR2,
			  x_project_num_to          IN  VARCHAR2,
			  x_in_service_date_through IN  DATE,
                          x_pa_date                 IN  DATE
			);

  PROCEDURE create_alc_asset_line_details (x_proj_asset_line_dtl_uniq_id	IN NUMBER,
					   x_expenditure_item_id		IN NUMBER,
					   x_line_num				IN NUMBER,
					   x_project_asset_line_detail_id	IN NUMBER,
					   x_err_stage				IN OUT NOCOPY VARCHAR2,
					   x_err_code				IN OUT NOCOPY NUMBER) ;

  PROCEDURE create_alc_proj_asset_lines (x_project_asset_line_id		IN NUMBER,
					    x_project_asset_line_detail_id	IN NUMBER,
					    x_rev_proj_asset_line_id		IN NUMBER,
					    x_original_asset_cost		IN NUMBER,
					    x_current_asset_cost		IN NUMBER,
					    x_err_stage				IN OUT NOCOPY VARCHAR2,
					    x_err_code				IN OUT NOCOPY NUMBER);

  PROCEDURE update_alc_proj_asset_lines (x_project_asset_line_id		IN NUMBER,
					    x_original_asset_cost		IN NUMBER,
					    x_current_asset_cost		IN NUMBER);

  PROCEDURE create_alc_fa_mass_additions  (x_project_asset_line_id	IN NUMBER,
                                           x_mass_addition_id		IN NUMBER,
					   x_parent_mass_addition_id	IN NUMBER,
					   x_fixed_assets_cost		IN NUMBER);

  -- Added this procedure for bug 5401326
  PROCEDURE set_request_id(x_passed_request_id IN NUMBER);

END PA_FAXFACE;

/
