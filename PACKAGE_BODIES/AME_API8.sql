--------------------------------------------------------
--  DDL for Package Body AME_API8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_API8" as
/* $Header: ameeapi8.pkb 120.0 2006/02/13 22:59:23 vboggava noship $ */
  procedure getItemProductions(applicationIdIn   in number
                              ,transactionTypeIn in varchar2
                              ,transactionIdIn   in varchar2
                              ,itemClassIn       in varchar2
                              ,itemIdIn          in varchar2
                              ,productionsOut   out nocopy ame_util2.productionsTable) is
    tempProductions ame_util2.productionsTable;
    begin
      ame_engine.updateTransactionState(isTestTransactionIn => false,
                                        isLocalTransactionIn => false,
                                        fetchConfigVarsIn => true,
                                        fetchOldApproversIn => true,
                                        fetchInsertionsIn => true,
                                        fetchDeletionsIn => true,
                                        fetchAttributeValuesIn => true,
                                        fetchInactiveAttValuesIn => true,
                                        processProductionActionsIn => true,
                                        processProductionRulesIn => true,
                                        updateCurrentApproverListIn => true,
                                        updateOldApproverListIn => true,
                                        processPrioritiesIn => true,
                                        prepareItemDataIn => true,
                                        prepareRuleIdsIn => true,
                                        prepareRuleDescsIn => true,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      ame_engine.getProductions(itemClassIn    => itemClassIn
                               ,itemIdIn       => itemIdIn
                               ,productionsOut => tempProductions);
      for i in 1 .. tempProductions.count loop
        productionsOut(i).variable_name := tempProductions(i).variable_name;
        productionsOut(i).variable_value := tempProductions(i).variable_value;
        productionsOut(i).item_class := tempProductions(i).item_class;
        productionsOut(i).item_id := tempProductions(i).item_id;
      end loop;
    end getItemProductions;
end ame_api8;

/
