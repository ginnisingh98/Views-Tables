--------------------------------------------------------
--  DDL for Package Body PAY_US_WORKFLOW_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_WORKFLOW_API_PKG" as
/* $Header: payuswfapipkg.pkb 120.0.12010000.2 2009/12/24 11:21:27 mikarthi ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_workflow_api_pkg

    Description :

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    08-JUN-2003 jgoswami   115.0            Created
    19-JUN-2003 jgoswami   115.1  3006871   Added procedure ExecuteConcProgram,
                                             CheckProcessInputs

    12-APR-2004 JGoswami   115.4  3316422  Added procedure IsResponseRequired
    12-APR-2004 JGoswami   115.4  3316527  Modified get_assignment_info.
    24-DEC-2009 mikarthi   115.5  9211154  Modified call to
                                           FND_GLOBAL.Apps_Initialize by passing
                                           security_group_id instead of security
                                           profile id
  ******************************************************************************/

  -- IN
  --   itemtype  - type of the current item
  --   itemkey   - key of the current item
  --   actid     - process activity instance id
  --   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
  -- OUT
  --   result
  --       - COMPLETE[:<result ]
  --           activity has completed with the indicated result
  --       - WAITING
  --           activity is waiting for additional transitions
  --       - DEFERED
  --           execution should be defered to background
  --       - NOTIFIED[:<notification_id :<assigned_user ]
  --           activity has notified an external entity that this
  --           step must be performed.  A call to wf_engine.CompleteActivty
  --           will signal when this step is complete.  Optional
  --           return of notification ID and assigned user.
  --       - ERROR[:<error_code ]
  --           function encountered an error.

          X_bg_id        NUMBER;
          X_org_id        NUMBER;
          X_req_id        VARCHAR2(50);


  /* ************************************************************************

     This procedure gets the Assignment Info and create the Document.
     ************************************************************************ */

  PROCEDURE get_assignment_info (document_id       IN VARCHAR2,
                                display_type      IN VARCHAR2,
                                document          IN OUT nocopy VARCHAR2,
                                document_type     IN OUT nocopy VARCHAR2)

          IS

          ln_request_id  number(15);
          ln_business_group_id  number(15);
          ln_payroll_id         number(15);
          ld_payroll_date_paid  varchar2(20);
          ln_total number(9);
          ln_complete number(9);
          ln_error number(9);
          ln_unprocessed number(9);
          lv_business_group_name varchar2(240);
          X_Segment1 VARCHAR2(240);
          X_Segment2 VARCHAR2(240);
          X_Segment3 VARCHAR2(240);
          X_Segment4 VARCHAR2(240);
          X_Segment5 VARCHAR2(240);
          X_result VARCHAR2(2000);
          l_cur_req_id Varchar2(240);
          l_payroll_flag varchar2(1);
          l_bg_flag varchar2(1);
          l_space varchar2(25);


          CURSOR asg_info_cur(p_req_id Number)
          IS
          select ppf.payroll_name PAYROLL_NAME,
                 to_char(count(paa.assignment_action_id)) ASG_COUNT,
                 paa.action_status ASG_STATUS
            from pay_assignment_actions paa,
                 pay_payroll_actions ppa,
                 pay_all_payrolls_f ppf
           where paa.payroll_action_id  = ppa.payroll_action_id
             and ppa.request_id =  to_number(p_req_id)
             and ppa.business_group_id = ln_business_group_id
             and ppa.payroll_id = ppf.payroll_id
             and ppf.payroll_id = ln_payroll_id
             and ppa.effective_date between
                 ppf.effective_start_date and
                 ppf.effective_end_date
             and ppa.effective_date = trunc(to_date(ld_payroll_date_paid,'YYYY/MM/DD HH24:MI:SS'))
             and ppa.action_type = 'R'
             and paa.source_action_id is null
             and paa.run_type_id is null
        group by ppf.payroll_name,paa.action_status;


  BEGIN
        l_payroll_flag := 'N';
        l_bg_flag := 'N';
        l_space := '  ';
        ln_total := 0;
        ln_complete := 0;
        ln_error := 0;
        ln_unprocessed := 0;

        hr_utility.trace('B4 ASG Info');
        hr_utility.trace('Document Id '||document_id);

        ln_request_id := substr(document_id,1,instr(document_id,':') -1 );
        ln_business_group_id := substr(document_id,instr(document_id,':',1,1)+1 ,
                                                 instr(document_id,':',1,2) -instr(document_id,':',1,1)-1 );
        ln_payroll_id := substr(document_id,instr(document_id,':',1,2)+1 ,
                                          instr(document_id,':',1,3) -instr(document_id,':',1,2)-1 );
        ld_payroll_date_paid := substr(document_id,instr(document_id,':',1,3)+1  );

        hr_utility.trace('ln_request_id = '||ln_request_id);
        hr_utility.trace('ln_business_group_id = '||ln_business_group_id);
        hr_utility.trace('ln_payroll_id = '||ln_payroll_id);
        hr_utility.trace('ld_payroll_date_paid = '||ld_payroll_date_paid);

     begin
            select pbg.name into lv_business_group_name
              from per_business_groups pbg
             where pbg.business_group_id = ln_business_group_id;

             hr_utility.trace('ln_business_group_id = '||ln_business_group_id);
     exception when others then
               null;
     end;

     FOR asg_info_rec in asg_info_cur(ln_request_id) LOOP


        if lv_business_group_name is not null
           and  l_bg_flag <> 'Y'then
        X_segment1 := 'Business Group :'||lv_business_group_name||l_space||wf_core.newline;
          l_bg_flag := 'Y';
        end if;

        if asg_info_rec.PAYROLL_NAME is not null
           and  l_payroll_flag <> 'Y'then
           X_segment2 := 'Payroll :'||asg_info_rec.PAYROLL_NAME||l_space||wf_core.newline;
           l_payroll_flag := 'Y';
        end if;

        if asg_info_rec.ASG_STATUS = 'C' then
           ln_complete := asg_info_rec.ASG_COUNT;
        elsif asg_info_rec.ASG_STATUS = 'E' then
           ln_error := asg_info_rec.ASG_COUNT;
        elsif asg_info_rec.ASG_STATUS = 'U' then
           ln_unprocessed := asg_info_rec.ASG_COUNT;
        end if;

     END LOOP ;

        X_segment3 := 'Total Assignment Successfully Processed :'||to_char(ln_complete)||l_space||wf_core.newline;
        X_segment4 := 'Total Assignment Errored :'||to_char(ln_error)||l_space||wf_core.newline;
        X_segment5 := 'Total Assignment Un-Processed :'||to_char(ln_unprocessed)||l_space||wf_core.newline;

        document := '<p>'||X_segment3||'<br>'||X_segment4||'<br>'||X_segment5||'<br></p>';

        document := document || l_space||wf_core.newline;

        hr_utility.trace('Document  '||document);


        document_type := 'text/html';
