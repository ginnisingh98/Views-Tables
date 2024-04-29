--------------------------------------------------------
--  DDL for Package Body JTF_EC_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_EC_WORKFLOW_PKG" as
/* $Header: jtfecwfb.pls 120.2.12010000.2 2009/01/29 12:22:13 ramchint ship $ */

FUNCTION get_resource_name(
			p_resource_type IN 	VARCHAR2,
			p_resource_id	IN	NUMBER
			) RETURN VARCHAR2 is
TYPE 	     cur_typ IS REF CURSOR;
c            cur_typ;
l_api_name   		VARCHAR2(20) 	:= 'Get_Resource_Name';
l_sql_statement		VARCHAR2(500)	:= NULL;
l_resource_name		jtf_tasks_b.source_object_name%TYPE := NULL;
l_where_clause		jtf_objects_b.where_clause%TYPE := NULL;

-------------------------------------------------------------------------
-- Create a SQL statement for getting the resource name
-------------------------------------------------------------------------

cursor c_get_res_name is
SELECT where_clause,
'SELECT '||select_name||' FROM '||from_table||' WHERE '||select_id|| ' = :RES'
FROM 	jtf_objects_vl
WHERE	object_code = p_resource_type;

BEGIN

open c_get_res_name;
fetch c_get_res_name into l_where_clause, l_sql_statement;
close c_get_res_name;

if l_sql_statement is not NULL then

l_sql_statement := l_sql_statement;  -- || to_char(p_resource_id);

	if l_where_clause is not NULL then
           l_sql_statement := l_sql_statement||' AND '||l_where_clause;
	end if;

	OPEN c FOR l_sql_statement USING p_resource_id;
        FETCH c INTO l_resource_name;
	CLOSE c;

--	EXECUTE IMMEDIATE l_sql_statement INTO l_resource_name;
	RETURN l_resource_name;
else

RETURN Null;

end if;

EXCEPTION

WHEN OTHERS THEN
	if 	FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	then    FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		l_api_name
	    		);
	end if;
RETURN Null;

END get_resource_name;


-------------------------------------------------------------------------
-- Include a role in the notification list
-------------------------------------------------------------------------

PROCEDURE include_role(
			p_role_name	IN	VARCHAR2,
			x_return_status	OUT NOCOPY	VARCHAR2) is

l_api_name		VARCHAR2(30)	:= 'Include_Role';
i BINARY_INTEGER := jtf_ec_workflow_pkg.NotifList.COUNT;

BEGIN

-- doesn't perform a role validation

x_return_status := FND_API.G_RET_STS_SUCCESS;

jtf_ec_workflow_pkg.NotifList(i+1).name := p_role_name;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_Ret_Sts_Error;
WHEN OTHERS THEN

x_return_status := fnd_api.g_ret_sts_unexp_error;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
then FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		l_api_name
	    		);
end if;

END include_role;

-------------------------------------------------------------------------
-- Get the name of the user who created the escalation document
-------------------------------------------------------------------------
PROCEDURE get_user_name(p_user_id 		IN 	NUMBER,
			  x_user_name		OUT NOCOPY 	VARCHAR2,
			  x_return_status 	OUT NOCOPY	VARCHAR2) is

l_api_name		VARCHAR2(30)	:= 'Get_User_Name';

cursor 	c_user_name(p_user_id IN NUMBER) is
SELECT	per.full_name name
FROM 	per_people_f	per,
	fnd_user	f
WHERE 	f.employee_id = per.person_id
AND   	f.user_id = p_user_id
union
SELECT 	user_name	name
FROM	fnd_user
WHERE 	employee_id is null
AND   	user_id = p_user_id;

BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	open c_user_name(p_user_id);
	fetch c_user_name into x_user_name;
	if   c_user_name%NOTFOUND then
	     x_user_name := NULL;
        end if;
        close c_user_name;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_Ret_Sts_Error;
WHEN OTHERS THEN

x_return_status := fnd_api.g_ret_sts_unexp_error;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
then FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		l_api_name
	    		);
end if;

END get_user_name;

-------------------------------------------------------------------------
-- Get the owner name for the escalated referenced
-- documents
-------------------------------------------------------------------------

PROCEDURE get_doc_owner_name(p_doc_type		IN	VARCHAR2,
		 	     p_doc_number	IN	VARCHAR2,
			     x_resource_id	OUT NOCOPY	NUMBER,
		 	     x_person_name	OUT NOCOPY	VARCHAR2,
		 	     x_return_status 	OUT NOCOPY	VARCHAR2) is

TYPE 	     cur_typ IS REF CURSOR;
c            cur_typ;

l_api_name		VARCHAR2(30)	:= 'Get_Doc_Owner_Name';

l_owner_name 		per_all_people_f.full_name%TYPE := NULL;
l_owner_id		NUMBER 			:= NULL;
l_resource_type		jtf_objects_vl.object_code%TYPE := NULL;
l_resource_type_dev	jtf_objects_vl.object_code%TYPE := NULL;
l_phase_owner_name	VARCHAR2(240);
l_dev_owner_name	VARCHAR2(240);
l_phase_owner_id	NUMBER;
l_dev_owner_id		NUMBER;
l_role_name		wf_users.name%TYPE := NULL;
l_return_status		varchar2(2) := 'x';
l_new_line		varchar2(4) := '
';

-------------------------------------------------------------------------
-- Get the owner name/id for the referenced TASKs
-------------------------------------------------------------------------

cursor 	c_get_task_owner_id is
SELECT	owner_id,
	owner_type_code
FROM 	jtf_tasks_vl
WHERE 	task_number = p_doc_number;


-------------------------------------------------------------------------
-- Get the owner name/id for the referenced SRs
-------------------------------------------------------------------------

l_sr_sql_statement	VARCHAR2(200)	:= 'SELECT incident_owner_id, resource_type FROM cs_incidents_all_vl WHERE 	incident_number = :p_doc_number';

/* cursor 	c_get_sr_owner_id is
SELECT	incident_owner_id,
	resource_type
FROM 	cs_incidents_all_vl
WHERE 	incident_number = p_doc_number; */

-------------------------------------------------------------------------
-- Get the owner name/id for the referenced DFs and ENHs
-------------------------------------------------------------------------

/* -- that code will be used when DF is ready for it  */

l_df_sql_statement	VARCHAR2(200)	:= 'SELECT phase_owner_id, phase_owner_resource_type FROM css_def_defects_b WHERE defect_number = :p_doc_number';

/*  l_df_sql_statement	VARCHAR2(200)	:= 'SELECT phase_owner_id, dev_owner_id FROM css_def_defects_all WHERE defect_number = :p_doc_number';  */


/* cursor 	c_get_df_owner_name is
SELECT	phase_owner_id,
	dev_owner_id
FROM 	css_def_defects_all
WHERE 	defect_number = p_doc_number; */

BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	if 	p_doc_type = 'TASK' then

		open c_get_task_owner_id;
		fetch c_get_task_owner_id into l_owner_id, l_resource_type;
		close c_get_task_owner_id;

      		if l_owner_id is not NULL AND l_resource_type = 'RS_EMPLOYEE' then --bug 5890282

		l_owner_name :=	get_resource_name(l_resource_type,
						l_owner_id);

			l_role_name := jtf_rs_resource_pub.get_wf_role(l_owner_id);

			if l_role_name is not NULL then
				include_role(l_role_name,
		     			     l_return_status);
			elsif l_owner_name is not NULL then
				   g_notif_not_sent := g_notif_not_sent || l_new_line || l_owner_name;
			else
  			           g_notif_not_sent := g_notif_not_sent || l_new_line ||l_resource_type||' = '|| to_char(l_owner_id);
			end if;



		else
		    l_owner_id := NULL;
		    l_owner_name := NULL;
	   	end if;


		x_person_name 	:= l_owner_name;
		x_resource_id  	:= l_owner_id;

	elsif 	p_doc_type = 'SR' then

		OPEN c FOR l_sr_sql_statement USING p_doc_number;
        	FETCH c INTO l_owner_id, l_resource_type;
		CLOSE c;

	/*	open c_get_sr_owner_id;
		fetch c_get_sr_owner_id into l_owner_id, l_resource_type;
		close c_get_sr_owner_id; */

		if l_owner_id is not NULL AND l_resource_type = 'RS_EMPLOYEE' then --bug 5890282


		        l_owner_name :=	get_resource_name(l_resource_type,
						l_owner_id);

			l_role_name := jtf_rs_resource_pub.get_wf_role(l_owner_id);

			if l_role_name is not NULL then
				include_role(l_role_name,
		     			     l_return_status);
			elsif l_owner_name is not NULL then
				   g_notif_not_sent := g_notif_not_sent || l_new_line || l_owner_name;
			else
  			           g_notif_not_sent := g_notif_not_sent || l_new_line ||l_resource_type||' = '|| to_char(l_owner_id);
			end if;



		else
	    	    l_owner_id := NULL;
		    l_owner_name := NULL;

	   	end if;

		x_person_name 	:= l_owner_name;
		x_resource_id  	:= l_owner_id;

	elsif 	(p_doc_type = 'DF') or (p_doc_type = 'ENH')  then


	/*	-- to be used when DF is ready  */
		OPEN c FOR l_df_sql_statement USING p_doc_number;
        	FETCH c INTO l_phase_owner_id, l_resource_type;
		CLOSE c;


	/*	OPEN c FOR l_df_sql_statement USING p_doc_number;
        	FETCH c INTO l_phase_owner_id,  l_dev_owner_id;
		CLOSE c;  */


	/*	open c_get_df_owner_name;
		fetch c_get_df_owner_name into 	l_phase_owner_id,
						l_dev_owner_id;
		close c_get_df_owner_name; */

           	if  l_phase_owner_id is not NULL AND l_resource_type = 'RS_EMPLOYEE' then --bug 5890282

		 /*       l_phase_owner_name :=	get_resource_name('RS_EMPLOYEE',
								  l_phase_owner_id); */
		/*	-- to be used when DF is ready  */

 			l_phase_owner_name :=	get_resource_name(l_resource_type,
								  l_phase_owner_id);

			x_person_name 	:= l_phase_owner_name;
			x_resource_id  	:= l_phase_owner_id;

			l_role_name := jtf_rs_resource_pub.get_wf_role(l_phase_owner_id);

			if l_role_name is not NULL then
				include_role(l_role_name,
		     			     l_return_status);


			elsif l_phase_owner_name is not NULL then
				   g_notif_not_sent := g_notif_not_sent || l_new_line || l_phase_owner_name;
			else
--Bug2415943  			           g_notif_not_sent := g_notif_not_sent || l_new_line || 'RS_EMPLOYEE = ' || to_char(l_phase_owner_id);
  			           g_notif_not_sent := g_notif_not_sent || l_new_line || l_resource_type || ' = ' || to_char(l_phase_owner_id);
			end if;

		else
			x_person_name 	:= NULL;
			x_resource_id  	:= NULL;

	   	end if;
	end if;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_Ret_Sts_Error;
WHEN OTHERS THEN

x_return_status := fnd_api.g_ret_sts_unexp_error;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
then FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		l_api_name
	    		);
end if;

END get_doc_owner_name;


-------------------------------------------------------------------------
-- Initialize the new line attributes needed for the notification layout
-------------------------------------------------------------------------

PROCEDURE init_new_lines(
			 p_itemtype    	IN       VARCHAR2,
      			 p_itemkey     	IN       VARCHAR2) is

l_new_line		VARCHAR2(4):= '
';  -- this is a new line. Do not touch.
l_api_name 	VARCHAR2(20) := 'Init_New_Lines';

BEGIN

      	wf_engine.SetItemAttrText (
         itemtype => p_itemtype ,
         itemkey => p_itemkey,
         aname => 'NLTO',
         avalue => l_new_line
        );
      	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'NLTL',
         avalue => l_new_line
        );
      	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'NLTS',
         avalue => l_new_line
        );
      	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'NLTD',
         avalue => l_new_line
        );

EXCEPTION

WHEN OTHERS THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
then FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		l_api_name
	    		);
end if;
raise;
END init_new_lines;

-------------------------------------------------------------------------
-- Hide the owner line in the notification when there are no owner changes
-------------------------------------------------------------------------

PROCEDURE hide_owner_line(
			 p_itemtype    	IN       VARCHAR2,
      			 p_itemkey     	IN       VARCHAR2) is
l_api_name	VARCHAR2(20) := 'Hide_Owner_Line';
BEGIN

      	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'NLTO',
         avalue => NULL
        );
	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'NLHO',
         avalue => NULL
        );
	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'EOOV',
         avalue => NULL
        );
	 wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'OWNER_NAME_OLD',
         avalue => NULL
        );
	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'EONV',
         avalue => NULL
        );
	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'OWNER_NAME_C',
         avalue => NULL
        );
EXCEPTION
WHEN OTHERS THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
then FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		l_api_name
	    		);
end if;
raise;
END hide_owner_line;

-------------------------------------------------------------------------
-- Hide the status line in the notification when there are no status changes
-------------------------------------------------------------------------

PROCEDURE hide_status_line(
			 p_itemtype    	IN       VARCHAR2,
      			 p_itemkey     	IN       VARCHAR2) is
l_api_name	VARCHAR2(20) := 'Hide_Status_Line';

BEGIN
     	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'NLTS',
         avalue => NULL
        );
	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'NLHS',
         avalue => NULL
        );
	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'ESOV',
         avalue => NULL
        );
      	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'ESC_STATUS_OLD',
         avalue => NULL
      	);
	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'ESNV',
         avalue => NULL
        );

	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'ESC_STATUS',
         avalue => NULL
        );

EXCEPTION

WHEN OTHERS THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
then FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		l_api_name
	    		);
end if;
raise;
End hide_status_line;

-------------------------------------------------------------------------
-- Hide the level line in the notification when there are no level changes
-------------------------------------------------------------------------

PROCEDURE hide_level_line(
			 p_itemtype    	IN       VARCHAR2,
      			 p_itemkey     	IN       VARCHAR2) is
l_api_name	VARCHAR2(20) := 'Hide_Level_Line';

BEGIN

     	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'NLTL',
         avalue => NULL
        );
	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'NLHL',
         avalue => NULL
        );
	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'ELOV',
         avalue => NULL
        );
      	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'ESC_LEVEL_OLD',
         avalue => NULL
      	);
	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'ELNV',
         avalue => NULL
        );
	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'ESC_LEVEL',
         avalue => NULL
        );
EXCEPTION

WHEN OTHERS THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
then FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		l_api_name
	    		);
end if;
raise;
END hide_level_line;

-------------------------------------------------------------------------
-- Hide the target date line in the notification when there are no changes
-------------------------------------------------------------------------

PROCEDURE hide_target_line(
			 p_itemtype    	IN       VARCHAR2,
      			 p_itemkey     	IN       VARCHAR2) is
l_api_name	VARCHAR2(20) := 'Hide_Target_Line';

BEGIN

      	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'NLTD',
         avalue => NULL
        );
	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'NLHD',
         avalue => NULL
        );
	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'ETDOV',
         avalue => NULL
        );
      	wf_engine.SetItemAttrDate (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'TARGET_DATE_OLD',
         avalue => NULL
      	);
	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'ETDNV',
         avalue => NULL
        );
	wf_engine.SetItemAttrText (
         itemtype => p_itemtype,
         itemkey => p_itemkey,
         aname => 'TARGET_DATE',
         avalue => NULL
        );

EXCEPTION

WHEN OTHERS THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
then FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		l_api_name
	    		);
end if;
raise;
END hide_target_line;


