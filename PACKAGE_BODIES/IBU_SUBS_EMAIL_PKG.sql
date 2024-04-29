--------------------------------------------------------
--  DDL for Package Body IBU_SUBS_EMAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_SUBS_EMAIL_PKG" as
/* $Header: ibusubsb.pls 120.1.12010000.2 2010/01/13 11:41:12 mkundali ship $ */
		SECONDS_IN_DAY	constant	INTEGER:=60*60*24;
		SECONDS_IN_REP	constant	INTEGER:=60*10;

		DoNothing				BOOLEAN;

procedure ibu_create_or_update_role (user_id in NUMBER, email_address_in in varchar2, planguage in varchar2)
as
	user_name      varchar2(100):=NULL;
	user_display_name   varchar2(100):=NULL;
	language		varchar2(100):= planguage;
	territory		varchar2(100):='America';
	description	varchar2(100):=NULL;
	notification_preference varchar2(100):='MAILHTM2' ;
	email_address	varchar2(100):=NULL;
	fax			varchar2(100):=NULL;
	status		varchar2(100):='ACTIVE';
	expiration_date varchar2(100):=NULL;
	role_name		varchar2(100):=NULL;
	role_display_name	varchar2(100):=NULL;
	role_description 	varchar2(100):=NULL;
	wf_id		Number;
	msg_type  varchar2(100):='CRMNOTIF';
	msg_name  varchar2(100):='DEFMSG';

	due_date date:=NULL;
	callback varchar2(100):=NULL;
     context varchar2(100):=NULL;
     send_comment varchar2(100):=NULL;
     priority  number:=NULL;

duplicate_user_or_role	exception;
PRAGMA	EXCEPTION_INIT (duplicate_user_or_role, -20002);

begin
	/*Create a role from user_id passed in*/
	role_name:='IBU_ROLE' || user_id;
	role_display_name:=role_name || 'Dis';
	email_address:=email_address_in;

	begin
	  /*
	  	Pre 11.5.10:
		Calling CreateAdHocRole alone was creating a role in
		WF_ROLES, but wasn't creating a user in WF_USER_ROLES
		which is required by WF_NOTIFICATION.SendGroup
		which internally calls Wf_Directory.GetRoleOrigSysInfo

	  	For 11.5.10:
	     Since CreateAdHocRole itself doesn't create a user in
	     WF_USER_ROLES, so calling CreateAdHocUser instead
		which creates a user in WF_USER_ROLES and an
		implicit role in WF_ROLES with ORIG_SYSTEM = 'WF_LOCAL_USERS'
		and ORIG_SYSTEM_ID = 0
	  */

       WF_DIRECTORY.CreateAdHocUser(role_name,
	                              role_display_name,
							language,
							territory,
							description,
							notification_preference,
							email_address,
							fax,
							status,
							expiration_date);
	exception
		when duplicate_user_or_role then
			WF_Directory.SetAdHocUserAttr(role_name,
									role_display_name,
									notification_preference,
									language,
									territory,
									email_address,
									fax);
	end;
