--------------------------------------------------------
--  DDL for Package AME_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_UTIL" AUTHID CURRENT_USER as
/* $Header: ameoutil.pkh 120.2.12010000.2 2009/03/11 11:28:57 prasashe ship $ */
  /* user-defined data types */
  /* The id and string types are for various record definitions and local-variable declarations. */
  charValue varchar2(1);
  parameterValue varchar2(320);
  boilerplateValue varchar2(80);
  longBoilerplateValue varchar2(300);
  attributeValue varchar2(100);
  stringValue varchar2(100);
  longStringValue varchar2(500);
  longestStringValue varchar2(4000);
  subtype charType is charValue%type;
  subtype parameterType is parameterValue%type;
  subtype boilerplateType is boilerplateValue%type;
  subtype attributeValueType is attributeValue%type;
  subtype stringType is stringValue%type;
  subtype longStringType is longStringValue%type;
  subtype longestStringType is longestStringValue%type;
  /*
    The longBoilerplateType and longBoilerplateList datatypes are for
    boilerplate strings that are too long to be stored as AK attributes.  The
    English-language values of such strings should not exceed 100 bytes
    (characters), so that their translates values will not exceed
    300 bytes.  Always fetch a long-boilerplate string into a local variable of
    type longBoilerplateType or longBoilerplateList.
  */
  subtype longBoilerplateType is longBoilerplateValue%type;
  type longBoilerplateList is table of longBoilerplateType index by binary_integer;
  parameterTypeLength constant integer := 320;
  attributeValueTypeLength constant integer := 100;
  stringTypeLength constant integer := 100;
  longStringTypeLength constant integer := 500;
  longestStringTypeLength constant integer := 4000;
  type idStringRecord is record(
    id integer,
    string stringType);
  type attributeValueList is table of attributeValueType index by binary_integer;
  type charList is table of charType index by binary_integer;
  type dateList is table of date index by binary_integer;
  type idList is table of integer index by binary_integer;
  type idStringTable is table of idStringRecord index by binary_integer;
  type numberList is table of number index by binary_integer;
  type boilerplateList is table of boilerplateType index by binary_integer;
  type stringList is table of stringType index by binary_integer;
  type longStringList is table of longStringType index by binary_integer;
  type longestStringList is table of longestStringType index by binary_integer;
  /* engine and API types */
  type approvalGroupMemberRecord is record(
    group_id integer,
    name varchar2(320),
    orig_system varchar2(48),
    orig_system_id integer);
  type approvalProcessRecord is record(
    line_item_id integer,
    rule_id integer,
    rule_type integer,
    action_type_id integer,
    parameter parameterType,
    priority integer,
    approver_category varchar2(1));
  type approverRecord is record(
    user_id fnd_user.user_id%type,
    person_id per_all_people_f.person_id%type,
    first_name per_all_people_f.first_name%type,
    last_name per_all_people_f.last_name%type,
    api_insertion varchar2(1),
    authority varchar2(1),
    approval_status varchar2(50),
    approval_type_id integer,
    group_or_chain_id integer,
    occurrence integer,
    source varchar2(500));
  type approverRecord2 is record(
    name varchar2(320),
    orig_system varchar2(30),
    orig_system_id number,
    display_name varchar2(360),
    approver_category varchar2(1),
    api_insertion varchar2(1),
    authority varchar2(1),
    approval_status varchar2(50),
    action_type_id integer,
    group_or_chain_id integer,
    occurrence integer,
    source varchar2(500),
    item_class ame_item_classes.name%type,
    item_id ame_temp_old_approver_lists.item_id%type,
    item_class_order_number integer,
    item_order_number integer,
    sub_list_order_number integer,
    action_type_order_number integer,
    group_or_chain_order_number integer,
    member_order_number integer,
    approver_order_number integer);
  type attributeValueRecord is record(
    attribute_value_1 attributeValueType,
    attribute_value_2 attributeValueType,
    attribute_value_3 attributeValueType);
  type handlerTransStateRecord is record(
    handler_name stringType,
    state stringType);
  type insertionRecord is record(
    order_type varchar2(50),
    parameter ame_temp_insertions.parameter%type,
    api_insertion varchar2(1),
    authority varchar2(1),
    description ame_temp_insertions.description%type);
  type insertionRecord2 is record(
    item_class ame_item_classes.name%type,
    item_id ame_temp_old_approver_lists.item_id%type,
    action_type_id integer,
    group_or_chain_id integer,
    order_type varchar2(50),
    parameter ame_temp_insertions.parameter%type,
    api_insertion varchar2(1),
    authority varchar2(1),
    description ame_temp_insertions.description%type);
/*
AME_STRIPING
  type lineItemStripeRuleRecord is record(
    line_item_id integer,
    stripe_set_id integer,
    rule_id integer,
    rule_type integer,
    action_type_id integer,
    parameter parameterType,
    priority integer);
*/
  type orderRecord is record(
    order_type varchar2(50),
    parameter ame_temp_insertions.parameter%type,
    description varchar2(200));
  type workflowLogRecord is record(
    package_name varchar2(50),
    routine_name varchar2(50),
    log_id integer,
    transaction_id varchar2(50),
    exception_number integer,
    exception_string longestStringType);
  /* Record to represent a engine approver tree node */
  type approverTreeRecord is record(
    parent_index   integer,
    child_index    integer,
    sibling_index  integer,
    approver_index integer,
    tree_level     integer,
    tree_level_id  varchar2(320),
    order_number   integer,
    min_order      integer,
    max_order      integer,
    status         integer,
    is_suspended    varchar2(1));
  /* Data Type to store the engine approver tree */
  type approversTreeTable is table of approverTreeRecord index by binary_integer;
  type approvalGroupMembersTable is table of approvalGroupMemberRecord index by binary_integer;
  type approvalProcessTable is table of approvalProcessRecord index by binary_integer;
  type approversTable is table of approverRecord index by binary_integer;
  type approversTable2 is table of approverRecord2 index by binary_integer;
  type sVAttributeValuesTable is table of attributeValueType index by binary_integer;
  type attributeValuesTable is table of attributeValueRecord index by binary_integer;
  type exceptionLogTable is table of ame_exceptions_log%rowtype index by binary_integer;
  type handlerTransStateTable is table of handlerTransStateRecord index by binary_integer;
  type insertionsTable is table of insertionRecord index by binary_integer;
  type insertionsTable2 is table of insertionRecord2 index by binary_integer;

