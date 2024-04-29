--------------------------------------------------------
--  DDL for Package Body IGP_VW_GEN_002_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGP_VW_GEN_002_PKG" AS
/* $Header: IGSPVWBB.pls 120.2 2006/01/27 01:56:00 bmerugu noship $ */

/* +=======================================================================+
   |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
   |                         All rights reserved.                          |
   +=======================================================================+
   |  NAME                                                                 |
   |    IGPVW01B.pls                                                       |
   |                                                                       |
   |  DESCRIPTION                                                          |
   |    This package provides service functions and procedures to          |
   |   support portfolio removal    WF                                     |
   |                                                                       |
   |  NOTES                                                                |
   |                                                                       |
   |  HISTORY                                                              |
   |    04-Mar-2004  ssawhney  Created                                      |
   |    17-Mar-2004  ssawhney  l_viewer_id was not assigned in Author event
        13-Apr-2004  ssawhney  removed 9i declaration dependancies.
   +=======================================================================+  */

PROCEDURE  Create_CC_Role(
 itemtype  IN  VARCHAR2,
 itemkey   IN  VARCHAR2
 ) AS

/*--------------------------------------------------------------------------
-- Created by : ssawhney
-- Purpose    : Get individual FND users holding Career Center Resp from the DB.
--              Form an Adhoc Role and Add each fnd user as a Role User.
--
-- History
---------------------------------------------------------------------------*/

l_error_message  VARCHAR2(500);

CURSOR c_career_center(cp_app_id IN NUMBER,cp_resp_key IN VARCHAR) IS
SELECT fnd.user_name
FROM   fnd_user fnd, fnd_responsibility_vl resp , fnd_user_resp_groups_direct rg
WHERE  rg.user_id = fnd.user_id AND
       rg.responsibility_id = resp.responsibility_id AND
       rg.responsibility_application_id = cp_app_id AND
       resp.responsibility_key = cp_resp_key ;


rec_career_center c_career_center%ROWTYPE;
l_role_name  VARCHAR2(100);
l_role_display_name VARCHAR2(100);


BEGIN

   fnd_message.set_name('IGS','IGP_VW_CC_TITLE'); -- Fetch the display name 'Career Administrator' from this message.
   l_role_display_name :=  fnd_message.get;
   l_role_name := 'IGPVW1VW'||itemkey;

   -- create adhoc role which will have all the fnd_users who have been assigned career center resp.
   -- so loop through the data and keep on adding them..

   Wf_Directory.CreateAdHocRole (
	  role_name         => l_role_name,
	  role_display_name => l_role_display_name   );

   FOR rec_career_center IN c_career_center(8405,'IGP_CAREER_CENTRE')
   LOOP
       -- get fnd user name, the Adhoc Role will send mail to FND USER.
        Wf_Directory.AddUsersToAdHocRole (
			  role_name  => l_role_name,
			  role_users => rec_career_center.user_name     );
   END LOOP;

   -- Set WF attrib for Role here.

      Wf_Engine.SetItemAttrText(
			  ItemType  =>  itemtype,
			  ItemKey   =>  itemkey,
			  aname     =>  'P_CC_ROLE',
			  avalue    =>  l_role_name     );


EXCEPTION
  WHEN others THEN
      l_error_message := sqlerrm;
      wf_core.context('igp_wf_gen_002_pkg','Create_CC_Role',itemtype,itemkey ,l_error_message);
      RAISE;


END Create_CC_Role;




PROCEDURE Write_CC_Message
(
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY CLOB,
    document_type IN OUT NOCOPY VARCHAR2
  ) AS
/*--------------------------------------------------------------------------
-- Created by : ssawhney
-- Purpose    : Proc written in a specific format to handle CLOB item attrib loading
--
-- History
---------------------------------------------------------------------------*/
    l_item_type        VARCHAR2(300);
    l_item_key         VARCHAR2(300);
    l_item             VARCHAR2(32000);
    l_message          VARCHAR2(32000);
    l_portfolio_ids    VARCHAR2(32000);

-- Start Local Procedure..