Exception When others then
        hr_utility.trace('In Exception ');

End Get_Assignment_Info;

--

/*
procedure set_attr_value(itemtype in varchar2,
                         itemkey in varchar2,
                         actid in number,
                         funcmode in varchar2,
                         resultout out nocopy varchar2) is
--->   <local declarations>
  lv_aname varchar2(30);

   begin
   -- Do nothing in cancel or timeout mode
   if (funcmode <> wf_engine.eng_run) then
       resultout := wf_engine.eng_null;
   else

    lv_aname := PAY_WORKFLOW_API_PKG.set_value(itemtype,itemkey,actid);
    hr_utility.trace('lv_aname = '|| lv_aname);
   -- put this activity in wait/notified state
    if lv_aname is not null then
       resultout := 'COMPLETE'||':'||wf_engine.eng_null;
    else
       resultout := wf_engine.eng_null;
    end if;

   end if;
       return;
      exception
           when others then
            WF_CORE.CONTEXT ('PAY_WORKFLOW_API_PKG', 'set_attr_value', itemtype,
                            itemkey, to_char(actid), funcmode);
           raise;
end set_attr_value;

procedure get_attr_value(itemtype in varchar2,
                         itemkey in varchar2,
                         actid in number,
                         funcmode in varchar2,
                         resultout out nocopy varchar2) is
--->   <local declarations>
  lv_aname varchar2(30);

   begin
   -- Do nothing in cancel or timeout mode
   if (funcmode <> wf_engine.eng_run) then
       resultout := wf_engine.eng_null;
   else

    lv_aname := PAY_WORKFLOW_API_PKG.get_value(itemtype,itemkey,actid)
   -- put this activity in wait/notified state
    if lv_aname is not null then
       resultout := 'COMPLETE'||':'||wf_engine.eng_null;
    else
       resultout := wf_engine.eng_null;
    end if;

   end if;
       return;
      exception
           when others then
            WF_CORE.CONTEXT ('PAY_WORKFLOW_API_PKG', 'get_attr_value', itemtype,
                            itemkey, to_char(actid), funcmode);
           raise;
end get_attr_value;
*/

  PROCEDURE get_message_details (document_id       IN VARCHAR2,
                                display_type      IN VARCHAR2,
                                document          IN OUT nocopy VARCHAR2,
                                document_type     IN OUT nocopy VARCHAR2)

          IS

          X_Segment1 VARCHAR2(240);
          X_Segment2 VARCHAR2(240);
          X_Segment3 VARCHAR2(240);
          X_Segment4 VARCHAR2(240);
          X_Segment5 VARCHAR2(240);
          X_result VARCHAR2(2000);
          l_cur_req_id Varchar2(240);
          l_payroll_flag varchar2(1);
          l_bg_flag varchar2(1);
          l_space varchar2(25);


          args Varchar2(240);
          firstcolon  number;
          nextcolon  number;
          lv_itemtype Varchar2(240);
          lv_itemkey Varchar2(240);
          lv_attr_name Varchar2(30);

  BEGIN
        l_payroll_flag := 'N';
        l_bg_flag := 'N';
        l_space := '  ';
     hr_utility.trace('B4 MSG Details ');
     hr_utility.trace('Document Id '||document_id);

     args := document_id;
     -- args has format itemtype:itemkey:attr_name
     firstcolon  := instr(args,':');
     nextcolon  := instr(args,':',firstcolon+1);
     lv_itemtype := substr(args,1, firstcolon-1);
     hr_utility.trace('Item Type '||lv_itemtype);
     lv_itemkey  := substr(args,firstcolon+1,nextcolon -(firstcolon-1));
     hr_utility.trace('Item Key '||lv_itemkey);
     lv_attr_name  := substr(args,nextcolon+1);
     hr_utility.trace('Attr Name '||lv_attr_name);