/*
AME_STRIPING
  type lineItemStripeRuleTable is table of lineItemStripeRuleRecord index by binary_integer;
*/
  type ordersTable is table of orderRecord index by binary_integer;
  type parametersTable is table of parameterType index by binary_integer;
  type workflowLogTable is table of workflowLogRecord index by binary_integer;
  /* misc. types */
  type queryCursor is ref cursor;
  /* Constants used by the engine to process the approver tree */
  noChildIndex     constant integer := -1;
  noParentIndex    constant integer := -1;
  noSiblingIndex   constant integer := -1;
  noApproverIndex  constant integer := -1;
  invalidTreeIndex constant integer := -1;
  unknownStatus    constant integer := -1;
  startedStatus    constant integer :=  3;
  notStartedStatus constant integer :=  2;
  completedStatus  constant integer :=  1;
  firstAmongEquals constant boolean := true;
  lastAmongEquals  constant boolean := false;
  minimumApproverOrderNumber constant integer := 1;
  /* misc. constants */
  ameShortName constant varchar2(3) := 'AME';
  defaultDateFormatModel constant varchar2(50) := 'DD-MM-YYYY';
  oneSecond constant number := 1/86400;
  mandAttActionTypeId constant integer := -1;
  seededDataCreatedById constant integer := 1;
  yes constant varchar(3) := 'yes';
  no constant varchar2(2) := 'no';
  testTrans constant varchar2(10) := 'testTrans';
  realTrans constant varchar2(10) := 'realTrans';
  /* special wf_roles.name values */
  invalidApproverWfRolesName constant varchar2(50) := 'AME_INVALID_APPROVER';
  /* ICX constants */
  developerResponsibility constant integer := 5;
  appAdminResponsibility constant integer := 4;
  genBusResponsibility constant integer := 3;
  limBusResponsibility constant integer := 2;
  readOnlyResponsibility constant integer := 1;
  noResponsibility constant integer := 0;
  devRespKey constant varchar2(50) := 'AMEDEVELOPER';
  appAdminRespKey constant varchar2(50) := 'AMEAPPADM';
  genBusUserRespKey constant varchar2(50) := 'AMEGENUSER';
  limBusUserRespKey constant varchar2(50) := 'AMELIMUSER';
  readOnlyUserRespKey constant varchar2(50) := 'AMEROUSER';
  webFunction constant varchar2(17) := 'AME_WEB_APPROVALS';
  attributeCode constant varchar2(26) := 'AME_INTERNAL_TRANS_TYPE_ID';
  /* per fnd app id */
  perFndAppId constant integer := 800;
  /* generalized-approver-type (GAT) constants */
  /* GAT originating-system constants */
  fndRespOrigSystem constant varchar2(8) := 'FND_RESP';
  fndUserOrigSystem constant varchar2(7) := 'FND_USR';
  perOrigSystem constant varchar2(3) := 'PER';
  posOrigSystem constant varchar2(3) := 'POS';
  /* GAT lookup types */
  origSystemLookupType constant fnd_lookups.lookup_type%type := 'FND_WF_ORIG_SYSTEMS';
  /* GAT approver categories */
  approvalApproverCategory constant varchar2(1) := 'A';
  fyiApproverCategory constant varchar2(1) := 'F';
  /* GAT other constants */
  anyApproverType constant integer := -1;
  approverWfRolesName constant varchar2(50) := 'wf_roles_name';
  /* developer-key constants */
  devKeyPlaceHolder constant varchar2(9) := 'CHANGE_ME';
  seededKeyPrefix constant varchar2(4) := 'SEED';
  /* chain-of-authority ordering modes */
  parallelChainsMode constant varchar2(1) := 'P';
  serialChainsMode constant varchar2(1) := 'S';
  /* The following values are the only allowed values for
     ame_approval_group_config.voting_regime.  All of the values other
     than orderNumberVoting are also allowed for
     ame_action_type_config.voting_regime. */
  consensusVoting constant varchar2(1) := 'C';
  firstApproverVoting constant varchar2(1) := 'F';
  orderNumberVoting constant varchar2(1) := 'O';
  serializedVoting constant varchar2(1) := 'S';
  /*
    None of the empty[whatever] variables below should ever be overwritten. They
    are only to be used as default arguments where empty defaults are required.
  */
  emptyApproverRecord approverRecord;
  emptyApproverRecord2 approverRecord2;
  emptyApproversTable approversTable;
  emptyApproversTable2 approversTable2;
  emptyDateList dateList;
  emptyDbmsSqlVarchar2Table dbms_sql.varchar2_table;
  emptyExceptionLogTable exceptionLogTable;
  emptyIdList idList;
  emptyIdStringTable idStringTable;
  emptyInsertionRecord insertionRecord;
  emptyInsertionRecord2 insertionRecord2;
  emptyInsertionsTable insertionsTable;
  emptyInsertionsTable2 insertionsTable2;
  emptyParametersTable parametersTable;
  emptyOrderRecord orderRecord;
  emptyOrdersTable ordersTable;
  emptyOwaUtilIdentArr owa_util.ident_arr;
  emptyCharList charList;
  emptyAttributeValueList attributeValueList;
  emptyStringList stringList;
  emptyLongStringList longStringList;
  emptyLongestStringList longestStringList;
  emptyWorkflowLogTable workflowLogTable;
  /* approver types */
  approverPersonId constant varchar2(50) := 'person_id';
  approverUserId constant varchar2(50) := 'user_id';
  approverOamGroupId constant varchar2(50) := 'OAM_group_id';
  /*
    The following constants are the only allowed values in an approverRecord2's
    api_insertion field.  They have the following meanings.  (1) An
    apiAuthorityInsertion is an insertion into the chain of authority requiring
    the chain to jump at the insertion.  (2) An apiInsertion is an "ad hoc"
    insertion.  If it occurs in the chain of authority, it does not require the
    chain to jump at the insertion.  The chain skips over the ad-hoc insertion.
    (3) An oamGenerated approver is not an insertion, but is generated by the
    rules in OAM applying to the transaction.
  */
  apiAuthorityInsertion constant varchar2(1) := 'A';
  apiInsertion constant varchar2(1) := 'Y';
  oamGenerated constant varchar2(1) := 'N';
  /*
    The following constants are the only allowed values in an approverRecord2's
    authority field.  Note that the constants are backwards compatible with the
    original Y/N values, and are also ordered so that one can select approvers
    in the proper order out of ame_temp_approval_processes.
  */
  preApprover constant varchar2(1) := 'N';
  authorityApprover constant varchar2(1) := 'Y';
  postApprover constant varchar2(1) := 'Z';
  /*
    The following constants are the only allowed values in an approverRecord2's
    approval_status fields.  Note that there is no 'D' on the end of 'APPROVE'
    in the value of approvedStatus; this is intentional.
  */
  approveAndForwardStatus constant varchar2(20) := 'APPROVE AND FORWARD';
  approvedStatus constant varchar2(20) := 'APPROVE';
  beatByFirstResponderStatus constant varchar2(50) := 'BEAT BY FIRST RESPONDER';
  clearExceptionsStatus constant varchar2(20) := 'CLEAR EXCEPTIONS';
  exceptionStatus constant varchar2(20) := 'EXCEPTION';
  forwardStatus constant varchar2(20) := 'FORWARD';
  noResponseStatus constant varchar2(20) := 'NO RESPONSE';
  notifiedStatus constant varchar2(20) := 'NOTIFIED';
  nullStatus constant varchar2(1) := null;
  rejectStatus constant varchar2(20) := 'REJECT';
  repeatedStatus constant varchar2(20) := 'REPEATED';
  suppressedStatus constant varchar2(20) := 'SUPPRESSED';
  /* New status added for asynchronous parallel approver functionality*/
  notifiedByRepeatedStatus constant varchar2(20) := 'NOTIFIEDBYREPEATED';
  approvedByRepeatedStatus constant varchar2(20) := 'APPROVEDBYREPEATED';
  rejectedByRepeatedStatus constant varchar2(20) := 'REJECTEDBYREPEATED';
  /*
    The following values are components of the only allowed values of the source field
    of an approverRecord2, when the record's api_insertion value is not ame_util.oamGenerated.
  */
  approveAndForwardInsertion constant varchar2(20) := 'APPROVE_AND_FORWARD';
  forwardInsertion constant varchar2(20) := 'FORWARD';
  specialForwardInsertion constant varchar2(20) := 'SPECIAL FORWARD';
  otherInsertion constant varchar2(20) := 'OTHER';
  surrogateInsertion constant varchar2(20) := 'SURROGATE';
  /* The following value is prepended to the source field of a deleted approver. */
  apiSuppression constant varchar2(20) := 'SUPPRESSED';
  /*
    The following constants are the only allowed values in the fields of the
    forwardingBehavior configuration variable:
  */
  forwardeeOnly constant varchar2(20) := 'FORWARDEE_ONLY';
  forwarderAndForwardee constant varchar2(20) := 'FORWARDER_FORWARDEE';
  ignoreForwarding constant varchar2(20) := 'IGNORE';
  remand constant varchar2(20) := 'REMAND';
  repeatForwarder constant varchar2(20) := 'REPEAT_FORWARDER';
  skipForwarder constant varchar2(20) := 'SKIP_FORWARDER';
  /*
    The following constants are the only allowed values of the repeatedApprovers
    configuration variable:
  */
  oncePerTransaction constant varchar2(50) := 'ONCE_PER_TRANSACTION';
  oncePerItemClass constant varchar2(50) := 'ONCE_PER_ITEM_CLASS';
  oncePerItem constant varchar2(50) := 'ONCE_PER_ITEM';
  oncePerSublist  constant varchar2(50) := 'ONCE_PER_SUBLIST';
  oncePerActionType constant varchar2(50) := 'ONCE_PER_ACTION_TYPE';
  oncePerGroupOrChain constant varchar2(50) := 'ONCE_PER_GROUP_OR_CHAIN';
  eachOccurrence constant varchar2(50) := 'EACH_OCCURRENCE';
  /*
    The following constants are the only allowed values of the REJECTION_RESPONSE
    mandatory attribute.
  */
  continueAllOtherItems constant varchar2(50) := 'CONTINUE_ALL_OTHER_ITEMS';
  continueOtherSubItems constant varchar2(50) := 'CONTINUE_OTHER_SUBORDINATE_ITEMS';
  stopAllItems constant varchar2(50) := 'STOP_ALL_ITEMS';
  /*
    The ame_engine.getForwardingBehavior function requires a forwarder type
    and a forwardee type.  The values below are allowed.  When the forwarder
    is a chainOfAuthorityForwarder, alreadyInListForwardee refers to an
    approver who is already in the approver list, but not in the same chain
    of authority as the forwarder.  (When the forwarder is an adHocForwarder,
    alreadyInListForwardee is the only allowed value.)
  */
  chainOfAuthorityForwarder constant varchar2(50) := 'CHAIN_FORWARDER';
  adHocForwarder constant varchar2(50) := 'AD_HOC_FORWARDER';
  previousSameChainForwardee constant varchar2(50) := 'SAME_CHAIN_PREVIOUS_FORWARDEE';
  subordSameHierarchyForwardee constant varchar2(50) := 'SUBORDINATE_SAME_HIERARCHY';
  alreadyInListForwardee constant varchar2(50) := 'ALREADY_IN_LIST';
  /*
  The API inserts the following constants in the ame_approvals_history table.  These
  values should never appear in an approverRecord.
  */
  /* pseudo-null constants for adhoc insertions */
  nullInsertionActionTypeId constant integer := -1;
  nullInsertionGroupOrChainId constant integer := -1;
  /* pseudo-null constants for adhoc insertions. For backward compatibility only. These 2 constants
     should not be used in the AME code at all. */
  adHocInsertionApprovalTypeId constant integer := -1;
  adHocInsertionGroupOrChainId constant integer := -1;
  /* pseudo-null constants for ame_approvals_history entries */
  nullHistoryActionTypeId constant integer := 0.5;
  nullHistoryGroupOrChainId constant integer := 0.5;
  nullHistoryOccurrence constant integer := 0.5;
  nullHistoryStatus constant varchar2(20) := 'NULL';
  nullHistorySource constant varchar2(20) := 'NULL';
  /*
    The following constants are used by the API to identify types of order
    relations for ad-hoc insertions.  They are the only valid values in the
    orderRecord record's order_type field.
  */
  absoluteOrder constant varchar2(50) := 'absolute order';
  absoluteOrderDescription constant varchar2(200) :=
    'Regardless of changes in the approver list''s membership, give the new approver ' ||
    'the following order number:  ';
  afterApprover constant varchar2(50) := 'after approver';
  afterApproverDescription constant varchar2(200) :=
    'Always put the new approver right after the following approver:  ';
  beforeApprover constant varchar2(50) := 'before approver';
  beforeApproverDescription constant varchar2(200) :=
    'Always put the new approver right before the following approver:  ';
  firstAuthority constant varchar2(50) := 'first authority';
  firstAuthorityDescription constant varchar2(200) :=
    'Start all chains of authority at the new approver.';
  firstAuthorityParameter constant varchar2(100) := 'first authority';
  firstPostApprover constant varchar2(50) := 'first post-approver';
  firstPostApproverDescription constant varchar2(200) := 'Make the approver the first post-approver.';
  firstPostParameter constant varchar2(50) := 'first_post_approver';
  firstPreApprover constant varchar2(50) := 'first pre-approver';
  firstPreApproverDescription constant varchar2(200) := 'Make the approver the first pre-approver.';
  firstPreParameter constant varchar2(50) := 'first_pre_approver';
  lastPostApprover constant varchar2(50) := 'last post-approver';
  lastPostApproverDescription constant varchar2(200) := 'Make the approver the last post-approver.';
  lastPostParameter constant varchar2(50) := 'last_post_approver';
  lastPreApprover constant varchar2(50) := 'last pre-approver';
  lastPreApproverDescription constant varchar2(200) := 'Make the approver the last pre-approver.';
  lastPreParameter constant varchar2(50) := 'last_pre_approver';
  /*
    The following constants are the only placeholders that may appear in the
    query strings defining an attribute for a given application, i.e. in
    the ame_attribute_usages.query_string column.
  */
  transactionIdPlaceholder constant varchar2(50) := ':transactionId';
  /* ame_attributes.attribute_type allowed values */
  numberAttributeType constant varchar2(20) := 'number';
  stringAttributeType constant varchar2(20) := 'string';
  dateAttributeType constant varchar2(20) := 'date';
  booleanAttributeType constant varchar2(20) := 'boolean';
  currencyAttributeType constant varchar2(20) := 'currency';
  /* boolean attribute allowed values */
  booleanAttributeTrue constant varchar2(10) := 'true';
  booleanAttributeFalse constant varchar2(10) := 'false';
  /* rule type labels */
  ruleTypeLabel0 constant varchar2(50) := 'combination';
  ruleTypeLabel1 constant varchar2(50) := 'list-creation rule';
  ruleTypeLabel2 constant varchar2(50) := 'list-creation exception';
  ruleTypeLabel3 constant varchar2(50) := 'list-modification rule';
  ruleTypeLabel4 constant varchar2(50) := 'substitution';
  ruleTypeLabel5 constant varchar2(50) := 'pre-list approval-group rule';
  ruleTypeLabel6 constant varchar2(50) := 'post-list approval-group rule';
  ruleTypeLabel7 constant varchar2(50) := 'production';
  /* ame_rules.rule_type allowed values */
  combinationRuleType constant integer := 0;
  authorityRuleType constant number := 1;
  exceptionRuleType constant number := 2;
  listModRuleType constant number := 3;
  substitutionRuleType constant number := 4;
  preListGroupRuleType constant number := 5;
  postListGroupRuleType constant number := 6;
  productionRuleType constant integer := 7;
  /* ame_conditions.condition_type allowed values */
  ordinaryConditionType constant varchar2(20) := 'auth';
  exceptionConditionType constant varchar2(20) := 'pre';
  listModConditionType constant varchar2(20) := 'post';
  /* dynamic-action-description bind variables */
  actionParameterOne constant varchar2(20) := ':parameterOne';
  actionParameterTwo constant varchar2(20) := ':parameterTwo';
  /* constants for list-modification conditions */
  anyApprover constant varchar2(50) := 'any_approver';
  finalApprover constant varchar2(50) := 'final_approver';
  /* The following 2 constants only to be used for backward comp. */
  dynamicPostApprover constant varchar2(50) := 'dynamic post-approver';
  dynamicPreApprover constant varchar2(50) := 'dynamic pre-approver';
  /* pseudo-boolean constants */
  booleanTrue constant varchar2(1) := 'Y';
  booleanFalse constant varchar2(1) := 'N';
  /*
    ame_attribute_usages.user_editable possible values:
    (1) booleanTrue:  the user can edit the query string (usage), but has not
    (2) booleanFalse:  the user cannot edit the query string
    (3) userEdited:  the user has edited the query string.
    If the value is booleanTrue or booleanFalse, it's ok to overwrite the usage when
    installing a patch.  If the value is userEdited, the patch should not overwrite
    the query string.
  */
  userEdited constant varchar2(1) := 'Z';
  /* mandatory-attribute names */
  allowAutoApprovalAttribute constant varchar2(50) := 'ALLOW_REQUESTOR_APPROVAL';
  allowDeletingOamApprovers constant varchar2(50) := 'ALLOW_DELETING_RULE_GENERATED_APPROVERS';
  atLeastOneRuleAttribute constant varchar2(50) := 'AT_LEAST_ONE_RULE_MUST_APPLY';
  transactionDateAttribute constant varchar2(50) := 'TRANSACTION_DATE';
  transactionRequestorAttribute constant varchar2(50) := 'TRANSACTION_REQUESTOR_PERSON_ID';
  transactionReqUserAttribute constant varchar2(50) := 'TRANSACTION_REQUESTOR_USER_ID';
  transactionOrgAttribute constant varchar2(50) := 'TRANSACTION_ORG_ID';
  transactionGroupAttribute constant varchar2(50) := 'TRANSACTION_GROUP_ID';
  transactionSetOfBooksAttribute constant varchar2(50) := 'TRANSACTION_SET_OF_BOOKS_ID';
  effectiveRuleDateAttribute constant varchar2(50) := 'EFFECTIVE_RULE_DATE';
  useWorkflowAttribute constant varchar2(50) := 'USE_WORKFLOW';
  workflowItemKeyAttribute constant varchar2(50) := 'WORKFLOW_ITEM_KEY';
  workflowItemTypeAttribute constant varchar2(50) := 'WORKFLOW_ITEM_TYPE';
  restrictiveLIEvalAttribute constant varchar2(50) := 'USE_RESTRICTIVE_LINE_ITEM_EVALUATION';
  evalPrioritiesPerLIAttribute constant varchar2(50) := 'EVALUATE_PRIORITIES_PER_LINE_ITEM';
  restrictiveItemEvalAttribute constant varchar2(50) := 'USE_RESTRICTIVE_ITEM_EVALUATION';
  evalPrioritiesPerItemAttribute constant varchar2(50) := 'EVALUATE_PRIORITIES_PER_ITEM';
  rejectionResponseAttribute constant varchar2(50) := 'REJECTION_RESPONSE';
  repeatSubstitutionsAttribute constant varchar2(50) := 'REPEAT_SUBSTITUTIONS';
  /* attribute names referenced by job-level handlers */
  jobLevelStartingPointAttribute constant varchar2(50) := 'JOB_LEVEL_NON_DEFAULT_STARTING_POINT_PERSON_ID';
  firstStartingPointAttribute constant varchar2(50) := 'FIRST_STARTING_POINT_PERSON_ID';
  secondStartingPointAttribute constant varchar2(50) := 'SECOND_STARTING_POINT_PERSON_ID';
  includeAllApproversAttribute constant varchar2(50) := 'INCLUDE_ALL_JOB_LEVEL_APPROVERS';
  lineItemStartingPointAttribute constant varchar2(50) := 'LINE_ITEM_STARTING_POINT_PERSON_ID';
  /* attribute names referenced by position handler, and allowed values */
  positionSortMethodAttribute constant varchar2(50) := 'POSITION_APPROVER_SORT_METHOD';
  orderedPositionSort constant varchar2(50) := 'ordered';
  randomPositionSort constant varchar2(50) := 'random';
  simplePosStartPointAttribute constant varchar2(50) := 'SIMPLE_POS_NON_DEFAULT_STARTING_POINT_PERSON_ID';
  /* attribute names referenced by position handler */
  nonDefStartingPointPosAttr constant varchar2(50) := 'NON_DEFAULT_STARTING_POINT_POSITION_ID';
  nonDefPosStructureAttr constant varchar2(50) := 'NON_DEFAULT_POSITION_STRUCTURE_ID';
  transactionReqPositionAttr constant varchar2(50) := 'TRANSACTION_REQUESTOR_POSITION_ID';
  topPositionIdAttribute constant varchar2(50) := 'TOP_POSITION_ID';
  /* attribute names referenced by approval-group handers */
  allowEmptyGroupAttribute constant varchar2(50) := 'ALLOW_EMPTY_APPROVAL_GROUPS';
  /* attribute names referenced by supervisory handler */
  supStartingPointAttribute constant varchar2(50) := 'SUPERVISORY_NON_DEFAULT_STARTING_POINT_PERSON_ID';
  topSupPersonIdAttribute constant varchar2(50) := 'TOP_SUPERVISOR_PERSON_ID';
  /* referenced handler names */
  absoluteJobLevelHandlerName constant varchar2(50) := 'ame_absolute_job_level_handler';
  simplePositionHandlerName constant varchar2(50) := 'ame_simple_position_handler';
  /* referenced approval-type names */
  preApprovalTypeName constant varchar2(50) := 'pre-chain-of-authority approvals';
  absoluteJobLevelTypeName constant varchar2(50) := 'absolute job level';
  relativeJobLevelTypeName constant varchar2(50) := 'relative job level';
  supervisoryLevelTypeName constant varchar2(50) := 'supervisory level';
  positionTypeName constant varchar2(50) := 'hr position';
  positionLevelTypeName constant varchar2(50) := 'hr position level';
  managerFinalApproverTypeName constant varchar2(50) := 'manager then final approver';
  finalApproverOnlyTypeName constant varchar2(50):= 'final approver only';
  lineItemJobLevelTypeName constant varchar2(50) := 'line-item job-level chains of authority';
  dualChainsAuthorityTypeName constant varchar2(50) := 'dual chains of authority';
  groupChainApprovalTypeName constant varchar2(50) := 'approval-group chain of authority';
  nonFinalAuthority constant varchar2(50) := 'nonfinal authority';
  finalAuthorityTypeName constant varchar2(50) := 'final authority';
  substitutionTypeName constant varchar2(50) := 'substitution';
  postApprovalTypeName constant varchar2(50) := 'post-chain-of-authority approvals';
  productionActionTypeName constant varchar2(50) := 'production rule';
  /* referenced item-class names */
  costCenterItemClassName constant varchar2(100) := 'cost center';
  headerItemClassName constant varchar2(100) := 'header';
  lineItemItemClassName constant varchar2(100) := 'line item';
  /* configuration-variable names */
  adminApproverConfigVar constant varchar2(50) := 'adminApprover';
  purgeFrequencyConfigVar constant varchar2(50) := 'purgeFrequency';
  useWorkflowConfigVar constant varchar2(50) := 'useWorkflow';
  helpPathConfigVar constant varchar2(50) := 'helpPath';
  htmlPathConfigVar constant varchar2(50) := 'htmlPath';
  imagePathConfigVar constant varchar2(50) := 'imagePath';
  portalUrlConfigVar constant varchar2(50) := 'portalUrl';
  distEnvConfigVar constant varchar2(50) := 'distributedEnvironment';
  curConvWindowConfigVar constant varchar2(50) := 'currencyConversionWindow';
  forwardingConfigVar constant varchar2(50) := 'forwardingBehaviors';
  repeatedApproverConfigVar constant varchar2(50) := 'repeatedApprovers';
  allowAllApproverTypesConfigVar constant varchar2(30) := 'allowAllApproverTypes';
  allowFyiNotificationsConfigVar constant varchar2(30) := 'allowFyiNotifications';
  rulePriorityModesConfigVar constant varchar2(50) := 'rulePriorityModes';
  productionConfigVar constant varchar2(50) := 'productionFunctionality';
  allowAllICRulesConfigVar constant varchar2(50) := 'allowAllItemClassRules';
  /* productionFunctionality allowed values */
  noProductions constant varchar2(50) := 'none';
  perApproverProductions constant varchar2(50) := 'approver';
  perTransactionProductions constant varchar2(50) := 'transaction';
  allProductions constant varchar2(50) := 'all';
  /* productionFunctionality exception */
  productionException exception;
  /* chain-of-authority ordering modes */
  sequentialChainsMode constant varchar2(1) := 'S';
  /*
    allowedValues for headerListParallelizationMode configuration variable
  */
  headerAfterItems constant varchar2(1) := 'A';
  headerBeforeItems constant varchar2(1) := 'B';
  headerWithFirstItems constant varchar2(1) := 'W';
  /*
    The following constants are the only allowed values for the
    ame_item_class_usages.item_class_sublist_mode column.
  */
  parallelSublists constant varchar2(1) := 'P';
  preFirst constant varchar2(1) := 'R';
  preAndAuthorityFirst constant varchar2(1) := 'A';
  serialSublists constant varchar2(1) := 'S';
  /*
    The following constants are the only allowed values
    for the ame_item_class_usages.item_class_par_mode
    column.
  */
  parallelItems constant varchar2(1) := 'P';
  serialItems constant varchar2(1) := 'S';
