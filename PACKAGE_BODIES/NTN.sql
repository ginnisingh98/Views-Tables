--------------------------------------------------------
--  DDL for Package Body NTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."NTN" as
/* $Header: PONSENDB.pls 115.1 2002/11/26 19:50:40 sbull ship $ */



procedure Send_Notification(
   p_employee_id   number,
   p_message_name  varchar2,
   object_id       number,
   priority        number default 3,
   deletable       varchar2 default 'Y',
   from_id         number default NULL,
   p_application_id  number default 0,
   doc_type        varchar2 default NULL,
   doc_number      varchar2 default NULL,
   amount          number default NULL,
   currency        varchar2 default NULL,
   note            varchar2 default NULL,
   start_effective_date date default NULL,
   end_effective_date date default NULL,
   doc_creation_date date default NULL,
   date1  date default NULL,
   date2  date default NULL,
   date3  date default NULL,
   attribute_array char_array,
   array_lb        number,
   array_ub        number,
   return_code out NOCOPY number,
   notification_id out NOCOPY number)
is
   stmt             varchar2(20000);
   ix               integer;
   new_id           integer;
   num_attrs        integer;
   num_attrs_passed integer;
   c		    integer;
   rows_processed   integer;
   status           varchar2(30):='NEW';
   user_id  Number  := FND_PROFILE.Value('USER_ID');
   login_id Number  := FND_PROFILE.Value('LOGIN_ID');
   xxx              rowid;
   off_line         varchar2(1);
   on_line          integer;

   x_app_short_name varchar2(50);          /* Bug458110. gtummala. 3/14/97.*/
   xxx_msg	    varchar2(2000):=NULL;  /* Added these 3 variables */
   x_progress       VARCHAR2(3) := '';     /*                         */

 begin
   notification_id:=NULL;
   return_code:=1;
dbms_output.put_line(p_message_name);
   -- Check for valid message name

   /* Bug458110. gtummala. 3/14/97.
    * Previously the code was:
    * select rowid into xxx
    *  from fnd_new_messages where application_id = p_application_id
    *                    and message_name=p_message_name;
    *
    * This causes too many rows to be returned in a translated install
    * since we are not joining on language_code. Thus in any translated
    * db notifications were not working.
    * We should be selecting from the fnd message dictionary api's.
    * So using the fnd_message.get_string api. It returns the translated
    * message or null if the message can't be found. The null is what
    * we need to check for.
    */

    x_progress:='010';
    select application_short_name
      into x_app_short_name
      from fnd_application
     where application_id = p_application_id;

    dbms_output.put_line('Application short name found');

    xxx_msg := fnd_message.get_string(x_app_short_name, p_message_name);
    x_progress:='020';

    dbms_output.put_line('xxx_msg =' || xxx_msg);

    if (xxx_msg is NULL) then
      RAISE NO_DATA_FOUND;
    end if;

    x_progress:='030';

dbms_output.put_line(to_char(p_employee_id));


   -- Check for valid employee id
   select rowid into xxx
        from hr_employees where employee_id=p_employee_id;

   -- Check for off-line users

   /* DEBUG. gtummala. 9/16/97.
    * person_type isn't supported in the sep10 install.
    * Just to make this package compile I'm going to take out
    * this whole sql stmt and hardcode on_line. We're going
    * to drop this package anyway in a week.
    */

   /* select count(1) into on_line
        from fnd_user where employee_id = p_employee_id
        and person_type = 'E'
        and sysdate < NVL(end_date, sysdate +1);
    */

    on_line :=1;


   if (on_line = 0) then
       off_line := 'Y';
   else
       off_line := 'N';
   end if;

dbms_output.put_line(off_line);

   stmt:= 'insert into fnd_notifications'
          || '(notification_id, employee_id, message_name, priority, status, object_id, deletable, from_id, application_id, doc_type, ' ||
	     'doc_number, amount, currency, note, start_effective_date, end_effective_date, doc_creation_date, date1, date2, date3, off_line,
