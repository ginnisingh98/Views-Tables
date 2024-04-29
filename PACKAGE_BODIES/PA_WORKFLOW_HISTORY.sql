--------------------------------------------------------
--  DDL for Package Body PA_WORKFLOW_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_WORKFLOW_HISTORY" as
/* $Header: PAWFHSUB.pls 120.3.12010000.3 2009/10/12 05:55:31 rmandali ship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+

 FILE NAME   : PAWFHSUB.pls
 DESCRIPTION :



 HISTORY     : 08/19/02 SYAO Initial Creation
               05-Aug-2005 raluthra Bug 4527617: Replaced fnd_user.customer_id with
                                    fnd_user.person_party_id for R12 ATG Mandate Fix.
	       18-Aug-2005 avaithia Bug 4537865 : NOCOPY Mandate Changes.
	       21-Apr-2006 avaithia Bug 5178531 : SWAN Changes
				    Changed these color codes :
				    replaced #cccc99 with #cfe0f1
				    Replaced #336699 with #3c3c3c
				    Replaced #f7f7e7 with #f2f2f5
				    Default Font Preference made as Tahoma
               23-Jul-2009 rmandali Bug 7538477 : Modified the PROCEDURE show_history
                              to incorporate the Hijrah/Thai calendar support.
               12-Oct-2009 rmandali Bug 8974192 : Added a nvl condition for the
                                    calendar support.
=============================================================================*/

  G_USER_ID         CONSTANT NUMBER := FND_GLOBAL.user_id;



	PROCEDURE save_comment_history(
				       itemtype       IN      VARCHAR2
				       ,itemkey       IN      VARCHAR2
				       ,funcmode      IN      VARCHAR2
				       ,user_name IN VARCHAR2
				       ,comment IN varchar2)

		  IS

		     l_comment VARCHAR2(2000);
		     l_object_id NUMBER;
		     l_project_id NUMBER;
		     l_seq NUMBER;
		     l_full_name VARCHAR2(2000);
		     l_user_name VARCHAR2(100);

		     CURSOR get_old_seq
		       IS
			  SELECT MAX(sequence_number)
			    FROM pa_wf_ntf_performers
			    WHERE
			    wf_type_code = 'APPROVAL_FYI'
			    AND item_type = itemtype
			    AND item_key = itemkey
			    AND object_id2 = l_object_id;

		     CURSOR get_full_name
		       IS
			   select party_name
		    from (
			  select fu.user_name, hp.party_name, hp.email_address
			  from fnd_user fu,
			  hz_parties hp
			  where fu.person_party_id = hp.party_id -- Bug 4527617. Replaced customer_id with person_party_id.
			  and fu.user_name = l_user_name
			  union all
			  select fu.user_name, papf.full_name, papf.email_address
			  from fnd_user fu,
			  hz_parties hp,
			  per_all_people_f papf
			  where 'PER:' || fu.employee_id = hp.orig_system_reference
			  and fu.user_name = l_user_name
			  and    trunc(sysdate)
			  between papf.EFFECTIVE_START_DATE
			  and		  Nvl(papf.effective_end_date, Sysdate + 1)
			  and papf.person_id = fu.employee_id);

	BEGIN


	    l_object_id     := wf_engine.GetItemAttrNumber
		      ( itemtype       => itemtype,
			itemkey        => itemkey,
			aname          => 'WF_OBJECT_ID');

	    --debug_msg_s1 ('XXXXXXXXXXXXXX d' || To_char(l_object_id));

	    l_project_id     := wf_engine.GetItemAttrNumber
		      ( itemtype       => itemtype,
			itemkey        => itemkey,
			aname          => 'PROJECT_ID');
