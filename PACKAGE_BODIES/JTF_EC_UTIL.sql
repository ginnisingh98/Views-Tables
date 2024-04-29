--------------------------------------------------------
--  DDL for Package Body JTF_EC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_EC_UTIL" as
/* $Header: jtfvecub.pls 115.8 2003/01/13 13:46:49 siyappan ship $ */

PROCEDURE Validate_Owner(
			 p_owner_id IN NUMBER,
			 p_owner_type IN VARCHAR2,
			 x_return_status OUT NOCOPY  VARCHAR2) Is

l_api_name varchar2(30) := 'Validate_Owner';

--Bug 2723761
x   CHAR;

      CURSOR c_object_code
      IS
     SELECT 1
       FROM jtf_objects_b
      WHERE object_code = p_owner_type
        AND trunc(NVL (end_date_active, SYSDATE)) >= trunc(SYSDATE)
        AND trunc(NVL (start_date_active, SYSDATE)) <= trunc(SYSDATE)
        AND (object_code IN
           (SELECT object_code
              FROM jtf_object_usages
             WHERE object_user_code = 'RESOURCES'));

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

    if p_owner_id is NULL or p_owner_id = fnd_api.g_miss_num then
	Add_Invalid_Argument_Msg(l_api_name, 'NULL','owner_id');
	raise fnd_api.g_exc_error;
--Bug 2723761
    end if;

    -- elsif p_owner_type <> jtf_ec_pub.g_escalation_owner_type_code then

    if p_owner_type is not NULL and p_owner_type <> fnd_api.g_miss_char then
     	OPEN c_object_code;
     	FETCH c_object_code INTO x;

     	IF c_object_code%NOTFOUND THEN
		Add_Invalid_Argument_Msg(l_api_name, p_owner_type, 'owner_type');
		raise fnd_api.g_exc_error;
     	END IF;
     	CLOSE c_object_code;
    else
--end changes
	Add_Invalid_Argument_Msg(l_api_name, 'NULL', 'owner_type');
	raise fnd_api.g_exc_error;
    end if;

EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
        x_return_status := fnd_api.g_ret_sts_error;

WHEN OTHERS THEN

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.ADD;

END Validate_Owner;

----------------------------------------------------------------------------------------
--- Validate_Requester
----------------------------------------------------------------------------------------

PROCEDURE Validate_Requester(p_escalation_id IN NUMBER,
			     x_return_status OUT NOCOPY  VARCHAR2) Is

l_api_name 	varchar2(30) := 'Validate_Requester';
l_dummy 	varchar2(2);


BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    	Select 'x' into l_dummy
    	From jtf_task_contacts
    	Where task_id = p_escalation_id
    	And  escalation_requester_flag = 'Y';

Exception
When no_data_found then
    	fnd_message.set_name ('JTF', 'JTF_EC_REQ_API_NULL');
	fnd_msg_pub.Add;
	x_return_status := fnd_api.g_ret_sts_error;
	FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		l_api_name
	    		);

When too_many_rows then
    	fnd_message.set_name ('JTF', 'JTF_TK_REQUESTER_FLAG');
	fnd_msg_pub.Add;
	x_return_status := fnd_api.g_ret_sts_error;
	FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		l_api_name
	    		);
When others then
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
       fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
       fnd_msg_pub.ADD;

	FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		l_api_name
	    		);

END Validate_Requester;



PROCEDURE Add_Invalid_Argument_Msg
( p_token_api_name	IN VARCHAR2,
  p_token_value		IN VARCHAR2,
  p_token_parameter	IN VARCHAR2
)

IS

BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    FND_MESSAGE.Set_Name('JTF','JTF_EC_API_INV_PARAMETER' );
    FND_MESSAGE.Set_Token('API_NAME',  p_token_api_name );
    FND_MESSAGE.Set_Token('VALUE', p_token_value );
    FND_MESSAGE.Set_Token('PARAMETER',p_token_parameter);
    FND_MSG_PUB.Add;
  END IF;
END Add_Invalid_Argument_Msg;


----------------------------------------------------------------------------------------
--- Validate_Requester
----------------------------------------------------------------------------------------
PROCEDURE Validate_Esc_Status (
        p_esc_status_id          IN       NUMBER,
        p_esc_status_name        IN       VARCHAR2,
        x_return_status          OUT NOCOPY       VARCHAR2,
        x_esc_status_id         OUT NOCOPY       NUMBER
    ) Is

l_api_name varchar2(61) := 'Validate_Esc_Status';