/*
AME_STRIPING
  useRuleStripingConfigVar constant varchar2(50) := 'useRuleStriping';
*/
  /* rulePriorityModes */
  disabledRulePriorityDefVal constant varchar2(100) := 'disabled:disabled:disabled:disabled:disabled:disabled:disabled:disabled';
  disabledRulePriority constant varchar2(50) := 'disabled';
  absoluteRulePriority constant varchar2(50) := 'absolute';
  relativeRulePriority constant varchar2(50) := 'relative';
  /* sourceDescriptionOut */
  /* one or more rules required the approver. */
  ruleGeneratedSource constant varchar2(50) := 'rule generated' ;
  /* Another approver forwarded to this approver, or this approver forwarded to another approver, and
  the repeatedApprover configuration variable's value required that this approver re-approve after the
  forwardee approves. */
  forwardeeSource constant varchar2(50) :=  'forwardee';
  /* An end user of the originating application inserted the approver from within the application. */
  inserteeSource constant varchar2(50) := 'insertee';
  /* Another approver was unresponsive, and the originating application so informed AME.  AME
  added this approver to serve as a surrogate for the unresponsive approver. */
  surrogateSource constant varchar2(50) :='surrogate';
  /* The calling application deleted the approver (via an API call). */
  suppressionSource constant varchar2(50) := 'suppressed by end user';
  /* versionStartDate stuff */
  objectVersionException exception;
  versionDateFormatModel constant varchar2(50) := 'YYYY:MM:DD:HH24:MI:SS';
  /* Approver-query-handler procecdures should raise this exception when they fetch more than 50 rows. */
  tooManyApproversException exception;
  /* Approver-query-handler procecdures should raise this exception when they fetch zero rows. */
  zeroApproversException exception;
  /* transaction-type cookie name */
  transactionTypeCookie constant varchar2(50) := 'AME_TRANSACTION_TYPE';
  /* admin-activity types */
  applicationAdministration constant varchar2(50) := 'applicationAdministration';
  transactionTypeAdministration constant varchar2(50) := 'transactionTypeAdministration';
  /* condition navigation paths */
  stringListForm constant varchar2(50) := 'stringListForm';
  conditionListForm constant varchar2(50) := 'conditionListForm';
  /* UI style-sheet constants (one per class in amestyle.css) */
  activeFooterItemStyle constant varchar2(30) := 'activeFooterItem';
  detailsHeadingStyle constant varchar2(30) := 'detailsHeading';
  detailsLabelStyle constant varchar2(30) := 'detailsLabel';
  editFormLinkStyle constant varchar2(30) := 'editFormLink';
  footerItemStyle constant varchar2(30) := 'footerItem';
  formOrListHeadingStyle constant varchar2(30) := 'formOrListHeading';
  listDeleteHeadingStyle constant varchar2(30) := 'listDeleteHeading';
  listSubheadingStyle constant varchar2(30) := 'listSubheading';
  navLinkStyle constant varchar2(30) := 'navLink';
  staticDescriptionStyle constant varchar2(30) := 'staticDescription';
  transTypeHeadingStyle constant varchar2(30) := 'transTypeHeading';
  twoColumnFormLabelStyle constant varchar2(30) := 'twoColumnFormLabel';
