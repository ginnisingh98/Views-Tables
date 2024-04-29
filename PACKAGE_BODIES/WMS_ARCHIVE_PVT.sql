--------------------------------------------------------
--  DDL for Package Body WMS_ARCHIVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_ARCHIVE_PVT" as
/* $Header: WMSTARCB.pls 115.5 2004/04/15 01:11:45 joabraha noship $ */
--
--
-- Internal Constant variables
--
   c_records_per_worker          constant number  default 50000;
   c_record_hi_number_per_worker constant number  default 300000;

   --c_records_per_worker          constant number  default 50;
   --c_record_hi_number_per_worker constant number  default 300;

--
--
   l_pkg            varchar2(72) := 'WMS_TASK_ARCHIVE :';
   l_total_records  number := 0;
--
--
-- ---------------------------------------------------------------------------------------
-- |---------------------< trace >--------------------------------------------------------|
-- ---------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Wrapper around the tracing utility.
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name        Reqd Type     Description
--   p_message   Yes  varchar2 Message to be displayed in the log file.
--   p_prompt    Yes  varchar2 Prompt.
--   p_level     No   number   Level.
--
-- Post Success:
--   None.
--
-- Post Failure:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--

Procedure trace(
   p_message  in varchar2
,  p_level    in number
   ) is
begin
      INV_LOG_UTIL.trace(p_message, 'WMS_TASK_ARCHIVE', p_level);
end trace;
--
--
-- ---------------------------------------------------------------------------------------
-- |-------------------------------< archive_tasks >--------------------------------------|
-- ---------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Archives tasks records based on organization.
--
--   Package-Procedure combination
--
-- Prerequisites:
--
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   x_errbuf                       Yes  varchar2 Concurrent Manager Parameter.
--   x_retcode                      Yes  varchar2 Concurrent Manager Parameter.
--   p_org_code                     Yes  number   Organization for which data needs to be purged.
--   p_purge_days                   Yes  number   Number of days of data left starting with current
--                                                date and going back.
--   p_archive_batches              Yes  number   Number of batches into which the records needs
--                                                to be broken up.
--
--
-- Post Success:
--   Data in the history table are deleted once the Archive tables are populated apropriately.
--
-- Post Failure:
--   No data archiving takes place,
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure archive_tasks(
   x_errbuf           out nocopy varchar2
,  x_retcode          out nocopy number
,  p_org_id           in         number
,  p_purge_days       in         number
,  p_archive_batches  in         number
) is
       l_proc        varchar2(72) := 'ARCHIVE_WMS_TASKS :';
       l_debug       number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

       l_max_date_time        varchar2(50):= null;
       l_sys_date             varchar2(50):= null;

       l_total_record_count   number:= 0;

       l_min_range_date_time  date;
       l_max_range_date_time  date;

       l_days_between         number := 0;
       l_each_worker_chunk    number:= 0;


       l_record_per_worker    number:= 0;
       l_number_workers       number:= 0;
       l_organization_id      number:= 0;

       l_loop_counter         number:= 1;
       l_from_date            date;
       l_to_date              date;
       l_num_batches          number;
       l_purge_req_id         number;

       l_purge_days           number:= 0;

       i                      number;
       type l_reqstatus_table is table of number
       index by binary_integer;

       l_reqstatus_tbl_type       l_reqstatus_table;
       --l_num_of_workers_launched  number:= 1;

       submission_error_except    exception;

--  ### This cursor gets the date upto which data will be purged.
--  ### Data in tables whose creation date is less than this date will be
--  ### purged(not including this date, is emphasized).
cursor c_get_total_eligible_recs is
select count(*), min(last_update_date), max(last_update_date),
       (max(last_update_date) - min(last_update_date))
from   wms_dispatched_tasks_history
where  last_update_date < (sysdate - l_purge_days)
and    organization_id = nvl(p_org_id, organization_id);
--
--
begin
   if (l_debug = 1) then
      trace(' Entering procedure  '|| l_proc || ':'|| to_char(sysdate, 'RRRR/MM/DD HH24:MI:SS'), 1);
      trace(l_proc || ' p_org_id  => ' || nvl(p_org_id, -99));
      trace(l_proc || ' p_purge_days  => ' || nvl(p_purge_days, -99));
      trace(l_proc || ' p_archive_batches   => ' || nvl(p_archive_batches, -99));
   end if;

   -- @@@ Validating input parameters.
   if (p_purge_days is null) then
      l_purge_days := 0;
   else
      l_purge_days := p_purge_days;
   end if;

   -- @@@ Get total number of eligible records to be archived.
   open  c_get_total_eligible_recs;
   fetch c_get_total_eligible_recs
   into  l_total_record_count, l_min_range_date_time, l_max_range_date_time, l_days_between;

   if l_total_record_count = 0 then
      if (l_debug = 1) then
         trace(l_proc || ' Eligible records not found for Archiving for date range provided... ');
      end if;

      close c_get_total_eligible_recs;
      raise fnd_api.g_exc_error;
      --return;
   elsif l_total_record_count > 0 then
      if (l_debug = 1) then
         trace(l_proc || ' l_total_record_count => '|| nvl(l_total_record_count, -99));
         trace(l_proc || ' l_min_range_date_time => '|| nvl(to_char(l_min_range_date_time, 'RRRR/MM/DD HH24:MI:SS'), '@@@'));
         trace(l_proc || ' l_max_range_date_time => '|| nvl(to_char(l_max_range_date_time, 'RRRR/MM/DD HH24:MI:SS'), '@@@'));
         trace(l_proc || ' l_days_between => '|| nvl(l_days_between, -99));
      end if;

      if (l_debug = 1) then
         trace(l_proc || ' Before Checking l_total_record_count and setting value for the l_record_per_worker variable...');
      end if;

      -- @@@ Determine number of records to be processe
      -- @@@ If the total number of records is less than a million then its set to 50000 else 300000;
      if l_total_record_count < 100000 then
         l_record_per_worker := c_records_per_worker;
      else
         l_record_per_worker := c_record_hi_number_per_worker;
      end if;

      if (l_debug = 1) then
         trace(l_proc || ' l_record_per_worker => '|| l_record_per_worker);
      end if;

      if (l_debug = 1) then
         trace(l_proc || ' After Checking l_total_record_count and setting value for the l_record_per_worker variable...');
      end if;

      if (l_debug = 1) then
         trace(l_proc || ' Before calculating value for l_num_batches variable...');
         trace(l_proc || ' l_total_record_count => ' || l_total_record_count);
         trace(l_proc || ' l_record_per_worker => ' || l_record_per_worker);
         trace(l_proc || ' p_archive_batches => ' || p_archive_batches);
      end if;

      -- @@@ Calculate the number of workers required for this run.
      -- @@@ The idea is to use the smaller value.
      l_num_batches := ceil(l_total_record_count/l_record_per_worker);

      if (l_debug = 1) then
         trace(l_proc || ' l_num_batches => ' || l_num_batches);
      end if;

      if p_archive_batches > l_num_batches then
         l_number_workers:= l_num_batches;
      else
         l_number_workers:= p_archive_batches;
      end if;

      if (l_debug = 1) then
         trace(l_proc || ' l_number_workers => '|| l_number_workers);
      end if;

      if (l_debug = 1) then
         trace(l_proc || ' After calculating value for l_num_batches variable...');
      end if;

      if (l_debug = 1) then
         trace(l_proc || ' Before calculating value for l_each_worker_chunk variable...');
         trace(l_proc || ' l_days_between => ' || l_days_between);
         trace(l_proc || ' l_num_batches =>' || l_num_batches);
      end if;

      -- @@@ Get the chunk of data in terms of days to be assigned to each worker.
      l_each_worker_chunk := l_days_between/l_number_workers;
      if (l_debug = 1) then
         trace(l_proc || ' l_each_worker_chunk => '|| l_each_worker_chunk);
      end if;

      if (l_debug = 1) then
         trace(l_proc || ' After calculating value for l_each_worker_chunk variable...');
      end if;

      if l_number_workers > 0 then
         if (l_debug = 1) then
            trace(l_proc || ' Before entering the for loop... ');
         end if;

         -- @@@ The from date and the to date passed to the worker program is derived in the
         -- @@@ loop itself.
         for i in 1..l_number_workers
         loop
             -- @@@ The l_loop_counter is used to determine mainly the first run in the loop.
             -- @@@ Note that the 'l_from_date' and 'l_to_date' are both defined as date variables.
             -- @@@ The  'l_min_range_date_time' is defined as a varchar2 so as to derive the date/time
             -- @@@ information to the precision of the last second.
             -- @@@ The 'l_min_range_date_time' derived as follows from the
             -- @@@  'c_get_total_eligible_recs' cursor:
             -- @@@    "to_char(min(last_update_date), 'MM/DD/YY HH:MI:SS')"
             -- @@@ Since the 'l_min_range_date_time' is a varchar, the fnd_date.displaydate_to_date()
             -- @@@ is used to convert it to a date and assign to the l_from_date(date variable).
             -- @@@ This only needs to be done the very first time since in the subsequence runs,
             -- @@@ date arithmetic is being performed with the SELECT from dual.
             -- @@@
             -- @@@ The logic of deriving the 'l_from_date' and 'l_to_date' for each worker call is as follows:
             -- @@@ 1. For the very first run, the 'l_from_date' is equal to the 'l_min_range_date_time'.
             -- @@@    This is passed as a date variable to the first worker call.
             -- @@@ 2. The 'l_to_date' is computed as the 'l_from_date + l_each_worker_chunk' every time as follows:
             -- @@@    The 'l_each_worker_chunk' stores the number of days for each worker.
             -- @@@    Hence the
             -- @@@     'select (l_from_date + l_each_worker_chunk) into l_to_date from dual;'
             -- @@@    effectively derives the l_to_date with a precision to the last second.
             -- @@@ 3. In every subsequent run, date arithmetic is performed on the 'l_from_date' and 'l_to_date'
             -- @@@    derived in the previous run prior to the worker call.
             -- @@@
             -- @@@ One another thing to note is that in the subsequent runs, the 'l_from_date' is set to the
             -- @@@ 'l_to_date' from the previous run in the loop. The SQL in the worker is selecting a range
             -- @@@ greater that the 'l_from_date'.
             if (i = 1) then
                -- @@@ Get the min date range for the first worker call.
                l_from_date := l_min_range_date_time - 1/(3600*24);
                if (l_debug = 1) then
                    trace(l_proc || ' Inside if for (i > 1)...');
                    trace(l_proc || ' i => ' || i);
                    trace(l_proc || ' l_from_date  => ' || to_char(l_from_date, 'RRRR/MM/DD HH24:MI:SS'));
                end if;
             elsif (i > 1) then
                -- @@@ Get the min date range for subsequent worker calls.
                l_from_date := l_to_date;
                if (l_debug = 1) then
                    trace(l_proc || ' Inside if for (i > 1)...');
                    trace(l_proc || ' i => ' || i);
                    trace(l_proc || ' l_from_date  => ' || to_char(l_from_date, 'RRRR/MM/DD HH24:MI:SS'));
                end if;
             end if;

             if (l_debug = 1) then
                trace(l_proc || ' l_from_date  Outside the if check for counter(i) => '|| to_char(l_from_date, 'RRRR/MM/DD HH24:MI:SS'));
             end if;

             -- @@@ Get the max date range for the worker call.
             -- @@@
             --l_to_date := l_from_date + l_each_worker_chunk;
             select (l_from_date + l_each_worker_chunk) into l_to_date from dual;

             if (l_debug = 1) then
                trace(l_proc || ' i => ' || i);
                trace(l_proc || ' l_to_date  => ' || to_char(l_to_date, 'RRRR/MM/DD HH24:MI:SS'));
             end if;

             if (l_debug = 1) then
                trace(l_proc || ' Loop Counter => ' || i);
                trace(l_proc || ' Before Launching WMS Task Purge Worker ...');
                trace(l_proc || ' For Range, with From Date => ' || to_char(l_from_date, 'RRRR/MM/DD HH24:MI:SS'));
                trace(l_proc || ' and To Date => ' || to_char(l_to_date, 'RRRR/MM/DD HH24:MI:SS'));
             end if;


             -- @@@ Calling the purge worker for a specific date range..
             -- @@@ 'l_purge_req_id' returns the concurrent request id for the worker launched.
             l_purge_req_id :=  fnd_request.submit_request(application => 'WMS'
                                                         , program => 'WMSTARCW'
                                                         , argument1 => to_char(l_from_date, 'RRRR/MM/DD HH24:MI:SS')
                                                         , argument2 => to_char(l_to_date, 'RRRR/MM/DD HH24:MI:SS')
                                                         , argument3 => p_org_id);

             if (l_debug = 1) then
                trace(l_proc || ' l_purge_req_id => ' || l_purge_req_id);
             end if;
             -- @@@ Handle worker submission error
             -- @@@ Raise exception if failed else commit and proceed.
             if (l_purge_req_id = 0) then
                 if (l_debug = 1) then
                     trace(l_proc || ' Error launching Purge Worker Number... ');
                 end if;
                 raise submission_error_except;
             else
                 if (l_debug = 1) then
                     trace(l_proc || ' Purge Worker launching Successfully... ' || i);
                 end if;
                 commit;
             end if;

             if (l_debug = 1) then
                trace(l_proc || ' Concurrent Request Id ' || l_purge_req_id|| ' Submitted' );
                trace(l_proc || ' WMS Task Purge Worker Number = ' || i|| ' Launched');
             end if;

             --l_num_of_workers_launched := l_num_of_workers_launched + 1;
             if (l_debug = 1) then
                trace(l_proc || ' l_num_of_workers_launched ' || i);
             end if;

             l_reqstatus_tbl_type(i) := l_purge_req_id;
             if (l_debug = 1) then
                trace(l_proc || ' l_reqstatus_tbl_type(' || i ||') => '|| l_reqstatus_tbl_type(i));
             end if;
         end loop;-- Marker End Loop for call to the Archiving Task Worker
         if (l_debug = 1) then
            trace(l_proc || ' Outside the For Loop...');
         end if;
      end if;
      close c_get_total_eligible_recs;
   end if ;

   if (l_debug = 1) then
      trace(l_proc || ' The following Worker Requests have been launched :');
   end if;

   for i in 1..l_reqstatus_tbl_type.count
   loop
       if (l_debug = 1) then
          trace(l_proc || ' Worker Number  ' || i || '...Concurrent Request ID ' || l_reqstatus_tbl_type(i));
          trace(l_proc || ' Please monitor for concurrent request failures....');
       end if;
   end loop;

   x_retcode  := 0;
   x_errbuf   := 'Success';
