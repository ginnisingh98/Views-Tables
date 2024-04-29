--------------------------------------------------------
--  DDL for Package HR_TRANSACTION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TRANSACTION_SWI" AUTHID CURRENT_USER as
/* $Header: hrtrnswi.pkh 120.4.12010000.1 2008/07/28 03:54:09 appldev ship $ */
-- Global variables
   g_date_format varchar2(10) := 'RRRR/MM/DD';

--
-- ---------------------------------------------------------------------- --
-- ----------------------<create_transaction>---------------------------- --
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
 ,P_CREATOR_ROLE                    IN       VARCHAR2   DEFAULT NULL
 ,P_LAST_UPDATE_ROLE                IN       VARCHAR2   DEFAULT NULL
 ,P_PARENT_TRANSACTION_ID           IN       NUMBER     DEFAULT NULL
 ,P_RELAUNCH_FUNCTION               IN       VARCHAR2   DEFAULT NULL
 ,P_TRANSACTION_GROUP               IN       VARCHAR2   DEFAULT NULL
 ,P_TRANSACTION_IDENTIFIER          IN       VARCHAR2   DEFAULT NULL
 ,P_TRANSACTION_DOCUMENT            IN       CLOB       DEFAULT NULL
 ,P_VALIDATE                        IN       NUMBER     default hr_api.g_false_num
);
--
-- ---------------------------------------------------------------------- --
-- --------------------<create_transaction_step>------------------------- --
-- ---------------------------------------------------------------------- --
--
procedure create_transaction_step
(
  P_API_NAME                  IN             VARCHAR2
 ,P_API_DISPLAY_NAME          IN             VARCHAR2     DEFAULT NULL
 ,P_PROCESSING_ORDER          IN             NUMBER
 ,P_ITEM_TYPE                 IN             VARCHAR2    DEFAULT NULL
 ,P_ITEM_KEY                  IN             VARCHAR2    DEFAULT NULL
 ,P_ACTIVITY_ID               IN             NUMBER      DEFAULT NULL
 ,P_CREATOR_PERSON_ID         IN             NUMBER
 ,P_UPDATE_PERSON_ID          IN             NUMBER      DEFAULT NULL
 ,P_OBJECT_TYPE               IN             VARCHAR2    DEFAULT NULL
 ,P_OBJECT_NAME               IN             VARCHAR2    DEFAULT NULL
 ,P_OBJECT_IDENTIFIER         IN             VARCHAR2    DEFAULT NULL
 ,P_OBJECT_STATE              IN             VARCHAR2    DEFAULT NULL
 ,P_PK1                       IN             VARCHAR2    DEFAULT NULL
 ,P_PK2                       IN             VARCHAR2    DEFAULT NULL
 ,P_PK3                       IN             VARCHAR2    DEFAULT NULL
 ,P_PK4                       IN             VARCHAR2    DEFAULT NULL
 ,P_PK5                       IN             VARCHAR2    DEFAULT NULL
 ,P_VALIDATE                  IN             NUMBER   	 default hr_api.g_false_num
 ,P_OBJECT_VERSION_NUMBER     IN OUT nocopy  NUMBER
 ,P_TRANSACTION_ID            IN             NUMBER
 ,P_TRANSACTION_STEP_ID       IN             NUMBER
 ,p_information_category        in  	     VARCHAR2    default null
 ,p_information1                in             VARCHAR2    default null
 ,p_information2                in             VARCHAR2    default null
 ,p_information3                in             VARCHAR2    default null
 ,p_information4                in             VARCHAR2    default null
 ,p_information5                in             VARCHAR2    default null
 ,p_information6                in             VARCHAR2    default null
 ,p_information7                in             VARCHAR2    default null
 ,p_information8                in             VARCHAR2    default null
 ,p_information9                in             VARCHAR2    default null
 ,p_information10               in             VARCHAR2    default null
 ,p_information11               in             VARCHAR2    default null
 ,p_information12               in             VARCHAR2    default null
 ,p_information13               in             VARCHAR2    default null
 ,p_information14               in             VARCHAR2    default null
 ,p_information15               in             VARCHAR2    default null
 ,p_information16               in             VARCHAR2    default null
 ,p_information17               in             VARCHAR2    default null
 ,p_information18               in             VARCHAR2    default null
 ,p_information19               in             VARCHAR2    default null
 ,p_information20               in             VARCHAR2    default null
 ,p_information21               in             VARCHAR2    default null
 ,p_information22               in             VARCHAR2    default null
 ,p_information23               in             VARCHAR2    default null
 ,p_information24               in             VARCHAR2    default null
 ,p_information25               in             VARCHAR2    default null
 ,p_information26               in             VARCHAR2    default null
 ,p_information27               in             VARCHAR2    default null
 ,p_information28               in             VARCHAR2    default null
 ,p_information29               in             VARCHAR2    default null
 ,p_information30               in             VARCHAR2    default null
);
--
-- ---------------------------------------------------------------------- --
-- ----------------------<update_transaction>---------------------------- --
-- ---------------------------------------------------------------------- --
--
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
);
--
-- ---------------------------------------------------------------------- --
-- --------------------<update_transaction_step>------------------------- --
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
 ,P_PK1                       IN             VARCHAR2  DEFAULT NULL
 ,P_PK2                       IN             VARCHAR2  DEFAULT NULL
 ,P_PK3                       IN             VARCHAR2  DEFAULT NULL
 ,P_PK4                       IN             VARCHAR2  DEFAULT NULL
 ,P_PK5                       IN             VARCHAR2  DEFAULT NULL
 ,P_VALIDATE                  IN             NUMBER    default hr_api.g_false_num
 ,P_OBJECT_VERSION_NUMBER     IN OUT nocopy  NUMBER
 ,P_TRANSACTION_ID            IN             NUMBER
 ,P_TRANSACTION_STEP_ID       IN             NUMBER
 ,p_information_category        in 	     VARCHAR2   default hr_api.g_varchar2
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
);

