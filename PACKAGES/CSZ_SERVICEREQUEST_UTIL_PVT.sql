--------------------------------------------------------
--  DDL for Package CSZ_SERVICEREQUEST_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSZ_SERVICEREQUEST_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: cszvutls.pls 120.5 2006/03/22 11:39:48 akartha noship $ */
-- -------------------------------------------------------------------------
-- Start of comments
-- UTIL Name   : GET_USER_NAME
-- Type        : Private
-- Description : Given a USER_ID the function will return the username/partyname. This
--               Function is used to display the CREATED_BY UserName
-- Parameters  :
-- IN : p_user_id NUMBER Required
-- OUT: Returns UserName  VARCHAR2(360)
-- End of comments
-- -------------------------------------------------------------------------
FUNCTION GET_USER_NAME
( p_user_id IN NUMBER )RETURN VARCHAR2;
--
-- -------------------------------------------------------------------------
-- Start of comments
-- UTIL Name   : get_contact_name
-- Type        : Private
-- Description : To get the ContactName based on the ContactPartyId,PartyId and ContactType
-- Parameters  :
-- IN:  p_contact_type IN  VARCHAR2  Required
-- IN : p_contact_party_id     IN  NUMBER Required
-- IN : p_party_id     IN  NUMBER Required
-- Returnvalue:
-- l_contact_name  VARCHAR2(360)
-- End of comments
-- -------------------------------------------------------------------------
FUNCTION get_contact_name
( p_contact_type IN VARCHAR2
 ,p_contact_party_id IN NUMBER
 , p_party_id  IN NUMBER
) RETURN VARCHAR2;
--
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_SR_JEOPARDY
--  Type        : Private
--  Description : Returns if Service Request is in Jeopardy or  not
--  Parameters  :
--  IN : p_incident_id    IN  NUMBER Required
--  IN : p_exp_response_date   IN  DATE Required
--  IN : p_exp_resolution_date IN  DATE Required
--  IN : p_actual_response_date     IN DATE Required
--  IN : p_actual_resolution_date   IN DATE Required)

--- Returnvalue:
--  l_sr_jeopardy  VARCHAR2(10)
-- End of comments
-- --------------------------------------------------------------------------------

Function      GET_SR_JEOPARDY
  (  p_incident_id       IN NUMBER,
     p_exp_response_date     IN DATE,
     p_exp_resolution_date   IN DATE,
     p_actual_response_date     IN DATE,
     p_actual_resolution_date   IN DATE)
  RETURN  VARCHAR2;
--
-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_CALCULATED_TIME
--  Type        : Private
--  Description : Returns the Time in Days
--  Parameters  :
--  IN :  p_time     IN NUMBER   Required
--  IN :  p_UOM IN VARCHAR2 Required
--  ReturnValue:
-- l_calculated_time  NUMBER
-- --------------------------------------------------------------------------------

Function     GET_CALCULATED_TIME
( p_time IN NUMBER,
  p_UOM IN VARCHAR2)
  RETURN  NUMBER;
