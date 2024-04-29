--------------------------------------------------------
--  DDL for Package Body GMS_ENCUMBRANCE_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_ENCUMBRANCE_ITEMS_PKG" as
/* $Header: GMSTITMB.pls 120.1 2007/02/06 09:47:11 rshaik ship $ */

 procedure insert_row (x_rowid                        in out NOCOPY VARCHAR2	,
                       x_encumbrance_item_id          in out NOCOPY NUMBER,
                       x_last_update_date             in DATE,
                       x_last_updated_by              in NUMBER,
                       x_creation_date                in DATE,
                       x_created_by                   in NUMBER,
                       x_encumbrance_id               in NUMBER,
                       x_task_id                      in NUMBER,
                       x_encumbrance_item_date        in DATE,
                       x_encumbrance_type             in VARCHAR2,
                       x_enc_distributed_flag        in VARCHAR2,
                       x_amount                     in NUMBER		DEFAULT NULL,
                       x_override_to_organization_id  in NUMBER		DEFAULT NULL,
                       x_adjusted_encumbrance_item_id in NUMBER		DEFAULT NULL,
                       x_net_zero_adjustment_flag     in VARCHAR2	DEFAULT NULL,
                       x_transferred_from_enc_item_id in NUMBER		DEFAULT NULL,
                       x_last_update_login            in NUMBER		DEFAULT NULL,
                       x_request_id                   in NUMBER         DEFAULT NULL,
                       x_attribute_category           in VARCHAR2	DEFAULT NULL,
                       x_attribute1                   in VARCHAR2	DEFAULT NULL,
                       x_attribute2                   in VARCHAR2	DEFAULT NULL,
                       x_attribute3                   in VARCHAR2	DEFAULT NULL,
                       x_attribute4                   in VARCHAR2	DEFAULT NULL,
                       x_attribute5                   in VARCHAR2	DEFAULT NULL,
                       x_attribute6                   in VARCHAR2	DEFAULT NULL,
                       x_attribute7                   in VARCHAR2	DEFAULT NULL,
                       x_attribute8                   in VARCHAR2	DEFAULT NULL,
                       x_attribute9                   in VARCHAR2	DEFAULT NULL,
                       x_attribute10                  in VARCHAR2	DEFAULT NULL,
                       x_orig_transaction_reference   in VARCHAR2	DEFAULT NULL,
                       x_transaction_source           in VARCHAR2	DEFAULT NULL,
                       x_project_id                   in NUMBER		DEFAULT NULL,
                       x_source_encumbrance_item_id   in NUMBER		DEFAULT NULL,
                       x_job_id                       in NUMBER		DEFAULT NULL,
                       x_system_linkage_function      in VARCHAR2,
                       x_denom_currency_code          in VARCHAR2	DEFAULT NULL,
                       x_denom_raw_amount             in NUMBER         DEFAULT NULL,
                       x_acct_exchange_rounding_limit in NUMBER		DEFAULT NULL,
                       x_acct_currency_code           in VARCHAR2	DEFAULT NULL,
                       x_acct_rate_date               in DATE		DEFAULT NULL,
                       x_acct_rate_type               in VARCHAR2	DEFAULT NULL,
                       x_acct_exchange_rate           in NUMBER		DEFAULT NULL,
                       x_acct_raw_cost                in NUMBER         DEFAULT NULL,
                       x_project_currency_code        in VARCHAR2	DEFAULT NULL,
                       x_project_rate_date            in DATE		DEFAULT NULL,
                       x_project_rate_type            in VARCHAR2	DEFAULT NULL,
                       x_project_exchange_rate        in NUMBER		DEFAULT NULL,
                       x_encumbrance_comment          in VARCHAR2	DEFAULT NULL,
                       x_org_id                       in NUMBER ,
                       x_denom_tp_currency_code       in VARCHAR2       DEFAULT NULL,
                       x_denom_transfer_price         in NUMBER         DEFAULT NULL,
                       x_person_id                    in NUMBER         DEFAULT NULL,
                       x_incurred_by_person_id        in NUMBER         DEFAULT NULL,
                       x_ind_compiled_set_id          in NUMBER         DEFAULT NULL,
                       x_pa_date                      in DATE           DEFAULT NULL,
                       x_gl_date                      in DATE           DEFAULT NULL,
                       x_line_num                     in NUMBER         DEFAULT 1,
                       x_burden_sum_dest_run_id       in NUMBER         DEFAULT NULL,
                       x_burden_sum_source_run_id     in NUMBER         DEFAULT NULL) IS


  cursor return_rowid is select rowid from gms_encumbrance_items
                         where encumbrance_item_id = x_encumbrance_item_id;
  cursor get_itemid is select gms_encumbrance_items_s.nextval from sys.dual;

  status	NUMBER;
  l_project_id  number; --Bug 5726575
 BEGIN

  if (x_encumbrance_item_id is null) then
    open get_itemid;
    fetch get_itemid into x_encumbrance_item_id;
    close get_itemid;
  end if;

  --Bug 5726575
  if x_project_id is null then
    select project_id
    into l_project_id
    from pa_tasks
    where task_id = x_task_id;
  end if;

  -- if amt is negative, need to update reversed original

  insert into gms_encumbrance_items (encumbrance_item_id,
                                    last_update_date,
                                    last_updated_by,
                                    creation_date,
                                    created_by,
                                    encumbrance_id,
                                    task_id,
                                    encumbrance_item_date,
                                    encumbrance_type,
                                    enc_distributed_flag,
                                    amount,
                                    override_to_organization_id,
                                    adjusted_encumbrance_item_id,
                                    net_zero_adjustment_flag,
                                    transferred_from_enc_item_id,
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
                                    orig_transaction_reference,
                                    transaction_source,
                                    project_id,
                                    source_encumbrance_item_id,
                                    job_id,
                                    system_linkage_function,
 		       		    denom_currency_code,
                                    denom_raw_amount,
				    acct_exchange_rounding_limit,
   		       		    acct_currency_code,
 		       		    acct_rate_date,
				    acct_rate_type,
 		       		    acct_exchange_rate,
                                    acct_raw_cost,
 		       		    project_currency_code,
 	       	       		    project_rate_date,
 		       		    project_rate_type,
 		       		    project_exchange_rate,
				    denom_tp_currency_code,
			            denom_transfer_price,
                                    encumbrance_comment,
                                    person_id,
                                    incurred_by_person_id,
                                    ind_compiled_set_id,
                                    pa_date,
                                    gl_date,
                                    line_num,
                                    burden_sum_dest_run_id,
                                    burden_sum_source_run_id ,
                                    org_id )
 values (x_encumbrance_item_id,
         x_last_update_date,
         x_last_updated_by,
         x_creation_date,
         x_created_by,
         x_encumbrance_id,
         x_task_id,
         x_encumbrance_item_date,
         x_encumbrance_type,
         x_enc_distributed_flag,
         x_amount,
         x_override_to_organization_id,
         x_adjusted_encumbrance_item_id,
         x_net_zero_adjustment_flag,
         x_transferred_from_enc_item_id,
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
         x_orig_transaction_reference,
         x_transaction_source,
         nvl(x_project_id, l_project_id),--Bug 5726575 x_project_id,
         x_source_encumbrance_item_id,
         x_job_id,
         x_system_linkage_function,
    	 x_denom_currency_code,
         x_denom_raw_amount,
   	 x_acct_exchange_rounding_limit,
 	 x_acct_currency_code,
 	 x_acct_rate_date,
 	 x_acct_rate_type,
 	 x_acct_exchange_rate,
         x_acct_raw_cost,
 	 x_project_currency_code,
 	 x_project_rate_date,
 	 x_project_rate_type,
 	 x_project_exchange_rate,
         x_denom_tp_currency_code,
         x_denom_transfer_price,
         x_encumbrance_comment,
         x_person_id,
         x_incurred_by_person_id,
         x_ind_compiled_set_id,
         x_pa_date,
         x_gl_date,
         x_line_num,
         x_burden_sum_dest_run_id,
         x_burden_sum_source_run_id,
         x_org_id  );

  open return_rowid;
  fetch return_rowid into x_rowid;
  if (return_rowid%notfound) then
    raise NO_DATA_FOUND;  -- should we return something else?
  end if;
  close return_rowid;

  -- this assumes the neg amount has already been validated, and
  -- is matched.  unmatched occurs in adjustments
