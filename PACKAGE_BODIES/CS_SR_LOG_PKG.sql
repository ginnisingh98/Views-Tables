--------------------------------------------------------
--  DDL for Package Body CS_SR_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_LOG_PKG" AS
/* $Header: csvsrlgb.pls 115.2 2000/03/01 11:19:11 pkm ship      $ */
-- Start of Comments
-- Package name     :CS_SR_LOG_PKG
-- Purpose          :package has function SR_LOG that returns the log field
--                   for a given SR ( incident_id) for fulfillment report
-- History          :
-- NOTE             :
-- End of Comments

--CREATE OR REPLACE PACKAGE BODY CS_SR_LOG_FUL IS

FUNCTION SR_LOG (p_incident_id varchar2,
		  p_public_notes_only varchar2 DEFAULT 'Y',
		  p_order_by varchar2 DEFAULT 'Y')
		  Return varchar2 is

  Cursor C1 (c_public_notes_only varchar2) IS
  select *
  from cs_incidents_diary_v
  where incident_id = p_incident_id
  and ( note_status is null or
	   note_status <> decode(c_public_notes_only,'Y','P') or
	   note_status = decode(c_public_notes_only,'N',note_status,
						'Y','P',note_status))
  order by last_update_date DESC;

  Cursor C2(c_public_notes_only varchar2)  IS
  select *
  from cs_incidents_diary_v
  where incident_id = p_incident_id
  and ( note_status is null or
	   note_status <> decode(c_public_notes_only,'Y','P',note_status) or
	   note_status = decode(c_public_notes_only,'N',note_status,
						'Y','P',note_status))
  order by last_update_date ;

  Cursor c1log is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_AUDIT'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

  Cursor c2log is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_NOTES'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

  Cursor c3log is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_TASKS'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);


  ls_concat_field varchar2(32000);
  ls_source_type  varchar2(30);
  ls_source_type_tr  varchar2(30);
  ls_main_field   varchar2(32000);
  ls_head_field   varchar2(32000);

  ls_audit_details varchar2(32000);

  ls_summary varchar2(32000);
  ls_public_notes_only varchar2(1);

  l_audit VARCHAR2(30);
  l_tasks VARCHAR2(30);
  l_notes VARCHAR2(30);

