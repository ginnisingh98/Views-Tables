--------------------------------------------------------
--  DDL for Package Body IGW_BUDGET_DETAILS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_BUDGET_DETAILS_TBH" AS
--$Header: igwtbdtb.pls 115.4 2002/11/14 18:40:00 vmedikon ship $

  procedure INSERT_ROW (
        p_proposal_id		       NUMBER
	,p_version_id		       NUMBER
        ,p_budget_period_id            NUMBER
        ,p_line_item_id                NUMBER
        ,p_expenditure_type            VARCHAR2
        ,p_expenditure_category_flag   VARCHAR2
        ,p_budget_category_code        VARCHAR2
        ,p_line_item_description       VARCHAR2
        ,p_based_on_line_item          NUMBER
        ,p_line_item_cost              NUMBER
	,p_cost_sharing_amount	       NUMBER
	,p_underrecovery_amount	       NUMBER
        ,p_apply_inflation_flag        VARCHAR2
        ,p_budget_justification        LONG
        ,p_location_code               VARCHAR2
        ,p_project_id                  NUMBER
        ,p_task_id                     NUMBER
        ,p_award_id                    NUMBER
        ,x_rowid    	          OUT NOCOPY  VARCHAR2
        ,x_return_status          OUT NOCOPY  VARCHAR2) IS

    cursor c_budget_line is
    select  rowid
    from    igw_budget_details
    where   proposal_id      = p_proposal_id
    and     version_id       = p_version_id
    and     budget_period_id = p_budget_period_id
    and     line_item_id  =    p_line_item_id;

    l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
    l_last_update_date  DATE   := SYSDATE;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    insert into igw_budget_details(
	proposal_id
	,version_id
        ,budget_period_id
        ,line_item_id
        ,expenditure_type
        ,expenditure_category_flag
        ,budget_category_code
        ,line_item_description
        ,based_on_line_item
        ,line_item_cost
	,cost_sharing_amount
	,underrecovery_amount
        ,apply_inflation_flag
        ,budget_justification
        ,location_code
        ,project_id
        ,task_id
        ,award_id
	,last_update_date
	,last_updated_by
	,creation_date
	,created_by
	,last_update_login
        ,record_version_number)
    values
      ( p_proposal_id
	,p_version_id
        ,p_budget_period_id
        ,p_line_item_id
        ,p_expenditure_type
        ,p_expenditure_category_flag
        ,p_budget_category_code
        ,p_line_item_description
        ,p_based_on_line_item
        ,p_line_item_cost
	,p_cost_sharing_amount
	,p_underrecovery_amount
        ,p_apply_inflation_flag
        ,p_budget_justification
        ,p_location_code
        ,p_project_id
        ,p_task_id
        ,p_award_id
	,l_last_update_date
	,l_last_updated_by
	,l_last_update_date
	,l_last_updated_by
	,l_last_update_login
        ,1);

    open c_budget_line;
    fetch c_budget_line into x_ROWID;
    if (c_budget_line%notfound) then
      close c_budget_line;
      raise no_data_found;
    end if;
    close c_budget_line;

exception
  when others then
    FND_MSG_PUB.add_exc_msg( p_pkg_name    => G_package_name
                              ,p_procedure_name => 'INSERT_ROW' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;
end insert_row;


-----------------------------------------------------------------------------------
  procedure UPDATE_ROW (
  	p_rowid    	               ROWID
        ,p_proposal_id		       NUMBER
	,p_version_id		       NUMBER
        ,p_budget_period_id            NUMBER
        ,p_line_item_id                NUMBER
        ,p_expenditure_type            VARCHAR2
        ,p_expenditure_category_flag   VARCHAR2
        ,p_budget_category_code        VARCHAR2
        ,p_line_item_description       VARCHAR2
        ,p_based_on_line_item          NUMBER
        ,p_line_item_cost              NUMBER
	,p_cost_sharing_amount	       NUMBER
	,p_underrecovery_amount	       NUMBER
        ,p_apply_inflation_flag        VARCHAR2
        ,p_budget_justification        LONG
        ,p_location_code               VARCHAR2
        ,p_project_id                  NUMBER
        ,p_task_id                     NUMBER
        ,p_award_id                    NUMBER
        ,p_record_version_number       NUMBER
        ,x_return_status          OUT NOCOPY  VARCHAR2) IS

  l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
  l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
  l_last_update_date  DATE   := SYSDATE;

  l_row_id  ROWID := p_rowid;

  CURSOR get_row_id IS
  SELECT rowid
    from    igw_budget_details
    where   proposal_id      = p_proposal_id
    and     version_id       = p_version_id
    and     budget_period_id = p_budget_period_id
    and     line_item_id  =    p_line_item_id;

begin
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_row_id IS NULL THEN
      OPEN get_row_id;
      FETCH get_row_id INTO l_row_id;
      CLOSE get_row_id;
    END IF;

    update igw_budget_details
    set	   expenditure_type = p_expenditure_type
    ,	   expenditure_category_flag = p_expenditure_category_flag
    ,	   budget_category_code = p_budget_category_code
    ,	   line_item_description = p_line_item_description
    ,	   based_on_line_item = p_based_on_line_item
    ,	   line_item_cost = p_line_item_cost
    ,      cost_sharing_amount = p_cost_sharing_amount
    ,	   underrecovery_amount = p_underrecovery_amount
    ,	   apply_inflation_flag = p_apply_inflation_flag
    ,	   budget_justification = p_budget_justification
    ,	   location_code    = p_location_code
    ,	   project_id       = decode(p_project_id, FND_API.G_MISS_NUM, NULL, p_project_id)
    ,	   task_id          = decode(p_task_id, FND_API.G_MISS_NUM, NULL, p_task_id)
    ,	   award_id         = decode(p_award_id  , FND_API.G_MISS_NUM, NULL, p_award_id)
    ,      record_version_number = record_version_number + 1
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
   p_rowid                        IN  ROWID
  ,p_proposal_id                  IN  NUMBER
  ,p_version_id                   IN  NUMBER
  ,p_budget_period_id             IN  NUMBER
  ,p_line_item_id                     NUMBER
  ,p_record_version_number        IN  NUMBER
  ,x_return_status                OUT NOCOPY VARCHAR2) is

  l_row_id  ROWID := p_rowid;

  CURSOR get_row_id IS
  SELECT rowid
    from    igw_budget_details
    where   proposal_id      = p_proposal_id
    and     version_id       = p_version_id
    and     budget_period_id = p_budget_period_id
    and     line_item_id  =    p_line_item_id;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_row_id IS NULL THEN
    OPEN get_row_id;
    FETCH get_row_id INTO l_row_id;
    CLOSE get_row_id;
  END IF;

  delete from igw_budget_details
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


END IGW_BUDGET_DETAILS_TBH;

/
