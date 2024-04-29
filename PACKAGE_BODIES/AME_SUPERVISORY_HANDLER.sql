--------------------------------------------------------
--  DDL for Package Body AME_SUPERVISORY_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_SUPERVISORY_HANDLER" as
/* $Header: ameesuha.pkb 120.3 2007/12/20 20:04:28 prasashe noship $ */
 /* package variables */
  approverCategories ame_util.charList;
  parametersCount integer;
  parameterNumbers ame_util.idList;
  parameters ame_util.stringList;
  parameterSigns ame_util.charList;
  ruleIds ame_util.idList;
  ruleSatisfiedYN ame_util.charList;
  topDogPersonId integer;
  currentSupervisoryLevel integer;
  /* forward declarations */
  /*
    getCatSourceAndAuthority does not account for the ALLOW_REQUESTOR_APPROVAL attribute.
    The handler procedure does that.
  */
  procedure getCatSourceAndAuthority(personIdIn in integer,
                                     categoryOut out nocopy varchar2,
                                     sourceOut out nocopy varchar2,
                                     hasFinalAuthorityYNOut out nocopy varchar2);
   /*
    parseAndSortRules populates the parameterNumbers and parameterSigns tables in
    ascending lexicographic order, first by numerical order, then with '+' dominating '-'.
    Note that it does not sort the parameters proper.
  */
  procedure parseAndSortRules;
   /*  Functions */
  function getSupervisor(personIdIn in integer) return integer as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    nullIdException exception;
    personDisplayName ame_util.longStringType;
    supervisorPersonId integer;
    begin
      select supervisor_id
      into supervisorPersonId
      from
        per_all_assignments_f
      where
        person_id = personIdIn and
        per_all_assignments_f.primary_flag = 'Y' and
        per_all_assignments_f.assignment_type in ('E','C') and
        per_all_assignments_f.assignment_status_type_id not in
          (select assignment_status_type_id
             from per_assignment_status_types
             where per_system_status = 'TERM_ASSIGN') and
        trunc(sysdate) between
          per_all_assignments_f.effective_start_date and
          per_all_assignments_f.effective_end_date;
      if(supervisorPersonId is null) then
        raise nullIdException;
      end if;
      return(supervisorPersonId);
      exception
        when nullIdException then
          personDisplayName := ame_approver_type_pkg.getApproverDisplayName2(
                                      origSystemIn => ame_util.perOrigSystem,
                                      origSystemIdIn => personIdIn );
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn     => 'AME_400297_HAN_LACK_SPVR',
            tokenNameOneIn    => 'FIRST_NAME',
            tokenValueOneIn   => personDisplayName,
            tokenNameTwoIn    => 'LAST_NAME',
            tokenValueTwoIn   => null ,
            tokenNameThreeIn  => 'OTHER_NAME',
            tokenValueThreeIn =>  null );
          ame_util.runtimeException(packageNameIn => 'ame_supervisory_handler',
                                    routineNameIn => 'getSupervisor',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_supervisory_handler',
                                    routineNameIn => 'getSupervisor',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getSupervisor;
   /*  Procedures */
  procedure getCatSourceAndAuthority(personIdIn in integer,
                                     categoryOut out nocopy varchar2,
                                     sourceOut out nocopy varchar2,
                                     hasFinalAuthorityYNOut out nocopy varchar2) as
    category ame_util.charType;
    hasFinalAuthorityYN ame_util.charType;
    source ame_util.longStringType;
    supervisorJobLevel integer;
    tempRuleRequiresApprover boolean;
    tempRuleSatisfied boolean;
    begin
      /*
        1.  An approver satisfies a rule in any of three cases:
            A.  The rule's parameter number does not exceed the currentSupervisoryLevel.
            B.  The rule's parameter sign is '-', and the supervisor level of the approver's
                supervisor exceeds the rule's parameter number.
            C.  The approver is the top dog and the parameter sign is '-' and parameter number
                does exceed the currentSupervisoryLevel
        2.  An approver has final authority if the approver satisfies all the rules.
        3.  The source value is an ame_util.fieldDelimiter-delimited list of the IDs of the
            rules that require an approver.  This procedure builds up the source value
            according to the following logic:
            A.  If a rule has not yet been satisfied, the rule requires the input
                approver.
        4.  An approver's category is ame_util.approvalApproverCategory if any of the
            rule usages requiring the approver is of that category; otherwise the
            approver's category is ame_util.fyiApproverCategory.
      */
      if currentSupervisoryLevel is null then
        currentSupervisoryLevel := 1;
      else
        currentSupervisoryLevel := currentSupervisoryLevel + 1;
      end if;
      category := ame_util.fyiApproverCategory;
      hasFinalAuthorityYN := ame_util.booleanTrue;
      for i in 1 .. parametersCount loop
        /* Determine whether the approver satisfies the current rule. */
        if(personIdIn = topDogPersonId) then
          if(currentSupervisoryLevel < parameterNumbers(i) and
             parameterSigns(i) = '+')  then
            tempRuleSatisfied := false;
          else
            tempRuleSatisfied := true;
          end if;
        else
          tempRuleSatisfied := false;
          if(currentSupervisoryLevel >= parameterNumbers(i)) then
            tempRuleSatisfied := true;
          elsif(parameterSigns(i) = '-') then
            if(currentSupervisoryLevel > parameterNumbers(i)) then
              tempRuleSatisfied := true;
            end if;
          end if;
        end if;
        /* Update hasFinalAuthorityYN as needed. */
        if(not tempRuleSatisfied and
           hasFinalAuthorityYN = ame_util.booleanTrue) then
          hasFinalAuthorityYN := ame_util.booleanFalse;
        end if;
        /* Determine whether the current rule requires the approver. */
        tempRuleRequiresApprover := false;
        if(ruleSatisfiedYN(i) = ame_util.booleanTrue) then
          if(not tempRuleSatisfied) then
            tempRuleRequiresApprover := true;
          end if;
        else
          tempRuleRequiresApprover := true;
          if(tempRuleSatisfied) then
            ruleSatisfiedYN(i) := ame_util.booleanTrue;
          end if;
        end if;
        if(tempRuleRequiresApprover) then
          /* Update source. */
          ame_util.appendRuleIdToSource(ruleIdIn => ruleIds(i),
                                        sourceInOut => source);
          /* Update category as needed. */
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
          categoryOut := null;
          hasFinalAuthorityYNOut := null;
          sourceOut := null;
          ame_util.runtimeException(packageNameIn => 'ame_supervisory_handler',
                                    routineNameIn => 'getCatSourceAndAuthority',
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
    tempSupervisorId integer;
    topDogRequestorException exception;
    votingRegimeType ame_util.stringType;
    currentApproverPersonId integer;
    firstAuthInsExists boolean := false;
    coaInsAuthForward boolean := false;
    begin
      /* Reset package variables */
      currentSupervisoryLevel := 0;
      /*
        The engine only calls a handler if a rule requiring it exists, so we can assume that
        the package variables that ame_engine.getHandlerRules2 initializes are nonempty.
        Fetch the rules and sort them in increasing parameter order.  (Duplicate parameters
        are harmless here.)
      */
      ame_engine.getHandlerRules2(ruleIdsOut => ruleIds,
                                  approverCategoriesOut => approverCategories,
                                  parametersOut => parameters);
      /* Populate some of the package variables. */
      topDogPersonId := to_number(ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.topSupPersonIdAttribute));
      parametersCount := parameters.count;
      parseAndSortRules;
      for i in 1 .. ruleIds.count loop
        ruleSatisfiedYN(i) := ame_util.booleanFalse;
      end loop;
      /* Set the fields in tempApprover that are constant for the entire handler cycle. */
      tempApprover.orig_system := ame_util.perOrigSystem;
      tempApprover.authority := ame_util.authorityApprover;
      tempApprover.action_type_id := ame_engine.getHandlerActionTypeId;
      tempApprover.item_class := ame_engine.getHandlerItemClassName;
      tempApprover.item_id := ame_engine.getHandlerItemId;
      tempApprover.item_class_order_number := ame_engine.getHandlerItemClassOrderNumber;
      tempApprover.item_order_number := ame_engine.getHandlerItemOrderNumber;
      tempApprover.sub_list_order_number := ame_engine.getHandlerSublistOrderNum;
      tempApprover.action_type_order_number := ame_engine.getHandlerActionTypeOrderNum;
      tempApprover.group_or_chain_order_number := 1;
      tempApprover.group_or_chain_id := 1;
      votingRegimeType := ame_engine.getActionTypeVotingRegime(actionTypeIdIn => tempApprover.action_type_id);
      /* In a supervisory hierarchy, self approval can not be done. Hence no check needed for it.  */
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
      /*
        Start building the chain from the COA Insertee if defined otherwise from the non-default
        starting point or the requestor's supervisor.
      */
      if COAInsertee.name is  null then
        /* Fetch some of the required attributes. */
        startingPointId :=
          to_number(ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.supStartingPointAttribute));
        if(startingPointId is null) then
          requestorId :=
             to_number(ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.transactionRequestorAttribute));
          if (requestorId is null) then
            raise nullFirstIdException;
          end if;
          /* check if requestor is the top supervisor person id */
          if topDogPersonId = requestorId then
            tempApprover.orig_system_id := requestorId;
            /* check if requestor can self approve transaction  */
            if(ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.allowAutoApprovalAttribute)
                 = ame_util.booleanAttributeTrue) then
              getCatSourceAndAuthority(personIdIn => tempApprover.orig_system_id,
                                       categoryOut => tempApprover.approver_category,
                                       sourceOut => tempApprover.source,
                                       hasFinalAuthorityYNOut => tempHasFinalAuthorityYN);
              tempApprover.occurrence := ame_engine.getHandlerOccurrence(nameIn =>  tempApprover.name,
                                                itemClassIn => tempApprover.item_class,
                                                itemIdIn => tempApprover.item_id,
                                                actionTypeIdIn => tempApprover.action_type_id,
                                                groupOrChainIdIn => tempApprover.group_or_chain_id);
              tempApprover.member_order_number := 1;
              tempApprover.api_insertion := ame_util.oamGenerated;
              tempApprover.approval_status := ame_util.approvedStatus;
              ame_approver_type_pkg.getWfRolesNameAndDisplayName(origSystemIn => ame_util.perOrigSystem,
                                                           origSystemIdIn => tempApprover.orig_system_id,
                                                           nameOut => tempApprover.name,
                                                           displayNameOut => tempApprover.display_name);
              ame_engine.addApprover(approverIn => tempApprover);
              return;
            else
              /*  raise appropriate exception */
              raise topDogRequestorException;
            end if;
          else
            tempApprover.orig_system_id := getSupervisor(personIdIn => requestorId);
          end if;
        else
          tempApprover.orig_system_id := startingPointId;
        end if;
        tempApprover.api_insertion := ame_util.oamGenerated;
        ame_approver_type_pkg.getWfRolesNameAndDisplayName(origSystemIn => ame_util.perOrigSystem,
                                                           origSystemIdIn=> tempApprover.orig_system_id,
                                                           nameOut => tempApprover.name,
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
        getCatSourceAndAuthority(personIdIn => tempApprover.orig_system_id,
                                 categoryOut => tempApprover.approver_category,
                                 sourceOut => tempApprover.source,
                                 hasFinalAuthorityYNOut => tempHasFinalAuthorityYN);
        /* reassign the value of source in case approver was a firstAuthority insertee */
        if firstApproverSource is not null then
          tempApprover.source := firstApproverSource;
          firstApproverSource := null;
        end if;
        tempMemberOrderNumber := tempMemberOrderNumber + 1;
        if(votingRegimeType = ame_util.serializedVoting) then
          tempApprover.member_order_number := tempMemberOrderNumber;
        else /* votingRegimeType in (ame_util.consensusVoting, ame_util.firstApproverVoting) */
          tempApprover.member_order_number := 1;
        end if;
        if tempApprover.name is null then
          ame_approver_type_pkg.getWfRolesNameAndDisplayName(origSystemIn => ame_util.perOrigSystem,
                                                           origSystemIdIn=> tempApprover.orig_system_id,
                                                           nameOut => tempApprover.name,
                                                           displayNameOut => tempApprover.display_name);
        end if;
        tempApprover.occurrence := ame_engine.getHandlerOccurrence(nameIn =>  tempApprover.name,
                                              itemClassIn => tempApprover.item_class,
                                              itemIdIn => tempApprover.item_id,
                                              actionTypeIdIn => tempApprover.action_type_id,
                                              groupOrChainIdIn => tempApprover.group_or_chain_id);
        tempApprover.approval_status := ame_engine.getHandlerApprovalStatus(approverIn => tempApprover);
        /* The engine will set tempApprover.approver_order_number; leave it null here. */
        ame_engine.addApprover(approverIn => tempApprover);
        /* check to see if there is a COA insertion after this approver. If a COA insertion is
           found, keep checking till no more COA insertions.
        */
        currentApproverPersonId := tempApprover.orig_system_id;
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
            if COAInsertee.source <> ame_util.specialForwardInsertion then
              coaInsAuthForward := true;
              currentApproverPersonId := COAInsertee.orig_system_id;
            end if;
            tempApprover.name := COAInsertee.name;
            tempApprover.orig_system := COAInsertee.orig_system;
            tempApprover.orig_system_id := COAInsertee.orig_system_id;
            tempApprover.display_name :=  COAInsertee.display_name;
            tempApprover.source := COAInsertee.source;
            tempApprover.approver_category := ame_util.approvalApproverCategory;
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
            tempApprover.approval_status := ame_engine.getHandlerApprovalStatus(approverIn => tempApprover);
            /* If approver has a status of ame_util.approve or ame_util.approveAndForwardStatus or
               ame_util.nullStatus check to see if approver could have final authority */
            ame_engine.addApprover(approverIn => tempApprover);
          end if;
        end loop;
        /* Decide whether to end the chain. */
        if(tempHasFinalAuthorityYN  = ame_util.booleanTrue ) then
          exit;
        end if;
        /* Final authority not found. Need to go up one level. */
        tempApprover.orig_system_id := getSupervisor(personIdIn => currentApproverPersonId);
        ame_approver_type_pkg.getWfRolesNameAndDisplayName(origSystemIn => ame_util.perOrigSystem,
                                                           origSystemIdIn=> tempApprover.orig_system_id,
                                                           nameOut => tempApprover.name,
                                                           displayNameOut => tempApprover.display_name);
        /*if the next approver because of first auth insertion the populate the date and reason*/
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
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                              messageNameIn => 'AME_400233_HAN_NO_TRANS_PER_ID');
          ame_util.runtimeException(packageNameIn => 'ame_supervisory_handler',
                                    routineNameIn => 'handler',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when topDogRequestorException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                    messageNameIn => 'AME_400421_REQ_CANNOT_APPROVE');
          ame_util.runtimeException(packageNameIn => 'ame_supervisory_handler',
                                    routineNameIn => 'handler',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_supervisory_handler',
                                    routineNameIn => 'handler',
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
    upperLimit integer;
    begin
      /* Parse. */
      for i in 1 .. parametersCount loop
        signPosition := instrb(parameters(i), '-');
        tempLength := lengthb(parameters(i));
        if signPosition = 0 then
          signPosition := instrb(parameters(i), '+');
          if signPosition = 0 then
            parameterSigns(i) := '+';
            parameterNumbers(i) := to_number(parameters(i));
          else
            parameterSigns(i) := substrb(parameters(i), tempLength, tempLength);
            parameterNumbers(i) := to_number(substrb(parameters(i), 1, tempLength - 1));
          end if;
        else
          parameterSigns(i) := substrb(parameters(i), tempLength, tempLength);
          parameterNumbers(i) := to_number(substrb(parameters(i), 1, tempLength - 1));
        end if;
        if(parameterSigns(i) <> '+' and
           parameterSigns(i) <> '-') then
          raise badParameterException;
        end if;
      end loop;
      /* Sort. */
      for i in 2 .. parametersCount loop
        upperLimit := i - 1;
        for j in 1 .. upperLimit loop
          if(parameterNumbers(i) < parameterNumbers(j) or
             (parameterNumbers(i) = parameterNumbers(j) and
              parameterSigns(i) = '-' and parameterSigns(j) = '+')) then
            tempRuleId := ruleIds(j);
            tempCategory := approverCategories(j);
            tempNumber := parameterNumbers(j);
            tempSign := parameterSigns(j);
            ruleIds(j) := ruleIds(i);
            approverCategories(j) := approverCategories(i);
            parameterNumbers(j) := parameterNumbers(i);
            parameterSigns(j) := parameterSigns(i);
            ruleIds(i) := tempRuleId;
            approverCategories(i) := tempCategory;
            parameterNumbers(i) := tempNumber;
            parameterSigns(i) := tempSign;
          end if;
        end loop;
      end loop;
      exception
        when badParameterException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400234_HAN_ACT_PAR_SIGN');
          ame_util.runtimeException(packageNameIn => 'ame_supervisory_handler',
                                    routineNameIn => 'parseAndSortRules',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_supervisory_handler',
                                    routineNameIn => 'parseAndSortRules',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end parseAndSortRules;
 end ame_supervisory_handler;

/
