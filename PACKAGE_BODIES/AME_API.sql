--------------------------------------------------------
--  DDL for Package Body AME_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_API" as
/* $Header: ameeapin.pkb 120.9.12000000.3 2007/07/23 08:19:51 prasashe noship $ */
  /*check11510 checks backward compatibility of 11510 code with 1159 implementation
    by checking if parallelization is induced in the AME setup*/
   procedure check11510(applicationIdIn   in integer,
                        transactionTypeIn in varchar2 default null);
  /* functions */
  function getRuleDescription(ruleIdIn in varchar2) return varchar2 as
    begin
      return(ame_api3.getRuleDescription(ruleIdIn => ruleIdIn));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'getRuleDescription',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getRuleDescription;
  function validateApprover(approverIn in ame_util.approverRecord) return boolean as
    approver ame_util.approverRecord2;
    begin
      ame_util.apprRecordToApprRecord2(approverRecordIn => approverIn,
                              itemIdIn=> null,
                              approverRecord2Out =>approver);
      if approver.name is null then
        return(false);
      else
        return(ame_api2.validateApprover(approverIn=>approver));
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'validateApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end validateApprover;
  /* procedures */
  /*check 11510*/
  procedure check11510(applicationIdIn   in integer,
                       transactionTypeIn in varchar2 default null) as
    tempChar                      varchar2(1);
    tempNum                       number;
    parallelizationFoundException exception;
    ameApplicationId              integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    itemClassId                   number;
    tempAMEObject                 varchar2(100);
    --+
    cursor chkItemClassNonSerialPar(applicationIdIn in number,
                                    itemClassIdIn   in number) is
      select 'Y'
         from ame_item_class_usages
         where application_id = applicationIdIn
           and item_class_id = itemClassIdIn
           and item_class_sublist_mode <> ame_util.serialSublists
           and sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate);
    --+
    cursor chkItemClassNonUniqueOrder(applicationIdIn in number) is
      select 'Y'
        from (select (count(item_class_order_number) - count(distinct item_class_order_number)) uniq
                 from ame_item_class_usages
                 where application_id = applicationIdIn
                   and sysdate between start_date and
                         nvl(end_date - ame_util.oneSecond, sysdate)
               )
        where uniq <> 0;
    --+
    cursor chkActionTypeNonSerialPar(applicationIdIn in number) is
      select 'Y'
        from ame_action_type_config
        where application_id = applicationIdIn
          and (chain_ordering_mode <> ame_util.serialChainsMode
               or ( voting_regime is not null and
                    voting_regime <> ame_util.serializedVoting
                  )
              )
          and sysdate between start_date and
                nvl(end_date - ame_util.oneSecond, sysdate);
    --+
    cursor chkActionTypeNonUniqueOrder(applicationIdIn in number) is
      select 'Y'
        from (select distinct (count(order_number) - count(distinct order_number)) uniq
                from ame_action_type_config acf,
                     ame_action_type_usages axu
                where acf.application_id = applicationIdIn
                  and acf.action_type_id = axu.action_type_id
                  and sysdate between acf.start_date and
                        nvl(acf.end_Date - ame_util.oneSecond, sysdate)
                  and sysdate between axu.start_date and
                        nvl(axu.end_Date - ame_util.oneSecond, sysdate)
                group by rule_type
              )
        where uniq <> 0;
    --+
    cursor chkApprovalGrpNonSerialPar(applicationIdIn in number) is
      select 'Y'
        from ame_approval_group_config
        where application_id = applicationIdIn
          and (voting_regime = ame_util.consensusVoting
               or voting_regime = ame_util.firstApproverVoting)
          and sysdate between start_date and
                nvl(end_date - ame_util.oneSecond, sysdate);
    --+
    cursor chkApprovalGrpNonUniqueOrder(applicationIdIn in number) is
      select 'Y'
        from (select (count(order_number) - count(distinct order_number)) uniq
                from ame_approval_group_config
                where application_id = applicationIdIn
                  and sysdate between start_date and
                        nvl(end_date - ame_util.oneSecond, sysdate)
             )
         where uniq <> 0;
    --+
    cursor chkApprovalGrpMemberOrder(applicationIdIn in number) is
      select gpi.approval_group_id group_id
        from ame_approval_groups apg,
             ame_approval_group_config gcf,
             ame_approval_group_items gpi
        where apg.is_static = ame_util.booleanTrue
          and gcf.application_id = applicationIdIn
          and gcf.approval_group_id = apg.approval_group_id
          and gcf.voting_regime = ame_util.orderNumberVoting
          and gpi.approval_group_id = apg.approval_group_id
          and sysdate between apg.start_date and
                nvl(apg.end_date - ame_util.oneSecond, sysdate)
          and sysdate between gcf.start_date and
                nvl(gcf.end_date - ame_util.oneSecond, sysdate)
          and sysdate between gpi.start_date and
                nvl(gpi.end_date - ame_util.oneSecond, sysdate)
        group by(gpi.approval_group_id)
          having (count(gpi.order_number) - count(distinct gpi.order_number)) <> 0;
     --+
     cursor chkGrpActionInCurrentTxn(groupIdIn in varchar2
                                     ,ameApplicationIdIn in number) is
        select 'Y'
          from ame_actions act,
               ame_action_usages acu,
               ame_rule_usages aru
         where acu.rule_id = aru.rule_id
           and act.action_id = acu.action_id
           and act.parameter = groupIdIn
           and aru.item_id = ameApplicationIdIn
           and sysdate between act.start_date and nvl(act.end_Date - (1/86400), sysdate)
           and ((sysdate between acu.start_date and nvl(acu.end_date - (1/86400),sysdate))
                or
               (sysdate < acu.start_date and acu.start_date < nvl(acu.end_date, acu.start_date + (1/86400))))
           and ((sysdate between aru.start_date and nvl(aru.end_date - (1/86400),sysdate))
                or
               (sysdate < aru.start_date and aru.start_date < nvl(aru.end_date, aru.start_date + (1/86400))));
  --+
  begin
  --+
      ameApplicationId := ame_admin_pkg.getApplicationId(fndAppIdIn => applicationIdIn,
                                                         transactionTypeIdIn => transactionTypeIn);
    --Check if parallelization is induced into ame_item_class_usages
    --by checking the columns item_class_sublist_mod for HEADER item class only.
    --Do not check item_class_par_mode for header item class since it will always have 1 item.
    --Do not check usages for other item classes since we throw error if allowAllItemClasses
    --is true in one of the checks below.
    --+
    itemClassId := ame_admin_pkg.getItemClassIdByName(ame_util.headerItemClassName);
    tempAMEObject := 'Item class non serail mode';
    open chkItemClassNonSerialPar(applicationIdIn => ameApplicationId,
                                  itemClassIdIn   => itemClassId);
    fetch chkItemClassNonSerialPar into tempChar;
    if(chkItemClassNonSerialPar%FOUND) then
      close chkItemClassNonSerialPar;
      raise parallelizationFoundException;
    end if;
    close chkItemClassNonSerialPar;
    --Check if parallelization is induced into ame_item_class_usages
    --by ensuring that no two item classes have same order number.
    --+
    tempAMEObject := 'Item class non unique order number';
    open chkItemClassNonUniqueOrder(applicationIdIn => ameApplicationId);
    fetch chkItemClassNonUniqueOrder into tempChar;
    if(chkItemClassNonUniqueOrder%FOUND) then
      close chkItemClassNonUniqueOrder;
      raise parallelizationFoundException;
    end if;
    close chkItemClassNonUniqueOrder;
    --+
    --Check if parallelization is induced into ame_action_type_config
    --by checking the columns chain_ordering_mode and voting_regime.
    --Throw error if any of them has non serial value.
    --+
    tempAMEObject := 'Action type non serail mode';
    open chkActionTypeNonSerialPar(applicationIdIn => ameApplicationId);
    fetch chkActionTypeNonSerialPar into tempChar;
    if(chkActionTypeNonSerialPar%FOUND) then
      close chkActionTypeNonSerialPar;
      raise parallelizationFoundException;
    end if;
    close chkActionTypeNonSerialPar;
    --+
    --Check if parallelization is induced into ame_action_type_config
    --by ensuring that no two action types belonging to a rule type
    --have same order number.
    --+
    tempAMEObject := 'Action type non serial order number';
    open chkActionTypeNonUniqueOrder(applicationIdIn => ameApplicationId);
    fetch chkActionTypeNonUniqueOrder into tempChar;
    if(chkActionTypeNonUniqueOrder%FOUND) then
      close chkActionTypeNonUniqueOrder;
      raise parallelizationFoundException;
    end if;
    close chkActionTypeNonUniqueOrder;
    --+
    --Check if parallelization is induced into ame_approval_group_config
    --by checking voting regime for consensus and first responder wins.
    --Do not throw error for voting regime = order number since it will
    --be taken care by one of the checks below.
    --+
    tempAMEObject := 'Approval group non serail mode';
    open chkApprovalGrpNonSerialPar(applicationIdIn => ameApplicationId);
    fetch chkApprovalGrpNonSerialPar into tempChar;
    if(chkApprovalGrpNonSerialPar%FOUND) then
      close chkApprovalGrpNonSerialPar;
      raise parallelizationFoundException;
    end if;
    close chkApprovalGrpNonSerialPar;
    --+
    --Check if parallelization is induced into ame_approval_group_config
    --by ensuring that no two approval groups have same order number.
    --+
    tempAMEObject := 'approval group: non unique order number';
    open chkApprovalGrpNonUniqueOrder(applicationIdIn => ameApplicationId);
    fetch chkApprovalGrpNonUniqueOrder into tempChar;
    if(chkApprovalGrpNonUniqueOrder%FOUND) then
      close chkApprovalGrpNonUniqueOrder;
      raise parallelizationFoundException;
    end if;
    close chkApprovalGrpNonUniqueOrder;
    --+
    --Check if parallelization is induced by checking all static approval
    --groups used in the current transaction type with voting_regime = order number
    --and ensuring that these groups' items have unique order numbers.
    --+
    for x in chkApprovalGrpMemberOrder(ameApplicationId) loop
      open chkGrpActionInCurrentTxn(groupIdIn => x.group_id
                                   ,ameApplicationIdIn => ameApplicationId);
      tempAMEObject := 'Approval group member non unique member order number:'||x.group_id;
      fetch chkGrpActionInCurrentTxn into tempChar;
      if(chkGrpActionInCurrentTxn%FOUND) then
        close chkGrpActionInCurrentTxn;
        raise parallelizationFoundException;
      end if;
      close chkGrpActionInCurrentTxn;
    end loop;
    --+
    --The following checks ensure that allowAllItemClasses, allowAllItemClassRules,
    --allowAllApproverTypes, productionFunctionality are turned off.
    --+
    tempAMEObject := 'AME config vars, allowAllRuleConfigvar';
    if(ame_util.getConfigVar(variableNameIn  => ame_util.allowAllICRulesConfigVar,
                             applicationIdIn => ameApplicationId)
        = ame_util.yes) then
      raise parallelizationFoundException;
    end if;
    --+
    tempAMEObject := 'AME config vars, fyi notification';
    if(ame_util.getConfigVar(variableNameIn  => ame_util.allowFyiNotificationsConfigVar,
                             applicationIdIn => ameApplicationId)
        = ame_util.yes) then
      raise parallelizationFoundException;
    end if;
    --+
    tempAMEObject := 'AME config vars allow all approver types';
    if(ame_util.getConfigVar(variableNameIn  => ame_util.allowAllApproverTypesConfigVar,
                             applicationIdIn => ameApplicationId)
        = ame_util.yes) then
      raise parallelizationFoundException;
    end if;
    --+
    tempAMEObject := 'AME config vars, production rules';
    if(ame_util.getConfigVar(variableNameIn  => ame_util.productionConfigVar,
                             applicationIdIn => ameApplicationId)
        <> ame_util.noProductions) then
      raise parallelizationFoundException;
    end if;
    --+
  exception
        when parallelizationFoundException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400679_API_PARALLEL_CONFIG');
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'check11510',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => 'ameApplicationId:'||ameApplicationId||
                                    ':'||tempAMEObject||':'||errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'check11510',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
  end check11510;
  procedure clearAllApprovals(applicationIdIn in integer,
                              transactionIdIn in varchar2,
                              transactionTypeIn in varchar2 default null) as
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_api2.clearAllApprovals(applicationIdIn => applicationIdIn,
                                 transactionIdIn => transactionIdIn,
                                 transactionTypeIn => transactionTypeIn);
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api',
                                  routineNameIn => 'clearAllApprovals',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
    end clearAllApprovals;
  procedure clearDeletion(approverIn in ame_util.approverRecord,
                          applicationIdIn in integer,
                          transactionIdIn in varchar2,
                          transactionTypeIn in varchar2 default null) as
    approver ame_util.approverRecord2;
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_util.apprRecordToApprRecord2(approverRecordIn => approverIn,
                              itemIdIn => transactionIdIn,
                              approverRecord2Out =>approver);
      ame_api3.clearSuppression(approverIn => approver,
                             applicationIdIn => applicationIdIn,
                             transactionIdIn => transactionIdIn,
                             transactionTypeIn => transactionTypeIn);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'clearDeletion',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end clearDeletion;
  procedure clearDeletions(applicationIdIn in integer,
                           transactionIdIn in varchar2,
                           transactionTypeIn in varchar2 default null) as
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_api3.clearSuppressions(applicationIdIn => applicationIdIn,
                              transactionIdIn => transactionIdIn,
                              transactionTypeIn => transactionTypeIn);
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api',
                                  routineNameIn => 'clearDeletions',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
    end clearDeletions;
  procedure clearInsertion(approverIn in ame_util.approverRecord,
                           applicationIdIn in integer,
                           transactionIdIn in varchar2,
                           transactionTypeIn in varchar2 default null) as
    approver ame_util.approverRecord2;
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_util.apprRecordToApprRecord2(approverRecordIn => approverIn,
                              itemIdIn => transactionIdIn,
                              approverRecord2Out =>approver);
      ame_api3.clearInsertion(approverIn => approver,
                              applicationIdIn => applicationIdIn,
                              transactionIdIn => transactionIdIn,
                              transactionTypeIn => transactionTypeIn);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'clearInsertion',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end clearInsertion;
  procedure clearInsertions(applicationIdIn in integer,
                            transactionIdIn in varchar2,
                            transactionTypeIn in varchar2 default null) as
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_api3.clearInsertions( applicationIdIn => applicationIdIn,
                              transactionIdIn => transactionIdIn,
                              transactionTypeIn => transactionTypeIn);
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api',
                                  routineNameIn => 'clearInsertions',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
    end clearInsertions;
  procedure deleteApprover(applicationIdIn in integer,
                           transactionIdIn in varchar2,
                           approverIn in ame_util.approverRecord,
                           transactionTypeIn in varchar2 default null) as
    approver ame_util.approverRecord2;
    approvers ame_util.approversTable2;
    approverIndex integer;
    errorCode integer;
    errorMessage ame_util.longStringType;
    noMatchException exception;
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_util.apprRecordToApprRecord2(approverRecordIn => approverIn,
                              itemIdIn => transactionIdIn,
                              approverRecord2Out =>approver);
      if (approver.action_type_id is null or
          approver.group_or_chain_id is null or
          approver.occurrence is null) then
        /* run the engine cycle to get the latest approver list and then iterate thru
           the list to find the first approver which matches this one. Populate this
           approvers action_type_id and group_or_chain_id */
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
        /* Fetch the approver list */
        ame_engine.getApprovers(approversOut => approvers);
        approverIndex := null;
        for i in 1 .. approvers.count loop
          if((approvers(i).approval_status is null or
              approvers(i).approval_status in
                 (ame_util.exceptionStatus,
                  ame_util.notifiedStatus,
                  ame_util.noResponseStatus,
                  ame_util.rejectStatus)) and
            approver.name = approvers(i).name) then
            approverIndex := i;
            exit;
          end if;
        end loop;
        approver.action_type_id := approvers(approverIndex).action_type_id;
        approver.group_or_chain_id := approvers(approverIndex).group_or_chain_id;
        approver.occurrence := approvers(approverIndex).occurrence;
        /* If there is no match, raise an exception. */
        if(approverIndex is null) then
          raise noMatchException;
        end if;
      end if;
      ame_api3.suppressApprover(applicationIdIn => applicationIdIn,
                              transactionIdIn => transactionIdIn,
                              approverIn => approver,
                              transactionTypeIn => transactionTypeIn);
      exception
        when noMatchException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400237_API_NO MATCH_APPR');
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'deleteApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'deleteApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end deleteApprover;
  procedure deleteApprovers(applicationIdIn in integer,
                            transactionIdIn in varchar2,
                            approversIn in ame_util.approversTable,
                            transactionTypeIn in varchar2 default null) as
    currentApproverInIndex integer;
    lastApproverInIndex integer;
    nextApproverInIndex integer;
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      lastApproverInIndex := approversIn.last;
      currentApproverInIndex := approversIn.first;
      --
      -- This procedure should always depend on deleteApprover, so that we don't
      -- need to repeat error-checking and other logic here.
      --
      loop
        ame_api.deleteApprover(applicationIdIn => applicationIdIn,
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
        ame_util.runtimeException(packageNameIn => 'ame_api',
                                  routineNameIn => 'deleteApprovers',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
    end deleteApprovers;
  procedure getAdminApprover(applicationIdIn in integer default null,
                             transactionTypeIn in varchar2 default null,
                             adminApproverOut out nocopy ame_util.approverRecord) as
    adminApprover ame_util.approverRecord2;
    begin
      ame_api2.getAdminApprover(applicationIdIn => applicationIdIn,
                                transactionTypeIn => transactionTypeIn,
                                adminApproverOut => adminApprover);
      if adminApprover.name is null then
        return;
      else
        ame_util.apprRecord2ToApprRecord(approverRecord2In => adminApprover,
                                         approverRecordOut => adminApproverOut);
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'getAdminApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getAdminApprover;
  procedure getAllApprovers(applicationIdIn in integer,
                            transactionIdIn in varchar2,
                            transactionTypeIn in varchar2 default null,
                            approversOut out nocopy ame_util.approversTable) as
    approvalProcessCompleteYN ame_util.charType;
    approvers ame_util.approversTable2;
    tempCount integer;
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_api2.getAllApprovers7(applicationIdIn => applicationIdIn,
                                transactionTypeIn => transactionTypeIn,
                                transactionIdIn => transactionIdIn,
                                approvalProcessCompleteYNOut => approvalProcessCompleteYN,
                                approversOut => approvers);
      ame_util.apprTable2ToApprTable(approversTable2In => approvers,
                            approversTableOut => approversOut);
    exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'getAllApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approversOut.delete;
          approversOut(1) := ame_util.emptyApproverRecord;
          getAdminApprover(applicationIdIn => applicationIdIn,
                           transactionTypeIn => transactionTypeIn,
                           adminApproverOut => approversOut(1));
          raise;
    end getAllApprovers;
  procedure getAndRecordAllApprovers(applicationIdIn in integer,
                                     transactionIdIn in varchar2,
                                     transactionTypeIn in varchar2 default null,
                                     approversOut out nocopy ame_util.approversTable) as
    approvalProcessCompleteYN ame_util.charType;
    approvers ame_util.approversTable2;
    itemClasses ame_util.stringList;
    itemIndexes ame_util.idList;
    itemIds ame_util.stringList;
    itemSources ame_util.longStringList;
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_api2.getAndRecordAllApprovers(applicationIdIn => applicationIdIn,
                                        transactionTypeIn => transactionTypeIn,
                                        transactionIdIn => transactionIdIn,
                                        approvalProcessCompleteYNOut => approvalProcessCompleteYN,
                                        approversOut => approvers,
                                        itemIndexesOut => itemIndexes,
                                        itemClassesOut => itemClasses,
                                        itemIdsOut => itemIds,
                                        itemSourcesOut => itemSources);
      ame_util.apprTable2ToApprTable(approversTable2In => approvers,
                            approversTableOut => approversOut);
    exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'getAndRecordAllApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approversOut.delete;
          getAdminApprover(applicationIdIn => applicationIdIn,
                           transactionTypeIn => transactionTypeIn,
                           adminApproverOut => approversOut(1));
          raise;
    end getAndRecordAllApprovers;
  procedure getApplicableRules1(applicationIdIn in integer,
                                transactionIdIn in varchar2,
                                transactionTypeIn in varchar2 default null,
                                ruleIdsOut out nocopy ame_util.idList) as
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_api3.getApplicableRules1(applicationIdIn => applicationIdIn,
                                   transactionIdIn => transactionIdIn,
                                   transactionTypeIn => transactionTypeIn,
                                   ruleIdsOut => ruleIdsOut);
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api',
                                  routineNameIn => 'getApplicableRules1',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
    end getApplicableRules1;
  procedure getApplicableRules2(applicationIdIn in integer,
                                transactionIdIn in varchar2,
                                transactionTypeIn in varchar2 default null,
                                ruleDescriptionsOut out nocopy ame_util.stringList) as
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_api3.getApplicableRules2(applicationIdIn => applicationIdIn,
                                   transactionIdIn => transactionIdIn,
                                   transactionTypeIn => transactionTypeIn,
                                   ruleDescriptionsOut => ruleDescriptionsOut);
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api',
                                  routineNameIn => 'getApplicableRules2',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
    end getApplicableRules2;
  procedure getApplicableRules3(applicationIdIn in integer,
                                transactionIdIn in varchar2,
                                transactionTypeIn in varchar2 default null,
                                ruleIdsOut out nocopy ame_util.idList,
                                ruleDescriptionsOut out nocopy ame_util.stringList) as
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_api3.getApplicableRules3(applicationIdIn => applicationIdIn,
                                   transactionIdIn => transactionIdIn,
                                   transactionTypeIn => transactionTypeIn,
                                   ruleIdsOut => ruleIdsOut,
                                   ruleDescriptionsOut => ruleDescriptionsOut);
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api',
                                  routineNameIn => 'getApplicableRules3',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
    end getApplicableRules3;
  procedure getApproversAndRules1(applicationIdIn in integer,
                                  transactionIdIn in varchar2,
                                  transactionTypeIn in varchar2 default null,
                                  approversOut out nocopy ame_util.approversTable,
                                  ruleIdsOut out nocopy ame_util.idList) as
    approvalProcessCompleteYN ame_util.charType;
    approvers ame_util.approversTable2;
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_api2.getAllApprovers7(applicationIdIn => applicationIdIn,
                                transactionTypeIn => transactionTypeIn,
                                transactionIdIn => transactionIdIn,
                                approvalProcessCompleteYNOut => approvalProcessCompleteYN,
                                approversOut => approvers);
      ame_api3.getApplicableRules1(applicationIdIn => applicationIdIn,
                                   transactionIdIn => transactionIdIn,
                                   transactionTypeIn => transactionTypeIn,
                                   ruleIdsOut => ruleIdsOut);
      ame_util.apprTable2ToApprTable(approversTable2In => approvers,
                            approversTableOut => approversOut);
    exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'getApproversAndRules1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approversOut.delete;
          ruleIdsOut.delete;
          getAdminApprover(applicationIdIn => applicationIdIn,
                           transactionTypeIn => transactionTypeIn,
                           adminApproverOut => approversOut(1));
          raise;
    end getApproversAndRules1;
  procedure getApproversAndRules2(applicationIdIn in integer,
                                  transactionIdIn in varchar2,
                                  transactionTypeIn in varchar2 default null,
                                  approversOut out nocopy ame_util.approversTable,
                                  ruleDescriptionsOut out nocopy ame_util.stringList) as
    approvalProcessCompleteYN ame_util.charType;
    approvers ame_util.approversTable2;
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_api2.getAllApprovers7(applicationIdIn => applicationIdIn,
                                transactionTypeIn => transactionTypeIn,
                                transactionIdIn => transactionIdIn,
                                approvalProcessCompleteYNOut => approvalProcessCompleteYN,
                                approversOut => approvers);
      ame_api3.getApplicableRules2(applicationIdIn => applicationIdIn,
                                   transactionIdIn => transactionIdIn,
                                   transactionTypeIn => transactionTypeIn,
                                   ruleDescriptionsOut => ruleDescriptionsOut);
      ame_util.apprTable2ToApprTable(approversTable2In => approvers,
                            approversTableOut => approversOut);
    exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'getApproversAndRules2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approversOut.delete;
          ruleDescriptionsOut.delete;
          getAdminApprover(applicationIdIn => applicationIdIn,
                           transactionTypeIn => transactionTypeIn,
                           adminApproverOut => approversOut(1));
          raise;
    end getApproversAndRules2;
  procedure getApproversAndRules3(applicationIdIn in integer,
                                  transactionIdIn in varchar2,
                                  transactionTypeIn in varchar2 default null,
                                  approversOut out nocopy ame_util.approversTable,
                                  ruleIdsOut out nocopy ame_util.idList,
                                  ruleDescriptionsOut out nocopy ame_util.stringList) as
    approvalProcessCompleteYN ame_util.charType;
    approvers ame_util.approversTable2;
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_api2.getAllApprovers7(applicationIdIn => applicationIdIn,
                                transactionTypeIn => transactionTypeIn,
                                transactionIdIn => transactionIdIn,
                                approvalProcessCompleteYNOut => approvalProcessCompleteYN,
                                approversOut => approvers);
      ame_api3.getApplicableRules3(applicationIdIn => applicationIdIn,
                                   transactionIdIn => transactionIdIn,
                                   transactionTypeIn => transactionTypeIn,
                                   ruleIdsOut => ruleIdsOut,
                                   ruleDescriptionsOut => ruleDescriptionsOut);
      ame_util.apprTable2ToApprTable(approversTable2In => approvers,
                            approversTableOut => approversOut);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'getApproversAndRules3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approversOut.delete;
          ruleIdsOut.delete;
          ruleDescriptionsOut.delete;
          getAdminApprover(applicationIdIn => applicationIdIn,
                           transactionTypeIn => transactionTypeIn,
                           adminApproverOut => approversOut(1));
          raise;
    end getApproversAndRules3;
  procedure getAvailableInsertions(applicationIdIn in integer,
                                   transactionIdIn in varchar2,
                                   positionIn in integer,
                                   transactionTypeIn in varchar2 default null,
                                   availableInsertionsOut out nocopy ame_util.insertionsTable) as
      i integer;
      tempParameter ame_util.longestStringType;
      availableInsertions ame_util.insertionsTable2;
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_api3.getAvailableInsertions(applicationIdIn => applicationIdIn,
                                      transactionIdIn => transactionIdIn,
                                      positionIn => positionIn,
                                      transactionTypeIn => transactionTypeIn,
                                      availableInsertionsOut => availableInsertions);
      ame_util.insTable2ToInsTable(insertionsTable2In => availableInsertions,
                          insertionsTableOut => availableInsertionsOut);
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api',
                                  routineNameIn => 'getAvailableInsertions',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
    end getAvailableInsertions;
  procedure getAvailableOrders(applicationIdIn in integer,
                               transactionIdIn in varchar2,
                               positionIn in integer,
                               transactionTypeIn in varchar2 default null,
                               availableOrdersOut out nocopy ame_util.ordersTable) as
    approvers ame_util.approversTable2;
    approversCount integer;
    availableOrdersIndex integer; /* pre-increment */
    errorCode integer;
    errorMessage ame_util.longestStringType;
    invalidPositionException exception;
    nextApproverDescription varchar2(100);
    prevApproverDescription varchar2(100);
    ruleIdList ame_util.idList;
    sourceDescription ame_util.stringType;
    tempBoolean boolean;
    tempInsertionDoesNotExist boolean;
    tempOrigSystem ame_util.stringType;
    tempOrigSystemId integer;
    tempParameter ame_temp_insertions.parameter%type;
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
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
      ame_engine.getApprovers(approversOut => approvers);
      approversCount := approvers.count;
      /* Check that positionIn is in bounds. */
      if(positionIn < 1 or
         positionIn > approversCount + 1 or
         not ame_util.isANonNegativeInteger(stringIn => positionIn)) then
        raise invalidPositionException;
      end if;
      availableOrdersIndex := 0;
      /*
        ORDER TYPE:  absoluteOrder
        absoluteOrder is always available.
      */
      tempParameter := positionIn;
      if(not ame_engine.insertionExists(orderTypeIn => ame_util.absoluteOrder,
                                        parameterIn => tempParameter)) then
        availableOrdersIndex := availableOrdersIndex + 1;
        availableOrdersOut(availableOrdersIndex).order_type := ame_util.absoluteOrder;
        availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
        availableOrdersOut(availableOrdersIndex).description :=
              ame_util.absoluteOrderDescription || positionIn || '.  ';
      end if;
      /*
        ORDER TYPE:  afterApprover
        Ad-hoc afterApprover is available if positionIn > 1.
      */
      if(positionIn = 1 or
           approversCount = 0) then
        prevApproverDescription := null;
      else
        ame_approver_type_pkg.getOrigSystemIdAndDisplayName(nameIn =>approvers(positionIn - 1).name,
                                          origSystemOut => tempOrigSystem,
                                          origSystemIdOut => tempOrigSystemId,
                                          displayNameOut => prevApproverDescription);
        if tempOrigSystem = ame_util.perOrigSystem then
          tempOrigSystem := 'person_id';
        elsif tempOrigSystem = ame_util.fndUserOrigSystem then
          tempOrigSystem := 'user_id';
        end if;
        tempParameter := tempOrigSystem || ':' || tempOrigSystemId || ':' ||
                         approvers(positionIn - 1).action_type_id || ':' ||
                         approvers(positionIn - 1).group_or_chain_id ||':' ||
                         approvers(positionIn - 1).occurrence;
        tempInsertionDoesNotExist := not ame_engine.insertionExists(orderTypeIn => ame_util.afterApprover,
                                                                      parameterIn => tempParameter);
        if(tempInsertionDoesNotExist) then
          availableOrdersIndex := availableOrdersIndex + 1;
          availableOrdersOut(availableOrdersIndex).order_type := ame_util.afterApprover;
          availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
          availableOrdersOut(availableOrdersIndex).description := ame_util.afterApproverDescription ||
                                                                          prevApproverDescription;
        end if;
      end if;
      /*
        ORDER TYPE:  beforeApprover
        beforeApprover is available if approversCount > 0 and positionIn < approversCount + 1.
      */
      if(positionIn = approversCount + 1 or
         approversCount = 0) then
        nextApproverDescription := null;
      else
        ame_approver_type_pkg.getOrigSystemIdAndDisplayName(nameIn =>approvers(positionIn).name,
                                          origSystemOut => tempOrigSystem,
                                          origSystemIdOut => tempOrigSystemId,
                                          displayNameOut => nextApproverDescription);
        if tempOrigSystem = ame_util.perOrigSystem then
          tempOrigSystem := 'person_id';
        elsif tempOrigSystem = ame_util.fndUserOrigSystem then
          tempOrigSystem := 'user_id';
        end if;
        tempParameter := tempOrigSystem || ':' || tempOrigSystemId || ':' ||
                         approvers(positionIn).action_type_id || ':' ||
                         approvers(positionIn).group_or_chain_id ||':' ||
                         approvers(positionIn).occurrence;
        if(not ame_engine.insertionExists(orderTypeIn => ame_util.beforeApprover,
                                          parameterIn => tempParameter)) then
          availableOrdersIndex := availableOrdersIndex + 1;
          availableOrdersOut(availableOrdersIndex).order_type := ame_util.beforeApprover;
          availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
          availableOrdersOut(availableOrdersIndex).description :=
                      ame_util.beforeApproverDescription || nextApproverDescription;
        end if;
      end if;
        /*
        ORDER TYPE:  firstAuthority
        firstAuthority is available if the approver you're at is the first COA approver in a chain.
      */
      if(positionIn < approversCount + 1 and
         approvers(positionIn).authority = ame_util.authorityApprover and
         approvers(positionIn).api_insertion <> ame_util.apiInsertion ) then
        tempBoolean := true; /* tempBoolean remains true if no previous authority is found.  */
        for i in reverse 1..positionIn - 1 loop
          if(approvers(i).group_or_chain_id <> approvers(positionIn).group_or_chain_id or
             approvers(i).action_type_id <> approvers(positionIn).action_type_id or
             approvers(i).item_id <> approvers(positionIn).item_id or
             approvers(i).item_class <> approvers(positionIn).item_class) then
            exit;
          end if;
          if(approvers(i).authority = ame_util.authorityApprover and
             approvers(i).api_insertion <> ame_util.apiInsertion) then
            tempBoolean := false;
            exit;
          end if;
        end loop;
        if(tempBoolean) then
          tempParameter := ame_util.firstAuthorityParameter ;
          if(not ame_engine.insertionExists(orderTypeIn => ame_util.firstAuthority,
                                            parameterIn => tempParameter)) then
            availableOrdersIndex := availableOrdersIndex + 1;
            availableOrdersOut(availableOrdersIndex).order_type := ame_util.firstAuthority;
            availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
            availableOrdersOut(availableOrdersIndex).description := ame_util.firstAuthorityDescription;
          end if;
        end if;
      end if;
      /*
        ORDER TYPE:  firstPostApprover
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
            if(the approvers at positionIn - 1 and positionIn are for the same item) then
              if(the first approver is not a post-approver and
                 the second approver is a post-approver) then
                allow a first-post-approver insertion for the approvers' item
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
      tempParameter := ame_util.firstPostParameter ;
      if(approversCount = 0) then
        if(not ame_engine.insertionExists(orderTypeIn => ame_util.firstPostApprover,
                                          parameterIn => tempParameter)) then
          availableOrdersIndex := availableOrdersIndex + 1;
          availableOrdersOut(availableOrdersIndex).order_type := ame_util.firstPostApprover;
          availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
          availableOrdersOut(availableOrdersIndex).description := ame_util.firstPostApproverDescription;
        end if;
      elsif(positionIn = approversCount + 1) then
        if(approvers(approversCount).authority <> ame_util.postApprover) then
          if(not ame_engine.insertionExists(orderTypeIn => ame_util.firstPostApprover,
                                            parameterIn => tempParameter)) then
            availableOrdersIndex := availableOrdersIndex + 1;
            availableOrdersOut(availableOrdersIndex).order_type := ame_util.firstPostApprover;
            availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
            availableOrdersOut(availableOrdersIndex).description := ame_util.firstPostApproverDescription;
          end if;
        end if;
      elsif(positionIn = 1) then
        if(approvers(1).authority = ame_util.postApprover) then
          if(not ame_engine.insertionExists(orderTypeIn => ame_util.firstPostApprover,
                                            parameterIn => tempParameter)) then
            availableOrdersIndex := availableOrdersIndex + 1;
            availableOrdersOut(availableOrdersIndex).order_type := ame_util.firstPostApprover;
            availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
            availableOrdersOut(availableOrdersIndex).description := ame_util.firstPostApproverDescription;
          end if;
        end if;
      else
        if(approvers(positionIn - 1).item_id = approvers(positionIn).item_id and
           approvers(positionIn - 1).item_class = approvers(positionIn).item_class) then
          if(approvers(positionIn - 1).authority <> ame_util.postApprover and
             approvers(positionIn).authority = ame_util.postApprover) then
            if(not ame_engine.insertionExists(orderTypeIn => ame_util.firstPostApprover,
                                              parameterIn => tempParameter)) then
              availableOrdersIndex := availableOrdersIndex + 1;
              availableOrdersOut(availableOrdersIndex).order_type := ame_util.firstPostApprover;
              availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
              availableOrdersOut(availableOrdersIndex).description := ame_util.firstPostApproverDescription;
            end if;
          end if;
        else
          if(approvers(positionIn).authority = ame_util.postApprover) then
            if(not ame_engine.insertionExists(orderTypeIn => ame_util.firstPostApprover,
                                              parameterIn => tempParameter)) then
              availableOrdersIndex := availableOrdersIndex + 1;
              availableOrdersOut(availableOrdersIndex).order_type := ame_util.firstPostApprover;
              availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
              availableOrdersOut(availableOrdersIndex).description := ame_util.firstPostApproverDescription;
            end if;
          end if;
          if(approvers(positionIn - 1).authority <> ame_util.postApprover) then
            if(not ame_engine.insertionExists(orderTypeIn => ame_util.firstPostApprover,
                                              parameterIn => tempParameter)) then
              availableOrdersIndex := availableOrdersIndex + 1;
              availableOrdersOut(availableOrdersIndex).order_type := ame_util.firstPostApprover;
              availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
              availableOrdersOut(availableOrdersIndex).description := ame_util.firstPostApproverDescription;
            end if;
          end if;
        end if;
      end if;
      /*
        ORDER TYPE:  firstPreApprover
        Assume that in the case of an entirely empty approver list, we allow insertion of a first
        pre-approver into the header item's list only.  Otherwise, we only allow insertion of
a
        first pre-approver into a non-empty item list.  Here is the case analysis:
          if(the approver list is empty) then
            allow a first-pre-approver insertion for the header item
          elsif(positionIn = 1) then
            allow a first-pre-approver insertion for the first approver's item
          elsif(positionIn < approversCount + 1) then
            if(the approvers at positionIn - 1 and positionIn are for different items) then
              allow a first-pre-approver insertion for the second approver's item
            end if
          end if
      */
      tempParameter := ame_util.firstPreApprover ;
      if(approversCount = 0) then
        if(not ame_engine.insertionExists(orderTypeIn => ame_util.firstPreApprover,
                                          parameterIn => tempParameter)) then
          availableOrdersIndex := availableOrdersIndex + 1;
          availableOrdersOut(availableOrdersIndex).order_type := ame_util.firstPreApprover;
          availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
          availableOrdersOut(availableOrdersIndex).description := ame_util.firstPreApproverDescription;
        end if;
      elsif(positionIn = 1) then
        if(not ame_engine.insertionExists(orderTypeIn => ame_util.firstPreApprover,
                                          parameterIn => tempParameter)) then
          availableOrdersIndex := availableOrdersIndex + 1;
          availableOrdersOut(availableOrdersIndex).order_type := ame_util.firstPreApprover;
          availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
          availableOrdersOut(availableOrdersIndex).description := ame_util.firstPreApproverDescription;
        end if;
      elsif(positionIn < approversCount + 1) then
        if(approvers(positionIn - 1).item_id <> approvers(positionIn).item_id or
           approvers(positionIn - 1).item_class <> approvers(positionIn).item_class) then
          if(not ame_engine.insertionExists(orderTypeIn => ame_util.firstPreApprover,
                                            parameterIn => tempParameter)) then
            availableOrdersIndex := availableOrdersIndex + 1;
            availableOrdersOut(availableOrdersIndex).order_type := ame_util.firstPreApprover;
            availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
            availableOrdersOut(availableOrdersIndex).description := ame_util.firstPreApproverDescription;
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
          elsif(positionIn = approversCount + 1) then
            allow last-post-approver insertion for the last approver's item
          elsif(positionIn > 1) then
            if(the approvers at positionIn - 1 and positionIn are for different items) then
              allow last-post-approver insertion for the former approver's item
            end if
          end if
      */
      tempParameter := ame_util.lastPostApprover ;
      if(approversCount = 0) then
        if(not ame_engine.insertionExists(orderTypeIn => ame_util.lastPostApprover,
                                          parameterIn => tempParameter)) then
          availableOrdersIndex := availableOrdersIndex + 1;
          availableOrdersOut(availableOrdersIndex).order_type := ame_util.lastPostApprover;
          availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
          availableOrdersOut(availableOrdersIndex).description := ame_util.lastPostApproverDescription;
        end if;
      elsif(positionIn = approversCount + 1) then
        if(not ame_engine.insertionExists(orderTypeIn => ame_util.lastPostApprover,
                                          parameterIn => tempParameter)) then
          availableOrdersIndex := availableOrdersIndex + 1;
          availableOrdersOut(availableOrdersIndex).order_type := ame_util.lastPostApprover;
          availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
          availableOrdersOut(availableOrdersIndex).description := ame_util.lastPostApproverDescription;
        end if;
      elsif(positionIn > 1) then
        if(approvers(positionIn - 1).item_id <> approvers(positionIn).item_id or
           approvers(positionIn - 1).item_class <> approvers(positionIn).item_class) then
          if(not ame_engine.insertionExists(orderTypeIn => ame_util.lastPostApprover,
                                            parameterIn => tempParameter)) then
            availableOrdersIndex := availableOrdersIndex + 1;
            availableOrdersOut(availableOrdersIndex).order_type := ame_util.lastPostApprover;
            availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
            availableOrdersOut(availableOrdersIndex).description := ame_util.lastPostApproverDescription;
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
          elsif(positionIn <= approversCount) then
            if(the approvers at positionIn - 1 and positionIn are for the same item) then
              if(the approver at positionIn - 1 is a pre-approver and
                 the approver at positionIn is not a pre-approver) then
                allow last-pre-approver insertion for the approvers' item
              end if
            else
              if(the approver at positionIn is not a pre-approver) then
                allow last-pre-approver insertion for the item of the approver at positionIn
              end if
            end if
          end if
      */
      tempParameter := ame_util.lastPreApprover ;
      if(approversCount = 0) then
        if(not ame_engine.insertionExists(orderTypeIn => ame_util.lastPreApprover,
                                          parameterIn => tempParameter)) then
          availableOrdersIndex := availableOrdersIndex + 1;
          availableOrdersOut(availableOrdersIndex).order_type := ame_util.lastPreApprover;
          availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
          availableOrdersOut(availableOrdersIndex).description := ame_util.lastPreApproverDescription;
        end if;
      elsif(positionIn = 1) then
        if(approvers(1).authority <> ame_util.preApprover) then
          if(not ame_engine.insertionExists(orderTypeIn => ame_util.lastPreApprover,
                                            parameterIn => tempParameter)) then
            availableOrdersIndex := availableOrdersIndex + 1;
            availableOrdersOut(availableOrdersIndex).order_type := ame_util.lastPreApprover;
            availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
            availableOrdersOut(availableOrdersIndex).description := ame_util.lastPreApproverDescription;
          end if;
        end if;
      elsif(positionIn <= approversCount) then
        if(approvers(positionIn - 1).item_id = approvers(positionIn).item_id and
           approvers(positionIn - 1).item_class = approvers(positionIn).item_class) then
          if(approvers(positionIn - 1).authority = ame_util.preApprover and
             approvers(positionIn).authority <> ame_util.preApprover) then
            if(not ame_engine.insertionExists(orderTypeIn => ame_util.lastPreApprover,
                                              parameterIn => tempParameter)) then
              availableOrdersIndex := availableOrdersIndex + 1;
              availableOrdersOut(availableOrdersIndex).order_type := ame_util.lastPreApprover;
              availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
              availableOrdersOut(availableOrdersIndex).description := ame_util.lastPreApproverDescription;
            end if;
          end if;
        else
          if(approvers(positionIn).authority <> ame_util.preApprover) then
            if(not ame_engine.insertionExists(orderTypeIn => ame_util.lastPreApprover,
                                              parameterIn => tempParameter)) then
              availableOrdersIndex := availableOrdersIndex + 1;
              availableOrdersOut(availableOrdersIndex).order_type := ame_util.lastPreApprover;
              availableOrdersOut(availableOrdersIndex).parameter := tempParameter;
              availableOrdersOut(availableOrdersIndex).description := ame_util.lastPreApproverDescription;
            end if;
          end if;
        end if;
      end if;
      exception
      when invalidPositionException then
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                 messageNameIn => 'AME_400418_INVALID_INSERTION');
        ame_util.runtimeException(packageNameIn => 'ame_api',
                                  routineNameIn => 'getAvailableOrders',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                errorMessage);
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api',
                                  routineNameIn => 'getAvailableOrders',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
    end getAvailableOrders;
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
      ame_api3.getConditionDetails(conditionIdIn => conditionIdIn,
                                   attributeNameOut => attributeNameOut,
                                   attributeTypeOut => attributeTypeOut,
                                   attributeDescriptionOut => attributeDescriptionOut,
                                   lowerLimitOut => lowerLimitOut,
                                   upperLimitOut => upperLimitOut,
                                   includeLowerLimitOut => includeLowerLimitOut,
                                   includeUpperLimitOut => includeUpperLimitOut,
                                   currencyCodeOut => currencyCodeOut,
                                   allowedValuesOut => allowedValuesOut);
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api',
                                  routineNameIn => 'getConditionDetails',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
    end getConditionDetails;
  procedure getGroupMembers(applicationIdIn in number,
                            transactionTypeIn in varchar2,
                            transactionIdIn in varchar2,
                            groupIdIn in number,
                            memberOrderNumbersOut out  nocopy ame_util.idList,
                            memberPersonIdsOut out  nocopy ame_util.idList,
                            memberUserIdsOut out  nocopy ame_util.idList) as
    begin
      null;
    end getGroupMembers;
  procedure getNextApprover(applicationIdIn in integer,
                            transactionIdIn in varchar2,
                            transactionTypeIn in varchar2 default null,
                            nextApproverOut out nocopy ame_util.approverRecord) as
    ameApplicationId integer;
    approvalProcessCompleteYN ame_util.charType;
    counter integer;
    nextApprovers ame_util.approversTable2;
    parallelizationFoundException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      loop
        ame_util2.detailedApprovalStatusFlagYN := ame_util.booleanTrue;
        ame_api2.getNextApprovers4(applicationIdIn => applicationIdIn,
                                   transactionTypeIn => transactionTypeIn,
                                   transactionIdIn => transactionIdIn,
                                   flagApproversAsNotifiedIn => ame_util.booleanFalse,
                                   approvalProcessCompleteYNOut => approvalProcessCompleteYN,
                                   nextApproversOut => nextApprovers);
        if ameApplicationId is null then
          ameApplicationId := ame_engine.getAmeApplicationId;
        end if;
        if approvalProcessCompleteYN = ame_util2.completeFullyApproved or
           approvalProcessCompleteYN = ame_util2.completeFullyRejected or
           approvalProcessCompleteYN = ame_util2.completePartiallyApproved or
           approvalProcessCompleteYN = ame_util2.completeNoApprovers then
          nextApproverOut := ame_util.emptyApproverRecord;
          exit;
        else
          if(nextApprovers.count > 1) then
            raise parallelizationFoundException;
          end if;
          counter := 0;
          for i in 1 .. nextApprovers.count loop
            if nextApprovers(i).approver_category = ame_util.approvalApproverCategory then
              counter := i;
              exit;
            else
              update ame_temp_old_approver_lists
                set approval_status = ame_util.notifiedStatus
                where item_class = nextApprovers(i).item_class and
                      item_id = nextApprovers(i).item_id and
                      name = nextApprovers(i).name and
                      action_type_id = nextApprovers(i).action_type_id and
                      group_or_chain_id = nextApprovers(i).group_or_chain_id and
                      occurrence = nextApprovers(i).occurrence and
                      transaction_id = transactionIdIn  and
                      application_id = ameApplicationId;
            end if;
          end loop;
          if counter <> 0 then
            ame_util.apprRecord2ToApprRecord(approverRecord2In => nextApprovers(counter),
                                    approverRecordOut => nextApproverOut);
            exit;
          end if;
        end if;
     end loop;
/*  delete after talking to TM and SS - nsoni
      ame_api2.getNextApprovers4(applicationIdIn => applicationIdIn,
                                 transactionTypeIn => transactionTypeIn,
                                 transactionIdIn => transactionIdIn,
                                 flagApproversAsNotifiedIn => ame_util.booleanFalse,
                                 approvalProcessCompleteYNOut => approvalProcessCompleteYN,
                                 nextApproversOut => nextApprovers);
      if approvalProcessCompleteYN = ame_util.booleanTrue then
        nextApproverOut := ame_util.emptyApproverRecord;
      else
        ame_util.apprRecord2ToApprRecord(approverRecord2In => nextApprovers(1),
                                approverRecordOut => nextApproverOut);
      end if;
*/
    exception
      when parallelizationFoundException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400679_API_PARALLEL_CONFIG');
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'getNextApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
      when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'getNextApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          getAdminApprover(applicationIdIn => applicationIdIn,
                           transactionTypeIn => transactionTypeIn,
                           adminApproverOut => nextApproverOut);
          raise;
    end getNextApprover;
  procedure getOldApprovers(applicationIdIn in integer,
                            transactionIdIn in varchar2,
                            transactionTypeIn in varchar2 default null,
                            oldApproversOut out nocopy ame_util.approversTable) as
    approvers ame_util.approversTable2;
    begin
      ame_api3.getOldApprovers(applicationIdIn => applicationIdIn,
                               transactionIdIn => transactionIdIn,
                               transactionTypeIn => transactionTypeIn,
                               oldApproversOut => approvers);
      ame_util.apprTable2ToApprTable(approversTable2In => approvers,
                            approversTableOut => oldApproversOut);
    exception
      when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'getOldApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          oldApproversOut.delete;
          getAdminApprover(applicationIdIn => applicationIdIn,
                           transactionTypeIn => transactionTypeIn,
                           adminApproverOut => oldApproversOut(1));
          raise;
    end getOldApprovers;
  procedure getRuleDetails1(ruleIdIn in integer,
                            ruleTypeOut out nocopy varchar2,
                            ruleDescriptionOut out nocopy varchar2,
                            conditionIdsOut out nocopy ame_util.idList,
                            approvalTypeNameOut out nocopy varchar2,
                            approvalTypeDescriptionOut out nocopy varchar2,
                            approvalDescriptionOut out nocopy varchar2) as
      approvalTypeNames ame_util.stringList;
      approvalTypeDescriptions ame_util.stringList;
      approvalDescriptions ame_util.stringList;
    begin
      ame_api3.getRuleDetails1(ruleIdIn => ruleIdIn,
                               ruleTypeOut => ruleTypeOut,
                               ruleDescriptionOut => ruleDescriptionOut,
                               conditionIdsOut => conditionIdsOut,
                               actionTypeNamesOut => approvalTypeNames,
                               actionTypeDescriptionsOut => approvalTypeDescriptions,
                               actionDescriptionsOut => approvalDescriptions);
        if approvalTypeNames.count = 0 then
          approvalTypeNameOut := null;
          approvalTypeDescriptionOut := null;
          approvalDescriptionOut := null;
        else
          approvalTypeNameOut := approvalTypeNames(1);
          approvalTypeDescriptionOut := approvalTypeDescriptions(1);
          approvalDescriptionOut := approvalDescriptions(1);
        end if;
    exception
      when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'getRuleDetails1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          conditionIdsOut.delete;
          raise;
    end getRuleDetails1;
  procedure getRuleDetails2(ruleIdIn in integer,
                            ruleTypeOut out nocopy varchar2,
                            ruleDescriptionOut out nocopy varchar2,
                            conditionDescriptionsOut out nocopy ame_util.longestStringList,
                            approvalTypeNameOut out nocopy varchar2,
                            approvalTypeDescriptionOut out nocopy varchar2,
                            approvalDescriptionOut out nocopy varchar2) as
      approvalTypeNames ame_util.stringList;
      approvalTypeDescriptions ame_util.stringList;
      approvalDescriptions ame_util.stringList;
    begin
      ame_api3.getRuleDetails2(ruleIdIn => ruleIdIn,
                               ruleTypeOut => ruleTypeOut,
                               ruleDescriptionOut => ruleDescriptionOut,
                               conditionDescriptionsOut => conditionDescriptionsOut,
                               actionTypeNamesOut => approvalTypeNames,
                               actionTypeDescriptionsOut => approvalTypeDescriptions,
                               actionDescriptionsOut => approvalDescriptions);
        if approvalTypeNames.count = 0 then
          approvalTypeNameOut := null;
          approvalTypeDescriptionOut := null;
          approvalDescriptionOut := null;
        else
          approvalTypeNameOut := approvalTypeNames(1);
          approvalTypeDescriptionOut := approvalTypeDescriptions(1);
          approvalDescriptionOut := approvalDescriptions(1);
        end if;
    exception
      when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'getRuleDetails2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          conditionDescriptionsOut.delete;
          raise;
    end getRuleDetails2;
  procedure getRuleDetails3(ruleIdIn in integer,
                            ruleTypeOut out nocopy varchar2,
                            ruleDescriptionOut out nocopy varchar2,
                            conditionIdsOut out nocopy ame_util.idList,
                            conditionDescriptionsOut out nocopy ame_util.longestStringList,
                            conditionHasLOVsOut out nocopy ame_util.charList,
                              /* Each value is ame_util.booleanTrue or ame_util.booleanFalse. */
                            approvalTypeNameOut out nocopy varchar2,
                            approvalTypeDescriptionOut out nocopy varchar2,
                            approvalDescriptionOut out nocopy varchar2) as
      approvalTypeNames ame_util.stringList;
      approvalTypeDescriptions ame_util.stringList;
      approvalDescriptions ame_util.stringList;
    begin
      ame_api3.getRuleDetails3(ruleIdIn => ruleIdIn,
                               ruleTypeOut => ruleTypeOut,
                               ruleDescriptionOut => ruleDescriptionOut,
                               conditionIdsOut => conditionIdsOut,
                               conditionDescriptionsOut => conditionDescriptionsOut,
                               conditionHasLOVsOut => conditionHasLOVsOut,
                               actionTypeNamesOut => approvalTypeNames,
                               actionTypeDescriptionsOut => approvalTypeDescriptions,
                               actionDescriptionsOut => approvalDescriptions);
        if approvalTypeNames.count = 0 then
          approvalTypeNameOut := null;
          approvalTypeDescriptionOut := null;
          approvalDescriptionOut := null;
        else
          approvalTypeNameOut := approvalTypeNames(1);
          approvalTypeDescriptionOut := approvalTypeDescriptions(1);
          approvalDescriptionOut := approvalDescriptions(1);
        end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'getRuleDetails3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          conditionIdsOut.delete;
          conditionDescriptionsOut.delete;
          raise;
    end getRuleDetails3;
  procedure initializeApprovalProcess(applicationIdIn in integer,
                                      transactionIdIn in varchar2,
                                      transactionTypeIn in varchar2 default null,
                                      recordApproverListIn in boolean default false) as
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_api2.initializeApprovalProcess(applicationIdIn => applicationIdIn,
                                         transactionIdIn => transactionIdIn,
                                         transactionTypeIn => transactionTypeIn,
                                         recordApproverListIn => recordApproverListIn);
    exception
      when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'initializeApprovalProcess',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end initializeApprovalProcess;
  procedure insertApprover(applicationIdIn in integer,
                           transactionIdIn in varchar2,
                           approverIn in ame_util.approverRecord,
                           positionIn in integer,
                           orderIn in ame_util.orderRecord,
                           transactionTypeIn in varchar2 default null) as
    approver ame_util.approverRecord2;
    i integer;
    tempParameter ame_util.longestStringType;
    insertion ame_util.insertionRecord2;
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_util.apprRecordToApprRecord2(approverRecordIn => approverIn,
                              itemIdIn => transactionIdIn,
                              approverRecord2Out =>approver);
      ame_util.ordRecordToInsRecord2(orderRecordIn => orderIn,
                            transactionIdIn => transactionIdIn,
                            approverIn => approverIn,
                            insertionRecord2Out =>  insertion );
      approver.action_type_id := insertion.action_type_id;
      approver.group_or_chain_id  := insertion.group_or_chain_id ;
      ame_api3.insertApprover(applicationIdIn => applicationIdIn,
                              transactionTypeIn => transactionTypeIn,
                              transactionIdIn => transactionIdIn,
                              approverIn => approver,
                              positionIn => positionIn,
                              insertionIn =>insertion );
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'insertApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end insertApprover;
  procedure setFirstAuthorityApprover(applicationIdIn in integer,
                                      transactionIdIn in varchar2,
                                      approverIn in ame_util.approverRecord,
                                      transactionTypeIn in varchar2 default null) as
    approver ame_util.approverRecord2;
    approversCount integer;
    approvalProcessCompleteYN ame_util.charType;
    approvers ame_util.approversTable2;
    chainToBeInserted boolean;
    currentActionTypeId integer;
    currentGroupOrChainId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    newChainFound boolean;
    tempCount integer;
    tooLateException exception;
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      /* call ame_engine.UpdateTransactionState  */
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
      /* Get the existing approver list (approvers)  */
      ame_engine.getApprovers(approversOut => approvers);
      approversCount := approvers.count;
      /* Iterate thru the approver list identifying each action_type_id /group_or_chain_id
         for authority approvers */
      currentActionTypeId := null;
      currentGroupOrChainId := null;
      for i in 1 .. approvers.count loop
        newChainFound := false;
        if (approvers(i).authority = ame_util.authorityApprover and
            approvers(i).item_class = ame_util.headerItemClassName and
            approvers(i).item_id = transactionIdIn ) then
          if (currentActionTypeId is null and
              currentGroupOrChainId is null ) then
            currentActionTypeId := approvers(i).action_type_id;
            currentGroupOrChainId := approvers(i).group_or_chain_id;
            newChainFound := true;
          elsif ((currentActionTypeId = approvers(i).action_type_id) and
                 (currentGroupOrChainId = approvers(i).group_or_chain_id)) then
            newChainFound := false;  /* same chain continues */
          else /* A new chain or a new action type id is found */
            currentActionTypeId := approvers(i).action_type_id;
            currentGroupOrChainId := approvers(i).group_or_chain_id;
            newChainFound := true;
          end if;
          if newChainFound then
            /* check that this action_type_id uses only those approver types which
               correspond to orig_system 'PER'.  */
            chainToBeInserted := false;
            begin
              select count(*)
                into tempCount
                from ame_approver_type_usages
                where action_type_id = currentActionTypeId
                  and approver_type_id not in (select approver_type_id
                                       from ame_approver_types
                                       where orig_system = ame_util.perOrigSystem) ;
              if tempCount = 0 then
                chainToBeInserted := true;
              else
                chainToBeInserted := false;
              end if;
            exception
              when no_data_found then
                chainToBeInserted := true;
              when others then
                chainToBeInserted := false;
            end;
            if chainToBeInserted then
              /* convert approverIn to ame_util.approverRecord2, set action_type_id
                 and group_or_chain_id. Call ame_api2.setFirstAuthorityApprover*/
              ame_util.apprRecordToApprRecord2(approverRecordIn => approverIn,
                                      itemIdIn => transactionIdIn,
                                      approverRecord2Out =>approver);
              approver.action_type_id := currentActionTypeId;
              approver.group_or_chain_id := currentGroupOrChainId;
              ame_api2.setFirstAuthorityApprover(applicationIdIn => applicationIdIn,
                                                 transactionIdIn => transactionIdIn,
                                                 approverIn => approver,
                                                 transactionTypeIn => transactionTypeIn,
                                                 clearChainStatusYNIn => 'Y');
            end if;
          end if;
        end if;
      end loop;
      exception
        when tooLateException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400244_API_CHN_AUTH_TRANS');
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'setFirstAuthorityApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'setFirstAuthorityApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end setFirstAuthorityApprover;
  procedure updateApprovalStatus(applicationIdIn in integer,
                                 transactionIdIn in varchar2,
                                 approverIn in ame_util.approverRecord,
                                 transactionTypeIn in varchar2 default null,
                                 forwardeeIn in ame_util.approverRecord default ame_util.emptyApproverRecord) as
    approver ame_util.approverRecord2;
    forwardee ame_util.approverRecord2;
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      ame_util.apprRecordToApprRecord2(approverRecordIn => approverIn,
                              itemIdIn => transactionIdIn,
                              approverRecord2Out =>approver);
      if (forwardeeIn.person_id is null and forwardeeIn.user_id is null) then
        forwardee := ame_util.emptyApproverRecord2;
      else
        ame_util.apprRecordToApprRecord2(approverRecordIn => forwardeeIn,
                              itemIdIn => transactionIdIn,
                              approverRecord2Out =>forwardee);
      end if;
      ame_api2.updateApprovalStatus(applicationIdIn => applicationIdIn,
                                    transactionIdIn => transactionIdIn,
                                    approverIn => approver,
                                    transactionTypeIn => transactionTypeIn,
                                    forwardeeIn => forwardee);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'updateApprovalStatus',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end updateApprovalStatus;
  procedure updateApprovalStatus2(applicationIdIn in integer,
                                  transactionIdIn in varchar2,
                                  approvalStatusIn in varchar2,
                                  approverPersonIdIn in integer default null,
                                  approverUserIdIn in integer default null,
                                  transactionTypeIn in varchar2 default null,
                                  forwardeeIn in ame_util.approverRecord default ame_util.emptyApproverRecord,
                                  approvalTypeIdIn in integer default null,
                                  groupOrChainIdIn in integer default null,
                                  occurrenceIn in integer default null) as
    forwardee ame_util.approverRecord2;
    approverOrigSystem ame_util.stringType;
    approverOrigSystemId integer;
    approverName ame_util.stringType;
    begin
      check11510(applicationIdIn   => applicationIdIn,
                 transactionTypeIn => transactionTypeIn);
      if approverPersonIdIn is not null then
        approverOrigSystem := ame_util.perOrigSystem;
        approverOrigSystemId := approverPersonIdIn;
      else
        approverOrigSystem := ame_util.fndUserOrigSystem;
        approverOrigSystemId := approverUserIdIn;
      end if;
      approverName := ame_approver_type_pkg.getWfRolesName(origSystemIn => approverOrigSystem,
                                             origSystemIdIn => approverOrigSystemId);
      if (forwardeeIn.person_id is null and forwardeeIn.user_id is null) then
        forwardee := ame_util.emptyApproverRecord2;
      else
        ame_util.apprRecordToApprRecord2(approverRecordIn => forwardeeIn,
                              itemIdIn => transactionIdIn,
                              approverRecord2Out =>forwardee);
      end if;
       ame_api2.updateApprovalStatus2(applicationIdIn => applicationIdIn,
                                      transactionTypeIn => transactionTypeIn,
                                      transactionIdIn => transactionIdIn,
                                      approvalStatusIn => approvalStatusIn,
                                      approverNameIn=> approverName,
                                      itemClassIn => ame_util.headerItemClassName,
                                      itemIdIn => transactionIdIn,
                                      actionTypeIdIn => approvalTypeIdIn,
                                      groupOrChainIdIn => groupOrChainIdIn,
                                      occurrenceIn => occurrenceIn,
                                      forwardeeIn => forwardee);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api',
                                    routineNameIn => 'updateApprovalStatus2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end updateApprovalStatus2;
end ame_api;

/
