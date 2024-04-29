--------------------------------------------------------
--  DDL for Package Body IGP_VW_GEN_001_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGP_VW_GEN_001_PKG" AS
/* $Header: IGSPVWAB.pls 120.0 2005/06/02 04:25:27 appldev noship $ */

/* +=======================================================================+
   |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
   |                         All rights reserved.                          |
   +=======================================================================+
   |  NAME                                                                 |
   |    IGPVW01B.pls                                                       |
   |                                                                       |
   |  DESCRIPTION                                                          |
   |    This package provides service functions and procedures to          |
   |   support Portfolio Assignments WF                                    |
   |                                                                       |
   |  NOTES                                                                |
   |                                                                       |
   |  HISTORY                                                              |
   |    04-APR-2001  ssawhney Created                                      |
   |                 ssawhney removed 9i declaration dependancies.
   +=======================================================================+  */

PROCEDURE  Create_Viewers_Role(
 itemtype  IN  VARCHAR2,
 itemkey   IN  VARCHAR2,
 p_viewer_ids	IN	varchar2,
 p_portfolio_ids IN     varchar2 ) AS

/*--------------------------------------------------------------------------
-- Created by : ssawhney
-- Purpose    : Get individual Viewers from the viewer's list.
--              Form an Adhoc Role and Add each viewer as a Role User.
--
-- History
---------------------------------------------------------------------------*/

   l_start_pos      NUMBER(10);
   l_end_pos        NUMBER(10);
   l_cur_pos        NUMBER(10);
   l_count          NUMBER(10);
   l_viewer_ids     VARCHAR2(32000);
   l_viewer_id      hz_parties.party_id%TYPE;
   l_status         VARCHAR2(1) ;
   l_port_name      VARCHAR2(80);
   l_author         VARCHAR2(360);
   l_pub_end_date   VARCHAR2(20);
   l_error_message  VARCHAR2(500);

CURSOR c_viewer(cp_viewer IN NUMBER) IS
SELECT fnd.user_name VIEWER
FROM   fnd_user fnd, igp_ac_accounts acc
WHERE  acc.user_id = fnd.user_id AND acc.party_id = cp_viewer;

rec_viewer c_viewer%ROWTYPE;
l_stmt varchar2(32000);
l_port_id  NUMBER(15);
l_role_name  VARCHAR2(100);
l_role_display_name VARCHAR2(100) ;
l_cc_users VARCHAR2(100);

BEGIN
   l_role_display_name  := 'Adhoc Role for Viewer of Portfolios';
   l_cc_users  := 'SYSADMIN';
   l_status     :='S';
   l_viewer_ids :=p_viewer_ids;

   l_start_pos := 1;
   l_end_pos   := LENGTH(l_viewer_ids);
   l_cur_pos   := 1;

   l_role_name := 'IGPVW1VW'||itemkey;

   -- create adhoc role which will have all the viewers who have been assigned.
   -- so loop through the viewers list and keep on adding them..

   Wf_Directory.CreateAdHocRole (
	  role_name         => l_role_name,
	  role_display_name => l_role_display_name   );


   IF (l_viewer_ids IS NOT NULL) THEN

      LOOP

         l_cur_pos := INSTR(l_viewer_ids,',',l_start_pos,1);
         IF (l_cur_pos = 0) THEN
            l_viewer_id := SUBSTR(l_viewer_ids, l_start_pos, l_end_pos - l_start_pos + 1);
         ELSE
            l_viewer_id := SUBSTR(l_viewer_ids, l_start_pos, l_cur_pos - l_start_pos);
         END IF;

         -- get fnd user name, the Adhoc Role will send mail to FND USER.

         OPEN c_viewer(l_viewer_id);
	 FETCH c_viewer INTO rec_viewer;
	 EXIT WHEN c_viewer%NOTFOUND;
	 CLOSE c_viewer;

	 Wf_Directory.AddUsersToAdHocRole (
			  role_name  => l_role_name,
			  role_users => rec_viewer.viewer     );



	 IF (l_cur_pos = 0) THEN
            EXIT;    -- Exit loop
         END IF;

	 l_start_pos := l_cur_pos + 1;


      END LOOP;

      -- Set WF attrib for Role here.

      Wf_Engine.SetItemAttrText(
			  ItemType  =>  itemtype,
			  ItemKey   =>  itemkey,
			  aname     =>  'P_VIEWER_ROLE',
			  avalue    =>  l_role_name     );
      Wf_Engine.SetItemAttrText(
			  ItemType  =>  itemtype,
			  ItemKey   =>  itemkey,
			  aname     =>  'FROM',
			  avalue    =>  l_cc_users     );

   END IF;