cursor 	c_esc_status_id (p_esc_status_id NUMBER) Is
SELECT 	task_status_id
FROM 	jtf_ec_statuses_vl
WHERE 	task_status_id = p_esc_status_id
AND 	NVL (start_date_active, sysdate) <= sysdate
AND 	NVL (end_date_active, sysdate) >= sysdate;

cursor 	c_esc_status_name (p_esc_status_name VARCHAR2) Is
SELECT 	task_status_id
FROM 	jtf_ec_statuses_vl
WHERE 	name = p_esc_status_name
AND 	NVL (start_date_active, sysdate) <= sysdate
AND 	NVL (end_date_active, sysdate) >= sysdate;



BEGIN

	x_return_status := fnd_api.g_ret_sts_success;

	if p_esc_status_id is not NULL and p_esc_status_id <> fnd_api.g_miss_num then
	   open c_esc_status_id(p_esc_status_id);
	   fetch c_esc_status_id into x_esc_status_id;
           if c_esc_status_id%NOTFOUND then
		close c_esc_status_id;
		Add_Invalid_Argument_Msg(l_api_name, to_char(p_esc_status_id), 'esc_status_id');
		raise fnd_api.g_exc_error;
	   end if;
	   close c_esc_status_id;

	   if p_esc_status_name <> fnd_api.g_miss_char then
		jtf_ec_util.add_param_ignored_msg(l_api_name, 'status_name');
	   end if;

	elsif p_esc_status_name is not NULL and  p_esc_status_name <> fnd_api.g_miss_char then
	   open c_esc_status_name(p_esc_status_name);
	   fetch c_esc_status_name into x_esc_status_id;
           if c_esc_status_name%NOTFOUND then
		close c_esc_status_name;
		Add_Invalid_Argument_Msg(l_api_name, p_esc_status_name, 'esc_status_name');
		raise fnd_api.g_exc_error;
	   end if;
	   close c_esc_status_name;
        elsif p_esc_status_name is NULL and p_esc_status_id is NULL then
		Add_Invalid_Argument_Msg(l_api_name, 'NULL', 'esc_status_id');
		Add_Invalid_Argument_Msg(l_api_name, 'NULL', 'esc_status_name');
		raise fnd_api.g_exc_error;
	else
		Add_Missing_Param_Msg(l_api_name, 'esc_status_id');
		Add_Missing_Param_Msg(l_api_name, 'esc_status_name');
		raise fnd_api.g_exc_error;
	end if;



EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
        x_return_status := fnd_api.g_ret_sts_error;

WHEN OTHERS THEN

	 x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.ADD;

END Validate_Esc_Status;


----------------------------------------------------------------------------------------
-- Validate Lookup
----------------------------------------------------------------------------------------

FUNCTION Validate_Lookup(p_lookup_type        IN VARCHAR2 ,
        		 p_lookup_code        IN VARCHAR2
        		 )RETURN BOOLEAN Is
l_temp	varchar2(1);

Cursor c_lookup Is
SELECT 	'x'
FROM	fnd_lookups
WHERE	lookup_type = p_lookup_type
AND	lookup_code = p_lookup_code
AND 	enabled_flag = 'Y'
AND 	nvl(start_date_active,sysdate) <= sysdate
AND	nvl(end_date_active, sysdate) >= sysdate;

BEGIN

	open c_lookup;
	fetch c_lookup into l_temp;
	if c_lookup%FOUND then
	   RETURN TRUE;
	else
	   RETURN FALSE;
	end if;

EXCEPTION
WHEN OTHERS THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.ADD;
	 RETURN FALSE;
END Validate_Lookup;


----------------------------------------------------------------------------------------
-- Add_Param_Ignored_Msg
----------------------------------------------------------------------------------------

PROCEDURE Add_Param_Ignored_Msg
( p_token_api_name		VARCHAR2,
  p_token_ignored_param		VARCHAR2
)
IS
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.Set_Name('JTF', 'JTF_EC_API_IGN_PARAMETER');
    FND_MESSAGE.Set_Token('API_NAME', p_token_api_name);
    FND_MESSAGE.Set_Token('IGNORED_PARAM', p_token_ignored_param);
    FND_MSG_PUB.Add;
  END IF;
END Add_Param_Ignored_Msg;


----------------------------------------------------------------------------------------
-- Add missing parameter procedure
----------------------------------------------------------------------------------------

PROCEDURE Add_Missing_Param_Msg
( p_token_api_name		VARCHAR2,
  p_token_miss_param		VARCHAR2
) Is

