--------------------------------------------------------
--  DDL for Package HR_EMPL_VERF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EMPL_VERF_UTIL" AUTHID CURRENT_USER AS
/* $Header: hrevutil.pkh 120.1 2005/06/07 23:48:58 svittal noship $*/


   FUNCTION CHECK_TICKET_STRING
     ( p_ticket IN VARCHAR2,
       p_operation OUT NOCOPY VARCHAR2,
       p_argument OUT NOCOPY VARCHAR2)
   RETURN NUMBER;

   /*
	PROCEDURE send_mail(to_address IN VARCHAR2, from_address IN VARCHAR2,
                mail_content VARCHAR2);
   */


   PROCEDURE send_notification (to_address IN VARCHAR2,from_address IN VARCHAR2,
                reply_to_address IN VARCHAR2, access_url VARCHAR2, access_days number,
		emp_name IN VARCHAR2, access_limit NUMBER, personal_key VARCHAR2,
        comments VARCHAR2);


   FUNCTION CHECK_ONETIME_TICKET_STRING
     ( p_ticket IN VARCHAR2,
       p_operation OUT NOCOPY VARCHAR2,
       p_argument OUT NOCOPY VARCHAR2) RETURN NUMBER;

   PROCEDURE get_employee_salary
    (p_assignment_id   In Per_All_Assignments_F.ASSIGNMENT_ID%TYPE,
     p_effective_Date  In Date,
     p_salary         OUT nocopy number,
     p_frequency      OUT nocopy varchar2,
     p_annual_salary  OUT nocopy number,
     p_pay_basis      OUT nocopy varchar2,
     p_reason_cd      OUT nocopy varchar2,
     p_currency       OUT nocopy varchar2,
     p_status         OUT nocopy number,
     p_currency_name  OUT nocopy varchar2,
     p_pay_basis_frequency  OUT nocopy varchar2
   );

   FUNCTION UPDATE_TICKET_STRING(P_TICKET    in varchar2,
                                P_OPERATION in varchar2,
                                P_ARGUMENT  in varchar2)
   return number;


END HR_EMPL_VERF_UTIL; -- Package spec


 

/
