--------------------------------------------------------
--  DDL for Package Body IGW_BUDGETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_BUDGETS_PKG" AS
-- $Header: igwbuthb.pls 115.10 2002/03/28 19:13:09 pkm ship    $
  procedure INSERT_ROW (
	x_rowid	IN OUT  VARCHAR2
	,p_proposal_id		NUMBER
	,p_version_id		NUMBER
  	,p_start_date		DATE
  	,p_end_date		DATE
  	,p_total_cost		NUMBER
  	,p_total_direct_cost	NUMBER
	,p_total_indirect_cost	NUMBER
	,p_cost_sharing_amount	NUMBER
	,p_underrecovery_amount	NUMBER
	,p_residual_funds	NUMBER
	,p_total_cost_limit	NUMBER
	,p_oh_rate_class_id	NUMBER
	,p_proposal_form_number VARCHAR2
	,p_comments		VARCHAR2
	,p_final_version_flag	VARCHAR2
	,p_budget_type_code	VARCHAR2
	,p_attribute_category	VARCHAR2
	,p_attribute1		VARCHAR2
	,p_attribute2		VARCHAR2
	,p_attribute3		VARCHAR2
	,p_attribute4		VARCHAR2
	,p_attribute5		VARCHAR2
	,p_attribute6		VARCHAR2
	,p_attribute7		VARCHAR2
	,p_attribute8		VARCHAR2
	,p_attribute9		VARCHAR2
	,p_attribute10		VARCHAR2
	,p_attribute11		VARCHAR2
	,p_attribute12		VARCHAR2
	,p_attribute13		VARCHAR2
	,p_attribute14		VARCHAR2
	,p_attribute15  	VARCHAR2) IS
    cursor c_budgets is
    select  rowid
    from    igw_budgets
    where   proposal_id = p_proposal_id;

    l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
    l_last_update_date  DATE   := SYSDATE;
  begin


    insert into igw_budgets(
	proposal_id
	,version_id
	,start_date
	,end_date
	,total_cost
	,total_direct_cost
	,total_indirect_cost
	,cost_sharing_amount
	,underrecovery_amount
	,residual_funds
	,total_cost_limit
	,oh_rate_class_id
	,proposal_form_number
	,comments
	,final_version_flag
	,budget_type_code
	,last_update_date
	,last_updated_by
	,creation_date
	,created_by
	,last_update_login
	,attribute_category
	,attribute1
	,attribute2
	,attribute3
	,attribute4
	,attribute5
	,attribute6
	,attribute7
	,attribute8
	,attribute9
	,attribute10
	,attribute11
	,attribute12
	,attribute13
	,attribute14
	,attribute15)
    values
      ( p_proposal_id
	,p_version_id
  	,p_start_date
  	,p_end_date
  	,p_total_cost
  	,p_total_direct_cost
	,p_total_indirect_cost
	,p_cost_sharing_amount
	,p_underrecovery_amount
	,p_residual_funds
	,p_total_cost_limit
	,p_oh_rate_class_id
	,p_proposal_form_number
	,p_comments
	,p_final_version_flag
	,p_budget_type_code
	,l_last_update_date
	,l_last_updated_by
	,l_last_update_date
	,l_last_updated_by
	,l_last_update_login
	,p_attribute_category
	,p_attribute1
	,p_attribute2
	,p_attribute3
	,p_attribute4
	,p_attribute5
	,p_attribute6
	,p_attribute7
	,p_attribute8
	,p_attribute9
	,p_attribute10
	,p_attribute11
	,p_attribute12
	,p_attribute13
	,p_attribute14
	,p_attribute15);

    open c_budgets;
    fetch c_budgets into x_ROWID;
    if (c_budgets%notfound) then
      close c_budgets;
      raise no_data_found;
    end if;
    close c_budgets;
  end insert_row;

  procedure lock_row(
        x_rowid			VARCHAR2
	,p_proposal_id		NUMBER
	,p_version_id		NUMBER
  	,p_start_date		DATE
  	,p_end_date		DATE
  	,p_total_cost		NUMBER
  	,p_total_direct_cost	NUMBER
	,p_total_indirect_cost	NUMBER
	,p_cost_sharing_amount	NUMBER
	,p_underrecovery_amount	NUMBER
	,p_residual_funds	NUMBER
	,p_total_cost_limit	NUMBER
	,p_oh_rate_class_id	NUMBER
	,p_proposal_form_number VARCHAR2
	,p_comments		VARCHAR2
	,p_final_version_flag	VARCHAR2
	,p_budget_type_code	VARCHAR2
	,p_attribute_category	VARCHAR2
	,p_attribute1		VARCHAR2
	,p_attribute2		VARCHAR2
	,p_attribute3		VARCHAR2
	,p_attribute4		VARCHAR2
	,p_attribute5		VARCHAR2
	,p_attribute6		VARCHAR2
	,p_attribute7		VARCHAR2
	,p_attribute8		VARCHAR2
	,p_attribute9		VARCHAR2
	,p_attribute10		VARCHAR2
	,p_attribute11		VARCHAR2
	,p_attribute12		VARCHAR2
	,p_attribute13		VARCHAR2
	,p_attribute14		VARCHAR2
	,p_attribute15  	VARCHAR2) IS
    cursor c_budgets is
      select  	*
     from  	igw_budgets
     where 	rowid = x_rowid
     for update of proposal_id nowait;

     tlinfo c_budgets%rowtype;
  begin
    open c_budgets;
    fetch c_budgets into tlinfo;
    if (c_budgets%notfound) then
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
      close c_budgets;
      return;
    end if;
    close c_budgets;
    if ( (tlinfo.proposal_id = p_proposal_id)
        AND (tlinfo.version_id = p_version_id)
        AND ((tlinfo.start_date = p_start_date)
           OR ((tlinfo.start_date is null)
               AND (p_start_date is null)))
        AND ((tlinfo.end_date = p_end_date)
           OR ((tlinfo.end_date is null)
               AND (p_end_date is null)))
        AND ((tlinfo.total_cost = p_total_cost)
           OR ((tlinfo.total_cost is null)
               AND (p_total_cost is null)))
        AND ((tlinfo.total_direct_cost = p_total_direct_cost)
           OR ((tlinfo.total_direct_cost is null)
               AND (p_total_direct_cost is null)))
        AND ((tlinfo.cost_sharing_amount = p_cost_sharing_amount)
           OR ((tlinfo.cost_sharing_amount is null)
               AND (p_cost_sharing_amount is null)))
        AND ((tlinfo.underrecovery_amount = p_underrecovery_amount)
           OR ((tlinfo.underrecovery_amount is null)
               AND (p_underrecovery_amount is null)))
        AND ((tlinfo.residual_funds = p_residual_funds)
           OR ((tlinfo.residual_funds is null)
               AND (p_residual_funds is null)))
        AND ((tlinfo.total_cost_limit = p_total_cost_limit)
           OR ((tlinfo.total_cost_limit is null)
               AND (p_total_cost_limit is null)))
        AND ((tlinfo.oh_rate_class_id = p_oh_rate_class_id)
           OR ((tlinfo.oh_rate_class_id is null)
               AND (p_oh_rate_class_id is null)))
        AND ((tlinfo.proposal_form_number = p_proposal_form_number)
           OR ((tlinfo.proposal_form_number is null)
               AND (p_proposal_form_number is null)))
        AND ((tlinfo.comments = p_comments)
           OR ((tlinfo.comments is null)
               AND (p_comments is null)))
        AND ((tlinfo.final_version_flag = p_final_version_flag)
           OR ((tlinfo.final_version_flag is null)
               AND (p_final_version_flag is null)))
        AND ((tlinfo.budget_type_code = p_budget_type_code)
           OR ((tlinfo.budget_type_code is null)
               AND (p_budget_type_code is null)))
        AND ((tlinfo.ATTRIBUTE1 = P_ATTRIBUTE1)
           OR ((tlinfo.ATTRIBUTE1 is null)
               AND (P_ATTRIBUTE1 is null)))
        AND ((tlinfo.ATTRIBUTE2 = P_ATTRIBUTE2)
           OR ((tlinfo.ATTRIBUTE2 is null)
               AND (P_ATTRIBUTE2 is null)))
        AND ((tlinfo.ATTRIBUTE3 = P_ATTRIBUTE3)
           OR ((tlinfo.ATTRIBUTE3 is null)
               AND (P_ATTRIBUTE3 is null)))
        AND ((tlinfo.ATTRIBUTE4 = P_ATTRIBUTE4)
           OR ((tlinfo.ATTRIBUTE4 is null)
               AND (P_ATTRIBUTE4 is null)))
        AND ((tlinfo.ATTRIBUTE5 = P_ATTRIBUTE5)
           OR ((tlinfo.ATTRIBUTE5 is null)
               AND (P_ATTRIBUTE5 is null)))
        AND ((tlinfo.ATTRIBUTE6 = P_ATTRIBUTE6)
             OR ((tlinfo.ATTRIBUTE6 is null)
               AND (P_ATTRIBUTE6 is null)))
        AND ((tlinfo.ATTRIBUTE7 = P_ATTRIBUTE7)
           OR ((tlinfo.ATTRIBUTE7 is null)
               AND (P_ATTRIBUTE7 is null)))
        AND ((tlinfo.ATTRIBUTE8 = P_ATTRIBUTE8)
           OR ((tlinfo.ATTRIBUTE8 is null)
               AND (P_ATTRIBUTE8 is null)))
        AND ((tlinfo.ATTRIBUTE9 = P_ATTRIBUTE9)
           OR ((tlinfo.ATTRIBUTE9 is null)
               AND (P_ATTRIBUTE9 is null)))
        AND ((tlinfo.ATTRIBUTE10 = P_ATTRIBUTE10)
           OR ((tlinfo.ATTRIBUTE10 is null)
               AND (P_ATTRIBUTE10 is null)))
        AND ((tlinfo.ATTRIBUTE11 = P_ATTRIBUTE11)
           OR ((tlinfo.ATTRIBUTE11 is null)
               AND (P_ATTRIBUTE11 is null)))
        AND ((tlinfo.ATTRIBUTE12 = P_ATTRIBUTE12)
           OR ((tlinfo.ATTRIBUTE12 is null)
               AND (P_ATTRIBUTE12 is null)))
        AND ((tlinfo.ATTRIBUTE13 = P_ATTRIBUTE13)
           OR ((tlinfo.ATTRIBUTE13 is null)
               AND (P_ATTRIBUTE13 is null)))
        AND ((tlinfo.ATTRIBUTE14 = P_ATTRIBUTE14)
           OR ((tlinfo.ATTRIBUTE14 is null)
               AND (P_ATTRIBUTE14 is null)))
        AND ((tlinfo.ATTRIBUTE15 = P_ATTRIBUTE15)
           OR ((tlinfo.ATTRIBUTE15 is null)
               AND (P_ATTRIBUTE15 is null)))
   ) then
      null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;
    return;
    end lock_row;

  procedure update_row(
	p_proposal_id		NUMBER
	,p_version_id		NUMBER
  	,p_start_date		DATE
  	,p_end_date		DATE
  	,p_total_cost		NUMBER
  	,p_total_direct_cost	NUMBER
	,p_total_indirect_cost	NUMBER
	,p_cost_sharing_amount	NUMBER
	,p_underrecovery_amount	NUMBER
	,p_residual_funds	NUMBER
	,p_total_cost_limit	NUMBER
	,p_oh_rate_class_id	NUMBER
	,p_proposal_form_number VARCHAR2
	,p_comments		VARCHAR2
	,p_final_version_flag	VARCHAR2
	,p_budget_type_code	VARCHAR2
	,p_attribute_category	VARCHAR2
	,p_attribute1		VARCHAR2
	,p_attribute2		VARCHAR2
	,p_attribute3		VARCHAR2
	,p_attribute4		VARCHAR2
	,p_attribute5		VARCHAR2
	,p_attribute6		VARCHAR2
	,p_attribute7		VARCHAR2
	,p_attribute8		VARCHAR2
	,p_attribute9		VARCHAR2
	,p_attribute10		VARCHAR2
	,p_attribute11		VARCHAR2
	,p_attribute12		VARCHAR2
	,p_attribute13		VARCHAR2
	,p_attribute14		VARCHAR2
	,p_attribute15  	VARCHAR2) IS
    l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
    l_last_update_date  DATE   := SYSDATE;
  begin

    update igw_budgets
    set	   start_date = p_start_date
    ,	   end_date = p_end_date
    ,	   total_cost = p_total_cost
    ,	   total_direct_cost = p_total_direct_cost
    ,	   total_indirect_cost = p_total_indirect_cost
    ,      cost_sharing_amount = p_cost_sharing_amount
    ,	   underrecovery_amount = p_underrecovery_amount
    ,      residual_funds = p_residual_funds
    ,      total_cost_limit = p_total_cost_limit
    ,      oh_rate_class_id = p_oh_rate_class_id
    ,	   proposal_form_number = p_proposal_form_number
    ,      comments = p_comments
    ,      final_version_flag = p_final_version_flag
    ,	   budget_type_code	= p_budget_type_code
    ,	   ATTRIBUTE_CATEGORY = P_ATTRIBUTE_CATEGORY
    ,	   ATTRIBUTE1 = P_ATTRIBUTE1
    ,	   ATTRIBUTE2 = P_ATTRIBUTE2
    ,	   ATTRIBUTE3 = P_ATTRIBUTE3
    ,	   ATTRIBUTE4 = P_ATTRIBUTE4
    ,	   ATTRIBUTE5 = P_ATTRIBUTE5
    ,	   ATTRIBUTE6 = P_ATTRIBUTE6
    ,	   ATTRIBUTE7 = P_ATTRIBUTE7
    ,	   ATTRIBUTE8 = P_ATTRIBUTE8
    ,	   ATTRIBUTE9 = P_ATTRIBUTE9
    ,	   ATTRIBUTE10 = P_ATTRIBUTE10
    ,	   ATTRIBUTE11 = P_ATTRIBUTE11
    ,	   ATTRIBUTE12 = P_ATTRIBUTE12
    ,	   ATTRIBUTE13 = P_ATTRIBUTE13
    ,	   ATTRIBUTE14 = P_ATTRIBUTE14
    ,  	   ATTRIBUTE15 = P_ATTRIBUTE15
    where  proposal_id = p_proposal_id
    and	   version_id = p_version_id;

    if (sql%notfound) then
      raise no_data_found;
    end if;
  end update_row;

END IGW_BUDGETS_PKG;

/
