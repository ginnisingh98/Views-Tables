--------------------------------------------------------
--  DDL for Package Body PA_CI_ACTIONS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_ACTIONS_UTIL" AS
/* $Header: PACIACUB.pls 120.1 2005/08/01 03:09:56 raluthra noship $ */

 Function action_with_reply(p_ci_action_id in number)
 return varchar2
 IS
   Cursor with_reply is
   select 'Y'
   from pa_ci_comments
   where ci_action_id = p_ci_action_id
   and type_code <> 'REQUESTOR';

   l_return_value VARCHAR2(1);

  BEGIN
	OPEN with_reply;
	FETCH with_reply into l_return_value;
 	CLOSE with_reply;
	if (l_return_value IS NULL) then
		return 'N';
	end if;
	return l_return_value;
  END action_with_reply;


 Function get_next_ci_action_number(p_ci_id in number)
 return number
 IS
   Cursor next_number is
   select pci.last_action_number
   from pa_control_items pci
   where pci.ci_id = p_ci_id
   for update of pci.last_action_number;

   l_next_number number;

 BEGIN
 	OPEN next_number;
	FETCH next_number into l_next_number;
	close next_number;
	if (l_next_number IS NULL) then
		l_next_number := 1;
	end if;


	UPDATE pa_control_items
	set last_action_number = l_next_number + 1
	where ci_id = p_ci_id;
	return l_next_number;
	EXCEPTION
    	WHEN OTHERS THEN -- catch the exceptins here
        	RAISE;
 END get_next_ci_action_number;

 Function get_party_id (
                        p_user_id in number )
 return number
 IS
    -- Bug 4527617: Modified Cursor Definition.
    Cursor external is
    select person_party_id from fnd_user
    where user_id = p_user_id;
    /* Cursor external is
    select customer_id from fnd_user
    where user_id = p_user_id; */


    -- Modified the cursor definiton for bug#4068669.
    Cursor internal is
    select pap.party_id
     from per_all_people_f pap,
          fnd_user fu
     where fu.user_id = p_user_id
     and fu.employee_id = pap.person_id
     and trunc(sysdate) between trunc(pap.effective_start_date) and trunc(pap.effective_end_date) ;
    /*select h.party_id
    from hz_parties h
    ,fnd_user f
    where h.orig_system_reference = CONCAT('PER:',f.employee_id)
    and f.user_id = p_user_id;*/

    l_party_id number;

    Begin
        Open internal;
        fetch internal into l_party_id;
            if (internal%NOTFOUND) then
                l_party_id := NULL;
            end if;
        close internal;

        if (l_party_id IS NULL) then
            Open external;
            fetch external into l_party_id;
                if (external%NOTFOUND) then
                    l_party_id := NULL;
                end if;
            close external;
        end if;

  return l_party_id;
 Exception
  When others then
   RAISE;
 End get_party_id;

 PROCEDURE CheckHzPartyName_Or_Id(			p_resource_id		IN	NUMBER,
			p_resource_name		    IN	VARCHAR2,
			p_date			        IN	DATE 	DEFAULT	SYSDATE,
			p_check_id_flag		    IN	VARCHAR2,
            p_resource_type_id      IN      NUMBER DEFAULT 101,
			x_party_id   		    OUT NOCOPY	NUMBER,
			x_resource_type_id      OUT NOCOPY NUMBER,
	        x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data	            OUT NOCOPY	VARCHAR2)IS

l_resource_id number;
l_error_message_code varchar2(30);
l_start_date_active date;

-- Modified the cursor defintion for bug#4068669.
Cursor C1 IS
       select party_id
       from per_all_people_f p
       where p.person_id = l_resource_id
       and trunc(p_date) between trunc(p.effective_start_date) and trunc(p.effective_end_date);
      --select party_id from hz_parties
      --where orig_system_reference = 'PER:'||TO_CHAR(l_resource_id);

