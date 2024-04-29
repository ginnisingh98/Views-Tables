--------------------------------------------------------
--  DDL for Package Body AME_TEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_TEST_PKG" as
  /* $Header: ameotest.pkb 120.0 2005/07/26 06:05:34 mbocutt noship $ */
  function getTestTransactionId return varchar2 is
    tempId integer;
    begin
      select ame_test_trans_s.nextval into tempId from dual;
      return(to_char(tempId));
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_test_pkg',
                                    routineNameIn => 'getTestTransactionId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getTestTransactionId;
  function isTestItemIdDuplicate(applicationIdIn in integer,
                                 transactionIdIn in varchar2,
                                 itemClassIdIN in integer,
                                 itemIdIn in varchar2) return boolean as
    cursor itemIdCursor(applicationIdIn in integer,
                        transactionIdIn in varchar2,
                        itemClassIdIn in integer) is
      select item_id
      from ame_test_trans_att_values
      where
        application_id = applicationIdIn and
        transaction_id = transactionIdIn and
        item_class_id = itemClassIdIn and
        item_id is not null
        order by item_id;
    begin
      for itemIdRec in itemIdCursor(applicationIdIn => applicationIdIn,
                                    transactionIdIn => transactionIdIn,
                                    itemClassIdIn => itemClassIdIn) loop
        if(itemIdRec.item_id = itemIdIn) then
          return true;
        end if;
      end loop;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_test_pkg',
                                    routineNameIn => 'isTestItemIdDuplicate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(true);
    end isTestItemIdDuplicate;
  procedure deleteTestItems(applicationIdIn in integer,
                            transactionIdIn in varchar2,
                            itemClassIdIn in integer,
                            deleteIn in ame_util.stringList) as
    upperLimit integer;
    begin
      upperLimit := deleteIn.count;
      forall i in 1 .. upperLimit
        delete from ame_test_trans_att_values
          where
          application_id = applicationIdIn and
          transaction_id = transactionIdIn and
          itemClassIdIn = itemClassIdIn and
          item_id = deleteIn(i);
        commit;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_test_pkg',
                                    routineNameIn => 'deleteTestItems',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end deleteTestItems;
  procedure getAllAttributeValues(applicationIdIn in integer,
                                  transactionIdIn in varchar2,
                                  itemIdIn in varchar2 default null,
                                  attributeIdsOut out nocopy ame_util.idList,
                                  attributeNamesOut out nocopy ame_util.stringList,
                                  attributeTypesOut out nocopy ame_util.stringList,
                                  isMandatoryOut out nocopy ame_util.stringList,
                                  attributeValues1Out out nocopy ame_util.attributeValueList,
                                  attributeValues2Out out nocopy ame_util.attributeValueList,
                                  attributeValues3Out out nocopy ame_util.attributeValueList) as
    cursor attValueCursor(applicationIdIn in integer,
                          transactionIdIn in varchar2,
                          itemIdIn in varchar2) is
      select
        attribute_id,
        attribute_name,
        attribute_type,
        is_mandatory,
        attribute_value_1,
        attribute_value_2,
        attribute_value_3
        from ame_test_trans_att_values
        where
          application_id = applicationIdIn and
          transaction_id = transactionIdIn and
          ((itemIdIn is null and item_id is null) or
           itemIdIn = item_id)
        order by attribute_name;
    outputIndex integer;
    begin
      outputIndex := 0; /* pre-increment */
      for tempAttValue in attValueCursor(applicationIdIn => applicationIdIn,
                                         transactionIdIn => transactionIdIn,
                                         itemIdIn => itemIdIn) loop
        outputIndex := outputIndex + 1;
        attributeIdsOut(outputIndex) := tempAttValue.attribute_id;
        attributeNamesOut(outputIndex) := tempAttValue.attribute_name;
        attributeTypesOut(outputIndex) := tempAttValue.attribute_type;
        isMandatoryOut(outputIndex) := tempAttValue.is_mandatory;
        attributeValues1Out(outputIndex) := tempAttValue.attribute_value_1;
        attributeValues2Out(outputIndex) := tempAttValue.attribute_value_2;
        attributeValues3Out(outputIndex) := tempAttValue.attribute_value_3;
      end loop;
      if(outputIndex = 0) then
        attributeIdsOut := ame_util.emptyIdList;
        attributeNamesOut := ame_util.emptyStringList;
        attributeTypesOut := ame_util.emptyStringList;
        isMandatoryOut := ame_util.emptyStringList;
        attributeValues1Out := ame_util.emptyAttributeValueList;
        attributeValues2Out := ame_util.emptyAttributeValueList;
        attributeValues3Out := ame_util.emptyAttributeValueList;
      end if;
      exception
        when others then
          rollback;
          attributeIdsOut := ame_util.emptyIdList;
          attributeNamesOut := ame_util.emptyStringList;
          attributeTypesOut := ame_util.emptyStringList;
          isMandatoryOut := ame_util.emptyStringList;
          attributeValues1Out := ame_util.emptyAttributeValueList;
          attributeValues2Out := ame_util.emptyAttributeValueList;
          attributeValues3Out := ame_util.emptyAttributeValueList;
          ame_util.runtimeException(packageNameIn => 'ame_test_pkg',
                                    routineNameIn => 'getAllAttributeValues',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getAllAttributeValues;
  procedure getAllAttributeValues2(applicationIdIn in integer,
                                   transactionIdIn in varchar2,
                                   itemClassIdIn in integer,
                                   itemIdIn in varchar2 default null,
                                   attributeIdsOut out nocopy ame_util.idList,
                                   attributeNamesOut out nocopy ame_util.stringList,
                                   attributeTypesOut out nocopy ame_util.stringList,
                                   isMandatoryOut out nocopy ame_util.stringList,
                                   attributeValues1Out out nocopy ame_util.attributeValueList,
                                   attributeValues2Out out nocopy ame_util.attributeValueList,
                                   attributeValues3Out out nocopy ame_util.attributeValueList) as
    cursor attValueCursor(applicationIdIn in integer,
                          transactionIdIn in varchar2,
                          itemClassIdIn in integer,
                          itemIdIn in varchar2) is
      select
        attribute_id,
        attribute_name,
        attribute_type,
        is_mandatory,
        attribute_value_1,
        attribute_value_2,
        attribute_value_3
        from ame_test_trans_att_values
        where
          application_id = applicationIdIn and
          transaction_id = transactionIdIn and
          item_class_id = itemClassIdIn and
          ((itemIdIn is null and item_id is null) or
           itemIdIn = item_id)
        order by attribute_name;
    outputIndex integer;
    begin
      outputIndex := 0; /* pre-increment */
      for tempAttValue in attValueCursor(applicationIdIn => applicationIdIn,
                                         transactionIdIn => transactionIdIn,
                                         itemClassIdIn => itemClassIdIn,
                                         itemIdIn => itemIdIn) loop
        outputIndex := outputIndex + 1;
        attributeIdsOut(outputIndex) := tempAttValue.attribute_id;
        attributeNamesOut(outputIndex) := tempAttValue.attribute_name;
        attributeTypesOut(outputIndex) := tempAttValue.attribute_type;
        isMandatoryOut(outputIndex) := tempAttValue.is_mandatory;
        attributeValues1Out(outputIndex) := tempAttValue.attribute_value_1;
        attributeValues2Out(outputIndex) := tempAttValue.attribute_value_2;
        attributeValues3Out(outputIndex) := tempAttValue.attribute_value_3;
      end loop;
      if(outputIndex = 0) then
        attributeIdsOut := ame_util.emptyIdList;
        attributeNamesOut := ame_util.emptyStringList;
        attributeTypesOut := ame_util.emptyStringList;
        isMandatoryOut := ame_util.emptyStringList;
        attributeValues1Out := ame_util.emptyAttributeValueList;
        attributeValues2Out := ame_util.emptyAttributeValueList;
        attributeValues3Out := ame_util.emptyAttributeValueList;
      end if;
      exception
        when others then
          rollback;
          attributeIdsOut := ame_util.emptyIdList;
          attributeNamesOut := ame_util.emptyStringList;
          attributeTypesOut := ame_util.emptyStringList;
          isMandatoryOut := ame_util.emptyStringList;
          attributeValues1Out := ame_util.emptyAttributeValueList;
          attributeValues2Out := ame_util.emptyAttributeValueList;
          attributeValues3Out := ame_util.emptyAttributeValueList;
          ame_util.runtimeException(packageNameIn => 'ame_test_pkg',
                                    routineNameIn => 'getAllAttributeValues2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getAllAttributeValues2;
  procedure getApplicableRules(applicationIdIn in integer,
                               transactionIdIn in varchar2,
                               ruleListVersionIn in integer,
                               testOrRealTransTypeIn in varchar2,
                               ruleItemClassIdsOut out nocopy ame_util.idList,
                               itemClassIdsOut out nocopy ame_util.idList,
                               itemIdsOut out nocopy ame_util.stringList,
                               ruleTypesOut out nocopy ame_util.idList,
                               ruleDescriptionsOut out nocopy ame_util.stringList,
                               ruleIdsOut out nocopy ame_util.idList) as
    isTestTransaction boolean;
    processPriorities boolean;
    processProductionActions boolean;
    processProductionRules boolean;
    tempConfigVarValue ame_util.stringType;
    begin
      if(ruleListVersionIn = 1) then
        /* The returned rule list does not account for priorities, exceptions,
           or multiple actions. */
        processPriorities := false;
      elsif(ruleListVersionIn = 2) then
        /* The returned rule list accounts for priorities but not exceptions
           or multiple actions. */
        processPriorities := true;
      else
        /* The returned rule list accounts for priorities, exceptions, and
           multiple actions. */
        processPriorities := true;
      end if;
      if(testOrRealTransTypeIn = ame_util.testTrans) then
        isTestTransaction := true;
      else
        isTestTransaction := false;
      end if;
      ame_engine.updateTransactionState(isTestTransactionIn => isTestTransaction,
                                        isLocalTransactionIn => true,
                                        fetchConfigVarsIn => true,
                                        fetchOldApproversIn => false,
                                        fetchInsertionsIn => false,
                                        fetchDeletionsIn => false,
                                        fetchAttributeValuesIn => true,
                                        fetchInactiveAttValuesIn => false,
                                        processProductionActionsIn => false,
                                        processProductionRulesIn => true,
                                        updateCurrentApproverListIn => false,
                                        updateOldApproverListIn => false,
                                        processPrioritiesIn => processPriorities,
                                        prepareItemDataIn => false,
                                        prepareRuleIdsIn => false,
                                        prepareRuleDescsIn => false,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => applicationIdIn,
                                        fndApplicationIdIn => null,
                                        transactionTypeIdIn => null);
      ame_engine.getTestTransApplicableRules(ruleItemClassIdsOut => ruleItemClassIdsOut,
                                             itemClassIdsOut => itemClassIdsOut,
                                             itemIdsOut => itemIdsOut,
                                             ruleIdsOut => ruleIdsOut,
                                             ruleTypesOut => ruleTypesOut,
                                             ruleDescriptionsOut => ruleDescriptionsOut);
      exception
        when others then
          rollback;
          ruleItemClassIdsOut := ame_util.emptyIdList;
          itemClassIdsOut := ame_util.emptyIdList;
          itemIdsOut := ame_util.emptyStringList;
          ruleTypesOut := ame_util.emptyIdList;
          ruleIdsOut := ame_util.emptyIdList;
          ruleDescriptionsOut := ame_util.emptyStringList;
          ame_util.runtimeException(packageNameIn => 'ame_test_pkg',
                                    routineNameIn => 'getApplicableRules',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getApplicableRules;
  procedure getApproverAttributes(applicationIdIn in integer,
                                  transactionIdIn in varchar2,
                                  itemClassIdIn   in integer,
                                  itemIdIn        in varchar2,
                                  attributeIdsOut    out nocopy ame_util.IdList,
                                  attributeNamesOut  out nocopy ame_util.stringList,
                                  approverTypeIdsOut out nocopy ame_util.idList) as
    cursor attributeCursor(applicationIdIn in integer,
                           transactionIdIn in varchar2,
                           itemClassIdIn   in integer,
                           itemIdIn        in varchar2) is
      select
        ame_attributes.attribute_id,
        ame_attributes.name,
        ame_attributes.approver_type_id
        from ame_test_trans_att_values,
             ame_attributes
        where
          ame_attributes.attribute_id = ame_test_trans_att_values.attribute_id and
          ame_attributes.item_class_id = itemClassIdIn and
          ame_test_trans_att_values.item_id        = itemIdIn        and
          ame_test_trans_att_values.application_id = applicationIdIn and
          ame_test_trans_att_values.transaction_id = transactionIdIn and
          ame_attributes.approver_type_id is not null and
          sysdate between ame_attributes.start_date and
            nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate)
        order by ame_attributes.name;
    begin
      open attributeCursor(applicationIdIn => applicationIdIn,
                           transactionIdIn => transactionIdIn,
                           itemClassIdIn   => itemClassIdIn,
                           itemIdIn        => itemIdIn);
      fetch attributeCursor bulk collect
        into
          attributeIdsOut,
          attributeNamesOut,
          approverTypeIdsOut;
      close attributeCursor;
      exception
        when others then
          attributeIdsOut := ame_util.emptyIdList;
          attributeNamesOut := ame_util.emptyStringList;
          approverTypeIdsOut := ame_util.emptyIdList;
          ame_util.runtimeException(packageNameIn => 'ame_test_pkg',
                                    routineNameIn => 'getApproverAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getApproverAttributes;
  procedure getApproverList(applicationIdIn in integer,
                            transactionIdIn in varchar2,
                            testOrRealTransTypeIn in varchar2,
                            approverListStageIn in integer,
                            approverListOut out nocopy ame_util.approversTable2,
                            productionIndexesOut out nocopy ame_util.idList,
                            variableNamesOut out nocopy ame_util.stringList,
                            variableValuesOut out nocopy ame_util.stringList,
                            doRepeatSubstitutionsOut out nocopy varchar2) as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    isTestTransaction boolean;
    processProductionActions boolean;
    processProductionRules boolean;
    stageException exception;
    tempConfigVarValue ame_util.stringType;
    begin
      if(approverListStageIn < 1 or approverListStageIn > 6) then
        raise stageException;
      end if;
      ame_engine.getTestTransApprovers(isTestTransactionIn => testOrRealTransTypeIn = ame_util.testTrans,
                                       transactionIdIn => transactionIdIn,
                                       ameApplicationIdIn => applicationIdIn,
                                       approverListStageIn => approverListStageIn,
                                       approversOut => approverListOut,
																			 productionIndexesOut => productionIndexesOut,
                                       variableNamesOut => variableNamesOut,
                                       variableValuesOut => variableValuesOut);
      doRepeatSubstitutionsOut := ame_engine.getHeaderAttValue2(attributeNameIn=> ame_util.repeatSubstitutionsAttribute);
      exception
        when stageException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn =>'AME_400452_APPR_STAGE_INT');
          ame_util.runtimeException(packageNameIn => 'ame_test_pkg',
                                    routineNameIn => 'getApproverList',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_test_pkg',
                                    routineNameIn => 'getApproverList',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approverListOut := ame_util.emptyApproversTable2;
          raise;
    end getApproverList;
  procedure getItemAttributeValues(applicationIdIn in integer,
                                   transactionIdIn in varchar2,
                                   itemClassIdIn in integer,
                                   itemIdIn in varchar2,
                                   testOrRealTransTypeIn in varchar2,
                                   attributeNamesOut out nocopy ame_util.stringList,
                                   attributeTypesOut out nocopy ame_util.stringList,
                                   attributeValuesOut1 out nocopy ame_util.attributeValueList,
                                   attributeValuesOut2 out nocopy ame_util.attributeValueList,
                                   attributeValuesOut3 out nocopy ame_util.attributeValueList) as
    attributeIds ame_util.idList;
    attributeNames ame_util.stringList;
    attributeTypes ame_util.stringList;
    isTestTransaction boolean;
    outputIndex integer;
    begin
      ame_attribute_pkg.getSubordinateICAttributes2(applicationIdIn => applicationIdIn,
                                                    itemClassIdIn => itemClassIdIn,
                                                    attributeIdsOut => attributeIds,
                                                    attributeNamesOut => attributeNames,
                                                    attributeTypesOut => attributeTypes);
      outputIndex := 0; /* pre-increment */
      if(testOrRealTransTypeIn = ame_util.testTrans) then
        isTestTransaction := true;
      else
        isTestTransaction := false;
      end if;
      ame_engine.updateTransactionState(isTestTransactionIn => isTestTransaction,
                                        isLocalTransactionIn => true,
                                        fetchConfigVarsIn => true,
                                        fetchOldApproversIn => false,
                                        fetchInsertionsIn => false,
                                        fetchDeletionsIn => false,
                                        fetchAttributeValuesIn => true,
                                        fetchInactiveAttValuesIn => true,
                                        processProductionActionsIn => false,
                                        processProductionRulesIn => false,
                                        updateCurrentApproverListIn => false,
                                        updateOldApproverListIn => false,
                                        processPrioritiesIn => false,
                                        prepareItemDataIn => false,
                                        prepareRuleIdsIn => false,
                                        prepareRuleDescsIn => false,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => applicationIdIn,
                                        fndApplicationIdIn => null,
                                        transactionTypeIdIn => null);
      for i in 1 .. attributeIds.count loop
        outputIndex := outputIndex + 1;
        attributeNamesOut(outputIndex) := attributeNames(i);
        attributeTypesOut(outputIndex) := attributeTypes(i);
        ame_engine.getItemAttValues1(attributeIdIn => attributeIds(i),
                                     itemIdIn => itemIdIn,
                                     attributeValue1Out => attributeValuesOut1(outputIndex),
                                     attributeValue2Out => attributeValuesOut2(outputIndex),
                                     attributeValue3Out => attributeValuesOut3(outputIndex));
      end loop;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_test_pkg',
                                    routineNameIn => 'getItemAttributeValues',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          attributeNamesOut := ame_util.emptyStringList;
          attributeValuesOut1 := ame_util.emptyAttributeValueList;
          attributeValuesOut2 := ame_util.emptyAttributeValueList;
          attributeValuesOut3 := ame_util.emptyAttributeValueList;
          raise;
  end getItemAttributeValues;
  procedure getItemIds(applicationIdIn in integer,
                       transactionIdIn in varchar2,
                       itemClassIdIn in integer,
                       itemIdsOut out nocopy ame_util.stringList) as
    cursor itemIdCursor(applicationIdIn in integer,
                        transactionIdIn in varchar2,
                        itemClassIdIn in integer) is
      select distinct item_id
      from ame_test_trans_att_values
      where
        application_id = applicationIdIn and
        transaction_id = transactionIdIn and
        item_class_id = itemClassIdIn and
        item_id is not null
        order by item_id;
    begin
      open itemIdCursor(applicationIdIn => applicationIdIn,
                        transactionIdIn => transactionIdIn,
                        itemClassIdIn => itemClassIdIn);
      fetch itemIdCursor bulk collect
        into itemIdsOut;
      close itemIdCursor;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_test_pkg',
                                    routineNameIn => 'getitemIds',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
           itemIdsOut := ame_util.emptyStringList;
          raise;
    end getitemIds;
  procedure getTransactionProductions(applicationIdIn in integer,
                                      transactionIdIn in varchar2,
                                      testOrRealTransTypeIn in varchar2,
                                      variableNamesOut out nocopy ame_util.stringList,
                                      variableValuesOut out nocopy ame_util.stringList) as
    isTestTransaction boolean;
    begin
      if(testOrRealTransTypeIn = ame_util.testTrans) then
        isTestTransaction := true;
      else
        isTestTransaction := false;
      end if;
      ame_engine.updateTransactionState(isTestTransactionIn => isTestTransaction,
                                        isLocalTransactionIn => true,
                                        fetchConfigVarsIn => true,
                                        fetchOldApproversIn => false,
                                        fetchInsertionsIn => false,
                                        fetchDeletionsIn => false,
                                        fetchAttributeValuesIn => true,
                                        fetchInactiveAttValuesIn => false,
                                        processProductionActionsIn => false,
                                        processProductionRulesIn => true,
                                        updateCurrentApproverListIn => false,
                                        updateOldApproverListIn => false,
                                        processPrioritiesIn => false,
                                        prepareItemDataIn => false,
                                        prepareRuleIdsIn => false,
                                        prepareRuleDescsIn => false,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => applicationIdIn,
                                        fndApplicationIdIn => null,
                                        transactionTypeIdIn => null);
      ame_engine.getTransVariableNames(transVariableNamesOut => variableNamesOut);
      ame_engine.getTransVariableValues(transVariableValuesOut => variableValuesOut);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_test_pkg',
                                    routineNameIn => 'getTransactionProductions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
           variableNamesOut := ame_util.emptyStringList;
           variableValuesOut := ame_util.emptyStringList;
          raise;
    end getTransactionProductions;
  procedure initializeTestTrans(applicationIdIn in integer,
                                transactionIdIn in varchar2,
                                itemClassIdIn in integer default null,
                                isHeaderItemClassIn in boolean default true,
                                itemIdIn in varchar2 default null) as
    attributeIds ame_util.idList;
    attributeNames ame_util.stringList;
    attributeTypes ame_util.stringList;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    isLineItem boolean;
    isMandatory ame_util.charType;
    isNonHeaderAttributeItem boolean;
    itemClassId integer;
    noAttributesException exception;
    upperLimit integer;
    begin
      if(isHeaderItemClassIn) then
        ame_attribute_pkg.getActiveHeaderAttributes(applicationIdIn => applicationIdIn,
                                                    attributeIdsOut => attributeIds,
                                                    attributeNamesOut => attributeNames);
        itemClassId :=
          ame_admin_pkg.getItemClassIdByName(itemClassNameIn => ame_util.headerItemClassName);
      else
        ame_attribute_pkg.getNonHeaderICAttributes2(applicationIdIn => applicationIdIn,
                                                    itemClassIdIn => itemClassIdIn,
                                                    attributeIdsOut => attributeIds,
                                                    attributeNamesOut => attributeNames);
        itemClassId := itemClassIdIn;
      end if;
      if(attributeIds.count = 0) then
        raise noAttributesException;
      end if;
      upperLimit := attributeIds.count;
      for i in 1 .. upperLimit loop
        if(attributeNames(i) <> ame_util.workflowItemKeyAttribute and
           attributeNames(i) <> ame_util.workflowItemTypeAttribute) then
          attributeTypes(i) := ame_attribute_pkg.getType(attributeIdIn => attributeIds(i));
          if(ame_attribute_pkg.isMandatory(attributeIdIn => attributeIds(i))) then
            isMandatory := ame_util.booleanTrue;
          else
            isMandatory := ame_util.booleanFalse;
          end if;
          insert into ame_test_trans_att_values(
              application_id,
              transaction_id,
              row_timestamp,
              attribute_id,
              attribute_name,
              attribute_type,
              is_mandatory,
              line_item_id,
              item_id,
              item_class_id,
              attribute_value_1,
              attribute_value_2,
              attribute_value_3) values(
                applicationIdIn,
                transactionIdIn,
                sysdate,
                attributeIds(i),
                attributeNames(i),
                attributeTypes(i),
                isMandatory,
                null,
                nvl(itemIdIn, transactionIdIn),
                itemClassId,
                null,
                null,
                null);
          commit;
        end if;
      end loop;
      exception
        when noAttributesException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn =>'AME_400443_TEST_NO_AU_EXST');
          ame_util.runtimeException(packageNameIn => 'ame_test_pkg',
                                    routineNameIn => 'initializeTestTrans',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_test_pkg',
                                    routineNameIn => 'initializeTestTrans',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end initializeTestTrans;
  procedure setAllAttributeValues(applicationIdIn in integer,
                                  transactionIdIn in varchar2,
                                  itemClassIdIn in integer,
                                  attributeIdsIn in ame_util.idList,
                                  itemIdIn in varchar2 default null,
                                  attributeValues1In in ame_util.attributeValueList,
                                  attributeValues2In in ame_util.attributeValueList,
                                  attributeValues3In in ame_util.attributeValueList) as
    attributeNames ame_util.stringList;
    attributeTypes ame_util.stringList;
    isMandatory ame_util.stringList;
    upperLimit integer;
    begin
      delete from ame_test_trans_att_values
        where
          application_id = applicationIdIn and
          transaction_id = transactionIdIn and
          item_class_id = itemClassIdIn and
          ((itemIdIn is null and item_id is null) or
           itemIdIn = item_id);
      commit;
      upperLimit := attributeIdsIn.count;
      for i in 1 .. upperLimit loop
        attributeNames(i) := ame_attribute_pkg.getName(attributeIdIn => attributeIdsIn(i));
        attributeTypes(i) := ame_attribute_pkg.getType(attributeIdIn => attributeIdsIn(i));
        if(ame_attribute_pkg.isMandatory(attributeIdIn => attributeIdsIn(i))) then
          isMandatory(i) := ame_util.booleanTrue;
        else
          isMandatory(i) := ame_util.booleanFalse;
        end if;
      end loop;
      forall i in 1 .. upperLimit
        insert into ame_test_trans_att_values(
          application_id,
          transaction_id,
          row_timestamp,
          attribute_id,
          attribute_name,
          attribute_type,
          is_mandatory,
          line_item_id,
          attribute_value_1,
          attribute_value_2,
          attribute_value_3,
          item_class_id,
          item_id)
          values(
            applicationIdIn,
            transactionIdIn,
            sysdate,
            attributeIdsIn(i),
            attributeNames(i),
            attributeTypes(i),
            isMandatory(i),
            null,
            attributeValues1In(i),
            attributeValues2In(i),
            attributeValues3In(i),
            itemClassIdIn,
            itemIdIn);
        commit;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_test_pkg',
                                    routineNameIn => 'setAllAttributeValues',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end setAllAttributeValues;
  procedure setAttributeValues(applicationIdIn in integer,
                               transactionIdIn in varchar2,
                               itemClassIdIn in integer,
                               itemIdIn in varchar2,
                               attributeIdIn in integer,
                               attributeValue1In in varchar2,
                               attributeValue2In in varchar2 default null,
                               attributeValue3In in varchar2 default null) as
    attributeName ame_attributes.name%type;
    attributeType ame_attributes.attribute_Type%type;
    isMandatory ame_test_trans_att_values.is_mandatory%type;
    begin
      delete from ame_test_trans_att_values
        where
          application_id = applicationIdIn and
          transaction_id = transactionIdIn and
          attribute_id = attributeIdIn and
          item_class_id = itemClassIdIn and
          itemIdIn = item_id;
      commit;
      if(ame_attribute_pkg.isMandatory(attributeIdIn => attributeIdIn)) then
        isMandatory := ame_util.booleanTrue;
      else
        isMandatory := ame_util.booleanFalse;
      end if;
      attributeName := ame_attribute_pkg.getName(attributeIdIn => attributeIdIn);
      attributeType := ame_attribute_pkg.getType(attributeIdIn => attributeIdIn);
      insert into ame_test_trans_att_values(
        application_id,
        transaction_id,
        row_timestamp,
        attribute_id,
        attribute_name,
        attribute_type,
        is_mandatory,
        line_item_id,
        item_id,
        item_class_id,
        attribute_value_1,
        attribute_value_2,
        attribute_value_3)
        values(
          applicationIdIn,
          transactionIdIn,
          sysdate,
          attributeIdIn,
          attributeName,
          attributeType,
          isMandatory,
          null,
          itemIdIn,
          itemClassIdIn,
          attributeValue1In,
          attributeValue2In,
          attributeValue3In);
      commit;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_test_pkg',
                                    routineNameIn => 'setAttributeValues',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end setAttributeValues;
end ame_test_pkg;

/
