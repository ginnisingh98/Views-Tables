--------------------------------------------------------
--  DDL for Package Body HR_EMPL_VERF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EMPL_VERF_UTIL" AS
/* $Header: hrevutil.pkb 120.6 2006/02/28 05:15:35 srpurani noship $*/
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------

   g_package varchar2(50) := 'hr_empl_verf_util';

   FUNCTION CHECK_TICKET_STRING
     ( p_ticket IN VARCHAR2,
       p_operation OUT NOCOPY VARCHAR2,
       p_argument OUT NOCOPY VARCHAR2)
   RETURN NUMBER IS
     isTicketMatched boolean default FALSE;
   BEGIN

        isTicketMatched :=  fnd_http_ticket.check_ticket_string(p_ticket  => p_ticket,
                               p_operation => p_operation,
                               p_argument => p_argument);
        IF(   isTicketMatched  = TRUE) THEN
            return 1;
        ELSIF ( isTicketMatched = FALSE ) THEN
            return 0;
        ELSIF ( isTicketMatched is null ) THEN
            return 2;
        END IF;

   EXCEPTION
       WHEN OTHERS THEN
       raise;
   END CHECK_TICKET_STRING;


   FUNCTION CHECK_ONETIME_TICKET_STRING
     ( p_ticket IN VARCHAR2,
       p_operation OUT NOCOPY VARCHAR2,
       p_argument OUT NOCOPY VARCHAR2)
   RETURN NUMBER IS
     isTicketMatched boolean default FALSE;
   BEGIN

        isTicketMatched :=  fnd_http_ticket.CHECK_ONETIME_TICKET_STRING(p_ticket  => p_ticket,
                               p_operation => p_operation,
                               p_argument => p_argument);
        IF(   isTicketMatched ) then
            return 1;
        ELSE
            return 0;
        END IF;

   EXCEPTION
       WHEN OTHERS THEN
       raise;
   END CHECK_ONETIME_TICKET_STRING;