/*
AME_STRIPING
  rule-striping stuff
  stripeWildcard varchar2(50) := 'AME_*';
*/
  /* functions and procedures */
  /*
    canonNumStringToDisplayString formats canonicalNumberStringIn according to the formatting
    conventions for the currency represented by currencyCodeIn.  Otherwise, at present,
    the input string's formatting is unchanged.  We should nevertheless call this function to
    format number-strings for display so that we can easily upgrade our number displays to NLS
    conformance, when that becomes possible.
  */
  function canonNumStringToDisplayString(canonicalNumberStringIn in varchar2,
                                         currencyCodeIn in varchar2 default null) return varchar2;
  function convertCurrency(fromCurrencyCodeIn in varchar2,
                           toCurrencyCodeIn in varchar2,
                           conversionTypeIn in varchar2,
                           amountIn in number,
                           dateIn in date default sysdate,
                           applicationIdIn in integer default null) return number;
  /*
    dateStringsToString takes values YYYY, MM, and DD and transforms them to a date-string
    with the format versionDateFormatModel.  Use it in handlers for forms having the
    ame_util.twoColumnFormDateInput widget.
  */
  function dateStringsToString(yearIn in varchar2,
                               monthIn in varchar2,
                               dayIn in varchar2) return varchar2;
  function escapeSpaceChars(stringIn in varchar2) return varchar2;
  function fieldDelimiter return varchar2;
  function filterHtmlUponInput(stringIn in varchar2) return varchar2;
  function filterHtmlUponRendering(stringIn in varchar2) return varchar2;
  function getAdminName(applicationIdIn in integer default null) return varchar2;
  function getBusGroupName(busGroupIdIn in integer) return varchar2;
  /*
    getCarriageReturn returns ASCII 13, a carriage return.  Some Web browsers combine this
    character with ASCII 10, a line feed (which is what the Enter key generates), to create
    a new line in a textarea input.  The removeReturns function removes both of these
    characters, optionally replacing them by a space character, and returning the result.
    When you want to strip the returns out of a string, use removeReturns.
  */
  function getCarriageReturn return varchar2;
  function getContactAdminString(applicationIdIn in integer default null) return varchar2;
  function getColumnLength(tableNameIn        in varchar2,
                           columnNameIn       in varchar2,
                           fndApplicationIdIn in integer default 800) return integer;
  function getConfigDesc(variableNameIn in varchar2) return varchar2;
  function getConfigVar(variableNameIn in varchar2,
                        applicationIdIn in integer default null) return varchar2;
  function getCurrencyName(currencyCodeIn in varchar2) return varchar2;
