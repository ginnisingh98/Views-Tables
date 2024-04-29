--------------------------------------------------------
--  DDL for Package Body BIS_RG_SEND_NOTIFICATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RG_SEND_NOTIFICATIONS_PVT" as
/* $Header: BISVRGNB.pls 115.12 2003/10/28 08:02:30 nkishore noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile:~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      BIS_SCHEDULE_PVT
--                                                                        --
--  DESCRIPTION:  Private package to create records in BIS_SCHEDULER
--
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                --
--  02-25-00   amkulkar   Initial creation                                --
--  05-16-01   mdamle     Changed document from VARCHAR to clob		  --
--  07-03-01   mdamle	  Scheduling Enhancements			  --
--  08-13-01   mdamle	  Fixed Bug#1919709 				  --
--  09-04-01   mdamle	  Scheduling Enhancements - Phase II - Multiple   --
--			  Preferences per schedule			  --
--  07-28-03   nkishore	  Changed send_notification signature 		  --
----------------------------------------------------------------------------

-- mdamle 07/03/01 - Scheduling Enhancements
gvRoleName varchar2(20) := 'BIS_SCHEDULE_';

--Email Component include role
PROCEDURE  SEND_NOTIFICATION
(p_user_id		IN	VARCHAR2
,p_file_id		IN	VARCHAR2 DEFAULT NULL
,p_schedule_id		IN	VARCHAR2 DEFAULT NULL
,p_role                 IN      VARCHAR2 DEFAULT NULL
,p_title           IN      VARCHAR2 DEFAULT NULL
)
IS
   l_wf_item_key     NUMBER;
   l_user_name       VARCHAR2(32000);
   l_title           VARCHAR2(32000);
   l_function_name   VARCHAR2(32000);
   l_file_id         NUMBER;
   l_schedule_id     NUMBER;
   l_url	     VARCHAR2(32000);
   l_role_name	     VARCHAR2(30);
   l_role_exists     number;

   -- mdamle 09/04/01 Scheduling Enhancements - Phase II - Multiple Preferences per schedule
   /*
   CURSOR c_sched IS
   SELECT title, function_name, schedule_id
   FROM bis_scheduler
   WHERE schedule_id = p_schedule_id;
   */
   CURSOR c_sched IS
   SELECT sp.file_id, sp.title, s.function_name, s.schedule_id
   FROM bis_scheduler s, bis_schedule_preferences sp
   WHERE sp.schedule_id = p_schedule_id
   and sp.file_id = p_file_id
   and s.schedule_id = sp.schedule_id
   and sp.user_id = p_user_id
   and sp.plug_id is null;

BEGIN

  -- mdamle 07/03/01 - Scheduling Enhancements
  -- Send to the Role setup for the schedule instead of the user
  --Email Component check role and then assign it

  SELECT user_name INTO l_user_name
  FROM fnd_user WHERE user_id = p_user_id;

  IF ( p_role is not null) then
     l_role_name := p_role;
  else

    -- mdamle 09/04/01 Scheduling Enhancements - Phase II - Multiple Preferences per schedule
    l_role_name := gvRoleName || p_file_id;
    select count(1)
    into l_role_exists
    from WF_LOCAL_ROLES
    where name = l_role_name;

    if l_role_exists = 0 then
    	l_role_name := l_user_name;
    end if;
  end if;


  IF (p_role is not null) THEN
     l_file_id := p_file_id;
     l_title := p_title;
  ELSE
    OPEN c_sched;
    FETCH c_sched INTO l_file_id, l_title, l_function_name, l_schedule_id;
    CLOSE c_sched;
    IF (l_title IS NULL) THEN
     --  mdamle 08/13/01 - Fixed Bug#1919709 				  --
     -- l_title := l_function_name;
       l_title := BIS_REPORT_UTIL_PVT.Get_Report_Title(l_function_name);
    END IF;
  END IF;


  -- mdamle 05/16/01 - Commenting out the URL notification, retaining the
  -- one with the Report Body
