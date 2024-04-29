--------------------------------------------------------
--  DDL for Package Body PQH_PROCESS_EMP_REVIEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PROCESS_EMP_REVIEW" AS
/* $Header: pqrewpkg.pkb 120.0.12010000.2 2009/10/07 12:20:49 rvagvala ship $ */
--
Cursor getUserName(p_person_id in Number) is
Select user_name
 From fnd_user
 Where employee_id = p_person_id;
--
FUNCTION  get_reviewers (
   p_transaction_step_id in varchar2
  ,p_show_deleted        in varchar2 default NULL ) RETURN ref_cursor IS

csr REF_CURSOR;
BEGIN

  OPEN csr FOR
  SELECT
      to_number(reviewer.event_id) event_id,
      to_number(reviewer.booking_id) Booking_id,
      pf.full_name employee_name,
      reviewer.employee_no employee_number,
      to_number(reviewer.person_id) person_id,
      rownum -1 row_index,
      reviewer.comments,
      reviewer.status,
      reviewer.business_group_id
  FROM (
      SELECT hr_transaction_api.get_varchar2_value (p_transaction_step_id , 'P_EVENT_ID'||x_row) event_id,
             hr_transaction_api.get_varchar2_value (p_transaction_step_id , 'P_BOOKING_ID'||x_row) booking_id,
             hr_transaction_api.get_varchar2_value (p_transaction_step_id , 'P_EMPLOYEE_NO'||x_row) employee_no,
             hr_transaction_api.get_varchar2_value (p_transaction_step_id , 'P_PERSON_ID'||x_row)   person_id,
             hr_transaction_api.get_varchar2_value (p_transaction_step_id , 'P_COMMENTS'||x_row)    comments,
             hr_transaction_api.get_varchar2_value (p_transaction_step_id , 'P_STATUS'||x_row)      status,
             hr_transaction_api.get_varchar2_value (p_transaction_step_id , 'P_BUSINESS_GROUP_ID'||x_row) business_group_id
      FROM  ( select substr(abc.name,14) x_row
              from  hr_api_transaction_values abc
              where abc.transaction_step_id = p_transaction_step_id
              and   abc.name like 'P_EMPLOYEE_NO%'
             ) x
    )     reviewer,
          per_all_people_f  pf
    WHERE pf.person_id = reviewer.person_id
    AND   (p_show_deleted = 'Y' or NVL(status,'E') <> 'D' )    -- Don't show deleted reviewers
    AND   SYSDATE BETWEEN pf.effective_start_date AND pf.effective_end_date;

    RETURN csr;
END;


FUNCTION  get_employee_review (
 p_transaction_step_id   in     varchar2 ) RETURN ref_cursor IS

csr REF_CURSOR;

BEGIN
  OPEN csr FOR
    SELECT
       to_number(review.event_id)                     event_id,
       review.Type,
       hl.meaning,
       fnd_date.canonical_to_date(review.date_start)  date_start,
       fnd_date.canonical_to_date(review.date_end)    date_end,
       review.time_start                              time_start,
       review.time_end                                time_end  ,
       to_number(review.location_id)                  location_id  ,
       loc.location_code                              location,
       review.comments      ,
       to_number(review.assignment_id)                assignment_id ,
       review.notify_flag,
       review.business_group_id
    FROM (
      SELECT
             max(event_id)          event_id,
             max(Type)              type,
             max(date_start)        date_start,
             max(date_end)          date_end,
             max(time_start)        time_start,
             max(time_end)          time_end,
             max(location_id)       location_id,
             max(comments)          comments,
             max(assignment_id)     assignment_id,
             max(notify_flag)       notify_flag,
             max(business_group_id) business_group_id
      FROM (
          SELECT
                 decode(a.name, 'P_EVENT_ID'          , a.varchar2_value ,null) Event_Id,
                 decode(a.name, 'P_TYPE'              , a.varchar2_value ,null) Type,
                 decode(a.name, 'P_DATE_START'        , a.varchar2_value ,null) Date_Start,
                 decode(a.name, 'P_DATE_END'          , a.varchar2_value ,null) Date_End,
                 decode(a.name, 'P_TIME_START'        , a.varchar2_value ,null) Time_Start,
                 decode(a.name, 'P_TIME_END'          , a.varchar2_value ,null) Time_End,
                 decode(a.name, 'P_LOCATION_ID'       , a.varchar2_value ,null) Location_Id,
                 decode(a.name, 'P_COMMENTS'          , a.varchar2_value ,null) Comments,
                 decode(a.name, 'P_ASSIGNMENT_ID'     , a.varchar2_value ,null) Assignment_Id,
                 decode(a.name, 'P_NOTIFY_FLAG'       , a.varchar2_value ,null) Notify_Flag,
                 decode(a.name, 'P_BUSINESS_GROUP_ID' , a.varchar2_value ,null) Business_Group_Id
           FROM hr_api_transaction_steps  s,
                hr_api_transaction_values a
           WHERE s.transaction_step_id = a.transaction_step_id
           AND   s.transaction_step_id = p_transaction_step_id
           AND   s.api_name            = 'PQH_PROCESS_EMP_REVIEW.PROCESS_API'
           )
          )  review ,
             hr_lookups   hl,
             hr_locations loc
      where  hl.lookup_type  = 'EMP_INTERVIEW_TYPE'
      AND    hl.lookup_code  = review.type
      AND    loc.location_id (+) = review.location_id
      AND    sysdate         <= nvl(loc.inactive_date, sysdate);

  RETURN csr;