PROCEDURE Create_CC_Message_Html
( p_portfolio_ids IN VARCHAR2,
  p_message_text  OUT NOCOPY VARCHAR2
  )
IS
/*--------------------------------------------------------------------------
-- Created by : ssawhney
-- Purpose    : Proc written to generate the HTML message, generating the message outside the WriteCCMessage
--              was not working, so we had to move the code here.
-- History
---------------------------------------------------------------------------*/
   l_start_pos      NUMBER(10);
   l_end_pos        NUMBER(10);
   l_cur_pos        NUMBER(10);
   l_count          NUMBER(10);
   l_portfolio_ids  VARCHAR2(32000);
   l_basic_text     VARCHAR2(32000);
   l_port_id        NUMBER(10);


nbsp VARCHAR2(10) ;
CURSOR c_port_info(cp_port_ids IN NUMBER) IS
SELECT '<td align="center">'||(RPAD(NVL(port.portfolio_name, nbsp), 80))||'</td>'   name,
               '<td align="center">'||(RPAD(NVL(DECODE(port.pub_end_date,to_date('31/12/4172','dd/mm/yyyy'),NULL,port.pub_end_date),nbsp), 13))||'</td>'  pub_end_date,
               '<td align="center">'||(RPAD(NVL((hz.person_last_name||','||hz.person_first_name),nbsp), 360))||'</td>'  AUTHOR
FROM   igp_us_portfolios port, igp_ac_accounts acc, hz_parties hz
WHERE  port.account_id = acc.account_id AND
       acc.party_id = hz.party_id AND
       port.portfolio_id = cp_port_ids ;
       rec_port_info c_port_info%ROWTYPE;

BEGIN
l_basic_text :=' ';
nbsp := fnd_global.local_chr(38) || 'nbsp;';
l_portfolio_ids := p_portfolio_ids;

-- Get details of All Portfolios passed in the string.
-- LOOP and keep on adding into the HTML message

IF (l_portfolio_ids IS NOT NULL) THEN

  l_start_pos := 1;
  l_end_pos   := LENGTH(l_portfolio_ids);
  l_cur_pos   := 1;

  LOOP
    l_cur_pos := INSTR(l_portfolio_ids,',',l_start_pos,1);
    IF (l_cur_pos = 0) THEN
        l_port_id := SUBSTR(l_portfolio_ids, l_start_pos, l_end_pos - l_start_pos + 1);
    ELSE
        l_port_id := SUBSTR(l_portfolio_ids, l_start_pos, l_cur_pos - l_start_pos);
    END IF;

    OPEN c_port_info(l_port_id) ;
    FETCH c_port_info INTO rec_port_info;
    CLOSE c_port_info;

    l_basic_text := l_basic_text ||
		  '<tr>' ||
                  rec_port_info.name ||
		  rec_port_info.author   ||
		  rec_port_info.pub_end_date ||
		  '</tr>';

    IF (l_cur_pos = 0) THEN
        EXIT;    -- Exit loop
    END IF;

    l_start_pos := l_cur_pos + 1;

  END LOOP;
  -- close the HTML syntax for table.
  l_basic_text := l_basic_text ||'</table>';

END IF;

p_message_text :=l_basic_text;

-- exception case when no portfolio passed,
IF l_basic_text IS NULL THEN
    l_basic_text := '<tr'||'<\tr>'||'</table>';
    p_message_text := l_basic_text;
END IF;


EXCEPTION
  WHEN OTHERS THEN
  IF l_basic_text IS NULL THEN
    l_basic_text := '<tr'||'<\tr>'||'</table>';
    p_message_text := l_basic_text;
  END IF;

END Create_CC_Message_html;

