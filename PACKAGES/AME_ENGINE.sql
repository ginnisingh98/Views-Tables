--------------------------------------------------------
--  DDL for Package AME_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ENGINE" AUTHID CURRENT_USER as
/* $Header: ameeengi.pkh 120.7.12010000.3 2009/10/15 07:30:18 prasashe ship $ */
  /*************************************************************************************
  functions
  *************************************************************************************/
  /******************************** boolean functions *********************************/
  function approversMatch(approverRecord1In in ame_util.approverRecord2,
                          approverRecord2In in ame_util.approverRecord2) return boolean;
  function checkAttributeVariant(attributeIdIn in integer) return varchar2;
  function evalPrioritiesPerItem return boolean;
  function insertionExists(orderTypeIn in varchar2,
                           parameterIn in varchar2) return boolean;
  function isLocalTransaction return boolean;
  function isStaticAttUsage(attributeIdIn in integer) return boolean;
  function isTestTransaction return boolean;
  function processPriorities return boolean;
  function processProductionActions return boolean;
  function processProductionRules return boolean;
  /********************************** get functions ***********************************/
  function getActionTypeChainOrderMode(actionTypeIdIn in integer) return varchar2;
  function getActionTypeId(actionTypeNameIn in varchar2) return integer;
  function getActionTypeName(actionTypeIdIn in integer) return varchar2;
  function getActionTypeOrderNumber(actionTypeIdIn in integer) return integer;
  function getActionTypePackageName(actionTypeIdIn in integer) return varchar2;
  function getActionTypeUsage(actionTypeIdIn in integer) return integer;
  function getActionTypeVotingRegime(actionTypeIdIn in integer) return varchar2;
  function getAmeApplicationId return integer;
  function getApprovalProcessCompleteYN return varchar2; /* for API use only */
  function getAttributeIdByName(attributeNameIn in varchar2) return integer;
  function getAttributeName(attributeIdIn in integer) return varchar2;
  function getAttributeType(attributeIdIn in integer) return varchar2;
  /*
    getConfigVarValue only works in a PL/SQL session that has been initialized by a call
    to updateTransactionState.
  */
  function getConfigVarValue(configVarNameIn in varchar2) return varchar2;
  function getEffectiveRuleDate return date;
  function getFndApplicationId return integer;
  /*
    getForwardingBehavior only works in a PL/SQL session that has been initialized by a
    call to updateTransactionState.  The allowed values for forwarderTypeIn are
      ame_util.chainOfAuthorityForwarder
      ame_util.adHocForwarder
    The allowed values for forwardeeTypeIn are
      ame_util.previousSameChainForwardee
      ame_util.subordSameHierarchyForwardee
      ame_util.alreadyInListForwardee
    The allowed values for approvalStatus in are
      ame_util.approveAndForwardStatus
      ame_util.forwardStatus
  */
  function getForwardingBehavior(forwarderTypeIn in varchar2,
                                 forwardeeTypeIn in varchar2,
                                 approvalStatusIn in varchar2) return varchar2;
  /* Only action-type handlers should call the getHandler functions.  See also the getHandler procedures. */
  function getHandlerActionTypeId return integer;
  function getHandlerActionTypeOrderNum return integer;
  function getHandlerApprovalStatus(approverIn in ame_util.approverRecord2
                                   ,votingRegimeIn in varchar2 default null) return varchar2;
  /* Only call getHandlerAuthority for action types that always generate approvers within a fixed sublist. */
  function getHandlerAuthority return varchar2;
  /*
    The getHandlerItem[Whatever] functions relate to the item to which a rule applies, <<not>> to
    the item that satisfies the rule.  These items differ for header-level rules with conditions
    on subordinate-item-class attributes, when per-item evaluation is enabled.
  */
  function getHandlerItemClassId return integer;
  function getHandlerItemClassName return varchar2;
  function getHandlerItemClassOrderNumber return integer;
  function getHandlerItemId return varchar2;
  function getHandlerItemOrderNumber return integer;
  /*
    If any of the default-null inputs to getHandlerOccurrence is null, the function returns the next
    occurrence value for the group or chain most recently added to the approver list.  If all of the
    default-null inputs are non-null, the function returns the next occurrence for the group or chain
    identified by the inputs.
  */
  function getHandlerOccurrence(nameIn in varchar2,
                                itemClassIn in varchar2 default null,
                                itemIdIn in varchar2 default null,
                                actionTypeIdIn in integer default null,
                                groupOrChainIdIn in integer default null) return integer;
  function getHandlerRuleType return integer;
  /*
    getHandlerState is included in this version of the engine for architectural backwards compatibility
    for custom handlers only.  The engine's handler-state functionality is deprecated.  Please use
    package variables to maintain handler state instead.
  */
  function getHandlerState(handlerNameIn in varchar2,
                           parameterIn in varchar2 default null) return varchar2;
  /*
    Only call getHandlerSublistOrderNum for action types that always generate approvers within a fixed sublist.
    This function returns the sublist order number determined by the sublist-ordering mode for the item class
    to which a rule applies.
  */
  function getHandlerSublistOrderNum return integer;
  /*
    The following attribute-value-fetching functions only work for attributes
    that are not of the currency attribute type.  For attributes that may be
    of that type, use the corresponding getHeaderAttValues or getItemAttValues
    procedures.
  */
  function getHeaderAttValue1(attributeIdIn in integer) return varchar2;
  function getHeaderAttValue2(attributeNameIn in varchar2) return varchar2;
  function getItemAttValue1(attributeIdIn in integer,
                            itemIdIn in varchar2) return varchar2;
  function getItemAttValue2(attributeNameIn in varchar2,
                            itemIdIn in varchar2) return varchar2;
  function getItemClassId(itemClassNameIn in varchar2) return integer;
  function getItemClassName(itemClassIdIn in integer) return varchar2;
  function getItemClassOrderNumber(itemClassIdIn in integer) return integer;
  function getItemClassParMode(itemClassIdIn in integer) return varchar2;
  function getItemClassSublistMode(itemClassIdIn in integer) return varchar2;
  function getItemOrderNumber(itemClassNameIn in varchar2,
                              itemIdIn in varchar2) return integer;
  /* Call updateTransactionState with fetchInsertionsIn set true, before calling getNextInsertionOrder. */
  function getNextInsertionOrder return integer;
  function getNullActionTypeOrderNumber return integer;
  function getRuntimeGroupCount(groupIdIn in integer) return integer;
  function getSublistOrderNum(itemClassNameIn in varchar2,
                              authorityIn in varchar2) return integer;
  function getTransactionId return varchar2;
  function getTransactionTypeId return varchar2;
  function getVariantAttributeValue(attributeIdIn in integer,
                                    itemClassIn in varchar2,
                                    itemIdIn in varchar2) return number;
  /*************************************************************************************
  procedures
  *************************************************************************************/
  procedure checkApprover(approverIn in ame_util.approverRecord2);
  /*
    The following procedures are for API use only.  Their output arguments correspond to API
    output arguments.  The API calls updateApprovalProcessState and then calls one or more
    of these procedures to populate API output arguments as required.  See also the function
    getApprovalProcessCompleteYN.
  */
  procedure getApprovers(approversOut out nocopy ame_util.approversTable2);
  /* This procedure will be called by the API's to fetch the approver tree from the engine */
  procedure getApprovers2(approversOut     out nocopy ame_util.approversTable2
                         ,approversTreeOut out nocopy ame_util.approversTreeTable);
  /* Procedure to return applicable rules and their descriptions */
  procedure getApplicableRules
    (ruleIdsOut             out nocopy ame_util.idList
    ,ruleDescriptionsOut    out nocopy ame_util.stringList);
  procedure getInsertions
    (positionIn             in            number
    ,orderTypeIn            in            varchar2 default null
    ,coaInsertionsYNIn      in            varchar2 default ame_util.booleanTrue
    ,availableInsertionsOut    out nocopy ame_util.insertionsTable2
    );
  procedure getItemAppProcessCompleteYN(itemAppProcessCompleteYNOut out nocopy ame_util.charList);
  procedure getItemClasses(itemClassesOut out nocopy ame_util.stringList);
  procedure getItemIds(itemIdsOut out nocopy ame_util.stringList);
  procedure getItemIndexes(itemIndexesOut out nocopy ame_util.idList);
  /* Procedure's to return all itemids and itemclasses or the current transaction */
  procedure getAllItemClasses(itemClassNamesOut out nocopy ame_util.stringList);
  procedure getAllItemIds(itemIdsOut out nocopy ame_util.stringList);
  procedure getItemSources(itemSourcesOut out nocopy ame_util.longStringList);
  procedure getProductionIndexes(productionIndexesOut out nocopy ame_util.idList);
  /* getRepeatedIndexes is Added for asynch */
  procedure getRepeatedIndexes(repeatedIndexesOut out nocopy ame_util.idList
                              ,repeatedAppIndexesOut out nocopy ame_util.idList);
  procedure getRuleDescriptions(ruleDescriptionsOut out nocopy ame_util.stringList);
  procedure getRuleIds(ruleIdsOut out nocopy ame_util.idList);
  procedure getRuleIndexes(ruleIndexesOut out nocopy ame_util.idList);
  procedure getSourceTypes(sourceTypesOut out nocopy ame_util.stringList);
  procedure getTransVariableNames(transVariableNamesOut out nocopy ame_util.stringList);
  procedure getTransVariableValues(transVariableValuesOut out nocopy ame_util.stringList);
  procedure getVariableNames(variableNamesOut out nocopy ame_util.stringList);
  procedure getVariableValues(variableValuesOut out nocopy ame_util.stringList);
  /*
    The following procedures are for the test tab's use and the action-type handlers' use.
    They let the handlers manipulate the approver list, query for approver insertions and
    deletions, etc.
  */
  /* addApprover adds an approver to the end of the list. */
  procedure addApprover(approverIn in ame_util.approverRecord2);
  /*
    clearHandlerState is included in this version of the engine for architectural backwards compatibility
    for custom handlers only.  The engine's handler-state functionality is deprecated.  Please use
    package variables to maintain handler state instead.
  */
  procedure clearHandlerState(handlerNameIn in varchar2,
                              parameterIn in varchar2 default null);
  /* getAllApprovers is for amem0013.sql backwards compatibility only.  Do not use it elsewhere. */
  procedure getAllApprovers(approversOut out nocopy ame_util.approversTable);
  /*
    getApprovalGroupConfigs returns the input group IDs in groupIdsInOut, as well as the
    output arguments, sorted first by group order number, second by group ID.  So approval-group
    handlers can process the groups in the order this procedure returns them.
    BUG : 4491715 modified to sort sources and approver categories with the group ids
  */
  procedure getApprovalGroupConfigs(groupIdsInOut in out nocopy ame_util.idList,
                                    sourcesInOut in out nocopy ame_util.longStringList,
                                    approverCategoriesInOut in out nocopy ame_util.charList,
                                    orderNumbersOut out nocopy ame_util.idList,
                                    votingRegimesOut out nocopy ame_util.charList);
  /* Only action-type handlers should call the getHandler procedures.  See also the getHandler functions. */
  /* getHandlerCOAFirstApprover only returns inserted approvers with the ame_util.firstAuthority order type. */
  procedure getHandlerCOAFirstApprover(itemClassIn in varchar2,
                                       itemIdIn in varchar2,
                                       actionTypeIdIn in integer,
                                       groupOrChainIdIn in integer,
                                       nameOut out nocopy varchar2,
                                       origSystemOut out nocopy varchar2,
                                       origSystemIdOut out nocopy integer,
                                       displayNameOut out nocopy varchar2,
                                       sourceOut out nocopy varchar2);
  /* getHandlerCOAInsertion only returns inserted approvers with the ame_util.afterApprover order type. */
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
                                   sourceOut out nocopy varchar2);
  procedure getHandlerRules(ruleIdsOut out nocopy ame_util.idList,
                            approverCategoriesOut out nocopy ame_util.charList,
                            parametersOut out nocopy ame_util.stringList,
                            parameterTwosOut out nocopy ame_util.stringList);
  procedure getHandlerRules2(ruleIdsOut out nocopy ame_util.idList,
                             approverCategoriesOut out nocopy ame_util.charList,
                             parametersOut out nocopy ame_util.stringList);
  procedure getHandlerRules3(ruleIdsOut out nocopy ame_util.idList,
                             ruleIndexesOut out nocopy ame_util.idList,
                             parametersOut out nocopy ame_util.stringList,
                             listModParameterOnesOut out nocopy ame_util.stringList,
                             listModParameterTwosOut out nocopy ame_util.longStringList);
  /*
    getHandlerLMApprovers returns the indexes of the approvers in engStApprovers that
    have the wf_roles.name value listModParameterTwoIn, at the positions within an approval
    group or chain of authority required by listModParameterOneIn, and satisfying the
    includeFyiApproversIn and includeApprovalGroupsIn arguments' requirements.  Each
    matched approver's index is written to approverIndexesOut.  If the calling handler
    needs to know also the last approver in a chain of forwardees following a matched
    approver who forwards (with or without approval), the handler should set
    returnForwardeesIn true.  Then lastForwardeeIndexesOut(i) will be the index of the
    last forwardee in engStApprovers corresponding to the matched approver at
    engStApprovers(approverIndexesOut(i)).
  */
  procedure getHandlerLMApprovers(listModParameterOneIn in varchar2,
                                  listModParameterTwoIn in varchar2,
                                  includeFyiApproversIn in boolean,
                                  includeApprovalGroupsIn in boolean,
                                  returnForwardeesIn in boolean,
                                  approverIndexesOut out nocopy ame_util.idList,
                                  lastForwardeeIndexesOut out nocopy ame_util.idList);
  /*
    The following attribute-value-fetching procedures work for attributes of all
    types (including currency types).  If you know the attribute whose value you want
    to fetch is not of currency type, and either (1) the attribute is header level or
    (2) you want to fetch its value for just one item ID, you can use one of the
    getHeaderAttValue or getItemAttValue functions declared above.
  */
  procedure getHeaderAttValues1(attributeIdIn in integer,
                                attributeValue1Out out nocopy varchar2,
                                attributeValue2Out out nocopy varchar2,
                                attributeValue3Out out nocopy varchar2);
  procedure getHeaderAttValues2(attributeNameIn in varchar2,
                                attributeValue1Out out nocopy varchar2,
                                attributeValue2Out out nocopy varchar2,
                                attributeValue3Out out nocopy varchar2);
  procedure getItemAttValues1(attributeIdIn in integer,
                              itemIdIn in varchar2,
                              attributeValue1Out out nocopy varchar2,
                              attributeValue2Out out nocopy varchar2,
                              attributeValue3Out out nocopy varchar2);
  procedure getItemAttValues2(attributeNameIn in varchar2,
                              itemIdIn in varchar2,
                              attributeValue1Out out nocopy varchar2,
                              attributeValue2Out out nocopy varchar2,
                              attributeValue3Out out nocopy varchar2);
  procedure getItemAttValues3(attributeIdIn in integer,
                              itemIndexIn in varchar2,
                              attributeValue1Out out nocopy varchar2,
                              attributeValue2Out out nocopy varchar2,
                              attributeValue3Out out nocopy varchar2);
  /*
    Use the getItemClassAttValues procedures to fetch all of the attribute values
    of a given item class.  Use one of the first two variants for attributes known
    not to be currency attributes, and one of the other two for attributes of
    unknown type.
  */
  procedure getItemClassAttValues1(attributeIdIn in integer,
                                   attributeValuesOut out nocopy ame_util.attributeValueList);
  procedure getItemClassAttValues2(attributeNameIn in varchar2,
                                   attributeValuesOut out nocopy ame_util.attributeValueList);
  procedure getItemClassAttValues3(attributeIdIn in integer,
                                   attributeValues1Out out nocopy ame_util.attributeValueList,
                                   attributeValues2Out out nocopy ame_util.attributeValueList,
                                   attributeValues3Out out nocopy ame_util.attributeValueList);
  procedure getItemClassAttValues4(attributeNameIn in varchar2,
                                   attributeValues1Out out nocopy ame_util.attributeValueList,
                                   attributeValues2Out out nocopy ame_util.attributeValueList,
                                   attributeValues3Out out nocopy ame_util.attributeValueList);
  procedure getItemClassItemIds(itemClassIdIn in integer,
                                itemIdsOut out nocopy ame_util.stringList);
  --+
  procedure getAllProductions(productionsOut out nocopy ame_util2.productionsTable);
  procedure getProductions(itemClassIn    in  varchar2
                          ,itemIdIn       in  varchar2
                          ,productionsOut out nocopy ame_util2.productionsTable);
  /*
    Runtime code should call ame_engine.getRuntimeGroupMembers, <<not>> ame_approval_group_pkg.getRuntimeGroupMembers,
    to fetch an approval group's membership.  (The engine version only performs the fetch the first time it is called,
    in a given PL/SQL context.  Thereafter it returns values cached in an engine package variable.)
  */
  procedure getRuntimeGroupMembers(groupIdIn in integer,
                                   approverNamesOut out nocopy ame_util.longStringList,
                                   approverOrderNumbersOut out nocopy ame_util.idList,
                                   approverDisplayNamesOut out nocopy ame_util.longStringList,
                                   origSystemIdsOut out nocopy ame_util.idList,
                                   origSystemsOut out nocopy ame_util.stringList);
  /*
    Only the test-tab object layer should call getTestTransApplicableRules.  It should first call
    updateTransactionState.  The itemClassIdsOut and itemIdsOut variables identify the items that
    satisfy the rules.
  */
  procedure getTestTransApplicableRules(ruleItemClassIdsOut out nocopy ame_util.idList,
                                        itemClassIdsOut out nocopy ame_util.idList,
                                        itemIdsOut out nocopy ame_util.stringList,
                                        ruleIdsOut out nocopy ame_util.idList,
                                        ruleTypesOut out nocopy ame_util.idList,
                                        ruleDescriptionsOut out nocopy ame_util.stringList);
  /*
    Only the test-tab object layer should call getTestTransApprovers.  No call to updateTransactionState
    should precede it.  The approverListStageIn argument should be an integer between one and five
    (inclusive), indicating which step in the approver-list algorithm the engine should complete before
    getTestTransApprovers returns the approver list as of that stage.  Here are the stages:
      stage    operations completed
      -----    --------------------
      1        generation of default approver list, accounting for chain-of-authority insertions
      2        ad-hoc insertions (including surrogates)
      3        ad-hoc deletions
      4        elimination of repeated approvers per configuration-variable values
      5        generation of approver order numbers
    The test tab should skip stages 2-3 for test transactions.
  */
  procedure getTestTransApprovers(isTestTransactionIn in boolean,
                                  transactionIdIn in varchar2,
                                  ameApplicationIdIn in integer,
                                  approverListStageIn in integer,
                                  approversOut out nocopy ame_util.approversTable2,
                                  productionIndexesOut out nocopy ame_util.idList,
                                  variableNamesOut out nocopy ame_util.stringList,
                                  variableValuesOut out nocopy ame_util.stringList);
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
                                   fetchInactiveAttValuesIn in boolean default false);
  /*
    insertApprover inserts a single approver at an arbitrary location in the current
    approver list.  Insertion may occur after the last approver.  If adjustMemberOrderNumbersIn
    is true, insertApprover performs the insertion and then adjusts the member_order_number
    values of the approvers at and above indexIn, in the same group or chain as approverIn,
    according to the following rules:
    1.  If engStApprovers(indexIn) (i.e. approverIn after the insertion) is the only approver
        in its group or chain, set its member_order_number to one.
    2.  Otherwise, if the previous approver but not the subsequent approver (if any) is in
        the same group or chain, set engStApprovers(indexIn).member_order_number to
        engStApprovers(indexIn - 1).member_order_number + 1.
    3.  Otherwise, if the next approver but not the previous approver (if any) is in the
        same group or chain, set engStApprovers(indexIn).member_order_number to
        engStApprovers(indexIn + 1).member_order_number - 1.
    4.  Otherwise, if the approvers on either side of engStApprovers(indexIn) have the same
        member_order_number, set engStApprovers(indexIn).member_order_number to that value.
        (Basically, preserve parallel group-or-chain ordering if it exists.)
    5.  Otherwise, set engStApprovers(indexIn).member_order_number to follow the previous
        approver, and increment the member_order_number values of any subsequent approvers
        in the same chain, so they follow engStApprovers(indexIn).  (Basically, preserve
        serial group-or-chain ordering if it exists.)
  */
  procedure insertApprover(indexIn in integer,
                           approverIn in ame_util.approverRecord2,
                           adjustMemberOrderNumbersIn in boolean default false,
                           approverLocationIn in boolean default ame_util.lastAmongEquals,
                           inserteeIndexIn in number default null,
                           currentInsIndex in integer default null);
  /*
    insertApprovers inserts a list of approvers at an arbitrary location in the current
    approver list.  approversIn(1) will have the index firstIndexIn in engStApprovers.
    Insertion may occur after the last approver.
  */
  procedure insertApprovers(firstIndexIn in integer,
                            approversIn in ame_util.approversTable2);
  /*
    Any API routine that could change transactional data in any of the ame_temp tables
    must call lockTransaction right after the routine's begin statement, and must call
    unlockTransaction right before returning (in both cases even if the routine calls another
    API routine that also calls lockTransaction).  Make sure every possible return calls
    unlockTransaction, including the exception handlers.
  */
  procedure lockTransaction(fndApplicationIdIn in integer,
                            transactionIdIn in varchar2,
                            transactionTypeIdIn in varchar2 default null);
  procedure logTransaction;
  /* parseFields parses stringIn into strings separated by ame_util.fieldDelimiter. */
  procedure parseFields(stringIn in varchar2,
                        fieldsOut out nocopy ame_util.longStringList);
  procedure updateInsertions(indexIn in integer);
  procedure processExceptions;
  /*
    setHandlerState is included in this version of the engine for architectural backwards compatibility
    for custom handlers only.  The engine's handler-state functionality is deprecated.  Please use
    package variables to maintain handler state instead.
  */
  procedure setHandlerState(handlerNameIn in varchar2,
                            parameterIn in varchar2 default null,
                            stateIn in varchar2 default null);
  /* Procedure called by LM /substitution handlers to indicate that the rule is applied */
  procedure setRuleApplied(ruleIndexIn in integer);
  procedure substituteApprover(approverIndexIn in integer,
                               nameIn in varchar2,
                               actionTypeIdIn in varchar2,
                               ruleIdIn in integer);
  /*
    truncateChain truncates the chain of authority in engStApprovers including
    the approver at approverIndexIn, starting with the first approver after that
    approver (if any).  If the allowFyiNotifications configuration variable is
    set to ame_util.yes, truncation means changing to ame_util.fyiApproverCategory
    the approver_category of the rest of the chain.  Otherwise it means deleting
    the rest of the chain.  Note that if a routine calls truncateChain repeatedly,
    it will need to account for the fact that truncation changes the indexes of
    approvers occurring after the point of truncation.  This suggests sorting the
    target indexes in descending order, and truncating in that order. . . .
  */
  procedure truncateChain(approverIndexIn in integer,
                          ruleIdIn in integer);
  procedure unlockTransaction(fndApplicationIdIn in integer,
                              transactionIdIn in varchar2,
                              transactionTypeIdIn in varchar2 default null);
  /*
    All API calls and test functions should call updateTransactionState to cycle the engine,
    before calling other engine routines to fetch transaction-state values.
  */
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
                                   transactionTypeIdIn in varchar2 default null);
  /* test procedure */
  procedure testEngine(printContextYNIn in varchar2 default 'N',
                       printAppRulesYNIn in varchar2 default 'N',
                       printApproversYNIn in varchar2 default 'N');
  /* getNext Approvers */
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
           ,transVariableValuesOut       out nocopy ame_util.stringList);
  /* updateApprovalStatus */
  procedure updateApprovalStatus(applicationIdIn in number,
                                 transactionTypeIn in varchar2,
                                 transactionIdIn in varchar2,
                                 approverIn in ame_util.approverRecord2,
                                 notificationIn in ame_util2.notificationRecord
                                         default ame_util2.emptyNotificationRecord,
                                 forwardeeIn in ame_util.approverRecord2 default
                                             ame_util.emptyApproverRecord2,
                                 updateItemIn in boolean default false) ;
  procedure setDeviationReasonDate(reasonIn in varchar2,dateIn in date);
end ame_engine;

/
