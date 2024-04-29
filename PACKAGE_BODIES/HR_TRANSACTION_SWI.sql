--------------------------------------------------------
--  DDL for Package Body HR_TRANSACTION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TRANSACTION_SWI" as
/* $Header: hrtrnswi.pkb 120.19.12010000.5 2009/12/04 10:12:11 pthoonig ship $ */
-- Global variables
   g_date_format varchar2(10) := 'RRRR/MM/DD';
   g_package  varchar2(33) := 'HR_TRANSACTION_SWI.';
   g_debug boolean := hr_utility.debug_enabled;
   g_tempClob CLOB;
   -- EO Api Map related global Variables
   g_current_EO_name    varchar2(160);
   g_current_EO_ApiName varchar2(160);
   -- EO Api Map related Associative Arrays indexed by BINARY_INTEGER for 8i Compatability
   TYPE eo_map_type IS TABLE of varchar2(160) INDEX BY BINARY_INTEGER;
   g_EO_Name_map eo_map_type;
   g_EO_ApiName_map eo_map_type;
   g_process_api_internal_error EXCEPTION;
   g_processing_EO_name VARCHAR2(1000);
   g_processing_EO_cdatavalue VARCHAR2(1000);


--
-- ---------------------------------------------------------------------- --
-- -----------------------<create_transaction>--------------------------- --
-- ---------------------------------------------------------------------- --
--

procedure create_transaction
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_CREATOR_PERSON_ID               IN       NUMBER
 ,P_TRANSACTION_PRIVILEGE           IN       VARCHAR2
 ,P_PRODUCT_CODE                    IN       VARCHAR2   DEFAULT NULL
 ,P_URL                             IN       LONG       DEFAULT NULL
 ,P_STATUS                          IN       VARCHAR2   DEFAULT NULL
 ,P_SECTION_DISPLAY_NAME            IN       VARCHAR2   DEFAULT NULL
 ,P_FUNCTION_ID                     IN       NUMBER     DEFAULT NULL
 ,P_TRANSACTION_REF_TABLE           IN       VARCHAR2   DEFAULT NULL
 ,P_TRANSACTION_REF_ID              IN       NUMBER     DEFAULT NULL
 ,P_TRANSACTION_TYPE                IN       VARCHAR2   DEFAULT NULL
 ,P_ASSIGNMENT_ID                   IN       NUMBER     DEFAULT NULL
 ,P_API_ADDTNL_INFO                 IN       VARCHAR2   DEFAULT NULL
 ,P_SELECTED_PERSON_ID              IN       NUMBER     DEFAULT NULL
 ,P_ITEM_TYPE                       IN       VARCHAR2   DEFAULT NULL
 ,P_ITEM_KEY                        IN       VARCHAR2   DEFAULT NULL
 ,P_TRANSACTION_EFFECTIVE_DATE      IN       DATE       DEFAULT NULL
 ,P_PROCESS_NAME                    IN       VARCHAR2   DEFAULT NULL
 ,P_TRANSACTION_STATE               IN       VARCHAR2   DEFAULT NULL
 ,P_EFFECTIVE_DATE_OPTION           IN       VARCHAR2   DEFAULT NULL
 ,P_RPTG_GRP_ID                     IN       NUMBER     DEFAULT NULL
 ,P_PLAN_ID                         IN       NUMBER     DEFAULT NULL
 ,P_CREATOR_ROLE                    IN       VARCHAR2  DEFAULT NULL
 ,P_LAST_UPDATE_ROLE                IN       VARCHAR2  DEFAULT NULL
 ,P_PARENT_TRANSACTION_ID           IN       NUMBER    DEFAULT NULL
 ,P_RELAUNCH_FUNCTION               IN       VARCHAR2   DEFAULT NULL
 ,P_TRANSACTION_GROUP               IN       VARCHAR2   DEFAULT NULL
 ,P_TRANSACTION_IDENTIFIER          IN       VARCHAR2   DEFAULT NULL
 ,P_TRANSACTION_DOCUMENT            IN       CLOB       DEFAULT NULL
 ,P_VALIDATE                        IN       NUMBER     default hr_api.g_false_num
)
is

    l_TRANSACTION_ID hr_api_transactions.TRANSACTION_ID%type;
    l_creator_role hr_api_transactions.creator_role%type;
    l_last_update_role hr_api_transactions.last_update_role%type;


    PRAGMA AUTONOMOUS_TRANSACTION;
begin
   --savepoint create_transaction;
   l_creator_role := nvl(P_CREATOR_ROLE, 'PER:' || fnd_global.employee_id);
   l_last_update_role := nvl(P_LAST_UPDATE_ROLE, 'PER:' || fnd_global.employee_id);



   l_TRANSACTION_ID := P_TRANSACTION_ID;
   hr_trn_ins.set_base_key_value(l_TRANSACTION_ID);
   hr_trn_ins.ins(
                p_validate               => false
               ,p_creator_person_id      => p_creator_person_id
               ,p_transaction_privilege  => P_TRANSACTION_PRIVILEGE
               ,p_transaction_id         => l_TRANSACTION_ID
               ,p_product_code => p_product_code
               ,p_url=> p_url
               ,p_status=>P_STATUS
               ,p_section_display_name=>P_SECTION_DISPLAY_NAME
               ,p_function_id=>P_FUNCTION_ID
               ,p_transaction_ref_table=>p_transaction_ref_table
               ,p_transaction_ref_id=>p_transaction_ref_id
               ,p_transaction_type=>P_TRANSACTION_TYPE
               ,p_assignment_id=>P_ASSIGNMENT_ID
               ,p_selected_person_id=>P_SELECTED_PERSON_ID
               ,p_item_type=>P_ITEM_TYPE
               ,p_item_key=>P_ITEM_KEY
               ,p_transaction_effective_date=>P_TRANSACTION_EFFECTIVE_DATE
               ,p_process_name=>P_PROCESS_NAME
               ,p_plan_id=>p_plan_id
               ,p_rptg_grp_id=>p_rptg_grp_id
               ,p_effective_date_option=>p_effective_date_option
               ,p_api_addtnl_info=>p_api_addtnl_info
               ,p_creator_role  =>l_creator_role
               ,p_last_update_role =>l_last_update_role
               ,p_parent_transaction_id => p_parent_transaction_id
	           ,p_relaunch_function => p_relaunch_function
               ,p_transaction_group   => p_transaction_group
               ,p_transaction_identifier => p_transaction_identifier
	           ,p_transaction_document => p_transaction_document



);
    If P_VALIDATE = hr_api.g_false_num Then
      commit;
    Else
      rollback;
    End If;
exception
    when OTHERS then
        rollback; -- to create_transaction;
end create_transaction;

--
-- ---------------------------------------------------------------------- --
-- --------------------<create_transaction_step>------------------------- --
-- ---------------------------------------------------------------------- --
--

procedure create_transaction_step
(
  P_API_NAME                  IN             VARCHAR2
 ,P_API_DISPLAY_NAME          IN             VARCHAR2  DEFAULT NULL
 ,P_PROCESSING_ORDER          IN             NUMBER
 ,P_ITEM_TYPE                 IN             VARCHAR2  DEFAULT NULL
 ,P_ITEM_KEY                  IN             VARCHAR2  DEFAULT NULL
 ,P_ACTIVITY_ID               IN             NUMBER    DEFAULT NULL
 ,P_CREATOR_PERSON_ID         IN             NUMBER
 ,P_UPDATE_PERSON_ID          IN             NUMBER    DEFAULT NULL
 ,P_OBJECT_TYPE               IN            VARCHAR2  DEFAULT NULL
 ,P_OBJECT_NAME               IN             VARCHAR2  DEFAULT NULL
 ,P_OBJECT_IDENTIFIER         IN             VARCHAR2  DEFAULT NULL
 ,P_OBJECT_STATE              IN            VARCHAR2  DEFAULT NULL
 ,P_PK1                       IN             VARCHAR2  DEFAULT NULL
 ,P_PK2                       IN             VARCHAR2  DEFAULT NULL
 ,P_PK3                       IN             VARCHAR2  DEFAULT NULL
 ,P_PK4                       IN             VARCHAR2  DEFAULT NULL
 ,P_PK5                       IN             VARCHAR2  DEFAULT NULL
 ,P_VALIDATE                  IN             NUMBER    DEFAULT hr_api.g_false_num
 ,P_OBJECT_VERSION_NUMBER     IN OUT nocopy  NUMBER
 ,P_TRANSACTION_ID            IN             NUMBER
 ,P_TRANSACTION_STEP_ID       IN             NUMBER
 ,p_information_category        in	     VARCHAR2   default null
 ,p_information1                in             VARCHAR2   default null
 ,p_information2                in             VARCHAR2   default null
 ,p_information3                in             VARCHAR2   default null
 ,p_information4                in             VARCHAR2   default null
 ,p_information5                in             VARCHAR2   default null
 ,p_information6                in             VARCHAR2   default null
 ,p_information7                in             VARCHAR2   default null
 ,p_information8                in             VARCHAR2   default null
 ,p_information9                in             VARCHAR2   default null
 ,p_information10               in             VARCHAR2   default null
 ,p_information11               in             VARCHAR2   default null
 ,p_information12               in             VARCHAR2   default null
 ,p_information13               in             VARCHAR2   default null
 ,p_information14               in             VARCHAR2   default null
 ,p_information15               in             VARCHAR2   default null
 ,p_information16               in             VARCHAR2   default null
 ,p_information17               in             VARCHAR2   default null
 ,p_information18               in             VARCHAR2   default null
 ,p_information19               in             VARCHAR2   default null
 ,p_information20               in             VARCHAR2   default null
 ,p_information21               in             VARCHAR2   default null
 ,p_information22               in             VARCHAR2   default null
 ,p_information23               in             VARCHAR2   default null
 ,p_information24               in             VARCHAR2   default null
 ,p_information25               in             VARCHAR2   default null
 ,p_information26               in             VARCHAR2   default null
 ,p_information27               in             VARCHAR2   default null
 ,p_information28               in             VARCHAR2   default null
 ,p_information29               in             VARCHAR2   default null
 ,p_information30               in             VARCHAR2   default null

)
is
    l_proc varchar2(72) := g_package || 'create_transaction_step';
    l_result         varchar2(100);
    l_trns_object_version_number number;
    l_transaction_step_id hr_api_transaction_steps.transaction_step_id%type;
    PRAGMA AUTONOMOUS_TRANSACTION;
begin
  --savepoint create_transaction_step;
  l_transaction_step_id := P_TRANSACTION_STEP_ID;
  hr_trs_ins.set_base_key_value(l_transaction_step_id);
  hr_trs_ins.ins
  (
     p_transaction_step_id            =>           l_transaction_step_id,
     p_transaction_id                 =>           p_transaction_id,
     p_api_name                       =>           p_api_name,
     p_api_display_name               =>           p_api_display_name,
     p_processing_order               =>           p_processing_order,
     p_item_type                      =>           p_item_type,
     p_item_key                       =>           p_item_key,
     p_activity_id                    =>           p_activity_id,
     p_creator_person_id              =>           p_creator_person_id,
     p_update_person_id               =>           p_update_person_id,
     p_object_version_number          =>           p_object_version_number ,
     p_OBJECT_TYPE                    =>           p_OBJECT_TYPE,
     p_OBJECT_NAME                    =>           p_OBJECT_NAME,
     p_OBJECT_IDENTIFIER              =>           p_OBJECT_IDENTIFIER,
     p_OBJECT_STATE                   =>           p_OBJECT_STATE,
     p_PK1                            =>           p_PK1,
     p_PK2                            =>           p_PK2,
     p_PK3                            =>           p_PK3,
     p_PK4                            =>           p_PK4,
     p_PK5                            =>           p_PK5,
     p_information_category             =>           p_information_category,
     p_information1                     =>           p_information1,
     p_information2                     =>           p_information2,
     p_information3                     =>           p_information3,
     p_information4                     =>           p_information4,
     p_information5                     =>           p_information5,
     p_information6                     =>           p_information6,
     p_information7                     =>           p_information7,
     p_information8                     =>           p_information8,
     p_information9                     =>           p_information9,
     p_information10                    =>           p_information10,
     p_information11                    =>           p_information11,
     p_information12                    =>           p_information12,
     p_information13                    =>           p_information13,
     p_information14                    =>           p_information14,
     p_information15                    =>           p_information15,
     p_information16                    =>           p_information16,
     p_information17                    =>           p_information17,
     p_information18                    =>           p_information18,
     p_information19                    =>           p_information19,
     p_information20                    =>           p_information20,
     p_information21                    =>           p_information21,
     p_information22                    =>           p_information22,
     p_information23                    =>           p_information23,
     p_information24                    =>           p_information24,
     p_information25                    =>           p_information25,
     p_information26                    =>           p_information26,
     p_information27                    =>           p_information27,
     p_information28                    =>           p_information28,
     p_information29                    =>           p_information29,
     p_information30                    =>           p_information30,
     p_validate                       =>           false
   );
   If P_VALIDATE = hr_api.g_false_num Then
      commit;
    Else
      rollback;
    End If;