--        l_cur_req_id := get_value(lv_itemtype,lv_itemkey,lv_attr_name);

        X_segment1 := '<p> The Function GET_VALUE retrives the value of the request id for the given attribute name Request Id :'||l_cur_req_id||wf_core.newline ||'<br> </p>';
        document := document || X_segment1||wf_core.newline;
        document_type := 'text/html';
     hr_utility.trace('Document  '||document);
Exception When others then
     hr_utility.trace('In Exception of Get message_details');

End get_message_details;

/*
-- Get Value
FUNCTION get_value(
                            wf_item_type in varchar2,
                            wf_item_key in  varchar2,
                            attr_name in  varchar2
                          ) RETURN VARCHAR2 IS
 ignore_notfound  boolean := FALSE;
 attr_value varchar2(80);
Begin

--  From the Runtime Attributes Get the Value of the Attribute for the Workflow
--   Item Type, Item Key,Attribute Name.

   attr_value := WF_Engine.GetItemAttrText(wf_item_type , wf_item_key , attr_name , ignore_notfound);

   return attr_value;

Exception When others then
     hr_utility.trace('In Exception of get_value');

End get_value;
*/

/*
-- Set Value
FUNCTION set_value(
                    wf_item_type in varchar2 default 'NO_WF_ITEM',
                    wf_item_key in  varchar2,
                    wf_actid     in number
                    ) RETURN VARCHAR2 IS
aname Wf_Engine.NameTabTyp;
avalue Wf_Engine.TextTabTyp;

lv_attr_name varchar2(30);
lv_attr_value varchar2(30);
Begin

--  Add an Item Attribute at Runtime and Set the Value of the Attribute
--    for the Workflow Item Type, Item Key,Attribute Name.

lv_attr_name := wf_engine.GetActivityAttrText(wf_item_type,wf_item_key,wf_actid, 'ATTR_NAME');
lv_attr_value := wf_engine.GetActivityAttrText(wf_item_type,wf_item_key,wf_actid, 'ATTR_VALUE');
--    aname(1) := lv_attr_name;
--    avalue(1) := lv_attr_value;

    hr_utility.trace('aname = '|| lv_attr_name);
    hr_utility.trace('avalue = '|| lv_attr_value);
    if aname is not null then
       --WF_Engine.AddItemAttr(wf_item_type, wf_item_key, aname, avalue);
       WF_Engine.AddItemAttr(wf_item_type, wf_item_key, lv_attr_name, lv_attr_value);
       --return aname;
       return lv_attr_name;
    else
       return null;
    end if;
Exception When others then
     hr_utility.trace('In Exception of set_value');

End set_value;
*/