-------------------------------------------------------------------------
-- Get the details (object_type,number) for the escalated referenced
-- documents
-------------------------------------------------------------------------

PROCEDURE get_doc_details(
			  p_task_id		IN 	VARCHAR2,
			  x_doc_type		OUT NOCOPY	VARCHAR2,
			  x_doc_number		OUT NOCOPY	VARCHAR2,
			  x_doc_owner_name	OUT NOCOPY	VARCHAR2,
			  x_doc_details_t	OUT NOCOPY	VARCHAR2,
			  x_doc_details_h	OUT NOCOPY	VARCHAR2,
			  x_return_status	OUT NOCOPY	VARCHAR2) is

l_api_name		VARCHAR2(30)	:= 'Get_Doc_Details';

l_select_statement	varchar2(500) 	:= NULL;
l_object_number		jtf_task_references_vl.object_name%TYPE;
l_object_desc		varchar2(1000);
l_doc_details_t		varchar2(4000);
l_doc_details_h		varchar2(4000);
l_resource_id 		NUMBER	:=NULL;
l_person_name		per_all_people_f.full_name%TYPE;
l_temp_status		VARCHAR2(2);

cursor 	get_doc_details is
SELECT 	jo.name object_type,
	jo.object_code,
	tr.object_name object_number
FROM   	jtf_objects_vl jo,
	jtf_task_references_vl tr
WHERE  	tr.task_id = p_task_id
AND	tr.object_type_code = jo.object_code
AND	tr.reference_code = 'ESC';

BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	for details_rec in get_doc_details loop
	    l_object_number := details_rec.object_number;

	    get_doc_owner_name(p_doc_type => details_rec.object_code,
		 	     p_doc_number => details_rec.object_number,
			     x_resource_id => l_resource_id,
		 	     x_person_name => l_person_name,
		 	     x_return_status 	=> l_temp_status);

	if fnd_msg_pub.check_msg_level( fnd_msg_pub.g_msg_lvl_debug_medium )
           AND l_temp_status <> FND_API.G_RET_STS_SUCCESS
        then
   	 fnd_message.set_name ('JTF', 'JTF_EC_DET_ERROR');
   	 fnd_msg_pub.Add;
	end if;

	    x_doc_type := details_rec.object_type;
	    x_doc_number := details_rec.object_number;
	    x_doc_owner_name := l_person_name;

	    l_doc_details_t := l_doc_details_t||'
'||rpad(details_rec.object_type, 31)||rpad(l_object_number,15)||l_person_name;

	    l_doc_details_h := l_doc_details_h||'<BR>'||rpad(details_rec.object_type, 35,'.')||rpad(l_object_number,20,'.')||l_person_name;

	end loop;

	x_doc_details_t	:= l_doc_details_t;
	x_doc_details_h	:= l_doc_details_h;

EXCEPTION

WHEN OTHERS THEN

	x_return_status := fnd_api.g_ret_sts_unexp_error;

	if 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	then
    	    	FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		l_api_name
	    		);
	end if;

END get_doc_details;


---------------------------------------------------------------------------
-- Create a list (PL/SQL table) with all of the people who will be notified
---------------------------------------------------------------------------

PROCEDURE SetNotifList(p_task_id		IN	NUMBER,
			p_owner_id		IN	NUMBER,
			p_old_owner_id		IN	NUMBER	:= FND_API.G_MISS_NUM,
			p_owner_type_code	IN	VARCHAR2,
			p_old_owner_type_code	IN	VARCHAR2,
			x_row_number 		OUT NOCOPY 	NUMBER,
			x_return_status       	OUT NOCOPY     VARCHAR2) Is

l_api_name		VARCHAR2(30)	:= 'SetNotifList';
l_name			per_all_people_f.full_name%TYPE := NULL;  --Bug 2700953
l_role_name		wf_users.name%TYPE := NULL;
l_display_name		wf_users.display_name%TYPE := NULL;
l_manager_id		per_all_people_f.person_id%TYPE := NULL;
l_temp_status		VARCHAR2(2);
l_new_line		VARCHAR2(4) := '
';

-------------------------------------------------------------------------
-- All employee contacts that should be notified
-------------------------------------------------------------------------
Cursor 	c_emp_contacts Is
SELECT 	contact_id
FROM 	jtf_task_contacts
WHERE	task_id = p_task_id
AND	contact_type_code = 'EMP'
AND	nvl(escalation_notify_flag, 'N') = 'Y';

-------------------------------------------------------------------------
-- Employee contact name
-------------------------------------------------------------------------
cursor get_employee_name(p_emp_id NUMBER) is
SELECT full_name
FROM   per_all_people_F
WHERE  person_id = p_emp_id;
--FROM   per_employees_current_x
--WHERE  employee_id = p_emp_id;

-------------------------------------------------------------------------
-- all external contacts that should be notified
-------------------------------------------------------------------------

cursor	c_ext_contact_details is
SELECT 	ct.contact_id,
       	p.subject_party_name contact_name
FROM   	jtf_task_contacts	ct,
       	jtf_party_all_contacts_v p
WHERE  	ct.task_id = p_task_id
AND    	NVL(ct.escalation_notify_flag, 'N') = 'Y'
AND	ct.contact_type_code ='CUST'
AND    	ct.contact_id IN (p.subject_party_id, p.party_id);

-------------------------------------------------------------------------
-- Owner's Manager Person ID
-------------------------------------------------------------------------

cursor	c_owner_manager(p_resource_id in NUMBER) is
SELECT 	manager_person_id
FROM 	jtf_rs_emp_dtls_vl
WHERE	resource_id = p_resource_id;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

-------------------------------------------------------------------------
-- Include the Esc Owner in the Notification List
-------------------------------------------------------------------------

--Bug 2415943 Include the Esc Owner only if owner_type_code is RS_EMPLOYEE Start
if (p_owner_type_code = 'RS_EMPLOYEE') then

l_role_name := jtf_rs_resource_pub.get_wf_role(p_owner_id);


if l_role_name is not NULL then

	include_role(l_role_name,
		     l_temp_status);
else

--Bug 2415943 l_name :=	get_resource_name('RS_EMPLOYEE', p_owner_id);

	l_name := get_resource_name(p_owner_type_code, p_owner_id);

	if l_name is not NULL then

	   g_notif_not_sent := g_notif_not_sent || l_new_line ||l_name;
	else

--Bug 2415943	   g_notif_not_sent := g_notif_not_sent || l_new_line || 'RS_EMPLOYEE = ' || to_char(p_owner_id);
	   g_notif_not_sent := g_notif_not_sent || l_new_line || p_owner_type_code || ' = ' || to_char(p_owner_id);

	end if;

end if;


-------------------------------------------------------------------------
-- Include the Owner Manager in the Notification List
-------------------------------------------------------------------------

-- get manager

l_name := NULL;

open c_owner_manager(p_owner_id);
fetch c_owner_manager into l_manager_id;
close c_owner_manager;

if (l_manager_id is not NULL) then
	l_role_name := NULL;

	wf_directory.GetUserName
     			('PER',
      			l_manager_id,
      			l_role_name,
      			l_display_name);

	if l_role_name is not NULL then
		include_role(l_role_name,
		     	     l_temp_status);
        else open  get_employee_name(l_manager_id);
	     fetch get_employee_name into l_name;
	     close get_employee_name;

	     if l_name is not NULL then
		g_notif_not_sent := g_notif_not_sent || l_new_line || l_name;
             else
	   	g_notif_not_sent := g_notif_not_sent || l_new_line || 'PERSON_ID = '|| to_char(l_manager_id);
	     end if;
         end if;


end if;
end if;

--Bug 2415943 Include the Esc Owner only if owner_type_code is RS_EMPLOYEE End

-------------------------------------------------------------------------
-- Include the Old Owner in the Notification List
-------------------------------------------------------------------------

--Bug 2415943 Include Old Owner only if old_owner_type_code is RS_EMPLOYEE Start