--
-- ---------------------------------------------------------------------- --
-- --------------------<delete_transaction_step>------------------------- --
-- ---------------------------------------------------------------------- --
--
procedure delete_transaction_step
(  p_transaction_step_id           in      number
  ,p_person_id                    in      number
  ,p_object_version_number        in      number
  ,p_validate                     in      number    default hr_api.g_false_num
);

--
-- ---------------------------------------------------------------------- --
-- --------------------<set_transaction_context>------------------------- --
-- ---------------------------------------------------------------------- --
--
procedure set_transaction_context(
  p_transaction_id in number);

--
-- ---------------------------------------------------------------------- --
-- -----------------------<set_person_context>--------------------------- --
-- ---------------------------------------------------------------------- --
--

procedure set_person_context(
  p_selected_person_id     in number,
  p_selected_assignment_id in number,
  p_effective_date         in DATE);

--
-- ---------------------------------------------------------------------- --
-- --------------------------<init_profiles>----------------------------- --
-- ---------------------------------------------------------------------- --
--

procedure init_profiles(
  p_person_id in number,
  p_assignment_id in Number,
  p_business_group_Id in Number,
  p_organization_Id in Number,
  p_location_id in Number,
  p_payroll_id in number
);




Type g_txn_details_rec Is Record
  (
    TRANSACTION_ID                  	  NUMBER(15),
    CREATOR_PERSON_ID              	      NUMBER(15),
    STATUS                                VARCHAR2(10),
    FUNCTION_ID                           NUMBER(10),
    TRANSACTION_REF_TABLE                 VARCHAR2(100),
    TRANSACTION_REF_ID                    NUMBER(15),
    TRANSACTION_TYPE                      VARCHAR2(10),
    ASSIGNMENT_ID                         NUMBER(15),
    SELECTED_PERSON_ID                    NUMBER(15),
    ITEM_TYPE                             VARCHAR2(10),
    ITEM_KEY                              VARCHAR2(240),
    EFFECTIVE_DATE                        DATE,
    PROCESS_NAME                          VARCHAR2(30),
    TRANSACTION_STATE                     VARCHAR2(10),
    EFFECTIVE_DATE_OPTION                 VARCHAR2(10)
  );

  g_txn_ctx g_txn_details_rec;

  Type g_person_details_rec Is Record
  (
    FULL_NAME                         VARCHAR2(240),
    PERSON_ID                         NUMBER(10),
    EMPLOYEE_NUMBER                   VARCHAR2(30),
    NPW_NUMBER                        VARCHAR2(30),
    ACTIVE                            VARCHAR2(10),
    ASSIGNMENT_ID                     NUMBER(10),
    ASSIGNMENT_NUMBER                 VARCHAR2(30),
    ASSIGNMENT_TYPE                   VARCHAR2(1),
    PRIMARY_FLAG                      VARCHAR2(30),
    SUPERVISOR_ID                     NUMBER(10),
    SUPERVISOR_NAME                   VARCHAR2(240),
    BUSINESS_GROUP_ID                 NUMBER(15),
    ORGANIZATION_ID                   NUMBER(15),
    BUSINESS_GROUP_NAME               VARCHAR2(240),
    ORGANIZATION_NAME          		  VARCHAR2(240),
    JOB_ID                            NUMBER(15),
    JOB_NAME			              VARCHAR2(700),
    POSITION_ID                       NUMBER(15),
    POSITION_NAME			          VARCHAR2(240),
    LOCATION_ID                       NUMBER(15),
    CURRENCY_CODE			          VARCHAR2(150),
    EMPLOYEE_NUMBER_GENERATION	      VARCHAR2(150),
    APPLICANT_NUMBER_GENERATION       VARCHAR2(150),
    NPW_NUMBER_GENERATION             VARCHAR2(150),
    LEGISLATION_CODE		          VARCHAR2(150),
    PEOPLE_GRP_F_STRUCT_CODE          VARCHAR2(30),
    SECURITY_GROUP_ID                 VARCHAR2(150),
    PAYROLL_ID                        NUMBER(10)
  );

 g_person_ctx g_person_details_rec;