end;

 /* Added by Mani on 4/9/00 - to start workflow process */
 /* modified by mukhan on 8/15/03 */
 -- Added addition tokens
 -- simple text attribute were parsing HTML anchors
 -- started using 16 PLSQL document attributes
 -- only 2K of data gets through PLSQL document id
 procedure StartProcess (roleName in varchar2,
                         subject in varchar2,
                         username in varchar2,
                         companyName in varchar2,
					companyWebAddr in varchar2,
					companyEmailAddr in varchar2,
					currentDate in varchar2,
                         content in jtf_varchar2_table_32767,
                         ProcessOwner in varchar2,
                         Workflowprocess in varchar2 ,
                         item_type in varchar2 ) is
       ItemType varchar2(30) := nvl(item_type, 'IBUHPSUB');
       ItemKey  varchar2(30) := 'NOTIF_' || roleName; -- this is not being used
       ItemUserKey varchar2(30) := roleName;

       cnt number := 0;
       l_user varchar2(50);
       seq number := 0;
       create_seq varchar2(50) := 'create sequence IBU_NOTIFICATION_S';
      -- get_seq varchar2(50) := 'select ' || 'IBU_NOTIFICATION_S' || '.nextval from dual';
       get_seq varchar2(50) := 'select ' || 'IBU_WF_ITEM_KEY_S' || '.nextval from dual';
       TYPE     IBU_STRING_ARRAY IS VARRAY(10) OF VARCHAR2(32767); -- mk changed from 4000 to 32767
       arr IBU_STRING_ARRAY;
       l_content varchar2(32766);

       --outfile  UTL_FILE.FILE_TYPE;
       mailAttrNames  Wf_Engine.NameTabTyp ;
       mailAttrVals   Wf_Engine.TextTabTyp ;

       begin

                     /* Get schema name */
				 select user into l_user from dual;

                     /* Get sequence for item key to be unique */
                     /* select count(*)
				  into cnt
				  from all_objects
				  where object_name like 'IBU_NOTIFICATION_S'
				  and object_type = 'SEQUENCE'
				  and owner = l_user;

                      if cnt = 0 then
                         execute immediate create_seq;

                      else
                         execute immediate get_seq into seq;
                      end if; */
                      execute immediate get_seq into seq;

                      ItemKey := roleName || seq;

                      wf_engine.CreateProcess (itemtype => ItemType,
                                                 itemkey => ItemKey,
                                                 process => WorkflowProcess );
                      wf_engine.SetItemUserKey (itemtype => Itemtype,
                                                 itemkey => Itemkey,
                                                 userkey => ItemUserKey);
                      wf_engine.SetItemAttrText (itemtype => Itemtype,
                                                 itemkey => Itemkey,
                                                 aname => 'IBU_ROLE',
                                                 avalue => roleName);
                      wf_engine.SetItemAttrText (itemtype => Itemtype,
                                                 itemkey => Itemkey,
                                                 aname => 'IBU_SUBJECT_ITEM',
                                                 avalue => subject);
                      wf_engine.SetItemAttrText (itemtype => Itemtype,
                                                 itemkey => Itemkey,
                                                 aname => 'IBU_USER_NAME',
                                                 avalue => username);
                      wf_engine.SetItemAttrText (itemtype => Itemtype,
                                                 itemkey => Itemkey,
                                                 aname => 'IBU_COMPANY_NAME',
                                                 avalue => companyName );
                      wf_engine.SetItemAttrText (itemtype => Itemtype,
                                                 itemkey => Itemkey,
                                                 aname => 'IBU_COMPANY_WEB_ADDR',
                                                 avalue => companyWebAddr );
                      wf_engine.SetItemAttrText (itemtype => Itemtype,
                                                 itemkey => Itemkey,
                                                 aname => 'IBU_COMPANY_EMAIL',
                                                 avalue => companyEmailAddr );
                      wf_engine.SetItemAttrText (itemtype => Itemtype,
                                                 itemkey => Itemkey,
                                                 aname => 'IBU_CURRENT_DATE',
                                                 avalue => currentDate );

                      -- to be used for debugging
                      --outfile := UTL_FILE.FOPEN('/appslog/srv_top/utl/srvdv11i/out',
	              --                        roleName || subject,'W',32234);

                      for i in 1..16
                      loop
                         if (i <= content.count and content(i) is not null) then
                             mailAttrNames(i) := 'IBUCONTENT' || TO_CHAR(i);
                             mailAttrVals(i) := 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/' || content(i);
                             --UTL_FILE.PUT_LINE(outfile,content(i), true);
                         end if;
                      end loop;

                      -- UTL_FILE.FCLOSE(outfile);

                      wf_engine.SetItemAttrTextArray( Itemtype,
                                                      Itemkey,
                                                      mailAttrNames,
                                                      mailAttrVals);

                      wf_engine.SetItemOwner  (itemtype => Itemtype,
						itemkey => Itemkey,
						  owner => roleName);

                      wf_engine.StartProcess (itemtype => Itemtype,
					       itemkey => Itemkey );

       end StartProcess;

       procedure ibu_get_role_info (role_name in varchar2,
                      display_Name out NOCOPY varchar2,
                      email_Address out NOCOPY varchar2,
                      notification_Preference out NOCOPY varchar2,
                      language out NOCOPY varchar2,
                      territory out NOCOPY varchar2) is
       begin
          wf_directory.GetRoleInfo (role_name,
                      display_Name,
                      email_Address,
                      notification_Preference,
                      language,
                      territory);
       end ibu_get_role_info;

       procedure ibu_update_role (role_name in varchar2,
                      role_display_name in varchar2,
                      notification_preference in varchar2,
                      language in varchar2,
                      territory in varchar2,
                      email_address in varchar2,
                      fax in varchar2) is
       begin
		  WF_Directory.SetAdHocRoleAttr (role_name, role_display_name, notification_preference, language, territory, email_address, fax);
       end ibu_update_role;

	  procedure SET_ADMIN_ROLE (itemtype in varchar2,
						   itemkey in varchar2,
						   actid in number,
						   funcmode in varchar2,
						   resultout out nocopy varchar2) is

		  l_error_itemtype      VARCHAR2(8);
		  l_error_itemkey       VARCHAR2(240);
		  l_administrator VARCHAR2(100);
		  l_ADMINISTRATOR_NOT_SET   EXCEPTION;
		  begin

		  BEGIN
			  l_administrator := FND_PROFILE.VALUE('IBU_WF_ADMINISTRATOR');
		  EXCEPTION
			  WHEN NO_DATA_FOUND THEN
			  l_administrator := 'SYSADMIN';
		  END;

		  IF (l_administrator IS NULL) THEN
			  l_administrator := 'SYSADMIN';
		  END IF;

		  wf_engine.SetItemAttrText (itemtype => Itemtype,
							    itemkey => Itemkey,
							    aname => 'IBU_ERROR_ADMIN_ROLE',
							    avalue => l_administrator);

	  end SET_ADMIN_ROLE;

end IBU_SUBS_EMAIL_PKG;

/