EXCEPTION
  WHEN others THEN
      l_error_message := sqlerrm;
      wf_core.context('igp_wf_gen_001_pkg','Create_Viewers_Role',itemtype,itemkey ,l_error_message);
      RAISE;


END Create_Viewers_Role;




PROCEDURE Write_Viewer_Message
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
    l_item             VARCHAR2(300);
    l_message          VARCHAR2(32000);
    l_portfolio_ids    VARCHAR2(32000);
    l_exp_date         VARCHAR2(20);
-- Start Local Procedure..

PROCEDURE Create_Viewers_Message_Html
( p_portfolio_ids IN VARCHAR2,
  p_expdate       IN VARCHAR2,
  p_message_text  OUT NOCOPY VARCHAR2
  )
IS
/*--------------------------------------------------------------------------
-- Created by : ssawhney
-- Purpose    : Proc written to generate the HTML message, generating the message outside the WriteAuthMessage
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


-- if the expiry date is passed, then dont query for it and add it in the table html syntax in the query itself.
nbsp VARCHAR2(10) ;
CURSOR c_port_info(cp_port_ids IN NUMBER) IS
SELECT '<td align="center">'||(RPAD(NVL(port.portfolio_name, nbsp), 80))||'</td>'   name,
       '<td align="center">'||(RPAD(NVL(NVL(p_expdate,' '),nbsp), 13))||'</td>'  pub_end_date,
       '<td align="center">'||(RPAD(NVL((hz.person_last_name||','||hz.person_first_name),nbsp), 360))||'</td>'  AUTHOR
FROM   igp_us_portfolios port, igp_ac_accounts acc, hz_parties hz
WHERE  port.account_id = acc.account_id AND
       acc.party_id = hz.party_id AND
       port.portfolio_id = cp_port_ids ;
rec_port_info c_port_info%ROWTYPE;

BEGIN
l_basic_text :=' ';
nbsp  := fnd_global.local_chr(38) || 'nbsp;';
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
		  rec_port_info.author ||
		  rec_port_info.pub_end_date
		  ||'</tr>';

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

END Create_Viewers_Message_html;

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
        -- if the event is raised when the author assigns the end date, then p_expdate parameter will be recieved.
	-- else if the access is given by the Career Center then the p_expdate will be NULL.

        l_exp_date := wf_engine.GetItemAttrText( itemtype => l_item_type,
                                                 itemkey  => l_item_key,
                                                 aname    => 'P_EXPDATE');
      END IF;


    END IF;

    -- call local procedure to generate the HTML message.

    Create_Viewers_Message_html(l_portfolio_ids,l_exp_date,l_message);


    -- Write the header doc into CLOB variable
    WF_NOTIFICATION.WriteToClob(document, l_message);
  EXCEPTION
     WHEN OTHERS THEN
      l_message := sqlerrm;
      wf_core.context('igp_wf_gen_001_pkg','Write_Viewer_Message',l_item_type,l_item_key ,l_message);
      RAISE;

END Write_Viewer_Message;


PROCEDURE Get_Viewer_Inform_Det (
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
l_sysdate DATE;

BEGIN
l_sysdate := SYSDATE;
IF (funcmode  = 'RUN') THEN

    Create_Viewers_Role    (itemtype => itemtype,
			    itemkey  => itemkey,
			    p_viewer_ids => wf_engine.getitemattrtext(itemtype,itemkey,'P_VIEWER_IDS'),
			    p_portfolio_ids => wf_engine.getitemattrtext(itemtype,itemkey,'P_PORTFOLIO_IDS') );

    -- standard way to call PLSQLCLOB. Dont modify.
    wf_engine.setitemattrtext(ItemType  => itemtype,
                              ItemKey   => itemkey,
                              aname     => 'P_VIEWER_MESSAGE',
                              avalue    => 'PLSQLCLOB:igp_vw_gen_001_pkg.write_viewer_message/'||itemtype||':'||itemkey||'*P_VIEWER_MESSAGE');

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
   wf_core.context('igp_wf_gen_001_pkg','Get_Viewer_Inform_Det',itemtype,itemkey ,l_error_message);
   RAISE;

END Get_Viewer_Inform_Det;




PROCEDURE Raise_Assign_Event
(
 p_viewer_ids	IN	varchar2,
 p_portfolio_ids IN     varchar2,
 p_access_exp_date IN   varchar2
) AS
/*--------------------------------------------------------------------------
-- Created by : ssawhney
-- Purpose    : Get individual Authors of the portfolio from the portfolios's list.
--              Get Viewers details.
--              Formulate a html message text to be sent to author for all viewers that got assigned to his portfolio.
-- History
---------------------------------------------------------------------------*/

CURSOR c_get_seq_val
IS
select igp_ac_bus_events_s.nextval
from dual;