END get_employee_review;


PROCEDURE rollback_transaction(
	itemType	IN VARCHAR2,
	itemKey		IN VARCHAR2,
        result	 OUT NOCOPY VARCHAR2) IS
BEGIN
--
   savepoint rollback_transaction;
   --
   wf_engine.setItemAttrNumber (
      itemType	=> itemType,
      itemKey   => itemKey,
      aname     => 'TRANSACTION_ID',
      avalue    => null );
   --
   --
   hr_transaction_ss.rollback_transaction (
      itemType	=> itemType,
      itemKey   => itemKey,
      actid     => 0,
      funmode   => 'RUN',
      result    => result );
   --
   --
   result := 'SUCCESS';
   --
   --
EXCEPTION
   --
   WHEN Others THEN
	rollback to rollback_transaction;
	result := 'FAILURE';
   --
END rollback_transaction;

PROCEDURE get_emp_review_details(
 x_transaction_step_id      IN  VARCHAR2,
 x_Event_Id                 OUT NOCOPY NUMBER,
 x_Assignment_Id            OUT NOCOPY NUMBER,
 x_Type                     OUT NOCOPY VARCHAR2,
 x_Date_Start               OUT NOCOPY VARCHAR2,
 x_Date_End                 OUT NOCOPY VARCHAR2,
 x_Time_Start               OUT NOCOPY VARCHAR2,
 x_Time_End                 OUT NOCOPY VARCHAR2,
 x_Location_Id              OUT NOCOPY NUMBER,
 x_Comments                 OUT NOCOPY VARCHAR2,
 x_Business_Group_Id        OUT NOCOPY NUMBER,
 x_notify_flag		    OUT NOCOPY VARCHAR2
 ) IS
----

 l_transaction_step_id  number;
 l_api_name             hr_api_transaction_steps.api_name%TYPE;


BEGIN

   hr_utility.set_location('Entering: PQH_PROCESS_EMP_REVIEW.get_emp_review_details',5);
   --
   l_transaction_step_id := to_number(x_transaction_step_id);
   --

   if l_transaction_step_id is null then
     return;
   end if;
   --

   x_event_Id    := hr_transaction_api.get_varchar2_value
                    (p_transaction_step_id => l_transaction_step_id,
                     p_name                => 'P_EVENT_ID');

   x_Assignment_Id  := hr_transaction_api.get_varchar2_value
                       (p_transaction_step_id => l_transaction_step_id,
                        p_name                => 'P_ASSIGNMENT_ID');

  x_Type 	   := hr_transaction_api.get_varchar2_value
                      (p_transaction_step_id => l_transaction_step_id,
                    p_name                => 'P_TYPE');




  x_Date_Start    :=  hr_transaction_api.get_varchar2_value
                              (p_transaction_step_id => l_transaction_step_id,
                               p_name                => 'P_DATE_START');

  x_Date_End :=hr_transaction_api.get_varchar2_value
                     (p_transaction_step_id => l_transaction_step_id,
                      p_name                => 'P_DATE_END');

  x_Time_Start :=hr_transaction_api.get_varchar2_value
                   (p_transaction_step_id => l_transaction_step_id,
                    p_name                => 'P_TIME_START');

  x_Time_End := hr_transaction_api.get_varchar2_value
                    (p_transaction_step_id => l_transaction_step_id,
                     p_name                => 'P_TIME_END');



  x_Location_id := hr_transaction_api.get_varchar2_value
                    (p_transaction_step_id => l_transaction_step_id,
                     p_name                => 'P_LOCATION_ID');

  x_Comments      := hr_transaction_api.get_varchar2_value
                   (p_transaction_step_id => l_transaction_step_id,
                    p_name                => 'P_COMMENTS');

 x_Business_Group_Id := hr_transaction_api.get_varchar2_value
                    (p_transaction_step_id => l_transaction_step_id,
                     p_name                => 'P_BUSINESS_GROUP_ID' );



  x_notify_flag      := hr_transaction_api.get_varchar2_value
                     (p_transaction_step_id => l_transaction_step_id,
                      p_name                => 'P_NOTIFY_FLAG');

/*  x_person_id	 := hr_transaction_api.get_number_value
                      (p_transaction_step_id => l_transaction_step_id,
                       p_name                => 'P_PERSON_ID' );

 */

hr_utility.set_location('Leaving: PQH_PROCESS_EMP_REVIEW.get_emp_review_details',10);
EXCEPTION
  WHEN hr_utility.hr_error THEN
    hr_utility.raise_error;
  WHEN OTHERS THEN
 x_Event_Id                 := null;
 x_Assignment_Id            := null;
 x_Type                     := null;
 x_Date_Start               := null;
 x_Date_End                 := null;
 x_Time_Start               := null;
 x_Time_End                 := null;
 x_Location_Id              := null;
 x_Comments                 := null;
 x_Business_Group_Id        := null;
 x_notify_flag		    := null;

        RAISE;  -- Raise error here relevant to the new tech stack.