/*
AME_STRIPING
  function getCurrentStripeSetId(applicationIdIn in integer) return integer;
*/
  function getCurrentUserId return integer;
  function getDayString(dateIn in date) return varchar2;
  function getHighestResponsibility return integer;
  /* getLineFeed returns ASCII character 10, which is what the return key produces. */
  function getLabel(attributeApplicationIdIn in number,
                    attributeCodeIn          in varchar2,
                    returnColonAndSpaces     in boolean default false) return varchar2;
  function getLineFeed return varchar2;
  function getLongBoilerplate(applicationShortNameIn in varchar2,
                              messageNameIn          in varchar2,
                              tokenNameOneIn        in varchar2 default null,
                              tokenValueOneIn       in varchar2 default null,
                              tokenNameTwoIn        in varchar2 default null,
                              tokenValueTwoIn       in varchar2 default null,
                              tokenNameThreeIn      in varchar2 default null,
                              tokenValueThreeIn     in varchar2 default null,
                              tokenNameFourIn       in varchar2 default null,
                              tokenValueFourIn      in varchar2 default null,
                              tokenNameFiveIn       in varchar2 default null,
                              tokenValueFiveIn      in varchar2 default null,
                              tokenNameSixIn        in varchar2 default null,
                              tokenValueSixIn       in varchar2 default null,
                              tokenNameSevenIn      in varchar2 default null,
                              tokenValueSevenIn     in varchar2 default null,
                              tokenNameEightIn      in varchar2 default null,
                              tokenValueEightIn     in varchar2 default null,
                              tokenNameNineIn       in varchar2 default null,
                              tokenValueNineIn      in varchar2 default null,
                              tokenNameTenIn        in varchar2 default null,
                              tokenValueTenIn       in varchar2 default null) return varchar2;
  function getMessage(applicationShortNameIn in varchar2,
                      messageNameIn          in varchar2,
                      tokenNameOneIn        in varchar2 default null,
                      tokenValueOneIn       in varchar2 default null,
                      tokenNameTwoIn        in varchar2 default null,
                      tokenValueTwoIn       in varchar2 default null,
                      tokenNameThreeIn      in varchar2 default null,
                      tokenValueThreeIn     in varchar2 default null,
                      tokenNameFourIn       in varchar2 default null,
                      tokenValueFourIn      in varchar2 default null,
                      tokenNameFiveIn       in varchar2 default null,
                      tokenValueFiveIn      in varchar2 default null,
                      tokenNameSixIn        in varchar2 default null,
                      tokenValueSixIn       in varchar2 default null,
                      tokenNameSevenIn      in varchar2 default null,
                      tokenValueSevenIn     in varchar2 default null,
                      tokenNameEightIn      in varchar2 default null,
                      tokenValueEightIn     in varchar2 default null,
                      tokenNameNineIn       in varchar2 default null,
                      tokenValueNineIn      in varchar2 default null,
                      tokenNameTenIn        in varchar2 default null,
                      tokenValueTenIn       in varchar2 default null) return varchar2;
  function getMonthString(dateIn in date) return varchar2;
  function getOrgName(orgIdIn in integer) return varchar2;
  function getPlsqlDadPath return varchar2;
  function getQuery(selectClauseIn in varchar2) return ame_util.queryCursor ;
  function getServerName return varchar2;
  function getServerPort return varchar2;
  function getSetOfBooksName(setOfBooksIdIn in integer) return varchar2;
  function getTransTypeCookie return integer;
