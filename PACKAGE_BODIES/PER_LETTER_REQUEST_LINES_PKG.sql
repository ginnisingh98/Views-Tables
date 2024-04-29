--------------------------------------------------------
--  DDL for Package Body PER_LETTER_REQUEST_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_LETTER_REQUEST_LINES_PKG" as
/* $Header: peltl01t.pkb 115.6 2003/02/21 07:13:34 vramanai ship $ */
--
PROCEDURE check_request_line_unique(X_letter_request_line_id in number,
				    X_assignment_id          in number,
				    X_letter_request_id      in number,
				    X_business_group_id      in number,
                                    X_ota_event_id           in number,
                                    X_ota_booking_id         in number,
                                    X_ota_booking_status_type_id in number)
is
--
cursor csr_line is select null
		      from per_letter_request_lines r
		      where (X_letter_request_line_id is null
		      or X_letter_request_line_id <> r.letter_request_line_id)
		      and r.assignment_id = X_assignment_id
		      and r.letter_request_id = X_letter_request_id
		      and r.business_group_id + 0 = X_business_group_id;
--
cursor csr_ota_line is
select null
from per_letter_request_lines r
where (X_letter_request_line_id is null
    or X_letter_request_line_id <> r.letter_request_line_id)
and r.letter_request_id = X_letter_request_id
and ((X_ota_event_id = ota_event_id and
      ota_booking_id is null and
      x_ota_booking_id is null)
   or (X_ota_booking_id = ota_booking_id
       and X_ota_booking_status_type_id = ota_booking_status_type_id));

--
g_dummy_number number;
v_not_unique   boolean := FALSE;
--
-- Check the request line is unique
--
begin
  --
hr_utility.trace('CHK PROCEDURE');

  if X_assignment_id is not null then
     open csr_line;
     fetch csr_line into g_dummy_number;
     v_not_unique := csr_line%found;
     close csr_line;
     --
     if v_not_unique then
        hr_utility.set_message(801,'PER_7352_OUT_LETTER_PERSON');
        hr_utility.raise_error;
     end if;
  --
  end if;

  if X_ota_event_id is not null or
     X_ota_booking_id is not null then
     open csr_ota_line;
     fetch csr_ota_line into g_dummy_number;
     v_not_unique := csr_ota_line%found;
     close csr_ota_line;
     --
     if v_not_unique then
        fnd_message.set_name('PER','PER_7352_OUT_LETTER_PERSON');
        fnd_message.raise_error;
     end if;
  end if;
  --
end check_request_line_unique;
--
PROCEDURE get_ota_details
          (p_letter_request_line_id in number
          ,p_event_title            in out NOCOPY  varchar2
          ,p_delegate_full_name     in out NOCOPY  varchar2
          ,p_course_start_date      in out NOCOPY  date
          ,p_ota_booking_id         in number
          ,p_ota_event_id           in number) is
--
l_event_title varchar2(80);
l_course_start_date date;
l_delegate_full_name varchar2(240);
source_cursor integer;
l_return integer;
--
begin
  if p_ota_event_id is not null then
     source_cursor := dbms_sql.open_cursor;
     dbms_sql.parse(source_cursor,
      'select title,course_start_date
       from  ota_events
       where event_id = '||to_char(p_ota_event_id),
       dbms_sql.v7);
     dbms_sql.define_column(source_cursor,1,l_event_title,80);
     dbms_sql.define_column(source_cursor,2,l_course_start_date);
     l_return := dbms_sql.execute(source_cursor);
     if dbms_sql.fetch_rows(source_cursor) >0 then
        dbms_sql.column_value(source_cursor,1,l_event_title);
        dbms_sql.column_value(source_cursor,2,l_course_start_date);
     end if;
     --
     p_event_title := l_event_title;
     p_course_start_date := l_course_start_date;
     --
     dbms_sql.close_cursor(source_cursor);
  end if;
  --
  if p_ota_booking_id is not null then
     source_cursor := dbms_sql.open_cursor;
     dbms_sql.parse(source_cursor,
      'select event_title
       ,      course_start_date
       ,      delegate_full_name
       from   ota_delegate_bookings_v
       where booking_id = '||to_char(p_ota_booking_id),
       dbms_sql.v7);
     dbms_sql.define_column(source_cursor,1,l_event_title,80);
     dbms_sql.define_column(source_cursor,2,l_course_start_date);
     dbms_sql.define_column(source_cursor,3,l_delegate_full_name,240);
     l_return := dbms_sql.execute(source_cursor);
     if dbms_sql.fetch_rows(source_cursor) >0 then
        dbms_sql.column_value(source_cursor,1,l_event_title);
        dbms_sql.column_value(source_cursor,2,l_course_start_date);
        dbms_sql.column_value(source_cursor,3,l_delegate_full_name);
     end if;
     --
     p_event_title := l_event_title;
     p_course_start_date := l_course_start_date;
     p_delegate_full_name := l_delegate_full_name;
     --
     dbms_sql.close_cursor(source_cursor);
  end if;
