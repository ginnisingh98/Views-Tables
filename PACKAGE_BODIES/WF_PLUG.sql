--------------------------------------------------------
--  DDL for Package Body WF_PLUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_PLUG" as
/* $Header: wfplugb.pls 120.2 2005/10/04 23:26:39 rtodi ship $ */


--
-- Package Globals
--
chr_newline varchar2(1) := '
';
result_button_threshold pls_integer := 3;  -- Max number of submit buttons

--
-- Error (PRIVATE)
--   Print a page with an error message.
--   Errors are retrieved from these sources in order:
--     1. wf_core errors
--     2. Oracle errors
--     3. Unspecified INTERNAL error
--
procedure Error
as
  error_name      varchar2(30);
  error_message   varchar2(2000);
  error_stack     varchar2(32000);
begin
    htp.htmlOpen;
    htp.headOpen;
    htp.title(wf_core.translate('ERROR'));
    htp.headClose;

    begin
      wfa_sec.Header(TRUE);
    exception
      when others then
        htp.bodyOpen;
    end;

    htp.header(nsize=>1, cheader=>wf_core.translate('ERROR'));

    wf_core.get_error(error_name, error_message, error_stack);

    if (error_name is not null) then
        htp.p(error_message);
    else
        htp.p(sqlerrm);
    end if;

    htp.hr;
    htp.p(wf_core.translate('WFENG_ERRNAME')||':  '||error_name);
    htp.br;
    htp.p(wf_core.translate('WFENG_ERRSTACK')||': '||
          replace(error_stack,wf_plug.chr_newline,'<br>'));

    wfa_sec.Footer;
    htp.htmlClose;
end Error;

--
-- GetPlugSession
--
procedure GetPlugSession(plug_id IN NUMBER, session_id IN NUMBER, user_name out NOCOPY varchar2)
is
  l_user_name varchar2(320);   -- used as out parameters cannot be read!!
  res    boolean;
begin

    -- Check the ic cookie for a session
    begin
      res := ICX_SEC.ValidatePlugSession(plug_id, session_id );
    exception
      when others then
        wf_core.token('SQLCODE', SQLCODE);
        wf_core.token('SQLERRM', SQLERRM);
        wf_core.raise('WFSEC_GET_SESSION');
    end;

    if (res = FALSE ) then
      wf_core.raise('WFSEC_NO_SESSION');
    end if;

    l_user_name := ICX_SEC.GetID(99, null, session_id);

    user_name := l_user_name;

exception
  when others then
    wf_core.context('Wf_plug', 'GetPlugSession');
    raise;
end GetPlugSession;


/*===========================================================================
  PROCEDURE NAME:	get_plug_definition

  DESCRIPTION:  	Selects the plug definition and sets the cookie

============================================================================*/
PROCEDURE get_plug_definition (
p_plug_id IN NUMBER,
p_worklist_definition OUT NOCOPY wf_plug.wf_worklist_definition_record
) IS

ii                         NUMBER         := 0;
l_definition_exists        VARCHAR2(1)    := 'Y';

BEGIN

    FOR ii IN 1..2 LOOP

      l_definition_exists := 'Y';

      BEGIN

       SELECT  ROWID ROW_ID,
               PLUG_ID,
   	       USERNAME,
      	       DEFINITION_NAME,
   	       WHERE_STATUS,
	       WHERE_FROM,
	       WHERE_ITEM_TYPE,
	       WHERE_NOTIF_TYPE,
	       WHERE_SUBJECT,
	       WHERE_SENT_START,
	       WHERE_SENT_END,
	       WHERE_DUE_START,
	       WHERE_DUE_END,
	       WHERE_PRIORITY,
	       WHERE_NOTIF_DEL_BY_ME,
	       ORDER_PRIMARY,
	       ORDER_ASC_DESC
       INTO    p_worklist_definition
       FROM    WF_WORKLIST_DEFINITIONS
       WHERE   PLUG_ID = p_plug_id;

       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             l_definition_exists    := 'N';
          WHEN OTHERS THEN
             RAISE;
       END;

       -- If this definition does not exist then copy the definition
       -- from the default
       IF (l_definition_exists = 'N' AND p_plug_id IS NOT NULL) THEN

           INSERT INTO WF_WORKLIST_DEFINITIONS
           (   PLUG_ID,
   	       USERNAME,
      	       DEFINITION_NAME,
	       WHERE_STATUS,
	       WHERE_FROM,
	       WHERE_ITEM_TYPE,
	       WHERE_NOTIF_TYPE,
	       WHERE_SUBJECT,
	       WHERE_SENT_START,
	       WHERE_SENT_END,
	       WHERE_DUE_START,
	       WHERE_DUE_END,
	       WHERE_PRIORITY,
	       WHERE_NOTIF_DEL_BY_ME,
	       ORDER_PRIMARY,
	       ORDER_ASC_DESC
           )
           SELECT	p_plug_id,
                	null,
                	null,
                        'OPEN',
                	'*',
                        '*',
                        '*',
                        null,
                        null,
                        null,
                        null,
                        null,
                        'HML',
                        '0',
                        'PRIORITY',
                        null
            FROM    SYS.DUAL
            WHERE   NOT EXISTS
                    (SELECT 1
                     FROM   WF_WORKLIST_DEFINITIONS
                     WHERE  PLUG_ID = p_plug_id);

           INSERT INTO WF_WORKLIST_COL_DEFINITIONS
           (	   PLUG_ID			,
   		   USERNAME		,
		   DEFINITION_NAME		,
        	   COLUMN_NUMBER           ,
        	   COLUMN_NAME             ,
	           COLUMN_SIZE
   	   )
           SELECT  p_plug_id,
                         null,
                         null,
                         1,
                         'SUBJECT',
                         100
                FROM    SYS.DUAL
                WHERE   NOT EXISTS
                (SELECT 1
                 FROM   WF_WORKLIST_COL_DEFINITIONS
                 WHERE  PLUG_ID = p_plug_id);

            COMMIT;

       ELSE

         -- break out of loop since you found the definition
         exit;

       END IF;

   END LOOP;


exception
  when others then
    rollback;
    wf_core.context('Wf_Plug', 'get_plug_definition');
    wf_plug.Error;
end get_plug_definition;