l_event_t             wf_event_t;
l_viewer_event        VARCHAR2(50);
l_seq_val_vw          VARCHAR2(100);
l_parameter_list_t wf_parameter_list_t;
l_error_message       VARCHAR2(500);
l_seq_val number;

BEGIN

    l_viewer_event := 'oracle.apps.igs.igp.vw.informviewer';
    OPEN c_get_seq_val;
    FETCH c_get_seq_val INTO l_seq_val;
    CLOSE c_get_seq_val;
    l_seq_val_vw:=to_char(l_seq_val);
    --
    -- initialize the wf_event_t object
    --
    wf_event_t.initialize(l_event_t);

    --
    -- Adding the parameters to the parameter list
    --
    wf_event.addparametertolist( p_name    => 'P_VIEWER_IDS',
                                 p_value   =>  p_viewer_ids  ,
                                 p_parameterlist => l_parameter_list_t);

    wf_event.addparametertolist( p_name    => 'P_PORTFOLIO_IDS',
                                 p_value   =>  p_portfolio_ids,
                                 p_parameterlist => l_parameter_list_t);

    wf_event.addparametertolist( p_name    => 'P_EXPDATE',
                                 p_value   =>  p_access_exp_date,
                                 p_parameterlist => l_parameter_list_t);

    --Raise the events...
    wf_event.raise (p_event_name => l_viewer_event,
                    p_event_key  => l_seq_val_vw,
                    p_parameters => l_parameter_list_t);

    --
    -- Deleting the Parameter list after the event is raised
    --
    l_parameter_list_t.delete;


END Raise_Assign_Event;




PROCEDURE Create_Author_Message
( p_viewer_ids IN VARCHAR2,
  p_message_text OUT NOCOPY VARCHAR) AS
 /*--------------------------------------------------------------------------
-- Created by : ssawhney
-- Purpose    : Create a Static HTML message for AUTHOR.
--
-- History
---------------------------------------------------------------------------*/
   l_start_pos      NUMBER(10);
   l_end_pos        NUMBER(10);
   l_cur_pos        NUMBER(10);
   l_count          NUMBER(10);
   l_viewer_ids     VARCHAR2(32000);
   l_viewer_id      hz_parties.party_id%TYPE;
   l_basic_text     VARCHAR2(32000) ;

nbsp VARCHAR2(10) ;

CURSOR c_viewer_info(cp_viewer IN NUMBER) IS
SELECT '<td align="left">'||(RPAD(NVL((hz.person_last_name||','||hz.person_first_name),nbsp), 360))||'</td>' VIEWER,
       '<td align="left"><a href=mailto:'|| fu.email_address||'>'||fu.email_address||'</a></td>' EMAIL
FROM   hz_parties hz,
       fnd_user fu,
       igp_ac_accounts acc
WHERE  hz.party_id = cp_viewer
AND    acc.party_id=hz.party_id
AND    acc.user_id = fu.user_id;

rec_viewer_info c_viewer_info%ROWTYPE;

BEGIN

nbsp := fnd_global.local_chr(38) || 'nbsp;';

l_viewer_ids :=p_viewer_ids;

-- LOOP through all viewer passed in the contacte-nated string. get details of individual and form a HTML text.
IF (l_viewer_ids IS NOT NULL) THEN

  l_start_pos := 1;
  l_end_pos   := LENGTH(l_viewer_ids);
  l_cur_pos   := 1;

  LOOP

    l_cur_pos := INSTR(l_viewer_ids,',',l_start_pos,1);

    IF (l_cur_pos = 0) THEN
        l_viewer_id := SUBSTR(l_viewer_ids, l_start_pos, l_end_pos - l_start_pos + 1);
    ELSE
        l_viewer_id := SUBSTR(l_viewer_ids, l_start_pos, l_cur_pos - l_start_pos);
    END IF;

    OPEN c_viewer_info(l_viewer_id) ;
    FETCH c_viewer_info INTO rec_viewer_info;
    CLOSE c_viewer_info;

    l_basic_text := l_basic_text ||'<tr>' || rec_viewer_info.viewer||rec_viewer_info.email ||'</tr>';

    IF (l_cur_pos = 0) THEN
        EXIT;    -- Exit loop
    END IF;

    l_start_pos := l_cur_pos + 1;

  END LOOP;

  -- close the HTML syntax for table.
  l_basic_text := l_basic_text ||'</table>';
  p_message_text := l_basic_text;
END IF;

IF l_basic_text IS NULL THEN
   l_basic_text := '<tr>'||'<\tr>'||'</table>';
   p_message_text := l_basic_text;
END IF;

EXCEPTION
  WHEN OTHERS THEN
  IF l_basic_text IS NULL THEN
    l_basic_text := '<tr'||'<\tr>'||'</table>';
    p_message_text := l_basic_text;
  END IF;