BEGIN


  OPEN c1log;
  fetch c1log into l_audit;
  CLOSE c1log;

  OPEN c2log;
  fetch c2log into l_notes;
  CLOSE c2log;

  OPEN c3log;
  fetch c3log into l_tasks;
  CLOSE c3log;

  if NVL(p_public_notes_only,'N')  = 'N' then
	   ls_public_notes_only :=  'N';
  elsif p_public_notes_only = 'Y' then
	   ls_public_notes_only := 'P';
  else
	   ls_public_notes_only := 'N';
  end if;

  if (p_order_by = 'Y') then
   for i in c1(ls_public_notes_only)

   loop

	if upper(i.source_type) = 'AUDIT' then
	   ls_source_type_tr := l_audit;
	elsif upper(i.source_type) = 'TASKS' then
	   ls_source_type_tr := l_tasks;
	elsif upper(i.source_type) = 'NOTES' then
	   ls_source_type_tr := l_notes;
     end if;

     If upper(i.source_type) = 'AUDIT' And
        (i.severity_old IS NOT NULL or
         i.severity_new is NOT NULL or
         i.type_old IS NOT NULL     or
         i.type_new IS NOT NULL     or
         i.status_old IS NOT NULL   or
         i.status_new IS NOT NULL   or
         i.urgency_new IS NOT NULL  or
         i.urgency_old IS NOT NULL  or
         i.group_new IS NOT NULL    or
         i.group_old IS NOT NULL    or
         i.owner_new IS NOT NULL    or
         i.owner_old IS NOT NULL    or
         i.date_new IS NOT NULL  or
         i.date_old IS NOT NULL  or
	    i.obligation_date_new IS NOT NULL or
	    i.obligation_date_old IS NOT NULL or
	    i.site_id_new IS NOT NULL or
	    i.site_id_old IS NOT NULL or
	    i.old_bill_to_contact_name IS NOT NULL or
	    i.new_bill_to_contact_name IS NOT NULL or
	    i.old_ship_to_contact_name IS NOT NULL or
	    i.new_ship_to_contact_name IS NOT NULL or
	    i.old_platform_name IS NOT NULL or
	    i.new_platform_name IS NOT NULL or
	    i.old_platform_version_name IS NOT NULL or
	    i.new_platform_version_name IS NOT NULL or
	    i.old_description IS NOT NULL or
	    i.new_description IS NOT NULL or
	    i.old_language IS NOT NULL or
	    i.new_language IS NOT NULL
        ) Then
       CS_SR_LOG_PKG.audit_display(i.source_type ,
                                    i.last_update_date ,
                                    i.owner,
                                    i.old_severity_name,
			                     i.new_severity_name ,
			                     i.old_type_name     ,
			                     i.new_type_name     ,
			                     i.old_status_name   ,
                   	                i.new_status_name   ,
                   	                i.old_urgency_name  ,
                  	                i.new_urgency_name ,
                   	                i.group_old   ,
                   	                i.group_new  ,
			                     i.old_owner,
			                     i.new_owner,
                   	                i.date_old  ,
                   	                i.date_new   ,
							    i.obligation_date_new ,
	    						i.obligation_date_old,
	    						i.site_id_new ,
	    						i.site_id_old,
	    						i.old_bill_to_contact_name,
	    						i.new_bill_to_contact_name,
	    						i.old_ship_to_contact_name,
	    						i.new_ship_to_contact_name,
	    						i.old_platform_name ,
	    						i.new_platform_name,
	    						i.old_platform_version_name ,
	    						i.new_platform_version_name ,
	    						i.old_description ,
	    						i.new_description,
	    						i.old_language ,
	    						i.new_language,
			                     ls_audit_details );
         ls_main_field := ls_audit_details;

         ls_concat_field := ls_concat_field||ls_main_field||gs_newline;
         --ls_concat_field := ls_concat_field||ls_main_field||CHR(10);

     Elsif upper(i.source_type) <> 'AUDIT' Then

         ls_main_field := rpad(to_char(i.last_update_date,'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
					 rpad(i.owner,20,' ')||'  '||
                          rpad(ls_source_type_tr,20,' ')||gs_newline||i.details;

         if upper(i.source_type) = 'TASKS' then

            CS_SR_LOG_PKG.task_notes(i.action_id,ls_audit_details);
            ls_main_field := ls_main_field||gs_newline||ls_audit_details;
         end if;

     ls_concat_field := ls_concat_field||ls_main_field||gs_newline;

     End If;

   end loop;


   else


   for i in c2(ls_public_notes_only)

   loop

	if upper(i.source_type) = 'AUDIT' then
	   ls_source_type_tr := l_audit;
	elsif upper(i.source_type) = 'TASKS' then
	   ls_source_type_tr := l_tasks;
	elsif upper(i.source_type) = 'NOTES' then
	   ls_source_type_tr := l_notes;
     end if;

     If upper(i.source_type) = 'AUDIT' And
        (i.severity_old IS NOT NULL or
         i.severity_new is NOT NULL or
         i.type_old IS NOT NULL     or
         i.type_new IS NOT NULL     or
         i.status_old IS NOT NULL   or
         i.status_new IS NOT NULL   or
         i.urgency_new IS NOT NULL  or
         i.urgency_old IS NOT NULL  or
         i.group_new IS NOT NULL    or
         i.group_old IS NOT NULL    or
         i.owner_new IS NOT NULL    or
         i.owner_old IS NOT NULL    or
         i.date_new IS NOT NULL  or
         i.date_old IS NOT NULL  or
	    i.obligation_date_new IS NOT NULL or
	    i.obligation_date_old IS NOT NULL or
	    i.site_id_new IS NOT NULL or
	    i.site_id_old IS NOT NULL or
	    i.old_bill_to_contact_name IS NOT NULL or
	    i.new_bill_to_contact_name IS NOT NULL or
	    i.old_ship_to_contact_name IS NOT NULL or
	    i.new_ship_to_contact_name IS NOT NULL or
	    i.old_platform_name IS NOT NULL or
	    i.new_platform_name IS NOT NULL or
	    i.old_platform_version_name IS NOT NULL or
	    i.new_platform_version_name IS NOT NULL or
	    i.old_description IS NOT NULL or
	    i.new_description IS NOT NULL or
	    i.old_language IS NOT NULL or
	    i.new_language IS NOT NULL
        ) Then
       CS_SR_LOG_PKG.audit_display(i.source_type ,
                                    i.last_update_date ,
                                    i.owner,
                                    i.old_severity_name,
			                     i.new_severity_name ,
			                     i.old_type_name     ,
			                     i.new_type_name     ,
			                     i.old_status_name   ,
                   	                i.new_status_name   ,
                   	                i.old_urgency_name  ,
                  	                i.new_urgency_name ,
                   	                i.group_old   ,
                   	                i.group_new  ,
			                     i.old_owner,
			                     i.new_owner,
                   	                i.date_old  ,
                   	                i.date_new   ,
							    i.obligation_date_new ,
	    						i.obligation_date_old,
	    						i.site_id_new ,
	    						i.site_id_old,
	    						i.old_bill_to_contact_name,
	    						i.new_bill_to_contact_name,
	    						i.old_ship_to_contact_name,
	    						i.new_ship_to_contact_name,
	    						i.old_platform_name ,
	    						i.new_platform_name,
	    						i.old_platform_version_name ,
	    						i.new_platform_version_name ,
	    						i.old_description ,
	    						i.new_description,
	    						i.old_language ,
	    						i.new_language,
			                     ls_audit_details );
         ls_main_field := ls_audit_details;

         ls_concat_field := ls_concat_field||ls_main_field||gs_newline;
         --ls_concat_field := ls_concat_field||ls_main_field||CHR(10);

     Elsif upper(i.source_type) <> 'AUDIT' Then

         ls_main_field := rpad(to_char(i.last_update_date,'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
					 rpad(i.owner,20,' ')||'  '||
                          rpad(ls_source_type_tr,20,' ')||gs_newline||i.details;

         if upper(i.source_type) = 'TASKS' then

            CS_SR_LOG_PKG.task_notes(i.action_id,ls_audit_details);
            ls_main_field := ls_main_field||gs_newline||ls_audit_details;
         end if;

     ls_concat_field := ls_concat_field||ls_main_field||gs_newline;

     End If;

   end loop;

   end if;

return SUBSTR(ls_concat_field,1,32000);

Exception
   When Value_Error Then
return SUBSTR(ls_concat_field,1,32000);

   When Others Then
       return null;
END SR_LOG;

PROCEDURE audit_display(x_source_type varchar2,
                        x_last_update_date date,
                        x_owner        varchar2,
                        x_severity_old varchar2,
	                   x_severity_new varchar2,
			         x_type_old     varchar2,
			         x_type_new     varchar2,
			         x_status_old   varchar2,
                   	    x_status_new   varchar2,
                   	    x_urgency_old  varchar2,
                        x_urgency_new  varchar2,
                  	    x_group_old    varchar2,
                   	    x_group_new    varchar2,
                   	    x_owner_old    varchar2,
                   	    x_owner_new    varchar2,
                   	    x_date_old     varchar2,
                   	    x_date_new     varchar2,
							    x_obligation_date_new   varchar2 ,
	    						x_obligation_date_old  varchar2 ,
	    						x_site_id_new   varchar2 ,
	    						x_site_id_old  varchar2 ,
	    						x_old_bill_to_contact_name  varchar2 ,
	    						x_new_bill_to_contact_name  varchar2 ,
	    						x_old_ship_to_contact_name  varchar2 ,
	    						x_new_ship_to_contact_name  varchar2 ,
	    						x_old_platform_name   varchar2 ,
	    						x_new_platform_name  varchar2 ,
	    						x_old_platform_version_name   varchar2 ,
	    						x_new_platform_version_name   varchar2 ,
	    						x_old_description   varchar2 ,
	    						x_new_description  varchar2 ,
	    						x_old_language   varchar2 ,
	    						x_new_language  varchar2 ,
			         x_details OUT VARCHAR2)
Is

  ls_details VARCHAR2(32767);

  Cursor c_status is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_STATUS'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

  Cursor c_urgency is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_URGENCY'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);


  Cursor c_severity is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_SEVERITY'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

  Cursor c_date is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_DATE'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

  Cursor c_obligation_date is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_OBLIGATION_DATE'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

  Cursor c_owner is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_OWNER'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

  Cursor c_bill_to_contact_name is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_BILL_TO_CONTACT_NAME'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

  Cursor c_ship_to_contact_name is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_SHIP_TO_CONTACT_NAME'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

  Cursor c_product is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_PRODUCT'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

  Cursor c_type is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_TYPE'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

  Cursor c_group is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_GROUP'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

  Cursor c_language is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_LANGUAGE'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

  Cursor c_platform is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_PLATFORM'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

  Cursor c_platform_version is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_PLATFORM_VERSION'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

  Cursor c_site is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_SITE'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

  lrec cs_incidents_diary_v%rowtype;

l_status VARCHAR2(240);
l_urgency VARCHAR2(240);
l_severity VARCHAR2(240);
l_date VARCHAR2(240);
l_obligation_date VARCHAR2(240);
l_owner VARCHAR2(240);
l_bill_to_contact_name VARCHAR2(240);
l_ship_to_contact_name VARCHAR2(240);
l_product VARCHAR2(240);
l_type VARCHAR2(240);
l_group VARCHAR2(240);
l_site VARCHAR2(240);
l_platform VARCHAR2(240);
l_platform_version VARCHAR2(240);
l_language VARCHAR2(240);

 Begin

OPEN c_status;
FETCH c_status INTO l_status;
CLOSE c_status;

OPEN c_urgency;
FETCH c_urgency INTO l_urgency;
CLOSE c_urgency;

OPEN c_severity;
FETCH c_severity INTO l_severity;
CLOSE c_severity;

OPEN c_date;
FETCH c_date INTO l_date;
CLOSE c_date;

OPEN c_obligation_date;
FETCH c_obligation_date INTO l_obligation_date;
CLOSE c_obligation_date;

OPEN c_owner;
FETCH c_owner INTO l_owner;
CLOSE c_owner;

OPEN c_bill_to_contact_name;
FETCH c_bill_to_contact_name INTO l_bill_to_contact_name;
CLOSE c_bill_to_contact_name;

OPEN c_ship_to_contact_name;
FETCH c_ship_to_contact_name INTO l_ship_to_contact_name;
CLOSE c_ship_to_contact_name;

OPEN c_product;
FETCH c_product INTO l_product;
CLOSE c_product;

OPEN c_type;
FETCH c_type INTO l_type;
CLOSE c_type;

OPEN c_group;
FETCH c_group INTO l_group;
CLOSE c_group;

OPEN c_site;
FETCH c_site INTO l_site;
CLOSE c_site;

OPEN c_language;
FETCH c_language INTO l_language;
CLOSE c_language;

OPEN c_platform;
FETCH c_platform INTO l_platform;
CLOSE c_platform;

OPEN c_platform_version;
FETCH c_platform_version INTO l_platform_version;
CLOSE c_platform_version;


 If X_severity_old is not null or x_severity_new is not null then
    ls_details := ls_details||
			      rpad(to_char(X_last_update_date,
				 'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
				 rpad(X_owner,20,' ')||'  '||
				 rpad(l_severity||':',20,' ')||'  '||
                  rpad(NVL(X_severity_old,' '),20,' ')||' -> '||
				 rpad(NVL(X_severity_new,' '),20,' ')||gs_newline;
 End If;

 If X_status_old is not null or x_status_new is not null then
    ls_details := ls_details||
			      rpad(to_char(X_last_update_date,
				 'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
				 rpad(X_owner,20,' ')||'  '||
				 rpad(l_status||':',20,' ')||'  '||
                  rpad(NVL(X_status_old,' '),20,' ')||' -> '||
				 rpad(NVL(X_status_new,' '),20,' ')||gs_newline;
 End If;

 If X_type_old is not null or x_type_new is not null then
    ls_details := ls_details||
			      rpad(to_char(X_last_update_date,
				 'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
				 rpad(X_owner,20,' ')||'  '||
				 rpad(l_type||':',20,' ')||'  '||
                  rpad(NVL(X_type_old,' '),20,' ')||' -> '||
				 rpad(NVL(X_type_new,' '),20,' ')||gs_newline;
 End If;

 If X_urgency_old is not null or x_urgency_new is not null then
    ls_details := ls_details||
			       rpad(to_char(X_last_update_date,
				  'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
				  rpad(X_owner,20,' ')||'  '||
				  rpad(l_urgency||':',20,' ')||'  '||
                   rpad(NVL(X_urgency_old,' '),20,' ')||' -> '||
				  rpad(NVL(X_urgency_new,' '),20,' ')||gs_newline;
 End If;

 If x_group_old is not null or x_group_new is not null then
    ls_details := ls_details||
			      rpad(to_char(X_last_update_date,
				 'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
				 rpad(X_owner,20,' ')||'  '||
				 rpad(l_group||':',25,' ')||'  '||
				 rpad(NVL(X_Group_old,' '),20,' ')||' -> '||
				 rpad(NVL(X_Group_new,' '),20,' ')||gs_newline;
 End if;

 If x_owner_old is not null or x_owner_new is not null then
    ls_details := ls_details||
			   rpad(to_char(X_last_update_date,
			   'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
			   rpad(X_owner,20,' ')||'  '||
			   rpad(l_owner||':',25,' ')||'  '||
               rpad(NVL(X_owner_old,' '),20,' ')||' -> '||
			   rpad(NVL(X_owner_new,' '),20,' ')||gs_newline;
 End If;

 If x_date_old is not null or x_date_new is not null then
     ls_details := ls_details||
				  rpad(to_char(X_last_update_date,
				  'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
				  rpad(X_owner,20,' ')||'  '||
				  rpad(l_date||':',25,' ')||'  '||
                   rpad(NVL(X_Date_old,' '),20,' ')||' -> '||
				  rpad(NVL(X_Date_new,' '),20,' ')||gs_newline;
 End If;


 If x_obligation_date_old is not null or x_obligation_date_new is not null then
     ls_details := ls_details||
			    rpad(to_char(X_last_update_date,
			    'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
			    rpad(X_owner,20,' ')||'  '||
			    rpad(l_obligation_date||
			    ':',25,' ')||'  '||
                   rpad(NVL(X_obligation_Date_old,' '),20,' ')||' -> '||
			    rpad(NVL(X_obligation_Date_new,' '),20,' ')||gs_newline;
 End If;

 If x_site_id_old is not null or x_site_id_old is not null then
     ls_details := ls_details||
			    rpad(to_char(X_last_update_date,
			    'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
			    rpad(X_owner,20,' ')||'  '||
			    rpad(l_site||
			    ':',25,' ')||'  '||
                   rpad(NVL(X_site_id_old,' '),20,' ')||' -> '||
			    rpad(NVL(X_site_id_old,' '),20,' ')||gs_newline;
 End If;

 If x_old_bill_to_contact_name is not null or
    x_new_bill_to_contact_name is not null then
     ls_details := ls_details||
			    rpad(to_char(X_last_update_date,
			    'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
			    rpad(X_owner,20,' ')||'  '||
			    rpad(l_bill_to_contact_name||
			    ':',25,' ')||'  '||
                rpad(NVL(X_old_bill_to_contact_name,' '),20,' ')||' -> '||
			    rpad(NVL(X_new_bill_to_contact_name,' '),20,' ')||
			    gs_newline;
 End If;


 If x_old_ship_to_contact_name is not null or
    x_old_ship_to_contact_name is not null then
     ls_details := ls_details||
			    rpad(to_char(X_last_update_date,
			    'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
			    rpad(X_owner,20,' ')||'  '||
			    rpad(l_ship_to_contact_name||
			    ':',25,' ')||'  '||
                   rpad(NVL(X_old_ship_to_contact_name,' '),20,' ')||' -> '||
			    rpad(NVL(X_new_ship_to_contact_name,' '),20,' ')||
			    gs_newline;
 End If;

 If x_old_platform_name is not null or
    x_new_platform_name is not null then
     ls_details := ls_details||
			    rpad(to_char(X_last_update_date,
			    'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
			    rpad(X_owner,20,' ')||'  '||
			    rpad(l_platform||
			    ':',25,' ')||'  '||
                rpad(NVL(X_old_platform_name,' '),20,' ')||' -> '||
			    rpad(NVL(X_new_platform_name,' '),20,' ')||gs_newline;
 End If;

 If x_old_platform_version_name is not null or
    x_new_platform_version_name is not null then
     ls_details := ls_details||
			    rpad(to_char(X_last_update_date,
			    'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
			    rpad(X_owner,20,' ')||'  '||
			    rpad(l_platform_version||
			    ':',25,' ')||'  '||
                   rpad(NVL(X_old_platform_version_name,' '),20,' ')||' -> '||
			    rpad(NVL(X_new_platform_version_name,' '),20,' ')||
			    gs_newline;
 End If;


 If x_old_description is not null or
    x_new_description is not null then
     ls_details := ls_details||
			    rpad(to_char(X_last_update_date,
			    'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
			    rpad(X_owner,20,' ')||'  '||
			    rpad(l_product||
			    ':',25,' ')||'  '||
                   rpad(NVL(X_old_description,' '),20,' ')||' -> '||
			    rpad(NVL(X_new_description,' '),20,' ')||
			    gs_newline;
 End If;

 If x_old_language is not null or
    x_new_language is not null then
     ls_details := ls_details||
			    rpad(to_char(X_last_update_date,
			    'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||
			    rpad(X_owner,20,' ')||'  '||
			    rpad(l_language||
			    ':',25,' ')||'  '||
                   rpad(NVL(X_old_language,' '),20,' ')||' -> '||
			    rpad(NVL(X_new_language,' '),20,' ')||
			    gs_newline;
 End If;

  X_details := ls_details;
Exception
 When Value_Error Then
   X_details := SUBSTR(ls_details,1,32000);
END audit_display;

PROCEDURE TASK_NOTES ( X_TASK_ID NUMBER,
                       X_DETAILS OUT VARCHAR2) IS

CURSOR CUR_NOTES IS
SELECT last_update_date,notes,entered_by_name owner
FROM   jtf_notes_vl
WHERE  source_object_id = X_TASK_ID
AND    source_object_code = 'TASK'
ORDER BY 1;

  Cursor c2log is
  select meaning
  from cs_lookups
  where lookup_type = 'CS_LOG_PARAMETERS'
  and   lookup_code = 'LOG_NOTES'
  and   enabled_flag = 'Y'
  and   sysdate between NVL(start_date_active,sysdate) and
				    NVL(end_date_active,sysdate);

ls_details_ind VARCHAR2(32000);
ls_details     VARCHAR2(32000);
ls_heading     VARCHAR2(1000);


l_notes VARCHAR2(240);
BEGIN

OPEN c2log;
FETCH c2log into l_notes;
CLOSE c2log;


  for i in cur_notes

    Loop

      ls_details_ind := rpad(to_char(i.last_update_date,'MM/DD/YYYY HH:MI:SS'),20,' ')||'  '||rpad(i.owner,20,' ')||'  '||rpad(l_notes,20,' ')||gs_newline||i.notes||gs_newline;
       ls_details := ls_details||ls_details_ind;
     End Loop;

X_details := ls_heading||ls_details;


END task_notes;
END cs_sr_log_pkg;

/
