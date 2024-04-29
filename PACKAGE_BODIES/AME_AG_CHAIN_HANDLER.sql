--------------------------------------------------------
--  DDL for Package Body AME_AG_CHAIN_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_AG_CHAIN_HANDLER" as
/* $Header: ameegcha.pkb 120.4 2007/12/12 12:47:27 prasashe noship $ */
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
   /*  Procedures */
  procedure eliminateDuplicates as
    begin
      for i in 2 .. groupIds.count loop
        if(groupIds(i) = groupIds(i - 1)) then
          /*
            Preserve the deleted rule's ID in the preserved rule's source field, if space permits.
            In the very unlikely event otherwise, silently omit the extra source value(s).  (The
            alternative would be to raise an exception that would require for its solution either
            a code change or a change to the structure of the rules or transaction--none of which
            would please the end user.)
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
          ame_util.runtimeException(packageNameIn => 'ame_ag_chain_handler',
                                    routineNameIn => 'eliminateDuplicates',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end eliminateDuplicates;
  procedure handler as
    chainOrderMode ame_util.stringType;
    COAInsertee ame_util.approverRecord2;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    finalAuthorityFound boolean;
    groupOrderNumber integer;
    nullFirstIdException exception;
    requestorId integer;
    startingPointId integer;
    tempApprover ame_util.approverRecord2;
    tempApproverNames ame_util.longStringList;
    tempApproverOrderNumbers ame_util.idList;
    tempApproverDisplayNames ame_util.longStringList;
    tempOrigSystemIds ame_util.idList;
    tempOrigSystems ame_util.stringList;
    tempHasFinalAuthorityYN ame_util.charType;
    tempIndex integer;
    tempMemberOrderNumber integer := 1;
    tempSupervisorId integer;
    votingRegimeType ame_util.stringType;
    allowEmptyGroups boolean;
    currentApproverGrpMemberCount integer;
    currentApproverGroupId integer;
    emptyGroupException exception;
    begin
      /*
        The engine only calls a handler if a rule requiring it exists, so we can assume that
        the package variables that ame_engine.getHandlerRules initializes are nonempty.
        Fetch the rules and sort them in increasing parameter order.  (Duplicate parameters
        are harmless here.)
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
      tempApprover.orig_system := ame_util.perOrigSystem;
      tempApprover.authority := ame_util.authorityApprover;
      tempApprover.action_type_id := ame_engine.getHandlerActionTypeId;
      tempApprover.group_or_chain_id := groupIds(groupIds.first);
      tempApprover.api_insertion := ame_util.oamGenerated;
      tempApprover.item_class := ame_engine.getHandlerItemClassName;
      tempApprover.item_id := ame_engine.getHandlerItemId;
      tempApprover.item_class_order_number := ame_engine.getHandlerItemClassOrderNumber;
      tempApprover.item_order_number := ame_engine.getHandlerItemOrderNumber;
      tempApprover.sub_list_order_number := ame_engine.getHandlerSublistOrderNum;
      tempApprover.action_type_order_number := ame_engine.getHandlerActionTypeOrderNum;
      votingRegimeType := ame_engine.getActionTypeVotingRegime(actionTypeIdIn => tempApprover.action_type_id);
      chainOrderMode := ame_engine.getActionTypeChainOrderMode(actionTypeIdIn => tempApprover.action_type_id);
      /* Check for COA First Authority Insertion */
      ame_engine.getHandlerCOAFirstApprover(itemClassIn => tempApprover.item_class,
                                            itemIdIn => tempApprover.item_id,
                                            actionTypeIdIn => tempApprover.action_type_id,
                                            groupOrChainIdIn => tempApprover.group_or_chain_id,
                                            nameOut => COAInsertee.name,
                                            origSystemOut => COAInsertee.orig_system,
                                            origSystemIdOut => COAInsertee.orig_system_id,
                                            displayNameOut => COAInsertee.display_name,
                                            sourceOut => COAInsertee.source);
      /* If COA Insertee exists add as first approver and then continue normal processing */
      if COAInsertee.name is null then
        tempApprover.api_insertion := ame_util.oamGenerated;
        /* Bug fix 4468908 */
        groupOrderNumber := 1;
      else
        /* Bug fix 4468908 */
        groupOrderNumber := 2;
        tempApprover.name := COAInsertee.name;
        tempApprover.orig_system := COAInsertee.orig_system;
        tempApprover.orig_system_id := COAInsertee.orig_system_id;
        tempApprover.display_name :=  COAInsertee.display_name;
        tempApprover.source := COAInsertee.source;
        tempApprover.api_insertion := ame_util.apiAuthorityInsertion;
        tempApprover.approver_category := ame_util.approvalApproverCategory;
        tempApprover.group_or_chain_id := groupIds(groupIds.first);
        tempApprover.occurrence := ame_engine.getHandlerOccurrence(nameIn=>tempApprover.name,
                                                itemClassIn => tempApprover.item_class,
                                                itemIdIn => tempApprover.item_id,
                                                actionTypeIdIn => tempApprover.action_type_id,
                                                groupOrChainIdIn => tempApprover.group_or_chain_id);
        tempApprover.group_or_chain_order_number := 1;
        tempApprover.member_order_number := 1;
        tempApprover.approval_status := ame_engine.getHandlerApprovalStatus(approverIn=>tempApprover);
        /*
          The engine will set tempApprover.approver_order_number; leave them null here.
        */
        ame_engine.addApprover(approverIn => tempApprover);
      end if;
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
        for j in 1 .. tempApproverNames.count loop
          tempApprover.name := tempApproverNames(j);
          tempApprover.orig_system := tempOrigSystems(j);
          tempApprover.orig_system_id := tempOrigSystemIds(j);
          tempApprover.display_name := tempApproverDisplayNames(j);
          tempApprover.approver_category := approverCategories(tempIndex);
          tempApprover.api_insertion := ame_util.oamGenerated;
          tempApprover.group_or_chain_id := groupIds(tempIndex);
          tempApprover.occurrence := ame_engine.getHandlerOccurrence(nameIn =>  tempApprover.name,
                                                itemClassIn => tempApprover.item_class,
                                                itemIdIn => tempApprover.item_id,
                                                actionTypeIdIn => tempApprover.action_type_id,
                                                groupOrChainIdIn => tempApprover.group_or_chain_id);
          tempApprover.source := sources(tempIndex);
          if (chainOrderMode = ame_util.serialChainsMode) then
            tempApprover.group_or_chain_order_number := groupOrderNumber;
          else /* chain Order Mode is parallel */
            tempApprover.group_or_chain_order_number := 1;
          end if;
          if(votingRegimeType = ame_util.orderNumberVoting) then
            tempApprover.member_order_number := tempApproverOrderNumbers(j);
          elsif(votingRegimeType = ame_util.serializedVoting) then
            tempApprover.member_order_number := tempMemberOrderNumber;
          else /* votingRegimeType in (ame_util.consensusVoting, ame_util.firstApproverVoting) */
            tempApprover.member_order_number := 1;
          end if;
          tempApprover.approval_status := ame_engine.getHandlerApprovalStatus(approverIn  => tempApprover);
          /*
            The engine will set tempApprover.approver_order_number; leave them null here.
          */
          ame_engine.addApprover(approverIn => tempApprover);
          /* Check if there is any COA Insertion after this approver. If a COA Insertee is
             found keep checking till there are no more COA Insertee's */
          loop
            /* Initialize COAInsertee approver record 2 */
            COAInsertee := ame_util.emptyApproverRecord2;
            /* Check if there are any chain of authority insertions */
            ame_engine.getHandlerCOAInsertion(nameIn => tempApprover.name,
                                        itemClassIn => tempApprover.item_class,
                                        itemIdIn => tempApprover.item_id,
                                        actionTypeIdIn => tempApprover.action_type_id,
                                        groupOrChainIdIn => tempApprover.group_or_chain_id,
                                        occurrenceIn => tempApprover.occurrence,
                                        approvalStatusIn => tempApprover.approval_status,
                                        nameOut => COAInsertee.name,
                                        origSystemOut => COAInsertee.orig_system,
                                        origSystemIdOut => COAInsertee.orig_system_id,
                                        displayNameOut => COAInsertee.display_name,
                                        sourceOut => COAInsertee.source);
            if COAInsertee.name is  null then
              exit;
            else
              tempApprover.name := COAInsertee.name;
              tempApprover.orig_system := COAInsertee.orig_system;
              tempApprover.orig_system_id := COAInsertee.orig_system_id;
              tempApprover.display_name :=  COAInsertee.display_name;
              tempApprover.source := COAInsertee.source;
              tempApprover.approver_category := ame_util.approvalApproverCategory;
              tempApprover.api_insertion := ame_util.apiAuthorityInsertion;
              tempApprover.group_or_chain_id := groupIds(tempIndex);
              tempApprover.occurrence := ame_engine.getHandlerOccurrence(
                                                nameIn => tempApprover.name,
                                                itemClassIn => tempApprover.item_class,
                                                itemIdIn => tempApprover.item_id,
                                                actionTypeIdIn => tempApprover.action_type_id,
                                                groupOrChainIdIn => tempApprover.group_or_chain_id);
              if (chainOrderMode = ame_util.serialChainsMode) then
                tempApprover.group_or_chain_order_number := groupOrderNumber;
              else /* chain Order Mode is parallel */
                tempApprover.group_or_chain_order_number := 1;
              end if;
              if(votingRegimeType = ame_util.orderNumberVoting) then
                tempApprover.member_order_number := tempApproverOrderNumbers(j);
              elsif(votingRegimeType = ame_util.serializedVoting) then
                tempMemberOrderNumber := tempMemberOrderNumber+1;
                tempApprover.member_order_number := tempMemberOrderNumber;
              else /* votingRegimeType in (ame_util.consensusVoting, ame_util.firstApproverVoting) */
                tempApprover.member_order_number := 1;
              end if;
              tempApprover.approval_status := ame_engine.getHandlerApprovalStatus(approverIn  => tempApprover);
              /*
                The engine will set tempApprover.approver_order_number; leave them null here.
              */
              ame_engine.addApprover(approverIn => tempApprover);
            end if;
          end loop;
          if(votingRegimeType = ame_util.serializedVoting) then
            tempMemberOrderNumber := tempMemberOrderNumber+1;
          end if;
        end loop;
        tempIndex := groupIds.next(tempIndex);
        groupOrderNumber := groupOrderNumber + 1;
      end loop;
      exception
        when emptyGroupException then
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn     => 'AME_400229_HAN_APR_NO_MEM',
            tokenNameOneIn    => 'APPROVAL_GROUP',
            tokenValueOneIn   => ame_approval_group_pkg.getName(approvalGroupIdIn => currentApproverGroupId));
          ame_util.runtimeException(packageNameIn => 'ame_ag_chain_handler',
                                    routineNameIn => 'handler',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_ag_chain_handler',
                                    routineNameIn => 'handler',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end handler;
end ame_ag_chain_handler;

/