-- End Local Procedure..


  BEGIN
    IF document_id IS NOT NULL THEN

      --Fetch the item Type, Item Key and Item Name from the passed Document ID.
      l_item_type := substr(document_id, 1, instr(document_id,':')-1);
      l_item_key  := substr (document_id, INSTR(document_id, ':') +1,  (INSTR(document_id, '*') - INSTR(document_id, ':'))-1) ;
      l_item := substr(document_id, instr(document_id,'*')+1);
      l_message := NULL;
      IF l_item IS NOT NULL THEN
        --
        -- If the Item Name is not null then get the value of the Portfolios to form the message again.
        --
        l_portfolio_ids := wf_engine.GetItemAttrText( itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'P_PORTFOLIO_IDS');
      END IF;


    END IF;

    -- call local procedure to generate the HTML message.

    Create_CC_Message_html(l_portfolio_ids,l_message);


    -- Write the header doc into CLOB variable
    WF_NOTIFICATION.WriteToClob(document, l_message);
  EXCEPTION
     WHEN OTHERS THEN
      l_message := sqlerrm;
      wf_core.context('igp_wf_gen_002_pkg','Write_CC_Message',l_item_type,l_item_key ,l_message);
      RAISE;

END Write_CC_Message;


PROCEDURE Get_Inform_Det (
    itemtype  IN  VARCHAR2,
    itemkey   IN  VARCHAR2,
    actid     IN  NUMBER  ,
    funcmode  IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2) AS
/*--------------------------------------------------------------------------
-- Created by : ssawhney
-- Purpose    : Workflow function call, this would handle the setting of all wf attributes.
--
-- History
---------------------------------------------------------------------------*/
l_error_message VARCHAR2(500);
l_sysdate DATE ;

BEGIN

IF (funcmode  = 'RUN') THEN

l_sysdate := SYSDATE+1;
    Create_CC_Role    ( itemtype => itemtype,
			itemkey  => itemkey			     );

    -- standard way to call PLSQLCLOB. Dont modify.
    wf_engine.setitemattrtext(ItemType  => itemtype,
                              ItemKey   => itemkey,
                              aname     => 'P_CC_MESSAGE',
                              avalue    => 'PLSQLCLOB:igp_vw_gen_002_pkg.write_cc_message/'||itemtype||':'||itemkey||'*P_CC_MESSAGE');

    wf_engine.setitemattrtext(ItemType  => itemtype,
                              ItemKey   => itemkey,
			      aname     => 'P_SYSDATE',
                              avalue    => l_sysdate);


    resultout := 'COMPLETE';

    RETURN;
END IF;

EXCEPTION
-- trap exceptions while setting workflow attribs..
   WHEN OTHERS THEN
   l_error_message := sqlerrm;
   wf_core.context('igp_wf_gen_002_pkg','Get_Viewer_Det',itemtype,itemkey ,l_error_message);
   RAISE;

END Get_Inform_Det;




PROCEDURE Raise_Removal_Event_CC
(
 p_viewer_id	IN	varchar2,
 p_portfolio_ids IN     varchar2,
 p_CC_user_name IN varchar2
) AS
/*--------------------------------------------------------------------------
-- Created by : ssawhney
-- Purpose    : Get individual Authors of the portfolio from the portfolios's list.
--              Get Viewers details.
--              Formulate a html message text to be sent to carer center for portfolio assignments removed from a viewer.
-- History
-- nsidana 4/22/2004 Populating the WF param for displaying the name of the CC while sending
--                                  access removal notification to CC / Author.
--
---------------------------------------------------------------------------*/
l_event_t             wf_event_t;
l_viewer_event        VARCHAR2(50);
l_seq_val_vw          VARCHAR2(100) ;
l_parameter_list_t wf_parameter_list_t;
l_error_message       VARCHAR2(500);

CURSOR c_viewer_info(cp_viewer_id IN NUMBER) IS
SELECT (hz.person_last_name||','||hz.person_first_name) VIEWER , us.user_name
FROM   hz_parties hz, fnd_user us, igp_ac_accounts ac
WHERE   ac.party_id = hz.party_id AND
	us.user_id=ac.user_id AND
        hz.party_id = cp_viewer_id;

-- Get the details of CC name.
CURSOR c_get_CC_name(cp_CC_user_name VARCHAR2)
IS
  SELECT  (hz.person_last_name||','||hz.person_first_name) CC_NAME
    FROM hz_parties hz,fnd_user fu
   WHERE fu.person_party_id=hz.party_id
     AND fu.user_name = cp_CC_user_name;