BEGIN
        -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_CI_ACTIONS_UTIL.CHECKHZPARTYNAME_OR_ID');

        -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        PA_RESOURCE_UTILS.Check_ResourceName_Or_Id ( p_resource_id        => p_resource_id
                                                ,p_resource_type_id   => p_resource_type_id
                                                ,p_resource_name      => p_resource_name
                                                ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                ,p_date               => p_date
                                                ,x_resource_id        => l_resource_id
                                                ,x_resource_type_id   => x_resource_type_id
                                                ,x_return_status      => x_return_status
                                                ,x_error_message_code => l_error_message_code);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.Add_Message( p_app_short_name  => 'PA'
                           ,p_msg_name       => 'PA_CI_ACTION_INVALID_ASSIGNEE');
            return;
        end if;

        If (x_return_status = fnd_api.g_ret_sts_success
        AND l_resource_id <> -999) then

            if (x_resource_type_id = 101) then
                OPEN C1;
                FETCH C1 into x_party_id;
                IF C1%NOTFOUND THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    PA_UTILS.Add_Message( p_app_short_name  => 'PA'
                           ,p_msg_name       => 'PA_CI_ACTION_INVALID_ASSIGNEE');
                    return;
                ELSE
                    x_return_status := fnd_api.g_ret_sts_success;
                END IF;
                CLOSE C1;
            else
                x_party_id := l_resource_id;
            end if;
        End If;
EXCEPTION

    WHEN OTHERS THEN
     -- Set the exception Message and the stack
     FND_MSG_PUB.add_exc_msg(p_pkg_name       => 'PA_CI_ACTIONS_UTILS.CheckHzPartyName_Or_Id'
                            ,p_procedure_name => PA_DEBUG.G_Err_Stack );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     RAISE;

END;


function GET_CI_OPEN_ACTIONS(
         p_ci_id        IN NUMBER  := NULL) RETURN NUMBER IS

    total_act   NUMBER:=0;
BEGIN
   select count(*)
     into total_act
     from pa_ci_actions
    where ci_id = p_ci_id and
          status_code = 'CI_ACTION_OPEN';
   return total_act;

exception when others then
   return 0;

END GET_CI_OPEN_ACTIONS;

function GET_MY_ACTIONS(p_action_status  IN  VARCHAR2,
         p_ci_id        IN NUMBER  := NULL) RETURN NUMBER IS

BEGIN
    return 0;
END GET_MY_ACTIONS;

function CHECK_OPEN_ACTIONS_EXIST(p_ci_id	IN NUMBER := NULL)
RETURN VARCHAR2
IS
  Cursor open_actions is
  select open_action_num
  from pa_control_items
  where ci_id = p_ci_id;

  --l_result varchar2(1); Commented and changed the data type for bug 4034873
  l_result pa_control_items.open_action_num%type;

  BEGIN
	Open open_actions;
    	fetch open_actions into l_result;
    	if (open_actions%NOTFOUND) then
		close open_actions;
		return 'N';
    	end if;
    	close open_actions;
    	if (l_result > 0) then
		return 'Y';
    	else
		return 'N';
    	end if;
  END CHECK_OPEN_ACTIONS_EXIST;

  function GET_TOP_PARENT_ACTION(p_ci_action_id IN NUMBER)
    RETURN NUMBER
    IS
    l_ci_action_id number;

    Cursor action_source is
	select ci_action_id
	from pa_ci_actions
	where source_ci_action_id is null
	start with ci_action_id = p_ci_action_id
	connect by prior source_ci_action_id = ci_action_id;

    l_parent_ci_action_id number;

    BEGIN
        OPEN action_source;
        FETCH action_source
        INTO l_parent_ci_action_id;
	if (l_parent_ci_action_id is null) then
	       l_parent_ci_action_id := p_ci_action_id;
        end if;
        CLOSE action_source;
        return l_parent_ci_action_id;
  END GET_TOP_PARENT_ACTION;

END; -- Package Body PA_CI_ACTIONS_UTIL

/