if (p_old_owner_type_code = 'RS_EMPLOYEE')  then

if p_old_owner_id <> FND_API.G_MISS_NUM then

	l_role_name := NULL;
	l_name := NULL;

l_role_name := jtf_rs_resource_pub.get_wf_role(p_old_owner_id);

	if l_role_name is not NULL then

		include_role(l_role_name,
		     	     l_temp_status);
	else

--Bug 2415943	   	l_name :=	get_resource_name('RS_EMPLOYEE', p_old_owner_id);

	   	l_name :=	get_resource_name(p_old_owner_type_code, p_old_owner_id);

		if l_name is not NULL then
	   	   g_notif_not_sent := g_notif_not_sent || l_new_line ||l_name;
		else

--Bug 2415943	   	   g_notif_not_sent := g_notif_not_sent || l_new_line || 'RS_EMPLOYEE = ' || to_char(p_old_owner_id);
		   g_notif_not_sent := g_notif_not_sent || l_new_line || p_old_owner_type_code || ' = ' || to_char(p_old_owner_id);
		end if;
	end if;
end if;

end if;

--Bug 2415943 Include Old Owner only if old_owner_type_code is RS_EMPLOYEE End

-------------------------------------------------------------------------
-- Include the Employee Contacts in the Notification List
-------------------------------------------------------------------------

For emp_rec in c_emp_contacts Loop
	l_role_name := NULL;

   if emp_rec.contact_id is not null then

	wf_directory.GetUserName
     	('PER',
      	emp_rec.contact_id,
      	l_role_name,
      	l_display_name);

	if l_role_name is not NULL then

	   include_role(l_role_name,
		     	l_temp_status);

	else open  get_employee_name(emp_rec.contact_id);
	     fetch get_employee_name into l_name;
	     close get_employee_name;

	     if l_name is not NULL then
		g_notif_not_sent := g_notif_not_sent || l_new_line || l_name;
             else
	   	g_notif_not_sent := g_notif_not_sent || l_new_line || 'PERSON_ID = '|| to_char(emp_rec.contact_id);
	     end if;
        end if;

   end if;

End Loop;

-------------------------------------------------------------------------
-- Include the External Contacts in the Notification List
-------------------------------------------------------------------------

For ext_rec in c_ext_contact_details Loop
	l_role_name := NULL;

	if ext_rec.contact_id is not null then
		wf_directory.GetUserName
     		('HZ_PARTY',
      		 ext_rec.contact_id,
      		 l_role_name,
      		 l_display_name);
	end if;

	if l_role_name is not NULL then

		include_role(l_role_name,
		     	     l_temp_status);
	elsif ext_rec.contact_name is not null then
		g_notif_not_sent := g_notif_not_sent|| l_new_line || ext_rec.contact_name;
	elsif ext_rec.contact_id is not null then
	  g_notif_not_sent := g_notif_not_sent|| l_new_line || 'CONTACT_ID = '|| to_char(ext_rec.contact_id);
	end if;

End Loop;


EXCEPTION

WHEN OTHERS THEN

	x_return_status := fnd_api.g_ret_sts_unexp_error;

	if 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	then
    	    	FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		l_api_name
	    		);
	end if;

END SetNotifList;

-------------------------------------------------------------------------
-- Set up the necessary data and Start the WF Notification Process
-------------------------------------------------------------------------

PROCEDURE Start_Resc_Workflow(
      p_api_version         	IN	NUMBER,
      p_init_msg_list       	IN	VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit              	IN	VARCHAR2 DEFAULT fnd_api.g_false,
      x_return_status       	OUT NOCOPY     VARCHAR2,
      x_msg_count           	OUT NOCOPY     NUMBER,
      x_msg_data            	OUT NOCOPY     VARCHAR2,
      p_task_id	      		IN 	NUMBER,
      p_doc_created             IN      VARCHAR2	:= FND_API.G_MISS_CHAR,
      p_owner_changed		IN      VARCHAR2	:= FND_API.G_MISS_CHAR,
      p_owner_type_changed      IN      VARCHAR2        := FND_API.G_MISS_CHAR,
      p_level_changed		IN      VARCHAR2	:= FND_API.G_MISS_CHAR,
      p_status_changed		IN      VARCHAR2	:= FND_API.G_MISS_CHAR,
      p_target_date_changed	IN      VARCHAR2	:= FND_API.G_MISS_CHAR,
      p_old_owner_id        	IN      NUMBER 		:= FND_API.G_MISS_NUM,
      p_old_owner_type_code     IN      VARCHAR2        := FND_API.G_MISS_CHAR,
      p_old_level       	IN      VARCHAR2 	:= FND_API.G_MISS_CHAR,
      p_old_status_id		IN      NUMBER	 	:= FND_API.G_MISS_NUM,
      p_old_target_date		IN	DATE 		:= FND_API.G_MISS_DATE,
      p_wf_process_name         IN      VARCHAR2 	DEFAULT	'ESC_NOTIF_PROCESS',
      p_wf_item_type_name       IN      VARCHAR2 	DEFAULT 'JTFEC',
      x_notif_not_sent		OUT NOCOPY	VARCHAR2,
      x_wf_process_id		OUT NOCOPY	NUMBER

   ) IS

task_details_rec	task_details_rec_type;

l_api_version     	CONSTANT NUMBER 	:= 1.0;
l_api_name		CONSTANT VARCHAR2(30)   := 'Start_Resc_Workflow';
l_itemkey               wf_item_activity_statuses.item_key%TYPE;
l_wf_key     		NUMBER;
l_old_owner_id		jtf_tasks_vl.owner_id%TYPE := p_old_owner_id;
--l_old_owner_type_code	jtf_tasks_vl.owner_type_code%TYPE := p_old_owner_type_code;
l_user_name		per_people_f.full_name%TYPE;
l_esc_status		jtf_ec_statuses_vl.description%TYPE;
l_esc_level		fnd_lookups.meaning%TYPE;
l_temp_status		VARCHAR2(1);
-- l_found			VARCHAR2(1) := 'x';
l_counter		NUMBER(5);
l_customer_name		hz_parties.party_name%TYPE := NULL;
l_event			VARCHAR2(50) DEFAULT NULL;
l_doc_number		jtf_task_references_vl.object_name%TYPE;
l_owner_name		VARCHAR2(200);
l_doc_type		jtf_objects_vl.name%TYPE;
l_doc_details_t		VARCHAR2(4000);
l_doc_details_h		VARCHAR2(4000);
l_notif_type		VARCHAR2(1) := 'N';
l_owner_changed		VARCHAR2(1):= 'N';
l_level_changed		VARCHAR2(1):= 'N';
l_status_changed	VARCHAR2(1):= 'N';
l_target_date_changed	VARCHAR2(1):= 'N';
l_new_line		VARCHAR2(4):= '
';  -- this is a new line. Do not touch.
l_errname varchar2(60);
l_errmsg varchar2(2000);
l_errstack varchar2(4000);



-------------------------------------------------------------------------
-- Generate the unique WF process itemkey
-------------------------------------------------------------------------
cursor	c_wf_key is
SELECT  jtf_task_workflow_process_s.nextval
FROM	dual;

-------------------------------------------------------------------------
-- Get esc document details
-------------------------------------------------------------------------

cursor	resc_task_details is
SELECT 	t.task_name,
	t.task_number,
	t.description,
	t.owner_type_code 	owner_code,
	t.owner_id,
	t.escalation_level,
	t.task_status_id,
	t.planned_end_date 	target_date,
	t.creation_date		date_opened,
	t.last_update_date	date_changed,
	t.last_updated_by		update_id,
	t.created_by		create_id
FROM 	jtf_tasks_vl		t,
	jtf_task_types_vl	tt
WHERE 	t.task_id = p_task_id
AND	t.task_type_id = tt.task_type_id
AND	tt.task_type_id = 22;

