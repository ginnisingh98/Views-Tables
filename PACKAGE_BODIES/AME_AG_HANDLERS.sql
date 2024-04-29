--------------------------------------------------------
--  DDL for Package Body AME_AG_HANDLERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_AG_HANDLERS" as
/* $Header: ameeagha.pkb 120.1.12010000.2 2009/10/09 07:15:29 prasashe ship $ */
  /* package variables */
  approverCategories ame_util.charList;
  groupIds ame_util.idList;
  groupOrderNumbers ame_util.idList;
  ruleIds ame_util.idList;
  parameters ame_util.stringList;
  parameterTwos ame_util.stringList;
  sources ame_util.longStringList;
  votingRegimes ame_util.charList;
  /* forward declarations */
  procedure eliminateDuplicates;
  /* procedures */
  procedure handler as
    allowEmptyGroups boolean;
    currentApproverGrpMemberCount integer;
    currentApproverGroupId integer;
    emptyGroupException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    tempApprover ame_util.approverRecord2;
    tempApproverDisplayNames ame_util.longStringList;
    tempApproverNames ame_util.longStringList;
    tempApproverOrderNumbers ame_util.idList;
    tempIndex integer;
    tempOrigSystemIds ame_util.idList;
    tempOrigSystems ame_util.stringList;
    begin
      /*
        The engine only calls a handler if a rule requiring it exists, so we can assume that
        the package variables that ame_engine.getHandlerRules initializes are nonempty.
      */
      ame_engine.getHandlerRules(ruleIdsOut => ruleIds,
                                 approverCategoriesOut => approverCategories,
                                 parametersOut => parameters,
                                 parameterTwosOut => parameterTwos);
      /* Initialize the source list. */
      for i in 1 .. ruleIds.count loop
        sources(i) := to_char(ruleIds(i));
      end loop;
      /*
        Convert the parameters to group IDs (integers), then fetch the groups' order numbers
        and ordering modes.
      */
      ame_util.stringListToIdList(stringListIn => parameters,
                                  idListOut => groupIds);
      /* Bug:4491715 when get configs we sort group ids so corresponding sources and categories
         must also be sorted */
      ame_engine.getApprovalGroupConfigs(groupIdsInOut => groupIds,
                                         sourcesInOut => sources,
                                         approverCategoriesInOut => approverCategories,
                                         orderNumbersOut => groupOrderNumbers,
                                         votingRegimesOut => votingRegimes);
      /* Eliminate duplicate group-ID entries, possibly leaving the package-variable lists sparse. */
      eliminateDuplicates;
      /* Find the transaction allows empty approval groups or not */
      allowEmptyGroups :=
         ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.allowEmptyGroupAttribute)
                       = ame_util.booleanAttributeTrue;
      /* Set the fields in tempApprover that are constant for the entire handler cycle. */
      tempApprover.api_insertion := ame_util.oamGenerated;
      tempApprover.authority := ame_engine.getHandlerAuthority;
      tempApprover.action_type_id := ame_engine.getHandlerActionTypeId;
      tempApprover.item_class := ame_engine.getHandlerItemClassName;
      tempApprover.item_id := ame_engine.getHandlerItemId;
      tempApprover.item_class_order_number := ame_engine.getHandlerItemClassOrderNumber;
      tempApprover.item_order_number := ame_engine.getHandlerItemOrderNumber;
      tempApprover.sub_list_order_number := ame_engine.getHandlerSublistOrderNum;
      tempApprover.action_type_order_number := ame_engine.getHandlerActionTypeOrderNum;
      /*
      /*
        Now iterate through the sorted groups, adding their membership to the engine's
        approver list in the group-member order dictated by the group's voting regime
        (and possibly its members' order numbers).
      */
      tempIndex := groupIds.first;
      while(tempIndex is not null) loop
        /* Clear the group-member buffers of any previous data. */
        tempApproverNames.delete;
        tempApproverOrderNumbers.delete;
        tempApproverDisplayNames.delete;
        tempOrigSystemIds.delete;
        tempOrigSystems.delete;
        /* Fetch the group's membership. */
        ame_engine.getRuntimeGroupMembers(groupIdIn => groupIds(tempIndex),
                                          approverNamesOut => tempApproverNames,
                                          approverOrderNumbersOut => tempApproverOrderNumbers,
                                          approverDisplayNamesOut => tempApproverDisplayNames,
                                          origSystemIdsOut => tempOrigSystemIds,
                                          origSystemsOut => tempOrigSystems);
        currentApproverGrpMemberCount := tempApproverNames.count;
        currentApproverGroupId := groupIds(tempIndex);
        /* Throw error if the current group is empty and the transaction
           doesnt accept empty groups */
        if(not allowEmptyGroups and currentApproverGrpMemberCount = 0 ) then
          raise emptyGroupException;
        end if;
        /* Add the group's members to the approver list. */
        for i in 1 .. tempApproverNames.count loop
          tempApprover.name := tempApproverNames(i);
          tempApprover.orig_system := tempOrigSystems(i);
          tempApprover.orig_system_id := tempOrigSystemIds(i);
          tempApprover.display_name := tempApproverDisplayNames(i);
          tempApprover.approver_category := approverCategories(tempIndex);
          tempApprover.group_or_chain_id := groupIds(tempIndex);
          tempApprover.occurrence := ame_engine.getHandlerOccurrence(nameIn =>  tempApprover.name,
                                                itemClassIn => tempApprover.item_class,
                                                itemIdIn => tempApprover.item_id,
                                                actionTypeIdIn => tempApprover.action_type_id,
                                                groupOrChainIdIn => tempApprover.group_or_chain_id);
          tempApprover.source := sources(tempIndex);
          tempApprover.group_or_chain_order_number := groupOrderNumbers(tempIndex);
          if(votingRegimes(tempIndex) = ame_util.orderNumberVoting) then
            tempApprover.member_order_number := tempApproverOrderNumbers(i);
          elsif(votingRegimes(tempIndex) = ame_util.serializedVoting) then
            tempApprover.member_order_number := i;
          else /* votingRegimes(i) in (ame_util.consensusVoting, ame_util.firstApproverVoting) */
            tempApprover.member_order_number := 1;
          end if;
          tempApprover.approval_status := ame_engine.getHandlerApprovalStatus(approverIn  => tempApprover,
                                                                              votingRegimeIn => votingRegimes(tempIndex));
          /*
            The engine will set tempApprover.approver_order_number; leave them null here.
          */
          ame_engine.addApprover(approverIn => tempApprover);
        end loop;
        tempIndex := groupIds.next(tempIndex);
      end loop;
      exception
        when emptyGroupException then
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn     => 'AME_400229_HAN_APR_NO_MEM',
            tokenNameOneIn    => 'APPROVAL_GROUP',
            tokenValueOneIn   => ame_approval_group_pkg.getName(approvalGroupIdIn => currentApproverGroupId));
          ame_util.runtimeException(packageNameIn => 'ame_ag_handlers',
                                    routineNameIn => 'handler',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_ag_handlers',
                                    routineNameIn => 'handler',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end handler;
  procedure eliminateDuplicates as
    begin
      for i in 2 .. groupIds.count loop
        if(groupIds(i) = groupIds(i - 1)) then
          /*
            Preserve the deleted rule's ID in the preserved rule's source field, if space permits.
            In the very unlikely event otherwise, silently omit the extra source value(s).  (This
            is the same functionality as ame_util.appendRuleIdToSource, but here we could be
            appending several rule IDs, so we can't use that procedure.)
          */
          if(lengthb(sources(i - 1)) + lengthb(sources(i)) + 1 <= ame_util.longStringTypeLength) then
            sources(i) := sources(i) || ame_util.fieldDelimiter || sources(i - 1);
          end if;
          /* Make sure the dominant approver category is preserved. */
          if(approverCategories(i) <> ame_util.approvalApproverCategory and
             approverCategories(i - 1) = ame_util.approvalApproverCategory) then
            approverCategories(i) := ame_util.approvalApproverCategory;
          end if;
          /* Delete the duplicate group. */
          approverCategories.delete(i - 1);
          groupIds.delete(i - 1);
          groupOrderNumbers.delete(i - 1);
          ruleIds.delete(i - 1);
          parameters.delete(i - 1);
          parameterTwos.delete(i - 1);
          sources.delete(i - 1);
          votingRegimes.delete(i - 1);
        end if;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_ag_handlers',
                                    routineNameIn => 'eliminateDuplicates',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end eliminateDuplicates;
end ame_ag_handlers;

/