exception
    when OTHERS then
        rollback ;--to create_transaction_step;
        raise;
end create_transaction_step;

procedure update_transaction
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_CREATOR_PERSON_ID               IN       NUMBER
 ,P_TRANSACTION_PRIVILEGE           IN       VARCHAR2
 ,P_PRODUCT_CODE                    IN       VARCHAR2   DEFAULT NULL
 ,P_URL                             IN       LONG       DEFAULT NULL
 ,P_STATUS                          IN       VARCHAR2   DEFAULT NULL
 ,P_SECTION_DISPLAY_NAME            IN       VARCHAR2   DEFAULT NULL
 ,P_FUNCTION_ID                     IN       NUMBER     DEFAULT NULL
 ,P_TRANSACTION_REF_TABLE           IN       VARCHAR2   DEFAULT NULL
 ,P_TRANSACTION_REF_ID              IN       NUMBER     DEFAULT NULL
 ,P_TRANSACTION_TYPE                IN       VARCHAR2   DEFAULT NULL
 ,P_ASSIGNMENT_ID                   IN       NUMBER     DEFAULT NULL
 ,P_API_ADDTNL_INFO                 IN       VARCHAR2   DEFAULT NULL
 ,P_SELECTED_PERSON_ID              IN       NUMBER     DEFAULT NULL
 ,P_ITEM_TYPE                       IN       VARCHAR2   DEFAULT NULL
 ,P_ITEM_KEY                        IN       VARCHAR2   DEFAULT NULL
 ,P_TRANSACTION_EFFECTIVE_DATE      IN       DATE       DEFAULT NULL
 ,P_PROCESS_NAME                    IN       VARCHAR2   DEFAULT NULL
 ,P_TRANSACTION_STATE               IN       VARCHAR2   DEFAULT NULL
 ,P_EFFECTIVE_DATE_OPTION           IN       VARCHAR2   DEFAULT NULL
 ,P_RPTG_GRP_ID                     IN       NUMBER     DEFAULT NULL
 ,P_PLAN_ID                         IN       NUMBER     DEFAULT NULL
 ,P_CREATOR_ROLE                    IN       VARCHAR2   DEFAULT NULL
 ,P_LAST_UPDATE_ROLE                IN       VARCHAR2   DEFAULT NULL
 ,P_PARENT_TRANSACTION_ID           IN       NUMBER     DEFAULT NULL
 ,P_RELAUNCH_FUNCTION               IN       VARCHAR2   DEFAULT NULL
 ,P_TRANSACTION_GROUP               IN       VARCHAR2   DEFAULT NULL
 ,P_TRANSACTION_IDENTIFIER          IN       VARCHAR2   DEFAULT NULL
 ,P_TRANSACTION_DOCUMENT            IN       CLOB       DEFAULT NULL
 ,P_VALIDATE                        IN       NUMBER     default hr_api.g_false_num
)
is
    l_proc varchar2(72) := 'update_transaction';
    l_last_update_role hr_api_transactions.last_update_role%type;
    PRAGMA AUTONOMOUS_TRANSACTION;
begin
   --savepoint update_transaction;
   l_last_update_role := nvl(P_LAST_UPDATE_ROLE, 'PER:' || fnd_global.employee_id);
   hr_trn_upd.upd(
                p_validate               => false
               ,p_creator_person_id      => p_creator_person_id
               ,p_transaction_privilege  => P_TRANSACTION_PRIVILEGE
               ,p_transaction_id         => p_TRANSACTION_ID
               ,p_product_code => p_product_code
               ,p_url=> p_url
               ,p_status=>P_STATUS
               ,p_section_display_name=>P_SECTION_DISPLAY_NAME
               ,p_function_id=>P_FUNCTION_ID
               ,p_transaction_ref_table=>p_transaction_ref_table
               ,p_transaction_ref_id=>p_transaction_ref_id
               ,p_transaction_type=>P_TRANSACTION_TYPE
               ,p_assignment_id=>P_ASSIGNMENT_ID
               ,p_selected_person_id=>P_SELECTED_PERSON_ID
               ,p_item_type=>P_ITEM_TYPE
               ,p_item_key=>P_ITEM_KEY
               ,p_transaction_effective_date=>P_TRANSACTION_EFFECTIVE_DATE
               ,p_process_name=>P_PROCESS_NAME
               ,p_plan_id=>p_plan_id
               ,p_rptg_grp_id=>p_rptg_grp_id
               ,p_effective_date_option=>p_effective_date_option
               ,p_api_addtnl_info=>p_api_addtnl_info
               ,p_creator_role  =>p_creator_role
               ,p_last_update_role =>l_last_update_role
               ,p_parent_transaction_id => p_parent_transaction_id
	           ,p_relaunch_function => p_relaunch_function
               ,p_transaction_group   => p_transaction_group
               ,p_transaction_identifier => p_transaction_identifier
               ,p_transaction_document => p_transaction_document
               ,p_transaction_state    => p_transaction_state -- Heena
	       );
   If P_VALIDATE = hr_api.g_false_num Then
      commit;
    Else
      rollback;
    End If;
exception
    when OTHERS then
        rollback ;--to update_transaction;
end update_transaction;

--
-- ---------------------------------------------------------------------- --
-- --------------------<create_transaction_step>------------------------- --
-- ---------------------------------------------------------------------- --
--

procedure update_transaction_step
(
  P_API_NAME                  IN             VARCHAR2
 ,P_API_DISPLAY_NAME          IN             VARCHAR2  DEFAULT NULL
 ,P_PROCESSING_ORDER          IN             NUMBER
 ,P_ITEM_TYPE                 IN             VARCHAR2  DEFAULT NULL
 ,P_ITEM_KEY                  IN             VARCHAR2  DEFAULT NULL
 ,P_ACTIVITY_ID               IN             NUMBER    DEFAULT NULL
 ,P_CREATOR_PERSON_ID         IN             NUMBER
 ,P_UPDATE_PERSON_ID          IN             NUMBER    DEFAULT NULL
 ,P_OBJECT_TYPE               IN             VARCHAR2  DEFAULT NULL
 ,P_OBJECT_NAME               IN             VARCHAR2  DEFAULT NULL
 ,P_OBJECT_IDENTIFIER         IN             VARCHAR2  DEFAULT NULL
 ,P_OBJECT_STATE              IN             VARCHAR2  DEFAULT NULL
 ,P_PK1                       IN             VARCHAR2    DEFAULT NULL
 ,P_PK2                       IN             VARCHAR2    DEFAULT NULL
 ,P_PK3                       IN             VARCHAR2    DEFAULT NULL
 ,P_PK4                       IN             VARCHAR2    DEFAULT NULL
 ,P_PK5                       IN             VARCHAR2    DEFAULT NULL
 ,P_VALIDATE                  IN             NUMBER     default hr_api.g_false_num
 ,P_OBJECT_VERSION_NUMBER     IN OUT nocopy  NUMBER
 ,P_TRANSACTION_ID            IN             NUMBER
 ,P_TRANSACTION_STEP_ID       IN             NUMBER
 ,p_information_category        in	     VARCHAR2   default hr_api.g_varchar2
 ,p_information1                in             VARCHAR2   default hr_api.g_varchar2
 ,p_information2                in             VARCHAR2   default hr_api.g_varchar2
 ,p_information3                in             VARCHAR2   default hr_api.g_varchar2
 ,p_information4                in             VARCHAR2   default hr_api.g_varchar2
 ,p_information5                in             VARCHAR2   default hr_api.g_varchar2
 ,p_information6                in             VARCHAR2   default hr_api.g_varchar2
 ,p_information7                in             VARCHAR2   default hr_api.g_varchar2
 ,p_information8                in             VARCHAR2   default hr_api.g_varchar2
 ,p_information9                in             VARCHAR2   default hr_api.g_varchar2
 ,p_information10               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information11               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information12               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information13               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information14               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information15               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information16               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information17               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information18               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information19               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information20               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information21               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information22               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information23               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information24               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information25               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information26               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information27               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information28               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information29               in             VARCHAR2   default hr_api.g_varchar2
 ,p_information30               in             VARCHAR2   default hr_api.g_varchar2
)
is
    l_proc varchar2(72) := 'update_transaction_step';
    l_result         varchar2(100);
    PRAGMA AUTONOMOUS_TRANSACTION;
begin
  --savepoint update_transaction_step;
  hr_trs_upd.upd
  (
     p_transaction_step_id            =>           p_transaction_step_id,
     p_transaction_id                 =>           p_transaction_id,
     p_api_name                       =>           p_api_name,
     p_api_display_name               =>           p_api_display_name,
     p_processing_order               =>           p_processing_order,
     p_item_type                      =>           p_item_type,
     p_item_key                       =>           p_item_key,
     p_activity_id                    =>           p_activity_id,
     p_creator_person_id              =>           p_creator_person_id,
     p_update_person_id               =>           p_update_person_id,
     p_object_version_number          =>           p_object_version_number ,
     p_OBJECT_TYPE                    =>           p_OBJECT_TYPE,
     p_OBJECT_NAME                    =>           p_OBJECT_NAME,
     p_OBJECT_IDENTIFIER              =>           p_OBJECT_IDENTIFIER,
     p_OBJECT_STATE                   =>           p_OBJECT_STATE,
     p_PK1                            =>           p_PK1,
     p_PK2                            =>           p_PK2,
     p_PK3                            =>           p_PK3,
     p_PK4                            =>           p_PK4,
     p_PK5                            =>           p_PK5,
     p_information_category             =>           p_information_category,
     p_information1                     =>           p_information1,
     p_information2                     =>           p_information2,
     p_information3                     =>           p_information3,
     p_information4                     =>           p_information4,
     p_information5                     =>           p_information5,
     p_information6                     =>           p_information6,
     p_information7                     =>           p_information7,
     p_information8                     =>           p_information8,
     p_information9                     =>           p_information9,
     p_information10                    =>           p_information10,
     p_information11                    =>           p_information11,
     p_information12                    =>           p_information12,
     p_information13                    =>           p_information13,
     p_information14                    =>           p_information14,
     p_information15                    =>           p_information15,
     p_information16                    =>           p_information16,
     p_information17                    =>           p_information17,
     p_information18                    =>           p_information18,
     p_information19                    =>           p_information19,
     p_information20                    =>           p_information20,
     p_information21                    =>           p_information21,
     p_information22                    =>           p_information22,
     p_information23                    =>           p_information23,
     p_information24                    =>           p_information24,
     p_information25                    =>           p_information25,
     p_information26                    =>           p_information26,
     p_information27                    =>           p_information27,
     p_information28                    =>           p_information28,
     p_information29                    =>           p_information29,
     p_information30                    =>           p_information30,
     p_validate                       =>           false
   );
   If P_VALIDATE = hr_api.g_false_num Then
      commit;
    Else
      rollback;
    End If;
exception
    when OTHERS then
        rollback ;--to update_transaction_step;
end update_transaction_step;