exception
   when fnd_api.g_exc_error then
        if (l_debug = 1) then
           trace(l_proc || ' fnd_api.g_exc_error :' || sqlcode);
           trace(l_proc || ' fnd_api.g_exc_error :' || substr(sqlerrm, 1, 100));
        end if;

        if c_get_total_eligible_recs%ISOPEN then
           close c_get_total_eligible_recs;
        end if;

        x_retcode  := 2;
        x_errbuf   := 'Error';
        return;
   when submission_error_except then
      if (l_debug = 1) then
        trace(l_proc || ' submission_error_except :' || sqlcode);
        trace(l_proc || ' submission_error_except :' || substr(sqlerrm, 1, 100));

        trace(l_proc || ' Number of workers launched before submission failure :' || i);
        trace(l_proc || ' Date Range for the last successful worker submission :');
        trace(l_proc || ' From Date = ' || l_from_date || ' .....To Date= ' || l_to_date);

        trace(l_proc || ' The following Worker Requests have been launched before  the last worker failed to Launch :');
        for i in 1..l_reqstatus_tbl_type.count
        loop
            trace(l_proc || ' Worker Number  ' || i || '...Concurrent Request ID ' || l_reqstatus_tbl_type(i));
        end loop;
      end if;

      if c_get_total_eligible_recs%ISOPEN then
         close c_get_total_eligible_recs;
      end if;

      x_retcode  := 2;
      x_errbuf   := 'Error';
      return;
   when others then
      if (l_debug = 1) then
        trace(l_proc || ' Other error :' || sqlcode);
        trace(l_proc || ' Other error :' || substr(sqlerrm, 1, 100));

        trace(l_proc || ' Number of workers launched before submission failure :' || i);
        trace(l_proc || ' Date Range for the last successful worker submission :');
        trace(l_proc || ' From Date = ' || l_from_date || ' .....To Date= ' || l_to_date);

        trace(l_proc || ' The following Worker Requests have been launched before  the last worker failed to Launch :');
        for i in 1..l_reqstatus_tbl_type.count
        loop
            trace(l_proc || ' Worker Number  ' || i || '...Concurrent Request ID ' || l_reqstatus_tbl_type(i));
        end loop;
      end if;

        if c_get_total_eligible_recs%ISOPEN then
           close c_get_total_eligible_recs;
        end if;

        x_retcode  := 2;
	x_errbuf   := 'Error';
        return;
end archive_tasks;
--
--
-- ---------------------------------------------------------------------------------------
-- |-------------------------------< archive_tasks_worker >-----------------------------|
-- ---------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Archives tasks records based on organization.
--
--   Package-Procedure combination
--
-- Prerequisites:
--
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   x_errbuf                       Yes  varchar2 Concurrent Manager Parameter.
--   x_retcode                      Yes  varchar2 Concurrent Manager Parameter.                                                                          --   x_subinventory_code            Yes  varchar2 Call procedure to be registered
--   p_from_date                    Yes  number   From Date for archive process.
--   p_to_date                      Yes  number   To date for the archive process
--   p_org_code                     Yes  varchar2 Organization Code for which data needs to be purged.
--
--
-- Post Success:
--   Data in the history table are deleted once the Archive tables are populated apropriately.
--
-- Post Failure:
--   No data archiving takes place,
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure archive_tasks_worker(
   x_errbuf           out nocopy varchar2
,  x_retcode          out nocopy number
,  p_from_date        in         varchar2
,  p_to_date          in         varchar2
,  p_org_id           in         number
) is

   l_proc        varchar2(72) := 'ARCHIVE_WMS_TASKS_WORKER :';
   l_debug       number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

   l_organization_id  number;
   l_number_of_records number;

   l_min_date   date;
   l_max_date   date;

