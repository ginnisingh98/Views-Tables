--------------------------------------------------------
--  DDL for Package Body PA_RESOURCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RESOURCE_PKG" 
-- $Header: PARCTBHB.pls 120.1 2005/08/19 16:49:47 mwasowic noship $
AS

/* THE INSERT_ROW1 PROCEDURE INSERTS INTO PA_RESOURCES TABLE.
THE INSERT_ROW2 PROCEDURE INSERTS INTO PA_RESOURCE_TXN_ATTRIBUTES TABLE.
THE INSERT_ROW3 PROCEDURE INSERTS INTO PA_RESOURCE_OU TABLE.*/

 PROCEDURE INSERT_ROW1(
	X_ROWID			IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_RESOURCE_ID		IN	PA_RESOURCES.RESOURCE_ID%TYPE,
	X_NAME			IN	PA_RESOURCES.NAME%TYPE,
	X_RESOURCE_TYPE_ID	IN	PA_RESOURCES.RESOURCE_TYPE_ID%TYPE,
	X_JTF_RESOURCE_ID	IN	PA_RESOURCES.JTF_RESOURCE_ID%TYPE,
	X_START_DATE_ACTIVE	IN	PA_RESOURCES.START_DATE_ACTIVE%TYPE,
	X_END_DATE_ACTIVE	IN	PA_RESOURCES.END_DATE_ACTIVE%TYPE,
	X_REQUEST_ID		IN	NUMBER,
	X_PROGRAM_ID		IN	NUMBER,
	X_PROGRAM_UPDATE_DATE	IN	DATE,
        X_PROGRAM_APPLICATION_ID	IN NUMBER,
	X_UNIT_OF_MEASURE       IN      PA_RESOURCES.UNIT_OF_MEASURE%TYPE, --added for bug 2599790
	X_ROLLUP_QUANTITY_FLAG  IN      PA_RESOURCES.ROLLUP_QUANTITY_FLAG%TYPE,  --added for bug 3921534
	X_TRACK_AS_LABOR_FLAG   IN      PA_RESOURCES.TRACK_AS_LABOR_FLAG%TYPE,   --added for bug 3921534
	X_LAST_UPDATE_BY	IN	NUMBER,
	X_LAST_UPDATE_DATE	IN	DATE,
	X_CREATION_DATE		IN	DATE,
	X_CREATED_BY		IN	NUMBER,
	X_LAST_UPDATE_LOGIN	IN	NUMBER ,
	X_RETURN_STATUS		OUT	NOCOPY VARCHAR2 )  --File.Sql.39 bug 4440895
 IS
  l_check_dup_id	VARCHAR2(1);
  --l_resource_id		NUMBER;
  --cursor to select rowid of current insert
  cursor C is
	select rowid from pa_resources
	where resource_id = x_resource_id;
 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --actual insert into pa_resources table
  insert into PA_RESOURCES (
		resource_id,
		name,
                description,      --  Added for bug 4318765
		resource_type_id,
		jtf_resource_id,
		start_date_active,
		end_date_active,
		request_id,
		program_id,
		program_update_date,
		program_application_id,
		unit_of_measure, --added for bug 2599790
		rollup_quantity_flag,  -- added for bug 3921534
		track_as_labor_flag,   -- added for bug 3921534
		last_updated_by,
		last_update_date,
		creation_date,
		created_by,
		last_update_login )
	values (
		X_RESOURCE_ID,
		X_NAME,
		X_NAME,     --  Added for bug 4318765
		X_RESOURCE_TYPE_ID,
		X_JTF_RESOURCE_ID,
		X_START_DATE_ACTIVE,
		X_END_DATE_ACTIVE,
		X_REQUEST_ID,
		X_PROGRAM_ID,
		X_PROGRAM_UPDATE_DATE,
		X_PROGRAM_APPLICATION_ID,
		X_UNIT_OF_MEASURE, --added for bug 2599790
		X_ROLLUP_QUANTITY_FLAG,         -- added for bug 3921534
		X_TRACK_AS_LABOR_FLAG,          -- added for bug 3921534
		X_LAST_UPDATE_BY,
		X_LAST_UPDATE_DATE,
		X_CREATION_DATE,
		X_CREATED_BY,
		X_LAST_UPDATE_LOGIN );

  --check if record was inserted
	open c;
	fetch c into X_ROWID;
	if (c%notfound) then
		close c;
		raise no_data_found;
	end if;
	close c;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN -- catch the exceptions here
        -- Set the current program unit name in the error stack
	-- PA_Error_Utils.Set_Error_Stack('PA_RESOURCE_PKG.Insert_Row1');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN -- catch the exceptions here
        -- Set the current program unit name in the error stack
	-- PA_Error_Utils.Set_Error_Stack('PA_RESOURCE_PKG.Insert_Row1');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
 END INSERT_ROW1;

