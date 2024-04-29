--------------------------------------------------------
--  DDL for Package Body FA_UPGHARNESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_UPGHARNESS_PKG" as
/* $Header: FAHAUPGB.pls 120.13.12010000.4 2009/08/23 20:03:50 glchen ship $   */

TYPE WorkerList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

Procedure submit_request(p_program      IN  VARCHAR2,
                         p_description  IN  VARCHAR2,
                         p_workers_num  IN  NUMBER,
                         p_worker_id    IN  NUMBER,
                         p_batch_size   IN  NUMBER,
                         x_req_id       OUT NOCOPY NUMBER);

Procedure verify_status(
      p_worker           IN  WorkerList,
      p_workers_num      IN  NUMBER,
      x_child_success    OUT NOCOPY VARCHAR2);

Procedure fa_master_upg (
  errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_workers_num  IN  NUMBER,
  p_batch_size   IN  NUMBER
) IS

  l_worker          WorkerList;

  l_worker_id       number;
  l_workers_num     number;
  l_batch_size      number;

  l_table_owner     varchar2(30);
  l_status          varchar2(1);
  l_industry        varchar2(1);

  l_child_success             VARCHAR2(1);
  l_errors                    NUMBER;

  l_batch_id         number(15);
  l_evt_script_name  varchar2(30) := 'faevt';
  l_evd_script_name  varchar2(30) := 'faevd';

  l_already_running  number;
  l_existing_error   number;

  nothing_to_run     EXCEPTION;
  already_running    EXCEPTION;
  existing_error     EXCEPTION;

begin

   l_batch_size := nvl(p_batch_size, 1000);
   l_workers_num := nvl(p_workers_num, 1);

   if (l_workers_num > 99) then
      errbuf := 'Too many workers';

      retcode := 1;
      return;
   end if;

   if (l_workers_num < 1) then
    raise nothing_to_run;
   end if;

   -- Fix for Bug #8797839.  Need to check if upgrade is already running
   -- or is in error for some existing book.
   select count(*)
   into   l_already_running
   from   fa_deprn_periods
   where  substr(xla_conversion_status, 1, 1) in
             ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9');

   if (l_already_running > 0) then
      raise already_running;
   end if;

   select count(*)
   into   l_existing_error
   from   fa_deprn_periods
   where  substr(xla_conversion_status, 1, 1) = 'E';

   if (l_already_running > 0) then
      raise existing_error;
   end if;

   update fa_deprn_periods dp
   set    dp.xla_conversion_status = 'H'
   where dp.xla_conversion_status is not null
   and   dp.xla_conversion_status not like 'U%'
   and   exists
   (
    select 'x'
    from   gl_period_statuses ps,
           fa_book_controls bc
    where  ps.application_id = 101
    and    ps.migration_status_code in ('P', 'U')
    and    bc.set_of_books_id = ps.set_of_books_id
    and    dp.book_type_code = bc.book_type_code
    and    dp.period_name = ps.period_name
   );

   for i in 1..l_workers_num loop

      l_worker_id := i;

      submit_request(p_program     => 'FAXLAUPGCP',
                     p_description => 'FA XLA Upgrade On Demand',
                     p_workers_num => l_workers_num,
                     p_worker_id   => l_worker_id,
                     p_batch_size  => l_batch_size,
                     x_req_id      => l_worker(i));

   end loop;

   verify_status(p_worker        => l_worker,
                 p_workers_num   => l_workers_num,
                 x_child_success => l_child_success);

   -- If any subworkers have failed then raise an error
   if (l_child_success = 'N') THEN
      errbuf := 'Execution failed';

      retcode := 1;
      return;
   end if;

   fa_trx2_upg (
     errbuf         => errbuf,
     retcode        => retcode,
     p_worker_id    => 1,
     p_workers_num  => l_workers_num
   );

   l_worker.delete;

   for i in 1..l_workers_num loop

      l_worker_id := i;

      submit_request(p_program     => 'FAXLAUPGCP2',
                     p_description => 'FA XLA Upgrade On Demand',
                     p_workers_num => l_workers_num,
                     p_worker_id   => l_worker_id,
                     p_batch_size  => l_batch_size,
                     x_req_id      => l_worker(i));

   end loop;

   verify_status(p_worker        => l_worker,
                 p_workers_num   => l_workers_num,
                 x_child_success => l_child_success);

   -- If any subworkers have failed then raise an error
   if (l_child_success = 'N') THEN
      errbuf := 'Execution failed';

      retcode := 1;
      return;
   end if;

   fa_deprn2_upg (
      errbuf         => errbuf,
      retcode        => retcode,
      p_worker_id    => 1,
      p_workers_num  => l_workers_num
   );

   -- Check to see if all periods were upgraded successfully.
   select count(*)
   into   l_errors
   from   fa_deprn_periods
   where  nvl(xla_conversion_status, 'UA') not in ('UT', 'UD', 'UA', 'H');

   if (l_errors > 0) then

      errbuf := 'Execution failed';
      retcode := 1;

   else

      errbuf := 'Execution is successful';
      retcode := 0;

   end if;