begin
   savepoint archiving_task_savepoint;
   if (l_debug = 1) then
      trace(l_proc || ' Entering procedure  '|| l_proc || ':'|| to_char(sysdate, 'RRRR/MM/DD HH24:MI:SS'), 1);
      trace(l_proc || ' p_from_date => ' || p_from_date);
      trace(l_proc || ' p_to_date => ' || p_to_date);
      trace(l_proc || ' p_org_id => ' || p_org_id);
   end if;

   l_min_date   := to_date(p_from_date, 'RRRR/MM/DD HH24:MI:SS');
   l_max_date   := to_date(p_to_date, 'RRRR/MM/DD HH24:MI:SS');

   if l_max_date < l_min_date then
      if (l_debug = 1) then
	 trace(l_proc || 'To date cannot be less than From date');
      end if;
      raise fnd_api.g_exc_error;
   end if;

   -- @@@ Insert section.
   -- @@@ Insert records from the wms_dispatched_tasks_history into wms_dispatched_tasks_arch
   -- @@@ where parent_transaction_id is not null and task_type in (2,8)
   if (l_debug = 1) then
      trace(l_proc || ' Start of insert into wms_dispatched_tasks_arch ...');
      trace(l_proc || ' for parent_transaction_id is not null and task_type in (2,8)');
   end if;

   insert into wms_dispatched_tasks_arch(
    TASK_ID
   ,TRANSACTION_ID
   ,ORGANIZATION_ID
   ,USER_TASK_TYPE
   ,PERSON_ID
   ,EFFECTIVE_START_DATE
   ,EFFECTIVE_END_DATE
   ,EQUIPMENT_ID
   ,EQUIPMENT_INSTANCE
   ,PERSON_RESOURCE_ID
   ,MACHINE_RESOURCE_ID
   ,STATUS
   ,DISPATCHED_TIME
   ,LOADED_TIME
   ,DROP_OFF_TIME
   ,LAST_UPDATE_DATE
   ,LAST_UPDATED_BY
   ,CREATION_DATE
   ,CREATED_BY
   ,LAST_UPDATE_LOGIN
   ,ATTRIBUTE_CATEGORY
   ,ATTRIBUTE1
   ,ATTRIBUTE2
   ,ATTRIBUTE3
   ,ATTRIBUTE4
   ,ATTRIBUTE5
   ,ATTRIBUTE6
   ,ATTRIBUTE7
   ,ATTRIBUTE8
   ,ATTRIBUTE9
   ,ATTRIBUTE10
   ,ATTRIBUTE11
   ,ATTRIBUTE12
   ,ATTRIBUTE13
   ,ATTRIBUTE14
   ,ATTRIBUTE15
   ,TASK_TYPE
   ,PRIORITY
   ,TASK_GROUP_ID
   ,SUGGESTED_DEST_SUBINVENTORY
   ,SUGGESTED_DEST_LOCATOR_ID
   ,OPERATION_PLAN_ID
   ,MOVE_ORDER_LINE_ID
   ,TRANSFER_LPN_ID
   ,TRANSACTION_BATCH_ID
   ,TRANSACTION_BATCH_SEQ
   ,INVENTORY_ITEM_ID
   ,REVISION
   ,TRANSACTION_QUANTITY
   ,TRANSACTION_UOM_CODE
   ,SOURCE_SUBINVENTORY_CODE
   ,SOURCE_LOCATOR_ID
   ,DEST_SUBINVENTORY_CODE
   ,DEST_LOCATOR_ID
   ,LPN_ID
   ,CONTENT_LPN_ID
   ,IS_PARENT
   ,PARENT_TRANSACTION_ID
   ,TRANSFER_ORGANIZATION_ID
   ,SOURCE_DOCUMENT_ID
   ,OP_PLAN_INSTANCE_ID
   ,TASK_METHOD
   ,TRANSACTION_TYPE_ID
   ,TRANSACTION_SOURCE_TYPE_ID
   ,TRANSACTION_ACTION_ID)
   select
    wdth.TASK_ID
   ,wdth.TRANSACTION_ID
   ,wdth.ORGANIZATION_ID
   ,wdth.USER_TASK_TYPE
   ,wdth.PERSON_ID
   ,wdth.EFFECTIVE_START_DATE
   ,wdth.EFFECTIVE_END_DATE
   ,wdth.EQUIPMENT_ID
   ,wdth.EQUIPMENT_INSTANCE
   ,wdth.PERSON_RESOURCE_ID
   ,wdth.MACHINE_RESOURCE_ID
   ,wdth.STATUS
   ,wdth.DISPATCHED_TIME
   ,wdth.LOADED_TIME
   ,wdth.DROP_OFF_TIME
   ,wdth.LAST_UPDATE_DATE
   ,wdth.LAST_UPDATED_BY
   ,wdth.CREATION_DATE
   ,wdth.CREATED_BY
   ,wdth.LAST_UPDATE_LOGIN
   ,wdth.ATTRIBUTE_CATEGORY
   ,wdth.ATTRIBUTE1
   ,wdth.ATTRIBUTE2
   ,wdth.ATTRIBUTE3
   ,wdth.ATTRIBUTE4
   ,wdth.ATTRIBUTE5
   ,wdth.ATTRIBUTE6
   ,wdth.ATTRIBUTE7
   ,wdth.ATTRIBUTE8
   ,wdth.ATTRIBUTE9
   ,wdth.ATTRIBUTE10
   ,wdth.ATTRIBUTE11
   ,wdth.ATTRIBUTE12
   ,wdth.ATTRIBUTE13
   ,wdth.ATTRIBUTE14
   ,wdth.ATTRIBUTE15
   ,wdth.TASK_TYPE
   ,wdth.PRIORITY
   ,wdth.TASK_GROUP_ID
   ,wdth.SUGGESTED_DEST_SUBINVENTORY
   ,wdth.SUGGESTED_DEST_LOCATOR_ID
   ,wdth.OPERATION_PLAN_ID
   ,wdth.MOVE_ORDER_LINE_ID
   ,wdth.TRANSFER_LPN_ID
   ,wdth.TRANSACTION_BATCH_ID
   ,wdth.TRANSACTION_BATCH_SEQ
   ,wdth.INVENTORY_ITEM_ID
   ,wdth.REVISION
   ,wdth.TRANSACTION_QUANTITY
   ,wdth.TRANSACTION_UOM_CODE
   ,wdth.SOURCE_SUBINVENTORY_CODE
   ,wdth.SOURCE_LOCATOR_ID
   ,wdth.DEST_SUBINVENTORY_CODE
   ,wdth.DEST_LOCATOR_ID
   ,wdth.LPN_ID
   ,wdth.CONTENT_LPN_ID
   ,wdth.IS_PARENT
   ,wdth.PARENT_TRANSACTION_ID
   ,wdth.TRANSFER_ORGANIZATION_ID
   ,wdth.SOURCE_DOCUMENT_ID
   ,wdth.OP_PLAN_INSTANCE_ID
   ,wdth.TASK_METHOD
   ,wdth.TRANSACTION_TYPE_ID
   ,wdth.TRANSACTION_SOURCE_TYPE_ID
   ,wdth.TRANSACTION_ACTION_ID
   from wms_dispatched_tasks_history wdth, wms_op_plan_instances_hist wopih
   where wdth.last_update_date > l_min_date
   and wdth.last_update_date <= l_max_date
   and wdth.parent_transaction_id is not null
   and wdth.task_type in (2,8)
   and wdth.op_plan_instance_id = wopih.op_plan_instance_id
   and wdth.organization_id = wopih.organization_id
   and wdth.organization_id = nvl(p_org_id, wdth.organization_id);

   l_number_of_records := SQL%ROWCOUNT;
   if (l_debug = 1) then
      trace(l_proc || ' l_number_of_records => '|| l_number_of_records);
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' End of insert into wms_dispatched_tasks_arch ...');
      trace(l_proc || ' for parent_transaction_id is not null and task_type in (2,8)');
   end if;

   -- @@@ Insert records from the wms_dispatched_tasks_history into wms_dispatched_tasks_arch
   -- @@@ where parent_transaction_id is null and task_type not in (2,8)
   if (l_debug = 1) then
      trace(l_proc || ' Start of insert into wms_dispatched_tasks_arch ...');
      trace(l_proc || ' for parent_transaction_id is null and task_type not in (2,8)');
   end if;

   insert into wms_dispatched_tasks_arch(
    TASK_ID
   ,TRANSACTION_ID
   ,ORGANIZATION_ID
   ,USER_TASK_TYPE
   ,PERSON_ID
   ,EFFECTIVE_START_DATE
   ,EFFECTIVE_END_DATE
   ,EQUIPMENT_ID
   ,EQUIPMENT_INSTANCE
   ,PERSON_RESOURCE_ID
   ,MACHINE_RESOURCE_ID
   ,STATUS
   ,DISPATCHED_TIME
   ,LOADED_TIME
   ,DROP_OFF_TIME
   ,LAST_UPDATE_DATE
   ,LAST_UPDATED_BY
   ,CREATION_DATE
   ,CREATED_BY
   ,LAST_UPDATE_LOGIN
   ,ATTRIBUTE_CATEGORY
   ,ATTRIBUTE1
   ,ATTRIBUTE2
   ,ATTRIBUTE3
   ,ATTRIBUTE4
   ,ATTRIBUTE5
   ,ATTRIBUTE6
   ,ATTRIBUTE7
   ,ATTRIBUTE8
   ,ATTRIBUTE9
   ,ATTRIBUTE10
   ,ATTRIBUTE11
   ,ATTRIBUTE12
   ,ATTRIBUTE13
   ,ATTRIBUTE14
   ,ATTRIBUTE15
   ,TASK_TYPE
   ,PRIORITY
   ,TASK_GROUP_ID
   ,SUGGESTED_DEST_SUBINVENTORY
   ,SUGGESTED_DEST_LOCATOR_ID
   ,OPERATION_PLAN_ID
   ,MOVE_ORDER_LINE_ID
   ,TRANSFER_LPN_ID
   ,TRANSACTION_BATCH_ID
   ,TRANSACTION_BATCH_SEQ
   ,INVENTORY_ITEM_ID
   ,REVISION
   ,TRANSACTION_QUANTITY
   ,TRANSACTION_UOM_CODE
   ,SOURCE_SUBINVENTORY_CODE
   ,SOURCE_LOCATOR_ID
   ,DEST_SUBINVENTORY_CODE
   ,DEST_LOCATOR_ID
   ,LPN_ID
   ,CONTENT_LPN_ID
   ,IS_PARENT
   ,PARENT_TRANSACTION_ID
   ,TRANSFER_ORGANIZATION_ID
   ,SOURCE_DOCUMENT_ID
   ,OP_PLAN_INSTANCE_ID
   ,TASK_METHOD
   ,TRANSACTION_TYPE_ID
   ,TRANSACTION_SOURCE_TYPE_ID
   ,TRANSACTION_ACTION_ID)
   select
    TASK_ID
   ,TRANSACTION_ID
   ,ORGANIZATION_ID
   ,USER_TASK_TYPE
   ,PERSON_ID
   ,EFFECTIVE_START_DATE
   ,EFFECTIVE_END_DATE
   ,EQUIPMENT_ID
   ,EQUIPMENT_INSTANCE
   ,PERSON_RESOURCE_ID
   ,MACHINE_RESOURCE_ID
   ,STATUS
   ,DISPATCHED_TIME
   ,LOADED_TIME
   ,DROP_OFF_TIME
   ,LAST_UPDATE_DATE
   ,LAST_UPDATED_BY
   ,CREATION_DATE
   ,CREATED_BY
   ,LAST_UPDATE_LOGIN
   ,ATTRIBUTE_CATEGORY
   ,ATTRIBUTE1
   ,ATTRIBUTE2
   ,ATTRIBUTE3
   ,ATTRIBUTE4
   ,ATTRIBUTE5
   ,ATTRIBUTE6
   ,ATTRIBUTE7
   ,ATTRIBUTE8
   ,ATTRIBUTE9
   ,ATTRIBUTE10
   ,ATTRIBUTE11
   ,ATTRIBUTE12
   ,ATTRIBUTE13
   ,ATTRIBUTE14
   ,ATTRIBUTE15
   ,TASK_TYPE
   ,PRIORITY
   ,TASK_GROUP_ID
   ,SUGGESTED_DEST_SUBINVENTORY
   ,SUGGESTED_DEST_LOCATOR_ID
   ,OPERATION_PLAN_ID
   ,MOVE_ORDER_LINE_ID
   ,TRANSFER_LPN_ID
   ,TRANSACTION_BATCH_ID
   ,TRANSACTION_BATCH_SEQ
   ,INVENTORY_ITEM_ID
   ,REVISION
   ,TRANSACTION_QUANTITY
   ,TRANSACTION_UOM_CODE
   ,SOURCE_SUBINVENTORY_CODE
   ,SOURCE_LOCATOR_ID
   ,DEST_SUBINVENTORY_CODE
   ,DEST_LOCATOR_ID
   ,LPN_ID
   ,CONTENT_LPN_ID
   ,IS_PARENT
   ,PARENT_TRANSACTION_ID
   ,TRANSFER_ORGANIZATION_ID
   ,SOURCE_DOCUMENT_ID
   ,OP_PLAN_INSTANCE_ID
   ,TASK_METHOD
   ,TRANSACTION_TYPE_ID
   ,TRANSACTION_SOURCE_TYPE_ID
   ,TRANSACTION_ACTION_ID
   from wms_dispatched_tasks_history wdth
   where wdth.last_update_date > l_min_date
   and wdth.last_update_date <= l_max_date
   and (wdth.parent_transaction_id is null or wdth.task_type not in (2,8))
   and wdth.organization_id = nvl(p_org_id, wdth.organization_id);

   l_number_of_records := SQL%ROWCOUNT;
   if (l_debug = 1) then
      trace(l_proc || ' l_number_of_records => '|| l_number_of_records);
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' End of insert into wms_dispatched_tasks_arch ...');
      trace(l_proc || ' for parent_transaction_id is null and task_type not in (2,8)');
   end if;

   -- @@@ Insert records into the wms_op_plan_instances_arch from the wms_op_plan_instances_hist
   if (l_debug = 1) then
      trace(l_proc || ' Start of insert into wms_op_plan_instances_arch ...');
   end if;

   insert into wms_op_plan_instances_arch(
    OP_PLAN_INSTANCE_ID
   ,OPERATION_PLAN_ID
   ,STATUS
   ,ORGANIZATION_ID
   ,PLAN_EXECUTION_START_DATE
   ,PLAN_EXECUTION_END_DATE
   ,CREATED_BY
   ,CREATION_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATE_LOGIN
   ,ATTRIBUTE_CATEGORY
   ,ATTRIBUTE1
   ,ATTRIBUTE2
   ,ATTRIBUTE3
   ,ATTRIBUTE4
   ,ATTRIBUTE5
   ,ATTRIBUTE6
   ,ATTRIBUTE7
   ,ATTRIBUTE8
   ,ATTRIBUTE9
   ,ATTRIBUTE10
   ,ATTRIBUTE11
   ,ATTRIBUTE12
   ,ATTRIBUTE13
   ,ATTRIBUTE14
   ,ATTRIBUTE15
   ,ACTIVITY_TYPE_ID
   ,PLAN_TYPE_ID
   ,ORIG_SOURCE_SUB_CODE
   ,ORIG_SOURCE_LOC_ID
   ,ORIG_DEST_SUB_CODE
   ,ORIG_DEST_LOC_ID)
   select
    OP_PLAN_INSTANCE_ID
   ,OPERATION_PLAN_ID
   ,STATUS
   ,ORGANIZATION_ID
   ,PLAN_EXECUTION_START_DATE
   ,PLAN_EXECUTION_END_DATE
   ,CREATED_BY
   ,CREATION_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATE_LOGIN
   ,ATTRIBUTE_CATEGORY
   ,ATTRIBUTE1
   ,ATTRIBUTE2
   ,ATTRIBUTE3
   ,ATTRIBUTE4
   ,ATTRIBUTE5
   ,ATTRIBUTE6
   ,ATTRIBUTE7
   ,ATTRIBUTE8
   ,ATTRIBUTE9
   ,ATTRIBUTE10
   ,ATTRIBUTE11
   ,ATTRIBUTE12
   ,ATTRIBUTE13
   ,ATTRIBUTE14
   ,ATTRIBUTE15
   ,ACTIVITY_TYPE_ID
   ,PLAN_TYPE_ID
   ,ORIG_SOURCE_SUB_CODE
   ,ORIG_SOURCE_LOC_ID
   ,ORIG_DEST_SUB_CODE
   ,ORIG_DEST_LOC_ID
   from wms_op_plan_instances_hist wopih
   where wopih.last_update_date > l_min_date
   and wopih.last_update_date <= l_max_date
   and wopih.organization_id = nvl(p_org_id, wopih.organization_id);

   l_number_of_records := SQL%ROWCOUNT;
   if (l_debug = 1) then
      trace(l_proc || ' l_number_of_records => '|| l_number_of_records);
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' End of insert into wms_op_plan_instances_arch ...');
   end if;

   -- @@@ Insert records from the wms_op_opertn_instances_hist into wms_op_opertn_instances_arch
   if (l_debug = 1) then
      trace(l_proc || ' Start of insert into wms_op_opertn_instances_arch ...');
   end if;

   insert into wms_op_opertn_instances_arch(
    OPERATION_INSTANCE_ID
   ,OP_PLAN_INSTANCE_ID
   ,ORGANIZATION_ID
   ,OPERATION_STATUS
   ,OPERATION_PLAN_DETAIL_ID
   ,OPERATION_SEQUENCE
   ,FROM_SUBINVENTORY_CODE
   ,FROM_LOCATOR_ID
   ,TO_SUBINVENTORY_CODE
   ,TO_LOCATOR_ID
   ,CREATED_BY
   ,CREATION_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATE_LOGIN
   ,ATTRIBUTE_CATEGORY
   ,ATTRIBUTE1
   ,ATTRIBUTE2
   ,ATTRIBUTE3
   ,ATTRIBUTE4
   ,ATTRIBUTE5
   ,ATTRIBUTE6
   ,ATTRIBUTE7
   ,ATTRIBUTE8
   ,ATTRIBUTE9
   ,ATTRIBUTE10
   ,ATTRIBUTE11
   ,ATTRIBUTE12
   ,ATTRIBUTE13
   ,ATTRIBUTE14
   ,ATTRIBUTE15
   ,OPERATION_TYPE_ID
   ,ACTIVITY_TYPE_ID
   ,SUG_TO_SUB_CODE
   ,SUG_TO_LOCATOR_ID
   ,SOURCE_TASK_ID
   ,EMPLOYEE_ID
   ,EQUIPMENT_ID
   ,ACTIVATE_TIME
   ,COMPLETE_TIME
   ,IS_IN_INVENTORY)
   select
    OPERATION_INSTANCE_ID
   ,OP_PLAN_INSTANCE_ID
   ,ORGANIZATION_ID
   ,OPERATION_STATUS
   ,OPERATION_PLAN_DETAIL_ID
   ,OPERATION_SEQUENCE
   ,FROM_SUBINVENTORY_CODE
   ,FROM_LOCATOR_ID
   ,TO_SUBINVENTORY_CODE
   ,TO_LOCATOR_ID
   ,CREATED_BY
   ,CREATION_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATE_LOGIN
   ,ATTRIBUTE_CATEGORY
   ,ATTRIBUTE1
   ,ATTRIBUTE2
   ,ATTRIBUTE3
   ,ATTRIBUTE4
   ,ATTRIBUTE5
   ,ATTRIBUTE6
   ,ATTRIBUTE7
   ,ATTRIBUTE8
   ,ATTRIBUTE9
   ,ATTRIBUTE10
   ,ATTRIBUTE11
   ,ATTRIBUTE12
   ,ATTRIBUTE13
   ,ATTRIBUTE14
   ,ATTRIBUTE15
   ,OPERATION_TYPE_ID
   ,ACTIVITY_TYPE_ID
   ,SUG_TO_SUB_CODE
   ,SUG_TO_LOCATOR_ID
   ,SOURCE_TASK_ID
   ,EMPLOYEE_ID
   ,EQUIPMENT_ID
   ,ACTIVATE_TIME
   ,COMPLETE_TIME
   ,IS_IN_INVENTORY
   from wms_op_opertn_instances_hist wooih
   where wooih.last_update_date > l_min_date
   and wooih.last_update_date <= l_max_date
   and wooih.organization_id = nvl(p_org_id, wooih.organization_id);

   l_number_of_records := SQL%ROWCOUNT;
   if (l_debug = 1) then
      trace(l_proc || ' l_number_of_records => '|| l_number_of_records);
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' End of insert into wms_op_opertn_instances_arch ...');
   end if;

   -- @@@ Delete Section
   -- @@@ Delete records from wms_dispatched_tasks_arch table.
   if (l_debug = 1) then
      trace(l_proc || ' Start of delete from wms_dispatched_tasks_history ...');
      trace(l_proc || ' for parent_transaction_id is not null and task_type in (2,8)');
   end if;

   delete from wms_dispatched_tasks_history
   where task_id in (
   select wdth.task_id
   from wms_dispatched_tasks_history wdth, wms_op_plan_instances_hist wopih
   where wdth.last_update_date > l_min_date
   and wdth.last_update_date <= l_max_date
   and wdth.parent_transaction_id is not null
   and wdth.task_type in (2,8)
   and wdth.op_plan_instance_id = wopih.op_plan_instance_id
   and wdth.organization_id = wopih.organization_id
   and wdth.organization_id = nvl(p_org_id, wdth.organization_id));

   l_number_of_records := SQL%ROWCOUNT;
   if (l_debug = 1) then
      trace(l_proc || ' l_number_of_records => '|| l_number_of_records);
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' End of delete from wms_dispatched_tasks_history ...');
      trace(l_proc || ' for parent_transaction_id is not null and task_type in (2,8)');
   end if;

   -- @@@ Delete records from wms_dispatched_tasks_arch table.
   if (l_debug = 1) then
      trace(l_proc || ' Start of delete from wms_dispatched_tasks_history ...');
      trace(l_proc || ' for parent_transaction_id is null and task_type not in (2,8)');
   end if;

   delete from wms_dispatched_tasks_history wdth
   where wdth.last_update_date > l_min_date
   and wdth.last_update_date <= l_max_date
   and (wdth.parent_transaction_id is null or wdth.task_type not in (2,8))
   and wdth.organization_id = nvl(p_org_id, wdth.organization_id);

   l_number_of_records := SQL%ROWCOUNT;
   if (l_debug = 1) then
      trace(l_proc || ' l_number_of_records => '|| l_number_of_records);
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' End of delete from wms_dispatched_tasks_history ...');
      trace(l_proc || ' for parent_transaction_id is null and task_type not in (2,8)');
   end if;

   -- @@@ Delete records from the wms_op_plan_instances_hist table.
   if (l_debug = 1) then
      trace(l_proc || ' Start of delete from wms_op_plan_instances_hist ...');
   end if;

   delete from wms_op_plan_instances_hist wopih
   where wopih.last_update_date > l_min_date
   and wopih.last_update_date <= l_max_date
   and wopih.organization_id = nvl(p_org_id, wopih.organization_id);

   l_number_of_records := SQL%ROWCOUNT;
   if (l_debug = 1) then
      trace(l_proc || ' l_number_of_records => '|| l_number_of_records);
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' End of delete from wms_op_plan_instances_hist ...');
   end if;

   -- @@@ Delete records from the wms_op_opertn_instances_hist table
   if (l_debug = 1) then
      trace(l_proc || ' Start of delete from wms_op_opertn_instances_hist ...');
   end if;

   delete from wms_op_opertn_instances_hist wooih
   where wooih.last_update_date > l_min_date
   and wooih.last_update_date <= l_max_date
   and wooih.organization_id = nvl(p_org_id, wooih.organization_id);

   l_number_of_records := SQL%ROWCOUNT;
   if (l_debug = 1) then
      trace(l_proc || ' l_number_of_records => '|| l_number_of_records);
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' End of delete from wms_op_opertn_instances_hist ...');
   end if;

   -- @@@ Delete records from the wms_op_opertn_instances_hist table
   if (l_debug = 1) then
      trace(l_proc || ' Start of delete from wms_exceptions ...');
   end if;

   delete from wms_exceptions wex
   where wex.creation_date > l_min_date
   and wex.creation_date  <= l_max_date
   and wex.organization_id = nvl(p_org_id, wex.organization_id);

   if (l_debug = 1) then
      trace(l_proc || ' End of delete from wms_exceptions ...');
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' Before commit in Worker...');
   end if;

   commit;
   if (l_debug = 1) then
      trace(l_proc || ' After commit in Worker...');
   end if;


   x_retcode  := 0;
   x_errbuf   := 'Success';
