--------------------------------------------------------
--  DDL for Package Body AME_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_API2" as
/* $Header: ameeapi2.pkb 120.8 2007/12/12 12:33:52 prasashe noship $ */
  ambiguousApproverException exception;
  ambiguousApproverMessage constant ame_util.longestStringType :=
    ame_util.getMessage(applicationShortNameIn =>'PER',
      messageNameIn => 'AME_400812_NULL_APPR_REC_NAME');
      /* functions */
  function validateApprover(approverIn in ame_util.approverRecord2)
           return boolean as
      tempCount integer;
    begin
      /* Just check if the employee is current. */
      if approverIn.name is null then
        return(false);
      end if;
      select count(*)
        into tempCount
        from wf_roles
       where name = approverIn.name and
             status = 'ACTIVE' and
             (expiration_date is null or
              sysdate < expiration_date ) ;  /* Don't use tempEffectiveRuleDate here. */
      if(tempCount = 0) then
        return(false);
      end if;
      return(true);
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'validateApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
        raise;
        return(false);
    end validateApprover;
  /* procedures */
  procedure clearAllApprovals(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2)as
    ameAppId integer;
    begin
      ame_engine.lockTransaction(fndApplicationIdIn => applicationIdIn,
                                 transactionIdIn => transactionIdIn,
                                 transactionTypeIdIn => transactionTypeIn);
      ameAppId := ame_admin_pkg.getApplicationId(fndAppIdIn => applicationIdIn,
                                                 transactionTypeIdIn => transactionTypeIn);
      delete from ame_temp_old_approver_lists
        where
          application_id = ameAppId and
          transaction_id = transactionIdIn;
      delete from ame_temp_insertions
        where
          application_id = ameAppId and
          transaction_id = transactionIdIn;
      delete from ame_temp_deletions
        where
          application_id = ameAppId and
          transaction_id = transactionIdIn;
      /* update all existing history rows from the Approval Notification History table
         to indicate the rows were cleared */
      update AME_TRANS_APPROVAL_HISTORY  set
        date_cleared = sysdate
        where
          application_id = ameAppId and
          transaction_id = transactionIdIn
          and date_cleared is null;
      ame_approver_deviation_pkg.clearDeviationState(
                        applicationIdIn  => ameAppId
                       ,transactionIdIn => transactionIdIn );
      ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                   transactionIdIn => transactionIdIn,
                                   transactionTypeIdIn => transactionTypeIn);
    exception
      when others then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'clearAllApprovals',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end clearAllApprovals;
  procedure getAdminApprover(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             adminApproverOut out nocopy ame_util.approverRecord2)as
    badAdminApproverException exception;
    configVarValue ame_config_vars.variable_value%type;
    configVarLength integer;
    errorCode integer;
    errorMessage ame_util.longStringType;
    tempAmeApplicationId integer;
    begin
      if ( applicationIdIn is null or transactionTypeIn is null) then
        adminApproverOut.name := ame_util.getAdminName;
      else
        select application_id
          into tempAmeApplicationId
          from ame_calling_apps
         where fnd_application_id = applicationIdIn  and
               transaction_type_id = transactionTypeIn and
               sysdate between start_date and
                   nvl(end_date - ame_util.oneSecond, sysdate);
        adminApproverOut.name := ame_util.getAdminName(applicationIdIn => tempAmeApplicationId);
      end if;
      ame_approver_type_pkg.getApproverOrigSystemAndId(nameIn =>adminApproverOut.name,
                                                  origSystemOut => adminApproverOut.orig_system,
                                                  origSystemIdOut => adminApproverOut.orig_system_id);
      adminApproverOut.approval_status := ame_util.exceptionStatus;
      adminApproverOut.item_class := null;
      adminApproverOut.item_id := null;
      adminApproverOut.item_class_order_number := null;
      adminApproverOut.item_order_number := null;
      adminApproverOut.sub_list_order_number := null;
      adminApproverOut.action_type_order_number := null;
      adminApproverOut.group_or_chain_order_number := null;
      adminApproverOut.member_order_number := null;
      adminApproverOut.approver_category := null;
      adminApproverOut.authority := null;
      adminApproverOut.api_insertion := null;
      adminApproverOut.source := null;
      adminApproverOut.action_type_id := null;
      adminApproverOut.group_or_chain_id := null;
      adminApproverOut.occurrence := null;
      exception
        when badAdminApproverException then
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn =>'PER',
                              messageNameIn => 'AME_400238_API_NO_DEF_ADM_CNFG');
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getAdminApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          adminApproverOut.name := null;
          adminApproverOut.approval_status := ame_util.exceptionStatus;
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getAdminApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          adminApproverOut.name := null;
          adminApproverOut.approval_status := ame_util.exceptionStatus;
          raise;
    end getAdminApprover;
  procedure getAllApprovers1(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approvalProcessCompleteYNOut out nocopy varchar2,
                             approversOut out nocopy ame_util.approversTable2,
                             itemIndexesOut out nocopy ame_util.idList,
                             itemClassesOut out nocopy ame_util.stringList,
                             itemIdsOut out nocopy ame_util.stringList,
                             itemSourcesOut out nocopy ame_util.longStringList)as
    begin
      ame_engine.updateTransactionState(isTestTransactionIn    => false
                                       ,isLocalTransactionIn   => false
                                       ,fetchConfigVarsIn      => true
                                       ,fetchOldApproversIn    => true
                                       ,fetchInsertionsIn      => true
                                       ,fetchDeletionsIn       => true
                                       ,fetchAttributeValuesIn => true
                                       ,fetchInactiveAttValuesIn    => false
                                       ,processProductionActionsIn  => false
                                       ,processProductionRulesIn    => false
                                       ,updateCurrentApproverListIn => true
                                       ,updateOldApproverListIn     => false
                                       ,processPrioritiesIn   => true
                                       ,prepareItemDataIn     => true
                                       ,prepareRuleIdsIn      => false
                                       ,prepareRuleDescsIn    => false
                                       ,prepareApproverTreeIn => true
                                       ,transactionIdIn     => transactionIdIn
                                       ,ameApplicationIdIn  => null
                                       ,fndApplicationIdIn  => applicationIdIn
                                       ,transactionTypeIdIn => transactionTypeIn );
      approvalProcessCompleteYNOut := ame_engine.getApprovalProcessCompleteYN;
      ame_engine.getApprovers(approversOut => approversOut);
      ame_engine.getItemIndexes(itemIndexesOut => itemIndexesOut);
      ame_engine.getItemIds(itemIdsOut => itemIdsOut);
      ame_engine.getItemClasses(itemClassesOut => itemClassesOut);
      ame_engine.getItemSources(itemSourcesOut => itemSourcesOut);
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getAllApprovers1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          approversOut.delete;
          raise;
    end getAllApprovers1;
  procedure getAllApprovers2(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approvalProcessCompleteYNOut out nocopy varchar2,
                             approversOut out nocopy ame_util.approversTable2,
                             itemIndexesOut out nocopy ame_util.idList,
                             itemClassesOut out nocopy ame_util.stringList,
                             itemIdsOut out nocopy ame_util.stringList,
                             itemSourcesOut out nocopy ame_util.longStringList,
                             productionIndexesOut out nocopy ame_util.idList,
                             variableNamesOut out nocopy ame_util.stringList,
                             variableValuesOut out nocopy ame_util.stringList)as
    begin
      ame_engine.updateTransactionState(isTestTransactionIn => false,
                                        isLocalTransactionIn => false,
                                        fetchConfigVarsIn => true,
                                        fetchOldApproversIn => true,
                                        fetchInsertionsIn => true,
                                        fetchDeletionsIn => true,
                                        fetchAttributeValuesIn => true,
                                        fetchInactiveAttValuesIn => false,
                                        processProductionActionsIn => true,
                                        processProductionRulesIn => false,
                                        updateCurrentApproverListIn => true,
                                        updateOldApproverListIn => false,
                                        processPrioritiesIn => true,
                                        prepareItemDataIn => true,
                                        prepareRuleIdsIn => false,
                                        prepareRuleDescsIn => false,
                                        prepareApproverTreeIn => true,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      approvalProcessCompleteYNOut := ame_engine.getApprovalProcessCompleteYN;
      ame_engine.getApprovers(approversOut => approversOut);
      ame_engine.getItemIndexes(itemIndexesOut => itemIndexesOut);
      ame_engine.getItemIds(itemIdsOut => itemIdsOut);
      ame_engine.getItemClasses(itemClassesOut => itemClassesOut);
      ame_engine.getItemSources(itemSourcesOut => itemSourcesOut);
      ame_engine.getProductionIndexes(productionIndexesOut => productionIndexesOut);
      ame_engine.getVariableNames(variableNamesOut=> variableNamesOut);
      ame_engine.getVariableValues(variableValuesOut => variableValuesOut);
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getAllApprovers2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          approversOut.delete;
          raise;
    end getAllApprovers2;
    procedure getAllApprovers3(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approvalProcessCompleteYNOut out nocopy varchar2,
                             approversOut out nocopy ame_util.approversTable2,
                             itemIndexesOut out nocopy ame_util.idList,
                             itemClassesOut out nocopy ame_util.stringList,
                             itemIdsOut out nocopy ame_util.stringList,
                             itemSourcesOut out nocopy ame_util.longStringList,
                             productionIndexesOut out nocopy ame_util.idList,
                             variableNamesOut out nocopy ame_util.stringList,
                             variableValuesOut out nocopy ame_util.stringList,
                             transVariableNamesOut out nocopy ame_util.stringList,
                             transVariableValuesOut out nocopy ame_util.stringList)as
    begin
      ame_engine.updateTransactionState(isTestTransactionIn => false,
                                        isLocalTransactionIn => false,
                                        fetchConfigVarsIn => true,
                                        fetchOldApproversIn => true,
                                        fetchInsertionsIn => true,
                                        fetchDeletionsIn => true,
                                        fetchAttributeValuesIn => true,
                                        fetchInactiveAttValuesIn => false,
                                        processProductionActionsIn => true,
                                        processProductionRulesIn => true,
                                        updateCurrentApproverListIn => true,
                                        updateOldApproverListIn => false,
                                        processPrioritiesIn => true,
                                        prepareItemDataIn => true,
                                        prepareRuleIdsIn => false,
                                        prepareRuleDescsIn => false,
                                        prepareApproverTreeIn => true,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      approvalProcessCompleteYNOut := ame_engine.getApprovalProcessCompleteYN;
      ame_engine.getApprovers(approversOut => approversOut);
      ame_engine.getItemIndexes(itemIndexesOut => itemIndexesOut);
      ame_engine.getItemIds(itemIdsOut => itemIdsOut);
      ame_engine.getItemClasses(itemClassesOut => itemClassesOut);
      ame_engine.getItemSources(itemSourcesOut => itemSourcesOut);
      ame_engine.getProductionIndexes(productionIndexesOut => productionIndexesOut);
      ame_engine.getVariableNames(variableNamesOut=> variableNamesOut);
      ame_engine.getVariableValues(variableValuesOut => variableValuesOut);
      ame_engine.getTransVariableNames(transVariableNamesOut => transVariableNamesOut);
      ame_engine.getTransVariableValues(transVariableValuesOut => transVariableValuesOut);
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getAllApprovers3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          approversOut.delete;
          raise;
    end getAllApprovers3;
  procedure getAllApprovers4(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approvalProcessCompleteYNOut out nocopy varchar2,
                             approversOut out nocopy ame_util.approversTable2,
                             itemIndexesOut out nocopy ame_util.idList,
                             itemClassesOut out nocopy ame_util.stringList,
                             itemIdsOut out nocopy ame_util.stringList,
                             itemSourcesOut out nocopy ame_util.longStringList,
                             ruleIndexesOut out nocopy ame_util.idList,
                             sourceTypesOut out nocopy ame_util.stringList,
                             ruleIdsOut out nocopy ame_util.idList)as
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
                                        prepareItemDataIn => true,
                                        prepareRuleIdsIn => true,
                                        prepareRuleDescsIn => false,
                                        prepareApproverTreeIn => true,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      approvalProcessCompleteYNOut := ame_engine.getApprovalProcessCompleteYN;
      ame_engine.getApprovers(approversOut => approversOut);
      ame_engine.getItemIndexes(itemIndexesOut => itemIndexesOut);
      ame_engine.getItemIds(itemIdsOut => itemIdsOut);
      ame_engine.getItemClasses(itemClassesOut => itemClassesOut);
      ame_engine.getItemSources(itemSourcesOut => itemSourcesOut);
      ame_engine.getRuleIndexes(ruleIndexesOut => ruleIndexesOut);
      ame_engine.getSourceTypes(sourceTypesOut => sourceTypesOut);
      ame_engine.getRuleIds(ruleIdsOut => ruleIdsOut);
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getAllApprovers4',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          approversOut.delete;
          raise;
    end getAllApprovers4;
  procedure getAllApprovers5(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approvalProcessCompleteYNOut out nocopy varchar2,
                             approversOut out nocopy ame_util.approversTable2,
                             itemIndexesOut out nocopy ame_util.idList,
                             itemClassesOut out nocopy ame_util.stringList,
                             itemIdsOut out nocopy ame_util.stringList,
                             itemSourcesOut out nocopy ame_util.longStringList,
                             ruleIndexesOut out nocopy ame_util.idList,
                             sourceTypesOut out nocopy ame_util.stringList,
                             ruleDescriptionsOut out nocopy ame_util.stringList) as
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
                                        prepareItemDataIn => true,
                                        prepareRuleIdsIn => true,
                                        prepareRuleDescsIn => true,
                                        prepareApproverTreeIn => true,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      approvalProcessCompleteYNOut := ame_engine.getApprovalProcessCompleteYN;
      ame_engine.getApprovers(approversOut => approversOut);
      ame_engine.getItemIndexes(itemIndexesOut => itemIndexesOut);
      ame_engine.getItemIds(itemIdsOut => itemIdsOut);
      ame_engine.getItemClasses(itemClassesOut => itemClassesOut);
      ame_engine.getItemSources(itemSourcesOut => itemSourcesOut);
      ame_engine.getRuleIndexes(ruleIndexesOut => ruleIndexesOut);
      ame_engine.getSourceTypes(sourceTypesOut => sourceTypesOut);
      ame_engine.getRuleDescriptions(ruleDescriptionsOut => ruleDescriptionsOut);
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getAllApprovers5',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          approversOut.delete;
          raise;
    end getAllApprovers5;
  procedure getAllApprovers6(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approvalProcessCompleteYNOut out nocopy varchar2,
                             approversOut out nocopy ame_util.approversTable2,
                             itemIndexesOut out nocopy ame_util.idList,
                             itemClassesOut out nocopy ame_util.stringList,
                             itemIdsOut out nocopy ame_util.stringList,
                             itemSourcesOut out nocopy ame_util.longStringList,
                             ruleIndexesOut out nocopy ame_util.idList,
                             sourceTypesOut out nocopy ame_util.stringList,
                             ruleIdsOut out nocopy ame_util.idList,
                             ruleDescriptionsOut out nocopy ame_util.stringList) as
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
                                        prepareItemDataIn => true,
                                        prepareRuleIdsIn => true,
                                        prepareRuleDescsIn => true,
                                        prepareApproverTreeIn => true,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      approvalProcessCompleteYNOut := ame_engine.getApprovalProcessCompleteYN;
      ame_engine.getApprovers(approversOut => approversOut);
      ame_engine.getItemIndexes(itemIndexesOut => itemIndexesOut);
      ame_engine.getItemIds(itemIdsOut => itemIdsOut);
      ame_engine.getItemClasses(itemClassesOut => itemClassesOut);
      ame_engine.getItemSources(itemSourcesOut => itemSourcesOut);
      ame_engine.getRuleIndexes(ruleIndexesOut => ruleIndexesOut);
      ame_engine.getSourceTypes(sourceTypesOut => sourceTypesOut);
      ame_engine.getRuleIds(ruleIdsOut => ruleIdsOut);
      ame_engine.getRuleDescriptions(ruleDescriptionsOut => ruleDescriptionsOut);
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getAllApprovers6',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          approversOut.delete;
          raise;
    end getAllApprovers6;
  procedure getAllApprovers7(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approvalProcessCompleteYNOut out nocopy varchar2,
                             approversOut out nocopy ame_util.approversTable2) as
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
                                        prepareApproverTreeIn => true,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      approvalProcessCompleteYNOut := ame_engine.getApprovalProcessCompleteYN;
      ame_engine.getApprovers(approversOut => approversOut);
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getAllApprovers7',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          approversOut.delete;
          raise;
    end getAllApprovers7;
  procedure getAllItemApprovers1(applicationIdIn in number,
                                 transactionTypeIn in varchar2,
                                 transactionIdIn in varchar2,
                                 itemClassIdIn in number,
                                 itemIdIn in varchar2,
                                 approvalProcessCompleteYNOut out nocopy varchar2,
                                 approversOut out nocopy ame_util.approversTable2) as
    approverCount integer;
    approvers ame_util.approversTable2;
    errorCode integer;
    errorMessage ame_util.longStringType;
    invalidItemClassIdException exception;
    invalidItemException exception;
    itemAppProcessCompleteYN ame_util.charList;
    itemClasses ame_util.stringList;
    itemClassName ame_util.stringType;
    itemIds ame_util.stringList;
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
                                        prepareItemDataIn => true,
                                        prepareRuleIdsIn => false,
                                        prepareRuleDescsIn => false,
                                        prepareApproverTreeIn => true,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      approvalProcessCompleteYNOut := null;
      -- get the approvers
      ame_engine.getApprovers(approversOut => approvers);
      -- get the Item Details
      ame_engine.getAllItemIds(itemIdsOut => itemIds);
      ame_engine.getAllItemClasses(itemClassNamesOut => itemClasses);
      ame_engine.getItemAppProcessCompleteYN(itemAppProcessCompleteYNOut => itemAppProcessCompleteYN);
      --  get item class name
      begin
        itemClassName := ame_engine.getItemClassName(itemClassIdIn => itemClassIdIn);
      exception
        when others then
          raise invalidItemClassIdException;
      end;
      for i in 1 .. itemIds.count  loop
        if (itemIds(i) = itemIdIn)  and
           ( itemClasses(i) = itemClassName)  then
          approvalProcessCompleteYNOut := itemAppProcessCompleteYN(i);
          exit;
        end if;
      end loop;
      if approvalProcessCompleteYNOut is null then
        raise invalidItemException;
      end if;
      -- identify approvers for this item class and Item Id
      approverCount := 0;
      for i in 1..approvers.count loop
        if (approvers(i).item_class = itemClassName   and
           approvers(i).item_id = itemIdIn ) then
          approverCount := approverCount + 1;
          ame_util.copyApproverRecord2(approverRecord2In => approvers(i),
                                       approverRecord2Out => approversOut(approverCount) );
        end if;
      end loop;
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when invalidItemClassIdException then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                    messageNameIn => 'AME_400419_INVALID_IC') ;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getAllItemApprovers1',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          approvalProcessCompleteYNOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
      when invalidItemException then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                             messageNameIn => 'AME_400420_INVALID_ITEM_ID') ;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getAllItemApprovers1',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          approvalProcessCompleteYNOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getAllItemApprovers1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          approversOut.delete;
          raise;
    end getAllItemApprovers1;
  procedure getAllItemApprovers2(applicationIdIn in number,
                                 transactionTypeIn in varchar2,
                                 transactionIdIn in varchar2,
                                 itemClassNameIn in varchar2,
                                 itemIdIn in varchar2,
                                 approvalProcessCompleteYNOut out nocopy varchar2,
                                 approversOut out nocopy ame_util.approversTable2)as
    approverCount integer;
    approvers ame_util.approversTable2;
    errorCode integer;
    errorMessage ame_util.longStringType;
    invalidItemClassIdException exception;
    invalidItemException exception;
    itemAppProcessCompleteYN ame_util.charList;
    itemClasses  ame_util.stringList;
    itemIds ame_util.stringList;
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
                                        prepareItemDataIn => true,
                                        prepareRuleIdsIn => false,
                                        prepareRuleDescsIn => false,
                                        prepareApproverTreeIn => true,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      approvalProcessCompleteYNOut := null;
      -- get the approvers
      ame_engine.getApprovers(approversOut => approvers);
      -- get the Item Details
      ame_engine.getAllItemIds(itemIdsOut => itemIds);
      ame_engine.getAllItemClasses(itemClassNamesOut => itemClasses);
      ame_engine.getItemAppProcessCompleteYN(itemAppProcessCompleteYNOut => itemAppProcessCompleteYN);
      for i in 1 .. itemIds.count  loop
        if (itemIds(i) = itemIdIn)  and
           ( itemClasses(i) = itemClassNameIn)  then
          approvalProcessCompleteYNOut := itemAppProcessCompleteYN(i);
          exit;
        end if;
      end loop;
      if approvalProcessCompleteYNOut is null then
        raise invalidItemException;
      end if;
      -- identify approvers for this item class and Item Id
      approverCount := 0;
      for i in 1..approvers.count loop
        if (approvers(i).item_class = itemClassNameIn  and
           approvers(i).item_id = itemIdIn ) then
          approverCount := approverCount + 1;
          ame_util.copyApproverRecord2(approverRecord2In => approvers(i),
                                       approverRecord2Out => approversOut(approverCount) );
        end if;
      end loop;
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when invalidItemException then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                             messageNameIn => 'AME_400420_INVALID_ITEM_ID') ;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getAllItemApprovers2',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          approvalProcessCompleteYNOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getAllItemApprovers2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          approversOut.delete;
          raise;
    end getAllItemApprovers2;
  procedure getAndRecordAllApprovers(applicationIdIn in number,
                                     transactionTypeIn in varchar2,
                                     transactionIdIn in varchar2,
                                     approvalProcessCompleteYNOut out nocopy varchar2,
                                     approversOut out nocopy ame_util.approversTable2,
                                     itemIndexesOut out nocopy ame_util.idList,
                                     itemClassesOut out nocopy ame_util.stringList,
                                     itemIdsOut out nocopy ame_util.stringList,
                                     itemSourcesOut out nocopy ame_util.longStringList)as
    begin
      ame_engine.lockTransaction(fndApplicationIdIn => applicationIdIn,
                                 transactionIdIn => transactionIdIn,
                                 transactionTypeIdIn => transactionTypeIn);
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
                                        prepareItemDataIn => true,
                                        prepareRuleIdsIn => false,
                                        prepareRuleDescsIn => false,
                                        prepareApproverTreeIn => true,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      approvalProcessCompleteYNOut := ame_engine.getApprovalProcessCompleteYN;
      ame_engine.getApprovers(approversOut => approversOut);
      ame_engine.getItemIndexes(itemIndexesOut => itemIndexesOut);
      ame_engine.getItemClasses(itemClassesOut => itemClassesOut);
      ame_engine.getItemIds(itemIdsOut => itemIdsOut);
      ame_engine.getItemSources(itemSourcesOut => itemSourcesOut);
      ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                   transactionIdIn => transactionIdIn,
                                   transactionTypeIdIn => transactionTypeIn);
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getAndRecordAllApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          approversOut.delete;
          raise;
    end getAndRecordAllApprovers;
  procedure getItemStatus1(applicationIdIn in number,
                           transactionTypeIn in varchar2,
                           transactionIdIn in varchar2,
                           itemClassIdIn in integer,
                           itemIdIn in varchar2,
                           approvalProcessCompleteYNOut out nocopy varchar2)as
    approvers ame_util.approversTable;
    errorCode integer;
    errorMessage ame_util.longStringType;
    invalidItemClassIdException exception;
    invalidItemException exception;
    itemAppProcessCompleteYN ame_util.charList;
    itemClasses ame_util.stringList;
    itemClassName ame_util.stringType;
    itemIds ame_util.stringList;
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
                                        prepareItemDataIn => true,
                                        prepareRuleIdsIn => false,
                                        prepareRuleDescsIn => false,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      approvalProcessCompleteYNOut := null;
      -- get the Item Details
      ame_engine.getAllItemIds(itemIdsOut => itemIds);
      ame_engine.getAllItemClasses(itemClassNamesOut => itemClasses);
      ame_engine.getItemAppProcessCompleteYN(itemAppProcessCompleteYNOut => itemAppProcessCompleteYN);
      --  get item class name
      begin
        itemClassName := ame_engine.getItemClassName(itemClassIdIn => itemClassIdIn);
      exception
        when others then
          raise invalidItemClassIdException;
      end;
      for i in 1 .. itemIds.count  loop
        if (itemIds(i) = itemIdIn)  and
           ( itemClasses(i) = itemClassName)  then
          approvalProcessCompleteYNOut := itemAppProcessCompleteYN(i);
          exit;
        end if;
      end loop;
      if approvalProcessCompleteYNOut is null then
        raise invalidItemException;
      end if;
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when invalidItemClassIdException then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                    messageNameIn => 'AME_400419_INVALID_IC') ;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getItemStatus1',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          approvalProcessCompleteYNOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
      when invalidItemException then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                             messageNameIn => 'AME_400420_INVALID_ITEM_ID') ;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getItemStatus1',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          approvalProcessCompleteYNOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getItemStatus1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          raise;
    end getItemStatus1;
  procedure getItemStatus2(applicationIdIn in number,
                           transactionTypeIn in varchar2,
                           transactionIdIn in varchar2,
                           itemClassNameIn in varchar2,
                           itemIdIn in varchar2,
                           approvalProcessCompleteYNOut out nocopy varchar2)as
    approvers ame_util.approversTable;
    errorCode integer;
    errorMessage ame_util.longStringType;
    invalidItemClassIdException exception;
    invalidItemException exception;
    itemAppProcessCompleteYN ame_util.charList;
    itemClasses ame_util.stringList;
    itemIds ame_util.stringList;
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
                                        prepareItemDataIn => true,
                                        prepareRuleIdsIn => false,
                                        prepareRuleDescsIn => false,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      approvalProcessCompleteYNOut := null;
      -- get the Item Details
      ame_engine.getAllItemIds(itemIdsOut => itemIds);
      ame_engine.getAllItemClasses(itemClassNamesOut => itemClasses);
      ame_engine.getItemAppProcessCompleteYN(itemAppProcessCompleteYNOut => itemAppProcessCompleteYN);
      --  get item class name
      for i in 1 .. itemIds.count  loop
        if (itemIds(i) = itemIdIn)  and
           ( itemClasses(i) = itemClassNameIn)  then
          approvalProcessCompleteYNOut := itemAppProcessCompleteYN(i);
          exit;
        end if;
      end loop;
      if approvalProcessCompleteYNOut is null then
        raise invalidItemException;
      end if;
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when invalidItemClassIdException then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                    messageNameIn => 'AME_400419_INVALID_IC') ;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getItemStatus2',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          approvalProcessCompleteYNOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
      when invalidItemException then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                             messageNameIn => 'AME_400420_INVALID_ITEM_ID') ;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getItemStatus2',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          approvalProcessCompleteYNOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getItemStatus2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          raise;
    end getItemStatus2;
  procedure getItemStatuses(applicationIdIn in number,
                            transactionTypeIn in varchar2,
                            transactionIdIn in varchar2,
                            itemClassNamesOut out nocopy ame_util.stringList,
                            itemIdsOut out nocopy ame_util.stringList,
                            approvalProcessesCompleteYNOut out nocopy ame_util.charList)as
    i number;
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
                                        prepareItemDataIn => true,
                                        prepareRuleIdsIn => false,
                                        prepareRuleDescsIn => false,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      ame_engine.getAllItemIds(itemIdsOut => itemIdsOut);
      ame_engine.getAllItemClasses(itemClassNamesOut => itemClassNamesOut);
      ame_engine.getItemAppProcessCompleteYN(itemAppProcessCompleteYNOut => approvalProcessesCompleteYNOut);
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        for i in 1 .. approvalProcessesCompleteYNOut.count loop
          if approvalProcessesCompleteYNOut(i) = ame_util2.completeFullyApproved
            or approvalProcessesCompleteYNOut(i) = ame_util2.completeNoApprovers then
            approvalProcessesCompleteYNOut(i)  :=  ame_util.booleanTrue;
          else
            approvalProcessesCompleteYNOut(i)  :=  ame_util.booleanFalse;
          end if;
        end loop;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getItemStatuses',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          itemClassNamesOut.delete;
          itemIdsOut.delete;
          approvalProcessesCompleteYNOut.delete;
          raise;
    end getItemStatuses;
  procedure getNextApprovers1(applicationIdIn in number,
                              transactionTypeIn in varchar2,
                              transactionIdIn in varchar2,
                              flagApproversAsNotifiedIn in varchar2 default ame_util.booleanTrue,
                              approvalProcessCompleteYNOut out nocopy varchar2,
                              nextApproversOut out nocopy ame_util.approversTable2,
                              itemIndexesOut out nocopy ame_util.idList,
                              itemClassesOut out nocopy ame_util.stringList,
                              itemIdsOut out nocopy ame_util.stringList,
                              itemSourcesOut out nocopy ame_util.longStringList)as
      dummyIdList         ame_util.idList;
      dummyStringList     ame_util.stringList;
    begin
      ame_engine.getNextApprovers(
            applicationIdIn   => applicationIdIn
           ,transactionTypeIn => transactionTypeIn
           ,transactionIdIn   => transactionIdIn
           ,nextApproversType => 1
           ,flagApproversAsNotifiedIn    => flagApproversAsNotifiedIn
           ,approvalProcessCompleteYNOut => approvalProcessCompleteYNOut
           ,nextApproversOut             => nextApproversOut
           ,itemIndexesOut               => itemIndexesOut
           ,itemClassesOut               => itemClassesOut
           ,itemIdsOut                   => itemIdsOut
           ,itemSourcesOut               => itemSourcesOut
           ,productionIndexesOut         => dummyIdList
           ,variableNamesOut             => dummyStringList
           ,variableValuesOut            => dummyStringList
           ,transVariableNamesOut        => dummyStringList
           ,transVariableValuesOut       => dummyStringList);
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getNextApprovers1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          nextApproversOut.delete;
          itemIndexesOut.delete;
          itemClassesOut.delete;
          itemIdsOut.delete;
          itemSourcesOut.delete;
          raise;
    end getNextApprovers1;
  procedure getNextApprovers2(applicationIdIn in number,
                              transactionTypeIn in varchar2,
                              transactionIdIn in varchar2,
                              flagApproversAsNotifiedIn in varchar2 default ame_util.booleanTrue,
                              approvalProcessCompleteYNOut out nocopy varchar2,
                              nextApproversOut out nocopy ame_util.approversTable2,
                              itemIndexesOut out nocopy ame_util.idList,
                              itemClassesOut out nocopy ame_util.stringList,
                              itemIdsOut out nocopy ame_util.stringList,
                              itemSourcesOut out nocopy ame_util.longStringList,
                              productionIndexesOut out nocopy ame_util.idList,
                              variableNamesOut out nocopy ame_util.stringList,
                              variableValuesOut out nocopy ame_util.stringList) as
      dummyStringList     ame_util.stringList;
    begin
      ame_engine.getNextApprovers(
            applicationIdIn   => applicationIdIn
           ,transactionTypeIn => transactionTypeIn
           ,transactionIdIn   => transactionIdIn
           ,nextApproversType => 2
           ,flagApproversAsNotifiedIn    => flagApproversAsNotifiedIn
           ,approvalProcessCompleteYNOut => approvalProcessCompleteYNOut
           ,nextApproversOut             => nextApproversOut
           ,itemIndexesOut               => itemIndexesOut
           ,itemClassesOut               => itemClassesOut
           ,itemIdsOut                   => itemIdsOut
           ,itemSourcesOut               => itemSourcesOut
           ,productionIndexesOut         => productionIndexesOut
           ,variableNamesOut             => variableNamesOut
           ,variableValuesOut            => variableValuesOut
           ,transVariableNamesOut        => dummyStringList
           ,transVariableValuesOut       => dummyStringList);
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getNextApprovers2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          nextApproversOut.delete;
          itemIndexesOut.delete;
          itemClassesOut.delete;
          itemIdsOut.delete;
          itemSourcesOut.delete;
          productionIndexesOut.delete;
          variableNamesOut.delete;
          variableValuesOut.delete;
          raise;
    end getNextApprovers2;
  procedure getNextApprovers3(applicationIdIn in number,
                              transactionTypeIn in varchar2,
                              transactionIdIn in varchar2,
                              flagApproversAsNotifiedIn in varchar2 default ame_util.booleanTrue,
                              approvalProcessCompleteYNOut out nocopy varchar2,
                              nextApproversOut out nocopy ame_util.approversTable2,
                              itemIndexesOut out nocopy ame_util.idList,
                              itemClassesOut out nocopy ame_util.stringList,
                              itemIdsOut out nocopy ame_util.stringList,
                              itemSourcesOut out nocopy ame_util.longStringList,
                              productionIndexesOut out nocopy ame_util.idList,
                              variableNamesOut out nocopy ame_util.stringList,
                              variableValuesOut out nocopy ame_util.stringList,
                              transVariableNamesOut out nocopy ame_util.stringList,
                              transVariableValuesOut out nocopy ame_util.stringList) as
    begin
      ame_engine.getNextApprovers(
            applicationIdIn   => applicationIdIn
           ,transactionTypeIn => transactionTypeIn
           ,transactionIdIn   => transactionIdIn
           ,nextApproversType => 3
           ,flagApproversAsNotifiedIn    => flagApproversAsNotifiedIn
           ,approvalProcessCompleteYNOut => approvalProcessCompleteYNOut
           ,nextApproversOut             => nextApproversOut
           ,itemIndexesOut               => itemIndexesOut
           ,itemClassesOut               => itemClassesOut
           ,itemIdsOut                   => itemIdsOut
           ,itemSourcesOut               => itemSourcesOut
           ,productionIndexesOut         => productionIndexesOut
           ,variableNamesOut             => variableNamesOut
           ,variableValuesOut            => variableValuesOut
           ,transVariableNamesOut        => transVariableNamesOut
           ,transVariableValuesOut       => transVariableValuesOut);
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getNextApprovers3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          nextApproversOut.delete;
          itemIndexesOut.delete;
          itemClassesOut.delete;
          itemIdsOut.delete;
          itemSourcesOut.delete;
          productionIndexesOut.delete;
          variableNamesOut.delete;
          variableValuesOut.delete;
          transVariableNamesOut.delete;
          transVariableValuesOut.delete;
          raise;
    end getNextApprovers3;
  procedure getNextApprovers4(applicationIdIn in number,
                              transactionTypeIn in varchar2,
                              transactionIdIn in varchar2,
                              flagApproversAsNotifiedIn in varchar2 default ame_util.booleanTrue,
                              approvalProcessCompleteYNOut out nocopy varchar2,
                              nextApproversOut out nocopy ame_util.approversTable2) as
      dummyIdList         ame_util.idList;
      dummyLongStringList ame_util.longStringList;
      dummyStringList     ame_util.stringList;
    begin
      ame_engine.getNextApprovers(
            applicationIdIn   => applicationIdIn
           ,transactionTypeIn => transactionTypeIn
           ,transactionIdIn   => transactionIdIn
           ,nextApproversType => 4
           ,flagApproversAsNotifiedIn    => flagApproversAsNotifiedIn
           ,approvalProcessCompleteYNOut => approvalProcessCompleteYNOut
           ,nextApproversOut             => nextApproversOut
           ,itemIndexesOut               => dummyIdList
           ,itemClassesOut               => dummyStringList
           ,itemIdsOut                   => dummyStringList
           ,itemSourcesOut               => dummyLongStringList
           ,productionIndexesOut         => dummyIdList
           ,variableNamesOut             => dummyStringList
           ,variableValuesOut            => dummyStringList
           ,transVariableNamesOut        => dummyStringList
           ,transVariableValuesOut       => dummyStringList);
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getNextApprovers4',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          nextApproversOut.delete;
          raise;
    end getNextApprovers4;
  procedure getPendingApprovers(applicationIdIn in number,
                                transactionTypeIn in varchar2,
                                transactionIdIn in varchar2,
                                approvalProcessCompleteYNOut out nocopy varchar2,
                                approversOut out nocopy ame_util.approversTable2) as
      approverCount integer;
      approvers ame_util.approversTable2;
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
                                        prepareApproverTreeIn => true,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      approvalProcessCompleteYNOut := ame_engine.getApprovalProcessCompleteYN;
      ame_engine.getApprovers(approversOut => approvers);
      approverCount := 0;
      for i in 1..approvers.count loop
        if (approvers(i).approver_category = ame_util.approvalApproverCategory  and
           approvers(i).approval_status  = ame_util.notifiedStatus ) then
          approverCount := approverCount + 1;
          ame_util.copyApproverRecord2(approverRecord2In => approvers(i),
                                       approverRecord2Out => approversOut(approverCount) );
        end if;
      end loop;
      if ame_util2.detailedApprovalStatusFlagYN = ame_util.booleanFalse then
        if approvalProcessCompleteYNOut = ame_util2.completeFullyApproved
          or approvalProcessCompleteYNOut = ame_util2.completeNoApprovers then
          approvalProcessCompleteYNOut  :=  ame_util.booleanTrue;
        else
          approvalProcessCompleteYNOut  :=  ame_util.booleanFalse;
        end if;
      else
        ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
      end if;
    exception
      when others then
          ame_util2.detailedApprovalStatusFlagYN :=  ame_util.booleanFalse;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getPendingApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approvalProcessCompleteYNOut:= null;
          approversOut.delete;
          raise;
    end getPendingApprovers;
  procedure getTransactionProductions(applicationIdIn in number,
                                      transactionTypeIn in varchar2,
                                      transactionIdIn in varchar2,
                                      variableNamesOut out nocopy ame_util.stringList,
                                      variableValuesOut out nocopy ame_util.stringList) as
    tempProductions ame_util2.productionsTable;
    tempIndex       integer;
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
                                        processProductionRulesIn => true,
                                        updateCurrentApproverListIn => false,
                                        updateOldApproverListIn => false,
                                        processPrioritiesIn => true,
                                        prepareItemDataIn => false,
                                        prepareRuleIdsIn => false,
                                        prepareRuleDescsIn => false,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      ame_engine.getProductions(itemClassIn    => ame_util.headerItemClassName
                               ,itemIdIn       => transactionIdIn
                               ,productionsOut => tempProductions);
      tempIndex := 1;
      for i in 1 .. tempProductions.count loop
        variableNamesOut(tempIndex)  := tempProductions(i).variable_name;
        variableValuesOut(tempIndex) := tempProductions(i).variable_value;
        tempIndex := tempIndex+1;
      end loop;
    exception
      when others then
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'getTransactionProductions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          variableNamesOut.delete;
          variableValuesOut.delete;
          raise;
    end getTransactionProductions;
  procedure initializeApprovalProcess(applicationIdIn in number,
                                    transactionTypeIn in varchar2,
                                    transactionIdIn in varchar2,
                                    recordApproverListIn in boolean default false) as

    begin
      ame_engine.lockTransaction(fndApplicationIdIn => applicationIdIn,
                                 transactionIdIn => transactionIdIn,
                                 transactionTypeIdIn => transactionTypeIn);
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
                                        updateCurrentApproverListIn => recordApproverListIn,
                                        updateOldApproverListIn => recordApproverListIn,
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
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'initializeApprovalProcess',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end initializeApprovalProcess;
  procedure setFirstAuthorityApprover(applicationIdIn in number,
                                      transactionTypeIn in varchar2,
                                      transactionIdIn in varchar2,
                                      approverIn in ame_util.approverRecord2,
                                      clearChainStatusYNIn in varchar2) as
    ameApplicationId integer;
    approversCount integer;
    approvers ame_util.approversTable2;
    approvalProcessCompleteYN ame_util.charType;
    itemApprovalProcessCompleteYN ame_util.charType;
    badStatusException exception;
    currentApprovers ame_util.approversTable2;
    errorCode integer;
    errorMessage ame_util.longStringType;
    invalidApproverException exception;
    tempCount integer;
    tempOrderNumber integer;
    tempParameter ame_temp_insertions.parameter%type;
    tooLateException exception;
    origSystemList ame_util.stringList;
    actionTypeCount number;
    invalidActionTypeException exception;
    invalidApproverTypeException exception;
    actionTypeName ame_action_types_tl.user_action_type_name%type;
    cursor getOrigSystem(actionTypeIdIn in number) is
      select apr.orig_system
        from ame_approver_type_usages apu
            ,ame_approver_types apr
       where apu.action_type_id=actionTypeIdIn
         and apr.approver_type_id = apu.approver_type_id
         and sysdate between apu.start_date
              and nvl(apu.end_date - ame_util.oneSecond,sysdate)
         and sysdate between apr.start_date
              and nvl(apr.end_date - ame_util.oneSecond,sysdate);
    cursor getActionTypeCount(actionTypeIdIn in number) is
      select distinct count(*) into actionTypeCount
        from ame_action_type_usages
       where action_type_id = approverIn.action_type_id
         and rule_type = ame_util.authorityRuleType
         and sysdate between start_date
              and nvl(end_date - ame_util.oneSecond,sysdate);
    cursor getActionTypeName(actionTypeIdIn in number) is
     select user_action_type_name
       from ame_action_types_vl
      where action_type_id = actionTypeIdIn
        and sysdate between start_date
             and nvl(end_date - ame_util.oneSecond,sysdate);
    --+
    begin
      /* Validate Input data */
      if approverIn.name is null then
        raise ambiguousApproverException;
      end if;
    -- Make sure approverIn.approval_status is null.
      if(approverIn.approval_status is not null) then
        raise badStatusException;
      end if;
      -- Validate approver.
      if(approverIn.name is null or
         approverIn.api_insertion <> ame_util.apiAuthorityInsertion or
         approverIn.authority <> ame_util.authorityApprover or
         approverIn.approval_status is not null) then
        raise invalidApproverException;
      end if;
      open getActionTypeCount(approverIn.action_type_id);
      fetch getActionTypeCount into actionTypeCount;
      close getActionTypeCount;
      if actionTypeCount = 0 then
        raise invalidActionTypeException;
      end if;
      open getOrigSystem(approverIn.action_type_id);
      fetch getOrigSystem bulk collect into origSystemList;
      close getOrigSystem;
      for i in 1..origSystemList.count loop
        if ame_approver_type_pkg.getApproverOrigSystem(nameIn => approverIn.name)<>origSystemList(i) then
          raise invalidApproverTypeException;
        end if;
      end loop;
      -- Cycle the engine, check if the approval process is complete for the transaction
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
      /* Insertions are possible for a transaction with an empty approver list and also
         an approver list which has only suppressed approvers
      */
      ame_engine.getApprovers(approversOut => approvers);
      approversCount := approvers.count;
      ameApplicationId := ame_engine.getAmeApplicationId;
      tempParameter := ame_util.firstAuthorityParameter ||
                       ame_util.fieldDelimiter ||
                       approverIn.item_class ||
                       ame_util.fieldDelimiter ||
                       approverIn.item_id ||
                       ame_util.fieldDelimiter ||
                       approverIn.action_type_id ||
                       ame_util.fieldDelimiter ||
                       approverIn.group_or_chain_id;
      if clearChainStatusYNIn = ame_util.booleanFalse then
        /* Check whether any chain-of-authority approvers have acted on the transaction's chain */
        select count(*)
          into tempCount
          from ame_temp_old_approver_lists
          where
            application_id = ameApplicationId and
            transaction_id = transactionIdIn and
            item_class = approverIn.item_class and
            item_id = approverIn.item_id and
            action_type_id = approverIn.action_type_id and
            group_or_chain_id = approverIn.group_or_chain_id and
            authority = ame_util.authorityApprover and
            api_insertion in (ame_util.oamGenerated, ame_util.apiAuthorityInsertion) and
            approval_status not in (ame_util.nullStatus,ame_util.notifiedStatus);
        if(tempCount > 0) then
          raise tooLateException;
        end if;
      else  /* clearChainStatusYNIn = 'Y' */
        /*  Clear the status of the relevant chain  for all approvers who have responded and have an approval
            approver category.  Approvers with a status of 'NOTIFIED' will not be cleared  */
        update ame_temp_old_approver_lists set
          approval_status = ame_util.nullStatus
          where
            application_id = ameApplicationId and
            transaction_id = transactionIdIn and
            item_class = approverIn.item_class and
            item_id = approverIn.item_id and
            action_type_id = approverIn.action_type_id and
            group_or_chain_id = approverIn.group_or_chain_id and
            authority = ame_util.authorityApprover and
            api_insertion in (ame_util.oamGenerated, ame_util.apiAuthorityInsertion) and
            approval_status  not in (ame_util.nullStatus,ame_util.notifiedStatus);
      /* update all existing history rows from the Approval Notification History table
         to indicate the rows were cleared */
      update AME_TRANS_APPROVAL_HISTORY  set
        date_cleared = sysdate
        where
          application_id = ameApplicationId and
            transaction_id = transactionIdIn and
            item_class = approverIn.item_class and
            item_id = approverIn.item_id and
            action_type_id = approverIn.action_type_id and
            group_or_chain_id = approverIn.group_or_chain_id and
            authority = ame_util.authorityApprover and
            status  not in (ame_util.nullStatus,ame_util.notifiedStatus) and
          date_cleared is null;
      end if;
      /* If there is already a firstAuthority in the insertions table for the transaction, item class, item_id ,
      delete it. */
      if(ame_engine.insertionExists(orderTypeIn => ame_util.firstAuthority,
                                    parameterIn => tempParameter)) then
        delete from ame_temp_insertions
          where
            application_id = ameApplicationId and
            transaction_id = transactionIdIn and
            item_class = approverIn.item_class and
            item_id = approverIn.item_id and
            order_type = ame_util.firstAuthority;
      end if;
      -- Perform the insertion.
      tempCount := ame_engine.getNextInsertionOrder;
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
          tempCount,
          ame_util.firstAuthority,
          tempParameter,
          ame_util.firstAuthorityDescription,
          approverIn.name,
          approverIn.item_class,
          approverIn.item_id,
          approverIn.approver_category,
          ame_util.apiAuthorityInsertion,
          ame_util.authorityApprover,
          sysdate,
          ame_approver_deviation_pkg.firstauthReason
          );
      -- Cycle the engine to account for changes in the insertions table.
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
      exception
        when ambiguousApproverException then
          errorCode := -20001;
          errorMessage := ambiguousApproverMessage;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'setFirstAuthorityApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when badStatusException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn =>'PER',
                                messageNameIn => 'AME_400242_API_NON_NULL_FRSAPP');
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'setFirstAuthorityApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                            errorMessage);
        when invalidApproverException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400243_API_INV_FRSTAPP');
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'setFirstAuthorityApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when invalidActionTypeException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn  => 'AME_400815_INV_COA_ACT_TYP');
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'setFirstAuthorityApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when invalidApproverTypeException then
          errorCode := -20001;
          open getActionTypeName(approverIn.action_type_id);
          fetch getActionTypeName into actionTypeName;
          close getActionTypeName;
          errorMessage :=
            ame_util.getMessage(
                      applicationShortNameIn =>'PER',
                      messageNameIn   => 'AME_400816_INV_APPROVER_TYPE',
                      tokenNameOneIn  => 'ACTION_TYPE',
                      tokenvalueOneIn => actionTypeName,
                      tokenNameTwoIn  => 'ORIG_SYSTEM',
                      tokenvalueTwoIn =>
                        ame_approver_type_pkg.getApproverOrigSystem(
                                         nameIn => approverIn.name));
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'setFirstAuthorityApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when tooLateException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400244_API_CHN_AUTH_TRANS');
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'setFirstAuthorityApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'setFirstAuthorityApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end setFirstAuthorityApprover;
  procedure updateApprovalStatus(applicationIdIn in number,
                                 transactionTypeIn in varchar2,
                                 transactionIdIn in varchar2,
                                 approverIn in ame_util.approverRecord2,
                                 forwardeeIn in ame_util.approverRecord2 default
                                             ame_util.emptyApproverRecord2,
                                 updateItemIn in boolean default false) as
    errorCode integer;
    errorMessage ame_util.longStringType;
    begin
    /*validate the input approver*/
      if(approverIn.name is null) then
        raise ambiguousApproverException;
      end if;
      ame_engine.updateApprovalStatus(applicationIdIn => applicationIdIn,
                                 transactionTypeIn => transactionTypeIn,
                                 transactionIdIn => transactionIdIn,
                                 approverIn => approverIn,
                                 forwardeeIn => forwardeeIn,
                                 updateItemIn => updateItemIn);
      exception
        when ambiguousApproverException then
          errorCode := -20001;
          errorMessage := ambiguousApproverMessage;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'updateApprovalStatus',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'updateApprovalStatus',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end updateApprovalStatus;
  procedure updateApprovalStatuses(applicationIdIn in number,
                                   transactionTypeIn in varchar2,
                                   transactionIdIn in varchar2,
                                   approverIn in ame_util.approverRecord2,
                                   approvalStatusesIn in ame_util.stringList default ame_util.emptyStringList,
                                   itemClassesIn in ame_util.stringList default ame_util.emptyStringList,
                                   itemIdsIn in ame_util.stringList default ame_util.emptyStringList,
                                   forwardeesIn in ame_util.approversTable2 default ame_util.emptyApproversTable2) as
  begin
    null;
  end updateApprovalStatuses;
  procedure updateApprovalStatus2(applicationIdIn in number,
                                  transactionTypeIn in varchar2,
                                  transactionIdIn in varchar2,
                                  approvalStatusIn in varchar2,
                                  approverNameIn in varchar2,
                                  itemClassIn in varchar2 default null,
                                  itemIdIn in varchar2 default null,
                                  actionTypeIdIn in number default null,
                                  groupOrChainIdIn in number default null,
                                  occurrenceIn in number default null,
                                  forwardeeIn in ame_util.approverRecord2 default ame_util.emptyApproverRecord2,
                                 updateItemIn in boolean default false) as
          approver ame_util.approverRecord2;
    errorCode integer;
    errorMessage ame_util.longStringType;
    nullApproverException exception;
    begin
      /* No locking needed here as it is done in updateApprovalStatus */
      if  approverNameIn is not null  then
        approver.name := approverNameIn;
      else
        raise nullApproverException;
      end if;
      approver.item_class := itemClassIn ;
      approver.item_id := itemIdIn ;
      approver.approval_status := approvalStatusIn;
      approver.action_type_id :=actionTypeIdIn ;
      approver.group_or_chain_id := groupOrChainIdIn;
      approver.occurrence := occurrenceIn;
      ame_approver_type_pkg.getOrigSystemIdAndDisplayName(nameIn =>approver.name,
                                          origSystemOut => approver.orig_system,
                                          origSystemIdOut => approver.orig_system_id,
                                          displayNameOut => approver.display_name);
      ame_engine.updateApprovalStatus(applicationIdIn => applicationIdIn,
                           transactionIdIn => transactionIdIn,
                           approverIn => approver,
                           transactionTypeIn => transactionTypeIn,
                           forwardeeIn => forwardeeIn,
                           updateItemIn => updateItemIn);
      exception
        when nullApproverException then
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn =>'PER',
             messageNameIn => 'AME_400812_NULL_APPR_REC_NAME');
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'updateApprovalStatus2',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'updateApprovalStatus2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end updateApprovalStatus2;
  procedure updateApprovalStatuses2(applicationIdIn in number,
                                    transactionTypeIn in varchar2,
                                    transactionIdIn in varchar2,
                                    approvalStatusIn in varchar2,
                                    approverNameIn in varchar2,
                                    itemClassIn in varchar2 default null,
                                    itemIdIn in varchar2 default null,
                                    actionTypeIdIn in number default null,
                                    groupOrChainIdIn in number default null,
                                    occurrenceIn in number default null,
                                    approvalStatusesIn in ame_util.stringList default ame_util.emptyStringList,
                                    itemClassesIn in ame_util.stringList default ame_util.emptyStringList,
                                    itemIdsIn in ame_util.stringList default ame_util.emptyStringList,
                                    forwardeesIn in ame_util.approversTable2 default ame_util.emptyApproversTable2) is
  begin
    null;
  end updateApprovalStatuses2;

end ame_api2;

/