-------------------------------------------------------------------------
-- Get customer name
-------------------------------------------------------------------------
cursor 	c_cust_name is
SELECT 	p.party_name	customer_name
FROM   	jtf_tasks_vl	t,
	hz_parties	p
WHERE	t.task_id = p_task_id
AND	t.customer_id = p.party_id;

-------------------------------------------------------------------------
-- Get the status
-------------------------------------------------------------------------

cursor	c_esc_status(p_status_id in NUMBER) is
SELECT  name
FROM	jtf_ec_statuses_vl
WHERE 	task_status_id = p_status_id;

-------------------------------------------------------------------------
-- Get the escalation level
-------------------------------------------------------------------------

cursor 	c_esc_level (p_level in VARCHAR2) is
SELECT	meaning
FROM	fnd_lookups
WHERE 	lookup_code = p_level
AND	lookup_type = 'JTF_TASK_ESC_LEVEL'
AND	enabled_flag = 'Y'
AND	start_date_active < sysdate
AND	nvl(end_date_active, sysdate) >= sysdate;

-------------------------------------------------------------------------
-- Get the old escalation level
-------------------------------------------------------------------------

cursor 	c_esc_old_level (p_level in VARCHAR2) is
SELECT	meaning
FROM	fnd_lookups
WHERE 	lookup_code = p_level
AND	lookup_type = 'JTF_TASK_ESC_LEVEL';

-------------------------------------------------------------------------
-- Get the escalated documents
-------------------------------------------------------------------------

cursor	c_esc_documents is
SELECT 	object_name
FROM   	jtf_task_references_vl
WHERE  	task_id = p_task_id
AND	reference_code = 'ESC';


BEGIN

SAVEPOINT	Start_Resc_Workflow;

-- Standard call to check for call compatibility.


IF NOT FND_API.Compatible_API_Call ( 	l_api_version,
           	    	    	 	p_api_version,
    	    	    	    	    	l_api_name,
			    	    	G_PKG_NAME)
THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- Check p_init_msg_list


IF FND_API.To_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
END IF;

	--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;


-------------------------------------------------------------------------
-- parameters validation
-------------------------------------------------------------------------

-- task_id

open resc_task_details;
fetch resc_task_details into 	task_details_rec;

if resc_task_details%NOTFOUND then
	close resc_task_details;
	fnd_message.set_name ('JTF', 'JTF_EC_TASK_NOT_FOUND');
        fnd_message.set_token ('TASK_ID', p_task_id);
	    -- Add message to API message list.
	fnd_msg_pub.Add;
	raise fnd_api.g_exc_error;
end if;
	close resc_task_details;

-- event validation

	if 	(p_doc_created <> 'Y')
	   AND 	(p_level_changed <> 'Y')
	   AND 	(p_status_changed <> 'Y')
	   AND 	(p_owner_changed <> 'Y')
	   AND	(p_target_date_changed <> 'Y')
	then
          	fnd_message.set_name ('JTF', 'JTF_EC_INVALID_EVENT');
          	fnd_msg_pub.add;
          	RAISE fnd_api.g_exc_error;
	end if;

	if (p_level_changed = 'Y') AND (p_old_level = FND_API.G_MISS_CHAR) then
          fnd_message.set_name ('JTF', 'JTF_EC_OLD_LEVEL');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
	end if;

	if ((p_owner_changed  = 'Y') AND (p_old_owner_id = FND_API.G_MISS_NUM)) then
          fnd_message.set_name ('JTF', 'JTF_EC_OLD_OWNER');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
	end if;

	if (p_status_changed = 'Y') AND (p_old_status_id = FND_API.G_MISS_NUM) then
          fnd_message.set_name ('JTF', 'JTF_EC_OLD_STATUS');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
	end if;

	if (p_target_date_changed = 'Y') AND (p_old_target_date = FND_API.G_MISS_DATE) 		then
          fnd_message.set_name ('JTF', 'JTF_EC_OLD_TARGET');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
	end if;

      l_owner_changed 	:= p_owner_changed;
      l_level_changed	:= p_level_changed;
      l_status_changed	:= p_status_changed;
      l_target_date_changed	:= p_target_date_changed;

-------------------------------------------------------------------------
-- initialize the table with the performer details
-------------------------------------------------------------------------

JTF_EC_WORKFLOW_PKG.NotifList.Delete; -- := JTF_EC_WORKFLOW_PKG.G_Miss_NotifList;

g_notif_not_sent := NULL;

-------------------------------------------------------------------------
-- create itemkey for the WF process
-------------------------------------------------------------------------

      open 	c_wf_key;
      fetch 	c_wf_key into l_wf_key;
      close 	c_wf_key;
      l_itemkey := to_char(p_task_id) || to_char(l_wf_key);
      x_wf_process_id := l_itemkey;


      wf_engine.CreateProcess (
         itemtype 	=> p_wf_item_type_name,
         itemkey 	=> l_itemkey,
         process	=> p_wf_process_name
      );

      wf_engine.SetItemUserKey (
         itemtype 	=> p_wf_item_type_name,
         itemkey 	=> l_itemkey,
         userkey 	=> task_details_rec.task_name
      );

     wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'TASK_NUMBER',
         avalue => task_details_rec.task_number
      );

      wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'TASK_DESC',
         avalue => task_details_rec.description
      );

	open c_esc_status(task_details_rec.task_status_id);
	fetch c_esc_status into l_esc_status;
        close c_esc_status;

      wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'ESC_STATUS',
         avalue => l_esc_status
      );

	open  c_esc_level(task_details_rec.escalation_level);
	fetch c_esc_level into l_esc_level;
        close c_esc_level;

      wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'ESC_LEVEL',
         avalue => l_esc_level
      );

	open c_cust_name;
	fetch c_cust_name into l_customer_name;
	close c_cust_name;

      wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'CUST_NAME',
         avalue => l_customer_name
      );

      wf_engine.SetItemAttrDate (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'DATE_OPENED',
         avalue => task_details_rec.date_opened
      );

      wf_engine.SetItemAttrDate (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'DATE_CHANGED',
         avalue => task_details_rec.date_changed
      );

-- get the name of the user who created the document

      get_user_name(task_details_rec.create_id,
		    l_user_name,
		    l_temp_status);

      wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'CREATE_NAME',
         avalue => l_user_name
      );

-- get the name of the user who made the changes

      get_user_name(task_details_rec.update_id,
		l_user_name,
		l_temp_status);

      wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'CHANGE_NAME',
         avalue => l_user_name
      );

      wf_engine.SetItemAttrDate (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'TARGET_DATE',
         avalue => task_details_rec.target_date
      );


--Bug 241593 l_owner_name :=	get_resource_name('RS_EMPLOYEE', task_details_rec.owner_id);

l_owner_name := get_resource_name(task_details_rec.owner_code, task_details_rec.owner_id);

if  l_owner_name is NULL then

	if fnd_msg_pub.check_msg_level( fnd_msg_pub.g_msg_lvl_debug_medium ) then
   	 fnd_message.set_name ('JTF', 'JTF_EC_ERROR');
   	 fnd_msg_pub.Add;
	 RAISE fnd_api.g_exc_error;
	end if;

end if;


      wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'OWNER_NAME',
         avalue => l_owner_name
      );

      wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'OWNER_NAME_C',
         avalue => l_owner_name
      );

-------------------------------------------------------------------------
-- Find out whether this is a single or multiple document escalation
-------------------------------------------------------------------------

for 	c_esc_doc_r in c_esc_documents LOOP
	if c_esc_documents%ROWCOUNT = 1 then
		l_notif_type := 'S';
	end if;
	if c_esc_documents%ROWCOUNT = 2 then
		l_notif_type := 'M';
		exit;
	end if;
end LOOP;

l_owner_name := NULL;

get_doc_details(p_task_id => p_task_id,
		x_doc_type => l_doc_type,
		x_doc_number => l_doc_number,
		x_doc_owner_name => l_owner_name,
		x_doc_details_t => l_doc_details_t,
		x_doc_details_h => l_doc_details_h,
		x_return_status => l_temp_status);

