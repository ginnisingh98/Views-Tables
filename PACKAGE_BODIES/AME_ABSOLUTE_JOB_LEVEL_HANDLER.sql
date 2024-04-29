--------------------------------------------------------
--  DDL for Package Body AME_ABSOLUTE_JOB_LEVEL_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ABSOLUTE_JOB_LEVEL_HANDLER" as
/* $Header: ameeajha.pkb 120.3 2007/12/20 20:01:26 prasashe noship $ */
  /* package variables */
  approverCategories ame_util.charList;
  parametersCount integer;
  parameterNumbers ame_util.idList;
  parameters ame_util.stringList;
  parameterSigns ame_util.charList;
  ruleIds ame_util.idList;
  ruleSatisfiedYN ame_util.charList;
  topDogFound boolean;
  topDogPersonId integer;
  /* forward declarations */
  /*
    getCatSourceAndAuthority does not account for the ALLOW_REQUESTOR_APPROVAL attribute.
    The handler procedure does that.
  */
  procedure getCatSourceAndAuthority(personIdIn in integer,
                                     jobLevelIn in integer,
                                     supervisorIdIn in integer,
                                     categoryOut out nocopy varchar2,
                                     sourceOut out nocopy varchar2,
                                     hasFinalAuthorityYNOut out nocopy varchar2,
                                     supervisorJobLevelOut out nocopy integer,
                                     nextSupervisorIdOut out nocopy integer);
  /*
    parseAndSortRules populates the parameterNumbers and parameterSigns tables in
    ascending lexicographic order, first by numerical order, then with '+' dominating '-'.
    Note that it does not sort the parameters proper.
  */
  procedure parseAndSortRules;
  /* procedures */
  procedure getJobLevelAndSupervisor(personIdIn in integer,
                                     jobLevelOut out nocopy integer,
                                     supervisorIdOut out nocopy integer) as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    jobLevelException exception;
    personDisplayName ame_util.longStringType;
    begin
      select
        nvl(per_jobs.approval_authority, 0),
        per_all_assignments_f.supervisor_id
        into
          jobLevelOut,
          supervisorIdOut
        from
          per_jobs,
          per_all_assignments_f
        where
          per_jobs.job_id = per_all_assignments_f.job_id and
          per_all_assignments_f.person_id = personIdIn and
          per_all_assignments_f.primary_flag = 'Y' and
          per_all_assignments_f.assignment_type in ('E','C') and
          per_all_assignments_f.assignment_status_type_id not in
            (select assignment_status_type_id
               from per_assignment_status_types
               where per_system_status = 'TERM_ASSIGN') and
          trunc(sysdate) between
            per_all_assignments_f.effective_start_date and
            per_all_assignments_f.effective_end_date;
      if(jobLevelOut is null) then
        raise jobLevelException;
      end if;
      exception
        when jobLevelException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400448_AJHA_JOB_NOT_ASSD');
          ame_util.runtimeException(packageNameIn => 'ame_absolute_job_level_handler',
                                    routineNameIn => 'getJobLevelAndSupervisor',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when no_data_found then
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
          ame_util.runtimeException(packageNameIn => 'ame_absolute_job_level_handler',
                                    routineNameIn => 'getJobLevelAndSupervisor',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_absolute_job_level_handler',
                                    routineNameIn => 'getJobLevelAndSupervisor',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getJobLevelAndSupervisor;
  procedure getCatSourceAndAuthority(personIdIn in integer,
                                     jobLevelIn in integer,
                                     supervisorIdIn in integer,
                                     categoryOut out nocopy varchar2,
                                     sourceOut out nocopy varchar2,
                                     hasFinalAuthorityYNOut out nocopy varchar2,
                                     supervisorJobLevelOut out nocopy integer,
                                     nextSupervisorIdOut out nocopy integer) as
    category ame_util.charType;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    hasFinalAuthorityYN ame_util.charType;
    noSupervisorException exception;
    personDisplayName ame_util.longStringType;
    source ame_util.longStringType;
    supervisorJobLevel integer;
    tempRuleRequiresApprover boolean;
    tempRuleSatisfied boolean;
    begin
      /* Initialize the two output arguments that might not otherwise get set. */
     supervisorJobLevelOut := null;
     nextSupervisorIdOut := null;
      /*
        1.  An approver satisfies a rule in any of three cases:
            A.  The rule's parameter number does not exceed the approver's job level.
            B.  The rule's parameter sign is '-', and the job level of the approver's
                supervisor exceeds the rule's parameter number.
            C.  The approver is the top dog.
        2.  An approver has final authority if the approver satisfies all the rules.
            (The handler procedure proper takes care of adding subsequent approvers at
            the same job level, if the relevant mandatory attribute so requires.)
        3.  The source value is a comma-delimited list of the IDs of the rules that
            require an approver.  This procedure builds up the source value according
            to the following logic:
            A.  If a rule has not yet been satisfied, the rule requires the input
                approver.
            B.  Otherwise, the rule requires the input approver only if the approver
                does <<not>> satisfy the rule.  (This would happen in the perverse case
                that an approver satisfies a rule, but their supervisor has a lower
                job level that does not satisfy the rule.)
        4.  An approver's category is ame_util.approvalApproverCategory if any of the
            rule usages requiring the approver is of that category; otherwise the
            approver's category is ame_util.fyiApproverCategory.
      */
      category := ame_util.fyiApproverCategory;
      hasFinalAuthorityYN := ame_util.booleanTrue;
      for i in 1 .. parametersCount loop
        if ruleSatisfiedYN(i) = ame_util.booleanFalse then
          /* Determine whether the approver satisfies the current rule. */
          if(personIdIn = topDogPersonId) then
            tempRuleSatisfied := true;
            topDogFound := true;
          else
            topDogFound := false;
            tempRuleSatisfied := false;
            if(jobLevelIn >= parameterNumbers(i)) then
              tempRuleSatisfied := true;
            elsif(parameterSigns(i) = '-') then
              if supervisorIdIn is null then
                supervisorJobLevel := 0;
              else
                if(supervisorJobLevel is null) then
                  if(supervisorIdIn is null) then
                    raise noSupervisorException;
                  end if;
                  getJobLevelAndSupervisor(personIdIn => supervisorIdIn,
                                           jobLevelOut => supervisorJobLevel,
                                           supervisorIdOut => nextSupervisorIdOut);
                  supervisorJobLevelOut := supervisorJobLevel;
                end if;
                if(supervisorJobLevel > parameterNumbers(i)) then
                  tempRuleSatisfied := true;
                end if;
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
          if(tempRuleRequiresApprover)
            then
            /* Update source. */
            ame_util.appendRuleIdToSource(ruleIdIn => ruleIds(i),
                                          sourceInOut => source);
            /* Update category as needed. */
            if(category = ame_util.fyiApproverCategory and
               approverCategories(i) = ame_util.approvalApproverCategory) then
              category := ame_util.approvalApproverCategory;
            end if;
          end if;
        end if;
      end loop;
      categoryOut := category;
      hasFinalAuthorityYNOut := hasFinalAuthorityYN;
      sourceOut := source;
      exception
        when noSupervisorException then
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
          ame_util.runtimeException(packageNameIn => 'ame_absolute_job_level_handler',
                                    routineNameIn => 'getCatSourceAndAuthority',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          categoryOut := null;
          hasFinalAuthorityYNOut := null;
          sourceOut := null;
          ame_util.runtimeException(packageNameIn => 'ame_absolute_job_level_handler',
                                    routineNameIn => 'getCatSourceAndAuthority',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getCatSourceAndAuthority;
  procedure handler as
    COAInsertee ame_util.approverRecord2;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    finalAuthorityApproverCategory ame_util.charType;
    finalAuthorityFound boolean;
    finalAuthoritySource ame_util.longStringType;
    firstApproverSource ame_util.longStringType;
    includeAllJobLevelApprovers boolean;
    noSupervisorException exception;
    nullFirstIdException exception;
    personDisplayName ame_util.longStringType;
    requestorId integer;
    startingPointId integer;
    tempApprover ame_util.approverRecord2;
    tempHasFinalAuthorityYN ame_util.charType;
    tempJobLevel integer;
    tempMemberOrderNumber integer;
    tempOldJobLevel integer;
    tempSupervisorId integer;
    tempSupervisorJobLevel integer;
    tempNextSupervisorId integer;
    topDogRequestorException exception;
    votingRegimeType ame_util.stringType;
    firstAuthInsExists boolean := false;
    coaInsAuthForward boolean := false;
    begin
      /* Populate some of the package variables. */
      finalAuthorityApproverCategory := null;
      finalAuthoritySource := null;
      includeAllJobLevelApprovers :=
        ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.includeAllApproversAttribute) =
        ame_util.booleanAttributeTrue;
      topDogPersonId := to_number(ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.topSupPersonIdAttribute));
      /*
        The engine only calls a handler if a rule requiring it exists, so we can assume that
        the package variables that ame_engine.getHandlerRules initializes are nonempty.
        Fetch the rules and sort them in increasing parameter order.  (Duplicate parameters
        are harmless here.)
      */
      ame_engine.getHandlerRules2(ruleIdsOut => ruleIds,
                                  approverCategoriesOut => approverCategories,
                                  parametersOut => parameters);
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
      /* Check to see if there is a COA first approver set */
      ame_engine.getHandlerCOAFirstApprover(itemClassIn => tempApprover.item_class,
                                            itemIdIn => tempApprover.item_id,
                                            actionTypeIdIn => tempApprover.action_type_id,
                                            groupOrChainIdIn => tempApprover.group_or_chain_id,
                                            nameOut => COAInsertee.name,
                                            origSystemOut => COAInsertee.orig_system,
                                            origSystemIdOut => COAInsertee.orig_system_id,
                                            displayNameOut => COAInsertee.display_name,
                                            sourceOut => COAInsertee.source);
      if(COAInsertee.name is null) then
            /* Check to see if job_level_non_default_starting_point_person_id is defined */
        startingPointId :=
          to_number(ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.jobLevelStartingPointAttribute));
        if  startingPointId is null then
          requestorId :=
            to_number(ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.transactionRequestorAttribute));
          if(requestorId is null) then
            raise nullFirstIdException;
          end if;
          tempApprover.orig_system_id := requestorId;
          /* Chain has to start from requestor or requestor's manager*/
          getJobLevelAndSupervisor(personIdIn => tempApprover.orig_system_id,
                                   jobLevelOut => tempJobLevel,
                                   supervisorIdOut => tempSupervisorId);
          /* Check if requestor can self approve. If so, insert the approver as the only approver, with a status
          of approved, and return.*/
          if(ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.allowAutoApprovalAttribute)
                 = ame_util.booleanAttributeTrue)
            then
            getCatSourceAndAuthority(personIdIn => requestorId,
                                     jobLevelIn => tempJobLevel,
                                     supervisorIdIn => tempSupervisorId,
                                     categoryOut => tempApprover.approver_category,
                                     sourceOut => tempApprover.source,
                                     hasFinalAuthorityYNOut => tempHasFinalAuthorityYN,
                                     supervisorJobLevelOut => tempSupervisorJobLevel,
                                     nextSupervisorIdOut => tempNextSupervisorId);
            if(tempHasFinalAuthorityYN = ame_util.booleanTrue) then
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
            end if;
          end if;
          /* As requestor can not self approve, the chain will start from requestor's manager.
             Check to make sure tempSupervisorId is not null, else raise noSupervisorException */
          if tempSupervisorId is null then
            /* check if the requestor was a topDog, if yes raise appropriate exception */
            if tempApprover.orig_system_id = topDogPersonId then
              raise topDogRequestorException;
            end if;
            raise noSupervisorException;
          else
            tempApprover.orig_system_id := tempSupervisorId;
          end if;
        else
          tempApprover.orig_system_id := startingPointId;
        end if;
        tempApprover.api_insertion := ame_util.oamGenerated;
        ame_approver_type_pkg.getWfRolesNameAndDisplayName(origSystemIn => ame_util.perOrigSystem,
                                                           origSystemIdIn => tempApprover.orig_system_id,
                                                           nameOut => tempApprover.name,
                                                           displayNameOut => tempApprover.display_name);
      else   /* COA firstAuthority insertion found  */
        /* assign tempApprover with appropriate values */
        tempApprover.name := COAInsertee.name;
        tempApprover.orig_system := COAInsertee.orig_system;
        tempApprover.orig_system_id := COAInsertee.orig_system_id;
        tempApprover.display_name :=  COAInsertee.display_name;
        firstApproverSource := COAInsertee.source;
        tempApprover.api_insertion := ame_util.apiAuthorityInsertion;
        firstAuthInsExists := true;
      end if;
      getJobLevelAndSupervisor(personIdIn => tempApprover.orig_system_id,
                               jobLevelOut => tempJobLevel,
                               supervisorIdOut => tempSupervisorId);
      /* Build the chain. */
      finalAuthorityFound := false;
      tempMemberOrderNumber := 0; /* pre-increment */
      loop
        getCatSourceAndAuthority(personIdIn => tempApprover.orig_system_id,
                                 jobLevelIn => tempJobLevel,
                                 supervisorIdIn => tempSupervisorId,
                                 categoryOut => tempApprover.approver_category,
                                 sourceOut => tempApprover.source,
                                 hasFinalAuthorityYNOut => tempHasFinalAuthorityYN,
                                 supervisorJobLevelOut => tempSupervisorJobLevel,
                                 nextSupervisorIdOut => tempNextSupervisorId);
        /* reassign the value of source in case approver was a firstAuthority insertee */
        if firstApproverSource is not null then
          tempApprover.source := firstApproverSource;
          firstApproverSource := null;
        end if;
        if(not finalAuthorityFound and
           tempHasFinalAuthorityYN = ame_util.booleanTrue) then
          finalAuthorityFound := true;
          finalAuthorityApproverCategory := tempApprover.approver_category;
          finalAuthoritySource := tempApprover.source;
        end if;
        if (tempApprover.source is null and
           finalAuthoritySource is not null ) then
          tempApprover.approver_category := finalAuthorityApproverCategory;
          tempApprover.source := finalAuthoritySource;
        end if;
        ame_approver_type_pkg.getWfRolesNameAndDisplayName(origSystemIn => ame_util.perOrigSystem,
                                                           origSystemIdIn => tempApprover.orig_system_id,
                                                           nameOut => tempApprover.name,
                                                           displayNameOut => tempApprover.display_name);
        tempApprover.occurrence := ame_engine.getHandlerOccurrence(nameIn =>  tempApprover.name,
                                              itemClassIn => tempApprover.item_class,
                                              itemIdIn => tempApprover.item_id,
                                              actionTypeIdIn => tempApprover.action_type_id,
                                              groupOrChainIdIn => tempApprover.group_or_chain_id);
        tempMemberOrderNumber := tempMemberOrderNumber + 1;
        if(votingRegimeType = ame_util.serializedVoting) then
          tempApprover.member_order_number := tempMemberOrderNumber;
        else /* votingRegimeType in (ame_util.consensusVoting, ame_util.firstApproverVoting) */
          tempApprover.member_order_number := 1;
        end if;
        tempApprover.approval_status := ame_engine.getHandlerApprovalStatus(approverIn => tempApprover);
        /* The engine will set tempApprover.approver_order_number; leave it null here. */
        ame_engine.addApprover(approverIn => tempApprover);
        /* check to see if there is a COA insertion after this approver. If a COA insertion is
           found, keep checking till no more COA insertions. The check for final authority will need to be
           done again.
        */
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
            tempApprover.name := COAInsertee.name;
            tempApprover.orig_system := COAInsertee.orig_system;
            tempApprover.orig_system_id := COAInsertee.orig_system_id;
            tempApprover.display_name :=  COAInsertee.display_name;
            getJobLevelAndSupervisor(personIdIn => tempApprover.orig_system_id,
                                     jobLevelOut => tempJobLevel,
                                     supervisorIdOut => tempSupervisorId);
            getCatSourceAndAuthority(personIdIn => tempApprover.orig_system_id,
                                     jobLevelIn => tempJobLevel,
                                     supervisorIdIn => tempSupervisorId,
                                     categoryOut => tempApprover.approver_category,
                                     sourceOut => tempApprover.source,
                                     hasFinalAuthorityYNOut => tempHasFinalAuthorityYN,
                                     supervisorJobLevelOut => tempSupervisorJobLevel,
                                     nextSupervisorIdOut => tempNextSupervisorId);
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
            if ((tempApprover.approval_status is null) or
                (tempApprover.approval_status in
                        (ame_util.approvedStatus, ame_util.approveAndForwardStatus,
                         ame_util.repeatedStatus, ame_util.suppressedStatus,
                         ame_util.beatByFirstResponderStatus, ame_util.nullStatus)) or
                (tempApprover.approver_category = ame_util.approvalApproverCategory and
                 tempApprover.approval_status = ame_util.notifiedStatus) )
              then
              if(not finalAuthorityFound and
                tempHasFinalAuthorityYN = ame_util.booleanTrue) then
                finalAuthorityFound := true;
              end if;
            end if;
            ame_engine.addApprover(approverIn => tempApprover);
            coaInsAuthForward := true;
          end if;
        end loop;
        /* Decide whether to end the chain. */
        if(topDogFound or
            (finalAuthorityFound and
             not includeAllJobLevelApprovers)) then
          exit;
        end if;
        /* Check to make sure tempSupervisorId is not null, else raise noSupervisorException */
        if tempSupervisorId is null then
          raise noSupervisorException;
        else
          tempApprover.orig_system_id := tempSupervisorId;
        end if;
        tempOldJobLevel := tempJobLevel;
        if(tempSupervisorJobLevel is null) then
          getJobLevelAndSupervisor(personIdIn => tempApprover.orig_system_id,
                                   jobLevelOut => tempJobLevel,
                                   supervisorIdOut => tempSupervisorId);
        else
          tempJobLevel := tempSupervisorJobLevel;
          tempSupervisorId := tempNextSupervisorId;
        end if;
        /*
          At this point finalAuthorityFound implies includeAllJobLevelApprovers, so the following if
          doesn't need to check includeAllJobLevelApprovers.  But it's implicit in the if statement.
        */
        if firstAuthInsExists then
          ame_engine.setDeviationReasonDate(ame_approver_deviation_pkg.firstauthHandlerInsReason,null);
        end if;
        if coaInsAuthForward then
          ame_engine.setDeviationReasonDate(ame_approver_deviation_pkg.forwarHandlerAuthInsReason,null);
        end if;
        if(finalAuthorityFound and
           tempOldJobLevel <> tempJobLevel) then
          exit;
        end if;
      end loop;
      exception
        when noSupervisorException then
          if tempApprover.display_name is null then
            personDisplayName := ame_approver_type_pkg.getApproverDisplayName2(
                                      origSystemIn => ame_util.perOrigSystem,
                                      origSystemIdIn => tempApprover.orig_system_id );
          else
            personDisplayName := tempApprover.display_name;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn     => 'AME_400297_HAN_LACK_SPVR',
            tokenNameOneIn    => 'FIRST_NAME',
            tokenValueOneIn   => personDisplayName,
            tokenNameTwoIn    => 'LAST_NAME',
            tokenValueTwoIn   => null ,
            tokenNameThreeIn  => 'OTHER_NAME',
            tokenValueThreeIn =>  null );
          ame_util.runtimeException(packageNameIn => 'ame_absolute_job_level_handler',
                                    routineNameIn => 'handler',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when nullFirstIdException then
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                              messageNameIn => 'AME_400233_HAN_NO_TRANS_PER_ID');
          ame_util.runtimeException(packageNameIn => 'ame_absolute_job_level_handler',
                                    routineNameIn => 'handler',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when topDogRequestorException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                    messageNameIn => 'AME_400421_REQ_CANNOT_APPROVE');
          ame_util.runtimeException(packageNameIn => 'ame_absolute_job_level_handler',
                                    routineNameIn => 'handler',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_absolute_job_level_handler',
                                    routineNameIn => 'handler',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end handler;
  procedure parseAndSortRules as
    badParameterException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    tempCategory ame_util.charType;
    tempLength integer;
    tempNumber integer;
    tempRuleId integer;
    tempSign ame_util.charType;
    upperLimit integer;
    begin
      /* Parse. */
      for i in 1 .. parametersCount loop
        tempLength := lengthb(parameters(i));
        parameterNumbers(i) := to_number(substrb(parameters(i), 1, tempLength - 1));
        parameterSigns(i) := substrb(parameters(i), tempLength, tempLength);
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
          ame_util.runtimeException(packageNameIn => 'ame_absolute_job_level_handler',
                                    routineNameIn => 'parseAndSortRules',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_absolute_job_level_handler',
                                    routineNameIn => 'parseAndSortRules',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end parseAndSortRules;
end ame_absolute_job_level_handler;

/