Begin

  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    FND_MESSAGE.Set_Name('JTF', 'JTF_EC_API_MISS_PARAMETER');
    FND_MESSAGE.Set_Token('API_NAME', p_token_api_name);
    FND_MESSAGE.Set_Token('MISSING_PARAM', p_token_miss_param);
    FND_MSG_PUB.Add;
  END IF;

END Add_Missing_Param_Msg;

----------------------------------------------------------------------------------------
-- Check_If_Escalated
----------------------------------------------------------------------------------------

FUNCTION  Check_If_Escalated (p_object_type_code IN VARCHAR2,
                              p_object_id IN NUMBER,
			      p_object_name IN VARCHAR2,
			      x_task_ref_id OUT NOCOPY  NUMBER) RETURN BOOLEAN Is


  cursor c_esc_doc_exists_id( P_OBJECT_TYPE_CODE  VARCHAR2,
                        P_OBJECT_ID    NUMBER) Is
  Select r.task_reference_id
  from   jtf_tasks_b             t,
         jtf_task_references_b   r,
         jtf_ec_statuses_vl      s
  where r.reference_code = 'ESC'
  and   r.object_id = p_object_id
  and   r.object_type_code = p_object_type_code
  and   r.task_id = t.task_id
  and   t.task_type_id = 22
  and   t.task_status_id = s.task_status_id
  and   nvl(s.completed_flag,'N') ='N'
  and   nvl(s.cancelled_flag,'N') = 'N'
  and   nvl(s.closed_flag, 'N') = 'N';

  cursor c_esc_doc_exists_name( P_OBJECT_TYPE_CODE  VARCHAR2,
                        	P_OBJECT_NAME    VARCHAR2) Is
  Select r.task_reference_id
  from   jtf_tasks_b             t,
         jtf_task_references_b   r,
         jtf_ec_statuses_vl      s
  where r.reference_code = 'ESC'
  and   r.object_name = p_object_name
  and   r.object_type_code = p_object_type_code
  and   t.task_type_id = 22
  and   r.task_id = t.task_id
  and   t.task_status_id = s.task_status_id
  and   nvl(s.completed_flag,'N') ='N'
  and   nvl(s.cancelled_flag,'N') = 'N'
  and   nvl(s.closed_flag, 'N') = 'N';


BEGIN


if  p_object_id is not NULL then
   open c_esc_doc_exists_id(p_object_type_code, p_object_id);
   fetch c_esc_doc_exists_id into x_task_ref_id;
   if c_esc_doc_exists_id%FOUND then
      close c_esc_doc_exists_id;
      RETURN TRUE;
   else
      close c_esc_doc_exists_id;
      RETURN FALSE;
   end if;
elsif p_object_name is not null then
   open c_esc_doc_exists_name(p_object_type_code, p_object_name);
   fetch c_esc_doc_exists_name into x_task_ref_id;
   if c_esc_doc_exists_name%FOUND then
      close c_esc_doc_exists_name;
      RETURN TRUE;
   else
      close c_esc_doc_exists_name;
      RETURN FALSE;
   end if;
else
      RETURN FALSE;
end if;

exception
when others then

         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.ADD;

	 RETURN FALSE;

END Check_If_Escalated;

FUNCTION  Reference_Duplicated (p_object_type_code IN VARCHAR2,
                               p_object_id IN NUMBER,
			       p_object_name IN VARCHAR2,
			       p_reference_code IN VARCHAR2,
			       p_escalation_id IN NUMBER) RETURN BOOLEAN Is


  cursor c_ref_doc_exists_id( P_OBJECT_TYPE_CODE  VARCHAR2,
                              P_OBJECT_ID    	  NUMBER,
			      P_REFERENCE_CODE	  VARCHAR2,
			      P_ESCALATION_ID 	  NUMBER) Is
  SELECT 'x'
  FROM   jtf_task_references_b
  WHERE  object_id = p_object_id
  AND   object_type_code =  p_object_type_code
  AND   task_id = p_escalation_id
  AND   reference_code = p_reference_code;


  cursor c_ref_doc_exists_name( P_OBJECT_TYPE_CODE  	VARCHAR2,
                        	P_OBJECT_NAME    	VARCHAR2,
			      	P_REFERENCE_CODE	VARCHAR2,
				P_ESCALATION_ID		NUMBER) Is
  SELECT 'x'
  FROM   jtf_task_references_b
  WHERE  object_name = p_object_name
  AND   object_type_code =  p_object_type_code
  AND   task_id = p_escalation_id
  AND   reference_code = p_reference_code;

  l_dummy 	varchar2(2) := NULL;