exception
   when nothing_to_run then

      retcode := 0;
      errbuf := 'Number of workers = ' || to_char(p_workers_num) ||
                '.  Nothing to run.';

   when already_running then
      retcode := 1;
      errbuf := 'Upgrade is already running in another session.  Exiting.';

      raise;

   when existing_error then
      retcode := 1;
      errbuf := 'Upgrade has an error from a previous run.  Exiting.';

      raise;


end fa_master_upg;

Procedure upgrade_by_request (
  errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_workers_num  IN  NUMBER,
  p_worker_id    IN  NUMBER,
  p_batch_size   IN  NUMBER
) IS

  l_table_owner     varchar2(30);
  l_status          varchar2(1);
  l_industry        varchar2(1);

  l_batch_id         number(15);
  l_evt_script_name  varchar2(30) := 'faevt';
  l_evd_script_name  varchar2(30) := 'faevd';

BEGIN

   retcode := 0;
   errbuf := 'Execution is successful';

   if not (FND_INSTALLATION.get_app_info (
      application_short_name => 'OFA',
      status                 => l_status,
      industry               => l_industry,
      oracle_schema          => l_table_owner
   )) then
      retcode := 1;
      errbuf  := 'Unable to find schema name';
      return;
   end if;

   select xla_upg_batches_s.nextval
   into   l_batch_id
   from   dual;

   fa_trx_upg (
      errbuf         => errbuf,
      retcode        => retcode,
      p_script_name  => l_evt_script_name || to_char(l_batch_id),
      p_table_owner  => l_table_owner,
      p_worker_id    => p_worker_id,
      p_workers_num  => nvl(p_workers_num, 1),
      p_batch_size   => nvl(p_batch_size, 1000)
    );

end upgrade_by_request;

Procedure upgrade_by_request2 (
  errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_workers_num  IN  NUMBER,
  p_worker_id    IN  NUMBER,
  p_batch_size   IN  NUMBER
) IS

  l_table_owner     varchar2(30);
  l_status          varchar2(1);
  l_industry        varchar2(1);

  l_batch_id         number(15);
  l_evt_script_name  varchar2(30) := 'faevt';
  l_evd_script_name  varchar2(30) := 'faevd';

BEGIN

   retcode := 0;
   errbuf := 'Execution is successful';

   if not (FND_INSTALLATION.get_app_info (
      application_short_name => 'OFA',
      status                 => l_status,
      industry               => l_industry,
      oracle_schema          => l_table_owner
   )) then
      retcode := 1;
      errbuf  := 'Unable to find schema name';
      return;
   end if;

   select xla_upg_batches_s.nextval
   into   l_batch_id
   from   dual;

    fa_deprn_upg (
      errbuf         => errbuf,
      retcode        => retcode,
      p_script_name  => l_evd_script_name || to_char(l_batch_id),
      p_mode         => 'uptime',
      p_table_owner  => l_table_owner,
      p_worker_id    => p_worker_id,
      p_workers_num  => nvl(p_workers_num, 1),
      p_batch_size   => nvl(p_batch_size, 1000)
    );

   errbuf := 'Execution is successful';
   retcode := 0;

end upgrade_by_request2;