/*
  SELECT bis_excpt_wf_s.nextval
  INTO l_wf_item_key FROM dual;


  --l_user_name := 'BISTESTER';
  --Construct the URL to be sent
  l_url := FND_WEB_CONFIG.TRAIL_SLASH(fnd_profile.value('APPS_WEB_AGENT'));
  l_url := l_url ||'BIS_SAVE_REPORT.RETRIEVE?file_id='||l_File_id;
  wf_engine.createprocess(itemtype=>'BISRGNOT'
                          ,itemkey =>l_wf_item_key
		          ,process=> 'BISSENDREPORTURL'
			  );
  wf_engine.setitemattrtext(
     itemtype => 'BISRGNOT'
     ,itemkey  => l_wf_item_key
     ,aname    => 'L_REPORTTITLE'
     ,avalue   => l_title
     );
  wf_engine.setitemattrtext(
     itemtype => 'BISRGNOT'
     ,itemkey  => l_wf_item_key
     ,aname    => 'REPORTRECIPIENT'
     ,avalue   => l_user_name
     );
  wf_engine.setitemattrtext(
     itemtype => 'BISRGNOT'
     ,itemkey  => l_wf_item_key
     ,aname    => 'L_REPORTURL'
     ,avalue   => l_url
     );
  wf_engine.startprocess
     (itemtype => 'BISRGNOT'
    ,itemkey =>   l_wf_item_key
    );
*/

  SELECT bis_excpt_wf_s.nextval
  INTO l_wf_item_key FROM dual;


  wf_engine.createprocess(itemtype=> 'BISRGNOT'
                         ,itemkey=> l_wf_item_key
                         ,process => 'BISSENDHTMLBODY'
                         );

  wf_engine.setitemattrtext(
           itemtype => 'BISRGNOT'
          ,itemkey  => l_wf_item_key
          ,aname    => 'L_EMAIL_RECIPIENT'
	  -- mdamle 07/03/01 - Scheduling Enhancements
  	  -- Send to the Role setup for the schedule instead of the user
          ,avalue   => l_role_name
         );

  wf_engine.setitemattrtext(
           itemtype => 'BISRGNOT'
          ,itemkey  => l_wf_item_key
          ,aname    => 'L_FILE_ID'
          ,avalue   => l_file_id
         );

  wf_engine.setitemattrtext(
     itemtype => 'BISRGNOT'
     ,itemkey  => l_wf_item_key
     ,aname    => 'L_REPORTTITLE'
     ,avalue   => l_title
     );

  wf_engine.setitemattrtext(
     itemtype => 'BISRGNOT'
     ,itemkey  => l_wf_item_key
     ,aname    => '#FROM_ROLE'
     ,avalue   => l_user_name
     );


  wf_engine.startprocess
        (itemtype => 'BISRGNOT'
        ,itemkey  => l_wf_item_key
       );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     null;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     null;
WHEN OTHERS THEN
     null;
END;



PROCEDURE RETRIEVE_REPORT
(document_id           IN       VARCHAR2
,display_Type          IN       VARCHAR2 DEFAULT 'TEXT/HTML'
,document              IN OUT   NOCOPY clob
,document_type         IN OUT   NOCOPY VARCHAR2
)
IS
    l_Document              VARCHAR2(32000);
    l_img_html              VARCHAR2(32000);
    --l_html_pieces           UTL_HTTP.HTML_PIECES;
    l_html_pieces           BIS_PMV_UTIL.lob_varchar_pieces;
    l_count                 NUMBER;
    l_length                NUMBER := 1;

BEGIN

    --l_img_html := bis_save_Report.returnURL(document_id);
    --l_html_pieces := utl_http.request_pieces(l_img_html,32000);
   -- mdamle 09/04/01 Scheduling Enhancements - Phase II - Multiple Preferences per schedule
    select count(*)
    into l_count
    from fnd_lobs
    where file_id = document_id;

    if l_count > 0 then
    	l_html_pieces := BIS_PMV_UTIL.readfndlobs(document_id);
    	FOR l_count IN 1..l_html_pieces.COUNT LOOP
		-- mdamle 05/16/01 - Changing document to clob - no longer a 32K limitation
        	l_document := l_html_pieces(l_count);
        	wf_notification.writetoclob(document, l_document);
    	END LOOP;
    else
	l_document :=  fnd_message.get_string('BIS', 'BIS_REPORT_DATA_PURGED');
       	wf_notification.writetoclob(document, l_document);
    end if;

END;
END BIS_RG_SEND_NOTIFICATIONS_PVT;

/