/*
	    OPEN get_project_id;
	    FETCH get_project_id INTO l_project_id;
	    CLOSE get_project_id;
	      */


	    OPEN get_old_seq;
	    FETCH get_old_seq INTO l_seq;
	    IF get_old_seq%notfound THEN
	       l_seq := 0;
	    END IF;
	    IF l_seq IS NULL THEN
	       l_seq := 0;
	    END IF;

	    CLOSE get_old_seq;

	    l_user_name := user_name;
	    OPEN get_full_name ;
	    FETCH get_full_name INTO l_full_name;
	    CLOSE get_full_name;

	    --debug_msg_s1 ('Main: Save comment history: ' ||itemtype  || ':' || itemkey || ':' || l_object_id || ':' || user_name);

	    	    --debug_msg_s1 ('Main: Save comment history: ' ||itemtype  || ':' || itemkey || ':' || l_object_id || ':' || l_full_name);


		    --debug_msg_s1 ('Main: Save comment history: seq ' ||  To_char(l_seq +1));
		    --debug_msg_s1 ('Main: Save comment history: func ' ||  funcmode);



	    INSERT INTO pa_wf_ntf_performers
	      (
	       wf_type_code,
	       item_type,
	       item_key,
	       object_id1,
	       object_id2,
	       user_name,
	       user_type,
	       action_code,
	       action_date,
	       sequence_number,
	       approver_comments
	       )
	      VALUES
	      (
	       'APPROVAL_FYI',
	       itemtype,
	       itemkey,
	       l_project_id,
	       l_object_id,
	       user_name,
	       'RESOURCE',
	       funcmode,
	       Sysdate,
	       l_seq +1 ,
	       comment
	       );


	END;


	PROCEDURE show_history
	  (document_id IN VARCHAR2,
	   display_type IN VARCHAR2,
	   document IN OUT NOCOPY VARCHAR2, -- 4537865
	   document_type IN OUT NOCOPY VARCHAR2) -- 4537865

	  IS

	     l_item_type VARCHAR2(30);
	     l_item_key number;
             l_object_id NUMBER;
	     l_dummy VARCHAR2(400);
	     l_action_date VARCHAR2(60) := NULL;


	     CURSOR get_history_info IS
		SELECT DISTINCT
		  pw.sequence_number,
		  wu.display_name user_full_name,
		  pl.meaning action_code,
		  pw.action_date,
		  pw.approver_comments
		  FROM pa_wf_ntf_performers pw,  wf_users wu, pa_lookups pl
		  WHERE --pw.wf_type_code = 'APPROVAL_FYI'
		  pw.item_type = l_item_type -- 'PAWFPPRA'
		  AND pw.item_key = l_item_key --32715
		  AND pw.object_id2 = l_object_id --10020
		  and pw.user_name = wu.name
		  and pl.lookup_type = 'PA_WF_APPROVAL_ACTION'
		  and pl.lookup_code = pw.action_code
		  ORDER BY pw.sequence_number ;
		  /*
		SELECT
		  pw.sequence_number,
		  wu.display_name user_full_name,
		  pw.action_code,
		  pw.action_date,
		  pw.approver_comments
		  FROM pa_wf_ntf_performers pw,  wf_users wu
		  WHERE --pw.wf_type_code = 'APPROVAL_FYI'
		  pw.item_type = l_item_type
		  AND pw.item_key = l_item_key
		  AND pw.object_id2 = l_object_id
		  and pw.user_name = wu.name
		  ORDER BY pw.sequence_number ;
		  */


	     	     l_index1 NUMBER;


	BEGIN

           --debug_msg_s1('AAAAA Project Id ' || document_id);
	   l_index1 := instr(document_id, ':');

	   l_item_type := substrb(document_id, 1, l_index1 - 1); -- 4537865 Changed substr to substrb


	   --debug_msg_s1 ('XXXXXXXXXXXXXX a' || To_char(l_index1));

	   --debug_msg_s1 ('XXXXXXXXXXXXXX b' || l_item_type);

	   l_item_key := To_number(substrb(document_id, l_index1 +1,
					  Length(document_id)- l_index1)); -- 4537865 Changed substr to substrb

	   --debug_msg_s1 ('XXXXXXXXXXXXXX c' || To_char(l_item_key));


	   l_object_id     := wf_engine.GetItemAttrNumber
		      ( itemtype       => l_item_type,
			itemkey        => l_item_key,
			aname          => 'WF_OBJECT_ID');

	   document := '<table cellpadding="0" cellspacing="0" border="0" width="100%" summary="">'
	     || '<tr><td width="100%"  > <font face="Tahoma"  color=#3c3c3c class="OraHeaderSub"> '
	     || '<B>Approval History</td></tr></table>' ;



	   document := document ||
	     '<table cellSpacing=1 cellPadding=3 width="90%" border=0 bgColor=white summary=""><tr>