Procedure fa_trx_upg (
  errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_script_name  IN  VARCHAR2,
  p_table_owner  IN  VARCHAR2,
  p_worker_id    IN  NUMBER,
  p_workers_num  IN  NUMBER,
  p_batch_size   IN  NUMBER
) IS

   -- for parallelization
   l_batch_size      number;
   l_any_rows_to_process boolean;

   l_table_name1      varchar2(30) := 'FA_TRX_REFERENCES';
   l_table_name2      varchar2(30) := 'FA_TRANSACTION_HEADERS';

   l_start_rowid     rowid;
   l_end_rowid       rowid;
   l_rows_processed  number;

   l_group_books      number(15);

   l_success_count    number;
   l_failure_count    number;
   l_return_status    number;

   cursor c_periods is
   select bc.book_type_code, ps.period_name
   from   gl_period_statuses ps,
          fa_book_controls bc
   where  ps.application_id = 101
   and    ps.migration_status_code in ('P', 'U')
   and    bc.set_of_books_id = ps.set_of_books_id;

   type char_tbl_type is table of varchar2(150) index by binary_integer;

   l_book_type_code_tbl char_tbl_type;
   l_period_name_tbl    char_tbl_type;

begin

   l_batch_size := p_batch_size;

   ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           p_table_owner,
           l_table_name1,
           p_script_name,
           p_worker_id,
           p_workers_num,
           l_batch_size, 0);

   ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           l_batch_size,
           TRUE);

   WHILE (l_any_rows_to_process = TRUE) LOOP

      FA_SLA_EVENTS_UPG_PKG.Upgrade_Inv_Events (
         p_start_rowid      => l_start_rowid,
         p_end_rowid        => l_end_rowid,
         p_batch_size       => l_batch_size,
         x_success_count    => l_success_count,
         x_failure_count    => l_failure_count,
         x_return_status    => l_return_status
      );

      l_rows_processed := l_batch_size;

      ad_parallel_updates_pkg.processed_rowid_range(
          l_rows_processed,
          l_end_rowid);

      commit;

      --
      -- get new range of rowids
      --
      ad_parallel_updates_pkg.get_rowid_range(
         l_start_rowid,
         l_end_rowid,
         l_any_rows_to_process,
         l_batch_size,
         FALSE);

   END LOOP;

   COMMIT;

-----------------------------------------------------------------------

   select count(*)
   into   l_group_books
   from   fa_book_controls
   where  allow_group_deprn_flag = 'Y';

   ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           p_table_owner,
           l_table_name2,
           p_script_name,
           p_worker_id,
           p_workers_num,
           l_batch_size, 0);

   ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           l_batch_size,
           TRUE);

   WHILE (l_any_rows_to_process = TRUE) LOOP

      if (l_group_books > 0) then

         FA_SLA_EVENTS_UPG_PKG.Upgrade_Group_Trxn_Events (
            p_start_rowid      => l_start_rowid,
            p_end_rowid        => l_end_rowid,
            p_batch_size       => l_batch_size,
            x_success_count    => l_success_count,
            x_failure_count    => l_failure_count,
            x_return_status    => l_return_status
         );
      end if;

      FA_SLA_EVENTS_UPG_PKG.Upgrade_Trxn_Events (
         p_start_rowid      => l_start_rowid,
         p_end_rowid        => l_end_rowid,
         p_batch_size       => l_batch_size,
         x_success_count    => l_success_count,
         x_failure_count    => l_failure_count,
         x_return_status    => l_return_status
      );

      l_rows_processed := l_batch_size;

      ad_parallel_updates_pkg.processed_rowid_range(
          l_rows_processed,
          l_end_rowid);


      commit;

      --
      -- get new range of rowids
      --
      ad_parallel_updates_pkg.get_rowid_range(
         l_start_rowid,
         l_end_rowid,
         l_any_rows_to_process,
         l_batch_size,
         FALSE);

   END LOOP;

   COMMIT;

   open c_periods;
   loop

      fetch c_periods bulk collect
       into l_book_type_code_tbl,
            l_period_name_tbl
      limit 100;

      forall i in 1..l_book_type_code_tbl.count
         update fa_deprn_periods dp
         set    dp.xla_conversion_status =
                decode (substr(dp.xla_conversion_status, 1, 1),
                        'H', '1',
                        'E', '1',
                        'U', '1',
                        '0', to_char(to_number(dp.xla_conversion_status) + 1),
                        '1', to_char(to_number(dp.xla_conversion_status) + 1),
                        '2', to_char(to_number(dp.xla_conversion_status) + 1),
                        '3', to_char(to_number(dp.xla_conversion_status) + 1),
                        '4', to_char(to_number(dp.xla_conversion_status) + 1),
                        '5', to_char(to_number(dp.xla_conversion_status) + 1),
                        '6', to_char(to_number(dp.xla_conversion_status) + 1),
                        '7', to_char(to_number(dp.xla_conversion_status) + 1),
                        '8', to_char(to_number(dp.xla_conversion_status) + 1),
                        '9', to_char(to_number(dp.xla_conversion_status) + 1),
                        dp.xla_conversion_status)
         where  dp.book_type_code = l_book_type_code_tbl(i)
         and   dp.period_name = l_period_name_tbl(i)
         and   dp.xla_conversion_status is not null
         and   dp.xla_conversion_status not in ('UA', 'UT');

      COMMIT;

      exit when c_periods%notfound;
   end loop;
   close c_periods;

   errbuf := 'Execution is successful';
   retcode := 0;