/*===========================================================================
  PROCEDURE NAME:	find_criteria

  DESCRIPTION:  	Draws the find criteria on the HTML Page.  This
			function is shared by the main find routine and the
			plug.

============================================================================*/
PROCEDURE find_criteria (
  username        IN VARCHAR2 DEFAULT NULL,
  status 	  IN VARCHAR2 DEFAULT '*',
  fromuser 	  IN VARCHAR2 DEFAULT '*',
  ittype 	  IN VARCHAR2 DEFAULT '*',
  msubject 	  IN VARCHAR2 DEFAULT '*',
  beg_sent 	  IN DATE     DEFAULT null,
  end_sent 	  IN DATE     DEFAULT null,
  beg_due 	  IN DATE     DEFAULT null,
  end_due 	  IN DATE     DEFAULT null,
  priority 	  IN VARCHAR2 DEFAULT null,
  delegated_by_me IN VARCHAR2 DEFAULT '0',
  orderkey        IN VARCHAR2 DEFAULT 'PRIORITY',
  customize       IN VARCHAR2 DEFAULT 'N'
) IS

  admin_role varchar2(320); -- Role for admin mode
  lang_codeset varchar2(50); -- Language Codeset from environment
			     -- (e.g. WE8ISO8859P1)
  realname varchar2(360);   -- Display name of username
  s0 varchar2(2000);
  lchecked VARCHAR2(2);

  lbeg_sent   NUMBER;

  cursor lkcurs(lktype in varchar2) is
    select WL.MEANING, WL.LOOKUP_CODE
    from WF_LOOKUPS WL
    where WL.LOOKUP_TYPE = lktype
    order by WL.MEANING;

-- Lookup for Item Type
  cursor itcurs(role in varchar2) is
    select unique WIT.DISPLAY_NAME, WN.MESSAGE_TYPE
    from WF_NOTIFICATIONS WN, WF_ITEM_TYPES_VL WIT
    where WN.MESSAGE_TYPE = WIT.NAME
    and WN.RECIPIENT_ROLE = role
    order by WIT.DISPLAY_NAME;

  ittype_list itcurs%rowtype;

BEGIN

  wf_directory.GetRoleInfo(username, realname, s0, s0, s0, s0);

  -- Get language codeset
  lang_codeset := substr(userenv('LANGUAGE'),instr(userenv('LANGUAGE'),'.')+1,
                         length(userenv('LANGUAGE')));


  -- From User Field
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('NOTIF_FROM'), calign=>'right');

  IF (fromuser = '*') THEN

     htp.tableData(htf.formText(cname=>'fromuser', csize=>'30',
                                cvalue=>'', cmaxlength=>'30'));

  ELSE

     htp.tableData(htf.formText(cname=>'fromuser', csize=>'30',
                                cvalue=>fromuser, cmaxlength=>'30'));

  END IF;

  htp.tableRowClose;


  -- Type field
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('NOTIF_TYPE'), calign=>'right');
  htp.p('<TD>');
  htp.formSelectOpen('ittype');

  for ittype_list in itcurs(username) loop

    IF (ittype_list.message_type = ittype) THEN

       htp.formSelectOption(cvalue=>ittype_list.display_name,
                            cselected => 'SELECTED',
                            cattributes=>'value='||ittype_list.message_type);

    ELSE

       htp.formSelectOption(cvalue=>ittype_list.display_name,
                            cattributes=>'value='||ittype_list.message_type);

    END IF;

  end loop;

  IF (ittype = '*') THEN

     htp.formSelectOption(cvalue=>wf_core.translate('ALL'),
                          cselected => 'SELECTED',
                          cattributes=>'value=*');

  ELSE

     htp.formSelectOption(cvalue=>wf_core.translate('ALL'),
                          cattributes=>'value=*');

  END IF;

  htp.formSelectClose;
  htp.p('</TD>');
  htp.tableRowClose;

  -- Sent in the last N days field
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('NOTIF_SENT'), calign=>'right');

  IF (beg_sent IS NOT NULL) THEN

     lbeg_sent :=  TO_DATE(beg_sent, 'MM/DD/YYYY') - TO_DATE('01/01/2000', 'MM/DD/YYYY');

  ELSE

     lbeg_sent := null;

  END IF;


  htp.tableData(htf.formText(cname=>'beg_sent', csize=>'5',
                             cvalue=>lbeg_sent, cmaxlength=>'5'));


  htp.tableRowClose;

  -- Skip a line
  htp.tableRowOpen;

  htp.tableData(cvalue=>'&nbsp');

  htp.tableRowClose;

  -- High Priority Items
  htp.tableRowOpen;

  htp.tableData(cvalue=>'&nbsp');

  IF (INSTR(priority, 'H') > 0) THEN

     lchecked := 'Y';

  ELSE

     lchecked := null;

  END IF;

  htp.tableData(
     cvalue=>htf.formcheckbox(
           cname=>'HPRIORITY',
           cvalue=>'H',
           cchecked=>lchecked)||
                   '&nbsp;'||wf_core.translate('HIGH_MESSAGES')||'&nbsp;&nbsp;&nbsp;',
            calign=>'left');

  htp.tableRowClose;

  -- Medium Priority Items
  htp.tableRowOpen;

  htp.tableData(cvalue=>'&nbsp');

  IF (INSTR(priority, 'M') > 0) THEN

     lchecked := 'Y';

  ELSE

     lchecked := null;

  END IF;

  htp.tableData(
     cvalue=>htf.formcheckbox(
           cname=>'MPRIORITY',
           cvalue=>'M',
           cchecked=>lchecked)||
                   '&nbsp;'||wf_core.translate('MEDIUM_MESSAGES')||'&nbsp;&nbsp;&nbsp;',
            calign=>'left');

  htp.tableRowClose;

  -- Low Priority Items
  htp.tableRowOpen;

  htp.tableData(cvalue=>'&nbsp');

  IF (INSTR(priority, 'L') > 0) THEN

     lchecked := 'Y';

  ELSE

     lchecked := null;

  END IF;

  htp.tableData(
     cvalue=>htf.formcheckbox(
           cname=>'LPRIORITY',
           cvalue=>'L',
           cchecked=>lchecked)||
                   '&nbsp;'||wf_core.translate('LOW_MESSAGES')||'&nbsp;&nbsp;&nbsp;',
            calign=>'left');

  htp.tableRowClose;

  htp.tableClose;


exception
  when others then
    Wf_Core.Context('wf_plug', 'find_criteria');
    wf_plug.Error;

END find_criteria;


--
-- WorkList
--   Construct the worklist (summary page) for user.
-- IN
--   orderkey - Key to order by (default PRIORITY)
--              Valid values are PRIORITY, MESSAGE_TYPE, SUBJECT, BEGIN_DATE,
--              DUE_DATE, END_DATE, STATUS.
--   status - Status to query (default OPEN)
--            Valid values are OPEN, CLOSED, CANCELED, ERROR, *.
--   user - User to query notifications for.  If null query user currently
--          logged in.
--          Note: Only a user in role WF_ADMIN_ROLE can query a user other
--          than the current user.
--
procedure WorkList(
  plug_id  in varchar2 default null,
  session_id in varchar2 default null,
  display_name in varchar2 default null
 )
