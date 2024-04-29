--------------------------------------------------------
--  DDL for Package PAY_GB_STUDENT_LOANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_STUDENT_LOANS_PKG" AUTHID CURRENT_USER AS
/* $Header: pygbslco.pkh 120.1 2005/06/12 05:25:10 npershad noship $ */
PROCEDURE Fetch_Balances(
            p_assignment_id in PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ID%TYPE,
            p_element_type_id in PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_Id%TYPE,
            p_element_name in PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE,
            p_element_entry_id in PAY_RUN_RESULTS.SOURCE_ID%TYPE,
            p_itd_balance   OUT NOCOPY NUMBER,
            p_ptd_balance   OUT NOCOPY NUMBER
             );

PROCEDURE Update_Court_Order(
            p_datetrack_update_mode in     varchar2
           ,p_effective_date        in     date
           ,p_business_group_id     in     number
           ,p_element_entry_id      in     number
           ,p_object_version_number in out nocopy number
           ,p_subpriority           in     number
           ,p_effective_start_date     out nocopy date
           ,p_effective_end_date       out nocopy date);

PROCEDURE Create_Student_Loan(
           P_EFFECTIVE_DATE         in     Date,
           P_BUSINESS_GROUP_ID      in     Number,
           P_ASSIGNMENT_ID          in     Number,
           P_START_DATE             in     Varchar2,
           P_END_DATE               in     Varchar2,
           P_SUBPRIORITY            in     Number,
           P_EFFECTIVE_START_DATE      out nocopy Date,
           P_EFFECTIVE_END_DATE        out nocopy Date,
           P_ELEMENT_ENTRY_ID          out nocopy Number,
           P_OBJECT_VERSION_NUMBER     out nocopy Number);

PROCEDURE Delete_Student_Loan(
            p_datetrack_mode in VARCHAR2
           ,p_element_entry_id in NUMBER
           ,p_effective_date in DATE
           ,p_object_version_number in NUMBER);

PROCEDURE Update_Student_Loan(
            p_datetrack_update_mode in     varchar2
           ,p_effective_date        in     date
           ,p_business_group_id     in     number
           ,p_element_entry_id      in     number
           ,p_object_version_number in out nocopy number
           ,p_start_date            in     VARCHAR2
           ,p_end_date              in     VARCHAR2
           ,p_subpriority           in     number
           ,p_effective_start_date     out nocopy date
           ,p_effective_end_date       out nocopy date);

/*Added below functions for bug fix 3336452*/

FUNCTION get_current_freq(p_assignment_id IN NUMBER
                         ,p_date_earned   IN  DATE
			 ,p_reference     IN VARCHAR2
			 ) RETURN NUMBER;

FUNCTION get_current_pay_date(p_assignment_id IN NUMBER
                             ,p_date_earned   IN  DATE
			     ,p_reference     IN VARCHAR2
			     ) RETURN DATE;


FUNCTION count_main_cto_entry(p_assignment_id IN NUMBER
                             ,p_date_earned   IN DATE
			     ,p_reference     IN VARCHAR2
			     ) RETURN NUMBER;

FUNCTION get_main_cto_pay_date(p_assignment_id IN NUMBER
                              ,p_date_earned   IN DATE
			      ,p_reference     IN VARCHAR2
			      ) RETURN DATE;

FUNCTION get_main_cto_freq(p_assignment_id IN NUMBER
                          ,p_date_earned   IN DATE
                          ,p_reference     IN VARCHAR2
			  ) RETURN NUMBER;

FUNCTION get_main_initial_debt(p_assignment_id IN NUMBER
                              ,p_date_earned   IN DATE
			      ,p_reference     IN VARCHAR2
			      ) RETURN NUMBER;

FUNCTION get_main_fee(p_assignment_id IN NUMBER
                     ,p_date_earned   IN DATE
	             ,p_reference     IN VARCHAR2
		     ) RETURN NUMBER;

FUNCTION check_ref(p_assignment_id IN NUMBER
                  ,p_date_earned   IN DATE
                  ,p_reference     IN VARCHAR2
		  ) RETURN VARCHAR2;

FUNCTION get_main_entry_value(p_assignment_id IN NUMBER,
                              p_date_earned   IN DATE,
                              p_reference     IN VARCHAR2
		              ) RETURN VARCHAR2;

/*Added below function for bug fix 4395503*/
FUNCTION entry_exists(p_element_entry_id IN NUMBER
                     ,p_date_earned     IN DATE
                     ,p_asg_action_id   IN NUMBER
                     ,p_reference       IN VARCHAR2) RETURN VARCHAR2 ;


END PAY_GB_STUDENT_LOANS_PKG;

 

/