procedure delete_transaction_step
(  p_transaction_step_id           in      number
  ,p_person_id                    in      number
  ,p_object_version_number        in      number
  ,p_validate                     in      number    default hr_api.g_false_num
) is
  --
  l_proc constant varchar2(100) := g_package || ' delete_transaction_step';
  PRAGMA AUTONOMOUS_TRANSACTION;
begin
  hr_transaction_api.delete_transaction_step
  (
    p_validate                     =>  false
   ,p_transaction_step_id          =>  p_transaction_step_id
   ,p_person_id                    =>  p_person_id
   ,p_object_version_number        =>  p_object_version_number
  );
  If p_validate = hr_api.g_false_num Then
    commit;
  Else
    rollback;
  End If;
exception
    when OTHERS then
        rollback ;--to update_transaction_step;
        raise;
end delete_transaction_step;

Function getAttributeValue(
  p_commitNode in xmldom.DOMNode,
  p_tagName in VARCHAR2,
  p_attributeName in VARCHAR2)
  return VARCHAR2 IS

  x_isNull VARCHAR2(22);
  l_tagName_NodeList xmldom.DOMNodeList;
  l_tagName_Node xmldom.DOMNode;
  l_proc    varchar2(72) := g_package || 'getNumberValue';

Begin
 --1. Navigate to the tagName
 x_isNull := null;

 l_tagName_NodeList  := xmldom.getChildrenByTagName(xmldom.makeElement(p_commitNode),p_tagName);
  if (xmldom.getLength(l_tagName_NodeList) > 0)  then
 --2. See if this tagName has a associated null=true attribute-value pair
   l_tagName_Node := xmldom.item(l_tagName_NodeList,0);
   x_isNull := xmldom.getAttribute(xmldom.makeElement(l_tagName_Node), p_attributeName);
  end if;
  return x_isNull;
  exception
    when OTHERS then
      return x_isNull;

end getAttributeValue;



Function getDateValue(
  commitNode in xmldom.DOMNode,
  attributeName in VARCHAR2,
  gmisc_value in date default hr_api.g_date)
  return DATE IS
  l_date DATE;
  l_isNull VARCHAR2(10);
  l_string VARCHAR2(100);
  l_element xmldom.DOMElement;
  l_proc    varchar2(72) := g_package || 'getDateValue';
  l_pos number;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);

  xslprocessor.valueof(commitNode,attributeName,l_string);
  l_pos := instr(l_string, ' ', 1);
  if(l_pos <> 0) then
    l_string := substr(l_string,1,l_pos-1);
  end if;
  l_date := TO_DATE(l_string,'RRRR-MM-DD');
  l_element := xmldom.makeElement(commitNode);
  --l_isNull := xmldom.getAttribute(l_element, 'null');
  l_isNull := getAttributeValue (commitNode,attributeName,'null');
  if l_isNull = 'true' then
    l_date := NULL;
  else
    l_date := NVL(l_date, gmisc_value);
  end if;
  hr_utility.set_location(' Exiting :' || l_proc,15);
  return l_date;
End getDateValue;

Function getVarchar2Value(
  commitNode in xmldom.DOMNode,
  attributeName in VARCHAR2,
  gmisc_value in varchar2 default hr_api.g_varchar2)
  return varchar2 IS
  l_varchar2 VARCHAR2(4000);
  l_isNull VARCHAR2(10);
  l_element xmldom.DOMElement;
  l_proc    varchar2(72) := g_package || 'getVarchar2Value';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  xslprocessor.valueof(commitNode,attributeName,l_varchar2);
  l_element := xmldom.makeElement(commitNode);
  -- l_isNull := xmldom.getAttribute(l_element, 'null');
  l_isNull := getAttributeValue (commitNode,attributeName,'null');
  if l_isNull = 'true' then
    l_varchar2 := NULL;
  else
    l_varchar2 := NVL(l_varchar2, gmisc_value);
  end if;
  hr_utility.set_location(' Exiting :' || l_proc,15);
  return l_varchar2;
End getVarchar2Value;

Function getNumberValue(
  commitNode in xmldom.DOMNode,
  attributeName in VARCHAR2,
  gmisc_value in number default hr_api.g_number)
  return NUMBER IS
  l_number NUMBER;
  l_isNull VARCHAR2(22);
  l_element xmldom.DOMElement;
  l_proc    varchar2(72) := g_package || 'getNumberValue';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --Fix for Bug 7712861
  --xslprocessor.valueof(commitNode,attributeName,l_number);
  if(xslprocessor.valueof(commitNode,attributeName) is not NULL) then
  l_number := fnd_number.canonical_to_number(xslprocessor.valueof(commitNode,attributeName));
  end if;
  l_element := xmldom.makeElement(commitNode);
 -- l_isNull := xmldom.getAttribute(l_element, 'null');
 l_isNull := getAttributeValue (commitNode,attributeName,'null');
  if l_isNull = 'true' then
    l_number := NULL;
  else
    l_number := NVL(l_number, gmisc_value);
  end if;
  hr_utility.set_location(' Exiting :' || l_proc,15);
  return l_number;
End getNumberValue;

Function get_EO_api_name(
 p_EO_Name in varchar2)
 return varchar2 is
 x_EO_ApiName varchar2(100);
Begin
 x_EO_ApiName :=null;

 if p_EO_Name = g_current_EO_name then
   x_EO_ApiName := g_current_EO_ApiName;
 else
   -- Go into searching the parallel Arrays only when
   -- g_current_EO_name does not match the p_EO_Name
   for i in 1..g_EO_Name_map.count loop
     if g_EO_Name_map(i) = p_EO_Name then
       -- When the EO Name matches return the API Name from the corresponding
       -- Parallel Associative Array => g_EO_ApiName_map
       x_EO_ApiName:= g_EO_ApiName_map(i);
       -- Store the match in the package level EO Name , EO Api Name varibales
       -- So that if the next request too is for the same EO we neednot iterate
       -- through the associative Arrays.
       g_current_EO_name    := p_EO_Name;
       g_current_EO_ApiName := x_EO_ApiName;
       exit;
     end if;
   end loop;
 end if ;
 -- The value in x_EO_ApiName would be returned.
 return x_EO_ApiName;
End get_EO_api_name;



Function process_api_internal(
  p_transaction_id in number,
  p_root_node in xmldom.DOMNode,
  p_validate in number default hr_api.g_false_num,
  p_effective_date in DATE,
  p_return_status in varchar2)
  return VARCHAR2 IS

  cursor csr_hat_steps(p_Api_Name in varchar2) is
    select *
    from hr_api_transaction_steps
    where transaction_id=p_transaction_id
    and  API_NAME = p_Api_Name
    and  OBJECT_TYPE is null;

  l_procapi_retstat_out VARCHAR2(1);
  l_EO_Name varchar2(1000);
  l_sqlbuf varchar2(1000);
  l_EO_api_name varchar2(100);
  l_CEO_Node_Element xmldom.DOMElement;
  l_EORowNode xmldom.DOMNode;
  l_child_EO_Node xmldom.DOMNode;
  l_CEO_NodeList xmldom.DOMNodeList;
  l_child_EO_NodeList xmldom.DOMNodeList;
--  l_CLOB CLOB;
  x_current_status varchar2(1);
  l_proc    varchar2(72) := g_package || 'process_api_internal';
  l_CDATANode xmldom.DOMNode;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);

  -- Get the ApiName fromt he EO node
  l_EO_Name := xmldom.getAttribute(xmldom.makeElement(p_root_node),'Name');
  --l_EO_api_name	:= NULL; --g_api_map(l_EO_Name);
  l_EO_api_name	:= get_EO_api_name(l_EO_Name);
  if l_EO_api_name is not NULL then
      -- From the Root Node Get the EORow Node,which is a sibiling to the  CDATA node
      l_EORowNode		:= xmldom.getNextSibling(xmldom.getFirstChild(p_root_node));
      -- Set the Return Status to the default value
      l_procapi_retstat_out := 'S';
      -- Set the return value to the return value got from the calling funtion
      x_current_status := p_return_status;

      -- set the global g_processing_EO_name for error logging
     g_processing_EO_name :=l_EO_Name;
     -- From the Root Node Get the EORow Node,which is a sibiling to the  CDATA node
      l_CDATANode    := xmldom.getFirstChild(p_root_node);
      g_processing_EO_cdatavalue := xmldom.getNodeValue(l_CDATANode);

     -- Make a CLOB out of the root_node for binding purposes
      hr_utility.set_location('Making the CLOB:' || l_proc,15);
      DBMS_LOB.createTemporary(g_tempClob, FALSE);
      --  DBMS_LOB.createTemporary(g_tempClob, FALSE);
      xmldom.writeToClob(l_EORowNode,g_tempClob);

      hr_utility.set_location('Building the Dynamic Procedure call:' || l_proc,20);
--      if l_EO_api_name = 'HR_PROCESS_PERSON_SS.PROCESS_API' or l_EO_api_name = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API' then
--        open csr_hat_steps(l_EO_api_name);
--        if csr_hat_steps%NOTFOUND then
            l_sqlbuf:= 'begin ' || l_EO_api_name
                 || ' (p_document => :1 '
                 || ' ,p_return_status => :2 '
                 || ' ,p_validate =>  :3 '
                 || ' ,p_effective_date => :4); end; ';
           EXECUTE IMMEDIATE l_sqlbuf using in g_tempClob, out l_procapi_retstat_out, in p_validate, in p_effective_date  ;
--        else
--           l_procapi_retstat_out := 'S';
--        end if;
--        close csr_hat_steps;
--      end if; -- End of checking if EOAPI Name is person/asg

      -- Free the CLOB
      -- Make the call to set_status to set the current_return Status
      x_current_status:=set_status(x_current_status,l_procapi_retstat_out);

      DBMS_LOB.freetemporary(g_tempClob);

      IF(l_procapi_retstat_out = 'E') THEN
         hr_utility.set_location(' Error processing with api call '||l_EO_api_name || l_proc,50);
         RAISE g_process_api_internal_error;
      END IF;

      hr_utility.set_location(' Convert RowNode into Element:' || l_proc,20);
      -- Convert RowNode into Element and get the list of Child EO Nodes if any
      l_CEO_NodeList	:=xmldom.getChildrenByTagName(xmldom.makeElement(l_EORowNode),'CEO');

      if (xmldom.getLength(l_CEO_NodeList) > 0)  then
	    hr_utility.set_location('Child Nodes Exist :' || l_proc,25);
        l_CEO_Node_Element	:=xmldom.makeElement(xmldom.item(l_CEO_NodeList,0));
	    l_child_EO_NodeList	:=xmldom.getChildrenByTagName(l_CEO_Node_Element,'EO');

    	hr_utility.set_location('Entering For Loop for Child Nodes :' || l_proc,30);
        for i in 1..xmldom.getLength(l_child_EO_NodeList) loop
	           l_child_EO_Node := xmldom.item(l_child_EO_NodeList,i-1);
	           x_current_status:=process_api_internal(p_transaction_id, l_child_EO_Node,p_validate,p_effective_date,x_current_status);
	    end loop;
        hr_utility.set_location('End of For Loop :' || l_proc,35);
      end if;
  end if; -- if EO API NAME IS NOT NULL
  hr_utility.set_location('Exiting:' || l_proc,40);
  return x_current_status;
End process_api_internal;



Function process_api_call(
  p_transaction_step_id in NUMBER,
  p_api_name in VARCHAR2,
  p_root_node in xmldom.DOMNode,
  p_validate in number default hr_api.g_false_num,
  p_effective_date in DATE,
  p_return_status in varchar2)
  return VARCHAR2 IS
  l_procapi_retstat_out VARCHAR2(1);
  l_sqlbuf varchar2(1000);
  l_EO_api_name varchar2(100);
  l_EORowNode xmldom.DOMNode;