as
  lorderkey varchar2(30);
  lstatus varchar2(30);
  luser varchar2(320);
  lfromuser varchar2(320);
  littype varchar2(8);
  lsubject varchar2(80);
  lbeg_sent date;
  lend_sent date;
  lbeg_due date;
  lend_due date;
  lpriority varchar2(8);
  ldbm  number;
  nf_from_user varchar2(4000);
  nf_subject   varchar2(4000);
  nf_to_user   varchar2(4000);

  high_bottom_value NUMBER;
  high_top_value    NUMBER;
  low_bottom_value  NUMBER;
  low_top_value     NUMBER;

  username varchar2(320);    -- Username to query
  colon pls_integer;        -- Magic orig_system decoder
  uorig_system varchar2(30); -- User orig_system for indexes
  uorig_system_id pls_integer; -- User orig_system_id for indexes
  realname varchar2(360);    -- Display name of username
  admin_role varchar2(320);  -- Role for admin mode
  s0 varchar2(2000);        -- Dummy
  n_priority varchar2(80);  -- priority icon
  l_record_num number;
  n_response varchar2(80);  -- required response icon

  cursor wl_cursor (p0 pls_integer, p1 pls_integer,
                    p2 pls_integer, p3 pls_integer) is
    select WN.NOTIFICATION_ID nid,
           WN.PRIORITY,
           WIT.DISPLAY_NAME message_type,
           WN.SUBJECT,
           WN.BEGIN_DATE,
           WN.DUE_DATE,
           WN.END_DATE,
           WL.MEANING display_status,
	   WN.STATUS,
           WN.LANGUAGE
    from WF_NOTIFICATIONS WN, WF_ITEM_TYPES_VL WIT, WF_LOOKUPS WL
    where WN.MESSAGE_TYPE = decode(Worklist.littype, '*', WN.MESSAGE_TYPE,
				     Worklist.littype)
    and WN.MESSAGE_TYPE = WIT.NAME
    and WL.LOOKUP_TYPE = 'WF_NOTIFICATION_STATUS'
    and WN.STATUS = WL.LOOKUP_CODE
    and WN.RECIPIENT_ROLE in
        (select WUR.ROLE_NAME
         from WF_USER_ROLES WUR
         where WUR.USER_ORIG_SYSTEM = Worklist.uorig_system
         and WUR.USER_ORIG_SYSTEM_ID = Worklist.uorig_system_id
         and WUR.USER_NAME = Worklist.username)
    and ((Worklist.lfromuser = '*' ) or
	 (WN.ORIGINAL_RECIPIENT = upper(Worklist.lfromuser)))
    and WN.STATUS = 'OPEN'
    and ((WN.BEGIN_DATE is null)
          or  ((WN.BEGIN_DATE >= decode(Worklist.lbeg_sent, null, WN.BEGIN_DATE,
				   Worklist.lbeg_sent))
          and (WN.BEGIN_DATE  <= decode(Worklist.lend_sent, null, WN.BEGIN_DATE,
				  Worklist.lend_sent))))
    and (PRIORITY between p0 and p1 or PRIORITY between p2 and p3)
    order by decode(upper(Worklist.lorderkey),
             'MESSAGE_TYPE', WIT.DISPLAY_NAME,
             'SUBJECT', WN.SUBJECT,
             'BEGIN_DATE', to_char(WN.BEGIN_DATE, 'J.SSSSS'),
             'DUE_DATE', to_char(WN.DUE_DATE, 'J.SSSSS'),
             'END_DATE', to_char(WN.END_DATE, 'J.SSSSS'),
             'STATUS', WL.MEANING,
	     'RPRIORITY', to_char(100 - WN.PRIORITY, '00000000'),
             to_char(WN.PRIORITY, '00000000'));

  -- Notes: lower the number higher the priority!
  --        Assumed priority has the range between 0 and 100

  cursor attrs(mnid in number) is
    select MA.NAME
    from WF_NOTIFICATION_ATTRIBUTES NA,
         WF_MESSAGE_ATTRIBUTES_VL MA,
         WF_NOTIFICATIONS N
    where N.NOTIFICATION_ID = mnid
    and NA.NOTIFICATION_ID = N.NOTIFICATION_ID
    and MA.MESSAGE_NAME = N.MESSAGE_NAME
    and MA.MESSAGE_TYPE = N.MESSAGE_TYPE
    and MA.NAME = NA.NAME
    and MA.SUBTYPE = 'RESPOND'
    and MA.TYPE <> 'FORM'
    and MA.NAME = 'RESULT';

CURSOR c_fetch_col_def (c_plug_id IN NUMBER,
                        c_username IN VARCHAR2) IS
SELECT
 ROWID    ROW_ID,
 PLUG_ID,
 USERNAME,
 COLUMN_NUMBER,
 COLUMN_NAME,
 COLUMN_SIZE
FROM WF_WORKLIST_COL_DEFINITIONS
WHERE (PLUG_ID = c_plug_id and c_plug_id IS NOT NULL)
OR    (USERNAME = c_username and c_username IS NOT NULL and c_plug_id IS NULL)
ORDER BY COLUMN_NUMBER;

l_worklist_definition     wf_plug.wf_worklist_definition_record;
l_worklist_col_definition wf_plug.wf_worklist_col_def_table;

notrec wl_cursor%ROWTYPE;
result attrs%rowtype;

