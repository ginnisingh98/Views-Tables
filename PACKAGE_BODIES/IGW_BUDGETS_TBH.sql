--------------------------------------------------------
--  DDL for Package Body IGW_BUDGETS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_BUDGETS_TBH" AS
-- $Header: igwtbvsb.pls 115.7 2002/11/14 18:39:11 vmedikon ship $

procedure INSERT_ROW (
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
        ,p_enter_budget_at_period_level   VARCHAR2
        ,p_apply_inflation_setup_rates    VARCHAR2
        ,p_apply_eb_setup_rates VARCHAR2
        ,p_apply_oh_setup_rates VARCHAR2
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
	,p_attribute15  	VARCHAR2
	,x_rowid    	        OUT NOCOPY  VARCHAR2
        ,x_return_status        OUT NOCOPY  VARCHAR2) IS

    cursor c_budgets is
    select  rowid
    from    igw_budgets
    where   proposal_id = p_proposal_id
    and     version_id  = p_version_id;

    l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
    l_last_update_date  DATE   := SYSDATE;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

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
        ,enter_budget_at_period_level
        ,apply_inflation_setup_rates
        ,apply_eb_setup_rates
        ,apply_oh_setup_rates
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
	,attribute15
        ,record_version_number)
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
        ,nvl(p_enter_budget_at_period_level, 'N')
        ,nvl(p_apply_inflation_setup_rates, 'Y')
        ,nvl(p_apply_eb_setup_rates , 'Y')
        ,nvl(p_apply_oh_setup_rates, 'Y')
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
	,p_attribute15
        ,1);

    open c_budgets;
    fetch c_budgets into x_ROWID;
    if (c_budgets%notfound) then
      close c_budgets;
      raise no_data_found;
    end if;
    close c_budgets;

exception
  when others then
    FND_MSG_PUB.add_exc_msg( p_pkg_name    => G_package_name
                              ,p_procedure_name => 'INSERT_ROW' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;
end insert_row;


-----------------------------------------------------------------------------------
procedure update_row(
	p_rowid    	        VARCHAR2
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
        ,p_enter_budget_at_period_level   VARCHAR2
        ,p_apply_inflation_setup_rates    VARCHAR2
        ,p_apply_eb_setup_rates VARCHAR2
        ,p_apply_oh_setup_rates VARCHAR2
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
	,p_attribute15  	VARCHAR2
        ,p_record_version_number NUMBER
        ,x_return_status   OUT NOCOPY  VARCHAR2) IS

  l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
  l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
  l_last_update_date  DATE   := SYSDATE;

  l_row_id  ROWID := p_rowid;

  CURSOR get_row_id IS
  SELECT rowid
  FROM   IGW_BUDGETS
  WHERE  proposal_id = p_proposal_id
  AND    version_id = p_version_id;

begin
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_row_id IS NULL THEN
      OPEN get_row_id;
      FETCH get_row_id INTO l_row_id;
      CLOSE get_row_id;
    END IF;

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
/* no need to update the budget type code */
    --,	   budget_type_code	= p_budget_type_code
    ,      enter_budget_at_period_level   = p_enter_budget_at_period_level
    ,      apply_inflation_setup_rates  = p_apply_inflation_setup_rates
    ,      apply_eb_setup_rates = p_apply_eb_setup_rates
    ,      apply_oh_setup_rates = p_apply_oh_setup_rates
    ,      record_version_number = record_version_number + 1
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
    where rowid = l_row_id
    and   record_version_number = p_record_version_number;

  if (sql%notfound) then
    FND_MESSAGE.SET_NAME('IGW','IGW_SS_RECORD_CHANGED');
    FND_MSG_PUB.Add;
    X_RETURN_STATUS := 'E';
  end if;

exception
  when others then
    FND_MSG_PUB.add_exc_msg( p_pkg_name    => G_package_name
                             ,p_procedure_name => 'UPDATE_ROW' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;
end update_row;
--------------------------------------------------------------------------------------------------

procedure DELETE_ROW (
   p_rowid                        IN ROWID
  ,p_proposal_id                  IN NUMBER
  ,p_version_id                   IN NUMBER
  ,p_record_version_number        IN NUMBER
  ,x_return_status                OUT NOCOPY VARCHAR2
) is

  l_row_id  ROWID := p_rowid;

  CURSOR get_row_id IS
  SELECT rowid
  FROM   IGW_BUDGETS
  WHERE  proposal_id = p_proposal_id
  AND    version_id = p_version_id;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_row_id IS NULL THEN
    OPEN get_row_id;
    FETCH get_row_id INTO l_row_id;
    CLOSE get_row_id;
  END IF;

  delete from igw_budgets
  where rowid = l_row_id
  and record_version_number = p_record_version_number;

  if (sql%notfound) then
    FND_MESSAGE.SET_NAME('IGW','IGW_SS_RECORD_CHANGED');
    FND_MSG_PUB.Add;
    X_RETURN_STATUS := 'E';
  end if;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name    => G_package_name
                              ,p_procedure_name => 'DELETE_ROW' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;
end DELETE_ROW;


END IGW_BUDGETS_TBH;

/