<TH  class=tableheader width=5%  ALIGN=left bgcolor=#cfe0f1><font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">Sequence</font>
</TH> <TH class=tableheader width=35%  ALIGN=left bgcolor=#cfe0f1><font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">Who</font>
</TH> <TH class=tableheader width=15%  ALIGN=left bgcolor=#cfe0f1><font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">Action</font>
</TH> <TH class=tableheader  width = 15%  ALIGN=left bgcolor=#cfe0f1><font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">Date</font>
</TH> <TH class=tableheader width=55%   ALIGN=left bgcolor=#cfe0f1><font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">Note</font>
</TH></TR> ';


	     FOR rec IN get_history_info  LOOP
	     /* Added for Bug 7538477 Start */
	     if (FND_RELEASE.MAJOR_VERSION = 12 and FND_RELEASE.minor_version >= 1 and FND_RELEASE.POINT_VERSION >= 1 )
       or (FND_RELEASE.MAJOR_VERSION > 12) then
          if (display_type = wf_notification.doc_html) then
              l_action_date := '<BDO DIR="LTR">' ||
                               to_char(rec.action_date  ,
                               FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', G_user_id),
                               'NLS_CALENDAR = ''' || nvl(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', G_user_id),'GREGORIAN') || '''')    /* Modified for Bug 8974192 */
                               || '</BDO>';
          else
              l_action_date := to_char(rec.action_date  ,
                               FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', G_user_id),
                               'NLS_CALENDAR = ''' || nvl(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', G_user_id),'GREGORIAN') || '''');   /* Modified for Bug 8974192 */
          end if;
      else
        l_action_date := to_char(rec.action_date);
      end if;
      /* Added for Bug 7538477 End */

		--debug_msg_s1('Project Id 3' || document_id);
		document := document ||
		  '<TR BGCOLOR="#ffffff" ><TD  class=approvalhistdata VALIGN=CENTER ALIGN=LEFT bgcolor=#f2f2f5> <font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">' || rec.sequence_number || '</font></TD>';

		document := document || '<TD  class=approvalhistdata VALIGN=CENTER ALIGN=LEFT bgcolor=#f2f2f5> <font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">' || rec.user_full_name || '</font></TD>';

		document := document || '<TD  class=approvalhistdata VALIGN=CENTER ALIGN=LEFT bgcolor=#f2f2f5> <font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">' || rec.action_code || '</font></TD>';

		document := document || '<TD  class=approvalhistdata VALIGN=CENTER ALIGN=LEFT bgcolor=#f2f2f5> <font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">' || l_action_date || '</font></TD>'; /* Modified for Bug 7538477 */

		document := document || '<TD  class=approvalhistdata VALIGN=CENTER ALIGN=LEFT bgcolor=#f2f2f5> <font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">' || rec.approver_comments || '</font></TD></tr>';

		l_action_date := NULL;  /* Added for Bug 7538477 */


	   END LOOP;


	   document := document ||'</table><br><br>';

	   --debug_msg_s1('Docu = ' || document);

 	   document_type := 'text/html';

	-- 4537865
	EXCEPTION
		WHEN OTHERS THEN
		document := 'An Unexpected Error has occured' ;
		document_type := 'text/html';
		-- RAISE not needed here.
	END show_history;



END pa_workflow_history;


/