begin

  -- If this is being called as a plug then go get the plug definition
  -- and set the cookie
  IF (plug_id IS NOT NULL) THEN

      -- Check plug session and get current user
      GetPlugSession(TO_NUMBER(plug_id), TO_NUMBER(session_id),
         username);

      get_plug_definition(TO_NUMBER(plug_id), l_worklist_definition);

  ELSE

      return;

  END IF;

  lorderkey := l_worklist_definition.order_primary;
  lstatus   := l_worklist_definition.where_status;
  lfromuser := l_worklist_definition.where_from;
  littype   := l_worklist_definition.where_item_type;
  lsubject  := l_worklist_definition.where_subject;

  /*
  ** This is a bit tricky but instead of having the user enter a range of
  ** dates for the criteria they enter the number of days since it was Sent
  ** We then store the start date as an offset from 01-JAN-2000 and get
  ** the Sent in the last NOT days criteria and subtract it from sysdate to
  ** get the correct start range for the search.
  */
  IF (l_worklist_definition.where_sent_start IS NOT NULL) THEN

     lbeg_sent := sysdate - (l_worklist_definition.where_sent_start - TO_DATE('01/01/2000', 'MM/DD/YYYY'));

  ELSE

     lbeg_sent := null;

  END IF;

  lend_sent := l_worklist_definition.where_sent_end;
  lbeg_due  := l_worklist_definition.where_due_start;
  lend_due  := l_worklist_definition.where_due_end;
  lpriority := l_worklist_definition.where_priority;
  ldbm      := TO_NUMBER(l_worklist_definition.where_notif_del_by_me);

  -- See if user over-ride argument requested
  if (luser is not null) then
    -- Check that current user has WF_ADMIN_ROLE privileges
    admin_role := wf_core.translate('WF_ADMIN_ROLE');
    if (admin_role <> '*' and
        not Wf_Directory.IsPerformer(username, admin_role)) then
      Wf_Core.Token('UNAME', username);
      Wf_Core.Token('ROLE', admin_role);
      Wf_Core.Raise('WFMON_ADMIN_ROLE');
    end if;
    -- Over-ride current user with argument
     username := luser;
  end if;

  OPEN c_fetch_col_def (TO_NUMBER(plug_id), username);

  /*
  ** Loop through all the lookup_code rows for the given lookup_type
  ** filling in the p_wf_lookups_tbl
  */
  l_record_num := 0;

  LOOP

       l_record_num := l_record_num + 1;

       FETCH c_fetch_col_def INTO
          l_worklist_col_definition(l_record_num);

       EXIT WHEN c_fetch_col_def%NOTFOUND;

  END LOOP;

  CLOSE c_fetch_col_def;

  IF (l_record_num = 1) THEN

     l_record_num := 0;

     OPEN c_fetch_col_def (-1, '-1');

     /*
     ** Loop through all the lookup_code rows for the given lookup_type
     ** filling in the p_wf_lookups_tbl
     */
     LOOP

          l_record_num := l_record_num + 1;

          FETCH c_fetch_col_def INTO
             l_worklist_col_definition(l_record_num);

          EXIT WHEN c_fetch_col_def%NOTFOUND;

     END LOOP;

  END IF;


  username := upper(username);
  wf_directory.GetRoleInfo(username, realname, s0, s0, s0, s0);

  -- Fetch user orig_system_ids for indexes in main cursor
  begin
    colon := instr(username, ':');
    if (colon = 0) then
      select WR.ORIG_SYSTEM, WR.ORIG_SYSTEM_ID
      into uorig_system, uorig_system_id
      from WF_ROLES WR
      where WR.NAME = username
      and   WR.ORIG_SYSTEM not in ('HZ_PARTY','POS','ENG_LIST','AMV_CHN',
              'HZ_GROUP','CUST_CONT');
    else
      select WR.ORIG_SYSTEM, WR.ORIG_SYSTEM_ID
      into uorig_system, uorig_system_id
      from WF_ROLES WR
      where WR.ORIG_SYSTEM = substr(username, 1, colon-1)
      and WR.ORIG_SYSTEM_ID = substr(username,  colon+1)
      and WR.NAME = username;
    end if;
  exception
    when no_data_found then
      wf_core.token('ROLE', username);
      wf_core.raise('WFNTF_ROLE');
  end;

  /*
  ** This is a little confusing but its a pretty cool routine.
  ** High priority = 0  - 33
  ** Med priority =  34 - 66
  ** Low priority =  67 - 100
  **
  ** Set the initial ranges for the select to be high and low priority items
  ** If you medium is also selected then add the medium range to the top of
  ** of the high priority range.
  ** Then check for the other flags.  If they are not turned on then remove
  ** them from the priority ranges
  */

  high_bottom_value := 0;
  high_top_value := 33;
  low_bottom_value := 67;
  low_top_value := 100;

  IF (INSTR(lpriority, 'M') > 0) THEN

      high_top_value := 66;

  END IF;

  IF (INSTR(lpriority, 'L') = 0) THEN

     low_bottom_value := 0;
     low_top_value := 0;

  END IF;

  IF (INSTR(lpriority, 'H') = 0) THEN

     high_bottom_value := 34;

  END IF;

  -- If there are no notifications, display a message and exit
  open wl_cursor (high_bottom_value,  high_top_value,
                  low_bottom_value,   low_top_value);

  fetch wl_cursor into notrec;
  if wl_cursor%NOTFOUND then
/*
   htp.p(lorderkey||':'||lstatus||':'||luser
      ||':'||lfromuser||':'||littype||':'||lsubject||':'||lbeg_sent
      ||':'||lend_sent||':'||lbeg_due||':'||lend_due||':'||lpriority
      ||':'||ldbm);
*/
    close wl_cursor;
    htp.tableOpen('border=0 cellspacing=0 cellpadding=0 width=100%');
    htp.tableRowOpen;
    htp.p('<TD>');
    IF (display_name IS NULL) THEN

       icx_plug_utilities.plugbanner(wf_core.translate('WFA_WTITLE'),
         owa_util.get_owa_service_path||'wf_plug.edit_worklist_definition?'||
         'p_plug_id='||plug_id, 'FNDALERT.gif');

    ELSE

        icx_plug_utilities.plugbanner(display_name,
         owa_util.get_owa_service_path||'wf_plug.edit_worklist_definition?'||
         'p_plug_id='||plug_id, 'FNDALERT.gif');

    END IF;
    htp.p('</TD>');
    htp.tableRowClose;
    htp.tableClose;

    htp.p(wf_core.translate('WFA_NO_HOME_NOTIFY'));
    htp.br;

    return;

  end if;