exception
   when fnd_api.g_exc_error then
        if (l_debug = 1) then
           trace(l_proc || ' fnd_api.g_exc_error :' || sqlcode);
           trace(l_proc || ' fnd_api.g_exc_error :' || substr(sqlerrm, 1, 100));
        end if;

        rollback to archiving_task_savepoint;
        x_retcode  := 2;
        x_errbuf   := 'Error';
        return;
   when others then
        if (l_debug = 1) then
           trace(l_proc || ' SQL Error Code :' || sqlcode);
           trace(l_proc || ' SQL Error Message :' || substr(sqlerrm, 1, 100));
        end if;

        rollback to archiving_task_savepoint;

        x_retcode  := 2;
        x_errbuf   := 'Error';
        return;
end archive_tasks_worker;
--
--
-- ---------------------------------------------------------------------------------------
-- |-------------------------------< unarchive_tasks >------------------------------------|
-- ---------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Archives tasks records based on organization.
--
--   Package-Procedure combination
--
-- Prerequisites:
--
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   x_errbuf                       Yes  varchar2 Concurrent Manager Parameter.
--   x_retcode                      Yes  varchar2 Concurrent Manager Parameter.
--   p_from_date                    Yes  varchar2 date from which records need to be restored.
--   p_to_date                      Yes  varchar2 date to which records need to be restored.
--   p_org_code                     Yes  number   Organization Code for the process.
--   p_unarch_batches               Yes  number   Number of batches into which the records
--                                                needs to be broken up.
--
--
-- Post Success:
--   Data in the history table are deleted once the Archive tables are populated apropriately.
--
-- Post Failure:
--   No data archiving takes place,
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure unarchive_tasks(
   x_errbuf           out nocopy varchar2
,  x_retcode          out nocopy number
,  p_from_date        in         varchar2
,  p_to_date          in         varchar2
,  p_org_id           in         number
,  p_unarch_batches   in         number
) is

       l_proc        varchar2(72) := 'UNARCHIVE_WMS_TASKS :';
       l_debug       number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

       l_max_date_time        varchar2(50):= null;
       l_sys_date             varchar2(50):= null;

       l_total_record_count   number:= 0;
       l_min_range_date_time  varchar2(50):= null;
       l_max_range_date_time  varchar2(50):= null;
       l_days_between         number := 0;
       l_each_worker_chunk    number:= 0;


       l_record_per_worker    number:= 0;
       l_number_workers       number:= 0;
       l_organization_id      number:= 0;

       l_loop_counter         number:= 1;
       l_from_date            date;
       l_to_date              date;
       l_num_batches          number:= 0;
       l_purge_req_id         number;

       l_min_date             date;
       l_max_date             date;

       type l_reqstatus_table is table of number
       index by binary_integer;

       l_reqstatus_tbl_type       l_reqstatus_table;
       --l_num_of_workers_launched  number;

       submission_error_except  exception;
       i                        number;
       l_number_of_records      number;


