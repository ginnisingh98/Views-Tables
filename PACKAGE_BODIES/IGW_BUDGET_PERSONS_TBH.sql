--------------------------------------------------------
--  DDL for Package Body IGW_BUDGET_PERSONS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_BUDGET_PERSONS_TBH" AS
-- $Header: igwtbpsb.pls 115.6 2002/11/14 18:43:21 vmedikon ship $

procedure INSERT_ROW (
	p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_person_id		            NUMBER
	,p_party_id			    NUMBER
  	,p_appointment_type_code	    VARCHAR2
  	,p_effective_date		    DATE
  	,p_calculation_base  	            NUMBER
        ,x_rowid    	               OUT NOCOPY  VARCHAR2
        ,x_return_status               OUT NOCOPY  VARCHAR2) IS

    cursor c_budgets is
    select  rowid
    from    igw_budget_persons
    where   proposal_id = p_proposal_id
    and     version_id = p_version_id
    and     party_id = p_party_id;

    l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
    l_last_update_date  DATE   := SYSDATE;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    insert into igw_budget_persons(
	proposal_id
	,version_id
	,person_id
        ,party_id
	,appointment_type_code
	,effective_date
	,calculation_base
	,last_update_date
	,last_updated_by
	,creation_date
	,created_by
	,last_update_login
        ,record_version_number)
    values
      ( p_proposal_id
	,p_version_id
	,p_person_id
        ,p_party_id
	,p_appointment_type_code
	,p_effective_date
	,p_calculation_base
	,l_last_update_date
	,l_last_updated_by
	,l_last_update_date
	,l_last_updated_by
	,l_last_update_login
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
procedure UPDATE_ROW (
	p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_person_id		            NUMBER
	,p_party_id			    NUMBER
  	,p_appointment_type_code	    VARCHAR2
  	,p_effective_date		    DATE
  	,p_calculation_base  	            NUMBER
        ,p_rowid    	                    VARCHAR2
        ,p_record_version_number            NUMBER
        ,x_return_status               OUT NOCOPY  VARCHAR2) IS

  l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
  l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
  l_last_update_date  DATE   := SYSDATE;

  l_row_id  ROWID := p_rowid;

  CURSOR get_row_id IS
  select  rowid
  from    igw_budget_persons
  where   proposal_id = p_proposal_id
  and     version_id = p_version_id
  and     party_id = p_party_id;

begin
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_row_id IS NULL THEN
      OPEN get_row_id;
      FETCH get_row_id INTO l_row_id;
      CLOSE get_row_id;
    END IF;

    update igw_budget_persons
    set	   person_id  = p_person_id
    ,      party_id = p_party_id
    ,	   appointment_type_code = p_appointment_type_code
    ,	   effective_date = p_effective_date
    ,	   calculation_base = p_calculation_base
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
-------------------------------------------------------------------------------------------

procedure DELETE_ROW (
   p_rowid                        IN ROWID
  ,p_proposal_id                  IN NUMBER
  ,p_version_id                   IN NUMBER
  ,p_person_id                    IN NUMBER
  ,p_party_id		  	     NUMBER
  ,p_record_version_number        IN NUMBER
  ,x_return_status                OUT NOCOPY VARCHAR2)  is

  l_row_id  ROWID := p_rowid;

  CURSOR  get_row_id IS
  select  rowid
  from    igw_budget_persons
  where   proposal_id = p_proposal_id
  and     version_id = p_version_id
  and     party_id = p_party_id;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_row_id IS NULL THEN
    OPEN get_row_id;
    FETCH get_row_id INTO l_row_id;
    CLOSE get_row_id;
  END IF;

  delete from igw_budget_persons
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


END IGW_BUDGET_PERSONS_TBH;

/
