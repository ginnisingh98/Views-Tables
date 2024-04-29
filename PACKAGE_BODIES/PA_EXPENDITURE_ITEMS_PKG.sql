--------------------------------------------------------
--  DDL for Package Body PA_EXPENDITURE_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EXPENDITURE_ITEMS_PKG" as
/* $Header: PAXTITMB.pls 120.3 2007/02/07 19:10:14 eyefimov ship $ */

 procedure insert_row (x_rowid                        in out NOCOPY VARCHAR2,
                       x_expenditure_item_id          in out NOCOPY NUMBER,
                       x_last_update_date             in DATE,
                       x_last_updated_by              in NUMBER,
                       x_creation_date                in DATE,
                       x_created_by                   in NUMBER,
                       x_expenditure_id               in NUMBER,
                       x_task_id                      in NUMBER,
                       x_expenditure_item_date        in DATE,
                       x_expenditure_type             in VARCHAR2,
                       x_cost_distributed_flag        in VARCHAR2,
                       x_revenue_distributed_flag     in VARCHAR2,
                       x_billable_flag                in VARCHAR2,
                       x_bill_hold_flag               in VARCHAR2,
                       x_quantity                     in NUMBER,
                       x_non_labor_resource           in VARCHAR2,
                       x_organization_id              in NUMBER,
                       x_override_to_organization_id  in NUMBER,
                       x_raw_cost                     in NUMBER,
                       x_raw_cost_rate                in NUMBER,
                       x_burden_cost                  in NUMBER,
                       x_burden_cost_rate             in NUMBER,
                       x_cost_dist_rejection_code     in VARCHAR2,
                       x_labor_cost_multiplier_name   in VARCHAR2,
                       x_raw_revenue                  in NUMBER,
                       x_bill_rate                    in NUMBER,
                       x_accrued_revenue              in NUMBER,
                       x_accrual_rate                 in NUMBER,
                       x_adjusted_revenue             in NUMBER,
                       x_adjusted_rate                in NUMBER,
                       x_bill_amount                  in NUMBER,
                       x_forecast_revenue             in NUMBER,
                       x_bill_rate_multiplier         in NUMBER,
                       x_rev_dist_rejection_code      in VARCHAR2,
                       x_event_num                    in NUMBER,
                       x_event_task_id                in NUMBER,
                       x_bill_job_id                  in NUMBER,
                       x_bill_job_billing_title       in VARCHAR2,
                       x_bill_employee_billing_title  in VARCHAR2,
                       x_adjusted_expenditure_item_id in NUMBER,
                       x_net_zero_adjustment_flag     in VARCHAR2,
                       x_transferred_from_exp_item_id in NUMBER,
                       x_converted_flag               in VARCHAR2,
                       x_last_update_login            in NUMBER,
                       x_attribute_category           in VARCHAR2,
                       x_attribute1                   in VARCHAR2,
                       x_attribute2                   in VARCHAR2,
                       x_attribute3                   in VARCHAR2,
                       x_attribute4                   in VARCHAR2,
                       x_attribute5                   in VARCHAR2,
                       x_attribute6                   in VARCHAR2,
                       x_attribute7                   in VARCHAR2,
                       x_attribute8                   in VARCHAR2,
                       x_attribute9                   in VARCHAR2,
                       x_attribute10                  in VARCHAR2,
                       x_cost_ind_compiled_set_id     in NUMBER,
                       x_rev_ind_compiled_set_id      in NUMBER,
                       x_inv_ind_compiled_set_id      in NUMBER,
                       x_cost_burden_distributed_flag in VARCHAR2,
                       x_ind_cost_dist_rejection_code in VARCHAR2,
                       x_orig_transaction_reference   in VARCHAR2,
                       x_transaction_source           in VARCHAR2,
                       x_project_id                   in NUMBER,
                       x_source_expenditure_item_id   in NUMBER,
                       x_job_id                       in NUMBER,
                       x_expenditure_comment          in VARCHAR2,
                       x_system_linkage_function      in VARCHAR2,
                       x_receipt_currency_amount      in NUMBER,
                       x_receipt_currency_code        in VARCHAR2,
                       x_receipt_exchange_rate        in NUMBER,
                       x_denom_currency_code          in VARCHAR2,
                       x_denom_raw_cost               in NUMBER,
                       x_denom_burdened_cost          in NUMBER,
                       x_acct_exchange_rounding_limit in NUMBER,
                       x_acct_currency_code           in VARCHAR2,
                       x_acct_rate_date               in DATE,
                       x_acct_rate_type               in VARCHAR2,
                       x_acct_exchange_rate           in NUMBER,
                       x_acct_raw_cost                in NUMBER,
                       x_acct_burdened_cost           in NUMBER,
                       x_project_currency_code        in VARCHAR2,
                       x_project_rate_date            in DATE,
                       x_project_rate_type            in VARCHAR2,
                       x_project_exchange_rate        in NUMBER,
                       x_recvr_org_id                 in NUMBER,
                       p_assignment_id                IN NUMBER  default null,
                       p_work_type_id                 IN NUMBER  default null,
                       p_projfunc_currency_code       IN varchar2 default null,
                       p_projfunc_cost_rate_date      IN date  default  null,
                       p_projfunc_cost_rate_type      IN varchar2 default null,
                       p_projfunc_cost_exchange_rate  IN number default null,
                       p_project_raw_cost             IN number default null,
                       p_project_burdened_cost        IN number default null,
                       p_tp_amt_type_code             IN varchar2 default null,
		               p_prvdr_accrual_date		      IN date default null,
		               p_recvr_accrual_date		      IN date default null,
		               p_capital_event_id             IN NUMBER default null,
                       p_wip_resource_id              IN number default null,
                       p_inventory_item_id            IN number default null,
                       p_unit_of_measure              IN varchar2 default null ,
                       P_Org_ID                       IN NUMBER default NULL -- 12i MOAC changes
			) is

  cursor return_rowid is select rowid from pa_expenditure_items
                         where expenditure_item_id = x_expenditure_item_id;
  cursor get_itemid is select pa_expenditure_items_s.nextval from sys.dual;

  status	NUMBER;
  l_rowid       VARCHAR2(1000);
  l_expenditure_item_id NUMBER;
 BEGIN
  l_expenditure_item_id := x_expenditure_item_id;
  l_rowid := x_rowid;

  if (x_expenditure_item_id is null) then
    open get_itemid;
    fetch get_itemid into x_expenditure_item_id;
    close get_itemid;
  end if;

  -- if amt is negative, need to update reversed original

  insert into pa_expenditure_items (
         expenditure_item_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         expenditure_id,
         task_id,
         expenditure_item_date,
         expenditure_type,
         cost_distributed_flag,
         revenue_distributed_flag,
         billable_flag,
         bill_hold_flag,
         quantity,
         non_labor_resource,
         organization_id,
         override_to_organization_id,
         raw_cost,
         raw_cost_rate,
         burden_cost,
         burden_cost_rate,
         cost_dist_rejection_code,
         labor_cost_multiplier_name,
         raw_revenue,
         bill_rate,
         accrued_revenue,
         accrual_rate,
         adjusted_revenue,
         adjusted_rate,
         bill_amount,
         forecast_revenue,
         bill_rate_multiplier,
         rev_dist_rejection_code,
         event_num,
         event_task_id,
         bill_job_id,
         bill_job_billing_title,
         bill_employee_billing_title,
         adjusted_expenditure_item_id,
         net_zero_adjustment_flag,
         transferred_from_exp_item_id,
         converted_flag,
         last_update_login,
         attribute_category,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         cost_ind_compiled_set_id,
         rev_ind_compiled_set_id,
         inv_ind_compiled_set_id,
         cost_burden_distributed_flag,
         ind_cost_dist_rejection_code,
         orig_transaction_reference,
         transaction_source,
         project_id,
         source_expenditure_item_id,
         job_id,
         system_linkage_function,
         receipt_currency_amount,
 		 receipt_currency_code,
 		 receipt_exchange_rate,
 		 denom_currency_code,
 	     denom_raw_cost,
 		 denom_burdened_cost,
		 acct_exchange_rounding_limit,
   		 acct_currency_code,
 		 acct_rate_date,
		 acct_rate_type,
 		 acct_exchange_rate,
 		 acct_raw_cost,
 		 acct_burdened_cost,
 		 project_currency_code,
 	     project_rate_date,
 		 project_rate_type,
 		 project_exchange_rate,
         recvr_org_id ,
         assignment_id,
         work_type_id,
         projfunc_currency_code,
         projfunc_cost_rate_date,
         projfunc_cost_rate_type,
         projfunc_cost_exchange_rate,
         project_raw_cost,
         project_burdened_cost,
		 tp_amt_type_code,
		 prvdr_accrual_date,
		 recvr_accrual_date,
		 capital_event_id,
         wip_resource_id,
         inventory_item_id,
         unit_of_measure,
         org_id -- 12i MOAC changes
)
 values (x_expenditure_item_id,
         x_last_update_date,
         x_last_updated_by,
         x_creation_date,
         x_created_by,
         x_expenditure_id,
         x_task_id,
         x_expenditure_item_date,
         x_expenditure_type,
         x_cost_distributed_flag,
         x_revenue_distributed_flag,
         x_billable_flag,
         x_bill_hold_flag,
         x_quantity,
         x_non_labor_resource,
         x_organization_id,
         x_override_to_organization_id,
         x_raw_cost,
         x_raw_cost_rate,
         x_burden_cost,
         x_burden_cost_rate,
         x_cost_dist_rejection_code,
         x_labor_cost_multiplier_name,
         x_raw_revenue,
         x_bill_rate,
         x_accrued_revenue,
         x_accrual_rate,
         x_adjusted_revenue,
         x_adjusted_rate,
         x_bill_amount,
         x_forecast_revenue,
         x_bill_rate_multiplier,
         x_rev_dist_rejection_code,
         x_event_num,
         x_event_task_id,
         x_bill_job_id,
         x_bill_job_billing_title,
         x_bill_employee_billing_title,
         x_adjusted_expenditure_item_id,
         x_net_zero_adjustment_flag,
         x_transferred_from_exp_item_id,
         x_converted_flag,
         x_last_update_login,
         x_attribute_category,
         x_attribute1,
         x_attribute2,
         x_attribute3,
         x_attribute4,
         x_attribute5,
         x_attribute6,
         x_attribute7,
         x_attribute8,
         x_attribute9,
         x_attribute10,
         x_cost_ind_compiled_set_id,
         x_rev_ind_compiled_set_id,
         x_inv_ind_compiled_set_id,
         x_cost_burden_distributed_flag,
         x_ind_cost_dist_rejection_code,
         x_orig_transaction_reference,
         x_transaction_source,
         x_project_id,
         x_source_expenditure_item_id,
         x_job_id,
         x_system_linkage_function,
         x_receipt_currency_amount,
         x_receipt_currency_code,
 	     x_receipt_exchange_rate,
 	     x_denom_currency_code,
 	     x_denom_raw_cost,
 	     x_denom_burdened_cost,
   	     x_acct_exchange_rounding_limit,
 	     x_acct_currency_code,
 	     x_acct_rate_date,
 	     x_acct_rate_type,
 	     x_acct_exchange_rate,
 	     x_acct_raw_cost,
 	     x_acct_burdened_cost,
 	     x_project_currency_code,
 	     x_project_rate_date,
 	     x_project_rate_type,
 	     x_project_exchange_rate,
         x_recvr_org_id,
         p_assignment_id,
         p_work_type_id,
         p_projfunc_currency_code,
         p_projfunc_cost_rate_date,
         p_projfunc_cost_rate_type,
         p_projfunc_cost_exchange_rate,
         p_project_raw_cost,
         p_project_burdened_cost,
	     p_tp_amt_type_code,
	     p_prvdr_accrual_date,
	     p_recvr_accrual_date,
	     p_capital_event_id,
         p_wip_resource_id,
         p_inventory_item_id,
         p_unit_of_measure,
         P_Org_Id -- 12i MOAC changes
         );

  open return_rowid;
  fetch return_rowid into x_rowid;
  if (return_rowid%notfound) then
    raise NO_DATA_FOUND;  -- should we return something else?
  end if;
  close return_rowid;

  -- this assumes the neg quantity has already been validated, and
  -- is matched.  unmatched occurs in adjustments