--  ### This cursor gets the record count and days between the p_from_date and p_to_date.
--  ### Data in this tables which lies betweent he range provided is elligible to be moved
--  ### back to the history tables.
cursor c_get_total_eligible_recs is
select  count(*), (l_max_date - l_min_date)
from wms_dispatched_tasks_arch
where last_update_date > l_min_date
and last_update_date <= l_max_date
and organization_id = nvl(p_org_id, organization_id);
--
--
begin
   savepoint unarch_task_master_savepoint;
   if (l_debug = 1) then
      trace(' Entering procedure  '|| l_proc || ':'|| to_char(sysdate, 'RRRR/MM/DD HH24:MI:SS'), 1);
      trace(l_proc || ' p_from_date  => ' || p_from_date);
      trace(l_proc || ' p_to_date  => ' || p_to_date);
      trace(l_proc || ' p_org_id  => ' || p_org_id);
      trace(l_proc || ' p_unarch_batches  => ' || p_unarch_batches);
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' Before validating date...');
   end if;

   l_min_date   := to_date(p_from_date, 'RRRR/MM/DD HH24:MI:SS');
   l_max_date   := to_date(p_to_date, 'RRRR/MM/DD HH24:MI:SS');

   if (l_debug = 1) then
      trace(l_proc || ' l_min_date  => ' || to_char(l_min_date, 'RRRR/MM/DD HH24:MI:SS'));
      trace(l_proc || ' l_max_date  => ' || to_char(l_max_date, 'RRRR/MM/DD HH24:MI:SS'));
   end if;

   -- @@@ Validating input parameters.
   if (l_max_date < l_min_date) then
      if (l_debug = 1) then
	 trace(l_proc || 'To date cannot be less than From date', 9);
      end if;
      raise fnd_api.g_exc_error;
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' After validating date...');
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' Before validating p_unarch_batches...');
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' After validating p_unarch_batches...');
   end if;

   -- @@@ Get total number of eligible records to be archived.
   open  c_get_total_eligible_recs;
   fetch c_get_total_eligible_recs
   into  l_total_record_count, l_days_between;

   if l_total_record_count = 0 then
      if (l_debug = 1) then
         trace(l_proc || ' Eligible records not found for Unarchiving for date range provided... ');
      end if;

      close c_get_total_eligible_recs;
      raise fnd_api.g_exc_error;
      --return;
   elsif l_total_record_count > 0 then
      if (l_debug = 1) then
         trace(l_proc || ' l_total_record_count => '|| nvl(l_total_record_count, -99));
         trace(l_proc || ' l_days_between => '|| nvl(l_days_between, -99));
         trace(l_proc || ' Before Checking l_total_record_count and setting value for the l_record_per_worker variable...');
      end if;

      -- @@@ Determine number of records to be processed by each worker.
      -- @@@ If the total number of records is less than a million then its set to 50000 else 300000;
      if l_total_record_count < 100000 then
         l_record_per_worker := c_records_per_worker;
      else
         l_record_per_worker := c_record_hi_number_per_worker;
      end if;

      if (l_debug = 1) then
         trace(l_proc || ' l_record_per_worker => '|| l_record_per_worker);
         trace(l_proc || ' After Checking l_total_record_count and setting value for the l_record_per_worker variable...');
         trace(l_proc || ' Before calculating value for l_num_batches variable...');
         trace(l_proc || ' l_total_record_count => ' || l_total_record_count);
         trace(l_proc || ' l_record_per_worker => ' || l_record_per_worker);
         trace(l_proc || ' p_unarch_batches => ' || p_unarch_batches);
      end if;

      -- @@@ Calculate the number of workers required for this run.
      -- @@@ The entire batch will be divided between multiple workers.
      l_num_batches := ceil(l_total_record_count/l_record_per_worker);

      if (l_debug = 1) then
         trace(l_proc || ' l_num_batches => ' || l_num_batches);
      end if;

      if p_unarch_batches > l_num_batches then
         l_number_workers:= l_num_batches;
      else
         l_number_workers:= p_unarch_batches;
      end if;

      if (l_debug = 1) then
         trace(l_proc || ' l_number_workers => '|| l_number_workers);
         trace(l_proc || ' After calculating value for l_num_batches variable...');
      end if;


      -- @@@ Get the chunk of data in terms of days to be assigned to each worker.
      l_each_worker_chunk := l_days_between/l_number_workers;
      if (l_debug = 1) then
         trace(l_proc || ' l_each_worker_chunk '|| l_each_worker_chunk);
      end if;

      if (l_debug = 1) then
         trace(l_proc || ' Start of Insert based on the exception condition...');
      end if;

      --savepoint unarch_task_master_savepoint;
      -- @@@ Insert section.
      -- @@@ Insert records from the wms_dispatched_tasks_arch into wms_dispatched_tasks_history
      -- @@@ These records are those which may have be missed in the worker cursor.
      -- @@@ For every wopia, there can be multiple records in the wdta.  Since the main cursor in
      -- @@@ the master, queries on the wdta, there is a chance that the from and to date
      -- @@@ specified by the user may not get all the related records satisfied by the condition
      -- @@@ mentioned in this SQL. This makes sure that there is no data inconsistency.
      insert into wms_dispatched_tasks_history(
      TASK_ID
     ,TRANSACTION_ID
     ,ORGANIZATION_ID
     ,USER_TASK_TYPE
     ,PERSON_ID
     ,EFFECTIVE_START_DATE
     ,EFFECTIVE_END_DATE
     ,EQUIPMENT_ID
     ,EQUIPMENT_INSTANCE
     ,PERSON_RESOURCE_ID
     ,MACHINE_RESOURCE_ID
     ,STATUS
     ,DISPATCHED_TIME
     ,LOADED_TIME
     ,DROP_OFF_TIME
     ,LAST_UPDATE_DATE
     ,LAST_UPDATED_BY
     ,CREATION_DATE
     ,CREATED_BY
     ,LAST_UPDATE_LOGIN
     ,ATTRIBUTE_CATEGORY
     ,ATTRIBUTE1
     ,ATTRIBUTE2
     ,ATTRIBUTE3
     ,ATTRIBUTE4
     ,ATTRIBUTE5
     ,ATTRIBUTE6
     ,ATTRIBUTE7
     ,ATTRIBUTE8
     ,ATTRIBUTE9
     ,ATTRIBUTE10
     ,ATTRIBUTE11
     ,ATTRIBUTE12
     ,ATTRIBUTE13
     ,ATTRIBUTE14
     ,ATTRIBUTE15
     ,TASK_TYPE
     ,PRIORITY
     ,TASK_GROUP_ID
     ,SUGGESTED_DEST_SUBINVENTORY
     ,SUGGESTED_DEST_LOCATOR_ID
     ,OPERATION_PLAN_ID
     ,MOVE_ORDER_LINE_ID
     ,TRANSFER_LPN_ID
     ,TRANSACTION_BATCH_ID
     ,TRANSACTION_BATCH_SEQ
     ,INVENTORY_ITEM_ID
     ,REVISION
     ,TRANSACTION_QUANTITY
     ,TRANSACTION_UOM_CODE
     ,SOURCE_SUBINVENTORY_CODE
     ,SOURCE_LOCATOR_ID
     ,DEST_SUBINVENTORY_CODE
     ,DEST_LOCATOR_ID
     ,LPN_ID
     ,CONTENT_LPN_ID
     ,IS_PARENT
     ,PARENT_TRANSACTION_ID
     ,TRANSFER_ORGANIZATION_ID
     ,SOURCE_DOCUMENT_ID
     ,OP_PLAN_INSTANCE_ID
     ,TASK_METHOD
     ,TRANSACTION_TYPE_ID
     ,TRANSACTION_SOURCE_TYPE_ID
     ,TRANSACTION_ACTION_ID)
     select
      wdta.TASK_ID
     ,wdta.TRANSACTION_ID
     ,wdta.ORGANIZATION_ID
     ,wdta.USER_TASK_TYPE
     ,wdta.PERSON_ID
     ,wdta.EFFECTIVE_START_DATE
     ,wdta.EFFECTIVE_END_DATE
     ,wdta.EQUIPMENT_ID
     ,wdta.EQUIPMENT_INSTANCE
     ,wdta.PERSON_RESOURCE_ID
     ,wdta.MACHINE_RESOURCE_ID
     ,wdta.STATUS
     ,wdta.DISPATCHED_TIME
     ,wdta.LOADED_TIME
     ,wdta.DROP_OFF_TIME
     ,wdta.LAST_UPDATE_DATE
     ,wdta.LAST_UPDATED_BY
     ,wdta.CREATION_DATE
     ,wdta.CREATED_BY
     ,wdta.LAST_UPDATE_LOGIN
     ,wdta.ATTRIBUTE_CATEGORY
     ,wdta.ATTRIBUTE1
     ,wdta.ATTRIBUTE2
     ,wdta.ATTRIBUTE3
     ,wdta.ATTRIBUTE4
     ,wdta.ATTRIBUTE5
     ,wdta.ATTRIBUTE6
     ,wdta.ATTRIBUTE7
     ,wdta.ATTRIBUTE8
     ,wdta.ATTRIBUTE9
     ,wdta.ATTRIBUTE10
     ,wdta.ATTRIBUTE11
     ,wdta.ATTRIBUTE12
     ,wdta.ATTRIBUTE13
     ,wdta.ATTRIBUTE14
     ,wdta.ATTRIBUTE15
     ,wdta.TASK_TYPE
     ,wdta.PRIORITY
     ,wdta.TASK_GROUP_ID
     ,wdta.SUGGESTED_DEST_SUBINVENTORY
     ,wdta.SUGGESTED_DEST_LOCATOR_ID
     ,wdta.OPERATION_PLAN_ID
     ,wdta.MOVE_ORDER_LINE_ID
     ,wdta.TRANSFER_LPN_ID
     ,wdta.TRANSACTION_BATCH_ID
     ,wdta.TRANSACTION_BATCH_SEQ
     ,wdta.INVENTORY_ITEM_ID
     ,wdta.REVISION
     ,wdta.TRANSACTION_QUANTITY
     ,wdta.TRANSACTION_UOM_CODE
     ,wdta.SOURCE_SUBINVENTORY_CODE
     ,wdta.SOURCE_LOCATOR_ID
     ,wdta.DEST_SUBINVENTORY_CODE
     ,wdta.DEST_LOCATOR_ID
     ,wdta.LPN_ID
     ,wdta.CONTENT_LPN_ID
     ,wdta.IS_PARENT
     ,wdta.PARENT_TRANSACTION_ID
     ,wdta.TRANSFER_ORGANIZATION_ID
     ,wdta.SOURCE_DOCUMENT_ID
     ,wdta.OP_PLAN_INSTANCE_ID
     ,wdta.TASK_METHOD
     ,wdta.TRANSACTION_TYPE_ID
     ,wdta.TRANSACTION_SOURCE_TYPE_ID
     ,wdta.TRANSACTION_ACTION_ID
      from  wms_dispatched_tasks_arch wdta, wms_op_plan_instances_arch wopia
      where wdta.last_update_date < l_min_date
      and wopia.op_plan_instance_id = wdta.op_plan_instance_id
      and wdta.organization_id = wopia.organization_id
      and wdta.organization_id = nvl(p_org_id, wdta.organization_id)
      and wopia.last_update_date > l_min_date
      and wopia.last_update_date <= l_max_date;

      l_number_of_records := SQL%ROWCOUNT;
      if (l_debug = 1) then
         trace(l_proc || ' l_number_of_records => '|| l_number_of_records);
      end if;

      if (l_debug = 1) then
         trace(l_proc || ' End of Insert based on the exception condition...');
      end if;

      if (l_debug = 1) then
         trace(l_proc || ' Start of Delete based on the exception condition...');
      end if;

      -- @@@ Delete this information from the wms_dispatched_tasks_arch table after inserting.
      delete from wms_dispatched_tasks_arch
      where task_id in (
      select wdta.task_id
      from wms_dispatched_tasks_arch wdta, wms_op_plan_instances_arch wopia
      where wdta.last_update_date <= l_min_date
      and wopia.op_plan_instance_id = wdta.op_plan_instance_id
      and wdta.organization_id = wopia.organization_id
      and wdta.organization_id = nvl(p_org_id, wdta.organization_id)
      and wopia.last_update_date > l_min_date
      and wopia.last_update_date <= l_max_date);

      l_number_of_records := SQL%ROWCOUNT;
      if (l_debug = 1) then
         trace(l_proc || ' l_number_of_records => '|| l_number_of_records);
      end if;

      if (l_debug = 1) then
         trace(l_proc || ' End of Delete based on the exception condition...');
      end if;


      if l_number_workers > 0 then
         if (l_debug = 1) then
            trace(l_proc || ' Before Entering the for loop... ');
         end if;

         -- @@@ Loop to call multiple workers to assign separate batches of records to be processsed.
         for i in 1..l_number_workers
         loop
             -- @@@ The l_loop_counter(i) is used to determine mainly the first run in the loop.
             -- @@@ Note that the 'l_from_date' and 'l_to_date' are both defined as date variables.
             -- @@@ The  'l_min_range_date_time' is defined as a varchar2 so as to derive the date/time
             -- @@@ information to the precision of the last second.
             -- @@@ The 'l_min_range_date_time' derived as follows from the
             -- @@@  'c_get_total_eligible_recs' cursor:
             -- @@@    "to_char(min(last_update_date), 'MM/DD/YY HH:MI:SS')"
             -- @@@ Since the 'l_min_range_date_time' is a varchar, the fnd_date.displaydate_to_date()
             -- @@@ is used to convert it to a date and assign to the l_from_date(date variable).
             -- @@@ This only needs to be done the very first time since in the subsequence runs,
             -- @@@ date arithmetic is being performed with the SELECT from dual.
             -- @@@
             -- @@@ The logic of deriving the 'l_from_date' and 'l_to_date' for each worker call is as follows:
             -- @@@ 1. For the very first run, the 'l_from_date' is equal to the 'l_min_range_date_time'.
             -- @@@    This is passed as a date variable to the first worker call.
             -- @@@ 2. The 'l_to_date' is computed as the 'l_from_date + l_each_worker_chunk' every time as follows:
             -- @@@    The 'l_each_worker_chunk' stores the number of days for each worker.
             -- @@@    Hence the
             -- @@@     'select (l_from_date + l_each_worker_chunk) into l_to_date from dual;'
             -- @@@    effectively derives the l_to_date with a precision to the last second.
             -- @@@ 3. In every subsequent run, date arithmetic is performed on the 'l_from_date' and 'l_to_date'
             -- @@@    derived in the previous run prior to the worker call.
             -- @@@
             -- @@@ One another thing to note is that the subsequent runs, the 'l_from_date' is set to the
             -- @@@ 'l_to_date' from the last run in the loop. The SQL in the worker is selecting a range
             -- @@@ greater that the 'l_from_date'.
             if (i = 1) then
                -- @@@ Get the min date range for the first worker call.
                --l_from_date := fnd_date.displaydate_to_date(l_min_date);
                l_from_date := l_min_date;
                if (l_debug = 1) then
                    trace(l_proc || ' Inside if for (i = 1)...');
                    trace(l_proc || ' i => ' || i);
                    trace(l_proc || ' l_from_date  => ' || to_char(l_from_date, 'RRRR/MM/DD HH24:MI:SS'));
                end if;
             elsif (i > 1) then
                -- @@@ Get the min date range for subsequent worker call.
                l_from_date := l_to_date;
                if (l_debug = 1) then
                    trace(l_proc || ' Inside if for (i > 1)...');
                    trace(l_proc || ' i => ' || i);
                    trace(l_proc || ' l_from_date  => ' || to_char(l_from_date, 'RRRR/MM/DD HH24:MI:SS'));
                end if;
             end if;

             if (l_debug = 1) then
                trace(l_proc || ' l_from_date  Outside the if check for counter(i) => ' || to_char(l_from_date, 'RRRR/MM/DD HH24:MI:SS'));
             end if;

             -- @@@ Get the max date range for the worker call.
             -- @@@ If the loop counter value equals the l_number_workers, then set the l_to_date to
             if (i = l_number_workers) then
             	l_to_date := l_max_date;
             else
                --l_to_date := l_from_date + l_each_worker_chunk;
                select (l_from_date + l_each_worker_chunk) into l_to_date from dual;
             end if;

             if (l_debug = 1) then
                trace(l_proc || ' i => ' || i);
                trace(l_proc || ' l_to_date  => ' || to_char(l_to_date, 'RRRR/MM/DD HH24:MI:SS'));
             end if;

             if (l_debug = 1) then
                trace(l_proc || ' Loop Counter = ' || i);
                trace(l_proc || ' Before Launching WMS Task Purge Worker ...');
                trace(l_proc || ' For Range, with From Date => ' || to_char(l_from_date, 'RRRR/MM/DD HH24:MI:SS'));
                trace(l_proc || ' and To Date => ' || to_char(l_to_date, 'RRRR/MM/DD HH24:MI:SS'));
             end if;


             -- @@@ Calling the purge worker for a specific date range..
             -- @@@
             l_purge_req_id :=  fnd_request.submit_request(application => 'WMS'
                                                         , program => 'WMSTUARW'
                                                         , argument1 => to_char(l_from_date, 'RRRR/MM/DD HH24:MI:SS')
                                                         , argument2 => to_char(l_to_date, 'RRRR/MM/DD HH24:MI:SS')
                                                         , argument3 => p_org_id);

             if (l_debug = 1) then
                trace(l_proc || ' l_purge_req_id => ' || l_purge_req_id);
             end if;

             -- @@@ Handle worker submission error
             -- @@@ Raise exception if failed else commit and proceed.
             if (l_purge_req_id = 0) then
                if (l_debug = 1) then
                    trace(l_proc || ' Error launching last Purge Worker........');
                end if;
                raise submission_error_except;
             else
                 commit;
             end if;

             if (l_debug = 1) then
                trace(l_proc || ' Concurrent Request Id ' || l_purge_req_id|| ' Submitted' );
                trace(l_proc || ' WMS Task Purge Worker Number = ' || i || ' Launched');
             end if;

             --l_num_of_workers_launched := l_num_of_workers_launched + 1;
             if (l_debug = 1) then
                trace(l_proc || ' l_num_of_workers_launched ' || i);
             end if;

             l_reqstatus_tbl_type(i) := l_purge_req_id;
             if (l_debug = 1) then
                trace(l_proc || ' l_reqstatus_tbl_type(' || i ||') => '|| l_reqstatus_tbl_type(i));
             end if;
         end loop;-- Marker End Loop for call to the Archiving Task Worker
         if (l_debug = 1) then
            trace(l_proc || ' Outside the For Loop...');
            trace(l_proc || ' l_loop_counter => ' || l_loop_counter);
            --trace(l_proc || ' l_number_workers  => ' || l_number_workers);
         end if;
      end if;
      close c_get_total_eligible_recs;
   end if ;

   if (l_debug = 1) then
      trace(l_proc || ' The following Worker Requests have been launched :');
   end if;

   for i in 1..l_reqstatus_tbl_type.count
   loop
       if (l_debug = 1) then
          trace(l_proc || ' Worker Number => ' || i || '...Concurrent Request ID =>' || l_reqstatus_tbl_type(i));
          trace(l_proc || ' Please monitor for concurrent request failures....');
       end if;
   end loop;

   x_retcode  := 0;
   x_errbuf   := 'Success';