--  if (((x_quantity < 0) or (x_burden_cost < 0)) and
 if ((x_amount < 0)  and
       (x_net_zero_adjustment_flag = 'Y'))  then
    update gms_encumbrance_items
    set net_zero_adjustment_flag = 'Y'
    where encumbrance_item_id = x_adjusted_encumbrance_item_id;

    -- Date :  17-JUN-99
    --
    -- Earlier the value for parameter encumbrance id was NULL. This
    -- resulted in the reversing related items getting creating in a
    -- different encumbrance id which is different from that of the
    -- source item. Changed the NULL value to the current encumbrance
    -- id.
    --
/*
    pa_adjustments.ReverseRelatedItems(x_adjusted_encumbrance_item_id,
                                       x_encumbrance_id,
                                       'PAXTREPE',
                                       X_created_by,
                                       X_last_update_login,
                                       status );
*/
    --
    --
  end if;
 END insert_row;
-- =====================================================================================

 procedure update_row (x_rowid				in VARCHAR2,
                       x_encumbrance_item_id		in NUMBER,
                       x_last_update_date		in DATE,
                       x_last_updated_by		in NUMBER,
                       x_encumbrance_id			in NUMBER,
                       x_task_id			in NUMBER,
                       x_encumbrance_item_date		in DATE,
                       x_encumbrance_type		in VARCHAR2,
                       x_enc_distributed_flag		in VARCHAR2,
                       x_amount				in NUMBER,
                       x_override_to_organization_id	in NUMBER,
                       x_adjusted_encumbrance_item_id	in NUMBER,
                       x_net_zero_adjustment_flag	in VARCHAR2,
                       x_transferred_from_enc_item_id	in NUMBER,
                       x_last_update_login		in NUMBER,
                       x_attribute_category		in VARCHAR2,
                       x_attribute1			in VARCHAR2,
                       x_attribute2			in VARCHAR2,
                       x_attribute3			in VARCHAR2,
                       x_attribute4			in VARCHAR2,
                       x_attribute5			in VARCHAR2,
                       x_attribute6			in VARCHAR2,
                       x_attribute7			in VARCHAR2,
                       x_attribute8			in VARCHAR2,
                       x_attribute9			in VARCHAR2,
                       x_attribute10			in VARCHAR2,
                       x_orig_transaction_reference	in VARCHAR2,
                       x_transaction_source		in VARCHAR2,
                       x_project_id			in NUMBER,
                       x_source_encumbrance_item_id	in NUMBER,
                       x_job_id				in NUMBER,
                       x_system_linkage_function        in VARCHAR2,
 		       x_denom_currency_code            in VARCHAR2,
                       x_denom_raw_amount               in NUMBER,
   		       x_acct_exchange_rounding_limit   in NUMBER,
 		       x_acct_currency_code             in VARCHAR2,
 		       x_acct_rate_date                 in DATE,
 		       x_acct_rate_type                 in VARCHAR2,
 		       x_acct_exchange_rate             in NUMBER,
                       x_acct_raw_cost                  in NUMBER,
 		       x_project_currency_code          in VARCHAR2,
 	       	       x_project_rate_date              in DATE,
 		       x_project_rate_type              in VARCHAR2,
 		       x_project_exchange_rate          in NUMBER,
                       x_encumbrance_comment            in VARCHAR2,
                       x_pa_date                        in DATE,
                       x_gl_date                        in DATE ) IS
/*
                       x_denom_tp_currency_code         in VARCHAR2,
                       x_denom_transfer_price           in NUMBER ,
                       x_person_id                      in NUMBER,
                       x_incurred_by_person_id          in NUMBER,
                       x_ind_compiled_set_id            in NUMBER,
                       x_line_num                       in NUMBER,
                       x_burden_sum_dest_run_id         in NUMBER,
                       x_burden_sum_source_run_id       in NUMBER) IS
*/

  action	VARCHAR2(30);
  outcome	VARCHAR2(100);
  num_processed	NUMBER;
  num_rejected	NUMBER;
  status	NUMBER;
  l_project_id  number; --Bug 5726575

 BEGIN
  -- need to check status, force user to use adjust if necessary

  --Bug 5693864
  if x_project_id is null then
    select project_id
    into l_project_id
    from pa_tasks
    where task_id = x_task_id;
  end if;

  update gms_encumbrance_items
  set encumbrance_item_id = 		x_encumbrance_item_id,
      last_update_date = 		x_last_update_date,
      last_updated_by = 		x_last_updated_by,
      encumbrance_id = 			x_encumbrance_id,
      task_id = 			x_task_id,
      encumbrance_item_date = 		x_encumbrance_item_date,
      encumbrance_type = 		x_encumbrance_type,
      enc_distributed_flag = 		x_enc_distributed_flag,
      amount = 				x_amount,
      override_to_organization_id = 	x_override_to_organization_id,
      adjusted_encumbrance_item_id = 	x_adjusted_encumbrance_item_id,
      net_zero_adjustment_flag = 	x_net_zero_adjustment_flag,
      transferred_from_enc_item_id = 	x_transferred_from_enc_item_id,
      last_update_login = 		x_last_update_login,
      attribute_category = 		x_attribute_category,
      attribute1 = 			x_attribute1,
      attribute2 = 			x_attribute2,
      attribute3 = 			x_attribute3,
      attribute4 = 			x_attribute4,
      attribute5 = 			x_attribute5,
      attribute6 = 			x_attribute6,
      attribute7 =	 		x_attribute7,
      attribute8 = 			x_attribute8,
      attribute9 = 			x_attribute9,
      attribute10 = 			x_attribute10,
      orig_transaction_reference = 	x_orig_transaction_reference,
      transaction_source = 		x_transaction_source,
      project_id =                      nvl(x_project_id, l_project_id), --Bug 5693864 x_project_id,
      source_encumbrance_item_id = 	x_source_encumbrance_item_id,
      job_id = 				x_job_id,
      system_linkage_function    =      x_system_linkage_function,
      denom_currency_code             = x_denom_currency_code,
      denom_raw_amount                = x_denom_raw_amount,
      acct_exchange_rounding_limit    = x_acct_exchange_rounding_limit,
      acct_currency_code              = x_acct_currency_code,
      acct_rate_date                  = x_acct_rate_date,
      acct_rate_type                  = x_acct_rate_type,
      acct_exchange_rate              = x_acct_exchange_rate,
      acct_raw_cost                   = x_acct_raw_cost,
      encumbrance_comment              = x_encumbrance_comment  ,
      pa_date                         = x_pa_date,
      gl_date                         = x_gl_date
     /*
      project_currency_code           = x_project_currency_code,
      project_rate_date               = x_project_rate_date,
      project_rate_type    	      = x_project_rate_type,
      project_exchange_rate           = x_project_exchange_rate
     */
       where rowid = x_rowid;

  -- this assumes the neg amount has already been validated, and
  -- is matched.  unmatched occurs in adjustments
--  if (((x_quantity < 0) or (x_burden_cost < 0)) and
 if ((x_amount < 0)  and
       (x_net_zero_adjustment_flag = 'Y')) then
    update gms_encumbrance_items
    set net_zero_adjustment_flag = 'Y'
    where encumbrance_item_id = x_adjusted_encumbrance_item_id;

    -- Date :  17-JUN-99
    --
    -- Earlier the value for parameter encumbrance id was NULL. This
    -- resulted in the reversing related items getting creating in a
    -- different encumbrance id which is different from that of the
    -- source item. Changed the NULL value to the current encumbrance
    -- id.
    --
    pa_adjustments.ReverseRelatedItems(x_adjusted_encumbrance_item_id,
                                       x_encumbrance_id,
                                       'PAXTREPE',
                                       X_last_updated_by,
                                       X_last_update_login,
                                       status );
    --
    --
  end if;

 END update_row;

-- =========================================================================================
 -- Given the encumbrance_item_id, delete the row.
 -- If deletion of an reversing item occurs, make sure to reset the
 -- net_zero_adjustment_flag in the reversed item.

 procedure delete_row (x_encumbrance_item_id	in NUMBER) is

  cursor check_reversing is
    select adjusted_encumbrance_item_id from gms_encumbrance_items
    where encumbrance_item_id = x_encumbrance_item_id;

  cursor check_source  is
    select encumbrance_item_id, adjusted_encumbrance_item_id
    from gms_encumbrance_items
    where source_encumbrance_item_id = x_encumbrance_item_id;

  rev_item	check_reversing%rowtype;
  source_item   check_source%rowtype;

 BEGIN

  -- reset the adjustment flag.
  open check_reversing;
  fetch check_reversing into rev_item;
  if (rev_item.adjusted_encumbrance_item_id is not null) then
    update gms_encumbrance_items
    set net_zero_adjustment_flag = 'N'
    where encumbrance_item_id = rev_item.adjusted_encumbrance_item_id;

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
      if (source_item.adjusted_encumbrance_item_id is not null)  then
           update gms_encumbrance_items
           set net_zero_adjustment_flag = 'N'
           where encumbrance_item_id = source_item.adjusted_encumbrance_item_id ;

           delete from gms_encumbrance_items
           where encumbrance_item_id = source_item.encumbrance_item_id;
      end if ;
    END LOOP;
    --
    -- End section
    --
    close check_source ;

  end if;

  delete from gms_encumbrance_items
  where encumbrance_item_id = x_encumbrance_item_id;


 END delete_row;

-- =======================================================================================================
 procedure delete_row (x_rowid	in VARCHAR2) is

  cursor get_itemid is select encumbrance_item_id from gms_encumbrance_items
                       where rowid = x_rowid;
  x_encumbrance_item_id  NUMBER;

 BEGIN
  open get_itemid;
  fetch get_itemid into x_encumbrance_item_id;

  delete_row (x_encumbrance_item_id);

 END delete_row;



 procedure lock_row (x_rowid	in VARCHAR2) is
 BEGIN
  null;
 END lock_row;

END gms_encumbrance_items_pkg;

/