--
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_DEFAULT_SITE
--  Type        : Private
--  Description : Returns the primary billto/shipto address associated with this party
--  Parameters  :
--  IN :  partyId     IN NUMBER   Required
--  IN :  siteUse     IN VARCHAR2 Required
--  ReturnValue: primary billto/shipto address for this party
-- l_default_site VARCHAR2
-- ----------------------------------------------------------------------------
Function get_default_site
( partyId  in NUMBER
, site_use in VARCHAR2
) return VARCHAR2;
-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_DEFAULT_SITE
--  Type        : Private
--  Description : Returns the site use for primary billto/shipto address
--  Parameters  :
--  IN :  partyId     IN NUMBER   Required
--  IN :  site_use    IN VARCHAR2 Required
--  ReturnValue:
-- l_default_site  VARCHAR2
-- -------------------------------------------------------------------------
Function get_default_site_id
( partyId  in NUMBER
, site_use in VARCHAR2
) return NUMBER;
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_DEFAULT_SITE_ID
--  Type        : Private
--  Description : Returns the site Id for primary billto/shipto address
--  Parameters  :
--  IN :  partyId     IN NUMBER   Required
--  IN :  site_use    IN VARCHAR2 Required
--  ReturnValue:
-- l_default_site  NUMBER
-- -------------------------------------------------------------------------
procedure task_group_template_mismatch
( p_init_msg_list    in         varchar2   default fnd_api.g_false
, p_old_inv_category in         number
, p_new_inv_category in         number
, p_old_inv_item     in         number
, p_new_inv_item     in         number
, p_old_inc_type     in         number
, p_new_inc_type     in         number
, p_inv_org_id       in         number
, p_incident_id      in         number
, p_old_prob_code    in         varchar2
, p_new_prob_code    in         varchar2
, x_msg_count        out nocopy number
, x_return_status    out nocopy varchar2
, x_msg_data         out nocopy varchar2
);
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : task_group_template_mismatch
--  Type        : Private
--  Description : Checks if there is a mismatch in task group template when item,
--                item category, type, problem code change on updating a SR
-- -------------------------------------------------------------------------
procedure get_instance_details
( p_instance_id     in         number
, p_inc_type_id     in         number   default fnd_profile.value('INC_DEFAULT_INCIDENT_TYPE')
, p_severity_id     in         number   default fnd_profile.value('INC_DEFAULT_INCIDENT_SEVERITY')
, p_request_date    in         date     default sysdate
, p_timezone_id     in         number   default fnd_profile.value('SERVER_TIMEZONE_ID')
, p_get_contact     in         varchar2 default fnd_api.g_false
, x_contact_id      out nocopy number
, x_contact_type    out nocopy varchar2
, x_contract_id     out nocopy number
, x_contract_number out nocopy varchar2
, x_service_line_id out nocopy number
, x_coverage_term   out nocopy varchar2
, x_warranty_flag   out nocopy varchar2
, x_reaction_time   out nocopy date
, x_resolution_time out nocopy date
, x_service_desc    out nocopy varchar2
);
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : get_instance_details
--  Type        : Private
--  Description : gets the contact and contract given an instance, primarily
--                used for defaulting when instance is selected
-- -------------------------------------------------------------------------
--
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : get_linked_srs
--  Type        : Private
--  Description : gets list of linked srs (used in KM Unified search).
-- -------------------------------------------------------------------------
--
  FUNCTION get_linked_srs (p_incident_id IN NUMBER) RETURN VARCHAR2;

-- -------------------------------------------------------------------------
-- Start of comments
-- UTIL Name   : get_contact_info
-- Type        : Private
-- Description : To get the Contact info based on the Incident id, ContactPartyId,PartyId and ContactType, primarycontact
-- Parameters  :
-- IN:  p_incident_id IN  VARCHAR2  Required
-- IN:  p_contact_type IN  VARCHAR2
-- IN : p_contact_party_id     IN  NUMBER
-- IN : p_party_id     IN  NUMBER Required
-- IN : p_primary_contact     IN  NUMBER Required
-- Returnvalue:
-- l_contact_name  VARCHAR2(360)
-- End of comments
-- -------------------------------------------------------------------------
FUNCTION get_contact_info
( p_incident_id IN NUMBER
 ,p_contact_type IN VARCHAR2
 ,p_contact_party_id IN NUMBER
 ,p_party_id  IN NUMBER
 ,p_primary_contact IN VARCHAR2
) RETURN VARCHAR2;
--
-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_TIMEZONE_FOR_CONTACT
--  Type        : Private
--  Description : Returns the Timezone Id for a Contact/ContactPoint/Location.
--  Parameters  :
--  IN :  p_contact_type      IN VARCHAR2   Optional. If not passed assumed not an Employee
--  IN :  p_contact_point_id  IN Number  Optional
--  IN :  p_contact_id        IN Number  Optional
--  ReturnValue:
-- l_timezone_id  NUMBER
-- --------------------------------------------------------------------------------

Function     GET_TIMEZONE_FOR_CONTACT
( p_contact_type  IN VARCHAR2,
  p_contact_id  IN NUMBER,
  p_contact_point_id  IN NUMBER)
  RETURN VARCHAR2;
--
-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_TIMEZONE_FOR_LOCATION
--  Type        : Private
--  Description : Returns the Timezone Id for the contact's primary Location.
--  Parameters  :
 --  IN :  p_contact_id        IN Number  Optional
--  ReturnValue:
-- l_timezone_id  NUMBER
-- --------------------------------------------------------------------------------
Function     GET_TIMEZONE_FOR_LOCATION
(    p_contact_id  IN NUMBER)
  RETURN  NUMBER;
--
-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_FIRST_NOTE
--  Type        : Private
--  Description : Returns the recently created note associated to a Service Request
--  Parameters  :
 --  IN :  p_incident_id        IN Number Required
--  ReturnValue:
-- l_first_note  VARCHAR2(2000)
-- --------------------------------------------------------------------------------
Function  GET_FIRST_NOTE
(    p_incident_id  IN NUMBER)
  RETURN  VARCHAR2;