/*
  htp.p(lorderkey||':'||lstatus||':'||luser
      ||':'||lfromuser||':'||littype||':'||lsubject||':'||lbeg_sent
      ||':'||lend_sent||':'||lbeg_due||':'||lend_due||':'||lpriority
      ||':'||ldbm);
*/

  -- If this is a plug then show title bar a customize reference
  IF (plug_id IS NOT NULL) THEN

     htp.tableOpen('border=0 cellspacing=0 cellpadding=0 width=100%');
     htp.tableRowOpen;
     htp.p('<TD>');
    IF (display_name IS NULL) THEN

       icx_plug_utilities.plugbanner(wf_core.translate('WFA_WTITLE'),
         owa_util.get_owa_service_path||'wf_plug.edit_worklist_definition?'||
         'p_plug_id='||plug_id, 'FNDALERT.gif');

    ELSE

     icx_plug_utilities.plugbanner(display_name,
        owa_util.get_owa_service_path||'wf_plug.edit_worklist_definition?'||
           'p_plug_id='||plug_id, 'FNDALERT.gif');
    end if;

     htp.p('</TD>');
     htp.p('<tr><td><font size=-2><BR></font></td></tr>');
     htp.tableRowClose;
     htp.tableClose;

  END IF;

  -- There are some notifications for the user. Construct the page.
  htp.tableOpen('border=0 cellpadding=1 cellspacing=0 width=100%');

  IF (l_worklist_col_definition.count > 1) THEN

     -- Column headers
     htp.tableRowOpen(cattributes=>'bgcolor='||icx_plug_utilities.plugbgcolor);

     htp.tabledata(cvalue=>'&nbsp');

     FOR l_record_num IN 1..l_worklist_col_definition.count LOOP

        IF (l_worklist_col_definition(l_record_num).column_name =
                'MESSAGE_TYPE') THEN

           htp.tableData('<font color=#000000 size=3>'||wf_core.translate('TYPE')||'</font>', 'Left');

        END IF;

        IF (l_worklist_col_definition(l_record_num).column_name =
                'SUBJECT') THEN

           htp.tableData('<font color=#000000 size=3>'||wf_core.translate('SUBJECT')||'</font>', 'Left');

        END IF;

        IF (l_worklist_col_definition(l_record_num).column_name =
             'BEGIN_DATE') THEN

           htp.tableData('<font color=#000000 size=3>'||wf_core.translate('BEGIN_DATE')||'</font>', 'Left');

        END IF;

        IF (l_worklist_col_definition(l_record_num).column_name =
                'DUE_DATE') THEN

            htp.tableData('<font color=#000000 size=3>'||wf_core.translate('DUE_DATE')||'</font>', 'Left');

        END IF;

     END LOOP;

     htp.tableRowClose;

     -- Print line
/*
     htp.p('<TR height=1 bgcolor=' || icx_plug_utilities.plugbannercolor ||
	   '>');
     htp.p('<TD height=1></TD><TD height=1 colspan=' ||
	   l_worklist_col_definition.count ||
	   '><IMG SRC=/OA_MEDIA/FND' || icx_plug_utilities.plugcolorscheme
           || 'UDT.gif width=1 height=1></TD>');
     htp.tableRowClose;
*/

  END IF;

  -- Worklist
  loop
    -- Figure out the priority first

    n_priority := null;

    if (notrec.priority < 35) then
      n_priority :=  '/OA_MEDIA/'||'high.gif';
    else
      if (notrec.priority > 65) then
	n_priority := '/OA_MEDIA/'||'low.gif';
      end if;
    end if;

    -- Displaying a row
    htp.tableRowOpen(cvalign=>'TOP', cattributes=>'bgcolor=white');

    IF (n_priority IS NULL) THEN

        htp.tableData(cvalue=>'&nbsp');

    ELSE

        htp.tableData(cvalue=>htf.img(curl=>n_priority));

    END IF;

    FOR l_record_num IN 1..l_worklist_col_definition.count LOOP

       IF (l_worklist_col_definition(l_record_num).column_name =
             'MESSAGE_TYPE') THEN

             htp.tableData(cvalue=>'<font  color=#000000 size=3>'||
                                    notrec.message_type, calign=>'left');

       END IF;

       IF (l_worklist_col_definition(l_record_num).column_name =
             'SUBJECT') THEN

         if (notrec.language is null or notrec.language <> userenv('LANG')) then

           Wfa_Html_Util.GetDenormalizedValues(notrec.nid, userenv('LANG'),
                                         nf_from_user, nf_to_user, nf_subject);

           htp.tableData(cvalue=>'<font  size=3>'||
                        htf.anchor(owa_util.get_owa_service_path||
                        Wfa_Sec.DetailURL(notrec.nid),
                        ctext=>nf_subject, cattributes=>'TARGET="_top"'),
                        calign=>'left');

         else

           htp.tableData( cvalue=>'<font  size=3>'||
                          htf.anchor(owa_util.get_owa_service_path||
                          Wfa_Sec.DetailURL(notrec.nid),
                          ctext=>notrec.subject, cattributes=>'TARGET="_top"'),
                          calign=>'left');

         end if;

       END IF;

       IF (l_worklist_col_definition(l_record_num).column_name =
             'BEGIN_DATE') THEN

             htp.tableData(cvalue=>'<font color=#000000 size=3>'||
                           to_char(notrec.begin_date ), calign=>'left',
                	      cnowrap=>1);

       END IF;

       IF (l_worklist_col_definition(l_record_num).column_name =
             'DUE_DATE') THEN

           htp.tableData(cvalue=>'<font color=#000000 size=3>'||
                         nvl(to_char(notrec.due_date), '<BR>'),
                         calign=>'left', cnowrap=>1);

       END IF;

     END LOOP;

    htp.tableRowClose;

    <<skip_it>>
    fetch wl_cursor into notrec;
    exit when wl_cursor%NOTFOUND;
  end loop;
  close wl_cursor;

  htp.tableClose;

exception
  when others then
    rollback;
    if (wl_cursor%isopen) then
      close wl_cursor;
    end if;
    if (attrs%isopen) then
      close attrs;
    end if;
    wf_core.context('Wf_Plug','WorkList');
    wf_plug.Error;
end Worklist;


/*===========================================================================
  PROCEDURE NAME:	edit_worklist_definition

  DESCRIPTION:  	Allows you to modify the look and feel of your
			worklist.  This definition mechanism is used
			for both the standard Worklist UI as well as the
			plug UI.

			If the p_plug_id = '0' then it assumes you are
			defining the default look and feel for the
			Worklist plug

			If the p_username = '0' then it assumes you are
			defining the default look and feel for the
			standard Worklist UI.

============================================================================*/

PROCEDURE edit_worklist_definition (p_plug_id    IN VARCHAR2 DEFAULT null,
				    p_username   IN VARCHAR2 DEFAULT null,
                                    p_add_column IN VARCHAR2 DEFAULT '0') IS


l_no_parameters_passed    BOOLEAN := FALSE;
l_definition_exists       VARCHAR2(1) := 'Y';
l_record_num              NUMBER := 0;
ii                        NUMBER := 0;
l_columns_to_show         NUMBER := 0;
l_size                    NUMBER := 0;
l_username varchar2(320);   -- Username to query
l_realname varchar2(360);   -- Display name of username
l_admin_role varchar2(320); -- Role for admin mode
s0 varchar2(2000);
lang_codeset varchar2(50); -- Language Codeset from environment
			     -- (e.g. WE8ISO8859P1)