--  l_CLOB CLOB;
  x_current_status varchar2(1);
  l_proc    varchar2(72) := g_package || 'process_api_call';

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);

  -- Get the ApiName from the parameter
  l_EO_api_name	:= p_api_name;
  if(xmlDOM.isNull(p_root_node)=false) then
      -- From the Root Node Get the EORow Node,which is a sibiling to the  CDATA node
      l_EORowNode		:= xmldom.getNextSibling(xmldom.getFirstChild(p_root_node));
  end if;
  -- Set the Return Status to the default value
  l_procapi_retstat_out := 'N';
  -- Set the return value to the return value got from the calling funtion
  x_current_status := p_return_status;


 -- Make a CLOB out of the root_node for binding purposes
  if(xmlDOM.isNull(l_EORowNode)=false) then
      hr_utility.set_location('Making the CLOB:' || l_proc,15);
      DBMS_LOB.createTemporary(g_tempClob, FALSE);
      xmldom.writeToClob(l_EORowNode,g_tempClob);
  end if;


  hr_utility.set_location('Building the Dynamic Procedure call:' || l_proc,20);
  if (xmldom.isNull(p_root_node)=false) then
  l_sqlbuf:= 'begin ' || l_EO_api_name ||
                 '(p_transaction_step_id => :1
                 ,p_document => :2
                 ,p_return_status => :3
                 ,p_validate =>  :4
                 ,p_effective_date => :5); end;';
      EXECUTE IMMEDIATE l_sqlbuf using in p_transaction_step_id, in g_tempClob, out l_procapi_retstat_out, in p_validate, in p_effective_date  ;
  else
      l_sqlbuf:= 'begin ' || l_EO_api_name ||
                     '(p_transaction_step_id => :1
                     ,p_return_status => :2
                     ,p_validate =>  :3
                     ,p_effective_date => :4); end;';
      EXECUTE IMMEDIATE l_sqlbuf using in p_transaction_step_id,  out l_procapi_retstat_out, in p_validate, in p_effective_date  ;
  DBMS_LOB.freetemporary(g_tempClob);
  end if;

  -- Free the CLOB
  -- Make the call to set_status to set the current_return Status
  x_current_status:=set_status(x_current_status,l_procapi_retstat_out);

  hr_utility.set_location('Exiting:' || l_proc,25);
  return x_current_status;

End process_api_call;

Function set_status(
  p_curent_status in VARCHAR2,
  p_dyn_sql_processapi_sts in VARCHAR2)
  return VARCHAR2 IS
  x_return_status varchar2(1);
  l_proc    varchar2(72) := g_package || 'set_status';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);

  x_return_status:=p_curent_status;
  if (p_dyn_sql_processapi_sts = 'E') then
    x_return_status := 'E';
  elsif (p_dyn_sql_processapi_sts = 'W' and NVL(p_curent_status,'W') <> 'E') then
    x_return_status := 'W';
  end if;
  hr_utility.set_location(' Exiting :' || l_proc,15);

  return x_return_status;

End set_status;


procedure set_transaction_context(
  p_transaction_id in number)
  IS
  cursor csr_hat is
     select hat.transaction_id,
     hat.creator_person_id,
     hat.status,
     hat.function_id,
     hat.transaction_ref_table,
     hat.transaction_ref_id,
     hat.transaction_type,
     hat.assignment_id,
     hat.selected_person_id,
     hat.item_type,
     hat.item_key,
     hat.transaction_effective_date,
     hat.process_name,
     hat.transaction_state,
     hat.effective_date_option
     from   hr_api_transactions hat
     where hat.transaction_id =p_transaction_id;
     step_row csr_hat%rowtype;
     l_proc    varchar2(72) := g_package || 'set_transaction_context';
    Begin

    hr_utility.set_location(' Entering:' || l_proc,10);
    hr_utility.set_location(' Opening Cursor:csr_hat' || l_proc,15);
    g_txn_ctx := null;
    open csr_hat;
    fetch csr_hat into step_row;
    close csr_hat;
    hr_utility.set_location(' Closing Cursor:csr_hat' || l_proc,20);

    -- Set the Individual fields on the Global Transaction Context Record
    hr_utility.set_location(' Setting GlobalTxnCtx' || l_proc,25);
    g_txn_ctx.TRANSACTION_ID            :=step_row.TRANSACTION_ID;
    g_txn_ctx.CREATOR_PERSON_ID         :=step_row.CREATOR_PERSON_ID;
    g_txn_ctx.STATUS                    :=step_row.STATUS;
    g_txn_ctx.FUNCTION_ID               :=step_row.FUNCTION_ID;
    g_txn_ctx.TRANSACTION_REF_TABLE     :=step_row.TRANSACTION_REF_TABLE;
    g_txn_ctx.TRANSACTION_REF_ID        :=step_row.TRANSACTION_REF_ID;
    g_txn_ctx.TRANSACTION_TYPE          :=step_row.TRANSACTION_TYPE;
    g_txn_ctx.ASSIGNMENT_ID             :=step_row.ASSIGNMENT_ID;
    g_txn_ctx.SELECTED_PERSON_ID        :=step_row.SELECTED_PERSON_ID;
    g_txn_ctx.ITEM_TYPE                 :=step_row.ITEM_TYPE;
    g_txn_ctx.ITEM_KEY                  :=step_row.ITEM_KEY;
    g_txn_ctx.PROCESS_NAME              :=step_row.PROCESS_NAME;
    g_txn_ctx.TRANSACTION_STATE         :=step_row.TRANSACTION_STATE;
    g_txn_ctx.EFFECTIVE_DATE_OPTION     :=step_row.EFFECTIVE_DATE_OPTION;

    if (step_row.EFFECTIVE_DATE_OPTION = 'A') then
        g_txn_ctx.EFFECTIVE_DATE        := trunc(SYSDATE);
    else
        g_txn_ctx.EFFECTIVE_DATE        := nvl(step_row.TRANSACTION_EFFECTIVE_DATE, trunc(sysdate));
    end if;
    hr_utility.set_location(' Completd Setting GlobalTxnCtx' || l_proc,30);
    hr_utility.set_location(' Exiting :' || l_proc,35);


 end set_transaction_context;


procedure set_person_context(
  p_selected_person_id     in number,
  p_selected_assignment_id in number,
  p_effective_date         in DATE)
  IS

cursor csr_person_details is
select  ppf.full_name,
        ppf.person_id,
        ppf.employee_number,
        ppf.npw_number,
        decode(ppf.current_employee_flag, 'Y', 'Y',decode(ppf.current_npw_flag,'Y','Y'),'N') active,
        paf.assignment_id,
        paf.assignment_number,
        paf.assignment_type,
        paf.primary_flag,
        paf.supervisor_id,
        sup.full_name supervisor_name,
        ppf.business_group_id,
        paf.organization_id,
        bustl.name business_group_name,
        orgtl.name organization_name,
        paf.job_id,
        jtl.name job_name,
        paf.position_id,
        postl.name position_name,
        oi.org_information10 currency_code,
        oi.org_information2 employee_number_generation,
        oi.org_information3 applicant_number_generation,
        oi.org_information16 npw_number_generation,
        oi.org_information9 legislation_code,
        fs.id_flex_structure_code people_grp_f_struct_code,
        oi.org_information14 security_group_id,
        paf.location_id,
	paf.payroll_id

from    per_all_people_f ppf,
        per_all_assignments_f paf,
        hr_all_organization_units_tl bustl,
        hr_all_organization_units_tl orgtl,
        per_jobs_tl jtl,
        hr_all_positions_f_tl postl,
        per_all_people_f sup,
        hr_organization_information oi,
        fnd_id_flex_structures fs

where   ppf.person_id = p_selected_person_id
and     ppf.person_id = paf.person_id
and     paf.assignment_id = nvl(p_selected_assignment_id, paf.assignment_id)
and     paf.assignment_type in ('E','C','A')
and     paf.primary_flag = decode (nvl(p_selected_assignment_id, -1),-1,'Y', paf.primary_flag)
and     paf.supervisor_id = sup.person_id(+)
and     ppf.business_group_id = oi.organization_id
and     oi.org_information_context = 'Business Group Information'
and     oi.org_information5 = fs.id_flex_num(+)
and     fs.id_flex_code(+) = 'GRP'
and     fs.application_id(+) = 801
and     ppf.business_group_id = bustl.organization_id
and     bustl.language = userenv('LANG')
and     paf.organization_id = orgtl.organization_id
and     orgtl.language = userenv('LANG')
and     paf.job_id = jtl.job_id(+)
and     jtl.language(+) = userenv('LANG')
and     paf.position_id = postl.position_id(+)
and     postl.language(+) = userenv('LANG')
and     p_effective_date between ppf.effective_start_date and ppf.effective_end_date
and     p_effective_date between paf.effective_start_date and paf.effective_end_date
and     p_effective_date between sup.effective_start_date(+) and sup.effective_end_date(+);

   step_row csr_person_details%rowtype;
   l_proc    varchar2(72) := g_package || 'set_person_context';
   l_orgid   number;
   Begin
    hr_utility.set_location(' Entering:' || l_proc,10);
    hr_utility.set_location(' Opening Cursor:csr_person_details' || l_proc,15);

  if p_selected_person_id is not null AND p_selected_assignment_id is not null AND p_effective_date is not null  then
    open csr_person_details;
    fetch csr_person_details into step_row;
    close csr_person_details;
    hr_utility.set_location(' Closing Cursor:csr_person_details' || l_proc,20);
    -- Set the Individual fields on the Global Person Record
    hr_utility.set_location('Setting the GlobalPersonRecord:' || l_proc,25);

    g_person_ctx.FULL_NAME                  :=step_row.FULL_NAME;
    g_person_ctx.PERSON_ID                  :=step_row.PERSON_ID;
    g_person_ctx.EMPLOYEE_NUMBER            :=step_row.EMPLOYEE_NUMBER;
    g_person_ctx.NPW_NUMBER                 :=step_row.NPW_NUMBER;
    g_person_ctx.ACTIVE                     :=step_row.ACTIVE;
    g_person_ctx.ASSIGNMENT_ID              :=step_row.ASSIGNMENT_ID;
    g_person_ctx.ASSIGNMENT_NUMBER          :=step_row.ASSIGNMENT_NUMBER;
    g_person_ctx.ASSIGNMENT_TYPE            :=step_row.ASSIGNMENT_TYPE;
    g_person_ctx.PRIMARY_FLAG               :=step_row.PRIMARY_FLAG;
    g_person_ctx.SUPERVISOR_ID              :=step_row.SUPERVISOR_ID;
    g_person_ctx.SUPERVISOR_NAME            :=step_row.SUPERVISOR_NAME;
    g_person_ctx.BUSINESS_GROUP_ID          :=step_row.BUSINESS_GROUP_ID;
    g_person_ctx.ORGANIZATION_ID            :=step_row.ORGANIZATION_ID;
    g_person_ctx.BUSINESS_GROUP_NAME        :=step_row.BUSINESS_GROUP_NAME;
    g_person_ctx.ORGANIZATION_NAME          :=step_row.ORGANIZATION_NAME;
    g_person_ctx.JOB_ID                     :=step_row.JOB_ID;
    g_person_ctx.JOB_NAME                   :=step_row.JOB_NAME;
    g_person_ctx.POSITION_ID                :=step_row.POSITION_ID;
    g_person_ctx.POSITION_NAME              :=step_row.POSITION_NAME;
    g_person_ctx.LOCATION_ID                :=step_row.LOCATION_ID;
    g_person_ctx.CURRENCY_CODE              :=step_row.CURRENCY_CODE;
    g_person_ctx.EMPLOYEE_NUMBER_GENERATION :=step_row.EMPLOYEE_NUMBER_GENERATION;
    g_person_ctx.APPLICANT_NUMBER_GENERATION:=step_row.APPLICANT_NUMBER_GENERATION;
    g_person_ctx.NPW_NUMBER_GENERATION      :=step_row.NPW_NUMBER_GENERATION;
    g_person_ctx.LEGISLATION_CODE           :=step_row.LEGISLATION_CODE;
    g_person_ctx.PEOPLE_GRP_F_STRUCT_CODE   :=step_row.PEOPLE_GRP_F_STRUCT_CODE;
    g_person_ctx.SECURITY_GROUP_ID          :=step_row.SECURITY_GROUP_ID;
    g_person_ctx.PAYROLL_ID                 :=step_row.PAYROLL_ID;

    init_profiles(  p_person_id          => g_person_ctx.PERSON_ID,
                  p_assignment_id      => g_person_ctx.ASSIGNMENT_ID,
		  p_business_group_Id  => g_person_ctx.BUSINESS_GROUP_ID,
		  p_organization_Id    => g_person_ctx.ORGANIZATION_ID,
                  p_location_id        => g_person_ctx.LOCATION_ID,
		  p_payroll_id         => g_person_ctx.PAYROLL_ID
		  );

    -- HRMS BPO Enhancement changes,for bug 7501793
    l_orgid := step_row.business_group_id;
    if hr_multi_tenancy_pkg.is_multi_tenant_system then
      l_orgid := hr_multi_tenancy_pkg.get_org_id_for_person(step_row.person_id);
    end if;

    hr_util_misc_ss.set_sys_ctx(step_row.legislation_code, l_orgid);
  end if;

    hr_utility.set_location('Set values on Global Person Record:' || l_proc,30);
    hr_utility.set_location(' Exiting :' || l_proc,35);

 end set_person_context;

 procedure init_profiles(
  p_person_id in number,
  p_assignment_id in Number,
  p_business_group_Id in Number,
  p_organization_Id in Number,
  p_location_id in Number,
  p_payroll_id in number
  )
  IS
  l_proc    varchar2(72) := g_package || 'init_profiles';
  Begin

    hr_utility.set_location(' Entering:' || l_proc,10);
    hr_utility.set_location(' Setting Profile values:' || l_proc,15);

    fnd_profile.put('PER_PERSON_ID', p_person_id);
    fnd_profile.put('PER_ASSIGNMENT_ID', p_assignment_id);
    fnd_profile.put('PER_BUSINESS_GROUP_ID', p_business_group_Id);
    fnd_profile.put('PER_ORGANIZATION_ID', p_organization_Id);
    fnd_profile.put('PER_LOCATION_ID', p_location_id);
    fnd_profile.put('PER_PAYROLL_ID', p_payroll_id);

    hr_utility.set_location(' Exiting :' || l_proc,20);

  end init_profiles;


 procedure delete_transaction(
 p_transaction_id in NUMBER,
 p_validate in NUMBER default hr_api.g_false_num)
 is
 l_proc    varchar2(72) := g_package || 'delete_transaction';
 begin
   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(' Calling:hr_transaction_api.rollback_transaction' || l_proc,15);
   delete_transaction_children(p_transaction_id, p_validate);
   hr_sflutil_ss.closesflnotifications(p_transaction_id,null,null);
   hr_transaction_api.rollback_transaction(
   p_transaction_id   =>  p_transaction_id,
   p_validate         =>  (p_validate=hr_api.g_true_num));
   hr_utility.set_location(' Exiting :' || l_proc,20);
 end delete_transaction;

 function convertCLOBtoXMLElement(
   p_document in CLOB)
   return xmldom.DOMElement is
   x_commitElement xmldom.DOMElement;
   l_parser xmlparser.Parser;
   l_proc    varchar2(72) := g_package || 'convertCLOBtoXMLElement';
 Begin
   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(' CLOB --> xmldom.DOMElement:' || l_proc,15);
   -- CLOB --> xmldom.DOMElement
   l_parser 	:= xmlparser.newParser;
   xmlparser.ParseCLOB(l_parser,p_document);
   x_commitElement  := xmldom.getDocumentElement(xmlparser.getDocument(l_parser));
   return x_commitElement;
 end convertCLOBtoXMLElement;

  procedure setTransactionStatus(
  p_transaction_id in NUMBER,
  p_transaction_ref_table in varchar2,
  p_currentTxnStatus in varchar2,
  p_proposedTxnStatus in varchar2,
  p_propagateMessagePub in number,
  p_status out nocopy varchar2)
  IS
  --
     PRAGMA AUTONOMOUS_TRANSACTION;
   --
   -- local variables
   c_proc constant varchar2(30) := 'setTransactionStatus';
   c_updateStatus hr_api_transactions.status%type;
   ln_notification_id wf_notifications.notification_id%type;
   lr_hr_api_transaction_rec hr_api_transactions%rowtype;

  begin
    -- check if debug enabled
    if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
    end if;

     -- call the overloaded setTransactionStatus with null comments
     setTransactionStatus(p_transaction_id,null,
                          p_transaction_ref_table,
			  p_currentTxnStatus,
			  p_proposedTxnStatus,
			  p_propagateMessagePub,
			  p_status);

    if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
    end if;

  exception
  when others then
   -- return error status
        p_status := 'E';
  end setTransactionStatus;


