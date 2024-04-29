--------------------------------------------------------
--  DDL for Package Body AME_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ENGINE" as
/* $Header: ameeengi.pkb 120.35.12010000.12 2010/02/23 15:05:22 prasashe ship $ */
  /*************************************************************************************
  package variables
  All engine package variables' names begin with the prefix 'eng'.  All engine package
  variables are private.
  *************************************************************************************/
  /* transaction identifiers */
  engAmeApplicationId integer;
  engFndApplicationId integer;
  engTransactionId ame_temp_old_approver_lists.transaction_id%type;
  engTransactionTypeId ame_calling_apps.transaction_type_id%type;
  /* engTransactionIsLocked is for the transaction-locking utilities used by the APIs. */
  engTransactionIsLocked boolean := false;
  /*
    engIsLocalTransaction indicates whether the current engine cycle originates in an API
    call or a test-tab routine.  If the test tab is testing a real transaction ID, it should
    set engIsTestTransaction to false (via a call to updateTransactionState), and it should
    set engIsLocalTransaction to true.  The API should set both engIsTestTransaction and
    engIsLocalTransaction to false.  The ame_util.runtimeException checks engIsLocalTransaction
    to determine whether to log an exception to the Workflow context stack.
  */
  engIsLocalTransaction boolean := true;
  /*
    engIsTestTransaction indicates whether the current transaction is a test transaction.
    If so, the engine fetches the transaction's attribute values from ame_test_trans_att_values.
    engIsTestTransaction is initialized to true so ame_util.runtimeException will see
    a value of true in the absence of a call to updateTransactionState, before the
    call to ame_util.runtimeException.  That is, unless a call to updateTransactionState
    sets this variable's value, we assume the transaction is a test transaction, to
    avoid writing spurious exceptions to the Workflow context stack.
   */
  engIsTestTransaction boolean := true;
  /*
    updateTransactionState sets the following variables.  They indicate which parts of its
    cycle the engine should or should not execute.
  */
  engPrepareItemData boolean;
  engPrepareRuleDescs boolean;
  engPrepareApproverTree boolean;
  engItemDataPrepared boolean;
  engPrepareRuleIds boolean;
  engProcessPriorities boolean;
  engProcessProductionActions boolean;
  engProcessProductionRules boolean;
  engUpdateCurrentApproverList boolean;
  engUpdateOldApproverList boolean;
  /* configuration-variable caches */
  engConfigVarNames ame_util.longStringList; /* kept compact */
  engConfigVarValues ame_util.longStringList; /* kept compact */
  /*
    Generally, all runtime queries should use engEffectiveRuleDate in their date logic, to make sure
    they all rely on the same snapshot of AME data.  (Failure to do this can lead to inconsistent data
    in different parts of the engine cycle, which could make the engine crash.)
  */
  engEffectiveRuleDate date;
  engEvalPrioritiesPerItem boolean;
  engForwardingBehaviors ame_util.stringList; /* kept compact */
  /*
    engPriorityModes and engPriorityThresholds are indexed by rule-type constant, so their
    indexes run from zero to seven.
  */
  engPriorityModes ame_util.stringList;
  engPriorityThresholds ame_util.idList;
  /*
    Approval-group members are cached (once fetched as required) in the engGroup variables.  These
    lists are compact.  All of a group's members are in a consecutive order consistent with the
    group members' order numbers (whether static or dynamic in the group definition).
  */
  engGroupMemberGroupIds ame_util.idList;
  engGroupMemberNames ame_util.longStringList;
  engGroupMemberOrderNumbers ame_util.idList;
  engGroupMemberDisplayNames ame_util.longStringList;
  engGroupMemberOrigSystems ame_util.stringList;
  engGroupMemberOrigSystemIds ame_util.idList;
  -- Array to keep track if approval group needs to be rerun for each item class, item ID
  engGroupUseItemBind ame_util.charList;
  /* approver lists */
  engDeletedApproverList ame_util.approversTable2; /* kept compact */
  engInsertedApproverList ame_util.approversTable2; /* kept compact */
  engOldApproverList ame_util.approversTable2; /* kept compact, read only */
  /* lists related to approver insertion and deletion */
  engInsertionOrderTypeList ame_util.stringList; /* corresponds in order to engInsertedApproverList */
  engInsertionParameterList ame_util.longestStringList; /* corresponds in order to engInsertedApproverList */
  engInsertionIsSpecialForwardee ame_util.charList; /* ame_util.booleanTrue if insertee is a special forwardee */
  engInsApproverIndex ame_util.idList; /*maintain the approver index for the insertion*/
  /* action-type configuration data, all sparse, indexed by action-type ID */
  engActionTypeChainOrderModes ame_util.charList;
  engActionTypeOrderNumbers ame_util.idList;
  engActionTypeVotingRegimes ame_util.charList;
  engActionTypeNames ame_util.stringList;
  engActionTypeUsages ame_util.idList;
  engActionTypePackageNames ame_util.stringList;
  /*
    list-modification condition caches, all sparse, indexed by the ID of the rule using the LM condition,
    not by the condition ID (It's more efficient to index by rule ID.)
  */
  engLMParameterOnes ame_util.stringList;
  engLMParameterTwos ame_util.longStringList;
  /*
    The item-class usages are stored in engItemClassIds, engItemClassNames, engItemClassOrderNumbers,
    engItemClassParModes, and engItemClassSublistModes.  All of these are compact, and ordered by
    item_class_order_number order.  If engItemClassIds(i) is a given item class' item-class ID, then
    engItemClassIndexes(engItemClassIds(i)) = i.  So the index of the row in the item-class-usage
    data structures for an item class with the item-class ID item_class_id is
    engItemClassIndexes(item_class_id).  engItemClassItemIdIndexes(i) is the index of the first item
    ID in itemIds of the item class with ID engItemClassIds(i).
  */
  engItemClassIds ame_util.idList;
  engItemClassIndexes ame_util.idList;
  engItemClassItemIdIndexes ame_util.idList;
  engItemClassNames ame_util.stringList;
  engItemClassOrderNumbers ame_util.idList;
  engItemClassParModes ame_util.charList;
  engItemClassSublistModes ame_util.charList;
  /*
    engItemCounts(i) is the number of items of the item class with item-class ID
    engItemClassIds(i).  engItemIds contains the item-ID lists returned by all
    of the item classes' item-ID queries, in item_class_order_number order.
  */
  engItemCounts ame_util.idList; /* compact */
  engItemIds ame_util.stringList; /* compact */
  /* attributes */
  engAttributeIsStatics ame_util.charList; /* indexed by attribute id */
  engAttributeItemClassIds ame_util.idList; /* indexed by attribute id */
  engAttributeNames ame_util.stringList; /* indexed by attribute id */
  engAttributeTypes ame_util.stringList; /* indexed by attribute id */
  /* New arrays to store the query details and whether they need to be evaluated
     for each itemClass and itemID */
  engAttributeQueries ame_util.longestStringList;
  engAttributeVariant ame_util.stringList;
  /*
    The attribute values are kept compact.  The values of the attribute with ID i
    are stored starting at the index engAttributeValueIndexes(i), in the order
    that their item IDs occur in engItemIds.
  */
  engAttributeValueIndexes ame_util.idList; /* indexed by attribute id */
  engAttributeValues1 ame_util.attributeValueList; /* compact */
  engAttributeValues2 ame_util.attributeValueList; /* compact */
  engAttributeValues3 ame_util.attributeValueList; /* compact */
  /*
    engHeaderConditionValues caches the truth values of conditions on
    attributes in the header item class.  It is indexed by condition ID.
  */
  engHeaderConditionValues ame_util.charList;
  /*
    The engACUsage variables store active condition usages and related data.
    engACUsageRulePriorities, engACUsageRuleTypes, and engACUsageRuleApprCategories
    are indexed by rule ID; the other variables are indexed consecutively, and are
    ordered first by item-class ID (with null item-class IDs last), then by rule ID.
    The first order-by is so the engine can efficiently access the related engAC and
    engACU data structures by item-class ID.  (List-modification rules have null
    item-class IDs, so they'll get processed last.)  The second order-by is so the
    engine can efficiently do weak per-item evaluation for rules in the header item
    class, when that is required.  engACUsageFirstIndexes(item_class_id) is the index
    of the first row in the engACUsage variables for the item class with ID
    item_class_id.  That is, engACUsageFirstIndexes is indexed by item-class
    ID.  An item class may have no active condition usages.  In this case,
    engACUsageFirstIndexes.exists(item_class_id) returns false.
    engACUsageItemClassCounts(item_class_id) is the number of rows in the
    engACUsage variables for the item class with ID item_class_id, starting at
    the index engACUsageFirstIndexes(item_class_id).
  */
  engACUsageConditionIds ame_util.idList;
  engACUsageFirstIndexes ame_util.idList;
  engACUsageItemClassCounts ame_util.idList;
  engACUsageRuleIds ame_util.idList;
  engACUsageRulePriorities ame_util.idList; /* indexed by rule ID */
  engACUsageRuleTypes ame_util.idList; /* indexed by rule ID */
  engACUsageRuleApprCategories ame_util.charList; /* indexed by rule ID */
  /*
    The engAC variables store properties of conditions in the active condition usages.
    They are indexed by condition ID.
  */
  engACAttributeIds ame_util.idList;
  engACConditionTypes ame_util.stringList;
  engACIncludeLowerLimits ame_util.charList;
  engACIncludeUpperLimits ame_util.charList;
  engACParameterOnes ame_util.stringList;
  engACParameterThrees ame_util.stringList;
  engACParameterTwos ame_util.longStringList;
  /*
    engACStringValues stores string values for active conditions on string attributes.
    It is ordered by condition ID.  engACStringValueFirstIndexes(condition_id) is the
    index of the first row in engACStringValues for the condition with ID condition_id.
    That is, engACStringValueFirstIndexes is indexed by condition ID.
    engACStringValueCounts(condition_id) is the number of rows in
    engACStringValues for the condition with ID condition_id, starting at
    the index engACStringValueFirstIndexes(condition_id).
  */
  engACStringValueCounts ame_util.idList;
  engACStringValueFirstIndexes ame_util.idList;
  engACStringValues ame_util.attributeValueList;
  /*
    >> engApp indexing
    The variables
      engAppHandlerFirstIndex
      engAppHandlerLastIndex
    are single-valued.  The variables
      engAppLMSubItemClassIds
      engAppLMSubItemIds
    are indexed by rule ID.  All other engApp variables are stored in a common, dense
    order, with each row representing the application of a single rule to a single
    item.  (Thus the same rule ID can appear several times in engAppRuleIds, as long
    as when i <> j, if engAppRuleIds(i) = engAppRuleIds(j) then engAppAppItemIds(i)
    <> engAppItemIds(j) and of course engAppRuleItemClassIds(i) does not identify the
    header item class.)  The rules determining the ordering of the dense engApp
    variables change somewhat at different engine-processing stages; see below.
    >> engApp semantics
    Most of the engApp variables store the list of applicable rules.  The following
    variables store actual rule and rule-usage properties:
      engAppActionTypeIds
      engAppApproverCategories
      engAppPriorities
      engAppRuleIds
      engAppRuleItemClassIds
      engAppRuleTypes.
    The variables
      engAppParameters
      engAppParameterTwos
    store the parameters of the rules' actions.  The variables
      engAppItemClassIds
      engAppItemIds
    store the item-class IDs and item IDs of the item that satisfies a rule.  The
    variable
      engAppAppItemIds
    contains the IDs of the items to which the rules apply (and these items always
    belong to the item classes identified by engAppRuleItemClassIds).  Usually the item
    that satisfies a rule is the same as the item to which the rule applies.  That is,
    usually
      engAppRuleItemClassIds(i) = engAppItemClassIds(i)
      engAppAppItemIds(i) = engAppItemIds(i).
    However, if per-item evaluation is enabled, these equalities fail for a rule
    that contains a subordinate-item-class level condition.  In this case,
    engAppRuleItemClassIds(i) identifies the header item class, and
    engAppAppItemIds(i) is the transaction ID; but engAppItemClassIds(i) and
    engAppItemIds(i) identify a subordinate item-class item satisfying the
    subordinate-item-class level conditions.  Note that the engine treats list-
    modification and substitution rules as applying to all item classes and items, so
      engAppItemClassIds
      engAppItemIds
    are null for rules of these types.  These rules' satisfying item classes and items
    are stored instead in
      engAppLMSubItemClassIds
      engAppLMSubItemIds.
    Finally, the variables
      engAppHandlerFirstIndex
      engAppHandlerLastIndex
    mark the first and last rows in the other engApp variables that the procedure
    processActionType is currently processing.  They have no meaning outside this context.
    >> engApp processing
    The procedure evaluateRules populates
      engAppRuleIds
      engAppRuleTypes
      engAppRuleItemClassIds
      engAppPriorities
      engAppApproverCategories
      engAppItemClassIds
      engAppItemIds
      engAppAppItemIds
    leaving them compact and sorted lexicographically by these values:
      the item-class order numbers of the engAppRuleItemClassIds values
      the engAppRuleItemClassIds values themselves
      the engAppItemClassIds values
      the engAppRuleTypes values.
    The processRelativePriorities procedure (called by evaluateRules)
      1.  deletes a row in the compact engApp lists if the rule represented by the row
          is of insufficient relative priority.
      2.  re-compacts the same lists (preserving the above lexicographic ordering).
    At this point, a rule with several actions still appears just once in the engApp
    lists.  The procedure fetchApplicableActions
      1.  populates engAppActionTypeIds, engAppParameters, and engAppParameterTwos.
      2.  splits out the actions in a rule so that the rule has one row in the engApp
          lists for each of the rule's actions.
      3.  converts each combination rule's rule type to the rule type that corresponds
          with the rule's action type.
      4.  re-sorts the lists lexicographically by these values:
            rule's item-class order number
            rule's item-class ID
            item ID of the item to which the rule applies
            rule type
            action-type order number
            action-type ID.
    fetchApplicableActions deletes engAppPriorities because priorities have already been
    processed; so engAppPriorities should not be referenced after fetchApplicableActions
    is called.  Next, processExceptions
      1.  deletes from the engApp variables any list-creation (authority) rules
          suppressed by the exception rules.
      2.  re-compacts the lists (preserving the above lexicographic ordering).
      3.  converts the exception rules to list-creation rules.
    processExceptions occurs in the engine algorithm after applicable actions have been
    fetched, so that the actions of any list-creation rules suppressed by exception
    rules will have been fetched unnecessarily.  The assumption here is that exception
    rules are deprecated, so if performance becomes an issue, exception rules should be
    converted to list-creation rules with appropriate priorities.
  */
  engAppActionTypeIds ame_util.idList;
  engAppAppItemIds ame_util.stringList;
  engAppApproverCategories ame_util.charList;
  engAppHandlerFirstIndex integer;
  engAppHandlerLastIndex integer;
  engAppItemClassIds ame_util.idList;
  engAppItemIds ame_util.stringList;
  engAppLMSubItemClassIds ame_util.idList;
  engAppLMSubItemIds ame_util.stringList;
  engAppParameters ame_util.stringList;
  engAppParameterTwos ame_util.stringList;
  engAppPriorities ame_util.idList;
  engAppRuleIds ame_util.idList;
  engRuleAppliedYN ame_util.charList;
  engAppRuleItemClassIds ame_util.idList;
  engAppRuleTypes ame_util.idList;
  /*
    The engAppPerAppProd variables contain per-approver productions sorted by rule ID.
    fetchApplicableActions populates these variables.  Then populateEngStVariables transfers
    the values into engStProductionIndexes, engStVariableNames, and engStVariableValues,
    after the approver list has been built.  Finally processRepeatedApprovers modifies the
    values as it suppresses repeated approvers.  All of the per-approver productions generated
    by a rule appear in consecutive order in the engAppPerAppProd variables.
    engAppPerAppProdFirstIndexes(i) is the index of the first row in the other
    engAppPerAppProd variables that contains a production generated by the rule with ID i.
  */
  engAppPerAppProdFirstIndexes ame_util.idList;
  engAppPerAppProdRuleIds ame_util.idList;
  engAppPerAppProdVariableNames ame_util.stringList;
  engAppPerAppProdVariableValues ame_util.stringList;
  /* engRepeatSubstitutions is a new private engine flag indicating whether the substitution handler
     needs to be called a second time after adhoc insertions and surrogate processing */
  engRepeatSubstitutions    boolean;
  /* engAppSub variables store relevant data needed to call the substitution handler a second time. */
  engAppSubHandlerFirstIndex integer;
  engAppSubHandlerLastIndex integer;
  /*
    The engSt variables contain approval-process state data for AME API code to output.
    Here are descriptions of each engSt variable.
    - engStApprovalProcessCompleteYN is a pseudoboolean indicating whether the entire
      transaction's approval process is complete.
    - engStApprovers is the current approver list.  It is compact.
    - engStItemIds, engStItemClasses, engStItemIndexes, and engStItemSources relate approvers in
      engStApprovers to the items requiring them.  If the item_id and item_class fields of an
      approverRecord2 in engStApprovers are null, several items require the approver.  (The
      converse is not true.  The item_id and item_class fields of an approver with the status
      ame_util.repeatedStatus are not nulled, even though the approver occurs several times.
      Only the first occurrence of an approver within the applicable repeated-approvers grouping
      will have null item_id and item_class values, when several items require the approver.)
      If such an approver is at index i in engStApprovers, and engStItemIndexes(j) = i, then
      engStItemIds(j) is the ID of an item requiring the approver, engStItemClasses(j) is the
      corresponding item class, and engStItemSources(j) is the source field indicating which
      rules require the approver for that item.  (There will be at least two such "rows" in
      these lists, for an approver in engStApprovers required by multiple items.)
    - engStProductionIndexes, engStVariableNames, and engStVariableValues store per-approver
      productions.  A variable-name/value pair is stored at the same index in
      engStVariableNames and engStVariableValues.  Several productions can be assigned to a
      single approver, so engStProductionIndexes contains for each production the index of the
      approverRecord2 in engStApprovers to which the production is assigned.  That is, if
      engStProductionIndexes(i) = j, then the production in engStVariableNames(i) and
      engStVariableValues(i) is assigned to engStApprovers(j).
    - engStTransVariableNames and engStTransVariableValues store per-transaction productions
      in compact lists.
    - engStRuleIds, engStRuleDescriptions, engStRuleIndexes, and engStSourceTypes classify
      approvers in engStApprovers according to their sources (the reasons for their occurrence
      in the approver list).  When an approver is required by one or more rules, the rules are
      identified in engStRuleIds.  More particularly:  every approverRecord2 in engStApprovers
      has at least one row in engStRuleIndexes, engStSourceTypes and engStRuleIds.  If
      engStRuleIndexes(i) = j, then the values in engStSourceTypes(i) and engStRuleIds(i)
      pertain to the approver in engStApprovers(j).  Every approver in engStApprovers has only
      one source value, no matter how many rules required the approver.  That is, if
      engStRuleIndexes(i1) = j and engStRuleIndexes(i2) = j for i1 <> i2, then
      engStSourceTypes(i1) = engStSourceTypes(i2).  Some source values indicate that an
      approver is not required by any rules, but is present for other reasons.  In such cases,
      if the approver is at index i and engStSourceTypes(j) = i, then engStRuleIds(j) is null.
    - engStItemAppProcesscompleteYN is compact.  It stores the approval-process status per item.
      It is ordered so that the approval-process status of engItemIds(i) is
      engStItemAppProcessCompleteYN(i).
  */
  engStApprovalProcessCompleteYN ame_util.charType;
  engStApprovers ame_util.approversTable2;
  /* This global variable stores the approver tree */
  engStApproversTree ame_util.approversTreeTable;
  engStItemClasses ame_util.stringList;
  engStItemIds ame_util.stringList;
  engStItemIndexes ame_util.idList;
  engStItemSources ame_util.longStringList;
  engStProductionIndexes ame_util.idList;
  /* Following two global variables to store repeated indexes */
  engStRepeatedIndexes    ame_util.idList;
  engStRepeatedAppIndexes ame_util.idList;
  engStRuleDescriptions ame_util.stringList;
  engStRuleIds ame_util.idList;
  engStRuleIndexes ame_util.idList;
  engStSourceTypes ame_util.stringList;
  /* Following two global variables store the list of suspended items */
  engStSuspendedItems ame_util.stringList;
  engStSuspendedItemClasses ame_util.stringList;
  engStVariableNames ame_util.stringList;
  engStVariableValues ame_util.stringList;
  engStProductionsTable ame_util2.productionsTable;
  engStItemAppProcessCompleteYN ame_util.charList;
  engStInsertionIndexes ame_util.idList;
  engInsertionOrderList ame_util.idList;
    /*eng deviation list*/
  engDeviationResultList ame_approver_deviation_pkg.deviationReasonList;
  engInsertionReasonList ame_util.stringList;
  engInsertionDateList ame_util.dateList;
  engSuppressionDateList ame_util.dateList;
  engSupperssionReasonList ame_util.stringList;
  engTempReason varchar2(50);
  engTempDate   date;
  /*************************************************************************************
  forward declarations of private functions
  *************************************************************************************/
  /******************************** boolean functions *********************************/
  /*
    conditionIsSatisfied assumes that itemIndexIn indexes an item ID in engItemIds, and
    that this item is of the same item class as that of the attribute used by the
    condition with ID conditionIdIn.
  */
  function conditionIsSatisfied(conditionIdIn in integer,
                                itemClassIdIn in integer,
                                itemIndexIn in integer) return boolean;
  /********************************* fetch functions **********************************/
  function fetchAmeApplicationId(fndApplicationIdIn in integer,
                                 transactionTypeIdIn in varchar2 default null) return integer;
  /********************************** get functions ***********************************/
  function getItemIndex(itemClassIdIn in integer,
                        itemIdIn in varchar2) return integer;
  function getItemOffset(itemClassIdIn in integer,
                         itemIdIn in varchar2) return integer;
  /********************************** sort functions **********************************/
  /* compareApplicableRules is a subroutine of the sortApplicableRules procedure. */
  function compareApplicableRules(index1In in integer,
                                  index2In in integer,
                                  compareActionTypesIn in boolean) return boolean;
  function getTestVariantAttValue(attributeIdIn in integer,
                                 itemClassIdIn  in integer,
                                 itemIdIn       in varchar2) return number;
  function isVariant(attributeIdIn in integer) return boolean;
  /*************************************************************************************
  forward declarations of private procedures
  *************************************************************************************/
  procedure addApproverToTree
    (approverRecordIn   in            ame_util.approverRecord2
    ,approverIndexIn    in            integer
    ,approverLocationIn in            boolean default ame_util.lastAmongEquals);
  procedure calculateApproverOrderNumbers;
  procedure compactEngAppLists(compactPrioritiesIn in boolean,
                               compactActionTypeIdsIn in boolean,
                               compactParametersIn in boolean);
  procedure doPerItemRuleEvaluation(itemClassIdIn in integer,
                                    itemIndexIn in varchar2);
  procedure doStrictHeaderRuleEvaluation(itemClassIndexIn in integer,
                                         itemClassIdIn in integer);
  procedure doWeakHeaderRuleEvaluation(itemClassIndexIn in integer,
                                       itemClassIdIn in integer);
  procedure evaluateRules;
  procedure fetchActiveConditionUsages;
  procedure fetchApplicableActions;
  procedure fetchAttributeValues(fetchInactivesIn in boolean);
  procedure fetchConfigVars;
  procedure fetchDeletedApprovers;
  procedure fetchFndApplicationId(applicationIdIn in integer,
                                  fndApplicationIdOut out nocopy integer,
                                  transactionTypeIdOut out nocopy varchar2);
  procedure fetchInsertedApprovers;
  procedure fetchItemClassData;
  procedure fetchOldApprovers;
  procedure fetchRuntimeGroup(groupIdIn in integer);
  procedure finalizeTree(parentIndexIn          in integer default 1
                        ,maximumOrderOut       out nocopy integer
                        ,approvalStatusOut     out nocopy integer
                        ,rejectedItemsExistOut out nocopy boolean);
  procedure getLMCondition(ruleIdIn in integer,
                           parameterOneOut out nocopy varchar2,
                           parameterTwoOut out nocopy varchar2);
  procedure insertIntoTransApprovalHistory
              (transactionIdIn  ame_trans_approval_history.transaction_id%type
              ,applicationIdIn  ame_trans_approval_history.application_id%type
              ,orderNumberIn    ame_trans_approval_history.order_number%type
              ,nameIn           ame_trans_approval_history.name%type
              ,appCategoryIn    ame_trans_approval_history.approver_category%type
              ,itemClassIn      ame_trans_approval_history.item_class%type
              ,itemIdIn         ame_trans_approval_history.item_id%type
              ,actionTypeIdIn   ame_trans_approval_history.action_type_id%type
              ,authorityIn      ame_trans_approval_history.authority%type
              ,statusIn         ame_trans_approval_history.status%type
              ,grpOrChainIdIn   ame_trans_approval_history.group_or_chain_id%type
              ,occurrenceIn     ame_trans_approval_history.occurrence%type
              ,apiInsertionIn   ame_trans_approval_history.api_insertion%type
              ,memberOrderNumberIn ame_trans_approval_history.member_order_number%type
              ,notificationIdIn ame_trans_approval_history.notification_id%type
              ,userCommentsIn   ame_trans_approval_history.user_comments%type
              ,dateClearedIn    ame_trans_approval_history.date_cleared%type
              ,historyTypeIn    varchar2);
  procedure parseForwardingBehaviors(forwardingBehaviorsIn in varchar2);
  procedure parsePriorityModes(priorityModesIn in varchar2);
  procedure populateEngStVariables;
  procedure prepareItemData(approverIndexesIn  in ame_util.idList default ame_util.emptyIdList
                           ,itemIndexesOut     out nocopy ame_util.idList
                           ,itemItemClassesOut out nocopy ame_util.stringList
                           ,itemIdsOut         out nocopy ame_util.stringList
                           ,itemSourcesOut     out nocopy ame_util.longStringList);
  procedure preparePerApproverProductions
           (approverIndexesIn    in ame_util.idList default ame_util.emptyIdList
           ,itemIndexesIn        in ame_util.idList default ame_util.emptyIdList
           ,itemSourcesIn        in ame_util.longStringList default ame_util.emptyLongStringList
           ,prodIndexesOut      out nocopy ame_util.idList
           ,productionNamesOut  out nocopy ame_util.stringList
           ,productionValuesOut out nocopy ame_util.stringList);
  procedure prepareRuleData;
  procedure processActionType;
  procedure processAdHocInsertions;
  procedure processSuppressions;
  procedure processRelativePriorities;
  procedure processRepeatedApprovers;
  procedure processRules(processOnlyProductionsIn in boolean default false);
  procedure processUnresponsiveApprovers;
  procedure populateInsertionIndexes(indexIn in integer
                                    ,insertionOrderIn in integer);
  procedure repeatSubstitutions;
  procedure setContext(isTestTransactionIn in boolean,
                       isLocalTransactionIn in boolean,
                       fetchConfigVarsIn in boolean,
                       fetchOldApproversIn in boolean,
                       fetchInsertionsIn in boolean,
                       fetchDeletionsIn in boolean,
                       fetchAttributeValuesIn in boolean,
                       fetchInactiveAttValuesIn in boolean,
                       processProductionActionsIn in boolean,
                       processProductionRulesIn in boolean,
                       updateCurrentApproverListIn in boolean,
                       updateOldApproverListIn in boolean,
                       processPrioritiesIn in boolean,
                       prepareItemDataIn in boolean,
                       prepareRuleIdsIn in boolean,
                       prepareRuleDescsIn in boolean,
                       prepareApproverTreeIn in boolean default false,
                       transactionIdIn in varchar2,
                       ameApplicationIdIn in integer default null,
                       fndApplicationIdIn in integer default null,
                       transactionTypeIdIn in varchar2 default null);
  procedure setInsertedApprovalStatus(currentApproverIndexIn in integer
                                      ,approvalStatusIn in varchar2);

  procedure sortApplicableRules(sortByActionTypeIn in boolean);
  procedure updateOldApproverList;
  /*************************************************************************************
  functions
  *************************************************************************************/
  /******************************** boolean functions *********************************/
  function approversMatch(approverRecord1In in ame_util.approverRecord2,
                          approverRecord2In in ame_util.approverRecord2) return boolean as
    begin
      /* The following if statement's conditions are in decreasing order of specificity for efficiency. */
      if(approverRecord1In.name = approverRecord2In.name and
         approverRecord1In.occurrence = approverRecord2In.occurrence and
         approverRecord1In.group_or_chain_id = approverRecord2In.group_or_chain_id and
         approverRecord1In.action_type_id = approverRecord2In.action_type_id and
         approverRecord1In.item_id = approverRecord2In.item_id and
         approverRecord1In.item_class = approverRecord2In.item_class) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'approversMatch',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end approversMatch;
  function checkAttributeVariant(attributeIdIn in integer) return varchar2 as
    begin
      if (engAttributeNames(attributeIdIn)  = ame_util.jobLevelStartingPointAttribute or
          engAttributeNames(attributeIdIn)  = ame_util.nonDefStartingPointPosAttr or
          engAttributeNames(attributeIdIn)  = ame_util.nonDefPosStructureAttr or
          engAttributeNames(attributeIdIn)  = ame_util.supStartingPointAttribute or
          engAttributeNames(attributeIdIn)  = ame_util.firstStartingPointAttribute or
          engAttributeNames(attributeIdIn)  = ame_util.secondStartingPointAttribute ) then
        return(ame_util.booleanTrue);
      else
        return(ame_util.booleanFalse);
      end if;
    end;
  function getVariantAttributeValue(attributeIdIn in integer,
                                    itemClassIn in varchar2,
                                    itemIdIn in varchar2) return number as
    dynamicCursor integer;
    dynamicQuery ame_util.longestStringType;
    rowsFound integer;
    tempAttributeValues1 dbms_sql.varchar2_table;
    begin
      if engIsTestTransaction then
        if checkAttributeVariant(attributeIdIn) = ame_util.booleanTrue then
          return (getTestVariantAttValue(attributeIdIn => attributeIdIn
                                        ,itemClassIdIn => getItemClassId(itemClassNameIn => itemClassIn)
                                        ,itemIdIn      => itemIdIn));
        else
          return(engAttributeValues1(engAttributeValueIndexes(attributeIdIn)));
        end if;
      end if;
      /* fetch the value for real transactions using the dynamic query */
      if(engAttributeVariant.exists(attributeIdIn))then
        dynamicQuery := ame_util.removeReturns(stringIn => engAttributeQueries(attributeIdIn),
                                               replaceWithSpaces => true);
        dynamicCursor := dbms_sql.open_cursor;
        dbms_sql.parse(dynamicCursor,
                       dynamicQuery,
                       dbms_sql.native);
        if(instrb(dynamicQuery, ame_util.transactionIdPlaceholder) > 0) then
          dbms_sql.bind_variable(dynamicCursor,
                                 ame_util.transactionIdPlaceholder,
                                 engTransactionId,
                                 50); /* ame_temp_transactions.transaction_id%length doesn't work here. */
        end if;
        if(instrb(dynamicQuery, ame_util2.itemClassPlaceHolder) > 0) then
          dbms_sql.bind_variable(dynamicCursor,
                                 ame_util2.itemClassPlaceHolder,
                                 itemClassIn,
                                 50); /* ame_temp_transactions.transaction_id%length doesn't work here. */
        end if;
        if(instrb(dynamicQuery, ame_util2.itemIdPlaceHolder) > 0) then
          dbms_sql.bind_variable(dynamicCursor,
                                 ame_util2.itemIdPlaceHolder,
                                 itemIdIn,
                                 50); /* ame_temp_transactions.transaction_id%length doesn't work here. */
        end if;
        dbms_sql.define_array(dynamicCursor,
                              1,
                              tempAttributeValues1,
                              ame_util.attributeValueTypeLength,
                              1);
        rowsFound := dbms_sql.execute(dynamicCursor);
        loop
          rowsFound := dbms_sql.fetch_rows(dynamicCursor);
          dbms_sql.column_value(dynamicCursor,
                                1,
                                tempAttributeValues1);
          exit when rowsFound < 2;
        end loop;
        dbms_sql.close_cursor(dynamicCursor);
        return(tempAttributeValues1(1));
      else
      /* this is not a variant attribute value would have fetched already in
         fetchAttributeValues return the same */
        return(engAttributeValues1(engAttributeValueIndexes(attributeIdIn)));
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getVariantAttributeValue',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return null;
    end getVariantAttributeValue;
/*  function getVariantAttributeValue2(attributeIdIn in integer,
                                     itemClassIn in varchar2,
                                     itemIdIn in varchar2) return number as
    begin
      return(getVariantAttributeValue(attributeIdIn => attributeIdIn,
                                      itemClassIn => itemClassIn,
                                      itemIdIn => itemIdIn));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getVariantAttributeValue2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return null;
    end getVariantAttributeValue2;*/
  function conditionIsSatisfied(conditionIdIn in integer,
                                itemClassIdIn in integer,
                                itemIndexIn in integer) return boolean as
    attributeId integer;
    attributeNumberValue number;
    attributeType ame_attributes.attribute_type%type;
    attributeTypeException exception;
    attributeValue1 ame_util.attributeValueType;
    attributeValue2 ame_util.attributeValueType;
    attributeValue3 ame_util.attributeValueType;
    attributeValueDate date;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    headerLevelCondition boolean;
    includeLowerLimit ame_conditions.include_lower_limit%type;
    includeUpperLimit ame_conditions.include_upper_limit%type;
    parameterOne ame_conditions.parameter_one%type;
    parameterOneDate date;
    parameterOneNumber number;
    parameterThree ame_conditions.parameter_three%type;
    parameterTwo ame_conditions.parameter_two%type;
    parameterTwoDate date;
    parameterTwoNumber number;
    begin
      /* Check whether the condition is on a header-level attribute. */
      if(engItemClassNames(engItemClassIndexes(engAttributeItemClassIds(engACAttributeIds(conditionIdIn)))) =
           ame_util.headerItemClassName) then
        headerLevelCondition := true;
      else
        headerLevelCondition := false;
      end if;
      attributeId := engACAttributeIds(conditionIdIn);
      /* Check for a cached value, for conditions on header-level attributes. */
      if (headerLevelCondition and
           not engIsTestTransaction and
           not engAttributeVariant.exists(attributeId) and
           engHeaderConditionValues.exists(conditionIdIn)) then
        /* The value is cached. */
        if(engHeaderConditionValues(conditionIdIn) = ame_util.booleanTrue) then
          return(true);
        end if;
        return(false);
      end if;
      /* The value must be calculated. */
      attributeType := engAttributeTypes(attributeId);
      if(attributeType <> ame_util.stringAttributeType) then
        includeLowerLimit := engACIncludeLowerLimits(conditionIdIn);
        includeUpperLimit := engACIncludeUpperLimits(conditionIdIn);
        parameterOne := engACParameterOnes(conditionIdIn);
        parameterTwo := engACParameterTwos(conditionIdIn);
        parameterThree := engACParameterThrees(conditionIdIn);
      end if;
      if(headerLevelCondition) then
        if isVariant(attributeId) then
          attributeValue1 :=  getVariantAttributeValue
                                 (attributeIdIn => attributeId,
                                  itemClassIn   => getItemClassName(itemClassIdIn => itemClassIdIn),
                                  itemIdIn      => engItemIds(itemIndexIn));
        else
          getHeaderAttValues1(attributeIdIn => attributeId,
                              attributeValue1Out => attributeValue1,
                              attributeValue2Out => attributeValue2,
                              attributeValue3Out => attributeValue3);
        end if;
      else
        getItemAttValues3(attributeIdIn => attributeId,
                          itemIndexIn => itemIndexIn,
                          attributeValue1Out => attributeValue1,
                          attributeValue2Out => attributeValue2,
                          attributeValue3Out => attributeValue3);
      end if;
      /* numbers and currencies */
      if(attributeType = ame_util.numberAttributeType or
         attributeType = ame_util.currencyAttributeType) then
        /* First handle the case of a null value. */
        if(attributeValue1 is null) then
          if(parameterOne is null and
             parameterTwo is null) then
            if(headerLevelCondition) then
              engHeaderConditionValues(conditionIdIn) := ame_util.booleanTrue;
            end if;
            return(true);
          else
            if(headerLevelCondition) then
              engHeaderConditionValues(conditionIdIn) := ame_util.booleanFalse;
            end if;
            return(false);
          end if;
        end if;
        /* Now handle the other cases. */
        if(attributeType = ame_util.currencyAttributeType and
        /* Issue 6 of the Bug list bug (4094080) */
        /* modified form parameterThree <> attributeValue3 to */
        /* parameterThree <> attributeValue2 */
           parameterThree <> attributeValue2) then
          attributeNumberValue :=
            ame_util.convertCurrency(fromCurrencyCodeIn => attributeValue2,
                                     toCurrencyCodeIn => parameterThree,
                                     conversionTypeIn => attributeValue3,
                                     amountIn => fnd_number.canonical_to_number(canonical => attributeValue1),
                                     dateIn => engEffectiveRuleDate,
                                     applicationIdIn => engAmeApplicationId);
        else
          attributeNumberValue := fnd_number.canonical_to_number(canonical => attributeValue1);
        end if;
        parameterOneNumber := fnd_number.canonical_to_number(canonical => parameterOne);
        parameterTwoNumber := fnd_number.canonical_to_number(canonical => parameterTwo);
        if(includeLowerLimit = ame_util.booleanTrue and
           attributeNumberValue = parameterOneNumber) then
          if(headerLevelCondition) then
            engHeaderConditionValues(conditionIdIn) := ame_util.booleanTrue;
          end if;
          return(true);
        end if;
        if(includeUpperLimit = ame_util.booleanTrue and
           attributeNumberValue = parameterTwoNumber) then
          if(headerLevelCondition) then
            engHeaderConditionValues(conditionIdIn) := ame_util.booleanTrue;
          end if;
          return(true);
        end if;
        if((parameterOneNumber is null and attributeNumberValue < parameterTwoNumber) or
           (parameterOneNumber < attributeNumberValue and parameterTwoNumber is null) or
           (parameterOneNumber < attributeNumberValue and attributeNumberValue < parameterTwoNumber)) then
          if(headerLevelCondition) then
            engHeaderConditionValues(conditionIdIn) := ame_util.booleanTrue;
          end if;
          return(true);
        end if;
      /* dates */
      elsif(attributeType = ame_util.dateAttributeType) then
        attributeValueDate := ame_util.versionStringToDate(stringDateIn => attributeValue1);
        parameterOneDate := ame_util.versionStringToDate(stringDateIn => parameterOne);
        parameterTwoDate := ame_util.versionStringToDate(stringDateIn => parameterTwo);
        /* First handle the case of a null value. */
        if(attributeValue1 is null) then
          if(parameterOne is null and
             parameterTwo is null) then
            if(headerLevelCondition) then
              engHeaderConditionValues(conditionIdIn) := ame_util.booleanTrue;
            end if;
            return(true);
          else
            if(headerLevelCondition) then
              engHeaderConditionValues(conditionIdIn) := ame_util.booleanFalse;
            end if;
            return(false);
          end if;
        end if;
        /* Now handle the other cases. */
        if(includeLowerLimit = ame_util.booleanTrue and
           attributeValueDate = parameterOneDate) then
          if(headerLevelCondition) then
            engHeaderConditionValues(conditionIdIn) := ame_util.booleanTrue;
          end if;
          return(true);
        end if;
        if(includeUpperLimit = ame_util.booleanTrue and
           attributeValueDate = parameterTwoDate) then
          if(headerLevelCondition) then
            engHeaderConditionValues(conditionIdIn) := ame_util.booleanTrue;
          end if;
          return(true);
        end if;
        if((parameterOneDate is null and attributeValueDate < parameterTwoDate) or
           (parameterOneDate < attributeValueDate and parameterTwoDate is null) or
           (parameterOneDate < attributeValueDate and attributeValueDate < parameterTwoDate)) then
          if(headerLevelCondition) then
            engHeaderConditionValues(conditionIdIn) := ame_util.booleanTrue;
          end if;
          return(true);
        end if;
      /* booleans */
      elsif(attributeType = ame_util.booleanAttributeType) then
        if((attributeValue1 is null and
            parameterOne is null) or
           attributeValue1 = parameterOne) then
          if(headerLevelCondition) then
            engHeaderConditionValues(conditionIdIn) := ame_util.booleanTrue;
          end if;
          return(true); /* If both pseudo-booleans are null, the condition applies. */
        end if;
        return(false);
      /* strings */
      elsif(attributeType = ame_util.stringAttributeType) then
        /* Note that if the attribute value and a string value are both null, the condition applies. */
        for stringValueIndex in
          engACStringValueFirstIndexes(conditionIdIn) ..
          (engACStringValueFirstIndexes(conditionIdIn) + engACStringValueCounts(conditionIdIn) - 1) loop
          if((attributeValue1 is null and engACStringValues(stringValueIndex) is null) or
             attributeValue1 = engACStringValues(stringValueIndex)) then
            if(headerLevelCondition) then
              engHeaderConditionValues(conditionIdIn) := ame_util.booleanTrue;
            end if;
            return(true);
          end if;
        end loop;
      else
        raise attributeTypeException;
      end if;
      /* The condition is not satisfied. */
      if(headerLevelCondition) then
        engHeaderConditionValues(conditionIdIn) := ame_util.booleanFalse;
      end if;
      return(false);
      exception
        when attributeTypeException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400113_ENG_ATTR_UNREG_TYPE');
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'conditionIsSatisfied',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'conditionIsSatisfied',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end conditionIsSatisfied;
  function evalPrioritiesPerItem return boolean as
    begin
      return(engEvalPrioritiesPerItem);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'evalPrioritiesPerItem',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end evalPrioritiesPerItem;
  function insertionExists(orderTypeIn in varchar2,
                           parameterIn in varchar2) return boolean as
    begin
      for i in 1 .. engInsertionOrderTypeList.count loop
        if(engInsertionOrderTypeList(i) = orderTypeIn and
           engInsertionParameterList(i) = parameterIn) then
          return(true);
        end if;
      end loop;
      return(false);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'insertionExists',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end insertionExists;
  function isLocalTransaction return boolean as
    begin
      return(engIsLocalTransaction);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'isLocalTransaction',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end isLocalTransaction;
  function isStaticAttUsage(attributeIdIn in integer) return boolean as
    begin
      if(engAttributeIsStatics(attributeIdIn) = ame_util.booleanTrue) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'isStaticAttUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end isStaticAttUsage;
  function isTestTransaction return boolean as
    begin
      return(engIsTestTransaction);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'isTestTransaction',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end isTestTransaction;
  function isVariant(attributeIdIn in integer) return boolean as
  begin
    if checkAttributeVariant(attributeIdIn) = ame_util.booleanTrue then
      if engIsTestTransaction then
        return true;
      elsif engAttributeVariant.exists(attributeIdIn) then
        return true;
      end if;
    end if;
    return false;
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_engine',
                                  routineNameIn => 'isVariant',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
        return(null);
  end isVariant;
  function processPriorities return boolean as
    begin
      return(engProcessPriorities);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'processPriorities',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end processPriorities;
  function processProductionActions return boolean as
    begin
      return(engProcessProductionActions);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'processProductionActions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end processProductionActions;
  function processProductionRules return boolean as
    begin
      return(engProcessProductionRules);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'processProductionRules',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end processProductionRules;
  /********************************* fetch functions **********************************/
  function fetchAmeApplicationId(fndApplicationIdIn in integer,
                                 transactionTypeIdIn in varchar2 default null) return integer as
    ameApplicationId integer;
    begin
      select application_id
        into ameApplicationId
        from ame_calling_apps
        where
          fnd_application_id = fndApplicationIdIn and
          ((transactionTypeIdIn is null and transaction_type_id is null) or
           (transaction_type_id = transactionTypeIdIn)) and
          /* Don't use engEffectiveRuleDate here. */
          sysdate between
            start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) and
          rownum < 2; /* Avoids second fetch otherwise required by ANSI standard to check for too many rows. */
      return(ameApplicationId);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'fetchAmeApplicationId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end fetchAmeApplicationId;
  /********************************** get functions ***********************************/
  function getActionTypeChainOrderMode(actionTypeIdIn in integer) return varchar2 as
    begin
      return(engActionTypeChainOrderModes(actionTypeIdIn));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getActionTypeChainOrderMode',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getActionTypeChainOrderMode;
  function getActionTypeId(actionTypeNameIn in varchar2) return integer as
    tempIndex integer;
    begin
      tempIndex := engActionTypeNames.first;
      while(tempIndex is not null) loop
        if(engActionTypeNames(tempIndex) = actionTypeNameIn) then
          return(tempIndex);
        end if;
        tempIndex := engActionTypeNames.next(tempIndex);
      end loop;
      return(null);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getActionTypeId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getActionTypeId;
  function getActionTypeName(actionTypeIdIn in integer) return varchar2 as
    begin
      return(engActionTypeNames(actionTypeIdIn));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getActionTypeName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getActionTypeName;
  function getActionTypeOrderNumber(actionTypeIdIn in integer) return integer as
    begin
      return(engActionTypeOrderNumbers(actionTypeIdIn));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getActionTypeOrderNumber',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getActionTypeOrderNumber;
  function getActionTypePackageName(actionTypeIdIn in integer) return varchar2 as
    begin
      return(engActionTypePackageNames(actionTypeIdIn));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getActionTypePackageName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getActionTypePackageName;
  function getActionTypeUsage(actionTypeIdIn in integer) return integer as
    begin /* getActionTypeUsage returns the rule type that uses the input action type. */
      return(engActionTypeUsages(actionTypeIdIn));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getActionTypeUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getActionTypeUsage;
  function getActionTypeVotingRegime(actionTypeIdIn in integer) return varchar2 as
    begin
      if(actionTypeIdIn = ame_util.nullInsertionActionTypeId or actionTypeIdIn = -2 ) then
        return(null);
      end if;
      return(engActionTypeVotingRegimes(actionTypeIdIn));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getActionTypeVotingRegime',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getActionTypeVotingRegime;
  function getAmeApplicationId return integer as
    begin
      return(engAmeApplicationId);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getAmeApplicationId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getAmeApplicationId;
  function getApprovalProcessCompleteYN return varchar2 as
    begin
      return(engStApprovalProcessCompleteYN);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getApprovalProcessCompleteYN',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getApprovalProcessCompleteYN;
  function getAttributeIdByName(attributeNameIn in varchar2) return integer as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    notFoundException exception;
    tempIndex integer;
    begin
      tempIndex := engAttributeNames.first;
      loop
        if(tempIndex is null) then
          raise notFoundException;
        end if;
        if(engAttributeNames(tempIndex) = attributeNameIn) then
          return(tempIndex);
        end if;
        tempIndex := engAttributeNames.next(tempIndex);
      end loop;
      exception
        when notFoundException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn   => 'AME_400680_NO_ID_FOR_ATTR',
                                              tokenNameOneIn  => 'ATTRIBUTE_NAME',
                                              tokenValueOneIn => attributeNameIn);
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getAttributeIdByName',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode, errorMessage);
          return(null);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getAttributeIdByName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => attributeNameIn || ':  ' || sqlerrm);
          raise;
          return(null);
    end getAttributeIdByName;
  function getAttributeName(attributeIdIn in integer) return varchar2 as
    begin
      return(engAttributeNames(attributeIdIn));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getAttributeName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getAttributeName;
  function getAttributeType(attributeIdIn in integer) return varchar2 as
    begin
      return(engAttributeTypes(attributeIdIn));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getAttributeType',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getAttributeType;
  function getConfigVarValue(configVarNameIn in varchar2) return varchar2 as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    noValueException exception;
    begin
      for i in 1 .. engConfigVarNames.count loop
        if(engConfigVarNames(i) = configVarNameIn) then
          return(engConfigVarValues(i));
        end if;
      end loop;
      raise noValueException;
      exception
        when noValueException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400114_ENG_INV_CON_VAR',
                                              tokenNameOneIn => 'CONFIG_VAR',
                                              tokenValueOneIn => configVarNameIn);
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getConfigVarValue',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getConfigVarValue',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getConfigVarValue;
  function getEffectiveRuleDate return date as
    begin
      return(engEffectiveRuleDate);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getEffectiveRuleDate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getEffectiveRuleDate;
  function getFndApplicationId return integer as
    begin
      return(engFndApplicationId);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getFndApplicationId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getFndApplicationId;
  function getForwardingBehavior(forwarderTypeIn in varchar2,
                                 forwardeeTypeIn in varchar2,
                                 approvalStatusIn in varchar2) return varchar2 as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    badArgsException exception;
    begin
      if(forwarderTypeIn = ame_util.chainOfAuthorityForwarder) then
        if(forwardeeTypeIn = ame_util.previousSameChainForwardee) then
          if(approvalStatusIn = ame_util.forwardStatus) then
            return(engForwardingBehaviors(1));
          elsif(approvalStatusIn = ame_util.approveAndForwardStatus) then
            return(engForwardingBehaviors(2));
          end if;
        elsif(forwardeeTypeIn = ame_util.subordSameHierarchyForwardee) then
          if(approvalStatusIn = ame_util.forwardStatus) then
            return(engForwardingBehaviors(3));
          elsif(approvalStatusIn = ame_util.approveAndForwardStatus) then
            return(engForwardingBehaviors(4));
          end if;
        elsif(forwardeeTypeIn = ame_util.alreadyInListForwardee) then
          if(approvalStatusIn = ame_util.forwardStatus) then
            return(engForwardingBehaviors(5));
          elsif(approvalStatusIn = ame_util.approveAndForwardStatus) then
            return(engForwardingBehaviors(6));
          end if;
        end if;
      elsif(forwarderTypeIn = ame_util.adHocForwarder) then
        if(forwardeeTypein = ame_util.alreadyInListForwardee) then
          if(approvalStatusIn = ame_util.forwardStatus) then
            return(engForwardingBehaviors(7));
          elsif(approvalStatusIn = ame_util.approveAndForwardStatus) then
            return(engForwardingBehaviors(8));
          end if;
        end if;
      end if;
      raise badArgsException;
      exception
        when badArgsException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400115_ENG_INV_VAL_ARG');
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getForwardingBehavior',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getForwardingBehavior',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getForwardingBehavior;
  function getHandlerActionTypeId return integer as
    begin
      return(engAppActionTypeIds(engAppHandlerFirstIndex));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerActionTypeId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getHandlerActionTypeId;
  function getHandlerActionTypeOrderNum return integer as
    begin
      return(engActionTypeOrderNumbers(engAppActionTypeIds(engAppHandlerFirstIndex)));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerActionTypeOrderNum',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getHandlerActionTypeOrderNum;
  function getHandlerApprovalStatus(approverIn in ame_util.approverRecord2,
                                    votingRegimeIn in varchar2 default null) return varchar2 as
    l_approvalStatus varchar2(50);
    l_action_type_id number;
    l_votingRegime  varchar2(100);
    l_action_type_name varchar2(100);
    begin
      for i in 1..engOldApproverList.count loop
        if(approversMatch(approverRecord1In => approverIn,
                          approverRecord2In => engOldApproverList(i))) then
          l_approvalStatus := engOldApproverList(i).approval_status;
        end if;
      end loop;
      if l_approvalStatus is null and (approverIn.action_type_id <> ame_util.nullInsertionActionTypeId and
                          approverIn.action_type_id is not null)then
        l_action_type_id := approverIn.action_type_id;
        l_action_type_name := getActionTypeName(l_action_type_id);
        if l_action_type_name not in (ame_util.postApprovalTypeName,ame_util.preApprovalTypeName ) then
          l_votingRegime := ame_engine.getActionTypeVotingRegime(actionTypeIdIn => approverIn.action_type_id);
        else
          l_votingRegime := votingRegimeIn;
        end if;
        if l_votingRegime = ame_util.firstApproverVoting then
          for i in 1..engOldApproverList.count loop
            if approverIn.name <> engOldApproverList(i).name and
                approverIn.action_type_id = engOldApproverList(i).action_type_id and
                approverIn.group_or_chain_id = engOldApproverList(i).group_or_chain_id and
                approverIn.item_class = engOldApproverList(i).item_class and
                approverIn.item_id = engOldApproverList(i).item_id and
                engOldApproverList(i).approval_status in (ame_util.approvedStatus
                                                      ,ame_util.beatByFirstResponderStatus
                                                      ,ame_util.rejectStatus  ) then
                 return(ame_util.beatByFirstResponderStatus);
           end if;
          end loop;
        end if;
          return(l_approvalStatus);
      else
        return(l_approvalStatus);
      end if;
      return(null);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerApprovalStatus',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getHandlerApprovalStatus;
  function getHandlerAuthority return varchar2 as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    badRuleTypeException exception;
    ruleType integer;
    begin
      ruleType := getHandlerRuleType;
      if(ruleType = ame_util.preListGroupRuleType) then
        return(ame_util.preApprover);
      elsif(ruleType = ame_util.postListGroupRuleType) then
        return(ame_util.postApprover);
      elsif(ruleType = ame_util.authorityRuleType) then
        return(ame_util.authorityApprover);
      else
        raise badRuleTypeException;
      end if;
      exception
        when badRuleTypeException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400681_INV_HANDLER_RUL_TYP');
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerAuthority',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerAuthority',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getHandlerAuthority;
  function getHandlerItemClassId return integer as
    begin
      return(engAppRuleItemClassIds(engAppHandlerFirstIndex));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerItemClassId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getHandlerItemClassId;
  function getHandlerItemClassName return varchar2 as
    begin
      return(getItemClassName(itemClassIdIn => engAppRuleItemClassIds(engAppHandlerFirstIndex)));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerItemClassName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getHandlerItemClassName;
  function getHandlerItemClassOrderNumber return integer as
    begin
      return(engItemClassOrderNumbers(engItemClassIndexes(engAppRuleItemClassIds(engAppHandlerFirstIndex))));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerItemClassOrderNumber',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getHandlerItemClassOrderNumber;
  function getHandlerItemId return varchar2 as
    begin
      return(engAppAppItemIds(engAppHandlerFirstIndex));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerItemId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getHandlerItemId;
  function getHandlerItemOrderNumber return integer as
    begin
      if(getItemClassParMode(itemClassIdIn => engAppRuleItemClassIds(engAppHandlerFirstIndex)) =
         ame_util.parallelItems) then
        return(1);
      else /* The parallelization modes is ame_util.serialItems. */
        return(1 + getItemOffset(itemClassIdIn => engAppRuleItemClassIds(engAppHandlerFirstIndex),
                                 itemIdIn => engAppAppItemIds(engAppHandlerFirstIndex)));
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerItemOrderNumber',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getHandlerItemOrderNumber;
  function getHandlerOccurrence(nameIn in varchar2,
                                itemClassIn in varchar2 default null,
                                itemIdIn in varchar2 default null,
                                actionTypeIdIn in integer default null,
                                groupOrChainIdIn in integer default null) return integer as
    engStApproversCount integer;
    itemClass ame_temp_old_approver_lists.item_class%type;
    itemId ame_temp_old_approver_lists.item_id%type;
    actionTypeId integer;
    groupOrChainId integer;
    occurrence integer;
    begin
      engStApproversCount := engStApprovers.count;
      /* Handle the empty-list case first. */
        if(engStApproversCount = 0) then
          return(1);
        end if;
      /* Determine which chain of authority to match. */
      if(itemClassIn is null or
         itemIdIn is null or
         actionTypeIdIn is null or
         groupOrChainIdIn is null) then
        /*
          If we're not trying to match an inserted approver with nullInsertionActionTypeId and
          nullInsertionGroupOrChainId, and one of the input arguments is null, match the most
          recently added group or chain.
        */
        for i in reverse 1 .. engStApproversCount loop
          if(engStApprovers(i).action_type_id <> ame_util.nullInsertionActionTypeId and
             engStApprovers(i).group_or_chain_id <> ame_util.nullInsertionGroupOrChainId and
             engStApprovers(i).item_class is not null and
             engStApprovers(i).item_id is not null and
             engStApprovers(i).action_type_id is not null and
             engStApprovers(i).group_or_chain_id is not null) then
            itemClass := engStApprovers(i).item_class;
            itemId := engStApprovers(i).item_id;
            actionTypeId := engStApprovers(i).action_type_id;
            groupOrChainId := engStApprovers(i).group_or_chain_id;
            exit;
          end if;
        end loop;
      else
        itemClass := itemClassIn;
        itemId := itemIdIn;
        actionTypeId := actionTypeIdIn;
        groupOrChainId := groupOrChainIdIn;
      end if;
      if(itemClass is null) then
        /*
          One of the input arguments is null, and all approvers in the list have nullInsertionActionTypeId and
          nullInsertionGroupOrChainId.  So these are the only action-type ID and group-or-chain ID we can match.
          In this case, match the item class and item ID of the most recent insertion.
        */
        itemClass := engStApprovers(engStApproversCount).item_class;
        itemId := engStApprovers(engStApproversCount).item_id;
        actionTypeId := engStApprovers(engStApproversCount).action_type_id;
        groupOrChainId := engStApprovers(engStApproversCount).group_or_chain_id;
      end if;
      /* Now count matches within the target item class, item ID, action-type ID, and group-or-chain ID. */
      occurrence := 1;
      for i in 1 .. engStApproversCount loop
        /*
          The order of the comparisons in the if statement below is significant for efficiency.
          (Most of the time, the names won't match, and that ends the comparison for engStApprovers(i).)
          (We could stop the comparison upon leaving the target item's approver list, but this would
          generally take more work than it would save.)
        */
        if(engStApprovers(i).name = nameIn and
           engStApprovers(i).group_or_chain_id = groupOrChainId and
           engStApprovers(i).action_type_id = actionTypeId and
           engStApprovers(i).item_id = itemId and
           engStApprovers(i).item_class = itemClass) then
          occurrence := occurrence + 1;
        end if;
      end loop;
      return(occurrence);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerOccurrence',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getHandlerOccurrence;
  function getHandlerRuleType return integer as
    begin
      return(engAppRuleTypes(engAppHandlerFirstIndex));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerRuleType',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getHandlerRuleType;
  function getHandlerState(handlerNameIn in varchar2,
                           parameterIn in varchar2 default null) return varchar2 as
    handlerName ame_temp_handler_states.handler_name%type;
    tempState ame_temp_handler_states.state%type;
    begin
      handlerName := upper(handlerNameIn);
      select state
        into tempState
        from ame_temp_handler_states
        where
          handler_name = handlerName and
          ((application_id is null and engAmeApplicationId is null) or
           (application_id = engAmeApplicationId)) and
          ((parameter is null and parameterIn is null) or
           (parameter = parameterIn)) and
          rownum < 2; /* Avoids second fetch otherwise required by ANSI standard to check for too many rows. */
      return(tempState);
      exception
        when no_data_found then
          return(null);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerState',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getHandlerState;
  function getHandlerSublistOrderNum return integer as
    handlerAuthority ame_util.charType;
    itemClassSublistMode ame_util.charType;
    begin
      handlerAuthority := getHandlerAuthority;
      itemClassSublistMode := getItemClassSublistMode(itemClassIdIn => engAppRuleItemClassIds(engAppHandlerFirstIndex));
      if(itemClassSublistMode = ame_util.serialSublists) then
        if(handlerAuthority = ame_util.preApprover) then
          return(1);
        elsif(handlerAuthority = ame_util.authorityApprover) then
          return(2);
        else
          return(3);
        end if;
      elsif(itemClassSublistMode = ame_util.parallelSublists) then
        return(1);
      elsif(itemClassSublistMode = ame_util.preFirst) then
        if(handlerAuthority = ame_util.preApprover) then
          return(1);
        else
          return(2);
        end if;
      else
        if(handlerAuthority = ame_util.postApprover) then
          return(2);
        else
          return(1);
        end if;
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerSublistOrderNum',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getHandlerSublistOrderNum;
  function getHeaderAttValue1(attributeIdIn in integer) return varchar2 as
    begin
      return(engAttributeValues1(engAttributeValueIndexes(attributeIdIn)));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHeaderAttValue1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getHeaderAttValue1;
  function getTestVariantAttValue(attributeIdIn in integer,
                                 itemClassIdIn  in integer,
                                 itemIdIn       in varchar2) return number as
    tempValue ame_util.attributeValueType;
    begin
      select attribute_value_1 into tempValue from ame_test_trans_att_values
        where application_id = engAmeApplicationId
          and transaction_id = engTransactionId
          and attribute_id = attributeIdIn
          and item_class_id = itemClassIdIn
          and item_id    = itemIdIn;
      return tempValue;
      exception
        when no_data_found then
          begin
            select attribute_value_1
              into tempValue
              from ame_test_trans_att_values
             where application_id = engAmeApplicationId
               and transaction_id = engTransactionId
               and attribute_id = attributeIdIn
               and item_class_id = getItemClassId(ame_util.headerItemClassName)
               and item_id    = engTransactionId;
            return tempValue;
          exception
            when others then
              ame_util.runtimeException(packageNameIn => 'ame_engine',
                                        routineNameIn => 'getTestVariantAttValue',
                                        exceptionNumberIn => sqlcode,
                                        exceptionStringIn => sqlerrm);
              raise;
              return(null);
          end;
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getTestVariantAttValue',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getTestVariantAttValue;
  function getHeaderAttValue2(attributeNameIn in varchar2) return varchar2 as
    attributeId integer;
    begin
      if engIsTestTransaction then
        attributeId := getAttributeIdByName(attributeNameIn => attributeNameIn);
        if checkAttributeVariant(attributeId) = ame_util.booleanTrue then
           return getTestVariantAttValue(attributeIdIn => attributeId
                                       ,itemClassIdIn => engAppRuleItemClassIds(engAppHandlerFirstIndex)
                                       ,itemIdIn => engAppAppItemIds(engAppHandlerFirstIndex));
        else
          return(engAttributeValues1(engAttributeValueIndexes(getAttributeIdByName(attributeNameIn => attributeNameIn))));
        end if;
      else
        if(engAttributeVariant.exists(getAttributeIdByName(attributeNameIn => attributeNameIn))) then
          return(getVariantAttributeValue(attributeIdIn => getAttributeIdByName(attributeNameIn => attributeNameIn),
                                          itemClassIn => getItemClassName(itemClassIdIn => engAppRuleItemClassIds(engAppHandlerFirstIndex)),
                                          itemIdIn => engAppAppItemIds(engAppHandlerFirstIndex)));
        else
          return(engAttributeValues1(engAttributeValueIndexes(getAttributeIdByName(attributeNameIn => attributeNameIn))));
        end if;
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHeaderAttValue2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getHeaderAttValue2;
  function getItemAttValue1(attributeIdIn in integer,
                            itemIdIn in varchar2) return varchar2 as
    begin
      return(engAttributeValues1(engAttributeValueIndexes(attributeIdIn) +
                                 getItemOffset(itemClassIdIn => engAttributeItemClassIds(attributeIdIn),
                                               itemIdIn => itemIdIn)));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemAttValue1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemAttValue1;
  function getItemAttValue2(attributeNameIn in varchar2,
                            itemIdIn in varchar2) return varchar2 as
    attributeId integer;
    begin
      attributeId := getAttributeIdByName(attributeNameIn => attributeNameIn);
      return(engAttributeValues1(engAttributeValueIndexes(attributeId) +
                                  getItemOffset(itemClassIdIn => engAttributeItemClassIds(attributeId),
                                                itemIdIn => itemIdIn)));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemAttValue2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemAttValue2;
  function getItemClassId(itemClassNameIn in varchar2) return integer as
    begin
      for itemClassIndex in 1 .. engItemClassNames.count loop
        if(engItemClassNames(itemClassIndex) = itemClassNameIn) then
          return(engItemClassIds(itemClassIndex));
        end if;
      end loop;
      return(null);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemClassId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemClassId;
  function getItemClassName(itemClassIdIn in integer) return varchar2 as
    begin
      return(engItemClassNames(engItemClassIndexes(itemClassIdIn)));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemClassName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemClassName;
  function getItemClassOrderNumber(itemClassIdIn in integer) return integer as
    begin
      return(engItemClassOrderNumbers(engItemClassIndexes(itemClassIdIn)));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemClassOrderNumber',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemClassOrderNumber;
  function getItemClassParMode(itemClassIdIn in integer) return varchar2 as
    begin
      return(engItemClassParModes(engItemClassIndexes(itemClassIdIn)));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemClassParMode',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemClassParMode;
  function getItemClassSublistMode(itemClassIdIn in integer) return varchar2 as
    begin
      return(engItemClassSublistModes(engItemClassIndexes(itemClassIdIn)));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemClassSublistMode',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemClassSublistMode;
  function getItemIndex(itemClassIdIn in integer,
                        itemIdIn in varchar2) return integer as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    firstItemIndex integer;
    itemClassIndex integer;
    noIndexException exception;
    begin
      itemClassIndex := engItemClassIndexes(itemClassIdIn);
      firstItemIndex := engItemClassItemIdIndexes(itemClassIndex);
      for i in firstItemIndex .. (firstItemIndex + engItemCounts(itemClassIndex) - 1) loop
        if(engItemIds(i) = itemIdIn) then
          return(i);
        end if;
      end loop;
      raise noIndexException;
      exception
        when noIndexException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400682_ENG_INV_ITEM_OFFSET');
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemIndex',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemIndex',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemIndex;
  function getItemOffset(itemClassIdIn in integer,
                         itemIdIn in varchar2) return integer as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    firstItemIndex integer;
    itemClassIndex integer;
    noOffsetException exception;
    begin
      itemClassIndex := engItemClassIndexes(itemClassIdIn);
      firstItemIndex := engItemClassItemIdIndexes(itemClassIndex);
      for i in firstItemIndex .. (firstItemIndex + engItemCounts(itemClassIndex) - 1) loop
        if(engItemIds(i) = itemIdIn) then
          return(i - firstItemIndex);
        end if;
      end loop;
      raise noOffsetException;
      exception
        when noOffsetException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400682_ENG_INV_ITEM_OFFSET');
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemOffset',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemOffset',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemOffset;
  function getItemOrderNumber(itemClassNameIn in varchar2,
                              itemIdIn in varchar2) return integer as
    itemClassId integer;
    begin
      itemClassId := getItemClassId(itemClassNameIn => itemClassNameIn);
      if(getItemClassParMode(itemClassIdIn => itemClassId) = ame_util.parallelItems) then
        return(1);
      else /* The parallelization modes is ame_util.serialItems. */
        return(1 + getItemOffset(itemClassIdIn => itemClassId,
                                 itemIdIn => itemIdIn));
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemOrderNumber',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemOrderNumber;
  function getNextInsertionOrder return integer as
    maxInsertionOrderNumber number;
    begin
      select max(insertion_order)
        into maxInsertionOrderNumber
        from ame_temp_insertions
       where transaction_id = engTransactionId
         and application_id = engAmeApplicationId;
      if maxinsertionOrderNumber is null
      then
        return 1;
      else
        return (maxInsertionOrderNumber + 1);
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getNextInsertionOrder',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getNextInsertionOrder;
  function getNullActionTypeOrderNumber return integer as
    maxOrderNumber integer := 0;
    tempIndex integer;
    begin
      tempIndex := engActionTypeOrderNumbers.first;
      while(tempIndex is not null) loop
        if(maxOrderNumber is null or
           engActionTypeOrderNumbers(tempIndex) < maxOrderNumber) then
          maxOrderNumber := engActionTypeOrderNumbers(tempIndex);
        end if;
        tempIndex := engActionTypeOrderNumbers.next(tempIndex);
      end loop;
      return(maxOrderNumber + 1);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getNullActionTypeOrderNumber',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getNullActionTypeOrderNumber;
  function getRuntimeGroupCount(groupIdIn in integer) return integer as
    tempIndex integer;
    begin
      tempIndex := 0; /* pre-increment */
      -- Check if group is defined or has to be re run for every item class/item ID
      if(not engGroupUseItemBind.exists(groupIdIn)) then
        fetchRuntimeGroup(groupIdIn => groupIdIn);
      elsif (engGroupUseItemBind(groupIdIn) = ame_util.booleanTrue) then
        fetchRuntimeGroup(groupIdIn => groupIdIn);
      end if;
      /* Group membership must exist in  engGroupMemberGroupIds now. */
      for i in 1 .. engGroupMemberGroupIds.count loop
        if(engGroupMemberGroupIds(i) = groupIdIn) then
          tempIndex := tempIndex + 1;
        elsif(tempIndex > 0) then
          /* The group was found and has been passed. */
          return(tempIndex);
        end if;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getRuntimeGroupCount',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getRuntimeGroupCount;
  function getSublistOrderNum(itemClassNameIn in varchar2,
                              authorityIn in varchar2) return integer as
    itemClassSublistMode ame_util.charType;
    begin
      itemClassSublistMode :=
        getItemClassSublistMode(itemClassIdIn => getItemClassId(itemClassNameIn => itemClassNameIn));
      if(itemClassSublistMode = ame_util.serialSublists) then
        if(authorityIn = ame_util.preApprover) then
          return(1);
        elsif(authorityIn = ame_util.authorityApprover) then
          return(2);
        else
          return(3);
        end if;
      elsif(itemClassSublistMode = ame_util.parallelSublists) then
        return(1);
      elsif(itemClassSublistMode = ame_util.preFirst) then
        if(authorityIn = ame_util.preApprover) then
          return(1);
        else
          return(2);
        end if;
      else
        if(authorityIn = ame_util.postApprover) then
          return(2);
        else
          return(1);
        end if;
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getSublistOrderNum',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getSublistOrderNum;
  function getTransactionId return varchar2 as
    begin
      return(engTransactionID);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getTransactionId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getTransactionId;
  function getTransactionTypeId return varchar2 as
    begin
      return(engTransactionTypeID);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getTransactionTypeId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getTransactionTypeId;
  /********************************** sort functions **********************************/
  function compareApplicableRules(index1In in integer,
                                  index2In in integer,
                                  compareActionTypesIn in boolean) return boolean as
    /* Returns true if the applicable rule at the first index weakly precedes the second. */
    actionTypeId1 integer;
    actionTypeId2 integer;
    itemClassId1 integer;
    itemClassId2 integer;
    begin
      itemClassId1 := engAppRuleItemClassIds(index1In);
      itemClassId2 := engAppRuleItemClassIds(index2In);
      /* Account for the possibility that one or both rules may have null item-class IDs. */
      if(itemClassId1 is null) then
        if(itemClassId2 is not null) then
          return(false);
        end if;
      else /* itemClassId1 is not null. */
        if(itemClassId2 is null) then
          return(true);
        else /* Both item-class IDs are non-null. */
          /* item-class order number */
          if(engItemClassOrderNumbers(engItemClassIndexes(itemClassId1)) >
             engItemClassOrderNumbers(engItemClassIndexes(itemClassId2))) then
            return(false);
          end if;
          if(engItemClassOrderNumbers(engItemClassIndexes(itemClassId1)) <
             engItemClassOrderNumbers(engItemClassIndexes(itemClassId2))) then
            return(true);
          end if;
          /* item-class ID */
          if(itemClassId1 > itemClassId2) then
            return(false);
          end if;
          if(itemClassId1 < itemClassId2) then
            return(true);
          end if;
        end if;
      end if;
      /* item ID */
      if(engAppAppItemIds(index1In) > engAppAppItemIds(index2In)) then
        return(false);
      end if;
      if(engAppAppItemIds(index1In) < engAppAppItemIds(index2In)) then
        return(true);
      end if;
      /* rule type */
      if(engAppRuleTypes(index1In) > engAppRuleTypes(index2In)) then
        return(false);
      end if;
      /*
        The second rule-type comparison is only necessary if compareActionTypesIn is true;
        otherwise, we return true regardless of the outcome of the second rule-type comparison.
        So include it within the if(compareActionTypesIn) below.
      /* optional action-type comparisons */
      if(compareActionTypesIn) then
        if(engAppRuleTypes(index1In) < engAppRuleTypes(index2In)) then
          return(true);
        end if;
        /* Do the action-type comparisons. */
        actionTypeId1 := engAppActionTypeIds(index1In);
        actionTypeId2 := engAppActionTypeIds(index2In);
        /* action-type order numbers */
        if(engActionTypeOrderNumbers(actionTypeId1) >
           engActionTypeOrderNumbers(actionTypeId2)) then
          return(false);
        end if;
        if(engActionTypeOrderNumbers(actionTypeId1) <
           engActionTypeOrderNumbers(actionTypeId2)) then
          return(true);
        end if;
        /* action-type ID */
        if(actionTypeId1 > actionTypeId2) then
          return(false);
        end if;
        /*
          The second comparison on action-type ID is unnecessary, because whether it succeeds
          or fails, we return true.
        */
      end if;
      return(true);
        exception
          when others then
            ame_util.runtimeException(packageNameIn => 'ame_engine',
                                      routineNameIn => 'compareApplicableRules',
                                      exceptionNumberIn => sqlcode,
                                      exceptionStringIn => sqlerrm);
            raise;
            return(false);
    end compareApplicableRules;
  /*************************************************************************************
  procedures
  *************************************************************************************/
  procedure addApprover(approverIn in ame_util.approverRecord2) as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    listTooLongException exception;
    nullFieldException exception;
    begin
      if(engStApprovers.count > 2500) then
        raise listTooLongException;
      end if;
      checkApprover(approverIn => approverIn);
      if(approverIn.name is null or
         approverIn.orig_system is null or
         approverIn.orig_system_id is null or
         approverIn.display_name is null or
         approverIn.approver_category is null or
         approverIn.api_insertion is null or
         approverIn.authority is null or
         approverIn.action_type_id is null or
         approverIn.group_or_chain_id is null or
         approverIn.occurrence is null or
         approverIn.source is null or
         approverIn.item_class is null or
         approverIn.item_id is null or
         approverIn.item_class_order_number is null or
         approverIn.item_order_number is null or
         approverIn.sub_list_order_number is null or
         approverIn.action_type_order_number is null or
         approverIn.group_or_chain_order_number is null or
         approverIn.member_order_number is null) then
        raise nullFieldException;
      end if;
      ame_util.copyApproverRecord2(approverRecord2In => approverIn,
                                   approverRecord2Out => engStApprovers(engStApprovers.count + 1));
      /* Add the approver to the tree whenever he is added to the approver list */
      /* Approvers location in list is engStApprovers.count                     */
      /* Add the approver as the last approver among the approvers with same    */
      /* order number                                                           */
      if engPrepareApproverTree then
        addApproverToTree
            (approverRecordIn    => engStApprovers(engStApprovers.count)
            ,approverIndexIn     => engStApprovers.count
            ,approverLocationIn  => ame_util.lastAmongEquals);
      end if;
      exception
        when listTooLongException then
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                              messageNameIn => 'AME_400118_ENG_LOOP_CHA_AUTH');
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'addApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when nullFieldException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400683_APPR_REC_INV');
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'addApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'addApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end addApprover;
  procedure addApproversTodevList(approverRecordIndexIn in integer) is
   tempCount integer;
  begin
    if engTempReason is not null or engTempDate is not null then
      engDeviationResultList(approverRecordIndexIn).reason := engTempReason;
      engDeviationResultList(approverRecordIndexIn).effectiveDate := engTempDate;
    end if;
    engTempReason := null;
    engTempDate := null;
  exception
    when others then
      ame_util.runtimeException(packageNameIn => 'ame_engine',
                                routineNameIn => 'addApproversTodevList',
                                exceptionNumberIn => sqlcode,
                                exceptionStringIn => sqlerrm);
  end addApproversTodevList;
  /* This procedure is used to add an approver to the approver tree */
  procedure addApproverToTree
    (approverRecordIn   in            ame_util.approverRecord2
    ,approverIndexIn    in            integer
    ,approverLocationIn in            boolean default ame_util.lastAmongEquals) is
    orderNumbers                 ame_util.idList;
    treeLevelIds                 ame_util.stringList;
    approverIndexs               ame_util.idList;
    previousTreeNodeIndex        integer;
    currentTreeNodeIndex         integer;
    newTreeNodeIndex             integer;
    newTreeNode                  ame_util.approverTreeRecord;
    currentSiblingTreeNodeIndex  integer;
    lowerOrderLastSiblingIndex   integer;
    higherOrderFirstSiblingIndex integer;
    sameOrderFirstSiblingIndex   integer;
    sameOrderLastSiblingIndex    integer;
    currentTreeNodeFound         boolean;
  begin
    /* Initialise the tree with the transaction level node if the tree */
    /* is not yet built.The tree level node will have min_order of 1   */
    /* which is the minimum allowed approver order number              */
    if engStApproversTree.count = 0 then
      newTreeNode.parent_index := ame_util.noParentIndex;
      newTreeNode.child_index := ame_util.noChildIndex;
      newTreeNode.sibling_index := ame_util.noSiblingIndex;
      newTreeNode.approver_index := ame_util.noApproverIndex;
      newTreeNode.tree_level_id := -1;
      newTreeNode.order_number := -1;
      newTreeNode.min_order := ame_util.minimumApproverOrderNumber;
      newTreeNode.is_suspended := ame_util.booleanFalse;
--      newTreeNode.repeated_index := -1;
      newTreeNode.tree_level := 0;
      engStApproversTree(1)  := newTreeNode;
    end if;
    /* For each tree level assign the node order number, unique tree level */
    /* ids and the approver indices                                        */
    orderNumbers(1) := approverRecordIn.item_class_order_number;
    orderNumbers(2) := approverRecordIn.item_order_number;
    orderNumbers(3) := approverRecordIn.sub_list_order_number;
    orderNumbers(4) := approverRecordIn.action_type_order_number;
    orderNumbers(5) := approverRecordIn.group_or_chain_order_number;
    orderNumbers(6) := approverRecordIn.member_order_number;
    treeLevelIds(1) := approverRecordIn.item_class;
    treeLevelIds(2) := approverRecordIn.item_id;
    treeLevelIds(3) := approverRecordIn.authority;
    treeLevelIds(4) := to_char(approverRecordIn.action_type_id);
    treeLevelIds(5) := to_char(approverRecordIn.group_or_chain_id);
    treeLevelIds(6) := approverRecordIn.name;
    approverIndexs(1) := ame_util.noApproverIndex;
    approverIndexs(2) := ame_util.noApproverIndex;
    approverIndexs(3) := ame_util.noApproverIndex;
    approverIndexs(4) := ame_util.noApproverIndex;
    approverIndexs(5) := ame_util.noApproverIndex;
    approverIndexs(6) := approverIndexIn;
    /* Starting with the transaction node traverse the tree through the    */
    /* item class,item,sublist,action type,group or chain and finally      */
    /* insert the approver into the tree.In the way if any of other nodes  */
    /* are missing create them.                                            */
    previousTreeNodeIndex := 1;
    for i in 1 .. 6 loop
      if engStApproversTree(previousTreeNodeIndex).child_index
                                                   = ame_util.noChildIndex then
        newTreeNode.parent_index := previousTreeNodeIndex;
        newTreeNode.sibling_index := ame_util.noSiblingIndex;
        newTreeNode.child_index := ame_util.noChildIndex;
        newTreeNode.approver_index := approverIndexs(i);
        newTreeNode.tree_level_id := treeLevelIds(i);
        newTreeNode.order_number := orderNumbers(i);
        newTreeNode.is_suspended := ame_util.booleanFalse;
        newTreeNode.tree_level := i;
        newTreeNodeIndex := engStApproversTree.last + 1;
        engStApproversTree(newTreeNodeIndex) := newTreeNode;
        engStApproversTree(previousTreeNodeIndex).child_index := newTreeNodeIndex;
        currentTreeNodeIndex := newTreeNodeIndex;
      else
        currentSiblingTreeNodeIndex :=
                             engStApproversTree(previousTreeNodeIndex).child_index;
        lowerOrderLastSiblingIndex := -1;
        higherOrderFirstSiblingIndex := -1;
        sameOrderFirstSiblingIndex := -1;
        sameOrderLastSiblingIndex := -1;
        currentTreeNodeFound := false;
        loop
          if engStApproversTree(currentSiblingTreeNodeIndex).order_number
                                                              < orderNumbers(i) then
            lowerOrderLastSiblingIndex := currentSiblingTreeNodeIndex;
          elsif engStApproversTree(currentSiblingTreeNodeIndex).order_number
                                                              = orderNumbers(i) then
            if engStApproversTree(currentSiblingTreeNodeIndex).tree_level_id
                                                              = treeLevelIds(i)
               and (i <> 6) then --added for bug 4232137
              currentTreeNodeIndex := currentSiblingTreeNodeIndex;
              currentTreeNodeFound := true;
              exit;
            end if;
            if sameOrderFirstSiblingIndex = -1 then
              sameOrderFirstSiblingIndex := currentSiblingTreeNodeIndex;
            end if;
            sameOrderLastSiblingIndex := currentSiblingTreeNodeIndex;
          elsif engStApproversTree(currentSiblingTreeNodeIndex).order_number
                                                              > orderNumbers(i) then
            if higherOrderFirstSiblingIndex = -1 then
              higherOrderFirstSiblingIndex := currentSiblingTreeNodeIndex;
            end if;
          end if;
          currentSiblingTreeNodeIndex
                   := engStApproversTree(currentSiblingTreeNodeIndex).sibling_index;
          exit when currentSiblingTreeNodeIndex = ame_util.noSiblingIndex;
        end loop;
        if not currentTreeNodeFound then
          if approverLocationIn then
            /* approverLocationIn is ame_util.firstAmongEquals */
            newTreeNode.parent_index := previousTreeNodeIndex;
            if sameOrderFirstSiblingIndex = -1 then
              newTreeNode.sibling_index := higherOrderFirstSiblingIndex;
            else
              newTreeNode.sibling_index := sameOrderFirstSiblingIndex;
            end if;
            newTreeNode.child_index := ame_util.noChildIndex;
            newTreeNode.approver_index := approverIndexs(i);
            newTreeNode.tree_level_id := treeLevelIds(i);
            newTreeNode.order_number := orderNumbers(i);
            newTreeNode.is_suspended := ame_util.booleanFalse;
            newTreeNode.tree_level := i;
            newTreeNodeIndex := engStApproversTree.last + 1;
            engStApproversTree(newTreeNodeIndex) := newTreeNode;
            if lowerOrderLastSiblingIndex = -1 then
              engStApproversTree(previousTreeNodeIndex).child_index := newTreeNodeIndex;
            else
              engStApproversTree(lowerOrderLastSiblingIndex).sibling_index := newTreeNodeIndex;
            end if;
            currentTreeNodeIndex := newTreeNodeIndex;
          else
            /* approverLocationIn is ame_util.lastAmongEquals */
            newTreeNode.parent_index := previousTreeNodeIndex;
            newTreeNode.sibling_index := higherOrderFirstSiblingIndex;
            newTreeNode.child_index := ame_util.noChildIndex;
            newTreeNode.approver_index := approverIndexs(i);
            newTreeNode.tree_level_id := treeLevelIds(i);
            newTreeNode.order_number := orderNumbers(i);
            newTreeNode.is_suspended := ame_util.booleanFalse;
            newTreeNode.tree_level := i;
            newTreeNodeIndex := engStApproversTree.last + 1;
            engStApproversTree(newTreeNodeIndex) := newTreeNode;
            if sameOrderLastSiblingIndex = -1 and lowerOrderLastSiblingIndex = -1 then
              engStApproversTree(previousTreeNodeIndex).child_index := newTreeNodeIndex;
            elsif sameOrderLastSiblingIndex = -1 then
              engStApproversTree(lowerOrderLastSiblingIndex).sibling_index := newTreeNodeIndex;
            else
              engStApproversTree(sameOrderLastSiblingIndex).sibling_index := newTreeNodeIndex;
            end if;
            currentTreeNodeIndex := newTreeNodeIndex;
          end if;
        end if;
      end if;
      previousTreeNodeIndex := currentTreeNodeIndex;
    end loop;
    addApproversTodevList(approverRecordIndexIn => approverIndexIn);
  exception
    when others then
      ame_util.runtimeException(packageNameIn => 'ame_engine',
                                routineNameIn => 'addApproverToTree',
                                exceptionNumberIn => sqlcode,
                                exceptionStringIn => sqlerrm);
      raise;
  end addApproverToTree;
  procedure calculateApproverOrderNumbers as
    maximumApproverOrderNumber integer;
    transactionApprovalStatus integer;
    transactionhasSuspendedItems boolean;
    stoppingRule ame_util.stringType;
    headerItemRejected boolean;
    loopIndex integer;
    begin
      /* The call to finalizeTree does the following            */
      /* 1.Calculate the approver order number                  */
      /* 2.Populates the list of rejected items and itemclasses */
      /* 3.Returns whether the transaction has rejected Items   */
      /* 4.Returns the maximum order number of approvers        */
      /* 5.Returns the approval status of the transaction       */
      finalizeTree
        (parentIndexIn         => 1
        ,maximumOrderOut       => maximumApproverOrderNumber
        ,approvalStatusOut     => transactionApprovalStatus
        ,rejectedItemsExistOut => transactionhasSuspendedItems);
      engStApproversTree(1).status := transactionApprovalStatus;
      engStApproversTree(1).max_order := maximumApproverOrderNumber;
      stoppingRule := ame_engine.getHeaderAttValue2
                                 (attributeNameIn => ame_util.rejectionResponseAttribute);
      if transactionhasSuspendedItems then
        /* Check if any of the suspended item is a header item */
        /* If a header item is suspended then it is as good as */
        /* the entire transaction being suspended              */
        headerItemRejected := false;
        for i in 1 .. engStSuspendedItemClasses.count loop
          if engStSuspendedItemClasses(i) = ame_util.headerItemClassName then
            headerItemRejected := true;
            exit;
          end if;
        end loop;
        if stoppingRule = ame_util.stopAllItems or headerItemRejected then
          /* Suspend the transaction node */
          engStApproversTree(1).is_suspended := ame_util.booleanTrue;
        elsif stoppingRule = ame_util.continueAllOtherItems then
          /* Suspend all items in the suspended items list */
          for i in 1 .. engStSuspendedItems.count loop
            /* Approvers Tree can be sparse */
            loopIndex := engStApproversTree.first;
            loop
              if(engStApproversTree(loopIndex).tree_level = 2 and
                 engStApproversTree(loopIndex).tree_level_id = engStSuspendedItems(i) and
                 engStApproversTree(engStApproversTree(loopIndex).parent_index).tree_level_id
                                                         = engStSuspendedItemClasses(i)) then
                engStApproversTree(loopIndex).is_suspended := ame_util.booleanTrue;
                exit;
              end if;
              exit when loopIndex = engStApproversTree.last;
              loopIndex := engStApproversTree.next(loopIndex);
            end loop;
          end loop;
        elsif stoppingRule = ame_util.continueOtherSubItems then
          /* Suspend all items in the suspended items list and header item */
          for i in 1 .. engStSuspendedItems.count loop
            /* Approvers Tree can be sparse */
            loopIndex := engStApproversTree.first;
            loop
              if(engStApproversTree(loopIndex).tree_level = 2 and
                 ((engStApproversTree(loopIndex).tree_level_id = engStSuspendedItems(i) and
                  engStApproversTree(engStApproversTree(loopIndex).parent_index).tree_level_id
                                                        = engStSuspendedItemClasses(i))
                                                        or
                  (engStApproversTree(engStApproversTree(loopIndex).parent_index).tree_level_id
                                                        = ame_util.headerItemClassName))) then
                engStApproversTree(loopIndex).is_suspended := ame_util.booleanTrue;
              end if;
              exit when loopIndex = engStApproversTree.last;
              loopIndex := engStApproversTree.next(loopIndex);
            end loop;
          end loop;
        end if;
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'calculateApproverOrderNumbers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end calculateApproverOrderNumbers;
  --+
  --+ check Approver
  --+
  procedure checkApprover(approverIn in ame_util.approverRecord2) is
    errorCode integer;
    errorMessage ame_util.longestStringType;
    tempApproverTypeCount integer;
    tempApproverType ame_approver_types.orig_system%type;
    invalidApproverException1 exception;
    invalidApproverException2 exception;
    begin
      tempApproverType := approverIn.orig_system;
      if tempApproverType like 'FND_RESP%' then
        return;
      end if;
      if getConfigVarValue(ame_util.allowAllApproverTypesConfigVar) = ame_util.yes then
        select count(*)
          into tempApproverTypeCount
          from ame_approver_types
         where orig_system = approverIn.orig_system
           and sysdate between start_date and end_date;
        if tempApproverTypeCount = 0 then
          raise invalidApproverException1;
        end if;
      else
        if(tempApproverType in (ame_util.perOrigSystem
                               ,ame_util.fndUserOrigSystem )) then
          null;
        else
          raise invalidApproverException2;
        end if;
      end if;
    exception
      when invalidApproverException1 then
        errorCode := -20001;
        errorMessage := 'The Approver '
                        ||approverIn.display_name
                        ||' belongs to approver type '
                        ||approverIn.orig_system
                        ||' which is not registered in AME.';
        ame_util.runtimeException(packageNameIn => 'ame_engine',
                                  routineNameIn => 'checkApprover',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                  errorMessage);
      when invalidApproverException2 then
        errorCode := -20001;
        errorMessage := 'The Approver '
                        ||approverIn.display_name
                        ||' belongs to approver type '
                        ||approverIn.orig_system
                        ||'. And the allowAllApproverTypes configuration variable set to No.';
        ame_util.runtimeException(packageNameIn => 'ame_engine',
                                  routineNameIn => 'checkApprover',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                  errorMessage);
    end checkApprover;
  --+
  procedure clearHandlerState(handlerNameIn in varchar2,
                              parameterIn in varchar2 default null) as
    handlerName ame_temp_handler_states.handler_name%type;
    begin
      handlerName := upper(handlerNameIn);
      delete
        from ame_temp_handler_states
        where
          handler_name = handlerName and
          application_id = engAmeApplicationId and
          ((parameter is null and parameterIn is null) or
           (parameter = parameterIn));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'clearHandlerState',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end clearHandlerState;
  procedure compactEngAppLists(compactPrioritiesIn in boolean,
                               compactActionTypeIdsIn in boolean,
                               compactParametersIn in boolean) as
    tempCount integer;
    tempFirstIndex integer;
    tempLastIndex integer;
    begin
      tempCount := engAppRuleIds.count;
      if(tempCount = 0) then
        return;
      end if;
      tempFirstIndex := engAppRuleIds.first;
      for i in 1 .. tempCount loop
        if(i <> tempFirstIndex) then /* (Don't copy a row onto itself.) */
          engAppItemClassIds(i) := engAppItemClassIds(tempFirstIndex);
          engAppItemIds(i) := engAppItemIds(tempFirstIndex);
          engAppApproverCategories(i) := engAppApproverCategories(tempFirstIndex);
          engAppRuleIds(i) := engAppRuleIds(tempFirstIndex);
          engRuleAppliedYN(i) := engRuleAppliedYN(tempFirstIndex);
          engAppRuleTypes(i) := engAppRuleTypes(tempFirstIndex);
          engAppRuleItemClassIds(i) := engAppRuleItemClassIds(tempFirstIndex);
          engAppAppItemIds(i) := engAppAppItemIds(tempFirstIndex);
          if(compactPrioritiesIn) then
            engAppPriorities(i) := engAppPriorities(tempFirstIndex);
          end if;
          if(compactActionTypeIdsIn) then
            engAppActionTypeIds(i) := engAppActionTypeIds(tempFirstIndex);
          end if;
          if(compactParametersIn) then
            engAppParameters(i) := engAppParameters(tempFirstIndex);
            engAppParameterTwos(i) := engAppParameterTwos(tempFirstIndex);
          end if;
        end if;
        tempFirstIndex := engAppRuleIds.next(tempFirstIndex);
      end loop;
      /*
        engAppRuleIds.next will set tempFirstIndex null just before the for loop
        exits, so we have to set it anew here.
      */
      tempFirstIndex := tempCount + 1;
      tempLastIndex := engAppRuleIds.last;
      engAppItemClassIds.delete(tempFirstIndex, tempLastIndex);
      engAppItemIds.delete(tempFirstIndex, tempLastIndex);
      engAppApproverCategories.delete(tempFirstIndex, tempLastIndex);
      engAppRuleIds.delete(tempFirstIndex, tempLastIndex);
      engRuleAppliedYN.delete(tempFirstIndex, tempLastIndex);
      engAppRuleTypes.delete(tempFirstIndex, tempLastIndex);
      engAppRuleItemClassIds.delete(tempFirstIndex, tempLastIndex);
      engAppAppItemIds.delete(tempFirstIndex, tempLastIndex);
      if(compactPrioritiesIn) then
        engAppPriorities.delete(tempFirstIndex, tempLastIndex);
      end if;
      if(compactActionTypeIdsIn) then
        engAppActionTypeIds.delete(tempFirstIndex, tempLastIndex);
      end if;
      if(compactParametersIn) then
        engAppParameters.delete(tempFirstIndex, tempLastIndex);
        engAppParameterTwos.delete(tempFirstIndex, tempLastIndex);
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'compactEngAppLists',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end compactEngAppLists;
  procedure doPerItemRuleEvaluation(itemClassIdIn in integer,
                                    itemIndexIn in varchar2) as
    currentACUsageConditionIds ame_util.idList;
    currentACUsageRuleIds ame_util.idList;
    currentConditionRuleCounts ame_util.idList;
    tempConditionId integer;
    tempConditionId2 integer;
    tempHighestRuleCount integer;
    tempIndex integer;
    tempIndex2 integer;
    tempIndex3 integer;
    tempPendingRuleIds ame_util.idList;
    tempRuleApplies boolean;
    tempRuleId integer;
    begin
      /* Handle the null case (no active conditions) first. */
      if(not engACUsageFirstIndexes.exists(itemClassIdIn)) then
        return;
      end if;
      /*
        Initialize the current condition usages.  Note that while the currentACUsage local
        variables start out as compact lists, the algorithm that iterates through them
        deletes them in an unpredictable order, and does not re-compact the lists; so the
        algorithm must treat these lists as sparse.
      */
      tempIndex := 0; /* pre-increment */
      if(engACUsageFirstIndexes.exists(itemClassIdIn)) then
        for ACUIndex in
          engACUsageFirstIndexes(itemClassIdIn) ..
          (engACUsageFirstIndexes(itemClassIdIn) + engACUsageItemClassCounts(itemClassIdIn) - 1) loop
          tempIndex := tempIndex + 1;
          currentACUsageConditionIds(tempIndex) := engACUsageConditionIds(ACUIndex);
          currentACUsageRuleIds(tempIndex) := engACUsageRuleIds(ACUIndex);
        end loop;
      else
        return;
      end if;
      /*
        Initialize the rule counts.  currentConditionRuleCounts is indexed by condition ID for
        efficiency (the alternative requires a lot more looping).
      */
      tempHighestRuleCount := 0;
      tempIndex := currentACUsageConditionIds.first;
      while(tempIndex is not null) loop
        tempConditionId := currentACUsageConditionIds(tempIndex);
        if(currentConditionRuleCounts.exists(tempConditionId)) then
          currentConditionRuleCounts(tempConditionId) := currentConditionRuleCounts(tempConditionId) + 1;
        else
          currentConditionRuleCounts(tempConditionId) := 1;
        end if;
        tempIndex := currentACUsageConditionIds.next(tempIndex);
      end loop;
      /* Loop through the condition usages. */
      while(currentACUsageConditionIds.count > 0) loop
        /* Set tempHighestRuleCount. */
        tempHighestRuleCount := 0;
        tempIndex := currentConditionRuleCounts.first;
        while(tempIndex is not null) loop
          if(tempHighestRuleCount < currentConditionRuleCounts(tempIndex)) then
            tempHighestRuleCount := currentConditionRuleCounts(tempIndex);
            tempConditionId := tempIndex;
          end if;
          tempIndex := currentConditionRuleCounts.next(tempIndex);
        end loop;
        /* Clear the pending-rule list. */
        tempPendingRuleIds.delete;
        /*
          Choose the first condition with a maximal rule count.  Recall that
          currentConditionRuleCounts is indexed by condition ID.
        */
    /* Following while loop commented asper Issue 14 Please refer the        */
    /* comments in doWeakHeaderEvaluation                                    */
    /*  tempConditionId := currentConditionRuleCounts.first;
        while(tempConditionId is not null) loop
          if(currentConditionRuleCounts(tempConditionId) = tempHighestRuleCount) then
            exit;
          end if;
          tempConditionId := currentConditionRuleCounts.next(tempConditionId);
        end loop;  */
        /* From now on, tempConditionId is the ID of the chosen condition with maximal rule count. */
        /* Delete this condition from currentConditionRuleCounts. */
        currentConditionRuleCounts.delete(tempConditionId);
        /*
          Evaluate the chosen condition.  Note that whether or not the condition is satisfied, the
          code first loops through the currentAC variables, locating each currentAC instance matching
          the chosen condition.  The code avoids compressing the two cases' loops into a single loop
          to avoid repeatedly branching on a boolean variable inside the loops, for efficiency.
        */
        if(conditionIsSatisfied(conditionIdIn => tempConditionId,
                                itemClassIdIn => itemClassIdIn,
                                itemIndexIn => itemIndexIn)) then
          /*
            Remove all usages of this condition from the current condition-usage list, adding their
            rules to the pending-rule list.  tempIndex indexes the next currentAC variables.
            tempIndex2 indexes the current currentAC variables, which may be deleted.  tempIndex3
            indexes tempPendingRuleIds.
          */
          tempIndex := currentACUsageConditionIds.first;
          tempIndex3 := 0; /* pre-increment */
          while(tempIndex is not null) loop
            tempIndex2 := tempIndex;
            tempIndex := currentACUsageConditionIds.next(tempIndex);
            if(currentACUsageConditionIds(tempIndex2) = tempConditionId) then
              tempIndex3 := tempIndex3 + 1;
              tempPendingRuleIds(tempIndex3) := currentACUsageRuleIds(tempIndex2);
              currentACUsageConditionIds.delete(tempIndex2);
              currentACUsageRuleIds.delete(tempIndex2);
            end if;
          end loop;
          /* If a pending rule has no other usages, add it to the applicable-rules list. */
          for pendingRuleIndex in 1 .. tempPendingRuleIds.count loop
            tempRuleApplies := true;
            tempIndex := currentACUsageConditionIds.first;
            while(tempIndex is not null) loop
              if(currentACUsageRuleIds(tempIndex) = tempPendingRuleIds(pendingRuleIndex)) then
                tempRuleApplies := false;
                exit;
              end if;
              tempIndex := currentACUsageConditionIds.next(tempIndex);
            end loop;
            if(tempRuleApplies) then
              tempIndex2 := engAppRuleIds.count + 1;
              tempRuleId := tempPendingRuleIds(pendingRuleIndex);
              engAppRuleIds(tempIndex2) := tempRuleId;
              engAppRuleTypes(tempIndex2) := engACUsageRuleTypes(tempRuleId);
              engRuleAppliedYN(tempIndex2) := ame_util.booleanTrue;
              engAppPriorities(tempIndex2) := engACUsageRulePriorities(tempRuleId);
              engAppApproverCategories(tempIndex2) := engACUsageRuleApprCategories(tempRuleId);
              engAppItemClassIds(tempIndex2) := itemClassIdIn;
              engAppItemIds(tempIndex2) := engItemIds(itemIndexIn);
              /*
                doPerItemRuleEvaluation only evaluates subordinate-item-class rules, so here
                  engAppRuleItemClassIds(i) = engAppItemClassIds(i) and
                  engAppAppItemIds(i) = engAppItemIds(i)
                always.
              */
              engAppRuleItemClassIds(tempIndex2) := itemClassIdIn;
              engAppAppItemIds(tempIndex2) := engItemIds(itemIndexIn);
            end if;
          end loop;
        else /* The condition is not satisfied. */
          /* Find all rules using the chosen condition. */
          tempIndex := currentACUsageConditionIds.first;
          tempIndex2 := 0; /* tempIndex2 indexes tempPendingRuleIds; pre-increment it. */
          while(tempIndex is not null) loop
            if(currentACUsageConditionIds(tempIndex) = tempConditionId) then
              tempIndex2 := tempIndex2 + 1;
              tempPendingRuleIds(tempIndex2) := currentACUsageRuleIds(tempIndex);
            end if;
            tempIndex := currentACUsageConditionIds.next(tempIndex);
          end loop;
          /*
            Remove all usages for rules using the chosen condition.  If the usage is for
            a condition other than the chosen condition, decrement that condition's
            rule count.  Here tempIndex indexes the next currentAC variable; tempIndex2
            indexes the current currentAC variable, which may be deleted; and tempIndex3
            indexes the engApp variables.
          */
          for pendingRuleIndex in 1 .. tempPendingRuleIds.count loop
            tempIndex := currentACUsageConditionIds.first;
            while(tempIndex is not null) loop
              tempIndex2 := tempIndex;
              tempIndex := currentACUsageConditionIds.next(tempIndex);
              if(currentACUsageRuleIds(tempIndex2) = tempPendingRuleIds(pendingRuleIndex)) then
                tempConditionId2 := currentACUsageConditionIds(tempIndex2);
                if(tempConditionId2 <> tempConditionId) then
                  currentConditionRuleCounts(tempConditionId2) := currentConditionRuleCounts(tempConditionId2) - 1;
                end if;
                currentACUsageConditionIds.delete(tempIndex2);
                currentACUsageRuleIds.delete(tempIndex2);
              end if;
            end loop;
          end loop;
        end if;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'doPerItemRuleEvaluation',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end doPerItemRuleEvaluation;
  procedure doStrictHeaderRuleEvaluation(itemClassIndexIn in integer,
                                         itemClassIdIn in integer) as
    currentACUsageConditionIds ame_util.idList;
    currentACUsageRuleIds ame_util.idList;
    headerItemIndex integer;
    tempFirstRuleIndex integer;
    tempLastRuleIndex integer;
    tempIndex integer;
    tempIndex2 integer;
    tempItemClassId integer;
    tempItemClassIndex integer;
    tempItemId ame_util.stringType;
    tempLowerLimit integer;
    tempRuleApplies boolean;
    tempRuleId integer;
    tempRuleId2 integer;
    tempUpperLimit integer;
    begin
      /* Handle the null case (no active conditions) first. */
      if(not engACUsageFirstIndexes.exists(itemClassIdIn)) then
        return;
      end if;
      /*
        A header-level rule can have conditions on attributes of at most one subordinate
        item class.  The active condition usages are sorted first by item class, then
        by rule ID; so within this procedure, the header item class' active condition
        usages are sorted by rule ID.  This procedure therefore loops through the rules
        in the active condition usages one rule at a time.  For each rule, if any of the
        conditions is defined on an attribute of a subordinate item class, the procedure
        loops through the items of that class, looking for an item that satisfies all of
        the rule's subordinate-item-level conditions.
      */
      /* Initialize the current condition usages. */
      tempIndex := 0; /* pre-increment */
      for ACUIndex in
        engACUsageFirstIndexes(itemClassIdIn) ..
        (engACUsageFirstIndexes(itemClassIdIn) + engACUsageItemClassCounts(itemClassIdIn) - 1) loop
        tempIndex := tempIndex + 1;
        currentACUsageConditionIds(tempIndex) := engACUsageConditionIds(ACUIndex);
        currentACUsageRuleIds(tempIndex) := engACUsageRuleIds(ACUIndex);
      end loop;
      if(currentACUsageRuleIds.count = 0) then
        /* There are no condition usages to process, so just return. */
        return;
      end if;
      headerItemIndex := engItemClassItemIdIndexes(itemClassIndexIn);
      tempFirstRuleIndex := 1;
      /* The following value of tempIndex is used throughout the remainder of the code; don't change it. */
      tempIndex := currentACUsageRuleIds.count;
      while(tempFirstRuleIndex is not null) loop
        tempRuleId := currentACUsageRuleIds(tempFirstRuleIndex);
        /* Find the last current condition usage with the rule ID tempRuleId. */
        tempLastRuleIndex := tempFirstRuleIndex;
        while(tempLastRuleIndex < tempIndex and
              currentACUsageRuleIds(tempLastRuleIndex + 1) = tempRuleId) loop
          tempLastRuleIndex := tempLastRuleIndex + 1;
        end loop;
        /*
          Determine whether the current rule references any conditions on attributes belonging
          to a subordinate item class.  If so, all such conditions are on the same item class,
          and tempItemClassId is its index.  Otherwise, tempItemClassId identifies the header
          item class, and tempItemId identifies the header item.
        */
        tempItemClassId := itemClassIdIn;
        tempItemId := engTransactionId;
        for ruleIndex in tempFirstRuleIndex .. tempLastRuleIndex loop
          tempItemClassId := engAttributeItemClassIds(engACAttributeIds(currentACUsageConditionIds(ruleIndex)));
          if(tempItemClassId <> itemClassIdIn) then
            exit;
          end if;
        end loop;
        tempRuleApplies := true;
        /* First loop through the header-level conditions. */
        for ruleIndex in tempFirstRuleIndex .. tempLastRuleIndex loop
          if(engAttributeItemClassIds(engACAttributeIds(currentACUsageConditionIds(ruleIndex))) = itemClassIdIn and
             not conditionIsSatisfied(conditionIdIn => currentACUsageConditionIds(ruleIndex),
                                      itemClassIdIn => itemClassIdIn,
                                      itemIndexIn   => headerItemIndex)) then
            tempRuleApplies := false;
            exit;
          end if;
        end loop;
        /*
          If the rule still applies and at least one condition is defined on a subordinate-item-level
          attribute, loop through the subordinate items, looking for an item that satisfies all of the
          rule's subordinate-item-level conditions.
        */
        if(tempRuleApplies and
           tempItemClassId <> itemClassIdIn) then
          tempItemClassIndex := engItemClassIndexes(tempItemClassId);
          tempLowerLimit := engItemClassItemIdIndexes(tempItemClassIndex);
          tempRuleApplies := false;
          /*
            If tempLowerLimit is null, no items exist in this item class, so the rule's conditions
            on attributes defined on the item class cannot be satisfied.  In this case, tempRuleApplies
            stays false.
          */
          if(tempLowerLimit is not null) then
            tempUpperLimit := (engItemClassItemIdIndexes(tempItemClassIndex) + engItemCounts(tempItemClassIndex) - 1);
            for itemIndex in tempLowerLimit .. tempUpperLimit loop
              for ruleIndex in tempFirstRuleIndex .. tempLastRuleIndex loop
                if(engAttributeItemClassIds(engACAttributeIds(currentACUsageConditionIds(ruleIndex))) =
                     tempItemClassId) then
                  if(conditionIsSatisfied(conditionIdIn => currentACUsageConditionIds(ruleIndex),
                                          itemClassIdIn => tempItemClassId,
                                          itemIndexIn => itemIndex)) then
                    /* The rule is only satisfied if all the conditions have succeeded. */
                    if(ruleIndex = tempLastRuleIndex) then
                      tempRuleApplies := true;
                      tempItemId := engItemIds(itemIndex);
                      exit;
                    end if;
                  else
                    /*
                      The condition is not satisfied, so the current item does not satisfy the rule.
                      Leave tempRuleApplies false and exit the inner loop.
                    */
                    exit;
                  end if;
                end if;
              end loop;
              if(tempRuleApplies) then
                exit;
              end if;
            end loop;
          end if;
        end if;
        /* If the rule applies, write it to the applicable-rule package variables. */
        if(tempRuleApplies) then
          tempIndex2 := engAppRuleIds.count + 1;
          tempRuleId2 := currentACUsageRuleIds(tempFirstRuleIndex);
          engAppRuleIds(tempIndex2) := tempRuleId2;
          engAppRuleTypes(tempIndex2) := engACUsageRuleTypes(tempRuleId2);
          engRuleAppliedYN(tempIndex2) := ame_util.booleanTrue;
          engAppPriorities(tempIndex2) := engACUsageRulePriorities(tempRuleId2);
          engAppApproverCategories(tempIndex2) := engACUsageRuleApprCategories(tempRuleId2);
          /* These two variables indicate which item satisfied the rule. */
          engAppItemClassIds(tempIndex2) := tempItemClassId;
          engAppItemIds(tempIndex2) := tempItemId;
          /* These two variables indicate which item the rule applies to, i.e. the header item. */
          engAppRuleItemClassIds(tempIndex2) := itemClassIdIn;
          engAppAppItemIds(tempIndex2) := engTransactionId;
        end if;
        /* Iterate or exit the main loop. */
        if(tempLastRuleIndex < tempIndex) then
          tempFirstRuleIndex := tempLastRuleIndex + 1;
        else
          exit;
        end if;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'doStrictHeaderRuleEvaluation',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end doStrictHeaderRuleEvaluation;
  procedure doWeakHeaderRuleEvaluation(itemClassIndexIn in integer,
                                       itemClassIdIn in integer) as
    currentACUsageConditionIds ame_util.idList;
    currentACUsageRuleIds ame_util.idList;
    currentConditionRuleCounts ame_util.idList;
    tempAttributeItemClassIndex integer;
    tempConditionId integer;
    tempConditionId2 integer;
    tempConditionIsSatisfied boolean;
    tempHighestRuleCount integer;
    tempIndex integer;
    tempIndex2 integer;
    tempIndex3 integer;
    tempLowerLimit integer;
    tempPendingRuleIds ame_util.idList;
    tempRuleApplies boolean;
    tempRuleId integer;
    tempUpperLimit integer;
    begin
      /* Handle the null case (no active conditions) first. */
      if(not engACUsageFirstIndexes.exists(itemClassIdIn)) then
        return;
      end if;
      /*
        Initialize the current condition usages.  Note that while the currentACUsage local
        variables start out as compact lists, the algorithm that iterates through them
        deletes them in an unpredictable order, and does not re-compact the lists; so the
        algorithm must treat these lists as sparse.
      */
      tempIndex := 0; /* pre-increment */
      for ACUIndex in
        engACUsageFirstIndexes(itemClassIdIn) ..
        (engACUsageFirstIndexes(itemClassIdIn) + engACUsageItemClassCounts(itemClassIdIn) - 1) loop
        tempIndex := tempIndex + 1;
        currentACUsageConditionIds(tempIndex) := engACUsageConditionIds(ACUIndex);
        currentACUsageRuleIds(tempIndex) := engACUsageRuleIds(ACUIndex);
      end loop;
      /*
        Initialize the rule counts.  currentConditionRuleCounts is indexed by condition ID for
        efficiency (the alternative requires a lot more looping).
      */
      tempIndex := currentACUsageConditionIds.first;
      while(tempIndex is not null) loop
        tempConditionId := currentACUsageConditionIds(tempIndex);
        if(currentConditionRuleCounts.exists(tempConditionId)) then
          currentConditionRuleCounts(tempConditionId) := currentConditionRuleCounts(tempConditionId) + 1;
        else
          currentConditionRuleCounts(tempConditionId) := 1;
        end if;
        tempIndex := currentACUsageConditionIds.next(tempIndex);
      end loop;
      /* Loop through the condition usages. */
      while(currentACUsageConditionIds.count > 0) loop
        /* Set tempHighestRuleCount. */
        tempHighestRuleCount := 0;
        tempIndex := currentConditionRuleCounts.first;
        while(tempIndex is not null) loop
          if(tempHighestRuleCount < currentConditionRuleCounts(tempIndex)) then
            tempHighestRuleCount := currentConditionRuleCounts(tempIndex);
    /* Following line has been added to avoid the another while loop to      */
    /* find the condition with highest rule count. Issue 14 of the bug list  */
    /* No bug logged for this                                                */
    /* currentConditionRuleCounts is pl/sql list which is sparse and indexes */
    /* are nothig but condition_ids.Hence there is no need to find the       */
    /* condition_id which has highestRuleCount in another loop.after this    */
    /* while loop the tempConditionId is the condition with highestRuleCount.*/
            tempConditionId := tempIndex;
          end if;
          tempIndex := currentConditionRuleCounts.next(tempIndex);
        end loop;
        /* Clear the pending-rule list. */
        tempPendingRuleIds.delete;
        /*
          Choose the first condition with a maximal rule count.  Recall that currentConditionRuleCounts
          is indexed by condition ID.
        */
    /* Removing this while loop as we already know the condition with        */
    /* highest rule count                                                    */
    /*  tempConditionId := currentConditionRuleCounts.first;
        while(tempConditionId is not null) loop
          if(currentConditionRuleCounts(tempConditionId) = tempHighestRuleCount) then
            exit;
          end if;
          tempConditionId := currentConditionRuleCounts.next(tempConditionId);
        end loop;*/
        /* From now on, tempConditionId is the ID of the chosen condition with maximal rule count. */
        /* Delete this condition from currentConditionRuleCounts. */
        currentConditionRuleCounts.delete(tempConditionId);
        /*
          Test the condition for each item in the item class of the attribute on which the condition
          is defined, until an item satisfies the condition or no items are left.
        */
        tempAttributeItemClassIndex :=
          engItemClassIndexes(engAttributeItemClassIds(engACAttributeIds(tempConditionId)));
        tempConditionIsSatisfied := false;
        tempLowerLimit := engItemClassItemIdIndexes(tempAttributeItemClassIndex);
        if(tempLowerLimit is not null) then
          tempUpperLimit :=
            (engItemClassItemIdIndexes(tempAttributeItemClassIndex) + engItemCounts(tempAttributeItemClassIndex) - 1);
          for itemIndex in tempLowerLimit .. tempUpperLimit loop
            if(conditionIsSatisfied(conditionIdIn => tempConditionId,
                                    itemClassIdIn => engAttributeItemClassIds(engACAttributeIds(tempConditionId)),
                                    itemIndexIn   => itemIndex)) then
              tempConditionIsSatisfied := true;
              exit;
            end if;
          end loop;
        end if;
        /*
          If the condition is satisfied, eliminate its usages, and add any rules with no other
          usages to the applicable-rules list.  If the condition is not satisfied, just eliminate
          its usages, and any other usages for the rules in the condition's usages.
        */
        if(tempConditionIsSatisfied) then
          /*
            Remove all usages of this condition from the current condition-usage list, adding their
            rules to the pending-rule list.  tempIndex indexes the next currentAC variables.
            tempIndex2 indexes the current currentAC variables, which may be deleted.  tempIndex3
            indexes tempPendingRuleIds.
          */
          tempIndex := currentACUsageConditionIds.first;
          tempIndex3 := 0; /* pre-increment */
          while(tempIndex is not null) loop
            tempIndex2 := tempIndex;
            tempIndex := currentACUsageConditionIds.next(tempIndex);
            if(currentACUsageConditionIds(tempIndex2) = tempConditionId) then
              tempIndex3 := tempIndex3 + 1;
              tempPendingRuleIds(tempIndex3) := currentACUsageRuleIds(tempIndex2);
              currentACUsageConditionIds.delete(tempIndex2);
              currentACUsageRuleIds.delete(tempIndex2);
            end if;
          end loop;
          /* If a pending rule has no other usages, add it to the applicable-rules list. */
          for pendingRuleIndex in 1 .. tempPendingRuleIds.count loop
            tempRuleApplies := true;
            tempIndex := currentACUsageConditionIds.first;
            while(tempIndex is not null) loop
              if(currentACUsageRuleIds(tempIndex) = tempPendingRuleIds(pendingRuleIndex)) then
                tempRuleApplies := false;
                exit;
              end if;
              tempIndex := currentACUsageConditionIds.next(tempIndex);
            end loop;
            if(tempRuleApplies) then
              tempIndex2 := engAppRuleIds.count + 1;
              tempRuleId := tempPendingRuleIds(pendingRuleIndex);
              engAppRuleIds(tempIndex2) := tempRuleId;
              engAppRuleTypes(tempIndex2) := engACUsageRuleTypes(tempRuleId);
              engRuleAppliedYN(tempIndex2) := ame_util.booleanTrue;
              engAppPriorities(tempIndex2) := engACUsageRulePriorities(tempRuleId);
              engAppApproverCategories(tempIndex2) := engACUsageRuleApprCategories(tempRuleId);
              engAppItemClassIds(tempIndex2) := itemClassIdIn;
              engAppItemIds(tempIndex2) := engTransactionId;
              /* In this case the satisfying item and item to which the rule applies always match. */
              engAppRuleItemClassIds(tempIndex2) := engAppItemClassIds(tempIndex2);
              engAppAppItemIds(tempIndex2) := engAppItemIds(tempIndex2);
            end if;
          end loop;
        else /* The condition is not satisfied. */
          /* Put all rules using the chosen condition in the pending-rule list. */
          tempIndex := currentACUsageConditionIds.first;
          tempIndex2 := 0; /* tempIndex2 indexes tempPendingRuleIds; pre-increment it. */
          while(tempIndex is not null) loop
            if(currentACUsageConditionIds(tempIndex) = tempConditionId) then
              tempIndex2 := tempIndex2 + 1;
              tempPendingRuleIds(tempIndex2) := currentACUsageRuleIds(tempIndex);
            end if;
            tempIndex := currentACUsageConditionIds.next(tempIndex);
          end loop;
          /*
            Remove all usages for rules using the chosen condition.  If the usage is for
            a condition other than the chosen condition, decrement that condition's
            rule count.  Here tempIndex indexes the next currentAC variable, and tempIndex2
            indexes the current currentAC variable (which may be deleted).
          */
          for pendingRuleIndex in 1 .. tempPendingRuleIds.count loop
            tempIndex := currentACUsageConditionIds.first;
            while(tempIndex is not null) loop
              tempIndex2 := tempIndex;
              tempIndex := currentACUsageConditionIds.next(tempIndex);
              if(currentACUsageRuleIds(tempIndex2) = tempPendingRuleIds(pendingRuleIndex)) then
                tempConditionId2 := currentACUsageConditionIds(tempIndex2);
                if(tempConditionId2 <> tempConditionId) then
                  currentConditionRuleCounts(tempConditionId2) := currentConditionRuleCounts(tempConditionId2) - 1;
                end if;
                currentACUsageConditionIds.delete(tempIndex2);
                currentACUsageRuleIds.delete(tempIndex2);
              end if;
            end loop;
          end loop;
        end if;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'doWeakHeaderRuleEvaluation',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end doWeakHeaderRuleEvaluation;
  procedure evaluateRules as
    /*
      conditionlessRuleCursor finds all rules having no ordinary or exception conditions
      that the current transaction type uses.
    */
    cursor conditionlessRuleCursor(processPrioritiesIn in varchar2,
                                   processProductionRulesIn in varchar2,
                                   combinationRulePriorityModeIn in varchar2,
                                   combinationRuleThresholdIn in integer,
                                   authorityRulePriorityModeIn in varchar2,
                                   authorityRuleThresholdIn in integer,
                                   exceptionRulePriorityModeIn in varchar2,
                                   exceptionRuleThresholdIn in integer,
                                   listModRulePriorityModeIn in varchar2,
                                   listModRuleThresholdIn in integer,
                                   substRulePriorityModeIn in varchar2,
                                   substRuleThresholdIn in integer,
                                   preRulePriorityModeIn in varchar2,
                                   preRuleThresholdIn in integer,
                                   postRulePriorityModeIn in varchar2,
                                   postRuleThresholdIn in integer,
                                   productionRulePriorityModeIn in varchar2,
                                   productionRuleThresholdIn in integer,
                                   headerItemClassIdIn in integer) is
      select
        ame_rules.rule_id rule_id,
        nvl(ame_rules.item_class_id,
            headerItemClassIdIn) item_class_id,
        ame_rules.rule_type rule_type,
        ame_rule_usages.priority priority,
        ame_rule_usages.approver_category approver_category
      from
        ame_rules,
        ame_rule_usages,
        ame_item_class_usages
      where
        ame_rules.rule_id = ame_rule_usages.rule_id and
        ame_rule_usages.item_id = engAmeApplicationId and
        nvl(ame_rules.item_class_id, headerItemClassIdIn) = ame_item_class_usages.item_class_id and
        ame_item_class_usages.application_id = engAmeApplicationId and
        (processPrioritiesIn = ame_util.booleanFalse or
         (ame_rules.rule_type = ame_util.combinationRuleType and
          (combinationRulePriorityModeIn <> ame_util.absoluteRulePriority or
           combinationRuleThresholdIn >= ame_rule_usages.priority)) or
         (ame_rules.rule_type = ame_util.authorityRuleType and
          (authorityRulePriorityModeIn <> ame_util.absoluteRulePriority or
           authorityRuleThresholdIn >= ame_rule_usages.priority)) or
         (ame_rules.rule_type = ame_util.exceptionRuleType and
          (exceptionRulePriorityModeIn <> ame_util.absoluteRulePriority or
           exceptionRuleThresholdIn >= ame_rule_usages.priority)) or
         (ame_rules.rule_type = ame_util.listModRuleType and
          (listModRulePriorityModeIn <> ame_util.absoluteRulePriority or
           listModRuleThresholdIn >= ame_rule_usages.priority)) or
         (ame_rules.rule_type = ame_util.substitutionRuleType and
          (substRulePriorityModeIn <> ame_util.absoluteRulePriority or
           substRuleThresholdIn >= ame_rule_usages.priority)) or
         (ame_rules.rule_type = ame_util.preListGroupRuleType and
          (preRulePriorityModeIn <> ame_util.absoluteRulePriority or
           preRuleThresholdIn >= ame_rule_usages.priority)) or
         (ame_rules.rule_type = ame_util.postListGroupRuleType and
          (postRulePriorityModeIn <> ame_util.absoluteRulePriority or
           postRuleThresholdIn >= ame_rule_usages.priority)) or
         (ame_rules.rule_type = ame_util.productionRuleType and
          (productionRulePriorityModeIn <> ame_util.absoluteRulePriority or
           productionRuleThresholdIn >= ame_rule_usages.priority))) and
        (processProductionRulesIn = ame_util.booleanTrue or
         ame_rules.rule_type <> ame_util.productionRuleType) and
        not exists (select *
                      from
                        ame_conditions,
                        ame_condition_usages
                      where
                        ame_conditions.condition_type <> ame_util.listModConditionType and
                        ame_conditions.condition_id = ame_condition_usages.condition_id and
                        ame_condition_usages.rule_id = ame_rules.rule_id and
                        engEffectiveRuleDate between
                          ame_conditions.start_date and
                          nvl(ame_conditions.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
                        engEffectiveRuleDate between
                          ame_condition_usages.start_date and
                          nvl(ame_condition_usages.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
                        /* Avoids second fetch otherwise required by ANSI standard to check for too many rows. */
                        rownum < 2) and
        engEffectiveRuleDate between
          ame_rules.start_date and
          nvl(ame_rules.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
        engEffectiveRuleDate between
          ame_rule_usages.start_date and
          nvl(ame_rule_usages.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
        engEffectiveRuleDate between
          ame_item_class_usages.start_date and
          nvl(ame_item_class_usages.end_date - ame_util.oneSecond, engEffectiveRuleDate)
      order by
        ame_item_class_usages.item_class_order_number,
        item_class_id,
        ame_rules.rule_type,
        ame_rules.rule_id;
    conditionlessItemClassIds ame_util.idList;
    conditionlessRuleApprCats ame_util.charList;
    conditionlessRuleIds ame_util.idList;
    conditionlessRulePriorities ame_util.idList;
    conditionlessRuleTypes ame_util.stringList;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    firstConditionlessRuleFound boolean;
    firstConditionlessRuleIndex integer;
    lastConditionlessRuleIndex integer;
    lowerBound integer;
    noRulesException exception;
    processPriorities ame_util.charType;
    processProductions ame_util.charType;
    tempIndex integer;
    tempItemClassId integer;
    upperBound integer;
    upperBound2 integer;
    begin
      /* Fetch all conditionless rules and store them in local variables. */
      if(engProcessPriorities) then
        processPriorities := ame_util.booleanTrue;
      else
        processPriorities := ame_util.booleanFalse;
      end if;
      if(engProcessProductionRules) then
        processProductions := ame_util.booleanTrue;
      else
        processProductions := ame_util.booleanFalse;
      end if;
      open conditionlessRuleCursor(processPrioritiesIn => processPriorities,
                                   processProductionRulesIn => processProductions,
                                   combinationRulePriorityModeIn => engPriorityModes(ame_util.combinationRuleType),
                                   combinationRuleThresholdIn => engPriorityThresholds(ame_util.combinationRuleType),
                                   authorityRulePriorityModeIn => engPriorityModes(ame_util.authorityRuleType),
                                   authorityRuleThresholdIn => engPriorityThresholds(ame_util.authorityRuleType),
                                   exceptionRulePriorityModeIn => engPriorityModes(ame_util.exceptionRuleType),
                                   exceptionRuleThresholdIn => engPriorityThresholds(ame_util.exceptionRuleType),
                                   listModRulePriorityModeIn => engPriorityModes(ame_util.listModRuleType),
                                   listModRuleThresholdIn => engPriorityThresholds(ame_util.listModRuleType),
                                   substRulePriorityModeIn => engPriorityModes(ame_util.substitutionRuleType),
                                   substRuleThresholdIn => engPriorityThresholds(ame_util.substitutionRuleType),
                                   preRulePriorityModeIn => engPriorityModes(ame_util.preListGroupRuleType),
                                   preRuleThresholdIn => engPriorityThresholds(ame_util.preListGroupRuleType),
                                   postRulePriorityModeIn => engPriorityModes(ame_util.postListGroupRuleType),
                                   postRuleThresholdIn => engPriorityThresholds(ame_util.postListGroupRuleType),
                                   productionRulePriorityModeIn => engPriorityModes(ame_util.productionRuleType),
                                   productionRuleThresholdIn => engPriorityThresholds(ame_util.productionRuleType),
                                   headerItemClassIdIn => getItemClassId(itemClassNameIn => ame_util.headerItemClassName));
      fetch conditionlessRuleCursor bulk collect
        into
          conditionlessRuleIds,
          conditionlessItemClassIds,
          conditionlessRuleTypes,
          conditionlessRulePriorities,
          conditionlessRuleApprCats;
      close conditionlessRuleCursor;
      firstConditionlessRuleIndex := 0;
      lastConditionlessRuleIndex := 0;
      /*
        Loop through the item classes in engItemClassIds, evaluating the
        transaction type's rules for each item in each class.
      */
      for itemClassIndex in 1 .. engItemClassIds.count loop
        lowerBound := engItemClassItemIdIndexes(itemClassIndex);
        if(lowerBound is not null) then
          upperBound := engItemClassItemIdIndexes(itemClassIndex) + engItemCounts(itemClassIndex) - 1;
          tempItemClassId := engItemClassIds(itemClassIndex);
          /* Find this item class' conditionless rules. */
          firstConditionlessRuleFound := false;
          upperBound2 := conditionlessRuleIds.count;
          /* Following for loop modified for bug 4094058 Issue 19 */
          for i in firstConditionlessRuleIndex + 1 .. upperBound2 loop
            if(firstConditionlessRuleFound) then
              if(conditionlessItemClassIds(i) = tempItemClassId) then
                lastConditionlessRuleIndex := i;
              end if;
            else
              if(conditionlessItemClassIds(i) = tempItemClassId) then
                firstConditionlessRuleFound := true;
                firstConditionlessRuleIndex := i;
                lastConditionlessRuleIndex := i;
              end if;
            end if;
            if (i < upperBound2 and conditionlessItemClassIds(i+1) <> tempItemClassId) then
              exit;
            end if;
          end loop;
          /* Loop through the items in this item class. */
          for itemIndex in lowerBound .. upperBound loop
            /* Add any conditionless rules for the current item class to the current item's applicable-rule list. */
            if(firstConditionlessRuleFound) then
              tempIndex := engAppRuleIds.count; /* pre-increment */
              for conditionlessRuleIndex in firstConditionlessRuleIndex .. lastConditionlessRuleIndex loop
                tempIndex := tempIndex + 1;
                engAppRuleIds(tempIndex) := conditionlessRuleIds(conditionlessRuleIndex);
                engAppPriorities(tempIndex) := conditionlessRulePriorities(conditionlessRuleIndex);
                engAppApproverCategories(tempIndex) := conditionlessRuleApprCats(conditionlessRuleIndex);
                engAppRuleTypes(tempIndex) := conditionlessRuleTypes(conditionlessRuleIndex);
                engRuleAppliedYN(tempIndex) := ame_util.booleanTrue;
                /* These are the item class and item to which the rule applies. */
                engAppItemClassIds(tempIndex) := tempItemClassId;
                engAppItemIds(tempIndex) := engItemIds(itemIndex);
                /*
                  These are the item class and item that satisfy the rule.  By convention, for rules
                  having no ordinary conditions, these are the same as the item class and item to
                  which the rule applies.
                */
                engAppRuleItemClassIds(tempIndex) := tempItemClassId;
                engAppAppItemIds(tempIndex) := engItemIds(itemIndex);
              end loop;
            end if;
            /* Evaluate the rules with conditions for this item. */
            if(engItemClassNames(itemClassIndex) = ame_util.headerItemClassName) then
              /*
                The header item class always has exactly one item, so one of the procedures
                in the following if/else will get called exactly once per engine cycle.
              */
              if(getHeaderAttValue2(attributeNameIn => ame_util.restrictiveItemEvalAttribute) =
                 ame_util.booleanAttributeTrue) then
                doStrictHeaderRuleEvaluation(itemClassIndexIn => itemClassIndex,
                                             itemClassIdIn => tempItemClassId);
              else
                doWeakHeaderRuleEvaluation(itemClassIndexIn => itemClassIndex,
                                           itemClassIdIn => tempItemClassId);
              end if;
            else
              /* Evaluate the rules in the active conditions for the current item only. */
              doPerItemRuleEvaluation(itemClassIdIn => tempItemClassId,
                                      itemIndexIn => itemIndex);
            end if;
          end loop;
        end if;
      end loop;
      /*
        So far, list-modification and substitution rules have been treated as if they belonged
        to the header item class.  Now set their item-class IDs and item IDs null and sort the
        applicable rules, so the list-modification and substitution rules get processed last.
      */
      for i in 1 .. engAppRuleIds.count loop
        if(engAppRuleTypes(i) in (ame_util.listModRuleType, ame_util.substitutionRuleType)) then
          engRuleAppliedYN(i) := ame_util.booleanFalse;
          engAppLMSubItemClassIds(engAppRuleIds(i)) := engAppRuleItemClassIds(i);
          engAppLMSubItemIds(engAppRuleIds(i)) := engAppAppItemIds(i);
          engAppRuleItemClassIds(i) := null;
          engAppAppItemIds(i) := null;
        end if;
      end loop;
      sortApplicableRules(sortByActionTypeIn => false);
      /*
        Priority processing has so far occurred only for absolute priorities--for conditionless
        rules in the conditionlessRuleCursor in this procedure, for rule with conditions in the
        activeCondUsageCursor cursor of the procedure fetchActiveConditionUsages.  Now that the
        remaining applicable rules are sorted by rule type, we can process relative priorities.
      */
      if(engProcessPriorities) then
        processRelativePriorities;
      end if;
      if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
        if engAppRuleIds.count = 0 then
          fnd_log.string
            (fnd_log.level_statement
            ,'ame_engine.evaluateRules'
            ,'*********** No Rules Applicable ************'
            );
        else
          for i in 1 .. engAppRuleIds.count loop
            fnd_log.string
              (fnd_log.level_statement
              ,'ame_engine.evaluateRules'
              ,'Applicable Rule ::: ' || engAppRuleIds(i)
              );
          end loop;
        end if;
      end if;
      /* Check for no rules, if AT_LEAST_ONE_RULE_MUST_APPLY is true. */
      if(getHeaderAttValue2(attributeNameIn => ame_util.atLeastOneRuleAttribute) = ame_util.booleanAttributeTrue and
         engAppRuleIds.count = 0) then
        raise noRulesException;
      end if;
      exception
        when noRulesException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400117_ENG_ONE_RULE_APPLY');
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'evaluateRules',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          if(conditionlessRuleCursor%isopen) then
            close conditionlessRuleCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'evaluateRules',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end evaluateRules;
  procedure fetchActiveConditionUsages as
    cursor activeCondStringValueCursor is
      select
        condition_id,
        string_value
      from ame_string_values
      where
        condition_id in
          (select ame_condition_usages.condition_id
            from
              ame_attributes,
              ame_conditions,
              ame_condition_usages,
              ame_rule_usages
            where
              ame_attributes.attribute_type = ame_util.stringAttributeType and
              ame_attributes.attribute_id = ame_conditions.attribute_id and
              ame_conditions.condition_id = ame_condition_usages.condition_id and
              ame_condition_usages.rule_id = ame_rule_usages.rule_id and
              ame_rule_usages.item_id = engAmeApplicationId and
              engEffectiveRuleDate between
                ame_attributes.start_date and
                nvl(ame_attributes.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
              engEffectiveRuleDate between
                ame_conditions.start_date and
                nvl(ame_conditions.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
              engEffectiveRuleDate between
                ame_condition_usages.start_date and
                nvl(ame_condition_usages.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
              engEffectiveRuleDate between
                ame_rule_usages.start_date and
                nvl(ame_rule_usages.end_date - ame_util.oneSecond, engEffectiveRuleDate)) and
        engEffectiveRuleDate between
          ame_string_values.start_date and
          nvl(ame_string_values.end_date - ame_util.oneSecond, engEffectiveRuleDate)
      order by condition_id;
    cursor activeCondUsageCursor(processPrioritiesIn in varchar2,
                                 processProductionRulesIn in varchar2,
                                 combinationRulePriorityModeIn in varchar2,
                                 combinationRuleThresholdIn in integer,
                                 authorityRulePriorityModeIn in varchar2,
                                 authorityRuleThresholdIn in integer,
                                 exceptionRulePriorityModeIn in varchar2,
                                 exceptionRuleThresholdIn in integer,
                                 listModRulePriorityModeIn in varchar2,
                                 listModRuleThresholdIn in integer,
                                 substRulePriorityModeIn in varchar2,
                                 substRuleThresholdIn in integer,
                                 preRulePriorityModeIn in varchar2,
                                 preRuleThresholdIn in integer,
                                 postRulePriorityModeIn in varchar2,
                                 postRuleThresholdIn in integer,
                                 productionRulePriorityModeIn in varchar2,
                                 productionRuleThresholdIn in integer,
                                 headerItemClassIdIn in integer) is
      select
        ame_conditions.condition_id condition_id,
        ame_conditions.condition_type condition_type,
        ame_conditions.attribute_id attribute_id,
        ame_conditions.parameter_one parameter_one,
        ame_conditions.parameter_two parameter_two,
        ame_conditions.parameter_three parameter_three,
        ame_conditions.include_lower_limit,
        ame_conditions.include_upper_limit,
        ame_condition_usages.rule_id rule_id,
        ame_rules.rule_type rule_type,
        nvl(ame_rules.item_class_id,
            headerItemClassIdIn) rule_item_class,
        ame_rule_usages.priority priority,
        ame_rule_usages.approver_category
      from
        ame_attributes,
        ame_conditions,
        ame_condition_usages,
        ame_rules,
        ame_rule_usages
      where
        ame_attributes.attribute_id = ame_conditions.attribute_id and
        ame_conditions.condition_type <> ame_util.listModConditionType and
        ame_conditions.condition_id = ame_condition_usages.condition_id and
        ame_condition_usages.rule_id = ame_rules.rule_id and
        ame_rules.rule_id = ame_rule_usages.rule_id and
        ame_rule_usages.item_id = engAmeApplicationId and
        (processPrioritiesIn = ame_util.booleanFalse or
         (ame_rules.rule_type = ame_util.combinationRuleType and
          (combinationRulePriorityModeIn <> ame_util.absoluteRulePriority or
           combinationRuleThresholdIn >= ame_rule_usages.priority)) or
         (ame_rules.rule_type = ame_util.authorityRuleType and
          (authorityRulePriorityModeIn <> ame_util.absoluteRulePriority or
           authorityRuleThresholdIn >= ame_rule_usages.priority)) or
         (ame_rules.rule_type = ame_util.exceptionRuleType and
          (exceptionRulePriorityModeIn <> ame_util.absoluteRulePriority or
           exceptionRuleThresholdIn >= ame_rule_usages.priority)) or
         (ame_rules.rule_type = ame_util.listModRuleType and
          (listModRulePriorityModeIn <> ame_util.absoluteRulePriority or
           listModRuleThresholdIn >= ame_rule_usages.priority)) or
         (ame_rules.rule_type = ame_util.substitutionRuleType and
          (substRulePriorityModeIn <> ame_util.absoluteRulePriority or
           substRuleThresholdIn >= ame_rule_usages.priority)) or
         (ame_rules.rule_type = ame_util.preListGroupRuleType and
          (preRulePriorityModeIn <> ame_util.absoluteRulePriority or
           preRuleThresholdIn >= ame_rule_usages.priority)) or
         (ame_rules.rule_type = ame_util.postListGroupRuleType and
          (postRulePriorityModeIn <> ame_util.absoluteRulePriority or
           postRuleThresholdIn >= ame_rule_usages.priority)) or
         (ame_rules.rule_type = ame_util.productionRuleType and
          (productionRulePriorityModeIn <> ame_util.absoluteRulePriority or
           productionRuleThresholdIn >= ame_rule_usages.priority))) and
        (processProductionRulesIn = ame_util.booleanTrue or
         ame_rules.rule_type <> ame_util.productionRuleType) and
        engEffectiveRuleDate between
          ame_attributes.start_date and
          nvl(ame_attributes.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
        engEffectiveRuleDate between
          ame_conditions.start_date and
          nvl(ame_conditions.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
        engEffectiveRuleDate between
          ame_condition_usages.start_date and
          nvl(ame_condition_usages.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
        engEffectiveRuleDate between
          ame_rules.start_date and
          nvl(ame_rules.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
        engEffectiveRuleDate between
          ame_rule_usages.start_date and
          nvl(ame_rule_usages.end_date - ame_util.oneSecond, engEffectiveRuleDate)
      order by
        rule_item_class,
        ame_rules.rule_type,
        ame_rules.rule_id,
        ame_attributes.item_class_id;
    /*
      The tempACU tables are buffers between the active-condition-usage fetch and
      the engAC variables.  The temp variables are indexed consecutively, while
      the engAC variables are indexed by condition ID or rule ID.
    */
    tempACUAttributeIds ame_util.idList;
    tempACUConditionTypes ame_util.stringList;
    tempACUIncludeLowerLimits ame_util.charList;
    tempACUIncludeUpperLimits ame_util.charList;
    tempACUItemClassIds ame_util.idList;
    tempACUParameterOnes ame_util.stringList;
    tempACUParameterThrees ame_util.stringList;
    tempACUParameterTwos ame_util.longStringList;
    tempACURuleApprCats ame_util.charList;
    tempACURulePriorities ame_util.idList;
    tempACURuleTypes ame_util.idList;
    /*
      tempACConditionIds is a buffer between the string-value fetch and the
      engACStringValue variables.
    */
    tempACConditionIds ame_util.idList;
    /* misc. local variables */
    processPriorities ame_util.charType;
    processProductions ame_util.charType;
    tempConditionID integer;
    tempCount integer;
    tempItemClassID integer;
    tempRuleId integer;
    begin
      /*
        Fetch all condition usages for conditions used by the rules that are used by
        the current transaction type.
      */
      if(engProcessPriorities) then
        processPriorities := ame_util.booleanTrue;
      else
        processPriorities := ame_util.booleanFalse;
      end if;
      if(engProcessProductionRules) then
        processProductions := ame_util.booleanTrue;
      else
        processProductions := ame_util.booleanFalse;
      end if;
      open activeCondUsageCursor(processPrioritiesIn => processPriorities,
                                 processProductionRulesIn => processProductions,
                                 combinationRulePriorityModeIn => engPriorityModes(ame_util.combinationRuleType),
                                 combinationRuleThresholdIn => engPriorityThresholds(ame_util.combinationRuleType),
                                 authorityRulePriorityModeIn => engPriorityModes(ame_util.authorityRuleType),
                                 authorityRuleThresholdIn => engPriorityThresholds(ame_util.authorityRuleType),
                                 exceptionRulePriorityModeIn => engPriorityModes(ame_util.exceptionRuleType),
                                 exceptionRuleThresholdIn => engPriorityThresholds(ame_util.exceptionRuleType),
                                 listModRulePriorityModeIn => engPriorityModes(ame_util.listModRuleType),
                                 listModRuleThresholdIn => engPriorityThresholds(ame_util.listModRuleType),
                                 substRulePriorityModeIn => engPriorityModes(ame_util.substitutionRuleType),
                                 substRuleThresholdIn => engPriorityThresholds(ame_util.substitutionRuleType),
                                 preRulePriorityModeIn => engPriorityModes(ame_util.preListGroupRuleType),
                                 preRuleThresholdIn => engPriorityThresholds(ame_util.preListGroupRuleType),
                                 postRulePriorityModeIn => engPriorityModes(ame_util.postListGroupRuleType),
                                 postRuleThresholdIn => engPriorityThresholds(ame_util.postListGroupRuleType),
                                 productionRulePriorityModeIn => engPriorityModes(ame_util.productionRuleType),
                                 productionRuleThresholdIn => engPriorityThresholds(ame_util.productionRuleType),
                                 headerItemClassIdIn => getItemClassId(itemClassNameIn => ame_util.headerItemClassName));
      fetch activeCondUsageCursor bulk collect
        into
          engACUsageConditionIds,
          tempACUConditionTypes,
          tempACUAttributeIds,
          tempACUParameterOnes,
          tempACUParameterTwos,
          tempACUParameterThrees,
          tempACUIncludeLowerLimits,
          tempACUIncludeUpperLimits,
          engACUsageRuleIds,
          tempACURuleTypes,
          tempACUItemClassIds,
          tempACURulePriorities,
          tempACURuleApprCats;
      close activeCondUsageCursor;
      /*
        Loop through the active condition usages, writing their conditions to the
        engAC variables each time a new condition is encountered.
      */
      tempCount := engACUsageConditionIds.count;
      for activeCUIndex in 1 .. tempCount loop
        tempItemClassID := tempACUItemClassIds(activeCUIndex);
        tempConditionID := engACUsageConditionIds(activeCUIndex);
        if(not engACAttributeIds.exists(tempConditionID)) then
          engACAttributeIds(tempConditionID) := tempACUAttributeIds(activeCUIndex);
          engACConditionTypes(tempConditionID) := tempACUConditionTypes(activeCUIndex);
          engACParameterOnes(tempConditionID) := tempACUParameterOnes(activeCUIndex);
          engACParameterTwos(tempConditionID) := tempACUParameterTwos(activeCUIndex);
          engACParameterThrees(tempConditionID) := tempACUParameterThrees(activeCUIndex);
          engACIncludeLowerLimits(tempConditionID) := tempACUIncludeLowerLimits(activeCUIndex);
          engACIncludeUpperLimits(tempConditionID) := tempACUIncludeUpperLimits(activeCUIndex);
        end if;
        /*
          If this iteration starts an item class, record this iteration's index
          in engACUsageFirstIndexes.
        */
        if(activeCUIndex = 1 or
           tempItemClassID <> tempACUItemClassIds(activeCUIndex - 1)) then
          engACUsageFirstIndexes(tempItemClassID) := activeCUIndex;
        end if;
        /*
          If this iteration is the last iteration for its item class,
          record the item class' active-condition-usage count.
        */
        if(activeCUIndex = tempCount or
           tempItemClassID <> tempACUItemClassIds(activeCUIndex + 1)) then
          engACUsageItemClassCounts(tempItemClassID) :=
            activeCUIndex - engACUsageFirstIndexes(tempItemClassID) + 1;
        end if;
        /*
          Write the rule priority and rule type into engACUsageRulePriorities indexed by rule ID.
          This lets the engine fetch the rule priorities and types efficiently, without carrying
          them through all of its algorithms.
        */
        tempRuleId := engACUsageRuleIds(activeCUIndex);
        engACUsageRulePriorities(tempRuleId) := tempACURulePriorities(activeCUIndex);
        engACUsageRuleTypes(tempRuleId) := tempACURuleTypes(activeCUIndex);
        engACUsageRuleApprCategories(tempRuleId) := tempACURuleApprCats(activeCUIndex);
      end loop;
      /* Second, fetch the string values for any active conditions on string attributes. */
      open activeCondStringValueCursor;
      fetch activeCondStringValueCursor bulk collect
        into
          tempACConditionIds,
          engACStringValues;
      close activeCondStringValueCursor;
      /* Loop through the string conditions, writing them out to the engACStringValue variables. */
      tempCount := tempACConditionIds.count;
      for stringValueIndex in 1 .. tempCount loop
        tempConditionID := tempACConditionIds(stringValueIndex);
        /*
          If this iteration starts a condition's string-value list, record this
          iteration's index in engACStringValueFirstIndexes.
        */
        if(stringValueIndex = 1 or
           tempConditionID <> tempACConditionIds(stringValueIndex - 1)) then
          engACStringValueFirstIndexes(tempConditionID) := stringValueIndex;
        end if;
        /*
          engACStringValueCounts(condition_id) is the number of rows in
          engACStringValues for the condition with ID condition_id, starting at
          the index engACStringValueFirstIndexes(condition_id).
        */
        if(stringValueIndex = tempCount or
           tempConditionID <> tempACConditionIds(stringValueIndex + 1)) then
          engACStringValueCounts(tempConditionID) :=
            stringValueIndex - engACStringValueFirstIndexes(tempConditionID) + 1;
        end if;
      end loop;
      exception
        when others then
          if(activeCondUsageCursor%isopen) then
            close activeCondUsageCursor;
          end if;
          if(activeCondStringValueCursor%isopen) then
            close activeCondStringValueCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'fetchActiveConditionUsages',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end fetchActiveConditionUsages;
  procedure fetchApplicableActions as
    cursor applicableActionsCursor(ruleIdIn in integer) is
      select
        ame_actions.action_type_id,
        ame_actions.parameter,
        ame_actions.parameter_two
        from
          ame_actions,
          ame_action_usages
        where
          ame_actions.action_id = ame_action_usages.action_id and
          ame_action_usages.rule_id = ruleIdIn and
          engEffectiveRuleDate between
            ame_actions.start_date and
            nvl(ame_actions.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
          engEffectiveRuleDate between
            ame_action_usages.start_date and
            nvl(ame_action_usages.end_date - ame_util.oneSecond, engEffectiveRuleDate);
    productionActionTypeId integer;
    tempActionTypeIds ame_util.idList;
    tempBoolean boolean;
    tempNewRuleIndex integer;
    tempRuleCount integer;
    tempRuleIndex integer;
    tempParameters ame_util.stringList;
    tempParameterTwos ame_util.stringList;
    tempPerAppProdIndex integer;
    begin
      /* Initialize per-approver-production variables. */
      productionActionTypeId := getActionTypeId(actionTypeNameIn => ame_util.productionActionTypeName);
      tempPerAppProdIndex := 0; /* pre-increment */
      /* Delete priorities, to make sure they don't get used from here on. */
      engAppPriorities.delete;
      /* Fetch each applicable rule's actions. */
      tempRuleCount := engAppRuleIds.count;
      tempNewRuleIndex := tempRuleCount; /* pre-increment tempNewRuleIndex */
      for i in 1 .. tempRuleCount loop
        tempActionTypeIds.delete;
        tempParameters.delete;
        tempParameterTwos.delete;
        open applicableActionsCursor(ruleIdIn => engAppRuleIds(i));
        fetch applicableActionsCursor bulk collect
          into
            tempActionTypeIds,
            tempParameters,
            tempParameterTwos;
        close applicableActionsCursor;
        /* Populate the engAppPerAppProd variables. */
        if(engAppRuleTypes(i) <> ame_util.productionRuleType) then
          tempBoolean := true; /* Here tempBoolean is true until a production action for this rule is found. */
          for j in 1 .. tempActionTypeIds.count loop
            if(engActionTypeUsages(tempActionTypeIds(j)) = ame_util.productionRuleType) then
              tempPerAppProdIndex := tempPerAppProdIndex + 1;
              if(tempBoolean) then
                tempBoolean := false;
                engAppPerAppProdFirstIndexes(engAppRuleIds(i)) := tempPerAppProdIndex;
              end if;
              engAppPerAppProdRuleIds(tempPerAppProdIndex) := engAppRuleIds(i);
              engAppPerAppProdVariableNames(tempPerAppProdIndex) := tempParameters(j);
              engAppPerAppProdVariableValues(tempPerAppProdIndex) := tempParameterTwos(j);
              tempActionTypeIds(j) := null;  /* This prevents further processing later. */
            end if;
          end loop;
        end if;
        /*
          If the rule is a production rule, put the first action in the same row as the rule.
          Otherwise, put the first non-production action in that row.  (There should always be
          at least one non-production action in a non-production rule, and at least one production
          action in a production rule.)  Put any remaining actions (non-production actions, unless
          the rule is a production rule) in new rows.
        */
        /* Here tempBoolean is true until the first useable production action is found. */
        tempBoolean := true;
        for j in 1 .. tempActionTypeIds.count loop
          /* Ignore actions with null action-type IDs; these were per-approver production actions. */
          if(tempActionTypeIds(j) is not null) then
            if(tempBoolean) then
              tempBoolean := false;
              tempRuleIndex := i;
            else
              tempNewRuleIndex := tempNewRuleIndex + 1;
              tempRuleIndex := tempNewRuleIndex;
            end if;
            engAppItemClassIds(tempRuleIndex) := engAppItemClassIds(i);
            engAppItemIds(tempRuleIndex) := engAppItemIds(i);
            engAppRuleIds(tempRuleIndex) := engAppRuleIds(i);
            engRuleAppliedYN(tempRuleIndex) := engRuleAppliedYN(i);
            engAppRuleTypes(tempRuleIndex) := engAppRuleTypes(i);
            engAppApproverCategories(tempRuleIndex) := engAppApproverCategories(i);
            engAppActionTypeIds(tempRuleIndex) := tempActionTypeIds(j);
            engAppParameters(tempRuleIndex) := tempParameters(j);
            engAppParameterTwos(tempRuleIndex) := tempParameterTwos(j);
            engAppRuleItemClassIds(tempRuleIndex) := engAppRuleItemClassIds(i);
            engAppAppItemIds(tempRuleIndex) := engAppAppItemIds(i);
          end if;
        end loop;
      end loop;
      /* Convert combination rules to other rule types. */
      for i in 1 .. engAppRuleTypes.count loop
        if(engAppRuleTypes(i) = ame_util.combinationRuleType) then
          engAppRuleTypes(i) := engActionTypeUsages(engAppActionTypeIds(i));
          /* The following if statement was added to resolve bug 3522880. */
          if(engAppRuleTypes(i) in (ame_util.listModRuleType, ame_util.substitutionRuleType)) then
            engAppLMSubItemClassIds(engAppRuleIds(i)) := engAppRuleItemClassIds(i);
            engAppLMSubItemIds(engAppRuleIds(i)) := engAppAppItemIds(i);
            engAppRuleItemClassIds(i) := null;
            engAppAppItemIds(i) := null;
          end if;
        end if;
      end loop;
      /*
        Sort all of the engApp lists:  first by item-class order number, then by
        item-class ID, then by item ID, then by rule type, then by action-type order
        number, then by action-type ID.  See engApp declaration comment block for
        details.
      */
      sortApplicableRules(sortByActionTypeIn => true);
      /* Restore the item-class IDs and item IDs of list-modification and substitution rules. */
      for i in 1 .. engAppRuleIds.count loop
        /* The following if statement was changed to resolve bug 3522880. */
        -- if(engAppRuleTypes(i) in (ame_util.listModRuleType, ame_util.substitutionRuleType)) then
        if(engAppRuleItemClassIds(i) is null) then
          engAppRuleItemClassIds(i) := engAppLMSubItemClassIds(engAppRuleIds(i));
          engAppAppItemIds(i) := engAppLMSubItemIds(engAppRuleIds(i));
          engRuleAppliedYN(i) := ame_util.booleanFalse;
        end if;
      end loop;
      engAppLMSubItemClassIds.delete;
      engAppLMSubItemIds.delete;
      exception
        when others then
          if(applicableActionsCursor%isopen) then
            close applicableActionsCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'fetchApplicableActions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end fetchApplicableActions;
  procedure fetchAttributeValues(fetchInactivesIn in boolean) as
    cursor attributeCursor(applicationIdIn in integer,
                           fetchInactivesIn in varchar2) is
      select
        ame_attributes.attribute_id attribute_id,
        ame_attributes.name attribute_name,
        ame_attributes.attribute_type attribute_type,
        ame_attributes.item_class_id item_class_id,
        ame_attribute_usages.query_string,
        ame_attribute_usages.is_static
        from
          ame_attributes,
          ame_attribute_usages,
          ame_item_class_usages
        where
          ame_attributes.name not in (ame_util.workflowItemKeyAttribute, ame_util.workflowItemTypeAttribute) and
          ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
          ame_attribute_usages.application_id = applicationIdIn and
          ame_item_class_usages.application_id = applicationIdIn and
          ame_attributes.item_class_id = ame_item_class_usages.item_class_id and
          (fetchInactivesIn = ame_util.booleanTrue or
           ame_attribute_usages.use_count > 0 or
           ame_attributes.attribute_id in
            (select ame_attributes2.attribute_id
              from
                ame_attributes ame_attributes2,
                ame_mandatory_attributes
              where
                ame_attributes2.attribute_id = ame_mandatory_attributes.attribute_id and
                ame_mandatory_attributes.action_type_id = -1 and
                engEffectiveRuleDate between
                  ame_attributes2.start_date and
                  nvl(ame_attributes2.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
                engEffectiveRuleDate between
                  ame_mandatory_attributes.start_date and
                  nvl(ame_mandatory_attributes.end_date - ame_util.oneSecond, engEffectiveRuleDate))) and
          engEffectiveRuleDate between
            ame_attributes.start_date and
            nvl(ame_attributes.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
          engEffectiveRuleDate between
            ame_attribute_usages.start_date and
            nvl(ame_attribute_usages.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
          engEffectiveRuleDate between
            ame_item_class_usages.start_date and
            nvl(ame_item_class_usages.end_date - ame_util.oneSecond, engEffectiveRuleDate)
        /*
          The order-by conditions are all necessary.  The second is to break
          item_class_order_number ties in a determinate order.  The third is
          to display attribute names in alphabetical order on the test tab.
          Compare the itemClassUsageCursor cursor in the procedure updateTransactionState.
        */
        order by
          ame_item_class_usages.item_class_order_number,
          ame_item_class_usages.item_class_id,
          ame_attributes.name;
    cursor testTransCurrencyCursor(attributeIdIn in integer) is
      select
        attribute_value_1,
        attribute_value_2,
        attribute_value_3
      from ame_test_trans_att_values
      where
        application_id = engAmeApplicationId and
        transaction_id = engTransactionId and
        attribute_id = attributeIdIn
      order by item_id;
    cursor testTransNonCurrencyCursor(attributeIdIn in integer) is
      select attribute_value_1
      from ame_test_trans_att_values
      where
        application_id = engAmeApplicationId and
        transaction_id = engTransactionId and
        attribute_id = attributeIdIn
      order by item_id;
    cursor testTransVariantHeaderCursor(attributeIdIn in integer) is
      select attribute_value_1
      from ame_test_trans_att_values
      where
        application_id = engAmeApplicationId and
        transaction_id = engTransactionId and
        attribute_id = attributeIdIn and
        item_class_id = getItemClassId(ame_util.headerItemClassName) and
        item_id = engTransactionId;
    attributeCount integer;
    attributeIds ame_util.idList;
    attributeItemClassIds ame_util.idList;
    attributeNames ame_util.stringList;
    attributeTypes ame_util.stringList;
    dynamicCursor integer;
    dynamicQuery ame_util.longestStringType;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    fetchInactives varchar2(1);
    isStatics ame_util.charList;
    queryStrings ame_util.longestStringList;
    rowCountException exception;
    rowsFound integer;
    tempAttributeId integer;
    tempAttributeName ame_attributes.name%type;
    tempAttributeType ame_attributes.attribute_type%type;
    tempAttributeValue1 ame_util.attributeValueType;
    tempAttributeValue2 ame_util.attributeValueType;
    tempAttributeValue3 ame_util.attributeValueType;
    tempAttributeValueIndex integer;
    tempAttributeValues1 dbms_sql.varchar2_table;
    tempAttributeValues2 dbms_sql.varchar2_table;
    tempAttributeValues3 dbms_sql.varchar2_table;
    tempItemClassIndex integer;
    begin
      /*
        fetchInactives is necessary because we can't use a PL/SQL boolean variable
        in a select statement.
      */
      if(fetchInactivesIn) then
        fetchInactives := ame_util.booleanTrue;
      else
        fetchInactives := ame_util.booleanFalse;
      end if;
      /* Bulk fetch attributeCursor into a PL/SQL table. */
      open attributeCursor(applicationIdIn => engAmeApplicationId,
                           fetchInactivesIn => fetchInactives);
      fetch attributeCursor bulk collect
        into
          attributeIds,
          attributeNames,
          attributeTypes,
          attributeItemClassIds,
          queryStrings,
          isStatics;
      close attributeCursor;
      /*
        Fetch each attribute's value.  The attributes are in order of their item classes'
        item_class_order_numbers, so we can simply load them into the attribute package
        variables in index order, noting in engAttributeValueIndexes where each attribute's
        values start.
      */
      attributeCount := attributeIds.count;
      /* tempAttributeValueIndex indexes into engAttributeValues1-3.  Pre-increment it. */
      tempAttributeValueIndex := 0;
      for i in 1 .. attributeCount loop
        tempItemClassIndex := engItemClassIndexes(attributeItemClassIds(i));
        tempAttributeId := attributeIds(i);
        tempAttributeType := attributeTypes(i);
        /* Set the attribute's package variables, even if the attribute's item class has no items. */
        engAttributeIsStatics(tempAttributeId) := isStatics(i);
        engAttributeNames(tempAttributeId) := attributeNames(i);
        engAttributeTypes(tempAttributeId) := attributeTypes(i);
        engAttributeItemClassIds(tempAttributeId) := attributeItemClassIds(i);
        /* Check if the attribute is a variant and set the engAttributeQueries and engAttributeVariant accordingly */
        dynamicQuery := ame_util.removeReturns(stringIn => queryStrings(i),
                                               replaceWithSpaces => true);
        if(checkAttributeVariant(attributeIdIn => tempAttributeId) = ame_util.booleanTrue) then
          if ((isStatics(i) = ame_util.booleanFalse) and
             (instrb(dynamicQuery, ame_util2.itemClassPlaceHolder) > 0 or
              instrb(dynamicQuery, ame_util2.itemIdPlaceHolder) > 0)) then
            engAttributeVariant(tempAttributeId) := ame_util.booleanTrue;
            engAttributeQueries(tempAttributeId) := queryStrings(i);
          end if;
        end if;
        if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
          fnd_log.string
            (fnd_log.level_statement
            ,'ame_engine.fetchAttributeValues'
            ,'Attribute ::: ' || engAttributeNames(tempAttributeId) || '(' || tempAttributeId || ')'
            );
        end if;
        /*
          Set this attribute's values in engAttributeValues1-3, if the attribute's item class
          has any items.
        */
        if(engItemCounts(tempItemClassIndex) = 0) then
          engAttributeValueIndexes(attributeIds(i)) := null;
        else
          /* (tempAttributeValueIndex will be pre-incremented when it's actually used.) */
          engAttributeValueIndexes(attributeIds(i)) := tempAttributeValueIndex + 1;
          if(engIsTestTransaction) then
              tempAttributeValues1.delete;
              tempAttributeValues2.delete;
              tempAttributeValues3.delete;
              if(checkAttributeVariant(tempAttributeId) = ame_util.booleanTrue) then
                open testTransVariantHeaderCursor(attributeIdIn => tempAttributeId);
                fetch testTransVariantHeaderCursor bulk collect
                  into tempAttributeValues1;
                close testTransVariantHeaderCursor;
              else
                if(tempAttributeType = ame_util.currencyAttributeType) then
                  open testTransCurrencyCursor(attributeIdIn => tempAttributeId);
                  fetch testTransCurrencyCursor bulk collect
                    into
                      tempAttributeValues1,
                      tempAttributeValues2,
                      tempAttributeValues3;
                  close testTransCurrencyCursor;
                else
                  open testTransNonCurrencyCursor(attributeIdIn => tempAttributeId);
                  fetch testTransNonCurrencyCursor bulk collect
                    into tempAttributeValues1;
                  close testTransNonCurrencyCursor;
                end if;
              end if;
              for j in 1 .. tempAttributeValues1.count loop
                tempAttributeValueIndex := tempAttributeValueIndex + 1;
                engAttributeValues1(tempAttributeValueIndex) := tempAttributeValues1(j);
                if(tempAttributeType = ame_util.currencyAttributeType) then
                  engAttributeValues2(tempAttributeValueIndex) := tempAttributeValues2(j);
                  engAttributeValues3(tempAttributeValueIndex) := tempAttributeValues3(j);
                else
                  engAttributeValues2(tempAttributeValueIndex) := null;
                  engAttributeValues3(tempAttributeValueIndex) := null;
                end if;
                if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
                  fnd_log.string
                    (fnd_log.level_statement
                    ,'ame_engine.fetchAttributeValues'
                    ,'Attribute Value :' || engAttributeValues1(tempAttributeValueIndex) ||
                     ':' || engAttributeValues2(tempAttributeValueIndex) || ':' || engAttributeValues3(tempAttributeValueIndex) || ':'
                    );
                end if;
              end loop;
              if tempAttributeValues1.count = 0 then
                for j in 1 .. engItemCounts(tempItemClassIndex) loop
                  tempAttributeValueIndex := tempAttributeValueIndex + 1;
                  engAttributeValues1(tempAttributeValueIndex) := null;
                  engAttributeValues2(tempAttributeValueIndex) := null;
                  engAttributeValues3(tempAttributeValueIndex) := null;
                  if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
                    fnd_log.string
                      (fnd_log.level_statement
                      ,'ame_engine.fetchAttributeValues'
                      ,'Attribute Value :' || engAttributeValues1(tempAttributeValueIndex) ||
                       ':' || engAttributeValues2(tempAttributeValueIndex) || ':' || engAttributeValues3(tempAttributeValueIndex) || ':'
                      );
                  end if;
                end loop;
              end if;
          else
            if(isStatics(i) = ame_util.booleanTrue) then
              /*
                Write the static usage into the attribute-value package variables once for each item
                of the attribute's item class.
              */
              if(attributeTypes(i) = ame_util.currencyAttributeType) then
                ame_util.parseStaticCurAttValue(applicationIdIn => engAmeApplicationId,
                                                attributeIdIn => tempAttributeId,
                                                attributeValueIn => queryStrings(i),
                                                localErrorIn => false,
                                                amountOut => tempAttributeValue1,
                                                currencyOut => tempAttributeValue2,
                                                conversionTypeOut => tempAttributeValue3);
              else
                tempAttributeValue1 := queryStrings(i);
                tempAttributeValue2 := null;
                tempAttributeValue3 := null;
              end if;
              for j in 1 .. engItemCounts(tempItemClassIndex) loop
                tempAttributeValueIndex := tempAttributeValueIndex + 1;
                engAttributeValues1(tempAttributeValueIndex) := tempAttributeValue1;
                engAttributeValues2(tempAttributeValueIndex) := tempAttributeValue2;
                engAttributeValues3(tempAttributeValueIndex) := tempAttributeValue3;
                if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
                  fnd_log.string
                    (fnd_log.level_statement
                    ,'ame_engine.fetchAttributeValues'
                    ,'Attribute Value :' || engAttributeValues1(tempAttributeValueIndex) ||
                     ':' || engAttributeValues2(tempAttributeValueIndex) || ':' || engAttributeValues3(tempAttributeValueIndex) || ':'
                    );
                end if;
              end loop;
            else
              tempAttributeValues1.delete;
              tempAttributeValues2.delete;
              tempAttributeValues3.delete;
              /*
                We need to do old-style dynamic PL/SQL here to make sure all occurrences of
                ame_util.transactionIdPlaceholder in dynamicQuery get bound.
              */
              dynamicQuery := ame_util.removeReturns(stringIn => queryStrings(i),
                                                     replaceWithSpaces => true);
              dynamicCursor := dbms_sql.open_cursor;
              dbms_sql.parse(dynamicCursor,
                             dynamicQuery,
                             dbms_sql.native);
              if(instrb(dynamicQuery, ame_util.transactionIdPlaceholder) > 0) then
                dbms_sql.bind_variable(dynamicCursor,
                                       ame_util.transactionIdPlaceholder,
                                       engTransactionId,
                                       50); /* ame_temp_transactions.transaction_id%length doesn't work here. */
              end if;
              if(instrb(dynamicQuery, ame_util2.itemClassPlaceHolder) > 0) then
                dbms_sql.bind_variable(dynamicCursor,
                                       ame_util2.itemClassPlaceHolder,
                                       ame_util.headerItemClassName,
                                       50); /* ame_temp_transactions.transaction_id%length doesn't work here. */
              end if;
              if(instrb(dynamicQuery, ame_util2.itemIdPlaceHolder) > 0) then
                dbms_sql.bind_variable(dynamicCursor,
                                       ame_util2.itemIdPlaceHolder,
                                       engTransactionId,
                                       50); /* ame_temp_transactions.transaction_id%length doesn't work here. */
              end if;
              dbms_sql.define_array(dynamicCursor,
                                    1,
                                    tempAttributeValues1,
                                    ame_util.attributeValueTypeLength,
                                    1);
              if(tempAttributeType = ame_util.currencyAttributeType) then
                dbms_sql.define_array(dynamicCursor,
                                      2,
                                      tempAttributeValues2,
                                      ame_util.attributeValueTypeLength,
                                      1);
                dbms_sql.define_array(dynamicCursor,
                                      3,
                                      tempAttributeValues3,
                                      ame_util.attributeValueTypeLength,
                                      1);
              end if;
              rowsFound := dbms_sql.execute(dynamicCursor);
              loop
                rowsFound := dbms_sql.fetch_rows(dynamicCursor);
                dbms_sql.column_value(dynamicCursor,
                                      1,
                                      tempAttributeValues1);
                if(tempAttributeType = ame_util.currencyAttributeType) then
                  dbms_sql.column_value(dynamicCursor,
                                        2,
                                        tempAttributeValues2);
                  dbms_sql.column_value(dynamicCursor,
                                        3,
                                        tempAttributeValues3);
                end if;
                exit when rowsFound < 100;
              end loop;
              dbms_sql.close_cursor(dynamicCursor);
              /* Make sure the attribute usage returned the right number of rows. */
              if(tempAttributeValues1.count <> engItemCounts(tempItemClassIndex)) then
                raise rowCountException;
              end if;
              /* Transfer the attribute values into the appropriate package variables. */
              for j in 1 .. tempAttributeValues1.count loop
                tempAttributeValueIndex := tempAttributeValueIndex + 1;
                engAttributeValues1(tempAttributeValueIndex) := tempAttributeValues1(j);
                if(tempAttributeType = ame_util.currencyAttributeType) then
                  engAttributeValues2(tempAttributeValueIndex) := tempAttributeValues2(j);
                  engAttributeValues3(tempAttributeValueIndex) := tempAttributeValues3(j);
                else
                  engAttributeValues2(tempAttributeValueIndex) := null;
                  engAttributeValues3(tempAttributeValueIndex) := null;
                end if;
                if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
                  fnd_log.string
                    (fnd_log.level_statement
                    ,'ame_engine.fetchAttributeValues'
                    ,'Attribute Value :' || engAttributeValues1(tempAttributeValueIndex) ||
                     ':' || engAttributeValues2(tempAttributeValueIndex) || ':' || engAttributeValues3(tempAttributeValueIndex) || ':'
                    );
                end if;
              end loop;
            end if;
          end if;
        end if;
      end loop;
      exception
        when rowCountException then
          if(attributeCursor%isopen) then
            close attributeCursor;
          end if;
          if(dbms_sql.is_open(dynamicCursor)) then
            dbms_sql.close_cursor(dynamicCursor);
          end if;
          if(testTransCurrencyCursor%isopen) then
            close testTransCurrencyCursor;
          end if;
          if(testTransNonCurrencyCursor%isopen) then
            close testTransNonCurrencyCursor;
          end if;
          tempAttributeName := ame_attribute_pkg.getName(attributeIdIn => tempAttributeId);
          if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
           fnd_log.string
            (fnd_log.level_statement
            ,'ame_engine.fetchAttributeValues'
            ,'Attribute ::: ' || tempAttributeName || '(' || tempAttributeId || ')'||
            'attribute returned ::'||tempAttributeValues1.count||'rows but the number of items for the '||
            'itemclass ::'||engItemCounts(tempItemClassIndex)
            );
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn =>'PER',
                                messageNameIn   => 'AME_400684_ATR_INV_DYN_USG',
                                tokenNameOneIn  => 'ATTRIBUTE_NAME',
                                tokenValueOneIn => tempAttributeName);
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'fetchAttributeValues',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          if(attributeCursor%isopen) then
            close attributeCursor;
          end if;
          if(dbms_sql.is_open(dynamicCursor)) then
            dbms_sql.close_cursor(dynamicCursor);
          end if;
          if(testTransCurrencyCursor%isopen) then
            close testTransCurrencyCursor;
          end if;
          if(testTransNonCurrencyCursor%isopen) then
            close testTransNonCurrencyCursor;
          end if;
          tempAttributeName := ame_attribute_pkg.getName(attributeIdIn => tempAttributeId);
          errorMessage := sqlerrm;
          if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
           fnd_log.string
            (fnd_log.level_statement
            ,'ame_engine.fetchAttributeValues'
            ,'Attribute ::: ' || tempAttributeName || '(' || tempAttributeId || '),error:'||errorMessage
            );
           end if;
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'fetchAttributeValues',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => errorMessage);
          raise;
    end fetchAttributeValues;
  procedure fetchOtherAttributeValues as
    cursor attributeCursor(applicationIdIn in integer) is
      select
        ame_attributes.attribute_id attribute_id,
        ame_attributes.name attribute_name,
        ame_attributes.attribute_type attribute_type,
        ame_attributes.item_class_id item_class_id,
        ame_attribute_usages.query_string,
        ame_attribute_usages.is_static
        from
          ame_attributes,
          ame_attribute_usages,
          ame_item_class_usages
        where
          ame_attributes.name not in (ame_util.workflowItemKeyAttribute, ame_util.workflowItemTypeAttribute) and
          ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
          ame_attribute_usages.application_id = applicationIdIn and
          ame_item_class_usages.application_id = applicationIdIn and
          ame_attributes.item_class_id = ame_item_class_usages.item_class_id and
          (ame_attribute_usages.use_count = 0 and
           ame_attributes.attribute_id not in
            (select ame_attributes2.attribute_id
              from
                ame_attributes ame_attributes2,
                ame_mandatory_attributes
              where
                ame_attributes2.attribute_id = ame_mandatory_attributes.attribute_id and
                ame_mandatory_attributes.action_type_id = -1 and
                sysdate between
                  ame_attributes2.start_date and
                  nvl(ame_attributes2.end_date - ame_util.oneSecond, sysdate) and
                sysdate between
                  ame_mandatory_attributes.start_date and
                  nvl(ame_mandatory_attributes.end_date - ame_util.oneSecond, sysdate))) and
          sysdate between
            ame_attributes.start_date and
            nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
          sysdate between
            ame_attribute_usages.start_date and
            nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate) and
          sysdate between
            ame_item_class_usages.start_date and
            nvl(ame_item_class_usages.end_date - ame_util.oneSecond, sysdate) and
            -- Condition to check whether the attribute is used in the rule
            exists
            (
              select 1
               from ame_conditions,
                    ame_condition_usages,
                    ame_rules,
                    ame_rule_usages
              where ame_conditions.attribute_id = ame_attributes.attribute_id
                and ame_conditions.condition_id = ame_condition_usages.condition_id
                and ame_condition_usages.rule_id = ame_rules.rule_id
                and ame_rules.rule_id = ame_rule_usages.rule_id
                and ame_rule_usages.item_id = applicationIdIn
                and ((engEffectiveRuleDate between ame_rules.start_date
                        and nvl(ame_rules.end_date - (1/86400), engEffectiveRuleDate)))
                and ((engEffectiveRuleDate between ame_rule_usages.start_date
                        and nvl(ame_rule_usages.end_date - (1/86400), engEffectiveRuleDate)))
                and engEffectiveRuleDate between ame_conditions.start_date
                      and nvl(ame_conditions.end_date - (1/86400), engEffectiveRuleDate)
                and ((engEffectiveRuleDate between ame_condition_usages.start_date
                      and nvl(ame_condition_usages.end_date - (1/86400), engEffectiveRuleDate)))
              union
              select 1
                from ame_mandatory_attributes,
                     ame_actions,
                     ame_action_usages,
                     ame_rules,
                     ame_rule_usages
               where ame_mandatory_attributes.attribute_id = ame_attributes.attribute_id
                 and ame_mandatory_attributes.action_type_id =
                        ame_actions.action_type_id
                 and ame_actions.action_id = ame_action_usages.action_id
                 and ame_action_usages.rule_id = ame_rules.rule_id
                 and ame_rules.rule_id = ame_rule_usages.rule_id
                 and ame_rule_usages.item_id = applicationIdIn
                 and ((engEffectiveRuleDate between ame_rules.start_date
                 and nvl(ame_rules.end_date - (1/86400), engEffectiveRuleDate)))
                 and ((engEffectiveRuleDate between ame_rule_usages.start_date
                 and nvl(ame_rule_usages.end_date - (1/86400), engEffectiveRuleDate)))
                 and engEffectiveRuleDate between ame_mandatory_attributes.start_date
                 and nvl(ame_mandatory_attributes.end_date - (1/86400), engEffectiveRuleDate)
                 and engEffectiveRuleDate between ame_actions.start_date
                 and nvl(ame_actions.end_date - (1/86400), engEffectiveRuleDate)
                 and ((engEffectiveRuleDate between ame_action_usages.start_date
                 and nvl(ame_action_usages.end_date - (1/86400), engEffectiveRuleDate)))
            )
        /*
          The order-by conditions are all necessary.  The second is to break
          item_class_order_number ties in a determinate order.  The third is
          to display attribute names in alphabetical order on the test tab.
          Compare the itemClassUsageCursor cursor in the procedure updateTransactionState.
        */
        order by
          ame_item_class_usages.item_class_order_number,
          ame_item_class_usages.item_class_id,
          ame_attributes.name;
    cursor testTransCurrencyCursor(attributeIdIn in integer) is
      select
        attribute_value_1,
        attribute_value_2,
        attribute_value_3
      from ame_test_trans_att_values
      where
        application_id = engAmeApplicationId and
        transaction_id = engTransactionId and
        attribute_id = attributeIdIn
      order by item_id;
    cursor testTransNonCurrencyCursor(attributeIdIn in integer) is
      select attribute_value_1
      from ame_test_trans_att_values
      where
        application_id = engAmeApplicationId and
        transaction_id = engTransactionId and
        attribute_id = attributeIdIn
      order by item_id;
    cursor testTransVariantHeaderCursor(attributeIdIn in integer) is
      select attribute_value_1
      from ame_test_trans_att_values
      where
        application_id = engAmeApplicationId and
        transaction_id = engTransactionId and
        attribute_id = attributeIdIn and
        item_class_id = getItemClassId(ame_util.headerItemClassName) and
        item_id = engTransactionId;
    attributeCount integer;
    attributeIds ame_util.idList;
    attributeItemClassIds ame_util.idList;
    attributeNames ame_util.stringList;
    attributeTypes ame_util.stringList;
    dynamicCursor integer;
    dynamicQuery ame_util.longestStringType;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    fetchInactives varchar2(1);
    isStatics ame_util.charList;
    queryStrings ame_util.longestStringList;
    rowCountException exception;
    rowsFound integer;
    tempAttributeId integer;
    tempAttributeName ame_attributes.name%type;
    tempAttributeType ame_attributes.attribute_type%type;
    tempAttributeValue1 ame_util.attributeValueType;
    tempAttributeValue2 ame_util.attributeValueType;
    tempAttributeValue3 ame_util.attributeValueType;
    tempAttributeValueIndex integer;
    tempAttributeValues1 dbms_sql.varchar2_table;
    tempAttributeValues2 dbms_sql.varchar2_table;
    tempAttributeValues3 dbms_sql.varchar2_table;
    tempItemClassIndex integer;
    begin
      open attributeCursor(applicationIdIn => engAmeApplicationId);

      fetch attributeCursor bulk collect
        into
          attributeIds,
          attributeNames,
          attributeTypes,
          attributeItemClassIds,
          queryStrings,
          isStatics;
      close attributeCursor;
      /*
        Fetch each attribute's value.  The attributes are in order of their item classes'
        item_class_order_numbers, so we can simply load them into the attribute package
        variables in index order, noting in engAttributeValueIndexes where each attribute's
        values start.
      */
      attributeCount := attributeIds.count;
      /* tempAttributeValueIndex indexes into engAttributeValues1-3.  Pre-increment it. */
      tempAttributeValueIndex := engAttributeValues1.last;--getMaxValueIndex;
      for i in 1 .. attributeCount loop
        tempItemClassIndex := engItemClassIndexes(attributeItemClassIds(i));
        tempAttributeId := attributeIds(i);
        tempAttributeType := attributeTypes(i);
        /* Set the attribute's package variables, even if the attribute's item class has no items. */
        engAttributeIsStatics(tempAttributeId) := isStatics(i);
        engAttributeNames(tempAttributeId) := attributeNames(i);
        engAttributeTypes(tempAttributeId) := attributeTypes(i);
        engAttributeItemClassIds(tempAttributeId) := attributeItemClassIds(i);
        /* Check if the attribute is a variant and set the engAttributeQueries and engAttributeVariant accordingly */
        dynamicQuery := ame_util.removeReturns(stringIn => queryStrings(i),
                                               replaceWithSpaces => true);
        if(checkAttributeVariant(attributeIdIn => tempAttributeId) = ame_util.booleanTrue) then
          if ((isStatics(i) = ame_util.booleanFalse) and
             (instrb(dynamicQuery, ame_util2.itemClassPlaceHolder) > 0 or
              instrb(dynamicQuery, ame_util2.itemIdPlaceHolder) > 0)) then
            engAttributeVariant(tempAttributeId) := ame_util.booleanTrue;
            engAttributeQueries(tempAttributeId) := queryStrings(i);
          end if;
        end if;
        if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
          fnd_log.string
            (fnd_log.level_statement
            ,'ame_engine.fetchOtherAttributeValues'
            ,'Attribute ::: ' || engAttributeNames(tempAttributeId) || '(' || tempAttributeId || ')'
            );
        end if;
        /*
          Set this attribute's values in engAttributeValues1-3, if the attribute's item class
          has any items.
        */
        if(engItemCounts(tempItemClassIndex) = 0) then
          engAttributeValueIndexes(attributeIds(i)) := null;
        else
          /* (tempAttributeValueIndex will be pre-incremented when it's actually used.) */
          engAttributeValueIndexes(attributeIds(i)) := tempAttributeValueIndex + 1;
          if(engIsTestTransaction) then
              tempAttributeValues1.delete;
              tempAttributeValues2.delete;
              tempAttributeValues3.delete;
              if(checkAttributeVariant(tempAttributeId) = ame_util.booleanTrue) then
                open testTransVariantHeaderCursor(attributeIdIn => tempAttributeId);
                fetch testTransVariantHeaderCursor bulk collect
                  into tempAttributeValues1;
                close testTransVariantHeaderCursor;
              else
                if(tempAttributeType = ame_util.currencyAttributeType) then
                  open testTransCurrencyCursor(attributeIdIn => tempAttributeId);
                  fetch testTransCurrencyCursor bulk collect
                    into
                      tempAttributeValues1,
                      tempAttributeValues2,
                      tempAttributeValues3;
                  close testTransCurrencyCursor;
                else
                  open testTransNonCurrencyCursor(attributeIdIn => tempAttributeId);
                  fetch testTransNonCurrencyCursor bulk collect
                    into tempAttributeValues1;
                  close testTransNonCurrencyCursor;
                end if;
              end if;
              for j in 1 .. tempAttributeValues1.count loop
                tempAttributeValueIndex := tempAttributeValueIndex + 1;
                engAttributeValues1(tempAttributeValueIndex) := tempAttributeValues1(j);
                if(tempAttributeType = ame_util.currencyAttributeType) then
                  engAttributeValues2(tempAttributeValueIndex) := tempAttributeValues2(j);
                  engAttributeValues3(tempAttributeValueIndex) := tempAttributeValues3(j);
                else
                  engAttributeValues2(tempAttributeValueIndex) := null;
                  engAttributeValues3(tempAttributeValueIndex) := null;
                end if;
                if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
                  fnd_log.string
                    (fnd_log.level_statement
                    ,'ame_engine.fetchOtherAttributeValues'
                    ,'Attribute Value :' || engAttributeValues1(tempAttributeValueIndex) ||
                     ':' || engAttributeValues2(tempAttributeValueIndex) || ':' || engAttributeValues3(tempAttributeValueIndex) || ':'
                    );
                end if;
              end loop;
              if tempAttributeValues1.count = 0 then
                for j in 1 .. engItemCounts(tempItemClassIndex) loop
                  tempAttributeValueIndex := tempAttributeValueIndex + 1;
                  engAttributeValues1(tempAttributeValueIndex) := null;
                  engAttributeValues2(tempAttributeValueIndex) := null;
                  engAttributeValues3(tempAttributeValueIndex) := null;
                  if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
                    fnd_log.string
                      (fnd_log.level_statement
                      ,'ame_engine.fetchOtherAttributeValues'
                      ,'Attribute Value :' || engAttributeValues1(tempAttributeValueIndex) ||
                       ':' || engAttributeValues2(tempAttributeValueIndex) || ':' || engAttributeValues3(tempAttributeValueIndex) || ':'
                      );
                  end if;
                end loop;
              end if;
          else
            if(isStatics(i) = ame_util.booleanTrue) then
              /*
                Write the static usage into the attribute-value package variables once for each item
                of the attribute's item class.
              */
              if(attributeTypes(i) = ame_util.currencyAttributeType) then
                ame_util.parseStaticCurAttValue(applicationIdIn => engAmeApplicationId,
                                                attributeIdIn => tempAttributeId,
                                                attributeValueIn => queryStrings(i),
                                                localErrorIn => false,
                                                amountOut => tempAttributeValue1,
                                                currencyOut => tempAttributeValue2,
                                                conversionTypeOut => tempAttributeValue3);
              else
                tempAttributeValue1 := queryStrings(i);
                tempAttributeValue2 := null;
                tempAttributeValue3 := null;
              end if;
              for j in 1 .. engItemCounts(tempItemClassIndex) loop
                tempAttributeValueIndex := tempAttributeValueIndex + 1;
                engAttributeValues1(tempAttributeValueIndex) := tempAttributeValue1;
                engAttributeValues2(tempAttributeValueIndex) := tempAttributeValue2;
                engAttributeValues3(tempAttributeValueIndex) := tempAttributeValue3;
                if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
                  fnd_log.string
                    (fnd_log.level_statement
                    ,'ame_engine.fetchOtherAttributeValues'
                    ,'Attribute Value :' || engAttributeValues1(tempAttributeValueIndex) ||
                     ':' || engAttributeValues2(tempAttributeValueIndex) || ':' || engAttributeValues3(tempAttributeValueIndex) || ':'
                    );
                end if;
              end loop;
            else
              tempAttributeValues1.delete;
              tempAttributeValues2.delete;
              tempAttributeValues3.delete;
              /*
                We need to do old-style dynamic PL/SQL here to make sure all occurrences of
                ame_util.transactionIdPlaceholder in dynamicQuery get bound.
              */
              dynamicQuery := ame_util.removeReturns(stringIn => queryStrings(i),
                                                     replaceWithSpaces => true);
              dynamicCursor := dbms_sql.open_cursor;
              dbms_sql.parse(dynamicCursor,
                             dynamicQuery,
                             dbms_sql.native);
              if(instrb(dynamicQuery, ame_util.transactionIdPlaceholder) > 0) then
                dbms_sql.bind_variable(dynamicCursor,
                                       ame_util.transactionIdPlaceholder,
                                       engTransactionId,
                                       50); /* ame_temp_transactions.transaction_id%length doesn't work here. */
              end if;
              if(instrb(dynamicQuery, ame_util2.itemClassPlaceHolder) > 0) then
                dbms_sql.bind_variable(dynamicCursor,
                                       ame_util2.itemClassPlaceHolder,
                                       ame_util.headerItemClassName,
                                       50); /* ame_temp_transactions.transaction_id%length doesn't work here. */
              end if;
              if(instrb(dynamicQuery, ame_util2.itemIdPlaceHolder) > 0) then
                dbms_sql.bind_variable(dynamicCursor,
                                       ame_util2.itemIdPlaceHolder,
                                       engTransactionId,
                                       50); /* ame_temp_transactions.transaction_id%length doesn't work here. */
              end if;
              dbms_sql.define_array(dynamicCursor,
                                    1,
                                    tempAttributeValues1,
                                    ame_util.attributeValueTypeLength,
                                    1);
              if(tempAttributeType = ame_util.currencyAttributeType) then
                dbms_sql.define_array(dynamicCursor,
                                      2,
                                      tempAttributeValues2,
                                      ame_util.attributeValueTypeLength,
                                      1);
                dbms_sql.define_array(dynamicCursor,
                                      3,
                                      tempAttributeValues3,
                                      ame_util.attributeValueTypeLength,
                                      1);
              end if;
              rowsFound := dbms_sql.execute(dynamicCursor);
              loop
                rowsFound := dbms_sql.fetch_rows(dynamicCursor);
                dbms_sql.column_value(dynamicCursor,
                                      1,
                                      tempAttributeValues1);
                if(tempAttributeType = ame_util.currencyAttributeType) then
                  dbms_sql.column_value(dynamicCursor,
                                        2,
                                        tempAttributeValues2);
                  dbms_sql.column_value(dynamicCursor,
                                        3,
                                        tempAttributeValues3);
                end if;
                exit when rowsFound < 100;
              end loop;
              dbms_sql.close_cursor(dynamicCursor);
              /* Make sure the attribute usage returned the right number of rows. */
              if(tempAttributeValues1.count <> engItemCounts(tempItemClassIndex)) then
                raise rowCountException;
              end if;
              /* Transfer the attribute values into the appropriate package variables. */
              for j in 1 .. tempAttributeValues1.count loop
                tempAttributeValueIndex := tempAttributeValueIndex + 1;
                engAttributeValues1(tempAttributeValueIndex) := tempAttributeValues1(j);
                if(tempAttributeType = ame_util.currencyAttributeType) then
                  engAttributeValues2(tempAttributeValueIndex) := tempAttributeValues2(j);
                  engAttributeValues3(tempAttributeValueIndex) := tempAttributeValues3(j);
                else
                  engAttributeValues2(tempAttributeValueIndex) := null;
                  engAttributeValues3(tempAttributeValueIndex) := null;
                end if;
                if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
                  fnd_log.string
                    (fnd_log.level_statement
                    ,'ame_engine.fetchOtherAttributeValues'
                    ,'Attribute Value :' || engAttributeValues1(tempAttributeValueIndex) ||
                     ':' || engAttributeValues2(tempAttributeValueIndex) || ':' || engAttributeValues3(tempAttributeValueIndex) || ':'
                    );
                end if;
              end loop;
            end if;
          end if;
        end if;
      end loop;
      exception
        when rowCountException then
          if(attributeCursor%isopen) then
            close attributeCursor;
          end if;
          if(dbms_sql.is_open(dynamicCursor)) then
            dbms_sql.close_cursor(dynamicCursor);
          end if;
          if(testTransCurrencyCursor%isopen) then
            close testTransCurrencyCursor;
          end if;
          if(testTransNonCurrencyCursor%isopen) then
            close testTransNonCurrencyCursor;
          end if;
          tempAttributeName := ame_attribute_pkg.getName(attributeIdIn => tempAttributeId);
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn =>'PER',
                                messageNameIn   => 'AME_400684_ATR_INV_DYN_USG',
                                tokenNameOneIn  => 'ATTRIBUTE_NAME',
                                tokenValueOneIn => tempAttributeName);
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'fetchOtherAttributeValues',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          if(attributeCursor%isopen) then
            close attributeCursor;
          end if;
          if(dbms_sql.is_open(dynamicCursor)) then
            dbms_sql.close_cursor(dynamicCursor);
          end if;
          if(testTransCurrencyCursor%isopen) then
            close testTransCurrencyCursor;
          end if;
          if(testTransNonCurrencyCursor%isopen) then
            close testTransNonCurrencyCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'fetchOtherAttributeValues',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end fetchOtherAttributeValues;
  procedure fetchConfigVars as
    cursor actionTypeConfigCursor is
      select
        ame_action_type_config.action_type_id,
        ame_action_type_config.voting_regime,
        ame_action_type_config.order_number,
        ame_action_type_config.chain_ordering_mode,
        ame_action_types.name,
        ame_action_types.procedure_name,
        ame_action_type_usages.rule_type
        from
          ame_action_type_config,
          ame_action_types,
          ame_action_type_usages
        where
          ame_action_type_config.application_id = engAmeApplicationId and
          ame_action_types.action_type_id = ame_action_type_config.action_type_id and
          ame_action_type_usages.action_type_id = ame_action_types.action_type_id and
          /*
            Only action types for list-creation and exception rules have two action-type usages;
            all other action types have exactly one (current) action-type usage each.
          */
          ame_action_type_usages.rule_type <> ame_util.exceptionRuleType and
          engEffectiveRuleDate between
            ame_action_type_config.start_date and
            nvl(ame_action_type_config.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
          engEffectiveRuleDate between
            ame_action_types.start_date and
            nvl(ame_action_types.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
          engEffectiveRuleDate between
            ame_action_type_usages.start_date and
            nvl(ame_action_type_usages.end_date - ame_util.oneSecond, engEffectiveRuleDate)
        order by ame_action_types.action_type_id;
    cursor configVarCursor is
      select
        decode(nvl(application_id,0),0,0,-1) application_id,
        /* modified from
           application_id to
           decode(nvl(application_id,0),0,0,-1) application_id
           for the bug 5614208 */
        variable_name,
        variable_value
        from ame_config_vars
        where
          (application_id = 0 or application_id is null or application_id = engAmeApplicationId) and
          /* Config vars can impact the approver list, so use engEffectiveRuleDate here. */
          engEffectiveRuleDate between
            start_date and
            nvl(end_date - ame_util.oneSecond, engEffectiveRuleDate)
        order by
          variable_name,
          application_id;
    appIds ame_util.idList;
    configVarIndex integer;
    variableNames ame_util.stringList;
    variableValues ame_util.longStringList;
    tempActionTypeId integer;
    tempActionTypeIds ame_util.idList;
    tempActionTypeNames ame_util.stringList;
    tempActionTypePackageNames ame_util.stringList;
    tempActionTypeUsages ame_util.idList;
    tempChainOrderingModes ame_util.charList;
    tempOrderNumbers ame_util.idList;
    tempVotingRegimes ame_util.charList;
    begin
      /* Fetch action-type configuration data. */
      open actionTypeConfigCursor;
      fetch actionTypeConfigCursor bulk collect
        into
          tempActionTypeIds,
          tempVotingRegimes,
          tempOrderNumbers,
          tempChainOrderingModes,
          tempActionTypeNames,
          tempActionTypePackageNames,
          tempActionTypeUsages;
      close actionTypeConfigCursor;
      for actionTypeIndex in 1 .. tempActionTypeIds.count loop
        tempActionTypeId := tempActionTypeIds(actionTypeIndex);
        engActionTypeChainOrderModes(tempActionTypeId) := tempChainOrderingModes(actionTypeIndex);
        engActionTypeOrderNumbers(tempActionTypeId) := tempOrderNumbers(actionTypeIndex);
        engActionTypeVotingRegimes(tempActionTypeId) := tempVotingRegimes(actionTypeIndex);
        engActionTypeNames(tempActionTypeId) := tempActionTypeNames(actionTypeIndex);
        engActionTypePackageNames(tempActionTypeId) := tempActionTypePackageNames(actionTypeIndex);
        engActionTypeUsages(tempActionTypeId) := tempActionTypeUsages(actionTypeIndex);
      end loop;
      /* Fetch configuration-variable values. */
      open configVarCursor;
      fetch configVarCursor bulk collect
        into
          appIds,
          variableNames,
          variableValues;
      close configVarCursor;
      /*
        This loop relies on the ordering of configVarCursor, which groups first by
        variable name, then by application ID.  Rows with null application ID follow
        rows with non-null application ID in this ordering, so if a transaction type
        has defined a value for a configuration variable, the loop will reach this
        value before reaching the default value.
      */
      /*
        Always write the first row to the package variables.  (This eliminates a
        comparison that would otherwise be necessary within the loop.)
      */
      engConfigVarNames(1) := variableNames(1);
      engConfigVarValues(1) := variableValues(1);
      configVarIndex := 1; /* pre-increment */
      for i in 2 .. variableValues.count loop
        if(variableNames(i) <> variableNames(i - 1)) then
          configVarIndex := configVarIndex + 1;
          engConfigVarNames(configVarIndex) := variableNames(i);
          engConfigVarValues(configVarIndex) := variableValues(i);
          if(engConfigVarNames(configVarIndex) = ame_util.forwardingConfigVar) then
            parseForwardingBehaviors(forwardingBehaviorsIn => engConfigVarValues(configVarIndex));
          elsif(engConfigVarNames(configVarIndex) = ame_util.rulePriorityModesConfigVar) then
            parsePriorityModes(priorityModesIn => engConfigVarValues(configVarIndex));
          end if;
        end if;
      end loop;
      exception
        when others then
          if(actionTypeConfigCursor%isopen) then
            close actionTypeConfigCursor;
          end if;
          if(configVarCursor%isopen) then
            close configVarCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'fetchConfigVars',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end fetchConfigVars;
  procedure fetchDeletedApprovers as
    cursor deletedApproversCursor(applicationIdIn in integer,
                                  transactionIdIn in varchar2) is
      select
        name,
        item_class,
        item_id,
        approver_category,
        action_type_id,
        group_or_chain_id,
        occurrence,
        effective_date,
        reason
        from ame_temp_deletions
        where
          application_id = applicationIdIn and
          transaction_id = transactionIdIn;
    actionTypeIds ame_util.idList;
    approverCategories ame_util.charList;
    approverNames ame_util.longStringList;
    groupOrChainIds ame_util.idList;
    itemClasses ame_util.stringList;
    itemIds ame_util.stringList;
    occurrences ame_util.idList;
    upperLimit integer;
    tempSuppressionDateList ame_util.dateList;
    tempReasonList ame_util.stringList;
    begin
      open deletedApproversCursor(applicationIdIn => engAmeApplicationId,
                                   transactionIdIn => engTransactionId);
      fetch deletedApproversCursor bulk collect
        into
          approverNames,
          itemClasses,
          itemIds,
          approverCategories,
          actionTypeIds,
          groupOrChainIds,
          occurrences,
          engSuppressionDateList,
          engSupperssionReasonList;
      close deletedApproversCursor;
      upperLimit := actionTypeIds.count;
      for i in 1 .. upperLimit loop
        engDeletedApproverList(i).name := approverNames(i);
        engDeletedApproverList(i).item_class := itemClasses(i);
        engDeletedApproverList(i).item_id := itemIds(i);
        engDeletedApproverList(i).approver_category := approverCategories(i);
        engDeletedApproverList(i).action_type_id := actionTypeIds(i);
        engDeletedApproverList(i).group_or_chain_id := groupOrChainIds(i);
        engDeletedApproverList(i).occurrence := occurrences(i);
      end loop;
      exception
        when others then
          if(deletedApproversCursor%isopen) then
            close deletedApproversCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'fetchDeletedApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end fetchDeletedApprovers;
  procedure fetchInsertedApprovers as
    cursor insertedApproversCursor(applicationIdIn in integer,
                                   transactionIdIn in varchar2) is
      select
        name,
        item_class,
        item_id,
        nvl(approver_category,ame_util.approvalApproverCategory) approver_category,
        api_insertion,
        authority,
        order_type,
        parameter,
        special_forwardee,
        insertion_order,
        effective_date,
        reason,
        approval_status
        from ame_temp_insertions
        where
          application_id = applicationIdIn and
          transaction_id = transactionIdIn
          order by insertion_order;
    approverApiInsertions ame_util.charList;
    approverAuthorities ame_util.charList;
    approverCategories ame_util.charList;
    approverItemClasses ame_util.stringList;
    approverItemIds ame_util.stringList;
    approverNames ame_util.longStringList;
    approvalStatuses ame_util.stringList;
    upperLimit integer;
    begin
      open insertedApproversCursor(applicationIdIn => engAmeApplicationId,
                                   transactionIdIn => engTransactionId);
      fetch insertedApproversCursor bulk collect
        into
          approverNames,
          approverItemClasses,
          approverItemIds,
          approverCategories,
          approverApiInsertions,
          approverAuthorities,
          engInsertionOrderTypeList,
          engInsertionParameterList,
          engInsertionIsSpecialForwardee,
          engInsertionOrderList,
          engInsertionDateList,
          engInsertionReasonList,
          approvalStatuses;
      close insertedApproversCursor;
      upperLimit := approverAuthorities.count;
      for i in 1 .. upperLimit loop
        engInsertedApproverList(i).name := approverNames(i);
        engInsertedApproverList(i).item_class := approverItemClasses(i);
        engInsertedApproverList(i).item_id := approverItemIds(i);
        engInsertedApproverList(i).approver_category := approverCategories(i);
        engInsertedApproverList(i).api_insertion := approverApiInsertions(i);
        engInsertedApproverList(i).authority := approverAuthorities(i);
        engInsertedApproverList(i).approval_status := approvalStatuses(i);
        ame_approver_type_pkg.getApproverOrigSystemAndId(nameIn =>approverNames(i),
                                                         origSystemOut => engInsertedApproverList(i).orig_system,
                                                         origSystemIdOut =>engInsertedApproverList(i).orig_system_id);
      end loop;
      exception
        when others then
          if(insertedApproversCursor%isopen) then
            close insertedApproversCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'fetchInsertedApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end fetchInsertedApprovers;
  procedure fetchItemClassData as
    cursor itemClassUsageCursor(applicationIdIn in integer) is
      select
        ame_item_classes.item_class_id,
        ame_item_classes.name,
        ame_item_class_usages.item_id_query,
        ame_item_class_usages.item_class_order_number,
        ame_item_class_usages.item_class_par_mode,
        ame_item_class_usages.item_class_sublist_mode
        from
          ame_item_classes,
          ame_item_class_usages
        where
          ame_item_classes.item_class_id = ame_item_class_usages.item_class_id and
          ame_item_class_usages.application_id = applicationIdIn and
          engEffectiveRuleDate between
            ame_item_classes.start_date and
            nvl(ame_item_classes.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
          engEffectiveRuleDate between
            ame_item_class_usages.start_date and
            nvl(ame_item_class_usages.end_date - ame_util.oneSecond, engEffectiveRuleDate)
        /*
          The order-by conditions are both critical.  The second is to break
          item_class_order_number ties in a determinate order.  Compare the
          attributeCursor cursor in the procedure fetchAttributeValues.
        */
        order by
          ame_item_class_usages.item_class_order_number,
          ame_item_class_usages.item_class_id;
    cursor testTransItemIdCursor(itemClassIdIn in integer) is
      select distinct item_id
      from ame_test_trans_att_values
      where
        application_id = engAmeApplicationId and
        transaction_id = engTransactionId and
        item_class_id = itemClassIdIn
      order by item_id;
    dynamicCursor integer;
    itemIdQuery ame_util.longestStringType;
    itemIds dbms_sql.varchar2_table;
    lastEngItemIdIndex integer;
    rowsFound integer;
    tempIndex integer;
    tempItemIdQueries ame_util.longestStringList;
    begin
      /* Fetch the item-class usages. */
      open itemClassUsageCursor(applicationIdIn => engAmeApplicationId);
      fetch itemClassUsageCursor bulk collect
        into
          engItemClassIds,
          engItemClassNames,
          tempItemIdQueries,
          engItemClassOrderNumbers,
          engItemClassParModes,
          engItemClassSublistModes;
      close itemClassUsageCursor;
      /* Fetch the item IDs. */
      lastEngItemIdIndex := null;
      for i in 1 .. engItemClassIds.count loop
        engItemClassIndexes(engItemClassIds(i)) := i;
        itemIds.delete;
        /* Fetch the current item class' item IDs into itemIds. */
        if(engItemClassNames(i) = ame_util.headerItemClassName) then
          /*
            The header item class should always have just one item, with the ID
            engTransactionId.  Note that the header item class may not be the
            first item class, as the item classes are ordered by item-class order
            number.  So lastEngItemIdIndex could be null.
          */
          if(lastEngItemIdIndex is null) then
            engItemClassItemIdIndexes(i) := 1;
            lastEngItemIdIndex := 1;
          else
            engItemClassItemIdIndexes(i) := lastEngItemIdIndex + 1;
            lastEngItemIdIndex := lastEngItemIdIndex + 1;
          end if;
          engItemIds(lastEngItemIdIndex) := engTransactionId;
          engItemCounts(i) := 1;
        else /* This item class is not the header item class. */
          if(engIsTestTransaction) then
            open testTransItemIdCursor(itemClassIdIn => engItemClassIds(i));
            fetch testTransItemIdCursor bulk collect into itemIds;
            close testTransItemIdCursor;
            engItemCounts(i) := itemIds.count;
            if(itemIds.count > 0) then
              if(lastEngItemIdIndex is null) then
                engItemClassItemIdIndexes(i) := 1;
                lastEngItemIdIndex := itemIds.count;
              else
                engItemClassItemIdIndexes(i) := lastEngItemIdIndex + 1;
                lastEngItemIdIndex := lastEngItemIdIndex + itemIds.count;
              end if;
              tempIndex := engItemClassItemIdIndexes(i); /* post-increment tempIndex */
              for j in 1 .. itemIds.count loop
                engItemIds(tempIndex) := itemIds(j);
                tempIndex := tempIndex + 1;
              end loop;
            else
              engItemClassItemIdIndexes(i) := null;
            end if;
          else
            itemIdQuery := ame_util.removeReturns(stringIn => tempItemIdQueries(i),
                                                  replaceWithSpaces => true);
            dynamicCursor := dbms_sql.open_cursor;
            dbms_sql.parse(dynamicCursor,
                           itemIdQuery,
                           dbms_sql.native);
            if(instrb(itemIdQuery, ame_util.transactionIdPlaceholder, 1, 1) > 0) then
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util.transactionIdPlaceholder,
                                     engTransactionId,
                                     50); /* ame_temp_transactions.transaction_id%length doesn't work here. */
            end if;
            dbms_sql.define_array(dynamicCursor,
                                  1,
                                  itemIds,
                                  100,
                                  1);
            rowsFound := dbms_sql.execute(dynamicCursor);
            loop
              rowsFound := dbms_sql.fetch_rows(dynamicCursor);
              dbms_sql.column_value(dynamicCursor,
                                    1,
                                    itemIds);
              exit when rowsFound < 100;
            end loop;
            dbms_sql.close_cursor(dynamicCursor);
            /* Copy the item IDs into engItemIds. */
            engItemCounts(i) := itemIds.count;
            if(itemIds.count > 0) then
              if(lastEngItemIdIndex is null) then
                engItemClassItemIdIndexes(i) := 1;
                lastEngItemIdIndex := itemIds.count;
              else
                engItemClassItemIdIndexes(i) := lastEngItemIdIndex + 1;
                lastEngItemIdIndex := lastEngItemIdIndex + itemIds.count;
              end if;
              tempIndex := engItemClassItemIdIndexes(i); /* post-increment tempIndex */
              for j in 1 .. itemIds.count loop
                engItemIds(tempIndex) := itemIds(j);
                tempIndex := tempIndex + 1;
              end loop;
            else
              engItemClassItemIdIndexes(i) := null;
            end if;
          end if;
        end if;
      if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
        fnd_log.string
          (fnd_log.level_statement
                 ,'ame_engine.fetchItemClassData'
                 ,'Item Class ::' || engItemClassNames(i) ||
                  ':' || 'has ' || ':' || engItemCounts(i) || ':items'
           );
      end if;
      end loop;
      exception
        when others then
          if(itemClassUsageCursor%isopen) then
            close itemClassUsageCursor;
          end if;
          if(testTransItemIdCursor%isopen) then
            close testTransItemIdCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'fetchItemClassData',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end fetchItemClassData;
  procedure fetchFndApplicationId(applicationIdIn in integer,
                                  fndApplicationIdOut out nocopy integer,
                                  transactionTypeIdOut out nocopy varchar2) as
    begin
      select
        fnd_application_id,
        transaction_type_id
        into
          fndApplicationIdOut,
          transactionTypeIdOut
        from ame_calling_apps
        where
          application_id = applicationIdIn and
          /* Don't use engEffectiveRuleDate here. */
          sysdate between
            start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) and
          rownum < 2; /* Avoids second fetch otherwise required by ANSI standard to check for too many rows. */
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'fetchFndApplicationId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          fndApplicationIdOut := null;
          transactionTypeIdOut := null;
          raise;
    end fetchFndApplicationId;
  procedure fetchOldApprovers as
    cursor oldApproversCursor(applicationIdIn in integer,
                              transactionIdIn in varchar2) is
      select
        name,
        item_class,
        item_id,
        approver_category,
        api_insertion,
        authority,
        approval_status,
        action_type_id,
        group_or_chain_id,
        occurrence
        from ame_temp_old_approver_lists
        where
          application_id = applicationIdIn and
          transaction_id = transactionIdIn
          order by order_number;
    actionTypeIds ame_util.idList;
    approverApiInsertions ame_util.charList;
    approverAuthorities ame_util.charList;
    approverCategories ame_util.charList;
    approverNames ame_util.longStringList;
    approverStatuses ame_util.stringList;
    groupOrChainIds ame_util.idList;
    itemClasses ame_util.stringList;
    itemIds ame_util.stringList;
    occurrences ame_util.idList;
    upperLimit integer;
    begin
      open oldApproversCursor(applicationIdIn => engAmeApplicationId,
                              transactionIdIn => engTransactionId);
      fetch oldApproversCursor bulk collect
        into
          approverNames,
          itemClasses,
          itemIds,
          approverCategories,
          approverApiInsertions,
          approverAuthorities,
          approverStatuses,
          actionTypeIds,
          groupOrChainIds,
          occurrences;
      close oldApproversCursor;
      upperLimit := approverAuthorities.count;
      for i in 1 .. upperLimit loop
        engOldApproverList(i).name := approverNames(i);
        engOldApproverList(i).item_class := itemClasses(i);
        engOldApproverList(i).item_id := itemIds(i);
        engOldApproverList(i).approver_category := approverCategories(i);
        engOldApproverList(i).api_insertion := approverApiInsertions(i);
        engOldApproverList(i).authority := approverAuthorities(i);
        engOldApproverList(i).action_type_id := actionTypeIds(i);
        engOldApproverList(i).group_or_chain_id := groupOrChainIds(i);
        engOldApproverList(i).occurrence := occurrences(i);
        engOldApproverList(i).source := null;
        /* Force recalculation of suppressed and repeated statuses with each engine cycle. */
        if approverStatuses(i) in (ame_util.suppressedStatus, ame_util.repeatedStatus) then
          engOldApproverList(i).approval_status := null;
        else
          engOldApproverList(i).approval_status := approverStatuses(i);
        end if;
      end loop;
      exception
        when others then
          if(oldApproversCursor%isopen) then
            close oldApproversCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'fetchOldApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end fetchOldApprovers;
  procedure fetchRuntimeGroup(groupIdIn in integer) as
    cursor groupMemberCursor(groupIdIn in integer) is
      select
        orig_system,
        orig_system_id,
        parameter,
        upper(parameter_name),
        query_string,
        order_number,
        decode(parameter_name,
               ame_util.approverOamGroupId, null,
               ame_approver_type_pkg.getWfRolesName(orig_system, orig_system_id)) name,
        decode(parameter_name,
               ame_util.approverOamGroupId, null,
               ame_approver_type_pkg.getApproverDisplayName2(orig_system, orig_system_id)) display_name
        from ame_approval_group_members
        where
          approval_group_id = groupIdIn
        order by order_number;
    badDynamicMemberException exception;
    dynamicCursor integer;
    colonLocation1 integer;
    colonLocation2 integer;
    displayNames ame_util.longStringList;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    names ame_util.longStringList;
    orderNumbers ame_util.idList;
    origSystemIds ame_util.idList;
    origSystems ame_util.stringList;
    outputIndex integer;
    parameters ame_util.longStringList;
    queryStrings ame_util.longestStringList;
    rowsFound integer;
    tempGroupMembers dbms_sql.Varchar2_Table;
    upperParameterNames ame_util.stringList;
    tempApproverType ame_util.stringType;
    tempApproverId   ame_util.stringType;
    tempname         wf_roles.name%type;
    processFndUser boolean;
    begin
      if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
        fnd_log.string
          (fnd_log.level_statement
            ,'ame_engine.fetchRuntimeGroup'
            ,'evaluating the group::'||ame_approval_group_pkg.getName(approvalGroupIdIn => groupIdIn
                                                                      ,effectiveDateIn   => engEffectiveRuleDate)
           );
      end if;
      open groupMemberCursor(groupIdIn => groupIdIn);
      fetch groupMemberCursor bulk collect
        into
          origSystems,
          origSystemIds,
          parameters,
          upperParameterNames,
          queryStrings,
          orderNumbers,
          names,
          displayNames;
      close groupMemberCursor;
      if (engGroupUseItemBind.exists(groupIdIn)) then
        /* This is not the first time this query is being executed, so find and delete all old approvers in this group. */
        for n in 1 .. engGroupMemberGroupIds.count loop
          if( engGroupMemberGroupIds(n) = groupIdIn ) then
            -- delete all occurrences of this
             engGroupMemberGroupIds(n) := null;
             engGroupMemberNames(n) := null;
             engGroupMemberOrderNumbers(n) := null;
             engGroupMemberDisplayNames(n) := null;
             engGroupMemberOrigSystems(n) := null;
             engGroupMemberOrigSystemIds(n) := null;
          end if;
        end loop;
        -- compact list
        outputIndex := engGroupMemberGroupIds.first;
        for i in 1 .. engGroupMemberGroupIds.count loop
          if(i <> outputIndex) then /* (Don't copy a row onto itself.) */
            engGroupMemberGroupIds(i) := engGroupMemberGroupIds(outputIndex);
            engGroupMemberNames(i) := engGroupMemberNames(outputIndex);
            engGroupMemberOrderNumbers(i) := engGroupMemberOrderNumbers(outputIndex);
            engGroupMemberDisplayNames(i) := engGroupMemberDisplayNames(outputIndex);
            engGroupMemberOrigSystems(i) := engGroupMemberOrigSystems(outputIndex);
            engGroupMemberOrigSystemIds(i) := engGroupMemberOrigSystemIds(outputIndex);
          end if;
          outputIndex := engGroupMemberGroupIds.next(outputIndex);
        end loop;
        engGroupMemberGroupIds.delete(outputIndex, engGroupMemberGroupIds.count);
      end if;
      outputIndex := engGroupMemberGroupIds.count; /* pre-increment */
      for i in 1 .. parameters.count loop
        tempGroupMembers.delete; -- for bug 4616570
        if(upperParameterNames(i) = upper(ame_util.approverOamGroupId)) then
          dynamicCursor := dbms_sql.open_cursor;
          dbms_sql.parse(dynamicCursor,
                         ame_util.removeReturns(stringIn => queryStrings(i),
                                                replaceWithSpaces => true),
                         dbms_sql.native);
          engGroupUseItemBind(groupIdIn) := ame_util.booleanFalse;
          if(instrb(queryStrings(i),
                    ame_util.transactionIdPlaceholder) > 0) then
            dbms_sql.bind_variable(dynamicCursor,
                                   ame_util.transactionIdPlaceholder,
                                   engTransactionId,
                                   50);
          end if;
          if(instrb(queryStrings(i),
                    ame_util2.itemClassPlaceHolder) > 0) then
            dbms_sql.bind_variable(dynamicCursor,
                                   ame_util2.itemClassPlaceHolder,
                                   getItemClassName(itemClassIdIn => engAppRuleItemClassIds(engAppHandlerFirstIndex)),
                                   50);
            engGroupUseItemBind(groupIdIn) := ame_util.booleanTrue;
          end if;
          if(instrb(queryStrings(i),
                    ame_util2.itemIdPlaceHolder) > 0) then
            dbms_sql.bind_variable(dynamicCursor,
                                   ame_util2.itemIdPlaceHolder,
                                   engAppAppItemIds(engAppHandlerFirstIndex),
                                   50);
            engGroupUseItemBind(groupIdIn) := ame_util.booleanTrue;
          end if;
          dbms_sql.define_array(dynamicCursor,
                                1,
                                tempGroupMembers,
                                100,
                                1);
          rowsFound := dbms_sql.execute(dynamicCursor);
          loop
            rowsFound := dbms_sql.fetch_rows(dynamicCursor);
            dbms_sql.column_value(dynamicCursor,
                                  1,
                                  tempGroupMembers);
            exit when rowsFound < 100;
          end loop;
          dbms_sql.close_cursor(dynamicCursor);
          /*
            Dynamic groups' query strings may return rows having one of two forms:
              (1) approver_type:approver_id
              (2) orig_system:orig_system_id
          */
          for j in 1 .. tempGroupMembers.count loop
            tempApproverType := null;
            tempApproverId   := null;
            colonLocation1 := instrb(tempGroupMembers(j), ':', 1, 1);
            if(colonLocation1 = 0) then
              raise badDynamicMemberException;
            end if;

            tempApproverId := substrb(tempGroupMembers(j),instrb(tempGroupMembers(j), ':', 1, 1) + 1);
            tempApproverType := substrb(tempGroupMembers(j), 1, (instrb(tempGroupMembers(j), ':', 1, 1) - 1));
            /*following changes added for bpo instance fnd user change*/
            processFndUser := true;
            if ame_multi_tenancy_pkg.is_multi_tenant_system = ame_util.booleanTrue then
              if upper(tempApproverType) = upper(ame_util.approverUserId)
                 or upper(tempApproverType) = upper(ame_util.fndUserOrigSystem) then
                processFndUser := false;
              end if;
            end if;
            if tempApproverId is not null and lengthb(trim(tempApproverId)) > 0
               and tempApproverType is not null and lengthb(trim(tempApproverType)) > 0
               and processFndUser then
              outputIndex := outputIndex + 1;
              engGroupMemberGroupIds(outputIndex) := groupIdIn;
              engGroupMemberOrderNumbers(outputIndex) := j;
              if upper(tempApproverType) = upper(ame_util.approverPersonId) then /* old style */
                engGroupMemberOrigSystems(outputIndex)   := ame_util.perOrigSystem;
                engGroupMemberOrigSystemIds(outputIndex) := tempApproverId;
              elsif upper(tempApproverType) = upper(ame_util.approverUserId) then /* old style */
                engGroupMemberOrigSystems(outputIndex)   := ame_util.fndUserOrigSystem;
                engGroupMemberOrigSystemIds(outputIndex) := tempApproverId;
              else /* 11i10 style */
                begin
                  tempName := ame_approver_type_pkg.getWfRolesName(tempApproverType,tempApproverId);
                exception
                  when others then
                    raise badDynamicMemberException;
                end;
                engGroupMemberOrigSystems(outputIndex)   := tempApproverType;
                engGroupMemberOrigSystemIds(outputIndex) := tempApproverId;
              end if;
              ame_approver_type_pkg.getWfRolesNameAndDisplayName(
                origSystemIn => engGroupMemberOrigSystems(outputIndex),
                origSystemIdIn => engGroupMemberOrigSystemIds(outputIndex),
                nameOut => engGroupMemberNames(outputIndex),
                displayNameOut => engGroupMemberDisplayNames(outputIndex));
            end if;
          end loop;
        else /* Copy the static group into the engGroup caches. */
          outputIndex := outputIndex + 1;
          engGroupUseItemBind(groupIdIn) := ame_util.booleanFalse;
          engGroupMemberGroupIds(outputIndex) := groupIdIn;
          engGroupMemberNames(outputIndex) := names(i);
          engGroupMemberOrderNumbers(outputIndex) := orderNumbers(i);
          engGroupMemberDisplayNames(outputIndex) := displayNames(i);
          engGroupMemberOrigSystems(outputIndex) := origSystems(i);
          engGroupMemberOrigSystemIds(outputIndex) := origSystemIds(i);
        end if;
      end loop;
      if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
        fnd_log.string
          (fnd_log.level_statement
            ,'ame_engine.fetchRuntimeGroup'
            ,'Completed the group evaluation::'||ame_approval_group_pkg.getName(approvalGroupIdIn => groupIdIn
                                                                      ,effectiveDateIn   => engEffectiveRuleDate)
           );
      end if;
      exception
        when badDynamicMemberException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400771_ENG_INVALID_DYN_GRP',
                                              tokenNameOneIn  => 'GROUP_NAME',
                                              tokenValueOneIn => ame_approval_group_pkg.getName(approvalGroupIdIn => groupIdIn
                                                                                               ,effectiveDateIn   => engEffectiveRuleDate));
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'fetchRuntimeGroup',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'fetchRuntimeGroup',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end fetchRuntimeGroup;
  /* This procedure is used to assign calculate min_order and max_order */
  /* of each node in the approver tree                                  */
  /* It also populates the approver_order_number of the engStApprovers  */
  procedure finalizeTree
    (parentIndexIn        in            integer default 1
    ,maximumOrderOut         out nocopy integer
    ,approvalStatusOut       out nocopy integer
    ,rejectedItemsExistOut   out nocopy boolean) is
    currentTreeNodeIndex           integer;
    maximumOrderOfChildren         integer;
    approvalStatusOfChildren       integer;
    previousTreeNodeIndex          integer;
    currentApproverApprovalStatus  varchar2(50);
    currentApproverCategory        varchar2(1);
    currentApproverIndex           integer;
    nextSuspendedItemIndex         integer;
    hasRejectedChildren            boolean;
    currentTreeNodeRejectionStatus boolean;
  begin
    if engStApproversTree.count > 0 then
      approvalStatusOfChildren := ame_util.unknownStatus;
      currentTreeNodeIndex := engStApproversTree(parentIndexIn).child_index;
      if currentTreeNodeIndex = ame_util.noChildIndex then
        /* This is an approver node                                     */
        /* 1. For a approver node the maximum order number is same      */
        /*    as parents minimum order number                           */
        /* 2. The approvalStatus of the node is set based on            */
        /*    approvers approval status                                 */
        /* 3. If the approvers approval status is ame_util.rejectStatus */
        /*    then the approvers item class and item id are populated   */
        /*    into the global list of rejected items                    */
        maximumOrderOut := engStApproversTree(parentIndexIn).min_order;
        currentApproverApprovalStatus :=
          engStApprovers(engStApproversTree(parentIndexIn).approver_index).approval_status;
        currentApproverCategory :=
          engStApprovers(engStApproversTree(parentIndexIn).approver_index).approver_category;
        if currentApproverApprovalStatus is null or
           currentApproverApprovalStatus in (ame_util.repeatedStatus) then
          approvalStatusOut := ame_util.notStartedStatus;
        elsif currentApproverApprovalStatus in (ame_util.approvedStatus
                                               ,ame_util.rejectStatus
                                               ,ame_util.beatByFirstResponderStatus
                                               ,ame_util.approvedByRepeatedStatus
                                               ,ame_util.rejectedByRepeatedStatus
                                               ,ame_util.suppressedStatus
                                               ,ame_util.noResponseStatus
                                               ,ame_util.forwardStatus
                                               ,ame_util.approveAndForwardStatus
                                               ,ame_util2.reassignStatus
                                               ,ame_util2.noResponseByRepeatedStatus
                                               ,ame_util2.forwardByRepeatedStatus) or
             (currentApproverCategory = ame_util.fyiApproverCategory and
              (currentApproverApprovalStatus in (ame_util.notifiedStatus,
                                                 ame_util.notifiedByRepeatedStatus))) then
          approvalStatusOut := ame_util.completedStatus;
        elsif currentApproverApprovalStatus not in (ame_util.approvedStatus
                                                   ,ame_util.rejectStatus
                                                   ,ame_util.beatByFirstResponderStatus
                                                   ,ame_util.approvedByRepeatedStatus
                                                   ,ame_util.rejectedByRepeatedStatus
                                                   ,ame_util.suppressedStatus) then
          approvalStatusOut := ame_util.startedStatus;
        end if;
        if currentApproverApprovalStatus = ame_util.rejectStatus
           or currentApproverApprovalStatus = ame_util.rejectedByRepeatedStatus then
          rejectedItemsExistOut := true;
          /* Populate the list of rejected items and item classes */
          nextSuspendedItemIndex := engStSuspendedItems.count + 1;
          engStSuspendedItems(nextSuspendedItemIndex)
            := engStApprovers(engStApproversTree(parentIndexIn).approver_index).item_id;
          engStSuspendedItemClasses(nextSuspendedItemIndex)
            := engStApprovers(engStApproversTree(parentIndexIn).approver_index).item_class;
        else
          rejectedItemsExistOut := false;
        end if;
      else
        /* This is a non approver node                               */
        /* 1.For a non approver node find the maximum order number   */
        /*   among its children and assign it as the maximum order   */
        /*   number of the parent node                               */
        /* 2.The approvalStatus of the node is determined by finding */
        /*   the aggregate status of all its child nodes             */
        /* 3.The current node is flagged as rejected if any of its   */
        /*   children have a rejectedStatus                          */
        previousTreeNodeIndex := ame_util.invalidTreeIndex;
        currentTreeNodeRejectionStatus := false;
        maximumOrderOfChildren := engStApproversTree(parentIndexIn).min_order;
        loop
          if previousTreeNodeIndex = ame_util.invalidTreeIndex then
            engStApproversTree(currentTreeNodeIndex).min_order
                            := engStApproversTree(parentIndexIn).min_order;
          elsif engStApproversTree(currentTreeNodeIndex).order_number
                   = engStApproversTree(previousTreeNodeIndex).order_number then
            engStApproversTree(currentTreeNodeIndex).min_order
                            := engStApproversTree(previousTreeNodeIndex).min_order;
          else
            engStApproversTree(currentTreeNodeIndex).min_order
                            := maximumOrderOfChildren + 1;
          end if;
          ame_engine.finalizeTree
            (parentIndexIn          => currentTreeNodeIndex
            ,maximumOrderOut        => engStApproversTree(currentTreeNodeIndex).max_order
            ,approvalStatusOut      => engStApproversTree(currentTreeNodeIndex).status
            ,rejectedItemsExistOut  => hasRejectedChildren);
          if hasRejectedChildren then
            currentTreeNodeRejectionStatus := true;
          end if;
          if engStApproversTree(currentTreeNodeIndex).max_order
                                                       > maximumOrderOfChildren then
            maximumOrderOfChildren := engStApproversTree(currentTreeNodeIndex).max_order;
          end if;
          if engStApproversTree(currentTreeNodeIndex).approver_index
                                                       <> ame_util.noApproverIndex then
            currentApproverIndex := engStApproversTree(currentTreeNodeIndex).approver_index;
            engStApprovers(currentApproverIndex).approver_order_number
                         := engStApproversTree(currentTreeNodeIndex).max_order;
          end if;
          if (engStApproversTree(currentTreeNodeIndex).status = ame_util.notStartedStatus
               and approvalStatusOfChildren = ame_util.completedStatus)
            or (engStApproversTree(currentTreeNodeIndex).status = ame_util.completedStatus
               and approvalStatusOfChildren = ame_util.notStartedStatus) then
            approvalStatusOfChildren := ame_util.startedStatus;
          elsif engStApproversTree(currentTreeNodeIndex).status
                           > approvalStatusOfChildren then
            approvalStatusOfChildren := engStApproversTree(currentTreeNodeIndex).status;
          end if;
          previousTreeNodeIndex := currentTreeNodeIndex;
          currentTreeNodeIndex := engStApproversTree(currentTreeNodeIndex).sibling_index;
          exit when currentTreeNodeIndex = ame_util.noSiblingIndex;
        end loop;
        maximumOrderOut := maximumOrderOfChildren;
        /* If the node has supended children and the node is below the item level then */
        /* its status is set to completed as no more approvers are to be fetched from  */
        /* below this node                                                             */
        if currentTreeNodeRejectionStatus and
           engStApproversTree(parentIndexIn).tree_level > 1 then
          approvalStatusOut := ame_util.completedStatus;
        elsif approvalStatusOfChildren = ame_util.unknownStatus then
          approvalStatusOut := ame_util.notStartedStatus;
        else
          approvalStatusOut := approvalStatusOfChildren;
        end if;
        rejectedItemsExistOut := currentTreeNodeRejectionStatus;
      end if;
    end if;
  exception
    when others then
      ame_util.runtimeException(packageNameIn => 'ame_engine',
                                routineNameIn => 'finalizeTree',
                                exceptionNumberIn => sqlcode,
                                exceptionStringIn => sqlerrm);
      raise;
  end finalizeTree;
  /* getAllApprovers is for amem0013.sql backwards compatibility only.  Do not use it elsewhere. */
  procedure getAllApprovers(approversOut out nocopy ame_util.approversTable) as
    begin
      ame_api.getAllApprovers(applicationIdIn => engAmeApplicationId,
                              transactionIdIn => engTransactionId,
                              transactionTypeIn => engTransactionTypeId,
                              approversOut => approversOut);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getAllApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getAllApprovers;
  procedure getApplicableRules
    (ruleIdsOut             out nocopy ame_util.idList
    ,ruleDescriptionsOut    out nocopy ame_util.stringList) as
    nextRuleIndex  integer;
    ruleFound      boolean;
    begin
      nextRuleIndex := 1;
      for i in 1 .. engAppRuleIds.count loop
        if engRuleAppliedYN(i) = ame_util.booleanTrue then
          if nextRuleIndex = 1 then
            ruleFound := false;
          else
            ruleFound := false;
            for j in 1 .. (nextRuleIndex - 1) loop
              if ruleIdsOut(j) = engAppRuleIds(i) then
                ruleFound := true;
                exit;
              end if;
            end loop;
          end if;
          if not ruleFound then
            ruleIdsOut(nextRuleIndex) := engAppRuleIds(i);
            ruleDescriptionsOut(nextRuleIndex) := ame_rule_pkg.getDescription(ruleIdIn => engAppRuleIds(i),
                                                                              processingDateIn => engEffectiveRuleDate);
            nextRuleIndex := nextRuleIndex + 1;
          end if;
        end if;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getApplicableRules',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getApplicableRules;
  /* BUG: 4491715 sort approver categories and sources along with group ids */
  procedure getApprovalGroupConfigs(groupIdsInOut in out nocopy ame_util.idList,
                                    sourcesInOut in out nocopy ame_util.longStringList,
                                    approverCategoriesInOut in out nocopy ame_util.charList,
                                    orderNumbersOut out nocopy ame_util.idList,
                                    votingRegimesOut out nocopy ame_util.charList) as
    cursor approvalGroupConfigCursor(groupIdIn in integer) is
      select
        order_number,
        voting_regime
        from ame_approval_group_config
        where
          application_id = engAmeApplicationId and
          approval_group_id = groupIdIn and
        engEffectiveRuleDate between
          start_date and
          nvl(end_date - ame_util.oneSecond, engEffectiveRuleDate);
    tempGroupId integer;
    tempOrderNumber integer;
    tempVotingRegime ame_util.charType;
    tempSource ame_util.longStringType;
    tempApproverCategory ame_util.charType;
    upperLimit integer;
    begin
      /*
        Evidently it's more efficient to fetch this way, than to do a single bulk fetch
        with a comma-delimited list of group IDs.
      */
      for i in 1 .. groupIdsInOut.count loop
        open approvalGroupConfigCursor(groupIdIn => groupIdsInOut(i));
        fetch approvalGroupConfigCursor
          into
            orderNumbersOut(i),
            votingRegimesOut(i);
        close approvalGroupConfigCursor;
      end loop;
      /* Sort in place, first by group order number, then by group ID. */
      for i in 2 .. groupIdsInOut.count loop
        upperLimit := i - 1;
        for j in 1 .. upperLimit loop
          if(orderNumbersOut(i) < orderNumbersOut(j) or
             (orderNumbersOut(i) = orderNumbersOut(j) and
              groupIdsInOut(i) < groupIdsInOut(j))) then
            /* j into temps */
            tempGroupId := groupIdsInOut(j);
            tempOrderNumber := orderNumbersOut(j);
            tempVotingRegime := votingRegimesOut(j);
            tempSource := sourcesInOut(j);
            tempApproverCategory := approverCategoriesInOut(j);
            /* i into j */
            groupIdsInOut(j) := groupIdsInOut(i);
            orderNumbersOut(j) := orderNumbersOut(i);
            votingRegimesOut(j) := votingRegimesOut(i);
            sourcesInOut(j) := sourcesInOut(i);
            approverCategoriesInOut(j) := approverCategoriesInOut(i);
            /* temps into i */
            groupIdsInOut(i) := tempGroupId;
            orderNumbersOut(i) := tempOrderNumber;
            votingRegimesOut(i) := tempVotingRegime;
            sourcesInOut(i) := tempSource;
            approverCategoriesInOut(i) := tempApproverCategory;
          end if;
        end loop;
      end loop;
      exception
        when others then
          if(approvalGroupConfigCursor%isopen) then
            close approvalGroupConfigCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getApprovalGroupConfigs',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getApprovalGroupConfigs;
  procedure getApprovers(approversOut out nocopy ame_util.approversTable2) as
    begin
      if (not engItemDataPrepared) and engPrepareItemData then
        prepareItemData(itemIndexesOut     => engStItemIndexes
                       ,itemItemClassesOut => engStItemClasses
                       ,itemIdsOut         => engStItemIds
                       ,itemSourcesOut     => engStItemSources);
        engItemDataPrepared := true;
      end if;
      prepareRuleData;
      preparePerApproverProductions
           (prodIndexesOut      => engStProductionIndexes
           ,productionNamesOut  => engStVariableNames
           ,productionValuesOut => engStVariableValues);
      for i in 1 .. engStApprovers.count loop
        approversOut(i).name := engStApprovers(i).name;
        approversOut(i).orig_system := engStApprovers(i).orig_system;
        approversOut(i).orig_system_id := engStApprovers(i).orig_system_id;
        approversOut(i).display_name := engStApprovers(i).display_name;
        approversOut(i).approver_category := engStApprovers(i).approver_category;
        approversOut(i).api_insertion := engStApprovers(i).api_insertion;
        approversOut(i).authority := engStApprovers(i).authority;
        approversOut(i).approval_status := engStApprovers(i).approval_status;
        approversOut(i).action_type_id := engStApprovers(i).action_type_id;
        approversOut(i).group_or_chain_id := engStApprovers(i).group_or_chain_id;
        approversOut(i).occurrence := engStApprovers(i).occurrence;
        approversOut(i).source := engStApprovers(i).source;
        approversOut(i).item_class := engStApprovers(i).item_class;
        approversOut(i).item_id := engStApprovers(i).item_id;
        approversOut(i).item_class_order_number := engStApprovers(i).item_class_order_number;
        approversOut(i).item_order_number := engStApprovers(i).item_order_number;
        approversOut(i).sub_list_order_number := engStApprovers(i).sub_list_order_number;
        approversOut(i).action_type_order_number := engStApprovers(i).action_type_order_number;
        approversOut(i).group_or_chain_order_number := engStApprovers(i).group_or_chain_order_number;
        approversOut(i).member_order_number := engStApprovers(i).member_order_number;
        approversOut(i).approver_order_number := engStApprovers(i).approver_order_number;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getApprovers;
  /* This procedure returns the approvers as well as approvers tree to the calling APIs */
  procedure getApprovers2(approversOut out nocopy ame_util.approversTable2
                         ,approversTreeOut out nocopy ame_util.approversTreeTable) as
    loopIndex integer;
    begin
      for i in 1 .. engStApprovers.count loop
        approversOut(i).name := engStApprovers(i).name;
        approversOut(i).orig_system := engStApprovers(i).orig_system;
        approversOut(i).orig_system_id := engStApprovers(i).orig_system_id;
        approversOut(i).display_name := engStApprovers(i).display_name;
        approversOut(i).approver_category := engStApprovers(i).approver_category;
        approversOut(i).api_insertion := engStApprovers(i).api_insertion;
        approversOut(i).authority := engStApprovers(i).authority;
        approversOut(i).approval_status := engStApprovers(i).approval_status;
        approversOut(i).action_type_id := engStApprovers(i).action_type_id;
        approversOut(i).group_or_chain_id := engStApprovers(i).group_or_chain_id;
        approversOut(i).occurrence := engStApprovers(i).occurrence;
        approversOut(i).source := engStApprovers(i).source;
        approversOut(i).item_class := engStApprovers(i).item_class;
        approversOut(i).item_id := engStApprovers(i).item_id;
        approversOut(i).item_class_order_number := engStApprovers(i).item_class_order_number;
        approversOut(i).item_order_number := engStApprovers(i).item_order_number;
        approversOut(i).sub_list_order_number := engStApprovers(i).sub_list_order_number;
        approversOut(i).action_type_order_number := engStApprovers(i).action_type_order_number;
        approversOut(i).group_or_chain_order_number := engStApprovers(i).group_or_chain_order_number;
        approversOut(i).member_order_number := engStApprovers(i).member_order_number;
        approversOut(i).approver_order_number := engStApprovers(i).approver_order_number;
      end loop;
      if engStApproversTree.count > 0 then
        /* Approvers Tree is sparse */
        loopIndex := engStApproversTree.first;
        loop
          approversTreeOut(loopIndex).parent_index   := engStApproversTree(loopIndex).parent_index;
          approversTreeOut(loopIndex).child_index    := engStApproversTree(loopIndex).child_index;
          approversTreeOut(loopIndex).sibling_index  := engStApproversTree(loopIndex).sibling_index;
          approversTreeOut(loopIndex).approver_index := engStApproversTree(loopIndex).approver_index;
          approversTreeOut(loopIndex).tree_level     := engStApproversTree(loopIndex).tree_level;
          approversTreeOut(loopIndex).tree_level_id  := engStApproversTree(loopIndex).tree_level_id;
          approversTreeOut(loopIndex).order_number   := engStApproversTree(loopIndex).order_number;
          approversTreeOut(loopIndex).min_order      := engStApproversTree(loopIndex).min_order;
          approversTreeOut(loopIndex).max_order      := engStApproversTree(loopIndex).max_order;
          approversTreeOut(loopIndex).status         := engStApproversTree(loopIndex).status;
          approversTreeOut(loopIndex).is_suspended   := engStApproversTree(loopIndex).is_suspended;
          exit when loopIndex = engStApproversTree.last;
          loopIndex := engStApproversTree.next(loopIndex);
        end loop;
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getApprovers2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getApprovers2;
  procedure getHandlerCOAFirstApprover(itemClassIn in varchar2,
                                       itemIdIn in varchar2,
                                       actionTypeIdIn in integer,
                                       groupOrChainIdIn in integer,
                                       nameOut out nocopy varchar2,
                                       origSystemOut out nocopy varchar2,
                                       origSystemIdOut out nocopy integer,
                                       displayNameOut out nocopy varchar2,
                                       sourceOut out nocopy varchar2) as
    parameter ame_temp_insertions.parameter%type;
    begin
      parameter := ame_util.firstAuthorityParameter ||
                   ame_util.fieldDelimiter ||
                   itemClassIn ||
                   ame_util.fieldDelimiter ||
                   itemIdIn ||
                   ame_util.fieldDelimiter ||
                   actionTypeIdIn ||
                   ame_util.fieldDelimiter ||
                   groupOrChainIdIn;
      for i in 1 .. engInsertedApproverList.count loop
        if(engInsertionParameterList(i) = parameter) then
          nameOut := engInsertedApproverList(i).name;
          ame_approver_type_pkg.getOrigSystemIdAndDisplayName(nameIn => engInsertedApproverList(i).name,
                                                              origSystemOut => origSystemOut,
                                                              origSystemIdOut => origSystemIdOut,
                                                              displayNameOut => displayNameOut);
          sourceOut := ame_util.otherInsertion;
          setDeviationReasonDate(engInsertionReasonList(i),engInsertionDateList(i));
          return;
        end if;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerCOAFirstApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getHandlerCOAFirstApprover;
  procedure getHandlerCOAInsertion(nameIn in varchar2,
                                   itemClassIn in varchar2,
                                   itemIdIn in varchar2,
                                   actionTypeIdIn in integer,
                                   groupOrChainIdIn in integer,
                                   occurrenceIn in integer,
                                   approvalStatusIn in varchar2,
                                   nameOut out nocopy varchar2,
                                   origSystemOut out nocopy varchar2,
                                   origSystemIdOut out nocopy integer,
                                   displayNameOut out nocopy varchar2,
                                   sourceOut out nocopy varchar2) as
    parameter ame_temp_insertions.parameter%type;
    begin
      parameter := nameIn ||
                   ame_util.fieldDelimiter ||
                   itemClassIn ||
                   ame_util.fieldDelimiter ||
                   itemIdIn ||
                   ame_util.fieldDelimiter ||
                   actionTypeIdIn ||
                   ame_util.fieldDelimiter ||
                   groupOrChainIdIn ||
                   ame_util.fieldDelimiter ||
                   occurrenceIn;
      for i in 1 .. engInsertedApproverList.count loop
        if(engInsertedApproverList(i).api_insertion = ame_util.apiAuthorityInsertion and
           engInsertionOrderTypeList(i) = ame_util.afterApprover and
           engInsertionParameterList(i) = parameter) then
          nameOut := engInsertedApproverList(i).name;
          ame_approver_type_pkg.getOrigSystemIdAndDisplayName(nameIn => engInsertedApproverList(i).name,
                                                              origSystemOut => origSystemOut,
                                                              origSystemIdOut => origSystemIdOut,
                                                              displayNameOut => displayNameOut);
          if(engInsertionIsSpecialForwardee(i) = ame_util.booleanTrue) then
            sourceOut := ame_util.specialForwardInsertion;
          elsif(approvalStatusIn = ame_util.forwardStatus) then
            sourceOut := ame_util.forwardInsertion;
          elsif(approvalStatusIn = ame_util.approveAndForwardStatus) then
            sourceOut := ame_util.approveAndForwardInsertion;
          else
            sourceOut := ame_util.otherInsertion;
          end if;
          setDeviationReasonDate(engInsertionReasonList(i),engInsertionDateList(i));
          return;
        end if;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerCOAInsertion',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getHandlerCOAInsertion;
  procedure getHandlerRules(ruleIdsOut out nocopy ame_util.idList,
                            approverCategoriesOut out nocopy ame_util.charList,
                            parametersOut out nocopy ame_util.stringList,
                            parameterTwosOut out nocopy ame_util.stringList) as
    outputIndex integer;
    begin
      outputIndex := 0;
      for i in engAppHandlerFirstIndex .. engAppHandlerLastIndex loop
        outputIndex := outputIndex + 1;
        ruleIdsOut(outputIndex) := engAppRuleIds(i);
        approverCategoriesOut(outputIndex) := engAppApproverCategories(i);
        parametersOut(outputIndex) := engAppParameters(i);
        parameterTwosOut(outputIndex) := engAppParameterTwos(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerRules',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getHandlerRules;
  procedure getHandlerRules2(ruleIdsOut out nocopy ame_util.idList,
                             approverCategoriesOut out nocopy ame_util.charList,
                             parametersOut out nocopy ame_util.stringList) as
    outputIndex integer;
    begin
      outputIndex := 0;
      for i in engAppHandlerFirstIndex .. engAppHandlerLastIndex loop
        outputIndex := outputIndex + 1;
        ruleIdsOut(outputIndex) := engAppRuleIds(i);
        approverCategoriesOut(outputIndex) := engAppApproverCategories(i);
        parametersOut(outputIndex) := engAppParameters(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerRules2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getHandlerRules2;
  procedure getHandlerRules3(ruleIdsOut out nocopy ame_util.idList,
                             ruleIndexesOut out nocopy ame_util.idList,
                             parametersOut out nocopy ame_util.stringList,
                             listModParameterOnesOut out nocopy ame_util.stringList,
                             listModParameterTwosOut out nocopy ame_util.longStringList) as
    outputIndex integer;
    begin
      outputIndex := 0;
      for i in engAppHandlerFirstIndex .. engAppHandlerLastIndex loop
        outputIndex := outputIndex + 1;
        ruleIdsOut(outputIndex) := engAppRuleIds(i);
        ruleIndexesOut(outputIndex) := i;
        parametersOut(outputIndex) := engAppParameters(i);
        getLMCondition(ruleIdIn => engAppRuleIds(i),
                       parameterOneOut => listModParameterOnesOut(outputIndex),
                       parameterTwoOut => listModParameterTwosOut(outputIndex));
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerRules3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getHandlerRules3;
  procedure getHandlerLMApprovers(listModParameterOneIn in varchar2,
                                  listModParameterTwoIn in varchar2,
                                  includeFyiApproversIn in boolean,
                                  includeApprovalGroupsIn in boolean,
                                  returnForwardeesIn in boolean,
                                  approverIndexesOut out nocopy ame_util.idList,
                                  lastForwardeeIndexesOut out nocopy ame_util.idList) as
    currentActionTypeId integer;
    currentGroupOrChainId integer;
    currentIndex integer;
    currentTargetIndex integer;
    engStApproversCount integer;
    outputIndex integer;
    begin
      engStApproversCount := engStApprovers.count;
      if(engStApproversCount = 0) then
        return;
      end if;
      outputIndex := 0; /* pre-increment */
      currentIndex := 1; /* post-increment */
      loop
        if((engStApprovers(currentIndex).approver_category = ame_util.approvalApproverCategory or
            includeFyiApproversIn) and
           (engStApprovers(currentIndex).authority = ame_util.authorityApprover or
            includeApprovalGroupsIn) and
           listModParameterTwoIn = engStApprovers(currentIndex).name) then
          /* This approver matches the input approver, and satisfies the input boolean arguments. */
          currentTargetIndex := currentIndex;
          currentGroupOrChainId := engStApprovers(currentTargetIndex).group_or_chain_id;
          currentActionTypeId := engStApprovers(currentTargetIndex).action_type_id;
          if(returnForwardeesIn) then
            /*
              Set currentIndex to the index of the last of any subsequent forwardees.  Start the loop
              at the target to check whether the target forwards.  (Note that we necessarily stay
              in the same approval group or chain of authority as long as we're forwarding.)
            */
            for i in currentTargetIndex .. engStApproversCount loop
              if(engStApprovers(currentIndex).approval_status in (ame_util.forwardStatus,
                                                                  ame_util.approveAndForwardStatus)) then
                currentIndex := i;
              else
                exit;
              end if;
            end loop;
          end if;
          /*
            Now increment currentIndex to point to the approver after the target, or after the target's
            forwarding chain if necessary.  (This may point past the end of the list; check for that.)
            This also serves to increment currentIndex for the outer loop.
          */
          currentIndex := currentIndex + 1;
          /*
            If the target approver satisfies listModParameterOneIn, output the target approver and
            optionally the last forwardee.
          */
          /*
            All but the first of the conditions in the following if statement
            are for the ame_util.finalApprover case.
          */
          if(listModParameterOneIn = ame_util.anyApprover or
             currentIndex > engStApproversCount or
             engStApprovers(currentIndex).group_or_chain_id <> currentGroupOrChainId or
             engStApprovers(currentIndex).action_type_id <> currentActionTypeId or
             engStApprovers(currentIndex).item_id <> engStApprovers(currentTargetIndex).item_id or
             engStApprovers(currentIndex).item_class <> engStApprovers(currentTargetIndex).item_class) then
            /* Output the approver(s). */
            outputIndex := outputIndex + 1;
            approverIndexesOut(outputIndex) := currentTargetIndex;
            if(returnForwardeesIn) then
              lastForwardeeIndexesOut(outputIndex) := currentIndex - 1;
            end if;
          end if;
        else /* Just iterate. */
          currentIndex := currentIndex + 1;
        end if;
        /* Exit the loop upon reaching the end of engStApprovers. */
        if(currentIndex > engStApproversCount) then
          exit;
        end if;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHandlerLMApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getHandlerLMApprovers;
  procedure getHeaderAttValues1(attributeIdIn in integer,
                                attributeValue1Out out nocopy varchar2,
                                attributeValue2Out out nocopy varchar2,
                                attributeValue3Out out nocopy varchar2) as
    attributeValueIndex integer;
    begin
      attributeValueIndex := engAttributeValueIndexes(attributeIdIn);
      attributeValue1Out := engAttributeValues1(attributeValueIndex);
      attributeValue2Out := engAttributeValues2(attributeValueIndex);
      attributeValue3Out := engAttributeValues3(attributeValueIndex);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHeaderAttValues1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getHeaderAttValues1;
  procedure getHeaderAttValues2(attributeNameIn in varchar2,
                                attributeValue1Out out nocopy varchar2,
                                attributeValue2Out out nocopy varchar2,
                                attributeValue3Out out nocopy varchar2) as
    attributeValueIndex integer;
    begin
      if (engAttributeVariant.exists(getAttributeIdByName(attributeNameIn => attributeNameIn))) then
        /* fetch the new attribute value */
        attributeValue1Out := getVariantAttributeValue(attributeIdIn => getAttributeIdByName(attributeNameIn => attributeNameIn),
                                    itemClassIn => getItemClassName(itemClassIdIn => engAppRuleItemClassIds(engAppHandlerFirstIndex)),
                                    itemIdIn => engAppAppItemIds(engAppHandlerFirstIndex) );
        attributeValue2Out := null;
        attributeValue3Out := null;
      else
        attributeValueIndex := engAttributeValueIndexes(getAttributeIdByName(attributeNameIn => attributeNameIn));
        attributeValue1Out := engAttributeValues1(attributeValueIndex);
        attributeValue2Out := engAttributeValues2(attributeValueIndex);
        attributeValue3Out := engAttributeValues3(attributeValueIndex);
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getHeaderAttValues2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getHeaderAttValues2;
  procedure getItemAppProcessCompleteYN(itemAppProcessCompleteYNOut out nocopy ame_util.charList) as
    begin
      for i in 1 .. engStItemAppProcessCompleteYN.count loop
        itemAppProcessCompleteYNOut(i) := engStItemAppProcessCompleteYN(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemAppProcessCompleteYN',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getItemAppProcessCompleteYN;
  procedure getItemAttValues1(attributeIdIn in integer,
                              itemIdIn in varchar2,
                              attributeValue1Out out nocopy varchar2,
                              attributeValue2Out out nocopy varchar2,
                              attributeValue3Out out nocopy varchar2) as
    attributeValueIndex integer;
    begin
      attributeValueIndex :=
        engAttributeValueIndexes(attributeIdIn) +
        getItemOffset(itemClassIdIn => engAttributeItemClassIds(attributeIdIn),
                      itemIdIn => itemIdIn);
      attributeValue1Out := engAttributeValues1(attributeValueIndex);
      attributeValue2Out := engAttributeValues2(attributeValueIndex);
      attributeValue3Out := engAttributeValues3(attributeValueIndex);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemAttValues1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getItemAttValues1;
  procedure getItemAttValues2(attributeNameIn in varchar2,
                              itemIdIn in varchar2,
                              attributeValue1Out out nocopy varchar2,
                              attributeValue2Out out nocopy varchar2,
                              attributeValue3Out out nocopy varchar2) as
    attributeId integer;
    attributeValueIndex integer;
    begin
      attributeId := getAttributeIdByName(attributeNameIn => attributeNameIn);
      attributeValueIndex :=
        engAttributeValueIndexes(attributeId) +
        getItemOffset(itemClassIdIn => engAttributeItemClassIds(attributeId),
                      itemIdIn => itemIdIn);
      attributeValue1Out := engAttributeValues1(attributeValueIndex);
      attributeValue2Out := engAttributeValues2(attributeValueIndex);
      attributeValue3Out := engAttributeValues3(attributeValueIndex);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemAttValues2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getItemAttValues2;
  procedure getItemAttValues3(attributeIdIn in integer,
                              itemIndexIn in varchar2,
                              attributeValue1Out out nocopy varchar2,
                              attributeValue2Out out nocopy varchar2,
                              attributeValue3Out out nocopy varchar2) as
    attributeValueIndex integer;
    begin
      attributeValueIndex :=
        engAttributeValueIndexes(attributeIdIn) +
        itemIndexIn -
        engItemClassItemIdIndexes(engItemClassIndexes(engAttributeItemClassIds(attributeIdIn)));
      attributeValue1Out := engAttributeValues1(attributeValueIndex);
      attributeValue2Out := engAttributeValues2(attributeValueIndex);
      attributeValue3Out := engAttributeValues3(attributeValueIndex);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemAttValues3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getItemAttValues3;
  procedure getItemClassAttValues1(attributeIdIn in integer,
                                   attributeValuesOut out nocopy ame_util.attributeValueList) as
    outputIndex integer;
    begin
      outputIndex := 0; /* pre-increment */
      for i in
        engAttributeValueIndexes(attributeIdIn) ..
        (engAttributeValueIndexes(attributeIdIn) +
         engItemCounts(engItemClassIndexes(engAttributeItemClassIds(attributeIdIn))) -
         1) loop
        outputIndex := outputIndex + 1;
        attributeValuesOut(outputIndex) := engAttributeValues1(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemClassAttValues1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getItemClassAttValues1;
  procedure getItemClassAttValues2(attributeNameIn in varchar2,
                                   attributeValuesOut out nocopy ame_util.attributeValueList) as
    attributeId integer;
    outputIndex integer;
    begin
      attributeId := getAttributeIdByName(attributeNameIn => attributeNameIn);
      outputIndex := 0; /* pre-increment */
      for i in
        engAttributeValueIndexes(attributeId) ..
        (engAttributeValueIndexes(attributeId) +
         engItemCounts(engItemClassIndexes(engAttributeItemClassIds(attributeId))) -
         1) loop
        outputIndex := outputIndex + 1;
        attributeValuesOut(outputIndex) := engAttributeValues1(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemClassAttValues2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getItemClassAttValues2;
  procedure getItemClassAttValues3(attributeIdIn in integer,
                                   attributeValues1Out out nocopy ame_util.attributeValueList,
                                   attributeValues2Out out nocopy ame_util.attributeValueList,
                                   attributeValues3Out out nocopy ame_util.attributeValueList) as
    outputIndex integer;
    begin
      outputIndex := 0; /* pre-increment */
      for i in
        engAttributeValueIndexes(attributeIdIn) ..
        (engAttributeValueIndexes(attributeIdIn) +
         engItemCounts(engItemClassIndexes(engAttributeItemClassIds(attributeIdIn))) -
         1) loop
        outputIndex := outputIndex + 1;
        attributeValues1Out(outputIndex) := engAttributeValues1(i);
        attributeValues2Out(outputIndex) := engAttributeValues2(i);
        attributeValues3Out(outputIndex) := engAttributeValues3(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemClassAttValues3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getItemClassAttValues3;
  procedure getItemClassAttValues4(attributeNameIn in varchar2,
                                   attributeValues1Out out nocopy ame_util.attributeValueList,
                                   attributeValues2Out out nocopy ame_util.attributeValueList,
                                   attributeValues3Out out nocopy ame_util.attributeValueList) as
    attributeId integer;
    outputIndex integer;
    begin
      attributeId := getAttributeIdByName(attributeNameIn => attributeNameIn);
      outputIndex := 0; /* pre-increment */
      for i in
        engAttributeValueIndexes(attributeId) ..
        (engAttributeValueIndexes(attributeId) +
         engItemCounts(engItemClassIndexes(engAttributeItemClassIds(attributeId))) -
         1) loop
        outputIndex := outputIndex + 1;
        attributeValues1Out(outputIndex) := engAttributeValues1(i);
        attributeValues2Out(outputIndex) := engAttributeValues2(i);
        attributeValues3Out(outputIndex) := engAttributeValues3(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemClassAttValues4',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getItemClassAttValues4;
  procedure getItemClassItemIds(itemClassIdIn in integer,
                                itemIdsOut out nocopy ame_util.stringList) as
    firstItemIndex integer;
    itemClassIndex integer;
    tempIndex integer;
    begin
      itemClassIndex := engItemClassIndexes(itemClassIdIn);
      firstItemIndex := engItemClassItemIdIndexes(itemClassIndex);
      if(firstItemIndex is not null) then
        tempIndex := 0; /* pre-increment */
        for itemIndex in
          firstItemIndex ..
          (firstItemIndex + engItemCounts(itemClassIndex) - 1) loop
          tempIndex := tempIndex + 1;
          itemIdsOut(tempIndex) := engItemIds(itemIndex);
        end loop;
      end if;
      exception
        when others then
          itemIdsOut.delete;
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemClassItemIds',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getItemClassItemIds;
  procedure getItemClasses(itemClassesOut out nocopy ame_util.stringList) as
    begin
      for i in 1 .. engStItemClasses.count loop
        itemClassesOut(i) := engStItemClasses(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemClasses',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getItemClasses;
  procedure getItemIds(itemIdsOut out nocopy ame_util.stringList) as
    begin
      for i in 1 .. engStItemIds.count loop
        itemIdsOut(i) := engStItemIds(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemIds',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getItemIds;
  procedure getItemIndexes(itemIndexesOut out nocopy ame_util.idList) as
    begin
      for i in 1 .. engStItemIndexes.count loop
        itemIndexesOut(i) := engStItemIndexes(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemIndexes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getItemIndexes;
  procedure getItemSources(itemSourcesOut out nocopy ame_util.longStringList) as
    begin
      for i in 1 .. engStItemSources.count loop
        itemSourcesOut(i) := engStItemSources(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getItemSources',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getItemSources;
  procedure getAllItemClasses(itemClassNamesOut out nocopy ame_util.stringList) as
    tempIndex integer;
    tempCount integer;
    begin
      tempIndex := 0;
      tempCount := 0;
      for i in 1 .. engItemClassIds.count loop
        tempCount := engItemCounts(engItemClassIndexes(engItemClassIds(i)));
        tempIndex := itemClassNamesOut.count;
        for x in 1 .. tempCount loop
          itemClassNamesOut(tempIndex + x) := engItemClassNames(i);
        end loop;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getAllItemClasses',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getAllItemClasses;
  procedure getAllItemIds(itemIdsOut out nocopy ame_util.stringList) as
    begin
      for i in 1 .. engItemIds.count loop
        itemIdsOut(i) := engItemIds(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getAllItemIds',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getAllItemIds;
  procedure getInsertions
    (positionIn             in            number
    ,orderTypeIn            in            varchar2 default null
    ,coaInsertionsYNIn      in            varchar2 default ame_util.booleanTrue
    ,availableInsertionsOut    out nocopy ame_util.insertionsTable2
    ) as

    engStApproversCount         integer;
    availableInsertionsIndex    integer; /* pre-increment */
    errorCode                   integer;
    errorMessage                ame_util.longestStringType;
    invalidPositionException    exception;
    nextApproverDescription     ame_temp_insertions.description%type;
    prevApproverDescription     ame_temp_insertions.description%type;
    ruleIdList                  ame_util.idList;
    sourceDescription           ame_util.stringType;
    tempBoolean                 boolean;
    tempInsertionDoesNotExist   boolean;
    tempParameter               ame_temp_insertions.parameter%type;
  begin

    engStApproversCount := engStApprovers.count;

    if(positionIn < 1 or
       positionIn > engStApproversCount + 1 or
       not ame_util.isANonNegativeInteger(stringIn => positionIn)) then
      raise invalidPositionException;
    end if;

    availableInsertionsIndex := 0;

    if (orderTypeIn is null or
        orderTypeIn = ame_util.absoluteOrder) then

      tempParameter := positionIn;
      if (engStApproversCount = 0) then

        /* pre-approver */
        if (not ame_engine.insertionExists
                  (orderTypeIn   => ame_util.absoluteOrder
                  ,parameterIn   => tempParameter
                  )) then
          availableInsertionsIndex := availableInsertionsIndex + 1;
          availableInsertionsOut(availableInsertionsIndex).item_class := ame_util.headerItemClassName;
          availableInsertionsOut(availableInsertionsIndex).item_id := engTransactionId;
          availableInsertionsOut(availableInsertionsIndex).action_type_id := null;
          availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := null;
          availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.absoluteOrder;
          availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
          availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
          availableInsertionsOut(availableInsertionsIndex).authority := ame_util.preApprover;
          availableInsertionsOut(availableInsertionsIndex).description :=
                                        ame_util.absoluteOrderDescription || positionIn || '.  ';
        end if;

        /* authority approver */
        if (not ame_engine.insertionExists
                  (orderTypeIn   => ame_util.absoluteOrder
                  ,parameterIn   => tempParameter
                  )) then
          availableInsertionsIndex := availableInsertionsIndex + 1;
          availableInsertionsOut(availableInsertionsIndex).item_class := ame_util.headerItemClassName;
          availableInsertionsOut(availableInsertionsIndex).item_id := engTransactionId;
          availableInsertionsOut(availableInsertionsIndex).action_type_id := null;
          availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := null;
          availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.absoluteOrder;
          availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
          availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
          availableInsertionsOut(availableInsertionsIndex).authority := ame_util.authorityApprover;
          availableInsertionsOut(availableInsertionsIndex).description :=
                                         ame_util.absoluteOrderDescription || positionIn || '.  ';
        end if;

        /* post approver */
        if (not ame_engine.insertionExists
                  (orderTypeIn   => ame_util.absoluteOrder
                  ,parameterIn   => tempParameter
                  )) then
          availableInsertionsIndex := availableInsertionsIndex + 1;
          availableInsertionsOut(availableInsertionsIndex).item_class := ame_util.headerItemClassName;
          availableInsertionsOut(availableInsertionsIndex).item_id := engTransactionId;
          availableInsertionsOut(availableInsertionsIndex).action_type_id := null;
          availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := null;
          availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.absoluteOrder;
          availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
          availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
          availableInsertionsOut(availableInsertionsIndex).authority := ame_util.postApprover;
          availableInsertionsOut(availableInsertionsIndex).description :=
                                         ame_util.absoluteOrderDescription || positionIn || '.  ';
        end if;

      else /* If approver count is more than zero */

        if (positionIn < engStApproversCount + 1) then

          /* Attribute to the insertee the relevant properties of the approver at positionIn. */
          if (not ame_engine.insertionExists
                    (orderTypeIn   => ame_util.absoluteOrder
                    ,parameterIn   => tempParameter
                    )) then
            availableInsertionsIndex := availableInsertionsIndex + 1;
            availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(positionIn).item_class;
            availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(positionIn).item_id;
            availableInsertionsOut(availableInsertionsIndex).action_type_id := engStApprovers(positionIn).action_type_id;
            availableInsertionsOut(availableInsertionsIndex).group_or_chain_id :=
                                                                       engStApprovers(positionIn).group_or_chain_id;
            availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.absoluteOrder;
            availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
            availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
            availableInsertionsOut(availableInsertionsIndex).authority := engStApprovers(positionIn).authority;
            availableInsertionsOut(availableInsertionsIndex).description :=
                                         ame_util.absoluteOrderDescription || positionIn || '.  ';
          end if;

        end if;

        /*
          If there is an approver at positionIn - 1, and the approver's relevant properties differ from
          those of the approver at positionIn (if any), add a second available insertion, attributing
          to the insertee the relevant properties of engStApprovers(positionIn - 1).
        */
        if (positionIn = engStApproversCount + 1 or
            (positionIn > 1 and
             (engStApprovers(positionIn).group_or_chain_id <> engStApprovers(positionIn - 1).group_or_chain_id or
              engStApprovers(positionIn).action_type_id <> engStApprovers(positionIn - 1).action_type_id or
              engStApprovers(positionIn).item_id <> engStApprovers(positionIn - 1).item_id or
              engStApprovers(positionIn).item_class <> engStApprovers(positionIn - 1).item_class
             ))) then

          /* Attribute to the insertee the relevant properties of the approver at positionIn - 1. */
          if (not ame_engine.insertionExists
                    (orderTypeIn   => ame_util.absoluteOrder
                    ,parameterIn   => tempParameter
                    )) then
            availableInsertionsIndex := availableInsertionsIndex + 1;
            availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(positionIn - 1).item_class;
            availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(positionIn - 1).item_id;
            availableInsertionsOut(availableInsertionsIndex).action_type_id :=
                                                                   engStApprovers(positionIn - 1).action_type_id;
            availableInsertionsOut(availableInsertionsIndex).group_or_chain_id :=
                                                                 engStApprovers(positionIn - 1).group_or_chain_id;
            availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.absoluteOrder;
            availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
            availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
            availableInsertionsOut(availableInsertionsIndex).authority := engStApprovers(positionIn - 1).authority;
            availableInsertionsOut(availableInsertionsIndex).description :=
                                                    ame_util.absoluteOrderDescription || positionIn || '.  ';
          end if;
        end if;
      end if; /* End if approver count > 0 */

    end if; /* End if order type is absolute Order */

    /*
      ORDER TYPE:  afterApprover
      Ad-hoc afterApprover is available if positionIn > 1.  COA afterApprover is available if also
      the approver at positionIn - 1 is a COA approvalApproverCategory approver.
    */
    if (orderTypeIn is null or
        orderTypeIn = ame_util.afterApprover) then

      if (positionIn = 1 or
          engStApproversCount = 0) then
        prevApproverDescription := null;
      else
        prevApproverDescription :=
             ame_approver_type_pkg.getApproverDisplayName(nameIn => engStApprovers(positionIn - 1).name);
      end if;

      if(positionIn > 1) then /* ad-hoc */

        tempParameter := engStApprovers(positionIn - 1).name ||
                         ame_util.fieldDelimiter ||
                         engStApprovers(positionIn - 1).item_class ||
                         ame_util.fieldDelimiter ||
                         engStApprovers(positionIn - 1).item_id ||
                         ame_util.fieldDelimiter ||
                         engStApprovers(positionIn - 1).action_type_id ||
                         ame_util.fieldDelimiter ||
                         engStApprovers(positionIn - 1).group_or_chain_id ||
                         ame_util.fieldDelimiter ||
                         engStApprovers(positionIn - 1).occurrence;

        if (not ame_engine.insertionExists
                  (orderTypeIn   => ame_util.afterApprover
                  ,parameterIn   => tempParameter
                  )) then
          availableInsertionsIndex := availableInsertionsIndex + 1;
          availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(positionIn - 1).item_class;
          availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(positionIn - 1).item_id;
          availableInsertionsOut(availableInsertionsIndex).action_type_id :=
                                                                engStApprovers(positionIn - 1).action_type_id;
          availableInsertionsOut(availableInsertionsIndex).group_or_chain_id :=
                                                             engStApprovers(positionIn - 1).group_or_chain_id;
          availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.afterApprover;
          availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
          availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
          availableInsertionsOut(availableInsertionsIndex).authority := engStApprovers(positionIn - 1).authority;
          availableInsertionsOut(availableInsertionsIndex).description :=
                                           ame_util.afterApproverDescription || prevApproverDescription;
        end if;

        if positionIn <= engStApproversCount then

          if (engStApprovers(positionIn).authority = ame_util.authorityApprover and
              engStApprovers(positionIn).api_insertion <> ame_util.apiInsertion and
              engStApprovers(positionIn).approver_category = ame_util.approvalApproverCategory and
              coaInsertionsYNIn = ame_util.booleanTrue and
              (not ame_engine.insertionExists
                   (orderTypeIn   => ame_util.afterApprover
                   ,parameterIn   => tempParameter
                   ))) then /* COA */
            availableInsertionsIndex := availableInsertionsIndex + 1;
            availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(positionIn - 1).item_class;
            availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(positionIn - 1).item_id;
            availableInsertionsOut(availableInsertionsIndex).action_type_id :=
                                                             engStApprovers(positionIn - 1).action_type_id;
            availableInsertionsOut(availableInsertionsIndex).group_or_chain_id :=
                                                                 engStApprovers(positionIn - 1).group_or_chain_id;
            availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.afterApprover;
              /* We've already build the parameter field above, let's not repeat the work here. */
            availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
            availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiAuthorityInsertion;
            availableInsertionsOut(availableInsertionsIndex).authority := engStApprovers(positionIn - 1).authority;
            availableInsertionsOut(availableInsertionsIndex).description :=
                                         ame_util.afterApproverDescription || prevApproverDescription;
          end if;
        end if;
      end if;
    end if;

    /*
      ORDER TYPE:  beforeApprover
      beforeApprover is available if engStApproversCount > 0 and positionIn < engStApproversCount + 1.
    */
    if (orderTypeIn is null or
         orderTypeIn = ame_util.beforeApprover
       ) then

      if (positionIn = engStApproversCount + 1 or
          engStApproversCount = 0) then
        nextApproverDescription := null;
      else
        nextApproverDescription :=
                 ame_approver_type_pkg.getApproverDisplayName(nameIn => engStApprovers(positionIn).name);
      end if;

      if (engStApproversCount > 0 and
          positionIn < engStApproversCount + 1) then

        tempParameter := engStApprovers(positionIn).name ||
                         ame_util.fieldDelimiter ||
                         engStApprovers(positionIn).item_class ||
                         ame_util.fieldDelimiter ||
                         engStApprovers(positionIn).item_id ||
                         ame_util.fieldDelimiter ||
                         engStApprovers(positionIn).action_type_id ||
                         ame_util.fieldDelimiter ||
                         engStApprovers(positionIn).group_or_chain_id ||
                         ame_util.fieldDelimiter ||
                         engStApprovers(positionIn).occurrence;

        if (not ame_engine.insertionExists
                  (orderTypeIn   => ame_util.beforeApprover
                  ,parameterIn   => tempParameter
                  )) then
          availableInsertionsIndex := availableInsertionsIndex + 1;
          availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(positionIn).item_class;
          availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(positionIn).item_id;
          availableInsertionsOut(availableInsertionsIndex).action_type_id := engStApprovers(positionIn).action_type_id;
          availableInsertionsOut(availableInsertionsIndex).group_or_chain_id :=
                                                                    engStApprovers(positionIn).group_or_chain_id;
          availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.beforeApprover;
          availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
          availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
          availableInsertionsOut(availableInsertionsIndex).authority := engStApprovers(positionIn).authority;
          availableInsertionsOut(availableInsertionsIndex).description :=
                                             ame_util.beforeApproverDescription || nextApproverDescription;
        end if;
      end if;
    end if;

    /*
      ORDER TYPE:  firstAuthority
      firstAuthority is available if the approver you're at is the first COA approver in a chain.
    */
    if (coaInsertionsYNIn = ame_util.booleanTrue and
        (orderTypeIn is null or
        orderTypeIn = ame_util.firstAuthority)) then

      if (positionIn < engStApproversCount + 1 and
          engStApprovers(positionIn).authority = ame_util.authorityApprover and
          engStApprovers(positionIn).api_insertion <> ame_util.apiInsertion) then
        tempBoolean := true; /* tempBoolean remains true if no previous authority is found. */
        for i in reverse 1..positionIn - 1 loop
          if (engStApprovers(i).group_or_chain_id <> engStApprovers(positionIn).group_or_chain_id or
              engStApprovers(i).action_type_id <> engStApprovers(positionIn).action_type_id or
              engStApprovers(i).item_id <> engStApprovers(positionIn).item_id or
              engStApprovers(i).item_class <> engStApprovers(positionIn).item_class) then
            exit;
          end if;

          if (engStApprovers(i).authority = ame_util.authorityApprover and
              engStApprovers(i).api_insertion <> ame_util.apiInsertion) then
            tempBoolean := false;
            exit;
          end if;
        end loop;

        if (tempBoolean) then
          tempParameter := ame_util.firstAuthorityParameter ||
                           ame_util.fieldDelimiter ||
                           engStApprovers(positionIn).item_class ||
                           ame_util.fieldDelimiter ||
                           engStApprovers(positionIn).item_id ||
                           ame_util.fieldDelimiter ||
                           engStApprovers(positionIn).action_type_id ||
                           ame_util.fieldDelimiter ||
                           engStApprovers(positionIn).group_or_chain_id;

          if (not ame_engine.insertionExists
                    (orderTypeIn   => ame_util.firstAuthority
                    ,parameterIn   => tempParameter
                    )) then
            availableInsertionsIndex := availableInsertionsIndex + 1;
            availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(positionIn).item_class;
            availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(positionIn).item_id;
            availableInsertionsOut(availableInsertionsIndex).action_type_id :=
                                                                   engStApprovers(positionIn).action_type_id;
            availableInsertionsOut(availableInsertionsIndex).group_or_chain_id :=
                                                                 engStApprovers(positionIn).group_or_chain_id;
            availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.firstAuthority;
            availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
            availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiAuthorityInsertion;
            availableInsertionsOut(availableInsertionsIndex).authority := ame_util.authorityApprover;
            availableInsertionsOut(availableInsertionsIndex).description := ame_util.firstAuthorityDescription;
          end if;
        end if;
      end if;
    end if;

    /*
      ORDER TYPE:  firstPostApprover
      Assume that in the case of an entirely empty approver list, we allow insertion of a first
      post-approver into the header item's list only.  Otherwise, we only allow insertion of a
      first post-approver into a non-empty item list.  Here is the case analysis:
          if(the approver list is empty) then
            allow a first-post-approver insertion for the header
          elsif(positionIn is after the end of the approver list) then
            if(the last approver in the list is not a post-approver) then
              allow a first-post-approver insertion for the last approver's item
            end if
          elsif(positionIn = 1) then
            if(the first approver in the list is a post-approver_ then
              allow a first-post-approver insertion for the first approver's item
            end if
          else
            if(the engStApprovers at positionIn - 1 and positionIn are for the same item) then
              if(the first approver is not a post-approver and
                 the second approver is a post-approver) then
                allow a first-post-approver insertion for the engStApprovers' item
              end if
            else
              if(the second approver is a post-approver) then
                allow a first-post-approver insertion for the second approver's item
              end if
              if(the first approver is not a post-approver) then
                allow a first-post-approver insertion for the first approver's item
              end if
            end if
          end if
    */
    if (orderTypeIn is null or
        orderTypeIn = ame_util.firstPostApprover) then

      if (engStApproversCount = 0) then
        tempParameter := ame_util.firstPostParameter ||
                         ame_util.fieldDelimiter ||
                         ame_util.headerItemClassName ||
                         ame_util.fieldDelimiter ||
                         engTransactionId;

        if (not ame_engine.insertionExists
                  (orderTypeIn => ame_util.firstPostApprover
                  ,parameterIn => tempParameter
                  )) then
          availableInsertionsIndex := availableInsertionsIndex + 1;
          availableInsertionsOut(availableInsertionsIndex).item_class := ame_util.headerItemClassName;
          availableInsertionsOut(availableInsertionsIndex).item_id := engTransactionId;
          availableInsertionsOut(availableInsertionsIndex).action_type_id := ame_util.nullInsertionActionTypeId;
          availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
          availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.firstPostApprover;
          availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
          availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
          availableInsertionsOut(availableInsertionsIndex).authority := ame_util.postApprover;
          availableInsertionsOut(availableInsertionsIndex).description := ame_util.firstPostApproverDescription;
        end if;
      elsif (positionIn = engStApproversCount + 1) then
        if (engStApprovers(engStApproversCount).authority <> ame_util.postApprover) then
          tempParameter := ame_util.firstPostParameter ||
                           ame_util.fieldDelimiter ||
                           engStApprovers(engStApproversCount).item_class ||
                           ame_util.fieldDelimiter ||
                           engStApprovers(engStApproversCount).item_id;
          if (not ame_engine.insertionExists
                    (orderTypeIn   => ame_util.firstPostApprover
                    ,parameterIn   => tempParameter
                    )) then
            availableInsertionsIndex := availableInsertionsIndex + 1;
            availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(engStApproversCount).item_class;
            availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(engStApproversCount).item_id;
            availableInsertionsOut(availableInsertionsIndex).action_type_id :=
                                                                        ame_util.nullInsertionActionTypeId;
            availableInsertionsOut(availableInsertionsIndex).group_or_chain_id :=
                                                                      ame_util.nullInsertionGroupOrChainId;
            availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.firstPostApprover;
            availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
            availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
            availableInsertionsOut(availableInsertionsIndex).authority := ame_util.postApprover;
            availableInsertionsOut(availableInsertionsIndex).description := ame_util.firstPostApproverDescription;
          end if;
        end if;
      elsif (positionIn = 1) then
        if (engStApprovers(1).authority = ame_util.postApprover) then
          tempParameter := ame_util.firstPostParameter ||
                           ame_util.fieldDelimiter ||
                           engStApprovers(1).item_class ||
                           ame_util.fieldDelimiter ||
                           engStApprovers(1).item_id;
          if (not ame_engine.insertionExists
                    (orderTypeIn   => ame_util.firstPostApprover
                    ,parameterIn   => tempParameter
                    )) then
            availableInsertionsIndex := availableInsertionsIndex + 1;
            availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(1).item_class;
            availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(1).item_id;
            availableInsertionsOut(availableInsertionsIndex).action_type_id := ame_util.nullInsertionActionTypeId;
            availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
            availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.firstPostApprover;
            availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
            availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
            availableInsertionsOut(availableInsertionsIndex).authority := ame_util.postApprover;
            availableInsertionsOut(availableInsertionsIndex).description := ame_util.firstPostApproverDescription;
          end if;
        end if;
      else
        if (engStApprovers(positionIn - 1).item_id = engStApprovers(positionIn).item_id and
            engStApprovers(positionIn - 1).item_class = engStApprovers(positionIn).item_class) then
          if (engStApprovers(positionIn - 1).authority <> ame_util.postApprover and
              engStApprovers(positionIn).authority = ame_util.postApprover) then
            tempParameter := ame_util.firstPostParameter ||
                             ame_util.fieldDelimiter ||
                             engStApprovers(positionIn).item_class ||
                             ame_util.fieldDelimiter ||
                             engStApprovers(positionIn).item_id;
            if (not ame_engine.insertionExists
                      (orderTypeIn => ame_util.firstPostApprover
                      ,parameterIn => tempParameter
                      )) then
              availableInsertionsIndex := availableInsertionsIndex + 1;
              availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(positionIn).item_class;
              availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(positionIn).item_id;
              availableInsertionsOut(availableInsertionsIndex).action_type_id := ame_util.nullInsertionActionTypeId;
              availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
              availableInsertionsOut(availableInsertionsIndex).group_or_chain_id :=
                                                            engStApprovers(positionIn).group_or_chain_id;
              availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.firstPostApprover;
              availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
              availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
              availableInsertionsOut(availableInsertionsIndex).authority := ame_util.postApprover;
              availableInsertionsOut(availableInsertionsIndex).description := ame_util.firstPostApproverDescription;
            end if;
          end if;
        else
          if (engStApprovers(positionIn).authority = ame_util.postApprover) then
            tempParameter := ame_util.firstPostParameter ||
                             ame_util.fieldDelimiter ||
                             engStApprovers(positionIn).item_class ||
                             ame_util.fieldDelimiter ||
                             engStApprovers(positionIn).item_id;
            if (not ame_engine.insertionExists
                      (orderTypeIn   => ame_util.firstPostApprover
                      ,parameterIn   => tempParameter
                      )) then
              availableInsertionsIndex := availableInsertionsIndex + 1;
              availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(positionIn).item_class;
              availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(positionIn).item_id;
              availableInsertionsOut(availableInsertionsIndex).action_type_id := ame_util.nullInsertionActionTypeId;
              availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
              availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.firstPostApprover;
              availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
              availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
              availableInsertionsOut(availableInsertionsIndex).authority := ame_util.postApprover;
              availableInsertionsOut(availableInsertionsIndex).description := ame_util.firstPostApproverDescription;
            end if;
          end if;

          if (engStApprovers(positionIn - 1).authority <> ame_util.postApprover) then
            tempParameter := ame_util.firstPostParameter ||
                             ame_util.fieldDelimiter ||
                             engStApprovers(positionIn - 1).item_class ||
                             ame_util.fieldDelimiter ||
                             engStApprovers(positionIn - 1).item_id;
            if (not ame_engine.insertionExists
                      (orderTypeIn   => ame_util.firstPostApprover
                      ,parameterIn   => tempParameter
                      )) then
              availableInsertionsIndex := availableInsertionsIndex + 1;
              availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(positionIn - 1).item_class;
              availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(positionIn - 1).item_id;
              availableInsertionsOut(availableInsertionsIndex).action_type_id := ame_util.nullInsertionActionTypeId;
              availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
              availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.firstPostApprover;
              availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
              availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
              availableInsertionsOut(availableInsertionsIndex).authority := ame_util.postApprover;
              availableInsertionsOut(availableInsertionsIndex).description := ame_util.firstPostApproverDescription;
            end if;
          end if;
        end if;
      end if;
    end if;

    /*
      ORDER TYPE:  firstPreApprover
      Assume that in the case of an entirely empty approver list, we allow insertion of a first
      pre-approver into the header item's list only.  Otherwise, we only allow insertion of a
      first pre-approver into a non-empty item list.  Here is the case analysis:
        if(the approver list is empty) then
          allow a first-pre-approver insertion for the header item
        elsif(positionIn = 1) then
          allow a first-pre-approver insertion for the first approver's item
        elsif(positionIn < engStApproversCount + 1) then
          if(the engStApprovers at positionIn - 1 and positionIn are for different items) then
            allow a first-pre-approver insertion for the second approver's item
          end if
        end if
    */
    if (orderTypeIn is null or
        orderTypeIn = ame_util.firstPreApprover) then

      if (engStApproversCount = 0) then
        tempParameter := ame_util.firstPreApprover ||
                         ame_util.fieldDelimiter ||
                         ame_util.headerItemClassName ||
                         ame_util.fieldDelimiter ||
                         engTransactionId;
        if (not ame_engine.insertionExists
                  (orderTypeIn => ame_util.firstPreApprover
                  ,parameterIn => tempParameter
                  )) then
          availableInsertionsIndex := availableInsertionsIndex + 1;
          availableInsertionsOut(availableInsertionsIndex).item_class := ame_util.headerItemClassName;
          availableInsertionsOut(availableInsertionsIndex).item_id := engTransactionId;
          availableInsertionsOut(availableInsertionsIndex).action_type_id := ame_util.nullInsertionActionTypeId;
          availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
          availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.firstPreApprover;
          availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
          availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
          availableInsertionsOut(availableInsertionsIndex).authority := ame_util.preApprover;
          availableInsertionsOut(availableInsertionsIndex).description := ame_util.firstPreApproverDescription;
        end if;
      elsif (positionIn = 1) then
        tempParameter := ame_util.firstPreApprover ||
                         ame_util.fieldDelimiter ||
                         engStApprovers(1).item_class ||
                         ame_util.fieldDelimiter ||
                         engStApprovers(1).item_id;
        if (not ame_engine.insertionExists
                  (orderTypeIn   => ame_util.firstPreApprover
                  ,parameterIn   => tempParameter
                  )) then
          availableInsertionsIndex := availableInsertionsIndex + 1;
          availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(1).item_class;
          availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(1).item_id;
          availableInsertionsOut(availableInsertionsIndex).action_type_id := ame_util.nullInsertionActionTypeId;
          availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
          availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.firstPreApprover;
          availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
          availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
          availableInsertionsOut(availableInsertionsIndex).authority := ame_util.preApprover;
          availableInsertionsOut(availableInsertionsIndex).description := ame_util.firstPreApproverDescription;
        end if;
      elsif (positionIn < engStApproversCount + 1) then
        if (engStApprovers(positionIn - 1).item_id <> engStApprovers(positionIn).item_id or
            engStApprovers(positionIn - 1).item_class <> engStApprovers(positionIn).item_class) then
          tempParameter := ame_util.firstPreApprover ||
                           ame_util.fieldDelimiter ||
                           engStApprovers(positionIn).item_class ||
                           ame_util.fieldDelimiter ||
                           engStApprovers(positionIn).item_id;
          if (not ame_engine.insertionExists
                    (orderTypeIn   => ame_util.firstPreApprover
                    ,parameterIn   => tempParameter
                    )) then
            availableInsertionsIndex := availableInsertionsIndex + 1;
            availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(positionIn).item_class;
            availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(positionIn).item_id;
            availableInsertionsOut(availableInsertionsIndex).action_type_id := ame_util.nullInsertionActionTypeId;
            availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
            availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.firstPreApprover;
            availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
            availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
            availableInsertionsOut(availableInsertionsIndex).authority := ame_util.preApprover;
            availableInsertionsOut(availableInsertionsIndex).description := ame_util.firstPreApproverDescription;
          end if;
        end if;
      end if;
    end if;

    /*
      ORDER TYPE:  lastPostApprover
      Assume that in the case of an entirely empty approver list, we allow insertion of a last
      post-approver into the header item's list only.  Otherwise, we only allow insertion of a
      last post-approver into a non-empty item list.  Here is the case analysis:
        if(the approver list is empty) then
          allow last-post-approver insertion for the header item
        elsif(positionIn = engStApproversCount + 1) then
          allow last-post-approver insertion for the last approver's item
        elsif(positionIn > 1) then
          if(the engStApprovers at positionIn - 1 and positionIn are for different items) then
            allow last-post-approver insertion for the former approver's item
          end if
        end if
    */
    if (orderTypeIn is null or
        orderTypeIn = ame_util.lastPostApprover) then
      if (engStApproversCount = 0) then
        tempParameter := ame_util.lastPostApprover ||
                         ame_util.fieldDelimiter ||
                         ame_util.headerItemClassName ||
                         ame_util.fieldDelimiter ||
                         engTransactionId;
        if (not ame_engine.insertionExists
                  (orderTypeIn   => ame_util.lastPostApprover
                  ,parameterIn   => tempParameter
                  )) then
          availableInsertionsIndex := availableInsertionsIndex + 1;
          availableInsertionsOut(availableInsertionsIndex).item_class := ame_util.headerItemClassName;
          availableInsertionsOut(availableInsertionsIndex).item_id := engTransactionId;
          availableInsertionsOut(availableInsertionsIndex).action_type_id := ame_util.nullInsertionActionTypeId;
          availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
          availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.lastPostApprover;
          availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
          availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
          availableInsertionsOut(availableInsertionsIndex).authority := ame_util.postApprover;
          availableInsertionsOut(availableInsertionsIndex).description := ame_util.lastPostApproverDescription;
        end if;
      elsif (positionIn = engStApproversCount + 1) then
        tempParameter := ame_util.lastPostApprover ||
                         ame_util.fieldDelimiter ||
                         engStApprovers(engStApproversCount).item_class ||
                         ame_util.fieldDelimiter ||
                         engStApprovers(engStApproversCount).item_id;
        if (not ame_engine.insertionExists
                  (orderTypeIn => ame_util.lastPostApprover
                  ,parameterIn => tempParameter
                  )) then
          availableInsertionsIndex := availableInsertionsIndex + 1;
          availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(engStApproversCount).item_class;
          availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(engStApproversCount).item_id;
          availableInsertionsOut(availableInsertionsIndex).action_type_id := ame_util.nullInsertionActionTypeId;
          availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
          availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.lastPostApprover;
          availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
          availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
          availableInsertionsOut(availableInsertionsIndex).authority := ame_util.postApprover;
          availableInsertionsOut(availableInsertionsIndex).description := ame_util.lastPostApproverDescription;
        end if;
      elsif (positionIn > 1) then
        if (engStApprovers(positionIn - 1).item_id <> engStApprovers(positionIn).item_id or
            engStApprovers(positionIn - 1).item_class <> engStApprovers(positionIn).item_class) then
          tempParameter := ame_util.lastPostApprover ||
                           ame_util.fieldDelimiter ||
                           engStApprovers(positionIn - 1).item_class ||
                           ame_util.fieldDelimiter ||
                           engStApprovers(positionIn - 1).item_id;
          if (not ame_engine.insertionExists
                    (orderTypeIn   => ame_util.lastPostApprover
                    ,parameterIn   => tempParameter
                    )) then
            availableInsertionsIndex := availableInsertionsIndex + 1;
            availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(positionIn - 1).item_class;
            availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(positionIn - 1).item_id;
            availableInsertionsOut(availableInsertionsIndex).action_type_id := ame_util.nullInsertionActionTypeId;
            availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
            availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.lastPostApprover;
            availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
            availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
            availableInsertionsOut(availableInsertionsIndex).authority := ame_util.postApprover;
            availableInsertionsOut(availableInsertionsIndex).description := ame_util.lastPostApproverDescription;
          end if;
        end if;
      end if;
    end if;

    /*
      ORDER TYPE:  lastPreApprover
      Assume that in the case of an entirely empty approver list, we allow insertion of a last
      pre-approver into the header item's list only.  Otherwise, we only allow insertion of a
      last pre-approver into a non-empty item list.  Here is the case analysis:
        if(the approver list is empty) then
          allow last-pre-approver insertion for the header item
        elsif(positionIn = 1) then
          if(the approver at position 1 is not a pre-approver) then
            allow last-pre-approver insertion for the item of the first approver
          end if
        elsif(positionIn <= engStApproversCount) then
          if(the engStApprovers at positionIn - 1 and positionIn are for the same item) then
            if(the approver at positionIn - 1 is a pre-approver and
               the approver at positionIn is not a pre-approver) then
              allow last-pre-approver insertion for the engStApprovers' item
            end if
          else
            if(the approver at positionIn is not a pre-approver) then
              allow last-pre-approver insertion for the item of the approver at positionIn
            end if
          end if
        end if
    */
    if (orderTypeIn is null or
        orderTypeIn = ame_util.lastPreApprover) then
      if (engStApproversCount = 0) then
        tempParameter := ame_util.lastPreApprover ||
                         ame_util.fieldDelimiter ||
                         ame_util.headerItemClassName ||
                         ame_util.fieldDelimiter ||
                         engTransactionId;
        if (not ame_engine.insertionExists
                  (orderTypeIn => ame_util.lastPreApprover
                  ,parameterIn => tempParameter)) then
          availableInsertionsIndex := availableInsertionsIndex + 1;
          availableInsertionsOut(availableInsertionsIndex).item_class := ame_util.headerItemClassName;
          availableInsertionsOut(availableInsertionsIndex).item_id := engTransactionId;
          availableInsertionsOut(availableInsertionsIndex).action_type_id := ame_util.nullInsertionActionTypeId;
          availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
          availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.lastPreApprover;
          availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
          availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
          availableInsertionsOut(availableInsertionsIndex).authority := ame_util.preApprover;
          availableInsertionsOut(availableInsertionsIndex).description := ame_util.lastPreApproverDescription;
        end if;
      elsif (positionIn = 1) then
        if (engStApprovers(1).authority <> ame_util.preApprover) then
          tempParameter := ame_util.lastPreApprover ||
                           ame_util.fieldDelimiter ||
                           engStApprovers(1).item_class ||
                           ame_util.fieldDelimiter ||
                           engStApprovers(1).item_id;
          if (not ame_engine.insertionExists
                    (orderTypeIn   => ame_util.lastPreApprover
                    ,parameterIn   => tempParameter
                    )) then
            availableInsertionsIndex := availableInsertionsIndex + 1;
            availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(1).item_class;
            availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(1).item_id;
            availableInsertionsOut(availableInsertionsIndex).action_type_id := ame_util.nullInsertionActionTypeId;
            availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
            availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.lastPreApprover;
            availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
            availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
            availableInsertionsOut(availableInsertionsIndex).authority := ame_util.preApprover;
            availableInsertionsOut(availableInsertionsIndex).description := ame_util.lastPreApproverDescription;
          end if;
        end if;
      elsif (positionIn <= engStApproversCount) then
        if (engStApprovers(positionIn - 1).item_id = engStApprovers(positionIn).item_id and
            engStApprovers(positionIn - 1).item_class = engStApprovers(positionIn).item_class) then
          if (engStApprovers(positionIn - 1).authority = ame_util.preApprover and
              engStApprovers(positionIn).authority <> ame_util.preApprover) then
            tempParameter := ame_util.lastPreApprover ||
                             ame_util.fieldDelimiter ||
                             engStApprovers(positionIn).item_class ||
                             ame_util.fieldDelimiter ||
                             engStApprovers(positionIn).item_id;
            if (not ame_engine.insertionExists
                      (orderTypeIn  => ame_util.lastPreApprover
                      ,parameterIn  => tempParameter
                      )) then
              availableInsertionsIndex := availableInsertionsIndex + 1;
              availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(positionIn).item_class;
              availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(positionIn).item_id;
              availableInsertionsOut(availableInsertionsIndex).action_type_id := ame_util.nullInsertionActionTypeId;
              availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
              availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.lastPreApprover;
              availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
              availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
              availableInsertionsOut(availableInsertionsIndex).authority := ame_util.preApprover;
              availableInsertionsOut(availableInsertionsIndex).description := ame_util.lastPreApproverDescription;
            end if;
          end if;
        else
          if (engStApprovers(positionIn).authority <> ame_util.preApprover) then
            tempParameter := ame_util.lastPreApprover ||
                             ame_util.fieldDelimiter ||
                             engStApprovers(positionIn).item_class ||
                             ame_util.fieldDelimiter ||
                             engStApprovers(positionIn).item_id;
            if (not ame_engine.insertionExists
                      (orderTypeIn   => ame_util.lastPreApprover
                      ,parameterIn   => tempParameter
                      )) then
              availableInsertionsIndex := availableInsertionsIndex + 1;
              availableInsertionsOut(availableInsertionsIndex).item_class := engStApprovers(positionIn).item_class;
              availableInsertionsOut(availableInsertionsIndex).item_id := engStApprovers(positionIn).item_id;
              availableInsertionsOut(availableInsertionsIndex).action_type_id := ame_util.nullInsertionActionTypeId;
              availableInsertionsOut(availableInsertionsIndex).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
              availableInsertionsOut(availableInsertionsIndex).order_type := ame_util.lastPreApprover;
              availableInsertionsOut(availableInsertionsIndex).parameter := tempParameter;
              availableInsertionsOut(availableInsertionsIndex).api_insertion := ame_util.apiInsertion;
              availableInsertionsOut(availableInsertionsIndex).authority := ame_util.preApprover;
              availableInsertionsOut(availableInsertionsIndex).description := ame_util.lastPreApproverDescription;
            end if;
          end if;
        end if;
      end if;
    end if;

  exception
    when invalidPositionException then
      errorCode := -20001;
      errorMessage := ame_util.getMessage
        (applicationShortNameIn   =>'PER'
        ,messageNameIn            => 'AME_400418_INVALID_INSERTION'
        );
      ame_util.runtimeException
        (packageNameIn     => 'ame_engine'
        ,routineNameIn     => 'getInsertions'
        ,exceptionNumberIn => errorCode
        ,exceptionStringIn => errorMessage
        );
      raise_application_error(errorCode,errorMessage);

    when others then
      ame_util.runtimeException
        (packageNameIn     => 'ame_engine'
        ,routineNameIn     => 'getInsertions'
        ,exceptionNumberIn => sqlcode
        ,exceptionStringIn => sqlerrm
        );
      raise;
  end getInsertions;
  procedure getLMCondition(ruleIdIn in integer,
                           parameterOneOut out nocopy varchar2,
                           parameterTwoOut out nocopy varchar2) as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    invalidNameException exception;
    tempRuleKey ame_rules.rule_key%type;
    parameterOne ame_conditions.parameter_one%type;
    parameterTwo ame_conditions.parameter_two%type;
    begin
      /* Checked for cached values. */
      if(not engLMParameterOnes.exists(ruleIdIn)) then
        /* Select the values, as they were not cached. */
        select
          ame_conditions.parameter_one,
          ame_conditions.parameter_two
          into
            parameterOne,
            parameterTwo
          from
            ame_conditions,
            ame_condition_usages
          where
            ame_condition_usages.rule_id = ruleIdIn and
            ame_condition_usages.condition_id = ame_conditions.condition_id and
            ame_conditions.condition_type = ame_util.listModConditionType and
            engEffectiveRuleDate between
              ame_conditions.start_date and
              nvl(ame_conditions.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
            engEffectiveRuleDate between
              ame_condition_usages.start_date and
              nvl(ame_condition_usages.end_date - ame_util.oneSecond, engEffectiveRuleDate) and
            rownum < 2; /* Avoids second fetch otherwise required by ANSI standard to check for too many rows. */
        /* Check for an invalid wf_roles.name value in parameter_two. */
        if(parameterTwo = ame_util.invalidApproverWfRolesName) then
          raise invalidNameException;
        end if;
        /* Cache the values. */
        engLMParameterOnes(ruleIdIn) := parameterOne;
        engLMParameterTwos(ruleIdIn) := parameterTwo;
      end if;
      /* Return the values. */
      parameterOneOut := engLMParameterOnes(ruleIdIn);
      parameterTwoOut := engLMParameterTwos(ruleIdIn);
      exception
        when invalidNameException then
          tempRuleKey := ame_rule_pkg.getRuleKey(ruleIdIn => ruleIdIn);
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400685_INV_LM_RULE',
                                              tokenNameOneIn  => 'RULE_KEY',
                                              tokenValueOneIn => tempRuleKey);
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getLMCondition',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getLMCondition',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getLMCondition;
  procedure getNextApprovers(
            applicationIdIn   in number
           ,transactionTypeIn in varchar2
           ,transactionIdIn   in varchar2
           ,nextApproversType in number
           ,flagApproversAsNotifiedIn in varchar2 default ame_util.booleanTrue
           ,approvalProcessCompleteYNOut out nocopy varchar2
           ,nextApproversOut             out nocopy ame_util.approversTable2
           ,itemIndexesOut               out nocopy ame_util.idList
           ,itemClassesOut               out nocopy ame_util.stringList
           ,itemIdsOut                   out nocopy ame_util.stringList
           ,itemSourcesOut               out nocopy ame_util.longStringList
           ,productionIndexesOut         out nocopy ame_util.idList
           ,variableNamesOut             out nocopy ame_util.stringList
           ,variableValuesOut            out nocopy ame_util.stringList
           ,transVariableNamesOut        out nocopy ame_util.stringList
           ,transVariableValuesOut       out nocopy ame_util.stringList) as
      allItemsNotSuspended boolean;
      ameApplicationId integer;
      copyAncillaryData  boolean;
      nextApproverCount integer;
      nextTreeNodeIndex integer;
      tempTreeNodeIndex integer;
      approverItemCount integer;
      approverProdCount integer;
      currentTreeNode ame_util.approverTreeRecord;
      evaluateNextNode boolean;
      currentOrderNumber integer;
      nextApproverTreeIndexList ame_util.idList;
      currentApproverIndex integer;
      tempApproverIndexes ame_util.idList;
--      tempItemClass ame_util.stringType;
--      tempItemId    ame_util.stringType;
      processSibling boolean;
      tempTreeNode ame_util.approverTreeRecord;
      -- following two variables added - to use incase of item_class is null
      tempItemClass ame_util.stringType;
      tempItemId    ame_util.stringType;
      -- repeated
      tempRepeatedCount integer;
      tempRepeatedCount2 integer;
      tempPrepareItemData boolean := true;
      tempProcessProductionActions boolean := false;
      tempProcessProductionRules   boolean := false;
      tempTreeLevelId integer;
      --+
      previousNodeOrderNumber integer;
      previousTreeLevelId     varchar2(320);
      previousNodeStatus      integer;
      --+
      prevApproverOrderNumber integer;
      prevApproverName        varchar2(320);
      prevApproverStatus      integer;
      --+
    begin
      if nextApproversType = 4 then
        tempPrepareItemData := false;
      end if;
      if nextApproversType = 2 or nextApproversType = 3 then
        tempProcessProductionActions := true;
      end if;
      if nextApproversType = 3 then
        tempProcessProductionRules := true;
      end if;
      ame_engine.lockTransaction(fndApplicationIdIn => applicationIdIn,
                                 transactionIdIn => transactionIdIn,
                                 transactionTypeIdIn => transactionTypeIn);
      ame_engine.updateTransactionState(isTestTransactionIn  => false
                                       ,isLocalTransactionIn => false
                                       ,fetchConfigVarsIn    => true
                                       ,fetchOldApproversIn  => true
                                       ,fetchInsertionsIn    => true
                                       ,fetchDeletionsIn     => true
                                       ,fetchAttributeValuesIn      => true
                                       ,fetchInactiveAttValuesIn    => false
                                       ,processProductionActionsIn  => tempProcessProductionActions
                                       ,processProductionRulesIn    => tempProcessProductionRules
                                       ,updateCurrentApproverListIn => true
                                       ,updateOldApproverListIn     => true
                                       ,processPrioritiesIn   => true
                                       ,prepareItemDataIn     => tempPrepareItemData
                                       ,prepareRuleIdsIn      => false
                                       ,prepareRuleDescsIn    => false
                                       ,prepareApproverTreeIn => true
                                       ,transactionIdIn       => transactionIdIn
                                       ,ameApplicationIdIn    => null
                                       ,fndApplicationIdIn    => applicationIdIn
                                       ,transactionTypeIdIn   => transactionTypeIn);
      approvalProcessCompleteYNOut := ame_engine.getApprovalProcessCompleteYN;
      ameApplicationId := ame_engine.getAmeApplicationId;
      /* If approvalProcessCompleteYNOut is 'Y', there should be no nextApprovers. Hence
         return with an empty nextApproversOut table */
      if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved or
         approvalProcessCompleteYNOut = ame_util2.completeFullyRejected or
         approvalProcessCompleteYNOut = ame_util2.completePartiallyApproved or
         approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
         ame_engine.unlockTransaction(fndApplicationIdIn  => applicationIdIn,
                                     transactionIdIn     => transactionIdIn,
                                     transactionTypeIdIn => transactionTypeIn);
        return;
      end if;
      copyAncillaryData := false;
      nextApproverCount := 0; /* Pre increment */
      approverItemCount := 0;
      approverProdCount := 0;
      nextTreeNodeIndex := 1;
      evaluateNextNode := true;
      currentOrderNumber := null;
      processSibling := true;
      loop
        currentTreeNode := engStApproversTree(nextTreeNodeIndex);
        if currentTreeNode.is_suspended is null or
           currentTreeNode.is_suspended = ame_util.booleanFalse then
          if currentTreeNode.tree_level = 6 and
             (currentTreeNode.status = ame_util.startedStatus
               and engStApprovers(currentTreeNode.approver_index).approval_status
                    <> ame_util.notifiedByRepeatedStatus)and
             (currentTreeNode.sibling_index <> ame_util.noSiblingIndex
               and currentTreeNode.min_order <> engStApproversTree(currentTreeNode.sibling_index).min_order ) then
            evaluateNextNode := false;
          end if;
          if evaluateNextNode then
            if currentTreeNode.status <> ame_util.completedStatus then
              if currentTreeNode.approver_index = ame_util.noApproverIndex and
                 evaluateNextNode then
                currentOrderNumber := currentTreeNode.min_order;
              end if;
            else
              currentOrderNumber := null;
            end if;
            if currentTreeNode.approver_index <> ame_util.noApproverIndex
                and currentOrderNumber is not null
                and currentTreeNode.status = ame_util.notStartedStatus
                and currentTreeNode.min_order = currentOrderNumber
                and (engStApprovers(currentTreeNode.approver_index).approval_status is null
                       or engStApprovers(currentTreeNode.approver_index).approval_status
                            <> ame_util.notifiedByRepeatedStatus)
                  then
              nextApproverCount := nextApproverCount + 1;
              ame_util.copyApproverRecord2
                (approverRecord2In => engStApprovers(currentTreeNode.approver_index)
                ,approverRecord2Out => nextApproversOut(nextApproverCount));
              if flagApproversAsNotifiedIn  = ame_util.booleanTrue then
                setInsertedApprovalStatus(currentApproverIndexIn => currentTreeNode.approver_index
                                           ,approvalStatusIn => ame_util.notifiedStatus );
              end if;
                currentApproverIndex := currentTreeNode.approver_index;
              copyAncillaryData := true;
              nextApproverTreeIndexList(nextApproverCount) := nextTreeNodeIndex;
              tempApproverIndexes(nextApproverCount) := currentTreeNode.approver_index;
              if currentTreeNode.sibling_index <> -1
                and currentTreeNode.max_order <> engStApproversTree(currentTreeNode.sibling_index).max_order then
                processSibling := false;
              else
                processSibling := true;
              end if;
              for x in 1 .. engStRepeatedIndexes.count loop
                if engStRepeatedIndexes(x) = currentTreeNode.approver_index
                   and engStRepeatedAppIndexes(x) <> currentTreeNode.approver_index then
                      --+
                  update ame_temp_old_approver_lists
                     set approval_status = ame_util.notifiedByRepeatedStatus
                   where application_id = ameApplicationId
                     and transaction_id = transactionIdIn
                     and name           = engStApprovers(engStRepeatedAppIndexes(x)).name --nextApproversOut(i).name
                     and item_class        = engStApprovers(engStRepeatedAppIndexes(x)).item_class
                     and item_id           = engStApprovers(engStRepeatedAppIndexes(x)).item_id
                     and action_type_id    = engStApprovers(engStRepeatedAppIndexes(x)).action_type_id
                     and group_or_chain_id = engStApprovers(engStRepeatedAppIndexes(x)).group_or_chain_id
                     and occurrence        = engStApprovers(engStRepeatedAppIndexes(x)).occurrence
                     and (approval_status is null or approval_status = ame_util.repeatedStatus);
                     engStApprovers(engStRepeatedAppIndexes(x)).approval_status := ame_util.notifiedByRepeatedStatus;
                     setInsertedApprovalStatus(currentApproverIndexIn => engStRepeatedAppIndexes(x)
                                    ,approvalStatusIn => ame_util.notifiedByRepeatedStatus);
                      --+
                end if;
              end loop;
            end if;
            if currentOrderNumber is null and currentTreeNode.tree_level = 6 then
              if currentTreeNode.approver_index <> ame_util.noApproverIndex and
                 (currentTreeNode.status = ame_util.completedStatus or
                  (
                    currentTreeNode.status = ame_util.startedStatus
                    and engStApprovers(currentTreeNode.approver_index).approval_status <> ame_util.notifiedByRepeatedStatus
                    and processSibling
                  )or
                  (
                  currentTreeNode.status = ame_util.notStartedStatus and
                  currentTreeNode.sibling_index <> ame_util.noSiblingIndex
                  and currentTreeNode.min_order = engStApproversTree(currentTreeNode.sibling_index).min_order
                  )
                 )and
                 processSibling and --evaluateNextNode and
                 (currentTreeNode.sibling_index <> ame_util.noSiblingIndex
                  and engStApproversTree(currentTreeNode.sibling_index).status = ame_util.notStartedStatus
                and ( engStApprovers(engStApproversTree(currentTreeNode.sibling_index).approver_index).approval_status is null
                  or engStApprovers(engStApproversTree(currentTreeNode.sibling_index).approver_index).approval_status
                      <> ame_util.notifiedByRepeatedStatus)
                  ) then
                --+
                if prevApproverOrderNumber is null or
                 (prevApproverOrderNumber < engStApproversTree(currentTreeNode.sibling_index).min_order
                 and prevApproverStatus = ame_util.completedStatus) or
                 (prevApproverOrderNumber = engStApproversTree(currentTreeNode.sibling_index).min_order )
                 then

                nextApproverCount := nextApproverCount + 1;
                ame_util.copyApproverRecord2
                  (approverRecord2In => engStApprovers(engStApproversTree(currentTreeNode.sibling_index).approver_index)
                  ,approverRecord2Out => nextApproversOut(nextApproverCount));
                if flagApproversAsNotifiedIn  = ame_util.booleanTrue then
                  setInsertedApprovalStatus(currentApproverIndexIn => engStApproversTree(currentTreeNode.sibling_index).approver_index
                                           ,approvalStatusIn =>ame_util.notifiedStatus );
                end if;
                nextApproverTreeIndexList(nextApproverCount) := currentTreeNode.sibling_index;
                tempApproverIndexes(nextApproverCount) := engStApproversTree(currentTreeNode.sibling_index).approver_index;
                currentApproverIndex := engStApproversTree(currentTreeNode.sibling_index).approver_index;
                copyAncillaryData := true;
                tempTreeNode := engStApproversTree(currentTreeNode.sibling_index);
                if tempTreeNode.sibling_index <> -1
                    and tempTreeNode.max_order <> engStApproversTree(tempTreeNode.sibling_index).max_order then
                  processSibling := false;
                else
                  processSibling := true;
                end if;
                for x in 1 .. engStRepeatedIndexes.count loop
                  if engStRepeatedIndexes(x) = engStApproversTree(currentTreeNode.sibling_index).approver_index
                     and engStRepeatedAppIndexes(x) <> engStApproversTree(currentTreeNode.sibling_index).approver_index then
                        --+
                    update ame_temp_old_approver_lists
                       set approval_status = ame_util.notifiedByRepeatedStatus
                     where application_id = ameApplicationId
                       and transaction_id = transactionIdIn
                       and name           = engStApprovers(engStRepeatedAppIndexes(x)).name --nextApproversOut(i).name
                       and item_class        = engStApprovers(engStRepeatedAppIndexes(x)).item_class
                       and item_id           = engStApprovers(engStRepeatedAppIndexes(x)).item_id
                       and action_type_id    = engStApprovers(engStRepeatedAppIndexes(x)).action_type_id
                       and group_or_chain_id = engStApprovers(engStRepeatedAppIndexes(x)).group_or_chain_id
                       and occurrence        = engStApprovers(engStRepeatedAppIndexes(x)).occurrence
                       and (approval_status is null or approval_status = ame_util.repeatedStatus);
                       engStApprovers(engStRepeatedAppIndexes(x)).approval_status := ame_util.notifiedByRepeatedStatus;
                       setInsertedApprovalStatus(currentApproverIndexIn => engStRepeatedAppIndexes(x)
                                                ,approvalStatusIn => ame_util.notifiedByRepeatedStatus);

                        --+
                  end if;
                end loop;
              end if;
              end if;
            end if;
          end if;
          --+
          --prevApproverOrderNumber := currentTreeNode.min_order;
          --prevApproverName        := currentTreeNode.tree_level_id;
          --prevApproverStatus      := currentTreeNode.status;
          --+
          if currentTreeNode.tree_level = 6 and (prevApproverOrderNumber is null or
             prevApproverOrderNumber = currentTreeNode.min_order)
            then
            if currentTreeNode.status <> ame_util.completedStatus then
              prevApproverStatus := currentTreeNode.status;
              prevApproverOrderNumber := currentTreeNode.min_order;
              prevApproverName := currentTreeNode.tree_level_id;
            end if;
          end if;
          --+
          if currentTreeNode.child_index <> ame_util.noChildIndex and evaluateNextNode then
            nextTreeNodeIndex := currentTreeNode.child_index;
          else
            if evaluateNextNode then
              nextTreeNodeIndex := currentTreeNode.sibling_index;
              if nextTreeNodeIndex <> ame_util.invalidTreeIndex
                 and (currentTreeNode.min_order = engStApproversTree(nextTreeNodeIndex).min_order
                 or currentTreeNode.status = ame_util.completedStatus) then
                 evaluateNextNode := true;
              else
                 evaluateNextNode := false;
              end if;
            else
              nextTreeNodeIndex := ame_util.noSiblingIndex;
            end if;
          end if;
        else
          nextTreeNodeIndex := currentTreeNode.sibling_index;
          prevApproverOrderNumber := null;
        end if;
        if nextTreeNodeIndex = ame_util.invalidTreeIndex then
          /* There are no more siblings or child nodes for the current node */
          /* So try moving to the parent's sibling node                     */
          /* If the parent's sibling is not found then move to its parent   */
          /* and so on ...                                                  */
          prevApproverOrderNumber := null;
          if currentTreeNode.tree_level = 0 then
            tempTreeNodeIndex := ame_util.invalidTreeIndex;
          else
            tempTreeNodeIndex := currentTreeNode.parent_index;
          end if;
          if tempTreeNodeIndex <> ame_util.invalidTreeIndex then
            processSibling := true;
            evaluateNextNode := false;
            loop
              if engStApproversTree(tempTreeNodeIndex).sibling_index
                                                          = ame_util.noSiblingIndex then
                tempTreeNodeIndex := engStApproversTree(tempTreeNodeIndex).parent_index;
              else
                nextTreeNodeIndex := engStApproversTree(tempTreeNodeIndex).sibling_index;
                evaluateNextNode := false;
                if (engStApproversTree(tempTreeNodeIndex).min_order
                     = engStApproversTree(nextTreeNodeIndex).min_order
                   ) or
                   (engStApproversTree(tempTreeNodeIndex).status
                     = ame_util.completedStatus )
                     and
                  (previousNodeOrderNumber is null or engStApproversTree(tempTreeNodeIndex).min_order = previousNodeOrderNumber
                    and previousNodeStatus = ame_util.completedStatus
                  ) then
                  evaluateNextNode := true;
                else
                  evaluateNextNode := false;
                end if;
                --+
                --previousNodeOrderNumber := engStApproversTree(tempTreeNodeIndex).min_order;
                previousTreeLevelId     := engStApproversTree(tempTreeNodeIndex).tree_level_id;
                --previousNodeStatus      := engStApproversTree(tempTreeNodeIndex).status;
                if previousNodeOrderNumber is null or previousNodeOrderNumber = engStApproversTree(tempTreeNodeIndex).min_order
                  then
                  if engStApproversTree(tempTreeNodeIndex).status <> ame_util.completedStatus then
                    previousNodeStatus := engStApproversTree(tempTreeNodeIndex).status;
                    previousNodeOrderNumber := engStApproversTree(tempTreeNodeIndex).min_order;
                  end if;
                end if;
                --+
                exit;
              end if;
              if tempTreeNodeIndex = 1 or tempTreeNodeIndex = ame_util.invalidTreeIndex then
                nextTreeNodeIndex := ame_util.invalidTreeIndex;
                exit;
              end if;
            end loop;
          end if;
        end if;
        /* When ever we reach this point we come with a valid node which needs     */
        /* be processed by the next pass of the loop. If no valid node is present  */
        /* this indicates that the entire tree is traversed and there are no more  */
        /* approvers to find                                                       */
        exit when nextTreeNodeIndex = ame_util.invalidTreeIndex;
      end loop;
      if copyAncillaryData and nextApproversType < 4 then
        ame_engine.prepareItemData(approverIndexesIn  => tempApproverIndexes
                                  ,itemIndexesOut     => itemIndexesOut
                                  ,itemItemClassesOut => itemClassesOut
                                  ,itemIdsOut         => itemIdsOut
                                  ,itemSourcesOut     => itemSourcesOut);
        if nextApproversType = 2 or nextApproversType = 3 then
          preparePerApproverProductions
                  (approverIndexesIn   => tempApproverIndexes
                  ,itemIndexesIn       => itemIndexesOut
                  ,itemSourcesIn       => itemSourcesOut
                  ,prodIndexesOut      => productionIndexesOut
                  ,productionNamesOut  => variableNamesOut
                  ,productionValuesOut => variableValuesOut);
        end if;
      end if;
      if nextApproversType = 3 then
        getTransVariableNames(transVariableNamesOut => transVariableNamesOut);
        getTransVariableValues(transVariableValuesOut => transVariableValuesOut);
      end if;
      if flagApproversAsNotifiedIn  = ame_util.booleanTrue then
        ameApplicationId := ame_engine.getAmeApplicationId;
        for i in 1 .. nextApproversOut.count loop
            update ame_temp_old_approver_lists
               set approval_status = ame_util.notifiedStatus
             where item_class = nextApproversOut(i).item_class
               and item_id = nextApproversOut(i).item_id
               and name = nextApproversOut(i).name
               and action_type_id = nextApproversOut(i).action_type_id
               and group_or_chain_id = nextApproversOut(i).group_or_chain_id
               and occurrence = nextApproversOut(i).occurrence
               and transaction_id = transactionIdIn
               and application_id = ameApplicationId;
           /* Insert into Approval Notification History Table */
          insertIntoTransApprovalHistory
            (transactionIdIn         => transactionIdIn
            ,applicationIdIn         => ameApplicationId
            ,orderNumberIn           => nextApproversOut(i).approver_order_number
            ,nameIn                  => nextApproversOut(i).name
            ,appCategoryIn           => nextApproversOut(i).approver_category
            ,itemClassIn             => nextApproversOut(i).item_class
            ,itemIdIn                => nextApproversOut(i).item_id
            ,actionTypeIdIn          => nextApproversOut(i).action_type_id
            ,authorityIn             => nextApproversOut(i).authority
            ,statusIn                => ame_util.notifiedStatus
            ,grpOrChainIdIn          => nextApproversOut(i).group_or_chain_id
            ,occurrenceIn            => nextApproversOut(i).occurrence
            ,apiInsertionIn          => nextApproversOut(i).api_insertion
            ,memberOrderNumberIn     => nextApproversOut(i).member_order_number
            ,notificationIdIn        => null
            ,userCommentsIn          => null
            ,dateClearedIn           => null
            ,historyTypeIn           => 'APPROVERPRESENT');
        end loop;
      end if;
      if tempPrepareItemData then
        for x in 1 .. nextApproversOut.count loop
          if engStApprovers(tempApproverIndexes(x)).item_class is null then
            nextApproversOut(x).item_class := null;
            nextApproversOut(x).item_id    := null;
            nextApproversOut(x).source     := null;
          end if;
        end loop;
      end if;
      for x in 1 .. nextApproversOut.count loop
        if nextApproversOut(x).approval_status = ame_util.repeatedStatus then
          nextApproversOut(x).approval_status := null;
        end if;
      end loop;
      ame_engine.unlockTransaction(fndApplicationIdIn  => applicationIdIn,
                                   transactionIdIn     => transactionIdIn,
                                   transactionTypeIdIn => transactionTypeIn);
    exception
      when others then
        ame_engine.unlockTransaction(fndApplicationIdIn  => applicationIdIn,
                                     transactionIdIn     => transactionIdIn,
                                     transactionTypeIdIn => transactionTypeIn);
        ame_util.runtimeException(packageNameIn => 'ame_engine',
                                  routineNameIn => 'getNextApprovers',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        approvalProcessCompleteYNOut:= null;
        nextApproversOut.delete;
        raise;
  end getNextApprovers;
  procedure prepareItemData(approverIndexesIn  in ame_util.idList default ame_util.emptyIdList
                           ,itemIndexesOut     out nocopy ame_util.idList
                           ,itemItemClassesOut out nocopy ame_util.stringList
                           ,itemIdsOut         out nocopy ame_util.stringList
                           ,itemSourcesOut     out nocopy ame_util.longStringList) as
    tempItemCount integer;
    tempItemClass ame_util.stringType;
    tempItemId    ame_util.stringType;
    tempRuleIdList ame_util.idList;
    prevIndex       integer;
    currentIndex    integer;
    currentApproverIndex integer;
    tempIndex       integer;
    tempSourceDescription ame_util.longStringType;
    tempLength      integer;
    tempFlag        boolean;
    tempCount       integer;
    tempFlag2       boolean;
    tempProcessApprover  boolean;
    tempProcessApprover2 boolean;
    begin
      tempItemCount := 0;
      prevIndex := null;
      tempCount := approverIndexesIn.count;
      tempFlag2 := false;
      if tempCount = 0 then
        tempFlag2  := true;
        tempCount := engStApprovers.count;
      end if;
      /* here tempFlag2 = false indicates the procedure invoked from getNextApprovers*/
      for i in 1 .. tempCount loop
        if tempFlag2 then
          currentApproverIndex := i;
        else
          currentApproverIndex := approverIndexesIn(i);
        end if;
        tempProcessApprover := false;
        tempProcessApprover2 := false;
        if not tempFlag2 then
          tempProcessApprover := true;
        else
          if ( engStApprovers(currentApproverIndex).approval_status is null
                or engStApprovers(currentApproverIndex).approval_status
                          not in (ame_util.notifiedByRepeatedStatus
                                 ,ame_util.approvedByRepeatedStatus
                                 ,ame_util.rejectedByRepeatedStatus
                                 ,ame_util.suppressedStatus
                                 ,ame_util.repeatedStatus) ) then
          tempProcessApprover := true;
          end if;
        end if;
        if tempProcessApprover then
          for j in 1 .. engStRepeatedIndexes.count loop
            if engStRepeatedIndexes(j) = currentApproverIndex
                and engStRepeatedAppIndexes(j) = currentApproverIndex then
              tempItemClass := engStApprovers(currentApproverIndex).item_class;
              tempItemId    := engStApprovers(currentApproverIndex).item_id;
            end if;
          end loop;
          for j in 1 .. engStRepeatedIndexes.count loop
            if engStRepeatedIndexes(j) = currentApproverIndex
                and engStRepeatedAppIndexes(j) <> currentApproverIndex then
              if tempItemClass <> engStApprovers(engStRepeatedAppIndexes(j)).item_class
                  or tempItemId <> engStApprovers(engStRepeatedAppIndexes(j)).item_id then
                tempProcessApprover2 := true;
              end if;
            end if;
          end loop;
        end if;
        if tempProcessApprover2 then
          prevIndex := null;
          for j in 1 .. engStRepeatedIndexes.count loop
            if engStRepeatedIndexes(j) = currentApproverIndex then
              currentIndex := engStRepeatedAppIndexes(j);
            if (currentApproverIndex = currentIndex)
                or
               (engStApprovers(currentIndex).item_id <> tempItemId
                 or engStApprovers(currentIndex).item_class <> tempItemClass) then
              tempItemCount := tempItemCount + 1;
              itemIndexesOut(tempItemCount) := i;
              tempFlag := true;
              itemItemClassesOut(tempItemCount) := engStApprovers(currentIndex).item_class;
              itemIdsOut(tempItemCount) := engStApprovers(currentIndex).item_id;
              prevIndex := tempItemCount;
            end if;
            tempSourceDescription := null;
            tempRuleIdList.delete;
            ame_util.parseSourceValue(sourceValueIn => engStApprovers(currentIndex).source
                                     ,sourceDescriptionOut => tempSourceDescription
                                     ,ruleIdListOut => tempRuleIdList);
            for z in 1 .. tempRuleIdList.count loop
              if itemSourcesOut.count >= tempItemCount then
                tempIndex := instrb(itemSourcesOut(tempItemCount),tempRuleIdList(z));
              else
                itemSourcesOut(tempItemCount) := null;
                tempIndex := -1;
              end if;
              if tempIndex = -1 then
                ame_util.appendRuleIdToSource(ruleIdIn => tempRuleIdList(z)
                                             ,sourceInOut => itemSourcesOut(tempItemCount));
              end if;
            end loop;
            end if;
          end loop;
        end if;
        if tempFlag and (not engIsLocalTransaction)then
          tempFlag := false;
          engStApprovers(currentApproverIndex).item_class := null;
          engStApprovers(currentApproverIndex).item_id    := null;
          engStApprovers(currentApproverIndex).source     := null;
        end if;
      end loop;
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_engine',
                                  routineNameIn => 'prepareItemData',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        itemIndexesOut.delete;
        itemItemClassesOut.delete;
        itemIdsOut.delete;
        itemSourcesOut.delete;
        raise;
  end prepareItemData;
  procedure preparePerApproverProductions
           (approverIndexesIn    in ame_util.idList default ame_util.emptyIdList
           ,itemIndexesIn        in ame_util.idList default ame_util.emptyIdList
           ,itemSourcesIn        in ame_util.longStringList default ame_util.emptyLongStringList
           ,prodIndexesOut      out nocopy ame_util.idList
           ,productionNamesOut  out nocopy ame_util.stringList
           ,productionValuesOut out nocopy ame_util.stringList) as
    tempRuleIdList ame_util.idList;
    tempSourceDescription ame_util.stringType;
    hasRepeatedOccurrences boolean;
    currentRepeatedFirstIndex integer;
    currentIndex integer;
    tempCount integer;
    tempPerAppProdIndex integer;
    tempProdIndex  integer;
    tempFlag2 boolean;
    tempCount2 integer;
    currentApproverIndex integer;
    begin
      if not engProcessProductionActions then
        return;
      end if;
      tempProdIndex  := 0;
      tempPerAppProdIndex := 0;
      tempCount := 1;
      tempCount2 := approverIndexesIn.count;
      tempFlag2 := false;
      if tempCount2 = 0 then
        tempFlag2  := true;
        tempCount2 := engStApprovers.count;
      end if;
      /* here tempFlag2 = false indicates the procedure invoked from getNextApprovers */
      for i in 1 .. tempCount2 loop
        hasRepeatedOccurrences := false;
        currentRepeatedFirstIndex := -1;
        tempRuleIdList.delete;
        tempSourceDescription := null;
        tempCount := 1;
        if tempFlag2 then
          currentApproverIndex := i;
        else
          currentApproverIndex := approverIndexesIn(i);
        end if;
        if tempFlag2 then
          if engStApprovers(currentApproverIndex).item_class is null then
            tempCount := 0;
            for x in 1 .. engStItemIndexes.count loop
              if engStItemIndexes(x) = currentApproverIndex then
                tempCount := tempCount + 1;
                if currentRepeatedFirstIndex = -1 then
                  currentRepeatedFirstIndex := x;
                end if;
              end if;
            end loop;
            hasRepeatedOccurrences := true;
          end if;
        else
          tempCount := 0;
          for x in 1 .. itemIndexesIn.count loop
            if itemIndexesIn(x) = i then
                tempCount := tempCount + 1;
                if currentRepeatedFirstIndex = -1 then
                  currentRepeatedFirstIndex := x;
                end if;
            end if;
          end loop;
          if currentRepeatedFirstIndex <> -1 then
            hasRepeatedOccurrences := true;
          else
            hasRepeatedOccurrences := false;
            tempCount := 1;
          end if;
        end if;
        currentIndex := 0;
        for j in 1 .. tempCount loop
          if hasRepeatedOccurrences then
            currentIndex := (currentRepeatedFirstIndex+j)-1;
          else
            currentIndex := currentApproverIndex;
          end if;
          tempSourceDescription := null;
          tempRuleIdList.delete;
          if hasRepeatedOccurrences then
            if tempFlag2 then
              ame_util.parseSourceValue(sourceValueIn => engStItemSources(currentIndex),
                                        sourceDescriptionOut => tempSourceDescription,
                                        ruleIdListOut => tempRuleIdList);
            else
              ame_util.parseSourceValue(sourceValueIn => itemSourcesIn(currentIndex),
                                        sourceDescriptionOut => tempSourceDescription,
                                        ruleIdListOut => tempRuleIdList);
            end if;
          else
            ame_util.parseSourceValue(sourceValueIn => engStApprovers(currentIndex).source,
                                      sourceDescriptionOut => tempSourceDescription,
                                      ruleIdListOut => tempRuleIdList);
          end if;
            for k in 1 .. tempRuleIdList.count loop
              if(engAppPerAppProdFirstIndexes.exists(tempRuleIdList(k))) then
                tempPerAppProdIndex := engAppPerAppProdFirstIndexes(tempRuleIdList(k));
                loop
                  tempProdIndex := tempProdIndex + 1;
                  prodIndexesOut(tempProdIndex) := i;
                  productionNamesOut(tempProdIndex) := engAppPerAppProdVariableNames(tempPerAppProdIndex);
                  productionValuesOut(tempProdIndex) := engAppPerAppProdVariableValues(tempPerAppProdIndex);
                  tempPerAppProdIndex := tempPerAppProdIndex + 1;
                  if(not engAppPerAppProdRuleIds.exists(tempPerAppProdIndex) or
                   engAppPerAppProdRuleIds(tempPerAppProdIndex) <> tempRuleIdList(k)) then
                    exit;
                  end if;
                end loop;
              end if;
            end loop;
        end loop;
      end loop;
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_engine',
                                  routineNameIn => 'preparePerApproverProductions',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        prodIndexesOut.delete;
        productionNamesOut.delete;
        productionValuesOut.delete;
        raise;
  end preparePerApproverProductions;
  procedure prepareRuleData as
    tempRuleIdList ame_util.idList;
    tempEngStRuleIndex integer;
    tempSourceDescription ame_util.stringType;
    hasRepeatedOccurrences boolean;
    currentRepeatedFirstIndex integer;
    currentIndex integer;
    tempCount integer;
    tempEngStProdIndex  integer;
    begin
      if not (engPrepareRuleIds
               or engPrepareRuleDescs ) then
        return;
      end if;
      tempEngStRuleIndex  := 0;
      tempCount := 1;
      for i in 1 .. engStApprovers.count loop
        hasRepeatedOccurrences := false;
        currentRepeatedFirstIndex := -1;
        tempRuleIdList.delete;
        tempSourceDescription := null;
        tempCount := 1;
        if engStApprovers(i).item_class is null then
          tempCount := 0;
          for x in 1 .. engStItemIndexes.count loop
            if engStItemIndexes(x) = i then
              tempCount := tempCount + 1;
              if currentRepeatedFirstIndex = -1 then
                currentRepeatedFirstIndex := x;
              end if;
            end if;
          end loop;
          hasRepeatedOccurrences := true;
        end if;
        currentIndex := 0;
        for j in 1 .. tempCount loop
          if hasRepeatedOccurrences then
            currentIndex := (currentRepeatedFirstIndex+j)-1;
          else
            currentIndex := i;
          end if;
          tempSourceDescription := null;
          tempRuleIdList.delete;
          if hasRepeatedOccurrences then
            ame_util.parseSourceValue(sourceValueIn => engStItemSources(currentIndex),
                                      sourceDescriptionOut => tempSourceDescription,
                                      ruleIdListOut => tempRuleIdList);
          else
            ame_util.parseSourceValue(sourceValueIn => engStApprovers(currentIndex).source,
                                      sourceDescriptionOut => tempSourceDescription,
                                      ruleIdListOut => tempRuleIdList);
          end if;
          if(tempRuleIdList.count = 0) then
            tempEngStRuleIndex := tempEngStRuleIndex + 1;
            engStRuleIndexes(tempEngStRuleIndex) := i;
            engStSourceTypes(tempEngStRuleIndex) := tempSourceDescription;
            if(engPrepareRuleIds) then
              engStRuleIds(tempEngStRuleIndex) := null;
            end if;
            if(engPrepareRuleDescs) then
              engStRuleDescriptions(tempEngStRuleIndex) := null;
            end if;
          else
            for k in 1 .. tempRuleIdList.count loop
              tempEngStRuleIndex := tempEngStRuleIndex + 1;
              engStRuleIndexes(tempEngStRuleIndex) := i;
              engStSourceTypes(tempEngStRuleIndex) := tempSourceDescription;
              if(engPrepareRuleIds) then
                engStRuleIds(tempEngStRuleIndex) := tempRuleIdList(k);
              end if;
              if(engPrepareRuleDescs) then
                engStRuleDescriptions(tempEngStRuleIndex) :=
                  ame_rule_pkg.getDescription(ruleIdIn => tempRuleIdList(k),
                                              processingDateIn => engEffectiveRuleDate);
              end if;
            end loop;
          end if;
        end loop;
      end loop;
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_engine',
                                  routineNameIn => 'prepareRuleData',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        engStRuleDescriptions.delete;
        engStRuleIds.delete;
        engStRuleIndexes.delete;
        raise;
  end prepareRuleData;
  procedure getProductionIndexes(productionIndexesOut out nocopy ame_util.idList) as
    begin
      for i in 1 .. engStProductionIndexes.count loop
        productionIndexesOut(i) := engStProductionIndexes(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getProductionIndexes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getProductionIndexes;
  procedure getRepeatedIndexes(repeatedIndexesOut out nocopy ame_util.idList
                              ,repeatedAppIndexesOut out nocopy ame_util.idList) as
    begin
      for i in 1 .. engStRepeatedIndexes.count loop
        repeatedIndexesOut(i) := engStRepeatedIndexes(i);
      end loop;
      for i in 1 .. engStRepeatedAppIndexes.count loop
        repeatedAppIndexesOut(i) := engStRepeatedAppIndexes(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getRepeatedIndexes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getRepeatedIndexes;
  procedure getRuleDescriptions(ruleDescriptionsOut out nocopy ame_util.stringList) as
    begin
      for i in 1 .. engStRuleDescriptions.count loop
        ruleDescriptionsOut(i) := engStRuleDescriptions(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getRuleDescriptions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getRuleDescriptions;
  procedure getRuleIds(ruleIdsOut out nocopy ame_util.idList) as
    begin
      for i in 1 .. engStRuleIds.count loop
        ruleIdsOut(i) := engStRuleIds(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getRuleIds',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getRuleIds;
  procedure getRuleIndexes(ruleIndexesOut out nocopy ame_util.idList) as
    begin
      for i in 1 .. engStRuleIndexes.count loop
        ruleIndexesOut(i) := engStRuleIndexes(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getRuleIndexes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getRuleIndexes;
  procedure getRuntimeGroupMembers(groupIdIn in integer,
                                   approverNamesOut out nocopy ame_util.longStringList,
                                   approverOrderNumbersOut out nocopy ame_util.idList,
                                   approverDisplayNamesOut out nocopy ame_util.longStringList,
                                   origSystemIdsOut out nocopy ame_util.idList,
                                   origSystemsOut out nocopy ame_util.stringList) as
    firstNewIndex integer;
    tempIndex integer;
    begin
      tempIndex := 0; /* pre-increment */
      -- Check if group is defined or has to be re run for every item class/item ID
      if(not engGroupUseItemBind.exists(groupIdIn)) then
        fetchRuntimeGroup(groupIdIn => groupIdIn);
      elsif (engGroupUseItemBind(groupIdIn) = ame_util.booleanTrue) then
        fetchRuntimeGroup(groupIdIn => groupIdIn);
      end if;
      for i in 1 .. engGroupMemberGroupIds.count loop
        if(engGroupMemberGroupIds(i) = groupIdIn) then
          tempIndex := tempIndex + 1;
          approverNamesOut(tempIndex) := engGroupMemberNames(i);
          approverOrderNumbersOut(tempIndex) := engGroupMemberOrderNumbers(i);
          approverDisplayNamesOut(tempIndex) := engGroupMemberDisplayNames(i);
          origSystemsOut(tempIndex) := engGroupMemberOrigSystems(i);
          origSystemIdsOut(tempIndex) := engGroupMemberOrigSystemIds(i);
        elsif(tempIndex > 0) then /* We found and have passed the group. */
          exit;
        end if;
      end loop;
      /*
        If the group is the last one in the engGroup package variables, the above loop
        will never arrive at its exit statement, so we need to check for a found group
        outside the loop.
      */
      if(tempIndex > 0) then
        return;
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getRuntimeGroupMembers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getRuntimeGroupMembers;
  procedure getSourceTypes(sourceTypesOut out nocopy ame_util.stringList) as
    begin
      for i in 1 .. engStSourceTypes.count loop
        sourceTypesOut(i) := engStSourceTypes(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getSourceTypes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getSourceTypes;
  procedure getTestTransApplicableRules(ruleItemClassIdsOut out nocopy ame_util.idList,
                                        itemClassIdsOut out nocopy ame_util.idList,
                                        itemIdsOut out nocopy ame_util.stringList,
                                        ruleIdsOut out nocopy ame_util.idList,
                                        ruleTypesOut out nocopy ame_util.idList,
                                        ruleDescriptionsOut out nocopy ame_util.stringList) as
    headerItemClassId integer;
    switchRows boolean;
    tempIndex integer;
    tempItemClassId integer;
    tempItemId ame_util.stringType;
    tempRuleDescription ame_util.stringType;
    tempRuleId integer;
    tempRuleItemClassId integer;
    tempRuleNotFound boolean;
    tempRuleType integer;
    begin
      headerItemClassId := ame_admin_pkg.getItemClassIdByName(itemClassNameIn => ame_util.headerItemClassName);
      /* First populate the output lists, eliminating duplicate rules. */
      tempIndex := 0; /* pre-increment */
      for i in 1 .. engAppRuleIds.count loop
        tempRuleNotFound := true;
        for j in 1 .. (i - 1) loop
          if(engAppRuleIds(j) = engAppRuleIds(i) and
             engAppItemClassIds(i) = engAppItemClassIds(j) and
             engAppItemIds(i) = engAppItemIds(j)) then
            tempRuleNotFound := false;
            exit;
          end if;
        end loop;
        if(tempRuleNotFound) then
          tempIndex := tempIndex + 1;
          ruleIdsOut(tempIndex) := engAppRuleIds(i);
          itemClassIdsOut(tempIndex) := engAppItemClassIds(i);
          itemIdsOut(tempIndex) := engAppItemIds(i);
          ruleTypesOut(tempIndex) := ame_rule_pkg.getRuleType(ruleIdIn => engAppRuleIds(i),
                                                              processingDateIn => engEffectiveRuleDate);
          ruleItemClassIdsOut(tempIndex) := ame_rule_pkg.getItemClassId(ruleIdIn => engAppRuleIds(i),
                                                                        processingDateIn => engEffectiveRuleDate);
          ruleDescriptionsOut(tempIndex) := ame_rule_pkg.getDescription(ruleIdIn => engAppRuleIds(i),
                                                                        processingDateIn => engEffectiveRuleDate);
        end if;
      end loop;
      /*
        Now sort the output lists.  The header-level rules come first, then all other rules.  Among
        the header-level rules, sort first by ruleTypesOut, then by itemClassIdsOut, then by itemIdsOut.
        (The sort by item class and item ID is only relevant under per-item evaluation, but it's harmless
        otherwise, and efficiency is not a concern here.)  Among the non-header-level rules, sort first
        by ruleItemClassIdsOut, then by itemClassIdsOut, then by itemIdsOut, then by ruleTypesOut.
      */
      for i in 2 .. ruleItemClassIdsOut.count loop
        for j in 1 .. (i - 1) loop
          if(ruleItemClassIdsOut(j) = headerItemClassId and
             ruleItemClassIdsOut(i) = headerItemClassId) then
            if(ruleTypesOut(i) > ruleTypesOut(j)) then
              switchRows := false;
            elsif(ruleTypesOut(i) < ruleTypesOut(j)) then
              switchRows := true;
            else /* ruleTypesOut(i) = ruleTypesOut(j) */
              if(itemClassIdsOut(i) > itemClassIdsOut(j)) then
                switchRows := false;
              elsif(itemClassIdsOut(i) < itemClassIdsOut(j)) then
                switchRows := true;
              else /* itemClassIdsOut(i) = itemClassIdsOut(j) */
                if(itemIdsOut(i) > itemIdsOut(j)) then
                  switchRows := false;
                elsif(itemIdsOut(i) < itemIdsOut(j)) then
                  switchRows := true;
                else /* itemIdsOut(i) = itemIdsOut(j) */
                  switchRows := false;
                end if;
              end if;
            end if;
          elsif(ruleItemClassIdsOut(j) = headerItemClassId and
                (ruleItemClassIdsOut(i) is null or
                 ruleItemClassIdsOut(i) <> headerItemClassId)) then
            switchRows := false;
          elsif((ruleItemClassIdsOut(j) is null or
                 ruleItemClassIdsOut(j) <> headerItemClassId) and
                ruleItemClassIdsOut(i) = headerItemClassId) then
            switchRows := true;
          else /* ruleItemClassIdsOut(j) <> headerItemClassId and ruleItemClassIdsOut(i) <> headerItemClassId */
            if(ruleItemClassIdsOut(i) > ruleItemClassIdsOut(j) or
               (ruleItemClassIdsOut(i) is null and ruleItemClassIdsOut(j) is not null)) then
              switchRows := false;
            elsif(ruleItemClassIdsOut(i) < ruleItemClassIdsOut(j) or
                  (ruleItemClassIdsOut(i) is not null and ruleItemClassIdsOut(j) is null)) then
              switchRows := true;
            else /* ruleItemClassIdsOut(i) = ruleItemClassIdsOut(j) or both are null */
              if(itemClassIdsOut(i) > itemClassIdsOut(j)) then
                switchRows := false;
              elsif(itemClassIdsOut(i) < itemClassIdsOut(j)) then
                switchRows := true;
              else /* itemClassIdsOut(i) = itemClassIdsOut(j) */
                if(itemIdsOut(i) > itemIdsOut(j)) then
                  switchRows := false;
                elsif(itemIdsOut(i) < itemIdsOut(j)) then
                  switchRows := true;
                else /* itemIdsOut(i) = itemIdsOut(j) */
                  switchRows := false;
                end if;
              end if;
            end if;
          end if;
          if(switchRows) then
            /* Assign i values to temp buffers. */
            tempRuleItemClassId := ruleItemClassIdsOut(i);
            tempItemClassId := itemClassIdsOut(i);
            tempItemId := itemIdsOut(i);
            tempRuleId := ruleIdsOut(i);
            tempRuleType := ruleTypesOut(i);
            tempRuleDescription := ruleDescriptionsOut(i);
            /* Assign j values to i values. */
            ruleItemClassIdsOut(i) := ruleItemClassIdsOut(j);
            itemClassIdsOut(i) := itemClassIdsOut(j);
            itemIdsOut(i) := itemIdsOut(j);
            ruleIdsOut(i) := ruleIdsOut(j);
            ruleTypesOut(i) := ruleTypesOut(j);
            ruleDescriptionsOut(i) := ruleDescriptionsOut(j);
            /* Assign temp buffers to j values. */
            ruleItemClassIdsOut(j) := tempRuleItemClassId;
            itemClassIdsOut(j) := tempItemClassId;
            itemIdsOut(j) := tempItemId;
            ruleIdsOut(j) := tempRuleId;
            ruleTypesOut(j) := tempRuleType;
            ruleDescriptionsOut(j) := tempRuleDescription;
          end if;
        end loop;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getTestTransApplicableRules',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getTestTransApplicableRules;
  procedure getTestTransApprovers(isTestTransactionIn in boolean,
                                  transactionIdIn in varchar2,
                                  ameApplicationIdIn in integer,
                                  approverListStageIn in integer,
                                  approversOut out nocopy ame_util.approversTable2,
                                  productionIndexesOut out nocopy ame_util.idList,
                                  variableNamesOut out nocopy ame_util.stringList,
                                  variableValuesOut out nocopy ame_util.stringList) as
    tempCount integer;
    begin
      if(not isTestTransactionIn) then
        /*
          Make sure a real transaction gets logged and its state initialized.  (This is usually
          only necessary for "real" transactions created for debugging purposes.)
        */
        select count(*)
          into tempCount
          from ame_temp_transactions
          where
            application_id = ameApplicationIdIn and
            transaction_id = transactionIdIn and
            rownum < 2; /* Avoids second fetch otherwise required by ANSI standard to check for too many rows. */
        if(tempCount = 0) then
          insert into ame_temp_transactions(
            application_id,
            transaction_id,
            row_timestamp) values(
              ameApplicationIdIn,
              transactionIdIn,
              sysdate); /* Don't use engEffectiveRuleDate here. */
          updateTransactionState(isTestTransactionIn => false,
                                 isLocalTransactionIn => true,
                                 fetchConfigVarsIn => true,
                                 fetchOldApproversIn => true,
                                 fetchInsertionsIn => true,
                                 fetchDeletionsIn => true,
                                 fetchAttributeValuesIn => true,
                                 fetchInactiveAttValuesIn => false,
                                 processProductionActionsIn => false,
                                 processProductionRulesIn => false,
                                 updateCurrentApproverListIn => true,
                                 updateOldApproverListIn => true,
                                 processPrioritiesIn => true,
                                 prepareItemDataIn => true,
                                 prepareRuleIdsIn => true,
                                 prepareRuleDescsIn => false,
                                 prepareApproverTreeIn => true,
                                 transactionIdIn => transactionIdIn,
                                 ameApplicationIdIn => ameApplicationIdIn);
        end if;
      end if;
      setContext(isTestTransactionIn => isTestTransactionIn,
                 isLocalTransactionIn => true,
                 fetchConfigVarsIn => true,
                 fetchOldApproversIn => true,
                 fetchInsertionsIn => approverListStageIn > 1,
                 fetchDeletionsIn => approverListStageIn > 2,
                 fetchAttributeValuesIn => true,
                 fetchInactiveAttValuesIn => false,
                 processProductionActionsIn => true,
                 processProductionRulesIn => true,
                 updateCurrentApproverListIn => true,
                 updateOldApproverListIn => true,
                 processPrioritiesIn => true,
                 prepareItemDataIn => true,
                 prepareRuleIdsIn => true,
                 prepareRuleDescsIn => false,
                 prepareApproverTreeIn => true,
                 transactionIdIn => transactionIdIn,
                 ameApplicationIdIn => ameApplicationIdIn);
      evaluateRules;
      fetchApplicableActions;
      processExceptions;
      processRules;
      if(approverListStageIn > 1 and not isTestTransactionIn) then
        processAdHocInsertions;
        processUnresponsiveApprovers;
      end if;
      if(approverListStageIn > 2 and not isTestTransactionIn) then
        if engRepeatSubstitutions  then
          repeatSubstitutions;
        end if;
      end if;
      if(approverListStageIn > 3 and not isTestTransactionIn) then
        processSuppressions;
      end if;
      if(approverListStageIn > 4) then
        processRepeatedApprovers;
      end if;
      if(approverListStageIn > 5) then
        calculateApproverOrderNumbers;
      end if;
      populateEngStVariables;
      getApprovers(approversOut => approversOut);
      getProductionIndexes(productionIndexesOut => productionIndexesOut);
      getVariableNames(variableNamesOut=> variableNamesOut);
      getVariableValues(variableValuesOut => variableValuesOut);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getTestTransApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getTestTransApprovers;
  procedure getTransVariableNames(transVariableNamesOut out nocopy ame_util.stringList) as
    tempIndex integer;
    begin
      tempIndex := 1;
      for i in 1 .. engStProductionsTable.count loop
        if engStProductionsTable(i).item_class = ame_util.headerItemClassName and
         engStProductionsTable(i).item_id = engTransactionId then
          transVariableNamesOut(tempIndex) := engStProductionsTable(i).variable_name;
          tempIndex := tempIndex + 1;
        end if;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getTransVariableNames',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getTransVariableNames;
  procedure getTransVariableValues(transVariableValuesOut out nocopy ame_util.stringList) as
    tempIndex integer;
    begin
      tempIndex := 1;
      for i in 1 .. engStProductionsTable.count loop
        if engStProductionsTable(i).item_class = ame_util.headerItemClassName and
         engStProductionsTable(i).item_id = engTransactionId then
          transVariableValuesOut(tempIndex) := engStProductionsTable(i).variable_value;
          tempIndex := tempIndex + 1;
        end if;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getTransVariableValues',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getTransVariableValues;
  procedure getVariableNames(variableNamesOut out nocopy ame_util.stringList) as
    begin
      for i in 1 .. engStVariableNames.count loop
        variableNamesOut(i) := engStVariableNames(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getVariableNames',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getVariableNames;
  procedure getVariableValues(variableValuesOut out nocopy ame_util.stringList) as
    begin
      for i in 1 .. engStVariableValues.count loop
        variableValuesOut(i) := engStVariableValues(i);
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'getVariableValues',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getVariableValues;
  /* initializePlsqlContext is for amem0013.sql backwards compatibility only.  Do not use it elsewhere. */
  procedure initializePlsqlContext(ameApplicationIdIn in integer default null,
                                   fndApplicationIdIn in integer default null,
                                   transactionIdIn in varchar2 default null,
                                   transactionTypeIdIn in varchar2 default null,
                                   fetchConfigVarsIn in boolean default true,
                                   fetchOldApproversIn in boolean default true,
                                   fetchInsertionsIn in boolean default true,
                                   fetchDeletionsIn in boolean default true,
                                   fetchAttributeValuesIn in boolean default true,
                                   fetchInactiveAttValuesIn in boolean default false) as
    begin
      setContext(isTestTransactionIn => false,
                 isLocalTransactionIn => true,
                 fetchConfigVarsIn => true,
                 fetchOldApproversIn => true,
                 fetchInsertionsIn => true,
                 fetchDeletionsIn => true,
                 fetchAttributeValuesIn => true,
                 fetchInactiveAttValuesIn => false,
                 processProductionActionsIn => false,
                 processProductionRulesIn => false,
                 updateCurrentApproverListIn => true,
                 updateOldApproverListIn => true,
                 processPrioritiesIn => true,
                 prepareItemDataIn => false,
                 prepareRuleIdsIn => false,
                 prepareRuleDescsIn => false,
                 prepareApproverTreeIn => false,
                 transactionIdIn => transactionIdIn,
                 ameApplicationIdIn => ameApplicationIdIn,
                 fndApplicationIdIn => null,
                 transactionTypeIdIn => transactionTypeIdIn);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'initializePlsqlContext',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end initializePlsqlContext;
  procedure updateDeviationList( sourceIndexIn in number
                              ,targetIndexIn in number) as
  begin
   if engDeviationResultList.exists(sourceIndexIn) then
     engDeviationResultList(targetIndexIn) := engDeviationResultList(sourceIndexIn);
     engDeviationResultList.delete(sourceIndexIn);
   else
     return;
   end if;
  exception
    when others then
      ame_util.runtimeException(packageNameIn => 'ame_engine',
                                routineNameIn => 'updateDeviationList',
                                exceptionNumberIn => sqlcode,
                                exceptionStringIn => sqlerrm);
  end updateDeviationList;
  procedure insertApprover(indexIn in integer,
                           approverIn in ame_util.approverRecord2,
                           adjustMemberOrderNumbersIn in boolean default false,
                           approverLocationIn in boolean default ame_util.lastAmongEquals,
                           inserteeIndexIn in number default null,
                           currentInsIndex in integer default null) as
    engStApproversCount integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    indexException exception;
    lastIndex integer;
    nextIndex integer;
    nextIndexInChain boolean;
    previousIndex integer;
    previousIndexInChain boolean;
    tempVotingRegime     varchar2(1);
    approverTreeIndex    integer;
    l_insIndex number;
    begin
      checkApprover(approverIn => approverIn);
      engStApproversCount := engStApprovers.count;
      if(indexIn < 1 or
         indexIn > engStApproversCount + 1) then
        raise indexException;
      end if;
      nextIndex := indexIn + 1;
      previousIndex := indexIn - 1;
      if(engStApproversCount < nextIndex) then
        lastIndex := engStApproversCount;
      else
        lastIndex := nextIndex;
      end if;
      /* Move any existing approvers at and above the target index. */
      /*
        It's necessary to initialize a new record at the end of engStApprovers,
        for ame_util.copyApproverRecord2 to work in the loop below.
      */
      engStApprovers(engStApproversCount + 1) := ame_util.emptyApproverRecord2;
      for i in reverse indexIn .. engStApproversCount loop
        ame_util.copyApproverRecord2(approverRecord2In => engStApprovers(i),
                                     approverRecord2Out => engStApprovers(i + 1));

        l_insIndex := engInsApproverIndex.first;
        if l_insIndex is not null then
          loop
            if engInsApproverIndex(l_insIndex) = i then
              engInsApproverIndex(l_insIndex) := null;
              engInsApproverIndex(l_insIndex) := i+1;
            end if;
            exit when l_insIndex = engInsApproverIndex.last;
            l_insIndex := engInsApproverIndex.next(l_insIndex);
          end loop;
        end if;
      end loop;
      /* Copy the input approver to the target index. */
      ame_util.copyApproverRecord2(approverRecord2In => approverIn,
                                   approverRecord2Out => engStApprovers(indexIn));
      /*
       If the status is not available in ame_temp_insertions get it from
       ame_temp_old_approver_lists
      */
      if engStApprovers(indexIn).approval_status is null then
        engStApprovers(indexIn).approval_status :=  getHandlerApprovalStatus(approverIn => engStApprovers(indexIn));
      end if;
      engStApproversCount := engStApproversCount + 1;
      /* Optionally adjust member_order_number values in the target group or chain. */
      if(adjustMemberOrderNumbersIn) then
        if(indexIn = 1 or
           engStApprovers(previousIndex).group_or_chain_id <> approverIn.group_or_chain_id or
           engStApprovers(previousIndex).action_type_id <> approverIn.action_type_id or
           engStApprovers(previousIndex).item_id <> approverIn.item_id or
           engStApprovers(previousIndex).item_class <> approverIn.item_class) then
          previousIndexInChain := false;
        else
          previousIndexInChain := true;
        end if;
        if(indexIn = engStApprovers.count or
           engStApprovers(nextIndex).group_or_chain_id <> approverIn.group_or_chain_id or
           engStApprovers(nextIndex).action_type_id <> approverIn.action_type_id or
           engStApprovers(nextIndex).item_id <> approverIn.item_id or
           engStApprovers(nextIndex).item_class <> approverIn.item_class) then
          nextIndexInChain := false;
        else
          nextIndexInChain := true;
        end if;
        if(previousIndexInChain) then
          if(nextIndexInChain) then
            if(engStApprovers(previousIndex).member_order_number =
               engStApprovers(nextIndex).member_order_number) then
              engStApprovers(indexIn).member_order_number := engStApprovers(previousIndex).member_order_number;
            else
              engStApprovers(indexIn).member_order_number := engStApprovers(previousIndex).member_order_number + 1;
              for i in nextIndex .. engStApproversCount loop
                if(engStApprovers(i).item_class <> engStApprovers(indexIn).item_class or
                   engStApprovers(i).item_id <> engStApprovers(indexIn).item_id or
                   engStApprovers(i).action_type_id <> engStApprovers(indexIn).action_type_id or
                   engStApprovers(i).group_or_chain_id <> engStApprovers(indexIn).group_or_chain_id) then
                  exit;
                end if;
                engStApprovers(i).member_order_number := engStApprovers(i).member_order_number + 1;
              end loop;
            end if;
          else
            if(engStApprovers(previousIndex).approval_status in
             (ame_util.approveAndForwardStatus, ame_util.forwardStatus)) then
              if(engActionTypeNames(engStApprovers(previousIndex).action_type_id) in
                      (ame_util.groupChainApprovalTypeName
                      ,ame_util.preApprovalTypeName
                      ,ame_util.postApprovalTypeName )) then
                select voting_regime
                  into tempVotingRegime
                  from ame_approval_group_config
                 where approval_group_id = engStApprovers(previousIndex).group_or_chain_id
                   and application_id = engAmeApplicationId
                   and sysdate between start_date and nvl(end_Date - (1/86400), sysdate);
                if(tempVotingRegime not in (ame_util.serializedVoting
                                           ,ame_util.orderNumberVoting)) then
                  engStApprovers(indexIn).member_order_number := 1;
                else
                  engStApprovers(indexIn).member_order_number := engStApprovers(previousIndex).member_order_number + 1;
                end if;
              else
                if(engActionTypeVotingRegimes(engStApprovers(previousIndex).action_type_id) <>
                         ame_util.serializedVoting) then
                  engStApprovers(indexIn).member_order_number := 1;
                else
                  engStApprovers(indexIn).member_order_number := engStApprovers(previousIndex).member_order_number + 1;
                end if;
              end if;
            else
              engStApprovers(indexIn).member_order_number := engStApprovers(previousIndex).member_order_number + 1;
            end if;
          end if;
        else
          if(nextIndexInChain) then
            engStApprovers(indexIn).member_order_number := engStApprovers(nextIndex).member_order_number - 1;
          else
            engStApprovers(indexIn).member_order_number := 1;
          end if;
        end if;
      end if;
      if engPrepareApproverTree then
        if engStApproversTree.count = 0 then
        /* If there are no approvers in tree just add the approver                  */
          if inserteeIndexIn is not null then
            engTempReason := engInsertionReasonList(inserteeIndexIn);
            engTempDate := engInsertionDateList(inserteeIndexIn);
          end if;
          addApproverToTree
            (approverRecordIn    => engStApprovers(indexIn)
            ,approverIndexIn     => indexIn
            ,approverLocationIn  => ame_util.lastAmongEquals);
          if currentInsIndex is not null then
            engInsApproverIndex(currentInsIndex) := indexIn;
          end if;
        else
        /* If there exists approvers in the tree then if adjustMemberOrderNumbersIn */
        /* is true update the member order number in the tree                       */
        /* Add the approver to tree                                                 */
          if adjustMemberOrderNumbersIn then
            approverTreeIndex := engStApproversTree.first;
            loop
              if engStApproversTree(approverTreeIndex).approver_index >= indexIn then
                engStApproversTree(approverTreeIndex).order_number
                     := engStApprovers(engStApproversTree(approverTreeIndex).approver_index + 1).member_order_number;
              end if;
              exit when approverTreeIndex = engStApproversTree.last;
              approverTreeIndex := engStApproversTree.next(approverTreeIndex);
            end loop;
          end if;
          approverTreeIndex := engStApproversTree.first;
          loop
            if engStApproversTree(approverTreeIndex).approver_index >= indexIn then
              engStApproversTree(approverTreeIndex).approver_index := engStApproversTree(approverTreeIndex).approver_index + 1;
            end if;
            exit when approverTreeIndex = engStApproversTree.last;
            approverTreeIndex := engStApproversTree.next(approverTreeIndex);
          end loop;
          if inserteeIndexIn is not null then
            engTempReason := engInsertionReasonList(inserteeIndexIn);
            engTempDate := engInsertionDateList(inserteeIndexIn);
          end if;
          addApproverToTree
            (approverRecordIn    => engStApprovers(indexIn)
            ,approverIndexIn     => indexIn
            ,approverLocationIn  => approverLocationIn);
          if currentInsIndex is not null then
            engInsApproverIndex(currentInsIndex) := indexIn;
          end if;
        end if;
      end if;
      exception
        when indexException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400686_ENG_IDX_OUT_OF_BOU');
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'insertApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'insertApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end insertApprover;
  procedure insertApprovers(firstIndexIn in integer,
                            approversIn in ame_util.approversTable2) as
    approversInCount integer;
    engStApproversCount integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    indexException exception;
    lastIndex integer;
    newTreeNode ame_util.approverTreeRecord;
    newTreeNodeIndex integer;
    siblingTreeNodeIndex integer;
    tempIndex integer;
    loopIndex integer;
    begin
      if(firstIndexIn < 1 or
         firstIndexIn > engStApprovers.count + 1) then
        raise indexException;
      end if;
      approversInCount := approversIn.count;
      engStApproversCount := engStApprovers.count;
      /* This code was modified to fix the BUG:(4093937) */
      /* Issue 1 in the list of bugs found during the implementation of the */
      /* asynchronous parallel approver functionality */
      lastIndex := engStApproversCount;
      /* Move any existing approvers at and above firstIndexIn. */
      for i in reverse firstIndexIn .. lastIndex loop
        ame_util.copyApproverRecord2(approverRecord2In => engStApprovers(i),
                                     approverRecord2Out => engStApprovers(i + approversInCount));
      end loop;
      /* Copy the input approvers to the target indexes. */
      tempIndex := firstIndexIn; /* post-increment */
      for i in 1 .. approversInCount loop
        ame_util.copyApproverRecord2(approverRecord2In => approversIn(i),
                                     approverRecord2Out => engStApprovers(tempIndex));
        tempIndex := tempIndex + 1;
      end loop;
      /* Insert the new approvers to the tree */
      if engPrepareApproverTree then
        /* Approvers Tree is sparse */
        loopIndex := engStApproversTree.last;
        loop
          if engStApproversTree(loopIndex).approver_index >= firstIndexIn then
            engStApproversTree(loopIndex).approver_index
                                 := engStApproversTree(loopIndex).approver_index + approversIn.count;
          elsif engStApproversTree(loopIndex).approver_index = firstIndexIn - 1 then
            siblingTreeNodeIndex := engStApproversTree(loopIndex).sibling_index;
            for j in reverse 1 .. approversIn.count loop
              newTreeNode.parent_index := engStApproversTree(loopIndex).parent_index;
              newTreeNode.sibling_index := siblingTreeNodeIndex;
              newTreeNode.child_index := ame_util.noChildIndex;
              newTreeNode.order_number := approversIn(j).member_order_number;
              newTreeNode.approver_index := engStApproversTree(loopIndex).approver_index + j ;
              newTreeNode.tree_level_id := approversIn(j).name;
              newTreeNode.is_suspended := ame_util.booleanFalse;
              newTreeNode.tree_level := 6;
              newTreeNodeIndex := engStApproversTree.last + 1;
              engStApproversTree(newTreeNodeIndex) := newTreeNode;
              siblingTreeNodeIndex := newTreeNodeIndex;
            end loop;
            engStApproversTree(loopIndex).sibling_index := siblingTreeNodeIndex;
          end if;
          exit when engStApproversTree.first = loopIndex;
          loopIndex := engStApproversTree.prior(loopIndex);
        end loop;
      end if;
      exception
        when indexException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400687_ENG_FIDX_OUT_OF_BOU');
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'insertApprovers',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'insertApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end insertApprovers;
  procedure insertIntoTransApprovalHistory
              (transactionIdIn  ame_trans_approval_history.transaction_id%type
              ,applicationIdIn  ame_trans_approval_history.application_id%type
              ,orderNumberIn    ame_trans_approval_history.order_number%type
              ,nameIn           ame_trans_approval_history.name%type
              ,appCategoryIn    ame_trans_approval_history.approver_category%type
              ,itemClassIn      ame_trans_approval_history.item_class%type
              ,itemIdIn         ame_trans_approval_history.item_id%type
              ,actionTypeIdIn   ame_trans_approval_history.action_type_id%type
              ,authorityIn      ame_trans_approval_history.authority%type
              ,statusIn         ame_trans_approval_history.status%type
              ,grpOrChainIdIn   ame_trans_approval_history.group_or_chain_id%type
              ,occurrenceIn     ame_trans_approval_history.occurrence%type
              ,apiInsertionIn   ame_trans_approval_history.api_insertion%type
              ,memberorderNumberIn ame_trans_approval_history.member_order_number%type
              ,notificationIdIn ame_trans_approval_history.notification_id%type
              ,userCommentsIn   ame_trans_approval_history.user_comments%type
              ,dateClearedIn    ame_trans_approval_history.date_cleared%type
              ,historyTypeIn    varchar2) as
    tempTransHistoryId ame_trans_approval_history.trans_history_id%type;
    tempItemClass      ame_trans_approval_history.item_class%type;
    tempItemId         ame_trans_approval_history.item_id%type;
    tempOrderNumber    ame_trans_approval_history.order_number%type;
    tempAuthority      ame_trans_approval_history.authority%type;
    tempActionTypeId   ame_trans_approval_history.action_type_id%type;
    tempGroupOrChainId ame_trans_approval_history.group_or_chain_id%type;
    tempOccurrence     ame_trans_approval_history.occurrence%type;
    tempApiInsertion   ame_trans_approval_history.api_insertion%type;
    tempMemberOrderNumber ame_trans_approval_history.member_order_number%type;
    tempName           ame_trans_approval_history.name%type;
    approvers          ame_util.approversTable2;
    begin
      tempName := nameIn;
      if historyTypeIn = 'BEATBYFIRSTRESPONDER' then
        ame_engine.getApprovers(approversOut => approvers);
        for i in 1 .. approvers.count loop
          if (approvers(i).name <> nameIn or approvers(i).occurrence <> occurrenceIn)
            and approvers(i).item_class = itemClassIn
            and approvers(i).item_id = itemIdIn
            and approvers(i).action_type_id = actionTypeIdIn
            and approvers(i).group_or_chain_id = grpOrChainIdIn
            and approvers(i).approver_category = ame_util.approvalApproverCategory
            and approvers(i).approval_status = ame_util.notifiedStatus
          then
            select ame_trans_approval_history_s.nextval
              into tempTransHistoryId
              from dual;
            insert into AME_TRANS_APPROVAL_HISTORY
                (TRANS_HISTORY_ID
                ,TRANSACTION_ID
                ,APPLICATION_ID
                ,ROW_TIMESTAMP
                ,ORDER_NUMBER
                ,NAME
                ,APPROVER_CATEGORY
                ,ITEM_CLASS
                ,ITEM_ID
                ,ACTION_TYPE_ID
                ,AUTHORITY
                ,STATUS
                ,GROUP_OR_CHAIN_ID
                ,OCCURRENCE
                ,API_INSERTION
                ,MEMBER_ORDER_NUMBER
                ,NOTIFICATION_ID
                ,USER_COMMENTS
                ,DATE_CLEARED
                )select tempTransHistoryId
                       ,transactionIdIn
                       ,applicationIdIn
                       ,sysdate
                       ,approvers(i).approver_order_number
                       ,approvers(i).name
                       ,approvers(i).approver_category
                       ,approvers(i).item_class
                       ,approvers(i).item_id
                       ,approvers(i).action_type_id
                       ,approvers(i).authority
                       ,ame_util.beatByFirstResponderStatus
                       ,approvers(i).group_or_chain_id
                       ,approvers(i).occurrence
                       ,approvers(i).api_insertion
                       ,approvers(i).member_order_number
                       ,notificationIdIn
                       ,null
                       ,null
                   from dual;
          end if;
        end loop;
        return;
      end if;
      select ame_trans_approval_history_s.nextval
        into tempTransHistoryId
        from dual;
      if historyTypeIn = 'APPROVERPRESENT' then
        insert into AME_TRANS_APPROVAL_HISTORY
                (TRANS_HISTORY_ID
                ,TRANSACTION_ID
                ,APPLICATION_ID
                ,ROW_TIMESTAMP
                ,ORDER_NUMBER
                ,NAME
                ,APPROVER_CATEGORY
                ,ITEM_CLASS
                ,ITEM_ID
                ,ACTION_TYPE_ID
                ,AUTHORITY
                ,STATUS
                ,GROUP_OR_CHAIN_ID
                ,OCCURRENCE
                ,API_INSERTION
                ,MEMBER_ORDER_NUMBER
                ,NOTIFICATION_ID
                ,USER_COMMENTS
                ,DATE_CLEARED
                )values
                (tempTransHistoryId
                ,transactionIdIn
                ,applicationIdIn
                ,sysdate
                ,orderNumberIn
                ,nameIn
                ,appCategoryIn
                ,itemClassIn
                ,itemIdIn
                ,actionTypeIdIn
                ,authorityIn
                ,statusIn
                ,grpOrChainIdIn
                ,occurrenceIn
                ,apiInsertionIn
                ,memberorderNumberIn
                ,notificationIdIn
                ,userCommentsIn
                ,dateClearedIn);
      else
        begin
          select atah.item_class item_class
                ,atah.item_id item_id
                ,atah.order_number order_number
                ,atah.authority authority
                ,atah.action_type_id action_type_id
                ,atah.group_or_chain_id group_or_chain_id
                ,atah.occurrence occurrence
                ,atah.api_insertion api_insertion
                ,atah.member_order_number member_order_number
            into tempItemClass
                ,tempItemId
                ,tempOrderNumber
                ,tempAuthority
                ,tempActionTypeId
                ,tempGroupOrChainId
                ,tempOccurrence
                ,tempApiInsertion
                ,tempMemberOrderNumber
            from ame_trans_approval_history atah
                ,fnd_lookups lookup
                ,fnd_lookups lookup2
                ,ame_approval_groups apg
           where atah.date_cleared is null
             and atah.transaction_id = transactionIdIn
             and atah.application_id = applicationIdIn
             and atah.name = tempName
             and atah.trans_history_id =
                   (select max(b.trans_history_id)
                      from ame_trans_approval_history b
                     where atah.transaction_id = b.transaction_id
                       and atah.application_id = b.application_id
                       and atah.name = b.name
                       and atah.approver_category = b.approver_category
                       and atah.item_class = b.item_class
                       and atah.item_id = b.item_id
                       and atah.action_type_id = b.action_type_id
                       and atah.authority = b.authority
                       and atah.group_or_chain_id = b.group_or_chain_id
                       and atah.occurrence = b.occurrence
                       and b.date_cleared is null )
             and lookup.lookup_type = 'AME_SUBLIST_TYPES'
             and lookup.lookup_code = atah.authority
             and lookup2.lookup_type = 'AME_APPROVAL_STATUS'
             and lookup2.lookup_code = atah.status
             and apg.approval_group_id(+) = atah.group_or_chain_id
             and sysdate between nvl(apg.start_date,sysdate) and nvl(apg.end_date,sysdate);
        exception
          when no_data_found then
            tempItemClass      := '$AME_INVALID_ITEM_CLASS$';
            tempItemId         := '$AME_INVALID_ITEM$';
            tempOrderNumber    := 0;
            tempAuthority      := 'Y';
            tempActionTypeId   := ame_util.nullHistoryActionTypeId;
            tempGroupOrChainId := ame_util.nullHistoryGroupOrChainId;
            tempOccurrence     := ame_util.nullHistoryOccurrence;
            tempApiInsertion   := null;
            tempMemberOrderNumber := null;
        end;
        if orderNumberIn is not null then
          tempOrderNumber := orderNumberIn;
        end if;
        if itemClassIn is not null then
          tempItemClass := itemClassIn;
        end if;
        if itemIdIn is not null then
          tempItemId := itemIdIn;
        end if;
        if grpOrChainIdIn is not null then
          tempGroupOrChainId := grpOrChainIdIn;
        end if;
        if authorityIn is not null then
          tempAuthority := authorityIn;
        end if;
        if actionTypeIdIn is not null then
          tempActionTypeId := actionTypeIdIn;
        end if;
        if occurrenceIn is not null then
          tempOccurrence := occurrenceIn;
        end if;
        if apiInsertionIn is not null then
          tempApiInsertion := apiInsertionIn;
        end if;
        if memberorderNumberIn is not null then
          tempMemberOrderNumber := memberorderNumberIn;
        end if;
        insert into AME_TRANS_APPROVAL_HISTORY
                (TRANS_HISTORY_ID
                ,TRANSACTION_ID
                ,APPLICATION_ID
                ,ROW_TIMESTAMP
                ,ORDER_NUMBER
                ,NAME
                ,APPROVER_CATEGORY
                ,ITEM_CLASS
                ,ITEM_ID
                ,ACTION_TYPE_ID
                ,AUTHORITY
                ,STATUS
                ,GROUP_OR_CHAIN_ID
                ,OCCURRENCE
                ,API_INSERTION
                ,MEMBER_ORDER_NUMBER
                ,NOTIFICATION_ID
                ,USER_COMMENTS
                ,DATE_CLEARED
               ) values
               (tempTransHistoryId
               ,transactionIdIn
               ,applicationIdIn
               ,sysdate
               ,tempOrderNumber
               ,nameIn
               ,appCategoryIn
               ,tempItemClass
               ,tempItemId
               ,tempActionTypeId
               ,tempAuthority
               ,statusIn
               ,tempGroupOrChainId
               ,tempOccurrence
               ,tempApiInsertion
               ,tempMemberOrderNumber
               ,notificationIdIn
               ,userCommentsIn
               ,dateClearedIn
               );
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'insertIntoTransApprovalHistory',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);

    end insertIntoTransApprovalHistory;
  procedure lockTransaction(fndApplicationIdIn in integer,
                            transactionIdIn in varchar2,
                            transactionTypeIdIn in varchar2 default null) as
    tempTransIsLocked varchar2(2);
    cursor IsEngLocked is
      select 'Y'
        from ame_temp_trans_locks
       where fnd_application_id = fndApplicationIdIn
         and transaction_id = transactionIdIn
         and transaction_type_id = transactionTypeIdIn;
    begin
      /*
        The ame_temp_trans_locks_pk unique index will prevent the following insert from occurring
        if another row has already been inserted into ame_temp_trans_locks with the same
        fnd_application_id, transaction_type_id, and transaction_id values (even though the other
        insert is not committed).
      */
      tempTransIsLocked := null;
      if(engTransactionIsLocked) then
        return;
      end if;
      open IsEngLocked;
      fetch IsEngLocked into tempTransIsLocked;
      close IsEngLocked;
      if tempTransIsLocked = 'Y' then
        return;
      end if;
      insert into ame_temp_trans_locks(fnd_application_id,
                                       transaction_type_id,
                                       transaction_id,
                                       row_timestamp) values(
                                       fndApplicationIdIn,
                                       transactionTypeIdIn,
                                       transactionIdIn,
                                       sysdate);
      engTransactionIsLocked := true;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'lockTransaction',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end lockTransaction;
  procedure logTransaction as
    tempCount integer:= null;
    tempTransSeqId number;
    begin
      /* Log the transaction for eventual purging from the temp tables. */
      select count(*)
        into tempCount
        from ame_temp_transactions
        where
          application_id = engAmeApplicationId and
          transaction_id = engTransactionId and
          rownum < 2; /* Avoids second fetch otherwise required by ANSI standard to check for too many rows. */
      if(tempCount = 0) then
        select ame_temp_transactions_s.nextval into tempTransSeqId from dual;
        insert into ame_temp_transactions(
          application_id,
          transaction_id,
          row_timestamp,
          temp_transactions_id
          ) values(
            engAmeApplicationId,
            engTransactionId,
            sysdate,
            tempTransSeqId); /* Don't use engEffectiveRuleDate here. */
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'logTransaction',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end logTransaction;
  procedure parseFields(stringIn in varchar2,
                        fieldsOut out nocopy ame_util.longStringList) as
    fieldEnd integer;
    fieldIndex integer;
    fieldStart integer;
    stringLength integer;
    begin
      stringLength := lengthb(stringIn);
      fieldStart := 1;
      fieldIndex := 1; /* post-increment */
      loop
        fieldEnd := instrb(stringIn, ame_util.fieldDelimiter, fieldStart, 1);
        if(fieldEnd = 0) then
          fieldsOut(fieldIndex) := substrb(stringIn, fieldStart);
          exit;
        end if;
        fieldsOut(fieldIndex) := substrb(stringIn, fieldStart, fieldEnd - fieldStart);
        fieldIndex := fieldIndex + 1;
        fieldStart := fieldEnd + 1;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'parseFields',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end parseFields;
  procedure parseForwardingBehaviors(forwardingBehaviorsIn in varchar2) as
    startPosition integer;
    valueLength integer;
    begin
      startPosition := 1;
      for i in 1 .. 8 loop
        if(i = 8) then
          valueLength := lengthb(substrb(forwardingBehaviorsIn, startPosition));
        else
          valueLength := instrb(forwardingBehaviorsIn, ':', startPosition + 1, 1) - startPosition;
        end if;
        engForwardingBehaviors(i) := substrb(forwardingBehaviorsIn, startPosition, valueLength);
        startPosition := startPosition + valueLength + 1;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'parseForwardingBehaviors',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end parseForwardingBehaviors;
  procedure parsePriorityModes(priorityModesIn in varchar2) as
    currentValue ame_util.stringType;
    endPosition integer;
    startPosition integer;
    underscorePosition integer;
    begin
      /*
        The i - 1 indexes on the left side of the assignments account
        for the rule-type constants starting at zero.
      */
      startPosition := 1;
      for i in 1 .. 8 loop
        if(i < 8) then
          endPosition := instrb(priorityModesIn, ':', startPosition, 1) - 1;
        else
          endPosition := lengthb(priorityModesIn);
        end if;
        currentValue := substrb(priorityModesIn, startPosition, endPosition - startPosition + 1);
        underscorePosition := instrb(currentValue, '_', 1, 1);
        if(underscorePosition = 0) then
          engPriorityModes(i - 1) := ame_util.disabledRulePriority;
          engPriorityThresholds(i - 1) := null;
        else
          engPriorityThresholds(i - 1) := to_number(substrb(currentValue, underscorePosition + 1));
          if(instrb(currentValue, ame_util.absoluteRulePriority, 1, 1) > 0) then
            engPriorityModes(i - 1) := ame_util.absoluteRulePriority;
          else
            engPriorityModes(i - 1) := ame_util.relativeRulePriority;
          end if;
        end if;
        startPosition := endPosition + 2;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'parsePriorityModes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end parsePriorityModes;
  procedure populateEngStVariables as
    headerItemRejected boolean;
    itemIds            ame_util.stringList;
    itemClasses        ame_util.stringList;
    tempItemClass      ame_util.stringType;
    tempItemId         ame_util.stringType;
    tempItemIndex      integer;
    tempPseudoBoolean  ame_util.charType;
    stoppingRule       ame_util.stringType;
    itemRejected       boolean;
    tempCount          integer;
    begin
      /*
        The procedure processRepeatedApprovers populates most of the engSt variables, to synchronize
        that work with the repeatedApprovers functionality, for efficiency.  This procedure just
        populates engStApprovalProcessCompleteYN, engStItemAppProcessCompleteYN, engStProductionIndexes,
        engStVariableNames, and engStVariableValues.  Note that this procedure should execute after
        processRepeatedApprovers, so it can treat repeated approvers as having approved in the
        calculation of the approval-process-complete values.
      */
      /* Initialize various values. */
      itemRejected := false;
      engStApprovalProcessCompleteYN := ame_util2.completeNoApprovers;
      for i in 1 .. engItemIds.count loop
        engStItemAppProcessCompleteYN(i) := ame_util2.completeNoApprovers;
      end loop;
      /* Handle the empty-approver-list case first. */
      if(engStApprovers.count = 0) then
        return;
      end if;
      /* get all itemclasses and itemids of current transaction */
      getAllItemClasses(itemClassNamesOut => itemClasses);
      getAllItemIds(itemIdsOut            => itemIds);
      /*
        The approver list is non-empty.  Set the process-complete values per the statuses in
        engStApprovers;
      */
      /* modified the values of approvalProcessCompleteYN as per bug 4411016 */
      /* Initialize the temp variables. */
      tempItemId := engStApprovers(1).item_id;
      tempItemClass := engStApprovers(1).item_class;
      for i in 1 .. itemIds.count loop
        if(itemIds(i) = tempItemId and itemClasses(i) = tempItemClass) then
          tempItemIndex := i;
          engStItemAppProcessCompleteYN(tempItemIndex) := ame_util2.completeFullyApproved;
          if engStApprovalProcessCompleteYN = ame_util2.completeNoApprovers then
            engStApprovalProcessCompleteYN := ame_util2.completeFullyApproved;
          end if;
          exit;
        end if;
      end loop;
      tempPseudoBoolean := ame_util.booleanTrue;
      /* Loop through the approvers. */
      for i in 1 .. engStApprovers.count loop
        /* Update the temp variables when the item changes. */
        if(engStApprovers(i).item_id <> tempItemId or
           engStApprovers(i).item_class <> tempItemClass) then
          tempItemId := engStApprovers(i).item_id;
          tempItemClass := engStApprovers(i).item_class;
          tempPseudoBoolean := ame_util.booleanTrue;
          for j in (tempItemIndex + 1) .. itemIds.count loop
            if(itemIds(j) = tempItemId and itemClasses(j) = tempItemClass) then
              tempItemIndex := j;
              engStItemAppProcessCompleteYN(tempItemIndex) := ame_util2.completeFullyApproved;
              if engStApprovalProcessCompleteYN = ame_util2.completeNoApprovers then
                engStApprovalProcessCompleteYN := ame_util2.completeFullyApproved;
              end if;
              exit;
            end if;
          end loop;
        end if;
        /* Update the process-complete engSt variables as appropriate. */
        -- check for pending/yet to be notified approvers
        if(engStItemAppProcessCompleteYN(tempItemIndex) <> ame_util2.completeFullyRejected and
           ((engStApprovers(i).approver_category = ame_util.approvalApproverCategory and
             (engStApprovers(i).approval_status is null or
              engStApprovers(i).approval_status in (ame_util.nullStatus
                                                   ,ame_util.notifiedStatus
                                                   ,ame_util.repeatedStatus
                                                   ,ame_util.notifiedByRepeatedStatus))) or
            (engStApprovers(i).approver_category = ame_util.fyiApproverCategory and
             (engStApprovers(i).approval_status is null or
             engStApprovers(i).approval_status = ame_util.nullStatus)))) then
          if engStItemAppProcessCompleteYN(tempItemIndex) in (ame_util2.completeNoApprovers
                                                             ,ame_util2.completeFullyApproved) then
            engStItemAppProcessCompleteYN(tempItemIndex) := ame_util2.notCompleted;
            if engStApprovalProcessCompleteYN in (ame_util2.completeNoApprovers
                                                 ,ame_util2.completeFullyApproved) then
              engStApprovalProcessCompleteYN := ame_util2.notCompleted;
            end if;
          end if;
        end if;
        -- check for rejections
        if(engStApprovers(i).approver_category = ame_util.approvalApproverCategory and
           engStApprovers(i).approval_status in (ame_util.rejectStatus,ame_util.rejectedByRepeatedStatus)) then
          itemRejected := true;
          if tempItemClass = ame_util.headerItemClassName then
            headerItemRejected := true;
          end if;
          engStItemAppProcessCompleteYN(tempItemIndex) := ame_util2.completeFullyRejected;
        end if;
      end loop;

      if itemRejected then
        stoppingRule := ame_engine.getHeaderAttValue2
                          (attributeNameIn => ame_util.rejectionResponseAttribute);
        if stoppingRule is null or stoppingRule not in (ame_util.stopAllItems,ame_util.continueOtherSubItems,
                                                        ame_util.continueAllOtherItems) then
           stoppingRule := ame_util.stopAllItems;
        end if;
        -- When the stoppingRule is STOP_ALL_ITEMS or a header item got rejected then
        -- 1. The transaction as a whole is rejected.
        -- 2. Make all pending items approval status rejected.
        if stoppingRule = ame_util.stopAllItems or headerItemRejected then
          engStApprovalProcessCompleteYN := ame_util2.completeFullyRejected;
          --+
          for x in 1 .. itemIds.count loop
            if engStItemAppProcessCompleteYN(x) = ame_util2.notCompleted then
              engStItemAppProcessCompleteYN(x) := ame_util2.completeFullyRejected;
            end if;
          end loop;
          --+
        end if;
        -- When the stoppingRule is CONTINUE_OTHER_SUBORDINATE_ITEMS or
        -- CONTINUE_ALL_OTHER_ITEMS then
        -- 1. Reject header item if stoppingRule is CONTINUE_OTHER_SUBORDINATE_ITEMS
        --    and header item is pending.
        -- 2. Set the transaction level status to partially rejected by default.
        -- 3. If any other item is still pending set the approval status of
        --    transaction to pending status.
        -- 4. If the transaction level status is still partially rejected then
        --    check for complete rejection. Complete rejection will happen if all items
        --    are rejected or have no approvers.
        if stoppingRule = ame_util.continueOtherSubItems or
           stoppingRule = ame_util.continueAllOtherItems then
          if stoppingRule = ame_util.continueOtherSubItems then
            for x in 1 .. itemIds.count loop
              if itemClasses(x) = ame_util.headerItemClassName and
                 engStItemAppProcessCompleteYN(x) = ame_util2.notCompleted then
                engStItemAppProcessCompleteYN(x) := ame_util2.completeFullyRejected;
                exit;
              end if;
            end loop;
          end if;
          engStApprovalProcessCompleteYN := ame_util2.completePartiallyApproved;
          for x in 1 .. itemIds.count loop
            if engStItemAppProcessCompleteYN(x) = ame_util2.notCompleted then
              engStApprovalProcessCompleteYN := ame_util2.notCompleted;
              exit;
            end if;
          end loop;
          tempCount := 0;
          if engStApprovalProcessCompleteYN = ame_util2.completePartiallyApproved then
            for x in 1 .. itemIds.count loop
              if engStItemAppProcessCompleteYN(x) <> ame_util2.completeFullyRejected and
                 engStItemAppProcessCompleteYN(x) <> ame_util2.completeNoApprovers then
                exit;
              end if;
              tempCount := tempCount + 1;
            end loop;
            if tempCount = itemIds.count then
              engStApprovalProcessCompleteYN := ame_util2.completeFullyRejected;
            end if;
          end if;
        end if;
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'populateEngStVariables',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end populateEngStVariables;
  procedure processAdHocInsertions as
    displacedInserteeIndexes ame_util.idList;
    engStApproversCount integer;
    parameterFields ame_util.longStringList;
    tempAnchorIndex integer;
    tempBoolean boolean;
    tempIndex integer;
    tempIndex2 integer;
    tempItemClass ame_temp_insertions.item_class%type;
    tempItemId ame_temp_insertions.item_id%type;
    tempOrderType ame_temp_insertions.order_type%type;
    begin
      /*
        This procedure generally must populate the following ame_util.approverRecord2 fields,
        for each inserted approver:
          orig_system
          orig_system_id
          display_name
          action_type_id
          group_or_chain_id
          occurrence
          source
          approval_status
          item_class_order_number
          item_order_number
          sub_list_order_number
          action_type_order_number
          group_or_chain_order_number
          member_order_number
        The first three of these fields get populated at the beginning of the outermost loop below.
        The other fields get populated just before the actual insertion occurs.  This procedure must
        therefore decide how to set the order-number fields.  The procedure attempts to set the
        order numbers consistent with the order relation of the insertion, where the order relation
        anchors the insertion to the approver preceeding or following the insertion in engStApprovers.
        See the comments near specific insertApprover calls below.
      */
      engStApproversCount := engStApprovers.count;
      for i in 1 .. engInsertedApproverList.count loop
        if(engInsertedApproverList(i).authority <> ame_util.authorityApprover or
           engInsertedApproverList(i).api_insertion = ame_util.apiInsertion) then
          ame_approver_type_pkg.getOrigSystemIdAndDisplayName(nameIn => engInsertedApproverList(i).name,
                                                              origSystemOut => engInsertedApproverList(i).orig_system,
                                                              origSystemIdOut => engInsertedApproverList(i).orig_system_id,
                                                              displayNameOut => engInsertedApproverList(i).display_name);
          parameterFields.delete;
          parseFields(stringIn => engInsertionParameterList(i),
                      fieldsOut => parameterFields);
          /* absoluteOrder */
          if(engInsertionOrderTypeList(i) = ame_util.absoluteOrder) then
            tempIndex := engInsertionParameterList(i);
            if(tempIndex > engStApprovers.count + 1) then
              tempIndex := engStApprovers.count + 1;
            end if;
            engInsertedApproverList(i).source := ame_util.otherInsertion;
            if(engStApprovers.exists(tempIndex - 1)  and
               engStApprovers(tempIndex - 1).authority = engInsertedApproverList(i).authority and
               engStApprovers(tempIndex - 1).item_class = engInsertedApproverList(i).item_class and
               engStApprovers(tempIndex - 1).item_id = engInsertedApproverList(i).item_id
               ) then
              /* Group the insertion with the preceeding approver in engStApprovers. */
              engInsertedApproverList(i).action_type_id := engStApprovers(tempIndex - 1).action_type_id;
              engInsertedApproverList(i).group_or_chain_id := engStApprovers(tempIndex - 1).group_or_chain_id;
              engInsertedApproverList(i).occurrence :=
                getHandlerOccurrence(nameIn => engInsertedApproverList(i).name,
                                     itemClassIn => engInsertedApproverList(i).item_class,
                                     itemIdIn => engInsertedApproverList(i).item_id,
                                     actionTypeIdIn => engInsertedApproverList(i).action_type_id,
                                     groupOrChainIdIn => engInsertedApproverList(i).group_or_chain_id);
              engInsertedApproverList(i).item_class_order_number :=
                engStApprovers(tempIndex - 1).item_class_order_number;
              engInsertedApproverList(i).item_order_number := engStApprovers(tempIndex - 1).item_order_number;
              engInsertedApproverList(i).sub_list_order_number := engStApprovers(tempIndex - 1).sub_list_order_number;
              engInsertedApproverList(i).action_type_order_number :=
                engStApprovers(tempIndex - 1).action_type_order_number;
              engInsertedApproverList(i).group_or_chain_order_number :=
                engStApprovers(tempIndex - 1).group_or_chain_order_number;
            elsif(engStApprovers.exists(tempIndex)) then
              /* Group the insertion with the following approver in engStApprovers. */
              engInsertedApproverList(i).authority := engStApprovers(tempIndex).authority;
              engInsertedApproverList(i).action_type_id := engStApprovers(tempIndex).action_type_id;
              engInsertedApproverList(i).group_or_chain_id := engStApprovers(tempIndex).group_or_chain_id;
              engInsertedApproverList(i).occurrence :=
                getHandlerOccurrence(nameIn => engInsertedApproverList(i).name,
                                     itemClassIn => engInsertedApproverList(i).item_class,
                                     itemIdIn => engInsertedApproverList(i).item_id,
                                     actionTypeIdIn => engInsertedApproverList(i).action_type_id,
                                     groupOrChainIdIn => engInsertedApproverList(i).group_or_chain_id);
              engInsertedApproverList(i).item_class_order_number := engStApprovers(tempIndex).item_class_order_number;
              engInsertedApproverList(i).item_order_number := engStApprovers(tempIndex).item_order_number;
              engInsertedApproverList(i).sub_list_order_number := engStApprovers(tempIndex).sub_list_order_number;
              engInsertedApproverList(i).action_type_order_number := engStApprovers(tempIndex).action_type_order_number;
              engInsertedApproverList(i).group_or_chain_order_number :=
                engStApprovers(tempIndex).group_or_chain_order_number;
            else
              /* engStApprovers must be empty. */
              engInsertedApproverList(i).action_type_id := ame_util.nullInsertionActionTypeId;
              engInsertedApproverList(i).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
              engInsertedApproverList(i).occurrence := 1;
              engInsertedApproverList(i).item_class_order_number :=
                getItemClassOrderNumber(itemClassIdIn =>
                  getItemClassId(itemClassNameIn => engInsertedApproverList(i).item_class));
              engInsertedApproverList(i).item_order_number :=
                getItemOrderNumber(itemClassNameIn => engInsertedApproverList(i).item_class,
                                   itemIdIn => engInsertedApproverList(i).item_id);
              engInsertedApproverList(i).sub_list_order_number :=
                getSublistOrderNum(itemClassNameIn => ame_util.headerItemClassName,
                                   authorityIn => ame_util.postApprover);
              engInsertedApproverList(i).action_type_order_number := getNullActionTypeOrderNumber;
              engInsertedApproverList(i).group_or_chain_order_number := 1;
            end if;
            if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
              fnd_log.string
                (fnd_log.level_statement
                ,'ame_engine.processAdhocInsertions'
                ,'Adhoc Insertion approver(absolute order) ::: ' || engInsertedApproverList(i).name
                );
            end if;
            insertApprover(indexIn => tempIndex,
                           approverIn => engInsertedApproverList(i),
                           adjustMemberOrderNumbersIn => true,
                           inserteeIndexIn => i,
                           currentInsIndex => i);
            populateInsertionIndexes(indexIn => tempIndex
                                    ,insertionOrderIn => engInsertionOrderList(i));
            engStApproversCount := engStApproversCount + 1;
          /* afterApprover, beforeApprover */
          elsif(engInsertionOrderTypeList(i) in (ame_util.afterApprover,
                                                 ame_util.beforeApprover)) then
            tempIndex := 1; /* post-increment */
            loop
              tempBoolean := false;
              /*
                In this loop, tempBoolean indicates whether engStApprovers(tempIndex) matches
                the insertion parameter.
              */
              if(engStApprovers(tempIndex).name = parameterFields(1) and
                 engStApprovers(tempIndex).occurrence = parameterFields(6) and
                 engStApprovers(tempIndex).group_or_chain_id = parameterFields(5) and
                 engStApprovers(tempIndex).action_type_id = parameterFields(4) and
                 engStApprovers(tempIndex).item_id = parameterFields(3) and
                 engStApprovers(tempIndex).item_class = parameterFields(2)) then
                tempBoolean := true;
                if(engInsertionOrderTypeList(i) = ame_util.afterApprover) then
                  tempIndex2 := tempIndex + 1;
                else
                  tempIndex2 := tempIndex;
                end if;
                engInsertedApproverList(i).action_type_id := engStApprovers(tempIndex).action_type_id;
                engInsertedApproverList(i).group_or_chain_id := engStApprovers(tempIndex).group_or_chain_id;
                engInsertedApproverList(i).occurrence :=
                  getHandlerOccurrence(nameIn => engInsertedApproverList(i).name,
                                       itemClassIn => engInsertedApproverList(i).item_class,
                                       itemIdIn => engInsertedApproverList(i).item_id,
                                       actionTypeIdIn => engInsertedApproverList(i).action_type_id,
                                       groupOrChainIdIn => engInsertedApproverList(i).group_or_chain_id);
                if(engInsertionIsSpecialForwardee(i) = ame_util.booleanTrue) then
                  engInsertedApproverList(i).source := ame_util.specialForwardInsertion;
                else
                  if(engInsertionOrderTypeList(i) = ame_util.afterApprover and
                     engStApprovers(tempIndex).approval_status = ame_util.forwardStatus) then
                    engInsertedApproverList(i).source := ame_util.forwardInsertion;
                  elsif(engInsertionOrderTypeList(i) = ame_util.afterApprover and
                        engStApprovers(tempIndex).approval_status = ame_util.approveAndForwardStatus) then
                    engInsertedApproverList(i).source := ame_util.approveAndForwardInsertion;
                  else
                    engInsertedApproverList(i).source := ame_util.otherInsertion;
                  end if;
                end if;
                engInsertedApproverList(i).item_class_order_number := engStApprovers(tempIndex).item_class_order_number;
                engInsertedApproverList(i).item_order_number := engStApprovers(tempIndex).item_order_number;
                engInsertedApproverList(i).sub_list_order_number := engStApprovers(tempIndex).sub_list_order_number;
                engInsertedApproverList(i).action_type_order_number := engStApprovers(tempIndex).action_type_order_number;
                engInsertedApproverList(i).group_or_chain_order_number :=
                  engStApprovers(tempIndex).group_or_chain_order_number;
                if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
                  fnd_log.string
                    (fnd_log.level_statement
                    ,'ame_engine.processAdhocInsertions'
                    ,'Adhoc Insertion approver(after/before approver) ::: ' || engInsertedApproverList(i).name
                    );
                end if;
                insertApprover(indexIn => tempIndex2,
                               approverIn => engInsertedApproverList(i),
                               adjustMemberOrderNumbersIn => true,
                               inserteeIndexIn => i,
                               currentInsIndex => i);
                populateInsertionIndexes(indexIn => tempIndex2
                                        ,insertionOrderIn => engInsertionOrderList(i));
                engStApproversCount := engStApproversCount + 1;
              end if;
              if(tempBoolean or
                 tempIndex = engStApproversCount) then
                exit;
              end if;
              tempIndex := tempIndex + 1;
            end loop;
          else /* first/last pre/post approver */
            /*
              The source, action_type_id, and group_or_chain_id fields are set in
              ame_api3.getAvailableInsertions for these order types.
            */
            if(engStApproversCount = 0) then
              /*
                The four first/last pre/post order types can only occur in an empty list if the insertion
                is for the header item.  Treat any other case of these order types as displaced, here.
                In the code blocks below for these four order types, require that engStApproversCount > 0.
              */
              if(parameterFields(3) = ame_util.headerItemClassName and
                 parameterFields(2) = engTransactionId) then
                engInsertedApproverList(i).occurrence := 1;
                engInsertedApproverList(i).item_class_order_number :=
                  getItemClassOrderNumber(itemClassIdIn =>
                    getItemClassId(itemClassNameIn => ame_util.headerItemClassName));
                engInsertedApproverList(i).item_order_number := 1;
                engInsertedApproverList(i).sub_list_order_number :=
                  getSublistOrderNum(itemClassNameIn => ame_util.headerItemClassName,
                                     authorityIn => engInsertedApproverList(i).authority);
                engInsertedApproverList(i).action_type_order_number := getNullActionTypeOrderNumber;
                engInsertedApproverList(i).group_or_chain_order_number := 1;
                engInsertedApproverList(i).member_order_number := 1;
                insertApprover(indexIn => 1,
                               approverIn => engInsertedApproverList(i),
                               adjustMemberOrderNumbersIn => false,
                               inserteeIndexIn => i,
                               currentInsIndex => i);
                populateInsertionIndexes(indexIn => 1
                                        ,insertionOrderIn => engInsertionOrderList(i));
                engStApproversCount := 1;
              else /* displaced */
                engInsertedApproverList(i).occurrence := 1;
                engInsertedApproverList(i).item_class_order_number :=
                  getItemClassOrderNumber(itemClassIdIn =>
                    getItemClassId(itemClassNameIn => engInsertedApproverList(i).item_class));
                engInsertedApproverList(i).item_order_number := 1;
                engInsertedApproverList(i).sub_list_order_number :=
                  getSublistOrderNum(itemClassNameIn => engInsertedApproverList(i).item_class,
                                     authorityIn => engInsertedApproverList(i).authority);
                engInsertedApproverList(i).action_type_order_number := getNullActionTypeOrderNumber;
                engInsertedApproverList(i).group_or_chain_order_number := 1;
                engInsertedApproverList(i).member_order_number := 1;
                displacedInserteeIndexes(displacedInserteeIndexes.count + 1) := i;
              end if;
            else
              tempIndex := null;
              tempAnchorIndex := null;
              /* firstPostApprover */
              if(engInsertionOrderTypeList(i) = ame_util.firstPostApprover) then
                /*
                  Insert at tempIndex if it's non-null, after checking the possible cases.
                  Recall that the case where engStApproversCount = 0 is handled at the
                  start of the procedure, that the item id is in parameterFields(3), and
                  that the item-class ID is in parameterFields(2).  Here are the cases
                  requiring insertion (always at j + 1).
                  1.  j = 0,
                      post-approver for the right item at j + 1 = 1
                  2.  j > 0,
                      j < engStApproversCount,
                      non-post-approver for the right item at j,
                      post-approver for the right item at j + 1
                  3.  j > 0,
                      j < engStApproversCount,
                      non-post-approver for the right item at j,
                      any approver for the wrong item at j + 1
                  4.  j > 0,
                      j = engStApproversCount,
                      non-post-approver for the right item at j
                  5.  j > 0,
                      j < engStApproversCount,
                      any approver for the wrong item at j,
                      post-approver for the right item at j + 1
                  Finally, note that the way the code is written, case 4 must be checked
                  before cases 2, 3, and 5, to ensure that for these cases,
                  j + 1 <= engStApproversCount.
                */
                /* The zero lower limit is intentional. */
                for j in 0 .. engStApproversCount loop
                  tempIndex2 := j + 1;
                  if(j = 0) then /* case 1 */
                    if(engStApprovers(tempIndex2).authority = ame_util.postApprover and
                       engStApprovers(tempIndex2).item_id = parameterFields(3) and
                       engStApprovers(tempIndex2).item_class = parameterFields(2)) then
                      tempIndex := tempIndex2;
                      tempAnchorIndex := tempIndex2;
                      exit;
                    end if;
                  else /* j > 0:  cases 2-5 */
                    /*
                      non-post-approver for the right item at j:  cases 2-4
                      Case 4 comes before the others to prevent indexing into a non-existent
                      engStApprovers(tempIndex2) when j = engStApproversCount.
                    */
                    if(engStApprovers(j).authority <> ame_util.postApprover and
                       engStApprovers(j).item_id = parameterFields(3) and
                       engStApprovers(j).item_class = parameterFields(2)) then
                      if(j = engStApproversCount) then /* case 4 */
                        tempIndex := tempIndex2;
                        exit;
                      end if;
                      if(engStApprovers(tempIndex2).authority = ame_util.postApprover and
                         engStApprovers(tempIndex2).item_id = parameterFields(3) and
                         engStApprovers(tempIndex2).item_class = parameterFields(2)) then /* case 2 */
                        tempIndex := tempIndex2;
                        tempAnchorIndex := tempIndex2;
                        exit;
                      end if;
                      if(engStApprovers(tempIndex2).item_id <> parameterFields(3) or
                         engStApprovers(tempIndex2).item_class <> parameterFields(2)) then /* case 3 */
                        tempIndex := tempIndex2;
                        exit;
                      end if;
                      if((engStApprovers(j).item_id <> parameterFields(3) or
                          engStApprovers(j).item_class <> parameterFields(2)) and
                         engStApprovers(tempIndex2).authority = ame_util.postApprover and
                         engStApprovers(tempIndex2).item_id = parameterFields(3) and
                         engStApprovers(tempIndex2).item_class = parameterFields(2)) then /* case 5 */
                        tempIndex := tempIndex2;
                        tempAnchorIndex := tempIndex2;
                        exit;
                      end if;
                    end if;
                  end if;
                end loop;
              /* firstPreApprover */
              elsif(engInsertionOrderTypeList(i) = ame_util.firstPreApprover) then
                /*
                  Insert at tempIndex if it's non-null, after checking the possible cases.
                  Recall that the case where engStApproversCount = 0 is handled at the
                  start of the procedure.  Here are the cases requiring insertion (always
                  at j).
                  1.  j = 1,
                      any approver for the right item at j = 1
                  2.  j > 1,
                      any approver for the wrong item at j - 1,
                      any approver for the right item at j
                */
                for j in 1 .. engStApproversCount loop
                  if(j = 1) then
                    if(engStApprovers(1).item_id = parameterFields(3) and
                       engStApprovers(1).item_class = parameterFields(2)) then /* case 1 */
                      tempIndex := 1;
                      if(engStApprovers(1).authority = ame_util.preApprover) then
                        tempAnchorIndex := 1;
                      end if;
                      exit;
                    end if;
                  elsif((engStApprovers(j - 1).item_id <> parameterFields(3) or
                         engStApprovers(j - 1).item_class <> parameterFields(2)) and
                        engStApprovers(j).item_id = parameterFields(3) and
                        engStApprovers(j).item_class = parameterFields(2)) then /* case 2 */
                    tempIndex := j;
                    if(engStApprovers(j).authority = ame_util.preApprover) then
                      tempAnchorIndex := j;
                    end if;
                    exit;
                  end if;
                end loop;
              /* lastPostApprover */
              elsif(engInsertionOrderTypeList(i) = ame_util.lastPostApprover) then
                /*
                  Insert at tempIndex if it's non-null, after checking the possible cases.
                  Recall that the case where engStApproversCount = 0 is handled at the
                  start of the procedure.  Here are the cases requiring insertion (always
                  at j + 1).
                  1.  j = engStApproversCount,
                      any approver for the right item at j
                  2.  j < engStApproversCount,
                      any approver for right item at j,
                      any approver for wrong item at j + 1
                */
                for j in 1 .. engStApproversCount loop
                  if(j = engStApproversCount) then
                    if(engStApprovers(j).item_id = parameterFields(3) and
                       engStApprovers(j).item_class = parameterFields(2)) then
                      tempIndex := engStApproversCount + 1;
                      if(engStApprovers(j).authority = ame_util.postApprover) then
                        tempAnchorIndex := j;
                      end if;
                      exit;
                    end if;
                  else
                    if(engStApprovers(j).item_id = parameterFields(3) and
                       engStApprovers(j).item_class = parameterFields(2) and
                       (engStApprovers(j + 1).item_id <> parameterFields(3) or
                       engStApprovers(j + 1).item_class <> parameterFields(2))) then
                      tempIndex := j + 1;
                      if(engStApprovers(j).authority = ame_util.postApprover) then
                        tempAnchorIndex := j;
                      end if;
                      exit;
                    end if;
                  end if;
                end loop;
              /* lastPreApprover */
              else /* engInsertionOrderTypeList(i) = ame_util.lastPreApprover */
                /*
                  Insert at tempIndex if it's non-null, after checking the possible cases.
                  Recall that the case where engStApproversCount = 0 is handled at the
                  start of the procedure.  Here are the cases (always inserting at j):
                  1.  j = 1,
                      non-pre-approver for the right item at 1
                  2.  j > 1,
                      j <= engStApproversCount,
                      the approver at j - 1 is for the right item,
                      the approver at j is for the right item,
                      the approver at j - 1 is a pre-approver,
                      the approver at j is not a pre-approver
                  3.  j > 1,
                      j <= engStApproversCount,
                      any approver at j - 1 for the wrong item,
                      the approver at j is for the right item,
                      the approver at j is not a pre-approver
                */
                for j in 1 .. engStApproversCount loop
                  if(j = 1) then
                    if(engStApprovers(1).item_id = parameterFields(3) and
                       engStApprovers(1).item_class = parameterFields(2) and
                       engStApprovers(1).authority <> ame_util.preApprover) then /* case 1 */
                      tempIndex := 1;
                      exit;
                    end if;
                  else
                    if(engStApprovers(j).item_id = parameterFields(3) and
                       engStApprovers(j).item_class = parameterFields(2) and
                       engStApprovers(j).authority <> ame_util.preApprover) then
                      if(engStApprovers(j - 1).item_id = parameterFields(3) and
                         engStApprovers(j - 1).item_class = parameterFields(2)) then
                        if(engStApprovers(j - 1).authority = ame_util.preApprover) then /* case 2 */
                          tempIndex := j;
                          tempAnchorIndex := j - 1;
                          exit;
                        end if;
                      else /* case 3 */
                        tempIndex := j;
                        exit;
                      end if;
                    end if;
                  end if;
                end loop;
              end if;
              /* Set the remaining fields in the insertee's approverRecord2. */
              engInsertedApproverList(i).source := ame_util.otherInsertion;
              if(tempAnchorIndex is null) then
                engInsertedApproverList(i).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
                /* This code was commented out to fix BUG (4095846)                                 */
                /* Issue 9 in the list of bugs identified during implementation of                  */
                /* asynchronous parallel approver functionality                                     */
                /* engInsertedApproverList(i).action_type_id := ame_util.nullInsertionActionTypeId; */
                engInsertedApproverList(i).occurrence :=
                  getHandlerOccurrence(nameIn => engInsertedApproverList(i).name,
                                       itemClassIn => engInsertedApproverList(i).item_class,
                                       itemIdIn => engInsertedApproverList(i).item_id,
                                       actionTypeIdIn => engInsertedApproverList(i).action_type_id,
                                       groupOrChainIdIn => engInsertedApproverList(i).group_or_chain_id);
                engInsertedApproverList(i).item_class_order_number :=
                  getItemClassOrderNumber(itemClassIdIn =>
                    getItemClassId(itemClassNameIn => engInsertedApproverList(i).item_class));
                engInsertedApproverList(i).item_order_number :=
                  getItemOrderNumber(itemClassNameIn => engInsertedApproverList(i).item_class,
                                                 itemIdIn => engInsertedApproverList(i).item_id);
                /* Code Modified to fix BUG (4095825)                              */
                /* Issue 2 in the list of bugs identified during implementation of */
                /* asynchronous parallel approver functionality                    */
                if engInsertionOrderTypeList(i) = ame_util.firstPreApprover or
                        engInsertionOrderTypeList(i) = ame_util.lastPreApprover then
                  engInsertedApproverList(i).sub_list_order_number :=
                    getSublistOrderNum(itemClassNameIn => engInsertedApproverList(i).item_class,
                                       authorityIn => ame_util.preApprover);
                elsif engInsertionOrderTypeList(i) = ame_util.firstPostApprover or
                        engInsertionOrderTypeList(i) = ame_util.lastPostApprover then
                  engInsertedApproverList(i).sub_list_order_number :=
                    getSublistOrderNum(itemClassNameIn => engInsertedApproverList(i).item_class,
                                       authorityIn => ame_util.postApprover);
                end if;
                /* Code Modified to fix BUG (4095846)                                                   */
                /* Issue 9 in the list of bugs identified during implementation of                      */
                /* asynchronous parallel approver functionality                                         */
                /* engInsertedApproverList(i).action_type_order_number := getNullActionTypeOrderNumber; */
                engInsertedApproverList(i).action_type_order_number := 1;
                engInsertedApproverList(i).group_or_chain_order_number := 1;
              else
                engInsertedApproverList(i).group_or_chain_id := ame_util.nullInsertionGroupOrChainId;
                /* Code Modified to fix BUG (4095846)                                              */
                /* Issue 9 in the list of bugs identified during implementation of                 */
                /* asynchronous parallel approver functionality                                    */
                /* engInsertedApproverList(i).action_type_id := ame_util.nullInsertionActionTypeId;*/
                engInsertedApproverList(i).occurrence :=
                  getHandlerOccurrence(nameIn => engInsertedApproverList(i).name,
                                       itemClassIn => engInsertedApproverList(i).item_class,
                                       itemIdIn => engInsertedApproverList(i).item_id,
                                       actionTypeIdIn => engInsertedApproverList(i).action_type_id,
                                       groupOrChainIdIn => engInsertedApproverList(i).group_or_chain_id);
                engInsertedApproverList(i).item_class_order_number :=
                  engStApprovers(tempAnchorIndex).item_class_order_number;
                engInsertedApproverList(i).item_order_number :=
                  engStApprovers(tempAnchorIndex).item_order_number;
                engInsertedApproverList(i).sub_list_order_number :=
                  engStApprovers(tempAnchorIndex).sub_list_order_number;
                /* Code Modified to fix BUG (4095846)                                   */
                /* Issue 9 in the list of bugs identified during implementation of      */
                /* asynchronous parallel approver functionality                         */
                /*engInsertedApproverList(i).action_type_order_number :=                */
                /*  engStApprovers(tempAnchorIndex).action_type_order_number;           */
                if engInsertionOrderTypeList(i) = ame_util.firstPreApprover or
                     engInsertionOrderTypeList(i) = ame_util.firstPostApprover then
                  engInsertedApproverList(i).action_type_order_number :=
                    engStApprovers(tempAnchorIndex).action_type_order_number - 1;
                elsif engInsertionOrderTypeList(i) = ame_util.lastPreApprover or
                     engInsertionOrderTypeList(i) = ame_util.lastPostApprover then
                  engInsertedApproverList(i).action_type_order_number :=
                    engStApprovers(tempAnchorIndex).action_type_order_number + 1;
                end if;
                engInsertedApproverList(i).group_or_chain_order_number :=
                  engStApprovers(tempAnchorIndex).group_or_chain_order_number;
              end if;
              /* Perform the insertion if the proper position has been located. */
              if(tempIndex is null) then
                displacedInserteeIndexes(displacedInserteeIndexes.count + 1) := i;
              else
                /* Code Modified to fix BUG (4095846)                                   */
                /* Issue 9 in the list of bugs identified during implementation of      */
                /* asynchronous parallel approver functionality                         */
                if engInsertionOrderTypeList(i) = ame_util.firstPreApprover or
                        engInsertionOrderTypeList(i) = ame_util.firstPostApprover then
                  engInsertedApproverList(i).action_type_id := -1;
                  if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
                    fnd_log.string
                      (fnd_log.level_statement
                      ,'ame_engine.processAdhocInsertions'
                      ,'Adhoc Insertion approver(first pre/first post approver) ::: ' || engInsertedApproverList(i).name
                      );
                  end if;
                  insertApprover(indexIn => tempIndex,
                                 approverIn => engInsertedApproverList(i),
                                 adjustMemberOrderNumbersIn => true,
                                 approverLocationIn => ame_util.firstAmongEquals,
                                 inserteeIndexIn => i,
                                 currentInsIndex => i);
                  populateInsertionIndexes(indexIn => tempIndex
                                          ,insertionOrderIn => engInsertionOrderList(i));
                elsif engInsertionOrderTypeList(i) = ame_util.lastPreApprover or
                        engInsertionOrderTypeList(i) = ame_util.lastPostApprover then
                  engInsertedApproverList(i).action_type_id := -2;
                  if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
                    fnd_log.string
                      (fnd_log.level_statement
                      ,'ame_engine.processAdhocInsertions'
                      ,'Adhoc Insertion approver(last pre/last post approver) ::: ' || engInsertedApproverList(i).name
                      );
                  end if;
                  insertApprover(indexIn => tempIndex,
                                 approverIn => engInsertedApproverList(i),
                                 adjustMemberOrderNumbersIn => true,
                                 approverLocationIn => ame_util.lastAmongEquals,
                                 inserteeIndexIn => i,
                                 currentInsIndex => i);
                  populateInsertionIndexes(indexIn => tempIndex
                                          ,insertionOrderIn => engInsertionOrderList(i));
                end if;
                engStApproversCount := engStApproversCount + 1;
              end if;
            end if;
          end if;
        end if;
      end loop;
      /*
        Insert any displaced approvers at the end of their items' lists, if possible; and
        otherwise at the end of the transaction's list.
      */
      for i in 1 .. displacedInserteeIndexes.count loop
        parameterFields.delete;
        parseFields(stringIn => engInsertionParameterList(displacedInserteeIndexes(i)),
                    fieldsOut => parameterFields);
        /* Set tempBoolean false if displaced approver i is inserted at the end of its item's list. */
        tempBoolean := true;
        engStApproversCount := engStApprovers.count;
        for j in 1 .. engStApproversCount loop
          if(engStApprovers(j).item_id = parameterFields(2) and
             engStApprovers(j).item_class = parameterFields(3) and
             (j = engStApproversCount or
              engStApprovers(j + 1).item_id <> parameterFields(2) or
              engStApprovers(j + 1).item_class <> parameterFields(3))) then
            if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
              fnd_log.string
                (fnd_log.level_statement
                ,'ame_engine.processAdhocInsertions'
                ,'Adhoc Insertion approver(displaced) ::: ' || engInsertedApproverList(displacedInserteeIndexes(i)).name
                );
            end if;
            insertApprover(indexIn => j + 1,
                           approverIn => engInsertedApproverList(displacedInserteeIndexes(i)),
                           adjustMemberOrderNumbersIn => true,
                           inserteeIndexIn => i,
                           currentInsIndex => i);
            populateInsertionIndexes(indexIn => j + 1
                                    ,insertionOrderIn => engInsertionOrderList(displacedInserteeIndexes(i)));
            tempBoolean := false;
            exit;
          end if;
        end loop;
        if(tempBoolean) then
          if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
            fnd_log.string
              (fnd_log.level_statement
              ,'ame_engine.processAdhocInsertions'
              ,'Adhoc Insertion approver(displaced) ::: ' || engInsertedApproverList(displacedInserteeIndexes(i)).name
              );
          end if;
          insertApprover(indexIn => engStApproversCount + 1,
                         approverIn => engInsertedApproverList(displacedInserteeIndexes(i)),
                         adjustMemberOrderNumbersIn => false,
                         inserteeIndexIn => i,
                         currentInsIndex => i);
          populateInsertionIndexes(indexIn => engStApproversCount + 1
                                  ,insertionOrderIn => engInsertionOrderList(displacedInserteeIndexes(i)));
        end if;
        engStApproversCount := engStApproversCount + 1;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'processAdHocInsertions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end processAdHocInsertions;
  --+
  --
  --+
  procedure getAllProductions(productionsOut out nocopy ame_util2.productionsTable) is
    begin
      for i in 1 .. engStProductionsTable.count loop
        productionsOut(i).variable_name := engStProductionsTable(i).variable_name;
        productionsOut(i).variable_value := engStProductionsTable(i).variable_value;
        productionsOut(i).item_class := engStProductionsTable(i).item_class;
        productionsOut(i).item_id := engStProductionsTable(i).item_id;
      end loop;
    end getAllProductions;
  procedure getProductions(itemClassIn    in  varchar2
                          ,itemIdIn       in  varchar2
                          ,productionsOut out nocopy ame_util2.productionsTable) is
    tempIndex integer;
    begin
      tempIndex := 1;
      for i in 1 .. engStProductionsTable.count loop
        if itemClassIn = engStProductionsTable(i).item_class and
         itemIdIn    = engStProductionsTable(i).item_id then
          productionsOut(tempIndex).variable_name := engStProductionsTable(i).variable_name;
          productionsOut(tempIndex).variable_value := engStProductionsTable(i).variable_value;
          productionsOut(tempIndex).item_class := engStProductionsTable(i).item_class;
          productionsOut(tempIndex).item_id := engStProductionsTable(i).item_id;
          tempIndex := tempIndex+1;
        end if;
      end loop;
    end getProductions;
  procedure processActionType as
    tempIndex integer;
    begin
      if(engAppRuleTypes(engAppHandlerFirstIndex) = ame_util.productionRuleType) then
        /*
          Copy item-level productions to the appropriate engStProductionsTable.  Note that we
          have to initialize tempIndex as below to account for the possibility of multiple
          production action types.
        */
        tempIndex := engStProductionsTable.count;
        for i in engAppHandlerFirstIndex .. engAppHandlerLastIndex loop
          tempIndex := tempIndex + 1;
          engStProductionsTable(tempIndex).variable_name  := engAppParameters(i);
          engStProductionsTable(tempIndex).variable_value := engAppParameterTwos(i);
          engStProductionsTable(tempIndex).item_class     := getHandlerItemClassName;
          engStProductionsTable(tempIndex).item_id        := getHandlerItemId;
          if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
            fnd_log.string
              (fnd_log.level_statement
              ,'ame_engine.processActionType'
              ,'Transaction Production ::: ' || engStProductionsTable(tempIndex).variable_name || '/' || engStProductionsTable(tempIndex).variable_value
              );
          end if;
        end loop;
      /*
        This elsif is necessary to avoid processing production actions of approver-generating rules.
        (The engine processes these after constructing the approver list.)
      */
      elsif(engActionTypeUsages(engAppActionTypeIds(engAppHandlerFirstIndex)) <>
            ame_util.productionRuleType) then
        /*
          Call the handler for action types other than the production-rule action type.
          (Per-approver productions get handled later.)
        */
        if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
          fnd_log.string
            (fnd_log.level_statement
            ,'ame_engine.processActionType'
            ,'Processing Action Type ::: ' || engAppActionTypeIds(engAppHandlerFirstIndex)
            );
        end if;
        execute immediate
          'begin ' ||
          getActionTypePackageName(actionTypeIdIn => engAppActionTypeIds(engAppHandlerFirstIndex)) ||
          '.handler; end;';
      end if;
      if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
          fnd_log.string
            (fnd_log.level_statement
            ,'ame_engine.processActionType'
            ,'Completed processing the action Type ::: ' || engAppActionTypeIds(engAppHandlerFirstIndex)
            );
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'processActionType',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end processActionType;
  procedure populateInsertionIndexes(indexIn in integer
                                    ,insertionOrderIn in integer) as
    firstIndex integer;
    lastIndex integer;
    tempValue integer;
    begin
      firstIndex := engStInsertionIndexes.first;
      if(engStInsertionIndexes.exists(firstIndex)) then
        lastIndex := engStInsertionIndexes.last;
        while engStInsertionIndexes.exists(lastIndex) and lastIndex >= indexIn loop
          tempValue := engStInsertionIndexes(lastIndex);
          engStInsertionIndexes(lastIndex + 1) := tempValue;
          engStInsertionIndexes.delete(lastIndex);
          lastIndex := engStInsertionIndexes.prior(lastIndex + 1);
        end loop;
        engStInsertionIndexes(indexIn) := insertionOrderIn;
      else
        engStInsertionIndexes(indexIn) := insertionOrderIn;
      end if;
    end populateInsertionIndexes;
  procedure processSuppressDeviation(approverIndexIn in number,suppressApproverIndex in number) as
   tempcount number;
  begin
   engDeviationResultList(approverIndexIn).effectiveDate := engSuppressionDateList(suppressApproverIndex);
   engDeviationResultList(approverIndexIn).reason := engSupperssionReasonList(suppressApproverIndex);
   exception
     when others then
       ame_util.runtimeException(packageNameIn => 'ame_engine',
                                 routineNameIn => 'processSuppressDeviation',
                                 exceptionNumberIn => sqlcode,
                                 exceptionStringIn => sqlerrm);
  end processSuppressDeviation;
  procedure processSuppressions as
    begin
      for i in 1 .. engDeletedApproverList.count loop
        for j in 1 .. engStApprovers.count loop
          if(engStApprovers(j).name = engDeletedApproverList(i).name and
             engStApprovers(j).occurrence = engDeletedApproverList(i).occurrence and
             engStApprovers(j).group_or_chain_id = engDeletedApproverList(i).group_or_chain_id and
             engStApprovers(j).action_type_id = engDeletedApproverList(i).action_type_id and
             engStApprovers(j).item_id = engDeletedApproverList(i).item_id and
             engStApprovers(j).item_class = engDeletedApproverList(i).item_class) then
            engStApprovers(j).approval_status := ame_util.suppressedStatus;
            engStApprovers(j).source := ame_util.apiSuppression;
            processSuppressDeviation(j,i);
            if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
              fnd_log.string
                (fnd_log.level_statement
                ,'ame_engine.processSuppressions'
                ,'Suppressed approver ::: ' || engStApprovers(j).name
                );
            end if;
          end if;
        end loop;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'processSuppressions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
   end processSuppressions;
  procedure processExceptions as
    authorityRuleSuppressed boolean;
    currentFirstAuthorityIndex integer;
    currentFirstExceptionIndex integer;
    currentFirstItemIndex integer;
    currentLastAuthorityIndex integer;
    currentLastExceptionIndex integer;
    currentLastItemIndex integer;
    currentItemClassId integer;
    currentItemId ame_util.stringType;
    ruleCount integer;
    tempAttributeId integer;
    tempAttributeIdsToMatch ame_util.idList;
    tempExcOrdCondAttributeIds ame_util.idList;
    tempBoolean boolean;
    tempBoolean2 boolean;
    begin
      /* Handle the empty-rule-list case first. */
      if(engAppRuleIds.count = 0) then
        return;
      end if;
      authorityRuleSuppressed := false;
      /* Check for exception rules. */
      ruleCount := engAppRuleIds.count; /* This value gets used later in the code too. */
      tempBoolean := true;
      for i in 1 .. ruleCount loop
        if(engAppRuleTypes(i) = ame_util.exceptionRuleType) then
          tempBoolean := false;
          exit;
        end if;
      end loop;
      if(tempBoolean) then /* No exception rules. */
        return;
      end if;
      /* Now handle the case of a nonempty rule list containing at least one exception rule. */
      currentLastItemIndex := 0; /* This will set currentFirstItemIndex to one below. */
      loop /* Loop through the sublists of rules applying to an item. */
        /* Initialize the current[whatever]Index values. */
        currentFirstItemIndex := currentLastItemIndex + 1;
        currentLastItemIndex := null;
        currentFirstAuthorityIndex := null;
        currentLastAuthorityIndex := null;
        currentFirstExceptionIndex := null;
        currentLastExceptionIndex := null;
        currentItemClassId := engAppRuleItemClassIds(currentFirstItemIndex);
        currentItemId := engAppAppItemIds(currentFirstItemIndex);
        /* Set the current[whatever]Index values. */
        for i in currentFirstItemIndex .. ruleCount loop
          if(currentItemClassId <> engAppRuleItemClassIds(i) or
             currentItemId <> engAppAppItemIds(i)) then
            currentLastItemIndex := i - 1;
            exit;
          elsif(i = ruleCount) then
            currentLastItemIndex := i;
          end if;
          if(engAppRuleTypes(i) = ame_util.authorityRuleType) then
            if(currentFirstAuthorityIndex is null) then
              currentFirstAuthorityIndex := i;
            end if;
            currentLastAuthorityIndex := i;
          elsif(engAppRuleTypes(i) = ame_util.exceptionRuleType) then
            if(currentFirstExceptionIndex is null) then
              currentFirstExceptionIndex := i;
            end if;
            currentLastExceptionIndex := i;
          end if;
        end loop;
        /* Process the current item's exception rules (if any). */
        if(currentFirstExceptionIndex is not null) then
          for i in currentFirstExceptionIndex .. currentLastExceptionIndex loop
            /*
              Build the list of attribute IDs for the ordinary conditions used by this exception
              (in the local variable tempExcOrdCondAttributeIds) by looping through the engACU variables
              until the current exception's rule ID is matched.  Index the list of attribute IDs by
              attribute ID (the value doesn't matter, so we set it to a constant--one--for efficiency).
              Here tempBoolean indicates whether the exception rule has been found in the engACU
              variables, so we can exit the inner loop once we find all of the exception's attributes.
            */
            tempBoolean := false;
            tempExcOrdCondAttributeIds.delete;
            for j in 1 .. engACUsageRuleIds.count loop
              if(engACUsageRuleIds(j) = engAppRuleIds(i)) then
                tempBoolean := true;
                if(engACConditionTypes(engACUsageConditionIds(j)) = ame_util.ordinaryConditionType) then
                  tempExcOrdCondAttributeIds(engACAttributeIds(engACUsageConditionIds(j))) := 1;
                end if;
              elsif(tempBoolean) then
                exit;
              end if;
            end loop;
            /* Suppress authority rules as necessary. */
            if(currentFirstAuthorityIndex is not null) then
              for j in currentFirstAuthorityIndex .. currentLastAuthorityIndex loop
                /* A previous iteration of the i loop could have suppressed the rule at j; check for this. */
                if(engAppRuleIds.exists(j)) then
                  /*
                    Rather than rebuild tempExcOrdCondAttributeIds at each iteration,
                    copy it at each iteration, so we can freely delete entries in the
                    copy.
                  */
                  tempAttributeIdsToMatch.delete;
                  ame_util.copyIdList(idListIn => tempExcOrdCondAttributeIds,
                                      idListOut => tempAttributeIdsToMatch);
                  /*
                    For an applicable exception to override an otherwise applicable authority rule,
                    both rules' ordinary conditions must be defined on the same attributes.  (If
                    neither rule has any ordinary conditions, the exception overrides the authority
                    rule.)  Here tempBoolean indicates whether each of the authority rule's
                    attributes were matched, and tempBoolean2 indicates whether the target authority
                    rule has been found in the engACU variables.
                  */
                  tempBoolean := true;
                  tempBoolean2 := false;
                  for k in 1 .. engACUsageRuleIds.count loop
                    if(engACUsageRuleIds(k) = engAppRuleIds(j)) then
                      tempBoolean2 := true;
                      /*
                        (An authority rule only has ordinary conditions, so we don't have to check
                        the condition type here.)
                      */
                      tempAttributeId := engACAttributeIds(engACUsageConditionIds(k));
                      if(tempAttributeIdsToMatch.exists(tempAttributeId)) then
                        tempAttributeIdsToMatch.delete(tempAttributeId);
                      else
                        tempBoolean := false;
                        exit;
                      end if;
                    elsif(tempBoolean2) then
                      exit;
                    end if;
                  end loop;
                  if(tempBoolean and
                     tempAttributeIdsToMatch.count = 0) then
                    /*
                      All of the authority rule's conditions' attributes were matched, and all of the
                      exception's ordinary conditions' attributes were matched; so, delete the authority
                      rule from the list of applicable rules.
                    */
                    authorityRuleSuppressed := true;
                    engAppItemClassIds.delete(j);
                    engAppItemIds.delete(j);
                    engAppRuleIds.delete(j);
                    engRuleAppliedYN.delete(j);
                    engAppRuleTypes.delete(j);
                    engAppActionTypeIds.delete(j);
                    engAppParameters.delete(j);
                    engAppParameterTwos.delete(j);
                    engAppRuleItemClassIds.delete(j);
                    engAppAppItemIds.delete(j);
                  end if;
                end if;
              end loop; /* j */
            end if;
            /*
              Convert the exception rule to an authority rule, so it gets processed with
              the remaining authority rules.
            */
            engAppRuleTypes(i) := ame_util.authorityRuleType;
          end loop;
        end if;
        /* Exit the outer loop if no more item rule lists exist. */
        if(currentLastItemIndex = ruleCount) then
          exit;
        end if;
      end loop;
      /* Re-compact the engApp lists if any authority rules got deleted. */
      if(authorityRuleSuppressed) then
        compactEngAppLists(compactPrioritiesIn => false,
                           compactActionTypeIdsIn => true,
                           compactParametersIn => true);
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'processExceptions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end processExceptions;
  procedure processRepeatedApprovers as
    engAppRuleIdsCount integer;
    engStApproversCount integer;
    productionActionTypeId integer;
    repeatedApproversMode ame_util.attributeValueType;
    repeatedByApproverIndex integer;
    repeatedIndexesList ame_util.idList;
    tempAuthority ame_util.charType;
    tempActionTypeId integer;
    tempCount integer;
    tempEngStItemIndex integer;
    tempEngStProductionIndex integer;
    tempEngStRuleIndex integer;
    tempFirstIndexOfLastItem integer;
    tempFirstOccurrenceCurGrouping integer;
    tempGroupOrChainId integer;
    tempItemClass ame_util.stringType;
    tempItemId ame_util.stringType;
    tempApproverCategory ame_util.charType;
    tempProcessApprover boolean;
    tempRuleNotFound boolean;
    tempRuleIdList ame_util.idList;
    tempRuleIdList2 ame_util.idList;
    tempSourceDescription ame_util.longStringType;
    treeLevel integer;
    tempRepeatedAprCount number;
    tempChangeStatus boolean;
    begin
      /*
        This procedure does two things:  (1) suppress repeated approvers, and (2) aggregate various
        approver-related data in appropriate engSt package variables.  The aggregation has to occur
        for all occurrences of a wf_roles.name value in engStApprovers, at once; so this procedure's
        outer loop iterates through engStApprovers, doing the aggregation.  The inner loop suppresses
        repeated approvers.
      */
      tempEngStItemIndex := 0; /* pre-increment */
      tempEngStProductionIndex := 0; /* pre-increment */
      tempEngStRuleIndex := 0; /* pre-increment */
      repeatedApproversMode := getConfigVarValue(configVarNameIn => ame_util.repeatedApproverConfigVar);
      /* Set treeLevel for efficiency in the inner loop. */
      if(repeatedApproversMode = ame_util.oncePerTransaction) then
        treeLevel := 0;
      elsif(repeatedApproversMode = ame_util.oncePerItemClass) then
        treeLevel := 1;
      elsif(repeatedApproversMode = ame_util.oncePerItem) then
        treeLevel := 2;
      elsif(repeatedApproversMode = ame_util.oncePerSublist) then
        treeLevel := 3;
      elsif(repeatedApproversMode = ame_util.oncePerActionType) then
        treeLevel := 4;
      elsif(repeatedApproversMode = ame_util.oncePerGroupOrChain) then
        treeLevel := 5;
      else /* repeatedApproversMode = ame_util.eachOccurrence */
        treeLevel := 6;
      end if;
      engStApproversCount := engStApprovers.count;
      for i in 1 .. engStApproversCount loop
        /*
          We only want to process an approver if the approver has not been previously processed and
          has not been suppressed.  If an approver was suppressed, they can't aggregate the approvals
          requirements of subsequent occurrences of the same wf_roles.name in engStApprovers.  If an
          approver was previously processed, we don't want to duplicate their data in the engStItem
          variables.
        */
        tempProcessApprover := true;
        if(engStApprovers(i).approval_status in (ame_util.suppressedStatus
                                                ,ame_util.repeatedStatus)) then
          tempProcessApprover := false;
        else
          for j in 1 .. (i - 1) loop
            if(engStApprovers(j).name = engStApprovers(i).name and
               engStApprovers(j).approver_category = engStApprovers(i).approver_category) then
              tempProcessApprover := false;
              exit;
            end if;
          end loop;
        end if;
        if(tempProcessApprover) then
          /*
            Iterate through the rest of the approver list, looking for engStApprovers(i).name, and outputting
            each occurrence's data as required to various engSt variables.  If engStApprovers(i).name has
            already occurred in the current grouping, set engStApprovers(i).approval_status to
            ame_util.repeatedStatus and output its data for the index tempFirstOccurrenceCurGrouping.
            Otherwise output its data for index j.  (Set tempFirstOccurrenceCurGrouping to j when we find a
            new repeated-approvers grouping.)
          */
          for j in i .. engStApproversCount loop
            if(engStApprovers(j).name = engStApprovers(i).name and
               engStApprovers(j).approver_category = engStApprovers(i).approver_category) then
              /*
                 If repeatedApproversMode is ame_util.oncePerTransaction (that is, treeLevel = 6),
                 all occurrences of the approver with j > i are repeated.
              */
              if(j = i or
                 treeLevel = 6 or
                 (treelevel = 5 and tempGroupOrChainId <> engStApprovers(j).group_or_chain_id) or
                 (treeLevel > 3 and tempActionTypeId <> engStApprovers(j).action_type_id) or
                 (treeLevel > 2 and tempAuthority <> engStApprovers(j).authority) or
                 (treeLevel > 1 and tempItemId <> engStApprovers(j).item_id) or
                 (treeLevel > 0 and tempItemClass <> engStApprovers(j).item_class)) then
                /* We're in a new repeatedApprovers grouping. */
                tempFirstOccurrenceCurGrouping := j;
                tempGroupOrChainId := engStApprovers(j).group_or_chain_id;
                tempActionTypeId := engStApprovers(j).action_type_id;
                tempAuthority := engStApprovers(j).authority;
                tempItemId := engStApprovers(j).item_id;
                tempItemClass := engStApprovers(j).item_class;
                repeatedIndexesList(1) := j;
              else /* This is a repeated approver. */
                /*
                  Don't overwrite non-null statuses with ame_util.repeatedStatus.  These can reflect
                  per-item approver responses.  See the ame_api2.updateApprovalStatus code for details.
                  Also, don't suppress special forwardees.  See bug 3401298 for details.
                */
                if(engStApprovers(j).approval_status is null and
                   engStApprovers(j).source not like ame_util.specialForwardInsertion || '%') then
                  engStApprovers(j).approval_status := ame_util.repeatedStatus;
                  if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
                    fnd_log.string
                      (fnd_log.level_statement
                      ,'ame_engine.processRepeatedApprovers'
                      ,'Repeated Approver ::: ' || engStApprovers(j).name
                      );
                  end if;
                end if;
                if engStApprovers(j).approval_status in (ame_util.repeatedStatus
                                                        ,ame_util.notifiedByRepeatedStatus
                                                        ,ame_util.approvedByRepeatedStatus
                                                        ,ame_util.rejectedByRepeatedStatus
                                                        ,ame_util.rejectStatus
                                                        ,ame_util.approvedStatus
                                                        ,ame_util.notifiedStatus
                                                        ,ame_util.beatByFirstResponderStatus) then
                  /* Get the repeated by approver's tree node index */
                  repeatedIndexesList(repeatedIndexesList.count + 1) := j;
                end if;
              end if;
            end if;
          end loop;
          tempCount := engStRepeatedIndexes.count;
          if repeatedIndexesList.count > 1 then
            for x in 1 .. repeatedIndexesList.count loop
              for y in 1 .. repeatedIndexesList.count loop
                tempCount := tempCount + 1;
                engStRepeatedIndexes(tempCount) := repeatedIndexesList(x);
                engStRepeatedAppIndexes(tempCount) := repeatedIndexesList(y);
              end loop;
            end loop;
          end if;
          repeatedIndexesList.delete;
        end if;
      end loop;
      -- Handle the case of migration from pre ASP to ASP.
      for i in 1 .. engStApprovers.count loop
        for j in 1 .. engStRepeatedIndexes.count loop
          if engStRepeatedIndexes(j) = i and engStRepeatedAppIndexes(j) <> i then
            if engStApprovers(i).approval_status = ame_util.repeatedStatus or
               engStApprovers(i).approval_status is null then
              if engStApprovers(engStRepeatedAppIndexes(j)).approval_status = ame_util.approvedStatus then
                engStApprovers(i).approval_status := ame_util.approvedByRepeatedStatus;
              elsif engStApprovers(engStRepeatedAppIndexes(j)).approval_status
                                              = ame_util.noResponseStatus then
                engStApprovers(i).approval_status := ame_util2.noResponseByRepeatedStatus;
              elsif engStApprovers(engStRepeatedAppIndexes(j)).approval_status
                                              = ame_util.notifiedStatus then
                engStApprovers(i).approval_status := ame_util.notifiedByRepeatedStatus;
              elsif engStApprovers(engStRepeatedAppIndexes(j)).approval_status
                                              = ame_util.forwardStatus then
                engStApprovers(i).approval_status := ame_util2.forwardByRepeatedStatus;
              end if;
            end if;
          end if;
        end loop;
      end loop;
      -- handle the repetaed status case
      tempRepeatedAprCount := engStRepeatedIndexes.count;
      for i in 1..engStApprovers.count loop
        if engStApprovers(i).approval_status in (ame_util.notifiedByRepeatedStatus
                                                ) then
          if tempRepeatedAprCount = 0 then
            if engStApprovers(i).approval_status = ame_util.notifiedByRepeatedStatus then
              engStApprovers(i).approval_status := ame_util.notifiedStatus ;
            end if;
          end if;
          tempChangeStatus := true;
          for j in 1..tempRepeatedAprCount loop
            if engStRepeatedIndexes(j) = i and engStRepeatedAppIndexes(j) <> i then
              if engStApprovers(engStRepeatedAppIndexes(j)).approval_status is null or
                 (engStApprovers(engStRepeatedAppIndexes(j)).approval_status = ame_util.notifiedStatus
                   and engStApprovers(i).approval_status = ame_util.notifiedByRepeatedStatus ) then
                 tempChangeStatus := false;
                exit;
              end if;
            end if;
          end loop;
          if tempChangeStatus then
            if engStApprovers(i).approval_status = ame_util.notifiedByRepeatedStatus then
              engStApprovers(i).approval_status := ame_util.notifiedStatus ;
            end if;
          end if;
        end if;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'processRepeatedApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end processRepeatedApprovers;
  procedure processRules(processOnlyProductionsIn in boolean default false) as
    currentActionTypeId integer;
    currentFirstItemIndex integer;
    currentFirstRuleIndexes ame_util.idList; /* indexed by rule type */
    currentIndex integer;
    currentItemClassId integer;
    currentItemId ame_util.stringType;
    currentLastItemIndex integer;
    currentLastRuleIndexes ame_util.idList; /* indexed by rule type */
    currentRuleType integer;
    ruleCount integer;
    ruleTypes ame_util.idList;
    tempIndex integer;
    tempLastRuleIndex integer;
    tempRuleType integer;
    ruleTypeUpperLimit integer;
    begin
      /* Handle the empty-rule-list case first. */
      if(engAppRuleIds.count = 0) then
        return;
      end if;
      /* Now handle the nonempty-rule-list case. . . . */
      /*
        Set the order in which rule types are processed, for a given item.
        Combination rules have already been split into their single-action
        components, and exceptions have been converted into authority rules,
        so ignore these rule types.
      */
      ruleTypes(1) := ame_util.productionRuleType;
      ruleTypes(2) := ame_util.preListGroupRuleType;
      ruleTypes(3) := ame_util.authorityRuleType;
      ruleTypes(4) := ame_util.postListGroupRuleType;
      ruleTypes(5) := ame_util.listModRuleType;
      ruleTypes(6) := ame_util.substitutionRuleType;
      /* Initialize the engine substitution variables. */
      engAppSubHandlerFirstIndex  := null;
      engAppSubHandlerLastIndex  := null;
      /* Initialize the state variables. */
      ruleCount := engAppRuleIds.count;
      currentItemClassId := engAppRuleItemClassIds(1);
      currentItemId := engAppAppItemIds(1);
      currentRuleType := engAppRuleTypes(1);
      currentFirstItemIndex := 1;
      currentFirstRuleIndexes(currentRuleType) := 1;
      currentIndex := 2;
      /* Iterate through the items. */
      loop
        if(currentIndex > ruleCount or
           currentItemClassId <> engAppRuleItemClassIds(currentIndex) or
           currentItemId <> engAppAppItemIds(currentIndex)) then
          currentLastItemIndex := currentIndex - 1;
          currentLastRuleIndexes(currentRuleType) := currentLastItemIndex;
        elsif(currentRuleType <> engAppRuleTypes(currentIndex)) then
          currentLastRuleIndexes(currentRuleType) := currentIndex - 1;
          currentRuleType := engAppRuleTypes(currentIndex);
          currentFirstRuleIndexes(currentRuleType) := currentIndex;
        end if;
        if(currentLastItemIndex is not null) then
          /* Process the current item's rules. */
          if processOnlyProductionsIn then
            if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
              fnd_log.string
                (fnd_log.level_statement
                ,'ame_engine.processRules'
                ,'Processing only production rules'
                );
            end if;
            ruleTypeUpperLimit := 1;
          else
            if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
              fnd_log.string
                (fnd_log.level_statement
                ,'ame_engine.processRules'
                ,'Processing all rules'
                );
            end if;
            ruleTypeUpperLimit := 6;
          end if;
          for i in 1 .. ruleTypeUpperLimit loop
            /* Process the action types within rule type ruleTypes(i). */
            tempRuleType := ruleTypes(i);
            if(currentFirstRuleIndexes.exists(tempRuleType)) then
              /* Initialize the action-type state variables. */
              engAppHandlerFirstIndex := currentFirstRuleIndexes(tempRuleType);
              currentActionTypeId := engAppActionTypeIds(engAppHandlerFirstIndex);
              tempIndex := engAppHandlerFirstIndex + 1;
              tempLastRuleIndex := currentLastRuleIndexes(tempRuleType);
              loop
                if(tempIndex > tempLastRuleIndex or
                   currentActionTypeId <> engAppActionTypeIds(tempIndex)) then
                  /* Process the current action type for the current item. */
                  engAppHandlerLastIndex := tempIndex - 1;
                  processActionType;
                  if (currentRuleType = ame_util.substitutionRuleType) then
                    /* Set variables so subsequent call to the substitution handler is
                    possible without iterating through the applicable rule list again */
                    engAppSubHandlerFirstIndex :=currentFirstRuleIndexes(tempRuleType);
                    engAppSubHandlerLastIndex := currentLastRuleIndexes(tempRuleType);
                  end if;
                  if(tempIndex <= tempLastRuleIndex) then
                    /* Update the current action-type state variables. */
                    engAppHandlerFirstIndex := tempIndex;
                    currentActionTypeId := engAppActionTypeIds(tempIndex);
                  end if;
                end if;
                /* Iterate or exit. */
                if(tempIndex > tempLastRuleIndex) then
                  exit;
                end if;
                tempIndex := tempIndex + 1;
              end loop;
            end if;
          end loop;
          if(currentIndex <= ruleCount) then
            /* Update the current state variables. */
            currentFirstRuleIndexes.delete;
            currentLastRuleIndexes.delete;
            currentItemClassId := engAppRuleItemClassIds(currentIndex);
            currentItemId := engAppAppItemIds(currentIndex);
            currentRuleType := engAppRuleTypes(currentIndex);
            currentFirstItemIndex := currentIndex;
            currentFirstRuleIndexes(currentRuleType) := currentIndex;
            currentLastItemIndex := null;
          end if;
        end if;
        /* Iterate or exit. */
        if(currentIndex > ruleCount) then
          exit;
        end if;
        currentIndex := currentIndex + 1;
      end loop;
      if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
        if engStApprovers.count = 0 then
          fnd_log.string
            (fnd_log.level_statement
            ,'ame_engine.processRules'
            ,'**************** No Approvers ******************'
            );
        else
          for i in 1 .. engStApprovers.count loop
            fnd_log.string
              (fnd_log.level_statement
              ,'ame_engine.processRules'
              ,'Approver ::: ' || engStApprovers(i).name
              );
          end loop;
        end if;
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'processRules',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end processRules;
  procedure processRelativePriorities as
    currentItemClassId integer;
    currentItemId ame_util.stringType;
    currentRuleType integer;
    currentThreshold integer;
    engAppRuleIdsCount integer;
    ruleDeleted boolean;
    tempAbsoluteThreshold integer;
    tempDoRelativePriorities boolean;
    tempFirstIndex integer;
    tempLastIndex integer;
    tempThresholdCounter integer;
    tempThresholds ame_util.idList;
    ruleExists boolean;
    tempIndex integer;
    oldTempIndex integer;
    begin
      /* Handle the trivial case here, so we can assume a non-empty applicable-rules list. */
      if(engAppRuleIds.count = 0) then
        return;
      end if;
      /* Now for the non-empty-list case. */
      ruleDeleted := false;
      /* Now for the non-empty-list case. */
      if engEvalPrioritiesPerItem then
        /* Evaluate priorites per item */
        tempFirstIndex := 1;
        engAppRuleIdsCount := engAppRuleIds.count;
        loop
          currentItemClassId := engAppRuleItemClassIds(tempFirstIndex);
          currentItemId := engAppAppItemIds(tempFirstIndex);
          currentRuleType := engAppRuleTypes(tempFirstIndex);
          tempThresholds.delete;
          tempLastIndex := null;
          tempDoRelativePriorities := engPriorityModes(currentRuleType) = ame_util.relativeRulePriority;
          /* Find tempLastIndex and optionally set the values in tempThresholds. */
          for i in tempFirstIndex .. engAppRuleIdsCount loop
            /* The following if does its comparisons in descending order of probability of success, for efficiency. */
            if(currentRuleType <> engAppRuleTypes(i) or
               currentItemId <> engAppAppItemIds(i) or
               currentItemClassId <> engAppRuleItemClassIds(i)) then
              tempLastIndex := i - 1;
              exit;
            else
              if(tempDoRelativePriorities) then
                /* The tempThresholds index and value are the same for convenience. */
                if engAppPriorities(i) is null then
                  tempThresholds(99999) := engAppPriorities(i);
                else
                  tempThresholds(engAppPriorities(i)) := engAppPriorities(i);
                end if;
              end if;
            end if;
          end loop;
          if(tempLastIndex is null) then
            tempLastIndex := engAppRuleIdsCount;
          end if;
          if(tempDoRelativePriorities) then
            /* Find the absolute threshold equivalent to the relative. */
            tempAbsoluteThreshold := tempThresholds.first;
            tempThresholdCounter := 1;
            currentThreshold := engPriorityThresholds(currentRuleType);
            while (tempThresholdCounter < currentThreshold) loop
              tempAbsoluteThreshold := tempThresholds.next(tempAbsoluteThreshold);
              tempThresholdCounter := tempThresholdCounter + 1;
            end loop;
            /* Do priority processing between tempFirstIndex and tempLastIndex. */
            for i in tempFirstIndex .. tempLastIndex loop
              if(engAppPriorities(i) is null or
                 engAppPriorities(i) > tempAbsoluteThreshold) then
                engAppRuleIds.delete(i);
                engRuleAppliedYN.delete(i);
                engAppItemClassIds.delete(i);
                engAppItemIds.delete(i);
                engAppPriorities.delete(i);
                engAppApproverCategories.delete(i);
                engAppRuleTypes.delete(i);
                engAppRuleItemClassIds.delete(i);
                engAppAppItemIds.delete(i);
                ruleDeleted := true;
              end if;
            end loop;
          end if;
          /* If there are no more applicable rules to process, stop. */
          if(tempLastIndex = engAppRuleIdsCount) then
            exit;
          end if;
          tempFirstIndex := tempLastIndex + 1;
        end loop;
      else
        /* Evaluate priorities at transaction level */
        /* BUG Fixes : 4472308 and 4065967 */
        for i in 0 .. 7 loop
          tempDoRelativePriorities := engPriorityModes(i) = ame_util.relativeRulePriority;
          if tempDoRelativePriorities then
            ruleExists := false;
            tempIndex := engAppRuleIds.first;
            loop
              if engAppRuleTypes(tempIndex) = i then
                if engAppPriorities(tempIndex) is null then
                  tempThresholds(99999) := engAppPriorities(tempIndex);
                else
                  tempThresholds(engAppPriorities(tempIndex)) := engAppPriorities(tempIndex);
                end if;
                ruleExists := true;
              end if;
              tempIndex := engAppRuleIds.next(tempIndex);
              exit when tempIndex is null;
            end loop;
            if ruleExists then
              tempAbsoluteThreshold := tempThresholds.first;
              tempThresholdCounter := 1;
              currentThreshold := engPriorityThresholds(i);
              while (tempThresholdCounter < currentThreshold) loop
                tempAbsoluteThreshold := tempThresholds.next(tempAbsoluteThreshold);
                tempThresholdCounter := tempThresholdCounter + 1;
              end loop;
              tempIndex := engAppRuleIds.first;
              loop
                if(engAppRuleTypes(tempIndex) = i and
                   (engAppPriorities(tempIndex) is null or
                    engAppPriorities(tempIndex) > tempAbsoluteThreshold)) then
                  oldTempIndex := tempIndex;
                  tempIndex := engAppRuleIds.next(oldTempIndex);
                  engAppRuleIds.delete(oldTempIndex);
                  engRuleAppliedYN.delete(oldTempIndex);
                  engAppItemClassIds.delete(oldTempIndex);
                  engAppItemIds.delete(oldTempIndex);
                  engAppPriorities.delete(oldTempIndex);
                  engAppApproverCategories.delete(oldTempIndex);
                  engAppRuleTypes.delete(oldTempIndex);
                  engAppRuleItemClassIds.delete(oldTempIndex);
                  engAppAppItemIds.delete(oldTempIndex);
                  ruleDeleted := true;
                else
                  tempIndex := engAppRuleIds.next(tempIndex);
                end if;
                exit when tempIndex is null;
              end loop;
            end if;
          end if;
        end loop;
      end if;
      /* If relative-priority processing deleted one or more rules from the engApp lists, compact them. */
      if(ruleDeleted) then
        compactEngAppLists(compactPrioritiesIn => true,
                           compactActionTypeIdsIn => false,
                           compactParametersIn => false);
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'processRelativePriorities',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end processRelativePriorities;
  procedure processUnresponsiveApprovers as
    engStApproversCount integer;
    tempIndex integer;
    tempSurrogateApprover ame_util.approverRecord2;
    begin
      /* First handle the empty-list case. */
      engStApproversCount := engStApprovers.count;
      if(engStApproversCount = 0) then
        return;
      end if;
      /* Now handle the non-empty case. */
      tempIndex := 1; /* post-increment */
      loop
        if(engStApprovers(tempIndex).approval_status = ame_util.noResponseStatus) then
          /* Fetch surrogate's wf_roles-specific data. */
          ame_approver_type_pkg.getSurrogate(origSystemIn => engStApprovers(tempIndex).orig_system,
                                             origSystemIdIn => engStApprovers(tempIndex).orig_system_id,
                                             origSystemIdOut => tempSurrogateApprover.orig_system_id,
                                             wfRolesNameOut => tempSurrogateApprover.name,
                                             displayNameOut => tempSurrogateApprover.display_name);
          tempSurrogateApprover.orig_system := engStApprovers(tempIndex).orig_system;
          /* Set fields constant for all surrogates. */
          tempSurrogateApprover.api_insertion := ame_util.apiInsertion;
          tempSurrogateApprover.source := ame_util.surrogateInsertion;
          /* Set common-valued fields. */
          tempSurrogateApprover.approver_category := engStApprovers(tempIndex).approver_category;
          tempSurrogateApprover.authority := engStApprovers(tempIndex).authority;
          tempSurrogateApprover.action_type_id := engStApprovers(tempIndex).action_type_id;
          tempSurrogateApprover.group_or_chain_id := engStApprovers(tempIndex).group_or_chain_id;
          tempSurrogateApprover.item_class := engStApprovers(tempIndex).item_class;
          tempSurrogateApprover.item_id := engStApprovers(tempIndex).item_id;
          tempSurrogateApprover.item_class_order_number := engStApprovers(tempIndex).item_class_order_number;
          tempSurrogateApprover.item_order_number := engStApprovers(tempIndex).item_order_number;
          tempSurrogateApprover.sub_list_order_number := engStApprovers(tempIndex).sub_list_order_number;
          tempSurrogateApprover.action_type_order_number := engStApprovers(tempIndex).action_type_order_number;
          tempSurrogateApprover.group_or_chain_order_number := engStApprovers(tempIndex).group_or_chain_order_number;
          /* Set remaining fields. */
          tempSurrogateApprover.occurrence :=
            getHandlerOccurrence(nameIn => tempSurrogateApprover.name,
                                 itemClassIn => tempSurrogateApprover.item_class,
                                 itemIdIn => tempSurrogateApprover.item_id,
                                 actionTypeIdIn => tempSurrogateApprover.action_type_id,
                                 groupOrChainIdIn => tempSurrogateApprover.group_or_chain_id);
          tempSurrogateApprover.approval_status := getHandlerApprovalStatus(approverIn => tempSurrogateApprover);
          /* The member order number and the approver order number are set here
             instead of in insertApprover. This will ensure that the surrogate has the same
             order as the unresponsive approver. Also changed call to insertApprover so that
             adjustMemberOrderNumbers is false */
          tempSurrogateApprover.member_order_number := engStApprovers(tempIndex).member_order_number;
          tempSurrogateApprover.approver_order_number := engStApprovers(tempIndex).approver_order_number;
          /* tempSurrogateApprover.approver_order_number also gets set later. */
          if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
            fnd_log.string
              (fnd_log.level_statement
              ,'ame_engine.processUnresponsiveApprovers'
              ,'Unresponsive approver ::: ' || engStApprovers(tempIndex).name || ' Surrogate ::: ' || tempSurrogateApprover.name
              );
          end if;
          engTempReason := ame_approver_deviation_pkg.timeoutReason;
          engTempDate := sysdate;
          insertApprover(indexIn => tempIndex + 1,
                         approverIn => tempSurrogateApprover,
                         adjustMemberOrderNumbersIn => false);
          engStApproversCount := engStApproversCount + 1;
        end if;
        if(tempIndex = engStApproversCount) then
          exit;
        end if;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'processUnresponsiveApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end processUnresponsiveApprovers;
  procedure repeatSubstitutions as
    currentActionTypeId integer;
    begin
      /* Check if any substitution rule exists. This can be done by checking if
         engAppSubHandlerFirstIndex  is null or not */
      if not(engAppSubHandlerFirstIndex  is null or
             engAppSubHandlerLastIndex is null) then
        /* Initialize the action-type state variables. */
        engAppHandlerFirstIndex := engAppSubHandlerFirstIndex;
        engAppHandlerLastIndex := engAppSubHandlerLastIndex;
        processActionType;
      end if;
    end repeatSubstitutions;
  procedure setContext(isTestTransactionIn in boolean,
                       isLocalTransactionIn in boolean,
                       fetchConfigVarsIn in boolean,
                       fetchOldApproversIn in boolean,
                       fetchInsertionsIn in boolean,
                       fetchDeletionsIn in boolean,
                       fetchAttributeValuesIn in boolean,
                       fetchInactiveAttValuesIn in boolean,
                       processProductionActionsIn in boolean,
                       processProductionRulesIn in boolean,
                       updateCurrentApproverListIn in boolean,
                       updateOldApproverListIn in boolean,
                       processPrioritiesIn in boolean,
                       prepareItemDataIn in boolean,
                       prepareRuleIdsIn in boolean,
                       prepareRuleDescsIn in boolean,
                       prepareApproverTreeIn in boolean default false,
                       transactionIdIn in varchar2,
                       ameApplicationIdIn in integer default null,
                       fndApplicationIdIn in integer default null,
                       transactionTypeIdIn in varchar2 default null) as
    badLocalTransException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    nullValuesException exception;
    tempConfigVarValue ame_config_vars.variable_value%type;
    begin
      /*
        Clear all of the package variables, to be conservative.  (The application server does not initialize
        package variables.  See http://www-apps.us.oracle.com/atg/plans/r1153/plsqlglobals.txt for details.)
      */
      engLMParameterOnes.delete;
      engLMParameterTwos.delete;
      engGroupMemberGroupIds.delete;
      engGroupMemberNames.delete;
      engGroupMemberOrderNumbers.delete;
      engGroupMemberDisplayNames.delete;
      engGroupMemberOrigSystems.delete;
      engGroupMemberOrigSystemIds.delete;
      engGroupUseItemBind.delete;
      engAppActionTypeIds.delete;
      engAppApproverCategories.delete;
      engAppItemClassIds.delete;
      engAppItemIds.delete;
      engAppLMSubItemClassIds.delete;
      engAppLMSubItemIds.delete;
      engAppParameters.delete;
      engAppParameterTwos.delete;
      engAppPriorities.delete;
      engAppRuleIds.delete;
      engRuleAppliedYN.delete;
      engAppRuleTypes.delete;
      engAppRuleItemClassIds.delete;
      engAppAppItemIds.delete;
      engAppPerAppProdFirstIndexes.delete;
      engAppPerAppProdRuleIds.delete;
      engAppPerAppProdVariableNames.delete;
      engAppPerAppProdVariableValues.delete;
      engStApprovers.delete;
      /* Clear the engine approver tree */
      engStApproversTree.delete;
      engStItemClasses.delete;
      engStItemIds.delete;
      engStItemIndexes.delete;
      engStItemSources.delete;
      engStProductionIndexes.delete;
      /* Clear repeated indexes list */
      engStRepeatedIndexes.delete;
      engStRepeatedAppIndexes.delete;
      engStRuleDescriptions.delete;
      engStRuleIds.delete;
      engStRuleIndexes.delete;
      engStSourceTypes.delete;
      /* Clear suspended items list */
      engStSuspendedItems.delete;
      engStSuspendedItemClasses.delete;
      engStProductionsTable.delete;
      engStVariableNames.delete;
      engStVariableValues.delete;
      engStItemAppProcessCompleteYN.delete;
      engConfigVarNames.delete;
      engConfigVarValues.delete;
      engForwardingBehaviors.delete;
      engPriorityModes.delete;
      engPriorityThresholds.delete;
      engActionTypeChainOrderModes.delete;
      engActionTypeOrderNumbers.delete;
      engActionTypeVotingRegimes.delete;
      engActionTypeNames.delete;
      engActionTypeUsages.delete;
      engActionTypePackageNames.delete;
      engItemClassIds.delete;
      engItemClassIndexes.delete;
      engItemClassItemIdIndexes.delete;
      engItemClassNames.delete;
      engItemClassOrderNumbers.delete;
      engItemClassParModes.delete;
      engItemClassSublistModes.delete;
      engItemCounts.delete;
      engItemIds.delete;
      engAttributeIsStatics.delete;
      engAttributeItemClassIds.delete;
      engAttributeNames.delete;
      engAttributeTypes.delete;
      engAttributeValueIndexes.delete;
      engAttributeValues1.delete;
      engAttributeValues2.delete;
      engAttributeValues3.delete;
      engAttributeQueries.delete;
      engAttributeVariant.delete;
      engHeaderConditionValues.delete;
      engACUsageConditionIds.delete;
      engACUsageFirstIndexes.delete;
      engACUsageItemClassCounts.delete;
      engACUsageRuleIds.delete;
      engACUsageRulePriorities.delete;
      engACUsageRuleTypes.delete;
      engACUsageRuleApprCategories.delete;
      engACAttributeIds.delete;
      engACConditionTypes.delete;
      engACIncludeLowerLimits.delete;
      engACIncludeUpperLimits.delete;
      engACParameterOnes.delete;
      engACParameterThrees.delete;
      engACParameterTwos.delete;
      engACStringValueCounts.delete;
      engACStringValueFirstIndexes.delete;
      engACStringValues.delete;
      engOldApproverList.delete;
      engInsertedApproverList.delete;
      engInsertionOrderTypeList.delete;
      engInsertionParameterList.delete;
      engInsertionIsSpecialForwardee.delete;
      engDeletedApproverList.delete;
      engStInsertionIndexes.delete;
      /*delete deviation related info*/
      engDeviationResultList.delete;
      engInsertionReasonList.delete;
      engInsertionDateList.delete;
      engSuppressionDateList.delete;
      engSupperssionReasonList.delete;
      engInsApproverIndex.delete;
      engTempReason := null;
      engTempDate := null;
      /* Fetch the transaction identifiers. */
      if(ameApplicationIdIn is null) then
        if(fndApplicationIdIn is null) then
          raise nullValuesException;
        end if;
        engFndApplicationId := fndApplicationIdIn;
        engTransactionTypeId := transactionTypeIdIn;
        engAmeApplicationId := fetchAmeApplicationId(fndApplicationIdIn => fndApplicationIdIn,
                                                     transactionTypeIdIn => transactionTypeIdIn);
      else
        engAmeApplicationId := ameApplicationIdIn;
        fetchFndApplicationId(applicationIdIn => ameApplicationIdIn,
                              fndApplicationIdOut => engFndApplicationId,
                              transactionTypeIdOut => engTransactionTypeId);
      end if;
      engTransactionId := transactionIdIn;
      engIsTestTransaction := isTestTransactionIn;
      engIsLocalTransaction := isLocalTransactionIn;
      if(engIsTestTransaction and not engIsLocalTransaction) then
        raise badLocalTransException;
      end if;
      /* Initialize engEffectiveRuleDate to sysdate, in case the attribute values aren't fetched. */
      engEffectiveRuleDate := sysdate;
      /* Initialize misc. boolean globals to the corresponding input values. */
      engPrepareItemData := prepareItemDataIn;
      engPrepareRuleIds := prepareRuleIdsIn;
      engPrepareRuleDescs := prepareRuleDescsIn;
      engPrepareApproverTree := prepareApproverTreeIn;
      engItemDataPrepared := false;
      engProcessProductionActions := processProductionActionsIn;
      engProcessProductionRules := processProductionRulesIn;
      engProcessPriorities := processPrioritiesIn;
      engUpdateCurrentApproverList := updateCurrentApproverListIn;
      engUpdateOldApproverList := updateOldApproverListIn;
      /* Optionally fetch the global configuration-variable lists. */
      if(fetchConfigVarsIn) then
        /* Fetch. */
        fetchConfigVars;
        /* Reconcile the engProcessProduction values with the productionFunctionality config var. */
        tempConfigVarValue := getConfigVarValue(configVarNameIn => ame_util.productionConfigVar);
        if(engProcessProductionActions and
           tempConfigVarValue in (ame_util.noProductions, ame_util.perTransactionProductions)) then
          engProcessProductionActions := false;
        end if;
        if(engProcessProductionRules and
           tempConfigVarValue in (ame_util.noProductions, ame_util.perApproverProductions)) then
          engProcessProductionRules := false;
        end if;
      end if;
      /* Optionally fetch the transaction's attribute values.  */
      if(fetchAttributeValuesIn) then
        /* Go fetch. */
        fetchItemClassData;
        fetchAttributeValues(fetchInactivesIn => fetchInactiveAttValuesIn);
        /* Set misc. frequently-used attribute-value caches. */
        engEvalPrioritiesPerItem :=
          getHeaderAttValue2(attributeNameIn => ame_util.evalPrioritiesPerItemAttribute) =
            ame_util.booleanAttributeTrue;
        engRepeatSubstitutions  :=
          getHeaderAttValue2(attributeNameIn => ame_util.repeatSubstitutionsAttribute) =
            ame_util.booleanAttributeTrue;
        /* A null effective rule date should be interpreted as sysdate. */
        engEffectiveRuleDate := ame_util.versionStringToDate(stringDateIn =>
          getHeaderAttValue2(attributeNameIn => ame_util.effectiveRuleDateAttribute));
        if(engEffectiveRuleDate is null) then
          engEffectiveRuleDate := sysdate;
        else
          -- evaluate the attributes with use count 0 if they are used in rules
          -- which were active as of effective_rule_date.
          if not fetchInactiveAttValuesIn then
            fetchOtherAttributeValues;
          end if;
        end if;
        if(processProductionActionsIn or
           processProductionRulesIn or
           updateCurrentApproverListIn or
           updateOldApproverListIn or
           processPrioritiesIn or
           prepareItemDataIn or
           prepareRuleIdsIn or
           prepareRuleDescsIn) then
          /* Fetch the active condition usages. */
          fetchActiveConditionUsages;
        end if;
      end if;
      /* Optionally fetch the old approver list. */
      if(fetchOldApproversIn) then
        fetchOldApprovers;
      end if;
      /* Optionally fetch the inserted-approvers list. */
      if(fetchInsertionsIn) then
        fetchInsertedApprovers;
      end if;
      /* Optionally fetch the approver-deletions list. */
      if(fetchDeletionsIn) then
        fetchDeletedApprovers;
      end if;
      exception
        when badLocalTransException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400688_ENG_TESTTX_NONLOCAL');
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'setContext',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when nullValuesException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400129_ENG_APPLID_NULL');
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'setContext',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'setContext',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end setContext;
  procedure setHandlerState(handlerNameIn in varchar2,
                            parameterIn in varchar2 default null,
                            stateIn in varchar2 default null) as
    argumentLengthException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    handlerName ame_temp_handler_states.handler_name%type;
    begin
      if(lengthb(stateIn) > 100 or
         lengthb(parameterIn) > 100) then
        raise argumentLengthException;
      end if;
      handlerName := upper(handlerNameIn);
      delete
        from ame_temp_handler_states
        where
          handler_name = handlerName and
          application_id = engAmeApplicationId and
          ((parameter is null and parameterIn is null) or
           (parameter = parameterIn));
      insert into ame_temp_handler_states(
        handler_name,
        row_timestamp,
        application_id,
        parameter,
        state)
        values(
          handlerName,
          sysdate, /* Don't use engEffectiveRuleDate here. */
          engAmeApplicationId,
          parameterIn,
          stateIn);
      exception
        when argumentLengthException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400130_ENG_HDLR_PAR_LNG');
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'setHandlerState',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'setHandlerState',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end setHandlerState;
  procedure setInsertedApprovalStatus(currentApproverIndexIn in integer
                                      ,approvalStatusIn in varchar2) as
      insIndex Number;
    begin
      insIndex := engInsApproverIndex.first;
      if insIndex is not null then
        loop
          if engInsApproverIndex(insIndex) = currentApproverIndexIn then
            engInsertedApproverList(insIndex).approval_status := approvalStatusIn;
            update ame_temp_insertions
             set approval_status = approvalStatusIn
            where application_id = engAmeApplicationId
              and transaction_id = engTransactionId
              and insertion_order = engInsertionOrderList(insIndex)
              and order_type = engInsertionOrderTypeList(insIndex)
              and parameter = engInsertionParameterList(insIndex)
              and api_insertion = engInsertedApproverList(insIndex).api_insertion
              and authority = engInsertedApproverList(insIndex).authority;
            return;
          end if;
          exit when insIndex = engInsApproverIndex.last;
          insIndex := engInsApproverIndex.next(insIndex);
        end loop;
      end if;
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_engine',
                                  routineNameIn => 'setInsertedApprovalStatus',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
          raise;
  end setInsertedApprovalStatus;
  procedure setRuleApplied(ruleIndexIn in integer) as
    begin
      engRuleAppliedYN(ruleIndexIn) := ame_util.booleanTrue;
    end setRuleApplied;
  procedure sortApplicableRules(sortByActionTypeIn in boolean) as
    exchangeActionTypeId integer;
    exchangeAppItemId ame_util.stringType;
    exchangeApproverCategory ame_util.charType;
    exchangeItemClassId integer;
    exchangeItemId ame_util.stringType;
    exchangeParameter ame_actions.parameter%type;
    exchangeParameterTwo ame_actions.parameter_two%type;
    exchangePriority integer;
    exchangeRuleId integer;
    exchangeRuleItemClassId integer;
    exchangeRuleType ame_util.stringType;
    exchangeRuleAppliedYN ame_util.charType;
    begin
      /*
        This is a simple sort algorithm, but it is efficient for small input counts.
        The inputs are generally nearly sorted, which makes at least a nonrandomized
        quicksort a poor choice (quicksort's worst-case performance arises in the
        case of inputs that are already sorted or nearly sorted).  A randomized
        quicksort would avoid this problem, but our judgment is that the random-number
        generation overhead makes this approach undesirable for inputs of the sizes
        we expect.
      */
      for i in 2 .. engAppRuleIds.count loop
        for j in 1 .. i - 1 loop
          if(compareApplicableRules(index1In => i,
                                    index2In => j,
                                    compareActionTypesIn => sortbyActionTypeIn)) then
            /* Set exchange buffers' values. */
            exchangeItemClassId := engAppItemClassIds(i);
            exchangeItemId := engAppItemIds(i);
            exchangeRuleItemClassId := engAppRuleItemClassIds(i);
            exchangeAppItemId := engAppAppItemIds(i);
            exchangeRuleId := engAppRuleIds(i);
            exchangeRuleAppliedYN := engRuleAppliedYN(i);
            exchangeRuleType := engAppRuleTypes(i);
            exchangeApproverCategory := engAppApproverCategories(i);
            if(sortByActionTypeIn) then
              exchangeActionTypeId := engAppActionTypeIds(i);
              exchangeParameter := engAppParameters(i);
              exchangeParameterTwo := engAppParameterTwos(i);
            elsif(engProcessPriorities) then
              exchangePriority := engAppPriorities(i);
            end if;
            /* Move jth values to index i. */
            engAppRuleItemClassIds(i) := engAppRuleItemClassIds(j);
            engAppAppItemIds(i) := engAppAppItemIds(j);
            engAppItemClassIds(i) := engAppItemClassIds(j);
            engAppItemIds(i) := engAppItemIds(j);
            engAppRuleIds(i) := engAppRuleIds(j);
            engRuleAppliedYN(i) := engRuleAppliedYN(j);
            engAppRuleTypes(i) := engAppRuleTypes(j);
            engAppApproverCategories(i) := engAppApproverCategories(j);
            if(sortByActionTypeIn) then
              engAppActionTypeIds(i) := engAppActionTypeIds(j);
              engAppParameters(i) := engAppParameters(j);
              engAppParameterTwos(i) := engAppParameterTwos(j);
            elsif(engProcessPriorities) then
              engAppPriorities(i) := engAppPriorities(j);
            end if;
            /* Move buffered ith values to index j. */
            engAppRuleItemClassIds(j) := exchangeRuleItemClassId;
            engAppAppItemIds(j) := exchangeAppItemId;
            engAppItemClassIds(j) := exchangeItemClassId;
            engAppItemIds(j) := exchangeItemId;
            engAppRuleIds(j) := exchangeRuleId;
            engRuleAppliedYN(j) := exchangeRuleAppliedYN;
            engAppRuleTypes(j) := exchangeRuleType;
            engAppApproverCategories(j) := exchangeApproverCategory;
            if(sortByActionTypeIn) then
              engAppActionTypeIds(j) := exchangeActionTypeId;
              engAppParameters(j) := exchangeParameter;
              engAppParameterTwos(j) := exchangeParameterTwo;
            elsif(engProcessPriorities) then
              engAppPriorities(j) := exchangePriority;
            end if;
          end if;
        end loop;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'sortApplicableRules',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end sortApplicableRules;
  procedure substituteApprover(approverIndexIn in integer,
                               nameIn in varchar2,
                               actionTypeIdIn in varchar2,
                               ruleIdIn in integer) as
    currentActionTypeId integer;
    currentGroupOrChainId integer;
    occurrence integer;
    begin
      /* Look up the orig_system, orig_system_id, and display_name values corresponding to nameIn. */
      ame_approver_type_pkg.getOrigSystemIdAndDisplayName(
        nameIn => nameIn,
        origSystemOut => engStApprovers(approverIndexIn).orig_system,
        origSystemIdOut => engStApprovers(approverIndexIn).orig_system_id,
        displayNameOut => engStApprovers(approverIndexIn).display_name);
      /* Calculate the occurrence value for the substitution. */
      currentGroupOrChainId := engStApprovers(approverIndexIn).group_or_chain_id;
      occurrence := 1;
      for i in reverse 1 .. (approverIndexIn - 1) loop
        if(currentGroupOrChainId <> engStApprovers(i).group_or_chain_id or
           engStApprovers(approverIndexIn).action_type_id <> engStApprovers(i).action_type_id or
           engStApprovers(approverIndexIn).item_id <> engStApprovers(i).item_id or
           engStApprovers(approverIndexIn).item_class <> engStApprovers(i).item_class) then
          exit;
        end if;
        if(nameIn = engStApprovers(i).name) then
          occurrence := occurrence + 1;
        end if;
      end loop;
      engStApprovers(approverIndexIn).name := nameIn;
      engStApprovers(approverIndexIn).occurrence := occurrence;
      /* Get and set the approval status. */
      engStApprovers(approverIndexIn).approval_status :=
        getHandlerApprovalStatus(approverIn => engStApprovers(approverIndexIn));
      /* Append ruleIdIn to source value. */
      ame_util.appendRuleIdToSource(ruleIdIn => ruleIdIn,
                                    sourceInOut => engStApprovers(approverIndexIn).source);
      /* Update the occurrence values of the same approver wherever the approver occurs later in the same chain. */
      for i in approverIndexIn + 1 .. engStApprovers.count loop
        if(currentGroupOrChainId <> engStApprovers(i).group_or_chain_id or
           engStApprovers(approverIndexIn).action_type_id <> engStApprovers(i).action_type_id or
           engStApprovers(approverIndexIn).item_id <> engStApprovers(i).item_id or
           engStApprovers(approverIndexIn).item_class <> engStApprovers(i).item_class) then
          exit;
        end if;
        if(nameIn = engStApprovers(i).name) then
          occurrence := occurrence + 1;
          engStApprovers(i).occurrence := occurrence;
          /* Get and set the approval status for this approver's approval status. */
          engStApprovers(i).approval_status :=
            getHandlerApprovalStatus(approverIn => engStApprovers(i));
        end if;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'substituteApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end substituteApprover;
  procedure truncateChain(approverIndexIn in integer,
                          ruleIdIn in integer) as
    currentActionTypeId integer;
    currentGroupOrChainId integer;
    engStApproversCount integer;
    firstIndexToTruncate integer;
    lastIndexToTruncate integer;
    siblingTreeNodeIndex integer;
    tempIndex integer;
    truncateCount integer;
    loopIndex integer;
    nextIndex integer;
    begin
      /*
        This procedure copies the current action-type ID and group-or-chain ID into local
        variables for efficiency, but does not copy the item ID or item class because these
        copy operations are likely to take much longer, and to require substantially more
        memory-allocation overhead.
      */
      currentActionTypeId := engStApprovers(approverIndexIn).action_type_id;
      currentGroupOrChainId := engStApprovers(approverIndexIn).group_or_chain_id;
      engStApproversCount := engStApprovers.count;
      /* First handle the case where no truncation is required. */
      tempIndex := approverIndexIn + 1;
      if(approverIndexIn = engStApproversCount or
         currentGroupOrChainId <> engStApprovers(tempIndex).group_or_chain_id or
         currentActionTypeId <> engStApprovers(tempIndex).action_type_id or
         engStApprovers(approverIndexIn).item_id <> engStApprovers(tempIndex).item_id or
         engStApprovers(approverIndexIn).item_class <> engStApprovers(tempIndex).item_class) then
        return;
      end if;
      /* Evidently the approver at tempIndex is in the same chain.  Find the last approver in that chain. */
      firstIndexToTruncate := tempIndex;
      lastIndexToTruncate := firstIndexToTruncate;
      for i in firstIndexToTruncate + 1 .. engStApproversCount loop
        /* Stop at the end of the chain. */
        if(currentGroupOrChainId <> engStApprovers(i).group_or_chain_id or
           currentActionTypeId <> engStApprovers(i).action_type_id or
           engStApprovers(approverIndexIn).item_id <> engStApprovers(i).item_id or
           engStApprovers(approverIndexIn).item_class <> engStApprovers(i).item_class) then
          lastIndexToTruncate := i - 1;
          exit;
        end if;
        if(i = engStApproversCount) then
          lastIndexToTruncate := engStApproversCount;
        end if;
      end loop;
      /*
        Truncate from the first index to the last index, inclusive.
         delete the rest of the chain.
      */
      truncateCount := lastIndexToTruncate - firstIndexToTruncate + 1;
      /* Copy the end of the list down truncateCount places. */
      for i in firstIndexToTruncate .. (engStApproversCount - truncateCount) loop
        ame_util.copyApproverRecord2(approverRecord2In => engStApprovers(i + truncateCount),
                                     approverRecord2Out => engStApprovers(i));
      end loop;
      /* Code to delete the approvers from the tree whenever there are approver suppressions */
      if engPrepareApproverTree then
        siblingTreeNodeIndex := ame_util.noSiblingIndex;
        /* Approvers Tree is sparse */
        loopIndex := engStApproversTree.last;
        loop
          if engStApproversTree(loopIndex).tree_level = 6 then
            if engStApproversTree(loopIndex).approver_index >= firstIndexToTruncate + truncateCount then
              engStApproversTree(loopIndex).approver_index := engStApproversTree(loopIndex).approver_index - truncateCount;
              nextIndex := engStApproversTree.prior(loopIndex);
            elsif engStApproversTree(loopIndex).approver_index >= firstIndexToTruncate
                  and engStApproversTree(loopIndex).approver_index < lastIndexToTruncate then
              nextIndex := engStApproversTree.prior(loopIndex);
              engStApproversTree.delete(loopIndex);
            elsif engStApproversTree(loopIndex).approver_index = lastIndexToTruncate then
              siblingTreeNodeIndex := engStApproversTree(loopIndex).sibling_index;
              nextIndex := engStApproversTree.prior(loopIndex);
              engStApproversTree.delete(loopIndex);
            elsif engStApproversTree(loopIndex).approver_index = firstIndexToTruncate - 1 then
              engStApproversTree(loopIndex).sibling_index := siblingTreeNodeIndex;
              nextIndex := engStApproversTree.prior(loopIndex);
            else
              nextIndex := engStApproversTree.prior(loopIndex);
            end if;
          else
            nextIndex := engStApproversTree.prior(loopIndex);
          end if;
          exit when engStApproversTree.first = nextIndex;
          loopIndex := nextIndex;
        end loop;
      end if;
      /* Delete the last truncateCount places. */
      engStApprovers.delete(engStApproversCount - truncateCount + 1, engStApproversCount);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'truncateChain',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end truncateChain;
  procedure unlockTransaction(fndApplicationIdIn in integer,
                              transactionIdIn in varchar2,
                              transactionTypeIdIn in varchar2 default null) as
    begin
      if(engTransactionIsLocked) then
        delete from ame_temp_trans_locks
          where
            fnd_application_id = fndApplicationIdIn and
            ((transaction_type_id is null and transactionTypeIdIn is null) or
             transaction_type_id = transactionTypeIdIn) and
            transaction_id = transactionIdIn;
      end if;
      engTransactionIsLocked := false;
      exception
         when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'unlockTransaction',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end unlockTransaction;
  procedure updateTransactionState(isTestTransactionIn in boolean,
                                   isLocalTransactionIn in boolean,
                                   fetchConfigVarsIn in boolean,
                                   fetchOldApproversIn in boolean,
                                   fetchInsertionsIn in boolean,
                                   fetchDeletionsIn in boolean,
                                   fetchAttributeValuesIn in boolean,
                                   fetchInactiveAttValuesIn in boolean,
                                   processProductionActionsIn in boolean,
                                   processProductionRulesIn in boolean,
                                   updateCurrentApproverListIn in boolean,
                                   updateOldApproverListIn in boolean,
                                   processPrioritiesIn in boolean,
                                   prepareItemDataIn in boolean,
                                   prepareRuleIdsIn in boolean,
                                   prepareRuleDescsIn in boolean,
                                   prepareApproverTreeIn in boolean default false,
                                   transactionIdIn in varchar2,
                                   ameApplicationIdIn in integer default null,
                                   fndApplicationIdIn in integer default null,
                                   transactionTypeIdIn in varchar2 default null) as
    configVarException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    begin
      setContext(isTestTransactionIn => isTestTransactionIn,
                 isLocalTransactionIn => isLocalTransactionIn,
                 fetchConfigVarsIn => fetchConfigVarsIn,
                 fetchOldApproversIn => fetchOldApproversIn,
                 fetchInsertionsIn => fetchInsertionsIn,
                 fetchDeletionsIn => fetchDeletionsIn,
                 fetchAttributeValuesIn => fetchAttributeValuesIn,
                 fetchInactiveAttValuesIn => fetchInactiveAttValuesIn,
                 processProductionActionsIn => processProductionActionsIn,
                 processProductionRulesIn => processProductionRulesIn,
                 updateCurrentApproverListIn => updateCurrentApproverListIn,
                 updateOldApproverListIn => updateOldApproverListIn,
                 processPrioritiesIn => processPrioritiesIn,
                 prepareItemDataIn => prepareItemDataIn,
                 prepareRuleIdsIn => prepareRuleIdsIn,
                 prepareRuleDescsIn => prepareRuleDescsIn,
                 prepareApproverTreeIn => prepareApproverTreeIn,
                 transactionIdIn => transactionIdIn,
                 ameApplicationIdIn => ameApplicationIdIn,
                 fndApplicationIdIn => fndApplicationIdIn,
                 transactionTypeIdIn => transactionTypeIdIn);
      if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
        fnd_log.string
          (fnd_log.level_statement
          ,'ame_engine.updateTransactionState'
          ,'AME Application Id ::: ' || engAmeApplicationId
          );
        fnd_log.string
          (fnd_log.level_statement
          ,'ame_engine.updateTransactionState'
          ,'AME Transaction Id ::: ' || engTransactionId
          );
      end if;
      /* Added from version 115.217 to log a transaction (backward compatiblity)*/
      if updateOldApproverListIn then
        logTransaction;
      end if;
      if(processProductionActionsIn or
         processProductionRulesIn or
         updateCurrentApproverListIn or
         updateOldApproverListIn or
         processPrioritiesIn or
         prepareItemDataIn or
         prepareRuleIdsIn or
         prepareRuleDescsIn) then
        if(not fetchConfigVarsIn) then
          raise configVarException;
        end if;
        evaluateRules;
        fetchApplicableActions;
        processExceptions;
      end if;
      if(updateCurrentApproverListIn or
         updateOldApproverListIn) then
        processRules(processOnlyProductionsIn => false);
      elsif(processProductionRulesIn) then
        processRules(processOnlyProductionsIn => true);
      end if;
      if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
        fnd_log.string
          (fnd_log.level_statement
          ,'ame_engine.updateTransactionState'
          ,'Approver count after processRules ::: ' || engStApprovers.count
          );
      end if;
      if(updateCurrentApproverListIn or
         updateOldApproverListIn) then
        processAdHocInsertions;
        if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
          fnd_log.string
            (fnd_log.level_statement
            ,'ame_engine.updateTransactionState'
            ,'Approver count after processAdHocInsertions ::: ' || engStApprovers.count
            );
        end if;
        processUnresponsiveApprovers;
        if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
          fnd_log.string
            (fnd_log.level_statement
            ,'ame_engine.updateTransactionState'
            ,'Approver count after processUnresponsiveApprovers ::: ' || engStApprovers.count
            );
        end if;
        if engRepeatSubstitutions  then
          repeatSubstitutions;
          if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
            fnd_log.string
              (fnd_log.level_statement
              ,'ame_engine.updateTransactionState'
              ,'Approver count after repeatSubstitutions ::: ' || engStApprovers.count
              );
          end if;
        end if;

        /*
          processSuppressions must precede processRepeatedApprovers, because the latter procedure needs to see
          any approver deletions, to aggregate approvers correctly.
        */
        processSuppressions;
        if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
          fnd_log.string
            (fnd_log.level_statement
            ,'ame_engine.updateTransactionState'
            ,'Approver count after processSuppressions ::: ' || engStApprovers.count
            );
        end if;
        /*
          processSuppressions must precede processRepeatedApprovers so every approver in engStApprovers still
          has non-null item_class and item_id fields.
        */
        processRepeatedApprovers;
        if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
          fnd_log.string
            (fnd_log.level_statement
            ,'ame_engine.updateTransactionState'
            ,'Approver count after processRepeatedApprovers ::: ' || engStApprovers.count
            );
        end if;
        /*
          processRepeatedApprovers must precede populateEngStVariables so the latter can treat repeated
          approvers as equivalent to approving approvers, for purposes of determining whether an item or
          transaction's approval process is complete.
        */
        populateEngStVariables;
        if engPrepareApproverTree then
          calculateApproverOrderNumbers;
          if updateOldApproverListIn then
            ame_approver_deviation_pkg.updateDeviationState(
                                         engAmeApplicationId
                                        ,engTransactionId
                                        ,engDeviationResultList
                                        ,engStApprovalProcessCompleteYN
                                        ,engStApprovers);
          end if;
        end if;
        if fnd_log.g_current_runtime_level <= fnd_log.level_statement then
          if engStApprovers.count = 0 then
            fnd_log.string
              (fnd_log.level_statement
              ,'ame_engine.updateTransactionState'
              ,'**************** No Approvers ******************'
              );
          else
            for i in 1 .. engStApprovers.count loop
              fnd_log.string
                (fnd_log.level_statement
                ,'ame_engine.updateTransactionState'
                ,'Approver ::: ' || engStApprovers(i).name || ' Order Number ::: ' || engStApprovers(i).approver_order_number
                );
            end loop;
          end if;
        end if;
        if(updateOldApproverListIn) then
          updateOldApproverList;
        end if;
      end if;
      exception
        when configVarException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400691_INV_PARAM_ENG_UPDTX');
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'updateTransactionState',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'updateTransactionState',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end updateTransactionState;
  procedure updateOldApproverList as
    tempActionTypeIds ame_util.idList;
    tempApiValues ame_util.charList;
    tempAuthorityValues ame_util.charList;
    tempCategories ame_util.charList;
    tempCount integer;
    tempGroupOrChainIds ame_util.idList;
    tempItemClasses ame_util.stringList;
    tempItemIds ame_util.stringList;
    tempNames ame_util.longStringList;
    tempOccurrences ame_util.idList;
    tempOrderNumbers ame_util.idList;
    tempStatuses ame_util.stringList;
    begin
      delete from ame_temp_old_approver_lists
        where
          application_id = engAmeApplicationId and
          transaction_id = engTransactionId;
      /*
        Bulk insert the transaction's current state into ame_temp_old_approver_lists.
        Take the state from engStApprovers, to account for all operations on the approver list.
      */
      ame_util.convertApproversTable2ToValues(approversTableIn => engStApprovers,
                                              namesOut => tempNames,
                                              itemClassesOut => tempItemClasses,
                                              itemIdsOut => tempItemIds,
                                              apiInsertionsOut => tempApiValues,
                                              authoritiesOut => tempAuthorityValues,
                                              actionTypeIdsOut => tempActionTypeIds,
                                              groupOrChainIdsOut => tempGroupOrChainIds,
                                              occurrencesOut => tempOccurrences,
                                              approverCategoriesOut => tempCategories,
                                              statusesOut => tempStatuses);
      tempCount := tempNames.count;
      for i in 1 .. tempCount loop
        if engStApprovers.exists(i) and engStApprovers(i).approver_order_number is not null then
           tempOrderNumbers(i) := engStApprovers(i).approver_order_number;
        else
           tempOrderNumbers(i) := i;
        end if;
      end loop;
      for i in 1..engStApprovers.count loop
        setInsertedApprovalStatus(currentApproverIndexIn => i
                                 ,approvalStatusIn => engStApprovers(i).approval_status);
      end loop;
      forall i in 1 .. tempCount
        insert into ame_temp_old_approver_lists(
          transaction_id,
          application_id,
          order_number,
          name,
          item_class,
          item_id,
          api_insertion,
          authority,
          action_type_id,
          group_or_chain_id,
          occurrence,
          approver_category,
          approval_status) values(
            engTransactionId,
            engAmeApplicationId,
            tempOrderNumbers(i),
            tempNames(i),
            tempItemClasses(i),
            tempItemIds(i),
            tempApiValues(i),
            tempAuthorityValues(i),
            tempActionTypeIds(i),
            tempGroupOrChainIds(i),
            tempOccurrences(i),
            tempCategories(i),
            tempStatuses(i));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'updateOldApproverList',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end updateOldApproverList;
  /* test procedure */
  procedure testEngine(printContextYNIn in varchar2 default 'N',
                       printAppRulesYNIn in varchar2 default 'N',
                       printApproversYNIn in varchar2 default 'N') as
    begin
null;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'testEngine',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end testEngine;
  procedure updateApprovalStatus(applicationIdIn in number,
                                 transactionTypeIn in varchar2,
                                 transactionIdIn in varchar2,
                                 approverIn in ame_util.approverRecord2,
                                 notificationIn in ame_util2.notificationRecord
                                         default ame_util2.emptyNotificationRecord,
                                 forwardeeIn in ame_util.approverRecord2 default
                                             ame_util.emptyApproverRecord2,
                                 updateItemIn in boolean default false) as
    ameApplicationId integer;
    apiInsertionException exception;
    approver ame_util.approverRecord2;
    approverInIndex integer;
    approverInIsSpecialForwardee boolean;
    badApproverException exception;
    badForwardeeException exception;
    badStatusException exception;
    currentApprovers ame_util.approversTable2;
    errorCode integer;
    errorMessage ame_util.longStringType;
    firstIndexInChain integer;
    forwardee ame_util.approverRecord2;
    forwardeeIndex integer;
    forwardeeType ame_util.stringType;
    forwarderFound boolean;
    forwarderType ame_util.stringType;
    forwardingBehavior ame_util.stringType;
    insertedApprover ame_util.approverRecord2;
    prevApproverIndex integer;
    prevApproverOccurrence integer;
    repeatedIndexes ame_util.idList;
    repeatedAppIndexes ame_util.idList;
    superiorApprover ame_util.approverRecord2;
    tempInsertionOrder integer;
    tempParameter ame_temp_insertions.parameter%type;
    tempCOAGroupActionTypeId integer;
    tempPreGroupActionTypeId integer;
    tempPostGroupActionTypeId integer;
    votingRegime ame_util.charType;
    approverOldApprovalStatus varchar2(50);
    tempReason varchar2(50);
    tempStatus varchar2(50);
    tempfrwCount number;
    l_actiontypeName varchar2(50);
    l_votingRegime varchar2(20);
    l_actionTypeId Number;
    l_frw_index number;
    begin
      /* Lock the transaction. */
      ame_engine.lockTransaction(fndApplicationIdIn => applicationIdIn,
                                 transactionIdIn => transactionIdIn,
                                 transactionTypeIdIn => transactionTypeIn);
      /* Clear the exception log when required. */
      if(approverIn.approval_status = ame_util.clearExceptionsStatus) then
        delete from ame_exceptions_log
          where
            transaction_id = transactionIdIn and
            application_id = ameApplicationId;
        ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                     transactionIdIn => transactionIdIn,
                                     transactionTypeIdIn => transactionTypeIn);
        return;
      end if;
      /* Locate approverIn in the current approver list, if possible. */
      ame_engine.updateTransactionState(isTestTransactionIn => false,
                                        isLocalTransactionIn => false,
                                        fetchConfigVarsIn => true,
                                        fetchOldApproversIn => true,
                                        fetchInsertionsIn => true,
                                        fetchDeletionsIn => true,
                                        fetchAttributeValuesIn => true,
                                        fetchInactiveAttValuesIn => false,
                                        processProductionActionsIn => false,
                                        processProductionRulesIn => false,
                                        updateCurrentApproverListIn => true,
                                        updateOldApproverListIn => false,
                                        processPrioritiesIn => true,
                                        prepareItemDataIn => false,
                                        prepareRuleIdsIn => false,
                                        prepareRuleDescsIn => false,
                                        prepareApproverTreeIn => true,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn);
      ame_engine.getApprovers(approversOut => currentApprovers);
      ame_engine.getRepeatedIndexes(repeatedIndexesOut    => repeatedIndexes
                                   ,repeatedAppIndexesOut => repeatedAppIndexes);
      ameApplicationId := ame_engine.getAmeApplicationId;
      approverInIndex := null;
      if(approverIn.occurrence is null or
         approverIn.group_or_chain_id is null or
         approverIn.action_type_id is null or
         approverIn.item_id is null or
         approverIn.item_class is null) then /* partial match */
        /* We need to split the search below to take in to account that the user
           could be trying to clear an approvers status */
        if(approverIn.approval_status is null) then /* Clear Approver status */
          for i in 1 .. currentApprovers.count loop
            if(approverIn.name = currentApprovers(i).name and
               (currentApprovers(i).approval_status = ame_util.approvedStatus or
                currentApprovers(i).approval_status = ame_util.approveAndForwardStatus or
                currentApprovers(i).approval_status = ame_util.forwardStatus or
                currentApprovers(i).approval_status = ame_util2.reassignStatus or
                currentApprovers(i).approval_status = ame_util.rejectStatus or
                currentApprovers(i).approval_status = ame_util.notifiedStatus or
                currentApprovers(i).approval_status = ame_util.exceptionStatus or
                currentApprovers(i).approval_status = ame_util.noResponseStatus ) and
               (approverIn.occurrence is null or
                approverIn.occurrence = currentApprovers(i).occurrence) and
               (approverIn.group_or_chain_id is null or
                approverIn.group_or_chain_id = currentApprovers(i).group_or_chain_id) and
               (approverIn.action_type_id is null or
                approverIn.action_type_id = currentApprovers(i).action_type_id) and
               (approverIn.item_id is null or
                approverIn.item_id = currentApprovers(i).item_id) and
               (approverIn.item_class is null or
                approverIn.item_class = currentApprovers(i).item_class)) then
              approverInIndex := i;
              exit;
            end if;
          end loop;
        else
          for i in 1 .. currentApprovers.count loop
            if(approverIn.name = currentApprovers(i).name and
               (currentApprovers(i).approval_status is null or
                currentApprovers(i).approval_status = ame_util.nullStatus or
                (currentApprovers(i).approver_category = ame_util.approvalApproverCategory and
                 currentApprovers(i).approval_status = ame_util.notifiedStatus)) and
               (approverIn.occurrence is null or
                approverIn.occurrence = currentApprovers(i).occurrence) and
               (approverIn.group_or_chain_id is null or
                approverIn.group_or_chain_id = currentApprovers(i).group_or_chain_id) and
               (approverIn.action_type_id is null or
                approverIn.action_type_id = currentApprovers(i).action_type_id) and
               (approverIn.item_id is null or
                approverIn.item_id = currentApprovers(i).item_id) and
               (approverIn.item_class is null or
                approverIn.item_class = currentApprovers(i).item_class)) then
              approverInIndex := i;
              exit;
            end if;
          end loop;
        end if;
      else /* complete match */
        for i in 1 .. currentApprovers.count loop
          if(ame_engine.approversMatch(approverRecord1In => currentApprovers(i),
                                       approverRecord2In => approverIn)) then
            approverInIndex := i;
            exit;
          end if;
        end loop;
      end if;
      /* Initialize the local variable approver. */
      if(approverInIndex is null) then
        ame_util.copyApproverRecord2(approverRecord2In => approverIn,
                                     approverRecord2Out => approver);
      else
        ame_util.copyApproverRecord2(approverRecord2In => currentApprovers(approverInIndex),
                                     approverRecord2Out => approver);
        approverOldApprovalStatus := approver.approval_status;
        approver.approval_status := approverIn.approval_status;
      end if;
      /*
        Most of the remaining code should reference approver rather than approverIn or
        currentApprovers(approverInIndex).  Any code below this comment that cannot reference
        approver should have a comment explaining why.
      */
      /* Make sure the input approval statuses are valid. */
      if((approver.approver_category = ame_util.approvalApproverCategory and
          approver.approval_status not in (ame_util.approvedStatus,
                                           ame_util.approveAndForwardStatus,
                                           ame_util.forwardStatus,
                                           ame_util.rejectStatus,
                                           ame_util.noResponseStatus,
                                           ame_util.nullStatus,
                                           ame_util.notifiedStatus,
                                           ame_util2.reassignStatus) and
          approver.approval_status is not null) or
         (approver.approver_category = ame_util.fyiApproverCategory and
          approver.approval_status is not null and
          approver.approval_status <> ame_util.notifiedStatus)) then
        raise badStatusException;
      end if;
      /* Prepare forwardee (if any), if the forwarder is in the current list. */
      if(approver.approval_status in (ame_util.approveAndForwardStatus, ame_util.forwardStatus) and
         approverInIndex is not null) then
        /* Make sure a valid forwardee exists for forwardings. */
        if(forwardeeIn.name is null or
           forwardeeIn.name = approver.name) then
          raise badForwardeeException;
        end if;
        if(approver.source like (ame_util.specialForwardInsertion || '%')) then
          approverInIsSpecialForwardee := true;
        else
          approverInIsSpecialForwardee := false;
        end if;
        /* Copy forwardeeIn to forwardee. */
        ame_util.copyApproverRecord2(approverRecord2In => forwardeeIn,
                                     approverRecord2Out => forwardee);
        /* If approverInIsSpecialForwardee, silently convert api_insertion to
           ame_util.apiInsertion for forwardee */
        if approverInIsSpecialForwardee then
          forwardee.api_insertion := ame_util.apiInsertion;
        end if;
        /* Make sure the forwardee has the correct api_insertion value for COA forwarders. */
        if(/* Special forwardees can only do ad-hoc forwardings. */
           (approverInIsSpecialForwardee and
            forwardee.api_insertion <> ame_util.apiInsertion) or
           /* Ad-hoc approvers can only do ad-hoc forwardings. */
           ((not approverInIsSpecialForwardee and
             approver.authority <> ame_util.authorityApprover or
             approver.api_insertion = ame_util.apiInsertion) and
            forwardee.api_insertion <> ame_util.apiInsertion) or
           /* COA approvers other than special forwardees can only do COA forwardings. */
           (not approverInIsSpecialForwardee and
            approver.authority = ame_util.authorityApprover and
            approver.api_insertion <> ame_util.apiInsertion and
            forwardee.api_insertion <> ame_util.apiAuthorityInsertion)) then
          raise apiInsertionException;
        end if;
        /* Make sure forwardee has complete approver-matching data. */
        if(forwardee.orig_system is null or
           forwardee.orig_system_id is null or
           forwardee.display_name is null) then
          ame_approver_type_pkg.getOrigSystemIdAndDisplayName(nameIn =>forwardee.name,
                                                              origSystemOut => forwardee.orig_system,
                                                              origSystemIdOut => forwardee.orig_system_id,
                                                              displayNameOut => forwardee.display_name);
        end if;
        /*
          If the forwardee is from a different originating system than the forwarder,
          make sure the forwardee is an ad-hoc insertion.  Make this change silently,
          so calling applications don't have to be originating-system aware.
        */
        if(approver.orig_system <> forwardee.orig_system) then
          forwardee.api_insertion := ame_util.apiInsertion;
        end if;
        forwardee.item_class := approver.item_class;
        forwardee.item_id := approver.item_id;
        forwardee.authority := approver.authority;
        forwardee.action_type_id := approver.action_type_id;
        forwardee.group_or_chain_id := approver.group_or_chain_id;
      end if;
      /* Log the status update to the history table. */
      if(approverInIndex is null) then
        insert into ame_approvals_history(transaction_id,
                                          application_id,
                                          approval_status,
                                          row_timestamp,
                                          item_class,
                                          item_id,
                                          name,
                                          approver_category,
                                          action_type_id,
                                          group_or_chain_id,
                                          occurrence)
          values(transactionIdIn,
                 ameApplicationId,
                 decode(approver.approval_status,
                        ame_util.nullStatus, ame_util.nullHistoryStatus,
                        null, ame_util.nullHistoryStatus,
                        approver.approval_status),
                 sysdate,
                 approver.item_class,
                 approver.item_id,
                 approver.name,
                 approver.approver_category,
                 ame_util.nullHistoryActionTypeId,
                 ame_util.nullHistoryGroupOrChainId,
                 ame_util.nullHistoryOccurrence);
        /*  As approver is no longer in the approval list, log the message in the
            history table with a cleared date equal to sysdate. Also, first set
            date_cleared for  other possible rows for this approver in the history
            table so  that rows do not appear in the history table. */
        update AME_TRANS_APPROVAL_HISTORY
           set date_cleared = sysdate
          where transaction_id = transactionIdIn
            and application_id = ameApplicationId
            and name = approver.name
            and (approver.item_class is null or
                 item_class = approver.item_class)
            and (approver.item_id is null or
                 item_id = approver.item_id)
            and (approver.action_type_id is null or
                 action_type_id = approver.action_type_id)
            and (approver.group_or_chain_id is null or
                 group_or_chain_id = approver.group_or_chain_id)
            and (approver.occurrence is null or
                 occurrence = approver.occurrence)
            and date_cleared is null;
      /* Log the approvers response in the Notification Approval History table before
         doing any further processing */
        insertIntoTransApprovalHistory
          (transactionIdIn         => transactionIdIn
          ,applicationIdIn         => ameApplicationId
          ,orderNumberIn           => approver.approver_order_number
          ,nameIn                  => approver.name
          ,appCategoryIn           => approver.approver_category
          ,itemClassIn             => approver.item_class
          ,itemIdIn                => approver.item_id
          ,actionTypeIdIn          => ame_util.nullHistoryActionTypeId
          ,authorityIn             => approver.authority
          ,statusIn                => approver.approval_status
          ,grpOrChainIdIn          => ame_util.nullHistoryGroupOrChainId
          ,occurrenceIn            => ame_util.nullHistoryOccurrence
          ,apiInsertionIn          => approver.api_insertion
          ,memberOrderNumberIn     => approver.member_order_number
          ,notificationIdIn        => notificationIn.notification_id
          ,userCommentsIn          => notificationIn.user_comments
          ,dateClearedIn           => sysdate
          ,historyTypeIn           => 'APPROVERNOTPRESENT');
        /* Insert a warning into AME's exception log and return. */
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                            messageNameIn => 'AME_400065_API_NO_MATCH_APPR2');
        /*
          Pass localErrorIn => true in this case, because we're just logging a warning
          to the AME exception log, and we don't want the warning to appear in the
          Workflow context stack.
        */
        ame_util.runtimeException(packageNameIn => 'ame_engine',
                                  routineNameIn => 'updateApprovalStatus',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
        return;
      end if;
      insert into ame_approvals_history(transaction_id,
                                        application_id,
                                        approval_status,
                                        row_timestamp,
                                        item_class,
                                        item_id,
                                        name,
                                        approver_category,
                                        action_type_id,
                                        group_or_chain_id,
                                        occurrence)
        values(transactionIdIn,
               ameApplicationId,
               decode(approver.approval_status,
                      ame_util.nullStatus, ame_util.nullHistoryStatus,
                      null, ame_util.nullHistoryStatus,
                      approver.approval_status),
               sysdate,
               approver.item_class,
               approver.item_id,
               approver.name,
               approver.approver_category,
               approver.action_type_id,
               approver.group_or_chain_id,
               approver.occurrence);
      /*
        If the approver has been suppressed or is a repeated approver, disregard their response,
        even if they're trying to forward.
      */
      if(approverOldApprovalStatus in (ame_util.suppressedStatus, ame_util.beatByFirstResponderStatus, ame_util.repeatedStatus)) then
        /* The response though disregarded must be logged in the history table. This should not be shown in
           the history region. Hence set the date_cleared to sysdate. */
        insertIntoTransApprovalHistory
          (transactionIdIn         => transactionIdIn
          ,applicationIdIn         => ameApplicationId
          ,orderNumberIn           => approver.approver_order_number
          ,nameIn                  => approver.name
          ,appCategoryIn           => approver.approver_category
          ,itemClassIn             => approver.item_class
          ,itemIdIn                => approver.item_id
          ,actionTypeIdIn          => approver.action_type_id
          ,authorityIn             => approver.authority
          ,statusIn                => approver.approval_status
          ,grpOrChainIdIn          => approver.group_or_chain_id
          ,occurrenceIn            => approver.occurrence
          ,apiInsertionIn          => approver.api_insertion
          ,memberOrderNumberIn     => approver.member_order_number
          ,notificationIdIn        => notificationIn.notification_id
          ,userCommentsIn          => notificationIn.user_comments
          ,dateClearedIn           => sysdate
          ,historyTypeIn           => 'APPROVERPRESENT');
        return;
      end if;
      /* Log the approvers response in the Notification Approval History table before
         doing any further processing */
        insertIntoTransApprovalHistory
          (transactionIdIn         => transactionIdIn
          ,applicationIdIn         => ameApplicationId
          ,orderNumberIn           => approver.approver_order_number
          ,nameIn                  => approver.name
          ,appCategoryIn           => approver.approver_category
          ,itemClassIn             => approver.item_class
          ,itemIdIn                => approver.item_id
          ,actionTypeIdIn          => approver.action_type_id
          ,authorityIn             => approver.authority
          ,statusIn                => approver.approval_status
          ,grpOrChainIdIn          => approver.group_or_chain_id
          ,occurrenceIn            => approver.occurrence
          ,apiInsertionIn          => approver.api_insertion
          ,memberOrderNumberIn     => approver.member_order_number
          ,notificationIdIn        => notificationIn.notification_id
          ,userCommentsIn          => notificationIn.user_comments
          ,dateClearedIn           => null
          ,historyTypeIn           => 'APPROVERPRESENT');
      /*
        Update the status of approverIn in ame_temp_old_approver_lists.  If updateItemIn
        is true, update also any other occurrences of the same approver for the same item
        class and item ID.
      */
      if(updateItemIn) then
        if(approver.approval_status in (ame_util.forwardStatus, ame_util.approveAndForwardStatus)) then
          /* Update the forwarder proper. */
          update ame_temp_old_approver_lists
            set approval_status = approver.approval_status
            where
              application_id = ameApplicationId and
              transaction_id = transactionIdIn and
              name = approver.name and
              item_class = approver.item_class and
              item_id = approver.item_id and
              action_type_id = approver.action_type_id and
              group_or_chain_id = approver.group_or_chain_id and
              occurrence = approver.occurrence;
          /* Suppress other occurrences of the approver, for the same item. */
          update ame_temp_old_approver_lists
            set approval_status = ame_util.suppressedStatus
            where
              application_id = ameApplicationId and
              transaction_id = transactionIdIn and
              name = approver.name and
              item_class = approver.item_class and
              item_id = approver.item_id and
              (action_type_id <> approver.action_type_id or
               group_or_chain_id <> approver.group_or_chain_id or
               occurrence <> approver.occurrence);
        else
          update ame_temp_old_approver_lists
            set approval_status = approver.approval_status
            where
              application_id = ameApplicationId and
              transaction_id = transactionIdIn and
              name = approver.name and
              item_class = approver.item_class and
              item_id = approver.item_id;
        end if;
      else
        update ame_temp_old_approver_lists
          set approval_status = approver.approval_status
          where
            application_id = ameApplicationId and
            transaction_id = transactionIdIn and
            name = approver.name and
            item_class = approver.item_class and
            item_id = approver.item_id and
            action_type_id = approver.action_type_id and
            group_or_chain_id = approver.group_or_chain_id and
            occurrence = approver.occurrence;
      end if;
      --+
      if approverInIndex is not null then
        setInsertedApprovalStatus(currentApproverIndexIn => approverInIndex
                                  ,approvalStatusIn => approver.approval_status);
      end if;
      if approver.approval_status in (ame_util.approvedStatus
                                     ,ame_util.rejectStatus
                                     ,ame_util.approveAndForwardStatus
                                     ,ame_util.forwardStatus
                                     ,ame_util.noResponseStatus) then
        for z in 1 .. repeatedIndexes.count loop
          if repeatedIndexes(z) = approverInIndex and repeatedAppIndexes(z) <> approverInIndex then
            update ame_temp_old_approver_lists
               set approval_status = decode(approver.approval_status
                                           ,ame_util.approvedStatus
                                           ,ame_util.approvedByRepeatedStatus
                                           ,ame_util.approveAndForwardStatus
                                           ,ame_util.approvedByRepeatedStatus
                                           ,ame_util.rejectStatus
                                           ,ame_util.rejectedByRepeatedStatus
                                           ,ame_util.forwardStatus
                                           ,ame_util2.forwardByRepeatedStatus
                                           ,ame_util2.reassignStatus
                                           ,ame_util.nullStatus
                                           ,ame_util.noResponseStatus
                                           ,ame_util2.noResponseByRepeatedStatus
                                           ,ame_util.repeatedStatus)
             where application_id = ameApplicationId
               and transaction_id = transactionIdIn
               and name           = approver.name
               and item_class        = currentApprovers(repeatedAppIndexes(z)).item_class
               and item_id           = currentApprovers(repeatedAppIndexes(z)).item_id
               and action_type_id    = currentApprovers(repeatedAppIndexes(z)).action_type_id
               and group_or_chain_id = currentApprovers(repeatedAppIndexes(z)).group_or_chain_id
               and occurrence        = currentApprovers(repeatedAppIndexes(z)).occurrence
               and approval_status in ( ame_util.notifiedByRepeatedStatus
                                       ,ame_util.repeatedStatus);
            select decode(approver.approval_status
                                           ,ame_util.approvedStatus
                                           ,ame_util.approvedByRepeatedStatus
                                           ,ame_util.approveAndForwardStatus
                                           ,ame_util.approvedByRepeatedStatus
                                           ,ame_util.rejectStatus
                                           ,ame_util.rejectedByRepeatedStatus
                                           ,ame_util.forwardStatus
                                           ,ame_util2.forwardByRepeatedStatus
                                           ,ame_util2.reassignStatus
                                           ,ame_util.nullStatus
                                           ,ame_util.noResponseStatus
                                           ,ame_util2.noResponseByRepeatedStatus
                                           ,ame_util.repeatedStatus) into tempStatus from dual;
            setInsertedApprovalStatus(currentApproverIndexIn => repeatedAppIndexes(z)
                                     ,approvalStatusIn => tempStatus);
            l_frw_index := repeatedAppIndexes(z);
            l_actionTypeId := currentApprovers(l_frw_index).action_type_id;
            l_votingRegime := null;
            l_votingRegime := ame_engine.getActionTypeVotingRegime(l_actionTypeId);
            if l_votingRegime is null then
              l_votingRegime := ame_approval_group_pkg.getVotingRegime(
                             approvalGroupIdIn => currentApprovers(l_frw_index).group_or_chain_id ,
                             applicationIdIn => ameApplicationId);
            end if;
            if l_votingRegime = ame_util.firstApproverVoting then
              tempfrwCount := 0;
              select count(*)
                 into tempfrwCount
                 from ame_temp_old_approver_lists
                where
                  application_id = ameApplicationId and
                  transaction_id = transactionIdIn and
                  item_class = currentApprovers(l_frw_index).item_class and
                  item_id = currentApprovers(l_frw_index).item_id and
                  action_type_id = currentApprovers(l_frw_index).action_type_id and
                  group_or_chain_id = currentApprovers(l_frw_index).group_or_chain_id and
                  approver_category = ame_util.approvalApproverCategory and
                  approval_status  in (ame_util.notifiedStatus
                                       ,ame_util.notifiedByRepeatedStatus) and
                 exists ( select null
                          from ame_temp_old_approver_lists
                          where  application_id = ameApplicationId and
                                 transaction_id = transactionIdIn and
                                 item_class = currentApprovers(l_frw_index).item_class and
                                 item_id = currentApprovers(l_frw_index).item_id and
                                 action_type_id = currentApprovers(l_frw_index).action_type_id and
                                 group_or_chain_id = currentApprovers(l_frw_index).group_or_chain_id and
                                 approver_category = ame_util.approvalApproverCategory and
                                 approval_status in (ame_util.approvedStatus
                                                    ,ame_util.approvedByRepeatedStatus
                                                    ,ame_util.rejectStatus
                                                    ,ame_util.rejectedByRepeatedStatus)
                           ) and
                not exists ( select null
                          from ame_temp_old_approver_lists
                          where  application_id = ameApplicationId and
                                 transaction_id = transactionIdIn and
                                 item_class = currentApprovers(l_frw_index).item_class and
                                 item_id = currentApprovers(l_frw_index).item_id and
                                 action_type_id = currentApprovers(l_frw_index).action_type_id and
                                 group_or_chain_id = currentApprovers(l_frw_index).group_or_chain_id and
                                 approver_category = ame_util.approvalApproverCategory and
                                 (approval_status  is null or approval_status in (
                                                     ame_util.nullStatus
                                                    ,ame_util.repeatedStatus)));
               if tempfrwCount > 0 then
                 update ame_temp_old_approver_lists
                 set approval_status = ame_util.beatByFirstResponderStatus
                 where
                  application_id = ameApplicationId and
                  transaction_id = transactionIdIn and
                  item_class = currentApprovers(l_frw_index).item_class and
                  item_id = currentApprovers(l_frw_index).item_id and
                  action_type_id = currentApprovers(l_frw_index).action_type_id and
                  group_or_chain_id = currentApprovers(l_frw_index).group_or_chain_id and
                  approver_category = ame_util.approvalApproverCategory and
                  approval_status in (ame_util.notifiedStatus,ame_util.notifiedByRepeatedStatus );
                 insertIntoTransApprovalHistory
                   (transactionIdIn         => transactionIdIn
                   ,applicationIdIn         => ameApplicationId
                   ,orderNumberIn           => currentApprovers(l_frw_index).approver_order_number
                   ,nameIn                  => currentApprovers(l_frw_index).name
                   ,appCategoryIn           => null
                   ,itemClassIn             => currentApprovers(l_frw_index).item_class
                   ,itemIdIn                => currentApprovers(l_frw_index).item_id
                   ,actionTypeIdIn          => currentApprovers(l_frw_index).action_type_id
                   ,authorityIn             => null
                   ,statusIn                => null
                   ,grpOrChainIdIn          => currentApprovers(l_frw_index).group_or_chain_id
                   ,occurrenceIn            => currentApprovers(l_frw_index).occurrence
                   ,apiInsertionIn          => currentApprovers(l_frw_index).api_insertion
                   ,memberOrderNumberIn     => currentApprovers(l_frw_index).member_order_number
                   ,notificationIdIn        => notificationIn.notification_id
                   ,userCommentsIn          => null
                   ,dateClearedIn           => null
                   ,historyTypeIn           => 'BEATBYFIRSTRESPONDER');
               end if;
            end if;
          end if;
        end loop;
      end if;
      if approver.approval_status in (ame_util.approvedStatus, ame_util.rejectStatus ) then
      /* Account for approval-group and chain-of-authority voting. */
      /* get action type id's  for  ame_util.groupChainApprovalTypeName,
         ame_util.postApprovalTypeName and ame_util.preApprovalTypeName */
      tempCOAGroupActionTypeId := ame_action_pkg.getActionTypeIdByName(actionTypeNameIn =>
                                         ame_util.groupChainApprovalTypeName);
      tempPreGroupActionTypeId := ame_action_pkg.getActionTypeIdByName(actionTypeNameIn =>
                                         ame_util.preApprovalTypeName);
      tempPostGroupActionTypeId := ame_action_pkg.getActionTypeIdByName(actionTypeNameIn =>
                                         ame_util.postApprovalTypeName);
        if approver.action_type_id in (tempPreGroupActionTypeId
                                      ,tempPostGroupActionTypeId) then
                 -- removed tempCOAGroupActionTypeId from above list for the
                 -- bug 4095605
        votingRegime := ame_approval_group_pkg.getVotingRegime(
                           approvalGroupIdIn => approver.group_or_chain_id ,
                           applicationIdIn => ameApplicationId);
                               -- in approver.group_or_chain_id
      else
        votingRegime := ame_engine.getActionTypeVotingRegime(actionTypeIdIn => approver.action_type_id);
      end if;
      if(votingRegime = ame_util.firstApproverVoting) then
        /*
          approverIn must be the first responder (otherwise, they would be suppressed,
          and we would have returned above).  Suppress the other approval approvers in the
          group or chain (including other occurrences of the input approver).
        */
        update ame_temp_old_approver_lists
          set approval_status = ame_util.beatByFirstResponderStatus
          where
            application_id = ameApplicationId and
            transaction_id = transactionIdIn and
            (name <> approver.name or
             occurrence <> approver.occurrence) and
            item_class = approver.item_class and
            item_id = approver.item_id and
            action_type_id = approver.action_type_id and
            group_or_chain_id = approver.group_or_chain_id and
              approver_category = ame_util.approvalApproverCategory and
              approval_status in (ame_util.notifiedStatus,ame_util.notifiedByRepeatedStatus);
        for i in 1..currentApprovers.count loop
          if currentApprovers(i).item_class = approver.item_class and
          currentApprovers(i).item_id = approver.item_id and
          currentApprovers(i).action_type_id = approver.action_type_id and
          currentApprovers(i).group_or_chain_id = approver.group_or_chain_id and
          currentApprovers(i).approver_category = approver.approver_category and
          currentApprovers(i).approval_status = ame_util.notifiedStatus and
          (currentApprovers(i).name <> approver.name or
          currentApprovers(i).occurrence <>  approver.occurrence) then
            setInsertedApprovalStatus(currentApproverIndexIn => i
                                  ,approvalStatusIn => ame_util.beatByFirstResponderStatus);
          end if;
        end loop;
        /* Insert rows in the notification approval history region for approvers
           with beat by first responder */
        insertIntoTransApprovalHistory
          (transactionIdIn         => transactionIdIn
          ,applicationIdIn         => ameApplicationId
          ,orderNumberIn           => approver.approver_order_number
          ,nameIn                  => approver.name
          ,appCategoryIn           => null
          ,itemClassIn             => approver.item_class
          ,itemIdIn                => approver.item_id
          ,actionTypeIdIn          => approver.action_type_id
          ,authorityIn             => null
          ,statusIn                => null
          ,grpOrChainIdIn          => approver.group_or_chain_id
          ,occurrenceIn            => approver.occurrence
          ,apiInsertionIn          => approver.api_insertion
          ,memberOrderNumberIn     => approver.member_order_number
          ,notificationIdIn        => notificationIn.notification_id
          ,userCommentsIn          => null
          ,dateClearedIn           => null
          ,historyTypeIn           => 'BEATBYFIRSTRESPONDER');
        end if;
      end if;
      --+
      --+ process reassignStatus
      --+
      if(approver.approval_status = ame_util2.reassignStatus) then
        ame_util.copyApproverRecord2(approverRecord2In => forwardeeIn,
                                     approverRecord2Out => forwardee);
        -- fetch forwardee details
        if(forwardee.orig_system is null or
           forwardee.orig_system_id is null or
           forwardee.display_name is null) then
          ame_approver_type_pkg.getOrigSystemIdAndDisplayName(nameIn =>forwardee.name,
                                                              origSystemOut => forwardee.orig_system,
                                                              origSystemIdOut => forwardee.orig_system_id,
                                                              displayNameOut => forwardee.display_name);
        end if;
          tempInsertionOrder := ame_engine.getNextInsertionOrder;
          tempParameter := approver.name ||
                           ame_util.fieldDelimiter ||
                           approver.item_class ||
                           ame_util.fieldDelimiter ||
                           approver.item_id ||
                           ame_util.fieldDelimiter ||
                           approver.action_type_id ||
                           ame_util.fieldDelimiter ||
                           approver.group_or_chain_id ||
                           ame_util.fieldDelimiter ||
                           approver.occurrence;
          insert into ame_temp_insertions(
              transaction_id,
              application_id,
              insertion_order,
              order_type,
              parameter,
              description,
              name,
              item_class,
              item_id,
              approver_category,
              api_insertion,
              authority,
              effective_date,
              reason) values(
                transactionIdIn,
                ameApplicationId,
                tempInsertionOrder,
                ame_util.afterApprover,
                tempParameter,
                ame_util.afterApproverDescription || approver.display_name,
                forwardee.name,
                forwardee.item_class,
                forwardee.item_id,
                forwardee.approver_category,
                decode(forwarderType,
                       ame_util.chainOfAuthorityForwarder, ame_util.apiAuthorityInsertion,
                       ame_util.apiInsertion),
                approver.authority,
                sysdate,
                ame_approver_deviation_pkg.reassignStatus );
      end if;
      --+
      /* Process the forwardee, checking for special forwarding cases. */
      if(approver.approval_status in (ame_util.forwardStatus,
                                        ame_util.approveAndForwardStatus)) then
        forwardeeType := null;
        if(approverInIsSpecialForwardee or
           approver.authority <> ame_util.authorityApprover or
           approver.api_insertion = ame_util.apiInsertion) then
          forwarderType := ame_util.adHocForwarder;
        else
          forwarderType := ame_util.chainOfAuthorityForwarder;
        end if;
        /* Use the reverse keyword to find the match nearest to approver. */
        for i in reverse 1 .. approverInIndex loop
          if(currentApprovers(i).name = forwardee.name) then
            forwardeeIndex := i;
            if(forwarderType = ame_util.chainOfAuthorityForwarder and
               currentApprovers(i).action_type_id = forwardee.action_type_id and
               currentApprovers(i).group_or_chain_id = forwardee.group_or_chain_id) then
              forwardeeType := ame_util.previousSameChainForwardee;
            else
              forwardeeType := ame_util.alreadyInListForwardee;
            end if;
            exit;
          end if;
        end loop;
        if(forwarderType = ame_util.chainOfAuthorityForwarder and
           (forwardeeType is null or
            forwardeeType = ame_util.alreadyInListForwardee) and
           ame_approver_type_pkg.isASubordinate(approverIn => approver,
                                                possibleSubordApproverIn => forwardee)) then
          forwardeeType := ame_util.subordSameHierarchyForwardee;
        end if;
        if(forwardeeType = ame_util.previousSameChainForwardee) then
          forwardee.occurrence := currentApprovers(forwardeeIndex).occurrence + 1;
        else
          forwardee.occurrence := 1;
        end if;
        if(forwardeeType is null) then /* Handle normal forwarding cases. */
          if(approver.orig_system <> forwardee.orig_system) then
            forwarderType := ame_util.adHocForwarder;
          end if;
          tempInsertionOrder := ame_engine.getNextInsertionOrder;
          tempParameter := approver.name ||
                           ame_util.fieldDelimiter ||
                           approver.item_class ||
                           ame_util.fieldDelimiter ||
                           approver.item_id ||
                           ame_util.fieldDelimiter ||
                           approver.action_type_id ||
                           ame_util.fieldDelimiter ||
                           approver.group_or_chain_id ||
                           ame_util.fieldDelimiter ||
                           approver.occurrence;
          insert into ame_temp_insertions(
              transaction_id,
              application_id,
              insertion_order,
              order_type,
              parameter,
              description,
              name,
              item_class,
              item_id,
              approver_category,
              api_insertion,
              authority,
              effective_date,
              reason) values(
                transactionIdIn,
                ameApplicationId,
                tempInsertionOrder,
                ame_util.afterApprover,
                tempParameter,
                ame_util.afterApproverDescription || approver.display_name,
                forwardee.name,
                forwardee.item_class,
                forwardee.item_id,
                forwardee.approver_category,
                decode(forwarderType,
                       ame_util.chainOfAuthorityForwarder, ame_util.apiAuthorityInsertion,
                       ame_util.apiInsertion),
                approver.authority,
                sysdate
                ,ame_approver_deviation_pkg.forwardReason );
        else /* Handle special forwarding cases. */
          /*
            All of the insertees generated within this if statement should have the same
            action_type_id and group_or_chain_id as approver.  The insertees' source
            should always be ame_util.specialForwardInsertion.  The insertions' order
            types should always be ame_util.afterApprover.
          */
          forwardingBehavior := ame_engine.getForwardingBehavior(forwarderTypeIn => forwarderType,
                                                                 forwardeeTypeIn => forwardeeType,
                                                                 approvalStatusIn => approver.approval_status);
          if(forwardingBehavior in (ame_util.repeatForwarder,
                                    ame_util.skipForwarder,
                                    ame_util.remand)) then
            /*
              Locate the start of the chain, so we can calculate each insertee's occurrence
              value, for use in the following insertee's insertion parameter.
            */
            for i in reverse 1 .. (approverInIndex - 1) loop
              if(currentApprovers(i).group_or_chain_id <> approver.group_or_chain_id or
                 currentApprovers(i).action_type_id <> approver.action_type_id or
                 currentApprovers(i).item_id <> approver.item_id or
                 currentApprovers(i).item_class <> approver.item_class) then
                firstIndexInChain := i + 1;
                exit;
              end if;
            end loop;
            if(firstIndexInChain is null) then
              firstIndexInChain := 1;
            end if;
          end if;
          /* Handle the special forwarding cases. */
          if(forwardingBehavior in (ame_util.forwardeeOnly,
                                    ame_util.forwarderAndForwardee)) then
            /* Insert forwardee as ad-hoc or COA, according to whether approverIn is ad-hoc or COA. */
            tempInsertionOrder := ame_engine.getNextInsertionOrder;
            tempParameter := approver.name ||
                             ame_util.fieldDelimiter ||
                             approver.item_class ||
                             ame_util.fieldDelimiter ||
                             approver.item_id ||
                             ame_util.fieldDelimiter ||
                             approver.action_type_id ||
                             ame_util.fieldDelimiter ||
                             approver.group_or_chain_id ||
                             ame_util.fieldDelimiter ||
                             approver.occurrence;
            insert into ame_temp_insertions(
              transaction_id,
              application_id,
              insertion_order,
              order_type,
              parameter,
              description,
              name,
              item_class,
              item_id,
              approver_category,
              api_insertion,
              authority,
              special_forwardee,
              effective_date,
              reason) values(
                transactionIdIn,
                ameApplicationId,
                tempInsertionOrder,
                ame_util.afterApprover,
                tempParameter,
                ame_util.afterApproverDescription || approver.display_name,
                forwardee.name,
                forwardee.item_class,
                forwardee.item_id,
                ame_util.approvalApproverCategory, /* Forwarding is not possible from an FYI approver. */
                decode(forwarderType,
                       ame_util.chainOfAuthorityForwarder, ame_util.apiAuthorityInsertion,
                       ame_util.apiInsertion),
                approver.authority,
                ame_util.booleanTrue,
                sysdate,
                ame_approver_deviation_pkg.forwardReason);
            if(forwardingBehavior = ame_util.forwarderAndForwardee) then /* Insert the forwarder. */
              tempInsertionOrder := ame_engine.getNextInsertionOrder;
              tempParameter := forwardee.name ||
                               ame_util.fieldDelimiter ||
                               forwardee.item_class ||
                               ame_util.fieldDelimiter ||
                               forwardee.item_id ||
                               ame_util.fieldDelimiter ||
                               forwardee.action_type_id ||
                               ame_util.fieldDelimiter ||
                               forwardee.group_or_chain_id ||
                               ame_util.fieldDelimiter ||
                               forwardee.occurrence;
              insert into ame_temp_insertions(
                transaction_id,
                application_id,
                insertion_order,
                order_type,
                parameter,
                description,
                name,
                item_class,
                item_id,
                approver_category,
                api_insertion,
                authority,
                special_forwardee,
                effective_date,
                reason) values(
                  transactionIdIn,
                  ameApplicationId,
                  tempInsertionOrder,
                  ame_util.afterApprover,
                  tempParameter,
                  ame_util.afterApproverDescription || forwardee.display_name,
                  approver.name,
                  approver.item_class,
                  approver.item_id,
                  ame_util.approvalApproverCategory, /* Forwarding is not possible from an FYI approver. */
                  decode(forwarderType,
                         ame_util.chainOfAuthorityForwarder, ame_util.apiAuthorityInsertion,
                         ame_util.apiInsertion),
                  approver.authority,
                  ame_util.booleanTrue,
                  sysdate,
                  ame_approver_deviation_pkg.forwardForwardeeReason);
            end if;
          elsif(forwardingBehavior in (ame_util.repeatForwarder, ame_util.skipForwarder)) then
            /*
              These cases are for a forwardee who is a subordinate of approverIn (who must be
              a COA approver), but who does not already precede approverIn in the list.  In this
              case we insert starting at the insertee, and ascending the hierarchy up to but not
              including approver.  In the case of ame_util.repeatForwarder, we then add
              approverIn and stop.  In the case of ame_util.skipForwarder, we then add
              approverIn's superior and stop.  The insertees are all COA approvers.
            */
            /* Insert the forwardee. */
            tempInsertionOrder := ame_engine.getNextInsertionOrder;
            tempParameter := approver.name ||
                             ame_util.fieldDelimiter ||
                             approver.item_class ||
                             ame_util.fieldDelimiter ||
                             approver.item_id ||
                             ame_util.fieldDelimiter ||
                             approver.action_type_id ||
                             ame_util.fieldDelimiter ||
                             approver.group_or_chain_id ||
                             ame_util.fieldDelimiter ||
                             approver.occurrence;
            insert into ame_temp_insertions(
              transaction_id,
              application_id,
              insertion_order,
              order_type,
              parameter,
              description,
              name,
              item_class,
              item_id,
              approver_category,
              api_insertion,
              authority,
              special_forwardee,
              effective_date,
              reason) values(
                transactionIdIn,
                ameApplicationId,
                tempInsertionOrder,
                ame_util.afterApprover,
                tempParameter,
                ame_util.afterApproverDescription || approver.display_name,
                forwardee.name,
                forwardee.item_class,
                forwardee.item_id,
                ame_util.approvalApproverCategory, /* Forwarding is not possible from an FYI approver. */
                ame_util.apiAuthorityInsertion,
                ame_util.authorityApprover,
                ame_util.booleanTrue,
                sysdate,
                ame_approver_deviation_pkg.forwardReason);
            insertedApprover.name := forwardee.name;
            insertedApprover.orig_system := forwardee.orig_system;
            insertedApprover.orig_system_id := forwardee.orig_system_id;
            insertedApprover.item_class := forwardee.item_class;
            insertedApprover.item_id := forwardee.item_id;
            insertedApprover.action_type_id := forwardee.action_type_id;
            insertedApprover.group_or_chain_id :=forwardee.group_or_chain_id;
            insertedApprover.occurrence := forwardee.occurrence;
            forwarderFound := false;
            /* Iterate through the forwardee's chain of authority. */
            loop
              /* Get the next superior to insert. */
              tempReason := ame_approver_deviation_pkg.forwardEngInsReason;
              ame_approver_type_pkg.getSuperior(approverIn => insertedApprover,
                                                superiorOut => superiorApprover);
              if(superiorApprover.name = approver.name) then
                forwarderFound := true;
                tempReason := ame_approver_deviation_pkg.forwardForwardeeReason;
                if(forwardingBehavior = ame_util.skipForwarder) then
                  tempReason := ame_approver_deviation_pkg.forwardEngInsReason;
                  --insertedApprover.name := approver.name;
                  --insertedApprover.orig_system_id := approver.orig_system_id;
                  ame_approver_type_pkg.getSuperior(approverIn => approver,
                                                    superiorOut => superiorApprover);
                end if;
              end if;
              /* Calculate insertedApprover.occurrence. */
              insertedApprover.occurrence := 1;
              for i in reverse firstIndexInChain .. approverInIndex loop
                if(currentApprovers(i).name = insertedApprover.name) then
                  insertedApprover.occurrence := currentApprovers(i).occurrence + 1;
                  exit;
                end if;
              end loop;
              /* Prepare and do the insertion. */
              tempInsertionOrder := ame_engine.getNextInsertionOrder;
              tempParameter := insertedApprover.name ||
                               ame_util.fieldDelimiter ||
                               insertedApprover.item_class ||
                               ame_util.fieldDelimiter ||
                               insertedApprover.item_id ||
                               ame_util.fieldDelimiter ||
                               insertedApprover.action_type_id ||
                               ame_util.fieldDelimiter ||
                               insertedApprover.group_or_chain_id ||
                               ame_util.fieldDelimiter ||
                               insertedApprover.occurrence;
              insert into ame_temp_insertions(
                transaction_id,
                application_id,
                insertion_order,
                order_type,
                parameter,
                description,
                name,
                item_class,
                item_id,
                approver_category,
                api_insertion,
                authority,
                special_forwardee,
                effective_date,
                reason) values(
                  transactionIdIn,
                  ameApplicationId,
                  tempInsertionOrder,
                  ame_util.afterApprover,
                  tempParameter,
                  ame_util.afterApproverDescription || insertedApprover.display_name,
                  superiorApprover.name,
                  approver.item_class,
                  approver.item_id,
                  ame_util.approvalApproverCategory, /* Forwarding is not possible from an FYI approver. */
                  ame_util.apiAuthorityInsertion,
                  ame_util.authorityApprover,
                  ame_util.booleanTrue,
                  sysdate,
                  tempReason);
              if(forwarderFound) then
                exit;
              end if;
              insertedApprover.name := superiorApprover.name;
              insertedApprover.orig_system_id := superiorApprover.orig_system_id;
            end loop;
          elsif(forwardingBehavior = ame_util.remand) then
            /*
              Remanding is possible only when forwardeeIn already precedes approverIn in
              the list (not necessarily in the same chain), and approverIn is a COA approver.  In
              such cases, we insert starting with forwardeeIn and continuing up to and including
              approver.  The insertees are always ad-hoc, and pertain to the same item, sublist,
              action type, and group or chain as the forwarder.
            */
            for i in forwardeeIndex .. approverInIndex loop
              if(i = forwardeeIndex) then
                prevApproverIndex := approverInIndex;
                prevApproverOccurrence := approver.occurrence;
              else
                prevApproverIndex := i - 1;
                prevApproverOccurrence := 1;
                for i in reverse firstIndexInChain .. approverInIndex loop
                  if(currentApprovers(i).name = currentApprovers(prevApproverIndex).name) then
                    prevApproverOccurrence := currentApprovers(prevApproverIndex).occurrence + 1;
                    exit;
                  end if;
                end loop;
              end if;
              tempInsertionOrder := ame_engine.getNextInsertionOrder;
              tempParameter := currentApprovers(prevApproverIndex).name ||
                               ame_util.fieldDelimiter ||
                               approver.item_class ||
                               ame_util.fieldDelimiter ||
                               approver.item_id ||
                               ame_util.fieldDelimiter ||
                               approver.action_type_id ||
                               ame_util.fieldDelimiter ||
                               approver.group_or_chain_id ||
                               ame_util.fieldDelimiter ||
                               prevApproverOccurrence;
              insert into ame_temp_insertions(
                transaction_id,
                application_id,
                insertion_order,
                order_type,
                parameter,
                description,
                name,
                item_class,
                item_id,
                approver_category,
                api_insertion,
                authority,
                special_forwardee,
                effective_date,
                reason) values(
                  transactionIdIn,
                  ameApplicationId,
                  tempInsertionOrder,
                  ame_util.afterApprover,
                  tempParameter,
                  ame_util.afterApproverDescription || insertedApprover.display_name,
                  currentApprovers(i).name,
                  approver.item_class,
                  approver.item_id,
                  ame_util.approvalApproverCategory, /* Forwarding is not possible from an FYI approver. */
                  ame_util.apiInsertion,
                  approver.authority,
                  ame_util.booleanTrue,
                  sysdate,
                  ame_approver_deviation_pkg.forwardRemandReason);
              prevApproverIndex := prevApproverIndex + 1;
            end loop;
          /* else forwardingBehavior = ame_util.ignoreForwarding */
        end if;
      end if;
      /* Cycle the engine to write the forwardees out to the old-approvers table. */
      ame_engine.updateTransactionState(isTestTransactionIn => false,
                                          isLocalTransactionIn => false,
                                          fetchConfigVarsIn => true,
                                          fetchOldApproversIn => true,
                                          fetchInsertionsIn => true,
                                          fetchDeletionsIn => true,
                                          fetchAttributeValuesIn => true,
                                          fetchInactiveAttValuesIn => false,
                                          processProductionActionsIn => false,
                                          processProductionRulesIn => false,
                                          updateCurrentApproverListIn => true,
                                          updateOldApproverListIn => true,
                                          processPrioritiesIn => true,
                                          prepareItemDataIn => false,
                                          prepareRuleIdsIn => false,
                                          prepareRuleDescsIn => false,
                                          transactionIdIn => transactionIdIn,
                                          ameApplicationIdIn => null,
                                          fndApplicationIdIn => applicationIdIn,
                                          transactionTypeIdIn => transactionTypeIn);
      end if;
      ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                   transactionIdIn => transactionIdIn,
                                   transactionTypeIdIn => transactionTypeIn);
      exception
        when badForwardeeException then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          errorCode := -20001;
          if transactionTypeIn is not null then
            errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                                messageNameIn => 'AME_400298_API_FOR_NOT_VALID',
                                                tokenNameOneIn => 'TRANSACTION_ID',
                                                tokenValueOneIn => transactionIdIn,
                                                tokenNameTwoIn => 'TRANSACTION_TYPE',
                                                tokenValueTwoIn => transactionTypeIn);
          else
            errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                                messageNameIn => 'AME_400066_API_FOR_NOT_VALID2',
                                                tokenNameOneIn => 'TRANSACTION_ID',
                                                tokenValueOneIn => transactionIdIn);
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'updateApprovalStatus',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when apiInsertionException then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                              messageNameIn => 'AME_400246_API_FWD_SAME_VALUE');
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'updateApprovalStatus',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when badStatusException then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          errorCode := -20001;
          if transactionTypeIn is not null then
            errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                                messageNameIn => 'AME_400247_API_APPR_STAT_VALUE',
                                                tokenNameOneIn => 'TRANSACTION_ID',
                                                tokenValueOneIn => transactionIdIn,
                                                tokenNameTwoIn => 'TRANSACTION_TYPE',
                                                tokenValueTwoIn => transactionTypeIn,
                                                tokenNameThreeIn => 'APPROVED_STATUS',
                                                tokenValueThreeIn => ame_util.approvedStatus,
                                                tokenNameFourIn => 'APPROVED_FORWARD_STATUS',
                                                tokenValueFourIn => ame_util.approveAndForwardStatus,
                                                tokenNameFiveIn => 'EXCEPTION_STATUS',
                                                tokenValueFiveIn => ame_util.exceptionStatus ,
                                                tokenNameSixIn => 'FORWARD_STATUS',
                                                tokenValueSixIn => ame_util.forwardStatus,
                                                tokenNameSevenIn => 'REJECT_STATUS',
                                                tokenValueSevenIn => ame_util.rejectStatus);
          else
            errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                                messageNameIn => 'AME_400064_API_APPR_STAT_VAL2',
                                                tokenNameOneIn => 'TRANSACTION_ID',
                                                tokenValueOneIn => transactionIdIn,
                                                tokenNameTwoIn => 'APPROVED_STATUS',
                                                tokenValueTwoIn => ame_util.approvedStatus,
                                                tokenNameThreeIn => 'APPROVED_FORWARD_STATUS',
                                                tokenValueThreeIn => ame_util.approveAndForwardStatus,
                                                tokenNameFourIn => 'EXCEPTION_STATUS',
                                                tokenValueFourIn => ame_util.exceptionStatus ,
                                                tokenNameFiveIn => 'FORWARD_STATUS',
                                                tokenValueFiveIn => ame_util.forwardStatus,
                                                tokenNameSixIn => 'REJECT_STATUS',
                                                tokenValueSixIn => ame_util.rejectStatus);
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'updateApprovalStatus',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          ame_util.runtimeException(packageNameIn => 'ame_engine',
                                    routineNameIn => 'updateApprovalStatus',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end updateApprovalStatus;
  procedure updateInsertions(indexIn in integer) as
    tempIndex integer;
    approverInsertionOrder integer;
    deletionInsertionOrder integer;
    begin
      if engStInsertionIndexes.exists(indexIn) then
        deletionInsertionOrder := engStInsertionIndexes(indexIn);
        tempIndex := engStInsertionIndexes.next(indexIn);
        while engStInsertionIndexes.exists(tempIndex) loop
          approverInsertionOrder := engStInsertionIndexes(tempIndex);
          if approverInsertionOrder > deletionInsertionOrder then
            update ame_temp_insertions
               set parameter = parameter - 1
             where insertion_order = approverInsertionOrder
               and application_id = engAmeApplicationId
               and transaction_id = engTransactionId
               and order_type = ame_util.absoluteOrder;
          end if;
          tempIndex := engStInsertionIndexes.next(tempIndex);
        end loop;
      end if;
    end updateInsertions;
  procedure setDeviationReasonDate(reasonIn in varchar2,dateIn in date) as
  begin
    engTempReason := reasonIn;
    engTempDate := dateIn;
  end setDeviationReasonDate;
end ame_engine;

/
