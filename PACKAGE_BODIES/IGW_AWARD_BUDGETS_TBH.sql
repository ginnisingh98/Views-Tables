--------------------------------------------------------
--  DDL for Package Body IGW_AWARD_BUDGETS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_AWARD_BUDGETS_TBH" AS
--$Header: igwtabtb.pls 115.4 2002/11/18 19:19:44 ashkumar noship $

  procedure INSERT_ROW (
         p_award_budget_id             NUMBER
        ,p_proposal_installment_id     NUMBER
        ,p_budget_period_id            NUMBER
        ,p_expenditure_type_cat        VARCHAR2
        ,p_expenditure_category_flag   VARCHAR2
        ,p_budget_amount               NUMBER
        ,p_indirect_flag               VARCHAR2
        ,p_project_id                  NUMBER
        ,p_task_id                     NUMBER
        ,p_period_name                 VARCHAR2
	,p_start_date                  DATE
	,p_end_date                    DATE
	,p_transferred_flag            VARCHAR2
        ,x_rowid    	          OUT NOCOPY  VARCHAR2
        ,x_return_status          OUT NOCOPY  VARCHAR2) IS

    cursor c_budget_line is
    select  rowid
    from    igw_award_budgets
    where   award_budget_id  = p_award_budget_id;

    l_last_updated_by  		NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login         NUMBER := FND_GLOBAL.LOGIN_ID;
    l_last_update_date          DATE   := SYSDATE;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    insert into igw_award_budgets(
         award_budget_id
        ,proposal_installment_id
        ,budget_period_id
        ,expenditure_type_cat
        ,expenditure_category_flag
        ,budget_amount
        ,indirect_flag
        ,project_id
        ,task_id
        ,period_name
	,start_date
	,end_date
	,transferred_flag
	,last_update_date
	,last_updated_by
	,creation_date
	,created_by
	,last_update_login
        ,record_version_number)
    values
      (  p_award_budget_id
        ,p_proposal_installment_id
        ,p_budget_period_id
        ,p_expenditure_type_cat
        ,p_expenditure_category_flag
        ,p_budget_amount
        ,p_indirect_flag
        ,p_project_id
        ,p_task_id
        ,p_period_name
	,p_start_date
	,p_end_date
	,p_transferred_flag
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
        ,p_award_budget_id             NUMBER
        ,p_proposal_installment_id     NUMBER
        ,p_budget_period_id            NUMBER
        ,p_expenditure_type_cat        VARCHAR2
        ,p_expenditure_category_flag   VARCHAR2
        ,p_budget_amount               NUMBER
        ,p_indirect_flag               VARCHAR2
        ,p_project_id                  NUMBER
        ,p_task_id                     NUMBER
        ,p_period_name                 VARCHAR2
	,p_start_date                  DATE
	,p_end_date                    DATE
	,p_transferred_flag            VARCHAR2
        ,p_record_version_number       NUMBER
        ,x_return_status          OUT NOCOPY  VARCHAR2) IS

  l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
  l_last_update_login   NUMBER := FND_GLOBAL.LOGIN_ID;
  l_last_update_date    DATE   := SYSDATE;

  l_row_id  ROWID := p_rowid;

  CURSOR get_row_id IS
  SELECT rowid
    from    igw_award_budgets
    where   award_budget_id  =    p_award_budget_id;

begin
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_row_id IS NULL THEN
      OPEN get_row_id;
      FETCH get_row_id INTO l_row_id;
      CLOSE get_row_id;
    END IF;

    update igw_award_budgets
    set	   budget_period_id = p_budget_period_id
    ,      expenditure_type_cat = p_expenditure_type_cat
    ,	   expenditure_category_flag = p_expenditure_category_flag
    ,	   budget_amount = p_budget_amount
    ,	   indirect_flag = p_indirect_flag
    ,	   project_id = p_project_id
    ,	   task_id   = p_task_id
    ,	   period_name = p_period_name
    ,      start_date = p_start_date
    ,      end_date = p_end_date
    ,      transferred_flag = p_transferred_flag
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
   p_rowid                       IN  ROWID
  ,p_award_budget_id             IN  NUMBER
  ,p_record_version_number       IN  NUMBER
  ,x_return_status               OUT NOCOPY VARCHAR2) is

  l_row_id  ROWID := p_rowid;

  CURSOR get_row_id IS
  SELECT rowid
  from    igw_award_budgets
  where   award_budget_id  =  p_award_budget_id;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_row_id IS NULL THEN
    OPEN get_row_id;
    FETCH get_row_id INTO l_row_id;
    CLOSE get_row_id;
  END IF;

  delete from igw_award_budgets
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


END IGW_AWARD_BUDGETS_TBH;

/
