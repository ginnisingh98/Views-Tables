--------------------------------------------------------
--  DDL for Package Body JUMF_LCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JUMF_LCT_PKG" as
/* $Header: JTFUMLSB.pls 120.1 2006/01/16 00:54:35 vimohan noship $*/
procedure LOAD_SEED_TEMPLATES(
 x_upload_mode      in  varchar2,
 x_template_name    in  varchar2,
 x_description      in  varchar2,
 x_owner            in  varchar2,
 x_template_key     in  varchar2,
 x_page_name          in  varchar2,
 x_template_handler    in  varchar2,
 x_template_type_code    in  varchar2,
 x_enabled_flag          in  varchar2,
 x_application_id        in varchar2,
 x_effective_start_date  in varchar2,
 x_effective_end_date    in varchar2,
 x_last_update_date      in varchar2 ,
 x_custom_mode        in varchar2
)
is

         v_db_owner_id number;

      begin
        if ( x_upload_mode = 'NLS' ) then
          JTF_UM_TEMPLATES_PKG.TRANSLATE_ROW(
            X_TEMPLATE_ID =>  JTF_UMUTIL.template_lookup(x_template_key, to_date(x_effective_start_date,'YYYY/MM/DD HH24:MI:SS')),
            X_TEMPLATE_NAME => x_template_name,
            X_DESCRIPTION => x_description,
            X_OWNER => x_owner,
	    X_LAST_UPDATE_DATE => x_last_update_date,
	    X_CUSTOM_MODE => x_custom_mode
	    );
        else
         --   select LAST_UPDATED_BY
         --   into v_db_owner_id
         --   from JTF_UM_TEMPLATES_B
         --   where TEMPLATE_ID = JTF_UMUTIL.template_lookup(x_template_key, to_date(x_effective_start_date,'YYYY/MM/DD HH24: MI:SS'));

        --  if (v_db_owner_id = 1) then
            JTF_UM_TEMPLATES_PKG.LOAD_ROW(
                X_TEMPLATE_ID =>  JTF_UMUTIL.template_lookup(x_template_key, to_date(x_effective_start_date,'YYYY/MM/DD HH24:MI:SS')),
                X_TEMPLATE_KEY => x_template_key,
                X_PAGE_NAME => x_page_name,
                X_TEMPLATE_HANDLER     => x_template_handler,
                X_TEMPLATE_TYPE_CODE => x_template_type_code,
                X_TEMPLATE_NAME => x_template_name,
                X_ENABLED_FLAG        => x_enabled_flag,
                X_APPLICATION_ID => to_number(x_application_id),
                X_EFFECTIVE_START_DATE => to_date(x_effective_start_date,'YYYY/MM/DD HH24:MI:SS'),
                X_EFFECTIVE_END_DATE => to_date(x_effective_end_date,'YYYY/MM/DD HH24:MI:SS'),
                X_DESCRIPTION => x_description,
                X_OWNER => x_owner,
		X_LAST_UPDATE_DATE => x_last_update_date,
	        X_CUSTOM_MODE => x_custom_mode 		 );
         -- end if;
        end if;

      exception
        when no_data_found then
          JTF_UM_TEMPLATES_PKG.LOAD_ROW(
                X_TEMPLATE_ID =>  JTF_UMUTIL.template_lookup(x_template_key, to_date(x_effective_start_date,'YYYY/MM/DD HH24:MI:SS')),
                X_TEMPLATE_KEY => x_template_key,
                X_PAGE_NAME => x_page_name,
                X_TEMPLATE_HANDLER     => x_template_handler,
                X_TEMPLATE_TYPE_CODE => x_template_type_code,
                X_TEMPLATE_NAME =>  x_template_name,
                X_ENABLED_FLAG  => x_enabled_flag,
                X_APPLICATION_ID => to_number(x_application_id),
                X_EFFECTIVE_START_DATE => to_date(x_effective_start_date,'YYYY/MM/DD HH24:MI:SS'),
                X_EFFECTIVE_END_DATE => to_date(x_effective_end_date,'YYYY/MM/DD HH24:MI:SS'),
                X_DESCRIPTION => x_description,
                X_OWNER => x_owner,
                X_LAST_UPDATE_DATE => x_last_update_date,
	        X_CUSTOM_MODE => x_custom_mode
		);

end LOAD_SEED_TEMPLATES;


procedure LOAD_SEED_APPROVALS(
x_upload_mode in varchar2,
x_approval_key in varchar2,
x_approval_key_start_date in varchar2,
x_approval_name in varchar2,
x_description in varchar2,
x_owner in varchar2,
x_enabled_flag in varchar2,
x_application_id in varchar2,
x_wf_item_type in varchar2,
x_use_pending_req_flag in varchar2,
x_effective_end_date in varchar2,
x_last_update_date in varchar2,
x_custom_mode in varchar2 )