--
-- ---------------------------------------------------------------------- --
-- --------------------------<getDateValue>----------------------------- --
-- ---------------------------------------------------------------------- --
--

-- Removed the Gmis Values and used Hr_Api.<gmisvalue>
Function getDateValue(
  commitNode in xmldom.DOMNode,
  attributeName in VARCHAR2,
  gmisc_value in date default hr_api.g_date)
  return DATE;

--
-- ---------------------------------------------------------------------- --
-- --------------------------<set_status>----------------------------- --
-- ---------------------------------------------------------------------- --
--

Function set_status(
  p_curent_status in VARCHAR2,
  p_dyn_sql_processapi_sts in VARCHAR2)
  return VARCHAR2;

--
-- ---------------------------------------------------------------------- --
-- --------------------------<getVarchar2Value>-------------------------- --
-- ---------------------------------------------------------------------- --
--
Function getVarchar2Value(
  commitNode in xmldom.DOMNode,
  attributeName in VARCHAR2,
  gmisc_value in varchar2 default hr_api.g_varchar2)
  return varchar2;

--
-- ---------------------------------------------------------------------- --
-- --------------------------<getNumberValue>---------------------------- --
-- ---------------------------------------------------------------------- --
--
Function getNumberValue(
  commitNode in xmldom.DOMNode,
  attributeName in VARCHAR2,
  gmisc_value in number default hr_api.g_number)
  return NUMBER;


--
-- ---------------------------------------------------------------------- --
-- -------------------------<delete_transaction>------------------------- --
-- ---------------------------------------------------------------------- --
--
 procedure delete_transaction(
 p_transaction_id in NUMBER,
 p_validate in NUMBER default hr_api.g_false_num);

--
-- ---------------------------------------------------------------------- --
-- -------------------------<process_api_internal>----------------------- --
-- ---------------------------------------------------------------------- --
--
Function process_api_internal(
  p_transaction_id in number,
  p_root_node in xmldom.DOMNode,
  p_validate in number default hr_api.g_false_num,
  p_effective_date in DATE,
  p_return_status in varchar2)
  return varchar2;

