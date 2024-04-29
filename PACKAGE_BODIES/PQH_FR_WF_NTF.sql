--------------------------------------------------------
--  DDL for Package Body PQH_FR_WF_NTF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_WF_NTF" as
/* $Header: pqfrpswf.pkb 115.6 2004/04/28 02:39:16 svorugan noship $ */
g_package varchar2(60) := 'PQH_FR_WF_NTF' ;
function get_person_name(p_person_id in varchar2) return varchar2 is
   l_person_name per_all_people_f.full_name%TYPE;
   cursor csr_person_name IS
    SELECT full_name
    FROM   per_all_people_f
    WHERE  person_id = p_person_id
    ORDER BY effective_start_date DESC;
begin

   OPEN  csr_person_name;
   FETCH csr_person_name INTO l_person_name;
   CLOSE csr_person_name;
   IF l_person_name IS NULL THEN
      hr_utility.set_location('employee search failed',10);
   END IF;
   return l_person_name;
end get_person_name;

function get_user_role(p_validation_id in number,
                       p_person_id in number,
                       p_role_name in varchar2,
                       p_role_id   in number,
                       p_user_name in varchar2) return varchar2
IS
   l_user_role Varchar2(200);
  cursor csr_last_event(p_valid_id number)
  IS
     SELECT event_code
     FROM   pqh_fr_validation_events
     WHERE  validation_id = p_valid_id
     ORDER BY creation_date DESC;
  cursor csr_emp_user  IS
     SELECT user_name
     FROM   fnd_user
     WHERE  employee_id = p_person_id;
  l_event_code Varchar2(30);
 /*  Bug Number: 3539224; added l_role_name */
  l_role_name Varchar2(30) := 'PQH_ROLE:'||p_role_id;

BEGIN

   If (p_role_name is null) Then
    --
     l_role_name := p_role_name;
    --
  End if;

    OPEN csr_last_event(p_validation_id);
    FETCH csr_last_event into l_event_code;
    CLOSE csr_last_event;
    IF l_event_code IN ('200','300','400','800') THEN
      OPEN csr_emp_user;
      FETCH csr_emp_user INTO l_user_role;
      CLOSE csr_emp_user;
    ELSE
      l_user_role := NVL(l_role_name,NVL(p_user_name,l_role_name));
    END IF;
    RETURN l_user_role;
END get_user_role;


PROCEDURE psv_ntf_api(
        p_validation_id                  in number
      , p_person_id                      in number
      , p_role_name                      in varchar2
      , p_role_id                        in number
      , p_user_name                      in varchar2
      , p_user_id                        in number
      , p_comments                       in varchar2
      , p_param1_name                    in varchar2
      , p_param1_value                   in varchar2
      , p_param2_name                    in varchar2
      , p_param2_value                   in varchar2
      , p_param3_name                    in varchar2
      , p_param3_value                   in varchar2
      , p_param4_name                    in varchar2
      , p_param4_value                   in varchar2
      , p_param5_name                    in varchar2
      , p_param5_value                   in varchar2
      , p_param6_name                    in varchar2
      , p_param6_value                   in varchar2
      , p_param7_name                    in varchar2
      , p_param7_value                   in varchar2
      , p_param8_name                    in varchar2
      , p_param8_value                   in varchar2
      , p_param9_name                    in varchar2
      , p_param9_value                   in varchar2
      , p_param10_name                   in varchar2
      , p_param10_value                  in varchar2
      )
     IS
     l_proc varchar2(61) := g_package||':'||'psv_ntf_api';
     l_itemkey  number;
     l_itemtype varchar2(60) := 'PQHGEN';
     l_process_name varchar2(60) := 'PQHFRNTF';
     l_message_name varchar2(100);
     l_person_name  per_all_people_f.full_name%TYPE;
     l_url     Varchar2(2000);
     l_user_role Varchar2(200);
  Begin
     hr_utility.set_location(l_proc || ' Entering',10);
     hr_utility.set_location(l_proc || ' Params - l_itemtype '|| l_itemtype,15);
     hr_utility.set_location(l_proc || ' Params - l_process name '|| l_process_name,15);
     select PQH_FR_WF_NOTIFICATION_S.NEXTVAL into l_itemkey from dual;
     hr_utility.set_location(l_proc || ' Params - l_itemkey '|| l_itemkey,35);

     wf_engine.createProcess(    ItemType => l_itemtype,
                                 ItemKey  => l_ItemKey,
                                 process  => l_process_name );

     wf_engine.SetItemAttrNumber(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'VALIDATION_ID'
                               , avalue   => p_validation_id);

     wf_engine.SetItemAttrNumber(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PERSON_ID'
                               , avalue   => p_person_id);

     l_person_name := get_person_name(p_person_id);

     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PSV_PERSON_NAME'
                               , avalue   => l_person_name);

     l_user_role := get_user_role(p_validation_id =>p_validation_id,
                                  p_person_id => p_person_id,
                                  p_role_name => p_role_name,
                                  p_role_id  => p_role_id,
                                  p_user_name => p_user_name);
     IF l_user_role IS NULL THEN
        hr_utility.set_location(l_proc || 'User /Role Not Entered for PSV',40);
        RETURN;
     END IF;
        hr_utility.set_location(l_proc || 'User /Role '||l_user_role,40);
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PSV_USER_ROLE'
                               , avalue   => l_user_role);

     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'COMMENTS'
                               , avalue   => p_comments);

     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'ROUTED_BY_USER'
                               , avalue   => fnd_global.user_name);

