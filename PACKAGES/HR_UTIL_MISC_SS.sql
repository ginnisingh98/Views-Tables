--------------------------------------------------------
--  DDL for Package HR_UTIL_MISC_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_UTIL_MISC_SS" AUTHID CURRENT_USER AS
/* $Header: hrutlmss.pkh 120.11.12010000.9 2009/10/19 11:48:30 gpurohit ship $ */

  TYPE EntityTabTyp IS TABLE of NUMBER index by binary_integer;

  g_entity_list EntityTabTyp;
  g_eff_date DATE:= sysdate;
  g_year_start DATE;
  g_loginPrsnBGId NUMBER;
  g_loginPrsnCurrencyCode VARCHAR2(30);
  g_rate_type VARCHAR2(30);

  PROCEDURE initLoginPrsnCtx(p_eff_date IN DATE);

  PROCEDURE populateInterimPersonList (
    person_data  PER_INTERIM_PERSON_LIST_STRUCT
  );

  PROCEDURE populateInterimListFromMyList (
    person_id number
  );

  PROCEDURE addToMyListFromInterimList (
    prsn_id number
  );

  PROCEDURE setEffectiveDate
     (p_effective_date in  date);


  PROCEDURE clear_cache;

  PROCEDURE populate_entity_list (
    p_elist IN HR_MISC_SS_NUMBER_TABLE,
    p_retain_cache in VARCHAR2
  );

  FUNCTION entity_exists (
    p_entity_id IN Number
  )
  RETURN VARCHAR2;

  FUNCTION validate_selected_function (
     p_api_version        IN  NUMBER
    ,p_function           IN  VARCHAR2
    ,p_object_name        IN  VARCHAR2
    ,p_person_id          IN  VARCHAR2
    ,p_instance_pk2_value IN  VARCHAR2
    ,p_user_name          IN  VARCHAR2
    ,p_eff_date           IN  DATE
  )
  RETURN VARCHAR2;

  FUNCTION check_cwk_access (
     p_function   IN VARCHAR2
    ,p_person_id  IN NUMBER
    ,p_eff_date   IN DATE
  )
  RETURN VARCHAR2;

  FUNCTION check_akregion_code (
    p_ak_region  IN VARCHAR2
  )
  RETURN VARCHAR2;

  PROCEDURE check_ota_installed (appl_id number, status out NOCOPY varchar2);

  PROCEDURE is_primary_assign (
    itemtype in     varchar2,
    itemkey  in     varchar2,
    actid    in     number,
    funcmode in     varchar2,
    resultout   out nocopy varchar2
  );

  FUNCTION get_apl_asgs_count(
    p_person_id IN number,
    p_effective_date IN date)
  return number;

FUNCTION get_assign_termination_date(
	p_assignment_id IN number) return date;

  PROCEDURE is_employee_check (
    itemtype in     varchar2,
    itemkey  in     varchar2,
    actid    in     number,
    funcmode in     varchar2,
    resultout   out nocopy varchar2
  );
  FUNCTION getObjectName(
           p_object    IN varchar2,
           p_object_id IN number,
           p_bg_id     IN number,
           p_value     IN varchar2
         )
  return varchar2;

  FUNCTION check_term_access (
     p_function   IN VARCHAR2
    ,p_person_id  IN NUMBER
    ,p_eff_date   IN DATE
  )
  RETURN VARCHAR2;

  FUNCTION check_primary_access (
     p_selected_person_id NUMBER,
     p_effective_date     DATE)
  RETURN VARCHAR2;

 PROCEDURE initialize_am ;

  PROCEDURE SET_SYS_CTX (
    p_legCode in varchar2
   ,p_bgId    in varchar2
  );

  function get_person_id return number;

  FUNCTION getCompSourceInfo (
   p_competence_id IN NUMBER
  ,p_person_id IN NUMBER
  ) RETURN VARCHAR2;

  FUNCTION get_in_preferred_currency_num(
    p_amount IN NUMBER
    ,p_from_currency IN VARCHAR2
    ,p_eff_Date IN DATE DEFAULT trunc(sysdate)
    ,p_override_currency IN VARCHAR2 default fnd_profile.value('ICX_PREFERRED_CURRENCY')
   ) RETURN NUMBER;

  FUNCTION get_in_preferred_currency_str(
    p_amount IN NUMBER
    ,p_from_currency IN VARCHAR2
    ,p_eff_Date IN DATE DEFAULT trunc(sysdate)
    ,p_override_currency IN VARCHAR2 default fnd_profile.value('ICX_PREFERRED_CURRENCY')
   ) RETURN VARCHAR2;

  FUNCTION get_preferred_currency(
    p_from_currency IN VARCHAR2
    ,p_eff_Date IN DATE DEFAULT trunc(sysdate)
    ,p_override_currency IN VARCHAR2 default fnd_profile.value('ICX_PREFERRED_CURRENCY')
  ) RETURN VARCHAR2;

  FUNCTION get_employee_salary(
     p_assignment_id IN NUMBER
     ,P_Effective_Date IN date
   ) RETURN NUMBER;

  FUNCTION get_employee_salary(
  p_assignment_id in number
  ,p_Effective_Date  in date
   ,p_proposed_salary IN NUMBER
   ,p_pay_annual_factor IN number
  ,p_pay_basis in varchar2
   ) RETURN NUMBER;

  PROCEDURE populateInterimEntityList (
    entity_data  PER_INTERIM_ENTITY_LIST_STRUCT
    ,p_retain_cache IN VARCHAR2
  );

  PROCEDURE clearInterimEntityList ;

  procedure isPersonTerminated (
   result out nocopy varchar2,
   p_person_id varchar2,
   p_assignment_id varchar2
  );

  procedure getDeploymentPersonID (person_id in number, result out nocopy number );

     FUNCTION getBusinessGroup(
           p_function_id IN number,
           p_bg_id     IN number,
           p_person_id IN number
   )RETURN per_all_people_f.business_group_id%Type;

  FUNCTION get_parameter_value (
     p_parameter_list IN VARCHAR2
    ,p_parameter      IN VARCHAR2
  )
  RETURN VARCHAR2;

 procedure merge_attachments (
		p_source_entity_name        in varchar2 default 'PQH_SS_ATTACHMENT'
		,p_dest_entity_name        in varchar2
    ,p_source_pk1_value          in varchar2 default null
    ,p_dest_pk1_value          in varchar2
    ,p_return_status         in out nocopy varchar2 );

procedure saveAttachment(
		p_transaction_id        in Number default null
		,p_return_status        out nocopy varchar2);


function getAttachToEntity(
		p_transaction_id in number)
return boolean ;

function getUpgradeCheck(
     p_transaction_id in number)
return varchar2;

function getLocName (p_loc_id in number, p_bg_id in number)
return varchar2;
function getOrgName (p_org_id in number, p_bg_id in number)
return varchar2;
function getGradeName (p_grade_id in number, p_bg_id in number)
return varchar2;
function getPositionName (p_position_id in number, p_bg_id in number)
return varchar2;
function getJobName (p_job_id in number, p_bg_id in number)
return varchar2;

END HR_UTIL_MISC_SS;

/
