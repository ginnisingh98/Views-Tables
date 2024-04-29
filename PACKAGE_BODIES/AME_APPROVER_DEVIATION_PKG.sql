--------------------------------------------------------
--  DDL for Package Body AME_APPROVER_DEVIATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_APPROVER_DEVIATION_PKG" as
/* $Header: ameaprdv.pkb 120.11 2008/02/21 12:45:31 prasashe noship $ */
/*check if the any approver is deviated*/
function IsTransactionDeviated(deviationListIn in deviationReasonList)
     return boolean as
  tempIndex number;
 begin
  tempIndex := deviationListIn.first;
  while(tempIndex is not null) loop
    if deviationListIn(tempIndex).reason is not null and deviationListIn(tempIndex).reason in
      ( insertReason
         ,suppressReason
         ,forwardReason
         ,timeoutReason
         ,firstauthReason
         ,firstauthHandlerInsReason
         ,forwarHandlerAuthInsReason
         ,reassignStatus
         ,forwardForwardeeReason
         ,forwardEngInsReason
         ,forwardRemandReason) then
       return true;
     end if;
     tempIndex := deviationListIn.next(tempIndex);
  end loop;
  return false;
 end IsTransactionDeviated;
 /*mark the transaction as deviated if not done already*/
 procedure markTransactionDeviation(applicationIdIn in number
                                   ,tranasactionId in varchar2
                                   ,transactionRequesterIn in varchar2
                                   ,transactionDescriptionIn in varchar2) as
  deviationflag varchar2(1);
  cursor chkTransDeviation(applId in number,transIdIn in varchar2) is
    select trans_deviation_flag /*allowed values are Y and N*/
      from ame_temp_transactions
      where application_id = applId
        and transaction_id = transIdIn;
 begin
   open chkTransDeviation(applicationIdIn,tranasactionId);
   fetch chkTransDeviation into deviationflag;
   close chkTransDeviation;
   if deviationflag is null then
     begin
       update ame_temp_transactions
          set trans_deviation_flag = 'Y'
             ,end_date = sysdate
             ,transaction_requestor = transactionRequesterIn
             ,transaction_description = transactionDescriptionIn
        where application_id = applicationIdIn
          and transaction_id = tranasactionId;
     exception
       when others then
        ame_util.runtimeException(packageNameIn => 'ame_approver_deviation_pkg',
                                routineNameIn => 'markTransactionDeviation',
                                exceptionNumberIn => sqlcode,
                                exceptionStringIn => sqlerrm);
     end;
     return;
   end if;
   if deviationflag = 'Y' then
     return;
   elsif deviationflag = 'N' then
     begin
       update ame_temp_transactions
          set trans_deviation_flag = 'Y'
             ,end_date = sysdate
             ,transaction_requestor = transactionRequesterIn
             ,transaction_description = transactionDescriptionIn
        where application_id = applicationIdIn
          and transaction_id = tranasactionId;
     exception
       when others then
        ame_util.runtimeException(packageNameIn => 'ame_approver_deviation_pkg',
                                routineNameIn => 'markTransactionDeviation',
                                exceptionNumberIn => sqlcode,
                                exceptionStringIn => sqlerrm);
     end;
   end if;
 end markTransactionDeviation;
 /*The following method is used to evaluate the attribute transaction description*/
 procedure getTransactionDecription( applicationIdIn in number
                                   ,transactionIdIn in varchar2
                                   ,descriptionOut out nocopy varchar2) as
  tempStatic varchar2(2);
  querystring ame_util.longestStringType;
  dynamicQuery ame_util.longestStringType;
  dynamicCursor integer;
  tempAttributeValues1 dbms_sql.varchar2_table;
  rowsFound integer;
  cursor getAttributeDetails(applnIdIn in number) is
   select is_static
       ,query_string
  from ame_attribute_usages atu
      ,ame_attributes attr
  where attr.name = 'DESCRIPTION_OF_TRANSACTION'
    and attr.attribute_id = atu.attribute_id
    and application_id = applnIdIn
    and sysdate between attr.start_date and nvl(attr.end_date,sysdate)
    and sysdate between atu.start_date and nvl(atu.end_date,sysdate);