/* begin ns - 26-mar-2004: This is no longer needed as the url for embedded region is
   specified in the the message attribute itself.
     l_url := 'JSP:/'||'OA_HTML'||'/'||'OA.jsp?akRegionCode=FR_PQH_PSV_VIEW_TOP'||'&'||'akRegionApplicationId=8302'||'&'||'pPersonId='||p_person_id||'&'||'pValidationId='||p_validation_id||'&'||'pNotification=Y';

     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PSV_URL'
                               , avalue   => l_url);

end ns */

     -- Setting the parameter name and values only if they are not null
     -- for performance reasons

     if ( p_param1_name is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER1_NAME'
                               , avalue   => p_param1_name);
     end if;

     if ( p_param2_name is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER2_NAME'
                               , avalue   => p_param2_name);
     end if;

     if ( p_param3_name is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER3_NAME'
                               , avalue   => p_param3_name);
     end if;

     if ( p_param4_name is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER4_NAME'
                               , avalue   => p_param4_name);
     end if;

     if ( p_param5_name is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER5_NAME'
                               , avalue   => p_param5_name);
     end if;

     if ( p_param6_name is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER6_NAME'
                               , avalue   => p_param6_name);
     end if;

     if ( p_param7_name is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER7_NAME'
                               , avalue   => p_param7_name);
     end if;

     if ( p_param8_name is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER8_NAME'
                               , avalue   => p_param8_name);
     end if;

     if ( p_param9_name is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER9_NAME'
                               , avalue   => p_param9_name);
     end if;

     if ( p_param10_name is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER10_NAME'
                               , avalue   => p_param10_name);
     end if;


     if ( p_param1_value is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER1_VALUE'
                               , avalue   => p_param1_value);

     end if;

     if ( p_param2_value is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER2_VALUE'
                               , avalue   => p_param2_value);
     end if;

     if ( p_param3_value is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER3_VALUE'
                               , avalue   => p_param3_value);
     end if;

     if ( p_param4_value is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER4_VALUE'
                               , avalue   => p_param4_value);
     end if;

     if ( p_param5_value is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER5_VALUE'
                               , avalue   => p_param5_value);
     end if;

     if ( p_param6_value is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER6_VALUE'
                               , avalue   => p_param6_value);
     end if;

     if ( p_param7_value is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER7_VALUE'
                               , avalue   => p_param7_value);
     end if;

     if ( p_param8_value is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER8_VALUE'
                               , avalue   => p_param8_value);
     end if;

     if ( p_param9_value is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER9_VALUE'
                               , avalue   => p_param9_value);
     end if;

     if ( p_param10_value is not null) then
     wf_engine.SetItemAttrText(  itemtype => l_itemtype
                               , itemkey  => l_itemkey
                               , aname    => 'PARAMETER10_VALUE'
                               , avalue   => p_param10_value);
     end if;

     hr_utility.set_location(l_proc || ' Start Process',15);

     wf_engine.StartProcess (  ItemType => l_itemtype,
                               ItemKey  => l_ItemKey );
     hr_utility.set_location(l_proc || ' Exiting ',100);
  End psv_ntf_api;

  PROCEDURE WHICH_MESSAGE (
        itemtype                         in varchar2
      , itemkey                          in varchar2
      , actid                            in number
      , funcmode                         in varchar2
      , result                       out nocopy    varchar2)
  IS
  l_proc varchar2(61) := g_package||':'||'psv_ntf_api';
  cursor csr_last_event(p_valid_id number)
  IS
     SELECT event_code
     FROM   pqh_fr_validation_events
     WHERE  validation_id = p_valid_id
     ORDER BY creation_date DESC;
  l_event_code pqh_fr_validation_events.event_code%TYPE;
  l_validation_id Number;
  BEGIN
   l_validation_id :=   wf_engine.GetItemAttrText(
                                                  itemtype => itemtype,
                                                  itemkey  => ItemKey,
                                                  aname    => 'VALIDATION_ID');

     OPEN csr_last_event(l_validation_id);
     FETCH csr_last_event INTO l_event_code;
     CLOSE csr_last_event;
     IF l_event_code = '200' THEN
       result := 'RECEIVE_BSCT';
     ELSIF l_event_code = '300' THEN
       result := 'RECEIVE_REQUEST';
     ELSIF l_event_code = '400' THEN
       result := 'RECEIVE_FILE_REQUEST';
     ELSIF l_event_code = '800' THEN
       result :=  'SEND_QUOTE';
     ELSIF l_event_code = '1100' THEN
       result := 'DEDUCTION_DEFINED';
     ELSE
       result := 'FR_PQH_PSV_NOTIFY';
     END IF;
     hr_utility.set_location(l_proc || ' Exiting with result '||result,100);
  end which_message;
END PQH_FR_WF_NTF;

/