function isFYINtf(p_ntfId in number)
return boolean IS

l_exists char(1);
begin
  l_exists := 'N';
 select 'Y' into l_exists
  from dual
 where exists (select 'e'
               from wf_notifications wn, wf_message_attributes mat
               where wn.notification_id = p_ntfId
               and wn.message_name = mat.message_name
               and wn.message_type = mat.message_type
               and mat.name = 'RESULT');

 return false;
 if(l_exists is not null and l_exists='Y') then
   return false;
 else
  return true;
 end if;
Exception when others then
 return true;
end isFYINtf;

function isEditAllowed(p_transaction_id in number,
                       p_transaction_status in varchar2,
                       p_notification_id in number,
                       p_authenticateNtf in number,
                       p_loginPersonId in number,
                       p_loginPersonBgId in number,
                       p_propagateMessagePub in number)
return varchar2
is
-- local variables
editAllowed varchar2(1);
lr_hr_api_transaction_rec hr_api_transactions%rowtype;
l_authenticateNtf boolean;
begin

  -- check if we need to propagate the error messages
    if(p_propagateMessagePub=hr_api.g_true_num) then
        hr_multi_message.enable_message_list;
    end if;

  -- set the default return satatus
  editAllowed :='N';

  -- set the default ntf authentication
  if((p_authenticateNtf is null) or (p_authenticateNtf=hr_api.g_true_num)) then
    l_authenticateNtf := true;
  else
     l_authenticateNtf := false;
  end if;


  if(p_notification_id is not null) then
    -- check if notification is open and user has access to the notification
    if not hr_sflutil_ss.OpenNotificationsExist(p_notification_id) then
      -- raise exception ... need to change
      if(hr_multi_message.is_message_list_enabled) then
        --HRSSA_TRANSACTION_COMPLETE
        --This notification is not available as it has already been completed
        --and closed.
        fnd_message.set_name(800,'HRSSA_TRANSACTION_COMPLETE');
        hr_multi_message.add(null,null,null,null,null,'N',hr_multi_message.g_error_msg);
       end if;
        editAllowed :='E';
        return editAllowed;
    end if;
    -- authenticate login user access to the notifcation id
    if(l_authenticateNtf and (wf_advanced_worklist.authenticate(fnd_global.user_name,
                                             p_notification_id,null)
        <>fnd_global.user_name)) then

         -- no more iterations return false
      if(hr_multi_message.is_message_list_enabled) then
        hr_multi_message.add(null,null,null,null,null,'N',hr_multi_message.g_error_msg);
      end if;
      editAllowed :='E';
      return editAllowed;
    end if;
  end if;

if(p_transaction_id is not null) then
   -- get the transaction details
   begin
     select * into lr_hr_api_transaction_rec
     from hr_api_transactions
     where transaction_id=p_transaction_id;
   exception
   when others then
     editAllowed :='N';
   end;

   if(p_transaction_status not in ('Y','YS','RO','ROS')
        and isTxnOwner(null,lr_hr_api_transaction_rec.creator_person_id)) then
    -- it is the creator editing the transaction
    editAllowed := 'Y';
    return editAllowed;
   elsif(p_transaction_status in ('Y','YS','RO','ROS' )) then
     -- case where approvers trying to edit

     -- check if the login person is the approver
     if(fnd_global.user_name=wf_engine.getitemattrtext(lr_hr_api_transaction_rec.item_type,
                                                       lr_hr_api_transaction_rec.item_key,
                                                      'FORWARD_TO_USERNAME',true)) then
        -- check the profile if the system is configured for approvers editing
        IF ( nvl(fnd_profile.value('PQH_ALLOW_APPROVER_TO_EDIT_TXN'),'N') = 'Y' ) THEN
         -- add specific override logic here
         -- case 1: check the programatic overide for the flow
         --        wf item attribute  HR_RESTRICT_EDIT_ATTR

            if(wf_engine.getitemattrtext(lr_hr_api_transaction_rec.item_type,
                                                       lr_hr_api_transaction_rec.item_key,
                                                      'HR_RESTRICT_EDIT_ATTR',true)='Y') then
              editAllowed := 'N';
              return editAllowed;
            end if;

         -- case 2: Functional module layer
         -- appraisal specific, not edit allowed for now by approvers
         if(lr_hr_api_transaction_rec.transaction_ref_table='PER_APPRAISALS') then
           editAllowed := 'N';
           -- no more checks return
           return editAllowed;
         end if;


         -- check the if the appover is allowed to edit
         pqh_ss_utility.check_edit_privilege (
           p_personId        => nvl(p_loginPersonId,fnd_global.employee_id)
          ,p_businessGroupId => p_loginPersonBgId
          ,p_editAllowed     => editAllowed);


        END IF;-- edit profile check.
     end if; -- approver check
   end if; -- transaction status check
 end if; -- transaction id null check
  -- disable the message propagation
    IF (p_propagateMessagePub=hr_api.g_true_num) THEN
            hr_multi_message.disable_message_list;
    END IF;

  return editAllowed;

exception
when others then
 editAllowed :='N';
 return editAllowed;
end isEditAllowed;


function isDeleteAllowed(p_transaction_id in number,
                         p_transaction_status in varchar2,
                         p_notification_id in number,
                         p_authenticateNtf in number,
                         p_propagateMessagePub in number)
return varchar2
is
-- local variables
deleteAllowed varchar2(1);
lr_hr_api_transaction_rec hr_api_transactions%rowtype;
l_authenticateNtf boolean;
begin

  -- set default
  deleteAllowed :='N';
  -- check if we need to propagate the error messages
    if(p_propagateMessagePub=hr_api.g_true_num) then
        hr_multi_message.enable_message_list;
    end if;

  -- set the default ntf authentication
  if((p_authenticateNtf is null) or (p_authenticateNtf=hr_api.g_true_num)) then
    l_authenticateNtf := true;
  else
     l_authenticateNtf := false;
  end if;


     if(p_notification_id is not null) then
      -- check if notification is open and user has access to the notification
       if not hr_sflutil_ss.OpenNotificationsExist(p_notification_id) then
        -- raise exception ... need to change
        if(hr_multi_message.is_message_list_enabled) then
          --HRSSA_TRANSACTION_COMPLETE
          --This notification is not available as it has already been completed
          --and closed.
          fnd_message.set_name(800,'HRSSA_TRANSACTION_COMPLETE');
          hr_multi_message.add(null,null,null,null,null,'N',hr_multi_message.g_error_msg);
        end if;

        deleteAllowed :='E';
        return deleteAllowed;
      end if;

    -- authenticate login user access to the notifcation id
    if(l_authenticateNtf and (wf_advanced_worklist.authenticate(fnd_global.user_name,
                                             p_notification_id,null)
        <>fnd_global.user_name)) then
         -- no more iterations return false
      if(hr_multi_message.is_message_list_enabled) then
        hr_multi_message.add(null,null,null,null,null,'N',hr_multi_message.g_error_msg);
      end if;
      deleteAllowed :='E';
      return deleteAllowed;
    end if;
  end if;

if(p_transaction_id is not null) then
  -- get the transaction details
   begin
     select * into lr_hr_api_transaction_rec
     from hr_api_transactions
     where transaction_id=p_transaction_id;
   exception
   when others then
     deleteAllowed :='N';
   end;

   if(p_transaction_status not in ('Y','YS','RO','ROS')
        and isTxnOwner(null,lr_hr_api_transaction_rec.creator_person_id)) then
    -- it is the creator editing the transaction
    deleteAllowed := 'Y';
   else
     deleteAllowed :='N';
   end if;

   -- disable the message propagation
    IF (p_propagateMessagePub=hr_api.g_true_num) THEN
            hr_multi_message.disable_message_list;
    END IF;
 end if;

   return deleteAllowed;