is

         v_db_owner_id number;

      begin
        if ( x_upload_mode  = 'NLS' ) then
          JTF_UM_APPROVALS_PKG.TRANSLATE_ROW(
	    X_APPROVAL_ID   =>  JTF_UMUTIL.approval_lookup(x_approval_key, to_date(x_approval_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
            X_APPROVAL_NAME => x_approval_name,
            X_DESCRIPTION   => x_description,
            X_OWNER         => x_owner,
	    X_LAST_UPDATE_DATE => x_last_update_date,
	    X_CUSTOM_MODE => x_custom_mode
	    );
	else
         --   select LAST_UPDATED_BY
         --   into v_db_owner_id
         --   from JTF_UM_APPROVALS_B
         --   where APPROVAL_ID = JTF_UMUTIL.approval_lookup(x_approval_key, to_date(x_approval_key_start_date,'YYYY/MM/DD HH24:MI:SS'));

        --  if (v_db_owner_id = 1) then
               JTF_UM_APPROVALS_PKG.LOAD_ROW(
	  	X_APPROVAL_ID		 =>  JTF_UMUTIL.approval_lookup(x_approval_key, to_date(x_approval_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
          	X_APPROVAL_KEY         => x_approval_key,
	  	X_ENABLED_FLAG 	 => x_enabled_flag,
          	X_APPLICATION_ID       => to_number(x_application_id),
	  	X_WF_ITEM_TYPE 	 => x_wf_item_type,
	  	X_USE_PENDING_REQ_FLAG => x_use_pending_req_flag,
	  	X_EFFECTIVE_START_DATE => to_date(x_approval_key_start_date,'YYYY/MM/DD HH24:MI:SS'),
	  	X_EFFECTIVE_END_DATE   => to_date(x_effective_end_date,'YYYY/MM/DD HH24:MI:SS'),
          	X_APPROVAL_NAME        => x_approval_name,
          	X_DESCRIPTION          => x_description,
          	X_OWNER                => x_owner,
		X_LAST_UPDATE_DATE => x_last_update_date,
	        X_CUSTOM_MODE => x_custom_mode
		);
        --  end if;
	end if;

      exception
        when no_data_found then
               JTF_UM_APPROVALS_PKG.LOAD_ROW(
	  	X_APPROVAL_ID		 =>  JTF_UMUTIL.approval_lookup(x_approval_key, to_date(x_approval_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
          	X_APPROVAL_KEY         => x_approval_key,
	  	X_ENABLED_FLAG 	 => x_enabled_flag,
          	X_APPLICATION_ID       => to_number(x_application_id),
	  	X_WF_ITEM_TYPE 	 => x_wf_item_type,
	  	X_USE_PENDING_REQ_FLAG =>  x_use_pending_req_flag,
	  	X_EFFECTIVE_START_DATE => to_date(x_approval_key_start_date,'YYYY/MM/DD HH24:MI:SS'),
	  	X_EFFECTIVE_END_DATE   => to_date(x_effective_end_date,'YYYY/MM/DD HH24:MI:SS'),
          	X_APPROVAL_NAME        => x_approval_name,
          	X_DESCRIPTION          => x_description,
          	X_OWNER                => x_owner,
		 X_LAST_UPDATE_DATE => x_last_update_date,
	    X_CUSTOM_MODE => x_custom_mode
		);

    end LOAD_SEED_APPROVALS;



    procedure LOAD_SEED_APPROVERS(
    x_upload_mode in varchar2,
    x_effective_start_date in varchar2,
    x_approval_key_start_date in varchar2,
    x_user_name in varchar2,
    x_approval_key in varchar2,
    x_approver_seq in varchar2,
    x_effective_end_date in varchar2,
    x_owner in varchar2,
    x_last_update_date in varchar2,
    x_custom_mode      in varchar2 )

    is

         v_db_owner_id number;
     BEGIN
        IF (x_upload_mode = 'NLS') THEN
          NULL;
     ELSE
      --  select LAST_UPDATED_BY
      --  into v_db_owner_id
      --  from JTF_UM_APPROVERS
      --  where  EFFECTIVE_START_DATE = to_date(x_effective_start_date,'YYYY/MM/DD HH24:MI:SS')
      --  and  APPROVAL_ID =  JTF_UMUTIL.approval_lookup(x_approval_key, to_date(x_approval_key_start_date,'YYYY/MM/DD HH24:MI:SS'))
      --  and  USER_ID = JTF_UMUTIL.user_lookup(x_user_name);

      --  if (v_db_owner_id = 1) then
	JTF_UM_APPROVALS_PKG.LOAD_APPROVERS_ROW(
	    X_APPROVAL_ID	   =>  JTF_UMUTIL.approval_lookup(x_approval_key, to_date(x_approval_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
            X_APPROVER_SEQ	   => to_number(x_approver_seq),
            X_USER_ID	           => JTF_UMUTIL.user_lookup(x_user_name),
	    X_EFFECTIVE_START_DATE => to_date(x_effective_start_date,'YYYY/MM/DD HH24:MI:SS'),
	    X_EFFECTIVE_END_DATE   => to_date(x_effective_end_date,'YYYY/MM/DD HH24:MI:SS'),
            X_OWNER                => x_owner,
	    X_LAST_UPDATE_DATE => x_last_update_date,
	    X_CUSTOM_MODE => x_custom_mode
	    );
      --  end if;
      END IF;

      exception
        when no_data_found then
	JTF_UM_APPROVALS_PKG.LOAD_APPROVERS_ROW(
	    X_APPROVAL_ID	   =>  JTF_UMUTIL.approval_lookup(x_approval_key, to_date(x_approval_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
            X_APPROVER_SEQ	   => to_number(x_approver_seq),
            X_USER_ID	           => JTF_UMUTIL.user_lookup(x_user_name),
	    X_EFFECTIVE_START_DATE => to_date(x_effective_start_date,'YYYY/MM/DD HH24:MI:SS'),
	    X_EFFECTIVE_END_DATE   => to_date(x_effective_end_date,'YYYY/MM/DD HH24:MI:SS'),
            X_OWNER                => x_owner,
	    X_LAST_UPDATE_DATE => x_last_update_date,
	    X_CUSTOM_MODE => x_custom_mode
	    );

    END LOAD_SEED_APPROVERS;



    procedure LOAD_SEED_USERTYPES(
    x_upload_mode in varchar2,
    x_usertype_key in varchar2,
    x_usertype_key_start_date in varchar2,
    x_usertype_name in varchar2,
    x_usertype_shortname in varchar2,
    x_description in varchar2,
    x_owner in varchar2,
    x_is_self_service_flag in varchar2,
    x_email_notification_flag in varchar2,
    x_enabled_flag in varchar2,
    x_approval_key in varchar2,
    x_approval_key_start_date in varchar2,
    x_application_id in varchar2,
    x_effective_end_date in varchar2,
    x_display_order in varchar2,
    x_last_update_date in varchar2,
    x_custom_mode in varchar2
    )

    is


         v_db_owner_id number;
         v_db_display_order number;
         v_db_usertype_shortname varchar2(230);

      begin
        if ( x_upload_mode = 'NLS' ) then
          JTF_UM_USERTYPES_PKG.TRANSLATE_ROW(
	    X_USERTYPE_ID   =>  JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
            X_USERTYPE_NAME => x_usertype_name,
            X_USERTYPE_SHORTNAME => NVL(x_usertype_shortname, 'CHANGE ME IN THE ADMIN CONSOLE: USERTYPE SETUP SCREEN'),
            X_DESCRIPTION   =>          x_description,
            X_OWNER         =>           x_owner,
	    X_LAST_UPDATE_DATE => x_last_update_date,
	    X_CUSTOM_MODE => x_custom_mode
	    );
	else
            select LAST_UPDATED_BY, DISPLAY_ORDER, USERTYPE_SHORTNAME
            into v_db_owner_id, v_db_display_order, v_db_usertype_shortname
            from JTF_UM_USERTYPES_VL
            where USERTYPE_ID = JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS'));



                JTF_UM_USERTYPES_PKG.LOAD_ROW(
  		X_USERTYPE_KEY 	=> x_usertype_key,
  		X_USERTYPE_ID		=> JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
 		X_IS_SELF_SERVICE_FLAG =>    x_is_self_service_flag,
  		X_EMAIL_NOTIFICATION_FLAG => x_email_notification_flag,
  		X_ENABLED_FLAG	=>           x_enabled_flag,
  		X_APPROVAL_ID		=> JTF_UMUTIL.approval_lookup_with_check(x_approval_key, to_date(x_approval_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
  		X_APPLICATION_ID => to_number(x_application_id),
  		X_EFFECTIVE_START_DATE => to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS'),
  		X_EFFECTIVE_END_DATE => to_date(x_effective_end_date,'YYYY/MM/DD HH24:MI:SS'),
  		X_USERTYPE_NAME => x_usertype_name,
                X_USERTYPE_SHORTNAME => NVL(x_usertype_shortname, 'CHANGE ME IN THE ADMIN CONSOLE: USERTYPE SETUP SCREEN'),
 		X_DESCRIPTION =>   x_description,
                X_DISPLAY_ORDER => x_display_order,
  		X_OWNER =>         x_owner,
		X_LAST_UPDATE_DATE => x_last_update_date,
		X_CUSTOM_MODE =>      x_custom_mode
		);




	end if;

      exception
        when no_data_found then
            JTF_UM_USERTYPES_PKG.LOAD_ROW(
                X_USERTYPE_KEY  => x_usertype_key,
                X_USERTYPE_ID           => JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
                X_IS_SELF_SERVICE_FLAG =>    x_is_self_service_flag,
                X_EMAIL_NOTIFICATION_FLAG => x_email_notification_flag,
                X_ENABLED_FLAG  =>           x_enabled_flag,
                X_APPROVAL_ID           => JTF_UMUTIL.approval_lookup_with_check(x_approval_key, to_date(x_approval_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
                X_APPLICATION_ID => to_number(x_application_id),
                X_EFFECTIVE_START_DATE => to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS'),
                X_EFFECTIVE_END_DATE => to_date(x_effective_end_date,'YYYY/MM/DD HH24:MI:SS'),
                X_USERTYPE_NAME => x_usertype_name,
                X_USERTYPE_SHORTNAME => NVL(x_usertype_shortname, 'CHANGE ME IN THE ADMIN CONSOLE: USERTYPE SETUP SCREEN'),
                X_DESCRIPTION =>   x_description,
                X_DISPLAY_ORDER => x_display_order,
                X_OWNER =>         x_owner,
		X_LAST_UPDATE_DATE => x_last_update_date,
		X_CUSTOM_MODE => x_custom_mode
		);

end LOAD_SEED_USERTYPES;


procedure LOAD_SEED_USERTYPE_TMPL(
x_upload_mode in varchar2,
x_usertype_key in varchar2,
x_usertype_key_start_date in varchar2,
x_template_key in varchar2,
x_template_key_start_date in varchar2,
x_effective_start_date in varchar2,
x_effective_end_date in varchar2,
x_owner in varchar2,
x_last_update_date in varchar2,
x_custom_mode       in varchar2
 )
is

    v_db_owner_id number;
         v_active_record_count number;

     begin
        if ( x_upload_mode = 'NLS' ) then
	  null;
	  return;
        else
           select count(*)
           into v_active_record_count
           from JTF_UM_USERTYPE_TMPL
           where USERTYPE_ID = JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS'))
           and EFFECTIVE_END_DATE is NULL
           and LAST_UPDATED_BY <> 1;

           if( v_active_record_count > 0 ) then
             return;
           end if;

           select LAST_UPDATED_BY
           into v_db_owner_id
           from JTF_UM_USERTYPE_TMPL
           where USERTYPE_ID = JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS'))
           and TEMPLATE_ID = JTF_UMUTIL.template_lookup(x_template_key, to_date(x_template_key_start_date,'YYYY/MM/DD HH24:MI:SS'))
           and EFFECTIVE_START_DATE = to_date(x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS');

          if (v_active_record_count = 0)  then
	    JTF_UM_USERTYPES_PKG.LOAD_USERTYPE_TMPL_ROW(
		X_USERTYPE_ID => JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
		X_TEMPLATE_ID => JTF_UMUTIL.template_lookup(x_template_key, to_date(x_template_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
		X_EFFECTIVE_START_DATE => to_date(x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS'),
		X_EFFECTIVE_END_DATE => to_date(x_effective_end_date, 'YYYY/MM/DD HH24:MI:SS'),
		X_OWNER => x_owner,
		X_LAST_UPDATE_DATE => x_last_update_date,
		X_CUSTOM_MODE => x_custom_mode
		);
          end if;

        end if;

      exception
        when no_data_found then

          update JTF_UM_USERTYPE_TMPL
          set EFFECTIVE_END_DATE = SYSDATE
          where EFFECTIVE_END_DATE is NULL
          and USERTYPE_ID = JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS'));

          JTF_UM_USERTYPES_PKG.LOAD_USERTYPE_TMPL_ROW(
                X_USERTYPE_ID => JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
                X_TEMPLATE_ID => JTF_UMUTIL.template_lookup(x_template_key, to_date(x_template_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
                X_EFFECTIVE_START_DATE => to_date(x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS'),
                X_EFFECTIVE_END_DATE => to_date(x_effective_end_date, 'YYYY/MM/DD HH24:MI:SS'),
                X_OWNER => x_owner,
		X_LAST_UPDATE_DATE => x_last_update_date,
		X_CUSTOM_MODE => x_custom_mode
		);

    end LOAD_SEED_USERTYPE_TMPL;


    procedure LOAD_SEED_USERTYPE_ROLE(
    x_upload_mode in varchar2,
    x_usertype_key in varchar2,
    x_usertype_key_start_date in varchar2,
    x_principal_name in varchar2,
    x_effective_start_date in varchar2,
    x_effective_end_date in varchar2,
    x_owner in varchar2,
    x_last_update_date in varchar2,
    x_custom_mode       in varchar2
    )
    is
         v_db_owner_id number;

     BEGIN
        IF (x_upload_mode = 'NLS') THEN
          NULL;
	  RETURN;
     ELSE
          --  select LAST_UPDATED_BY
          --  into v_db_owner_id
          --  from JTF_UM_USERTYPE_ROLE
          --  where USERTYPE_ID = JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS'))
          --  and PRINCIPAL_NAME = x_principal_name
          --  and EFFECTIVE_START_DATE = TO_DATE ( x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS' );

         -- if (v_db_owner_id = 1) then
	   JTF_UM_ROLE_RESP_PKG.LOAD_usertype_role_ROW(
            x_usertype_id   	   => JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
            x_principal_name	   => x_principal_name ,
	    x_effective_start_date => TO_DATE ( x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS' ) ,
	    x_effective_end_date   => TO_DATE ( x_effective_end_date, 'YYYY/MM/DD HH24:MI:SS' ) ,
	    x_owner 		   => x_owner ,
            X_LAST_UPDATE_DATE => x_last_update_date ,
            X_CUSTOM_MODE => x_custom_mode
	    );
        --  end if;
      END IF;

      exception
        when no_data_found then
          JTF_UM_ROLE_RESP_PKG.LOAD_usertype_role_ROW(
            x_usertype_id          => JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
            x_principal_name       => x_principal_name ,
            x_effective_start_date => TO_DATE ( x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS' ) ,
            x_effective_end_date   => TO_DATE ( x_effective_end_date, 'YYYY/MM/DD HH24:MI:SS' ) ,
            x_owner                => x_owner,
	    X_LAST_UPDATE_DATE => x_last_update_date ,
            X_CUSTOM_MODE => x_custom_mode
            );

    END LOAD_SEED_USERTYPE_ROLE;



procedure LOAD_SEED_USERTYPE_RESP(
x_upload_mode in varchar2,
x_usertype_key in varchar2,
x_usertype_key_start_date in varchar2,
x_responsibility_key in varchar2,
x_effective_start_date in varchar2,
x_is_default_flag in varchar2,
x_effective_end_date in varchar2,
x_owner in varchar2,
x_application_id in varchar2 ,
x_last_update_date in varchar2,
x_custom_mode       in varchar2
)

is

v_db_owner_id number;
         v_active_record_count number;

     begin
        if ( x_upload_mode = 'NLS' ) then
          null;
          return;
        else
           select count(*)
           into v_active_record_count
           from JTF_UM_USERTYPE_RESP
           where USERTYPE_ID = JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS'))
           and EFFECTIVE_END_DATE is NULL
           and LAST_UPDATED_BY <> 1;

           if( v_active_record_count > 0 ) then
             return;
           end if;

           select LAST_UPDATED_BY
           into v_db_owner_id
           from JTF_UM_USERTYPE_RESP
           where USERTYPE_ID = JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS'))
           and RESPONSIBILITY_KEY = x_responsibility_key
           and EFFECTIVE_START_DATE = to_date(x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS');

          if ( v_active_record_count = 0 ) then
	    JTF_UM_ROLE_RESP_PKG.LOAD_usertype_resp_ROW(
               x_usertype_id   	   => JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
               x_responsibility_key   => x_responsibility_key ,
               x_is_default_flag  	   => x_is_default_flag ,
	       x_effective_start_date => TO_DATE ( x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS' ) ,
	       x_effective_end_date   => TO_DATE ( x_effective_end_date, 'YYYY/MM/DD HH24:MI:SS' ) ,
	       x_owner 		   => x_owner ,
               x_application_id       => TO_NUMBER( x_application_id) ,
	       X_LAST_UPDATE_DATE => x_last_update_date ,
               X_CUSTOM_MODE => x_custom_mode

        );
          end if;
        end if;

      exception
        when no_data_found then

          update JTF_UM_USERTYPE_RESP
          set EFFECTIVE_END_DATE = SYSDATE
          where EFFECTIVE_END_DATE is NULL
          and USERTYPE_ID = JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS'));

          JTF_UM_ROLE_RESP_PKG.LOAD_usertype_resp_ROW(
              x_usertype_id       => JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
              x_responsibility_key   => x_responsibility_key ,
              x_is_default_flag           => x_is_default_flag ,
              x_effective_start_date => TO_DATE ( x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS' ) ,
              x_effective_end_date   => TO_DATE ( x_effective_end_date, 'YYYY/MM/DD HH24:MI:SS' ) ,
              x_owner             => x_owner ,
              x_application_id       => TO_NUMBER( x_application_id ),
	      X_LAST_UPDATE_DATE => x_last_update_date ,
              X_CUSTOM_MODE => x_custom_mode
          );

    end LOAD_SEED_USERTYPE_RESP;


procedure LOAD_SEED_SUBSCRIPTIONS(
x_upload_mode in varchar2,
x_subscription_key in varchar2,
x_subscription_key_start_date in varchar2,
x_subscription_name in varchar2,
x_description in varchar2,
x_owner in varchar2,
x_availability_code in varchar2,
x_logon_display_frequency in varchar2,
x_parent_subscription_key in varchar2,
x_parent_key_start_date in varchar2,
x_application_id in varchar2,
x_enabled_flag in varchar2,
x_approval_key in varchar2,
x_approval_key_start_date in varchar2,
x_auth_delegation_role_id in varchar2,
x_effective_end_date in varchar2,
x_last_update_date in varchar2,
x_custom_mode   in varchar2

)

is

         v_db_owner_id number;

      BEGIN
        if ( x_upload_mode = 'NLS' ) then
          JTF_UM_SUBSCRIPTIONS_PKG.TRANSLATE_ROW(
  	    X_SUBSCRIPTION_ID  =>  JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
            X_SUBSCRIPTION_NAME => x_subscription_name,
            X_DESCRIPTION   =>     x_description,
            X_OWNER         =>     x_owner,
            x_last_update_date => x_last_update_date ,
            x_custom_mode => x_custom_mode);
        else
       --     select LAST_UPDATED_BY
       --     into v_db_owner_id
       --     from JTF_UM_SUBSCRIPTIONS_B
       --     where SUBSCRIPTION_ID = JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS'));

       --   if (v_db_owner_id = 1) then
	   JTF_UM_SUBSCRIPTIONS_PKG.LOAD_ROW(
  		X_SUBSCRIPTION_KEY    =>  x_subscription_key,
  		X_SUBSCRIPTION_ID     =>  JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
  		X_AVAILABILITY_CODE => x_availability_code,
  		X_LOGON_DISPLAY_FREQUENCY => to_number(x_logon_display_frequency),
  		X_PARENT_SUBSCRIPTION_ID => JTF_UMUTIL.subscription_lookup_with_check(x_parent_subscription_key, to_date(x_parent_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
  		X_APPLICATION_ID => to_number(x_application_id),
  		X_ENABLED_FLAG	=>             x_enabled_flag,
  		X_APPROVAL_ID		=> JTF_UMUTIL.approval_lookup_with_check(x_approval_key, to_date(x_approval_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
                X_AUTH_DELEGATION_ROLE_ID => to_number(x_auth_delegation_role_id),
  		X_EFFECTIVE_START_DATE => to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS'),
  		X_EFFECTIVE_END_DATE => to_date(x_effective_end_date,'YYYY/MM/DD HH24:MI:SS'),
  		X_SUBSCRIPTION_NAME => x_subscription_name,
  		X_DESCRIPTION => x_description,
  		X_OWNER => x_owner,
		X_LAST_UPDATE_DATE => x_last_update_date,
                X_CUSTOM_MODE => x_custom_mode
		);
        --  end if;
	end if;

      exception
        when no_data_found then
          JTF_UM_SUBSCRIPTIONS_PKG.LOAD_ROW(
                X_SUBSCRIPTION_KEY    =>  x_subscription_key,
                X_SUBSCRIPTION_ID     =>  JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
                X_AVAILABILITY_CODE => x_availability_code,
                X_LOGON_DISPLAY_FREQUENCY => to_number(x_logon_display_frequency),
                X_PARENT_SUBSCRIPTION_ID => JTF_UMUTIL.subscription_lookup_with_check(x_parent_subscription_key, to_date(x_parent_key_start_date,'YYYY/MM/DD H
H24:MI:SS')),
                X_APPLICATION_ID => to_number(x_application_id),
                X_ENABLED_FLAG  => x_enabled_flag,
                X_APPROVAL_ID           => JTF_UMUTIL.approval_lookup_with_check(x_approval_key, to_date(x_approval_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
                X_AUTH_DELEGATION_ROLE_ID => to_number(x_auth_delegation_role_id),
                X_EFFECTIVE_START_DATE => to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS'),
                X_EFFECTIVE_END_DATE => to_date(x_effective_end_date,'YYYY/MM/DD HH24:MI:SS'),
                X_SUBSCRIPTION_NAME => x_subscription_name,
                X_DESCRIPTION => x_description,
                X_OWNER => x_owner,
		X_LAST_UPDATE_DATE => x_last_update_date ,
                X_CUSTOM_MODE => x_custom_mode
		);

    end  LOAD_SEED_SUBSCRIPTIONS;



procedure LOAD_SEED_SUBSCRIPTION_TMPL(
x_upload_mode in varchar2,
x_subscription_key in varchar2,
x_subscription_key_start_date in varchar2,
x_template_key in varchar2,
x_template_key_start_date in varchar2,
x_effective_start_date in varchar2,
x_effective_end_date in varchar2,
x_owner in varchar2,
x_last_update_date in varchar2,
x_custom_mode   in varchar2
)

is

v_db_owner_id number;
         v_active_record_count number;

     begin
        if ( x_upload_mode = 'NLS' ) then
          null;
          return;
        else
           select count(*)
           into v_active_record_count
           from JTF_UM_SUBSCRIPTION_TMPL
           where SUBSCRIPTION_ID = JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS'))
           and EFFECTIVE_END_DATE is NULL
           and LAST_UPDATED_BY <> 1;

           if( v_active_record_count > 0 ) then
             return;
           end if;

           select LAST_UPDATED_BY
           into v_db_owner_id
           from JTF_UM_SUBSCRIPTION_TMPL
           where SUBSCRIPTION_ID = JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS'))
           and TEMPLATE_ID = JTF_UMUTIL.template_lookup(x_template_key, to_date(x_template_key_start_date,'YYYY/MM/DD HH24:MI:SS'))
           and EFFECTIVE_START_DATE = to_date(x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS');

          if ( v_active_record_count = 0 ) then
	  JTF_UM_SUBSCRIPTIONS_PKG.LOAD_SUBSCRIPTION_TMPL_ROW(
                X_SUBSCRIPTION_ID     =>  JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
		X_TEMPLATE_ID => JTF_UMUTIL.template_lookup(x_template_key, to_date(x_template_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
		X_EFFECTIVE_START_DATE => to_date(x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS'),
		X_EFFECTIVE_END_DATE => to_date(x_effective_end_date, 'YYYY/MM/DD HH24:MI:SS'),
		X_OWNER => x_owner,
		X_LAST_UPDATE_DATE => x_last_update_date ,
                X_CUSTOM_MODE => x_custom_mode
		);
          end if;
        end if;

      exception
        when no_data_found then

          update JTF_UM_SUBSCRIPTION_TMPL
          set EFFECTIVE_END_DATE = SYSDATE
          where EFFECTIVE_END_DATE is NULL
          and SUBSCRIPTION_ID = JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS'));

	  JTF_UM_SUBSCRIPTIONS_PKG.LOAD_SUBSCRIPTION_TMPL_ROW(
                X_SUBSCRIPTION_ID     =>  JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
		X_TEMPLATE_ID => JTF_UMUTIL.template_lookup(x_template_key, to_date(x_template_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
		X_EFFECTIVE_START_DATE => to_date(x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS'),
		X_EFFECTIVE_END_DATE => to_date(x_effective_end_date, 'YYYY/MM/DD HH24:MI:SS'),
		X_OWNER => x_owner,
		X_LAST_UPDATE_DATE => x_last_update_date ,
                X_CUSTOM_MODE => x_custom_mode
		);

    end LOAD_SEED_SUBSCRIPTION_TMPL;




procedure LOAD_SEED_SUBSCR_USERTYPE(
x_upload_mode in varchar2,
x_subscription_key in varchar2,
x_subscription_key_start_date in varchar2,
x_usertype_key in varchar2,
x_usertype_key_start_date in varchar2,
x_effective_start_date in varchar2,
x_subscription_flag in varchar2,
x_subscription_display_order in varchar2,
x_effective_end_date in varchar2,
x_owner in varchar2,
x_last_update_date in varchar2,
x_custom_mode   in varchar2
)

is

     v_db_owner_id number;

     BEGIN
        if ( x_upload_mode = 'NLS' ) then
	  null;
     ELSE
      --   select LAST_UPDATED_BY
      --   into v_db_owner_id
      --   from JTF_UM_USERTYPE_SUBSCRIP
      --   where SUBSCRIPTION_ID = JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS'))
      --   and USERTYPE_ID = JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS'))
      --   and EFFECTIVE_START_DATE = to_date(x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS');

      --  if (v_db_owner_id = 1) then
	JTF_UM_USERTYPES_PKG.LOAD_USERTYPES_SUB_ROW(
                X_USERTYPE_ID        => JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
                X_SUBSCRIPTION_ID     =>  JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
		X_SUBSCRIPTION_FLAG	=> x_subscription_flag,
		X_DISPLAY_ORDER => to_number(x_subscription_display_order),
		X_EFFECTIVE_START_DATE => to_date(x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS'),
		X_EFFECTIVE_END_DATE => to_date(x_effective_end_date, 'YYYY/MM/DD HH24:MI:SS'),
		X_OWNER => x_owner,
		X_LAST_UPDATE_DATE => x_last_update_date ,
                X_CUSTOM_MODE => x_custom_mode
		);
        --  end if;
        end if;

      exception
        when no_data_found then
        JTF_UM_USERTYPES_PKG.LOAD_USERTYPES_SUB_ROW(
                X_USERTYPE_ID        => JTF_UMUTIL.usertype_lookup(x_usertype_key, to_date(x_usertype_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
                X_SUBSCRIPTION_ID     =>  JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
                X_SUBSCRIPTION_FLAG     => x_subscription_flag,
                X_DISPLAY_ORDER => to_number(x_subscription_display_order),
                X_EFFECTIVE_START_DATE => to_date(x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS'),
                X_EFFECTIVE_END_DATE => to_date(x_effective_end_date, 'YYYY/MM/DD HH24:MI:SS'),
                X_OWNER => x_owner,
		X_LAST_UPDATE_DATE => x_last_update_date ,
                X_CUSTOM_MODE => x_custom_mode
		);

    end LOAD_SEED_SUBSCR_USERTYPE;


procedure LOAD_SEED_SUBSCRIPTION_ROLE(
x_upload_mode in varchar2,
x_subscription_key in varchar2,
x_subscription_key_start_date in varchar2,
x_principal_name in varchar2,
x_effective_start_date in varchar2,
x_effective_end_date in varchar2,
x_owner in varchar2,
x_last_update_date in varchar2,
x_custom_mode   in varchar2)

is

         v_db_owner_id number;

     BEGIN
        IF (x_upload_mode = 'NLS') THEN
          NULL;
        else

--	 select LAST_UPDATED_BY
--         into v_db_owner_id
--         from JTF_UM_SUBSCRIPTION_ROLE
--         where SUBSCRIPTION_ID = JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS'))
--         and PRINCIPAL_NAME =               x_principal_name
--         and EFFECTIVE_START_DATE = to_date(x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS');

--        if (v_db_owner_id = 1) then
	  JTF_UM_ROLE_RESP_PKG.LOAD_subscription_role_ROW(
            x_subscription_id      =>  JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
            x_principal_name	   => x_principal_name ,
	    x_effective_start_date => TO_DATE ( x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS' ) ,
	    x_effective_end_date   => TO_DATE ( x_effective_end_date, 'YYYY/MM/DD HH24:MI:SS' ) ,
	    x_owner 		   => x_owner,
	    X_LAST_UPDATE_DATE => x_last_update_date ,
            X_CUSTOM_MODE => x_custom_mode
          );
  --        end if;
        end if;

      exception
        when no_data_found then
        JTF_UM_ROLE_RESP_PKG.LOAD_subscription_role_ROW(
            x_subscription_id      =>  JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
            x_principal_name       => x_principal_name ,
            x_effective_start_date => TO_DATE ( x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS' ) ,
            x_effective_end_date   => TO_DATE ( x_effective_end_date, 'YYYY/MM/DD HH24:MI:SS' ) ,
            x_owner                => x_owner,
	    X_LAST_UPDATE_DATE => x_last_update_date ,
            X_CUSTOM_MODE => x_custom_mode
        );
    END LOAD_SEED_SUBSCRIPTION_ROLE;



procedure LOAD_SEED_SUBSCRIPTION_RESP(
x_upload_mode in varchar2,
x_subscription_key in varchar2,
x_subscription_key_start_date in varchar2,
x_responsibility_key in varchar2,
x_effective_start_date in varchar2,
x_effective_end_date in varchar2,
x_owner in varchar2,
x_application_id in varchar2,
x_last_update_date in varchar2,
x_custom_mode   in varchar2
)

is

v_db_owner_id number;
         v_active_record_count number;

     begin
        if ( x_upload_mode = 'NLS' ) then
          null;
          return;
        else
           select count(*)
           into v_active_record_count
           from JTF_UM_SUBSCRIPTION_RESP
           where SUBSCRIPTION_ID = JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS'))
           and EFFECTIVE_END_DATE is NULL
           and LAST_UPDATED_BY <> 1;

           if( v_active_record_count > 0 ) then
             return;
           end if;

 --          select LAST_UPDATED_BY
 --          into v_db_owner_id
 --          from JTF_UM_SUBSCRIPTION_RESP
 --          where SUBSCRIPTION_ID = JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS'))
 --          and RESPONSIBILITY_KEY = x_responsibility_key
 --          and EFFECTIVE_START_DATE = to_date(x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS');

          if ( v_active_record_count = 0 ) then
	    JTF_UM_ROLE_RESP_PKG.LOAD_subscription_resp_ROW(
               x_subscription_id      =>  JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
               x_responsibility_key   => x_responsibility_key ,
	       x_effective_start_date => TO_DATE ( x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS' ) ,
	       x_effective_end_date   => TO_DATE ( x_effective_end_date, 'YYYY/MM/DD HH24:MI:SS' ) ,
	       x_owner 		   => x_owner ,
               x_application_id       => TO_NUMBER( x_application_id ),
	       X_LAST_UPDATE_DATE => x_last_update_date ,
               X_CUSTOM_MODE => x_custom_mode
           );
          end if;
        end if;

      exception
        when no_data_found then

          update JTF_UM_SUBSCRIPTION_RESP
          set EFFECTIVE_END_DATE = SYSDATE
          where EFFECTIVE_END_DATE is NULL
          and SUBSCRIPTION_ID = JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS'));

            JTF_UM_ROLE_RESP_PKG.LOAD_subscription_resp_ROW(
               x_subscription_id      =>  JTF_UMUTIL.subscription_lookup(x_subscription_key, to_date(x_subscription_key_start_date,'YYYY/MM/DD HH24:MI:SS')),
               x_responsibility_key   => x_responsibility_key ,
               x_effective_start_date => TO_DATE ( x_effective_start_date, 'YYYY/MM/DD HH24:MI:SS' ) ,
               x_effective_end_date   => TO_DATE ( x_effective_end_date, 'YYYY/MM/DD HH24:MI:SS' ) ,
               x_owner             => x_owner ,
               x_application_id       => TO_NUMBER( x_application_id ),
	       X_LAST_UPDATE_DATE => x_last_update_date ,
               X_CUSTOM_MODE => x_custom_mode
           );

    end LOAD_SEED_SUBSCRIPTION_RESP;

end jumf_lct_pkg;

/