begin
  open getAttributeDetails(applicationIdIn);
  fetch getAttributeDetails into tempStatic,querystring;
  close getAttributeDetails;
  if tempStatic is null or querystring is null then
    return;
  end if;
  if tempStatic = 'Y' then
   descriptionOut := querystring;
   return;
  else
    dynamicQuery  := ame_util.removeReturns(stringIn          => querystring,
                                            replaceWithSpaces => true);
    dynamicCursor := dbms_sql.open_cursor;
    dbms_sql.parse(dynamicCursor,
                   dynamicQuery,
                   dbms_sql.native);
    if(instrb(dynamicQuery, ame_util.transactionIdPlaceholder, 1, 1) > 0) then
      dbms_sql.bind_variable(dynamicCursor,
                             ame_util.transactionIdPlaceholder,
                             transactionIdIn,
                             50);
    end if;
    dbms_sql.define_array(dynamicCursor,
                          1,
                          tempAttributeValues1,
                          100,
                          1);
    rowsFound := dbms_sql.execute(dynamicCursor);
    loop
      rowsFound := dbms_sql.fetch_rows(dynamicCursor);
      dbms_sql.column_value(dynamicCursor,
                                         1,
                    tempAttributeValues1);
       exit when rowsFound < 100;
    end loop;
    dbms_sql.close_cursor(dynamicCursor);
    if tempAttributeValues1.count > 1 then
      ame_util.runtimeException(packageNameIn => 'ame_approver_deviation_pkg',
                           routineNameIn => 'getTransactionDecription',
                           exceptionNumberIn => -20001,
                           exceptionStringIn => 'sql returned incorrect number of rows');
      descriptionOut := null;
      return;
    end if;
    descriptionOut := tempAttributeValues1(1);
    return;
  end if;
  exception
    when others then
      ame_util.runtimeException(packageNameIn => 'ame_approver_deviation_pkg',
                           routineNameIn => 'getTransactionDecription',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
      descriptionOut := null;
      dbms_sql.close_cursor(dynamicCursor);
end getTransactionDecription;
 /*This method insert the approverlist into the table. This method will be called only
 when approvalprocessis completed. This method does the following
   1. mark the transaction as deviated if not already done and mark the transaction as
     completed.
   2. insert the record if the transaction is not already completed. This to prevent
   the insertion of the same record in repeatdely. To implement this we need the following
   check in other place
     a) clear the record from detailed table and trans_deviation_flag when approver status is cleared
     b) approver list changes even after the approval process is complete and now the transaction has
     new set of approver. In this case AME engine is responsible to clear the record from detailed table
     and the trans_deviation_flag from master table*/
 procedure insertDeviations( applicationIdIn in number
                            ,tranasactionIdIn in varchar2
                            ,deviationListIn in deviationReasonList
                            ,finalapproverListIn in ame_util.approversTable2) as
  tempTransSequenceId integer;
  approverDeviationId integer;
  tempTransReq integer;
  tempTransDescr varchar2(100);
  tempwfNmae varchar2(100);
  tempDisplayName varchar2(100);
  tempApproverIndex number;
  tempReason varchar2(100);
  tempDate date;
  cursor isTxnComplete(applnIdIn in number, txnIdIn in varchar2) is
    select temp_transactions_id
      from ame_temp_transactions
     where application_id = applnIdIn
       and transaction_id = txnIdIn
       and end_date is not null;
  cursor gettempTranskey(applnIdIn in number, txnIdIn in varchar2) is
    select temp_transactions_id
      from ame_temp_transactions
     where application_id = applnIdIn
       and transaction_id = txnIdIn;
 begin
   open isTxnComplete(applicationIdIn,tranasactionIdIn);
   fetch isTxnComplete into tempTransSequenceId;
   close isTxnComplete;
   if tempTransSequenceId is not null then
    return;
   else
     open gettempTranskey(applicationIdIn,tranasactionIdIn);
     fetch gettempTranskey into tempTransSequenceId;
     close gettempTranskey;
   end if;
   if finalapproverListIn.count = 0 then
    return;
   end if;
   begin
    getTransactionDecription( applicationIdIn => applicationIdIn
                             ,transactionIdIn => tranasactionIdIn
                             ,descriptionOut => tempTransDescr);
    tempTransReq := ame_engine.getHeaderAttValue2(ame_util.transactionRequestorAttribute);
    if tempTransReq is not null then
      tempwfNmae := ame_approver_type_pkg.getWfRolesName(ame_util.perOrigSystem,tempTransReq,'false');
      if tempwfNmae is not null then
        tempDisplayName := ame_approver_type_pkg.getApproverDisplayName(tempwfNmae);
      else
        tempDisplayName := 'INVALID:'||tempTransReq;
      end if;
    end if;
   exception
     when others then
      null;
   end;
   if IsTransactionDeviated(deviationListIn) then
    markTransactionDeviation(applicationIdIn,tranasactionIdIn,tempDisplayName,tempTransDescr);
   else
     update ame_temp_transactions
        set end_date = sysdate
           ,trans_deviation_flag = 'N'
           ,transaction_requestor = tempDisplayName
           ,transaction_description = tempTransDescr
      where application_id = applicationIdIn
        and transaction_id = tranasactionIdIn;
   end if;
   for approverIndex in 1..finalapproverListIn.count loop
     tempReason := null;
     tempDate := null;
     if deviationListIn.exists(approverIndex) then
       tempReason := deviationListIn(approverIndex).reason;
       tempDate := deviationListIn(approverIndex).effectiveDate;
     end if;
     begin
        approverDeviationId := null;
        select ame_txn_approvers_s.nextval
          into approverDeviationId from dual;
       insert into ame_txn_approvers
        (
            txn_approvers_id
           ,temp_transactions_id
           ,name
           ,orig_system
           ,orig_system_id
           ,display_name
           ,approver_category
           ,api_insertion
           ,authority
           ,approval_status
           ,action_type_id
           ,group_or_chain_id
           ,occurrence
           ,source
           ,item_class
           ,item_id
           ,item_class_order_number
           ,item_order_number
           ,sub_list_order_number
           ,action_type_order_number
           ,group_or_chain_order_number
           ,member_order_number
           ,approver_order_number
           ,effective_date
           ,reason
           ,txn_attribute_1
           ,txn_attribute_2
           ,txn_attribute_3
           ,txn_attribute_4
           ,txn_attribute_5
           ,txn_attribute_6
           ,txn_attribute_7
           ,txn_attribute_8
           ,txn_attribute_9
           ,txn_attribute_10
        )values
          (
            approverDeviationId
           ,tempTransSequenceId
           ,finalapproverListIn(approverIndex).name
           ,finalapproverListIn(approverIndex).orig_system
           ,finalapproverListIn(approverIndex).orig_system_id
           ,finalapproverListIn(approverIndex).display_name
           ,finalapproverListIn(approverIndex).approver_category
           ,finalapproverListIn(approverIndex).api_insertion
           ,finalapproverListIn(approverIndex).authority
           ,finalapproverListIn(approverIndex).approval_status
           ,finalapproverListIn(approverIndex).action_type_id
           ,finalapproverListIn(approverIndex).group_or_chain_id
           ,finalapproverListIn(approverIndex).occurrence
           ,finalapproverListIn(approverIndex).source
           ,finalapproverListIn(approverIndex).item_class
           ,finalapproverListIn(approverIndex).item_id
           ,finalapproverListIn(approverIndex).item_class_order_number
           ,finalapproverListIn(approverIndex).item_order_number
           ,finalapproverListIn(approverIndex).sub_list_order_number
           ,finalapproverListIn(approverIndex).action_type_order_number
           ,finalapproverListIn(approverIndex).group_or_chain_order_number
           ,finalapproverListIn(approverIndex).member_order_number
           ,finalapproverListIn(approverIndex).approver_order_number
           ,tempDate
           ,tempReason
           ,null
           ,null
           ,null
           ,null
           ,null
           ,null
           ,null
           ,null
           ,null
           ,null
           );
     exception
       when others then
        ame_util.runtimeException(packageNameIn => 'ame_approver_deviation_pkg',
                                routineNameIn => 'insertDeviations',
                                exceptionNumberIn => sqlcode,
                                exceptionStringIn => sqlerrm);
     end;
   end loop;
 end insertDeviations;
/*this method is used by the deviation report sql for translation
of the deviation reason*/
function getreasonDescription(reasonIn in varchar2) return varchar2 as
 templookupcode varchar2(100);
 descrOut varchar2(100);
begin
  if reasonIn = insertReason then
    templookupcode := 'INSERT';
  elsif reasonIn = suppressReason then
    templookupcode := 'SUPPRESS';
  elsif reasonIn = forwardReason then
    templookupcode := 'FORWARDEE';
  elsif reasonIn = timeoutReason then
    templookupcode := 'SURROGATE';
  elsif reasonIn = firstauthReason then
    templookupcode := 'FIRSTAUTH';
  elsif reasonIn = firstauthHandlerInsReason then
    templookupcode := 'FIRSTAUTHHANDLERINS';
  elsif reasonIn = forwarHandlerAuthInsReason then
    templookupcode := 'FORWARDHANDLERAUTHINS';
  elsif reasonIn = reassignStatus then
    templookupcode := 'REASSIGN';
  elsif reasonIn = forwardForwardeeReason then
    templookupcode := 'FORWARDERREPEAT';
  elsif reasonIn = forwardEngInsReason then
    templookupcode := 'FORWARDENGINS';
  elsif reasonIn = forwardRemandReason then
    templookupcode := 'FORWARDREMAND';
  elsif reasonIn is null then
    templookupcode := null;
  end if;
  begin
    select meaning
      into descrOut
      from fnd_lookups
      where lookup_type = 'AME_DEVIATION_REASON'
        and lookup_code = templookupcode;
  exception
    when others then
     descrOut := null;
      ame_util.runtimeException(packageNameIn => 'ame_approver_deviation_pkg',
                                routineNameIn => 'getreasonDescription',
                                exceptionNumberIn => sqlcode,
                                exceptionStringIn => sqlerrm);
  end;
  return descrOut;
end getreasonDescription;
 /*This check if the approvla process is not complete but has been already
 registered as complete. This can happen when trans was completed but due t some change
 trans start again with new deviated list*/
procedure updateDeviationState( applicationIdIn in number
                            ,tranasactionIdIn in varchar2
                            ,deviationListIn in deviationReasonList
                            ,approvalProcessCompleteYNIn in varchar2
                            ,finalapproverListIn in ame_util.approversTable2) as
tempTransactionKey integer;
recordConfig varchar2(100) := 'recordDeviations';
cursor getTxnKey(applnId in number, transIdIn in varchar2) is
  select temp_transactions_id
    from ame_temp_transactions
   where application_id = applnId
     and transaction_id = transIdIn
     and end_date is not null;
begin
  begin
      if ame_engine.getConfigVarValue(recordConfig) = ame_util.no then
        return;
      end if;
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_approver_deviation_pkg',
                            routineNameIn => 'updateDeviationState',
                            exceptionNumberIn => sqlcode,
                            exceptionStringIn => sqlerrm);
       return;
  end;
  if approvalProcessCompleteYNIn not in
             (ame_util2.completeFullyApproved,
              ame_util2.completeFullyRejected) then
    open getTxnKey(applicationIdIn,tranasactionIdIn);
    fetch getTxnKey into tempTransactionKey;
    close getTxnKey;
    if tempTransactionKey is null then
     return;
    end if;
    begin
      delete from ame_txn_approvers
       where temp_transactions_id = tempTransactionKey;
      update ame_temp_transactions
         set end_Date = null
            ,trans_deviation_flag = null
            ,transaction_requestor = null
            ,transaction_description = null
       where temp_transactions_id = tempTransactionKey;
       return;
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_approver_deviation_pkg',
                                    routineNameIn => 'updateDeviationState',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
    end;
  else
   insertDeviations( applicationIdIn  => applicationIdIn
                    ,tranasactionIdIn => tranasactionIdIn
                    ,deviationListIn  => deviationListIn
                    ,finalapproverListIn => finalapproverListIn);
  end if;