/*  Bug 1715308 removed the criteria of x_quantity < 0
  if (((x_quantity < 0) or (x_burden_cost < 0)) and
       (x_net_zero_adjustment_flag = 'Y'))  then */

  If x_net_zero_adjustment_flag = 'Y' then
    update pa_expenditure_items
    set net_zero_adjustment_flag = 'Y'
    where expenditure_item_id = x_adjusted_expenditure_item_id;

/*Added for bug 5639026 to update transfer price columns*/
    IF nvl(x_adjusted_expenditure_item_id, 0) <> 0 then
        UPDATE pa_expenditure_items
        SET(cc_prvdr_organization_id,
            cc_recvr_organization_id,
            cc_rejection_code,
            denom_tp_currency_code,
            denom_transfer_price,
            acct_tp_rate_type,
            acct_tp_rate_date,
            acct_tp_exchange_rate,
            acct_transfer_price,
            projacct_transfer_price,
            cc_markup_base_code,
            tp_base_amount,
            tp_ind_compiled_set_id,
            tp_bill_rate,
            tp_bill_markup_percentage,
            tp_schedule_line_percentage,
            tp_rule_percentage,
            cost_job_id,
            tp_job_id,
            prov_proj_bill_job_id,
            project_tp_rate_date,
            project_tp_rate_type,
            project_tp_exchange_rate,
            project_transfer_price) =
            (SELECT ei.cc_prvdr_organization_id,
                    ei.cc_recvr_organization_id,
                    ei.cc_rejection_code,
                    ei.denom_tp_currency_code,
                    (0 -ei.denom_transfer_price),
                    ei.acct_tp_rate_type,
                    ei.acct_tp_rate_date,
                    ei.acct_tp_exchange_rate,
                    (0 -ei.acct_transfer_price),
                    (0 -ei.projacct_transfer_price),
                    ei.cc_markup_base_code,
                    (0 -ei.tp_base_amount),
                    ei.tp_ind_compiled_set_id,
                    ei.tp_bill_rate,
                    ei.tp_bill_markup_percentage,
                    ei.tp_schedule_line_percentage,
                    ei.tp_rule_percentage,
                    ei.cost_job_id,
                    ei.tp_job_id,
                    ei.prov_proj_bill_job_id,
                    ei.project_tp_rate_date,
                    ei.project_tp_rate_type,
                    ei.project_tp_exchange_rate,
                    (0 -ei.project_transfer_price)
             FROM pa_expenditure_items ei
             WHERE ei.expenditure_item_id = x_adjusted_expenditure_item_id)
        WHERE expenditure_item_id = x_expenditure_item_id;
    END if;