rec_viewer_info c_viewer_info%ROWTYPE;
l_cc_name  hz_parties.party_name%TYPE;

BEGIN

    l_seq_val_vw       := 'IGPVW2CC'||to_char(SYSDATE,'YYYYMMDDHH24MISS');
    l_viewer_event := 'oracle.apps.igs.igp.vw.inform_cc';
    --
    -- initialize the wf_event_t object
    --
    wf_event_t.initialize(l_event_t);

    --
    -- Adding the parameters to the parameter list
    --
    OPEN c_viewer_info(p_viewer_id) ;
    FETCH c_viewer_info INTO rec_viewer_info;
    CLOSE c_viewer_info;

    OPEN c_get_CC_name(p_CC_user_name);
    FETCH c_get_CC_name INTO l_cc_name;
    CLOSE c_get_CC_name;

    wf_event.addparametertolist( p_name    => 'P_VIEWER_NAME',
                                 p_value   =>  rec_viewer_info.viewer,
                                 p_parameterlist => l_parameter_list_t);
    wf_event.addparametertolist( p_name    => 'FROM',
                                 p_value   =>  rec_viewer_info.user_name,
                                 p_parameterlist => l_parameter_list_t);

    wf_event.addparametertolist( p_name    => 'P_VIEWER_ID',
                                 p_value   =>  p_viewer_id  ,
                                 p_parameterlist => l_parameter_list_t);

    wf_event.addparametertolist( p_name    => 'P_PORTFOLIO_IDS',
                                 p_value   =>  p_portfolio_ids,
                                 p_parameterlist => l_parameter_list_t);

    wf_event.addparametertolist( p_name    => 'P_ACTION',
                                 p_value   =>  'R',
                                 p_parameterlist => l_parameter_list_t);

    wf_event.addparametertolist( p_name    => 'P_SOURCE',
                                 p_value   =>  'CC',
                                 p_parameterlist => l_parameter_list_t);

   wf_event.addparametertolist( p_name    => 'P_CC_NAME',    -- nsidana 4/22/2004 : This param added to the WF to display the CC name when the notification for removal is sent to Author / CC.
                                      p_value   =>  l_cc_name,
                                      p_parameterlist => l_parameter_list_t);

    --Raise the events...
    wf_event.raise (p_event_name => l_viewer_event,
                    p_event_key  => l_seq_val_vw,
                    p_parameters => l_parameter_list_t);

    --
    -- Deleting the Parameter list after the event is raised
    --
    l_parameter_list_t.delete;

END Raise_Removal_Event_CC;

PROCEDURE Raise_Inform_Author_Event
(
 p_viewer_id	IN	varchar2,
 p_portfolio_ids IN     varchar2,
 p_CC_user_name IN varchar2
) AS
/*------------------------------------------------------------------------------------------------------------
-- Created by : ssawhney
-- Purpose    : Get individual Authors of the portfolio from the portfolios's list.
--              Get Viewers details.
--              Formulate a html message text to be sent to author for all portfolio removals.
-- History
--
-- nsidana 4/21/2004  Added a param to indicate if the workflow was called from
--                                   career center or viewer. This will send different messages
--                                   accordingly. This procedure is called from CC page,
--                                   so setting the WF param P_SOURCE as 'CC'
--
-- nsidana 4/22/2004 Populating the WF param for displaying the name of the CC while sending
--                                  access removal notification to CC / Author.
--
--------------------------------------------------------------------------------------------------------------*/
l_event_t          wf_event_t;
l_author_event        VARCHAR2(50);
l_seq_val_au          VARCHAR2(100);
l_parameter_list_t wf_parameter_list_t;
l_message_text        VARCHAR2(32000);

l_start_pos      NUMBER(10);
l_end_pos        NUMBER(10);
l_cur_pos        NUMBER(10);
l_count          NUMBER(10);
l_viewer_ids     VARCHAR2(32000);
l_viewer_id      hz_parties.party_id%TYPE;
l_portfolio_ids  VARCHAR2(32000);
l_basic_text     VARCHAR2(32000);

nbsp VARCHAR2(10);