exception
   when fnd_api.g_exc_error then
        if (l_debug = 1) then
           trace(l_proc || ' fnd_api.g_exc_error :' || sqlcode);
           trace(l_proc || ' fnd_api.g_exc_error :' || substr(sqlerrm, 1, 100));
        end if;

        if c_get_total_eligible_recs%ISOPEN then
           close c_get_total_eligible_recs;
        end if;

        rollback to unarch_task_master_savepoint;
        x_retcode  := 2;
        x_errbuf   := 'Error';
        return;
   when submission_error_except then
      if (l_debug = 1) then
        trace(l_proc || ' submission_error_except :' || sqlcode);
        trace(l_proc || ' submission_error_except :' || substr(sqlerrm, 1, 100));

        trace(l_proc || ' Number of workers launched before submission failure :' || i);
        trace(l_proc || ' Date Range for the last successful worker submission :');
        trace(l_proc || ' From Date = ' || l_from_date || ' .....To Date= ' || l_to_date);

        trace(l_proc || ' The following Worker Requests have been launched before  the last worker failed to Launch :');
        for i in 1..l_reqstatus_tbl_type.count
        loop
            trace(l_proc || ' Worker Number  ' || i || '...Concurrent Request ID ' || l_reqstatus_tbl_type(i));
        end loop;
      end if;

      if c_get_total_eligible_recs%ISOPEN then
         close c_get_total_eligible_recs;
      end if;

      rollback to unarch_task_master_savepoint;
      x_retcode  := 2;
      x_errbuf   := 'Error';
      return;
   when others then
      if (l_debug = 1) then
        trace(l_proc || ' Others Error :' || sqlcode);
        trace(l_proc || ' Others Error :' || substr(sqlerrm, 1, 100));

        trace(l_proc || ' Number of workers launched before submission failure :' || i);
        trace(l_proc || ' Date Range for the last successful worker submission :');
        trace(l_proc || ' From Date = ' || l_from_date || ' .....To Date= ' || l_to_date);

        trace(l_proc || ' The following Worker Requests have been launched before  the last worker failed to Launch :');
        for i in 1..l_reqstatus_tbl_type.count
        loop
            trace(l_proc || ' Worker Number  ' || i || '...Concurrent Request ID ' || l_reqstatus_tbl_type(i));
        end loop;
      end if;

        if c_get_total_eligible_recs%ISOPEN then
           close c_get_total_eligible_recs;
        end if;

        rollback to unarch_task_master_savepoint;

        x_retcode  := 2;
	x_errbuf   := 'Error';
        return;