/* End of bug fix for 5639026 */

    -- Date :  17-JUN-99
    --
    -- Earlier the value for parameter expenditure id was NULL. This
    -- resulted in the reversing related items getting creating in a
    -- different expenditure id which is different from that of the
    -- source item. Changed the NULL value to the current expenditure
    -- id.
    --
    pa_adjustments.ReverseRelatedItems(x_adjusted_expenditure_item_id,
                                       x_expenditure_id,
                                       'PAXTREPE',
                                       X_created_by,
                                       X_last_update_login,
                                       status );
    --
    --
  end if;


  if (x_expenditure_comment is not null) then
    insert into pa_expenditure_comments (expenditure_item_id,
                                         line_number,
                                         expenditure_comment,
                                         last_update_date,
                                         last_updated_by,
                                         creation_date,
                                         created_by,
                                         last_update_login)
    values (x_expenditure_item_id,
            1,
            x_expenditure_comment,
            x_last_update_date,
            x_last_updated_by,
            x_creation_date,
            x_created_by,
            x_last_update_login);
    -- what if insert into comment fails?
  end if;

-- R12 NOCOPY mandate
EXCEPTION WHEN OTHERS THEN
     x_expenditure_item_id := l_expenditure_item_id;
     x_rowid := l_rowid;
     RAISE;
 END insert_row;


 procedure update_row (x_rowid				          in VARCHAR2,
                       x_expenditure_item_id		  in NUMBER,
                       x_last_update_date		      in DATE,
                       x_last_updated_by		      in NUMBER,
                       x_expenditure_id			      in NUMBER,
                       x_task_id			          in NUMBER,
                       x_expenditure_item_date	 	  in DATE,
                       x_expenditure_type		      in VARCHAR2,
                       x_cost_distributed_flag		  in VARCHAR2,
                       x_revenue_distributed_flag	  in VARCHAR2,
                       x_billable_flag			      in VARCHAR2,
                       x_bill_hold_flag			      in VARCHAR2,
                       x_quantity			          in NUMBER,
                       x_non_labor_resource		      in VARCHAR2,
                       x_organization_id		      in NUMBER,
                       x_override_to_organization_id  in NUMBER,
                       x_raw_cost			          in NUMBER,
                       x_raw_cost_rate			      in NUMBER,
                       x_burden_cost			      in NUMBER,
                       x_burden_cost_rate		      in NUMBER,
                       x_cost_dist_rejection_code	  in VARCHAR2,
                       x_labor_cost_multiplier_name	  in VARCHAR2,
                       x_raw_revenue			      in NUMBER,
                       x_bill_rate			          in NUMBER,
                       x_accrued_revenue		      in NUMBER,
                       x_accrual_rate			      in NUMBER,
                       x_adjusted_revenue		      in NUMBER,
                       x_adjusted_rate			      in NUMBER,
                       x_bill_amount			      in NUMBER,
                       x_forecast_revenue		      in NUMBER,
                       x_bill_rate_multiplier		  in NUMBER,
                       x_rev_dist_rejection_code	  in VARCHAR2,
                       x_event_num			          in NUMBER,
                       x_event_task_id			      in NUMBER,
                       x_bill_job_id			      in NUMBER,
                       x_bill_job_billing_title		  in VARCHAR2,
                       x_bill_employee_billing_title  in VARCHAR2,
                       x_adjusted_expenditure_item_id in NUMBER,
                       x_net_zero_adjustment_flag	  in VARCHAR2,
                       x_transferred_from_exp_item_id in NUMBER,
                       x_converted_flag			      in VARCHAR2,
                       x_last_update_login		      in NUMBER,
                       x_attribute_category		      in VARCHAR2,
                       x_attribute1			          in VARCHAR2,
                       x_attribute2			          in VARCHAR2,
                       x_attribute3			          in VARCHAR2,
                       x_attribute4			          in VARCHAR2,
                       x_attribute5			          in VARCHAR2,
                       x_attribute6			          in VARCHAR2,
                       x_attribute7			          in VARCHAR2,
                       x_attribute8			          in VARCHAR2,
                       x_attribute9			          in VARCHAR2,
                       x_attribute10			      in VARCHAR2,
                       x_cost_ind_compiled_set_id	  in NUMBER,
                       x_rev_ind_compiled_set_id	  in NUMBER,
                       x_inv_ind_compiled_set_id	  in NUMBER,
                       x_cost_burden_distributed_flag in VARCHAR2,
                       x_ind_cost_dist_rejection_code in VARCHAR2,
                       x_orig_transaction_reference	  in VARCHAR2,
                       x_transaction_source		      in VARCHAR2,
                       x_project_id			          in NUMBER,
                       x_source_expenditure_item_id	  in NUMBER,
                       x_job_id				          in NUMBER,
                       x_expenditure_comment		  in VARCHAR2,
                       x_system_linkage_function      in VARCHAR2,
                       x_receipt_currency_amount      in NUMBER,
 		               x_receipt_currency_code        in VARCHAR2,
 		               x_receipt_exchange_rate        in NUMBER,
 		               x_denom_currency_code          in VARCHAR2,
 	                   x_denom_raw_cost               in NUMBER,
 		               x_denom_burdened_cost          in NUMBER,
   		               x_acct_exchange_rounding_limit in NUMBER,
 		               x_acct_currency_code           in VARCHAR2,
 		               x_acct_rate_date               in DATE,
 		               x_acct_rate_type               in VARCHAR2,
 		               x_acct_exchange_rate           in NUMBER,
 		               x_acct_raw_cost                in NUMBER,
 		               x_acct_burdened_cost           in NUMBER,
 		               x_project_currency_code        in VARCHAR2,
 	       	           x_project_rate_date            in DATE,
 		               x_project_rate_type            in VARCHAR2,
 		               x_project_exchange_rate        in NUMBER,
             	       x_recvr_org_id                 in NUMBER,
                       p_assignment_id                IN NUMBER  default null,
                       p_work_type_id                 IN NUMBER  default null,
                       p_projfunc_currency_code       IN varchar2 default null,
                       p_projfunc_cost_rate_date      IN date  default  null,
                       p_projfunc_cost_rate_type      IN varchar2 default null,
                       p_projfunc_cost_exchange_rate  IN number default null,
                       p_project_raw_cost             IN number default null,
                       p_project_burdened_cost        IN number default null,
		               p_tp_amt_type_code             IN varchar2 default null,
		               p_prvdr_accrual_date		      IN date default null,
		               p_recvr_accrual_date		      IN date default null,
		               p_capital_event_id             IN number default null
			) is

  cursor c_get_comment is select expenditure_comment
                          from pa_expenditure_comments
                          where expenditure_item_id = x_expenditure_item_id;

  temp_comment	c_get_comment%rowtype;

  action	VARCHAR2(30);
  outcome	VARCHAR2(100);
  num_processed	NUMBER;
  num_rejected	NUMBER;
  status	NUMBER;

 BEGIN
  -- need to check status, force user to use adjust if necessary

  update pa_expenditure_items
  set expenditure_item_id             = x_expenditure_item_id,
      last_update_date                = x_last_update_date,
      last_updated_by                 = x_last_updated_by,
      expenditure_id                  = x_expenditure_id,
      task_id                         = x_task_id,
      expenditure_item_date           = x_expenditure_item_date,
      expenditure_type                = x_expenditure_type,
      cost_distributed_flag           = x_cost_distributed_flag,
      revenue_distributed_flag        = x_revenue_distributed_flag,
      billable_flag                   = x_billable_flag,
      bill_hold_flag                  = x_bill_hold_flag,
      quantity                        = x_quantity,
      non_labor_resource              = x_non_labor_resource,
      organization_id                 = x_organization_id,
      override_to_organization_id     = x_override_to_organization_id,
      raw_cost                        =	x_raw_cost,
      raw_cost_rate                   = x_raw_cost_rate,
      burden_cost                     = x_burden_cost,
      burden_cost_rate                = x_burden_cost_rate,
      cost_dist_rejection_code        = x_cost_dist_rejection_code,
      labor_cost_multiplier_name      = x_labor_cost_multiplier_name,
      raw_revenue                     = x_raw_revenue,
      bill_rate                       = x_bill_rate,
      accrued_revenue                 = x_accrued_revenue,
      accrual_rate                    = x_accrual_rate,
      adjusted_revenue                = x_adjusted_revenue,
      adjusted_rate                   = x_adjusted_rate,
      bill_amount                     = x_bill_amount,
      forecast_revenue                = x_forecast_revenue,
      bill_rate_multiplier            = x_bill_rate_multiplier,
      rev_dist_rejection_code         = x_rev_dist_rejection_code,
      event_num                       = x_event_num,
      event_task_id                   = x_event_task_id,
      bill_job_id                     = x_bill_job_id,
      bill_job_billing_title          = x_bill_job_billing_title,
      bill_employee_billing_title     = x_bill_employee_billing_title,
      adjusted_expenditure_item_id    = x_adjusted_expenditure_item_id,
      net_zero_adjustment_flag        = x_net_zero_adjustment_flag,
      transferred_from_exp_item_id    = x_transferred_from_exp_item_id,
      converted_flag                  = x_converted_flag,
      last_update_login               = x_last_update_login,
      attribute_category              = x_attribute_category,
      attribute1                      = x_attribute1,
      attribute2                      = x_attribute2,
      attribute3                      = x_attribute3,
      attribute4                      = x_attribute4,
      attribute5                      = x_attribute5,
      attribute6                      = x_attribute6,
      attribute7                      =	x_attribute7,
      attribute8                      = x_attribute8,
      attribute9                      = x_attribute9,
      attribute10                     = x_attribute10,
      cost_ind_compiled_set_id        = x_cost_ind_compiled_set_id,
      rev_ind_compiled_set_id         = x_rev_ind_compiled_set_id,
      inv_ind_compiled_set_id         = x_inv_ind_compiled_set_id,
      cost_burden_distributed_flag    = x_cost_burden_distributed_flag,
      ind_cost_dist_rejection_code    = x_ind_cost_dist_rejection_code,
      orig_transaction_reference      = x_orig_transaction_reference,
      transaction_source              = x_transaction_source,
      project_id                      = x_project_id,
      source_expenditure_item_id      = x_source_expenditure_item_id,
      job_id                          = x_job_id,
      system_linkage_function         = x_system_linkage_function,
      receipt_currency_amount         = x_receipt_currency_amount,
      receipt_currency_code           = x_receipt_currency_code,
      receipt_exchange_rate           = x_receipt_exchange_rate,
      denom_currency_code             = x_denom_currency_code,
      denom_raw_cost                  = x_denom_raw_cost,
      denom_burdened_cost             = x_denom_burdened_cost,
      acct_exchange_rounding_limit    = x_acct_exchange_rounding_limit,
      acct_currency_code              = x_acct_currency_code,
      acct_rate_date                  = x_acct_rate_date,
      acct_rate_type                  = x_acct_rate_type,
      acct_exchange_rate              = x_acct_exchange_rate,
      acct_raw_cost                   = x_acct_raw_cost,
      acct_burdened_cost              = x_acct_burdened_cost,
      project_currency_code           = x_project_currency_code,
      project_rate_date               = x_project_rate_date,
      project_rate_type    	          = x_project_rate_type,
      project_exchange_rate           = x_project_exchange_rate,
      recvr_org_id                    = x_recvr_org_id
      ,assignment_id                  = p_assignment_id
      ,work_type_id                   = p_work_type_id
      ,projfunc_currency_code         = p_projfunc_currency_code
      ,projfunc_cost_rate_date        = p_projfunc_cost_rate_date
      ,projfunc_cost_rate_type        = p_projfunc_cost_rate_type
      ,projfunc_cost_exchange_rate    = p_projfunc_cost_exchange_rate
      ,project_raw_cost               = p_project_raw_cost
      ,project_burdened_cost          = p_project_burdened_cost
      ,tp_amt_type_code		          = p_tp_amt_type_code
      ,prvdr_accrual_date	          = p_prvdr_accrual_date
      ,recvr_accrual_date	          = p_recvr_accrual_date
      ,capital_event_id               = p_capital_event_id
  where rowid = x_rowid;

  -- this assumes the neg quantity has already been validated, and
  -- is matched.  unmatched occurs in adjustments