CURSOR c_port_info(cp_port_ids IN NUMBER) IS
SELECT port.portfolio_name, fnd.user_name
FROM   igp_us_portfolios port, igp_ac_accounts acc, fnd_user fnd
WHERE  port.account_id = acc.account_id AND
       fnd.user_id = acc.user_id AND
       port.portfolio_id = cp_port_ids;

CURSOR c_viewer_info(cp_viewer_id IN NUMBER) IS
SELECT (hz.person_last_name||','||hz.person_first_name) VIEWER  ,  us.user_name,us.email_address
FROM   hz_parties hz, fnd_user us, igp_ac_accounts ac
WHERE   ac.party_id = hz.party_id AND
	us.user_id=ac.user_id AND
        hz.party_id = cp_viewer_id;

-- Get the details of CC name.
CURSOR c_get_CC_name(cp_CC_user_name VARCHAR2)
IS
  SELECT  (hz.person_last_name||','||hz.person_first_name) CC_NAME
    FROM hz_parties hz,fnd_user fu
   WHERE fu.person_party_id=hz.party_id
     AND fu.user_name = cp_CC_user_name;


rec_viewer_info c_viewer_info%ROWTYPE;
rec_port_info c_port_info%ROWTYPE;
l_stmt varchar2(32000);
l_port_id  NUMBER(15);
l_cc_name  hz_parties.party_name%TYPE;