BEGIN


if  p_object_id is not NULL then
   open c_ref_doc_exists_id(p_object_type_code, p_object_id,p_reference_code, p_escalation_id);
   fetch c_ref_doc_exists_id into l_dummy;
   if c_ref_doc_exists_id%FOUND then
      close c_ref_doc_exists_id;
      RETURN TRUE;
   else
      close c_ref_doc_exists_id;
      RETURN FALSE;
   end if;
elsif p_object_name is not null then
   open c_ref_doc_exists_name(p_object_type_code, p_object_name,p_reference_code, p_escalation_id);
   fetch c_ref_doc_exists_name into l_dummy;
   if c_ref_doc_exists_name%FOUND then
      close c_ref_doc_exists_name;
      RETURN TRUE;
   else
      close c_ref_doc_exists_name;
      RETURN FALSE;
   end if;
else
      RETURN FALSE;
end if;

exception
when others then

         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.ADD;

	 RETURN FALSE;

END Reference_Duplicated;

FUNCTION Contact_Duplicated(p_contact_id IN NUMBER,
			    p_contact_type_code IN VARCHAR2,
			    p_escalation_id IN NUMBER) RETURN BOOLEAN IS

cursor c_contact_exists(p_contact_id NUMBER,
			p_contact_type_code VARCHAR2,
			p_escalation_id NUMBER) Is
Select 'x'
from jtf_task_contacts
where task_id = p_escalation_id
and contact_id = p_contact_id
and contact_type_code = p_contact_type_code;

l_dummy 	varchar2(2);

BEGIN

open c_contact_exists(p_contact_id, p_contact_type_code, p_escalation_id);
fetch c_contact_exists into l_dummy;

if c_contact_exists%FOUND then
	RETURN TRUE;
else
	RETURN FALSE;
end if;

exception
when others then

         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.ADD;

	 RETURN FALSE;

END Contact_Duplicated;

PROCEDURE Validate_Desc_Flex
( p_api_name			IN	VARCHAR2,
  p_application_short_name	IN	VARCHAR2,
  p_desc_flex_name		IN	VARCHAR2,
  p_desc_segment1		IN	VARCHAR2,
  p_desc_segment2		IN	VARCHAR2,
  p_desc_segment3		IN	VARCHAR2,
  p_desc_segment4		IN	VARCHAR2,
  p_desc_segment5		IN	VARCHAR2,
  p_desc_segment6		IN	VARCHAR2,
  p_desc_segment7		IN	VARCHAR2,
  p_desc_segment8		IN	VARCHAR2,
  p_desc_segment9		IN	VARCHAR2,
  p_desc_segment10		IN	VARCHAR2,
  p_desc_segment11		IN	VARCHAR2,
  p_desc_segment12		IN	VARCHAR2,
  p_desc_segment13		IN	VARCHAR2,
  p_desc_segment14		IN	VARCHAR2,
  p_desc_segment15		IN	VARCHAR2,
  p_desc_context		IN	VARCHAR2,
  p_resp_appl_id		IN	NUMBER		:= NULL,
  p_resp_id			IN	NUMBER		:= NULL,
  x_return_status		OUT NOCOPY 	VARCHAR2
)
IS
  l_error_message	VARCHAR2(2000);

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF ( p_desc_context   || p_desc_segment1  || p_desc_segment2  ||
       p_desc_segment3  || p_desc_segment4  || p_desc_segment5  ||
       p_desc_segment6  || p_desc_segment7  || p_desc_segment8  ||
       p_desc_segment9  || p_desc_segment10 || p_desc_segment11 ||
       p_desc_segment12 || p_desc_segment13 || p_desc_segment14 ||
       p_desc_segment15
     ) IS NOT NULL THEN

    FND_FLEX_DESCVAL.Set_Context_Value(p_desc_context);
    FND_FLEX_DESCVAL.Set_Column_Value('ATTRIBUTE_1', p_desc_segment1);
    FND_FLEX_DESCVAL.Set_Column_Value('ATTRIBUTE_2', p_desc_segment2);
    FND_FLEX_DESCVAL.Set_Column_Value('ATTRIBUTE_3', p_desc_segment3);
    FND_FLEX_DESCVAL.Set_Column_Value('ATTRIBUTE_4', p_desc_segment4);
    FND_FLEX_DESCVAL.Set_Column_Value('ATTRIBUTE_5', p_desc_segment5);
    FND_FLEX_DESCVAL.Set_Column_Value('ATTRIBUTE_6', p_desc_segment6);
    FND_FLEX_DESCVAL.Set_Column_Value('ATTRIBUTE_7', p_desc_segment7);
    FND_FLEX_DESCVAL.Set_Column_Value('ATTRIBUTE_8', p_desc_segment8);
    FND_FLEX_DESCVAL.Set_Column_Value('ATTRIBUTE_9', p_desc_segment9);
    FND_FLEX_DESCVAL.Set_Column_Value('ATTRIBUTE_10', p_desc_segment10);
    FND_FLEX_DESCVAL.Set_Column_Value('ATTRIBUTE_11', p_desc_segment11);
    FND_FLEX_DESCVAL.Set_Column_Value('ATTRIBUTE_12', p_desc_segment12);
    FND_FLEX_DESCVAL.Set_Column_Value('ATTRIBUTE_13', p_desc_segment13);
    FND_FLEX_DESCVAL.Set_Column_Value('ATTRIBUTE_14', p_desc_segment14);
    FND_FLEX_DESCVAL.Set_Column_Value('ATTRIBUTE_15', p_desc_segment15);
    IF NOT FND_FLEX_DESCVAL.Validate_Desccols
             ( appl_short_name => p_application_short_name,
               desc_flex_name  => p_desc_flex_name,
               resp_appl_id    => p_resp_appl_id,
               resp_id         => p_resp_id
             ) THEN
      l_error_message := FND_FLEX_DESCVAL.Error_Message;