l_worklist_definition     wf_plug.wf_worklist_definition_record;
l_worklist_col_definition wf_plug.wf_worklist_col_def_table;


CURSOR lkcurs(lktype in varchar2) IS
    SELECT   WL.MEANING, WL.LOOKUP_CODE
    FROM     WF_LOOKUPS WL
    WHERE    WL.LOOKUP_TYPE = lktype
    AND      WL.LOOKUP_CODE IN ('SUBJECT', 'DUE_DATE', 'BEGIN_DATE', 'MESSAGE_TYPE')
    ORDER BY WL.MEANING;

CURSOR lkcurs_order(lktype in varchar2) IS
    SELECT   WL.MEANING, WL.LOOKUP_CODE
    FROM     WF_LOOKUPS WL
    WHERE    WL.LOOKUP_TYPE = lktype
    AND      WL.LOOKUP_CODE IN ('SUBJECT', 'DUE_DATE', 'BEGIN_DATE', 'MESSAGE_TYPE', 'PRIORITY')
    ORDER BY WL.MEANING;

CURSOR c_fetch_col_def (c_plug_id IN NUMBER,
                        c_username IN VARCHAR2) IS
SELECT
 ROWID    ROW_ID,
 PLUG_ID,
 USERNAME,
 COLUMN_NUMBER,
 COLUMN_NAME,
 COLUMN_SIZE
FROM WF_WORKLIST_COL_DEFINITIONS
WHERE (PLUG_ID = c_plug_id and c_plug_id IS NOT NULL)
OR    (USERNAME = c_username and c_username IS NOT NULL and c_plug_id IS NULL)
ORDER BY COLUMN_NUMBER;


