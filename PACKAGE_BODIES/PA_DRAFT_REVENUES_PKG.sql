--------------------------------------------------------
--  DDL for Package Body PA_DRAFT_REVENUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DRAFT_REVENUES_PKG" as
/* $Header: PAXRVUTB.pls 120.2 2007/12/08 19:18:57 jjgeorge ship $ */

 procedure INITIALIZE is
 begin
   pa_security.initialize(fnd_global.user_id, 'PAXRVRVW');
 end INITIALIZE;

 function ALLOW_RELEASE(
		X_PROJECT_ID		in NUMBER,
		X_DRAFT_REVENUE_NUM	in NUMBER)
	return BOOLEAN is
   dummy varchar2(1);
   adj_flag varchar2(1);
 begin
   if pa_security.allow_update(X_project_id) = 'N' then
     FND_MESSAGE.SET_NAME('PA','PA_PROJECT_SECURITY_ENFORCED');
     return FALSE;
   else
     begin
	 select null
	 into dummy
	 from sys.dual
	 where exists (
	   select null
	   from pa_draft_revenues
	   where project_id = X_project_id
	     and draft_revenue_num = X_draft_revenue_num
	     and released_date is null
	     and NVL(generation_error_flag, 'N') = 'N');
     exception
       when no_data_found then
	 FND_MESSAGE.SET_NAME('PA','PA_RV_NO_RELEASE');
	 return FALSE;
       when others then
	 return FALSE;
     end;
     /** bug 2343583 **/
    Select nvl(adjusting_revenue_flag,'N') into adj_flag
    from pa_draft_revenues_all where project_id = X_project_id and
    draft_revenue_num = X_draft_revenue_num;
     begin
	 select null
         into dummy
	 from sys.dual
	 where not exists (
	   select null
	   from pa_draft_revenues
	   where project_id = X_project_id
	     and draft_revenue_num < X_draft_revenue_num
             and released_date is null
             and nvl(adjusting_revenue_flag,'N') = adj_flag );
     exception
       when no_data_found then
	 FND_MESSAGE.SET_NAME('PA','PA_RV_NOT_EARLIEST_REV');
	 return FALSE;
       when others then
	 return FALSE;
     end;
     return TRUE;
   end if;
 end ALLOW_RELEASE;

 function ALLOW_UNRELEASE(
		X_PROJECT_ID		in NUMBER,
		X_DRAFT_REVENUE_NUM	in NUMBER)
	return BOOLEAN is
   dummy varchar2(1);
   adj_flag varchar2(1);
 begin
   if pa_security.allow_update(X_project_id) = 'N' then
     FND_MESSAGE.SET_NAME('PA','PA_PROJECT_SECURITY_ENFORCED');
     return FALSE;
   else
     begin
	 select null
         into dummy
	 from sys.dual
	 where exists (
	   select null
	   from pa_draft_revenues
	   where project_id = X_project_id
	     and draft_revenue_num = X_draft_revenue_num
	     and released_date is not null
             and transfer_status_code in ('P', 'R'));
     exception
       when no_data_found then
	 FND_MESSAGE.SET_NAME('PA','PA_RV_NO_UNRELEASE');
	 return FALSE;
       when others then
	 return FALSE;
     end;

     /** bug 2343583 **/
    Select nvl(adjusting_revenue_flag,'N') into adj_flag
    from pa_draft_revenues_all where project_id = X_project_id and
    draft_revenue_num = X_draft_revenue_num;

     begin
	 select null
         into dummy
	 from sys.dual
	 where not exists (
	   select null
	   from pa_draft_revenues
	   where project_id = X_project_id
	     and draft_revenue_num > X_draft_revenue_num
             and released_date is not null
             and nvl(adjusting_revenue_flag,'N') = adj_flag );
     exception
       when no_data_found then
	 FND_MESSAGE.SET_NAME('PA','PA_RV_NOT_LATEST_REV');
	 return FALSE;
       when others then
	 return FALSE;
     end;

     begin
	 select null
         into dummy
	 from sys.dual
	 where not exists (
	   select null
	   from pa_draft_invoices
	   where (project_id, draft_invoice_num) in
	     (select project_id,draft_invoice_num
	      from pa_cust_rev_dist_lines
	      where project_id = X_project_id
	        and draft_revenue_num = X_draft_revenue_num
              union
	      select project_id,draft_invoice_num
	      from pa_cust_event_rev_dist_lines
	      where project_id = X_project_id
	        and draft_revenue_num = X_draft_revenue_num
	      union /* Start of Changes for bug 5401384 -base bug 5246804 */
	       select distinct dii.project_id,dii.draft_invoice_num
	       from pa_draft_invoice_items dii, pa_events e
	       where dii.project_id=X_project_id
	       and dii.event_num is not null
	       AND e.event_num = dii.event_num
	       and nvl(e.task_id,-99) = nvl(dii.event_task_id,-99)
	       AND EXISTS (SELECT 1 FROM pa_event_types et
               WHERE e.event_type = et.event_type
	       and et.event_type_classification = 'AUTOMATIC')
	       and exists
	       (select 1
	        from pa_cust_event_RDL_ALL
	        where project_id = dii.project_id
	        and draft_revenue_num = X_draft_revenue_num
		and event_num = dii.event_num
		and NVL(task_id,-99) = NVL(dii.event_task_id,-99)
		))/* End of Changes for bug 5401384 - base bug 5246804 */
	     and released_date is not null);
     exception
       when no_data_found then
	 FND_MESSAGE.SET_NAME('PA','PA_RV_INV_RELEASED');
	 return FALSE;
       when others then
	 return FALSE;
     end;

     begin
	 select null
         into dummy
	 from sys.dual
	 where not exists (
	   select null
	   from pa_draft_revenues
           where project_id = X_project_id
	     and draft_revenue_num = X_draft_revenue_num
	     and (nvl(resource_accumulated_flag, 'N') = 'Y'
	       or nvl(accumulated_flag, 'N') = 'Y'));
     exception
       when no_data_found then
	 FND_MESSAGE.SET_NAME('PA','PA_RV_ACCUMED');
	 return FALSE;
       when others then
	 return FALSE;
     end;
   end if;
   return TRUE;
 end ALLOW_UNRELEASE;

 procedure RELEASE(
		X_PROJECT_ID		in     NUMBER,
		X_DRAFT_REVENUE_NUM	in     NUMBER,
                X_ERR_CODE		in out NOCOPY  NUMBER) Is
 begin
   if not allow_release(X_PROJECT_ID, X_DRAFT_REVENUE_NUM) then
     X_err_code := 1;
   else
     begin
       update pa_draft_revenues
       set released_date = sysdate,
	   last_update_date = sysdate,
	   last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.login_id
       where project_id = X_project_id
         and draft_revenue_num = X_draft_revenue_num;
     exception
       when others then
	 X_err_code := sqlcode;
     end;
     X_err_code := 0;
   end if;
 end RELEASE;

 procedure UNRELEASE(
		X_PROJECT_ID		in     NUMBER,
		X_DRAFT_REVENUE_NUM	in     NUMBER,
                X_ERR_CODE		in out NOCOPY  NUMBER) Is
 begin
   if not allow_unrelease(X_PROJECT_ID, X_DRAFT_REVENUE_NUM) then
     X_err_code := 1;
   else
     begin
       update pa_draft_revenues
       set released_date = NULL,
	   last_update_date = sysdate,
	   last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.login_id
       where project_id = X_project_id
         and draft_revenue_num = X_draft_revenue_num;
     exception
       when others then
	 X_err_code := sqlcode;
     end;
     X_err_code := 0;
   end if;
 end UNRELEASE;

end pa_draft_revenues_pkg;

/
