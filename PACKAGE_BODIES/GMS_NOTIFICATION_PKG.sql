--------------------------------------------------------
--  DDL for Package Body GMS_NOTIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_NOTIFICATION_PKG" AS
--$Header: gmsawnob.pls 115.13 2003/03/06 05:34:41 gnema ship $

PROCEDURE Insert_Row(X_Rowid          IN OUT NOCOPY      VARCHAR2,
                       X_Award_Id       IN         NUMBER,
                       X_Event_type     IN         VARCHAR2,
                       X_User_id        IN         NUMBER) IS

     CURSOR C IS SELECT rowid FROM GMS_NOTIFICATIONS
            WHERE  Award_id = X_Award_id and
                   Event_type = X_Event_type and
                   User_id = X_User_id;

BEGIN
      INSERT into GMS_NOTIFICATIONS(award_id,
                               event_type,
                               user_id)
      values (X_award_id,
              X_event_type,
              X_user_id);

       Open c;
        Fetch c into X_rowid;
        if (c%NOTFOUND) then
           close c;
           RAISE NO_DATA_FOUND;
        END if;
        CLOSE c;
END Insert_row;


PROCEDURE   Lock_Row(X_Rowid            IN        VARCHAR2,  --bug 2813856, removed OUT NOCOPY
                       X_Award_Id       IN         NUMBER,
                       X_Event_type     IN         VARCHAR2,
                       X_User_id        IN         NUMBER) IS

   cursor c is select * from  gms_notifications
                 where rowid = X_rowid
                 for update of Award_id, event_type, user_id  nowait;
   Recinfo c%rowtype;
BEGIN
     open c;
     fetch c into Recinfo;
     if (c%NOTFOUND)  then
        CLOSE c;
     FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
     APP_EXCEPTION.Raise_Exception;
    END if;
    CLOSE c;
    if (    recinfo.award_id = X_award_id
        and recinfo.event_type = X_event_type
        and recinfo.user_id = X_user_id ) then
     return;
    else
       FND_MESSAGE.set_name('FND','FORM_RECORD_CHANGED');
       APP_EXCEPTION.Raise_Exception;
   END if;

-- Added Exception for Bug:2662848
EXCEPTION
when OTHERS then
RAISE;
END Lock_row;


PROCEDURE Delete_Row(X_Rowid             VARCHAR2) is
BEGIN
  delete gms_notifications
  where rowid = X_Rowid;
END Delete_row;


PROCEDURE Crt_default_person_events( x_err_code in out NOCOPY NUMBER,
				     x_err_stage in out NOCOPY VARCHAR2,
				     p_award_id INTEGER,
                                     p_person_id INTEGER) IS
   cursor report_event_cursor is
      select distinct to_char(report_template_id)
      from gms_default_reports_v
      where award_id = p_award_id;

  cursor fnd_user_cursor is
     select user_id
     from fnd_user
     where employee_id = p_person_id;

  l_row_id rowid;
  l_user_id integer;
  l_report_template_id varchar2(30);
  user_not_yet_created exception;

BEGIN

  x_err_code := 0;

  open fnd_user_cursor;
  fetch fnd_user_cursor into l_user_id;

  if fnd_user_cursor%NOTFOUND then
    close fnd_user_cursor;
    raise user_not_yet_created;
  END if;

  close fnd_user_cursor;

-- Bug 1969587 : Added for Installment closeout notification

  BEGIN

     INSERT into GMS_NOTIFICATIONS(award_id,
                               event_type,
                               user_id)
      values (p_award_id,
              'INSTALLMENT_CLOSEOUT',
              l_user_id);

     EXCEPTION
       when DUP_VAL_ON_INDEX then
        null;
  END;

  BEGIN

     INSERT into GMS_NOTIFICATIONS(award_id,
                               event_type,
                               user_id)
      values (p_award_id,
              'BUDGET_BASELINE',
              l_user_id);

     EXCEPTION
       when DUP_VAL_ON_INDEX then
        null;
  END;

 BEGIN

     INSERT into GMS_NOTIFICATIONS(award_id,
                               event_type,
                               user_id)
      values (p_award_id,
              'INSTALLMENT_ACTIVE',
              l_user_id);

     EXCEPTION
       when DUP_VAL_ON_INDEX then
        null;
  END;



  open report_event_cursor;

  LOOP
    fetch report_event_cursor into l_report_template_id;
    exit when report_event_cursor%notfound;
    BEGIN

     INSERT into GMS_NOTIFICATIONS(award_id,
                               event_type,
                               user_id)
      values (p_award_id,
              'REPORT_'||l_report_template_id,
              l_user_id);

     EXCEPTION
       when DUP_VAL_ON_INDEX then
        null;
     END;

  END LOOP;
  close report_event_cursor;