end fa_trx_upg;

Procedure fa_trx2_upg (
  errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_worker_id    IN NUMBER,
  p_workers_num  IN NUMBER
) IS

begin

   -- We need to find the total number of workers, but we need this script
   -- to only run once, so exit if it is not the first worker.
   if (p_worker_id <> 1) then return; end if;

   -- If all of the workers completed successfully, mark the period as
   -- successful.
   update fa_deprn_periods dp
   set    dp.xla_conversion_status = 'UT'
   where  dp.xla_conversion_status = to_char (p_workers_num)
   and    exists
   (
    select 'x'
    from   gl_period_statuses ps,
           fa_book_controls bc
    where  ps.application_id = 101
    and    ps.migration_status_code in ('P', 'U')
    and    bc.set_of_books_id = ps.set_of_books_id
    and    dp.book_type_code = bc.book_type_code
    and    ps.period_name = dp.period_name
   );

   -- Mark as error any periods where the workers did not complete.
   update fa_deprn_periods dp
   set    dp.xla_conversion_status = 'ET'
   where  dp.xla_conversion_status <> to_char (p_workers_num)
   and    dp.xla_conversion_status not in ('UA', 'UT')
   and    dp.xla_conversion_status is not null
   and    exists
   (
    select 'x'
    from   gl_period_statuses ps,
           fa_book_controls bc
    where  ps.application_id = 101
    and    ps.migration_status_code in ('P', 'U')
    and    bc.set_of_books_id = ps.set_of_books_id
    and    dp.book_type_code = bc.book_type_code
    and    ps.period_name = dp.period_name
   );

   COMMIT;

   errbuf := 'Execution is successful';
   retcode := 0;

end fa_trx2_upg;

Procedure fa_deprn_upg (
  errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_script_name  IN  VARCHAR2,
  p_mode         IN  VARCHAR2,
  p_table_owner  IN  VARCHAR2,
  p_worker_id    IN  NUMBER,
  p_workers_num  IN  NUMBER,
  p_batch_size   IN  NUMBER
) IS

   l_batch_size      varchar2(30);
   l_any_rows_to_process boolean;

   l_table_name1      varchar2(30) := 'FA_DEPRN_SUMMARY';
   l_table_name2      varchar2(30) := 'FA_DEFERRED_DEPRN';

   l_start_rowid     rowid;
   l_end_rowid       rowid;
   l_rows_processed  number;

   l_group_books      number(15);
   l_deprn_run        number(15);

   l_success_count    number;
   l_failure_count    number;
   l_return_status    number;

   cursor c_periods is
   select bc.book_type_code, ps.period_name
   from   gl_period_statuses ps,
          fa_book_controls bc
   where  ps.application_id = 101
   and    ps.migration_status_code in ('P', 'U')
   and    bc.set_of_books_id = ps.set_of_books_id;

   type char_tbl_type is table of varchar2(150) index by binary_integer;

   l_book_type_code_tbl char_tbl_type;
   l_period_name_tbl    char_tbl_type;

