--------------------------------------------------------
--  DDL for Package PQH_SS_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SS_UTILITY" AUTHID CURRENT_USER as
/* $Header: pqutlswi.pkh 120.0.12010000.1 2008/07/28 13:16:26 appldev ship $*/

procedure get_rg_eligibility(p_person_id in number,
                            p_rptg_grp_id in number,
                            p_eligibility_flag out nocopy varchar2,
                            p_eligibility out nocopy varchar2);

function get_Reporting_Group_id(
               p_function_name varchar2,
               p_business_group_id number) return number;

function check_eligibility(
               p_person_id number,
               p_rptg_grp_id number) return boolean;
--
FUNCTION check_eligibility (
        p_planId         IN NUMBER
       ,p_personId       IN NUMBER
       ,p_effectiveDate  IN DATE ) RETURN VARCHAR2;
--
--
PROCEDURE get_Role_Info (
        p_roleTypeCd       IN VARCHAR2
       ,p_businessGroupId  IN NUMBER
       ,p_globalRoleFlag  out nocopy VARCHAR2
       ,p_roleName        out nocopy VARCHAR2
       ,p_roleId          out nocopy NUMBER );
--
--


FUNCTION get_pos_structure_version
   ( p_business_group_id number)
   RETURN  number;
--
--
function  check_edit_privilege (
        p_personId        IN NUMBER
       ,p_businessGroupId IN NUMBER ) return VARCHAR2;
--
--
PROCEDURE  check_edit_privilege (
        p_personId        IN NUMBER
       ,p_businessGroupId IN NUMBER
       ,p_editAllowed    out nocopy VARCHAR2 ) ;
--
--
PROCEDURE check_edit_privilege ( p_person_id          IN NUMBER
                                ,p_business_group_id  IN NUMBER
                                ,p_transaction_status IN VARCHAR2
                                ,p_edit_privilege     OUT NOCOPY VARCHAR2) ;
--
--

FUNCTION check_future_change (
             p_txnId          IN NUMBER
            ,p_assignmentId   IN NUMBER
            ,p_effectiveDate  IN DATE
            ,p_calledFrom     IN VARCHAR2 DEFAULT 'REQUEST' ) RETURN VARCHAR2;
--
--
FUNCTION check_pending_transaction(
          p_txnId       IN NUMBER
         ,p_itemType    IN VARCHAR2
         ,p_personId    IN NUMBER
         ,p_assignId    IN NUMBER ) RETURN VARCHAR2 ;
--
--
FUNCTION check_intervening_action (
           p_txnId         IN VARCHAR2
          ,p_assignmentId  IN NUMBER
          ,p_effectiveDate IN DATE
          ,p_futureChange  IN VARCHAR2 ) RETURN VARCHAR2 ;
--
--
FUNCTION get_business_group_id (
        p_personId      IN NUMBER
       ,p_effectiveDate IN DATE    ) RETURN NUMBER;
--
--
FUNCTION check_function_parameter (
        p_functionId  IN NUMBER,
        p_paramName   IN VARCHAR2 ) RETURN VARCHAR2 ;
--
--
L_DESCRIPTION VARCHAR2(2000); -- defined for function get_desc
Function get_desc (p_function VARCHAR2 ) return varchar2;
--
PROCEDURE set_datetrack_mode (
           p_txnId           IN VARCHAR2
          ,p_dateTrack_mode  IN VARCHAR2  );
--
--
FUNCTION get_assignment_startdate ( p_assignmentId IN VARCHAR2 ) RETURN DATE ;
--
function get_approval_process_version(p_itemType varchar2, p_itemKey varchar2 )
 return varchar2;
--
--
FUNCTION  get_transaction_step_id (
          p_itemType  IN VARCHAR2
         ,p_itemKey   IN VARCHAR2
         ,p_apiName   IN VARCHAR2 ) RETURN VARCHAR2;
--
FUNCTION chk_transaction_step_exist( p_transaction_id IN NUMBER ) RETURN VARCHAR2;
--
--
function plans_exists_for_rg(p_reporting_group_id number,
                      p_business_group_id number,
                      p_effective_date date) return varchar2;
--
end;

/