END Create_Author_Message;


PROCEDURE Raise_Inform_Author_Event
(
 p_viewer_ids	IN	varchar2,
 p_portfolio_ids IN     varchar2
) AS
/*--------------------------------------------------------------------------
-- Created by : ssawhney
-- Purpose    : Get individual Authors of the portfolio from the portfolios's list.
--              Get Viewers details.
--              Formulate a html message text to be sent to author for all viewers that got assigned to his portfolio.
-- History
---------------------------------------------------------------------------*/

CURSOR c_get_seq_val
IS
select igp_ac_bus_events_s.nextval
from dual;

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
l_seq_num number;

nbsp VARCHAR2(10);

CURSOR c_port_info(cp_port_ids IN NUMBER) IS
SELECT port.portfolio_name, fnd.user_name
FROM   igp_us_portfolios port, igp_ac_accounts acc, fnd_user fnd
WHERE  port.account_id = acc.account_id AND
       fnd.user_id = acc.user_id AND
       port.portfolio_id = cp_port_ids ;

rec_port_info c_port_info%ROWTYPE;
l_stmt varchar2(32000);
l_port_id  NUMBER(15);

BEGIN
    nbsp  := fnd_global.local_chr(38) || 'nbsp;';

    l_author_event := 'oracle.apps.igs.igp.vw.informauthor';

    OPEN c_get_seq_val;
    FETCH c_get_seq_val INTO l_seq_num;
    CLOSE c_get_seq_val;
    l_seq_val_au:=to_char(l_seq_num);

    --
    -- initialize the wf_event_t object
    --
    wf_event_t.initialize(l_event_t);

    --
    -- Adding the parameters to the parameter list
    --
    -- call the package to make a static message.
    --

    Create_Author_Message(p_viewer_ids,l_message_text);

    wf_event.addparametertolist( p_name    => 'P_MESSAGE_TEXT',
                                 p_value   =>  l_message_text,
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



PROCEDURE Write_Author_Message
(
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY CLOB,
    document_type IN OUT NOCOPY VARCHAR2
  ) AS
/*--------------------------------------------------------------------------
-- Created by : ssawhney
-- Purpose    : Standard format of proc, to be used to write CLOB into Attribute to be picked by Notification.
--              See workflow standards for more details
-- History
---------------------------------------------------------------------------*/
l_item_type  VARCHAR2(100);
l_item_key   VARCHAR2(100);
l_item       VARCHAR2(100);
l_message_text  VARCHAR2(32000);
BEGIN

  l_item_type := substr(document_id, 1, instr(document_id,':')-1);
  l_item_key  := substr (document_id, INSTR(document_id, ':') +1,  (INSTR(document_id, '*') - INSTR(document_id, ':'))-1) ;
  l_item := substr(document_id, instr(document_id,'*')+1);

  l_message_text  := wf_engine.GetItemAttrText( itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'P_MESSAGE_TEXT');
    -- Write the header doc into CLOB variable
    WF_NOTIFICATION.WriteToClob(document, l_message_text);

EXCEPTION
    WHEN OTHERS THEN
      l_message_text := sqlerrm;
      wf_core.context('igp_wf_gen_001_pkg','Write_Author_Message',l_item_type,l_item_key ,l_message_text);
      RAISE;
END Write_Author_Message;


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
l_users VARCHAR2(30);
BEGIN

l_sysdate := SYSDATE;
l_users :='SYSADMIN';

IF (funcmode  = 'RUN') THEN

    -- standard way to write a CLOB in workflow. dont change.
    wf_engine.setitemattrtext(ItemType  => itemtype,
                              ItemKey   => itemkey,
                              aname     => 'P_AUTHOR_MESSAGE',
                              avalue    => 'PLSQLCLOB:igp_vw_gen_001_pkg.write_author_message/'||itemtype||':'||itemkey||'*P_AUTHOR_MESSAGE');

    wf_engine.setitemattrtext(ItemType  => itemtype,
                              ItemKey   => itemkey,
			      aname     => 'P_SYSDATE',
                              avalue    => l_sysdate);
    Wf_Engine.SetItemAttrText(
			  ItemType  =>  itemtype,
			  ItemKey   =>  itemkey,
			  aname     =>  'FROM',
			  avalue    =>  l_users     );



    resultout := 'COMPLETE';

    RETURN;
END IF;

EXCEPTION

   WHEN OTHERS THEN
   l_message := sqlerrm;
   wf_core.context('igp_wf_gen_001_pkg','Get_Author_Det',itemtype,itemkey ,l_message);
   RAISE;

END Get_Author_Det;



END IGP_VW_GEN_001_PKG;

/