procedure GetRetroInformation(itemtype in varchar2,
                                  itemkey in varchar2,
                                  actid in number,
                                  funcmode in varchar2,
                                  resultout out nocopy varchar2) is
aname 			varchar2(80);
avalue 			number(30);
result 			varchar2(30);
lv_result 		varchar2(30);
lv_retro_asg_set 	varchar2(30);
ln_retro_asg_set_id 	number(30);
ln_get_retro_asgset_id 	number(30);
ignore_notfound  	boolean;
l_notification_id     	NUMBER;
l_notification_id2     	NUMBER;
nid     		NUMBER;


begin

 lv_result := 'SKIP';
 ignore_notfound  := FALSE;

        hr_utility.trace(' In GetRetroInformation ');
    if ( funcmode = 'RUN' ) then
        hr_utility.trace('Function Mode  = '||funcmode);
      -- get attr value
           --<your RUN executable statements>
        hr_utility.trace('itemtype = '||itemtype);
        hr_utility.trace('itemkey = '||itemkey);
        hr_utility.trace('actid = '||to_char(actid));

                              aname    :=  'RETRO_ASSIGNMENT_SET_NAME';
          lv_retro_asg_set := Wf_Engine.GetItemAttrText(
                              itemtype ,
                              itemkey  ,
                              aname,
                              ignore_notfound);

                              aname    :=  'P_BUSINESS_GROUP_ID';

          X_bg_id        := Wf_Engine.GetItemAttrNumber(
                            itemtype,
                            itemkey,
                            aname,
                            ignore_notfound);


     hr_utility.trace(' BG Id  = '|| to_char(X_bg_id));
     hr_utility.trace(' Retro Asg Set  = '|| lv_retro_asg_set);

         begin
              select assignment_set_id
                into ln_retro_asg_set_id
               from  hr_assignment_sets
               where business_group_id = X_bg_id
                and  assignment_set_name like lv_retro_asg_set||'%';

     hr_utility.trace(' Retro Asg Set ID = '|| to_char(ln_retro_asg_set_id));
         exception when others then
                   result := 'SKIP';
                   hr_utility.trace('Skiping Retro Pay By Element as Assignment Set Not Found');
         end;

         if ln_retro_asg_set_id is not null then

               Wf_Engine.SetItemAttrNumber
                         (itemtype,
                          itemkey,
                          'RETRO_ASSIGNMENT_SET_ID',
                          ln_retro_asg_set_id);
               result := 'RUN';
               hr_utility.trace('result = '||result);
          else
               result := 'SKIP';

               hr_utility.trace('result = '||result);
          end if;

           resultout := 'COMPLETE:'||result;
           hr_utility.trace(' Resultout  = '|| resultout);
           return;
      elsif ( funcmode = 'CANCEL' ) then
