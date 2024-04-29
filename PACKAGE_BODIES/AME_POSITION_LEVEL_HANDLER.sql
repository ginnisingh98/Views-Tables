--------------------------------------------------------
--  DDL for Package Body AME_POSITION_LEVEL_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_POSITION_LEVEL_HANDLER" as
/* $Header: ameeplha.pkb 120.5 2007/12/20 20:03:41 prasashe noship $ */
 /* package variables */
  approverCategories ame_util.charList;
  parametersCount integer;
  parameterNumbers ame_util.idList;
  parameters ame_util.stringList;
  parameterSigns ame_util.charList;
  ruleIds ame_util.idList;
  ruleSatisfiedYN ame_util.charList;
  topDogPositionId     integer;
  currentPositionLevel integer;
  positionStructureId  integer := null;
  /* forward declarations */
  function getPositionStructureId return integer;
  /*
    getCatSourceAndAuthority does not account for the ALLOW_REQUESTOR_APPROVAL attribute.
    The handler procedure does that.
  */
  procedure getCatSourceAndAuthority(positionIdIn in integer,
                                     categoryOut out nocopy varchar2,
                                     sourceOut out nocopy varchar2,
                                     hasFinalAuthorityYNOut out nocopy varchar2);
   /*
    parseAndSortRules populates the parameterNumbers and parameterSigns tables in
    ascending lexicographic order.
  */
  procedure parseAndSortRules;
  /*  Functions */
  function getNextPosition(positionIdIn in integer) return integer as
    cursor positionCursor(positionIdIn in integer) is
      select str.parent_position_id
      from
        per_pos_structure_elements str,
        per_pos_structure_versions psv,
        per_position_structures    pst
      where
            str.subordinate_position_id  = positionIdIn
        and str.pos_structure_version_id = psv.pos_structure_version_id
        and pst.position_structure_id    = psv.position_structure_id
        and pst.primary_position_flag    = 'Y'
        and trunc(sysdate) between  psv.date_from and nvl( psv.date_to , sysdate);
    cursor positionCursor2(positionIdIn in integer,posStrIdIn in integer) is
      select str.parent_position_id
      from
        per_pos_structure_elements str,
        per_pos_structure_versions psv,
        per_position_structures    pst
      where
            str.subordinate_position_id  = positionIdIn
        and str.pos_structure_version_id = psv.pos_structure_version_id
        and psv.position_structure_id    = pst.position_structure_id
        and pst.position_structure_id    = posStrIdIn
        and trunc(sysdate) between  psv.date_from and nvl( psv.date_to , sysdate);
    approverDescription ame_util.longStringType;
    approverName wf_roles.name%type;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    nextPositionId integer;
    posStrId       integer;
    nullIdException exception;
    begin
      posStrId := getPositionStructureId;
      if posStrId is null then
        open positionCursor(positionIdIn => positionIdIn);
        fetch positionCursor into nextPositionId;
        if(positionCursor%notfound) then
          raise nullIdException;
        end if;
        close positionCursor;
      else
        open positionCursor2(positionIdIn => positionIdIn,posStrIdIn => posStrId);
        fetch positionCursor2 into nextPositionId;
        if(positionCursor2%notfound) then
          raise nullIdException;
        end if;
        close positionCursor2;
      end if;
      return(nextPositionId);
      exception
        when nullIdException then
          errorCode := -20001;
          approverName := ame_approver_type_pkg.getWfRolesName(
                                 origSystemIn       => ame_util.posOrigSystem,
                                 origSystemIdIn     => positionIdIn);
          approverDescription :=
              ame_approver_type_pkg.getApproverDescription(nameIn => approverName);
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn          => 'AME_400407_NO_PARENT_POSITION',
                                             tokenNameOneIn  => 'POSITION',
                                             tokenValueOneIn => substrb(approverDescription, 1,70));
          ame_util.runtimeException(packageNameIn => 'ame_position_level_handler',
                                    routineNameIn => 'getNextPosition',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_position_level_handler',
                                    routineNameIn => 'getNextPosition',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getNextPosition;
--
  function getPositionStructureId return integer as
    begin
      positionStructureId :=
        ame_engine.getHeaderAttValue2(attributeNameIn =>ame_util.nonDefPosStructureAttr);
      return positionStructureId;
    end getPositionStructureId;
   /*  Procedures */
  procedure getCatSourceAndAuthority(positionIdIn in integer,
                                     categoryOut out nocopy varchar2,
                                     sourceOut out nocopy varchar2,
                                     hasFinalAuthorityYNOut out nocopy varchar2) as
    category ame_util.charType;
    hasFinalAuthorityYN ame_util.charType;
    source ame_util.longStringType;
    tempRuleRequiresApprover boolean;
    tempRuleSatisfied boolean;
    begin
      /*
        1.  An approver satisfies a rule in any of three cases:
            A.  The rule's parameter number does not exceed the currentPositionLevel.
            B.  The approver is the top dog and parameter number does exceed
                the currentPositionLevel
        2.  An approver has final authority if the approver satisfies all the rules.
        3.  The source value is an ame_util.fieldDelimiter-delimited list of the IDs
            of the rules that require an approver.  This procedure builds up the
            source value according to the following logic:
            A.  If a rule has not yet been satisfied, the rule requires the input
                approver.
        4.  An approver's category is ame_util.approvalApproverCategory if any of the
            rule usages requiring the approver is of that category; otherwise the
            approver's category is ame_util.fyiApproverCategory.
      */
      if currentPositionLevel is null then
        currentPositionLevel := 1;
      else
        currentPositionLevel := currentPositionLevel + 1;
      end if;
      category            := ame_util.fyiApproverCategory;
      hasFinalAuthorityYN := ame_util.booleanTrue;
      for i in 1 .. parametersCount loop
        /* if the rule is satisfied already no need to process again. */
        if(ruleSatisfiedYN(i) = ame_util.booleanFalse) then
          --
          -- Determine whether the approver satisfies the current rule.
          --
          if(positionIdIn = topDogPositionId) then
            tempRuleSatisfied := true;
          else
            tempRuleSatisfied := false;
            if(currentPositionLevel >= parameterNumbers(i)) then
              tempRuleSatisfied := true;
            end if;
          end if;
          --
          -- Update hasFinalAuthorityYN as needed.
          --
          if(not tempRuleSatisfied and
             hasFinalAuthorityYN = ame_util.booleanTrue) then
            hasFinalAuthorityYN := ame_util.booleanFalse;
          end if;
          --
          -- Determine whether the current rule requires the approver.
          --
          if(tempRuleSatisfied) then
            ruleSatisfiedYN(i) := ame_util.booleanTrue;
          end if;
          --
          -- Update source. */
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
      categoryOut := category;
      hasFinalAuthorityYNOut := hasFinalAuthorityYN;
      sourceOut := source;
      exception
        when others then
          categoryOut            := null;
          hasFinalAuthorityYNOut := null;
          sourceOut              := null;
          ame_util.runtimeException(packageNameIn     => 'ame_position_level_handler',
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
    firstApproverSource ame_util.longStringType;
    nullFirstIdException exception;
    requestorId integer;
    startingPointId integer;
    tempApprover ame_util.approverRecord2;
    tempHasFinalAuthorityYN ame_util.charType;
    tempMemberOrderNumber integer;
    topDogRequestorException exception;
    votingRegimeType ame_util.stringType;
    firstAuthInsExists boolean := false;
    coaInsAuthForward boolean := false;
    begin
      /*
        The engine only calls a handler if a rule requiring it exists, so we can assume that
        the package variables that ame_engine.getHandlerRules2 initializes are nonempty.
        Fetch the rules and sort them in increasing parameter order.  (Duplicate parameters
        are harmless here.)
      */
      currentPositionLevel := 0;
      ame_engine.getHandlerRules2(ruleIdsOut            => ruleIds,
                                  approverCategoriesOut => approverCategories,
                                  parametersOut         => parameters);
      /* Populate some of the package variables. */
      topDogPositionId := to_number(ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.topPositionIdAttribute));
      parametersCount := parameters.count;
      parseAndSortRules;
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
          if topDogPositionId = requestorId then
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
            else
              /* The requestor is the top position but he can not auto approve.
                 hence raise appropriate exception*/
              raise topDogRequestorException;
            end if;
          end if;
          /* The requestor could not self-approve, either because there was a non-default
          starting point, or because the requestor lacked sufficient authority.  So,
          start building the chain from the non-default starting point or the requestor's
          parent position.  */
          tempApprover.orig_system_id := getNextPosition(positionIdIn => requestorId);
        else
          tempApprover.orig_system_id := startingPointId;
        end if;
        tempApprover.api_insertion := ame_util.oamGenerated;
        ame_approver_type_pkg.getWfRolesNameAndDisplayName(origSystemIn   => ame_util.posOrigSystem,
                                                           origSystemIdIn => tempApprover.orig_system_id,
                                                           nameOut        => tempApprover.name,
                                                           displayNameOut => tempApprover.display_name);
      else
        firstAuthInsExists := true;
        tempApprover.name := COAInsertee.name;
        tempApprover.orig_system := COAInsertee.orig_system;
        tempApprover.orig_system_id := COAInsertee.orig_system_id;
        tempApprover.display_name :=  COAInsertee.display_name;
        firstApproverSource := COAInsertee.source;
        tempApprover.api_insertion := ame_util.apiAuthorityInsertion;
      end if;
      /* Build the chain. */
      currentPositionLevel := 0;
      tempMemberOrderNumber := 0; /* pre-increment */
      loop
        getCatSourceAndAuthority(positionIdIn           => tempApprover.orig_system_id,
                                 categoryOut            => tempApprover.approver_category,
                                 sourceOut              => tempApprover.source,
                                 hasFinalAuthorityYNOut => tempHasFinalAuthorityYN);
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
        /* check to see if there is a COA insertion after this approver. If a COA
           insertion is found, keep checking till no more COA insertions. The check
           for final authority will not be needed (similar to supervisory handler).  */
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
            ame_engine.addApprover(approverIn => tempApprover);
          end if;
        end loop;
        /* Decide whether to end the chain. */
        if(tempHasFinalAuthorityYN  = ame_util.booleanTrue ) then
          exit;
        end if;
        tempApprover.orig_system_id := getNextPosition(positionIdIn =>tempApprover.orig_system_id );
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
          ame_util.runtimeException(packageNameIn     => 'ame_position_level_handler',
                                    routineNameIn     => 'handler',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when topDogRequestorException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                    messageNameIn => 'AME_400421_REQ_CANNOT_APPROVE');
          ame_util.runtimeException(packageNameIn => 'ame_position_level_handler',
                                    routineNameIn => 'handler',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn     => 'ame_position_level_handler',
                                    routineNameIn     => 'handler',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end handler;
  procedure parseAndSortRules as
    badParameterException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    signPosition integer;
    tempCategory ame_util.charType;
    tempLength integer;
    tempNumber integer;
    tempRuleId integer;
    tempSign ame_util.charType;
    tempParameter ame_util.parameterType;
    upperLimit integer;
    begin
      /* Parse. */
      for i in 1 .. parametersCount loop
        signPosition := instrb(parameters(i), '+');
        tempLength   := lengthb(parameters(i));
        if signPosition = 0 then
          signPosition := instrb(parameters(i), '-');
          if signPosition = 0 then
            parameterSigns(i) := '+';
            parameterNumbers(i) := to_number(parameters(i));
          else
            parameterSigns(i) := substrb(parameters(i), tempLength, tempLength);
            parameterNumbers(i) := to_number(substrb(parameters(i), 1, tempLength - 1));
          end if;
        else
          parameterSigns(i)   := substrb(parameters(i), tempLength, tempLength);
          parameterNumbers(i) := to_number(substrb(parameters(i), 1, tempLength - 1));
        end if;
        if(parameterSigns(i) <> '+' ) then
          raise badParameterException;
        end if;
      end loop;
      /* Sort. */
      for i in 2 .. parametersCount loop
        upperLimit := i - 1;
        for j in 1 .. upperLimit loop
          if(parameterNumbers(i) < parameterNumbers(j) ) then
            tempRuleId            := ruleIds(j);
            tempCategory          := approverCategories(j);
            tempNumber            := parameterNumbers(j);
            tempSign              := parameterSigns(j);
            tempParameter         := parameters(j);
            --
            ruleIds(j)            := ruleIds(i);
            approverCategories(j) := approverCategories(i);
            parameterNumbers(j)   := parameterNumbers(i);
            parameterSigns(j)     := parameterSigns(i);
            parameters(j)         := parameters(i);
            --
            ruleIds(i)            := tempRuleId;
            approverCategories(i) := tempCategory;
            parameterNumbers(i)   := tempNumber;
            parameterSigns(i)     := tempSign;
            parameters(i)         := tempParameter;
          end if;
        end loop;
      end loop;
      exception
        when badParameterException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn          => 'AME_400234_HAN_ACT_PAR_SIGN');
          ame_util.runtimeException(packageNameIn     => 'ame_position_level_handler',
                                    routineNameIn     => 'parseAndSortRules',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn     => 'ame_position_level_handler',
                                    routineNameIn     => 'parseAndSortRules',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end parseAndSortRules;
 end ame_position_level_handler;

/