end updateDeviationState;
/*Thie method will be called whenever any clear in transaction state is determined
This method will simply removes the approver list from deviation table and
sets the transaction state as not completed in ame_temtransaction table*/
procedure clearDeviationState( applicationIdIn in number
                              ,transactionIdIn in varchar2 ) as
 tempTransSeq number;
 cursor getTransKey(applnId in number, transIdIn in varchar2) is
  select temp_transactions_id
    from ame_temp_transactions
   where application_id = applnId
     and transaction_id = transIdIn
     and end_date is not null;
begin
  open getTransKey(applicationIdIn,transactionIdIn);
  fetch getTransKey into tempTransSeq;
  close getTransKey;
  if tempTransSeq is not null then
    begin
      delete from ame_txn_approvers
       where temp_transactions_id = tempTransSeq;
      update ame_temp_transactions
        set end_date  = null
           ,transaction_requestor = null
           ,transaction_description = null
           ,trans_deviation_flag = null
       where temp_transactions_id = tempTransSeq;
      /*This method is added to check if the approval process is completed even after the changes*/
      ame_engine.updateTransactionState(isTestTransactionIn => false,
                                        isLocalTransactionIn => false,
                                        fetchConfigVarsIn => true,
                                        fetchOldApproversIn => true,
                                        fetchInsertionsIn => true,
                                        fetchDeletionsIn => true,
                                        fetchAttributeValuesIn => true,
                                        fetchInactiveAttValuesIn => false,
                                        processProductionActionsIn => false,
                                        processProductionRulesIn => false,
                                        updateCurrentApproverListIn => true,
                                        updateOldApproverListIn => true,
                                        prepareApproverTreeIn => true,
                                        processPrioritiesIn => true,
                                        prepareItemDataIn => false,
                                        prepareRuleIdsIn => false,
                                        prepareRuleDescsIn => false,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => applicationIdIn,
                                        fndApplicationIdIn => null,
                                        transactionTypeIdIn => null );
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_approver_deviation_pkg',
                                    routineNameIn => 'clearDeviationState',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
    end;
  end if;