--           <your CANCEL executable statements>
           null;
           result := 'SKIP';
           resultout := 'COMPLETE:'||result;
           hr_utility.trace('In Skip  Resultout  = '|| resultout);
           return;

      end if;

 exception
           when others then
            WF_CORE.CONTEXT ('PAY_US_WORKFLOW_API_PKG', 'GetRetroInformation', itemtype, itemkey, to_char(actid), funcmode);
           raise;
end GetRetroInformation;


procedure post_notification_set_attr(itemtype in varchar2,
                                  itemkey in varchar2,
                                  actid in number,
                                  funcmode in varchar2,
                                  resultout out nocopy varchar2) is
aname 			varchar2(80);
avalue 			number(30);
result 			varchar2(30);
lv_result 		varchar2(30);
lv_retro_asg_set 	varchar2(30);
ln_retro_asg_set_id 	number(30);
ln_get_retro_asgset_id 	number(30);
ignore_notfound  	boolean;
l_notification_id     	NUMBER;
l_notification_id2     	NUMBER;
nid     		NUMBER;

begin

 lv_result := 'SKIP';
 ignore_notfound  := FALSE;

        hr_utility.trace('1. Function Mode  = '||funcmode);
    if ( funcmode = 'RUN' ) then
      ln_get_retro_asgset_id := Wf_Engine.GetItemAttrNumber(
                                  itemtype,
                                  itemkey,
                                  'RETRO_ASSIGNMENT_SET_ID');

        hr_utility.trace('Function Mode  = '||funcmode);
        hr_utility.trace('1. ln_get_retro_asgset_id = '||to_char(ln_get_retro_asgset_id));

        if ln_get_retro_asgset_id is not null  then
           resultout := 'COMPLETE:RUN';
           hr_utility.trace(' Resultout  = '|| resultout);
        else
           resultout := 'COMPLETE:SKIP';
           hr_utility.trace(' Resultout  = '|| resultout);
        end if;

           return;
    end if;


    if ( funcmode = 'RESPOND' ) then
        hr_utility.trace('Function Mode  = '||funcmode);
      -- get attr value
           --<your RUN executable statements>
        hr_utility.trace('itemtype = '||itemtype);
        hr_utility.trace('itemkey = '||itemkey);
        hr_utility.trace('actid = '||to_char(actid));
        l_notification_id2:=    wf_engine.context_nid;
        hr_utility.trace('2. l_notification_id = '||to_char(l_notification_id2));

        if (l_notification_id is not null ) then
           lv_result := WF_NOTIFICATION.GetAttrText( l_notification_id, 'RESULT');
           hr_utility.trace('1. lv_result = '||lv_result);
        elsif ( l_notification_id2 is not null) then
            lv_result := WF_NOTIFICATION.GetAttrText( l_notification_id2, 'RESULT');
            hr_utility.trace('2.lv_result = '||lv_result);
        end if;

      if (lv_result <> 'SKIP') then
                              aname    :=  'RETRO_ASSIGNMENT_SET_NAME';
          lv_retro_asg_set := Wf_Engine.GetItemAttrText(
                              itemtype ,
                              itemkey  ,
                              aname,
                              ignore_notfound);

                              aname    :=  'P_BUSINESS_GROUP_ID';

          X_bg_id        := Wf_Engine.GetItemAttrNumber(
                            itemtype,
                            itemkey,
                            aname,
                            ignore_notfound);


     hr_utility.trace(' BG Id  = '|| to_char(X_bg_id));
     hr_utility.trace(' Retro Asg Set  = '|| lv_retro_asg_set);

         begin
              select assignment_set_id
                into ln_retro_asg_set_id
               from  hr_assignment_sets
               where business_group_id = X_bg_id
                and  assignment_set_name like lv_retro_asg_set||'%';

     hr_utility.trace(' Retro Asg Set ID = '|| to_char(ln_retro_asg_set_id));
         exception when others then
                   result := 'SKIP';
                   hr_utility.trace('Skiping Retro Pay By Element as Assignment Set Not Found');
         end;

         if ln_retro_asg_set_id is not null then

               Wf_Engine.SetItemAttrNumber
                         (itemtype,
                          itemkey,
                          'RETRO_ASSIGNMENT_SET_ID',
                          ln_retro_asg_set_id);
               result := 'RUN';
               hr_utility.trace('result = '||result);
          else
               result := 'SKIP';

               hr_utility.trace('result = '||result);
          end if;

           resultout := 'COMPLETE:'||result;
           hr_utility.trace(' Resultout  = '|| resultout);
           return;
      else
           result := 'SKIP';
           resultout := 'COMPLETE:'||result;
           hr_utility.trace('In Skip  Resultout  = '|| resultout);
           return;

      end if;