begin

 l_batch_size := p_batch_size;

 if (p_mode = 'downtime') then

    select count(*)
    into   l_deprn_run
    from   fa_deprn_periods dp
    where  dp.period_close_date is null
    and    dp.deprn_run = 'Y'
    and    dp.xla_conversion_status is not null
    and    dp.xla_conversion_status not in ('UA', 'UD')
    and   exists
    (
     select 'x'
     from   gl_period_statuses ps,
            fa_book_controls bc
     where  ps.application_id = 101
     and    ps.migration_status_code in ('P', 'U')
     and    bc.set_of_books_id = ps.set_of_books_id
     and    dp.book_type_code = bc.book_type_code
     and    dp.period_name = ps.period_name
    );
 end if;

 if (p_mode <> 'downtime') or (l_deprn_run > 0) then

   -- for deprn table
   ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           p_table_owner,
           l_table_name1,
           p_script_name,
           p_worker_id,
           p_workers_num,
           l_batch_size, 0);

   ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           l_batch_size,
           TRUE);

   WHILE (l_any_rows_to_process = TRUE) LOOP

      FA_SLA_EVENTS_UPG_PKG.Upgrade_Deprn_Events (
         p_mode             => p_mode,
         p_start_rowid      => l_start_rowid,
         p_end_rowid        => l_end_rowid,
         p_batch_size       => l_batch_size,
         x_success_count    => l_success_count,
         x_failure_count    => l_failure_count,
         x_return_status    => l_return_status
      );

      l_rows_processed := l_batch_size;

      ad_parallel_updates_pkg.processed_rowid_range(
          l_rows_processed,
          l_end_rowid);

      commit;

      --
      -- get new range of rowids
      --
      ad_parallel_updates_pkg.get_rowid_range(
         l_start_rowid,
         l_end_rowid,
         l_any_rows_to_process,
         l_batch_size,
         FALSE);

   END LOOP;

   COMMIT;

 end if;