if (l_temp_status <> FND_API.G_RET_STS_SUCCESS) then

	if fnd_msg_pub.check_msg_level( fnd_msg_pub.g_msg_lvl_debug_medium ) then
   	 fnd_message.set_name ('JTF', 'JTF_EC_ERROR');
   	 fnd_msg_pub.Add;
	 RAISE fnd_api.g_exc_error;
	end if;

end if;



if (p_doc_created = 'Y') then  -- new esc document is created

-- do not process changes if there are some requests
      l_owner_changed 	:= 'N';
      l_level_changed	:= 'N';
      l_status_changed	:= 'N';
      l_target_date_changed	:= 'N';
      l_old_owner_id	:= FND_API.G_MISS_NUM;

   if 	(l_notif_type = 'S') then
	l_event := 'ESC_DOC_CREATED_S';
   else 			-- multi document + no documents
	l_event := 'ESC_DOC_CREATED_M';
   end if;

else  -- attribute(s) (status, level, owner, target date) has/have changed

   if (l_notif_type = 'S') then  	-- single document
	l_event := 'ESC_DOC_CHANGED_S';
   else 		 		-- multi document + no documents
	l_event := 'ESC_DOC_CHANGED_M';
   end if;

end if;

      wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'EVENT',
         avalue => l_event
      );

-- Set the document owner attributes


if (l_notif_type = 'S') then  		-- for single doc escalation

      wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'DOC_TYPE',
         avalue => l_doc_type
      );

      wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'DOC_NUMBER',
         avalue => l_doc_number
      );

      wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'DOC_OWNER',
         avalue => l_owner_name
      );
else					-- for multi doc escalation
	 wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'DOC_DETAILS_T',
         avalue => l_doc_details_t
      );
	 wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'DOC_DETAILS_H',
         avalue => l_doc_details_h
      );
end if;

-------------------------------------------------------------------------
-- Initialize the new line attributes needed for the notification layout
-------------------------------------------------------------------------

init_new_lines(p_wf_item_type_name,l_itemkey);

-------------------------------------------------------------------------
-- The Owner is Changed Event
-------------------------------------------------------------------------

if p_owner_changed = 'Y' then

-- get previous owner details

 l_owner_name := NULL;

--Bug 2415943 l_owner_name := get_resource_name('RS_EMPLOYEE', p_old_owner_id);

l_owner_name := get_resource_name(p_old_owner_type_code, p_old_owner_id);


      	wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'OWNER_NAME_OLD',
         avalue => l_owner_name
      );
      	wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'NLTO',
         avalue => l_new_line
        );


elsif  p_doc_created <> 'Y' then -- set the owner line of WF notification to NULL

        l_old_owner_id	:= FND_API.G_MISS_NUM;
	hide_owner_line(p_wf_item_type_name,l_itemkey);

end if;

-------------------------------------------------------------------------
-- Status is Changed Event
-------------------------------------------------------------------------

if p_status_changed = 'Y' then

-- get previous status

	open c_esc_status(p_old_status_id);
	fetch c_esc_status into l_esc_status;

	if c_esc_status%NOTFOUND then
		close c_esc_status;
		if fnd_msg_pub.check_msg_level( fnd_msg_pub.g_msg_lvl_debug_medium ) then
   	 	  fnd_message.set_name ('JTF', 'JTF_EC_ERROR');
   	 	  fnd_msg_pub.Add;
	 	  RAISE fnd_api.g_exc_error;
		end if;
	end if;

	close c_esc_status;

      	wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'ESC_STATUS_OLD',
         avalue => l_esc_status
      	);
      	wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'NLTS',
         avalue => l_new_line
        );
elsif  p_doc_created <> 'Y' then  -- set the staus line of WF notification to NULL

	hide_status_line(p_wf_item_type_name,l_itemkey);

end if;
-------------------------------------------------------------------------
-- Level is Changed Event
-------------------------------------------------------------------------

if p_level_changed = 'Y' then

-- get the previous level
/*
	open c_esc_level(p_old_level);
	fetch c_esc_level into l_esc_level;
	if c_esc_level%NOTFOUND then
		close c_esc_level;
		if fnd_msg_pub.check_msg_level( fnd_msg_pub.g_msg_lvl_debug_medium ) then
   	 	  fnd_message.set_name ('JTF', 'JTF_EC_ERROR');
   	 	  fnd_msg_pub.Add;
	 	  RAISE fnd_api.g_exc_error;
		end if;
	end if;
	close c_esc_level;
*/
	open c_esc_old_level(p_old_level);
	fetch c_esc_old_level into l_esc_level;
	if c_esc_old_level%NOTFOUND then
		close c_esc_old_level;
		if fnd_msg_pub.check_msg_level( fnd_msg_pub.g_msg_lvl_debug_medium ) then
   	 	  fnd_message.set_name ('JTF', 'JTF_EC_ERROR');
   	 	  fnd_msg_pub.Add;
	 	  RAISE fnd_api.g_exc_error;
		end if;
	end if;
	close c_esc_old_level;

      	wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'ESC_LEVEL_OLD',
         avalue => l_esc_level
      	);

      	wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'NLTL',
         avalue => l_new_line
        );

elsif  p_doc_created <> 'Y' then -- set the level line of WF notification to NULL

	hide_level_line(p_wf_item_type_name,l_itemkey);

end if;

-------------------------------------------------------------------------
-- Target Date is Changed Event
-------------------------------------------------------------------------

if p_target_date_changed = 'Y' then

      	wf_engine.SetItemAttrDate (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'TARGET_DATE_OLD',
         avalue => p_old_target_date
      	);
      	wf_engine.SetItemAttrText (
         itemtype => p_wf_item_type_name,
         itemkey => l_itemkey,
         aname => 'NLTD',
         avalue => l_new_line
        );

elsif	p_doc_created <> 'Y' 	then

	hide_target_line(p_wf_item_type_name,l_itemkey);

end if;


-------------------------------------------------------------------------
-- Set the Notification List
-------------------------------------------------------------------------

    		SetNotifList(
		p_task_id	=> p_task_id,
		p_owner_id	=> task_details_rec.owner_id,
		p_old_owner_id  => l_old_owner_id,
		p_owner_type_code => task_details_rec.owner_code,
		p_old_owner_type_code => p_old_owner_type_code,
		x_row_number 	=> l_counter,
		x_return_status   => l_temp_status);

-------------------------------------------------------------------------
-- Set the process counters
-------------------------------------------------------------------------

l_counter := jtf_ec_workflow_pkg.NotifList.COUNT;

           wf_engine.SetItemAttrNumber(
         		itemtype => p_wf_item_type_name,
         		itemkey => l_itemkey,
         		aname 	=> 'LIST_COUNTER',
         		avalue 	=> 1
      			);

            wf_engine.SetItemAttrNumber(
         		itemtype => p_wf_item_type_name,
         		itemkey => l_itemkey,
         		aname 	=> 'PERFORMER_LIMIT',
         		avalue 	=> l_counter
      			);

 WF_ENGINE.StartProcess
 (
  itemtype => p_wf_item_type_name,
  itemkey => l_itemkey
 );

	 update jtf_tasks_b
         set workflow_process_id = l_itemkey
         where task_id = p_task_id;

	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	 x_notif_not_sent := g_notif_not_sent;

	fnd_msg_pub.count_and_get
    	(  	p_count	=>      x_msg_count,
        	p_data 	=>	x_msg_data
    	);

EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
	ROLLBACK TO Start_Resc_Workflow;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
            );