/*
AME_STRIPING
  function getStripeSetCookieName(applicationIdIn in integer) return varchar2;
*/
  function getYearString(dateIn in date) return varchar2;
  function hasOrderClause(queryStringIn in varchar2) return boolean;
  function idListsMatch(idList1InOut in out nocopy idList,
                        idList2InOut in out nocopy idList,
                        sortList1In in boolean default false,
                        sortList2In in boolean default true) return boolean;
  /*
    inputNumStringToCanonNumString converts inputNumberStringIn to a number-string in
    canonical format, for storage in database tables.  It also validates the input.  If
    currencyCodeIn is non-null, the validation includes checking the proper number of
    decimal places for a currency number-string.  We should always use this function to
    convert input number-strings to storable number-strings.
  */
  function inputNumStringToCanonNumString(inputNumberStringIn in varchar2,
                                          currencyCodeIn in varchar2 default null) return varchar2;
  function isAnEvenNumber(numberIn in integer) return boolean;
  function isAnInteger(stringIn in varchar2) return boolean;
  function isANegativeInteger(stringIn in varchar2) return boolean;
  function isANonNegativeInteger(stringIn in varchar2) return boolean;
  function isANumber(stringIn in varchar2,
                     allowDecimalsIn in boolean default true,
                     allowNegativesIn in boolean default true) return boolean;
  function isArgumentTooLong(tableNameIn in varchar2,
                             columnNameIn in varchar2,
                             argumentIn in varchar2) return boolean;
  function isConversionTypeValid(conversionTypeIn in varchar2) return boolean;
  function isCurrencyCodeValid(currencyCodeIn in varchar2) return boolean;
  function isDateInRange(currentDateIn in date default sysdate,
                         startDateIn in date,
                         endDateIn in date) return boolean;
  function longStringListsMatch(longStringList1InOut in out nocopy longStringList,
                                longStringList2InOut in out nocopy longStringList,
                                sortList1In in boolean default false,
                                sortList2In in boolean default true) return boolean;
  function longestStringListsMatch(longestStringList1InOut in out nocopy longestStringList,
                                   longestStringList2InOut in out nocopy longestStringList,
                                   sortList1In in boolean default false,
                                   sortList2In in boolean default true) return boolean;
  function matchCharacter(stringIn in varchar2,
                          locationIn in integer,
                          characterIn in varchar2) return boolean;
  function personIdToUserId(personIdIn in integer) return integer;
  function recordDelimiter return varchar2;
  /* See the comment for getCarriageReturn above for an explanation of removeReturns. */
  function removeReturns(stringIn in varchar2,
                         replaceWithSpaces in boolean default false) return varchar2;
  function removeScriptTags(stringIn in varchar2 default null) return varchar2;
  function stringListsMatch(stringList1InOut in out nocopy stringList,
                            stringList2InOut in out nocopy stringList,
                            sortList1In in boolean default false,
                            sortList2In in boolean default true) return boolean;
  function userIdToPersonId(userIdIn in integer) return integer;
  function useWorkflow(transactionIdIn in varchar2 default null,
                       applicationIdIn in integer) return boolean;
  function validateUser(responsibilityIn in integer,
                        applicationIdIn in integer default null) return integer;
  /*
    versionDateToDisplayDate transforms a date-string with the format versionDateFormatModel
    to a date-string formatted per the end user's preferences by fnd_date.date_to_displayDate.
  */
  function versionDateToDisplayDate(stringDateIn in varchar2) return varchar2;
  /* versionDateToString transforms a date to a date-string with the format versionDateFormatModel. */
  function versionDateToString(dateIn in date) return varchar2;
  /* versionStringToDate transforms a date-string with the format versionDateFormatModel to a date. */
  function versionStringToDate(stringDateIn in varchar2) return date;
  procedure appendRuleIdToSource(ruleIdIn in integer,
                                 sourceInOut in out nocopy varchar2);
  /* Translation Routines for approverRecord- approverRecord2*/
  procedure apprRecordToApprRecord2(approverRecordIn in ame_util.approverRecord,
                                    itemIdIn in varchar2 default null,
                                    approverRecord2Out out nocopy ame_util.approverRecord2);
  procedure apprRecord2ToApprRecord(approverRecord2In in ame_util.approverRecord2,
                                    approverRecordOut out nocopy ame_util.approverRecord);
  procedure apprTableToApprTable2(approversTableIn in ame_util.approversTable,
                                  itemIdIn in varchar2 default null,
                                  approversTable2Out out nocopy ame_util.approversTable2) ;
  procedure apprTable2ToApprTable(approversTable2In in ame_util.approversTable2,
                                  approversTableOut out nocopy ame_util.approversTable);
  procedure checkForSqlInjection(queryStringIn in varchar2);
  procedure compactIdList(idListInOut in out nocopy idList);
  procedure compactLongStringList(longStringListInOut in out nocopy ame_util.longStringList);
  procedure compactLongestStringList(longestStringListInOut in out nocopy ame_util.longestStringList);
  procedure compactStringList(stringListInOut in out nocopy ame_util.stringList) ;
  procedure convertApproversTableToValues(approversTableIn in ame_util.approversTable,
                                          personIdValuesOut out nocopy ame_util.idList,
                                          userIdValuesOut out nocopy ame_util.idList,
                                          apiInsertionValuesOut out nocopy ame_util.charList,
                                          authorityValuesOut out nocopy ame_util.charList,
                                          approvalTypeIdValuesOut out nocopy ame_util.idList,
                                          groupOrChainIdValuesOut out nocopy ame_util.idList,
                                          occurrenceValuesOut out nocopy ame_util.idList,
                                          sourceValuesOut out nocopy ame_util.longStringList,
                                          statusValuesOut out nocopy ame_util.stringList);
  procedure convertApproversTable2ToValues(approversTableIn in ame_util.approversTable2,
                                           namesOut out nocopy ame_util.longStringList,
                                           itemClassesOut out nocopy ame_util.stringList,
                                           itemIdsOut out nocopy ame_util.stringList,
                                           apiInsertionsOut out nocopy ame_util.charList,
                                           authoritiesOut out nocopy ame_util.charList,
                                           actionTypeIdsOut out nocopy ame_util.idList,
                                           groupOrChainIdsOut out nocopy ame_util.idList,
                                           occurrencesOut out nocopy ame_util.idList,
                                           approverCategoriesOut out nocopy ame_util.charList,
                                           statusesOut out nocopy ame_util.stringList);
  procedure convertValuesToApproversTable(personIdValuesIn in ame_util.idList,
                                          userIdValuesIn in ame_util.idList,
                                          apiInsertionValuesIn in ame_util.charList,
                                          authorityValuesIn in ame_util.charList,
                                          approvalTypeIdValuesIn in ame_util.idList,
                                          groupOrChainIdValuesIn in ame_util.idList,
                                          occurrenceValuesIn in ame_util.idList,
                                          sourceValuesIn in ame_util.longStringList,
                                          statusValuesIn in ame_util.stringList,
                                          approversTableOut out nocopy ame_util.approversTable);
  procedure convertValuesToApproversTable2(nameValuesIn in ame_util.longStringList,
                                          approverCategoryValuesIn in ame_util.charList,
                                          apiInsertionValuesIn in ame_util.charList,
                                          authorityValuesIn in ame_util.charList,
                                          approvalTypeIdValuesIn in ame_util.idList,
                                          groupOrChainIdValuesIn in ame_util.idList,
                                          occurrenceValuesIn in ame_util.idList,
                                          sourceValuesIn in ame_util.longStringList,
                                          statusValuesIn in ame_util.stringList,
                                          approversTableOut out nocopy ame_util.approversTable2);
  procedure copyApproverRecord2(approverRecord2In in approverRecord2,
                                approverRecord2Out out nocopy approverRecord2);
  procedure copyApproversTable2(approversTable2In in approversTable2,
                                approversTable2Out out nocopy approversTable2);
  procedure copyCharList(charListIn in charList,
                         charListOut out nocopy charList);
  procedure copyIdList(idListIn in idList,
                       idListOut out nocopy idList);
  procedure copyLongStringList(longStringListIn in longStringList,
                               longStringListOut out nocopy longStringList);
  procedure copyStringList(stringListIn in stringList,
                           stringListOut out nocopy stringList);
  procedure deserializeLongStringList(longStringListIn in varchar2,
                                      longStringListOut out nocopy longStringList);
  procedure getAllowedAppIds(applicationIdsOut out nocopy ame_util.stringList,
                             applicationNamesOut out nocopy ame_util.stringList);
  procedure getApplicationList(applicationListOut out nocopy idStringTable);
  procedure getApplicationList2(applicationIdListOut out nocopy stringList,
                                applicationNameListOut out nocopy stringList);
  procedure getApplicationList3(applicationIdIn in integer,
                                applicationIdListOut out nocopy stringList,
                                applicationNameListOut out nocopy stringList);
  procedure getConversionTypes(conversionTypesOut out nocopy ame_util.stringList);
  procedure getCurrencyCodes(currencyCodesOut out nocopy ame_util.stringList);
  procedure getCurrencies(currencyCodesOut out nocopy ame_util.stringList,
                          currencyNamesOut out nocopy ame_util.stringList);
  procedure getFndApplicationId(applicationIdIn in integer,
                                fndApplicationIdOut out nocopy integer,
                                transactionTypeIdOut out nocopy varchar2);
  procedure getWorkflowAttributeValues(applicationIdIn in integer,
                                       transactionIdIn in varchar2,
                                       workflowItemKeyOut out nocopy varchar2,
                                       workflowItemTypeOut out nocopy varchar2);
  procedure identArrToIdList(identArrIn in owa_util.ident_arr,
                             startIndexIn in integer default 2,
                             idListOut out nocopy idList);
  procedure identArrToLongestStringList(identArrIn in owa_util.ident_arr,
                                        startIndexIn in integer default 2,
                                        longestStringListOut out nocopy longestStringList);
  procedure identArrToStringList(identArrIn in owa_util.ident_arr,
                                 startIndexIn in integer default 2,
                                 stringListOut out nocopy stringList);
  procedure idListToStringList(idListIn in idList,
                               stringListOut out nocopy stringList);
  /* Translation Routines for insertionRecord - insertionRecord2 */
   procedure insTable2ToInsTable(insertionsTable2In in ame_util.insertionsTable2,
                                 insertionsTableOut out nocopy ame_util.insertionsTable) ;
   procedure insTableToInsTable2(insertionsTableIn in ame_util.insertionsTable,
                                 transactionIdIn in varchar2,
                                 insertionsTable2Out out nocopy ame_util.insertionsTable2) ;
  procedure makeEven(numberInOut in out nocopy integer);
  procedure makeOdd(numberInOut in out nocopy integer);
  /* Translation Routines  orderRecord - insertionRecord2 */
   procedure ordRecordToInsRecord2(orderRecordIn in ame_util.orderRecord,
                                 transactionIdIn in varchar2,
                                 approverIn in ame_util.approverRecord,
                                 insertionRecord2Out out nocopy ame_util.insertionRecord2) ;

  /*
    An ame_util.approverRecord2's source field is either a field-delimited list of
    rule IDs, or a string representing any of several insertion types.  In all cases,
    parseSourceValue sets sourceDescriptionOut to a string describing the source.  In
    the case of a rule-generated approver, parseSourceValue populates ruleIdListOut
    with the rule IDs requiring the approver.
  */
  procedure parseSourceValue(sourceValueIn in varchar2,
                             sourceDescriptionOut out nocopy varchar2,
                             ruleIdListOut out nocopy ame_util.idList);
  procedure parseStaticCurAttValue(applicationIdIn in integer,
                                   attributeIdIn in integer,
                                   attributeValueIn in varchar2,
                                   localErrorIn in boolean,
                                   amountOut out nocopy varchar2,
                                   currencyOut out nocopy varchar2,
                                   conversionTypeOut out nocopy varchar2);
  procedure purgeOldTempData;
  procedure purgeOldTempData2(errbuf out nocopy varchar2,
                              retcode out nocopy varchar2);
  procedure purgeOldTransLocks(errbuf out nocopy varchar2,
                               retcode out nocopy varchar2);
  procedure runtimeException(packageNameIn in varchar2,
                             routineNameIn in varchar2,
                             exceptionNumberIn in integer,
                             exceptionStringIn in varchar2);
  procedure serializeApprovers(approverNamesIn in ame_util.longStringList,
                               approverDescriptionsIn in ame_util.longStringList,
                               maxOutputLengthIn in integer,
                               approverNamesOut out nocopy varchar2,
                               approverDescriptionsOut out nocopy varchar2);
  procedure setConfigVar(variableNameIn  in varchar2,
                         variableValueIn in varchar2,
                         applicationIdIn in integer default null);
/*
AME_STRIPING
  procedure setCurrentStripeSetId(applicationIdIn in integer,
                                  stripeSetIdIn in integer);
*/
  procedure setTransTypeCookie(applicationIdIn in integer);
  procedure sortIdListInPlace(idListInOut in out nocopy idList);
  procedure sortLongStringListInPlace(longStringListInOut in out nocopy longStringList);
  procedure sortLongestStringListInPlace(longestStringListInOut in out nocopy longestStringList);
  procedure sortStringListInPlace(stringListInOut in out nocopy stringList);
  procedure stringListToIdList(stringListIn in stringList,
                               idListOut out nocopy idList);
  procedure substituteStrings(stringIn in varchar2,
                              targetStringsIn in ame_util.stringList,
                              substitutionStringsIn in ame_util.stringList,
                              stringOut out nocopy varchar2);
end ame_util;

/