--            result := 'SKIP';
--           resultout := 'COMPLETE:'||result;
--           hr_utility.trace('In Skip  Resultout  = '|| resultout);
--           return;

    end if;

        if ( funcmode = 'CANCEL' ) then
--           <your CANCEL executable statements>
           null;
           result := 'SKIP';
           resultout := 'COMPLETE:'||result;
           return;
      end if;


 exception
           when others then
            WF_CORE.CONTEXT ('PAY_US_WORKFLOW_API_PKG', 'post_notification_set_attr', itemtype, itemkey, to_char(actid), funcmode);
           raise;
end post_notification_set_attr;

PROCEDURE ExecuteConcProgram
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2
)
IS
  l_user_id             NUMBER;
  l_resp_id             NUMBER;
  l_resp_appl_id        NUMBER;
  l_org_id              NUMBER;
  l_resultout           varchar2(80);
  l_security_group_id   NUMBER;
  l_per_security_id   NUMBER;

      work_item_org_id NUMBER;
      session_org_id varchar2(100);
    BEGIN

/*
cursor c1 is select
                furg.user_id,
                furg.responsibility_id,
                furg.responsibility_application_id
        from fnd_user_resp_groups furg,
             fnd_user fu,
             fnd_responsibility fr
        where   fu.user_id = furg.user_id
                and furg.responsibility_id = fr.responsibility_id
                and fu.user_name  = 'JATIN'
                and responsibility_key like 'JJ CA HRMS MANAGER';
*/



--FOR crec in c1  loop

   IF (p_funcmode = 'RUN') THEN

    -- Code that determines Start Process
    --   p_result := 'COMPLETE';
     -- get Item Attributes for user_id, responsibility_id and application_id
     -- this assumes that they were set as item attribute, probably through
     -- definition.

      hr_utility.trace('In set context of ExecuteConcProgram');
     l_user_id:= wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'USER_ID');
     l_resp_appl_id:= wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'APPLICATION_ID');
     l_resp_id:= wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'RESPONSIBILITY_ID');
     l_org_id:=  wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'ORG_ID');

  l_security_group_id :=  wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'SECURITY_GROUP_ID');
  l_per_security_id :=  wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'PER_SECURITY_PROFILE_ID');