END get_emp_review_details;

--
 PROCEDURE get_reviewers_count(
 x_transaction_step_id      IN    VARCHAR2,
 x_total_no_of_rows   OUT NOCOPY NUMBER,
 x_total_deleted_rows   OUT NOCOPY NUMBER) is

 cursor Rec_Count(p_step_id varchar2) is
 select count(*)
 from hr_api_transaction_values
 where transaction_step_id = p_step_id
 and name like 'P_EMPLOYEE_NO_';

 cursor Rec_Count_Deleted(p_step_id varchar2) is
 select count(*)
 from hr_api_transaction_values
 where transaction_step_id = p_step_id
 and name like 'P_EMPLOYEE_NO%D';


 BEGIN
--l_column_name := ''''||x_column_name||'%'||'''';

open Rec_Count(x_transaction_step_id);

fetch Rec_Count into x_total_no_of_rows;

close Rec_Count;



open Rec_Count_Deleted(x_transaction_step_id);

 Fetch Rec_Count_Deleted into x_total_deleted_rows;

close Rec_Count_Deleted;


Exception
	When Others Then
 x_total_no_of_rows   := null;
 x_total_deleted_rows   := null;
 --raise;	--for nocopy changes not puting raise here because the null below was already there.
 	null;
 End;




--

PROCEDURE get_emp_reviewers_details(
x_transaction_step_id      IN    VARCHAR2,
x_Event_Id                 OUT NOCOPY   NUMBER,
x_Booking_Id               OUT NOCOPY   NUMBER,
x_Employee_no              OUT NOCOPY   VARCHAR2,
x_Comments                 OUT NOCOPY   VARCHAR2,
x_Business_Group_Id        OUT NOCOPY   NUMBER ,
x_status                   OUT NOCOPY   VARCHAR2,
x_row_number		   IN    VARCHAR2 ,
x_person_id		   OUT NOCOPY   NUMBER
) IS


l_transaction_step_id  number;
l_api_name             hr_api_transaction_steps.api_name%TYPE;

BEGIN
  hr_utility.set_location('Entering: PQH_PROCESS_EMP_REVIEW.get_emp_reviewers_details',5);
  --
  l_transaction_step_id := to_number(x_transaction_step_id);
  --

  if l_transaction_step_id is null then
    return;
  end if;
  --


  x_Event_Id    := hr_transaction_api.get_varchar2_value
                      (p_transaction_step_id => l_transaction_step_id,
                       p_name                => 'P_EVENT_ID'||x_row_number);


  x_Booking_Id   := hr_transaction_api.get_varchar2_value
                      (p_transaction_step_id => l_transaction_step_id,
                     p_name                => 'P_BOOKING_ID'||x_row_number );


  x_Employee_no    := hr_transaction_api.get_varchar2_value
                       (p_transaction_step_id => l_transaction_step_id,
                     p_name                => 'P_EMPLOYEE_NO'||x_row_number );

  x_Comments      := hr_transaction_api.get_varchar2_value
                    (p_transaction_step_id => l_transaction_step_id,
                     p_name                => 'P_COMMENTS'||x_row_number );


 x_Business_Group_Id := hr_transaction_api.get_varchar2_value
                    (p_transaction_step_id => l_transaction_step_id,
                     p_name                => 'P_BUSINESS_GROUP_ID'||x_row_number );

  x_status      := hr_transaction_api.get_varchar2_value
                    (p_transaction_step_id => l_transaction_step_id,
                     p_name                => 'P_STATUS'||x_row_number );

  x_person_id	 := hr_transaction_api.get_varchar2_value
                    (p_transaction_step_id => l_transaction_step_id,
                     p_name                => 'P_PERSON_ID'||x_row_number );


hr_utility.set_location('x_person_id'||x_person_id,10);
hr_utility.set_location('Leaving: PQH_PROCESS_EMP_REVIEW.get_emp_reviewers_details',10);
EXCEPTION
  WHEN hr_utility.hr_error THEN
	hr_utility.raise_error;
  WHEN OTHERS THEN
x_Event_Id                 := null;
x_Booking_Id               := null;
x_Employee_no              := null;
x_Comments                 := null;
x_Business_Group_Id        := null;
x_status                   := null;
x_person_id		   := null;
      RAISE;  -- Raise error here relevant to the new tech stack.
END get_emp_reviewers_details;

--
--

PROCEDURE set_emp_review_details(
x_Login_person_id          IN 	NUMBER,
x_Person_id                IN 	NUMBER,
x_Item_type                IN 	VARCHAR2,
x_Item_key                 IN 	NUMBER,
x_Activity_id              IN 	NUMBER,
x_Event_Id                 IN   NUMBER,
x_Assignment_Id            IN   NUMBER,
x_Type                     IN   VARCHAR2,
x_Date_Start               IN   VARCHAR2,
x_Date_End                 IN   VARCHAR2,
x_Time_Start               IN   VARCHAR2,
x_Time_End                 IN   VARCHAR2,
x_Location_Id              IN   NUMBER,
x_Comments                 IN   VARCHAR2,
x_Business_Group_Id        IN   NUMBER,
x_notify_flag		   IN   VARCHAR2
) IS


