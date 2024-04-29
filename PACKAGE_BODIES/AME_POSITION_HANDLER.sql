--------------------------------------------------------
--  DDL for Package Body AME_POSITION_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_POSITION_HANDLER" as
/* $Header: ameepoha.pkb 120.5 2007/12/20 20:03:55 prasashe noship $ */
 /* package variables */
  approverCategories  ame_util.charList;
  parameterIds        ame_util.idList;
  parametersCount     integer;
  parameters          ame_util.stringList;
  ruleIds             ame_util.idList;
  ruleSatisfiedYN     ame_util.charList;
  isRequestor         boolean;
  /* forward declarations */
  procedure getParameterIds;
  /*  Procedures */
  /*
    getCatSourceAndAuthority does not account for the ALLOW_REQUESTOR_APPROVAL attribute.
    The handler procedure does that.
  */
  procedure getCatSourceAndAuthority(positionIdIn           in  integer,
                                     categoryOut            out nocopy varchar2,
                                     sourceOut              out nocopy varchar2,
                                     hasFinalAuthorityYNOut out nocopy varchar2) as
    category ame_util.charType;
    hasFinalAuthorityYN ame_util.charType;
    source ame_util.longStringType;
    tempRuleRequiresApprover boolean;
    tempRuleSatisfied boolean;
    tempApprover1 ame_util.approverRecord2;
    tempApprover2 ame_util.approverRecord2;
    begin
      /*
        1.  An approver satisfies a rule when the rule's parameter number equals to
            the approver's orig_system_id.
        2.  An approver has final authority if the approver satisfies all the rules.
        3.  The source value is a comma-delimited list of the IDs of the rules that
            require an approver.  This procedure builds up the source value according
            to the following logic:
            A.  If a rule has not yet been satisfied, the rule requires the input
                approver.
        4.  An approver's category is ame_util.approvalApproverCategory if any of the
            rule usages requiring the approver is of that category; otherwise the
            approver's category is ame_util.fyiApproverCategory.
      */
      category            := ame_util.fyiApproverCategory;
      hasFinalAuthorityYN := ame_util.booleanTrue;
      for i in 1 .. parametersCount loop
        /* if the rule is satisfied already no need to process again. */
        if(ruleSatisfiedYN(i) = ame_util.booleanFalse) then
          --
          -- Determine whether the approver satisfies the current rule.
          --
          tempRuleSatisfied := false;
          tempApprover1.orig_system := 'POS';
          tempApprover1.orig_system_id := positionIdIn;
          tempApprover2.orig_system := 'POS';
          tempApprover2.orig_system_id := parameterIds(i);
          if(positionIdIn = parameterIds(i) or
               (isRequestor and ame_approver_type_pkg.isASubordinate
                                   (approverIn => tempApprover1,
                                    possibleSubordApproverIn => tempApprover2))) then
            tempRuleSatisfied := true;
          end if;
          --
          -- Update hasFinalAuthorityYN as needed.
          --
          if(not tempRuleSatisfied and
             hasFinalAuthorityYN = ame_util.booleanTrue) then
            hasFinalAuthorityYN := ame_util.booleanFalse;
          end if;
          --
          -- Mark the rule as satisfied as needed.
          --
          if(tempRuleSatisfied) then
            ruleSatisfiedYN(i) := ame_util.booleanTrue;
          end if;
          --
          -- Update source.
          --
          ame_util.appendRuleIdToSource(ruleIdIn => ruleIds(i),
                                        sourceInOut => source);
          --
          -- Update category as needed.
          --
          if(category = ame_util.fyiApproverCategory and
             approverCategories(i) = ame_util.approvalApproverCategory) then
            category := ame_util.approvalApproverCategory;
          end if;
        end if;
      end loop;
      categoryOut            := category;
      hasFinalAuthorityYNOut := hasFinalAuthorityYN;
      sourceOut              := source;
      exception
        when others then
          categoryOut            := null;
          hasFinalAuthorityYNOut := null;
          sourceOut              := null;
          ame_util.runtimeException(packageNameIn     => 'ame_position_handler',
                                    routineNameIn     => 'getCatSourceAndAuthority',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getCatSourceAndAuthority;
  procedure handler as
    COAInsertee ame_util.approverRecord2;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    finalAuthorityFound boolean;
    nullFirstIdException exception;
    requestorId     integer;
    startingPointId integer;
    tempApprover ame_util.approverRecord2;
    tempHasFinalAuthorityYN ame_util.charType;
    tempMemberOrderNumber integer;
    votingRegimeType ame_util.stringType;
    firstApproverSource ame_util.longStringType;
    firstAuthInsExists boolean := false;
    coaInsAuthForward boolean := false;
    begin
      /*
        The engine only calls a handler if a rule requiring it exists, so we can assume that
        the package variables that ame_engine.getHandlerRules2 initializes are nonempty.
        Fetch the rules and sort them in increasing parameter order. (Duplicate parameters
        are harmless here.)
      */
      ame_engine.getHandlerRules2(ruleIdsOut            => ruleIds,
                                  approverCategoriesOut => approverCategories,
                                  parametersOut         => parameters);
      /* Populate some of the package variables. */
      parametersCount := parameters.count;
      getParameterIds;
      for i in 1 .. ruleIds.count loop
        ruleSatisfiedYN(i) := ame_util.booleanFalse;
      end loop;
      /* Set the fields in tempApprover that are constant for the entire handler cycle. */
      tempApprover.orig_system       := ame_util.posOrigSystem;
      tempApprover.authority         := ame_util.authorityApprover;
      tempApprover.action_type_id    := ame_engine.getHandlerActionTypeId;
      tempApprover.item_class        := ame_engine.getHandlerItemClassName;
      tempApprover.item_id           := ame_engine.getHandlerItemId;
      tempApprover.group_or_chain_id := 1;
      --
      tempApprover.item_class_order_number     := ame_engine.getHandlerItemClassOrderNumber;
      tempApprover.item_order_number           := ame_engine.getHandlerItemOrderNumber;
      tempApprover.sub_list_order_number       := ame_engine.getHandlerSublistOrderNum;
      tempApprover.action_type_order_number    := ame_engine.getHandlerActionTypeOrderNum;
      tempApprover.group_or_chain_order_number := 1;
      /* Fetch some of the required attributes. */
      votingRegimeType := ame_engine.getActionTypeVotingRegime(actionTypeIdIn => tempApprover.action_type_id);
      /* Check for COA Insertions */
      ame_engine.getHandlerCOAFirstApprover(itemClassIn => tempApprover.item_class,
                                            itemIdIn => tempApprover.item_id,
                                            actionTypeIdIn => tempApprover.action_type_id,
                                            groupOrChainIdIn => tempApprover.group_or_chain_id,
                                            nameOut => COAInsertee.name,
                                            origSystemOut => COAInsertee.orig_system,
                                            origSystemIdOut => COAInsertee.orig_system_id,
                                            displayNameOut => COAInsertee.display_name,
                                            sourceOut => COAInsertee.source);
      /* Start building the chain from the COA Insertee if defined otherwise from the
         non-default starting point or the requestor's supervisor.  */
      isRequestor := true;
      if COAInsertee.name is  null then
        /* Fetch some of the required attributes. */
        startingPointId :=
           to_number(ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.nonDefStartingPointPosAttr));
        if(startingPointId is null) then
          requestorId :=
            to_number(ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.transactionReqPositionAttr));
          if (requestorId is null) then
            raise nullFirstIdException;
          end if;
          tempApprover.orig_system_id := requestorId;
          /* Check if requestor can self approve. If so, insert the approver as the
             only approver, with a status of approved, and return.*/
          if(ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.allowAutoApprovalAttribute)
                 = ame_util.booleanAttributeTrue)
            then
            getCatSourceAndAuthority(positionIdIn           => requestorId,
                                 categoryOut            => tempApprover.approver_category,
                                 sourceOut              => tempApprover.source,
                                 hasFinalAuthorityYNOut => tempHasFinalAuthorityYN);
            if(tempHasFinalAuthorityYN = ame_util.booleanTrue) then
              tempApprover.api_insertion := ame_util.oamGenerated;
              ame_approver_type_pkg.getWfRolesNameAndDisplayName(
                                 origSystemIn   => ame_util.posOrigSystem,
                                 origSystemIdIn => requestorId,
                                 nameOut        => tempApprover.name,
                                 displayNameOut => tempApprover.display_name);
              tempApprover.occurrence := ame_engine.getHandlerOccurrence(
                                       nameIn =>  tempApprover.name,
                                       itemClassIn => tempApprover.item_class,
                                       itemIdIn => tempApprover.item_id,
                                       actionTypeIdIn => tempApprover.action_type_id,
                                       groupOrChainIdIn => tempApprover.group_or_chain_id);
              tempApprover.member_order_number := 1;
              tempApprover.approval_status     := ame_util.approvedStatus;
              ame_engine.addApprover(approverIn => tempApprover);
              return;
            end if;
            isRequestor := false;
          end if;
          /* The requestor could not self-approve, either because there was a non-default
          starting point, or because the requestor lacked sufficient authority.  So,
          start building the chain from the non-default starting point or the requestor's
          parent position.  */
          tempApprover.orig_system_id := ame_position_level_handler.getNextPosition(positionIdIn => requestorId);
        else
          tempApprover.orig_system_id := startingPointId;
        end if;
        tempApprover.api_insertion := ame_util.oamGenerated;
        ame_approver_type_pkg.getWfRolesNameAndDisplayName(origSystemIn   => ame_util.posOrigSystem,
                                                           origSystemIdIn => tempApprover.orig_system_id,
                                                           nameOut        => tempApprover.name,
                                                           displayNameOut => tempApprover.display_name);
      else
        tempApprover.name := COAInsertee.name;
        tempApprover.orig_system := COAInsertee.orig_system;
        tempApprover.orig_system_id := COAInsertee.orig_system_id;
        tempApprover.display_name :=  COAInsertee.display_name;
        firstApproverSource := COAInsertee.source;
        tempApprover.api_insertion := ame_util.apiAuthorityInsertion;
        firstAuthInsExists := true;
      end if;
      /* Build the chain. */
      tempMemberOrderNumber := 0; /* pre-increment */
      loop
        getCatSourceAndAuthority(positionIdIn           => tempApprover.orig_system_id,
                                 categoryOut            => tempApprover.approver_category,
                                 sourceOut              => tempApprover.source,
                                 hasFinalAuthorityYNOut => tempHasFinalAuthorityYN);
        isRequestor := false;
        if firstApproverSource is not null then
          tempApprover.source := firstApproverSource;
          firstApproverSource := null;
        end if;
        tempApprover.occurrence := ame_engine.getHandlerOccurrence(
                                       nameIn =>  tempApprover.name,
                                       itemClassIn => tempApprover.item_class,
                                       itemIdIn => tempApprover.item_id,
                                       actionTypeIdIn => tempApprover.action_type_id,
                                       groupOrChainIdIn => tempApprover.group_or_chain_id);
        tempMemberOrderNumber      := tempMemberOrderNumber + 1;
        if(votingRegimeType = ame_util.serializedVoting) then
          tempApprover.member_order_number := tempMemberOrderNumber;
        else /* votingRegimeType in (ame_util.consensusVoting, ame_util.firstApproverVoting) */
          tempApprover.member_order_number := 1;
        end if;
        tempApprover.approval_status := ame_engine.getHandlerApprovalStatus(approverIn => tempApprover);
        /* The engine will set tempApprover.approver_order_number; leave it null here. */
        ame_engine.addApprover(approverIn => tempApprover);
        /* check to see if there is a COA insertion after this approver. If a COA insertion is
           found, keep checking till no more COA insertions. The check for final authority
           will need to be done again.  */
        loop
          /* Initialize COAInsertee approverRecord2 */
          COAInsertee := ame_util.emptyApproverRecord2;
          /* Check if there are any COAInsertions */
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
          if COAInsertee.name is null then
            exit;
          else
            coaInsAuthForward := true;
            tempApprover.name := COAInsertee.name;
            tempApprover.orig_system := COAInsertee.orig_system;
            tempApprover.orig_system_id := COAInsertee.orig_system_id;
            tempApprover.display_name :=  COAInsertee.display_name;
            getCatSourceAndAuthority(positionIdIn           => tempApprover.orig_system_id,
                                 categoryOut            => tempApprover.approver_category,
                                 sourceOut              => tempApprover.source,
                                 hasFinalAuthorityYNOut => tempHasFinalAuthorityYN);
            tempApprover.source := COAInsertee.source;
            tempApprover.api_insertion := ame_util.apiAuthorityInsertion;
            tempMemberOrderNumber := tempMemberOrderNumber + 1;
            if(votingRegimeType = ame_util.serializedVoting) then
              tempApprover.member_order_number := tempMemberOrderNumber;
            else /* votingRegimeType in (ame_util.consensusVoting, ame_util.firstApproverVoting) */
              tempApprover.member_order_number := 1;
            end if;
            tempApprover.occurrence := ame_engine.getHandlerOccurrence(nameIn =>  tempApprover.name,
                                              itemClassIn => tempApprover.item_class,
                                              itemIdIn => tempApprover.item_id,
                                              actionTypeIdIn => tempApprover.action_type_id,
                                              groupOrChainIdIn => tempApprover.group_or_chain_id);
            tempApprover.approval_status := ame_engine.getHandlerApprovalStatus(approverIn =>
tempApprover);
            /* If approver has a status of ame_util.approve or ame_util.approveAndForwardStatus or
               ame_util.nullStatus check to see if approver could have final authority */
            if tempApprover.approval_status in (ame_util.approvedStatus, ame_util.approveAndForwardStatus,
                                                ame_util.nullStatus)
              then
              if(not finalAuthorityFound and
                tempHasFinalAuthorityYN = ame_util.booleanTrue) then
                finalAuthorityFound := true;
              end if;
            end if;
            ame_engine.addApprover(approverIn => tempApprover);
          end if;
        end loop;
        /* Decide whether to end the chain. */
        if(tempHasFinalAuthorityYN  = ame_util.booleanTrue ) then
          exit;
        end if;
        tempApprover.orig_system_id := ame_position_level_handler.getNextPosition(positionIdIn =>tempApprover.orig_system_id );
        ame_approver_type_pkg.getWfRolesNameAndDisplayName(origSystemIn   => ame_util.posOrigSystem,
                                                           origSystemIdIn => tempApprover.orig_system_id,
                                                           nameOut        => tempApprover.name,
                                                           displayNameOut => tempApprover.display_name);
        if firstAuthInsExists then
          ame_engine.setDeviationReasonDate(ame_approver_deviation_pkg.firstauthHandlerInsReason,null);
        end if;
        if coaInsAuthForward then
          ame_engine.setDeviationReasonDate(ame_approver_deviation_pkg.forwarHandlerAuthInsReason,null);
        end if;
        tempApprover.api_insertion := ame_util.oamGenerated;
      end loop;
      exception
        when nullFirstIdException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn          => 'AME_400408_HAN_NO_TRANS_POS_ID');
          ame_util.runtimeException(packageNameIn     => 'ame_position_handler',
                                    routineNameIn     => 'handler',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn     => 'ame_position_handler',
                                    routineNameIn     => 'handler',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end handler;
  procedure getParameterIds as
    errorCode integer;
    begin
      for i in 1..parametersCount loop
        parameterIds(i) :=
         ame_approver_type_pkg.getApproverOrigSystemId(nameIn => parameters(i));
      end loop;
      exception
        when no_data_found then
          errorCode := -20001;
          ame_util.runtimeException(packageNameIn     => 'ame_position_handler',
                                    routineNameIn     => 'getParameterIds',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => sqlerrm);
          raise_application_error(errorCode,
                                  sqlerrm);
        when others then
          ame_util.runtimeException(packageNameIn     => 'ame_position_handler',
                                    routineNameIn     => 'getParameterIds',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getParameterIds;
 end ame_position_handler;

/
