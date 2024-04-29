--------------------------------------------------------
--  DDL for Package IBU_SUBS_EMAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBU_SUBS_EMAIL_PKG" AUTHID CURRENT_USER as
/* $Header: ibusubss.pls 115.29 2004/01/16 20:26:26 mukhan ship $ */

		 app_id	constant integer:=672;
		 profile_name constant varchar2(30):='IBU_A_PROFILE00';
	     isTEST constant               BOOLEAN:=FALSE;
         lclob CLOB;

        procedure ibu_create_or_update_role (user_id in NUMBER, email_address_in in varchar2, planguage in varchar2);

        procedure ibu_get_role_info (role_name in varchar2,
                      display_Name out NOCOPY varchar2,
                      email_Address out NOCOPY varchar2,
                      notification_Preference out NOCOPY varchar2,
                      language out NOCOPY varchar2,
                      territory out NOCOPY varchar2);

        procedure StartProcess (roleName in varchar2,
                         subject in varchar2,
                         username in varchar2,
                         companyName in varchar2,
					companyWebAddr in varchar2,
					companyEmailAddr in varchar2,
					currentDate in varchar2,
                         content in jtf_varchar2_table_32767,
                         ProcessOwner in varchar2,
                         Workflowprocess in varchar2 default null,
                         item_type in varchar2 default null);
        procedure ibu_update_role (role_name varchar2,
                      role_display_name varchar2,
                      notification_preference varchar2,
                      language varchar2,
                      territory varchar2,
                      email_address varchar2,
                      fax varchar2);

	  procedure SET_ADMIN_ROLE (itemtype in varchar2,
						   itemkey in varchar2,
						   actid in number,
						   funcmode in varchar2,
						   resultout out NOCOPY varchar2);

end IBU_SUBS_EMAIL_PKG;

 

/
