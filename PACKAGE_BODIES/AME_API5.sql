--------------------------------------------------------
--  DDL for Package Body AME_API5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_API5" as
/* $Header: ameeapi5.pkb 120.4 2007/12/12 12:43:13 prasashe noship $ */
  /* procedures */
  procedure  clearItemClassApprovals1(applicationIdIn    in number,
                                      transactionTypeIn  in varchar2,
                                      transactionIdIn    in varchar2,
                                      itemClassIdIn      in number,
                                      itemIdIn           in varchar2 default null)as
    ameAppId integer;
    invalidItemClassException exception;
    cursor chkItemClass is
      select name
        from ame_item_classes
        where item_class_id  = itemClassIdIn
          and sysdate between start_date and nvl(end_date - ame_util.oneSecond, sysdate);
    item_class_name ame_item_classes.name%type;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    begin
      ame_engine.lockTransaction(fndApplicationIdIn => applicationIdIn,
                                 transactionIdIn => transactionIdIn,
                                 transactionTypeIdIn => transactionTypeIn);
      ameAppId := ame_admin_pkg.getApplicationId(fndAppIdIn => applicationIdIn,
                                                 transactionTypeIdIn => transactionTypeIn);
      -- check that the item class being passed in is valid
      open  chkItemClass;
      fetch chkItemClass into  item_class_name;
      if  chkItemClass%notFound then
        raise invalidItemClassException;
      end if;
      -- update the approval status to null
      update  ame_temp_old_approver_lists
        set approval_status = null
        where
          application_id = ameAppId and
          transaction_id = transactionIdIn and
          item_class = item_class_name and
           (itemIdIn is null  or
            item_id = itemIdIn);
      if sql%found then
        ame_approver_deviation_pkg.clearDeviationState(
                        applicationIdIn  => ameAppId
                       ,transactionIdIn => transactionIdIn );
      end if;
      /* update all existing history rows from the Approval Notification History table
         to indicate the rows were cleared */
      update AME_TRANS_APPROVAL_HISTORY  set
        date_cleared = sysdate
        where
          application_id = ameAppId and
          transaction_id = transactionIdIn and
          item_class = item_class_name and
           (itemIdIn is null  or
            item_id = itemIdIn) and
          date_cleared is null;
    exception
      when invalidItemClassException then
        ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_99999_INVALID_ITEM_CLASS');
        ame_util.runtimeException(packageNameIn => 'ame_api3',
                                  routineNameIn => 'getAvailableInsertions',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                errorMessage);
      when others then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'clearAllApprovals',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end clearItemClassApprovals1;
  procedure  clearItemClassApprovals2(applicationIdIn    in number,
                                      transactionTypeIn  in varchar2,
                                      transactionIdIn    in varchar2,
                                      itemClassNameIn    in varchar2,
                                      itemIdIn           in varchar2 default null)as
    ameAppId integer;
    invalidItemClassException exception;
    cursor chkItemClass is
      select item_class_id
        from ame_item_classes
        where name  = itemClassNameIn
          and sysdate between start_date and nvl(end_date - ame_util.oneSecond, sysdate);
    item_class_id ame_item_classes.item_class_id%type;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    begin
      ame_engine.lockTransaction(fndApplicationIdIn => applicationIdIn,
                                 transactionIdIn => transactionIdIn,
                                 transactionTypeIdIn => transactionTypeIn);
      ameAppId := ame_admin_pkg.getApplicationId(fndAppIdIn => applicationIdIn,
                                                 transactionTypeIdIn => transactionTypeIn);
      -- check that the item class being passed in is valid
      open  chkItemClass;
      fetch chkItemClass into  item_class_id;
      if  chkItemClass%notFound then
        raise invalidItemClassException;
      end if;
      -- update the approval status to null
      update  ame_temp_old_approver_lists
        set approval_status = null
        where
          application_id = ameAppId and
          transaction_id = transactionIdIn and
          item_class = itemClassNameIn and
           (itemIdIn is null  or
            item_id = itemIdIn);
      if sql%found then
        ame_approver_deviation_pkg.clearDeviationState(
                        applicationIdIn  => ameAppId
                       ,transactionIdIn => transactionIdIn );
      end if;
      /* update all existing history rows from the Approval Notification History table
         to indicate the rows were cleared */
      update AME_TRANS_APPROVAL_HISTORY  set
        date_cleared = sysdate
        where
          application_id = ameAppId and
          transaction_id = transactionIdIn and
          item_class = itemClassNameIn and
           (itemIdIn is null  or
            item_id = itemIdIn) and
          date_cleared is null;
    exception
      when invalidItemClassException then
        ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_99999_INVALID_ITEM_CLASS');
        ame_util.runtimeException(packageNameIn => 'ame_api3',
                                  routineNameIn => 'getAvailableInsertions',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                errorMessage);
      when others then
          ame_engine.unlockTransaction(fndApplicationIdIn => applicationIdIn,
                                       transactionIdIn => transactionIdIn,
                                       transactionTypeIdIn => transactionTypeIn);
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'clearAllApprovals',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end clearItemClassApprovals2;
  procedure  getApprovalGroupName(groupIdIn   in   number
                                 ,groupNameOut out nocopy ame_util.stringType) as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    begin
      select name
        into groupNameOut
        from ame_approval_groups
        where approval_group_id = groupIdIn
          and sysdate between start_date
             and nvl(end_date - ame_util.oneSecond, sysdate);
    exception
      when no_data_found then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400453_GROUP_NOT_DEFINED',
                           tokenNameOneIn  => 'APPROVAL_GROUP',
                           tokenValueOneIn => groupIdIn);
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
  end getApprovalGroupName;

  procedure getAllApproversAndInsertions
    (applicationIdIn                in            number
    ,transactionTypeIn              in            varchar2
    ,transactionIdIn                in            varchar2
    ,activeApproversYNIn            in            varchar2 default ame_util.booleanFalse
    ,coaInsertionsYNIn              in            varchar2 default ame_util.booleanFalse
    ,approvalProcessCompleteYNOut      out nocopy varchar2
    ,approversOut                      out nocopy ame_util.approversTable2
    ,availableInsertionsOut            out nocopy ame_util2.insertionsTable3
    ) as

    allApprovers                       ame_util.approversTable2;
    positionInsertions                 ame_util.insertionsTable2;
    nextAvailableInsertionIndex        integer;
    lastActiveApproverIndex            integer;
    tempCount                          integer;

    procedure copyInsRec2ToInsRec3
      (insertionRec2In                in            ame_util.insertionRecord2
      ,insertionRec3Out                  out nocopy ame_util2.insertionRecord3
      ) as
    begin
      insertionRec3Out.item_class := insertionRec2In.item_class;
      insertionRec3Out.item_id := insertionRec2In.item_id;
      insertionRec3Out.action_type_id := insertionRec2In.action_type_id;
      insertionRec3Out.group_or_chain_id := insertionRec2In.group_or_chain_id;
      insertionRec3Out.order_type := insertionRec2In.order_type;
      insertionRec3Out.parameter := insertionRec2In.parameter;
      insertionRec3Out.api_insertion := insertionRec2In.api_insertion;
      insertionRec3Out.authority := insertionRec2In.authority;
      insertionRec3Out.description := insertionRec2In.description;
    end copyInsRec2ToInsRec3;

  begin
    /* Check if the fnd application and transaction type combination is valid. */
    select count(*)
      into tempCount
      from ame_calling_apps
     where sysdate between start_date and nvl(end_date - (1/86400),sysdate)
       and fnd_application_id = applicationIdIn
       and transaction_type_id = transactionTypeIn;
     if tempCount = 0 then
       fnd_message.set_name('PER','AME_400791_INV_FND_APPS_TTY');
       fnd_message.raise_error;
     end if;