'
          || 'attribute1, attribute2, attribute3, attribute4, attribute5,'
          || 'attribute6, attribute7, attribute8, attribute9, attribute10,'
          || 'attribute11, attribute12, attribute13, attribute14, attribute15,'
          || 'attribute16, attribute17, attribute18, attribute19, attribute20,'
          || 'attribute21, attribute22, attribute23, attribute24, attribute25,'
          || 'attribute26, attribute27, attribute28, attribute29, attribute30,'
          || 'attribute31, attribute32, '
          || 'last_update_date, last_updated_by, last_update_login, '
          || 'creation_date,  created_by)'
          || ' values '
          || '(fnd_notifications_s.nextval, :employee_id, :message_name, :priority, :status, :object_id, :deletable, :from_id, :application_id, ' ||
	     ':doc_type, :doc_number, :amount, :currency, :note, :start_effective_date, :end_effective_date, :doc_creation_date, :date1, :date2, :date3, :off_line, '
          || ':a1, :a2, :a3, :a4, :a5, :a6, :a7, :a8, :a9, :a10,'
          || ':a11, :a12, :a13, :a14, :a15, :a16,'
          || ':a17, :a18, :a19, :a20, :a21, :a22,'
          || ':a23, :a24, :a25, :a26, :a27, :a28,'
          || ':a29, :a30, :a31, :a32,'
          || 'sysdate, :user_id, :login_id, sysdate, :user_id)';

--   stmt:= stmt||' '||new_id||',';
--   stmt:= stmt||' '||employee_id||',';
--   stmt:= stmt||''''||p_message_name||''',';
   c := sys.dbms_sql.open_cursor;
   sys.dbms_sql.parse(c, stmt, dbms_sql.native);
   sys.dbms_sql.bind_variable(c,'employee_id', p_employee_id);
   sys.dbms_sql.bind_variable(c,'message_name', p_message_name);
   sys.dbms_sql.bind_variable(c,'object_id', object_id);
   sys.dbms_sql.bind_variable(c,'deletable', deletable);
   sys.dbms_sql.bind_variable(c,'from_id', from_id);
   sys.dbms_sql.bind_variable(c,'application_id', p_application_id);
   sys.dbms_sql.bind_variable(c,'doc_type', doc_type);
   sys.dbms_sql.bind_variable(c,'doc_number', doc_number);
   sys.dbms_sql.bind_variable(c,'amount', amount);
   sys.dbms_sql.bind_variable(c,'currency', currency);
   sys.dbms_sql.bind_variable(c,'note', note);
   sys.dbms_sql.bind_variable(c,'start_effective_date', start_effective_date);
   sys.dbms_sql.bind_variable(c,'end_effective_date', end_effective_date);
   sys.dbms_sql.bind_variable(c,'doc_creation_date', doc_creation_date);
   sys.dbms_sql.bind_variable(c,'date1', date1);
   sys.dbms_sql.bind_variable(c,'date2', date2);
   sys.dbms_sql.bind_variable(c,'date3', date3);
   sys.dbms_sql.bind_variable(c,'off_line', off_line);
   sys.dbms_sql.bind_variable(c,'priority', priority);
   sys.dbms_sql.bind_variable(c,'status', status);
   sys.dbms_sql.bind_variable(c,'user_id', user_id);
   sys.dbms_sql.bind_variable(c,'login_id', login_id);

dbms_output.put_line('after message insert');
   num_attrs := 32;
   for ix in  1..num_attrs loop
      num_attrs_passed := array_ub - array_lb +1;
      if (ix <= num_attrs_passed) then
         sys.dbms_sql.bind_variable(c,'a' || (ix), attribute_array(array_lb +ix -1));
      else
         sys.dbms_sql.bind_variable(c,'a' || (ix), '');
      end if ;

   end loop;
dbms_output.put_line('after attribute array');
--   sys.dbms_output.put_line(stmt);

   rows_processed := sys.dbms_sql.execute(c);
   sys.dbms_sql.close_cursor(c);
   select fnd_notifications_s.currval into notification_id from dual;
   return_code:=0;
dbms_output.put_line('after send notification');


/* Bug458110. gtummala. 3/14/97.
 * Added this exception handler
 */

EXCEPTION
    WHEN OTHERS THEN
	dbms_output.put_line('In Exception');
	PO_MESSAGE_S.SQL_ERROR('Send_Notification', x_progress, sqlcode);
	RAISE;
end Send_Notification;


procedure Delete_Notification(
   p_notification_id number,
   return_code out NOCOPY number)
is
  candelete varchar2(25) := '';