-----------------------------------------------------------------------

 -- Only run the deferred deprn upgrade in uptime, and run it single
 -- threaded
 if (p_mode <> 'downtime') and (p_worker_id = 1) then

   -- for deferred table
   ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           p_table_owner,
           l_table_name2,
           p_script_name,
           1,                   -- p_worker_id
           1,                   -- p_workers_num
           l_batch_size, 0);

   ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           l_batch_size,
           TRUE);

   WHILE (l_any_rows_to_process = TRUE) LOOP

      FA_SLA_EVENTS_UPG_PKG.Upgrade_Deferred_Events (
         p_start_rowid      => l_start_rowid,
         p_end_rowid        => l_end_rowid,
         p_batch_size       => l_batch_size,
         x_success_count    => l_success_count,
         x_failure_count    => l_failure_count,
         x_return_status    => l_return_status
      );

      l_rows_processed := l_batch_size;

      ad_parallel_updates_pkg.processed_rowid_range(
          l_rows_processed,
          l_end_rowid);

      commit;

      --
      -- get new range of rowids
      --
      ad_parallel_updates_pkg.get_rowid_range(
         l_start_rowid,
         l_end_rowid,
         l_any_rows_to_process,
         l_batch_size,
         FALSE);

   END LOOP;

   COMMIT;

 end if;

   if (p_mode = 'downtime') then

      update fa_deprn_periods dp
      set    dp.xla_conversion_status =
             decode (substr(dp.xla_conversion_status, 1, 1),
                     'U', '1',
                     'E', '1',
                     '0', to_char(to_number(dp.xla_conversion_status) + 1),
                     '1', to_char(to_number(dp.xla_conversion_status) + 1),
                     '2', to_char(to_number(dp.xla_conversion_status) + 1),
                     '3', to_char(to_number(dp.xla_conversion_status) + 1),
                     '4', to_char(to_number(dp.xla_conversion_status) + 1),
                     '5', to_char(to_number(dp.xla_conversion_status) + 1),
                     '6', to_char(to_number(dp.xla_conversion_status) + 1),
                     '7', to_char(to_number(dp.xla_conversion_status) + 1),
                     '8', to_char(to_number(dp.xla_conversion_status) + 1),
                     '9', to_char(to_number(dp.xla_conversion_status) + 1),
                     dp.xla_conversion_status)
      where dp.xla_conversion_status is not null
      and   dp.xla_conversion_status not in ('UA', 'UD', 'H')
      and   dp.period_close_date is null;

      COMMIT;

   else

      open c_periods;
      loop

         fetch c_periods bulk collect
          into l_book_type_code_tbl,
               l_period_name_tbl
         limit 100;

         forall i in 1..l_book_type_code_tbl.count
         update fa_deprn_periods dp
         set    dp.xla_conversion_status =
                decode (substr(dp.xla_conversion_status, 1, 1),
                        'U', '1',
                        'E', '1',
                        '0', to_char(to_number(dp.xla_conversion_status) + 1),
                        '1', to_char(to_number(dp.xla_conversion_status) + 1),
                        '2', to_char(to_number(dp.xla_conversion_status) + 1),
                        '3', to_char(to_number(dp.xla_conversion_status) + 1),
                        '4', to_char(to_number(dp.xla_conversion_status) + 1),
                        '5', to_char(to_number(dp.xla_conversion_status) + 1),
                        '6', to_char(to_number(dp.xla_conversion_status) + 1),
                        '7', to_char(to_number(dp.xla_conversion_status) + 1),
                        '8', to_char(to_number(dp.xla_conversion_status) + 1),
                        '9', to_char(to_number(dp.xla_conversion_status) + 1),
                        dp.xla_conversion_status)
         where dp.book_type_code = l_book_type_code_tbl(i)
         and   dp.period_name = l_period_name_tbl(i)
         and   dp.xla_conversion_status is not null
         and   dp.xla_conversion_status not in ('UA', 'UD', 'H');

         COMMIT;

         exit when c_periods%notfound;
      end loop;
      close c_periods;

   end if;

   errbuf := 'Execution is successful';
   retcode := 0;

end fa_deprn_upg;

