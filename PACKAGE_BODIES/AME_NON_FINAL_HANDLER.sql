--------------------------------------------------------
--  DDL for Package Body AME_NON_FINAL_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_NON_FINAL_HANDLER" as
/* $Header: ameenfha.pkb 120.1 2005/08/08 05:15:00 ubhat noship $ */
  actionParameters ame_util.stringList;
  allRuleIds ame_util.idList;
  allRuleIndexes ame_util.idList;
  currentRuleIdcount integer;
  listModParameterOnes ame_util.stringList;
  listModParameterTwos ame_util.longStringList;
  parametersCount integer;
  parameterNumbers ame_util.idList;
  parameterSigns ame_util.charList;
  parameters ame_util.stringList;
  ruleIds ame_util.idList;
  ruleIndexes ame_util.idList;
  ruleSatisfiedYN ame_util.charList;
  threshholdJobLevel integer;
  topDogFound boolean;
  topDogPersonId integer;
  /* forward declaration */
  procedure getSourceAndAuthority(personIdIn in integer,
                                  jobLevelIn in integer,
                                  supervisorIdIn in integer,
                                  sourceOut out nocopy varchar2,
                                  hasFinalAuthorityYNOut out nocopy varchar2,
                                  supervisorJobLevelOut out nocopy integer,
                                  nextSupervisorIdOut out nocopy integer) ;
  /* getNextTargetApprover, will iterate thru the sorted listModParameterTwos and return
     all the parameters for the next target approver */
  procedure getNextTargetApprover;
  /* This routine will group all the actionParameters, listModParameterTwos and  ruleIds
     based on the listModParameterTwos values.i.e. based on the target approver*/
  procedure groupRules;
 procedure parseAndSortRules;
  /* procedures */
  /* getNextTargetApprover, will iterate thru the sorted listModParameterTwos and return
     all the parameters for the next target approver */
  procedure getNextTargetApprover is
    rowCount integer;
    tempInteger integer;
    begin
      rowCount := 1 ; /* post increment */
      if currentRuleIdCount = actionParameters.count then
        return;
      end if;
      currentRuleIdCount := currentRuleIdCount + 1;
      parameters(rowCount) := actionParameters(currentRuleIdCount);
      ruleIds(rowCount) := allRuleIds(currentRuleIdCount);
      ruleIndexes(rowCount) := allRuleIndexes(currentRuleIdCount);
      tempInteger := currentRuleIdCount + 1;
      for i in tempInteger.. actionParameters.count loop
        if listModParameterTwos(i) = listModParameterTwos(currentRuleIdCount) then
          rowCount := rowCount + 1;
          currentRuleIdCount := currentRuleIdCount + 1;
          parameters(rowCount) := actionParameters(currentRuleIdCount);
          ruleIds(rowCount) := allRuleIds(currentRuleIdCount);
          ruleIndexes(rowCount) := allRuleIndexes(currentRuleIdCount);
        else
          exit;
        end if;
      end loop;
    exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_non_final_handler',
                                    routineNameIn => 'getNextTargetApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getNextTargetApprover;
  /*
    getSourceAndAuthority does not account for the ALLOW_REQUESTOR_APPROVAL attribute.
    The handler procedure does that.
  */
  procedure getSourceAndAuthority(personIdIn in integer,
                                  jobLevelIn in integer,
                                  supervisorIdIn in integer,
                                  sourceOut out nocopy varchar2,
                                  hasFinalAuthorityYNOut out nocopy varchar2,
                                  supervisorJobLevelOut out nocopy integer,
                                  nextSupervisorIdOut out nocopy integer) is
    hasFinalAuthorityYN ame_util.charType;
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
      */
      hasFinalAuthorityYN := ame_util.booleanTrue;
      for i in 1 .. parametersCount loop
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
                ame_absolute_job_level_handler.getJobLevelAndSupervisor(personIdIn => supervisorIdIn,
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
        if(tempRuleRequiresApprover )
          then
          /* Update source. */
          ame_util.appendRuleIdToSource(ruleIdIn => ruleIds(i),
                                        sourceInOut => source);
        end if;
      end loop;
      hasFinalAuthorityYNOut := hasFinalAuthorityYN;
      sourceOut := source;
      exception
        when others then
          hasFinalAuthorityYNOut := null;
          sourceOut := null;
          ame_util.runtimeException(packageNameIn => 'ame_non_final_handler',
                                    routineNameIn => 'getSourceAndAuthority',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getSourceAndAuthority;
  procedure groupRules is
    insertCount integer;
    lowerLimit integer;
    tempRuleId integer;
    tempRuleIndex integer;
    tempActionParameter ame_util.stringType;
    tempListModParameterTwo ame_util.stringType;
    tempListModParameterOne ame_util.stringType;
    tempParameterCount integer;
    begin
      tempParameterCount := listModParameterTwos.count;
      for i in 1 .. tempParameterCount loop
        lowerLimit := i + 1;
        insertCount := i ; /* Pre increment */
        for j in lowerLimit .. tempParameterCount loop
          if(listModParameterTwos(i) = listModParameterTwos(j) ) then
            insertCount := insertCount + 1;
            if j <> insertCount then
              tempRuleId := allRuleIds(j);
              tempRuleIndex := allRuleIndexes(j);
              tempActionParameter := actionParameters(j);
              tempListModParameterTwo := listModParameterTwos(j);
              tempListModParameterOne := listModParameterOnes(j);
              allRuleIds(j) := allRuleIds(insertCount);
              allRuleIndexes(j) := allRuleIndexes(insertCount);
              actionParameters(j) := actionParameters(insertCount);
              listModParameterTwos(j) := listModParameterTwos(insertCount);
              listModParameterOnes(j) := listModParameterOnes(insertCount);
              allRuleIds(insertCount) := tempRuleId;
              allRuleIndexes(insertCount) := tempRuleIndex;
              actionParameters(insertCount) := tempActionParameter;
              listModParameterTwos(insertCount) :=  tempListModParameterTwo;
              listModParameterOnes(insertCount) := tempListModParameterOne;
            end if;
          end if;
        end loop;
      end loop;
    exception
      when others  then
          ame_util.runtimeException(packageNameIn => 'ame_non_final_handler',
                                    routineNameIn => 'groupRules',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end groupRules;
  procedure handler as
    badParameterException exception;
    COAInsertee ame_util.approverRecord2;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    extensionApprovers ame_util.approversTable2;
    extIndex integer;
    finalAuthorityNotFound boolean;
    finalAuthorityFound boolean;
    finalAuthoritySource ame_util.longStringType;
    includeAllJobLevelApprovers boolean;
    insertionThreshhold integer;
    lastForwardeeIndexes ame_util.idList;
    noSupervisorException exception;
    nullFirstIdException exception;
    requestorId integer;
    source ame_util.longStringType;
    startingPointId integer;
    tempApprovers ame_util.approversTable2;
    tempApproverIndexes ame_util.idList;
    tempHasFinalAuthorityYN ame_util.charType;
    tempIndex integer;
    tempJobLevel integer;
    tempLength integer;
    tempMemberOrderNumber integer;
    tempOldJobLevel integer;
    tempSupervisorId integer;
    tempSupervisorJobLevel integer;
    tempNextSupervisorId integer;
    begin
      /* Populate some of the package variables. */
      includeAllJobLevelApprovers := null;
      topDogPersonId := to_number(ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.topSupPersonIdAttribute));
      ame_engine.getHandlerRules3(ruleIdsOut => allRuleIds,
                                  ruleIndexesOut => allRuleIndexes,
                                  parametersOut => actionParameters,
                                  listModParameterOnesOut => listModParameterOnes,
                                  listModParameterTwosOut => listModParameterTwos);
      /* sort all the rules so that they are grouped by listModParameterTwos. In all these
         cases the listModParameterOnes should be final_approver, so, ignore this value */
      groupRules;
      /* Loop for each distinct listModParameterTwos */
      currentRuleIdCount := 0; /* pre increment */
      loop
        /* initialize arrays */
        parameters.delete;
        getNextTargetApprover;
        if parameters.count = 0 then
          exit;
        end if;
        tempApproverIndexes.delete;
        insertionThreshhold := 0;
        ame_engine.getHandlerLMApprovers(listModParameterOneIn => listModParameterOnes(currentRuleIdCount),
                                         listModParameterTwoIn => listModParameterTwos(currentRuleIdCount),
                                         includeFyiApproversIn => false,
                                         includeApprovalGroupsIn => false,
                                         returnForwardeesIn => true,
                                         approverIndexesOut => tempApproverIndexes,
                                         lastForwardeeIndexesOut => lastForwardeeIndexes);
        for j in 1 .. tempApproverIndexes.count loop
          finalAuthorityNotFound := true;
          finalAuthoritySource := null;
          tempIndex := lastForwardeeIndexes(j) + insertionThreshhold;
          /* Get the approver list. This should be inside the loop so that we get the latest list*/
          ame_engine.getApprovers(approversOut => tempApprovers);
          /* Check that the action type id of the target is based on job level handler */
          if (tempApprovers(tempIndex).action_type_id =
                  ame_engine.getActionTypeId(actionTypeNameIn => ame_util.absoluteJobLevelTypeName) or
              tempApprovers(tempIndex).action_type_id =
                  ame_engine.getActionTypeId(actionTypeNameIn => ame_util.relativeJobLevelTypeName) or
              tempApprovers(tempIndex).action_type_id =
                  ame_engine.getActionTypeId(actionTypeNameIn => ame_util.managerFinalApproverTypeName) or
              tempApprovers(tempIndex).action_type_id =
                  ame_engine.getActionTypeId(actionTypeNameIn => ame_util.finalApproverOnlyTypeName) or
              tempApprovers(tempIndex).action_type_id =
                  ame_engine.getActionTypeId(actionTypeNameIn => ame_util.lineItemJobLevelTypeName) or
              tempApprovers(tempIndex).action_type_id =
                  ame_engine.getActionTypeId(actionTypeNameIn => ame_util.dualChainsAuthorityTypeName) )
          then
            if(includeAllJobLevelApprovers is null) then
              includeAllJobLevelApprovers :=
                ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.includeAllApproversAttribute) =
                 ame_util.booleanAttributeTrue;
            end if;
            /* First, get the orig_system_id and job level of the target approver. */
            if tempApprovers(tempIndex).orig_system_id is null then
              ame_approver_type_pkg.getApproverOrigSystemAndId(nameIn =>tempApprovers(tempIndex).name,
                                  origSystemOut => tempApprovers(tempIndex).orig_system,
                                  origSystemIdOut => tempApprovers(tempIndex).orig_system_id);
            end if;
            ame_absolute_job_level_handler.getJobLevelAndSupervisor(
                                  personIdIn => tempApprovers(tempIndex).orig_system_id,
                                  jobLevelOut => tempJobLevel,
                                  supervisorIdOut => tempSupervisorId);
            threshholdJobLevel := tempJobLevel;
            parseAndSortRules;
            for i in 1 .. ruleIds.count loop
              ruleSatisfiedYN(i) := ame_util.booleanFalse;
              ame_engine.setRuleApplied(ruleIndexIn => ruleIndexes(i));
            end loop;
            /*
              Third, walk the chain starting with the target and ending with the last forwardee,
              checking for final authority.
            */
            for k in tempApproverIndexes(j) .. lastForwardeeIndexes(j) loop
              /* no need to check that the approver is in the same chain as the target approver
                 as this is done in the ame_engine.getHandlerLMApprovers() */
              /* Check whether the approver has sufficient authority as per the
                 actionParameter defined */
              ame_absolute_job_level_handler.getJobLevelAndSupervisor(
                                    personIdIn => tempApprovers(k).orig_system_id,
                                    jobLevelOut => tempJobLevel,
                                    supervisorIdOut => tempSupervisorId);
              getSourceAndAuthority(personIdIn => tempApprovers(tempIndex).orig_system_id,
                           jobLevelIn => tempJobLevel,
                           supervisorIdIn => tempSupervisorId,
                           sourceOut =>  source,
                           hasFinalAuthorityYNOut => tempHasFinalAuthorityYN,
                           supervisorJobLevelOut => tempSupervisorJobLevel,
                           nextSupervisorIdOut => tempNextSupervisorId);
              if(tempHasFinalAuthorityYN = ame_util.booleanTrue) then
                finalAuthorityNotFound := false;
                exit;
              end if;
            end loop;
            /* If final authority was not found at the previous step, extend the chain,
              starting from the last forwardee.
              All the approvers inserted this way will have an approver category of 'A'.
            */
            if finalAuthorityNotFound then
              extensionApprovers.delete;
              extIndex := 1;
              finalAuthorityFound := false;
              tempMemberOrderNumber := tempApprovers(tempIndex).member_order_number; /* pre-increment */
              ame_absolute_job_level_handler.getJobLevelAndSupervisor(
                                    personIdIn => tempApprovers(tempIndex).orig_system_id,
                                    jobLevelOut => tempJobLevel,
                                    supervisorIdOut => tempSupervisorId);
              extensionApprovers(extIndex).orig_system_id := tempSupervisorId;
              while finalAuthorityNotFound loop
                /* get the next approver to be inserted */
                ame_absolute_job_level_handler.getJobLevelAndSupervisor(
                                    personIdIn => extensionApprovers(extIndex).orig_system_id,
                                    jobLevelOut => tempJobLevel,
                                    supervisorIdOut => tempSupervisorId);
                extensionApprovers(extIndex).orig_system := ame_util.perOrigSystem;
                extensionApprovers(extIndex).authority := ame_util.authorityApprover;
                -- preserve the action_type_ID and action_type_order_number values of the original chains
                extensionApprovers(extIndex).action_type_id := tempApprovers(tempIndex).action_type_id;
                extensionApprovers(extIndex).item_class := tempApprovers(tempIndex).item_class;
                extensionApprovers(extIndex).item_id := tempApprovers(tempIndex).item_id;
                extensionApprovers(extIndex).item_class_order_number := tempApprovers(tempIndex).item_class_order_number;
                extensionApprovers(extIndex).item_order_number := tempApprovers(tempIndex).item_order_number;
                extensionApprovers(extIndex).sub_list_order_number := tempApprovers(tempIndex).sub_list_order_number;
                extensionApprovers(extIndex).action_type_order_number := tempApprovers(tempIndex).action_type_order_number;
                extensionApprovers(extIndex).group_or_chain_order_number := tempApprovers(tempIndex).group_or_chain_order_number;
                extensionApprovers(extIndex).group_or_chain_id := tempApprovers(tempIndex).group_or_chain_id;
                extensionApprovers(extIndex).approver_category := ame_util.approvalApproverCategory;
                extensionApprovers(extIndex).api_insertion := ame_util.oamGenerated;
                getSourceAndAuthority(personIdIn => extensionApprovers(extIndex).orig_system_id,
                             jobLevelIn => tempJobLevel,
                             supervisorIdIn => tempSupervisorId,
                             sourceOut =>  extensionApprovers(extIndex).source,
                             hasFinalAuthorityYNOut => tempHasFinalAuthorityYN,
                             supervisorJobLevelOut => tempSupervisorJobLevel,
                             nextSupervisorIdOut => tempNextSupervisorId);
                if(not finalAuthorityFound and
                   tempHasFinalAuthorityYN = ame_util.booleanTrue) then
                  finalAuthorityFound := true;
                  finalAuthoritySource := extensionApprovers(extIndex).source;
                end if;
                if (extensionApprovers(extIndex).source is null and
                   finalAuthoritySource is not null ) then
                  extensionApprovers(extIndex).source := finalAuthoritySource;
                end if;
                ame_approver_type_pkg.getWfRolesNameAndDisplayName(origSystemIn => ame_util.perOrigSystem,
                              origSystemIdIn => extensionApprovers(extIndex).orig_system_id,
                              nameOut => extensionApprovers(extIndex).name,
                              displayNameOut => extensionApprovers(extIndex).display_name);
                extensionApprovers(extIndex).occurrence := ame_engine.getHandlerOccurrence(
                              nameIn =>extensionApprovers(extIndex).name,
                              itemClassIn => extensionApprovers(extIndex).item_class,
                              itemIdIn => extensionApprovers(extIndex).item_id,
                              actionTypeIdIn => extensionApprovers(extIndex).action_type_id,
                              groupOrChainIdIn => extensionApprovers(extIndex).group_or_chain_id);
                tempMemberOrderNumber := tempMemberOrderNumber + 1;
                extensionApprovers(extIndex).member_order_number := tempMemberOrderNumber;
                extensionApprovers(extIndex).approval_status := ame_engine.getHandlerApprovalStatus(
                              approverIn => extensionApprovers(extIndex));
                /* The engine will set extensionApprovers(extIndex).approver_order_number; leave it null here. */
                /* check to see if there is a COA insertion after this approver. If a COA
                   insertion is found, keep checking till no more COA insertions. The check
                   for final authority will need to be done again.  */
                loop
                  /* Initialize COAInsertee approverRecord2 */
                  COAInsertee := ame_util.emptyApproverRecord2;
                  /* Check if there are any COAInsertions */
                  ame_engine.getHandlerCOAInsertion(nameIn => extensionApprovers(extIndex).name,
                             itemClassIn => extensionApprovers(extIndex).item_class,
                             itemIdIn => extensionApprovers(extIndex).item_id,
                             actionTypeIdIn => extensionApprovers(extIndex).action_type_id,
                             groupOrChainIdIn => extensionApprovers(extIndex).group_or_chain_id,
                             occurrenceIn => extensionApprovers(extIndex).occurrence,
                             approvalStatusIn => extensionApprovers(extIndex).approval_status,
                             nameOut => COAInsertee.name,
                             origSystemOut => COAInsertee.orig_system,
                             origSystemIdOut => COAInsertee.orig_system_id,
                             displayNameOut => COAInsertee.display_name,
                             sourceOut => COAInsertee.source);
                  if COAInsertee.name is null then
                    exit;
                  else
                    extIndex := extIndex + 1;
                    extensionApprovers(extIndex).name := COAInsertee.name;
                    extensionApprovers(extIndex).orig_system := COAInsertee.orig_system;
                    extensionApprovers(extIndex).orig_system_id := COAInsertee.orig_system_id;
                    extensionApprovers(extIndex).display_name :=  COAInsertee.display_name;
                    ame_absolute_job_level_handler.getJobLevelAndSupervisor(personIdIn => extensionApprovers(extIndex).orig_system_id,
                                       jobLevelOut => tempJobLevel,
                                       supervisorIdOut => tempSupervisorId);
                    extensionApprovers(extIndex).orig_system_id := tempSupervisorId;
                    extensionApprovers(extIndex).orig_system := ame_util.perOrigSystem;
                    extensionApprovers(extIndex).authority := ame_util.authorityApprover;
                    extensionApprovers(extIndex).action_type_id := ame_engine.getHandlerActionTypeId;
                    extensionApprovers(extIndex).item_class := tempApprovers(tempIndex).item_class;
                    extensionApprovers(extIndex).item_id := tempApprovers(tempIndex).item_id;
                    extensionApprovers(extIndex).item_class_order_number := tempApprovers(tempIndex).item_class_order_number;
                    extensionApprovers(extIndex).item_order_number := tempApprovers(tempIndex).item_order_number;
                    extensionApprovers(extIndex).sub_list_order_number := tempApprovers(tempIndex).sub_list_order_number;
                    extensionApprovers(extIndex).action_type_order_number := tempApprovers(tempIndex).action_type_order_number;
                    extensionApprovers(extIndex).group_or_chain_order_number := tempApprovers(tempIndex).group_or_chain_order_number;
                    extensionApprovers(extIndex).group_or_chain_id := tempApprovers(tempIndex).group_or_chain_id;
                    getSourceAndAuthority(personIdIn => extensionApprovers(extIndex).orig_system_id,
                                       jobLevelIn => tempJobLevel,
                                       supervisorIdIn => tempSupervisorId,
                                       sourceOut =>  extensionApprovers(extIndex).source,
                                       hasFinalAuthorityYNOut => tempHasFinalAuthorityYN,
                                       supervisorJobLevelOut => tempSupervisorJobLevel,
                                       nextSupervisorIdOut => tempNextSupervisorId);
                    extensionApprovers(extIndex).source := COAInsertee.source;
                    extensionApprovers(extIndex).api_insertion := ame_util.apiAuthorityInsertion;
                    tempMemberOrderNumber := tempMemberOrderNumber + 1;
                    extensionApprovers(extIndex).member_order_number := tempMemberOrderNumber;
                    extensionApprovers(extIndex).occurrence := ame_engine.getHandlerOccurrence(
                                        nameIn =>  extensionApprovers(extIndex).name,
                                        itemClassIn => extensionApprovers(extIndex).item_class,
                                        itemIdIn => extensionApprovers(extIndex).item_id,
                                        actionTypeIdIn => extensionApprovers(extIndex).action_type_id,
                                        groupOrChainIdIn => extensionApprovers(extIndex).group_or_chain_id);
                    extensionApprovers(extIndex).approval_status :=
                          ame_engine.getHandlerApprovalStatus(approverIn => extensionApprovers(extIndex));
                    /* If approver has a status of ame_util.approve or
                       ame_util.approveAndForwardStatus or ame_util.nullStatus check to see
                       if approver could have final authority */
                    if extensionApprovers(extIndex).approval_status in (ame_util.approvedStatus, ame_util.approveAndForwardStatus,
                                                  ame_util.nullStatus)
                      then
                      if(not finalAuthorityFound and
                        tempHasFinalAuthorityYN = ame_util.booleanTrue) then
                        finalAuthorityFound := true;
                        tempOldJobLevel := tempJobLevel;
                      end if;
                    end if;
                    extIndex := extIndex + 1;
                  end if;
                end loop;
                /* Decide whether to end the chain. */
                if(topDogFound or
                    (finalAuthorityFound and
                     not includeAllJobLevelApprovers)) then
                  finalAuthorityNotFound := false;
                  exit;
                end if;
                tempOldJobLevel := tempJobLevel;
                /* Check to make sure tempSupervisorId is not null, else raise noSupervisorException */
                if tempSupervisorId is null then
                  raise noSupervisorException;
                end if;
                if(tempSupervisorJobLevel is null) then
                  ame_absolute_job_level_handler.getJobLevelAndSupervisor(personIdIn => tempSupervisorId,
                                           jobLevelOut => tempSupervisorJobLevel,
                                           supervisorIdOut => tempNextSupervisorId);
                end if;
                /*
                  At this point finalAuthorityFound implies includeAllJobLevelApprovers, so the following if
                  doesn't need to check includeAllJobLevelApprovers.  But it's implicit in the if statement.
                */
                if(finalAuthorityFound and
                   tempOldJobLevel < tempSupervisorJobLevel) then
                  finalAuthorityNotFound := false;
                  exit;
                end if;
                extIndex := extIndex + 1;
                extensionApprovers(extIndex).orig_system_id := tempSupervisorId;
                tempJobLevel := tempSupervisorJobLevel;
                tempSupervisorId := tempNextSupervisorId;
              end loop;
              ame_engine.insertApprovers(firstIndexIn => lastForwardeeIndexes(j)+ insertionThreshhold + 1,
                                         approversIn => extensionApprovers);
              insertionThreshhold := insertionThreshhold + extensionApprovers.count;
            end if;
          end if;  /* This if corresponds to the check that action type id is valid */
        end loop;
      end loop;
      exception
        when badParameterException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400234_HAN_ACT_PAR_SIGN');
          ame_util.runtimeException(packageNameIn => 'ame_non_final_handler',
                                    routineNameIn => 'handler',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when noSupervisorException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400232_HAN_NO_SUPVSR_ID',
                                              tokenNameOneIn => 'PERSON_ID',
                                              tokenValueOneIn =>extensionApprovers(extIndex).orig_system_id);
          ame_util.runtimeException(packageNameIn => 'ame_non_final_handler',
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
          ame_util.runtimeException(packageNameIn => 'ame_non_final_handler',
                                    routineNameIn => 'handler',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_non_final_handler',
                                    routineNameIn => 'handler',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end handler;
 procedure parseAndSortRules is
    badParameterException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    tempCategory ame_util.charType;
    tempLength integer;
    tempNumber integer;
    tempRuleId integer;
    tempRuleIndex integer;
    tempSign ame_util.charType;
    upperLimit integer;
   begin
     parametersCount := parameters.count;
     /* Parse. */
     for i in 1 .. parametersCount loop
       tempLength := lengthb(parameters(i));
       if(substrb(parameters(i), 1, 1) = 'R') then
         parameterNumbers(i) := to_number(substrb(parameters(i), 2, tempLength - 2)) +
                                threshholdJobLevel;
         parameterSigns(i) := substrb(parameters(i), -1, 1);
       else
         parameterNumbers(i) := to_number(substrb(parameters(i), 2, tempLength - 2)) ;
         parameterSigns(i) := substrb(parameters(i), -1, 1);
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
           tempRuleIndex := ruleIndexes(j);
           tempNumber := parameterNumbers(j);
           tempSign := parameterSigns(j);
           ruleIds(j) := ruleIds(i);
           ruleIndexes(j) := ruleIndexes(i);
           parameterNumbers(j) := parameterNumbers(i);
           parameterSigns(j) := parameterSigns(i);
           ruleIds(i) := tempRuleId;
           ruleIndexes(i) := tempRuleIndex;
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
         ame_util.runtimeException(packageNameIn => 'ame_non_final_handler',
                                   routineNameIn => 'parseAndSortRules',
                                   exceptionNumberIn => errorCode,
                                   exceptionStringIn => errorMessage);
         raise_application_error(errorCode,
                                 errorMessage);
       when others then
         ame_util.runtimeException(packageNameIn => 'ame_non_final_handler',
                                   routineNameIn => 'parseAndSortRules',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => sqlerrm);
         raise;
   end parseAndSortRules ;
end ame_non_final_handler;

/
