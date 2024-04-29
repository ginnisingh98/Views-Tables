--------------------------------------------------------
--  DDL for Package Body IGW_BUDGET_PERSONNEL_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_BUDGET_PERSONNEL_TBH" AS
--$Header: igwtbpdb.pls 115.5 2002/11/14 18:42:41 vmedikon ship $

  procedure INSERT_ROW (
        p_proposal_id		       NUMBER
	,p_version_id		       NUMBER
        ,p_budget_period_id            NUMBER
        ,p_line_item_id                NUMBER
        ,p_budget_personnel_detail_id  NUMBER
        ,p_person_id                   NUMBER
	,p_party_id		       NUMBER
  	,p_start_date		       DATE
  	,p_end_date		       DATE
        ,p_period_type_code            VARCHAR2
        ,p_appointment_type_code       VARCHAR2
        ,p_salary_requested            NUMBER
        ,p_percent_charged             NUMBER
        ,p_percent_effort              NUMBER
        ,p_cost_sharing_percent        NUMBER
	,p_cost_sharing_amount	       NUMBER
	,p_underrecovery_amount	       NUMBER
        ,x_rowid    	          OUT NOCOPY  VARCHAR2
        ,x_return_status          OUT NOCOPY  VARCHAR2) IS

    cursor c_budget_personnel is
    select  rowid
    from    igw_budget_personnel_details
    where   budget_personnel_detail_id  = p_budget_personnel_detail_id;

    l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
    l_last_update_date  DATE   := SYSDATE;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    insert into igw_budget_personnel_details(
	proposal_id
	,version_id
        ,budget_period_id
        ,line_item_id
        ,budget_personnel_detail_id
        ,person_id
        ,party_id
  	,start_date
  	,end_date
        ,period_type_code
        ,appointment_type_code
        ,salary_requested
        ,percent_charged
        ,percent_effort
        ,cost_sharing_percent
	,cost_sharing_amount
	,underrecovery_amount
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
        ,p_budget_personnel_detail_id
        ,p_person_id
        ,p_party_id
  	,p_start_date
  	,p_end_date
        ,p_period_type_code
        ,p_appointment_type_code
        ,p_salary_requested
        ,p_percent_charged
        ,p_percent_effort
        ,p_cost_sharing_percent
	,p_cost_sharing_amount
	,p_underrecovery_amount
	,l_last_update_date
	,l_last_updated_by
	,l_last_update_date
	,l_last_updated_by
	,l_last_update_login
        ,1);

    open c_budget_personnel;
    fetch c_budget_personnel into x_ROWID;
    if (c_budget_personnel%notfound) then
      close c_budget_personnel;
      raise no_data_found;
    end if;
    close c_budget_personnel;

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
        ,p_budget_personnel_detail_id  NUMBER
        ,p_person_id                   NUMBER
	,p_party_id		       NUMBER
  	,p_start_date		       DATE
  	,p_end_date		       DATE
        ,p_period_type_code            VARCHAR2
        ,p_appointment_type_code       VARCHAR2
        ,p_salary_requested            NUMBER
        ,p_percent_charged             NUMBER
        ,p_percent_effort              NUMBER
        ,p_cost_sharing_percent        NUMBER
	,p_cost_sharing_amount	       NUMBER
	,p_underrecovery_amount	       NUMBER
        ,p_record_version_number       NUMBER
        ,x_return_status          OUT NOCOPY  VARCHAR2)IS

  l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
  l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
  l_last_update_date  DATE   := SYSDATE;

  l_row_id  ROWID := p_rowid;

  CURSOR get_row_id IS
    select  rowid
    from    igw_budget_personnel_details
    where   budget_personnel_detail_id  = p_budget_personnel_detail_id;

begin
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_row_id IS NULL THEN
      OPEN get_row_id;
      FETCH get_row_id INTO l_row_id;
      CLOSE get_row_id;
    END IF;

    update igw_budget_personnel_details
    set	   person_id                = p_person_id
    ,      party_id	            = p_party_id
    ,	   start_date               = p_start_date
    ,	   end_date	            = p_end_date
    ,	   period_type_code         = p_period_type_code
    ,	   appointment_type_code    = p_appointment_type_code
    ,      salary_requested         = p_salary_requested
    ,	   percent_charged          = p_percent_charged
    ,      percent_effort           = p_percent_effort
    ,	   cost_sharing_percent     = p_cost_sharing_percent
    ,	   cost_sharing_amount      = p_cost_sharing_amount
    ,	   underrecovery_amount     = p_underrecovery_amount
    ,      record_version_number    = record_version_number + 1
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
  ,p_budget_personnel_detail_id       NUMBER
  ,p_proposal_id                  IN  NUMBER
  ,p_version_id                   IN  NUMBER
  ,p_budget_period_id             IN  NUMBER
  ,p_line_item_id                     NUMBER
  ,p_person_id                        NUMBER
  ,p_party_id		              NUMBER
  ,p_record_version_number        IN  NUMBER
  ,x_return_status                OUT NOCOPY VARCHAR2) is

  l_row_id  ROWID := p_rowid;

  CURSOR get_row_id IS
    select  rowid
    from    igw_budget_personnel_details
    where   budget_personnel_detail_id  = p_budget_personnel_detail_id;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_row_id IS NULL THEN
    OPEN get_row_id;
    FETCH get_row_id INTO l_row_id;
    CLOSE get_row_id;
  END IF;

  delete from igw_budget_personnel_details
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


END;

/