exception
when others then
  deleteAllowed :='N';
  return deleteAllowed;
end isDeleteAllowed;

procedure ownerDeleteAction(p_transaction_id in number,
                            p_currentTxnStatus in varchar2,
                            p_transaction_type in varchar2,
                            p_item_type in varchar2,
                            p_item_key in varchar2)
is
lv_result varchar2(100);
ln_notification_id wf_notifications.notification_id%type;
ln_activity_id wf_item_activity_statuses.process_activity%type;
begin

  -- check on high level if the owner can delete it
  -- only case when the pending approvals
  if(p_currentTxnStatus in ('Y','YS','RO','ROS')) then
    -- raise exception
    return;
  end if;


  if(p_transaction_id is not null) then
    -- check if WF based on non-WF based
    if(p_item_key is not null) then
      -- based on status we need to either abort the wf process
      -- and soft delete the txn
      -- OR transition the WF process in delete mode
      if(p_currentTxnStatus in ('RI','RIS')) then
        -- call workflow process in 'DELETE' mode
        -- get the notification id and complete it with delete mode

        -- get the rfc ntf id
           select ias.notification_id,ias.process_activity
           into ln_notification_id,ln_activity_id
           from wf_item_activity_statuses ias
           where ias.item_type        = p_item_type
            and   ias.item_key         = p_item_key
            and   ias.activity_status  = 'NOTIFIED'
            and   notification_id is not null
            and   rownum < 2;
         -- check if the notification id if not throw exception
         if(ln_notification_id is not null) then

            -- hsundar: Delete any open SFL Notification for this txn
            hr_sflutil_ss.closesflnotifications(p_transaction_id,p_item_type,p_item_key);

            -- complete ntf with HR_V5_ALL_RESPONSES.del code
          /*  wf_engine.CompleteActivity(
                   p_item_Type
                 , p_item_Key
                 , wf_engine.getactivitylabel(ln_activity_id)
                 , 'DEL')  ; */
         -- fix for bug 5328872
         wf_notification.setattrtext(
       			ln_notification_id
       		       ,'RESULT'
       		       ,'DEL');
             wf_notification.respond(
        			ln_notification_id
      		       ,null
      		       ,fnd_global.user_name
      		       ,null);
         else
           -- throw exception
           null;
         end if;
      else -- other statuses

        -- hsundar: Delete any open SFL Notification for this txn
        hr_sflutil_ss.closesflnotifications(p_transaction_id,p_item_type,p_item_key);

        hr_transaction_ss.rollback_transaction(p_item_type,
                                               p_item_key,
                                               null,
                                               wf_engine.eng_run,
                                               lv_result);
        wf_engine.abortprocess(itemtype => p_item_type
                               ,itemkey  => p_item_key
                               ,process  =>null
                               ,result   => wf_engine.eng_force
                               ,verify_lock=> true
                               ,cascade=> true);
      end if;
    else -- non workflow case
      -- soft delete the transaction
      hr_transaction_api.update_transaction(
               p_transaction_id    => p_transaction_id,
               p_status            => 'D');

       -- close all sfl notifications
       hr_sflutil_ss.closesflnotifications(p_transaction_id,null,null);
      -- do the module specific logic
    end if;


  else
    -- transaction id is null raise error ??
    null;
  end if;
exception
when others then
  raise;
end ownerDeleteAction;

procedure othersDeleteAction(p_transaction_id in number,
                            p_currentTxnStatus in varchar2,
                            p_transaction_type in varchar2,
                            p_item_type in varchar2,
                            p_item_key in varchar2)
is
lr_hr_api_transaction_rec hr_api_transactions%rowtype;
lv_result varchar2(100);
ln_notification_id wf_notifications.notification_id%type;
ln_activity_id wf_item_activity_statuses.process_activity%type;
begin

   if(p_currentTxnStatus in ('Y','YS','RO','ROS')) then
     -- get the notification activity id and complete
     -- the process in reject status
     -- get the rfc ntf id
           select ias.notification_id,ias.process_activity
           into ln_notification_id,ln_activity_id
           from wf_item_activity_statuses ias
           where ias.item_type        = p_item_type
            and   ias.item_key         = p_item_key
            and   ias.activity_status  = 'NOTIFIED'
            and   notification_id is not null
            and   rownum < 2;
         -- check if we have the notification id
         if(ln_notification_id is not null) then

            -- hsundar: Delete any open SFL Notification for this txn
             hr_sflutil_ss.closesflnotifications(p_transaction_id,p_item_type,p_item_key);

            -- complete ntf with HR_V5_ALL_RESPONSES.Reject code
          /*  wf_engine.CompleteActivity(
                   p_item_Type
                 , p_item_Key
                 , wf_engine.getactivitylabel(ln_activity_id)
                 , 'REJECTED')  ; */
          -- fix for bug 5328872
          wf_notification.setattrtext(
       			ln_notification_id
       		       ,'RESULT'
       		       ,'REJECTED');
             wf_notification.respond(
        			ln_notification_id
      		       ,null
      		       ,fnd_global.user_name
      		       ,null);

         else
           -- throw exception
           null;
         end if;

   else
   -- raise exception action cannot be performed
     null;
   end if;



exception
when others then
  raise;
end othersDeleteAction;

procedure deleteAction(p_transaction_id in number)
is
lr_hr_api_transaction_rec hr_api_transactions%rowtype;
lv_result varchar2(100);
begin
   -- this routine is called from  all actions UI
   --
   -- implementation logic
   /*
     CurrentStatus Creator         Approver
     ============  =======         =========
      W             Soft delete     N/A
                    set status
                    to 'D'
      others        no impl         Reject txn
                    in phase I

     Phase II we need the txn data rollback and
     WF page navigation state reset.

   */
    if(p_transaction_id is not null) then
     begin
       select * into lr_hr_api_transaction_rec
       from hr_api_transactions
       where transaction_id=p_transaction_id;
     exception
     when others then
        raise;
     end;

         -- check the current owner
       if(isTxnOwner(null,lr_hr_api_transaction_rec.creator_person_id)) then
         -- do logic specific to creator
         ownerDeleteAction(p_transaction_id ,
                           lr_hr_api_transaction_rec.status,
                           lr_hr_api_transaction_rec.transaction_type,
                           lr_hr_api_transaction_rec.item_type,
                           lr_hr_api_transaction_rec.item_key);
       else -- approvers case
          othersDeleteAction(p_transaction_id ,
                           lr_hr_api_transaction_rec.status,
                           lr_hr_api_transaction_rec.transaction_type,
                           lr_hr_api_transaction_rec.item_type,
                           lr_hr_api_transaction_rec.item_key);
     end if;-- transaction owner check
   end if;-- transaction id check

               exception
                 when others then
                   null;
end deleteAction;


procedure initiatorDeleteAction(p_transaction_id in number)
is
lv_result varchar2(100);
lr_hr_api_transaction_rec hr_api_transactions%rowtype;
begin

  if(p_transaction_id is not null) then
    -- Read Transaction Details
     begin
       select * into lr_hr_api_transaction_rec
       from hr_api_transactions
       where transaction_id=p_transaction_id;
     exception
     when others then
        raise;
     end;

    -- check if WF based on non-WF based

    if(lr_hr_api_transaction_rec.item_type is not null) then
       -- WF case.
       -- hsundar: Delete any open SFL Notification for this txn
        hr_sflutil_ss.closesflnotifications(p_transaction_id
                                           ,lr_hr_api_transaction_rec.item_type
                                           ,lr_hr_api_transaction_rec.item_key);

        hr_transaction_ss.rollback_transaction(lr_hr_api_transaction_rec.item_type,
                                               lr_hr_api_transaction_rec.item_key,
                                               null,
                                               wf_engine.eng_run,
                                               lv_result);
        wf_engine.abortprocess(itemtype     => lr_hr_api_transaction_rec.item_type
                               ,itemkey     => lr_hr_api_transaction_rec.item_key
                               ,process     =>null
                               ,result      => wf_engine.eng_force
                               ,verify_lock => true
                               ,cascade     => true);
    else
      -- non WF case
      -- soft delete the transaction
      hr_transaction_api.update_transaction(
               p_transaction_id    => p_transaction_id,
               p_status            => 'D');

       -- close all sfl notifications
       hr_sflutil_ss.closesflnotifications(p_transaction_id,null,null);
      -- do the module specific logic

    end if; -- End of 2nd if(lr_hr_api_transaction_rec.item_type is not null)

  else
    -- transaction id is null raise error ??
    null;
  end if; -- End of main if(p_transaction_id is not null)

exception
when others then
  raise;
end initiatorDeleteAction;




procedure cancelAction(p_transaction_id in number)
is
lr_hr_api_transaction_rec hr_api_transactions%rowtype;
begin

   if(p_transaction_id is not null) then
     begin
       select * into lr_hr_api_transaction_rec
       from hr_api_transactions
       where transaction_id=p_transaction_id;
exception
  when others then
    null;
     end;

     -- check the status
     if(lr_hr_api_transaction_rec.status='W') then
        -- delete the transaction if owner
         -- check the current owner
       if(isTxnOwner(null,lr_hr_api_transaction_rec.creator_person_id)) then
          deleteAction(p_transaction_id);
       else
        -- raise error ??
        -- not a valid call to this action
         null;
       end if;
     else
        -- all other status we need to revert the state back to last known good
        -- state
        hr_trans_history_api.cancel_action(p_transaction_id);
	-- Note:
	-- This method does not revert the inadvertant wf page flow state
	-- the WF activity is handling the transition and based on user action
	-- will revert the flow state.

	-- call  the method to reset the wf pageflow state , if wf is used for page navigation
	hr_approval_ss.resetWfPageFlowState(p_transaction_id);

     end if;
   end if;


exception
  when others then
    null;
end cancelAction;


function isTxnOwner(p_transaction_id in number,
                    p_person_id in number) return boolean
is
-- local variables
x_returnStatus boolean;
lr_hr_api_transaction_rec hr_api_transactions%rowtype;
ln_person_id number;
begin

 -- set the default value
 x_returnStatus := false;
 ln_person_id := p_person_id;

  if(p_transaction_id is not null) then
    -- ignore passed personid
    -- derive from the transaction details
     select hr_api_transactions.creator_person_id
     into ln_person_id
     from hr_api_transactions
     where transaction_id=p_transaction_id;
  end if;

  --
     if(ln_person_id= fnd_global.employee_id) then
       x_returnStatus := true;
     else
       x_returnStatus :=false;
     end if;
  return x_returnStatus;
exception
when others then
  raise;
end isTxnOwner;

procedure delete_transaction_children(
 p_transaction_id in NUMBER,
 p_validate in NUMBER default hr_api.g_false_num)
is
  cursor csr_trn is
    select trn.transaction_id
    from hr_api_transactions trn
    where trn.parent_transaction_id = p_transaction_id;
begin
  for csr_row in csr_trn loop
    delete_transaction(csr_row.transaction_id);
  end loop;
end delete_transaction_children;

FUNCTION commit_transaction(
  p_transaction_id IN NUMBER,
  p_validate IN NUMBER DEFAULT hr_api.g_false_num,
  p_effective_date IN DATE DEFAULT SYSDATE)
  RETURN VARCHAR2 IS
  l_proc    VARCHAR2(72) := g_package || 'commit_transaction';
  x_return_status VARCHAR2(1);
  p_error_log CLOB;

 BEGIN
  hr_utility.set_location(' Entering:' || l_proc,10);
    commit_transaction(
             p_transaction_id=>p_transaction_id,
             p_validate =>p_validate,
             p_effective_date=>p_effective_date,
             p_process_all_on_error =>hr_api.g_false_num,
             p_status=>x_return_status,
             p_error_log=>p_error_log);
  hr_utility.set_location(' Exiting:' || l_proc,20);

  RETURN x_return_status;
  EXCEPTION
    WHEN others THEN
      RAISE;
 END commit_transaction;

