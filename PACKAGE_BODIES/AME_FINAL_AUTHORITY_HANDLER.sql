--------------------------------------------------------
--  DDL for Package Body AME_FINAL_AUTHORITY_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_FINAL_AUTHORITY_HANDLER" as
/* $Header: ameefaha.pkb 120.1 2005/08/08 05:09:54 ubhat noship $ */
  procedure handler as
    actionParameters ame_util.stringList;
    listModParameterOnes ame_util.stringList;
    listModParameterTwos ame_util.longStringList;
    ruleIds ame_util.idList;
    ruleIndexes ame_util.idList;
    tempApproverIndexes ame_util.idList;
    tempLastForwardeeIndexes ame_util.idList;
    begin
      /*
        This handler is for the final-authority list-modification action type.
        For each input list-modification rule using this action type, the
        handler truncates each chain of authority containing the target approver,
        in the following sense.  First, the handler finds the end of any
        forwarding chain starting with the target approver.  If the
        allowFyiNotifications configuration variable is set to ame_util.yes, all
        approvers after the forwarding chain are converted to FYI recipients.
        Otherwise, the approvers are deleted.  (The target approver must be an
        ame_util.approvalApproverCategory approver.)
      */
      ame_engine.getHandlerRules3(ruleIdsOut => ruleIds,
                                  ruleIndexesOut => ruleIndexes,
                                  parametersOut => actionParameters, /* The action parameters are null here. */
                                  listModParameterOnesOut => listModParameterOnes,
                                  listModParameterTwosOut => listModParameterTwos);
      for i in 1 .. ruleIds.count loop
        tempApproverIndexes.delete;
        ame_engine.getHandlerLMApprovers(listModParameterOneIn => listModParameterOnes(i),
                                         listModParameterTwoIn => listModParameterTwos(i),
                                         includeFyiApproversIn => false,
                                         includeApprovalGroupsIn => false,
                                         returnForwardeesIn => true,
                                         approverIndexesOut => tempApproverIndexes /* not used here */,
                                         lastForwardeeIndexesOut => tempLastForwardeeIndexes);
        /*
          ame_engine.getHandlerLMApprovers returns tempLastForwardeeIndexes in ascending order.  Truncate
          in the opposite order, to avoid having to recalculate the index of each remaining target approver
          after each truncation.
        */
        for j in reverse 1 .. tempLastForwardeeIndexes.count loop
          ame_engine.truncateChain(approverIndexIn => tempLastForwardeeIndexes(j),
                                   ruleIdIn => ruleIds(i));
        end loop;
        if tempLastForwardeeIndexes.count > 0 then
          ame_engine.setRuleApplied(ruleIndexIn => ruleIndexes(i));
        end if;
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_final_authority_handler',
                                    routineNameIn => 'handler',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end handler;
end ame_final_authority_handler;

/