BEGIN

  -- Check session and current user
  wfa_sec.GetSession(l_username);
  l_username := upper(l_username);
  wf_directory.GetRoleInfo(l_username, l_realname, s0, s0, s0, s0);

  -- Get language codeset
  lang_codeset := substr(userenv('LANGUAGE'),instr(userenv('LANGUAGE'),'.')+1,
                         length(userenv('LANGUAGE')));

  -- Make sure you have either the definition that the user created or the
  -- default definition
  get_plug_definition (p_plug_id, l_worklist_definition);

 -- Get the plug definition if the plug_id is not null
 IF (p_plug_id IS NOT NULL OR p_username IS NOT NULL) THEN

    BEGIN

    SELECT  ROWID ROW_ID,
            PLUG_ID,
	    USERNAME,
   	    DEFINITION_NAME,
	    WHERE_STATUS,
	    WHERE_FROM,
	    WHERE_ITEM_TYPE,
	    WHERE_NOTIF_TYPE,
	    WHERE_SUBJECT,
	    WHERE_SENT_START,
	    WHERE_SENT_END,
	    WHERE_DUE_START,
	    WHERE_DUE_END,
	    WHERE_PRIORITY,
	    WHERE_NOTIF_DEL_BY_ME,
	    ORDER_PRIMARY,
	    ORDER_ASC_DESC
    INTO    l_worklist_definition
    FROM    WF_WORKLIST_DEFINITIONS
    WHERE   (PLUG_ID = p_plug_id AND p_plug_id IS NOT NULL)
    OR      (USERNAME = p_username AND p_username IS NOT NULL and p_plug_id IS NULL);

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_definition_exists    := 'N';
       WHEN OTHERS THEN
          RAISE;
    END;

    --  If the definition exists then go get the column definition information
    IF (l_definition_exists = 'Y') THEN

       OPEN c_fetch_col_def (l_worklist_definition.plug_id,
                             l_worklist_definition.username);

       /*
       ** Loop through all the lookup_code rows for the given lookup_type
       ** filling in the p_wf_lookups_tbl
       */
       LOOP

           l_record_num := l_record_num + 1;

           FETCH c_fetch_col_def INTO
               l_worklist_col_definition(l_record_num);

           EXIT WHEN c_fetch_col_def%NOTFOUND;

       END LOOP;

       CLOSE c_fetch_col_def;

    END IF;

 -- Must have either a plug_id or username passed in otherwise show an error
 ELSE

    l_no_parameters_passed := TRUE;
    Wf_Core.Context('wf_plug', 'edit_worklist_definition',
       'missing parameter values');
    wf_plug.Error;
    return;

  END IF;

  -- Page title
  htp.htmlOpen;
  htp.headOpen;
  htp.title(ctitle=>wf_core.translate('WF_EDIT_WORKLIST_TITLE'));

  htp.headClose;
  htp.p('<BODY bgcolor='||icx_plug_utilities.bgcolor||'>');

  -- Open body and draw standard header
  if (p_plug_id =0) then
      icx_plug_utilities.toolbar(p_text => wf_core.translate('WF_EDIT_WORKLIST_TITLE'),
                             p_disp_mainmenu => 'N',
                             p_disp_menu => 'N');
  else
      icx_plug_utilities.toolbar(p_text => icx_plug_utilities.getPlugTitle(p_plug_id),
                             p_disp_mainmenu => 'N',
                             p_disp_menu => 'N');
  end if;

  htp.tableopen;

  htp.tablerowopen;

  htp.p('<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>');

  htp.p('<TD>'||wf_core.translate('WF_EDIT_WORKLIST_HELP')||'</TD>');

  htp.p('<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>');

  htp.tablerowclose;

  htp.tableclose;

  htp.tableopen(calign=>'CENTER');

  htp.tablerowopen;

  htp.p('<TD>');

  -- wf_dsk.submit_dsk is the url(procedure) to which the contents
  -- of this form is sent
  htp.p('<FORM NAME="WFPLUG" ACTION="wf_plug.submit_worklist_definition" METHOD="POST">');

  htp.formHidden(cname=>'plug_id', cvalue=>p_plug_id);
  htp.formHidden(cname=>'username', cvalue=>p_username);
  htp.formHidden(cname=>'definition_name', cvalue=>null);

  htp.bold(wf_core.translate('WF_EDIT_WORKLIST_COLUMNS'));
  htp.br;
  htp.br;


  -- There are some notifications for the user. Construct the page.
  htp.tableOpen;

  -- Column Titles
  htp.tableRowOpen;

  htp.p('<TD>');

  -- Create the column titles table inside the outer tablex
  htp.p('<TABLE border=1 cellpadding=2 bgcolor=white>');

  htp.tableRowOpen(cattributes=>'bgcolor='||icx_plug_utilities.plugbannercolor);

  -- If the p_add_columns to show has been passed in that means the user
  -- has asked to add a column to the list.
  l_columns_to_show := 4;

  FOR l_record_num IN 1..l_columns_to_show LOOP

      htp.p('<TH><font color=#000000>'||
          wf_core.translate('COLUMN')||' '||
          TO_CHAR(l_record_num)||'</font></TD>');

  END LOOP;

  htp.tableRowClose;

  htp.tableRowOpen(cattributes=>'bgcolor='||icx_plug_utilities.plugbannercolor);

  -- Display the LOV's for the column names that are in each column
  htp.tableRowOpen;

  FOR l_record_num IN 1..l_columns_to_show LOOP

     htp.p('<TD>');

     htp.formSelectOpen(cname=>'COLUMN_NAME');

     -- Loop on each of the possible column names that can be selected
     -- for a given column.
     -- Need to make this a table so you only select it once.
     FOR orderby IN lkcurs('WFSTD_WLORDERBY') LOOP
        IF (l_record_num <= l_worklist_col_definition.count AND
             l_worklist_col_definition(l_record_num).column_name =
              orderby.lookup_code) THEN
            htp.formSelectOption(cvalue=>orderby.meaning,
                                 cselected => 'SELECTED',
                                 cattributes=>'value='||orderby.lookup_code);
        ELSE
             htp.formSelectOption(cvalue=>orderby.meaning,
                                  cattributes=>'value='||orderby.lookup_code);
        END IF;

     END LOOP;

     IF (l_record_num > l_worklist_col_definition.count) THEN

        htp.formSelectOption(cvalue=>wf_core.translate('BLANK'),
                              cselected => 'SELECTED',
                                  cattributes=>'value=NULL');

     ELSE

        htp.formSelectOption(cvalue=>wf_core.translate('BLANK'),
                                  cattributes=>'value=NULL');

     END IF;

     htp.formSelectClose;

     htp.p('</TD>');

  END LOOP;

  htp.tableRowClose;

  htp.tableClose;

  htp.p('<TD></TD>');

  htp.p('<TD>');

  -- Create the order column title table inside the outer tablex
  htp.p('<TABLE border=1 cellpadding=2 bgcolor=white>');

  htp.tableRowOpen(cattributes=>'bgcolor='||icx_plug_utilities.plugbannercolor);

  htp.p('<TH>'||wf_core.translate('ORDERBY')||'</TD>');

  htp.tableRowClose;

  htp.tableRowOpen;

  htp.p('<TD>');

  htp.formSelectOpen('orderkey');
  for orderby in lkcurs_order('WFSTD_WLORDERBY') loop
    if (orderby.lookup_code = l_worklist_definition.order_primary) then
      htp.formSelectOption(cvalue=>orderby.meaning,
                           cselected => 'SELECTED',
                           cattributes=>'value='||orderby.lookup_code);
    else
      htp.formSelectOption(cvalue=>orderby.meaning,
                           cattributes=>'value='||orderby.lookup_code);
    end if;
  end loop;

  htp.formSelectClose;

  htp.p('</TD>');

  htp.tableRowClose;

  htp.tableClose; -- Worklist display

  htp.tableClose; -- outer table

  -- Place an extra space between the other search criteria and order by
  htp.br;

  htp.bold(wf_core.translate('WF_EDIT_WORKLIST_CRITERIA'));

  htp.tableOpen; -- Show me only

  -- Add blank row
  htp.tableRowOpen;
  htp.tableData(htf.br);
  htp.tableRowClose;

  find_criteria (username=>l_username,
                 status=>l_worklist_definition.where_status,
                 fromuser=>l_worklist_definition.where_from,
  		 ittype=>l_worklist_definition.where_item_type,
  		 msubject=>l_worklist_definition.where_subject,
  		 beg_sent=>l_worklist_definition.where_sent_start,
  		 end_sent=>l_worklist_definition.where_sent_end,
  		 beg_due=>l_worklist_definition.where_due_start,
  		 end_due=>l_worklist_definition.where_due_end,
  		 priority=>l_worklist_definition.where_priority,
  		 delegated_by_me=>l_worklist_definition.where_notif_del_by_me,
                 orderkey=>l_worklist_definition.order_primary,
                 customize=>'Y');

  -- Add blank row
  htp.tableRowOpen;
  htp.tableData(htf.br);
  htp.tableRowClose;

  htp.formHidden(cname=>'definition_exists', cvalue=>l_definition_exists);
  htp.tableClose; -- Show me only

  htp.p('<CENTER>');
  htp.tableOpen; -- OK
  -- Add submit button
  htp.tableRowOpen;

  htp.p('<TD width=50% align="right">');

  icx_plug_utilities.buttonleft(wf_core.translate('WF_EDIT_LONG_OK'),'javascript:document.WFPLUG.submit()', 'FNDJLFOK.gif');
--   htp.p('<A href=javascript:document.WFPLUG.submit()> OK </A>');

  htp.p('</TD><TD width=50% align="left">');


  -- fixed bug for cancel button
  icx_plug_utilities.buttonright(wf_core.translate('CANCEL'),'javascript:history.back()', 'FNDJLFCN.gif');
--  icx_plug_utilities.buttonright(wf_core.translate('CANCEL'),icx_plug_utilities.MainMenulink, 'FNDJLFCN.gif');

  htp.p('</TD>');

  htp.tableRowClose;

  htp.tableClose; -- OK
  htp.p('</CENTER>');

  htp.formClose;

  htp.p('</TD>');

  htp.tablerowclose;

  htp.tableclose;

  wfa_sec.footer;
  htp.htmlClose;

exception
  when others then
    Wf_Core.Context('wf_plug', 'edit_worklist_definition',
        p_plug_id, p_username);
    wf_plug.Error;

END edit_worklist_definition;