-- need to return a message
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

END Validate_Desc_Flex;

----------------------------------------------------------------------------------------
-- Validate Escalation Document
----------------------------------------------------------------------------------------

PROCEDURE Validate_Esc_Document(p_esc_id 	IN NUMBER,
				p_esc_number 	IN VARCHAR2,
				x_esc_id	OUT NOCOPY  NUMBER,
				x_return_status	OUT NOCOPY  VARCHAR2) Is

l_api_name 	VARCHAR2(30) := 'Valdate_Esc_Document';

cursor 	c_esc_id(p_escal_id NUMBER) Is
select 	task_id
from	jtf_tasks_b
where 	task_id = p_escal_id
and   	task_type_id = 22;

cursor 	c_esc_number(p_esc_number VARCHAR2) Is
select 	task_id
from	jtf_tasks_b
where 	task_number = p_esc_number
and   	task_type_id = 22;

l_esc_id	jtf_tasks_b.task_id%TYPE;

BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

if p_esc_id is not NULL then
	open c_esc_id(p_esc_id);
	fetch c_esc_id into l_esc_id;
	if c_esc_id%NOTFOUND then
		close c_esc_id;
		jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, p_esc_id, 'escalation_id');
                raise fnd_api.g_exc_error;
	end if;
	close c_esc_id;
elsif p_esc_number is not NULL then
	open c_esc_number(p_esc_number);
	fetch c_esc_number into l_esc_id;
	if c_esc_number%NOTFOUND then
		close c_esc_number;
		jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, p_esc_number, 'escalation_number');
                raise fnd_api.g_exc_error;
	end if;
	close c_esc_number;
else jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, 'NULL', 'p_esc_id');
     jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, 'NULL', 'p_esc_number');
end if;

	x_esc_id := l_esc_id;

EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
        x_return_status := fnd_api.g_ret_sts_error;

WHEN OTHERS THEN

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.ADD;

END Validate_Esc_Document;

----------------------------------------------------------------------------------------
-- Check whether the task can be closed. If it can sets the close_date to sysdate.
----------------------------------------------------------------------------------------

Procedure Check_Completed_Status(p_status_id	IN 	NUMBER,
				 p_esc_id	IN	NUMBER,
				 p_esc_level	IN	VARCHAR2,
				 x_closed_flag  OUT NOCOPY 	VARCHAR2,
			     	 x_return_status	OUT NOCOPY 	VARCHAR2) IS
l_api_name varchar2(30) := 'Check_Completed_Status';

cursor c_chk_completed (p_status_id  NUMBER) is
select 'x'
from jtf_ec_statuses_vl
where task_status_id = p_status_id
and   completed_flag = 'Y';


-- the escalation cannot be closed if there are open tasks for it with restrict_closure_flag = 'Y'