/*
     l_user_id:= crec.user_id;
     l_resp_appl_id:= crec.responsibility_application_id;
     l_resp_id:= crec.responsibility_id;

*/
     hr_utility.trace('l_user_id = '|| l_user_id);
     hr_utility.trace('l_resp_appl_id: = '|| l_resp_appl_id);
     hr_utility.trace('l_resp_id = '|| l_resp_id);
     hr_utility.trace('l_org_id = '|| l_org_id);
     hr_utility.trace('l_security_group_id = '|| l_security_group_id);
     hr_utility.trace('l_per_security_id = '|| l_per_security_id);

     -- Set the database session context which also sets the org
     --Bug 9211154 - Pass l_security_group_id instead of l_per_security_id
     FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id,l_security_group_id);
     --FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id,l_per_security_id);

      hr_utility.trace('In funcmode RUN of ExecuteConcProgram');
   --    HR_SIGNON.Initialize_HR_Security;
      hr_utility.trace('A4 HR_SIGNON.Initialize_HR_Security of ExecuteConcProgram');
       fnd_wf_standard.ExecuteConcProgram(p_itemtype  ,
                  p_itemkey   ,
                  p_actid     ,
                  p_funcmode  ,
                  l_resultout );

        p_result := l_resultout;
        return;

   ELSIF (p_funcmode = 'TEST_CTX') THEN
      hr_utility.trace('In Test context of ExecuteConcProgram');
         -- Code that compares current session context
          -- with the work item context required to execute
          -- the workflow safely

          fnd_profile.get(name=>'ORG_ID',val=>session_org_id);

          work_item_org_id := wf_engine.GetItemAttrNumber(p_itemtype, p_itemkey, 'ORG_ID');

          if session_org_id = work_item_org_id then

            p_result := 'COMPLETE:TRUE';

          else
          -- If the background engine is executing the
          -- Selector/Callback function, the workflow engine
          -- Will immediately run the Selector/Callback
          -- Function in SET_CTX mode

             p_result := 'COMPLETE:FALSE';

          end if;

        return;

   ELSIF(p_funcmode = 'SET_CTX') THEN

     -- Code that sets the current session context
     -- based on the work item context stored in item attributes

     -- get Item Attributes for user_id, responsibility_id and application_id
     -- this assumes that they were set as item attribute, probably through
     -- definition.

      hr_utility.trace('In set context of ExecuteConcProgram');
     l_user_id:= wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'USER_ID');
     l_resp_appl_id:= wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'APPLICATION_ID');
     l_resp_id:= wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'RESPONSIBILITY_ID');
     l_org_id:=  wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'ORG_ID');

/*
     l_user_id:= crec.user_id;
     l_resp_appl_id:= crec.responsibility_application_id;
     l_resp_id:= crec.responsibility_id;

*/
     -- Set the database session context which also sets the org
     --Bug 9211154 - Pass l_security_group_id
     l_security_group_id :=  wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'SECURITY_GROUP_ID');
     FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id,l_security_group_id);
     --FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id);


     p_result := 'COMPLETE';

        return;

  ELSE
    p_result := 'COMPLETE';
        return;


  END IF;
--end loop;


EXCEPTION
   WHEN OTHERS THEN NULL;
   WF_CORE.Context('PAY_US_WORKFLOW_API_PKG', 'ExecuteConcProgram',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
   RAISE;


END  ExecuteConcProgram;

PROCEDURE CheckProcessInputs
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2
)
IS
  l_user_id             NUMBER;
  l_resp_id             NUMBER;
  l_resp_appl_id        NUMBER;
  l_org_id              NUMBER;
  l_resultout           varchar2(80);
  l_security_group_id   NUMBER;
  l_per_security_id   NUMBER;

    BEGIN

    hr_utility.trace('In CheckProcessInputs');

   IF (p_funcmode = 'RUN') THEN

    -- Code that determines Start Process
    --   p_result := 'COMPLETE:RUN';
     -- get Item Attributes for user_id, responsibility_id and application_id
     -- this assumes that they were set as item attribute, probably through
     -- definition.
      hr_utility.trace('In set context of ExecuteConcProgram');
     l_user_id:= wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'USER_ID');
     l_resp_appl_id:= wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'APPLICATION_ID');
     l_resp_id:= wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'RESPONSIBILITY_ID');
     l_org_id:=  wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'ORG_ID');

  l_security_group_id :=  wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'SECURITY_GROUP_ID');
  l_per_security_id :=  wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'PER_SECURITY_PROFILE_ID');

     hr_utility.trace('l_user_id = '|| l_user_id);
     hr_utility.trace('l_resp_appl_id: = '|| l_resp_appl_id);
     hr_utility.trace('l_resp_id = '|| l_resp_id);
     hr_utility.trace('l_org_id = '|| l_org_id);
     hr_utility.trace('l_security_group_id = '|| l_security_group_id);
     hr_utility.trace('l_per_security_id = '|| l_per_security_id);

     -- Set the database session context which also sets the org
     --Bug 9211154 - Pass l_security_group_id instead of l_per_security_id
     FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id,l_security_group_id);
     --FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id,l_per_security_id);

       WF_STANDARD.COMPARE(p_itemtype  ,
                           p_itemkey   ,
                           p_actid     ,
                           p_funcmode  ,
                           l_resultout );

           if (l_resultout = 'COMPLETE:EQ') then
                 p_result := 'COMPLETE:RUN';
        elsif ((l_resultout = 'COMPLETE:LT') or
               (l_resultout = 'COMPLETE:GT') or
               (l_resultout  = 'COMPLETE:NULL')) then
                 p_result := 'COMPLETE:SKIP';
        end if;

        return;

  ELSE
    p_result := 'COMPLETE:SKIP';
        return;

  END IF;