l_transaction_id        number;
l_trans_tbl            	hr_transaction_ss.transaction_table;
l_count		        number;
l_transaction_step_id   number;
l_api_name   constant  	hr_api_transaction_steps.api_name%TYPE := 'PQH_PROCESS_EMP_REVIEW.PROCESS_API';
l_result               	varchar2(100);
l_trns_object_version_number    number;
l_review_proc_call      VARCHAR2(30);
l_effective_date      	DATE 	;

BEGIN
  hr_utility.set_location('Entering: PQH_PROCESS_EMP_REVIEW.set_emp_review_details',5);
  l_review_proc_call    := 'PqhEmployeeReview';
  l_effective_date      := SYSDATE;
    --


  hr_transaction_api.get_transaction_step_info
       (p_item_type             => x_item_type
       ,p_item_key              => x_item_key
       ,p_activity_id           => x_activity_id
       ,p_transaction_step_id   => l_transaction_step_id
       ,p_object_version_number => l_trns_object_version_number);



    l_count:=1;
    l_trans_tbl(l_count).param_name      := 'P_PERSON_ID';
    l_trans_tbl(l_count).param_value     :=  x_Person_id;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_REVIEW_ACTID';
    l_trans_tbl(l_count).param_value     :=  x_activity_id;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_REVIEW_PROC_CALL';
    l_trans_tbl(l_count).param_value     :=  l_review_proc_call;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_EVENT_ID';
    l_trans_tbl(l_count).param_value     :=  x_Event_Id ;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_ASSIGNMENT_ID';
    l_trans_tbl(l_count).param_value     :=  x_Assignment_Id;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_TYPE';
    l_trans_tbl(l_count).param_value     :=  x_Type;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_DATE_START';
    l_trans_tbl(l_count).param_value     :=  x_Date_Start;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_DATE_END';
    l_trans_tbl(l_count).param_value     :=  x_Date_End;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_TIME_START';
    l_trans_tbl(l_count).param_value     :=  x_Time_Start;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_TIME_END';
    l_trans_tbl(l_count).param_value     :=  x_Time_End;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_LOCATION_ID';
    l_trans_tbl(l_count).param_value     :=  x_Location_Id ;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

      hr_utility.set_location('Entering: Location_ID:'||x_Location_Id,5);
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_COMMENTS';
    l_trans_tbl(l_count).param_value     :=  x_Comments;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    hr_utility.set_location('Entering: Comments:'||x_Comments,5);
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_BUSINESS_GROUP_ID';
    l_trans_tbl(l_count).param_value     :=  x_Business_Group_Id;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

    --

        l_count:=l_count+1;
        l_trans_tbl(l_count).param_name      := 'P_NOTIFY_FLAG';
        l_trans_tbl(l_count).param_value     :=  x_notify_flag;
        l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --


    hr_utility.set_location('Entering: Business Group Id:'||x_Business_Group_Id,5);

    hr_transaction_ss.save_transaction_step
      (p_item_type             => x_item_type
      ,p_item_key              => x_item_key
      ,p_actid                 => x_activity_id
      ,p_login_person_id       => x_login_person_id
      ,p_transaction_step_id   => l_transaction_step_id
      ,p_api_name	       => l_api_name
      ,p_transaction_data      => l_trans_tbl  );
    hr_utility.set_location('Leaving: PQH_PROCESS_EMP_REVIEW.set_emp_review_details',10);

  commit;
  --- Saving the Transaction Step Id ,
  --- With the same step-id Reviewers details also being saved.

  --       x_trans_step_id	:= l_transaction_step_id;
  --
  --
  EXCEPTION
    WHEN hr_utility.hr_error THEN
  	hr_utility.raise_error;
    WHEN OTHERS THEN
        RAISE;  -- Raise error here relevant to the new tech stack.
  END set_emp_review_details;
--
--


PROCEDURE set_emp_reviewer_details(
x_login_person_id          IN 	NUMBER,
x_person_id                IN 	NUMBER,
x_item_type                IN 	VARCHAR2,
x_item_key                 IN 	NUMBER,
x_activity_id              IN 	NUMBER,
x_Event_Id                 IN   NUMBER,
x_Booking_Id               IN   NUMBER,
x_Employee_no              IN   VARCHAR2,
x_Comments                 IN   VARCHAR2,
x_Business_Group_Id        IN   NUMBER,
x_row_number		   IN   VARCHAR2,
x_status                   IN   VARCHAR2 ) IS

l_transaction_id        number;
l_trans_tbl            	hr_transaction_ss.transaction_table;
l_count		        number;
l_transaction_step_id   number;
l_api_name constant    	hr_api_transaction_steps.api_name%TYPE := 'PQH_PROCESS_EMP_REVIEW.PROCESS_API';
l_result               	varchar2(100);
l_trns_object_version_number    number;
l_review_proc_call      VARCHAR2(30);
l_effective_date      	DATE 	;