cursor c_chk_open_tasks(p_task_id NUMBER) Is
select 'x'
from  jtf_tasks_b t,
jtf_task_statuses_vl s
where t.source_object_id = p_task_id
and   t.source_object_type_code = 'ESC'
and   t.restrict_closure_flag = 'Y'
and   t.task_status_id = s.task_status_id
and   nvl(s.cancelled_flag, 'N') = 'N'
and   nvl(s.completed_flag, 'N') = 'N'
and   nvl(s.closed_flag, 'N') = 'N';

cursor c_get_esc_level(p_task_id NUMBER) Is
Select escalation_level
from jtf_tasks_b
where task_id = p_task_id;


l_dummy 	varchar2(1);
l_esc_level	varchar2(30) := p_esc_level;
l_close_deesc	varchar2(1) :='x';


BEGIN

  -- Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

fnd_profile.get('JTF_EC_CLOSE_WHEN_DEESCALATED', l_close_deesc);


if p_esc_level = fnd_api.g_miss_char then

  Open c_get_esc_level(p_esc_id);
  fetch c_get_esc_level into l_esc_level;
  if c_get_esc_level%NOTFOUND then
	close c_get_esc_level;
	raise fnd_api.g_exc_error;  -- need to give the reason
  end if;
  close c_get_esc_level;

end if;

x_closed_flag := 'N';

Open  c_chk_completed(p_status_id);
fetch c_chk_completed into l_dummy;
if c_chk_completed%found then

	x_closed_flag := 'Y';
	close c_chk_completed;

	open c_chk_open_tasks(p_esc_id) ;
	fetch c_chk_open_tasks into l_dummy;
	if c_chk_open_tasks%found then
		close c_chk_open_tasks;
	       	fnd_message.set_name('JTF','JTF_EC_RESTRICT_TASKS');
	       	fnd_msg_pub.Add;
		x_closed_flag := 'N';
 		raise fnd_api.g_exc_error;
        else
	  	close c_chk_open_tasks;
	end if;


	-- check whether the level is De-Escalated.

	if l_close_deesc = 'Y'
	and l_esc_level <> 'DE' then
	   	fnd_message.set_name('JTF','JTF_EC_CLOSE_WHEN_DEESCALATED');
	  	fnd_msg_pub.Add;
		x_closed_flag := 'N';
 		raise fnd_api.g_exc_error;
	end if;
else
	close c_chk_completed;
end if;


EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
        x_return_status := fnd_api.g_ret_sts_error;

WHEN OTHERS THEN

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.ADD;

END Check_Completed_Status;

PROCEDURE Conv_Miss_Num(p_number IN OUT NOCOPY  NUMBER) Is
BEGIN

if p_number = fnd_api.g_miss_num then
	p_number := NULL;
end if;

END Conv_Miss_Num;

PROCEDURE Conv_Miss_Date(p_date IN OUT NOCOPY  DATE) Is
BEGIN

if p_date = fnd_api.g_miss_date then
	p_date := NULL;
end if;

END Conv_Miss_Date;

PROCEDURE Conv_Miss_Char(p_char IN OUT NOCOPY  VARCHAR2) Is
BEGIN

if p_char = fnd_api.g_miss_char then
	p_char := NULL;
end if;

END Conv_Miss_Char;

----------------------------------------------------------------------------------------
-- Validate task_phone_id against the escalation_id
----------------------------------------------------------------------------------------

PROCEDURE Validate_Task_Phone_Id(p_task_phone_id IN NUMBER,
		    	      p_escalation_id IN NUMBER,
		    	      x_return_status OUT NOCOPY  VARCHAR2) Is

l_api_name varchar2(30) := 'Validate_Task_Phone_Id';

cursor c_check_phone_id(p_task_phone_id NUMBER,
			p_escalation_id NUMBER) Is
select 'x'
from 	jtf_task_phones ph,
	jtf_task_contacts c
where 	ph.task_phone_id = p_task_phone_id
and 	ph.task_contact_id = c.task_contact_id
and 	c.task_id = p_escalation_id;

l_dummy 	varchar2(1);

BEGIN

  -- Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

open c_check_phone_id(p_task_phone_id,p_escalation_id);
fetch c_check_phone_id into l_dummy;
if c_check_phone_id%NOTFOUND then
	close c_check_phone_id;
	Add_Invalid_Argument_Msg(l_api_name, p_task_phone_id ,'task_phone_id');
	raise fnd_api.g_exc_error;
else
	close c_check_phone_id;
end if;


EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
        x_return_status := fnd_api.g_ret_sts_error;

WHEN OTHERS THEN

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.Add;

END Validate_Task_Phone_Id;

----------------------------------------------------------------------------------------
-- Validate_Contact_id against the escalation_id
----------------------------------------------------------------------------------------


