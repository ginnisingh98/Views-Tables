--------------------------------------------------------
--  DDL for Package PQH_FR_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_UTILITY" AUTHID CURRENT_USER AS
/* $Header: pqfrutil.pkh 120.3.12000000.1 2007/01/16 22:44:08 appldev noship $ */



    FUNCTION  Get_Award_Type(p_person_id   Number,
                             p_award_category  Varchar2,
                             p_award_type      Varchar2) RETURN VARCHAR2;
    FUNCTION  Get_Award_Grade_Level(p_person_id   Number,
                                    p_award_category  Varchar2,
                                    p_award_type      Varchar2)  RETURN VARCHAR2;

    FUNCTION Get_Entitlement_Item(p_business_group_id NUMBER,
                                  p_item_type Varchar2) RETURN NUMBER;
    FUNCTION Check_PS_Installed (p_business_group_id NUMBER) RETURN VARCHAR2;
    PROCEDURE Get_DateTrack_Mode (p_effective_date IN DATE,
                                 p_base_table_name IN VARCHAR2,
                                 p_base_key_column IN VARCHAR2,
                                 p_base_key_value  IN NUMBER,
                                 p_datetrack_mode  OUT NOCOPY VARCHAR2);

   FUNCTION  Get_Accommodation_status (p_accommodation_id IN NUMBER,
                                      p_effective_date IN DATE) RETURN VARCHAR2;

   FUNCTION get_lookup_shared_type( p_lookup_type VARCHAR2, p_lookup_code VARCHAR2,
                                     p_business_group_id NUMBER, p_return_value VARCHAR2) RETURN VARCHAR2;

   procedure hr_actions_validate_person (p_person_id in number, p_return_status out NOCOPY varchar2,
                            p_effective_date in varchar2,p_function_name in Varchar2);

   procedure admin_effective_warning( p_person_id in number,p_effective_date in varchar2,p_return_status out NOCOPY varchar );

   Function Get_DateTrack_Mode ( p_effective_date IN DATE,
                                 p_base_table_name IN VARCHAR2,
                                 p_base_key_column IN VARCHAR2,
                                 p_base_key_value  IN NUMBER) Return varchar2;

  Function Get_available_hours(p_person_id IN NUMBER, p_effective_date in Date) return number;

  Function Get_Salary_Share(p_shard_type_cd IN Varchar2) return VARCHAR2;

  Function Get_contract_reference(p_contract_id in Number, p_effective_date in Date) return varchar2;


  Function is_worker_employee(p_person_id in number, p_effective_date in date) return boolean;

  Function is_worker_CWK(p_person_id in number, p_effective_date in date) return boolean;

  PROCEDURE Default_Employment_Terms(p_person_id IN NUMBER,p_emp_type IN VARCHAR2);

  Function is_action_valid(p_function_name IN varchar2, p_person_id in Number,p_effective_date in Date) return varchar2;

  Function get_position_name (p_admin_career_id in Varchar2,p_effective_date in Date) return varchar2;

  Function get_position_id (p_admin_career_id in Varchar2,p_effective_date in Date) return number;

  FUNCTION GET_STEP_RATE (p_step_id IN NUMBER, p_effective_date IN DATE, p_gl_currency IN VARCHAR2) RETURN NUMBER;

  FUNCTION GET_SALARY_RATE(p_assignment_id NUMBER, p_effective_date DATE) RETURN NUMBER;

 FUNCTION GET_DT_DIFF_FOR_DISPLAY(p_start_date IN DATE, p_end_date IN DATE) Return VARCHAR2;

 Function GET_BG_TYPE_OF_PS RETURN VARCHAR2;

 function view_start_date(p_assignment_id in number,
                         p_start_date    in date,
                         p_action        in varchar2) return date;
--
--Function to get Proposed End Date for Contract.
  FUNCTION get_proposed_end_date(p_contract_id      IN NUMBER,
                                 p_effective_date   IN DATE)
  RETURN DATE;
--
--Function to check if Working Hours changed or Affectations exist outside new Corp.
  FUNCTION diff_corps_attributes(p_old_ben_pgm_id    IN VARCHAR2,
                                 p_new_ben_pgm_id    IN VARCHAR2,
                                 p_primary_assign_id IN NUMBER,
                                 p_effective_date    IN DATE)
  RETURN VARCHAR2;
--
--Function to check if Working Hours changed for new Establishment.
  FUNCTION check_work_hrs(p_old_estab_id   IN VARCHAR2,
                          p_new_estab_id   IN VARCHAR2,
                          p_effective_date IN DATE)
  RETURN VARCHAR2;
--
function view_end_date(p_assignment_id in number,
                         p_person_id in number,
                         p_start_date    in date,
                         p_action        in varchar2) return date;

FUNCTION diff_corps_positions(p_pos_id    IN VARCHAR2,
                                 p_primary_assign_id IN NUMBER,
                                 p_effective_date    IN DATE)
  RETURN VARCHAR2 ;
--
--Function to get Org Category Information1 for BG Shared Type.
  FUNCTION get_ps_org_cat_info(p_person_id      NUMBER,
                               p_effective_date DATE) RETURN VARCHAR2;

--
--This function is same as get_lookup_shared_types but because of Web ADI
--Integrator Col limitations created this function so as to reduce size of
--fn call in query to fit Val_Object_Name Column size for Type_Of_PS LOV.
  FUNCTION get_ps(p_lookup_code  VARCHAR2
                 ,p_return_value VARCHAR2) RETURN VARCHAR2;
--
  FUNCTION get_currency_desc(p_currency_code IN VARCHAR2) RETURN VARCHAR2;
--
  FUNCTION get_owner_desc(p_org_id         IN NUMBER
                         ,p_effective_date IN DATE) RETURN VARCHAR2;
--
  FUNCTION get_payment_name(p_business_group_id IN NUMBER
                           ,p_payment_code      IN NUMBER) RETURN VARCHAR2;
--
-- New procedure for mass update of employee assignment form
PROCEDURE DELETE_DUPLICATE_ASG_RECORDS (P_COPY_ENTITY_RESULT_ID in NUMBER
,P_COPY_ENTITY_TXN_ID IN NUMBER
,P_RESULT_TYPE_CD in VARCHAR2
,P_INFORMATION2 IN VARCHAR2
,P_INFORMATION67 IN VARCHAR2);

END PQH_FR_UTILITY;

 

/