BEGIN
  hr_utility.set_location('Entering: PQH_PROCESS_EMP_REVIEW.set_emp_reviewer_details',5);
    --
  l_review_proc_call    := 'PqhEmployeeReview';
  l_effective_date      := SYSDATE;


  hr_transaction_api.get_transaction_step_info
         (p_item_type             => x_item_type
         ,p_item_key              => x_item_key
         ,p_activity_id           => x_activity_id
         ,p_transaction_step_id   => l_transaction_step_id
         ,p_object_version_number => l_trns_object_version_number);


    l_count:=1;
    l_trans_tbl(l_count).param_name      := 'P_PERSON_ID'||x_row_number ;
    l_trans_tbl(l_count).param_value     :=  x_Person_id;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_REVIEW_ACTID'||x_row_number ;
    l_trans_tbl(l_count).param_value     :=  x_activity_id;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_REVIEW_PROC_CALL'||x_row_number ;
    l_trans_tbl(l_count).param_value     :=  l_review_proc_call;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_EVENT_ID'||x_row_number ;
    l_trans_tbl(l_count).param_value     :=  x_Event_Id  ;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_BOOKING_ID'||x_row_number ;
    l_trans_tbl(l_count).param_value     :=  x_booking_id;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_EMPLOYEE_NO'||x_row_number ;
    l_trans_tbl(l_count).param_value     :=  x_Employee_no  ;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_COMMENTS'||x_row_number ;
    l_trans_tbl(l_count).param_value     :=  x_Comments;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_BUSINESS_GROUP_ID'||x_row_number ;
    l_trans_tbl(l_count).param_value     :=  x_Business_Group_Id;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    --
    l_count:=l_count+1;
    l_trans_tbl(l_count).param_name      := 'P_STATUS'||x_row_number;
    l_trans_tbl(l_count).param_value     :=  x_Status;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';



   hr_transaction_ss.save_transaction_step
         (p_item_type             => x_item_type
         ,p_item_key              => x_item_key
         ,p_actid                 => x_activity_id
         ,p_login_person_id       => x_login_person_id
         ,p_transaction_step_id   => l_transaction_step_id
         ,p_api_name	          => l_api_name
         ,p_transaction_data      => l_trans_tbl  );
    hr_utility.set_location('Leaving: PQH_PROCESS_EMP_REVIEW.set_emp_review_details',10);

  commit;

  EXCEPTION
    WHEN hr_utility.hr_error THEN
  	hr_utility.raise_error;
    WHEN OTHERS THEN
        RAISE;  -- Raise error here relevant to the new tech stack.
  END set_emp_reviewer_details;

  --
  --
-- Local procedure to set notification attributes
-- for notification send to the subject or the reviewers
procedure set_notification_attributes (
        p_ntf_id         IN NUMBER,
        p_employee_name  IN VARCHAR2,
        p_review_type    IN VARCHAR2,
        p_date_start     IN VARCHAR2,
        p_date_end       IN VARCHAR2,
        p_time_start     IN VARCHAR2,
        p_time_end       IN VARCHAR2,
        p_location       IN VARCHAR2,
        p_comments       IN VARCHAR2  ) IS
BEGIN
        if p_employee_name is not null then
            WF_NOTIFICATION.setAttrText(p_ntf_id,'PQH_EMP_NAME',p_employee_name);
        end if;

        if  p_review_type is not null  THEN
           WF_NOTIFICATION.setAttrText(p_ntf_id, 'PQH_REVIEW_TYPE', p_review_type);
        end if;

        if p_date_start is not null then
           WF_NOTIFICATION.setAttrText(p_ntf_id, 'PQH_START_DATE',
                         FND_DATE.date_to_displaydate(fnd_date.chardt_to_date(p_Date_Start)));
        end if;

        if p_date_end is not null then
           WF_NOTIFICATION.setAttrText(p_ntf_id, 'PQH_END_DATE',
                         FND_DATE.date_to_displaydate(fnd_date.chardt_to_date(p_Date_End)));
        end if;

        if p_Time_Start is not null then
           WF_NOTIFICATION.setAttrText(p_ntf_id, 'PQH_START_TIME', p_Time_Start);
        end if;

        if p_Time_End is not null then
           WF_NOTIFICATION.setAttrText(p_ntf_id, 'PQH_END_TIME', p_Time_End);
        end if;

        if p_location is not null then
           WF_NOTIFICATION.setAttrText(p_ntf_id, 'PQH_LOCATION', p_location);
        end if;

        if p_Comments is not null then
           WF_NOTIFICATION.setAttrText(p_ntf_id, 'PQH_COMMENTS', p_Comments);
        end if;

       WF_NOTIFICATION.setAttrText(p_ntf_id,'#FROM_ROLE',fnd_global.user_name);

--Bug 3014549: Adding Commit as it is needed to display attribute values, just set, for the notification
COMMIT;

END set_notification_attributes;


--
--
--

PROCEDURE process_api (
   p_validate		   IN   BOOLEAN DEFAULT FALSE,
   p_transaction_step_id   IN   NUMBER ) IS

l_Event_id              NUMBER;
l_booking_id            NUMBER;
l_Row_id		VARCHAR2(100);
--
--
l_Location_Id           NUMBER;
l_Assignment_Id         NUMBER;
l_Date_Start            VARCHAR2(12);
l_status                VARCHAR2(10);
l_Type                  VARCHAR2(200);
l_Comments              VARCHAR2(2000);
l_Date_End              VARCHAR2(12);
l_Time_End              VARCHAR2(200);
l_Time_Start            VARCHAR2(200);
l_Business_Group_Id     NUMBER;
l_notify_flag		VARCHAR2(10);
l_userName              VARCHAR2(100);
l_id 			Number;
l_person_Id		Number;
l_employee_name VARCHAR2(240);
l_employee_no   VARCHAR2(100);
l_ename         VARCHAR2(240);

