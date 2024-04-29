--------------------------------------------------------
--  DDL for Package HR_APPROVAL_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPROVAL_CUSTOM" AUTHID CURRENT_USER as
/* $Header: hrapcuwf.pkh 120.1 2005/06/15 01:33:15 sturlapa noship $ */
--
  g_itemtype varchar2(8);
  g_itemkey  varchar2(240);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_routing_details1 >--------------------|
-- ----------------------------------------------------------------------------
--
-- This function returns the Id of a person. Used for routing of notifications
-- within the approval process
--
function get_routing_details1
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_routing_details2 >--------------------|
-- ----------------------------------------------------------------------------
--
-- This function returns the Id of a person. Used for routing of notifications
-- within the approval process
--
function get_routing_details2
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_routing_details3 >--------------------|
-- ----------------------------------------------------------------------------
--
-- This function returns the Id of a person. Used for routing of notifications
-- within the approval process
--
function get_routing_details3
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type;
-- ----------------------------------------------------------------------------
-- |------------------------------< get_routing_details4 >--------------------|
-- ----------------------------------------------------------------------------
--
-- This function returns the Id of a person. Used for routing of notifications
-- within the approval process
--
function get_routing_details4
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_routing_details5 >--------------------|
-- ----------------------------------------------------------------------------
--
-- This function returns the Id of a person. Used for routing of notifications
-- within the approval process
--
function get_routing_details5
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type;
--
-- ------------------------------------------------------------------------
-- |----------------------< Check_Final_Approver >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Determine if this person is the final manager in the approval chain
--
--
function Check_Final_Approver
       (p_forward_to_person_id  in per_people_f.person_id%type
       ,p_person_id             in per_people_f.person_id%type)
    return varchar2;
--
-- ------------------------------------------------------------------------
-- |----------------------< Check_Final_Payroll_Notifier >----------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Determine if this person is the final payroll notifier in the payroll
--  notification chain
--
--
function Check_Final_Payroll_Notifier
       (p_forward_to_person_id  in per_people_f.person_id%type
       ,p_person_id             in per_people_f.person_id%type)
    return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------< Get_next_approver >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the next approver in the chain
--
--
function Get_Next_Approver
       (p_person_id     in per_people_f.person_id%type)
        return per_people_f.person_id%type;
-- ------------------------------------------------------------------------
-- |------------------------< Get_next_payroll_notifier >-----------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the next payroll notifier in the payroll notification chain
--
--
function Get_Next_Payroll_Notifier
       (p_person_id     in per_people_f.person_id%type)
        return per_people_f.person_id%type;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL1 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk
--  This is the URL for the approver to review the changes of an employee
--
--
function get_URL1 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL2 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk
--  This is the URL for the employee to complete a process once approved
--
--
function get_URL2 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL3 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk
--  This is the URL for the employee to resubmit a rejected request
--
--
function get_URL3 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL4 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk
--  This is the URL for the employee to cancel a rejected request
--
--
function get_URL4 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL5 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk Apply for a Job
--  This is the URL for the approver to review the employee details
--
--
function get_URL5 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL6 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk Apply for a Job
--  This is the URL for the approver to review the job details
--
--
function get_URL6 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL7 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk Apply for a Job
--  This is the URL for the approver to review the employee's application
--
--
function get_URL7 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL8 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk Apply for a Job
--  This is the URL for the approver to review the job details
--
--
function get_URL8 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL9 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk Apply for a Job
--  This is the URL for the approver to review the job details
--
--
function get_URL9 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL10 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk
--  This is the URL for the employee to cancel a rejected request
--
--
function get_URL10 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL11 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk
--  This is the URL for the employee to cancel a rejected request
--
--
function get_URL11 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL12 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk
--  This is the URL for the employee to cancel a rejected request
--
--
function get_URL12 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL13 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk
--  This is the URL for the employee to cancel a rejected request
--
--
function get_URL13 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL14 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk
--  This is the URL for the employee to cancel a rejected request
--
--
function get_URL14 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL15 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk
--  This is the URL for the employee to cancel a rejected request
--
--
function get_URL15 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL16 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk
--  This is the URL for the employee to cancel a rejected request
--
--
function get_URL16 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL17 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk
--  This is the URL for the employee to cancel a rejected request
--
--
function get_URL17 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL18 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk
--  This is the URL for the employee to cancel a rejected request
--
--
function get_URL18 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL19 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk
--  This is the URL for the employee to cancel a rejected request
--
--
function get_URL19 return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL20 >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This function will return a  URL for the Employee Kiosk
--  This is the URL for the employee to cancel a rejected request
--
--
function get_URL20 return varchar2;
-- ----------------------------------------------------------------------------
-- |-----------------------< check_if_in_approval_chain >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--
--  This function will return true if the forward to person is in
--  the approval chain of the current person
--
function check_if_in_approval_chain
           (p_forward_to_person_id in per_people_f.person_id%type
           ,p_person_id            in per_people_f.person_id%type)
         return boolean;
--
end hr_approval_custom;

 

/
