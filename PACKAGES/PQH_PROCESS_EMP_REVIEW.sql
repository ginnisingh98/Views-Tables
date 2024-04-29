--------------------------------------------------------
--  DDL for Package PQH_PROCESS_EMP_REVIEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PROCESS_EMP_REVIEW" AUTHID CURRENT_USER AS
/* $Header: pqrewpkg.pkh 115.6 2004/05/11 15:08:18 nsanghal noship $ */
--
--
--
TYPE ref_cursor IS REF CURSOR;
--
FUNCTION  get_reviewers (
   p_transaction_step_id in varchar2
  ,p_show_deleted        in varchar2 default NULL ) RETURN ref_cursor;
--
--
--
FUNCTION  get_employee_review (
 p_transaction_step_id   in     varchar2 ) RETURN ref_cursor ;
--
--

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
 x_Business_Group_Id        OUT NOCOPY NUMBER ,
 x_notify_flag		   OUT NOCOPY   VARCHAR2
);
--
--

PROCEDURE get_emp_reviewers_details(
x_transaction_step_id      IN    VARCHAR2,
x_Event_Id                 OUT NOCOPY   NUMBER,
x_Booking_Id               OUT NOCOPY   NUMBER,
x_Employee_no              OUT NOCOPY   VARCHAR2,
x_Comments                 OUT NOCOPY   VARCHAR2,
x_Business_Group_Id        OUT NOCOPY   NUMBER,
x_status                   OUT NOCOPY   VARCHAR2,
x_row_number		   IN    VARCHAR2,
x_person_id		   OUT NOCOPY   NUMBER   );


--
--

PROCEDURE get_reviewers_count(
x_transaction_step_id      IN    VARCHAR2,

x_total_no_of_rows   OUT NOCOPY NUMBER,
 x_total_deleted_rows   OUT NOCOPY NUMBER);
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
x_notify_flag		   IN   VARCHAR2);
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
x_status                   IN   VARCHAR2) ;

--
--

PROCEDURE process_api (
   p_validate		   IN   BOOLEAN DEFAULT FALSE,
   p_transaction_step_id   IN   NUMBER );
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
     p_personId             IN   NUMBER     ) ;
--
--

PROCEDURE rollback_transaction (
	itemType	IN VARCHAR2,
	itemKey		IN VARCHAR2,
        result	 OUT NOCOPY VARCHAR2) ;

--
--
pkg_event_id Number;
END pqh_process_emp_review;

 

/