/*===========================================================================
  PROCEDURE NAME:	submit_worklist_definition

  DESCRIPTION:  	Saves the worklist definition in the database.

============================================================================*/
PROCEDURE submit_worklist_definition (
  plug_id         IN VARCHAR2 DEFAULT NULL,
  username        IN VARCHAR2 DEFAULT NULL,
  definition_name IN VARCHAR2 DEFAULT NULL,
  column_name     IN column_name_array,
  status 	  IN VARCHAR2 DEFAULT '*',
  fromuser 	  IN VARCHAR2 DEFAULT '*',
  user 		  IN VARCHAR2 DEFAULT NULL,
  ittype 	  IN VARCHAR2 DEFAULT '*',
  msubject 	  IN VARCHAR2 DEFAULT '*',
  beg_sent 	  IN VARCHAR2 DEFAULT '*',
  end_sent 	  IN VARCHAR2 DEFAULT '*',
  beg_due 	  IN VARCHAR2 DEFAULT '*',
  end_due 	  IN VARCHAR2 DEFAULT '*',
  hpriority 	  IN VARCHAR2 DEFAULT null,
  mpriority 	  IN VARCHAR2 DEFAULT null,
  lpriority 	  IN VARCHAR2 DEFAULT null,
  delegated_by_me IN VARCHAR2 DEFAULT '0',
  orderkey	  IN VARCHAR2 DEFAULT 'PRIORITY',
  definition_exists  IN VARCHAR2 DEFAULT 'N'
)
IS

  l_plug_id          VARCHAR2(30)  := plug_id;
  l_username         VARCHAR2(320)  := username;
  l_definition_name  VARCHAR2(30)  := definition_name;
  l_status 	     VARCHAR2(30)  := NVL(status, '*');
  l_fromuser 	     VARCHAR2(320)  := NVL(fromuser, '*');
  l_user 	     VARCHAR2(320)  := user;
  l_ittype 	     VARCHAR2(8)   := NVL(ittype, '*');
  l_msubject 	     VARCHAR2(240) := NVL(msubject, '*');
  l_beg_sent 	     DATE;
  l_end_sent 	     DATE;
  l_beg_due 	     DATE;
  l_end_due 	     DATE;
  l_priority 	     VARCHAR2(10)  := NVL(hpriority||mpriority||lpriority, '*');
  l_delegated_by_me  VARCHAR2(1)   := NVL(delegated_by_me, '0');
  l_orderkey	     VARCHAR2(30)  := NVL(orderkey, 'PRIORITY');
  l_column_name      VARCHAR2(30)  := null;
  l_column_size      NUMBER        := 0;
  l_columns_to_show  NUMBER        := 0;

BEGIN

  -- Check session and current user
  wfa_sec.GetSession(l_username);
  l_username := upper(l_username);

  IF (beg_sent IS NOT NULL) THEN

     l_beg_sent := TO_DATE('01/01/2000', 'MM/DD/YYYY') + TO_NUMBER(beg_sent);

  END IF;


  IF (definition_exists = 'N') THEN

     INSERT INTO WF_WORKLIST_DEFINITIONS
     (	PLUG_ID			,
	USERNAME		,
	DEFINITION_NAME		,
        WHERE_STATUS		,
	WHERE_FROM		,
        WHERE_ITEM_TYPE 	,
        WHERE_SUBJECT		,
        WHERE_SENT_START	,
        WHERE_SENT_END		,
        WHERE_DUE_START		,
        WHERE_DUE_END		,
        WHERE_PRIORITY		,
        WHERE_NOTIF_DEL_BY_ME	,
        ORDER_PRIMARY
     )
    VALUES
    (
        TO_NUMBER(l_plug_id),
        l_username,
        l_definition_name,
        l_status,
        l_fromuser,
        l_ittype,
        l_msubject,
        l_beg_sent,
        l_end_sent,
        l_beg_due,
        l_end_due,
        l_priority,
        l_delegated_by_me,
        l_orderkey
    );

  ELSE

     UPDATE WF_WORKLIST_DEFINITIONS
     SET DEFINITION_NAME	= l_definition_name,
        WHERE_STATUS		= l_status,
	WHERE_FROM		= l_fromuser,
        WHERE_ITEM_TYPE 	= l_ittype,
        WHERE_SUBJECT		= l_msubject,
        WHERE_SENT_START	= l_beg_sent,
        WHERE_SENT_END		= l_end_sent,
        WHERE_DUE_START		= l_beg_due,
        WHERE_DUE_END		= l_end_due,
        WHERE_PRIORITY		= l_priority,
        WHERE_NOTIF_DEL_BY_ME	= l_delegated_by_me,
        ORDER_PRIMARY           = l_orderkey
      WHERE   PLUG_ID = TO_NUMBER(l_plug_id);

      -- Delete all the old column definitions
      DELETE FROM WF_WORKLIST_COL_DEFINITIONS
      WHERE   PLUG_ID = TO_NUMBER(l_plug_id);

  END IF;

  -- Insert the new column definitions
  FOR l_record_num IN 1..column_name.count LOOP

     l_column_name := column_name(l_record_num);

     -- The user deletes a column by selecting delete from the poplist.
     -- Since all the columns are already deleted you can just skip it
     -- here.
     IF (l_column_name <> 'NULL') THEN

        INSERT INTO WF_WORKLIST_COL_DEFINITIONS
        (	PLUG_ID			,
   		USERNAME		,
		DEFINITION_NAME		,
        	COLUMN_NUMBER           ,
        	COLUMN_NAME             ,
	        COLUMN_SIZE
	)
	VALUES
        (
	        TO_NUMBER(l_plug_id),
        	l_username,
	        l_definition_name,
        	l_record_num,
	        l_column_name,
                100
        );

    END IF;

  END LOOP;

  icx_plug_utilities.gotomainmenu;

exception
  when others then
    Wf_Core.Context('wf_plug', 'submit_worklist_definition',
        plug_id, username);
    wf_plug.Error;

END submit_worklist_definition;

/*===========================================================================
  PROCEDURE NAME:	worklist_plug

  DESCRIPTION:  	creates the worklist plug for the ICX folks for
                        the customizable home page

============================================================================*/
PROCEDURE worklist_plug (
p_session_id     IN      VARCHAR2 DEFAULT NULL,
p_plug_id        IN      VARCHAR2 DEFAULT NULL,
p_display_name   IN      VARCHAR2 DEFAULT NULL,
p_delete         IN      VARCHAR2 DEFAULT 'N') IS

BEGIN

   IF (p_delete = 'Y') THEN

      -- Delete all the old column definitions
      DELETE FROM WF_WORKLIST_COL_DEFINITIONS
      WHERE  PLUG_ID = TO_NUMBER(p_plug_id) ;

      -- Delete all the old plug definition
      DELETE FROM WF_WORKLIST_DEFINITIONS
      WHERE  PLUG_ID = TO_NUMBER(p_plug_id) ;


   ELSE

      wf_plug.worklist (plug_id=>p_plug_id, session_id=>p_session_id,
                        display_name=>p_display_name);

   END IF;

   COMMIT;

exception
  when others then
    Wf_Core.Context('wf_plug', 'worklist_plug',
        p_session_id,p_plug_id,p_delete);
    wf_plug.Error;

END worklist_plug;

end WF_PLUG;

/