end unarchive_tasks;
--
--
-- ---------------------------------------------------------------------------------------
-- |-------------------------------< unarchive_tasks_worker >-----------------------------|
-- ---------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Archives tasks records based on organization.
--
--   Package-Procedure combination
--
-- Prerequisites:
--
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   x_errbuf                       Yes  varchar2 Concurrent Manager Parameter.
--   x_retcode                      Yes  varchar2 Concurrent Manager Parameter.                                                                          --   x_subinventory_code            Yes  varchar2 Call procedure to be registered
--   p_from_date                    Yes  number   From Date for archive process.
--   p_to_date                      Yes  number   To date for the archive process
--   p_org_code                     Yes  varchar2 Organization Code for which data needs
--                                                to be purged.
--
--
-- Post Success:
--   Data in the Archive tables are deleted once the history tables are populated apropriately.
--
-- Post Failure:
--   No data archiving takes place,
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure unarchive_tasks_worker(
   x_errbuf           out nocopy varchar2
,  x_retcode          out nocopy number
,  p_from_date        in         varchar2
,  p_to_date          in         varchar2
,  p_org_id           in         number
) is

   l_proc        varchar2(72) := 'UNARCHIVE_WMS_TASKS_WORKER :';
   l_debug       number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

   l_organization_id  number;
   l_number_of_records number;

   l_min_date   date;
   l_max_date   date;