--
-- ---------------------------------------------------------------------- --
-- -----------------------<convertCLOBtoXMLElement>---------------------- --
-- ---------------------------------------------------------------------- --
--
function convertCLOBtoXMLElement(
 p_document in CLOB)
 return xmldom.DOMElement;

--
-- ---------------------------------------------------------------------- --
-- --------------------------<process_api_call>-------------------------- --
-- ---------------------------------------------------------------------- --
--
Function process_api_call(
  p_transaction_step_id in NUMBER,
  p_api_name in VARCHAR2,
  p_root_node in xmldom.DOMNode,
  p_validate in number default hr_api.g_false_num,
  p_effective_date in DATE,
  p_return_status in varchar2)
  return varchar2;

--
-- ---------------------------------------------------------------------- --
-- --------------------------<setTransactionStatus>----------------------- --
-- ---------------------------------------------------------------------- --
--
procedure setTransactionStatus(
  p_transaction_id in NUMBER,
  p_transaction_ref_table in varchar2,
  p_currentTxnStatus in varchar2,
  p_proposedTxnStatus in varchar2,
  p_propagateMessagePub in number,
  p_status out nocopy varchar2);

--
-- ---------------------------------------------------------------------- --
-- ---------------------------<isDeleteAllowed>-------------------------- --
-- ---------------------------------------------------------------------- --
--
function isDeleteAllowed(p_transaction_id in number,
                       p_transaction_status in varchar2,
                       p_notification_id in number,
                       p_authenticateNtf in number,
                       p_propagateMessagePub in number)
return varchar2;

--
-- ---------------------------------------------------------------------- --
-- ---------------------------<isEditAllowed>-------------------------- --
-- ---------------------------------------------------------------------- --
--
function isEditAllowed(p_transaction_id in number,
                     p_transaction_status in varchar2,
                     p_notification_id in number,
                     p_authenticateNtf in number,
                     p_loginPersonId in number,
                     p_loginPersonBgId in number,
                     p_propagateMessagePub in number)
return varchar2;
--
-- ---------------------------------------------------------------------- --
-- ---------------------------<cancelAction>-------------------------- --
-- ---------------------------------------------------------------------- --
--
procedure cancelAction(p_transaction_id in number);

--
-- ---------------------------------------------------------------------- --
-- ---------------------------<deleteAction>-------------------------- --
-- ---------------------------------------------------------------------- --
--
procedure deleteAction(p_transaction_id in number);

--
-- ---------------------------------------------------------------------- --
-- ---------------------------<isTxnOwner>-------------------------- --
-- ---------------------------------------------------------------------- --
--
function isTxnOwner(p_transaction_id in number,
                    p_person_id in number) return boolean;

--
-- ---------------------------------------------------------------------- --
-- -------------------------delete_transaction_steps>-------------------- --
-- ---------------------------------------------------------------------- --
--
procedure delete_transaction_children(
 p_transaction_id in NUMBER,
 p_validate in NUMBER default hr_api.g_false_num);

--
-- ---------------------------------------------------------------------- --
-- --------------------------<commit_transaction>----------------------- --
-- ---------------------------------------------------------------------- --
--
Function commit_transaction(
  p_transaction_id in NUMBER,
  p_validate in number default hr_api.g_false_num,
  p_effective_date in DATE default SYSDATE)  return VARCHAR2;


procedure setTransactionStatus(
  p_transaction_id in NUMBER,
  p_approver_comments in varchar2,
  p_transaction_ref_table in varchar2,
  p_currentTxnStatus in varchar2,
  p_proposedTxnStatus in varchar2,
  p_propagateMessagePub in number,
  p_status out nocopy varchar2);

procedure commit_transaction(
  p_transaction_id in NUMBER,
  p_validate in number default hr_api.g_false_num,
  p_effective_date in DATE default SYSDATE,
  p_process_all_on_error in number default hr_api.g_false_num,
  p_status out nocopy varchar2,
  p_error_log in out nocopy CLOB);

--
-- ---------------------------------------------------------------------- --
-- --------------------------<initiatorDeleteAction>----------------------- --
-- ---------------------------------------------------------------------- --
--

procedure initiatorDeleteAction(p_transaction_id in number);


end hr_transaction_swi;

/