Procedure fa_deprn2_upg (
  errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_worker_id    IN NUMBER,
  p_workers_num  IN NUMBER
) IS
  PROCEDURE check_period_status ( p_ledger_id   IN NUMBER
                                , p_period_name IN VARCHAR2
				, o_status_is_u OUT NOCOPY BOOLEAN
				, o_status_is_p OUT NOCOPY BOOLEAN
				, o_status_is_n OUT NOCOPY BOOLEAN
                                ) IS
	  l_u_count number;  -- processed
	  l_h_count  number;  -- still in status 'H', pending upgrade
	  l_e_count  number;  -- error status
	  l_n_count  number;  -- null status

	  cursor c_check_conv (cp_period_name in varchar2, cp_ledger_id in number) is
	     select distinct nvl(xla_conversion_status,'N') xla_conversion_status
	     from   fa_deprn_periods
	     where  period_name = cp_period_name
	      and    book_type_code in ( select book_type_code
					    from   fa_book_controls
					   where  set_of_books_id = cp_ledger_id )
	      order by xla_conversion_status
	    ;
  BEGIN
	  o_status_is_u := FALSE;
	  o_status_is_p := FALSE;
	  o_status_is_n := FALSE;

	  l_u_count := 0; /* processed */
	  l_h_count  := 0; /* pending for xla upgrade  */
	  l_e_count  := 0; /* E* statuses are errors */
	  l_n_count  := 0; /* null is 'N' */

	   for l_conv in c_check_conv (p_period_name,p_ledger_id ) loop
	     if l_conv.xla_conversion_status in ( 'UA','UD','UT') then
		l_u_count := l_u_count + 1;
	     elsif l_conv.xla_conversion_status = 'H' then
		l_h_count := l_h_count + 1;
	     elsif l_conv.xla_conversion_status = 'N' then
		l_n_count := l_n_count + 1;
	     else
		l_e_count := l_e_count + 1;
	     end if;
	   end loop;


	   if l_h_count = 0 and l_e_count = 0 AND l_n_count = 0 then
	      o_status_is_u := TRUE;
	      o_status_is_p := FALSE;
	      o_status_is_n := FALSE;
	   elsif l_h_count <> 0  and l_e_count = 0 AND l_n_count = 0 THEN /* not too sure, if this is P */
	      o_status_is_u := FALSE;
	      o_status_is_p := FALSE;
	      o_status_is_n := TRUE;
	   elsif l_h_count = 0 AND l_e_count = 0 AND l_n_count <> 0 THEN
	      o_status_is_u := FALSE;
	      o_status_is_p := FALSE;
	      o_status_is_n := TRUE;
	   ELSIF l_h_count <> 0 AND l_e_count = 0 AND l_n_count <> 0 THEN
              o_status_is_u := FALSE;
	      o_status_is_p := FALSE;
	      o_status_is_n := TRUE;
	   ELSIF  l_e_count <> 0 THEN
	      o_status_is_u := FALSE;
	      o_status_is_p := TRUE;
	      o_status_is_n := FALSE;
	   end if;
  EXCEPTION WHEN OTHERS THEN raise;
  END ;

  procedure sync_gl_period_statuses is
  begin
        -- Fix for Bug #5596250.  Need to update migration_status_code to null
        -- for any periods that do not exist.
        -- we can run this step any number of times without impacting upgrade
        -- for FA.
	--
	-- ledgers in gl not used by FA or periods not used by FA
	-- need to be set to 'U' from 'P'
         UPDATE gl_period_statuses ps
           SET ps.migration_status_code = 'U'
         WHERE ps.migration_status_code = 'P'
           AND ps.application_id = 101
           AND (ps.ledger_id, ps.period_name) not in
             (
                  SELECT DISTINCT fbc.set_of_books_id, fdp.period_name
                    FROM fa_deprn_periods fdp, fa_book_controls fbc
                   WHERE fdp.book_type_code = fbc.book_type_code
             );

        COMMIT;

       -- this routine ensures we have a clear idea of the status of
       -- gl ledger period that is associated with multiple books and takes
       -- into account the xla conversion status across all the fa books and periods.
       -- mainly, this code will aid debugging if customer reports issues via OWC.

        DECLARE
	   l_status_is_u boolean;
	   l_status_is_p boolean;
	   l_status_is_n boolean;

	   CURSOR c_periods IS
	     SELECT period_name, ledger_id
	     FROM   gl_period_statuses
	     WHERE  migration_status_code = 'P'
	       AND  application_id = 101
	      ORDER BY ledger_id, period_name
	      FOR UPDATE OF migration_status_code;

	BEGIN

           FOR l_per IN c_periods LOOP
	           l_status_is_u := false;
		   l_status_is_p := true;
		   l_status_is_n := false;

	           check_period_status ( p_ledger_id   => l_per.ledger_id
                                       , p_period_name => l_per.period_name
				       , o_status_is_u => l_status_is_u
				       , o_status_is_p => l_status_is_p
				       , o_status_is_n => l_status_is_n
                                );
		   IF (NOT l_status_is_u) AND (l_status_is_p) AND (NOT l_status_is_n) THEN

		      UPDATE gl_period_statuses
		      SET    migration_status_code = 'P'
		      WHERE CURRENT OF c_periods;

		   ELSIF (l_status_is_u) AND (NOT l_status_is_p) AND (NOT l_status_is_n) THEN

                      UPDATE gl_period_statuses
		      SET    migration_status_code = 'U'
		      WHERE CURRENT OF c_periods;

                   ELSIF  (NOT l_status_is_u) AND (NOT l_status_is_p) AND ( l_status_is_n) THEN

                      UPDATE gl_period_statuses
		      SET    migration_status_code = null /* this will be reset to P when hot patch is re-run */
		      WHERE CURRENT OF c_periods;

		   END IF;
	   END LOOP;
	EXCEPTION WHEN OTHERS THEN NULL;
	END;
        COMMIT;
  EXCEPTION WHEN OTHERS THEN
        raise;
  end;