EXCEPTION
 when user_not_yet_created then
	x_err_code := 2;
	x_err_stage := 'GMS_FND_USER_NOT_CREATED';

--     fnd_message.set_name('GMS','GMS_FND_USER_NOT_CREATED');
--     fnd_message.set_token('PERSON_ID',to_char(p_person_id));
--     APP_EXCEPTION.raise_exception;

  when others then
    if report_event_cursor%isopen then
       close report_Event_cursor;
    end if;
    if fnd_user_cursor%isopen  then
       close fnd_user_cursor;
    end if;

	gms_error_pkg.gms_message(x_err_name => 'GMS_UNEXPECTED_ERROR',
				x_token_name1 => 'SQLCODE',
				x_token_val1 => sqlcode,
				x_token_name2 => 'SQLERRM',
				x_token_val2 => sqlerrm,
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

--     fnd_message.set_name('GMS','GMS_UNEXPECTED_ERROR');
--     fnd_message.set_token('PROGRAM_NAME','GMS_NOTIFICATIONS_PKG.CRT_DEFAULT_PERSON_EVENTS');
--     fnd_message.set_token('OERRNO',to_char(sqlcode));
--     fnd_message.set_token('OERRM',sqlerrm);
--     APP_EXCEPTION.raise_exception;
END crt_default_person_events;


PROCEDURE crt_default_report_events(x_err_code in out NOCOPY NUMBER,
				    x_err_stage in out NOCOPY VARCHAR2,
				    p_award_id integer,
                                    p_report_template_id integer) is


  l_report_template_id varchar2(20);
  l_person_id integer;
  l_user_id integer;

  cursor fnd_user_cursor is
     select user_id
     from fnd_user
     where employee_id = l_person_id;


  cursor award_persons  is
  select person_id
  from gms_personnel
  where award_id = p_award_id and
  trunc(sysdate) between start_date_active and nvl(end_date_active,to_date('01/01/4000','DD/MM/YYYY'));

   user_not_yet_created exception;

BEGIN

  x_err_code := 0;

  l_report_template_id := to_char(p_report_template_id);

  open award_persons;
  LOOP
     fetch award_persons into l_person_id;
     exit when award_persons%NOTFOUND;

     open fnd_user_cursor;
     fetch fnd_user_cursor into l_user_id;
     if fnd_user_cursor%NOTFOUND then
       close fnd_user_cursor;
       raise user_not_yet_created;
     end if;
     close fnd_user_cursor;
     BEGIN
       INSERT into GMS_NOTIFICATIONS(award_id,
                               event_type,
                               user_id)
        values (p_award_id,
              'REPORT_'||l_report_template_id,
              l_user_id);

     EXCEPTION
       when DUP_VAL_ON_INDEX then
        null;
     END;
  END LOOP;
EXCEPTION
  when user_not_yet_created then
  x_err_code := 2;
  x_err_stage := 'GMS_FND_USER_NOT_CREATED';

--     fnd_message.set_name('GMS','GMS_FND_USER_NOT_CREATED');
--     fnd_message.set_token('PERSON_ID',to_char(l_person_id));
--     APP_EXCEPTION.raise_exception;
  when others then
    if award_persons%isopen then
       close award_persons;
    end if;
    if fnd_user_cursor%isopen  then
       close fnd_user_cursor;
    end if;

	gms_error_pkg.gms_message(x_err_name => 'GMS_UNEXPECTED_ERROR',
				x_token_name1 => 'SQLCODE',
				x_token_val1 => sqlcode,
				x_token_name2 => 'SQLERRM',
				x_token_val2 => sqlerrm,
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

--     fnd_message.set_name('GMS','GMS_UNEXPECTED_ERROR');
--     fnd_message.set_token('PROGRAM_NAME','GMS_NOTIFICATIONS_PKG.CRT_DEFAULT_REPORT_EVENTS');
--     fnd_message.set_token('OERRNO',to_char(sqlcode));
--     fnd_message.set_token('OERRM',sqlerrm);
--     app_exception.raise_exception;
END crt_default_report_events;


PROCEDURE Del_default_person_events(x_err_code in out NOCOPY NUMBER,
				    x_err_stage in out NOCOPY VARCHAR2,
				    p_award_id INTEGER,
                                    p_person_id INTEGER) is

  cursor fnd_user_cursor is
     select user_id
     from fnd_user
     where employee_id = p_person_id;

  l_user_id integer;
  user_not_yet_created exception;
BEGIN

  x_err_code := 0;

  open fnd_user_cursor;
  fetch fnd_user_cursor into l_user_id;
  if fnd_user_cursor%NOTFOUND then
     close fnd_user_cursor;
     raise user_not_yet_created ;
  end if;
  close fnd_user_cursor;
  delete gms_notifications
  where user_id = l_user_id and
       award_id = p_award_id and

-- Bug 1969587 : Installment closeout Notification
--               added in order not to delete the person if he still exists in gms_personnel with additional
--               award role.

      not exists ( select 1
                     from gms_personnel
                    where award_id = p_award_id and
                          person_id = p_person_id
                 );




EXCEPTION
 when user_not_yet_created then
     x_err_code := 2;
     x_err_stage := 'GMS_FND_USER_NOT_CREATED';

--     fnd_message.set_name('GMS','GMS_FND_USER_NOT_CREATED');
--     fnd_message.set_token('PERSON_ID',to_char(l_user_id));
--    APP_EXCEPTION.raise_exception;
  when others then
	gms_error_pkg.gms_message(x_err_name => 'GMS_UNEXPECTED_ERROR',
				x_token_name1 => 'SQLCODE',
				x_token_val1 => sqlcode,
				x_token_name2 => 'SQLERRM',
				x_token_val2 => sqlerrm,
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

--     fnd_message.set_name('GMS','GMS_UNEXPECTED_ERROR');
--     fnd_message.set_token('PROGRAM_NAME','GMS_NOTIFICATIONS_PKG.DEL_DEFAULT_PERSON_EVENTS');
--     fnd_message.set_token('OERRNO',to_char(sqlcode));
--     fnd_message.set_token('OERRM',sqlerrm);
--     app_exception.raise_exception;
END;


PROCEDURE Del_default_report_events(x_err_code in out NOCOPY NUMBER,
				    x_err_stage in out NOCOPY VARCHAR2,
				    p_award_id INTEGER,
                                    p_report_template_id INTEGER) is
BEGIN

  x_err_code := 0;

  delete gms_notifications
  where award_id = p_award_id and
      event_type = 'REPORT_'||to_char(p_report_template_id);

EXCEPTION
  when others then
	gms_error_pkg.gms_message(x_err_name => 'GMS_UNEXPECTED_ERROR',
				x_token_name1 => 'SQLCODE',
				x_token_val1 => sqlcode,
				x_token_name2 => 'SQLERRM',
				x_token_val2 => sqlerrm,
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

--     fnd_message.set_name('GMS','GMS_UNEXPECTED_ERROR');
--     fnd_message.set_token('PROGRAM_NAME','GMS_NOTIFICATIONS_PKG.DEL_DEFAULT_REPORT_EVENTS');
--     fnd_message.set_token('OERRNO',to_char(sqlcode));
--     fnd_message.set_token('OERRM',sqlerrm);
--     app_exception.raise_exception;
END;


END GMS_NOTIFICATION_PKG;

/