WHEN 	fnd_api.g_exc_unexpected_error
THEN
        ROLLBACK TO Start_Resc_Workflow;

	-- get the WF error stack
	wf_core.get_error(l_errname, l_errmsg, l_errstack);

    	-- If no wf error look for a native Oracle error

    	if ((l_errname is null) and (sqlcode <> 0)) then
      	  l_errname := to_char(sqlcode);
      	  l_errmsg := sqlerrm;
    	end if;

	if (l_errname is not null) then
       	  fnd_message.set_name('FND', 'WF_ERROR');
       	  fnd_message.set_token('ERROR_MESSAGE', l_errmsg);
	  fnd_message.set_token('ERROR_STACK', l_errstack);
	  fnd_msg_pub.add;
	end if;

        x_return_status := fnd_api.g_ret_sts_unexp_error;
	FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		l_api_name
	    		);
        fnd_msg_pub.count_and_get (
				   p_count => x_msg_count,
				   p_data => x_msg_data
				   );

WHEN OTHERS
THEN
        ROLLBACK TO Start_Resc_Workflow;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	if 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	then
    	    	FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		l_api_name
	    		);
	end if;

        fnd_msg_pub.count_and_get (
				   p_count => x_msg_count,
				   p_data => x_msg_data
				   );
END Start_Resc_Workflow;

PROCEDURE Check_Event(
      itemtype    	IN       VARCHAR2,
      itemkey     	IN       VARCHAR2,
      actid       	IN       NUMBER,
      funcmode    	IN       VARCHAR2,
      resultout   	OUT NOCOPY      VARCHAR2
      ) IS

      l_resultout   VARCHAR2(200);

BEGIN
      --
      -- RUN mode - normal process execution
      --

     if (funcmode = 'RUN')  then
         --
         -- Return process to run
         --

         l_resultout :=
            wf_engine.GetItemAttrText (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'EVENT'
             );

         resultout := 'COMPLETE:' || l_resultout;
         return;
      end if;

      --
      -- CANCEL mode - activity 'compensation'
      --
      if  (funcmode = 'CANCEL') then
         --
         -- Return process to run
         --
         resultout := 'COMPLETE';
         return;
      end if;

      --
      -- TIMEOUT mode
      --
      if (funcmode = 'TIMEOUT') then
         resultout := 'COMPLETE';
         return;
     end if;
   --
exception
      when others then

         wf_core.context (
          G_PKG_NAME,
         'Check_Event',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode
         );

         raise;

END Check_Event;

PROCEDURE Set_Notif_Message(
      itemtype    	IN       VARCHAR2,
      itemkey     	IN       VARCHAR2,
      actid       	IN       NUMBER,
      funcmode    	IN       VARCHAR2,
      resultout   	OUT NOCOPY      VARCHAR2
      ) IS

      l_event   	VARCHAR2(200);


BEGIN
      --
      -- RUN mode - normal process execution
      --
     if (funcmode = 'RUN')  then
         --
         -- Return process to run
         --
         l_event :=
            wf_engine.GetItemAttrText (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'EVENT'
             );

      if l_event = 'ESC_DOC_CREATED_S' then
		  wf_engine.SetItemAttrText (
                  itemtype => itemtype,
         	  itemkey => itemkey,
        	  aname => 'MESSAGE_NAME',
         	  avalue => 'MSG_ESC_DOC_CREATED_S'
     	 	);

      elsif  	l_event = 'ESC_DOC_CREATED_M' then
		 wf_engine.SetItemAttrText (
                 itemtype =>  itemtype,
         	 itemkey => itemkey,
        	 aname => 'MESSAGE_NAME',
         	 avalue => 'MSG_ESC_DOC_CREATED_M'
     	 	);

      elsif  	l_event = 'ESC_DOC_CHANGED_S' then
		 wf_engine.SetItemAttrText (
                 itemtype =>  itemtype,
         	 itemkey => itemkey,
        	 aname => 'MESSAGE_NAME',
         	 avalue => 'MSG_ESC_DOC_CHANGED_S'
     	 	);

      elsif  	l_event = 'ESC_DOC_CHANGED_M' then
		 wf_engine.SetItemAttrText (
                 itemtype =>  itemtype,
         	 itemkey => itemkey,
        	 aname => 'MESSAGE_NAME',
         	 avalue => 'MSG_ESC_DOC_CHANGED_M'
     	 	);
      end if;

        resultout := 'COMPLETE';
        return;
      end if;

      --
      -- CANCEL mode - activity 'compensation'
      --
      if  (funcmode = 'CANCEL') then
         --
         -- Return process to run
         --
         resultout := 'COMPLETE';
         return;
      end if;

      --
      -- TIMEOUT mode
      --
      if (funcmode = 'TIMEOUT') then
         resultout := 'COMPLETE';
         return;
     end if;
   --
exception
      when others then

         wf_core.context (
          G_PKG_NAME,
         'Set_Notif_Message',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode
         );

         raise;

END Set_Notif_Message;



PROCEDURE Set_Notif_Performer(
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
      ) IS

      l_counter   	BINARY_INTEGER;
      l_role		wf_roles.name%TYPE;

BEGIN
      --
      -- RUN mode - normal process execution
      --
     if (funcmode = 'RUN')  then
         --
         -- Return process to run
         --

	l_counter := 	wf_engine.GetItemAttrNumber(
         		itemtype => itemtype,
         		itemkey => itemkey,
         		aname => 'LIST_COUNTER'
         		);

	l_role := jtf_ec_workflow_pkg.NotifList(l_counter).Name;

	if l_role is not NULL then

	      	wf_engine.SetItemAttrText(
         		itemtype => itemtype,
         		itemkey => itemkey,
         		aname => 'MESSAGE_RECIPIENT',
         		avalue => l_role
      			);
	end if;

	l_counter := l_counter + 1;

            	wf_engine.SetItemAttrNumber(
         		itemtype => itemtype,
         		itemkey => itemkey,
         		aname => 'LIST_COUNTER',
         		avalue => l_counter
      			);

         resultout := 'COMPLETE';
         return;

      end if;

      --
      -- CANCEL mode - activity 'compensation'
      --
      if  (funcmode = 'CANCEL') then
         --
         -- Return process to run
         --
         resultout := 'COMPLETE';
         return;
      end if;

      --
      -- TIMEOUT mode
      --
      if (funcmode = 'TIMEOUT') then
         resultout := 'COMPLETE';
         return;
     end if;
   --
exception
      when others then
         wf_core.context (
          G_PKG_NAME,
         'Set_Notif_Performer',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode
         );

         raise;

END Set_Notif_Performer;

--Start of code for ER 7032664

PROCEDURE Raise_Esc_Create_Event(P_TASK_ID IN NUMBER)
IS
   l_list                   WF_PARAMETER_LIST_T;
   l_key                    varchar2(240);
   l_event_name             varchar2(240) := 'oracle.apps.jtf.cac.esc.createEscalation';
   l_task_id                number := p_task_id;

  BEGIN
    --Get the item key
    l_list := NULL;
    SELECT l_event_name ||'-'|| jtf_ec_wf_events_s.nextval INTO l_key FROM DUAL;
    wf_event.addparametertolist ('TASK_ID', to_char(l_task_id), l_list);

    -- Raise the create task event
    wf_event.raise3(
                               p_event_name        => l_event_name,
                               p_event_key         => l_key,
                               p_parameter_list    => l_list,
                               p_send_date         => sysdate
                  );
    l_list.DELETE;
  END Raise_Esc_Create_Event;