procedure intializeWFApprovals(p_transaction_id     IN   NUMBER
                               ,p_item_key out nocopy number
                               ,p_status out nocopy varchar2) as


  lv_item_type wf_items.item_type%type;
  lr_transaction_rec hr_api_transactions%rowtype;
  lv_status    varchar2(8);
  lv_result    varchar2(30);
  lv_errorActid wf_item_activity_statuses.process_activity%type;
  lv_errname VARCHAR2(4000);
  l_index                binary_integer;
  l_temp_item_attribute       varchar2(2000);
  l_role_name wf_roles.name%type;
  l_role_displayname wf_roles.display_name%type;
  lt_additional_wf_attributes  HR_WF_ATTR_TABLE;
  lv_error_message varchar2(4000);
  lv_errstack varchar2(4000);
  lv_ntfSubMsg fnd_new_messages.message_name%type;
  lv_relaunchFunc fnd_form_functions.function_name%type;
  lv_param_name fnd_form_functions.parameters%type;
  lv_approval_required varchar2(5);
  lv_ameTransType varchar2(240);
  ln_ameTranAppId number;
  lv_xpath varchar2(20000) default 'Transaction/TransCtx';
  lv_review_template_rn fnd_form_functions.function_name%type;
  lv_Ntf_Attach_Attr wf_item_attribute_values.text_value%type;
  lv_approval_comments wf_item_attribute_values.text_value%type;
  lv_perz_func wf_item_attribute_values.text_value%type;
  lv_perz_leg wf_item_attribute_values.text_value%type;
  lv_perz_org wf_item_attribute_values.text_value%type;
begin

   begin
     -- call the method to create the workflow approval process
     if(p_transaction_id is not null) then
         -- get the transaction details
         select *
         into lr_transaction_rec
         from hr_api_transactions
         where transaction_id=p_transaction_id;

       -- derive the fnd function params values from txn
       lv_approval_required := hr_xml_util.get_node_value(p_transaction_id,
                                                 'pApprovalReqd',
                                                 lv_xpath,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL);
           lv_ntfSubMsg := hr_xml_util.get_node_value(p_transaction_id,
                                                 'pNtfSubMsg',
                                                 lv_xpath,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL);
         lv_ameTransType := hr_xml_util.get_node_value(p_transaction_id,
                                                 'pAMETranType',
                                                 lv_xpath,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL);
         ln_ameTranAppId:= hr_xml_util.get_node_value(p_transaction_id,
                                                 'pAMEAppId',
                                                 lv_xpath,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL);
         lv_review_template_rn := hr_xml_util.get_node_value(p_transaction_id,
                                                 'ReviewTemplateRNAttr',
                                                 lv_xpath,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL);
         lv_Ntf_Attach_Attr:= hr_xml_util.get_node_value(p_transaction_id,
                                                 'NtfAttachAttr',
                                                 lv_xpath,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL);
         lv_perz_func:= hr_xml_util.get_node_value(p_transaction_id,
                                                 'PerzFunctionName',
                                                 lv_xpath,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL);
         lv_perz_leg:= hr_xml_util.get_node_value(p_transaction_id,
                                                 'PerzLocalizationCode',
                                                 lv_xpath,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL);
         lv_perz_org:= hr_xml_util.get_node_value(p_transaction_id,
                                                 'PerzOrganizationId',
                                                 lv_xpath,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL);
       lt_additional_wf_attributes :=  HR_WF_ATTR_TABLE(HR_WF_ATTR_TYPE('TRAN_SUBMIT','N',null,null));
         hr_approval_ss.startGenericApprovalProcess(p_transaction_id
                                     ,p_item_key
                                     ,lv_ntfSubMsg
                                     ,'HR_RELAUNCH_SS'
                                     ,lt_additional_wf_attributes
                                     ,lv_status
                                     ,lv_error_message
                                     ,lv_errstack
                                   );


         -- add check for the error status and raise to bc4j accordingly


        -- set additional  item attributes
        -- HR_OAF_NAVIGATION_ATTR
        -- set HR_OAF_EDIT_URL_ATTR
        hr_approval_ss.create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_OAF_EDIT_URL_ATTR'
                               ,text_value=>'HR_RELAUNCH_SS'
                               ,number_value=>null,
                               date_value=>null
                               );
     -- set HR_OAF_NAVIGATION_ATTR
       hr_approval_ss.create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_OAF_NAVIGATION_ATTR'
                               ,text_value=>'N'
                               ,number_value=>null,
                               date_value=>null
                               );
     -- set HR_REVIEW_TEMPLATE_RN_ATTR
       hr_approval_ss.create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_REVIEW_TEMPLATE_RN_ATTR'
                               ,text_value=>lv_review_template_rn
                               ,number_value=>null,
                               date_value=>null
                               );

       hr_approval_ss.create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_NTF_ATTACHMENTS_ATTR'
                               ,text_value=>lv_Ntf_Attach_Attr
                               ,number_value=>null,
                               date_value=>null
                               );

     -- HR_RESTRICT_RFC_ATTR

     -- HR_RESTRICT_EDIT_ATTR

      -- APPROVAL_GENERIC_URL

      -- HR_RUNTIME_APPROVAL_REQ_FLAG
       hr_approval_ss.create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_RUNTIME_APPROVAL_REQ_FLAG'
                               ,text_value=>lv_approval_required
                               ,number_value=>null,
                               date_value=>null
                               );
       -- set AME params
       -- 'HR_AME_APP_ID_ATTR'
          hr_approval_ss.create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_AME_APP_ID_ATTR'
                               ,text_value=>null
                               ,number_value=>ln_ameTranAppId
                               ,date_value=>null
                               );
       -- 'HR_AME_TRAN_TYPE_ATTR'
          hr_approval_ss.create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_AME_TRAN_TYPE_ATTR'
                               ,text_value=>lv_ameTransType
                               ,number_value=>null,
                               date_value=>null
                               );

       -- TRANSACTION_ID
           hr_approval_ss.create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'TRANSACTION_ID'
                               ,text_value=>null
                               ,number_value=>p_transaction_id
                               ,date_value=>null
                               );

       -- TRAN_SUBMIT
         hr_approval_ss.create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'TRAN_SUBMIT'
                               ,text_value=>'Y'
                               ,number_value=>null
                               ,date_value=>null
                               );
      -- PROCESS_DISPLAY_NAME
         fnd_message.set_name('PER',lv_ntfSubMsg); -- change the hardcoded

         hr_approval_ss.create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'PROCESS_DISPLAY_NAME'
                               ,text_value=>fnd_message.get
                               ,number_value=>null
                               ,date_value=>null
                               );
         hr_approval_ss.create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_PERZ_FUNCTION_NAME_ATTR'
                               ,text_value=>lv_perz_func
                               ,number_value=>null
                               ,date_value=>null
                               );
         hr_approval_ss.create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_PERZ_LOCALIZATION_CODE_ATTR'
                               ,text_value=>lv_perz_leg
                               ,number_value=>null
                               ,date_value=>null
                               );
         hr_approval_ss.create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_PERZ_ORGANIZATION_ID_ATTR'
                               ,text_value=>lv_perz_org
                               ,number_value=>null
                               ,date_value=>null
                               );
     else
       null; -- raise error

     end if;
   exception
   when no_data_found then
       raise;
   when others then
      raise;
   end;


end;

procedure setTransactionStatus(
  p_transaction_id in NUMBER,
  p_approver_comments in varchar2,
  p_transaction_ref_table in varchar2,
  p_currentTxnStatus in varchar2,
  p_proposedTxnStatus in varchar2,
  p_propagateMessagePub in number,
  p_status out nocopy varchar2)
  IS
  --
    PRAGMA AUTONOMOUS_TRANSACTION;
   --
   -- local variables
   c_proc constant varchar2(30) := 'setTransactionStatus';
   c_updateStatus hr_api_transactions.status%type;
   ln_notification_id wf_notifications.notification_id%type;
   lr_hr_api_transaction_rec hr_api_transactions%rowtype;
   lv_item_key  wf_items.item_key%type;
   lt_additional_wf_attributes  HR_WF_ATTR_TABLE;
   lv_error_message varchar2(4000);
   lv_errstack varchar2(4000);
   lv_status varchar2(30); -- revisit on the size
   lv_wf_item_attribute HR_WF_ATTR_TYPE;
   lv_currentTxnStatus hr_api_transactions.status%type;


  begin
   -- check if debug enabled
    if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
    end if;
    -- check if we need to propagate the error messages
    if(p_propagateMessagePub=hr_api.g_true_num) then
        hr_multi_message.enable_message_list;
    end if;
      -- check the proposed status
      -- S --> SFL
      -- A --> Approval (submit for approval).
      if(p_proposedTxnStatus='A')then
          -- set the transaction status to 'Y'
          c_updateStatus:='Y';
       elsif(p_proposedTxnStatus='S')then
         begin
          select status into lv_currentTxnStatus
          from hr_api_transactions
          where transaction_id=p_transaction_id;
         exception
         when others then
           null;
        end;

         c_updateStatus:= hr_sflutil_ss.getSFLStatusForUpdate(
                             nvl(p_currentTxnStatus,lv_currentTxnStatus),
                             p_proposedTxnStatus);
       else
        -- we do not handle other status, return error status
        p_status := 'E';
        return;
       end if;


       begin
           if(p_proposedTxnStatus='S')then
           -- send SFL notification
             -- get the transaction record
             select *
             into lr_hr_api_transaction_rec
             from hr_api_transactions
             where transaction_id=p_transaction_id;
             -- send sfl notification to login user
             hr_sflutil_ss.sendsflnotification(p_transaction_id,
                                               p_transaction_ref_table,
                                               fnd_global.user_name,
                                               'HR_RELAUNCH_SS',
                                               null,
                                               ln_notification_id);
             -- return success status
             p_status := 'S';
                -- update the transaction status
             hr_transaction_api.update_transaction(
               p_transaction_id    => p_transaction_id,
               p_status            => c_updateStatus,
               p_transaction_state => null);

             -- add the code plugin transfer history
             hr_trans_history_api.archive_sfl(p_transaction_id,
                                              ln_notification_id,
                                              fnd_global.user_name);
            elsif(p_proposedTxnStatus='A') then


              begin
               -- check if the wf process is initialized or not
               select *
               into lr_hr_api_transaction_rec
               from hr_api_transactions
               where transaction_id=p_transaction_id;

               exception
               when others then
                 raise;
              end;

               if(lr_hr_api_transaction_rec.item_key is not null) then

                -- call the code to transition flow in case of approvals
                   hr_approval_ss.processapprovalsubmit(p_transaction_id,
                                                        p_approver_comments);
               else

                 -- intialize the generic approval flow
                    intializeWFApprovals(p_transaction_id=>p_transaction_id
                                        ,p_item_key =>lv_item_key
                                        ,p_status =>p_status);
                     if(lv_item_key is null or p_status='E') then
                       null; -- raise error
                     else
                        -- update the transaction with the item key
                         hr_transaction_api.update_transaction(
                            p_transaction_id    => p_transaction_id,
                            p_item_key            => lv_item_key);

                       -- complete the wf to send ntf or process commit
                        hr_approval_ss.processapprovalsubmit(p_transaction_id,
                                                             p_approver_comments);

                    end if;

               end if;
           else
             null;-- do nothing
           end if;
       exception
       when others then
         -- return error status
        p_status := 'E';
        -- propagate the error message

       end;
    -- disable the message propagation
    IF (p_propagateMessagePub=hr_api.g_true_num) THEN
            hr_multi_message.disable_message_list;
    END IF;

   -- finally commit the data
        commit;


    if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
    end if;

  exception
  when others then
   -- return error status
        p_status := 'E';
  end setTransactionStatus;