cursor getrowid(c_event_id in number) is
select rowid from per_events
where event_id = c_event_id;

--
cursor c_empName is
select wf_engine.GetItemAttrText(item_type, item_key, 'CURRENT_PERSON_DISPLAY_NAME')
from hr_api_transaction_steps
where transaction_step_id = p_transaction_step_id;

reviewer_csr REF_CURSOR;
empReviewCsr REF_CURSOR;

l_temp number;
l_location_code varchar2(80);
l_typeMeaning varchar2(240);

   --
   -- SSHR Attachment feature changes : 8975847
   --
   l_attach_status varchar2(80);

BEGIN

hr_utility.set_location('Entering: PQH_PROCESS_EMP_REVIEW.process_api',5);
  --
  savepoint  process_emp_review_details;
  --
  empReviewCsr := get_employee_review(p_transaction_step_id);
  fetch empReviewCsr into l_event_id, l_type, l_typeMeaning, l_date_start, l_date_end, l_time_start,
                          l_time_end, l_location_id, l_location_code, l_comments, l_Assignment_Id,
                          l_notify_flag, l_business_group_id;
  close empReviewCsr;
  --
  l_person_id  :=  hr_transaction_api.get_varchar2_value (
                       p_transaction_step_id	=> p_transaction_step_id,
		       p_name			=> 'P_PERSON_ID');

  wf_directory.GetUserName
          (p_orig_system    => 'PER'
          ,p_orig_system_id => l_person_id
          ,p_name           => l_username
          ,p_display_name   => l_employee_name);
   --
   -- Bug 3881664: Pick the employee name from WF Attribute current_person_display_name.
      Open  c_empName ;
      Fetch c_empName into l_employee_name;
      Close c_empName;

  -- Send notification to the person if notify flag is turned on
  if l_userName is not null then
     if ( l_notify_flag = 'Y') then
        l_id := WF_NOTIFICATION.send (l_userName,'HRSSA','PQH_EMP_REV_MSG',NULL,NULL,NULL,NULL,NULl);