PROCEDURE Raise_Esc_Update_Event(P_ESC_REC IN   JTF_EC_WORKFLOW_PKG.esc_rec_type)
IS
   l_list                   WF_PARAMETER_LIST_T;
   l_key                    varchar2(240);
   l_event_name             varchar2(240) := 'oracle.apps.jtf.cac.esc.updateEscalation';
   l_esc_rec                JTF_EC_WORKFLOW_PKG.esc_rec_type := p_esc_rec;

  BEGIN
    --Get the item key
    l_list := NULL;
    SELECT l_event_name ||'-'|| jtf_ec_wf_events_s.nextval INTO l_key FROM DUAL;

    wf_event.addparametertolist ('TASK_ID', to_char(l_esc_rec.task_id), l_list);
    wf_event.addparametertolist ('DOC_CREATED', l_esc_rec.doc_created, l_list);
    wf_event.addparametertolist ('OWNER_CHANGED', l_esc_rec.owner_changed, l_list);
    wf_event.addparametertolist ('OWNER_TYPE_CHANGED', l_esc_rec.owner_type_changed, l_list);
    wf_event.addparametertolist ('LEVEL_CHANGED', l_esc_rec.level_changed, l_list);
    wf_event.addparametertolist ('STATUS_CHANGED', l_esc_rec.status_changed, l_list);
    wf_event.addparametertolist ('TARGET_DATE_CHANGED', l_esc_rec.target_date_changed, l_list);
    wf_event.addparametertolist ('OLD_OWNER_ID', to_char(l_esc_rec.old_owner_id), l_list);
    wf_event.addparametertolist ('OLD_OWNER_TYPE_CODE', l_esc_rec.old_owner_type_code, l_list);
    wf_event.addparametertolist ('OLD_LEVEL', l_esc_rec.old_level, l_list);
    wf_event.addparametertolist ('OLD_STATUS_ID', to_char(l_esc_rec.old_status_id), l_list);
    wf_event.addparametertolist ('OLD_TARGET_DATE', to_char(l_esc_rec.old_target_date,'YYYY-MM-DD HH24:MI:SS'), l_list);

    -- Raise the create task event
    wf_event.raise3(           p_event_name        => l_event_name,
                               p_event_key         => l_key,
                               p_parameter_list    => l_list,
                               p_send_date         => sysdate
                  );
    l_list.DELETE;
  END Raise_Esc_Update_Event;


FUNCTION create_esc_notif_subs(p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t)
RETURN VARCHAR2 IS
    l_task_id                 jtf_tasks_b.task_id%TYPE;
    l_wf_process_id           NUMBER;
    l_notif_not_sent          VARCHAR2(1000);
    x_return_status           VARCHAR2(200);
    x_msg_count               NUMBER;
    x_msg_data                VARCHAR2(1000);

  BEGIN
    l_task_id          := wf_event.getvalueforparameter('TASK_ID', p_event.parameter_list);

    Start_Resc_Workflow(
          P_API_VERSION             =>1.0,
          P_INIT_MSG_LIST           =>'T',
          P_COMMIT                  =>'T',
          X_RETURN_STATUS           =>x_return_status,
          X_MSG_COUNT               =>x_msg_count,
          X_MSG_DATA                =>x_msg_data,
          P_TASK_ID                 =>l_task_id,
          P_DOC_CREATED             =>'Y',
          P_OWNER_CHANGED           =>'N',
          P_OWNER_TYPE_CHANGED      =>'N',
          P_LEVEL_CHANGED           =>'N',
          P_STATUS_CHANGED          =>'N',
          P_TARGET_DATE_CHANGED     =>'N',
          P_OLD_OWNER_ID            =>NULL,
          P_OLD_OWNER_TYPE_CODE     =>NULL,
          P_OLD_LEVEL               =>NULL,
          P_OLD_STATUS_ID           =>NULL,
          P_OLD_TARGET_DATE         =>NULL,
          x_notif_not_sent          =>l_notif_not_sent,
          X_WF_PROCESS_ID           =>l_wf_process_id);

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      wf_core.CONTEXT('jtf_ec_workflow_pkg', 'create_esc_notif_subs', p_event.event_name, p_subscription_guid);
      wf_event.seterrorinfo(p_event, 'WARNING');
      RETURN 'WARNING';
    END IF;

    RETURN 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.CONTEXT('jtf_ec_workflow_pkg', 'create_esc_notif_subs', p_event.event_name, p_subscription_guid);
      wf_event.seterrorinfo(p_event, 'WARNING');
      RETURN 'WARNING';
  END create_esc_notif_subs;



FUNCTION update_esc_notif_subs(p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t)
RETURN VARCHAR2 IS
    l_wf_process_id           NUMBER;
    l_notif_not_sent          VARCHAR2(1000);
    x_return_status           VARCHAR2(200);
    x_msg_count               NUMBER;
    x_msg_data                VARCHAR2(1000);

    l_esc_rec                JTF_EC_WORKFLOW_PKG.esc_rec_type;
  BEGIN
    l_esc_rec.task_id             := wf_event.getvalueforparameter('TASK_ID', p_event.parameter_list);
    l_esc_rec.doc_created         := wf_event.getvalueforparameter('DOC_CREATED', p_event.parameter_list);
    l_esc_rec.owner_changed       := wf_event.getvalueforparameter('OWNER_CHANGED', p_event.parameter_list);
    l_esc_rec.owner_type_changed  := wf_event.getvalueforparameter('OWNER_TYPE_CHANGED', p_event.parameter_list);
    l_esc_rec.level_changed       := wf_event.getvalueforparameter('LEVEL_CHANGED', p_event.parameter_list);
    l_esc_rec.status_changed      := wf_event.getvalueforparameter('STATUS_CHANGED', p_event.parameter_list);
    l_esc_rec.target_date_changed := wf_event.getvalueforparameter('TARGET_DATE_CHANGED', p_event.parameter_list);
    l_esc_rec.old_owner_id        := wf_event.getvalueforparameter('OLD_OWNER_ID', p_event.parameter_list);
    l_esc_rec.old_owner_type_code := wf_event.getvalueforparameter('OLD_OWNER_TYPE_CODE', p_event.parameter_list);
    l_esc_rec.old_level           := wf_event.getvalueforparameter('OLD_LEVEL', p_event.parameter_list);
    l_esc_rec.old_status_id       := wf_event.getvalueforparameter('OLD_STATUS_ID', p_event.parameter_list);
    l_esc_rec.old_target_date     := wf_event.getvalueforparameter('OLD_TARGET_DATE', p_event.parameter_list);

    Start_Resc_Workflow(
       P_API_VERSION             =>1.0,
       P_INIT_MSG_LIST           =>'T',
       P_COMMIT                  =>'T',
       X_RETURN_STATUS           =>x_return_status,
       X_MSG_COUNT               =>x_msg_count,
       X_MSG_DATA                =>x_msg_data,
       P_TASK_ID                 =>l_esc_rec.task_id,
       P_DOC_CREATED             =>l_esc_rec.doc_created,
       P_OWNER_CHANGED           =>l_esc_rec.owner_changed,
       P_OWNER_TYPE_CHANGED      =>l_esc_rec.owner_type_changed,
       P_LEVEL_CHANGED           =>l_esc_rec.level_changed,
       P_STATUS_CHANGED          =>l_esc_rec.status_changed,
       P_TARGET_DATE_CHANGED     =>l_esc_rec.target_date_changed,
       P_OLD_OWNER_ID            =>l_esc_rec.old_owner_id,
       P_OLD_OWNER_TYPE_CODE     =>l_esc_rec.old_owner_type_code,
       P_OLD_LEVEL               =>l_esc_rec.old_level,
       P_OLD_STATUS_ID           =>l_esc_rec.old_status_id,
       P_OLD_TARGET_DATE         =>l_esc_rec.old_target_date,
       x_notif_not_sent          =>l_notif_not_sent,
       X_WF_PROCESS_ID           =>l_wf_process_id);

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      wf_core.CONTEXT('jtf_ec_workflow_pkg', 'update_esc_notif_subs', p_event.event_name, p_subscription_guid);
      wf_event.seterrorinfo(p_event, 'WARNING');
      RETURN 'WARNING';
    END IF;

    RETURN 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.CONTEXT('jtf_ec_workflow_pkg', 'update_esc_notif_subs', p_event.event_name, p_subscription_guid);
      wf_event.seterrorinfo(p_event, 'WARNING');
      RETURN 'WARNING';
  END update_esc_notif_subs;

--End of code for ER 7032664

END JTF_EC_WORKFLOW_PKG;

/