BEGIN

    l_seq_val_au     := 'IGPVW2AU'||to_char(SYSDATE,'YYYYMMDDHH24MISS');
    l_basic_text     :=null;
    nbsp  := fnd_global.local_chr(38) || 'nbsp;';
    l_author_event := 'oracle.apps.igs.igp.vw.inform_author_rem';
    --
    -- initialize the wf_event_t object
    --
    wf_event_t.initialize(l_event_t);

    --
    -- Adding the parameters to the parameter list
    --
    -- call the package to make a static message.
    --

    l_viewer_id := p_viewer_id;
    OPEN c_viewer_info(l_viewer_id) ;
    FETCH c_viewer_info INTO rec_viewer_info;
    CLOSE c_viewer_info;

    OPEN c_get_CC_name(p_CC_user_name);
    FETCH c_get_CC_name INTO l_cc_name;
    CLOSE c_get_CC_name;


    wf_event.addparametertolist( p_name    => 'P_VIEWER_NAME',
                                 p_value   =>  rec_viewer_info.viewer,
                                 p_parameterlist => l_parameter_list_t);
    wf_event.addparametertolist( p_name    => 'P_VIEWER_EMAIL',
                                 p_value   =>  rec_viewer_info.email_address,
                                 p_parameterlist => l_parameter_list_t);
    wf_event.addparametertolist( p_name    => 'FROM',
                                 p_value   =>  rec_viewer_info.user_name,
                                 p_parameterlist => l_parameter_list_t);


    -- loop for items in the Portfolio List...get individual author and the portfolio name.
    -- raise multiple BEs, cause we want to show author and portfolio information both
    -- hence we can not have the ADHOC role logic here.

   l_portfolio_ids:= p_portfolio_ids;

   l_start_pos := 1;
   l_end_pos   := LENGTH(l_portfolio_ids);
   l_cur_pos   := 1;

   IF (l_portfolio_ids IS NOT NULL) THEN
      LOOP

         l_cur_pos := INSTR(l_portfolio_ids,',',l_start_pos,1);
         IF (l_cur_pos = 0) THEN
            l_port_id := SUBSTR(l_portfolio_ids, l_start_pos, l_end_pos - l_start_pos + 1);
         ELSE
            l_port_id := SUBSTR(l_portfolio_ids, l_start_pos, l_cur_pos - l_start_pos);
         END IF;

         OPEN c_port_info(l_port_id);
	 FETCH c_port_info INTO rec_port_info;
	 CLOSE c_port_info;

         wf_event.addparametertolist( p_name    => 'P_PORT_NAME',
                                      p_value   =>  rec_port_info.portfolio_name,
                                      p_parameterlist => l_parameter_list_t);

	 wf_event.addparametertolist( p_name    => 'P_AUTHOR_ROLE',
                                      p_value   =>  rec_port_info.user_name,
                                      p_parameterlist => l_parameter_list_t);

	 wf_event.addparametertolist( p_name    => 'P_SOURCE',         -- nsidana 4/21/2004 : This param P_SOURCE indicates if the Viewer / Career Center removed the Portfolio Access. As this procedure
                                      p_value   =>  'CC',                                          -- is called only from the SS page, I am defaulting this value to 'CC'. The viewer page does not call this procedure. It directly raises the
                                      p_parameterlist => l_parameter_list_t);      -- BE, so we have set this param there in the Java code. (File : AssignPortfolioSearchAMImpl.java

   wf_event.addparametertolist( p_name    => 'P_CC_NAME',    -- nsidana 4/22/2004 : This param added to the WF to display the CC name when the notification for removal is sent to Author / CC.
                                      p_value   =>  l_cc_name,
                                      p_parameterlist => l_parameter_list_t);

         --Raise the event...
         wf_event.raise ( p_event_name => l_author_event,
                          p_event_key  => l_seq_val_au,
                          p_parameters => l_parameter_list_t);

	 IF (l_cur_pos = 0) THEN
            EXIT;    -- Exit loop
         END IF;

	 l_start_pos := l_cur_pos + 1;
      END LOOP;
   END IF;
    --
    -- Deleting the Parameter list after the event is raised
    --
   l_parameter_list_t.delete;


END Raise_Inform_Author_Event;



PROCEDURE Get_Author_Det (
    itemtype  IN  VARCHAR2,
    itemkey   IN  VARCHAR2,
    actid     IN  NUMBER  ,
    funcmode  IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2) AS
/*--------------------------------------------------------------------------
-- Created by : ssawhney
-- Purpose    : Workflow function call, this would handle the setting of all wf attributes. for the Author BE.
--
-- History
---------------------------------------------------------------------------*/
l_message VARCHAR2(500);
l_sysdate DATE ;

BEGIN

IF (funcmode  = 'RUN') THEN
l_sysdate:= SYSDATE+1;

    wf_engine.setitemattrtext(ItemType  => itemtype,
                              ItemKey   => itemkey,
			      aname     => 'P_SYSDATE',
                              avalue    => l_sysdate);
    resultout := 'COMPLETE';

    RETURN;
END IF;

EXCEPTION

   WHEN OTHERS THEN
   l_message := sqlerrm;
   wf_core.context('igp_wf_gen_002_pkg','Get_Author_Det',itemtype,itemkey ,l_message);
   RAISE;

END Get_Author_Det;


PROCEDURE chk_action (
    itemtype  IN  VARCHAR2,
    itemkey   IN  VARCHAR2,
    actid     IN  NUMBER  ,
    funcmode  IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2)
AS

l_action VARCHAR2(1);

BEGIN
    l_action   :=null;
    l_action   :=null;
    l_action   := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_ACTION');
    IF  (l_action = 'A' ) THEN
          resultout := 'COMPLETE:A';
    ELSIF (l_action = 'R' ) THEN
              resultout := 'COMPLETE:R';
    END IF;
    RETURN;
EXCEPTION
WHEN OTHERS THEN
NULL;
END chk_action;

-- this raise the inform CC for invalid Assignments.
PROCEDURE Raise_invalid_assign_Event_CC(
 p_invalid_assignments	IN	varchar2
)
AS

l_event_t             wf_event_t;
l_viewer_event        VARCHAR2(50);
l_seq_val_vw          VARCHAR2(100);
l_parameter_list_t wf_parameter_list_t;
l_error_message       VARCHAR2(500);
BEGIN
    l_viewer_event := 'oracle.apps.igs.igp.vw.inform_cc';
    l_seq_val_vw       := 'IGPVW2CC'||to_char(SYSDATE,'YYYYMMDDHH24MISS');
    --
    -- initialize the wf_event_t object
    --
    wf_event_t.initialize(l_event_t);

    wf_event.addparametertolist( p_name    => 'P_INVALID_ASSIGN_LIST',
                             p_value   => p_invalid_assignments,
                             p_parameterlist => l_parameter_list_t);

    wf_event.addparametertolist( p_name    => 'P_ACTION',
                                 p_value   =>  'A',
                                 p_parameterlist => l_parameter_list_t);

    --Raise the events...
    wf_event.raise (p_event_name => l_viewer_event,
                    p_event_key  => l_seq_val_vw,
                    p_parameters => l_parameter_list_t);

    --
    -- Deleting the Parameter list after the event is raised
    --
    l_parameter_list_t.delete;

END Raise_invalid_assign_Event_CC;

PROCEDURE Write_CC_invalid_assign_Mes
(
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY CLOB,
    document_type IN OUT NOCOPY VARCHAR2
  ) AS
/*--------------------------------------------------------------------------
-- Created by : nsidana
-- Purpose    : Proc written in a specific format to handle CLOB item attrib loading
--
-- History
---------------------------------------------------------------------------*/
    l_item_type      VARCHAR2(300);
    l_item_key       VARCHAR2(300);
    l_item                VARCHAR2(32000);
    l_message        VARCHAR2(32000);
    l_str                   VARCHAR2(32000);

-- Start Local Procedure..

PROCEDURE build_invalid_assign_message
( p_invalid_list IN VARCHAR2,
  p_message_text  OUT NOCOPY VARCHAR2
  )
IS
   -- Get the details of portfolio.
   CURSOR c_get_port_name(cp_port_id VARCHAR2) IS
     SELECT portfolio_name
       FROM igp_us_portfolios
      WHERE portfolio_id=to_number(cp_port_id);
   -- Get the name of the viewer.
   CURSOR c_get_viewer_name(cp_party_id VARCHAR2) IS
     SELECT person_last_name||', '||person_first_name
       FROM hz_parties
      WHERE party_id=to_number(cp_party_id);

    l_str varchar2(2000);
    l_length number;
    l_substr varchar2(200);
    l_pos number;
    l_viewer varchar2(200);
    l_port varchar2(200);
    l_line varchar2(2000);
    l_message_text varchar2(32000);
    l_port_name varchar2(50);
    l_v_name   varchar2(50);
    l_err varchar2(2000);
BEGIN
     l_str:=p_invalid_list;
     l_message_text :='';
    LOOP
              l_length := length(l_str);
              l_pos:=0;
              l_pos := INSTR(l_str,'#',1);

              IF (l_pos = 0) THEN
                    EXIT;
              END IF;

              l_substr := substr(l_str,1,l_pos-1);
              l_port  :=substr(l_substr,1,(instr(l_substr,',',1)-1));
               l_viewer :=substr(l_substr,instr(l_substr,',',1)+1);

              OPEN c_get_viewer_name(l_viewer);
              FETCH c_get_viewer_name INTO l_v_name;
              CLOSE c_get_viewer_name;

              OPEN c_get_port_name(l_port);
              FETCH c_get_port_name INTO l_port_name;
              CLOSE c_get_port_name;

              l_line:=null;
              l_line:='<tr><td align=center> '||l_v_name ||'</td><td align=center>'||l_port_name||'</td></tr>';
              l_message_text:=l_message_text||l_line;
              l_str := substr(l_str,l_pos+1,length(l_str));
    END LOOP;

    l_port  :=substr(l_str,1,(instr(l_str,',',1)-1));
    l_viewer :=substr(l_str,instr(l_str,',',1)+1);

    OPEN c_get_viewer_name(l_viewer);
    FETCH c_get_viewer_name INTO l_v_name;
    CLOSE c_get_viewer_name;

    OPEN c_get_port_name(l_port);
    FETCH c_get_port_name INTO l_port_name;
    CLOSE c_get_port_name;
    l_line:=null;
    l_line:='<tr><td align=center> '||l_v_name ||'</td><td align=center>'||l_port_name||'</td></tr>';
    l_message_text:=l_message_text||l_line;

    p_message_text := l_message_text;
EXCEPTION
WHEN OTHERS THEN
l_err :=sqlerrm;
 wf_core.context('igp_wf_gen_002_pkg','Write_CC_invalid_assign_Mes',l_item_type,l_item_key ,l_err);


END build_invalid_assign_message;
-- End Local Procedure..
  BEGIN
    IF document_id IS NOT NULL THEN
      --Fetch the item Type, Item Key and Item Name from the passed Document ID.
      l_item_type := substr(document_id, 1, instr(document_id,':')-1);
      l_item_key  := substr (document_id, INSTR(document_id, ':') +1,  (INSTR(document_id, '*') - INSTR(document_id, ':'))-1) ;
      l_item := substr(document_id, instr(document_id,'*')+1);
      l_message := NULL;
      IF l_item IS NOT NULL THEN
        --
        -- If the Item Name is not null then get the value of the invalid assignments to form the message again.
        --
        l_str := wf_engine.GetItemAttrText( itemtype => l_item_type, itemkey  => l_item_key, aname    => 'P_INVALID_ASSIGN_LIST');
      END IF;
    END IF;
    -- call local procedure to generate the HTML message.
        build_invalid_assign_message(l_str,l_message);
      -- Write the header doc into CLOB variable
          WF_NOTIFICATION.WriteToClob(document, l_message);
  EXCEPTION
     WHEN OTHERS THEN
      l_message := sqlerrm;
      wf_core.context('igp_wf_gen_002_pkg','Write_CC_invalid_assign_Mes',l_item_type,l_item_key ,l_message);
      RAISE;

END Write_CC_invalid_assign_Mes;

PROCEDURE Get_invalid_assign_Det (
    itemtype  IN  VARCHAR2,
    itemkey   IN  VARCHAR2,
    actid     IN  NUMBER  ,
    funcmode  IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2) AS
/*--------------------------------------------------------------------------
-- Created by : nsidana
-- Purpose    : Workflow function call, this would handle the setting of all wf attributes.
--
-- History
---------------------------------------------------------------------------*/
l_error_message VARCHAR2(500);
l_sysdate DATE;

BEGIN

IF (funcmode  = 'RUN') THEN
l_sysdate := SYSDATE;
    Create_CC_Role    ( itemtype => itemtype,
			itemkey  => itemkey			     );


    -- standard way to call PLSQLCLOB. Dont modify.
    wf_engine.setitemattrtext(ItemType  => itemtype,
                              ItemKey   => itemkey,
                              aname     => 'P_MESSAGE_TEXT',
                              avalue    => 'PLSQLCLOB:igp_vw_gen_002_pkg.Write_CC_invalid_assign_Mes/'||itemtype||':'||itemkey||'*P_MESSAGE_TEXT');
   resultout := 'COMPLETE';

    RETURN;
END IF;

EXCEPTION
-- trap exceptions while setting workflow attribs..
   WHEN OTHERS THEN
   l_error_message := sqlerrm;
   wf_core.context('igp_wf_gen_002_pkg','Get_Viewer_Det',itemtype,itemkey ,l_error_message);
   RAISE;

END Get_invalid_assign_Det;

 PROCEDURE CHK_SOURCE (itemtype  IN  VARCHAR2,
                                                       itemkey   IN  VARCHAR2,
                                                       actid     IN  NUMBER  ,
                                                       funcmode  IN  VARCHAR2,
                                                       resultout OUT NOCOPY VARCHAR2)
AS
  l_source VARCHAR2(2);                          -- This will just hold either the value CC or VW.
  l_error_message VARCHAR2(5000);

BEGIN
    IF (funcmode  = 'RUN') THEN
         l_source := null;
         l_source := wf_engine.GetItemAttrText( itemtype => itemtype,itemkey  => itemkey,aname    => 'P_SOURCE');
         IF (l_source = 'CC') THEN
                  resultout := 'COMPLETE:CC';          -- Path 1 : Career Center removed the access.
         ELSIF (l_source = 'VW') THEN
                     resultout := 'COMPLETE:VW';            -- Path 2 : Viewer removed the access.
         END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
      l_error_message := sqlerrm;
      wf_core.context('igp_wf_gen_002_pkg','chk_source',itemtype,itemkey ,l_error_message);
      RAISE;
END CHK_SOURCE;

END IGP_VW_GEN_002_PKG;

/