--
      set_notification_attributes (
        p_ntf_id         => l_id,
        p_employee_name  => l_employee_name,
        p_review_type    => l_typeMeaning,
        p_date_start     => l_date_start,
        p_date_end       => l_date_end,
        p_time_start     => l_time_start,
        p_time_end       => l_time_end,
        p_location       => l_location_code,
        p_comments       => l_comments);

     End if; -- if notify flag is Y
   --
   End if;  -- End if user name is not null

  IF l_Event_id IS NOT NULL or  l_Event_id <> '0' THEN
  --
  open getrowid(l_event_id);
   fetch getrowid into l_Row_id;
  close getrowid;

  PER_EVENTS_PKG.Update_row(X_Rowid 		 => l_Row_id,
                       X_Event_Id   		 => l_Event_id,
                       X_Business_Group_Id	 => l_Business_Group_Id,
                       X_Location_Id             => l_Location_id,
                       X_Internal_Contact_Person_Id => null,
                       X_Organization_Run_By_Id     => null,
                       X_Assignment_Id              => l_Assignment_Id,
                       X_Date_Start 		    => fnd_date.chardt_to_date(l_Date_Start),
                       X_Type                       => l_Type,
                       X_Comments                   => l_Comments,
                       X_Contact_Telephone_Number   => null ,
                       X_Date_End                   => fnd_date.chardt_to_date(l_Date_End ),
                       X_Emp_Or_Apl                 => 'E',
                       X_Event_Or_Interview         => 'I' ,
                       X_External_Contact           => null ,
                       X_Time_End                   => l_Time_End,
                       X_Time_Start                 => l_Time_Start,
                       X_Attribute_Category         => null,
                       X_Attribute1                 => null,
                       X_Attribute2                 => null,
                       X_Attribute3                 => null,
                       X_Attribute4                 => null,
                       X_Attribute5		=> null,
                       X_Attribute6		=> null,
                       X_Attribute7		=> null,
                       X_Attribute8		=> null,
                       X_Attribute9		=> null,
                       X_Attribute10   		=> null,
                       X_Attribute11		=> null,
                       X_Attribute12		=> null,
                       X_Attribute13		=> null,
                       X_Attribute14		=> null,
                       X_Attribute15		=> null,
                       X_Attribute16		=> null,
                       X_Attribute17		=> null,
                       X_Attribute18		=> null,
                       X_Attribute19		=> null,
                       X_Attribute20		=> null,
                     X_ctl_globals_end_of_time  => fnd_date.chardt_to_date(l_Date_Start));
   --
   ELSE
   --
   PER_EVENTS_PKG.Insert_row(X_Rowid 		  	 => l_Row_id,
                          X_Event_Id   			 => l_Event_id,
                          X_Business_Group_Id		 => l_Business_Group_Id,
                          X_Location_Id           	 => l_Location_id,
                          X_Internal_Contact_Person_Id => null,
                          X_Organization_Run_By_Id     => null,
                          X_Assignment_Id              => l_Assignment_Id,
                          X_Date_Start 		       => fnd_date.chardt_to_date(l_Date_Start),
                          X_Type                       => l_Type,
                          X_Comments                   => l_Comments,
                          X_Contact_Telephone_Number   => null ,
                          X_Date_End                   => fnd_date.chardt_to_date(l_Date_End ),
                          X_Emp_Or_Apl                 => 'E',
                          X_Event_Or_Interview         => 'I' ,
                          X_External_Contact           => null ,
                          X_Time_End                   => l_Time_End,
                          X_Time_Start                 => l_Time_Start,
                          X_Attribute_Category         => null,
                          X_Attribute1                 => null,
                          X_Attribute2                 => null,
                          X_Attribute3                 => null,
                          X_Attribute4                 => null,
                          X_Attribute5		=> null,
                          X_Attribute6		=> null,
                          X_Attribute7		=> null,
                          X_Attribute8		=> null,
                          X_Attribute9		=> null,
                          X_Attribute10   	=> null,
                          X_Attribute11		=> null,
                          X_Attribute12		=> null,
                          X_Attribute13		=> null,
                          X_Attribute14		=> null,
                          X_Attribute15		=> null,
                          X_Attribute16		=> null,
                          X_Attribute17		=> null,
                          X_Attribute18		=> null,
                          X_Attribute19		=> null,
                          X_Attribute20		=> null,
                     X_ctl_globals_end_of_time  => fnd_date.chardt_to_date(l_Date_Start));
     --
  END IF;

    pkg_event_id  := l_Event_id;
    reviewer_csr  := get_reviewers (   p_transaction_step_id,'Y'  );

    while (true)
    loop
       fetch reviewer_csr into l_event_id, l_booking_id, l_ename, l_employee_no, l_person_id, l_temp,
                               l_comments, l_status, l_business_group_id ;
       exit when reviewer_csr%notfound;
       --
       l_status := NVL(l_status,'N');
       --
       process_emp_reviewers_api (
                p_validate          => p_validate,
                p_event_id          => l_event_id,
                p_booking_id        => l_booking_id,
                p_employee_no       => l_employee_no,
                p_comments          => l_comments,
                p_business_group_id => l_business_group_id,
                p_status            => l_status,
                p_personId          => l_person_Id );
       --
       wf_directory.GetUserName
          (p_orig_system    => 'PER'
          ,p_orig_system_id => l_person_Id
          ,p_name           => l_username
          ,p_display_name   => l_ename );
       --
    IF ( l_userName IS NOT NULL AND l_status in ('D','N') ) THEN
       --
       If l_status = 'D' Then
         l_id := WF_NOTIFICATION.send (l_userName,'HRSSA','PQH_EMP_REV_REMOVED_MSG',NULL,NULL,NULL,NULL,NULl);
       elsif l_status = 'N' Then
         l_id := WF_NOTIFICATION.send (l_userName,'HRSSA','PQH_EMP_REV_ADDED_MSG',NULL,NULL,NULL,NULL,NULl);
       end if;
       --
      set_notification_attributes (
        p_ntf_id         => l_id,
        p_employee_name  => l_employee_name,
        p_review_type    => l_typeMeaning,
        p_date_start     => l_date_start,
        p_date_end       => l_date_end,
        p_time_start     => l_time_start,
        p_time_end       => l_time_end,
        p_location       => l_location_code,
        p_comments       => l_comments);
       --
    End If;
    end loop;
    --
    --
  close  reviewer_csr ;

    hr_utility.set_location('merge_attachments Start : l_person_id = ' || l_person_id || ' ' || 'PQH_PROCESS_EMP_REVIEW.PROCESS_API', 7);

  HR_UTIL_MISC_SS.merge_attachments( p_dest_entity_name => 'PER_PEOPLE_F'
                           ,p_dest_pk1_value => l_person_id
                           ,p_return_status => l_attach_status);

  hr_utility.set_location('merge_attachments End: l_attach_status = ' || l_attach_status || ' ' || 'PQH_PROCESS_EMP_REVIEW.PROCESS_API',9);

  hr_utility.set_location('Leaving: PQH_PROCESS_EMP_REVIEW.process_emp_review_api',10);
EXCEPTION
  WHEN hr_utility.hr_error THEN
	ROLLBACK TO process_emp_review_details;
	RAISE;
  WHEN OTHERS THEN
	ROLLBACK TO process_emp_review_details;
        RAISE;  -- Raise error here relevant to the new tech stack.
END process_api;

 --
 --