begin

   -- We sync gl period status info before and after the
   -- main logic to ensure that we are on safe side....
   -- We have hit bugs with XLA HOT Patch...

   sync_gl_period_statuses;
   -- We need to find the total number of workers, but we need this script
   -- to only run once, so exit if it is not the first worker.

   if (p_worker_id <> 1) then return; end if;

   -- If all of the workers completed successfully, mark the period as
   -- successful.
   update fa_deprn_periods dp
   set    dp.xla_conversion_status = 'UA'
   where  dp.xla_conversion_status = to_char (p_workers_num)
   and    exists
   (
    select 'x'
    from   gl_period_statuses ps,
           fa_book_controls bc
    where  ps.application_id = 101
    and    ps.migration_status_code in ('P', 'U')
    and    bc.set_of_books_id = ps.set_of_books_id
    and    dp.book_type_code = bc.book_type_code
    and    ps.period_name = dp.period_name
   );

   COMMIT;

   -- Mark as error any periods where the workers did not complete.
   update fa_deprn_periods dp
   set    dp.xla_conversion_status = 'ED'
   where  dp.xla_conversion_status <> to_char (p_workers_num)
   and    dp.xla_conversion_status not in ('UA', 'UT', 'UD')
   and    dp.xla_conversion_status is not null
   and    exists
   (
    select 'x'
    from   gl_period_statuses ps,
           fa_book_controls bc
    where  ps.application_id = 101
    and    ps.migration_status_code in ('P', 'U')
    and    bc.set_of_books_id = ps.set_of_books_id
    and    dp.book_type_code = bc.book_type_code
    and    ps.period_name = dp.period_name
   );

   COMMIT;


   sync_gl_period_statuses;  /* we need this again to sync deprn periods with gl period statuses */

   errbuf := 'Execution is successful';
   retcode := 0;
EXCEPTION WHEN OTHERS THEN
   errbuf := SQLERRM;
   retcode := -1;
   /* force the routine to fail in the XLA hot patch when there are issues */
end fa_deprn2_upg;

Procedure submit_request(p_program      IN  VARCHAR2,
                         p_description  IN  VARCHAR2,
                         p_workers_num  IN  NUMBER,
                         p_worker_id    IN  NUMBER,
                         p_batch_size   IN  NUMBER,
                         x_req_id       OUT NOCOPY NUMBER)
is

begin

      x_req_id:= FND_REQUEST.SUBMIT_REQUEST
                     (application => 'OFA',
                      program     => p_program,
                      description => p_description,
                      start_time  => to_char(sysdate,'DD-MON-YY HH:MI:SS'),
                      sub_request => FALSE,
                      argument1   => p_workers_num,
                      argument2   => p_worker_id,
                      argument3   => p_batch_size);


end submit_request;

Procedure verify_status(
      p_worker           IN  WorkerList,
      p_workers_num      IN  NUMBER,
      x_child_success    OUT NOCOPY VARCHAR2
) IS

  l_result                    BOOLEAN;
  l_phase                     VARCHAR2(500) := NULL;
  l_req_status                VARCHAR2(500) := NULL;
  l_devphase                  VARCHAR2(500) := NULL;
  l_devstatus                 VARCHAR2(500) := NULL;
  l_message                   VARCHAR2(500) := NULL;
  l_child_notcomplete         BOOLEAN := TRUE;

  l_req_id                    NUMBER;

begin

  x_child_success := 'Y';

  while l_child_notcomplete loop

     dbms_lock.sleep(10);
     l_child_notcomplete := FALSE;
     commit;

     for i in 1..p_workers_num loop

       l_req_id := p_worker(i);

       if (FND_CONCURRENT.GET_REQUEST_STATUS
                                 (l_req_id,
                                  NULL,
                                  NULL,
                                  l_phase,
                                  l_req_status,
                                  l_devphase,
                                  l_devstatus,
                                  l_message)) THEN
         null;
       end if;

       commit;

       if (l_devphase <> 'COMPLETE') then
          l_child_notcomplete := TRUE;
       end if;

       if (l_devstatus = 'ERROR') THEN
          x_child_success := 'N';
       end if;

   end loop;
 end loop;

end verify_status;

END FA_UPGHARNESS_PKG;

/