begin
   savepoint unarch_task_worker_savepoint;
   if (l_debug = 1) then
      trace(' Entering procedure  '|| l_proc || ':'|| to_char(sysdate, 'RRRR/MM/DD HH24:MI:SS'), 1);
      trace(l_proc || ' p_from_date => ' || p_from_date);
      trace(l_proc || ' p_to_date => ' || p_to_date);
      trace(l_proc || ' p_org_id   => ' || nvl(p_org_id, -99));
   end if;

   l_min_date   := to_date(p_from_date, 'RRRR/MM/DD HH24:MI:SS');
   l_max_date   := to_date(p_to_date, 'RRRR/MM/DD HH24:MI:SS');

   if (l_debug = 1) then
      trace(l_proc || ' l_min_date  => ' || to_char(l_min_date, 'RRRR/MM/DD HH24:MI:SS'));
      trace(l_proc || ' l_max_date  => ' || to_char(l_max_date, 'RRRR/MM/DD HH24:MI:SS'));
   end if;

   if (l_max_date < l_min_date) then
      if (l_debug = 1) then
	 trace(l_proc || 'To date cannot be less than From date', 9);
      end if;
      raise fnd_api.g_exc_error;
   end if;

   -- @@@ Insert section.
   -- @@@ Insert records from the wms_dispatched_tasks_arch into wms_dispatched_tasks_history
   -- @@@ where parent_transaction_id is not null and task_type in (2,8)
   if (l_debug = 1) then
      trace(l_proc || ' Start of insert into wms_dispatched_tasks_history ...');
   end if;

   insert into wms_dispatched_tasks_history(
    TASK_ID
   ,TRANSACTION_ID
   ,ORGANIZATION_ID
   ,USER_TASK_TYPE
   ,PERSON_ID
   ,EFFECTIVE_START_DATE
   ,EFFECTIVE_END_DATE
   ,EQUIPMENT_ID
   ,EQUIPMENT_INSTANCE
   ,PERSON_RESOURCE_ID
   ,MACHINE_RESOURCE_ID
   ,STATUS
   ,DISPATCHED_TIME
   ,LOADED_TIME
   ,DROP_OFF_TIME
   ,LAST_UPDATE_DATE
   ,LAST_UPDATED_BY
   ,CREATION_DATE
   ,CREATED_BY
   ,LAST_UPDATE_LOGIN
   ,ATTRIBUTE_CATEGORY
   ,ATTRIBUTE1
   ,ATTRIBUTE2
   ,ATTRIBUTE3
   ,ATTRIBUTE4
   ,ATTRIBUTE5
   ,ATTRIBUTE6
   ,ATTRIBUTE7
   ,ATTRIBUTE8
   ,ATTRIBUTE9
   ,ATTRIBUTE10
   ,ATTRIBUTE11
   ,ATTRIBUTE12
   ,ATTRIBUTE13
   ,ATTRIBUTE14
   ,ATTRIBUTE15
   ,TASK_TYPE
   ,PRIORITY
   ,TASK_GROUP_ID
   ,SUGGESTED_DEST_SUBINVENTORY
   ,SUGGESTED_DEST_LOCATOR_ID
   ,OPERATION_PLAN_ID
   ,MOVE_ORDER_LINE_ID
   ,TRANSFER_LPN_ID
   ,TRANSACTION_BATCH_ID
   ,TRANSACTION_BATCH_SEQ
   ,INVENTORY_ITEM_ID
   ,REVISION
   ,TRANSACTION_QUANTITY
   ,TRANSACTION_UOM_CODE
   ,SOURCE_SUBINVENTORY_CODE
   ,SOURCE_LOCATOR_ID
   ,DEST_SUBINVENTORY_CODE
   ,DEST_LOCATOR_ID
   ,LPN_ID
   ,CONTENT_LPN_ID
   ,IS_PARENT
   ,PARENT_TRANSACTION_ID
   ,TRANSFER_ORGANIZATION_ID
   ,SOURCE_DOCUMENT_ID
   ,OP_PLAN_INSTANCE_ID
   ,TASK_METHOD
   ,TRANSACTION_TYPE_ID
   ,TRANSACTION_SOURCE_TYPE_ID
   ,TRANSACTION_ACTION_ID)
   select
    wdta.TASK_ID
   ,wdta.TRANSACTION_ID
   ,wdta.ORGANIZATION_ID
   ,wdta.USER_TASK_TYPE
   ,wdta.PERSON_ID
   ,wdta.EFFECTIVE_START_DATE
   ,wdta.EFFECTIVE_END_DATE
   ,wdta.EQUIPMENT_ID
   ,wdta.EQUIPMENT_INSTANCE
   ,wdta.PERSON_RESOURCE_ID
   ,wdta.MACHINE_RESOURCE_ID
   ,wdta.STATUS
   ,wdta.DISPATCHED_TIME
   ,wdta.LOADED_TIME
   ,wdta.DROP_OFF_TIME
   ,wdta.LAST_UPDATE_DATE
   ,wdta.LAST_UPDATED_BY
   ,wdta.CREATION_DATE
   ,wdta.CREATED_BY
   ,wdta.LAST_UPDATE_LOGIN
   ,wdta.ATTRIBUTE_CATEGORY
   ,wdta.ATTRIBUTE1
   ,wdta.ATTRIBUTE2
   ,wdta.ATTRIBUTE3
   ,wdta.ATTRIBUTE4
   ,wdta.ATTRIBUTE5
   ,wdta.ATTRIBUTE6
   ,wdta.ATTRIBUTE7
   ,wdta.ATTRIBUTE8
   ,wdta.ATTRIBUTE9
   ,wdta.ATTRIBUTE10
   ,wdta.ATTRIBUTE11
   ,wdta.ATTRIBUTE12
   ,wdta.ATTRIBUTE13
   ,wdta.ATTRIBUTE14
   ,wdta.ATTRIBUTE15
   ,wdta.TASK_TYPE
   ,wdta.PRIORITY
   ,wdta.TASK_GROUP_ID
   ,wdta.SUGGESTED_DEST_SUBINVENTORY
   ,wdta.SUGGESTED_DEST_LOCATOR_ID
   ,wdta.OPERATION_PLAN_ID
   ,wdta.MOVE_ORDER_LINE_ID
   ,wdta.TRANSFER_LPN_ID
   ,wdta.TRANSACTION_BATCH_ID
   ,wdta.TRANSACTION_BATCH_SEQ
   ,wdta.INVENTORY_ITEM_ID
   ,wdta.REVISION
   ,wdta.TRANSACTION_QUANTITY
   ,wdta.TRANSACTION_UOM_CODE
   ,wdta.SOURCE_SUBINVENTORY_CODE
   ,wdta.SOURCE_LOCATOR_ID
   ,wdta.DEST_SUBINVENTORY_CODE
   ,wdta.DEST_LOCATOR_ID
   ,wdta.LPN_ID
   ,wdta.CONTENT_LPN_ID
   ,wdta.IS_PARENT
   ,wdta.PARENT_TRANSACTION_ID
   ,wdta.TRANSFER_ORGANIZATION_ID
   ,wdta.SOURCE_DOCUMENT_ID
   ,wdta.OP_PLAN_INSTANCE_ID
   ,wdta.TASK_METHOD
   ,wdta.TRANSACTION_TYPE_ID
   ,wdta.TRANSACTION_SOURCE_TYPE_ID
   ,wdta.TRANSACTION_ACTION_ID
   from wms_dispatched_tasks_arch wdta
   where wdta.last_update_date > l_min_date
   and wdta.last_update_date <= l_max_date
   and wdta.organization_id = nvl(p_org_id, wdta.organization_id);

   l_number_of_records := SQL%ROWCOUNT;
   if (l_debug = 1) then
      trace(l_proc || ' l_number_of_records => '|| l_number_of_records);
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' End of insert into wms_dispatched_tasks_history ...');
   end if;

   -- @@@ Insert records from the wms_op_plan_instance_hist into wms_op_plan_instances_archive
   if (l_debug = 1) then
      trace(l_proc || ' Start of insert into wms_op_plan_instance_hist ...');
   end if;

   insert into wms_op_plan_instances_hist(
    OP_PLAN_INSTANCE_ID
   ,OPERATION_PLAN_ID
   ,STATUS
   ,ORGANIZATION_ID
   ,PLAN_EXECUTION_START_DATE
   ,PLAN_EXECUTION_END_DATE
   ,CREATED_BY
   ,CREATION_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATE_LOGIN
   ,ATTRIBUTE_CATEGORY
   ,ATTRIBUTE1
   ,ATTRIBUTE2
   ,ATTRIBUTE3
   ,ATTRIBUTE4
   ,ATTRIBUTE5
   ,ATTRIBUTE6
   ,ATTRIBUTE7
   ,ATTRIBUTE8
   ,ATTRIBUTE9
   ,ATTRIBUTE10
   ,ATTRIBUTE11
   ,ATTRIBUTE12
   ,ATTRIBUTE13
   ,ATTRIBUTE14
   ,ATTRIBUTE15
   ,ACTIVITY_TYPE_ID
   ,PLAN_TYPE_ID
   ,ORIG_SOURCE_SUB_CODE
   ,ORIG_SOURCE_LOC_ID
   ,ORIG_DEST_SUB_CODE
   ,ORIG_DEST_LOC_ID)
   select
    OP_PLAN_INSTANCE_ID
   ,OPERATION_PLAN_ID
   ,STATUS
   ,ORGANIZATION_ID
   ,PLAN_EXECUTION_START_DATE
   ,PLAN_EXECUTION_END_DATE
   ,CREATED_BY
   ,CREATION_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATE_LOGIN
   ,ATTRIBUTE_CATEGORY
   ,ATTRIBUTE1
   ,ATTRIBUTE2
   ,ATTRIBUTE3
   ,ATTRIBUTE4
   ,ATTRIBUTE5
   ,ATTRIBUTE6
   ,ATTRIBUTE7
   ,ATTRIBUTE8
   ,ATTRIBUTE9
   ,ATTRIBUTE10
   ,ATTRIBUTE11
   ,ATTRIBUTE12
   ,ATTRIBUTE13
   ,ATTRIBUTE14
   ,ATTRIBUTE15
   ,ACTIVITY_TYPE_ID
   ,PLAN_TYPE_ID
   ,ORIG_SOURCE_SUB_CODE
   ,ORIG_SOURCE_LOC_ID
   ,ORIG_DEST_SUB_CODE
   ,ORIG_DEST_LOC_ID
   from wms_op_plan_instances_arch wopia
   where wopia.last_update_date > l_min_date
   and wopia.last_update_date <= l_max_date
   and wopia.organization_id = nvl(p_org_id, wopia.organization_id);

   l_number_of_records := SQL%ROWCOUNT;
   if (l_debug = 1) then
      trace(l_proc || ' l_number_of_records => '|| l_number_of_records);
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' End of insert into wms_op_plan_instance_hist ...');
   end if;

   -- @@@ Insert records from the wms_op_opertn_instances_archive into wms_op_opertn_instance_hist
   if (l_debug = 1) then
      trace(l_proc || ' Start of insert into wms_op_opertn_instances_hist ...');
   end if;

   insert into wms_op_opertn_instances_hist(
    OPERATION_INSTANCE_ID
   ,OP_PLAN_INSTANCE_ID
   ,ORGANIZATION_ID
   ,OPERATION_STATUS
   ,OPERATION_PLAN_DETAIL_ID
   ,OPERATION_SEQUENCE
   ,FROM_SUBINVENTORY_CODE
   ,FROM_LOCATOR_ID
   ,TO_SUBINVENTORY_CODE
   ,TO_LOCATOR_ID
   ,CREATED_BY
   ,CREATION_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATE_LOGIN
   ,ATTRIBUTE_CATEGORY
   ,ATTRIBUTE1
   ,ATTRIBUTE2
   ,ATTRIBUTE3
   ,ATTRIBUTE4
   ,ATTRIBUTE5
   ,ATTRIBUTE6
   ,ATTRIBUTE7
   ,ATTRIBUTE8
   ,ATTRIBUTE9
   ,ATTRIBUTE10
   ,ATTRIBUTE11
   ,ATTRIBUTE12
   ,ATTRIBUTE13
   ,ATTRIBUTE14
   ,ATTRIBUTE15
   ,OPERATION_TYPE_ID
   ,ACTIVITY_TYPE_ID
   ,SUG_TO_SUB_CODE
   ,SUG_TO_LOCATOR_ID
   ,SOURCE_TASK_ID
   ,EMPLOYEE_ID
   ,EQUIPMENT_ID
   ,ACTIVATE_TIME
   ,COMPLETE_TIME
   ,IS_IN_INVENTORY)
   select
    OPERATION_INSTANCE_ID
   --,OPERATION_TYPE
   ,OP_PLAN_INSTANCE_ID
   ,ORGANIZATION_ID
   ,OPERATION_STATUS
   ,OPERATION_PLAN_DETAIL_ID
   ,OPERATION_SEQUENCE
   --,LPN_ID
   --,FROM_ZONE_ID
   ,FROM_SUBINVENTORY_CODE
   ,FROM_LOCATOR_ID
   --,TO_ZONE_ID
   ,TO_SUBINVENTORY_CODE
   ,TO_LOCATOR_ID
   ,CREATED_BY
   ,CREATION_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATE_LOGIN
   ,ATTRIBUTE_CATEGORY
   ,ATTRIBUTE1
   ,ATTRIBUTE2
   ,ATTRIBUTE3
   ,ATTRIBUTE4
   ,ATTRIBUTE5
   ,ATTRIBUTE6
   ,ATTRIBUTE7
   ,ATTRIBUTE8
   ,ATTRIBUTE9
   ,ATTRIBUTE10
   ,ATTRIBUTE11
   ,ATTRIBUTE12
   ,ATTRIBUTE13
   ,ATTRIBUTE14
   ,ATTRIBUTE15
   ,OPERATION_TYPE_ID
   ,ACTIVITY_TYPE_ID
   ,SUG_TO_SUB_CODE
   ,SUG_TO_LOCATOR_ID
   ,SOURCE_TASK_ID
   ,EMPLOYEE_ID
   ,EQUIPMENT_ID
   ,ACTIVATE_TIME
   ,COMPLETE_TIME
   ,IS_IN_INVENTORY
   from wms_op_opertn_instances_arch wooia
   where wooia.last_update_date > l_min_date
   and wooia.last_update_date <= l_max_date
   and wooia.organization_id = nvl(p_org_id, wooia.organization_id);

   l_number_of_records := SQL%ROWCOUNT;
   if (l_debug = 1) then
      trace(l_proc || ' l_number_of_records => '|| l_number_of_records);
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' End of insert into wms_op_opertn_instances_hist ...');
   end if;

   -- @@@ Delete Section
   -- @@@ Delete records from wms_dispatched_tasks_arch table.
   if (l_debug = 1) then
      trace(l_proc || ' Start of delete from wms_dispatched_tasks_arch ...');
   end if;

   delete from wms_dispatched_tasks_arch wdta
   where wdta.last_update_date > l_min_date
   and wdta.last_update_date <= l_max_date
   and wdta.organization_id = nvl(p_org_id, wdta.organization_id);

   l_number_of_records := SQL%ROWCOUNT;
   if (l_debug = 1) then
      trace(l_proc || ' l_number_of_records => '|| l_number_of_records);
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' End of delete from wms_dispatched_tasks_arch ...');
   end if;

   -- @@@ Delete records from the wms_op_plan_instances_arch table.
   if (l_debug = 1) then
      trace(l_proc || ' Start of delete from wms_op_plan_instances_arch ...');
   end if;

   delete from wms_op_plan_instances_arch wopia
   where wopia.last_update_date > l_min_date
   and wopia.last_update_date <= l_max_date
   and wopia.organization_id = nvl(p_org_id, wopia.organization_id);

   l_number_of_records := SQL%ROWCOUNT;
   if (l_debug = 1) then
      trace(l_proc || ' l_number_of_records => '|| l_number_of_records);
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' End of delete from wms_op_plan_instances_arch ...');
   end if;

   -- @@@ Delete records from the wms_op_opertn_instances_hist table
   if (l_debug = 1) then
      trace(l_proc || ' Start of delete from wms_op_opertn_instances_arch ...');
   end if;

   delete from wms_op_opertn_instances_arch wooia
   where wooia.last_update_date > l_min_date
   and wooia.last_update_date <= l_max_date
   and wooia.organization_id = nvl(p_org_id, wooia.organization_id);

   l_number_of_records := SQL%ROWCOUNT;
   if (l_debug = 1) then
      trace(l_proc || ' l_number_of_records => '|| l_number_of_records);
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' End of delete from wms_op_opertn_instances_arch ...');
   end if;

    x_retcode  := 0;
    x_errbuf   := 'Success';
exception
   when fnd_api.g_exc_error then
        if (l_debug = 1) then
           trace(l_proc || ' fnd_api.g_exc_error :' || sqlcode);
           trace(l_proc || ' fnd_api.g_exc_error :' || substr(sqlerrm, 1, 100));
        end if;

        rollback to unarch_task_worker_savepoint;

        x_retcode  := 2;
        x_errbuf   := 'Error';
   when others then
        if (l_debug = 1) then
           trace(l_proc || ' Others error :' || sqlcode);
           trace(l_proc || ' Others error :' || substr(sqlerrm, 1, 100));
        end if;

        rollback to unarch_task_worker_savepoint;

        x_retcode  := 2;
        x_errbuf   := 'Error';

end unarchive_tasks_worker;
--
--
end wms_archive_pvt;

/