end;
--
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Letter_Request_Line_Id       IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Letter_Request_Id                   NUMBER,
                     X_Person_Id                           NUMBER,
                     X_Assignment_Id                       NUMBER,
                     X_Assignment_Status_Type_Id           NUMBER,
                     X_Date_From                           DATE,
                     X_OTA_BOOKING_STATUS_TYPE_ID          number,
                     X_OTA_BOOKING_ID                      number,
                     X_OTA_EVENT_ID                        number,
                     X_CONTRACT_ID                  IN     NUMBER DEFAULT NULL
 ) IS
   CURSOR C IS SELECT rowid FROM per_letter_request_lines
             WHERE  letter_request_line_id = X_Letter_Request_Line_Id;
   --
   CURSOR C2 IS SELECT per_letter_request_lines_s.nextval FROM sys.dual;
   --
BEGIN
   --
hr_utility.trace('Insert_Row');
   if (X_Letter_Request_Line_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Letter_Request_Line_Id;
     CLOSE C2;
   end if;
   --
   INSERT INTO per_letter_request_lines(
          letter_request_line_id,
          business_group_id,
          letter_request_id,
          person_id,
          assignment_id,
          assignment_status_type_id,
          date_from,
          OTA_BOOKING_STATUS_TYPE_ID,
          OTA_BOOKING_ID,
          OTA_EVENT_ID,
          CONTRACT_ID
         ) VALUES (
          X_Letter_Request_Line_Id,
          X_Business_Group_Id,
          X_Letter_Request_Id,
          X_Person_Id,
          X_Assignment_Id,
          X_Assignment_Status_Type_Id,
          X_Date_From,
          X_OTA_BOOKING_STATUS_TYPE_ID,
          X_OTA_BOOKING_ID,
          X_OTA_EVENT_ID,
          X_CONTRACT_ID
  );
  --
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','Insert_Row');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
  end if;
  CLOSE C;
END Insert_Row;
--
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Letter_Request_Line_Id                NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Letter_Request_Id                     NUMBER,
                   X_Person_Id                             NUMBER,
                   X_Assignment_Id                         NUMBER,
                   X_Assignment_Status_Type_Id             NUMBER,
                   X_Date_From                             DATE,
                   X_OTA_BOOKING_STATUS_TYPE_ID           number,
                   X_OTA_BOOKING_ID                       number,
                   X_OTA_EVENT_ID                         number
) IS
  CURSOR C IS
      SELECT *
      FROM   per_letter_request_lines
      WHERE  rowid = X_Rowid
      FOR UPDATE of letter_request_line_id   NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  --
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','Lock_Row');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.letter_request_line_id = X_Letter_Request_Line_Id)
           OR (    (Recinfo.letter_request_line_id IS NULL)
               AND (X_Letter_Request_Line_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.letter_request_id = X_Letter_Request_Id)
           OR (    (Recinfo.letter_request_id IS NULL)
               AND (X_Letter_Request_Id IS NULL)))
      AND (   (Recinfo.person_id = X_Person_Id)
           OR (    (Recinfo.person_id IS NULL)
               AND (X_Person_Id IS NULL)))
      AND (   (Recinfo.assignment_id = X_Assignment_Id)
           OR (    (Recinfo.assignment_id IS NULL)
               AND (X_Assignment_Id IS NULL)))
      AND (   (Recinfo.assignment_status_type_id = X_Assignment_Status_Type_Id)
           OR (    (Recinfo.assignment_status_type_id IS NULL)
               AND (X_Assignment_Status_Type_Id IS NULL)))
      AND (   (Recinfo.date_from = X_Date_From)
           OR (    (Recinfo.date_from IS NULL)
               AND (X_Date_From IS NULL)))
      AND (   (Recinfo.ota_booking_id =
                                  X_ota_booking_id)
           OR (    (Recinfo.ota_booking_id IS NULL)
               AND (X_ota_booking_id IS NULL)))
      AND (   (Recinfo.ota_event_id =
                                  X_ota_event_id)
           OR (    (Recinfo.ota_event_id IS NULL)
               AND (X_ota_event_id IS NULL)))
      AND (   (Recinfo.ota_booking_status_type_id =
                                  X_ota_booking_status_type_id)
           OR (    (Recinfo.ota_booking_status_type_id IS NULL)
               AND (X_ota_booking_status_type_id IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM per_letter_request_lines
  WHERE  rowid = X_Rowid;
  --
  if (SQL%NOTFOUND) then
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','Delete_Row');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
  end if;
END Delete_Row;
--
--
END PER_LETTER_REQUEST_LINES_PKG;

/
