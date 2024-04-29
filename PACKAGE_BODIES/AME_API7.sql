--------------------------------------------------------
--  DDL for Package Body AME_API7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_API7" as
/* $Header: ameeapi7.pkb 120.0 2005/11/28 07:24:33 srpurani noship $ */
  /*The following method validates itemClass for the current transaction*/
  function validateItemClass(itemClassIn varchar2) return boolean as
    itemClassNames ame_util.stringList;
  begin
    ame_engine.getAllItemClasses(itemClassNamesOut => itemClassNames);
    for i in 1..itemClassNames.count loop
      if itemClassNames(i) = itemClassIn then
        return true;
      end if;
    end loop;
    return false;
  end;
  /*The following method validates itemId for the itemClass for the current
    transaction*/
  function validateItemClassItemId(itemClassIn varchar2
                                  ,itemIdIn varchar2) return boolean as
    itemIds ame_util.stringList;
  begin
    ame_engine.getItemClassItemIds
              (itemClassIdIn => ame_admin_pkg.getItemClassIdByName(itemClassNameIn => itemClassIn),
               itemIdsOut => itemIds );
    for i in 1..itemIds.count loop
      if itemIds(i) = itemIdIn then
        return true;
      end if;
    end loop;
    return false;
  end;
  procedure getAttributeValue( applicationIdIn in number,
                               transactionTypeIn in varchar2,
                               transactionIdIn in varchar2,
                               attributeNameIn in varchar2,
                               itemClassIn in varchar2,
                               itemIdIn in varchar2,
                               attributeValue1Out out nocopy varchar2,
                               attributeValue2Out out nocopy varchar2,
                               attributeValue3Out out nocopy varchar2) as
    itemId ame_util.stringType;
    itemClass ame_util.stringType;
    invalidItemIdException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    begin
      ame_engine.updateTransactionState(isTestTransactionIn => false,
                                        isLocalTransactionIn => false,
                                        fetchConfigVarsIn => false,
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
                                        ameApplicationIdIn => null,
                                        fndApplicationIdIn => applicationIdIn,
                                        transactionTypeIdIn => transactionTypeIn );
      /* In case no itemClass is passed in , assume it is header and set itemId as
         transactionIdIn */

      if itemClassIn is null or itemClassIn = ame_util.headerItemClassName then
        itemClass := ame_util.headerItemClassName;
        itemId := transactionIdIn;
      else
        itemId := itemIdIn;
        itemClass := itemClassIn;
      end if;
      --+
      --+ Validate Item Class Name
      --+
      if not validateItemClass (itemClassIn => itemClass) then
        raise invalidItemIdException;
      end if;
      --+
      --+ Validate Item Id
      --+
      if not validateItemClassItemId (itemClassIn => itemClass,
                                      itemIdIn => itemId ) then
        raise invalidItemIdException;
      end if;
      /*Handle variant attributes */
      if (attributeNameIn  = ame_util.jobLevelStartingPointAttribute or
          attributeNameIn  = ame_util.nonDefStartingPointPosAttr or
          attributeNameIn  = ame_util.nonDefPosStructureAttr or
          attributeNameIn  = ame_util.supStartingPointAttribute or
          attributeNameIn  = ame_util.firstStartingPointAttribute or
          attributeNameIn  = ame_util.secondStartingPointAttribute ) then
         attributeValue1Out := ame_engine.getVariantAttributeValue(attributeIdIn => ame_attribute_pkg.getIdByName(
                                                                               attributeNameIn => attributeNameIn),
                                                                   itemClassIn => itemClass,
                                                                   itemIdIn => itemId
                                                                  );
      else
        ame_engine.getItemAttValues2(attributeNameIn => attributeNameIn,
                                     itemIdIn => itemId,
                                     attributeValue1Out => attributeValue1Out,
                                     attributeValue2Out => attributeValue2Out,
                                     attributeValue3Out => attributeValue3Out);
      end if;
    exception
        when invalidItemIdException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                      messageNameIn => 'AME_400800_INVALID_ITEM_ID');
          ame_util.runtimeException(packageNameIn => 'ame_api7',
                                    routineNameIn => 'getAttributeValue',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api7',
                                    routineNameIn => 'getAttributeValue',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getAttributeValue;
  procedure getGroupMembers1(applicationIdIn in number default null,
                             transactionTypeIn in varchar2 default null,
                             transactionIdIn in varchar2 default null,
                             itemClassIn in varchar2,
                             itemIdIn in varchar2,
                             groupIdIn in number,
                             memberDisplayNamesOut out nocopy ame_util.longStringList)as
      cursor groupMemberCursor(groupIdIn in integer) is
        select
          parameter,
          upper(parameter_name),
          query_string,
          decode(parameter_name,
                 ame_util.approverOamGroupId, null,
                 ame_approver_type_pkg.getApproverDisplayName2(orig_system, orig_system_id)) display_name
          from ame_approval_group_members
          where
            approval_group_id = groupIdIn
          order by order_number;
      badDynamicMemberException exception;
      noItemBindException exception;
      dynamicCursor integer;
      colonLocation1 integer;
      colonLocation2 integer;
      displayNames ame_util.longStringList;
      errorCode integer;
      errorMessage ame_util.longestStringType;
      noTransIdDefinedException exception;
      orderNumbers ame_util.idList;
      memberOrigSystem ame_util.stringType;
      memberOrigSystemId number;
      outputIndex integer;
      parameters ame_util.longStringList;
      queryStrings ame_util.longestStringList;
      rowsFound integer;
      tempGroupMembers dbms_sql.Varchar2_Table;
      upperParameterNames ame_util.stringList;
      tempGroupName       ame_util.stringType;
      begin
        open groupMemberCursor(groupIdIn => groupIdIn);
        fetch groupMemberCursor bulk collect
          into
            parameters,
            upperParameterNames,
            queryStrings,
            displayNames;
        close groupMemberCursor;
        outputIndex := 0; /* pre-increment */
        for i in 1 .. parameters.count loop
          if(upperParameterNames(i) = upper(ame_util.approverOamGroupId)) then
            dynamicCursor := dbms_sql.open_cursor;
            dbms_sql.parse(dynamicCursor,
                           ame_util.removeReturns(stringIn => queryStrings(i),
                                                  replaceWithSpaces => true),
                           dbms_sql.native);
            if(instrb(queryStrings(i),
                      ame_util.transactionIdPlaceholder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noTransIdDefinedException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util.transactionIdPlaceholder,
                                     transactionIdIn,
                                     50);
            end if;
            if(instrb(queryStrings(i),
                      ame_util2.itemClassPlaceHolder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noItemBindException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util2.itemClassPlaceHolder,
                                     itemClassIn,
                                     50);
            end if;
            if(instrb(queryStrings(i),
                      ame_util2.itemIdPlaceHolder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noItemBindException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util2.itemIdPlaceHolder,
                                     itemIdIn,
                                     50);
            end if;
            dbms_sql.define_array(dynamicCursor,
                                  1,
                                  tempGroupMembers,
                                  100,
                                  1);
            rowsFound := dbms_sql.execute(dynamicCursor);
            loop
              rowsFound := dbms_sql.fetch_rows(dynamicCursor);
              dbms_sql.column_value(dynamicCursor,
                                    1,
                                    tempGroupMembers);
              exit when rowsFound < 100;
            end loop;
            dbms_sql.close_cursor(dynamicCursor);
            /*
              Dynamic groups' query strings may return rows having one of two forms:
                (1) approver_type:approver_id
                (2) orig_system:orig_system_id:approver_name
            */
            for j in 1 .. tempGroupMembers.count loop
              colonLocation1 := instrb(tempGroupMembers(j), ':', 1, 1);
              colonLocation2 := instrb(tempGroupMembers(j), ':', 1, 2);
              if(colonLocation1 = 0) then
                raise badDynamicMemberException;
              end if;
              outputIndex := outputIndex + 1;
              if(colonLocation2 = 0) then /* first case (old style) */
                memberOrigSystemId :=
                  substrb(tempGroupMembers(j), (instrb(tempGroupMembers(j), ':', 1, 1) + 1));
                if(substrb(upper(tempGroupMembers(j)), 1, (instrb(tempGroupMembers(j), ':', 1, 1) - 1)) =
                   upper(ame_util.approverPersonId)) then
                  memberOrigSystem := ame_util.perOrigSystem;
                else
                  memberOrigSystem := ame_util.fndUserOrigSystem;
                end if;
              else
                memberOrigSystem :=
                  substrb(tempGroupMembers(j), 1, (instrb(tempGroupMembers(j), ':', 1, 1)-1));
                memberOrigSystemId :=
                  substrb(tempGroupMembers(j), (instrb(tempGroupMembers(j), ':', 1, 1)+1),
                    (instrb(tempGroupMembers(j), ':', 1, 2)-1));
              end if;
               memberDisplayNamesOut(outputIndex) :=
                     ame_approver_type_pkg.getApproverDisplayName2(
                                     origSystemIn => memberOrigSystem,
                                     origSystemIdIn => memberOrigSystemId);
            end loop;
          else /* Copy the static group into the engGroup caches. */
            outputIndex := outputIndex + 1;
            memberDisplayNamesOut(outputIndex) := displayNames(i);
          end if;
        end loop;
      exception
        when badDynamicMemberException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          memberDisplayNamesOut.delete;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                      messageNameIn => 'AME_400454_GRP_DYN_QRY_ERR');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers1',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when noItemBindException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          memberDisplayNamesOut.delete;
          errorCode := -20001;
          ame_api5.getApprovalGroupName(groupIdIn    => groupIdIn
                                       ,groupNameOut => tempGroupName);
          errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400798_GROUP_ITEM_BIND',
                           tokenNameOneIn  => 'APPROVER_GROUP',
                           tokenValueOneIn => tempGroupName);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers3',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when noTransIdDefinedException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          memberDisplayNamesOut.delete;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400455_GRP_DYN_NULL_TXID',
                           tokenNameOneIn  => 'APPROVAL_GROUP',
                           tokenValueOneIn => 'TO_BE_MODIFIED');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers1',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          memberDisplayNamesOut.delete;
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
  end getGroupMembers1;
  procedure getGroupMembers2(applicationIdIn in number default null,
                             transactionTypeIn in varchar2 default null,
                             transactionIdIn in varchar2 default null,
                             itemClassIn in varchar2,
                             itemIdIn in varchar2,
                             groupIdIn in number,
                             memberNamesOut out nocopy ame_util.longStringList,
                             memberDisplayNamesOut out nocopy ame_util.longStringList)as
      cursor groupMemberCursor(groupIdIn in integer) is
        select
          parameter,
          upper(parameter_name),
          query_string,
          decode(parameter_name,
                 ame_util.approverOamGroupId, null,
                 ame_approver_type_pkg.getWfRolesName(orig_system, orig_system_id)) approver_name,
          decode(parameter_name,
                 ame_util.approverOamGroupId, null,
                 ame_approver_type_pkg.getApproverDisplayName2(orig_system, orig_system_id)) display_name
          from ame_approval_group_members
          where
            approval_group_id = groupIdIn
          order by order_number;
      badDynamicMemberException exception;
      noItemBindException exception;
      dynamicCursor integer;
      colonLocation1 integer;
      colonLocation2 integer;
      displayNames ame_util.longStringList;
      errorCode integer;
      errorMessage ame_util.longestStringType;
      approverNames ame_util.longStringList;
      memberOrigSystem ame_util.stringType;
      memberOrigSystemId number;
      noTransIdDefinedException exception;
      orderNumbers ame_util.idList;
      origSystemIds ame_util.idList;
      origSystems ame_util.stringList;
      outputIndex integer;
      parameters ame_util.longStringList;
      queryStrings ame_util.longestStringList;
      rowsFound integer;
      tempGroupMembers dbms_sql.Varchar2_Table;
      upperParameterNames ame_util.stringList;
      tempGroupName       ame_util.stringType;
      begin
        open groupMemberCursor(groupIdIn => groupIdIn);
        fetch groupMemberCursor bulk collect
          into
            parameters,
            upperParameterNames,
            queryStrings,
            approverNames,
            displayNames;
        close groupMemberCursor;
        outputIndex := 0; /* pre-increment */
        for i in 1 .. parameters.count loop
          if(upperParameterNames(i) = upper(ame_util.approverOamGroupId)) then
            dynamicCursor := dbms_sql.open_cursor;
            dbms_sql.parse(dynamicCursor,
                           ame_util.removeReturns(stringIn => queryStrings(i),
                                                  replaceWithSpaces => true),
                           dbms_sql.native);
            if(instrb(queryStrings(i),
                      ame_util.transactionIdPlaceholder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noTransIdDefinedException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util.transactionIdPlaceholder,
                                     transactionIdIn,
                                     50);
            end if;
            if(instrb(queryStrings(i),
                      ame_util2.itemClassPlaceHolder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noItemBindException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util2.itemClassPlaceHolder,
                                     itemClassIn,
                                     50);
            end if;
            if(instrb(queryStrings(i),
                      ame_util2.itemIdPlaceHolder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noItemBindException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util2.itemIdPlaceHolder,
                                     itemIdIn,
                                     50);
            end if;
            dbms_sql.define_array(dynamicCursor,
                                  1,
                                  tempGroupMembers,
                                  100,
                                  1);
            rowsFound := dbms_sql.execute(dynamicCursor);
            loop
              rowsFound := dbms_sql.fetch_rows(dynamicCursor);
              dbms_sql.column_value(dynamicCursor,
                                    1,
                                    tempGroupMembers);
              exit when rowsFound < 100;
            end loop;
            dbms_sql.close_cursor(dynamicCursor);
            /*
              Dynamic groups' query strings may return rows having one of two forms:
                (1) approver_type:approver_id
                (2) orig_system:orig_system_id:approver_name
            */
            for j in 1 .. tempGroupMembers.count loop
              colonLocation1 := instrb(tempGroupMembers(j), ':', 1, 1);
              colonLocation2 := instrb(tempGroupMembers(j), ':', 1, 2);
              if(colonLocation1 = 0) then
                raise badDynamicMemberException;
              end if;
              outputIndex := outputIndex + 1;
              if(colonLocation2 = 0) then /* first case (old style) */
                memberOrigSystemId :=
                  substrb(tempGroupMembers(j), (instrb(tempGroupMembers(j), ':', 1, 1) + 1));
                if(substrb(upper(tempGroupMembers(j)), 1, (instrb(tempGroupMembers(j), ':', 1, 1) - 1)) =
                   upper(ame_util.approverPersonId)) then
                  memberOrigSystem := ame_util.perOrigSystem;
                else
                  memberOrigSystem := ame_util.fndUserOrigSystem;
                end if;
              else
                memberOrigSystem :=
                  substrb(tempGroupMembers(j), 1, (instrb(tempGroupMembers(j), ':', 1, 1)-1));
                memberOrigSystemId :=
                  substrb(tempGroupMembers(j), (instrb(tempGroupMembers(j), ':', 1, 1)+1),
                    (instrb(tempGroupMembers(j), ':', 1, 2)-1));
              end if;
              ame_approver_type_pkg.getWfRolesNameAndDisplayName(
                origSystemIn => memberOrigSystem,
                origSystemIdIn => memberOrigSystemId,
                nameOut => memberNamesOut(outputIndex),
                displayNameOut => memberDisplayNamesOut(outputIndex));
            end loop;
          else /* Copy the static group into the engGroup caches. */
            outputIndex := outputIndex + 1;
            memberNamesOut(outputIndex) := approverNames(i);
            memberDisplayNamesOut(outputIndex) := displayNames(i);
          end if;
        end loop;
      exception
        when badDynamicMemberException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                      messageNameIn => 'AME_400454_GRP_DYN_QRY_ERR');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers2',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when noTransIdDefinedException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400455_GRP_DYN_NULL_TXID',
                           tokenNameOneIn  => 'APPROVAL_GROUP',
                           tokenValueOneIn => 'TO_BE_MODIFIED');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers2',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
       when noItemBindException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          memberDisplayNamesOut.delete;
          errorCode := -20001;
         errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400798_GROUP_ITEM_BIND',
                           tokenNameOneIn  => 'APPROVER_GROUP',
                           tokenValueOneIn => tempGroupName);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers3',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getGroupMembers2;
  procedure getGroupMembers3(applicationIdIn in number default null,
                             transactionTypeIn in varchar2 default null,
                             transactionIdIn in varchar2 default null,
                             itemClassIn in varchar2,
                             itemIdIn in varchar2,
                             groupIdIn in number,
                             memberNamesOut out nocopy ame_util.longStringList,
                             memberOrderNumbersOut out nocopy ame_util.idList,
                             memberDisplayNamesOut out nocopy ame_util.longStringList)as
      cursor groupMemberCursor(groupIdIn in integer) is
        select
          parameter,
          upper(parameter_name),
          query_string,
          order_number,
          decode(parameter_name,
                 ame_util.approverOamGroupId, null,
                 ame_approver_type_pkg.getWfRolesName(orig_system, orig_system_id)) approver_name,
          decode(parameter_name,
                 ame_util.approverOamGroupId, null,
                 ame_approver_type_pkg.getApproverDisplayName2(orig_system, orig_system_id)) display_name
          from ame_approval_group_members
          where
            approval_group_id = groupIdIn
          order by order_number;
      badDynamicMemberException exception;
      noItemBindException exception;
      dynamicCursor integer;
      colonLocation1 integer;
      colonLocation2 integer;
      displayNames ame_util.longStringList;
      errorCode integer;
      errorMessage ame_util.longestStringType;
      approverNames ame_util.longStringList;
      memberOrigSystem ame_util.stringType;
      memberOrigSystemId number;
      noTransIdDefinedException exception;
      orderNumbers ame_util.idList;
      origSystemIds ame_util.idList;
      origSystems ame_util.stringList;
      outputIndex integer;
      parameters ame_util.longStringList;
      queryStrings ame_util.longestStringList;
      rowsFound integer;
      tempGroupMembers dbms_sql.Varchar2_Table;
      tempGroupName       ame_util.stringType;
      upperParameterNames ame_util.stringList;
      begin
        open groupMemberCursor(groupIdIn => groupIdIn);
        fetch groupMemberCursor bulk collect
          into
            parameters,
            upperParameterNames,
            queryStrings,
            orderNumbers,
            approverNames,
            displayNames;
        close groupMemberCursor;
        outputIndex := 0; /* pre-increment */
        for i in 1 .. parameters.count loop
          if(upperParameterNames(i) = upper(ame_util.approverOamGroupId)) then
            dynamicCursor := dbms_sql.open_cursor;
            dbms_sql.parse(dynamicCursor,
                           ame_util.removeReturns(stringIn => queryStrings(i),
                                                  replaceWithSpaces => true),
                           dbms_sql.native);
            if(instrb(queryStrings(i),
                      ame_util.transactionIdPlaceholder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noTransIdDefinedException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util.transactionIdPlaceholder,
                                     transactionIdIn,
                                     50);
            end if;
            if(instrb(queryStrings(i),
                      ame_util2.itemClassPlaceHolder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noItemBindException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util2.itemClassPlaceHolder,
                                     itemClassIn,
                                     50);
            end if;
            if(instrb(queryStrings(i),
                      ame_util2.itemIdPlaceHolder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noItemBindException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util2.itemIdPlaceHolder,
                                     itemIdIn,
                                     50);
            end if;
            dbms_sql.define_array(dynamicCursor,
                                  1,
                                  tempGroupMembers,
                                  100,
                                  1);
            rowsFound := dbms_sql.execute(dynamicCursor);
            loop
              rowsFound := dbms_sql.fetch_rows(dynamicCursor);
              dbms_sql.column_value(dynamicCursor,
                                    1,
                                    tempGroupMembers);
              exit when rowsFound < 100;
            end loop;
            dbms_sql.close_cursor(dynamicCursor);
            /*
              Dynamic groups' query strings may return rows having one of two forms:
                (1) approver_type:approver_id
                (2) orig_system:orig_system_id:approver_name
            */
            for j in 1 .. tempGroupMembers.count loop
              colonLocation1 := instrb(tempGroupMembers(j), ':', 1, 1);
              colonLocation2 := instrb(tempGroupMembers(j), ':', 1, 2);
              if(colonLocation1 = 0) then
                raise badDynamicMemberException;
              end if;
              outputIndex := outputIndex + 1;
              memberOrderNumbersOut(outputIndex) := j;
              if(colonLocation2 = 0) then /* first case (old style) */
                memberOrigSystemId :=
                  substrb(tempGroupMembers(j), (instrb(tempGroupMembers(j), ':', 1, 1) + 1));
                if(substrb(upper(tempGroupMembers(j)), 1, (instrb(tempGroupMembers(j), ':', 1, 1) - 1)) =
                   upper(ame_util.approverPersonId)) then
                  memberOrigSystem := ame_util.perOrigSystem;
                else
                  memberOrigSystem := ame_util.fndUserOrigSystem;
                end if;
              else
                memberOrigSystem :=
                  substrb(tempGroupMembers(j), 1, (instrb(tempGroupMembers(j), ':', 1, 1)-1));
                memberOrigSystemId :=
                  substrb(tempGroupMembers(j), (instrb(tempGroupMembers(j), ':', 1, 1)+1),
                    (instrb(tempGroupMembers(j), ':', 1, 2)-1));
              end if;
              ame_approver_type_pkg.getWfRolesNameAndDisplayName(
                origSystemIn => memberOrigSystem,
                origSystemIdIn => memberOrigSystemId,
                nameOut => memberNamesOut(outputIndex),
                displayNameOut => memberDisplayNamesOut(outputIndex));
            end loop;
          else /* Copy the static group into the engGroup caches. */
            outputIndex := outputIndex + 1;
            memberOrderNumbersOut(outputIndex) := orderNumbers(i);
            memberNamesOut(outputIndex) := approverNames(i);
            memberDisplayNamesOut(outputIndex) := displayNames(i);
          end if;
        end loop;
      exception
        when badDynamicMemberException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                      messageNameIn => 'AME_400454_GRP_DYN_QRY_ERR');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers3',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when noTransIdDefinedException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400455_GRP_DYN_NULL_TXID',
                           tokenNameOneIn  => 'APPROVAL_GROUP',
                           tokenValueOneIn => 'TO_BE_MODIFIED');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers3',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
       when noItemBindException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          memberDisplayNamesOut.delete;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400798_GROUP_ITEM_BIND',
                           tokenNameOneIn  => 'APPROVER_GROUP',
                           tokenValueOneIn => tempGroupName);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers3',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
  end getGroupMembers3;
  procedure getGroupMembers4(applicationIdIn in number default null,
                             transactionTypeIn in varchar2 default null,
                             transactionIdIn in varchar2 default null,
                             itemClassIn in varchar2,
                             itemIdIn in varchar2,
                             groupIdIn in number,
                             memberNamesOut out nocopy ame_util.longStringList,
                             memberOrderNumbersOut out nocopy ame_util.idList,
                             memberDisplayNamesOut out nocopy ame_util.longStringList,
                             memberOrigSystemIdsOut out nocopy ame_util.idList,
                             memberOrigSystemsOut out nocopy ame_util.stringList)as
      cursor groupMemberCursor(groupIdIn in integer) is
        select
          orig_system,
          orig_system_id,
          parameter,
          upper(parameter_name),
          query_string,
          order_number,
          decode(parameter_name,
                 ame_util.approverOamGroupId, null,
                 ame_approver_type_pkg.getWfRolesName(orig_system, orig_system_id)) approver_name,
          decode(parameter_name,
                 ame_util.approverOamGroupId, null,
                 ame_approver_type_pkg.getApproverDisplayName2(orig_system, orig_system_id)) display_name
          from ame_approval_group_members
          where
            approval_group_id = groupIdIn
          order by order_number;
      badDynamicMemberException exception;
      dynamicCursor integer;
      colonLocation1 integer;
      colonLocation2 integer;
      displayNames ame_util.longStringList;
      errorCode integer;
      errorMessage ame_util.longestStringType;
      approverNames ame_util.longStringList;
      noTransIdDefinedException exception;
      noItemBindException exception;
      orderNumbers ame_util.idList;
      origSystemIds ame_util.idList;
      origSystems ame_util.stringList;
      outputIndex integer;
      parameters ame_util.longStringList;
      queryStrings ame_util.longestStringList;
      rowsFound integer;
      tempGroupMembers dbms_sql.Varchar2_Table;
      tempGroupName       ame_util.stringType;
      upperParameterNames ame_util.stringList;
      begin
        open groupMemberCursor(groupIdIn => groupIdIn);
        fetch groupMemberCursor bulk collect
          into
            origSystems,
            origSystemIds,
            parameters,
            upperParameterNames,
            queryStrings,
            orderNumbers,
            approverNames,
            displayNames;
        close groupMemberCursor;
        outputIndex := 0; /* pre-increment */
        for i in 1 .. parameters.count loop
          if(upperParameterNames(i) = upper(ame_util.approverOamGroupId)) then
            dynamicCursor := dbms_sql.open_cursor;
            dbms_sql.parse(dynamicCursor,
                           ame_util.removeReturns(stringIn => queryStrings(i),
                                                  replaceWithSpaces => true),
                           dbms_sql.native);
            if(instrb(queryStrings(i),
                      ame_util.transactionIdPlaceholder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noTransIdDefinedException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util.transactionIdPlaceholder,
                                     transactionIdIn,
                                     50);
            end if;
            if(instrb(queryStrings(i),
                      ame_util2.itemClassPlaceHolder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noItemBindException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util2.itemClassPlaceHolder,
                                     itemClassIn,
                                     50);
            end if;
            if(instrb(queryStrings(i),
                      ame_util2.itemIdPlaceHolder) > 0) then
              if transactionIdIn is null then
                 dbms_sql.close_cursor(dynamicCursor);
                 raise noItemBindException;
              end if;
              dbms_sql.bind_variable(dynamicCursor,
                                     ame_util2.itemIdPlaceHolder,
                                     itemIdIn,
                                     50);
            end if;
            dbms_sql.define_array(dynamicCursor,
                                  1,
                                  tempGroupMembers,
                                  100,
                                  1);
            rowsFound := dbms_sql.execute(dynamicCursor);
            loop
              rowsFound := dbms_sql.fetch_rows(dynamicCursor);
              dbms_sql.column_value(dynamicCursor,
                                    1,
                                    tempGroupMembers);
              exit when rowsFound < 100;
            end loop;
            dbms_sql.close_cursor(dynamicCursor);
            /*
              Dynamic groups' query strings may return rows having one of two forms:
                (1) approver_type:approver_id
                (2) orig_system:orig_system_id:approver_name
            */
            for j in 1 .. tempGroupMembers.count loop
              colonLocation1 := instrb(tempGroupMembers(j), ':', 1, 1);
              colonLocation2 := instrb(tempGroupMembers(j), ':', 1, 2);
              if(colonLocation1 = 0) then
                raise badDynamicMemberException;
              end if;
              outputIndex := outputIndex + 1;
              memberOrderNumbersOut(outputIndex) := j;
              if(colonLocation2 = 0) then /* first case (old style) */
                memberOrigSystemIdsOut(outputIndex) :=
                  substrb(tempGroupMembers(j), (instrb(tempGroupMembers(j), ':', 1, 1) + 1));
                if(substrb(upper(tempGroupMembers(j)), 1, (instrb(tempGroupMembers(j), ':', 1, 1) - 1)) =
                   upper(ame_util.approverPersonId)) then
                  memberOrigSystemsOut(outputIndex) := ame_util.perOrigSystem;
                else
                  memberOrigSystemsOut(outputIndex) := ame_util.fndUserOrigSystem;
                end if;
              else
                memberOrigSystemsOut(outputIndex) :=
                  substrb(tempGroupMembers(j), 1, (instrb(tempGroupMembers(j), ':', 1, 1)-1));
                memberOrigSystemIdsOut(outputIndex) :=
                  substrb(tempGroupMembers(j), (instrb(tempGroupMembers(j), ':', 1, 1)+1),
                    (instrb(tempGroupMembers(j), ':', 1, 2)-1));
              end if;
              ame_approver_type_pkg.getWfRolesNameAndDisplayName(
                origSystemIn => memberOrigSystemsOut(outputIndex),
                origSystemIdIn => memberOrigSystemIdsOut(outputIndex),
                nameOut => memberNamesOut(outputIndex),
                displayNameOut => memberDisplayNamesOut(outputIndex));
            end loop;
          else /* Copy the static group into the engGroup caches. */
            outputIndex := outputIndex + 1;
            memberNamesOut(outputIndex) := approverNames(i);
            memberOrderNumbersOut(outputIndex) := orderNumbers(i);
            memberDisplayNamesOut(outputIndex) := displayNames(i);
            memberOrigSystemsOut(outputIndex) := origSystems(i);
            memberOrigSystemIdsOut(outputIndex) := origSystemIds(i);
          end if;
        end loop;
      exception
        when badDynamicMemberException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                      messageNameIn => 'AME_400454_GRP_DYN_QRY_ERR');
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers4',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when noTransIdDefinedException then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          errorCode := -20001;
         errorMessage := ame_util.getMessage(
                           applicationShortNameIn => 'PER',
                           messageNameIn   => 'AME_400798_GROUP_ITEM_BIND',
                           tokenNameOneIn  => 'APPROVER_GROUP',
                           tokenValueOneIn => tempGroupName);
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers3',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          if(groupMemberCursor%isopen) then
            close groupMemberCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_api3',
                                    routineNameIn => 'getGroupMembers4',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
  end getGroupMembers4;
end ame_api7;

/
