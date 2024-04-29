--------------------------------------------------------
--  DDL for Package Body AME_SUBSTITUTION_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_SUBSTITUTION_HANDLER" as
/* $Header: ameesbha.pkb 120.1 2005/08/08 05:07:30 ubhat noship $ */
  procedure handler as
    actionParameters ame_util.stringList;
    actionTypeId integer;
    lastForwardeeIndexes ame_util.idList;
    listModParameterOnes ame_util.stringList;
    listModParameterTwos ame_util.longStringList;
    ruleIds ame_util.idList;
    ruleIndexes ame_util.idList;
    tempApproverIndexes ame_util.idList;
    begin
      /*
        1.  Rule usages for substitution rules don't have approver categories.  Instead,
            substitutions must preserve the approver categories of the target approvers.
        2.  All approvers in an approval group or a chain of authority matching an LM
            condition must be replaced.
        3.  A substitution only changes the following approverRecord2 fields:  name,
            orig_system, orig_system_id, display_name, action_type_id, occurrence, source.
      */
      ame_engine.getHandlerRules3(ruleIdsOut => ruleIds,
                                  ruleIndexesOut => ruleIndexes,
                                  parametersOut => actionParameters,
                                  listModParameterOnesOut => listModParameterOnes,
                                  listModParameterTwosOut => listModParameterTwos);
      actionTypeId := ame_engine.getHandlerActionTypeId;
      for i in 1 .. ruleIds.count loop
        tempApproverIndexes.delete;
        ame_engine.getHandlerLMApprovers(listModParameterOneIn => listModParameterOnes(i),
                                         listModParameterTwoIn => listModParameterTwos(i),
                                         includeFyiApproversIn => true,
                                         includeApprovalGroupsIn => true,
                                         returnForwardeesIn => false,
                                         approverIndexesOut => tempApproverIndexes,
                                         lastForwardeeIndexesOut => lastForwardeeIndexes /* not used here */);
        for j in 1 .. tempApproverIndexes.count loop
          /*
            substituteApprover looks up the orig_system, orig_system_id, and display_name
            values corresponding to nameIn.  It calculates the occurrence value, and it
            appends ruleIdIn to the existing source value.
          */
          ame_engine.substituteApprover(approverIndexIn => tempApproverIndexes(j),
                                        nameIn => actionParameters(i),
                                        actionTypeIdIn => actionTypeId,
                                        ruleIdIn => ruleIds(i));
        end loop;
        if tempApproverIndexes.count > 0 then
          ame_engine.setRuleApplied(ruleIndexIn => ruleIndexes(i));
        end if;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_substitution_handler',
                                    routineNameIn => 'handler',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end handler;
end ame_substitution_handler;

/