PROCEDURE Validate_Contact_id(p_contact_id 		IN NUMBER,
				p_contact_type_code 	IN VARCHAR2,
		    	      	p_escalation_id 	IN NUMBER,
				x_task_contact_id	OUT NOCOPY  NUMBER,
				x_return_status 	OUT NOCOPY  VARCHAR2) Is

l_api_name varchar2(30) := 'Validate_Contact_id';

cursor c_check_contact(	p_contact_id NUMBER,
			p_contact_type_code VARCHAR2,
			p_escalation_id NUMBER) Is
select 	c.task_contact_id
from	jtf_task_contacts c
where 	c.contact_id = p_contact_id
and 	c.task_id = p_escalation_id
and	c.contact_type_code = p_contact_type_code;

BEGIN

  -- Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

open c_check_contact(p_contact_id, p_contact_type_code, p_escalation_id);
fetch c_check_contact into x_task_contact_id;
if c_check_contact%NOTFOUND then
	close c_check_contact;
	Add_Invalid_Argument_Msg(l_api_name, p_contact_id ,'contact_id');
	Add_Invalid_Argument_Msg(l_api_name, p_contact_type_code,'contact_type_code');
	raise fnd_api.g_exc_error;
else
	close c_check_contact;
end if;


EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
        x_return_status := fnd_api.g_ret_sts_error;

WHEN OTHERS THEN

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.Add;

END Validate_Contact_id;

----------------------------------------------------------------------------------------
-- Validate task_phone_id against the escalation_id
----------------------------------------------------------------------------------------

PROCEDURE Validate_Task_Contact_Id(p_task_contact_id IN NUMBER,
		    	      	   p_escalation_id IN NUMBER,
		    	           x_return_status OUT NOCOPY  VARCHAR2) Is

l_api_name varchar2(30) := 'Validate_Task_Contact_Id';

cursor c_check_task_contact_id(p_task_contact_id NUMBER,
			       p_escalation_id NUMBER) Is
select 'x'
from 	jtf_task_contacts
where 	task_contact_id = p_task_contact_id
and 	task_id = p_escalation_id;

l_dummy 	varchar2(1);

BEGIN

  -- Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

open c_check_task_contact_id(p_task_contact_id,p_escalation_id);
fetch c_check_task_contact_id into l_dummy;
if c_check_task_contact_id%NOTFOUND then
	close c_check_task_contact_id;
	Add_Invalid_Argument_Msg(l_api_name, p_task_contact_id ,'task_contact_id');
	raise fnd_api.g_exc_error;
else
	close c_check_task_contact_id;
end if;


EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
        x_return_status := fnd_api.g_ret_sts_error;

WHEN OTHERS THEN

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.Add;

END Validate_Task_Contact_Id;

----------------------------------------------------------------------------------------
-- Validate task_reference_id against the escalation_id
----------------------------------------------------------------------------------------

PROCEDURE Validate_Task_Reference_Id(p_task_reference_id IN NUMBER,
		    	      	     p_escalation_id IN NUMBER,
		    	             x_return_status OUT NOCOPY  VARCHAR2) Is

l_api_name varchar2(30) := 'Validate_Task_Reference_Id';

cursor c_check_task_ref_id(p_task_reference_id NUMBER,
			   p_escalation_id NUMBER) Is
select 'x'
from 	jtf_task_references_vl
where 	task_reference_id = p_task_reference_id
and 	task_id = p_escalation_id;

l_dummy 	varchar2(1);

BEGIN

  -- Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

open c_check_task_ref_id(p_task_reference_id,p_escalation_id);
fetch c_check_task_ref_id into l_dummy;
if c_check_task_ref_id%NOTFOUND then
	close c_check_task_ref_id;
	Add_Invalid_Argument_Msg(l_api_name, p_task_reference_id ,'task_reference_id');
	raise fnd_api.g_exc_error;
else
	close c_check_task_ref_id;
end if;


EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
        x_return_status := fnd_api.g_ret_sts_error;

WHEN OTHERS THEN

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.Add;

END Validate_Task_Reference_Id;


----------------------------------------------------------------------------------------
-- Validate_Who_info
----------------------------------------------------------------------------------------

PROCEDURE Validate_Who_Info (
			     	p_api_name	IN  	VARCHAR2,
				p_user_id	IN  	NUMBER,
				p_login_id	IN  	NUMBER,
				x_return_status	OUT NOCOPY   	VARCHAR2
  				) Is

  l_dummy 	VARCHAR2(1);