begin
  select 'record_exists'
         into candelete
         from fnd_notifications
         where notification_id = p_notification_id;
  if candelete = 'record_exists' then
         delete from fnd_notifications
         where notification_id = p_notification_id;
         return_code:=0;
  else
         return_code:=1;
  end if;
end;

procedure Delete_Notif_By_ID_Type(
   p_object_id number,
   p_doc_type  varchar2)
is
   /* DEBUG. gtummala. 9/16/97.
    * fnd_notifications_view isn't in the sep10 install.
    * Just to make this package compile I'm going to take
    * this whole procedure and replace with a null.
    * We're going to drop this package
    * next week anyway.
    */


   /*
     cursor c1 is     select notification_id
                    from fnd_notifications_view
                    where object_id=p_object_id
                      and p_doc_type = doc_type;

    */

  return_code number;
begin
   /*
   for dntn in c1 loop
      Delete_Notification(dntn.notification_id, return_code);
   end loop;
   */

   NULL;

end;

procedure Forward_Notification(
   p_notification_id number,
   p_new_recip       number,
   p_note	     varchar2 default NULL)
is
   xxx rowid;
   user_id  Number  := FND_PROFILE.Value('USER_ID');
   login_id Number  := FND_PROFILE.Value('LOGIN_ID');

begin
   -- Check for valid employee id
   select rowid into xxx
        from hr_employees where employee_id=p_new_recip;

   update fnd_notifications
   set from_id = employee_id,
       employee_id = p_new_recip,
       note = p_note,
       last_update_date = sysdate,
       last_updated_by = user_id,
       last_update_login = login_id
   where
      notification_id = p_notification_id;

end;

/*
procedure  Get_Notification_Attribute(
   p_notification_id number,
   attribute_name varchar2,
   attribute_value out NOCOPY varchar2)
is
stmt varchar2(2000);
c    integer;
rows_processed integer;
attrval varchar2(100);
begin
  attribute_value:= NULL;
  stmt:= 'select '
         || attribute_name
         || ' from jliang_nv '
         || ' where notification_id = :p_notification_id';


   c := sys.dbms_sql.open_cursor;
   sys.dbms_sql.parse(c, stmt, dbms_sql.native);
   sys.dbms_sql.bind_variable(c,'p_notification_id', p_notification_id);
   sys.dbms_sql.define_column(c, 1, attrval, 100);


   rows_processed := sys.dbms_sql.execute(c);

   if dbms_sql.fetch_rows(c) > 0 then
            dbms_sql.column_value(c,1,attrval);
   end if;

   sys.dbms_sql.close_cursor(c);
   attribute_value := attrval;
end;
*/


/*===========================================================================

  PROCEDURE NAME:	notif_current

===========================================================================*/

FUNCTION notif_current (x_notification_id NUMBER) RETURN BOOLEAN IS
    x_progress	  VARCHAR2(3) := '';
    x_data_exists NUMBER := 0;
BEGIN

    IF x_notification_id IS NOT NULL THEN

        x_progress := '010';

        SELECT count(1)
        INTO   x_data_exists
        FROM   fnd_notifications
        WHERE  notification_id = x_notification_id;

    ELSE
	x_progress := '015';
	RETURN false;
    END IF;

    x_progress := '020';
    IF x_data_exists = 1 THEN
	return TRUE;
    ELSE
	return FALSE;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
	dbms_output.put_line('In Exception');
        raise_application_error(-20000, sqlerrm);
END;




procedure test_in(i number)
is
attr_a char_array;
new_id number;
return_code number;
t   varchar2(30);
begin
attr_a(0):='at_val1';
attr_a(1):='at_val2';
attr_a(2):=NULL;
for ix in 1..10 loop
Send_Notification(p_employee_id=>5009,
           p_message_name=>'FNDFMREG- no matching forms',
           object_id=>ix,
           doc_type=>'req',
           attribute_array=>attr_a,
           array_lb=>0,
           array_ub=>2,
           notification_id=>new_id,
           return_code=>return_code);
end loop;


Delete_Notification(
           p_notification_id => new_id,
           return_code=>return_code);


Delete_Notif_By_ID_Type(
           p_doc_type => 'req',
           p_object_id => 8);

Forward_Notification(
           p_notification_id => 5,
           p_new_recip => 5010,
	   p_note => 'test');

--Get_Notification_Attribute(2, 'attr2', t);
end;

end ntn;

/
