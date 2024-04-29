--------------------------------------------------------
--  DDL for Package Body IGW_PROP_RATES_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_RATES_TBH" AS
-- $Header: igwtprtb.pls 115.5 2002/11/15 00:44:47 ashkumar ship $

procedure INSERT_ROW (
	p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_rate_class_id	            NUMBER
        ,p_rate_type_id                     NUMBER
        ,p_fiscal_year                      VARCHAR2
        ,p_location_code                    VARCHAR2
        ,p_activity_type_code              VARCHAR2
        ,p_start_date                       DATE
        ,p_applicable_rate                  NUMBER
        ,p_institute_rate                   NUMBER
        ,x_rowid    	               OUT NOCOPY  VARCHAR2
        ,x_return_status               OUT NOCOPY  VARCHAR2) IS

  cursor c_rates is
  select rowid
  from   igw_prop_rates
  where  proposal_id = p_proposal_id
  and    version_id = p_version_id
  and    rate_class_id = p_rate_class_id
  and    rate_type_id = p_rate_type_id
  and    location_code = p_location_code
  and    activity_type_code = p_activity_type_code
  and    fiscal_year = p_fiscal_year;

  l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
  l_last_update_login   NUMBER := FND_GLOBAL.LOGIN_ID;
  l_last_update_date    DATE   := SYSDATE;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    insert into igw_prop_rates(
	proposal_id
	,version_id
	,rate_class_id
	,rate_type_id
	,fiscal_year
	,location_code
        ,activity_type_code
        ,start_date
        ,applicable_rate
        ,institute_rate
	,last_update_date
	,last_updated_by
	,creation_date
	,created_by
	,last_update_login
        ,record_version_number)
    values
      ( p_proposal_id
	,p_version_id
	,p_rate_class_id
	,p_rate_type_id
	,p_fiscal_year
	,p_location_code
        ,p_activity_type_code
        ,p_start_date
        ,p_applicable_rate
        ,p_institute_rate
	,l_last_update_date
	,l_last_updated_by
	,l_last_update_date
	,l_last_updated_by
	,l_last_update_login
        ,1);

    open c_rates;
    fetch c_rates into x_ROWID;
    if (c_rates%notfound) then
      close c_rates;
      raise no_data_found;
    end if;
    close c_rates;

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
  	,p_rate_class_id	            NUMBER
        ,p_rate_type_id                     NUMBER
        ,p_fiscal_year                      VARCHAR2
        ,p_location_code                    VARCHAR2
        ,p_activity_type_code              VARCHAR2
        ,p_start_date                       DATE
        ,p_applicable_rate                  NUMBER
        ,p_institute_rate                   NUMBER
        ,p_rowid    	                    VARCHAR2
        ,p_record_version_number            NUMBER
        ,x_return_status               OUT NOCOPY  VARCHAR2) IS

  l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
  l_last_update_login   NUMBER := FND_GLOBAL.LOGIN_ID;
  l_last_update_date    DATE   := SYSDATE;

  l_row_id  ROWID := p_rowid;

  CURSOR get_row_id IS
  select  rowid
  from   igw_prop_rates
  where  proposal_id = p_proposal_id
  and    version_id = p_version_id
  and    rate_class_id = p_rate_class_id
  and    rate_type_id = p_rate_type_id
  and    location_code = p_location_code
  and    activity_type_code = p_activity_type_code
  and    fiscal_year = p_fiscal_year;

begin
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_row_id IS NULL THEN
      OPEN get_row_id;
      FETCH get_row_id INTO l_row_id;
      CLOSE get_row_id;
    END IF;

    update igw_prop_rates
    set	   applicable_rate  = p_applicable_rate
    where rowid = l_row_id;
    --and   record_version_number = p_record_version_number;

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
        p_rowid                          IN ROWID
	,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_rate_class_id	            NUMBER
        ,p_rate_type_id                     NUMBER
        ,p_fiscal_year                      VARCHAR2
        ,p_location_code                    VARCHAR2
        ,p_activity_type_code              VARCHAR2
        ,p_start_date                       DATE
        ,p_applicable_rate                  NUMBER
        ,p_institute_rate                   NUMBER
        ,p_record_version_number        IN  NUMBER
        ,x_return_status                OUT NOCOPY VARCHAR2) is

  l_row_id  ROWID := p_rowid;


  CURSOR get_row_id IS
  select  rowid
  from   igw_prop_rates
  where  proposal_id = p_proposal_id
  and    version_id = p_version_id
  and    rate_class_id = p_rate_class_id
  and    rate_type_id = p_rate_type_id
  and    location_code = p_location_code
  and    activity_type_code = p_activity_type_code
  and    fiscal_year = p_fiscal_year;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_row_id IS NULL THEN
    OPEN get_row_id;
    FETCH get_row_id INTO l_row_id;
    CLOSE get_row_id;
  END IF;

  delete from igw_prop_rates
  where rowid = l_row_id;
  --and record_version_number = p_record_version_number;

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


END IGW_PROP_RATES_TBH;

/