PROCEDURE process_emp_reviewers_api (
     p_validate             IN   BOOLEAN DEFAULT FALSE,
     p_Event_Id             IN   NUMBER,
     p_Booking_Id           IN   NUMBER,
     p_Employee_no          IN   VARCHAR2 ,
     p_Comments             IN   VARCHAR2 ,
     p_Business_Group_Id    IN   NUMBER,
     p_status               IN   VARCHAR2,
     p_personId             IN   NUMBER     ) IS

   l_Row_id			VARCHAR2(100);
   l_id 			number;
   l_userName			VARCHAR2(100);
   l_MsgType    		VARCHAR2(100);
   l_rowId			VARCHAR2(100);
   l_count			Number;
   l_booking_id                 Number;

   Cursor getBookingRowid(p_Booking_id In Number) is
    select rowid
    from per_bookings
    where Booking_id = p_Booking_id;

     Cursor getBookingRowidForBooking(p_personId In Number,p_event_id In Number) is
     Select rowid
     From per_bookings
     Where person_id =p_personId and event_id = p_event_id;

   Cursor check_for_row_exsistance(X_Person_Id in Number,X_Event_Id in Number) is
   Select count(*)
   from per_bookings
   where person_id = x_Person_Id and event_Id = x_Event_Id;

 Begin
    --
    hr_utility.set_location('Entering: PQH_PROCESS_EMP_REVIEW.process_emp_review_api',5);
    --
    savepoint  process_emp_reviewers_details;
    --
    hr_utility.set_location('p_personId '||p_personId||'Delete Place'||p_status,10);
    --
    If p_status = 'D' Then
       --
       open  getBookingRowid(p_Booking_Id);
       fetch getBookingRowid into l_rowId;
       close getBookingRowid;
       --
       hr_utility.set_location('Row Id in Delete '||l_rowId,10);
       per_bookings_pkg.Delete_Row(X_Rowid  => l_rowId);
       hr_utility.set_location(' After Row Id in Delete '||l_rowId,10);
       --
     end if;
    --
    IF p_Booking_id IS NOT NULL or p_Booking_id <> '0' THEN
       --
       open  getBookingRowidForBooking(p_personId,p_event_id);
       fetch getBookingRowidForBooking into l_rowId;
       close getBookingRowidForBooking;
       --
       hr_utility.set_location('Row Id '||l_rowId,10);
       hr_utility.set_location('Booking Id '||p_Booking_Id||'business Group Id '||p_Business_Group_Id||'event Id '||p_event_id,10);
       --
       PER_BOOKINGS_PKG.Update_Row(X_Rowid       => l_rowId,
                            X_Booking_Id         => p_Booking_Id ,
                            X_Business_Group_Id  => p_Business_Group_Id,
                            X_Person_Id          => p_personId,
                            X_Event_Id           => p_event_id,
                            X_Message	         => null,
       	                    X_Token              => null,
                            X_Comments           => p_Comments,
                            X_Attribute_Category => null,
                            X_Attribute1         => null,
                            X_Attribute2         => null,
                            X_Attribute3         => null,
                            X_Attribute4         => null,
                            X_Attribute5         => null,
                            X_Attribute6         => null,
                            X_Attribute7         => null,
                            X_Attribute8         => null,
                            X_Attribute9         => null,
                            X_Attribute10        => null,
                            X_Attribute11        => null,
                            X_Attribute12        => null,
                            X_Attribute13        => null,
                            X_Attribute14        => null,
                            X_Attribute15        => null,
                            X_Attribute16        => null,
                            X_Attribute17        => null,
                            X_Attribute18        => null,
                            X_Attribute19        => null,
                            X_Attribute20        => null);
      --
      ELSE
      --

       open  check_for_row_exsistance(p_personId,pkg_event_id);
       fetch check_for_row_exsistance into l_count;
       close check_for_row_exsistance;

      if l_count = 0 then

      PER_BOOKINGS_PKG.Insert_Row(X_Rowid       => l_Row_Id,
                              X_Booking_Id         => l_Booking_Id ,
                              X_Business_Group_Id  => p_Business_Group_Id,
                              X_Person_Id          => p_personId,
                              X_Event_Id           => pkg_event_id,
                              X_Message	    	   => null,
         	              X_Token              => null,
                              X_Comments           => p_Comments,
                              X_Attribute_Category => null,
                              X_Attribute1         => null,
                              X_Attribute2         => null,
                              X_Attribute3         => null,
                              X_Attribute4         => null,
                              X_Attribute5         => null,
                              X_Attribute6         => null,
                              X_Attribute7         => null,
                              X_Attribute8         => null,
                              X_Attribute9         => null,
                              X_Attribute10        => null,
                              X_Attribute11        => null,
                              X_Attribute12        => null,
                              X_Attribute13        => null,
                              X_Attribute14        => null,
                              X_Attribute15        => null,
                              X_Attribute16        => null,
                              X_Attribute17        => null,
                              X_Attribute18        => null,
                              X_Attribute19        => null,
                          X_Attribute20        => null);

      END IF;  -- for l_count

     END IF;

  -- ns 5/19/2005: BUG 4381336: commenting commit as it is called while
  -- resurrecting the transaction (via update action link), it is then
  -- attempted to rollback which would fail if committed here.
  -- commit;

     hr_utility.set_location('Leaving: PQH_PROCESS_EMP_REVIEW.process_emp_reviewers_api',10);
  EXCEPTION
     WHEN hr_utility.hr_error THEN
        ROLLBACK TO process_emp_reviewers_details;
     	RAISE;
     WHEN OTHERS THEN
        ROLLBACK TO process_emp_reviewers_details;
     	RAISE;  -- Raise error here relevant to the new tech stack.
 End process_emp_reviewers_api;
 --
 --
END;

/