/* Bug 1715308 : Removed the condition of x_quantity < 0
  if (((x_quantity < 0) or (x_burden_cost < 0)) and
       (x_net_zero_adjustment_flag = 'Y')) then */
  if x_net_zero_adjustment_flag = 'Y' then
    update pa_expenditure_items
    set net_zero_adjustment_flag = 'Y'
    where expenditure_item_id = x_adjusted_expenditure_item_id;

    -- Date :  17-JUN-99
    --
    -- Earlier the value for parameter expenditure id was NULL. This
    -- resulted in the reversing related items getting creating in a
    -- different expenditure id which is different from that of the
    -- source item. Changed the NULL value to the current expenditure
    -- id.
    --
    pa_adjustments.ReverseRelatedItems(x_adjusted_expenditure_item_id,
                                       x_expenditure_id,
                                       'PAXTREPE',
                                       X_last_updated_by,
                                       X_last_update_login,
                                       status );
    --
    --
  end if;

  -- if item is released, then need to use the adjust package
  open c_get_comment;
  fetch c_get_comment into temp_comment;
  if (c_get_comment%notfound) then
    if (x_expenditure_comment is not null) then
      insert into pa_expenditure_comments (expenditure_item_id,
                                           line_number,
                                           expenditure_comment,
                                           last_update_date,
                                           last_updated_by,
                                           creation_date,
                                           created_by,
                                           last_update_login)
      values (x_expenditure_item_id,
              1,
              x_expenditure_comment,
              x_last_update_date,
              x_last_updated_by,
              x_last_update_date,  -- is this okay
              x_last_updated_by,
              x_last_update_login);
    end if;
  else
    if (x_expenditure_comment is not null) then
      update pa_expenditure_comments
      set expenditure_comment = x_expenditure_comment
      where expenditure_item_id = x_expenditure_item_id;
    else
      delete from pa_expenditure_comments
      where expenditure_item_id = x_expenditure_item_id;
    end if;
  end if;

 END update_row;


 -- Given the expenditure_item_id, delete the row.
 -- If deletion of an reversing item occurs, make sure to reset the
 -- net_zero_adjustment_flag in the reversed item.

 procedure delete_row (x_expenditure_item_id	in NUMBER) is

  cursor check_reversing is
    select adjusted_expenditure_item_id from pa_expenditure_items
    where expenditure_item_id = x_expenditure_item_id;

  cursor check_source  is
    select expenditure_item_id, adjusted_expenditure_item_id
    from pa_expenditure_items
    where source_expenditure_item_id = x_expenditure_item_id;

  rev_item	check_reversing%rowtype;
  source_item   check_source%rowtype;

 BEGIN

  -- reset the adjustment flag.
  open check_reversing;
  fetch check_reversing into rev_item;
  if (rev_item.adjusted_expenditure_item_id is not null) then
    update pa_expenditure_items
    set net_zero_adjustment_flag = 'N'
    where expenditure_item_id = rev_item.adjusted_expenditure_item_id;

    open check_source  ;
    --
    -- Previously the following section which deals with related items was
    -- done based on the assumption that there can exist only one related
    -- item. So not suprisingly bug# 912209 was logged which states that
    -- only one of the related item was getting deleted when the source
    -- item was deleted. Now the deletion of related items sections is
    -- called in a loop for each of the related items.
    --
    LOOP
      fetch check_source into source_item ;
      if check_source%notfound then exit ;
      end if;
      fetch check_source into source_item ;
      if (source_item.adjusted_expenditure_item_id is not null)  then
           update pa_expenditure_items
           set net_zero_adjustment_flag = 'N'
           where expenditure_item_id = source_item.adjusted_expenditure_item_id ;

           delete from pa_expenditure_items
           where expenditure_item_id = source_item.expenditure_item_id;
      end if ;
    END LOOP;
    --
    -- End section
    --
    close check_source ;

  end if;

  -- error checking?
  delete from pa_expenditure_comments
  where expenditure_item_id = x_expenditure_item_id;

  delete from pa_expenditure_items
  where expenditure_item_id = x_expenditure_item_id;


 END delete_row;


 procedure delete_row (x_rowid	in VARCHAR2) is

  cursor get_itemid is select expenditure_item_id from pa_expenditure_items
                       where rowid = x_rowid;
  x_expenditure_item_id  NUMBER;

 BEGIN
  open get_itemid;
  fetch get_itemid into x_expenditure_item_id;

  delete_row (x_expenditure_item_id);

 END delete_row;



 procedure lock_row (x_rowid	in VARCHAR2) is
 BEGIN
  null;
 END lock_row;

END pa_expenditure_items_pkg;

/