EXCEPTION
   WHEN OTHERS THEN NULL;
   WF_CORE.Context('PAY_US_WORKFLOW_API_PKG', 'CheckProcessInputs',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
   RAISE;


END  CheckProcessInputs;


PROCEDURE IsResponseRequired
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2
)
IS
  l_user_id             NUMBER;
  l_resp_id             NUMBER;
  l_resp_appl_id        NUMBER;
  l_org_id              NUMBER;
  l_resultout           varchar2(80);
  l_security_group_id   NUMBER;
  l_per_security_id   NUMBER;

    BEGIN

    hr_utility.trace('In IsResponseRequired');

   IF (p_funcmode = 'RUN') THEN

    -- Code that determines Start Process
    --   p_result := 'COMPLETE:RUN';
     -- get Item Attributes for user_id, responsibility_id and application_id
     -- this assumes that they were set as item attribute, probably through
     -- definition.
      hr_utility.trace('In set context of ExecuteConcProgram');
     l_user_id:= wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'USER_ID');
     l_resp_appl_id:= wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'APPLICATION_ID');
     l_resp_id:= wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'RESPONSIBILITY_ID');
     l_org_id:=  wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'ORG_ID');

  l_security_group_id :=  wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'SECURITY_GROUP_ID');
  l_per_security_id :=  wf_engine.GetItemAttrNumber(p_itemtype,p_itemkey,'PER_SECURITY_PROFILE_ID');

     hr_utility.trace('l_user_id = '|| l_user_id);
     hr_utility.trace('l_resp_appl_id: = '|| l_resp_appl_id);
     hr_utility.trace('l_resp_id = '|| l_resp_id);
     hr_utility.trace('l_org_id = '|| l_org_id);
     hr_utility.trace('l_security_group_id = '|| l_security_group_id);
     hr_utility.trace('l_per_security_id = '|| l_per_security_id);

     -- Set the database session context which also sets the org
     --Bug 9211154 - Pass l_security_group_id instead of l_per_security_id
     FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id,l_security_group_id);
     --FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id,l_per_security_id);

       WF_STANDARD.COMPARE(p_itemtype  ,
                           p_itemkey   ,
                           p_actid     ,
                           p_funcmode  ,
                           l_resultout );

           if (l_resultout = 'COMPLETE:EQ') then
                 p_result := 'COMPLETE:Y';
        elsif ((l_resultout = 'COMPLETE:LT') or
               (l_resultout = 'COMPLETE:GT') or
               (l_resultout  = 'COMPLETE:NULL')) then
                 p_result := 'COMPLETE:N';
        end if;

        return;

  ELSE
    p_result := 'COMPLETE:Y';
        return;

  END IF;


EXCEPTION
   WHEN OTHERS THEN NULL;
   WF_CORE.Context('PAY_US_WORKFLOW_API_PKG', 'IsResponseRequired',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
   RAISE;


END  IsResponseRequired;

--begin
--    hr_utility.trace_on(null,'PYWF');

END PAY_US_WORKFLOW_API_PKG;

/