/*

  PROCEDURE send_mail(to_address IN VARCHAR2, from_address IN VARCHAR2,
                mail_content VARCHAR2)
  IS
     conn utl_smtp.connection;
  BEGIN
    conn := utl_smtp.open_connection('rgmamersmtp.oraclecorp.com');
    utl_smtp.helo(conn, 'oracle.com');
    utl_smtp.mail(conn, from_address);
    utl_smtp.rcpt(conn, to_address);
    utl_smtp.open_data(conn);
    utl_smtp.write_data(conn, 'From' || ': ' || '"Dev" <Srinivas.Vittal@oracle.com>' || utl_tcp.CRLF);
    utl_smtp.write_data(conn, 'To' || ': ' || '"Recipient" <Srinivas.Vittal@oracle.com>' || utl_tcp.CRLF);
    utl_smtp.write_data(conn, 'Subject' || ': ' || 'Employment Verification'  || utl_tcp.CRLF);
    utl_smtp.write_data(conn, utl_tcp.CRLF || mail_content);
    utl_smtp.close_data(conn);
    utl_smtp.quit(conn);
  EXCEPTION
  WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
    BEGIN
      utl_smtp.quit(conn);
    EXCEPTION
      WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
        NULL; -- When the SMTP server is down or unavailable, we don't have
              -- a connection to the server. The quit call will raise an
              -- exception that we can ignore.
    END;
    raise_application_error(-20000,
      'Failed to send mail due to the following error: ' || sqlerrm);
  END;

*/

  PROCEDURE send_notification
  (to_address IN VARCHAR2,
   from_address IN VARCHAR2,
   reply_to_address in VARCHAR2,
   access_url VARCHAR2,
   access_days NUMBER,
   emp_name VARCHAR2,
   access_limit NUMBER,
   personal_key VARCHAR2,
   comments VARCHAR2)
  IS
    lv_role_name wf_roles.name%TYPE;
    lv_role_display_name wf_roles.display_name%TYPE;
    ln_notification_id number;

    Role_Info_Tbl wf_directory.wf_local_roles_tbl_type;
    login_user_info_tbl wf_directory.wf_local_roles_tbl_type;
    login_user_name fnd_user.user_name%TYPE;
    lv_subject FND_NEW_MESSAGES.message_text%TYPE;
    l_proc varchar2(50) := 'send_notification';


  BEGIN
      hr_utility.set_location(' Entering: ' || g_package || '.' || l_proc,5);

      lv_role_name := null;
      --Fix 4778117
      begin
        select to_char(WF_ADHOC_ROLE_S.NEXTVAL)
        into lv_role_name
        from SYS.DUAL;
      exception
        when others then
          raise;
      end;

      lv_role_name := '~WF_ADHOC-' || lv_role_name;
      lv_role_display_name := to_address;
      wf_directory.GetRoleInfo2(lv_role_name, Role_Info_Tbl);

      login_user_name := fnd_global.user_name();
      wf_directory.GetRoleInfo2(login_user_name, login_user_info_tbl);

      begin
        wf_directory.createadhocrole(role_name => lv_role_name,
                                   role_display_name => lv_role_display_name,
                                   language => login_user_info_tbl(1).language,
                                   territory =>  login_user_info_tbl(1).territory,
                                   role_description => 'Adhoc Role for Employment Verification',
                                   notification_preference => 'MAILHTML',
                                   role_users => null,
                                   email_address => to_address,
                                   fax => null,
                                   status => 'ACTIVE',
                                   expiration_date => trunc(sysdate)+access_days,--4778117
                                   parent_orig_system => null,
                                   parent_orig_system_id => null,
                                   owner_tag => 'PER');
     exception when others then
	hr_utility.set_location(' Exception when calling wf_directory.createadhocrole ' || SQLERRM, 55);
	hr_utility.set_location(' Leaving ' || l_proc, 60);
     end;



        ln_notification_id := wf_notification.send(role => lv_role_name,
                             msg_type => 'HRVERF' ,
                             msg_name => 'HR_ACCESS_KEY_MSG',
                             callback => null,
                             context => null,
                             send_comment => null,
                             priority => 50) ;

        fnd_message.set_name('PER','HR_EV_NTF_SUBJECT');
        fnd_message.set_token('EMPL_NAME',emp_name,false);
        lv_subject := fnd_message.get;


        wf_notification.setattrtext(ln_notification_id,'EXT_URL',access_url);
        wf_notification.setattrtext(ln_notification_id,'EXP_DAYS',access_days);
        wf_notification.setattrtext(ln_notification_id,'ACCESS_TIMES',access_limit);
        wf_notification.setattrtext(ln_notification_id,'#FROM_ROLE',login_user_name);
        wf_notification.setattrtext(ln_notification_id,'EMP_NAME',lv_subject);
        wf_notification.setattrtext(ln_notification_id,'REPLY_TO','mailto:' ||reply_to_address);
        wf_notification.setattrtext(ln_notification_id,'#WFM_FROM', emp_name);
        wf_notification.setattrtext(ln_notification_id,'#WFM_REPLYTO',reply_to_address);
        wf_notification.setattrtext(ln_notification_id,'COMMENTS',comments);



  EXCEPTION WHEN OTHERS THEN
    rollback;
    raise;
  END;


  PROCEDURE GET_EMPLOYEE_SALARY
    (p_Assignment_id   In Per_All_Assignments_F.ASSIGNMENT_ID%TYPE,
     p_Effective_Date  In Date,
     p_salary         OUT nocopy number,
     p_frequency      OUT nocopy varchar2,
     p_annual_salary  OUT nocopy number,
     p_pay_basis      OUT nocopy varchar2,
     p_reason_cd      OUT nocopy varchar2,
     p_currency       OUT nocopy varchar2,
     p_status         OUT nocopy number,
     p_currency_name  OUT nocopy varchar2,
     p_pay_basis_frequency OUT nocopy varchar2
  ) IS
    CURSOR get_currency_name(p_code in varchar2) IS
    select name from fnd_currencies_tl
    where currency_code = p_code
    and language = userenv('lang');

    CURSOR get_frequency_name(p_lookup_code in varchar2) IS
    select meaning from hr_lookups hl
    where hl.lookup_type = 'PAY_BASIS'
    and lookup_code = p_lookup_code
    and hl.enabled_flag = 'Y'
    and sysdate between
    nvl(hl.start_date_active, sysdate)
    and nvl(hl.end_date_active, sysdate);

  BEGIN
    pqh_employee_salary.get_employee_salary
        (p_assignment_id => p_assignment_id,
         p_effective_date  => p_effective_date,
         p_salary => p_salary,
         p_frequency => p_frequency,
         p_annual_salary => p_annual_salary,
         p_pay_basis => p_pay_basis,
         p_reason_cd => p_reason_cd,
         p_currency => p_currency,
         p_status => p_status,
	 p_pay_basis_frequency => p_pay_basis_frequency);

    if( p_currency is not null) then
        open get_currency_name(p_currency);
        fetch get_currency_name into p_currency_name;
        close get_currency_name;
    end if;

    if(p_pay_basis_frequency is not null) then
        open get_frequency_name(p_pay_basis_frequency);
        fetch get_frequency_name into p_pay_basis_frequency;
        close get_frequency_name;
    end if;



  END;

  FUNCTION UPDATE_TICKET_STRING(P_TICKET    in varchar2,
                                P_OPERATION in varchar2,
                                P_ARGUMENT  in varchar2)
  RETURN NUMBER IS
    return_value boolean default false;
  BEGIN
    return_value := FND_HTTP_TICKET.UPDATE_TICKET_STRING(P_TICKET, P_OPERATION, P_ARGUMENT);

    if(return_value = TRUE) then
        return 0;
    else
        return 1;
    end if;
  EXCEPTION WHEN OTHERS THEN
    rollback;
    raise;
  END;

   -- Enter further code below as specified in the Package spec.

END HR_EMPL_VERF_UTIL;

/