--
-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : CHECK_IF_NEXT_WORK_ENABLED
--  Type        : Private
--  Description : Checks if the UWQ profile options
--                 IEU_WR_DIST_MODE,IEU:Distribute:SR:Work Source
--                 are set and also Activation status is turned on.
--                 Return value is yes  if profile options are set properly.
--                 and activation status is turned on
-- -------------------------------------------------------------------------
   PROCEDURE CHECK_IF_NEXT_WORK_ENABLED
     ( p_ws_code               IN VARCHAR2,
      x_enable_next_work         OUT nocopy VARCHAR2,
	   x_msg_count                OUT nocopy NUMBER,
 	   x_return_status            OUT nocopy VARCHAR2,
	   x_msg_data                 OUT nocopy VARCHAR2);
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_NEXT_SR_TO_WORK
--  Type        : Private
--  Description : Calls  IEU_WR_PUB.GET_NEXT_WORK_FOR_APPS
--                and returns the incident_id retreived from the above call.
-- -------------------------------------------------------------------------
PROCEDURE GET_NEXT_SR_TO_WORK
      ( p_ws_code               IN VARCHAR2,
        p_resource_id           IN NUMBER,
        x_incident_id           OUT nocopy NUMBER,
        x_msg_count             OUT nocopy NUMBER,
        x_return_status         OUT nocopy VARCHAR2,
        x_msg_data              OUT nocopy VARCHAR2,
        x_object_type           OUT nocopy VARCHAR2);

--
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_SR_ESCALATED
--  Type        : Private
--  Description : Returns Y if Service Request is escalated, else returns N
--  Parameters  :
--  IN : p_incident_id    IN  NUMBER Required
--
--- Returnvalue:
--  l_sr_escalated  VARCHAR2(1)
-- End of comments
-- --------------------------------------------------------------------------
Function      GET_SR_ESCALATED
  (  p_incident_id       IN NUMBER
  )
  RETURN  VARCHAR2;
-- --------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_CONTACT_NAME
--  Type        : Private
--  Description : Returns contact name
--  Parameters  :
--  IN : p_incident_id    IN  NUMBER
--       p_customer_id    IN  NUMBER
--  Returnvalue: contact name
-- End of comments
-- -------------------------------------------------------------------------
Function      GET_CONTACT_NAME
  (  p_incident_id       IN NUMBER,
     p_customer_id       IN NUMBER
  )
RETURN  VARCHAR2;
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_REL_OBJ_DETAILS
--  Type        : Private
--  Description : Returns details of a related object
--  Parameters  :
--  IN : p_object_type      IN VARCHAR2
--       p_object_id        IN NUMBER
--  Returnvalue: details (summary) of a jtf object.
-- End of comments
-- -------------------------------------------------------------------------
FUNCTION GET_REL_OBJ_DETAILS
  (  p_object_type      IN VARCHAR2,
     p_object_id        IN NUMBER
  )
RETURN  VARCHAR2;
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : get_assc_party_name
--  Type        : Private
--  Description : Returns associated party name
--  Parameters  :
--  IN
--     p_assc_party_type IN VARCHAR2
--     p_assc_party_id  IN  NUMBER
-- End of comments
-- -------------------------------------------------------------------------
FUNCTION get_assc_party_name
( p_assc_party_type IN VARCHAR2
 ,p_assc_party_id  IN  NUMBER
) RETURN VARCHAR2;
-- -------------------------------------------------------------------------
FUNCTION get_concat_associated_role
( p_incident_id  IN  NUMBER
 ,p_party_id IN NUMBER
 ,p_party_type IN VARCHAR2)
RETURN VARCHAR2;
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : get_emp_contact_name
--  Type        : Private
--  Description : Returns employee contact name
--  Parameters  :
--  IN
--   p_person_id  IN  NUMBER
-- End of comments
-- -------------------------------------------------------------------------
FUNCTION get_emp_contact_name
(p_person_id  IN  NUMBER
) RETURN VARCHAR2;
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : get_emp_contact_email
--  Type        : Private
--  Description : Returns employee contact email
--  Parameters  :
--  IN
--   p_person_id  IN  NUMBER
-- End of comments
-- -------------------------------------------------------------------------
FUNCTION get_emp_contact_email
(p_person_id  IN  NUMBER
) RETURN VARCHAR2;
-- -------------------------------------------------------------------------
end csz_servicerequest_util_pvt;

 

/
