--------------------------------------------------------
--  DDL for Package Body PER_LETTER_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_LETTER_REQUESTS_PKG" as
/* $Header: peltr01t.pkb 115.3 2003/01/22 12:24:59 asahay ship $ */
--
PROCEDURE check_request_unique(X_letter_request_id  in number,
			       X_business_group_id  in number,
                               X_vacancy_id     	in number,
			       X_event_id     		in number,
			       X_letter_type_id     in number,
			       X_date_from          in date,
			       X_request_status     in varchar2)
--
is

cursor csr_request is select null
		       from   per_letter_requests
		       where  (X_letter_request_id is null
		       or     (letter_request_id <> X_letter_request_id
		       and    X_letter_request_id is not null))
		       and    business_group_id + 0   = X_business_group_id
		       and    letter_type_id      = X_letter_type_id
                       and    nvl(vacancy_id,-1)  = nvl(X_Vacancy_ID,-1)
                       and    date_from           = X_date_from
		       and    request_status      = 'PENDING';
--

v_not_unique    boolean := FALSE;
g_dummy_number  number;
--
-- Check there are no requests with the same letter pending for this date
--
begin
--

   open csr_request;
   fetch csr_request into g_dummy_number;
   v_not_unique := csr_request%found;
   close csr_request;

--
   if v_not_unique then
      hr_utility.set_message (801,'PER_7350_OUT_LETTER_EXISTS');
      hr_utility.raise_error;
   end if;
--
end check_request_unique;
--
PROCEDURE check_request_lines (X_letter_request_id  in     NUMBER)
--
   is cursor c is select null
		  from per_letter_request_lines
		  where  letter_request_id = X_letter_request_id;
--
   g_dummy_number number;
   request_lines_not_exist boolean := FALSE;
--
-- Check that if the request status is changed to 'Requested' then there
-- are request lines for this letter request
--
begin
  open c;
  fetch c into g_dummy_number;
  request_lines_not_exist := c%notfound;
  close c;
  --
  if request_lines_not_exist then
        hr_utility.set_message (801,'PER_7351_OUT_LETTER_NO_LINES');
	hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('PER_LETTER_REQUESTS_PKG.check_request_lines', 1);
  --
end check_request_lines;
--
PROCEDURE confirm_delete_lines (X_letter_request_id   in     NUMBER,
				X_business_group_id   in     NUMBER,
				X_request_lines_exist in out nocopy BOOLEAN) is
--
   cursor c is select null
		  from per_letter_request_lines
		  where  letter_request_id = X_letter_request_id;
--
   g_dummy_number number;
--
-- If request lines exist then ensure the user wishes to delete these
-- as well as the request letter itself
--
begin
  open c;
  fetch c into g_dummy_number;
  --
  if c%found then
     X_request_lines_exist := TRUE;
  end if;
  close c;
  --
  hr_utility.set_location('PER_LETTER_REQUESTS_PKG.confirm_delete_lines', 1);
  --
