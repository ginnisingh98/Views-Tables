--------------------------------------------------------
--  DDL for Package PA_COST_PLUS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COST_PLUS1" AUTHID CURRENT_USER as
-- $Header: PAXCCPFS.pls 120.1.12000000.3 2007/05/02 10:02:21 haananth ship $

   /* Added code for 2798971 */
   procedure get_indirect_cost_import
				( task_id       IN     Number,
				  p_txn_interface_id  IN  number DEFAULT NULL,-- added for bug 3246794
				effective_date   IN     Date,
				expenditure_type IN     Varchar2,
				organization_id  IN     Number,
				schedule_type    IN     Varchar2,
				direct_cost      IN     Number,
				direct_cost_denom         IN     number,
				direct_cost_acct          IN     number,
				direct_cost_project       IN     number,
				indirect_cost_sum    IN OUT NOCOPY Number,
				indirect_cost_denom_sum   IN OUT NOCOPY number,
				indirect_cost_acct_sum    IN OUT NOCOPY number,
				indirect_cost_project_sum IN OUT NOCOPY number,
				l_projfunc_currency_code  IN     varchar2,
				l_project_currency_code   IN     varchar2,
				l_acct_currency_code      IN     varchar2 default null,
				l_denom_currency_code     IN     varchar2,
				Compiled_set_id  IN OUT NOCOPY Number,
				status           IN OUT NOCOPY Number,
				stage            IN OUT NOCOPY Number);
/* Added code for 2798971 ends */

    procedure view_indirect_cost(task_id       IN     Number,
                                     effective_date   IN     Date,
                                     expenditure_type IN     Varchar2,
                                     organization_id  IN     Number,
                                     schedule_type    IN     Varchar2,
                                     direct_cost      IN     Number,
                                     indirect_cost    IN OUT NOCOPY Number,
                                     status           IN OUT NOCOPY Number,
                                     stage            IN OUT NOCOPY Number);


    procedure get_indirect_cost_amounts (x_indirect_cost_costing IN OUT NOCOPY number,
                                     x_indirect_cost_revenue IN OUT NOCOPY number,
                                     x_indirect_cost_invoice IN OUT NOCOPY number,
                                     x_task_id               IN     number,
                                     x_gl_date               IN     date,
                                     x_expenditure_type      IN     varchar2,
                                     x_organization_id       IN     number,
                                     x_direct_cost           IN     number,
			    	     x_return_status	     IN OUT NOCOPY number,
			    	     x_stage	    	     IN OUT NOCOPY number);


    procedure get_ind_rate_sch_rev(x_ind_rate_sch_name      IN OUT NOCOPY varchar2,
                               x_ind_rate_sch_revision      IN OUT NOCOPY varchar2,
                               x_ind_rate_sch_revision_type IN OUT NOCOPY varchar2,
                               x_start_date_active          IN OUT NOCOPY date,
                               x_end_date_active            IN OUT NOCOPY date,
                               x_task_id                    IN     number,
                               x_gl_date                    IN     date,
                               x_detail_type_flag           IN     varchar2,
                               x_expenditure_type           IN     varchar2,
                               x_cost_base                  IN OUT NOCOPY varchar2,
                               x_ind_compiled_set_id        IN OUT NOCOPY number,
                               x_organization_id            IN     number,
			       x_return_status	            IN OUT NOCOPY number,
			       x_stage	    	            IN OUT NOCOPY number);
     procedure get_compile_set_info(p_txn_interface_id  IN  number DEFAULT NULL,-- added for bug 2563364
				    task_id 	   	IN Number,
                                    effective_date   	IN     Date,
                                    expenditure_type 	IN     Varchar2,
                                    organization_id  	IN     Number,
                                    schedule_type    	IN     Varchar2,
				    Compiled_multiplier IN OUT NOCOPY Number,
				    compiled_set_id     IN OUT NOCOPY Number,
                                    status           IN OUT NOCOPY Number,
                                    stage            IN OUT NOCOPY Number,
                                    x_cp_structure   IN OUT NOCOPY VARCHAR2,--added for Bug 5743708
				                    x_cost_base      IN OUT NOCOPY VARCHAR2);

end PA_COST_PLUS1 ;
 

/