--begin of Insert_row2 procedure
 PROCEDURE INSERT_ROW2 (
	X_ROWID				IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_RESOURCE_TXN_ATTRIBUTE_ID	IN	PA_RESOURCE_TXN_ATTRIBUTES.
						RESOURCE_TXN_ATTRIBUTE_ID%TYPE,
	X_RESOURCE_ID			IN	PA_RESOURCE_TXN_ATTRIBUTES.
						RESOURCE_ID%TYPE,
	X_PERSON_ID			IN	PA_RESOURCE_TXN_ATTRIBUTES.
						PERSON_ID%TYPE,
	X_RESOURCE_FORMAT_ID		IN	PA_RESOURCE_TXN_ATTRIBUTES.
						RESOURCE_FORMAT_ID%TYPE,
	X_REQUEST_ID			IN	NUMBER,
	X_PROGRAM_ID			IN	NUMBER,
        X_PARTY_ID                      IN      PA_RESOURCE_TXN_ATTRIBUTES.
						PARTY_ID%TYPE,
	X_PROGRAM_UPDATE_DATE		IN	DATE,
	X_PROGRAM_APPLICATION_ID	IN	NUMBER,
	X_LAST_UPDATE_BY		IN	NUMBER,
	X_LAST_UPDATE_DATE		IN	DATE,
	X_CREATION_DATE			IN	DATE,
	X_CREATED_BY			IN	NUMBER,
	X_LAST_UPDATE_LOGIN		IN	NUMBER ,
	X_RETURN_STATUS			OUT	NOCOPY VARCHAR2 )  --File.Sql.39 bug 4440895
 IS
	l_check_dup_id			VARCHAR2(1);
	--l_resource_txn_attribute_id     NUBMER;
	 --cursor to select rowid of current insert
	 cursor c is
		select rowid from pa_resource_txn_attributes
	        where resource_txn_attribute_id = resource_txn_attribute_id;

 BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--actual insert into pa_resource_txn_attribute
	 insert into PA_RESOURCE_TXN_ATTRIBUTES (
		resource_txn_attribute_id
		,resource_id
		,person_id
		,resource_format_id
		,request_id
                ,party_id
		,program_id
		,program_update_date
		,program_application_id
		,last_updated_by
		,last_update_date
		,creation_date
		,created_by
		,last_update_login)
	 values (
		X_RESOURCE_TXN_ATTRIBUTE_ID,
		X_RESOURCE_ID ,
		X_PERSON_ID ,
		X_RESOURCE_FORMAT_ID ,
		X_REQUEST_ID,
                X_PARTY_ID,
		X_PROGRAM_ID ,
		X_PROGRAM_UPDATE_DATE ,
		X_PROGRAM_APPLICATION_ID ,
		X_LAST_UPDATE_BY,
		X_LAST_UPDATE_DATE ,
		X_CREATION_DATE ,
		X_CREATED_BY ,
		X_LAST_UPDATE_LOGIN );

	 --check to see if record was inserted
	 open c;
	 fetch c into X_ROWID;
	 if (c%notfound) then
		 close c;
		 raise no_data_found;
	 end if;
	 close c;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN -- catch the exceptions here
        -- Set the current program unit name in the error stack
	-- PA_Error_Utils.Set_Error_Stack('PA_RESOURCE_PKG.Insert_Row2');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN -- catch the exceptions here
        -- Set the current program unit name in the error stack
	-- PA_Error_Utils.Set_Error_Stack('PA_RESOURCE_PKG.Insert_Row2');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
 END INSERT_ROW2;

END PA_RESOURCE_PKG;

/
