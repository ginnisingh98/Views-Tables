--------------------------------------------------------
--  DDL for Package Body AME_API3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_API3" as
/* $Header: ameeapi3.pkb 120.13.12010000.2 2009/08/20 12:31:50 prasashe ship $ */
  ambiguousApproverException exception;
  ambiguousApproverMessage constant ame_util.longestStringType :=
    ame_util.getMessage(applicationShortNameIn =>'PER',
                       messageNameIn           => 'AME_400812_NULL_APPR_REC_NAME');
  /* functions */
  function getRuleDescription(ruleIdIn in varchar2) return varchar2 as
    begin
      return(ame_rule_pkg.getDescription(ruleIdIn => ruleIdIn));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getRuleDescription',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getRuleDescription;
  /* procedures */
  procedure clearInsertion(applicationIdIn in number,
                           transactionTypeIn in varchar2,
                           transactionIdIn in varchar2,
                           approverIn in ame_util.approverRecord2) as
    ameAppId integer;
    errorCode integer;
    errorMessage ame_util.longStringType;
    appr_rec_params varchar2(100);
    cursor getAnchorInsertions (parameterIn varchar2) is
      (select name
         from ame_temp_insertions
        where application_id = ame_engine.getAmeApplicationId
          and transaction_id = transactionIdIn
          and parameter = parameterIn);
    nameList       ame_util.longStringList;
    anchorsExistException exception;
    cmpParameter ame_temp_insertions.parameter%type;
    anchorName varchar2(320);
    anchorList varchar2(1000);
    approvers ame_util.approversTable2;
    nullApprRecordFieldException Exception;
    begin
      ame_engine.lockTransaction(fndApplicationIdIn => applicationIdIn,
                                 transactionIdIn => transactionIdIn,
                                 transactionTypeIdIn => transactionTypeIn);
      ameAppId := ame_admin_pkg.getApplicationId(fndAppIdIn => applicationIdIn,
                                                 transactionTypeIdIn => transactionTypeIn);
      appr_rec_params:=null;
      if(approverIn.name is null) then
        appr_rec_params := 'name ';
      end if;
      if approverIn.item_class is null then
        appr_rec_params := appr_rec_params || ', item_class ';
      end if;
      if approverIn.item_id is null then
        appr_rec_params := appr_rec_params || ', item_id ';
      end if;
      if appr_rec_params is not null then
        raise nullApprRecordFieldException;
      end if;
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
                                        transactionTypeIdIn => transactionTypeIn );
      ame_engine.getApprovers(approversOut => approvers);
      for i in 1 .. approvers.count loop
        if approvers(i).name = approverIn.name and
           approvers(i).item_class = approverIn.item_class and
           approvers(i).item_id = approverIn.item_id and
           approvers(i).api_insertion = ame_util.apiInsertion then
          anchorName := approvers(i).name;
          cmpParameter := approvers(i).name ||
                          ame_util.fieldDelimiter ||
                          approvers(i).item_class ||
                          ame_util.fieldDelimiter ||
                          approvers(i).item_id ||
                          ame_util.fieldDelimiter ||
                          approvers(i).action_type_id ||
                          ame_util.fieldDelimiter ||
                          approvers(i).group_or_chain_id ||
                          ame_util.fieldDelimiter ||
                          approvers(i).occurrence;
          open getAnchorInsertions(cmpParameter);
          fetch getAnchorInsertions bulk collect into nameList;
          if nameList.count > 0 then
            close getAnchorInsertions;
            raise anchorsExistException;
          end if;
          close getAnchorInsertions;
        end if;
      end loop;
      for i in 1 .. approvers.count loop
        if approvers(i).name = approverIn.name and
           approvers(i).item_class = approverIn.item_class and
           approvers(i).item_id = approverIn.item_id then
          ame_engine.updateInsertions(indexIn => i);
        end if;
      end loop;
      delete from ame_temp_insertions
        where
          application_id = ameAppId and
          transaction_id = transactionIdIn and
          name = approverIn.name  and
          item_class = approverIn.item_class and
          item_id  = approverIn.item_id ;
      if sql%found then
        ame_approver_deviation_pkg.clearDeviationState(
                        applicationIdIn  => ameAppId
                       ,transactionIdIn => transactionIdIn );
      end if;
      ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                   transactionIdIn => transactionIdIn,
                                   transactionTypeIdIn => transactionTypeIn);
    exception
      when anchorsExistException then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          anchorList := '';
          for i in 1 .. nameList.count loop
            anchorList := anchorList || ame_approver_type_pkg.getApproverDescription(nameList(i));
            if i <> nameList.count then
              anchorList := anchorList || '; ';
            end if;
          end loop;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400651_ANCHORS_EXIST',
                                              tokenNameOneIn => 'APPROVER',
                                              tokenValueOneIn => ame_approver_type_pkg.getApproverDescription(anchorName),
                                              tokenNameTwoIn => 'ANCHORED_APPROVERS',
                                              tokenValueTwoIn => anchorList);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'clearInsertion',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
      when nullApprRecordFieldException then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn          => 'AME_400813_NULL_CLINS_APPR_FLD',
                                              tokenNameOneIn         => 'APPROVER_REC_PARAMS',
                                              tokenValueOneIn        => appr_rec_params);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'clearInsertion',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
      when others then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'clearInsertion',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
  end clearInsertion;
  procedure clearInsertions(applicationIdIn in integer,
                            transactionTypeIn in varchar2,
                            transactionIdIn in varchar2) as
    ameAppId integer;
    begin
      ame_engine.lockTransaction(fndApplicationIdIn => applicationIdIn,
                                 transactionIdIn => transactionIdIn,
                                 transactionTypeIdIn => transactionTypeIn);
      ameAppId := ame_admin_pkg.getApplicationId(fndAppIdIn => applicationIdIn,
                                                 transactionTypeIdIn => transactionTypeIn);
      delete from ame_temp_insertions
        where
          application_id = ameAppId and
          transaction_id = transactionIdIn ;
      if sql%found then
        ame_approver_deviation_pkg.clearDeviationState(
                        applicationIdIn  => ameAppId
                       ,transactionIdIn => transactionIdIn );
      end if;
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
                                        transactionTypeIdIn => transactionTypeIn );
      ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                   transactionIdIn => transactionIdIn,
                                   transactionTypeIdIn => transactionTypeIn);
    exception
      when others then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'clearInsertions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
  end clearInsertions;
  procedure clearSuppression(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approverIn in ame_util.approverRecord2) as
    ameAppId integer;
    errorCode integer;
    errorMessage ame_util.longStringType;
    appr_rec_params varchar2(100);
    nullApprRecordFieldException Exception;
    begin
      ame_engine.lockTransaction(fndApplicationIdIn => applicationIdIn,
                                 transactionIdIn => transactionIdIn,
                                 transactionTypeIdIn => transactionTypeIn);
      ameAppId := ame_admin_pkg.getApplicationId(fndAppIdIn => applicationIdIn,
                                                 transactionTypeIdIn => transactionTypeIn);
      appr_rec_params:=null;
      if(approverIn.name is null) then
        appr_rec_params := 'name ';
      end if;
      if approverIn.item_class is null then
        appr_rec_params := appr_rec_params || ', item_class ';
      end if;
      if approverIn.item_id is null then
        appr_rec_params := appr_rec_params || ', item_id ';
      end if;
      if approverIn.action_type_id is null then
        appr_rec_params := appr_rec_params || ', action_type_id ';
      end if;
      if approverIn.group_or_chain_id is null then
        appr_rec_params := appr_rec_params || ', group_or_chain_id ';
      end if;
      if appr_rec_params is not null then
              raise nullApprRecordFieldException;
      end if;
      delete from ame_temp_deletions
        where
          application_id = ameAppId and
          transaction_id = transactionIdIn and
          name = approverIn.name  and
          item_class = approverIn.item_class and
          item_id  = approverIn.item_id and
          action_type_id = approverIn.action_type_id and
          group_or_chain_id = approverIn.group_or_chain_id ;
      if sql%found then
        ame_approver_deviation_pkg.clearDeviationState(
                        applicationIdIn  => ameAppId
                       ,transactionIdIn => transactionIdIn );
      end if;
      --
      --  Cycle the engine to account for changes in the deletions table.  (There is no previous
      -- call to initializePlsqlContext, so all of the boolean arguments need to be true.)
      --
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
                                        transactionTypeIdIn => transactionTypeIn );
      ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                   transactionIdIn => transactionIdIn,
                                   transactionTypeIdIn => transactionTypeIn);
    exception
      when nullApprRecordFieldException then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                     transactionIdIn => transactionIdIn,
                                     transactionTypeIdIn => transactionTypeIn);
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400814_NULL_SUPPR_APPR_FLD',
                                              tokenNameOneIn => 'APPROVER_REC_PARAMS',
                                              tokenvalueOneIn=>appr_rec_params);
          errorCode := -20001;
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'clearSuppression',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
      when others then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                     transactionIdIn => transactionIdIn,
                                     transactionTypeIdIn => transactionTypeIn);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'clearSuppression',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
  end clearSuppression;
  procedure clearSuppressions(applicationIdIn in integer,
                              transactionTypeIn in varchar2,
                              transactionIdIn in varchar2) as
    ameAppId integer;
    begin
      ame_engine.lockTransaction(fndApplicationIdIn => applicationIdIn,
                                 transactionIdIn => transactionIdIn,
                                 transactionTypeIdIn => transactionTypeIn);
      ameAppId := ame_admin_pkg.getApplicationId(fndAppIdIn => applicationIdIn,
                                                 transactionTypeIdIn => transactionTypeIn);
      delete from ame_temp_deletions
        where
          application_id = ameAppId and
          transaction_id = transactionIdIn ;
      if sql%found then
        ame_approver_deviation_pkg.clearDeviationState(
                        applicationIdIn  => ameAppId
                       ,transactionIdIn => transactionIdIn );
      end if;
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
                                        transactionTypeIdIn => transactionTypeIn );
      ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                   transactionIdIn => transactionIdIn,
                                   transactionTypeIdIn => transactionTypeIn);
    exception
      when others then
        ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                     transactionIdIn => transactionIdIn,
                                     transactionTypeIdIn => transactionTypeIn);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'clearSuppressions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
  end clearSuppressions;
  procedure getAllApprovalGroups(groupIdsOut out nocopy ame_util.idList,
                                 groupNamesOut out nocopy ame_util.stringList)  as
    cursor fetchGroupsCursor is
      select approval_group_id, name
        from ame_approval_groups
        where end_date is null
        order by name;
    begin
      open fetchGroupsCursor;
      fetch fetchGroupsCursor bulk collect
        into
          groupIdsOut,
          groupNamesOut;
      close fetchGroupsCursor;
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getAllApprovalGroups',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
        raise;
  end getAllApprovalGroups;
  procedure getApplicableRules1(applicationIdIn in integer,
                                transactionIdIn in varchar2,
                                transactionTypeIn in varchar2,
                                ruleIdsOut out nocopy ame_util.idList) as
    ruleDescriptions ame_util.stringList;
    productionFunctionality ame_util.stringType;
    processProductionRules boolean;
    begin
      productionFunctionality := ame_util.getConfigVar
        (variableNameIn    => ame_util.productionConfigVar
        ,applicationIdIn   => ame_admin_pkg.getApplicationId
           (fndAppIdIn            => applicationIdIn
           ,transactionTypeIdIn   => transactionTypeIn
           )
        );
      if productionFunctionality in (ame_util.noProductions, ame_util.perApproverProductions) then
        processProductionRules := false;
      else
        processProductionRules := true;
      end if;
      ame_engine.updateTransactionState(isTestTransactionIn => false,
                                        isLocalTransactionIn => false,
                                        fetchConfigVarsIn => true,
                                        fetchOldApproversIn => true,
                                        fetchInsertionsIn => true,
                                        fetchDeletionsIn => true,
                                        fetchAttributeValuesIn => true,
                                        fetchInactiveAttValuesIn => false,
                                        processProductionActionsIn => false,
                                        processProductionRulesIn => processProductionRules,
                                        updateCurrentApproverListIn => true,
                                        updateOldApproverListIn => true,
                                        processPrioritiesIn => true,
                                        prepareItemDataIn => false,
                                        prepareRuleIdsIn => true,
                                        prepareRuleDescsIn => false,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      ame_engine.getApplicableRules
        (ruleIdsOut          => ruleIdsOut
        ,ruleDescriptionsOut => ruleDescriptions);
    exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getApplicableRules1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getApplicableRules1;
  procedure getApplicableRules2(applicationIdIn in integer,
                                transactionIdIn in varchar2,
                                transactionTypeIn in varchar2,
                                ruleDescriptionsOut out nocopy ame_util.stringList) as
    ruleIds ame_util.idList;
    productionFunctionality ame_util.stringType;
    processProductionRules boolean;
    begin
      productionFunctionality := ame_util.getConfigVar
        (variableNameIn    => ame_util.productionConfigVar
        ,applicationIdIn   => ame_admin_pkg.getApplicationId
           (fndAppIdIn            => applicationIdIn
           ,transactionTypeIdIn   => transactionTypeIn
           )
        );
      if productionFunctionality in (ame_util.noProductions, ame_util.perApproverProductions) then
        processProductionRules := false;
      else
        processProductionRules := true;
      end if;
      ame_engine.updateTransactionState(isTestTransactionIn => false,
                                        isLocalTransactionIn => false,
                                        fetchConfigVarsIn => true,
                                        fetchOldApproversIn => true,
                                        fetchInsertionsIn => true,
                                        fetchDeletionsIn => true,
                                        fetchAttributeValuesIn => true,
                                        fetchInactiveAttValuesIn => false,
                                        processProductionActionsIn => false,
                                        processProductionRulesIn => processProductionRules,
                                        updateCurrentApproverListIn => true,
                                        updateOldApproverListIn => true,
                                        processPrioritiesIn => true,
                                        prepareItemDataIn => false,
                                        prepareRuleIdsIn => true,
                                        prepareRuleDescsIn => true,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      ame_engine.getApplicableRules
        (ruleIdsOut          => ruleIds
        ,ruleDescriptionsOut => ruleDescriptionsOut);
    exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getApplicableRules2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
  end getApplicableRules2;
  procedure getApplicableRules3(applicationIdIn in integer,
                                transactionIdIn in varchar2,
                                transactionTypeIn in varchar2,
                                ruleIdsOut out nocopy ame_util.idList,
                                ruleDescriptionsOut out nocopy ame_util.stringList) as
    productionFunctionality ame_util.stringType;
    processProductionRules boolean;
    begin
      productionFunctionality := ame_util.getConfigVar
        (variableNameIn    => ame_util.productionConfigVar
        ,applicationIdIn   => ame_admin_pkg.getApplicationId
           (fndAppIdIn            => applicationIdIn
           ,transactionTypeIdIn   => transactionTypeIn
           )
        );
      if productionFunctionality in (ame_util.noProductions, ame_util.perApproverProductions) then
        processProductionRules := false;
      else
        processProductionRules := true;
      end if;
      ame_engine.updateTransactionState(isTestTransactionIn => false,
                                        isLocalTransactionIn => false,
                                        fetchConfigVarsIn => true,
                                        fetchOldApproversIn => true,
                                        fetchInsertionsIn => true,
                                        fetchDeletionsIn => true,
                                        fetchAttributeValuesIn => true,
                                        fetchInactiveAttValuesIn => false,
                                        processProductionActionsIn => false,
                                        processProductionRulesIn => processProductionRules,
                                        updateCurrentApproverListIn => true,
                                        updateOldApproverListIn => true,
                                        processPrioritiesIn => true,
                                        prepareItemDataIn => false,
                                        prepareRuleIdsIn => true,
                                        prepareRuleDescsIn => true,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn);
      ame_engine.getApplicableRules
        (ruleIdsOut          => ruleIdsOut
        ,ruleDescriptionsOut => ruleDescriptionsOut);
    exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getApplicableRules3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
  end getApplicableRules3;
  procedure getApprovalGroupId(groupNameIn ame_util.stringType,
                               groupIdOut out nocopy number)  as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    begin
      select approval_group_id
        into groupIdOut
        from ame_approval_groups
        where name = groupNameIn
          and end_date is null;
    exception
      when no_data_found then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400453_GROUP_NOT_DEFINED',
                           tokenNameOneIn  => 'APPROVAL_GROUP',
                           tokenValueOneIn => groupNameIn);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getApprovalGroupId',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getApprovalGroupId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
        raise;
  end getApprovalGroupId;
  procedure getAttributeValue( applicationIdIn in number,
                               transactionTypeIn in varchar2,
                               transactionIdIn in varchar2,
                               attributeNameIn in varchar2,
                               itemIdIn in varchar2,
                               attributeValue1Out out nocopy varchar2,
                               attributeValue2Out out nocopy varchar2,
                               attributeValue3Out out nocopy varchar2) as
    itemId ame_util.stringType;
    begin
      ame_engine.updateTransactionState(isTestTransactionIn => false,
                                        isLocalTransactionIn => false,
                                        fetchConfigVarsIn => false,
                                        fetchOldApproversIn => false,
                                        fetchInsertionsIn => false,
                                        fetchDeletionsIn => false,
                                        fetchAttributeValuesIn => true,
                                        fetchInactiveAttValuesIn => true,
                                        processProductionActionsIn => false,
                                        processProductionRulesIn => false,
                                        updateCurrentApproverListIn => false,
                                        updateOldApproverListIn => false,
                                        processPrioritiesIn => false,
                                        prepareItemDataIn => false,
                                        prepareRuleIdsIn => false,
                                        prepareRuleDescsIn => false,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      /* In case no itemId is passed in, assume it belongs to the header itemClass and
         pass in the transactionIdIn */
      if itemIdIn is null then
        itemId := transactionIdIn;
      else
        itemId := itemIdIn;
      end if;
      ame_engine.getItemAttValues2(attributeNameIn => attributeNameIn,
                                   itemIdIn => itemId,
                                   attributeValue1Out => attributeValue1Out,
                                   attributeValue2Out => attributeValue2Out,
                                   attributeValue3Out => attributeValue3Out);
    exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getAttributeValue',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getAttributeValue;
   /*
    getAvailableInsertions limits its output to insertions available for the order type orderTypeIn,
    if this is null; otherwise getAvailableInsertions outputs insertions available for all order types.
    Chain-of-authority insertees (those having authority = ame_util.authorityApprover and
    api_insertion = ame_util.apiAuthorityInsertion) must have the approver_category value
    ame_util.approvalApproverCategory.  Ad-hoc insertees may be of either approver category.
  */
  procedure getAvailableInsertions(applicationIdIn in number,
                                   transactionTypeIn in varchar2,
                                   transactionIdIn in varchar2,
                                   positionIn in number,
                                   orderTypeIn in varchar2 default null,
                                   availableInsertionsOut out nocopy ame_util.insertionsTable2) as
    begin
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
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );

      ame_engine.getInsertions
        (positionIn               => positionIn
        ,coaInsertionsYNIn        => ame_util.booleanTrue
        ,orderTypeIn              => orderTypeIn
        ,availableInsertionsOut   => availableInsertionsOut
        );
    exception
      when others then
        ame_util.runtimeException
          (packageNameIn      => 'ame_api3'
          ,routineNameIn      => 'getAvailableInsertions'
          ,exceptionNumberIn  => sqlcode
          ,exceptionStringIn  => sqlerrm
          );
      raise;
  end getAvailableInsertions;
  procedure getConditionDetails(conditionIdIn in integer,
                                attributeNameOut out nocopy varchar2,
                                attributeTypeOut out nocopy varchar2,
                                attributeDescriptionOut out nocopy varchar2,
                                lowerLimitOut out nocopy varchar2,
                                upperLimitOut out nocopy varchar2,
                                includeLowerLimitOut out nocopy varchar2,
                                includeUpperLimitOut out nocopy varchar2,
                                currencyCodeOut out nocopy varchar2,
                                allowedValuesOut out nocopy ame_util.longestStringList) as
    begin
      select
        ame_attributes.name,
        ame_attributes.attribute_type,
        ame_attributes.description,
        ame_conditions.parameter_one,
        ame_conditions.parameter_two,
        ame_conditions.include_lower_limit,
        ame_conditions.include_upper_limit,
        ame_conditions.parameter_three
        into
          attributeNameOut,
          attributeTypeOut,
          attributeDescriptionOut,
          lowerLimitOut,
          upperLimitOut,
          includeLowerLimitOut,
          includeUpperLimitOut,
          currencyCodeOut
        from
          ame_attributes,
          ame_conditions
        where
          ame_attributes.attribute_id = ame_conditions.attribute_id and
          ame_conditions.condition_id = conditionIdIn and
          sysdate between
            ame_attributes.start_date and
            nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
          sysdate between
            ame_conditions.start_date and
            nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate);
      if(attributeTypeOut = ame_util.stringAttributeType) then
        ame_condition_pkg.getStringValueList(conditionIdIn => conditionIdIn,
                                             stringValueListOut => allowedValuesOut);
      end if;
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api3',
                                  routineNameIn => 'getConditionDetails',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
    end getConditionDetails;
  procedure getGroupMembers1(applicationIdIn in number default null,
                             transactionTypeIn in varchar2 default null,
                             transactionIdIn in varchar2 default null,
                             groupIdIn in number,
                             memberDisplayNamesOut out nocopy ame_util.longStringList)as
      cursor groupMemberCursor(groupIdIn in integer) is
        select
          parameter,
          upper(parameter_name),
          query_string,
          decode(parameter_name,
                 ame_util.approverOamGroupId, null,
                 ame_approver_type_pkg.getApproverDisplayName2(orig_system, orig_system_id)) display_name
          from ame_approval_group_members
          where
            approval_group_id = groupIdIn
          order by order_number;
      badDynamicMemberException exception;
      noItemBindException exception;
      dynamicCursor integer;
      colonLocation1 integer;
      colonLocation2 integer;
      displayNames ame_util.longStringList;
      errorCode integer;
      errorMessage ame_util.longestStringType;
      noTransIdDefinedException exception;
      orderNumbers ame_util.idList;
      memberOrigSystem ame_util.stringType;
      memberOrigSystemId number;
      outputIndex integer;
      parameters ame_util.longStringList;
      queryStrings ame_util.longestStringList;
      rowsFound integer;
      tempGroupMembers dbms_sql.Varchar2_Table;
      upperParameterNames ame_util.stringList;
      tempGroupName       ame_util.stringType;
      begin
        open groupMemberCursor(groupIdIn => groupIdIn);
        fetch groupMemberCursor bulk collect
          into
            parameters,
            upperParameterNames,
            queryStrings,
            displayNames;
        close groupMemberCursor;
        outputIndex := 0; /* pre-increment */
        for i in 1 .. parameters.count loop
          if(upperParameterNames(i) = upper(ame_util.approverOamGroupId)) then
            dynamicCursor := dbms_sql.open_cursor;
            dbms_sql.parse(dynamicCursor,
                           ame_util.removeReturns(stringIn => queryStrings(i),
                                                  replaceWithSpaces => true),
                           dbms_sql.native);
            if(instrb(queryStrings(i),
                      ame_util.transactionIdPlaceholder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noTransIdDefinedException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util.transactionIdPlaceholder,
                                     transactionIdIn,
                                     50);
            end if;
            if(instrb(queryStrings(i),
                      ame_util2.itemClassPlaceHolder) > 0)  then
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util2.itemClassPlaceHolder,
                                     ame_util.headerItemClassName,
                                     50);
            end if;
            if (instrb(queryStrings(i),
                      ame_util2.itemIdPlaceHolder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noTransIdDefinedException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util2.itemIdPlaceHolder,
                                     transactionIdIn,
                                     50);
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
                (2) orig_system:orig_system_id:approver_name
            */
            for j in 1 .. tempGroupMembers.count loop
              colonLocation1 := instrb(tempGroupMembers(j), ':', 1, 1);
              colonLocation2 := instrb(tempGroupMembers(j), ':', 1, 2);
              if(colonLocation1 = 0) then
                raise badDynamicMemberException;
              end if;
              outputIndex := outputIndex + 1;
              if(colonLocation2 = 0) then /* first case (old style) */
                memberOrigSystemId :=
                  substrb(tempGroupMembers(j), (instrb(tempGroupMembers(j), ':', 1, 1) + 1));
                if(substrb(upper(tempGroupMembers(j)), 1, (instrb(tempGroupMembers(j), ':', 1, 1) - 1)) =
                   upper(ame_util.approverPersonId)) then
                  memberOrigSystem := ame_util.perOrigSystem;
                elsif (substrb(upper(tempGroupMembers(j)), 1, (instrb(tempGroupMembers(j), ':', 1, 1) - 1)) =
                   upper(ame_util.approverUserId)) then
                  memberOrigSystem := ame_util.fndUserOrigSystem;
                else
                  memberOrigSystem :=
                   substrb(tempGroupMembers(j), 1, (instrb(tempGroupMembers(j), ':', 1, 1)-1));
                  memberOrigSystemId :=
                   substrb(tempGroupMembers(j),instrb(tempGroupMembers(j), ':', 1, 1) + 1);
                end if;
              else
                memberOrigSystem :=
                  substrb(tempGroupMembers(j), 1, (instrb(tempGroupMembers(j), ':', 1, 1)-1));
                memberOrigSystemId :=
                  substrb(tempGroupMembers(j), (instrb(tempGroupMembers(j), ':', 1, 1)+1),
                    (instrb(tempGroupMembers(j), ':', 1, 2)-1));
              end if;
               memberDisplayNamesOut(outputIndex) :=
                     ame_approver_type_pkg.getApproverDisplayName2(
                                     origSystemIn => memberOrigSystem,
                                     origSystemIdIn => memberOrigSystemId);
            end loop;
          else /* Copy the static group into the engGroup caches. */
            outputIndex := outputIndex + 1;
            memberDisplayNamesOut(outputIndex) := displayNames(i);
          end if;
        end loop;
      exception
        when badDynamicMemberException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          memberDisplayNamesOut.delete;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                      messageNameIn => 'AME_400454_GRP_DYN_QRY_ERR');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers1',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when noItemBindException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          memberDisplayNamesOut.delete;
          errorCode := -20001;
          ame_api5.getApprovalGroupName(groupIdIn    => groupIdIn
                                       ,groupNameOut => tempGroupName);
          errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400798_GROUP_ITEM_BIND',
                           tokenNameOneIn  => 'APPROVER_GROUP',
                           tokenValueOneIn => tempGroupName);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers1',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when noTransIdDefinedException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          memberDisplayNamesOut.delete;
          errorCode := -20001;
          ame_api5.getApprovalGroupName(groupIdIn    => groupIdIn
                                       ,groupNameOut => tempGroupName);
          errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400455_GRP_DYN_NULL_TXID',
                           tokenNameOneIn  => 'APPROVAL_GROUP',
                           tokenValueOneIn => tempGroupName);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers1',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          memberDisplayNamesOut.delete;
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
  end getGroupMembers1;
  procedure getGroupMembers2(applicationIdIn in number default null,
                             transactionTypeIn in varchar2 default null,
                             transactionIdIn in varchar2 default null,
                             groupIdIn in number,
                             memberNamesOut out nocopy ame_util.longStringList,
                             memberDisplayNamesOut out nocopy ame_util.longStringList)as
      cursor groupMemberCursor(groupIdIn in integer) is
        select
          parameter,
          upper(parameter_name),
          query_string,
          decode(parameter_name,
                 ame_util.approverOamGroupId, null,
                 ame_approver_type_pkg.getWfRolesName(orig_system, orig_system_id)) approver_name,
          decode(parameter_name,
                 ame_util.approverOamGroupId, null,
                 ame_approver_type_pkg.getApproverDisplayName2(orig_system, orig_system_id)) display_name
          from ame_approval_group_members
          where
            approval_group_id = groupIdIn
          order by order_number;
      badDynamicMemberException exception;
      noItemBindException exception;
      dynamicCursor integer;
      colonLocation1 integer;
      colonLocation2 integer;
      displayNames ame_util.longStringList;
      errorCode integer;
      errorMessage ame_util.longestStringType;
      approverNames ame_util.longStringList;
      memberOrigSystem ame_util.stringType;
      memberOrigSystemId number;
      noTransIdDefinedException exception;
      orderNumbers ame_util.idList;
      origSystemIds ame_util.idList;
      origSystems ame_util.stringList;
      outputIndex integer;
      parameters ame_util.longStringList;
      queryStrings ame_util.longestStringList;
      rowsFound integer;
      tempGroupMembers dbms_sql.Varchar2_Table;
      upperParameterNames ame_util.stringList;
      tempGroupName       ame_util.stringType;
      begin
        open groupMemberCursor(groupIdIn => groupIdIn);
        fetch groupMemberCursor bulk collect
          into
            parameters,
            upperParameterNames,
            queryStrings,
            approverNames,
            displayNames;
        close groupMemberCursor;
        outputIndex := 0; /* pre-increment */
        for i in 1 .. parameters.count loop
          if(upperParameterNames(i) = upper(ame_util.approverOamGroupId)) then
            dynamicCursor := dbms_sql.open_cursor;
            dbms_sql.parse(dynamicCursor,
                           ame_util.removeReturns(stringIn => queryStrings(i),
                                                  replaceWithSpaces => true),
                           dbms_sql.native);
            if(instrb(queryStrings(i),
                      ame_util.transactionIdPlaceholder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noTransIdDefinedException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util.transactionIdPlaceholder,
                                     transactionIdIn,
                                     50);
            end if;
            if(instrb(queryStrings(i),
                      ame_util2.itemClassPlaceHolder) > 0)  then
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util2.itemClassPlaceHolder,
                                     ame_util.headerItemClassName,
                                     50);
            end if;
            if (instrb(queryStrings(i),
                      ame_util2.itemIdPlaceHolder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noTransIdDefinedException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util2.itemIdPlaceHolder,
                                     transactionIdIn,
                                     50);
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
                (2) orig_system:orig_system_id:approver_name
            */
            for j in 1 .. tempGroupMembers.count loop
              colonLocation1 := instrb(tempGroupMembers(j), ':', 1, 1);
              colonLocation2 := instrb(tempGroupMembers(j), ':', 1, 2);
              if(colonLocation1 = 0) then
                raise badDynamicMemberException;
              end if;
              outputIndex := outputIndex + 1;
              if(colonLocation2 = 0) then /* first case (old style) */
                memberOrigSystemId :=
                  substrb(tempGroupMembers(j), (instrb(tempGroupMembers(j), ':', 1, 1) + 1));
                if(substrb(upper(tempGroupMembers(j)), 1, (instrb(tempGroupMembers(j), ':', 1, 1) - 1)) =
                   upper(ame_util.approverPersonId)) then
                  memberOrigSystem := ame_util.perOrigSystem;
                elsif (substrb(upper(tempGroupMembers(j)), 1, (instrb(tempGroupMembers(j), ':', 1, 1) - 1)) =
                   upper(ame_util.approverUserId)) then
                  memberOrigSystem := ame_util.fndUserOrigSystem;
                else
                  memberOrigSystem :=
                   substrb(tempGroupMembers(j), 1, (instrb(tempGroupMembers(j), ':', 1, 1)-1));
                  memberOrigSystemId :=
                   substrb(tempGroupMembers(j),instrb(tempGroupMembers(j), ':', 1, 1) + 1);
                end if;
              else
                memberOrigSystem :=
                  substrb(tempGroupMembers(j), 1, (instrb(tempGroupMembers(j), ':', 1, 1)-1));
                memberOrigSystemId :=
                  substrb(tempGroupMembers(j), (instrb(tempGroupMembers(j), ':', 1, 1)+1),
                    (instrb(tempGroupMembers(j), ':', 1, 2)-1));
              end if;
              ame_approver_type_pkg.getWfRolesNameAndDisplayName(
                origSystemIn => memberOrigSystem,
                origSystemIdIn => memberOrigSystemId,
                nameOut => memberNamesOut(outputIndex),
                displayNameOut => memberDisplayNamesOut(outputIndex));
            end loop;
          else /* Copy the static group into the engGroup caches. */
            outputIndex := outputIndex + 1;
            memberNamesOut(outputIndex) := approverNames(i);
            memberDisplayNamesOut(outputIndex) := displayNames(i);
          end if;
        end loop;
      exception
        when badDynamicMemberException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                      messageNameIn => 'AME_400454_GRP_DYN_QRY_ERR');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers2',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when noTransIdDefinedException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          errorCode := -20001;
          ame_api5.getApprovalGroupName(groupIdIn    => groupIdIn
                                       ,groupNameOut => tempGroupName);
          errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400455_GRP_DYN_NULL_TXID',
                           tokenNameOneIn  => 'APPROVAL_GROUP',
                           tokenValueOneIn => tempGroupName);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers2',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
       when noItemBindException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          memberDisplayNamesOut.delete;
          errorCode := -20001;
          ame_api5.getApprovalGroupName(groupIdIn    => groupIdIn
                                       ,groupNameOut => tempGroupName);
          errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400798_GROUP_ITEM_BIND',
                           tokenNameOneIn  => 'APPROVER_GROUP',
                           tokenValueOneIn => tempGroupName);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers2',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getGroupMembers2;
  procedure getGroupMembers3(applicationIdIn in number default null,
                             transactionTypeIn in varchar2 default null,
                             transactionIdIn in varchar2 default null,
                             groupIdIn in number,
                             memberNamesOut out nocopy ame_util.longStringList,
                             memberOrderNumbersOut out nocopy ame_util.idList,
                             memberDisplayNamesOut out nocopy ame_util.longStringList)as
      cursor groupMemberCursor(groupIdIn in integer) is
        select
          parameter,
          upper(parameter_name),
          query_string,
          order_number,
          decode(parameter_name,
                 ame_util.approverOamGroupId, null,
                 ame_approver_type_pkg.getWfRolesName(orig_system, orig_system_id)) approver_name,
          decode(parameter_name,
                 ame_util.approverOamGroupId, null,
                 ame_approver_type_pkg.getApproverDisplayName2(orig_system, orig_system_id)) display_name
          from ame_approval_group_members
          where
            approval_group_id = groupIdIn
          order by order_number;
      badDynamicMemberException exception;
      noItemBindException exception;
      dynamicCursor integer;
      colonLocation1 integer;
      colonLocation2 integer;
      displayNames ame_util.longStringList;
      errorCode integer;
      errorMessage ame_util.longestStringType;
      approverNames ame_util.longStringList;
      memberOrigSystem ame_util.stringType;
      memberOrigSystemId number;
      noTransIdDefinedException exception;
      orderNumbers ame_util.idList;
      origSystemIds ame_util.idList;
      origSystems ame_util.stringList;
      outputIndex integer;
      parameters ame_util.longStringList;
      queryStrings ame_util.longestStringList;
      rowsFound integer;
      tempGroupMembers dbms_sql.Varchar2_Table;
      upperParameterNames ame_util.stringList;
      tempGroupName       ame_util.stringType;
      begin
        open groupMemberCursor(groupIdIn => groupIdIn);
        fetch groupMemberCursor bulk collect
          into
            parameters,
            upperParameterNames,
            queryStrings,
            orderNumbers,
            approverNames,
            displayNames;
        close groupMemberCursor;
        outputIndex := 0; /* pre-increment */
        for i in 1 .. parameters.count loop
          if(upperParameterNames(i) = upper(ame_util.approverOamGroupId)) then
            dynamicCursor := dbms_sql.open_cursor;
            dbms_sql.parse(dynamicCursor,
                           ame_util.removeReturns(stringIn => queryStrings(i),
                                                  replaceWithSpaces => true),
                           dbms_sql.native);
            if(instrb(queryStrings(i),
                      ame_util.transactionIdPlaceholder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noTransIdDefinedException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util.transactionIdPlaceholder,
                                     transactionIdIn,
                                     50);
            end if;
            if(instrb(queryStrings(i),
                      ame_util2.itemClassPlaceHolder) > 0)  then
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util2.itemClassPlaceHolder,
                                     ame_util.headerItemClassName,
                                     50);
            end if;
            if (instrb(queryStrings(i),
                      ame_util2.itemIdPlaceHolder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noTransIdDefinedException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util2.itemIdPlaceHolder,
                                     transactionIdIn,
                                     50);
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
                (2) orig_system:orig_system_id:approver_name
            */
            for j in 1 .. tempGroupMembers.count loop
              colonLocation1 := instrb(tempGroupMembers(j), ':', 1, 1);
              colonLocation2 := instrb(tempGroupMembers(j), ':', 1, 2);
              if(colonLocation1 = 0) then
                raise badDynamicMemberException;
              end if;
              outputIndex := outputIndex + 1;
              memberOrderNumbersOut(outputIndex) := j;
              if(colonLocation2 = 0) then /* first case (old style) */
                memberOrigSystemId :=
                  substrb(tempGroupMembers(j), (instrb(tempGroupMembers(j), ':', 1, 1) + 1));
                if(substrb(upper(tempGroupMembers(j)), 1, (instrb(tempGroupMembers(j), ':', 1, 1) - 1)) =
                   upper(ame_util.approverPersonId)) then
                memberOrigSystem := ame_util.perOrigSystem;
                elsif (substrb(upper(tempGroupMembers(j)), 1, (instrb(tempGroupMembers(j), ':', 1, 1) - 1)) =
                   upper(ame_util.approverUserId)) then
                  memberOrigSystem := ame_util.fndUserOrigSystem;
                else
                  memberOrigSystem :=
                   substrb(tempGroupMembers(j), 1, (instrb(tempGroupMembers(j), ':', 1, 1)-1));
                  memberOrigSystemId :=
                   substrb(tempGroupMembers(j),instrb(tempGroupMembers(j), ':', 1, 1) + 1);
                end if;
              else
                memberOrigSystem :=
                  substrb(tempGroupMembers(j), 1, (instrb(tempGroupMembers(j), ':', 1, 1)-1));
                memberOrigSystemId :=
                  substrb(tempGroupMembers(j), (instrb(tempGroupMembers(j), ':', 1, 1)+1),
                    (instrb(tempGroupMembers(j), ':', 1, 2)-1));
              end if;
              ame_approver_type_pkg.getWfRolesNameAndDisplayName(
                origSystemIn => memberOrigSystem,
                origSystemIdIn => memberOrigSystemId,
                nameOut => memberNamesOut(outputIndex),
                displayNameOut => memberDisplayNamesOut(outputIndex));
            end loop;
          else /* Copy the static group into the engGroup caches. */
            outputIndex := outputIndex + 1;
            memberOrderNumbersOut(outputIndex) := orderNumbers(i);
            memberNamesOut(outputIndex) := approverNames(i);
            memberDisplayNamesOut(outputIndex) := displayNames(i);
          end if;
        end loop;
      exception
        when badDynamicMemberException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                      messageNameIn => 'AME_400454_GRP_DYN_QRY_ERR');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers3',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when noTransIdDefinedException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          errorCode := -20001;
          ame_api5.getApprovalGroupName(groupIdIn    => groupIdIn
                                       ,groupNameOut => tempGroupName);
          errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400455_GRP_DYN_NULL_TXID',
                           tokenNameOneIn  => 'APPROVAL_GROUP',
                           tokenValueOneIn => tempGroupName);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers3',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
       when noItemBindException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          memberDisplayNamesOut.delete;
          errorCode := -20001;
          ame_api5.getApprovalGroupName(groupIdIn    => groupIdIn
                                       ,groupNameOut => tempGroupName);
          errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400798_GROUP_ITEM_BIND',
                           tokenNameOneIn  => 'APPROVER_GROUP',
                           tokenValueOneIn => tempGroupName);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers3',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
  end getGroupMembers3;
  procedure getGroupMembers4(applicationIdIn in number default null,
                             transactionTypeIn in varchar2 default null,
                             transactionIdIn in varchar2 default null,
                             groupIdIn in number,
                             memberNamesOut out nocopy ame_util.longStringList,
                             memberOrderNumbersOut out nocopy ame_util.idList,
                             memberDisplayNamesOut out nocopy ame_util.longStringList,
                             memberOrigSystemIdsOut out nocopy ame_util.idList,
                             memberOrigSystemsOut out nocopy ame_util.stringList)as
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
                 ame_approver_type_pkg.getWfRolesName(orig_system, orig_system_id)) approver_name,
          decode(parameter_name,
                 ame_util.approverOamGroupId, null,
                 ame_approver_type_pkg.getApproverDisplayName2(orig_system, orig_system_id)) display_name
          from ame_approval_group_members
          where
            approval_group_id = groupIdIn
          order by order_number;
      badDynamicMemberException exception;
      noItemBindException exception;
      dynamicCursor integer;
      colonLocation1 integer;
      colonLocation2 integer;
      displayNames ame_util.longStringList;
      errorCode integer;
      errorMessage ame_util.longestStringType;
      approverNames ame_util.longStringList;
      noTransIdDefinedException exception;
      orderNumbers ame_util.idList;
      origSystemIds ame_util.idList;
      origSystems ame_util.stringList;
      outputIndex integer;
      parameters ame_util.longStringList;
      queryStrings ame_util.longestStringList;
      rowsFound integer;
      tempGroupMembers dbms_sql.Varchar2_Table;
      upperParameterNames ame_util.stringList;
      tempGroupName       ame_util.stringType;
      begin
        open groupMemberCursor(groupIdIn => groupIdIn);
        fetch groupMemberCursor bulk collect
          into
            origSystems,
            origSystemIds,
            parameters,
            upperParameterNames,
            queryStrings,
            orderNumbers,
            approverNames,
            displayNames;
        close groupMemberCursor;
        outputIndex := 0; /* pre-increment */
        for i in 1 .. parameters.count loop
          if(upperParameterNames(i) = upper(ame_util.approverOamGroupId)) then
            dynamicCursor := dbms_sql.open_cursor;
            dbms_sql.parse(dynamicCursor,
                           ame_util.removeReturns(stringIn => queryStrings(i),
                                                  replaceWithSpaces => true),
                           dbms_sql.native);
            if(instrb(queryStrings(i),
                      ame_util.transactionIdPlaceholder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noTransIdDefinedException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util.transactionIdPlaceholder,
                                     transactionIdIn,
                                     50);
            end if;
            if(instrb(queryStrings(i),
                      ame_util2.itemClassPlaceHolder) > 0)  then
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util2.itemClassPlaceHolder,
                                     ame_util.headerItemClassName,
                                     50);
            end if;
            if (instrb(queryStrings(i),
                      ame_util2.itemIdPlaceHolder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noTransIdDefinedException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util2.itemIdPlaceHolder,
                                     transactionIdIn,
                                     50);
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
                (2) orig_system:orig_system_id:approver_name
            */
            for j in 1 .. tempGroupMembers.count loop
              colonLocation1 := instrb(tempGroupMembers(j), ':', 1, 1);
              colonLocation2 := instrb(tempGroupMembers(j), ':', 1, 2);
              if(colonLocation1 = 0) then
                raise badDynamicMemberException;
              end if;
              outputIndex := outputIndex + 1;
              memberOrderNumbersOut(outputIndex) := j;
              if(colonLocation2 = 0) then /* first case (old style) */
                memberOrigSystemIdsOut(outputIndex) :=
                  substrb(tempGroupMembers(j), (instrb(tempGroupMembers(j), ':', 1, 1) + 1));
                if(substrb(upper(tempGroupMembers(j)), 1, (instrb(tempGroupMembers(j), ':', 1, 1) - 1)) =
                   upper(ame_util.approverPersonId)) then
                  memberOrigSystemsOut(outputIndex) := ame_util.perOrigSystem;
                elsif (substrb(upper(tempGroupMembers(j)), 1, (instrb(tempGroupMembers(j), ':', 1, 1) - 1)) =
                   upper(ame_util.approverUserId)) then
                  memberOrigSystemsOut(outputIndex) := ame_util.fndUserOrigSystem;
                else
                  memberOrigSystemsOut(outputIndex) :=
                   substrb(tempGroupMembers(j), 1, (instrb(tempGroupMembers(j), ':', 1, 1)-1));
                  memberOrigSystemIdsOut(outputIndex) :=
                   substrb(tempGroupMembers(j),instrb(tempGroupMembers(j), ':', 1, 1) + 1);
                end if;
              else
                memberOrigSystemsOut(outputIndex) :=
                  substrb(tempGroupMembers(j), 1, (instrb(tempGroupMembers(j), ':', 1, 1)-1));
                memberOrigSystemIdsOut(outputIndex) :=
                  substrb(tempGroupMembers(j), (instrb(tempGroupMembers(j), ':', 1, 1)+1),
                    (instrb(tempGroupMembers(j), ':', 1, 2)-1));
              end if;
              ame_approver_type_pkg.getWfRolesNameAndDisplayName(
                origSystemIn => memberOrigSystemsOut(outputIndex),
                origSystemIdIn => memberOrigSystemIdsOut(outputIndex),
                nameOut => memberNamesOut(outputIndex),
                displayNameOut => memberDisplayNamesOut(outputIndex));
            end loop;
          else /* Copy the static group into the engGroup caches. */
            outputIndex := outputIndex + 1;
            memberNamesOut(outputIndex) := approverNames(i);
            memberOrderNumbersOut(outputIndex) := orderNumbers(i);
            memberDisplayNamesOut(outputIndex) := displayNames(i);
            memberOrigSystemsOut(outputIndex) := origSystems(i);
            memberOrigSystemIdsOut(outputIndex) := origSystemIds(i);
          end if;
        end loop;
      exception
        when badDynamicMemberException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                      messageNameIn => 'AME_400454_GRP_DYN_QRY_ERR');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers4',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when noTransIdDefinedException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          errorCode := -20001;
          ame_api5.getApprovalGroupName(groupIdIn    => groupIdIn
                                       ,groupNameOut => tempGroupName);
          errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400455_GRP_DYN_NULL_TXID',
                           tokenNameOneIn  => 'APPROVAL_GROUP',
                           tokenValueOneIn => tempGroupName);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers4',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when noItemBindException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          memberDisplayNamesOut.delete;
          errorCode := -20001;
          ame_api5.getApprovalGroupName(groupIdIn    => groupIdIn
                                       ,groupNameOut => tempGroupName);
          errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400798_GROUP_ITEM_BIND',
                           tokenNameOneIn  => 'APPROVER_GROUP',
                           tokenValueOneIn => tempGroupName);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers4',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers4',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
  end getGroupMembers4;
  procedure getItemClasses( applicationIdIn in number,
                            transactionTypeIn in varchar2,
                            itemClassIdsOut out nocopy ame_util.idList,
                            itemClassNamesOut out nocopy ame_util.stringList) as
    ameAppId integer;
    begin
      ameAppId := ame_admin_pkg.getApplicationId(fndAppIdIn => applicationIdIn,
                                                 transactionTypeIdIn => transactionTypeIn);
      ame_admin_pkg.getTransTypeItemClasses2(applicationIdIn => ameAppId,
                                            itemClassIdsOut => itemClassIdsOut,
                                            itemClassNamesOut => itemClassNamesOut);
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api3',
                                  routineNameIn => 'getItemClasses',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
    end getItemClasses;
  procedure getItemClassId( itemClassNameIn in varchar2,
                            itemClassIdOut out nocopy number) as
    ameAppId integer;
    begin
      itemClassIdOut := ame_admin_pkg.getItemClassIdByName(itemClassNameIn => itemClassNameIn);
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api3',
                                  routineNameIn => 'getItemClassId',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
  end getItemClassId;
  procedure getItemClassName( itemClassIdIn in number,
                              itemClassNameOut out nocopy varchar2) as
    ameAppId integer;
    begin
      itemClassNameOut := ame_admin_pkg.getItemClassName(itemClassIdIn => itemClassIdIn);
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api3',
                                  routineNameIn => 'getItemClassName',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
    end getItemClassName;
    procedure getApproverDetails(nameIn                in varchar2
                                 ,validityOut          out NOCOPY varchar2
                                 ,displayNameOut       out NOCOPY varchar2
                                 ,origSystemIdOut      out NOCOPY integer
                                 ,origSystemOut        out NOCOPY varchar2 ) as
    begin
      validityOut := 'INVALID';
      select
        display_name,
        orig_system,
        orig_system_id
        into
          displayNameOut,
          origSystemOut,
          origSystemIdOut
        from wf_roles
        where
          name = nameIn and
          status = 'ACTIVE' and
          (expiration_date is null or
            sysdate < expiration_date) and
          rownum < 2;
        validityOut := 'VALID';
      exception
        when no_data_found then
          begin
            select
              display_name,
              orig_system,
              orig_system_id
              into
                displayNameOut,
                origSystemOut,
                origSystemIdOut
              from wf_local_roles
              where
                name = nameIn and
                rownum < 2;
            validityOut := 'INACTIVE';
            exception
              when no_data_found then
                displayNameOut := nameIn;
                origSystemOut  := 'PER';
          end;
    end getApproverDetails;
  procedure getOldApprovers( applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             oldApproversOut out nocopy ame_util.approversTable2) as
    ameAppId integer;
    cursor oldApproverCursor(applicationIdIn in integer,
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
      tempIndex integer;
      l_display_name varchar2(400);
      l_valid varchar2(50);
    begin
      ameAppId := ame_admin_pkg.getApplicationId(fndAppIdIn => applicationIdIn,
                                                 transactionTypeIdIn => transactionTypeIn);
      tempIndex := 0;
      for tempOldApprover in oldApproverCursor(applicationIdIn => ameAppId,
                                               transactionIdIn => transactionIdIn) loop
        tempIndex := tempIndex + 1;
        oldApproversOut(tempIndex).name := tempOldApprover.name;
        oldApproversOut(tempIndex).item_class := tempOldApprover.item_class;
        oldApproversOut(tempIndex).item_id := tempOldApprover.item_id;
        oldApproversOut(tempIndex).approver_category := tempOldApprover.approver_category;
        oldApproversOut(tempIndex).api_insertion := tempOldApprover.api_insertion;
        oldApproversOut(tempIndex).authority := tempOldApprover.authority;
        oldApproversOut(tempIndex).approval_status := tempOldApprover.approval_status;
        oldApproversOut(tempIndex).action_type_id := tempOldApprover.action_type_id;
        oldApproversOut(tempIndex).group_or_chain_id := tempOldApprover.group_or_chain_id;
        oldApproversOut(tempIndex).occurrence := tempOldApprover.occurrence;
        begin
        ame_approver_type_pkg.getApproverOrigSystemAndId
             (nameIn          => tempOldApprover.name
             ,origSystemOut   => oldApproversOut(tempIndex).orig_system
             ,origSystemIdOut => oldApproversOut(tempIndex).orig_system_id);
        exception
          when others then
             getApproverDetails(nameIn => tempOldApprover.name
                                 ,validityOut     => l_valid
                                 ,displayNameOut  => l_display_name
                                 ,origSystemIdOut => oldApproversOut(tempIndex).orig_system_id
                                 ,origSystemOut   => oldApproversOut(tempIndex).orig_system);
            if l_valid = 'INVALID' then
              oldApproversOut(tempIndex).orig_system_id := null;
              oldApproversOut(tempIndex).orig_system := null;
            end if;
        end;
        /*
          The old approver list does not maintain source.  Calling applications requiring
          source data must get it by calling getNextApprover or getAllApprovers.
        */
        oldApproversOut(tempIndex).source := null;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getOldApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          oldApproversOut.delete;
          ame_api2.getAdminApprover(applicationIdIn => applicationIdIn,
                                    transactionTypeIn => transactionTypeIn,
                                    adminApproverOut => oldApproversOut(1));
          raise;
    end getOldApprovers;
  procedure getRuleDetails1( ruleIdIn in number,
                             ruleTypeOut out nocopy varchar2,
                             ruleDescriptionOut out nocopy varchar2,
                             conditionIdsOut out nocopy ame_util.idList,
                             actionTypeNamesOut out nocopy ame_util.stringList,
                             actionTypeDescriptionsOut out nocopy ame_util.stringList,
                             actionDescriptionsOut out nocopy ame_util.stringList) as
    cursor actionCursor is
      select
        ame_action_types.name,
        ame_action_types.description,
        ame_actions.description
      from
        ame_action_usages,
        ame_action_types,
        ame_actions
      where
        ame_action_usages.rule_id = ruleIdIn and
        ame_actions.action_id = ame_action_usages.action_id and
        ame_action_types.action_type_id = ame_actions.action_type_id and
        sysdate between
          ame_action_usages.start_date and
          nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate) and
        sysdate between
          ame_action_types.start_date and
          nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
        sysdate between
          ame_actions.start_date and
          nvl(ame_actions.end_date - ame_util.oneSecond, sysdate);
    cursor conditionCursor(ruleIdIn in integer) is
      select condition_id
      from ame_condition_usages
      where
        ame_condition_usages.rule_id = ruleIdIn and
        sysdate between
          start_date and
          nvl(end_date - ame_util.oneSecond, sysdate);
    cursor ruleCursor is
      select
        ame_rules.rule_type,
        ame_rules.description
      from
        ame_rules
      where
        ame_rules.rule_id = ruleIdIn and
        sysdate between
          ame_rules.start_date and
          nvl(ame_rules.end_date - ame_util.oneSecond, sysdate) ;
    begin
      open ruleCursor;
      fetch ruleCursor into
        ruleTypeOut,
        ruleDescriptionOut;
      close ruleCursor;
      open actionCursor;
      fetch actionCursor bulk collect into
        actionTypeNamesOut,
        actionTypeDescriptionsOut,
        actionDescriptionsOut;
      close actionCursor;
      open conditionCursor(ruleIdIn => ruleIdIn);
      fetch conditionCursor bulk collect
        into conditionIdsOut;
      close conditionCursor;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getRuleDetails1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          conditionIdsOut.delete;
          raise;
    end getRuleDetails1;
  procedure getRuleDetails2( ruleIdIn in number,
                             ruleTypeOut out nocopy varchar2,
                             ruleDescriptionOut out nocopy varchar2,
                             conditionDescriptionsOut out nocopy ame_util.longestStringList,
                             actionTypeNamesOut out nocopy ame_util.stringList,
                             actionTypeDescriptionsOut out nocopy ame_util.stringList,
                             actionDescriptionsOut out nocopy ame_util.stringList) as
    cursor actionCursor is
      select
        ame_action_types.name,
        ame_action_types.description,
        ame_actions.description
      from
        ame_action_usages,
        ame_action_types,
        ame_actions
      where
        ame_action_usages.rule_id = ruleIdIn and
        ame_actions.action_id = ame_action_usages.action_id and
        ame_action_types.action_type_id = ame_actions.action_type_id and
        sysdate between
          ame_action_usages.start_date and
          nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate) and
        sysdate between
          ame_action_types.start_date and
          nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
        sysdate between
          ame_actions.start_date and
          nvl(ame_actions.end_date - ame_util.oneSecond, sysdate);
    cursor conditionCursor(ruleIdIn in integer) is
      select ame_condition_pkg.getDescription(ame_condition_usages.condition_id)
      from ame_condition_usages
      where
        ame_condition_usages.rule_id = ruleIdIn and
        sysdate between
          ame_condition_usages.start_date and
          nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate);
    cursor ruleCursor is
      select
        ame_rules.rule_type,
        ame_rules.description
      from
        ame_rules
      where
        ame_rules.rule_id = ruleIdIn and
        sysdate between
          ame_rules.start_date and
          nvl(ame_rules.end_date - ame_util.oneSecond, sysdate) ;
    begin
      open ruleCursor;
      fetch ruleCursor into
        ruleTypeOut,
        ruleDescriptionOut;
      close ruleCursor;
      open actionCursor;
      fetch actionCursor bulk collect into
        actionTypeNamesOut,
        actionTypeDescriptionsOut,
        actionDescriptionsOut;
      close actionCursor;
      open conditionCursor(ruleIdIn => ruleIdIn);
      fetch conditionCursor bulk collect
        into conditionDescriptionsOut;
      close conditionCursor;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getRuleDetails2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          conditionDescriptionsOut.delete;
          raise;
    end getRuleDetails2;
  procedure getRuleDetails3( ruleIdIn in number,
                             ruleTypeOut out nocopy varchar2,
                             ruleDescriptionOut out nocopy varchar2,
                             conditionIdsOut out nocopy ame_util.idList,
                             conditionDescriptionsOut out nocopy ame_util.longestStringList,
                             conditionHasLOVsOut out nocopy ame_util.charList,
                             actionTypeNamesOut out nocopy ame_util.stringList,
                             actionTypeDescriptionsOut out nocopy ame_util.stringList,
                             actionDescriptionsOut out nocopy ame_util.stringList) as
    cursor actionCursor is
      select
        ame_action_types.name,
        ame_action_types.description,
        ame_actions.description
      from
        ame_action_usages,
        ame_action_types,
        ame_actions
      where
        ame_action_usages.rule_id = ruleIdIn and
        ame_actions.action_id = ame_action_usages.action_id and
        ame_action_types.action_type_id = ame_actions.action_type_id and
        sysdate between
          ame_action_usages.start_date and
          nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate) and
        sysdate between
          ame_action_types.start_date and
          nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
        sysdate between
          ame_actions.start_date and
          nvl(ame_actions.end_date - ame_util.oneSecond, sysdate);
    cursor conditionCursor(ruleIdIn in integer) is
      select
        ame_conditions.condition_id,
        ame_condition_pkg.getDescription(ame_conditions.condition_id),
        decode(ame_attributes.attribute_type,
               ame_util.stringAttributeType, ame_util.booleanTrue,
               /* default */                 ame_util.booleanFalse)
      from
        ame_conditions,
        ame_condition_usages,
        ame_attributes
      where
        ame_condition_usages.rule_id = ruleIdIn and
        ame_conditions.condition_id = ame_condition_usages.condition_id and
        ame_attributes.attribute_id = ame_conditions.attribute_id and
        sysdate between
          ame_condition_usages.start_date and
          nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate) and
        sysdate between
          ame_conditions.start_date and
          nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate) and
        sysdate between
          ame_attributes.start_date and
          nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate);
    cursor ruleCursor is
      select
        ame_rules.rule_type,
        ame_rules.description
      from
        ame_rules
      where
        ame_rules.rule_id = ruleIdIn and
        sysdate between
          ame_rules.start_date and
          nvl(ame_rules.end_date - ame_util.oneSecond, sysdate) ;
    begin
      open ruleCursor;
      fetch ruleCursor into
        ruleTypeOut,
        ruleDescriptionOut;
      close ruleCursor;
      open actionCursor;
      fetch actionCursor bulk collect into
        actionTypeNamesOut,
        actionTypeDescriptionsOut,
        actionDescriptionsOut;
      close actionCursor;
      open conditionCursor(ruleIdIn => ruleIdIn);
      fetch conditionCursor bulk collect
        into
          conditionIdsOut,
          conditionDescriptionsOut,
          conditionHasLOVsOut;
      close conditionCursor;
    exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getRuleDetails3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          conditionDescriptionsOut.delete;
          conditionIdsOut.delete;
          conditionHasLOVsOut.delete;
          raise;
    end getRuleDetails3;
  procedure insertApprover( applicationIdIn in number,
                            transactionTypeIn in varchar2,
                            transactionIdIn in varchar2,
                            approverIn in ame_util.approverRecord2,
                            positionIn in number,
                            insertionIn in ame_util.insertionRecord2) as
    ameApplicationId integer;
    absoluteOrder integer;
    availableInsertions ame_util.insertionsTable2;
    badInsertionTypeException exception;
    badStatusException exception;
    disallowedAuthException exception;
    errorCode integer;
    errorMessage ame_util.longStringType;
    incompatibleApproverException exception;
    insertionOrder integer;
    insertionTypeNotFound boolean;
    noApproverCategoryException exception;
    tempCount integer;
    begin
      /* Validate input data */
      if approverIn.name is null then
        raise ambiguousApproverException;
      end if;
      if insertionIn.item_class is null or
         insertionIn.parameter is null then
       raise incompatibleApproverException;
      end if;
      /* Make sure that the approverIn and insertionsIn relate to the same chain */
      if (approverIn.item_class <> insertionIn.item_class ) or
          (approverIn.item_id <> insertionIn.item_id) or
          (approverIn.action_type_id <> insertionIn.action_type_id) or
          (approverIn.group_or_chain_id <> insertionIn.group_or_chain_id) or
          (approverIn.api_insertion <> insertionIn.api_insertion) or
          (approverIn.authority <> insertionIn.authority) then
        raise incompatibleApproverException;
      end if;
      /* Make sure that the approver catgeory is defined correctly for approver */
      if (( approverIn.approver_category  is null ) or
          ( approverIn.approver_category <> ame_util.approvalApproverCategory and
            approverIn.approver_category <> ame_util.fyiApproverCategory)) then
        raise noApproverCategoryException;
      end if;
      /* Handler ame_util.firstApprover order types specially. */
      if(insertionIn.order_type = ame_util.firstAuthority) then
        ame_api2.setFirstAuthorityApprover(applicationIdIn => applicationIdIn,
                                          transactionTypeIn => transactionTypeIn,
                                          transactionIdIn => transactionIdIn,
                                          approverIn => approverIn,
                                          clearChainStatusYNIn => ame_util.booleanFalse);
        return;
      end if;
      /* Make sure approverIn.approval_status is null. */
      if(approverIn.approval_status is not null) then
        raise badStatusException;
      end if;
      /* Make sure approverIn.api_insertion is of the right type. */
      if(approverIn.api_insertion = ame_util.oamGenerated) then
        raise badInsertionTypeException;
      end if;
      /* Lock Transactions */
      ame_engine.lockTransaction(fndApplicationIdIn => applicationIdIn,
                                 transactionIdIn => transactionIdIn,
                                 transactionTypeIdIn => transactionTypeIn);
      /*
        Check that only allowed insertion-order and approver-type values are passed, by calling
        getAvailableInsertions and comparing values.
      */
      getAvailableInsertions(applicationIdIn => applicationIdIn,
                             transactionTypeIn => transactionTypeIn,
                             transactionIdIn => transactionIdIn,
                             positionIn => positionIn,
                             orderTypeIn =>  insertionIn.order_type,
                             availableInsertionsOut => availableInsertions);
      tempCount := availableInsertions.count;
      insertionTypeNotFound := true;
      /* Check if insertionIn is a valid insertion in availableInsertions */
      for i in 1 .. tempCount loop
        if(availableInsertions(i).order_type = insertionIn.order_type and
           availableInsertions(i).parameter = insertionIn.parameter and
           availableInsertions(i).api_insertion = insertionIn.api_insertion and
           availableInsertions(i).authority = insertionIn.authority) then
          insertionTypeNotFound := false;
          exit;
        end if;
      end loop;
      if(insertionTypeNotFound) then
        raise badInsertionTypeException;
      end if;
      /* Perform the insertion. */
      insertionOrder := ame_engine.getNextInsertionOrder;
      ameApplicationId := ame_engine.getAmeApplicationId;
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
          insertionOrder,
          insertionIn.order_type,
          insertionIn.parameter,
          insertionIn.description,
          approverIn.name,
          approverIn.item_class,
          approverIn.item_id,
          approverIn.approver_category,
          insertionIn.api_insertion,
          insertionIn.authority,
          sysdate,
          ame_approver_deviation_pkg.insertReason
          );
      /* Cycle the engine to account for changes in the insertions table. */
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
                                        transactionTypeIdIn => transactionTypeIn );
      ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                   transactionIdIn => transactionIdIn,
                                   transactionTypeIdIn => transactionTypeIn);
      exception
        when ambiguousApproverException then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          errorCode := -20001;
          errorMessage :=   ambiguousApproverMessage;
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                  routineNameIn => 'insertApprover',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when badInsertionTypeException then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400240_API_INV_ORDER_TYPE');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                  routineNameIn => 'insertApprover',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when badStatusException then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400241_API_NON_NULL_INSAPP');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                  routineNameIn => 'insertApprover',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when incompatibleApproverException then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                         messageNameIn => 'AME_400446_INCMPTBLE_APPR_INS');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                  routineNameIn => 'insertApprover',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when noApproverCategoryException then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                         messageNameIn => 'AME_400447_INVALID_APPR_CATG');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                  routineNameIn => 'insertApprover',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                  routineNameIn => 'insertApprover',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
          raise;
  end insertApprover;
  procedure parseApproverSource(approverSourceIn in varchar2,
                                sourceDescriptionOut out nocopy varchar2,
                                ruleIdListOut out nocopy ame_util.idList) as
  begin
    ame_util.parseSourceValue(sourceValueIn => approverSourceIn,
                              sourceDescriptionOut => sourceDescriptionOut,
                              ruleIdListOut => ruleIdListOut);
  end parseApproverSource;
    procedure suppressApprover(applicationIdIn in number,
                           transactionTypeIn in varchar2,
                           transactionIdIn in varchar2,
                           approverIn in ame_util.approverRecord2) as
    ameApplicationId integer;
    approverIndex integer;
    approvers ame_util.approversTable2;
    allowDeletingOamApprovers ame_util.attributeValueType;
    badDeletionException exception;
    errorCode integer;
    errorMessage ame_util.longStringType;
    noMatchException exception;
    orderTypeLocation integer;
    parameterLocation integer;
    ruleIdList ame_util.idList;
    sourceDescription ame_util.stringType;
    sourceLength integer;
    tempOrderType ame_temp_insertions.order_type%type;
    tempParameter ame_temp_insertions.parameter%type;
    upperLimit integer;
    cursor getAnchorInsertions (parameterIn varchar2) is
      (select name
         from ame_temp_insertions
        where application_id = ame_engine.getAmeApplicationId
          and transaction_id = transactionIdIn
          and parameter = parameterIn);
    nameList       ame_util.longStringList;
    anchorsExistException exception;
    cmpParameter ame_temp_insertions.parameter%type;
    anchorName varchar2(320);
    anchorList varchar2(1000);
    appr_rec_params varchar2(100);
    nullApprRecordFieldException Exception;
    begin
      ame_engine.lockTransaction(fndApplicationIdIn => applicationIdIn,
                                 transactionIdIn => transactionIdIn,
                                 transactionTypeIdIn => transactionTypeIn);
       appr_rec_params:=null;
       if(approverIn.name is null) then
         appr_rec_params := 'name ';
       end if;
       if approverIn.item_class is null then
         appr_rec_params := appr_rec_params || ', item_class ';
       end if;
       if approverIn.item_id is null then
         appr_rec_params := appr_rec_params || ', item_id ';
       end if;
       if approverIn.action_type_id is null then
         appr_rec_params := appr_rec_params || ', action_type_id ';
       end if;
       if approverIn.group_or_chain_id is null then
         appr_rec_params := appr_rec_params || ', group_or_chain_id ';
       end if;
       if appr_rec_params is not null then
               raise nullApprRecordFieldException;
       end if;
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
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      /* Try to match the approver. */
      ame_engine.getApprovers(approversOut => approvers);
      upperLimit := approvers.count;
      approverIndex := null;
      for i in 1 .. upperLimit loop
        if((approvers(i).approval_status is null or
            approvers(i).approval_status in
              (ame_util.exceptionStatus,
               ame_util.noResponseStatus,
               ame_util.notifiedStatus,
               ame_util.rejectStatus)) and
            ame_engine.approversMatch(approverRecord1In => approverIn,
                                      approverRecord2In => approvers(i))) then
          approverIndex := i;
          if approvers(approverIndex).api_insertion = ame_util.apiInsertion then
            anchorName := approvers(i).name;
            cmpParameter := approvers(i).name ||
                            ame_util.fieldDelimiter ||
                            approvers(i).item_class ||
                            ame_util.fieldDelimiter ||
                            approvers(i).item_id ||
                            ame_util.fieldDelimiter ||
                            approvers(i).action_type_id ||
                            ame_util.fieldDelimiter ||
                            approvers(i).group_or_chain_id ||
                            ame_util.fieldDelimiter ||
                            approvers(i).occurrence;
            open getAnchorInsertions(cmpParameter);
            fetch getAnchorInsertions bulk collect into nameList;
            if nameList.count > 0 then
              close getAnchorInsertions;
              raise anchorsExistException;
            end if;
            close getAnchorInsertions;
          end if;
          exit;
        end if;
      end loop;
      -- If there is no match, raise an exception.
      if(approverIndex is null) then
        raise noMatchException;
      end if;
      ameApplicationId := ame_engine.getAmeApplicationId;
      -- parse the source to see if the approver was inserted.
      ame_util.parseSourceValue(sourceValueIn => approvers(approverIndex).source,
                                sourceDescriptionOut => sourceDescription,
                                ruleIdListOut => ruleIdList);
      -- If the approver was inserted, delete the approver from ame_temp_insertions.
      -- If the approver was OAM generated, check whether deleting OAM-generated approvers
      -- is allowed.  If so, record the deletion.
      --
      if(approvers(approverIndex).api_insertion = ame_util.oamGenerated or
         sourceDescription = ame_util.ruleGeneratedSource or
         sourceDescription = ame_util.surrogateSource)  then
        allowDeletingOamApprovers :=
          ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.allowDeletingOamApprovers);
        if(allowDeletingOamApprovers <> ame_util.booleanAttributeTrue) then
                                  raise badDeletionException;
        end if;
        insert into ame_temp_deletions(
          transaction_id,
          application_id,
          name,
          item_class,
          item_id,
          approver_category,
          action_type_id,
          group_or_chain_id,
          occurrence,
          effective_date,
          reason) values(
            transactionIdIn,
            ameApplicationId,
            approvers(approverIndex).name,
            approvers(approverIndex).item_class,
            approvers(approverIndex).item_id,
            approvers(approverIndex).approver_category,
            approvers(approverIndex).action_type_id,
            approvers(approverIndex).group_or_chain_id,
            approvers(approverIndex).occurrence,
            sysdate,
            ame_approver_deviation_pkg.suppressReason
            );
      else
        for i in 1 .. approvers.count loop
          if approvers(i).name = approverIn.name and
             approvers(i).item_class = approverIn.item_class and
             approvers(i).item_id = approverIn.item_id then
            ame_engine.updateInsertions(indexIn => i);
          end if;
        end loop;
        delete from ame_temp_insertions
          where
            application_id = ameApplicationId and
            transaction_id = transactionIdIn and
            name = approvers(approverIndex).name and
            item_class = approvers(approverIndex).item_class and
            item_id = approvers(approverIndex).item_id ;
      end if;
      -- Cycle the engine to account for changes in the deletions table.
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
                                        transactionTypeIdIn => transactionTypeIn );
      ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                   transactionIdIn => transactionIdIn,
                                   transactionTypeIdIn => transactionTypeIn);
    exception
      when anchorsExistException then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          anchorList := '';
          for i in 1 .. nameList.count loop
            anchorList := anchorList || ame_approver_type_pkg.getApproverDescription(nameList(i));
            if i <> nameList.count then
              anchorList := anchorList || '; ';
            end if;
          end loop;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400651_ANCHORS_EXIST',
                                              tokenNameOneIn => 'APPROVER',
                                              tokenValueOneIn => ame_approver_type_pkg.getApproverDescription(anchorName),
                                              tokenNameTwoIn => 'ANCHORED_APPROVERS',
                                              tokenValueTwoIn => anchorList);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'suppressApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
      when nullApprRecordFieldException then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400814_NULL_SUPPR_APPR_FLD',
                                              tokenNameOneIn => 'APPROVER_REC_PARAMS',
                                              tokenValueOneIn=>appr_rec_params);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'suppressApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
      when badDeletionException then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400236_API_ADRGA_TRUE');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'suppressApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
      when noMatchException then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400237_API_NO MATCH_APPR');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'suppressApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
      when others then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'suppressApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
         raise;
    end suppressApprover;
  procedure suppressApprovers(applicationIdIn in integer,
                            transactionTypeIn in varchar2,
                            transactionIdIn in varchar2,
                            approversIn in ame_util.approversTable2) as
    currentApproverInIndex integer;
    lastApproverInIndex integer;
    nextApproverInIndex integer;
    begin
      lastApproverInIndex := approversIn.last;
      currentApproverInIndex := approversIn.first;
      --
      -- This procedure should always depend on suppressApprovers, so that we don't need to repeat its
      -- error-checking logic here.
      --
      loop
        suppressApprover(applicationIdIn => applicationIdIn,
                       transactionIdIn => transactionIdIn,
                       approverIn => approversIn(currentApproverInIndex),
                       transactionTypeIn => transactionTypeIn);
        if(currentApproverInIndex = lastApproverInIndex) then
          exit;
        end if;
        currentApproverInIndex := approversIn.next(currentApproverInIndex);
      end loop;
    exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'suppressApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
  end suppressApprovers;
end ame_api3;

/