--+
    /* Invoke the engine and generate the approver list */
    ame_engine.updateTransactionState
      (isTestTransactionIn          => false
      ,isLocalTransactionIn         => false
      ,fetchConfigVarsIn            => true
      ,fetchOldApproversIn          => true
      ,fetchInsertionsIn            => true
      ,fetchDeletionsIn             => true
      ,fetchAttributeValuesIn       => true
      ,fetchInactiveAttValuesIn     => false
      ,processProductionActionsIn   => false
      ,processProductionRulesIn     => false
      ,updateCurrentApproverListIn  => true
      ,updateOldApproverListIn      => false
      ,processPrioritiesIn          => true
      ,prepareItemDataIn            => false
      ,prepareRuleIdsIn             => false
      ,prepareRuleDescsIn           => false
      ,prepareApproverTreeIn        => true
      ,transactionIdIn              => transactionIdIn
      ,ameApplicationIdIn           => null
      ,fndApplicationIdIn           => applicationIdIn
      ,transactionTypeIdIn          => transactionTypeIn
      );

    /* Get all approvers from the engine */
    ame_engine.getApprovers
      (approversOut => allApprovers);

    /* Get transaction's approval status from the engine */
    approvalProcessCompleteYNOut := ame_engine.getApprovalProcessCompleteYN;

    nextAvailableInsertionIndex := 0;

    /* Copy approver records from input to output only if approvers are present */
    if allApprovers.count > 0 then
      for i in 1 .. allApprovers.count loop
        if activeApproversYNIn = ame_util.booleanTrue then
          if allApprovers(i).approval_status is null or
             allApprovers(i).approval_status in
               (ame_util.approveAndForwardStatus
               ,ame_util.approvedStatus
               ,ame_util.beatByFirstResponderStatus
               ,ame_util.forwardStatus
               ,ame_util.noResponseStatus
               ,ame_util.notifiedStatus
              ,ame_util.rejectStatus) then
            ame_util.copyApproverRecord2
              (approverRecord2In    => allApprovers(i)
              ,approverRecord2Out   => approversOut(i)
              );

            positionInsertions.delete;

            /* Get available insertions at position i from the engine */
            ame_engine.getInsertions
              (positionIn               => i
              ,orderTypeIn              => null
              ,coaInsertionsYNIn        => coaInsertionsYNIn
              ,availableInsertionsOut   => positionInsertions
              );

            /* Copy insertion records only if insertions are available at this position */
            if positionInsertions.count > 0 then
              for j in 1 .. positionInsertions.count loop
                nextAvailableInsertionIndex := nextAvailableInsertionIndex + 1;
                copyInsRec2ToInsRec3
                  (insertionRec2In  => positionInsertions(j)
                  ,insertionRec3Out => availableInsertionsOut(nextAvailableInsertionIndex)
                  );
                availableInsertionsOut(nextAvailableInsertionIndex).position := i;
              end loop;
            end if;

          end if;
        else /* if activeApproversYNIn = ame_util.booleanFalse */
          ame_util.copyApproverRecord2
            (approverRecord2In    => allApprovers(i)
            ,approverRecord2Out   => approversOut(i)
            );

          positionInsertions.delete;

          /* Get available insertions at position i from the engine */
          ame_engine.getInsertions
            (positionIn               => i
            ,orderTypeIn              => null
            ,coaInsertionsYNIn        => coaInsertionsYNIn
            ,availableInsertionsOut   => positionInsertions
            );

          /* Copy insertion records only if insertions are available at this position */
          if positionInsertions.count > 0 then
            for j in 1 .. positionInsertions.count loop
              nextAvailableInsertionIndex := nextAvailableInsertionIndex + 1;
              copyInsRec2ToInsRec3
                (insertionRec2In  => positionInsertions(j)
                ,insertionRec3Out => availableInsertionsOut(nextAvailableInsertionIndex)
                );
              availableInsertionsOut(nextAvailableInsertionIndex).position := i;
            end loop;
          end if;
        end if;
      end loop;
    end if;

    /* If all approvers are active or we want all approvers */
    /* Also takes care when no approvers are present */
    if allApprovers.count = approversOut.count or
       activeApproversYNIn = ame_util.booleanFalse then

      positionInsertions.delete;

      /* Get available insertions at position i from the engine */
      ame_engine.getInsertions
        (positionIn               => allApprovers.count + 1
        ,orderTypeIn              => null
        ,coaInsertionsYNIn        => coaInsertionsYNIn
        ,availableInsertionsOut   => positionInsertions
        );

      /* Copy insertion records only if insertions are available at this position */
      if positionInsertions.count > 0 then
        for j in 1 .. positionInsertions.count loop
          nextAvailableInsertionIndex := nextAvailableInsertionIndex + 1;
          copyInsRec2ToInsRec3
            (insertionRec2In  => positionInsertions(j)
            ,insertionRec3Out => availableInsertionsOut(nextAvailableInsertionIndex)
            );
          availableInsertionsOut(nextAvailableInsertionIndex).position := allApprovers.count + 1;
        end loop;
      end if;
    else /* If active approvers are required and inactive approvers are present */

      /* Incase no approvers are active lastActiveApproverIndex must be 0 */
      /* else it will be the last active approver */
      lastActiveApproverIndex := 0;
      if approversOut.count > 0 then
        lastActiveApproverIndex := approversOut.last;
      end if;

      positionInsertions.delete;

      /* Get available insertions at position lastActiveApproverIndex + 1 from the engine */
      ame_engine.getInsertions
        (positionIn               => lastActiveApproverIndex + 1
        ,orderTypeIn              => null
        ,coaInsertionsYNIn        => coaInsertionsYNIn
        ,availableInsertionsOut   => positionInsertions
        );

      /* Copy insertion records only if insertions are available at this position */
      if positionInsertions.count > 0 then
        for j in 1 .. positionInsertions.count loop
          if positionInsertions(j).order_type <> ame_util.beforeApprover then
            nextAvailableInsertionIndex := nextAvailableInsertionIndex + 1;
            copyInsRec2ToInsRec3
              (insertionRec2In  => positionInsertions(j)
              ,insertionRec3Out => availableInsertionsOut(nextAvailableInsertionIndex)
              );
            availableInsertionsOut(nextAvailableInsertionIndex).position := lastActiveApproverIndex + 1;
          end if;
        end loop;
      end if;
    end if;

  exception
    when others then
      ame_util.runtimeException
        (packageNameIn      => 'ame_api5'
        ,routineNameIn      => 'getAllApproversAndInsertions'
        ,exceptionNumberIn  => sqlcode
        ,exceptionStringIn  => sqlerrm
        );
      approvalProcessCompleteYNOut := null;
      approversOut.delete;
      availableInsertionsOut.delete;
      raise;
  end getAllApproversAndInsertions;
end ame_api5;

/