cursor 	c_check_user_id (p_user_id NUMBER) is
select 	'x'
from 	fnd_user
where 	user_id = p_user_id
and 	nvl(start_date,sysdate) <= sysdate
and 	nvl(end_date, sysdate) >= sysdate;

cursor 	c_check_login_id (p_login_id NUMBER, p_user_id NUMBER) is
select 	'x'
from	fnd_logins
where	login_id  = p_login_id
and	user_id	  = p_user_id;

BEGIN

    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	open 	c_check_user_id(p_user_id);
	fetch 	c_check_user_id into l_dummy;
	if  c_check_user_id%NOTFOUND then
		close  c_check_user_id;
		Add_Invalid_Argument_Msg(p_api_name, p_user_id ,'user_id');
		raise fnd_api.g_exc_error;
	else
		close c_check_user_id;
	end if;

	if p_login_id is not NULL then
	   open c_check_login_id(p_login_id, p_user_id);
	   fetch c_check_login_id into l_dummy;
	   if c_check_login_id%NOTFOUND then
		close  c_check_login_id;
		Add_Invalid_Argument_Msg(p_api_name, p_login_id ,'login_id');
		raise fnd_api.g_exc_error;
	   else
		close c_check_login_id;
	   end if;

	end if;
EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
        x_return_status := fnd_api.g_ret_sts_error;

WHEN OTHERS THEN

	 x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.Add;


END Validate_Who_Info;

----------------------------------------------------------------------------------------
-- Validate note_id against the escalation_id
----------------------------------------------------------------------------------------

PROCEDURE Validate_Note_Id(p_note_id IN NUMBER,
		    	   p_escalation_id IN NUMBER,
		    	   x_return_status OUT NOCOPY  VARCHAR2) Is

l_api_name varchar2(30) := 'Validate_Note_Id';


cursor c_check_note_id(p_note_id NUMBER,
		       p_escalation_id NUMBER) Is
select 'x'
from 	jtf_notes_b
where 	jtf_note_id = p_note_id
and 	source_object_id = p_escalation_id;


l_dummy 	varchar2(1);

BEGIN

  -- Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

open c_check_note_id(p_note_id,p_escalation_id);
fetch c_check_note_id into l_dummy;
if c_check_note_id%NOTFOUND then
	close c_check_note_id;
	Add_Invalid_Argument_Msg(l_api_name, p_note_id ,'note_id');
	raise fnd_api.g_exc_error;
else
	close c_check_note_id;
end if;


EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
        x_return_status := fnd_api.g_ret_sts_error;

WHEN OTHERS THEN

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.Add;

END Validate_Note_Id;

FUNCTION Get_Requester_Name(p_escalation_id IN NUMBER) RETURN VARCHAR2 Is

cursor 	get_requester_details (p_esc_id NUMBER) Is
SELECT 	contact_id, contact_type_code
FROM 	jtf_task_contacts
WHERE 	task_id = p_esc_id
AND 	NVL(escalation_requester_flag,'N') = 'Y';


cursor 	get_customer_name (p_contact_id NUMBER) Is
SELECT  subject_party_name
FROM 	jtf_party_all_contacts_v
WHERE  	p_contact_id IN (party_id, subject_party_id);

cursor 	get_emp_name (p_contact_id NUMBER) Is
SELECT 	full_name
FROM 	per_all_people_f
WHERE 	person_id = p_contact_id
AND 	SYSDATE >= NVL(effective_start_date,SYSDATE)
AND 	SYSDATE <= NVL(effective_end_date,SYSDATE);


l_contact_id 		NUMBER;
l_contact_type_code 	VARCHAR2(30);
l_requester_name 	PER_ALL_PEOPLE_F.FULL_NAME%type :=NULL;  --Bug 2700953

Begin

	open get_requester_details(p_escalation_id);
	fetch get_requester_details into l_contact_id, l_contact_type_code;
	close get_requester_details;

	if   l_contact_type_code is not NULL
	 and l_contact_type_code = 'CUST' then
	     open get_customer_name(l_contact_id);
	     fetch get_customer_name into l_requester_name;
	     close get_customer_name;
	elsif  l_contact_type_code is not NULL
	   and l_contact_type_code = 'EMP' then
	     open get_emp_name(l_contact_id);
	     fetch get_emp_name into l_requester_name;
	     close get_emp_name;
	end if;

	RETURN(l_requester_name);

EXCEPTION
WHEN OTHERS THEN

         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.ADD;
	 RETURN NULL;

End Get_Requester_Name;

END JTF_EC_UTIL;


/
