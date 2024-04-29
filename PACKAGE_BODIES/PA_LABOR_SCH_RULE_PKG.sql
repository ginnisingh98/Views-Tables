--------------------------------------------------------
--  DDL for Package Body PA_LABOR_SCH_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_LABOR_SCH_RULE_PKG" as
-- $Header: PALABSRB.pls 115.2 2002/12/02 23:36:36 riyengar noship $
PROCEDURE print_msg(p_msg  varchar2) IS
BEGIN
      --dbms_output.put_line('Log:'||p_msg);
      --r_debug.r_msg('Log:'||p_msg);
        PA_DEBUG.g_err_stage := p_msg;
        PA_DEBUG.write_file('LOG',pa_debug.g_err_stage);
	null;
END print_msg;

PROCEDURE insert_row (
	x_rowid                   IN OUT NOCOPY varchar2
 	,x_ORG_LABOR_SCH_RULE_ID    IN OUT NOCOPY number
 	,p_ORGANIZATION_ID          IN  number
 	,p_ORG_ID                   IN  number
 	,p_LABOR_COSTING_RULE       IN  varchar2
 	,p_COST_RATE_SCH_ID         IN  number
 	,p_OVERTIME_PROJECT_ID      IN  number
 	,p_OVERTIME_TASK_ID         IN  number
 	,p_ACCT_RATE_DATE_CODE      IN  varchar2
 	,p_ACCT_RATE_TYPE           IN  varchar2
 	,p_ACCT_EXCHANGE_RATE       IN  number
 	,p_START_DATE_ACTIVE        IN  DATE
 	,p_END_DATE_ACTIVE          IN  DATE
	,p_FORECAST_COST_RATE_SCH_ID IN  number
 	,p_CREATION_DATE            IN  DATE
 	,p_CREATED_BY               IN  number
 	,p_LAST_UPDATE_DATE         IN  DATE
 	,p_LAST_UPDATED_BY          IN  number
 	,p_LAST_UPDATE_LOGIN        IN  number
	,x_return_status            IN OUT NOCOPY varchar2
        ,x_error_msg_code           IN OUT NOCOPY varchar2
                      )IS
  cursor return_rowid is
   select rowid
   from pa_org_labor_sch_rule
   where ORG_LABOR_SCH_RULE_ID = x_ORG_LABOR_SCH_RULE_ID;

  cursor get_itemid is
   select pa_org_labor_sch_rule_s.nextval
   from sys.dual;

   l_return_status        varchar2(100) := 'S';
   l_error_msg_code       varchar2(100) := NULL;

   l_debug_mode           varchar2(1) := 'N';
 BEGIN
   fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   l_debug_mode := NVL(l_debug_mode, 'N');

   pa_debug.set_process('PLSQL','LOG',l_debug_mode);

  IF l_debug_mode = 'Y' THEN
	print_msg('Inside pa_labor_sch_rule_pkg table handler..');
  End If;

  if (x_ORG_LABOR_SCH_RULE_ID is null) then
    open get_itemid;
    fetch get_itemid into x_ORG_LABOR_SCH_RULE_ID;
    close get_itemid;
  end if;
  IF l_debug_mode = 'Y' THEN
	print_msg('Info transacton id ..'||x_ORG_LABOR_SCH_RULE_ID);
  End If;

  INSERT into pa_org_labor_sch_rule
	(
        ORG_LABOR_SCH_RULE_ID
        ,ORGANIZATION_ID
        ,ORG_ID
        ,LABOR_COSTING_RULE
        ,COST_RATE_SCH_ID
        ,OVERTIME_PROJECT_ID
        ,OVERTIME_TASK_ID
        ,ACCT_RATE_DATE_CODE
        ,ACCT_RATE_TYPE
        ,ACCT_EXCHANGE_RATE
        ,START_DATE_ACTIVE
        ,END_DATE_ACTIVE
	,FORECAST_COST_RATE_SCH_ID
        ,CREATION_DATE
        ,CREATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_LOGIN
	) VALUES
        (
        x_ORG_LABOR_SCH_RULE_ID
        ,p_ORGANIZATION_ID
        ,p_ORG_ID
        ,p_LABOR_COSTING_RULE
        ,p_COST_RATE_SCH_ID
        ,p_OVERTIME_PROJECT_ID
        ,p_OVERTIME_TASK_ID
        ,p_ACCT_RATE_DATE_CODE
        ,p_ACCT_RATE_TYPE
        ,p_ACCT_EXCHANGE_RATE
        ,p_START_DATE_ACTIVE
        ,p_END_DATE_ACTIVE
	,p_FORECAST_COST_RATE_SCH_ID
        ,p_CREATION_DATE
        ,p_CREATED_BY
        ,p_LAST_UPDATE_DATE
        ,p_LAST_UPDATED_BY
        ,p_LAST_UPDATE_LOGIN
        );
     OPEN return_rowid;
     FETCH return_rowid into x_rowid;
     IF  (return_rowid%notfound) then
	l_return_status := 'E';
	l_error_msg_code := 'NO_DATA_FOUND';
	IF l_debug_mode = 'Y' THEN
		print_msg('rowid not found raise insert failed');
	End If;
        raise NO_DATA_FOUND;  -- should we return something else?
     Else
	l_return_status := 'S';
	l_error_msg_code := NULL;
     End if;
     CLOSE return_rowid;

	x_return_status := l_return_status;
	x_error_msg_code := l_error_msg_code;
 EXCEPTION
	when others then
	    x_error_msg_code := sqlcode||sqlerrm;
	    IF l_debug_mode = 'Y' THEN
	    	print_msg('x_err_msg_code exception:'||x_error_msg_code);
	    End If;
	    Raise;

 END insert_row;

 PROCEDURE update_row
        (
         p_rowid                   IN  varchar2
        ,p_ORG_LABOR_SCH_RULE_ID    IN  number
        ,p_ORGANIZATION_ID          IN  number
        ,p_ORG_ID                   IN  number
        ,p_LABOR_COSTING_RULE       IN  varchar2
        ,p_COST_RATE_SCH_ID         IN  number
        ,p_OVERTIME_PROJECT_ID      IN  number
        ,p_OVERTIME_TASK_ID         IN  number
        ,p_ACCT_RATE_DATE_CODE      IN  varchar2
        ,p_ACCT_RATE_TYPE           IN  varchar2
        ,p_ACCT_EXCHANGE_RATE       IN  number
        ,p_START_DATE_ACTIVE        IN  DATE
        ,p_END_DATE_ACTIVE          IN  DATE
	,p_FORECAST_COST_RATE_SCH_ID IN  number
        ,p_CREATION_DATE            IN  DATE
        ,p_CREATED_BY               IN  number
        ,p_LAST_UPDATE_DATE         IN  DATE
        ,p_LAST_UPDATED_BY          IN  number
        ,p_LAST_UPDATE_LOGIN        IN  number
        ,x_return_status            IN OUT NOCOPY varchar2
        ,x_error_msg_code           IN OUT NOCOPY varchar2
                      )IS
	CURSOR cur_row is
	SELECT
        ORGANIZATION_ID
        ,ORG_ID
        ,LABOR_COSTING_RULE
        ,COST_RATE_SCH_ID
        ,OVERTIME_PROJECT_ID
        ,OVERTIME_TASK_ID
        ,ACCT_RATE_DATE_CODE
        ,ACCT_RATE_TYPE
        ,ACCT_EXCHANGE_RATE
        ,START_DATE_ACTIVE
        ,END_DATE_ACTIVE
	,FORECAST_COST_RATE_SCH_ID
	FROM pa_org_labor_sch_rule
	WHERE ORG_LABOR_SCH_RULE_ID = p_ORG_LABOR_SCH_RULE_ID
	FOR UPDATE OF ORG_LABOR_SCH_RULE_ID NOWAIT;

	recinfo cur_row%rowtype;
   	l_debug_mode           varchar2(1) := 'N';
 BEGIN
   	fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   	l_debug_mode := NVL(l_debug_mode, 'N');

   	pa_debug.set_process('PLSQL','LOG',l_debug_mode);

	/** set the return status to success **/
	x_return_status := 'S';
	x_error_msg_code := NULL;

	IF l_debug_mode = 'Y' THEN
		print_msg('Inside update row.');
	End If;

	OPEN cur_row;
	FETCH cur_row INTO recinfo;
	If cur_row%NOTFOUND then
		IF l_debug_mode = 'Y' THEN
			print_msg('row not found return');
		End If;
		return;
	End If;
	CLOSE cur_row;

	/** check if any of the attributes changed then update else donot **/
	IF (Nvl(recinfo.org_id,0) <> nvl(p_org_id,0) OR
           Nvl(recinfo.organization_id,0) <> nvl(p_organization_id,0) OR
	   Nvl(recinfo.labor_costing_rule,'X') <> nvl(p_labor_costing_rule,'X') OR
	   Nvl(recinfo.cost_rate_sch_id,0) <> nvl(p_cost_rate_sch_id,0) OR
	   Nvl(recinfo.overtime_project_id,0) <> nvl(p_overtime_project_id,0) OR
	   nvl(recinfo.overtime_task_id,0) <> nvl(p_overtime_task_id,0) OR
	   Nvl(recinfo.acct_rate_date_code,'X') <> nvl(p_acct_rate_date_code,'X') OR
	   Nvl(recinfo.acct_rate_type,'X') <> nvl(p_acct_rate_type,'X') OR
	   Nvl(recinfo.acct_exchange_rate,0) <> nvl(p_acct_exchange_rate,0) OR
	   Nvl(recinfo.start_date_active,trunc(sysdate)) <> nvl(p_start_date_active,trunc(sysdate)) OR
	   Nvl(recinfo.end_date_active,recinfo.start_date_active-1) <>
           nvl(p_end_date_active,recinfo.start_date_active-1) OR
	   Nvl(recinfo.FORECAST_COST_RATE_SCH_ID,0) <> nvl(p_FORECAST_COST_RATE_SCH_ID,0) ) THEN
		IF l_debug_mode = 'Y' THEN
			print_msg('firing update query');
		End If;
		UPDATE  pa_org_labor_sch_rule SET
        	   ORGANIZATION_ID   = p_ORGANIZATION_ID
        	   ,ORG_ID                  = p_ORG_ID
        	   ,LABOR_COSTING_RULE      = p_LABOR_COSTING_RULE
        	   ,COST_RATE_SCH_ID        = p_COST_RATE_SCH_ID
        	   ,OVERTIME_PROJECT_ID     = p_OVERTIME_PROJECT_ID
        	   ,OVERTIME_TASK_ID        = p_OVERTIME_TASK_ID
        	   ,ACCT_RATE_DATE_CODE     = p_ACCT_RATE_DATE_CODE
        	   ,ACCT_RATE_TYPE          = p_ACCT_RATE_TYPE
        	   ,ACCT_EXCHANGE_RATE      = p_ACCT_EXCHANGE_RATE
        	   ,START_DATE_ACTIVE       = p_START_DATE_ACTIVE
        	   ,END_DATE_ACTIVE         = p_END_DATE_ACTIVE
		   ,FORECAST_COST_RATE_SCH_ID = p_FORECAST_COST_RATE_SCH_ID
        	   ,LAST_UPDATE_DATE        = p_LAST_UPDATE_DATE
        	   ,LAST_UPDATED_BY         = p_LAST_UPDATED_BY
        	   ,LAST_UPDATE_LOGIN       = p_LAST_UPDATE_LOGIN
		WHERE ORG_LABOR_SCH_RULE_ID = p_ORG_LABOR_SCH_RULE_ID;
        	If sql%found then
                	x_return_status := 'S';
        	Else
                	x_return_status := 'E';
                	x_error_msg_code := 'NO_DATA_FOUND';
			IF l_debug_mode = 'Y' THEN
				print_msg('Update failure:'||x_error_msg_code);
			End If;
                	raise NO_DATA_FOUND;
        	End If;

	End IF;

 EXCEPTION
        when others then
            x_error_msg_code := sqlcode||sqlerrm;
	    IF l_debug_mode = 'Y' THEN
	    	print_msg('Exception:'||x_error_msg_code);
	    End If;
            Raise;

 END update_row;


 PROCEDURE  delete_row (p_ORG_LABOR_SCH_RULE_ID in NUMBER)IS

	l_debug_mode           varchar2(1) := 'N';

 BEGIN
        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'N');

        pa_debug.set_process('PLSQL','LOG',l_debug_mode);

	DELETE FROM PA_ORG_LABOR_SCH_RULE
	WHERE ORG_LABOR_SCH_RULE_ID = p_ORG_LABOR_SCH_RULE_ID;
	if sql%found then
		IF l_debug_mode = 'Y' THEN
			print_msg('Delete Success');
		End If;
	Else
		IF l_debug_mode = 'Y' THEN
			print_msg('Delete Failure');
		End if;
	End if;

 END delete_row;

 PROCEDURE delete_row (x_rowid   in VARCHAR2)IS

	cursor get_itemid is
	select ORG_LABOR_SCH_RULE_ID
	from PA_ORG_LABOR_SCH_RULE
        where rowid = x_rowid;

	l_ORG_LABOR_SCH_RULE_ID Number;

 BEGIN
  	open get_itemid;
  	fetch get_itemid into l_ORG_LABOR_SCH_RULE_ID;
	close get_itemid;

  	delete_row (l_ORG_LABOR_SCH_RULE_ID);

 END delete_row;

 PROCEDURE lock_row (p_org_labor_sch_rule_id    in NUMBER)IS
        CURSOR cur_row is
        SELECT
        ORGANIZATION_ID
        ,ORG_ID
        ,LABOR_COSTING_RULE
        ,COST_RATE_SCH_ID
        ,OVERTIME_PROJECT_ID
        ,OVERTIME_TASK_ID
        ,ACCT_RATE_DATE_CODE
        ,ACCT_RATE_TYPE
        ,ACCT_EXCHANGE_RATE
        ,START_DATE_ACTIVE
        ,END_DATE_ACTIVE
        ,FORECAST_COST_RATE_SCH_ID
        FROM pa_org_labor_sch_rule
        WHERE ORG_LABOR_SCH_RULE_ID = p_ORG_LABOR_SCH_RULE_ID
        FOR UPDATE OF ORG_LABOR_SCH_RULE_ID NOWAIT;

        recinfo cur_row%rowtype;

	l_debug_mode           varchar2(1) := 'N';

 BEGIN
        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'N');

        pa_debug.set_process('PLSQL','LOG',l_debug_mode);

        OPEN cur_row;
        FETCH cur_row INTO recinfo;
        If cur_row%NOTFOUND then
		IF l_debug_mode = 'Y' THEN
                	print_msg('row not found return');
		End If;
                fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
                app_exception.raise_exception;
        End If;
        CLOSE cur_row;
 END lock_row;

END PA_LABOR_SCH_RULE_PKG;

/
