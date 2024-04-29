--------------------------------------------------------
--  DDL for Package Body AME_TRANS_DATA_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_TRANS_DATA_PURGE" as
/* $Header: amepurge.pkb 120.10 2008/04/16 13:50:38 prasashe noship $ */
  procedure purgeTransData(errbuf              out nocopy varchar2,   --needed by concurrent manager.
                           retcode             out nocopy number,     --needed by concurrent manager.
                           applicationIdIn in number,
                           purgeTypeIn in varchar2) as
/* IN argument purgeTypeIn has the following allowed values
   Y - Purge all complete or incomplete transactions
   A - Purge all completed transactions which have been Approved
   P - Purge all Partially approved /rejected transactions and all completely approved transactions too.
*/
    lastDateToSave date;
    cursor attributeUsageCursor (applicationIdIn integer) is
      select attribute_id
      from ame_attribute_usages
      where
        application_id = applicationIdIn and
        sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate);
    cursor tempTransaction is
           select transaction_id
             from ame_temp_transactions
            where application_id = applicationIdIn and
                   row_timestamp < lastDateToSave;
    cursor oldApproverCursor(applicationIdIn in integer,
                             transactionIdIn in varchar2) is
      select
        name,
        item_class,
        item_id,
        approver_category,
        api_insertion,
        authority,
        approval_status,
        action_type_id,
        group_or_chain_id,
        occurrence
        from ame_temp_old_approver_lists
        where
          application_id = applicationIdIn and
          transaction_id = transactionIdIn
        order by order_number;
      tempIndex integer;
    attributeId    integer;
    transactionId ame_temp_transactions.transaction_id%type;
    transactionIds ame_util.stringList;
    bulkFetchRowLimit number := 1000;
    approverNames ame_util.longStringList;
    approverItemClasses ame_util.stringList;
    approverItemIds ame_util.stringList;
    approverCategories ame_util.charList;
    approverApiInsertions ame_util.StringList;
    approverAuthorities ame_util.StringList;
    approverStatuses ame_util.StringList;
    approverActionTypeIds ame_util.idList;
    approverGroupOrChainIds ame_util.idList;
    approverOccurrences ame_util.idList;
    applicationName ame_calling_apps.application_name%type;
    begin
      /* Get last Date to save based on the purge frquency set in the config variables */
      lastDateToSave := sysdate - to_number(ame_util.getConfigVar(variableNameIn => 'purgeFrequency',
                                                                  applicationIdIn => applicationIdIn));
      begin
        select application_name
          into applicationName
          from ame_calling_apps
         where application_id = applicationIdIn
           and sysdate between start_date and nvl(end_date - 1/86400,sysdate);
      exception
        when no_data_found then
          FND_FILE.PUT_LINE(FND_FILE.LOG,applicationIdIn || ' Application ID does not exist' );
      end;
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Purge run for Transaction Type: ' || applicationName);
      FND_FILE.NEW_LINE(FND_FILE.OUTPUT,3);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'The following Transaction IDs will be purged');
      /* Recalculate the attribute use count */
      for tempAttrUsage in attributeUsageCursor(applicationIdIn) loop
          attributeId := tempAttrUsage.attribute_id;
          ame_attribute_pkg.updateUseCount(attributeIdIn   => attributeId,
                                           applicationIdIn => applicationIdIn);
      end loop;
      /* Fetch all transactions which potentially need to be purged */
      open tempTransaction;
      loop
        fetch tempTransaction bulk collect into
             transactionIds limit bulkFetchRowLimit;
        if transactionIds.count = 0 then
          close tempTransaction;
          exit;
        end if;
        /* Check whether every transaction retrieved is complete or not */
        for i in 1 .. transactionIds.count
        loop
          if purgeTypeIn <> 'Y' then
            /* For each transaction retrieve the approver list from ame_temp_old_approver_lists */
            open oldApproverCursor(applicationIdIn=> applicationIdIn
                                  ,transactionIdIn=> transactionIds(i));
            fetch oldApproverCursor bulk collect into
                 approverNames
                ,approverItemClasses
                ,approverItemIds
                ,approverCategories
                ,approverApiInsertions
                ,approverAuthorities
                ,approverStatuses
                ,approverActionTypeIds
                ,approverGroupOrChainIds
                ,approverOccurrences ;
            close oldApproverCursor;
            /* Check to see if the transaction is complete */
            /* If there is any approver with a null status or a notified status with approver category = 'A'
               then transaction is incomplete so do not purge */
            /* If there is any approver with a status of Rejected then this is a rejected transaction or a
               partially approved transaction */
            if approverNames.count >= 0 then
              for j in 1..approverNames.count
              loop
                if (approverStatuses(j) is null or
                    (approverStatuses(j) =  ame_util.notifiedStatus and
                     approverStatuses(j) = ame_util.approvalApproverCategory)) then
                  /* Transaction is incomplete so do not purge */
                  transactionIds.delete(i);
                  exit;
                elsif (approverStatuses(j) =  ame_util.rejectStatus and
                         purgeTypeIn <> 'P') then
                  /* Transaction is rejected, and purge type is not 'P' so do not purge */
                  transactionIds.delete(i);
                  exit;
                else
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'1: ' ||transactionIds(i));
                end if;
              end loop;
            else
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'2: '||transactionIds(i)); -- P
            end if;
          else
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'3: ' ||transactionIds(i));
          end if;
        end loop;
       /* compact ID List */
       ame_util.compactStringList(stringListInOut => transactionIds);
       /* Do bulk deletes */
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'No.of transaction ids to be purged: '||transactionIds.count);
       if(transactionIds.count > 0) then
         /* ame_temp_old_approver_lists */
         forall ct in transactionIds.first..transactionIds.last
           delete from ame_temp_old_approver_lists
            where application_id = applicationIdIn and
                  transaction_id = transactionIds(ct);
         /* ame_temp_insertions */
         forall ct in transactionIds.first..transactionIds.last
           delete from ame_temp_insertions
            where application_id = applicationIdIn and
                  transaction_id = transactionIds(ct);
         /* ame_temp_deletions */
         forall ct in transactionIds.first..transactionIds.last
           delete from ame_temp_deletions
            where application_id = applicationIdIn and
                  transaction_id = transactionIds(ct);
         /* ame_trans_approval_history */
         forall ct in transactionIds.first..transactionIds.last
           delete from ame_trans_approval_history
            where application_id = applicationIdIn and
                  transaction_id = transactionIds(ct);
         /* ame_temp_transactions */
         forall ct in transactionIds.first..transactionIds.last
           delete from ame_temp_transactions
            where application_id = applicationIdIn
              and transaction_id = transactionIds(ct)
              and trans_deviation_flag is null or trans_deviation_flag = 'D';
       end if;
    end loop;
    delete from ame_temp_trans_locks
        where row_timestamp < sysdate - 1;
  exception
        when others then
          FND_FILE.PUT_LINE(FND_FILE.LOG,sqlerrm);
          ame_util.runtimeException(packageNameIn => 'ame_trans_data_purge',
                           routineNameIn => 'purgeTransData',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
  end purgeTransData;

 procedure purgeDeviationData(errbuf            out nocopy varchar2,
                            retcode            out nocopy number,
                            applicationIdIn in number default null,
                            ameApplicationId    in number default null,
                            endDateIn         in  varchar2 default null) as
  l_profileDate date;
  defaultValue date;
  dateToDelete date;
  errormsg varchar2(500);
  errorCode integer;
  tempTxnId  varchar2(100);
  tempFndapplicationId number;
  errorMessage ame_util.longStringType;
  applicationIdList ame_util.idList;
  tempApplication number;
  l_endDate date;
  l_error_date varchar2(12);
  cursor getApplicationList(applictionIdIn in number) is
   select application_id
     from ame_calling_apps
    where fnd_application_id = applictionIdIn
      and sysdate between start_date and nvl(end_Date-(1/86400),sysdate);
  profileNotsetExc exception;
  invalidInputDateExc exception;
  deleteTodayRecordExc exception;
begin
  tempFndapplicationId := applicationIdIn;
  l_profileDate := to_date(FND_PROFILE.VALUE('AME_DEVITION_PURGE_DATE'),'dd/mm/yyyy');
  l_endDate := fnd_date.canonical_to_date(endDateIn);
  dateToDelete := l_endDate;
  FND_FILE.PUT_LINE (FND_FILE.LOG,'Staring AME deviation data purge process');
  FND_FILE.PUT_LINE (FND_FILE.LOG,'Application id:'||applicationIdIn);
  FND_FILE.PUT_LINE (FND_FILE.LOG,'AME internal application id:'||ameApplicationId);
  FND_FILE.PUT_LINE (FND_FILE.LOG,'Date upto record deltion allowed:'||l_endDate);
  FND_FILE.PUT_LINE (FND_FILE.LOG,'Profile date:'||l_profileDate);
  if l_endDate > l_profileDate then
    raise invalidInputDateExc;
  elsif l_endDate > sysdate then
    dateToDelete := sysdate;
  elsif l_endDate <= l_profileDate then
    dateToDelete := l_endDate;
  end if;
  if dateToDelete > trunc(sysdate) or dateToDelete = trunc(sysdate) then
    raise deleteTodayRecordExc;
  end if;
  if applicationIdIn is not null and ameApplicationId is not null then
    tempApplication := ameApplicationId;
    begin
      delete from ame_txn_approvers
      where temp_transactions_id in
        (select temp_transactions_id
           from ame_temp_transactions
          where trunc(row_timestamp) <= dateToDelete
            and application_id = tempApplication);
      FND_FILE.PUT_LINE (FND_FILE.LOG,'number of rows deleted:'||sql%rowcount);
      update ame_temp_transactions
         set trans_deviation_flag = 'D'
       where trunc(row_timestamp) <= dateToDelete
         and application_id = tempApplication;
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_trans_data_purge',
                           routineNameIn => 'purgeDeviationData',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
        FND_FILE.PUT_LINE (FND_FILE.LOG,sqlerrm);
    end;
  elsif ameApplicationId is null and tempFndapplicationId is not null then
    open getApplicationList(tempFndapplicationId);
    fetch getApplicationList bulk collect into applicationIdList;
    close getApplicationList;
    begin
      for i in 1..applicationIdList.count loop
        delete from ame_txn_approvers
        where temp_transactions_id in
          (select temp_transactions_id
             from ame_temp_transactions
            where trunc(row_timestamp) <= dateToDelete
              and application_id = applicationIdList(i));
        FND_FILE.PUT_LINE (FND_FILE.LOG,'AME internal application id:'||applicationIdList(i));
        FND_FILE.PUT_LINE (FND_FILE.LOG,'number of rows deleted:'||sql%rowcount);
        update ame_temp_transactions
           set trans_deviation_flag = 'D'
         where trunc(row_timestamp) <= dateToDelete
           and application_id = applicationIdList(i);
      end loop;
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_trans_data_purge',
                           routineNameIn => 'purgeDeviationData',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
        FND_FILE.PUT_LINE (FND_FILE.LOG,sqlerrm);
    end;
  elsif tempTxnId is null and tempFndapplicationId is null then
    begin
      delete from ame_txn_approvers
      where temp_transactions_id in
        (select temp_transactions_id
           from ame_temp_transactions
          where trunc(row_timestamp) <= dateToDelete);
      FND_FILE.PUT_LINE (FND_FILE.LOG,'number of rows deleted:'||sql%rowcount);
      update ame_temp_transactions
         set trans_deviation_flag = 'D'
       where trunc(row_timestamp) <= dateToDelete;
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_trans_data_purge',
                           routineNameIn => 'purgeDeviationData',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
        FND_FILE.PUT_LINE (FND_FILE.LOG,sqlerrm);
    end;
  end if;
  FND_FILE.PUT_LINE (FND_FILE.LOG,'Completed AME deviation data purge process');
exception
  when profileNotsetExc then
     errorCode := -20001;
     errorMessage :=
     ame_util.getMessage(applicationShortNameIn =>'PER',
                         messageNameIn => 'AME_400828_DEV_PRF_NOTSET');
     ame_util.runtimeException(packageNameIn => 'ame_trans_data_purge',
                           routineNameIn => 'purgeDeviationData',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
    FND_FILE.PUT_LINE (FND_FILE.LOG,errorMessage);
    raise_application_error(errorCode,
                                  errorMessage);
  when deleteTodayRecordExc then
     errorCode := -20001;
     errorMessage :=
     ame_util.getMessage(applicationShortNameIn =>'PER',
                         messageNameIn => 'AME_400832_INV_PURGE_UP_TODATE');
     ame_util.runtimeException(packageNameIn => 'ame_trans_data_purge',
                           routineNameIn => 'purgeDeviationData',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
    FND_FILE.PUT_LINE (FND_FILE.LOG,errorMessage);
    raise_application_error(errorCode,
                                  errorMessage);
  when invalidInputDateExc then
     l_error_date := FND_PROFILE.VALUE('AME_DEVITION_PURGE_DATE');
     errorCode := -20001;
     errorMessage :=
     ame_util.getMessage(applicationShortNameIn =>'PER',
                         messageNameIn => 'AME_400830_INVALID_PURGE_DATE',
                         tokenNameOneIn  => 'PROFILE_DATE',
                         tokenValueOneIn => l_error_date );
     ame_util.runtimeException(packageNameIn => 'ame_trans_data_purge',
                           routineNameIn => 'purgeDeviationData',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
    FND_FILE.PUT_LINE (FND_FILE.LOG,errorMessage);
    raise_application_error(errorCode,
                                  errorMessage);
  when others then
    ame_util.runtimeException(packageNameIn => 'ame_trans_data_purge',
                           routineNameIn => 'purgeDeviationData',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
    FND_FILE.PUT_LINE (FND_FILE.LOG,sqlerrm);
        raise_application_error(sqlcode,
                                  sqlerrm);
end purgeDeviationData;
end ame_trans_data_purge;

/