end clearDeviationState;
function validateDate return boolean is
  errbuf varchar2(1000);
  retcode varchar2(100);
  endDateinFuture exception;
  startDateinFurture exception;
  priorStartDateExp exception;
  errorMessage ame_util.longStringType;
  errorCode integer;
  begin
   if P_ENDDATE < P_STARTDATE then
     raise priorStartDateExp;
   end if;
   if P_STARTDATE > sysdate then
     raise startDateinFurture;
   end if;
   if P_ENDDATE > sysdate then
     raise endDateinFuture;
   end if;
   begin
     TEMP_APPLID := P_AMEAPPLID;
      select lookup_code
       into TEMP_REASON
       from fnd_lookup_values
      where lookup_type ='AME_DEVIATION_REASON'
        and language = userenv('LANG')
        and meaning = P_REASON;

     exception
       when others then
         null;
   end;
   return true;
  exception
    when endDateinFuture then
      errorCode := -20001;
      errorMessage :=
      ame_util.getMessage(applicationShortNameIn =>'PER',
                         messageNameIn => 'AME_400827_DEV_END_DATE_ERR');
      ame_util.runtimeException(packageNameIn => 'ame_trans_data_purge',
                           routineNameIn => 'purgeDeviationData',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
      FND_FILE.PUT_LINE (FND_FILE.LOG,errorMessage);
      raise_application_error(errorCode,
                                  errorMessage);
    when startDateinFurture then
      errorCode := -20001;
      errorMessage :=
      ame_util.getMessage(applicationShortNameIn =>'PER',
                         messageNameIn => 'AME_400826_DEV_START_DATE_ERR');
      ame_util.runtimeException(packageNameIn => 'ame_trans_data_purge',
                           routineNameIn => 'purgeDeviationData',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
      FND_FILE.PUT_LINE (FND_FILE.LOG,errorMessage);
      raise_application_error(errorCode,
                                  errorMessage);
    when priorStartDateExp then
      errorCode := -20001;
      errorMessage :=
      ame_util.getMessage(applicationShortNameIn =>'PER',
                          messageNameIn => 'AME_400828_DEV_DATE_MISMATCH');
      ame_util.runtimeException(packageNameIn => 'ame_trans_data_purge',
                            routineNameIn => 'purgeDeviationData',
                            exceptionNumberIn => errorCode,
                            exceptionStringIn => errorMessage);
      FND_FILE.PUT_LINE (FND_FILE.LOG,errorMessage);
      raise_application_error(errorCode,
                                  errorMessage);
  end validateDate;
function getApplicationName return varchar2 as
tempName varchar2(300);
begin
   select application_name
     into tempName
     from fnd_application_vl
    where application_id = to_number(P_APPLICATION);
   return tempName;
  exception
    when others then
     return null;
end getApplicationName;
function gettxntype return varchar2 as
 tempapplName varchar2(720);
begin
    select application_name
      into tempapplName
     from ame_calling_apps_vl
    where application_id = P_AMEAPPLID
      and sysdate between start_date and nvl(end_date,sysdate);
     return tempapplName;
  exception
    when others then
     return null;
end gettxntype;
function getStartDateParam return varchar2 as
begin
  return fnd_date.date_to_displayDate(P_STARTDATE);
exception
  when others then
    return to_char(P_STARTDATE);
end getStartDateParam;

function getEndDateParam return varchar2 as
begin
  return fnd_date.date_to_displayDate(P_ENDDATE);
exception
  when others then
    return to_char(P_ENDDATE);
end getEndDateParam;
end ame_approver_deviation_pkg;

/