PROCEDURE createEOErrorMSgNode(doc IN OUT nocopy  xmldom.DOMDocument,root_node IN OUT  nocopy xmldom.DOMNode)
AS
  EO_node xmldom.DOMNode;
  message_node xmldom.DOMNode;
  item_node xmldom.DOMNode;
  msg_count_elmt xmldom.DOMElement;
  item_elmt xmldom.DOMElement;
  item_text xmldom.DOMText;
  msg_count NUMBER;
  msg_details VARCHAR2(2000);
  p_data	    VARCHAR2(4000);
  p_msg_index_out NUMBER;

 BEGIN
  msg_count :=  fnd_msg_pub.Count_Msg;

    msg_count_elmt :=xmldom.createElement(doc, 'MsgCount');
    xmldom.setAttribute(
        msg_count_elmt
      , 'Value'
      , msg_count
    );

 EO_node := xmldom.appendChild(root_node,xmldom.makeNode(msg_count_elmt));

 FOR i IN 1 .. msg_count LOOP
   item_elmt := xmldom.createElement(
        doc
      , 'Msg'
    );

    message_node := xmldom.appendChild(
        EO_node
      , xmldom.makeNode(item_elmt)
    );
    --
    item_elmt := xmldom.createElement(
        doc
      , 'EncodedMessage'
    );
    item_node := xmldom.appendChild(
        message_node
      , xmldom.makeNode(item_elmt)
    );
    -- get the actual message from fnd_msg_pub
    msg_details :=fnd_msg_pub.Get_Detail(p_msg_index=>i,p_encoded=>'F');
     item_text := xmldom.createTextNode(
        doc
      , msg_details
    );
    item_node := xmldom.appendChild(
        item_node
      , xmldom.makeNode(item_text)
    );
    --
    END LOOP;

 END ;

procedure writeXMLDocToClob(p_error_doc in xmldom.DOMDocument,
                            p_error_log IN OUT nocopy CLOB)
as
 error_log  CLOB;
 charset VARCHAR2(64);
begin
  IF(NOT xmldom.isnull(p_error_doc)) THEN
    SELECT v$nls_parameters.value INTO charset FROM v$nls_parameters
    WHERE v$nls_parameters.parameter='NLS_CHARACTERSET';
    DBMS_LOB.createTemporary(error_log, FALSE);
      xmldom.writeToClob(p_error_doc,error_log,charset);
      p_error_log:=error_log;
    DBMS_LOB.freetemporary(error_log);
    xmldom.freeDocument(p_error_doc);
  END IF;
end;

PROCEDURE commit_transaction(
  p_transaction_id IN NUMBER,
  p_validate IN NUMBER DEFAULT hr_api.g_false_num,
  p_effective_date IN DATE DEFAULT SYSDATE,
  p_process_all_on_error IN NUMBER DEFAULT hr_api.g_false_num,
  p_status OUT nocopy VARCHAR2,
  p_error_log IN OUT nocopy CLOB)IS
  CURSOR csr_trn IS
    SELECT transaction_document
    FROM hr_api_transactions
    WHERE transaction_id = p_transaction_id;

    rootNode xmldom.DOMNode;
    l_TXN_Node xmldom.DOMNode;
    l_AM_Node xmldom.DOMNode;
    l_TransCache_Node xmldom.DOMNode;
    l_EO_Node xmldom.DOMNode;
    l_CDATA_Node xmldom.DOMNode;
    l_EoApiMap_Node xmldom.DOMNode;


    l_EoApiMap_NodeList xmldom.DOMNodeList;
    l_EO_NodeList xmldom.DOMNodeList;
    l_TransCache_NodeList xmldom.DOMNodeList;

    l_proc    VARCHAR2(72) := g_package || 'commit_transaction';
    x_return_status VARCHAR2(1);
    l_pwac_return_status VARCHAR2(1);
    l_language VARCHAR2(2);
    l_EO_Api_Name VARCHAR2(1000);

    l_EO_Object_Name VARCHAR2(1000);
    l_EO_Id	  	     VARCHAR2(1000);
    l_CDATA_Name	 VARCHAR2(1000);
    l_CDATA_Length   NUMBER;

    step_row csr_trn%ROWTYPE;

    -- error logging
    error_doc xmldom.DOMDocument;
    error_doc_main_node xmldom.DOMNode;
    error_doc_root_elmt xmldom.DOMElement;
    error_EO_Node xmldom.DOMNode;
    error_temp_Node xmldom.DOMNode;
    error_EO_elmt xmldom.DOMElement;
    charset VARCHAR2(64);
    error_log  CLOB;

BEGIN
  SAVEPOINT commit_transaction_swi;
  hr_utility.set_location(' Entering:' || l_proc,10);
  -- Call Set_Transaction_Context
  hr_utility.set_location(' Calling set_transaction_context:' || l_proc,15);
  set_transaction_context(p_transaction_id);

  -- If p_effective_date is not NULL then set it on the g_txn_ctx.EFFECTIVE_DATE
  IF ( p_effective_date IS NOT NULL ) THEN
    g_txn_ctx.EFFECTIVE_DATE:=p_effective_date;
  END IF;
  -- Call Set_Person_Context
  l_language:='US';
  hr_utility.set_location(' Calling set_person_context:' || l_proc,20);
  set_person_context( p_selected_person_id      => g_txn_ctx.SELECTED_PERSON_ID,
                      p_selected_assignment_id  => g_txn_ctx.ASSIGNMENT_ID,
                      p_effective_date          => g_txn_ctx.EFFECTIVE_DATE);

  x_return_status := 'S';
  hr_utility.set_location(' Calling :hr_util_misc_ss.seteffectivedate' || l_proc,25);
  hr_utility.set_location(' Entering For Loop' || l_proc,35);
  -- new code
   OPEN csr_trn;
   FETCH csr_trn INTO step_row;
   -- hsundar: Do the Document processing only when the Txn_document is not null
   -- hsundar: If the Document is NULL just return the status as S
   IF step_row.transaction_document IS NOT NULL THEN
     -- Now get the <Transaction> Node
   rootNode	:= xmldom.makeNode(convertCLOBtoXMLElement(step_row.transaction_document));

   -- Now get the <EOApiMap>
   l_EoApiMap_NodeList   :=xmldom.getChildrenByTagName(xmldom.makeElement(rootNode),'EoApiMap');
   IF (xmldom.getLength(l_EoApiMap_NodeList) > 0)  THEN
   l_EoApiMap_Node       :=xmldom.item(l_EoApiMap_NodeList,0);
   l_EO_NodeList	     :=xmldom.getChildrenByTagName(xmldom.makeElement(l_EoApiMap_Node),'EO');

   -- Put it into a Table
   FOR i IN 1..xmldom.getLength(l_EO_NodeList) LOOP
      l_EO_Node         := xmldom.item(l_EO_NodeList,i-1);
      l_EO_Object_Name  := xmldom.getAttribute(xmldom.makeElement(l_EO_Node),'Name');
      l_EO_Node         := xmldom.getFirstChild(l_EO_Node);
      l_EO_Api_Name     :=xmldom.getNodeValue(l_EO_Node);
      --g_api_map(l_EO_Object_Name)       := l_EO_Api_Name;
      -- Maintain Parallel Arrays
      -- 1. Put the EO Name in  g_EO_Name_map
      g_EO_Name_map(i)   := l_EO_Object_Name;
      -- 2. Put the EO's API name
      g_EO_ApiName_map(i):= l_EO_Api_Name;
   END LOOP;


   -- Now get the <TransCache> Node
   l_TransCache_NodeList   :=xmldom.getChildrenByTagName(xmldom.makeElement(rootNode),'TransCache');
   l_TransCache_Node       :=xmldom.item(l_TransCache_NodeList,0);
   -- Now get the <AM> Node
   l_AM_Node               :=xmldom.getFirstChild(l_TransCache_Node);
   -- Now get the </cd> Node and get its Sibling --> <TXN>
   l_TXN_Node              :=xmldom.getNextSibling(xmldom.getFirstChild(l_AM_Node));

   -- Now get the list of all <EO> Nodes
   l_EO_NodeList	:=xmldom.getChildrenByTagName(xmldom.makeElement(l_TXN_Node),'EO');
   --
   IF (xmldom.getLength(l_EO_NodeList) > 0)  THEN
   -- Loop for it
     FOR i IN 1..xmldom.getLength(l_EO_NodeList) LOOP
      l_EO_Node := xmldom.item(l_EO_NodeList,i-1);
      l_pwac_return_status := 'S';

      BEGIN
       l_pwac_return_status:=process_api_internal(
            p_transaction_id        => p_transaction_id,
            p_root_node		    => l_EO_Node,
            p_validate 		    => p_validate,  -- 5919836
            p_effective_date 	    => p_effective_date,
            p_return_status         => x_return_status
         );
      EXCEPTION
      WHEN g_process_api_internal_error THEN
        x_return_status := set_status(x_return_status,'E');
         -- read the fnd msg pub for errors and log them to error doc
         IF(xmldom.isnull(error_doc)) THEN -- first error condition
           -- create the new empty document
            error_doc := xmldom.newDOMDocument;
            error_doc_main_node := xmldom.makeNode(error_doc);
            -- create the root element to hold txn id
            -- error_doc_root_elmt
            error_doc_root_elmt:= xmldom.createElement(error_doc, 'Transaction');
            xmldom.setAttribute(error_doc_root_elmt,'Id', p_transaction_id);
            error_doc_main_node :=xmldom.appendChild(error_doc_main_node, xmldom.makeNode(error_doc_root_elmt));
         END IF;

         -- add the EO node to the error doc
          error_EO_elmt  := xmldom.createElement(error_doc, 'EO');
          -- need the actual nested EO which has errored and its cdata node
          xmldom.setAttribute(error_EO_elmt, 'Name', g_processing_EO_name);
          xmldom.setAttribute(error_EO_elmt, 'CDATA', g_processing_EO_cdatavalue);
          --
          error_EO_Node :=xmldom.makeNode(error_EO_elmt);
          createEOErrorMSgNode(error_doc,error_EO_Node);
          error_temp_Node:=xmldom.appendChild(error_doc_main_node,error_EO_Node);
          -- see if we need to progress on the siblings ?
        IF p_process_all_on_error = hr_api.g_false_num THEN
         RAISE g_process_api_internal_error;
        END IF;

      END;
      x_return_status := set_status(x_return_status,l_pwac_return_status);
    END LOOP;
  END IF; -- End of if where we check if we have some EO Nodes
 END IF; -- End of if where we check if we have EOAPIMAP Nodes
 END IF; -- End of if where we check if the txn_doc is null
  CLOSE csr_trn;

  writeXMLDocToClob(error_doc ,p_error_log );

  hr_utility.set_location(' Exiting For Loop:' || l_proc,40);
  IF p_validate = hr_api.g_true_num THEN
    hr_utility.set_location(' p_validate=TRUE:' || l_proc,45);
    RAISE hr_api.validate_enabled;
  END IF;
  -- Return the status to the calling procedure
  -- hsundar: There is no need to commit as Work-Flow takes care of it implicitly
  /*if p_validate = hr_api.g_false_num then
    hr_utility.set_location('Commiting as  p_validate=FALSE:' || l_proc,50);
    COMMIT;
  END IF; */

    hr_utility.set_location(' Exiting:' || l_proc,55);

  --return x_return_status;
    p_status :=x_return_status;
  -- Moved the exception Block out of the for loop

  EXCEPTION
   WHEN g_process_api_internal_error THEN
     p_status :=x_return_status;
     writeXMLDocToClob(error_doc ,p_error_log );
    WHEN hr_utility.hr_error THEN
      --do something here
      hr_utility.set_location('Exception:hr_utility.hr_error' || l_proc,555);
      ROLLBACK TO commit_transaction_swi;
      RAISE;
    WHEN hr_api.validate_enabled THEN
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      hr_utility.set_location('Exception:hr_api.validate_enabled' || l_proc,560);
      ROLLBACK TO commit_transaction_swi;
      p_status :=x_return_status;
    WHEN others THEN
      hr_utility.set_location('Exception:others' || l_proc,565);
      ROLLBACK TO commit_transaction_swi;
      RAISE;

 END commit_transaction;



end hr_transaction_swi;


/