end confirm_delete_lines;
--
PROCEDURE Insert_Row(X_Rowid                        IN OUT nocopy VARCHAR2,
                     X_Letter_Request_Id            IN OUT nocopy NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Letter_Type_Id                      NUMBER,
                     X_Date_From                           DATE,
                     X_Request_Status                      VARCHAR2,
                     X_Auto_Or_Manual                      VARCHAR2,
		     X_VACANCY_ID	                   NUMBER,
                     X_EVENT_ID                            NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM per_letter_requests
             WHERE  letter_request_id = X_Letter_Request_Id;
   --
   CURSOR C2 IS SELECT per_letter_requests_s.nextval FROM sys.dual;
BEGIN
   if (X_Letter_Request_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Letter_Request_Id;
     CLOSE C2;
   end if;
   --
   INSERT INTO per_letter_requests(
          letter_request_id,
          business_group_id,
          letter_type_id,
          date_from,
          request_status,
          auto_or_manual,
	  vacancy_id,
          event_id
         ) VALUES (
          X_Letter_Request_Id,
          X_Business_Group_Id,
          X_Letter_Type_Id,
          X_Date_From,
          X_Request_Status,
          X_Auto_Or_Manual,
          X_Vacancy_ID,
	  X_Event_ID
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
                   X_Letter_Request_Id                     NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Letter_Type_Id                        NUMBER,
                   X_Date_From                             DATE,
                   X_Request_Status                        VARCHAR2,
                   X_Auto_Or_Manual                        VARCHAR2,
                   X_VACANCY_ID		                   NUMBER,
		   X_EVENT_ID		                   NUMBER
) IS
  --
  CURSOR C IS
      SELECT *
      FROM   per_letter_requests
      WHERE  rowid = X_Rowid
      FOR UPDATE of letter_request_id            NOWAIT;
  Recinfo C%ROWTYPE;
  --
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
  --
  Recinfo.request_status := rtrim(Recinfo.request_status);
  Recinfo.auto_or_manual := rtrim(Recinfo.auto_or_manual);
  if (
          (   (Recinfo.letter_request_id = X_Letter_Request_Id)
           OR (    (Recinfo.letter_request_id IS NULL)
               AND (X_Letter_Request_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.letter_type_id = X_Letter_Type_Id)
           OR (    (Recinfo.letter_type_id IS NULL)
               AND (X_Letter_Type_Id IS NULL)))
      AND (   (Recinfo.date_from = X_Date_From)
           OR (    (Recinfo.date_from IS NULL)
               AND (X_Date_From IS NULL)))
      AND (   (Recinfo.request_status = X_Request_Status)
           OR (    (Recinfo.request_status IS NULL)
               AND (X_Request_Status IS NULL)))
      AND (   (Recinfo.auto_or_manual = X_Auto_Or_Manual)
           OR (    (Recinfo.auto_or_manual IS NULL)
               AND (X_Auto_Or_Manual IS NULL)))
          ) then
    return;
    --
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Letter_Request_Id                   NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Letter_Type_Id                      NUMBER,
                     X_Date_From                           DATE,
                     X_Request_Status                      VARCHAR2,
                     X_Auto_Or_Manual                      VARCHAR2,
                     X_VACANCY_ID	                   NUMBER,
		     X_EVENT_ID	 	                   NUMBER
) IS
BEGIN
  --
  UPDATE per_letter_requests
  SET
    letter_request_id                         =    X_Letter_Request_Id,
    business_group_id                         =    X_Business_Group_Id,
    letter_type_id                            =    X_Letter_Type_Id,
    date_from                                 =    X_Date_From,
    request_status                            =    X_Request_Status,
    auto_or_manual                            =    X_Auto_Or_Manual,
    vacancy_id 	                              =    X_Vacancy_ID,
    event_id 	                              =    X_Event_ID
  WHERE rowid = X_rowid;
  --
  if (SQL%NOTFOUND) then
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','Update_Row');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
  end if;
  --
END Update_Row;
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2,
		     X_Letter_Request_Id NUMBER) is
--
cursor csr_lines is select null
                    from per_letter_request_lines
		    where letter_request_id = X_letter_request_id;
--
g_dummy_number number;
v_lines_exist boolean := FALSE;
--
BEGIN
  --
  open csr_lines;
  fetch csr_lines into g_dummy_number;
  v_lines_exist := csr_lines%found;
  close csr_lines;
  --
  if v_lines_exist then
    --
    DELETE FROM per_letter_request_lines
    WHERE letter_Request_Id = X_letter_request_id;
    --
    if (SQL%NOTFOUND) then
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','Delete_Row');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
    end if;
    --
  end if;
  --
  DELETE FROM per_letter_requests
  WHERE  rowid = X_Rowid;
  --
  if (SQL%NOTFOUND) then
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','Delete_Row');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
  end if;
  --
END Delete_Row;
--
PROCEDURE concurrent_program_call(p_application       varchar2,
				  p_program           varchar2,
				  p_argument1         varchar2,
				  p_argument2         varchar2,
				  p_request_id in out nocopy number) is
--
-- Submit the concurrent program request and return the request id
--
begin
  --
  p_request_id := FND_REQUEST.SUBMIT_REQUEST
		    (p_application,
	             p_program,
		     NULL,
		     NULL,
		     NULL,
                     p_argument1,
	             p_argument2);
  --
end concurrent_program_call;
--
END PER_LETTER_REQUESTS_PKG;

/
