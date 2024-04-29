--------------------------------------------------------
--  DDL for Package Body PAYPLNK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAYPLNK" as
/* $Header: paylink.pkb 120.0.12010000.6 2010/02/18 06:45:54 sivanara ship $ */
--
--
-- GLOBAL DECLARATIONS
--
type varchar2_table2 is table of varchar2(240)
     index by binary_integer;
--
type varchar2_table80 is table of varchar2(80)
     index by binary_integer;
--
g_header_error                  boolean;
g_control_error                 boolean;
g_line_error                    boolean;
g_header_processing             boolean := FALSE;
g_process_mode                  varchar2(50);
g_user_status                   pay_batch_headers.batch_status%TYPE;
g_count                         binary_integer := 0;
--
g_line_id_tbl   hr_entry.number_table;
g_status_tbl    hr_entry.varchar2_table;
g_message_tbl   varchar2_table2;
--
g_control_count number :=0;
g_ctl_id_tbl    hr_entry.number_table;
g_ctl_stat_tbl  hr_entry.varchar2_table;
g_ctl_mess_tbl  varchar2_table2;
--
g_head_err_msg  pay_message_lines.line_text%TYPE     := null;
g_head_err_stat varchar(1) := null;
--
error_occurred                  exception;
--
cursor csr_all_lines (l_batch_id in number) is
       select *
       from   pay_batch_lines  bal
       where  bal.batch_id = l_batch_id
       order by bal.batch_line_id
       for update;
--
cursor csr_asg_lines (l_batch_id in number, l_asg_id in number) is
       select *
       from   pay_batch_lines  bal
       where  bal.assignment_id = l_asg_id
       and    bal.batch_id = l_batch_id
       and not exists
              (select null
               from   pay_batch_lines pbl
               where  pbl.batch_id = l_batch_id
               and    pbl.assignment_id = l_asg_id
               and    pbl.batch_line_status in ('T','E'))
       order by bal.batch_sequence,bal.batch_line_id
       for update;
--
cursor csr_all_controls (l_batch_id in number) is
       select *
       from   pay_batch_control_totals  bac
       where  bac.batch_id = l_batch_id
       and    bac.control_status <> 'T'
       for update;
--
cursor csr_header (l_batch_id in number) is
       select *
       from   pay_batch_headers  bah
       where  bah.batch_id = l_batch_id
       for update;
--
-- This was introduced to overcome the performace within the
-- validate_lines procedure.
--
cursor csr_bl_header (l_batch_id in number) is
       select *
       from   pay_batch_headers  bah
       where  bah.batch_id = l_batch_id;
--
cursor csr_status_chk (l_user_status in varchar2) is
       select 'x'
       from   hr_lookups  hlk
       where  hlk.lookup_type = 'BATCH_STATUS'
       and    sysdate between nvl(hlk.start_date_active,sysdate)
                      and     nvl(hlk.end_date_active,
                                  hr_general.end_of_time)
       and    hlk.enabled_flag = 'Y'
       and    hlk.lookup_code = upper(l_user_status);
--
g_header_record         csr_header%ROWTYPE;
g_control_record        csr_all_controls%ROWTYPE;
g_line_record           csr_all_lines%ROWTYPE;
--
-- FORWARD DECLARATIONS
--
procedure validate_header
(
p_batch_id              in number,
p_business_group_id     in number,
p_leg_header_check      in boolean
);
--
procedure validate_controls
(
p_batch_id      in number
);
--
--This is now included within the package header.
-- procedure validate_lines
-- (
-- p_process_mode          in varchar,
-- p_line_id_tbl           in out hr_entry.number_table,
-- p_status_tbl            in out hr_entry.varchar2_table,
-- p_message_tbl           in out varchar2_table2,
-- p_batch_id              in number,
-- p_business_group_id     in number
-- p_leg_line_check        in boolean
-- );
--
procedure purge_messages
(
p_batch_id              in number,
p_mode                  in varchar2
);
--
procedure insert_element_entry
(
p_link_id               in      number,
l_line_record           in out  nocopy csr_all_lines%ROWTYPE,
p_asg_act_id            in      number,
p_creator_type          in      varchar2,
p_absence_attendance_id in      number,
p_entry_values_count    in      number,
p_passed_inp_tbl        in      hr_entry.number_table,
p_passed_val_tbl        in      hr_entry.varchar2_table
);
--
procedure update_element_entry
(
p_update_mode           in      varchar2,
p_element_entry_id      in      number,
p_creator_type          in      varchar2,
p_creator_id            in      number,
p_allow_rollback        in      boolean,
p_asg_act_id            in      number,
l_line_record           in      csr_all_lines%ROWTYPE,
p_entry_values_count    in      number,
p_passed_inp_tbl        in      hr_entry.number_table,
p_passed_val_tbl        in      hr_entry.varchar2_table
);
--
-- -------------------------------------------------------------------------
-- Procedure to convert input values from internal format to display format.
-- -------------------------------------------------------------------------
function convert_internal_to_display
  (p_input_value     varchar2,
   p_uom_value       varchar2,
   p_lookup_type     varchar2,
   p_value_set_id    number,
   p_currency_code   varchar2)
   return varchar2 is
--
/*Changed size from 80 to 240, Modified for 9350651*/
   l_display_value   varchar2(240) := p_input_value;
   l_internal_value  varchar2(240) := p_input_value;
   l_dummy           varchar2(100);
   --
   cursor csr_valid_lookup
          (p_lookup_type varchar2,
           p_lookup_code varchar2) is
       select HL.meaning
         from hr_lookups HL
        where HL.lookup_type = p_lookup_type
          and HL.lookup_code = p_lookup_code;
--
begin
--
hr_utility.set_location('payplnk.convert_internal_to_display',10);
   if (p_lookup_type is not null and
       l_internal_value is not null) then
      --
      open csr_valid_lookup(p_lookup_type, l_internal_value);
      fetch csr_valid_lookup into l_display_value ;
      close csr_valid_lookup;
         hr_utility.set_location('payplnk.convert_internal_to_display',15);
      --
   elsif (p_value_set_id is not null and
          l_internal_value is not null) then
      --
      l_display_value := pay_input_values_pkg.decode_vset_value(
                           p_value_set_id, l_internal_value);
         hr_utility.set_location('payplnk.convert_internal_to_display',20);
      --
   else
      --
     hr_utility.set_location('payplnk.convert_internal_to_display',21);
      hr_chkfmt.changeformat (
         l_internal_value, 		/* the value to be formatted (out - display) */
         l_display_value, 	/* the formatted value on output (out - canonical) */
         p_uom_value,			/* the format to check */
         p_currency_code );
      --
               hr_utility.set_location('payplnk.convert_internal_to_display',25);
   end if;
   hr_utility.set_location('payplnk.convert_internal_to_display',30);
   --
   return l_display_value;
--
exception
   when others then
      hr_utility.set_message ('PAY','PAY_6306_INPUT_VALUE_FORMAT');
      hr_utility.set_message_token ('UNIT_OF_MEASURE', hr_general.decode_lookup ('UNITS', p_uom_value ));
      hr_utility.raise_error;
--
end convert_internal_to_display;
--
--
function get_upgrade_status
   (p_business_group_id number
   ,p_short_name        varchar2
   )return varchar2 is
   --
   l_status pay_upgrade_status.status%type;
   --
begin
   --
   pay_core_utils.get_upgrade_status(p_business_group_id,p_short_name,l_status);
   --
   return l_status;
   --
exception
   when others then
   --
   return 'E';
   --
end;
--
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- payplnk.run_process                                               --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- The main procedure caled from the SRS screen, from which the      --
 -- paylink process is triggered for a particular batch.              --
 -- The success status of the process, or not, as the case maybe,     --
 -- is returned back to the SRS screen.                               --
 -----------------------------------------------------------------------
--
procedure run_process
(
errbuf                  out     nocopy varchar2,
retcode                 out     nocopy number,
p_business_group_id     in      number,
p_batch_operation       in      varchar2,
p_batch_id              in      number
) is
--

--
-- LOCAL DECLARATIONS
--

l_dummy             varchar2(1) := null;
l_row_not_exists    boolean := FALSE;
--
l_bee_iv_upgrade  varchar2(1);
--
begin
 --
 -- Initialise variables.
 --
 g_header_error := false;
 g_control_error := false;
 g_line_error := false;
 g_count := 0;
 g_process_mode := p_batch_operation;
 g_header_processing := false;
 l_bee_iv_upgrade := get_upgrade_status(p_business_group_id,'BEE_IV_UPG');
 --
 --
 SAVEPOINT RP;
 --
 --
 --
 -- Check whether the upgrade process is in progress.
 --
 if l_bee_iv_upgrade = 'E' then
    hr_utility.set_message(800, 'HR_449106_BEE_UPGRADING');
    hr_utility.raise_error;
 end if;
 --
 -- Need a row in fnd_sessions if it does not exist (bug 372339).
 -- It may exist because next run_process may use same concurrent manager session
 -- (this will not be neccessary when hr_utility.fnd_insert will do the check for
 -- existing row before its insert).
 --
    begin
    select null
      into l_dummy
      from fnd_sessions
      where session_id = userenv('sessionid');
    exception
      when no_data_found then
        l_row_not_exists := TRUE;
    end;
    if l_row_not_exists then
      hr_utility.fnd_insert(sysdate);
    end if;
 --
 --
 -- Depending on the mode of operation requested the particular batch
 -- will be processed accordingly.
 --
 hr_utility.set_location('payplnk.run_process',5);
 --
 if      (p_batch_operation = 'VALIDATE' OR p_batch_operation = 'TRANSFER') then
      --
      -- validate the batch.
      --
 hr_utility.set_location('payplnk.run_process',6);
         --
         g_header_processing := TRUE;
         --
         payplnk.validate
         (
         p_business_group_id,
         p_batch_operation,
         p_batch_id
         );
         --
         set_header_status(p_business_group_id,p_batch_operation,p_batch_id);
         --
         g_header_processing := FALSE;
         --
         payplnk.g_payplnk_call := TRUE;
         --
 hr_utility.set_location('payplnk.run_process',7);
 --
--  elsif   p_batch_operation = 'TRANSFER' then
--       --
--       -- transfer the batch. NB The transfer procedure calls the
--       -- validate procedure to ensure the batch is valid before
--       -- tansferring the element entries into the appropriate
--       -- base tables.
--       --
--  hr_utility.set_location('payplnk.run_process',8);
--          payplnk.transfer
--          (
--          p_business_group_id,
--          p_batch_operation,
--          p_batch_id
--          );
--  hr_utility.set_location('payplnk.run_process',9);
 --
 elsif   p_batch_operation = 'PURGE' then
      --
      -- purge the batch. All records associated with the batch i.e.
      -- batch messages, controls, lines and header will be deleted
      -- from the temporary batch tables.
      --
 hr_utility.set_location('payplnk.run_process',10);
         payplnk.purge
         (
         p_batch_id
         );
 hr_utility.set_location('payplnk.run_process',11);
 --
 end if;
 --
 hr_utility.set_location('payplnk.run_process',15);
 --
 -- commit;
--
  errbuf  := null;
  retcode := 0;
 --
 --
exception
   when others then
      rollback to RP;
      errbuf  := sqlerrm;  /* return the unhandled error message.  */
      retcode := 2;        /* process failed, as an unhandled error
                           occurred.                               */
      if p_batch_operation <> 'PURGE' then
         hr_utility.set_message(800, 'HR_289718_BEE_HEADER_ERROR');
      end if;
      hr_utility.raise_error;
 --
end run_process;
--
------------------------------------------------------------------------
-- NAME                                                               --
-- payplnk.validate                                                   --
--                                                                    --
-- DESCRIPTION                                                        --
-- Given a batch id it will validate the batch and insert its         --
-- element entries into the necessary base tables.  Then depending on --
-- the mode of operation passed in i.e. VALIDATE or TRANSFER the      --
-- inserted element entries will either be ROLLED BACK or not.        --
------------------------------------------------------------------------
--
procedure validate
(
p_business_group_id     in      number,
p_batch_operation       in      varchar2,
p_batch_id              in      number
) is
--
-- LOCAL DECLARATIONS
--
l_error_count   binary_integer :=0;
l_line_match    boolean := false;
--
l_line_id_tbl   hr_entry.number_table;
l_status_tbl    hr_entry.varchar2_table;
l_message_tbl   varchar2_table2;
--
sql_curs        number;
rows_processed  integer;
statem          varchar2(256);
l_header_check  number;
l_leg_header_check      boolean := false;
l_line_check    number;
l_leg_line_check        boolean := false;
l_legislation_code      per_business_groups_perf.legislation_code%TYPE := null;
--
l_assignment_id pay_batch_lines.assignment_id%TYPE   := null;
l_error_text    pay_message_lines.line_text%TYPE     := null;
l_assignment_exists        varchar2(1) := null;
not_upper       boolean := false;
--
begin
--
 hr_utility.set_location('payplnk.validate',1);
--
 SAVEPOINT VL;
--
 hr_utility.set_location('payplnk.validate',5);
--
 select legislation_code
 into l_legislation_code
 from per_business_groups_perf
 where business_group_id = p_business_group_id;
--
--
-- Find out of legislative checks at header and lines to
-- be performed.
--
-- (i) legislative header check
--
 begin
   statem := 'BEGIN
           :header_check := pay_'||lower(l_legislation_code)||'_bee.header_check_supported; END;';
--
   sql_curs := dbms_sql.open_cursor;
--
   dbms_sql.parse(sql_curs,
                statem,
                dbms_sql.v7);
--
   dbms_sql.bind_variable(sql_curs, 'header_check', l_header_check);
--
   rows_processed := dbms_sql.execute(sql_curs);
--
   dbms_sql.variable_value(sql_curs, 'header_check', l_header_check);
--
   dbms_sql.close_cursor(sql_curs);
--
   if l_header_check = 0 then
      l_leg_header_check := TRUE;
   else
      l_leg_header_check := FALSE;
   end if;
--
--
 exception
   when others then
     l_leg_header_check := FALSE;
--
     if dbms_sql.is_open(sql_curs) then
        dbms_sql.close_cursor(sql_curs);
     end if;
--
 end;
--
-- This has been moved into the validate_lines.
-- -- (ii) legislative line check
-- --
--  begin
--    statem := 'BEGIN
--            :line_check := pay_'||lower(l_legislation_code)||'_bee.line_check_supported; END;';
-- --
--    sql_curs := dbms_sql.open_cursor;
-- --
--    dbms_sql.parse(sql_curs,
--                   statem,
--                   dbms_sql.v7);
-- --
--    dbms_sql.bind_variable(sql_curs, 'line_check', l_line_check);
-- --
--    rows_processed := dbms_sql.execute(sql_curs);
-- --
--    dbms_sql.variable_value(sql_curs, 'line_check', l_line_check);
-- --
--    dbms_sql.close_cursor(sql_curs);
-- --
--    if l_line_check = 0 then
--       l_leg_line_check := TRUE;
--    else
--       l_leg_line_check := FALSE;
--    end if;
-- --
--  exception
--    when others then
--      l_leg_line_check := FALSE;
-- --
--      if dbms_sql.is_open(sql_curs) then
--         dbms_sql.close_cursor(sql_curs);
--      end if;
-- --
--  end;
--
-- Validates the batch header details held in pay_batch_headers.
--
 validate_header (
 p_batch_id,
 p_business_group_id,
 l_leg_header_check
 );
--
-- Only when the batch header details have been validated successfully
-- are the associated controls validated and checked against any
-- user defined control checks for the particular batch.
--
 if g_header_error = true then
    raise error_occurred;
 else
    open csr_all_controls(p_batch_id);
    fetch csr_all_controls into g_control_record;
    if csr_all_controls%FOUND then
       close csr_all_controls;
       validate_controls (
       p_batch_id
       );
    elsif csr_all_controls%NOTFOUND then
       close csr_all_controls;
    end if;
  end if;
--
  hr_utility.set_location('payplnk.validate',10);
--
-- Any updates made to the batch header and control statuses, and
-- and messages resulting from the header and control checks will be
-- committed.
--
 -- commit;
--
-- Only if the header and control(s) have been validated successfully will
-- the associated lines be validated.
--
 if g_control_error = true then
    raise error_occurred;
 else
    open csr_all_lines(p_batch_id);
    fetch csr_all_lines into g_line_record;
    if csr_all_lines%FOUND then
       close csr_all_lines;
-- Validate Batch lines will be called further below as a
-- multithreaded process.
--       validate_lines (
--       l_line_id_tbl,
--       l_status_tbl,
--       l_message_tbl,
--       p_batch_id,
--       p_business_group_id,
--       l_leg_line_check );
    else
       close csr_all_lines;
       -- Bug 3186708: No longer raises error if no lines exists.
       -- raise error_occurred;
    end if;
  end if;
--
  hr_utility.set_location('payplnk.validate',15);
-- The following is comment out due to multithreading.
-- --
-- -- Successfully validated line(s) may as a result have created
-- -- element entrie(s) in the base tables, therefore the entries must be
-- -- ROLLED BACK as the requested batch operation was 'VALIDATE'.
-- --
--  if p_batch_operation = 'VALIDATE' then
--     rollback;
-- --
-- -- Else the batch operation was 'TRANSFER'. Check if atleast one
-- -- error occurred during lines validation.
-- --
--  elsif (p_batch_operation = 'TRANSFER') and (g_line_error = true) then
--     rollback;
-- -- Safe now to reset the batch status from 'P' to original.
--         update pay_batch_headers  bah
--         set    bah.batch_status = decode(upper(g_user_status),
--                                          'W','V',
--                                          upper(g_user_status))
--         where bah.batch_id = p_batch_id;
--  else
--     commit;
--  end if;
-- --
--  hr_utility.set_location('payplnk.validate',20);
-- --
-- -- Any messages accumulated during batch lines validation are now
-- -- inserted into the pay_message_lines table.
-- --
--  begin
--    for l_error_count in 1..g_count loop
--       if l_message_tbl(l_error_count) is not null then
-- --
--         insert into pay_message_lines
--         (LINE_SEQUENCE,
--         PAYROLL_ID,
--         MESSAGE_LEVEL,
--         SOURCE_ID,
--         SOURCE_TYPE,
--         LINE_TEXT)
--         values (
--         pay_message_lines_s.nextval,
--         null,
--         l_status_tbl(l_error_count),
--         l_line_id_tbl(l_error_count),
--         'L',
--         l_message_tbl(l_error_count));
--       end if;
--    end loop;
-- --
--  exception
--    when no_data_found then
--    null;
--  end;
-- --
--  hr_utility.set_location('payplnk.validate',25);
-- --
-- -- The status of each batch line is set according to the outcome
-- -- of the validation carried out for the particular line.
-- --
--    for g_line_record in csr_all_lines(p_batch_id) loop
--    begin
--      for l_error_count in 1..g_count loop
--      if (g_line_record.batch_line_id = l_line_id_tbl(l_error_count)) then
-- --
--         update pay_batch_lines  bal
--         set    bal.batch_line_status =
--                    decode(l_status_tbl(l_error_count),'F','E','V')
--         where  current of csr_all_lines;
-- --
--         l_line_match := true;
-- --
--         if (l_status_tbl(l_error_count) = 'F') then
--            exit;
--         end if;
--       end if;
--      end loop;
-- --
--    exception
--      when no_data_found then
--      null;
--    end;
-- --
--    hr_utility.set_location('payplnk.validate',30);
-- --
--    if  l_line_match = false then
-- --
--        update pay_batch_lines  bal
--        set    bal.batch_line_status = 'V'
--        where  current of csr_all_lines;
--    else
--        l_line_match := false;
--    end if;
--  end loop;
-- --
-- End of the code blocked for multithreading.
 hr_utility.set_location('payplnk.validate',35);
--
  for g_line_record in csr_all_lines(p_batch_id) loop
      --
      if g_line_record.effective_date is null then
           hr_utility.set_message(801,'HR_7449_PLK_COLUMN_NULL');
           hr_utility.set_message_token('COLUMN_NAME','EFFECTIVE DATE');
           l_error_text := substrb(hr_utility.get_message, 1, 240);
           --
           insert into pay_message_lines
           (LINE_SEQUENCE,
           PAYROLL_ID,
           MESSAGE_LEVEL,
           SOURCE_ID,
           SOURCE_TYPE,
           LINE_TEXT)
           values (
           pay_message_lines_s.nextval,
           null,
           'F',
           g_line_record.batch_line_id,
           'L',
           l_error_text);
           --
           update pay_batch_lines
           set    batch_line_status = 'E'
           where current of csr_all_lines;
      else
         --
         -- If only an assignment number has been entered, ensure it is valid.
         --
         if (g_line_record.assignment_id is null)  and
            (g_line_record.assignment_number is not null) then
           begin
             select asg.assignment_id
             into   l_assignment_id
             from   per_assignments_f  asg
             where  asg.assignment_number =
                    g_line_record.assignment_number
             and    g_line_record.effective_date between asg.effective_start_date
                                     and     asg.effective_end_date
             and    asg.business_group_id + 0 = p_business_group_id;
             --
             g_line_record.assignment_id := l_assignment_id;
             not_upper := false;
             --
             update pay_batch_lines
             set assignment_id = l_assignment_id
             where current of csr_all_lines;
             --
           exception
             when no_data_found then
               not_upper := true;
               --
             when too_many_rows then
               --
               hr_utility.set_message(801,'HR_7449_PLK_COLUMN_NULL');
               hr_utility.set_message_token('COLUMN_NAME','ASSIGNMENT ID');
               l_error_text := substrb(hr_utility.get_message, 1, 240);
               --
               insert into pay_message_lines
               (LINE_SEQUENCE,
               PAYROLL_ID,
               MESSAGE_LEVEL,
               SOURCE_ID,
               SOURCE_TYPE,
               LINE_TEXT)
               values (
               pay_message_lines_s.nextval,
               null,
               'F',
               g_line_record.batch_line_id,
               'L',
               l_error_text);
               --
               update pay_batch_lines
               set    batch_line_status = 'E'
               where current of csr_all_lines;
               --
           end;
           -- If upper case is not found, try again for mixed case
           --
           begin
             if(not_upper = true) then
                  select asg.assignment_id
                  into l_assignment_id
                  from per_assignments_f asg
                  where upper(asg.assignment_number) =
                        upper(g_line_record.assignment_number)
                  and   g_line_record.effective_date between
                        asg.effective_start_date
                  and   asg.effective_end_date
                  and   asg.business_group_id = p_business_group_id;
                  --
                  update pay_batch_lines
                  set assignment_id = l_assignment_id
                  where current of csr_all_lines;
                  --
             end if;
             exception
                 when no_data_found then
                 --
                 hr_utility.set_message(801,'HR_7466_PLK_NOT_ELGBLE_ASS_NUM');
                 hr_utility.set_message_token('ASSIGNMENT_NUMBER',
                                         g_line_record.assignment_number);
                 l_error_text := substrb(hr_utility.get_message, 1, 240);
                 --
                 insert into pay_message_lines
                 (LINE_SEQUENCE,
                 PAYROLL_ID,
                 MESSAGE_LEVEL,
                 SOURCE_ID,
                 SOURCE_TYPE,
                 LINE_TEXT)
                 values (
                 pay_message_lines_s.nextval,
                 null,
                 'F',
                 g_line_record.batch_line_id,
                 'L',
                 l_error_text);
                 --
                 update pay_batch_lines
                 set    batch_line_status = 'E'
                 where current of csr_all_lines;
                 --
                 --
                 when too_many_rows then
                 --
                 hr_utility.set_message(801,'HR_7449_PLK_COLUMN_NULL');
                 hr_utility.set_message_token('COLUMN_NAME','ASSIGNMENT ID');
                 l_error_text := substrb(hr_utility.get_message, 1, 240);
                 --
                 insert into pay_message_lines
                 (LINE_SEQUENCE,
                 PAYROLL_ID,
                 MESSAGE_LEVEL,
                 SOURCE_ID,
                 SOURCE_TYPE,
                 LINE_TEXT)
                 values (
                 pay_message_lines_s.nextval,
                 null,
                 'F',
                 g_line_record.batch_line_id,
                 'L',
                 l_error_text);
                 --
                 update pay_batch_lines
                 set    batch_line_status = 'E'
                 where current of csr_all_lines;
                 --
           end;
           --
           hr_utility.set_location('payplnk.validate',40);
           --
        elsif (g_line_record.assignment_id is null) and
              (g_line_record.assignment_number is null) then
           --
           hr_utility.set_message(801,'HR_7482_PLK_BOTH_COLUMNS_NULL');
           hr_utility.set_message_token('COL1','ASSIGNMENT NUMBER');
           hr_utility.set_message_token('COL2','ASSIGNMENT ID');
           l_error_text := substrb(hr_utility.get_message, 1, 240);
           --
           insert into pay_message_lines
           (LINE_SEQUENCE,
           PAYROLL_ID,
           MESSAGE_LEVEL,
           SOURCE_ID,
           SOURCE_TYPE,
           LINE_TEXT)
           values (
           pay_message_lines_s.nextval,
           null,
           'F',
           g_line_record.batch_line_id,
           'L',
           l_error_text);
           --
           update pay_batch_lines
           set    batch_line_status = 'E'
           where current of csr_all_lines;
           --
           --
           hr_utility.set_location('payplnk.validate',45);
           --
        elsif (g_line_record.assignment_id is not null)     and
              (g_line_record.assignment_number is not null) then
           begin
             select 'x'
             into   l_assignment_exists
             from   per_assignments_f  asg
             where  asg.assignment_number =
                    g_line_record.assignment_number
             and    asg.assignment_id = g_line_record.assignment_id
             and    g_line_record.effective_date between asg.effective_start_date
                                     and     asg.effective_end_date
             and    asg.business_group_id + 0 = p_business_group_id;
             --
             not_upper := false;
             --
           exception
             when no_data_found then
             not_upper := true;
           end;
           --
           --
           --
           begin
             if(not_upper = true) then
                select 'x'
                into   l_assignment_exists
                from   per_assignments_f  asg
                where  upper(asg.assignment_number) =
                       upper(g_line_record.assignment_number)
                and    asg.assignment_id = g_line_record.assignment_id
                and    g_line_record.effective_date between asg.effective_start_date
                                     and     asg.effective_end_date
                and    asg.business_group_id +0 = p_business_group_id;
             end if;
           exception
             when no_data_found then
             --
             hr_utility.set_message(801,'HR_7479_PLK_INCONSISTENT_ASS');
             hr_utility.set_message_token('ASSIGNMENT_ID',
                                          g_line_record.assignment_id);
             hr_utility.set_message_token('ASSIGNMENT_NUMBER',
                                          g_line_record.assignment_number);
             l_error_text := substrb(hr_utility.get_message, 1, 240);
             --
             insert into pay_message_lines
             (LINE_SEQUENCE,
             PAYROLL_ID,
             MESSAGE_LEVEL,
             SOURCE_ID,
             SOURCE_TYPE,
             LINE_TEXT)
             values (
             pay_message_lines_s.nextval,
             null,
             'F',
             g_line_record.batch_line_id,
             'L',
             l_error_text);
             --
             update pay_batch_lines
             set    batch_line_status = 'E'
             where current of csr_all_lines;
             --
           end;
           --
           hr_utility.set_location('payplnk.validate',50);
           --
           -- If only an assignment id has been entered, ensure that it is valid.
           --
        else
           begin
             select 'x'
             into   l_assignment_exists
             from   per_assignments_f  asg
             where  asg.assignment_id = g_line_record.assignment_id
             and    g_line_record.effective_date between asg.effective_start_date
                                     and     asg.effective_end_date
             and    asg.business_group_id +0 = p_business_group_id;
             --
           exception
             when no_data_found then
             --
             hr_utility.set_message(801,'HR_7467_PLK_NOT_ELGBLE_ASS_ID');
             hr_utility.set_message_token('ASSIGNMENT_ID',
                                       g_line_record.assignment_id);
             l_error_text := substrb(hr_utility.get_message, 1, 240);
             --
             insert into pay_message_lines
             (LINE_SEQUENCE,
             PAYROLL_ID,
             MESSAGE_LEVEL,
             SOURCE_ID,
             SOURCE_TYPE,
             LINE_TEXT)
             values (
             pay_message_lines_s.nextval,
             null,
             'F',
             g_line_record.batch_line_id,
             'L',
             l_error_text);
             --
             update pay_batch_lines
             set    batch_line_status = 'E'
             where current of csr_all_lines;
             --
           end;
          --
        end if;
        --
        hr_utility.set_location('payplnk.validate',55);
        --
      end if;
      --
  end loop;
  --
  hr_utility.set_location('payplnk.validate',60);
  --
  -- COMMIT;
  --
  --
  hr_utility.set_location('payplnk.validate',85);
  --
exception
  when error_occurred then
  rollback to VL;
  raise;
  --
--
  when others then
  rollback to VL;
  raise;
--
end validate;
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- payplnk.set_status                                                --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Given a batch id and the mode of operation it will set the status --
 -- of the batch and control totals.                                  --
 -----------------------------------------------------------------------
--
procedure set_status
(
p_business_group_id     in      number,
p_batch_operation       in      varchar2,
p_batch_id              in      number
) is
--
l_errors_exists            varchar2(1) := null;
l_batch_status             pay_batch_headers.batch_status%TYPE := null;
l_status                   pay_batch_headers.batch_status%TYPE := null;
l_purge_after_transfer     pay_batch_headers.purge_after_transfer%TYPE := null;
--
cursor csr_error_lines is
  select 'Y'
  from   pay_batch_lines pbl
  where  pbl.batch_line_status = 'E'
  and    pbl.batch_id = p_batch_id;
--
cursor csr_error_totals is
  select 'Y'
  from   pay_batch_control_totals pct
  where  pct.control_status = 'E'
  and    pct.batch_id = p_batch_id;
--
cursor csr_error_header is
  select 'Y'
  from   pay_batch_headers pbh
  where  pbh.batch_status = 'E'
  and    pbh.batch_id = p_batch_id;
--
cursor csr_header_status is
  select pbh.batch_status,
         pbh.purge_after_transfer
  from   pay_batch_headers pbh
  where  pbh.batch_id = p_batch_id;
--
begin
--
 hr_utility.set_location('payplnk.set_status',5);
--
  SAVEPOINT SS;
  --
  g_line_error := false;
  g_control_error := false;
  g_header_error := false;
  --
  open csr_header_status;
  fetch csr_header_status into l_batch_status,l_purge_after_transfer;
  close csr_header_status;
  --
  -- Continue with this section only if the batch status is 'P'.
  if (l_batch_status <> 'P') then
     return;
  end if;
  --
  if (p_batch_operation = 'TRANSFER') then
     l_status := 'T';
  else
     l_status := 'V';
  end if;
  --
  open csr_error_lines;
  fetch csr_error_lines into l_errors_exists;
  if csr_error_lines%FOUND then
     g_line_error := true;
  end if;
  close csr_error_lines;
  --
  open csr_error_totals;
  fetch csr_error_totals into l_errors_exists;
  if csr_error_totals%FOUND then
     g_control_error := true;
  end if;
  close csr_error_totals;
  --
  open csr_error_header;
  fetch csr_error_header into l_errors_exists;
  if csr_error_header%FOUND then
     g_header_error := true;
  end if;
  close csr_error_header;
  --

  if (g_header_error = true) then
    hr_utility.trace('payplnk.set_status g_header_error = TRUE');
  else
    hr_utility.trace('payplnk.set_status g_header_error = FALSE');
  end if;

  if (g_control_error = true) then
    hr_utility.trace('payplnk.set_status g_control_error = TRUE');
  else
    hr_utility.trace('payplnk.set_status g_control_error = FALSE');
  end if;

  if (g_line_error = true) then
    hr_utility.trace('payplnk.set_status g_line_error = TRUE');
  else
    hr_utility.trace('payplnk.set_status g_line_error = FALSE');
  end if;
--
   if (p_batch_operation = 'VALIDATE' and g_header_error = false) then
--
         update pay_batch_headers
         set    batch_status = l_status
         where  batch_id = p_batch_id;
   else
--
-- If no errors were detected then continue i.e. purge/transfer records.
--
   if (g_header_error = false) and (g_control_error = false) then
-- Once the element entries have been committed check if the
-- PURGE_AFTER_TRANSFER flag is 'Y'.  If so delete all records associated
-- with the batch from the temporary batch tables.
--
      hr_utility.set_location('payplnk.set_status',11);
--
      if (g_line_error = false) and
         upper(l_purge_after_transfer) = 'Y' then
         hr_utility.set_location('payplnk.set_status',30);
         purge (
         p_batch_id
         );
--
      else
--
         hr_utility.set_location('payplnk.set_status',15);
--
         if g_control_error = false then
            for g_control_record in csr_all_controls(p_batch_id) loop
               update pay_batch_control_totals
               set    control_status = l_status
               where  current of csr_all_controls;
--
            end loop;
         end if;
--
         hr_utility.set_location('payplnk.set_status',20);
--
         update pay_batch_headers
         set    batch_status = l_status
         where  batch_id = p_batch_id;
--
         hr_utility.set_location('payplnk.set_status',25);
--
      end if;
--
      hr_utility.set_location('payplnk.set_status',30);
   end if;
--
   end if;
--
   hr_utility.set_location('payplnk.set_status',35);
--
exception
  when others then
  rollback to SS;
--
end set_status;
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- payplnk.set_line_status                                           --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Given a batch id and the mode of operation it will set the status --
 -- of the batch lines.                                               --
 -----------------------------------------------------------------------
--
procedure set_line_status
(
p_business_group_id     in      number,
p_batch_operation       in      varchar2,
p_batch_id              in      number,
p_asg_id                in      number
) is
--
l_batch_line_status        pay_batch_lines.batch_line_status%TYPE := null;
l_error_count              binary_integer :=0;
l_line_match               boolean := false;
--
--
begin
--
  hr_utility.set_location('payplnk.set_line_status',5);
  --
  -- Set the global parameter to disable the triggers.
  payplnk.g_payplnk_call := true;
  --
  SAVEPOINT SLS;
  --
  --
  if p_batch_operation = 'VALIDATE' then
     l_batch_line_status := 'V';
  elsif (p_batch_operation = 'TRANSFER') and (g_line_error = true) then
     l_batch_line_status := 'V';
  else
     l_batch_line_status := 'T';
  end if;
  --
  hr_utility.set_location('payplnk.set_line_status',10);
  --
  -- Any messages accumulated during batch lines validation are now
  -- inserted into the pay_message_lines table.
  --
  begin
    for l_error_count in 1..g_count loop
        if g_message_tbl(l_error_count) is not null then
          --
          insert into pay_message_lines
          (LINE_SEQUENCE,
          PAYROLL_ID,
          MESSAGE_LEVEL,
          SOURCE_ID,
          SOURCE_TYPE,
          LINE_TEXT)
          values (
          pay_message_lines_s.nextval,
          null,
          g_status_tbl(l_error_count),
          g_line_id_tbl(l_error_count),
          'L',
          g_message_tbl(l_error_count));
        end if;
    end loop;
  --
  exception
    when no_data_found then
    null;
  end;
  --
  hr_utility.set_location('payplnk.set_line_status',20);
  --
  -- The status of each batch line is set according to the outcome
  -- of the validation carried out for the particular line.
  --
  for g_line_record in csr_asg_lines(p_batch_id, p_asg_id) loop
    begin
    for l_error_count in 1..g_count loop
        if (g_line_record.batch_line_id = g_line_id_tbl(l_error_count)) then
          --
          update pay_batch_lines  bal
          set    bal.batch_line_status =
                     decode(l_batch_line_status,
                            'T',decode(g_status_tbl(l_error_count),'F','E','T'),
                            decode(g_status_tbl(l_error_count),'F','E','V'))
          where  current of csr_asg_lines;
          --
          l_line_match := true;
          --
          -- Bug 2854485
          -- There could be more than one message exists for a batch line.
          -- Hence, only skip the check if the status is fatal.
          --
          if g_status_tbl(l_error_count) = 'F' then
             exit;
          end if;
          --
        end if;
    end loop;
    --
    exception
       when no_data_found then
       null;
    end;
    --
    hr_utility.set_location('payplnk.set_line_status',30);
    --
    if  l_line_match = false then
    --
         update pay_batch_lines  bal
         set    bal.batch_line_status = l_batch_line_status
         where  current of csr_asg_lines;
    else
         l_line_match := false;
    end if;
  end loop;
  --
  -- Empty global messages.
  g_count := 0;
  g_line_error := false;
  g_line_id_tbl.delete;
  g_status_tbl.delete;
  g_message_tbl.delete;
  --
  -- Set the global parameter to enable the triggers.
  payplnk.g_payplnk_call := false;
  --
  --
  hr_utility.set_location('payplnk.set_line_status',35);
--
exception
  when others then
  rollback to SLS;
--
end set_line_status;
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- payplnk.set_header_status                                         --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Given a batch id and the mode of operation it will set the status --
 -- of the batch lines.                                               --
 -----------------------------------------------------------------------
--
procedure set_header_status
(
p_business_group_id     in      number,
p_batch_operation       in      varchar2,
p_batch_id              in      number
) is
--
l_error_count              binary_integer :=0;
l_line_match               boolean := false;
--
--
begin
--
  hr_utility.set_location('payplnk.set_header_status',5);
  --
  -- Set the global parameter to disable the triggers.
  payplnk.g_payplnk_call := true;
  --
  SAVEPOINT SHS;
  --
  if g_header_processing then
     --
     if g_head_err_msg is not null then
        insert into pay_message_lines
             (LINE_SEQUENCE,
             PAYROLL_ID,
             MESSAGE_LEVEL,
             SOURCE_ID,
             SOURCE_TYPE,
             LINE_TEXT)
             values (
             pay_message_lines_s.nextval,
             null,
             g_head_err_stat,
             p_batch_id,
             'H',
             g_head_err_msg);

        if g_head_err_stat = 'F' then
           update pay_batch_headers
              set batch_status = 'E'
           where batch_id = p_batch_id;
        end if;
     end if;
     --
     --
     hr_utility.set_location('payplnk.set_header_status',10);
     --
     -- Only update the status of the cotnrol totals if the batc his not failed.
     if g_head_err_stat <> 'F' or g_head_err_stat is null then
     --
     -- Any messages accumulated during batch lines validation are now
     -- inserted into the pay_message_lines table.
     --
     begin
       for l_error_count in 1..g_control_count loop
           if g_ctl_mess_tbl(l_error_count) is not null then
             --
             insert into pay_message_lines
             (LINE_SEQUENCE,
             PAYROLL_ID,
             MESSAGE_LEVEL,
             SOURCE_ID,
             SOURCE_TYPE,
             LINE_TEXT)
             values (
             pay_message_lines_s.nextval,
             null,
             g_ctl_stat_tbl(l_error_count),
             g_ctl_id_tbl(l_error_count),
             'C',
             g_ctl_mess_tbl(l_error_count));
           end if;
       end loop;
     --
     exception
       when no_data_found then
       null;
     end;
     --
     hr_utility.set_location('payplnk.set_header_status',20);
     --
     -- The status of each batch total is set according to the outcome
     -- of the validation carried out for the particular total.
     --
     for g_control_record in csr_all_controls(p_batch_id) loop
       begin
       for l_error_count in 1..g_control_count loop
           if (g_control_record.batch_control_id = g_ctl_id_tbl(l_error_count)) then
             --
             update pay_batch_control_totals  ctl
             set    ctl.control_status =
                        decode(g_ctl_stat_tbl(l_error_count),'F','E','V')
             where  current of csr_all_controls;
             --
             l_line_match := true;
             --
             exit;
             --
           end if;
       end loop;
       --
       exception
          when no_data_found then
          null;
       end;
       --
       hr_utility.set_location('payplnk.set_header_status',30);
       --
       if  l_line_match = false then
       --
            update pay_batch_control_totals  ctl
            set    ctl.control_status = 'V'
            where  current of csr_all_controls;
       else
            l_line_match := false;
       end if;
     end loop;
     --
     end if;
     --
  else
    --
    -- This will be called if the payroll action status being set. This will be
    -- either at the end or when there are too many errors while
    -- validating lines.
    --
    update pay_batch_control_totals
    set    control_status = decode(p_batch_operation,'TRANSFER','T','VALIDATE','V','P')
    where  batch_id = p_batch_id
    and    control_status = 'V'
    and    exists
           ( select null
             from   pay_batch_headers pbh
             where  pbh.batch_id = p_batch_id
             and    pbh.batch_status = 'P');
    --
    update pay_batch_headers
    set    batch_status = decode(p_batch_operation,'TRANSFER','T','VALIDATE','V','P')
    where  batch_id = p_batch_id
    and    batch_status = 'P';
    --
  end if;
  --
  -- Empty global messages.
  g_control_count := 0;
  g_control_error := false;
  g_ctl_id_tbl.delete;
  g_ctl_stat_tbl.delete;
  g_ctl_mess_tbl.delete;
  g_head_err_stat := null;
  g_head_err_msg := null;
  g_header_processing := false;
  --
  -- Set the global parameter to enable the triggers.
  payplnk.g_payplnk_call := false;
  --
  --
  hr_utility.set_location('payplnk.set_header_status',35);
--
exception
  when others then
  rollback to SHS;
--
end set_header_status;
--
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- payplnk.purge                                                     --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Given a batch id it will delete all records associated with the   --
 -- batch from all the temporary batch tables.  Any messages          --
 -- associated with the batch will also be deleted from the           --
 -- PAY_MESSAGE_LINES table.                                          --
 -----------------------------------------------------------------------
--
procedure purge
(
p_batch_id       in     number
) is
--
l_ovn number;
--
cursor csr_ovn is
select pbh.object_version_number
from   pay_batch_headers pbh
where  pbh.batch_id = p_batch_id;
--
begin
--
 SAVEPOINT PU;
 hr_utility.set_location('payplnk.purge',5);
--
 open csr_ovn;
 fetch csr_ovn into l_ovn;
 close csr_ovn;
 --
 -- Set the global parameter to enable the triggers.
 payplnk.g_payplnk_call := true;
 --
--
--
-- Calls the BEE API to delete the batch.
--
 PAY_BATCH_ELEMENT_ENTRY_API.delete_batch_header
     (p_batch_id                       => p_batch_id
     ,p_object_version_number          => l_ovn
     );
 --
 -- Set the global parameter to enable the triggers.
 payplnk.g_payplnk_call := false;
 --
--
 hr_utility.set_location('payplnk.purge',8);
--
--
/*
 purge_messages(p_batch_id,'Y');
--
 hr_utility.set_location('payplnk.purge',10);
--
 delete from pay_batch_control_totals
 where batch_id = p_batch_id;
--
 hr_utility.set_location('payplnk.purge',15);
--
 delete from pay_batch_lines
 where batch_id = p_batch_id;
--
 hr_utility.set_location('payplnk.purge',20);
--
 delete from pay_batch_headers
 where batch_id = p_batch_id;
--
 hr_utility.set_location('payplnk.purge',25);
--
*/
--
exception
  when others then
  rollback to PU;
  raise;
--
end purge;
--
 ----------------------------------------------------------------------
 -- NAME                                                             --
 -- payplnk.validate_header                       PRIVATE PROCEDURE  --
 --                                                                  --
 -- DESCRIPTION                                                      --
 -- Validates batch header details.  This includes the user defined  --
 -- checks for the header as well as the core validation checks      --
 -- carried out by the process. If and only if the header has been   --
 -- validated successfully do we continue onto the next stage of     --
 -- validation i.e. VALIDATE_CONTROLS.                               --
 ----------------------------------------------------------------------
--
procedure validate_header
(
p_batch_id              in number,
p_business_group_id     in number,
p_leg_header_check      in boolean
) is
--
-- LOCAL DECLARATIONS
--
l_transfer_recs   varchar2(1) := null;
l_process_recs    varchar2(1) := null;
l_column_name1    varchar2(30):= null;
l_usr_status_chk  varchar2(1) := null;
l_error_text    pay_message_lines.line_text%TYPE    := null;
l_user_status   pay_batch_headers.batch_status%TYPE := null;
l_user_message  pay_message_lines.line_text%TYPE    := null;
sql_curs        number;
rows_processed  integer;
statem          varchar2(256);
l_valid         number;
l_leg_message   pay_message_lines.line_text%TYPE    := null;
l_legislation_code per_business_groups_perf.legislation_code%TYPE := null;
--
column_is_null          exception;
invalid_value           exception;
user_error              exception;
core_error              exception;
nopackbody              exception;
pragma exception_init(nopackbody,-6508);
--
begin
--
 hr_utility.set_location('payplnk.validate_header',5);
--
 select legislation_code
 into l_legislation_code
 from per_business_groups_perf
 where business_group_id = p_business_group_id;
--
-- Delete any messages that may have resulted from an OLD operation
-- carried out on the batch.
--
 purge_messages(p_batch_id,'N');
--
 -- Initialize the global error message parameters.
 g_head_err_msg := null;
 g_head_err_stat := null;
 g_header_error := false;
--
 SAVEPOINT BH;
--
 -- commit;
--
 hr_utility.set_location('payplnk.validate_header',10);
--
-- Check if transferred record(s) exist in the batch, if so, terminate
-- validation with an appropriate message.
--
  begin
    select 'x'
    into   l_transfer_recs
    from   sys.dual
    where  exists
          (select null
           from   pay_batch_headers         bah
           ,      pay_batch_lines           bal
           ,      pay_batch_control_totals  bac
           where  bah.batch_id = bal.batch_id(+)
           and    bah.batch_id = bac.batch_id(+)
           and    bah.batch_id = p_batch_id
           and    ((bah.batch_status not in ('T','P')
                    and (bal.batch_line_status = 'T'
                         or bac.control_status = 'T'))));
  exception
  when no_data_found then
  null;
  end;
--
  hr_utility.set_location('payplnk.validate_header',15);
--
    if l_transfer_recs = 'x' then
--
-- Atleast one transferred record has been detected in the batch,
-- therefore the batch will not be validated. An appropriate error
-- message will be inserted into the PAY_MESSAGE_LINES table.
--
--
       hr_utility.set_message(801,'HR_7472_PLK_TRANSFERRED_RECS');
       hr_utility.set_message_token('BATCH_ID',p_batch_id);
       l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- p_batch_id,
       -- 'H',
       -- l_error_text);
       --
       g_head_err_msg := l_error_text;
       g_head_err_stat := 'F';
--
       raise core_error;
    end if;
--
    hr_utility.set_location('payplnk.validate_header',20);
--
-- The core validation checks will be carried out first.
-- Check the batch status is not already  PROCESSING.
--
    savepoint A;
    select batch_status into l_process_recs
    from pay_batch_headers
    where batch_id = p_batch_id
    for update;
    hr_utility.trace('batch_status ='||l_process_recs);
    hr_utility.trace('processing mode = '||g_process_mode);
--
--   IF batch is in processing state, lock out others processing.
   -- if(g_process_mode <> 'VALIDATE') then
      if(l_process_recs = 'P') then
          rollback to A;   -- release lock
            hr_utility.trace('batch is in processing state');
          hr_utility.set_message(801,'HR_MIX_289133_PROCESS_STATE');
          hr_utility.set_message_token('BATCH_ID',p_batch_id);
          l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- p_batch_id,
       -- 'H',
       -- l_error_text);
       --
       g_head_err_msg := l_error_text;
       g_head_err_stat := 'F';
--
          raise core_error;
      end if;
      update pay_batch_headers  bah
      set    bah.batch_status = 'P'
      where  bah.batch_id = p_batch_id;
      -- commit;
   -- else
      -- update pay_batch_headers  bah
      -- set    bah.batch_status = 'U'
      -- where  bah.batch_id = p_batch_id;
      -- commit;
   -- end if;
--
 hr_utility.set_location('payplnk.validate_header',25);
--
 update pay_batch_control_totals  bac
 set    bac.control_status = 'U'
 where  bac.batch_id = p_batch_id
 and    bac.control_status <> 'T';
--
 hr_utility.set_location('payplnk.validate_header',30);
--
 update pay_batch_lines  bal
 set    bal.batch_line_status = 'U'
 where  bal.batch_id = p_batch_id
 and    bal.batch_line_status <> 'T';
--
 -- commit;
--
 hr_utility.set_location('payplnk.validate_header',35);
--
 if l_process_recs <> 'T' then
 --
 open csr_header(p_batch_id);
 fetch csr_header into g_header_record;
--
-- Check that the correct business group id has be entered.
--
 if g_header_record.business_group_id <> p_business_group_id then
    l_column_name1 := 'BUSINESS GROUP ID';
--
    raise invalid_value;
--
-- Check that a value has been entered for the PURGE_AFTER_TRANSFER flag
--
 elsif g_header_record.purge_after_transfer is null then
    l_column_name1 := 'PURGE AFTER TRANSFER';
--
    raise column_is_null;
 end if;
--
-- Core checks have been validated successfully, hence
-- legislative hook checks (if any) and then user defined
-- checks for the header can now be carried out.
--
--
-- call legislative header check hook if required
--
 hr_utility.set_location('payplnk.validate_header',36);
 if p_leg_header_check = TRUE then
--
   begin
     statem := 'BEGIN
             pay_'||lower(l_legislation_code)||'_bee.validate_header(:batch_id, :valid, :leg_message); END;';
--
     sql_curs := dbms_sql.open_cursor;
--
     dbms_sql.parse(sql_curs,
                  statem,
                  dbms_sql.v7);
--
     dbms_sql.bind_variable(sql_curs, 'batch_id', p_batch_id);
     dbms_sql.bind_variable(sql_curs, 'valid', l_valid);
     dbms_sql.bind_variable(sql_curs, 'leg_message', l_leg_message, 240);
--
     rows_processed := dbms_sql.execute(sql_curs);
--
     dbms_sql.variable_value(sql_curs, 'valid', l_valid);
     dbms_sql.variable_value(sql_curs, 'leg_message', l_leg_message);
--
     dbms_sql.close_cursor(sql_curs);
--
   exception
     when others then
--
       if dbms_sql.is_open(sql_curs) then
          dbms_sql.close_cursor(sql_curs);
       end if;
--
       -- update pay_batch_headers  bah
       -- set    bah.batch_status = 'E'
       -- where  current of csr_header;
--
       hr_utility.set_message(801,'HR_7481_PLK_USR_CHECK_ERROR');
       hr_utility.set_message_token('USER_PROCEDURE',
                                    'the legislative batch header procedure');
       l_error_text := substrb((hr_utility.get_message||' '||sqlerrm),1,240);
--
 hr_utility.trace(sqlerrm);
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- p_batch_id,
       -- 'H',
       -- l_error_text);
       --
       g_head_err_msg := l_error_text;
       g_head_err_stat := 'F';
--
       raise user_error;
   end;
--
   if l_valid = 0 then
     -- update pay_batch_headers  bah
     -- set    bah.batch_status = 'E'
     -- where  current of csr_header;
--
     hr_utility.set_message(801,'HR_7469_PLK_USR_STATUS_INVLD');
     hr_utility.set_message_token('USER_PROCEDURE',
                                'the legislative batch header procedure');
     l_error_text := substrb((hr_utility.get_message||' '||l_leg_message),1,240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- p_batch_id,
       -- 'H',
       -- l_error_text);
       --
       g_head_err_msg := l_error_text;
       g_head_err_stat := 'F';
--
     raise user_error;
   end if;
--
 end if;
--
-- call user defined checks
--
 l_user_status := 'V';
 g_user_status := l_user_status;
--
 hr_utility.set_location('payplnk.validate_header',40);
--
 begin
  pay_user_check.validate_header (
  p_batch_id,
  l_user_status,
  l_user_message);
--
  hr_utility.set_location('payplnk.validate_header',45);
--
 exception
  when nopackbody then
--
-- The user defined checks could not be found.
--
  g_header_error := true;
--
  -- update pay_batch_headers  bah
  -- set    bah.batch_status = 'E'
  -- where  current of csr_header;
--
  hr_utility.set_message(801,'HR_7450_PLK_PACK_BODY_NOT_EXST');
  l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- p_batch_id,
       -- 'H',
       -- l_error_text);
       --
       g_head_err_msg := l_error_text;
       g_head_err_stat := 'F';
--
  raise user_error;
--
--
 when others then
--
   -- update pay_batch_headers  bah
   -- set    bah.batch_status = 'E'
   -- where  current of csr_header;
--
   hr_utility.set_message(801,'HR_7481_PLK_USR_CHECK_ERROR');
   hr_utility.set_message_token('USER_PROCEDURE',
                                'the user batch header procedure');
   l_error_text := substrb((hr_utility.get_message||' '||sqlerrm),1,240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- p_batch_id,
       -- 'H',
       -- l_error_text);
       --
       g_head_err_msg := l_error_text;
       g_head_err_stat := 'F';
--
   raise user_error;
 end;
--
 hr_utility.set_location('payplnk.validate_header',50);
--
-- If a status has not been returned raise an error.
--
  if l_user_status is null then
--
     -- update pay_batch_headers  bah
     -- set    bah.batch_status = 'E'
     -- where  current of csr_header;
--
     hr_utility.set_message(801,'HR_7468_PLK_USR_STATUS_NULL');
     hr_utility.set_message_token('USER_PROCEDURE',
                                  'the user batch header procedure');
     l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- p_batch_id,
       -- 'H',
       -- l_error_text);
       --
       g_head_err_msg := l_error_text;
       g_head_err_stat := 'F';
--
     raise user_error;
--
  else
     open csr_status_chk(l_user_status);
     fetch csr_status_chk into l_usr_status_chk;
--
       if csr_status_chk%NOTFOUND then
--
-- An invalid status has been returned, raise an error.
--
         -- update pay_batch_headers  bah
         -- set    bah.batch_status = 'E'
         -- where  current of csr_header;
         hr_utility.set_message(801,'HR_7469_PLK_USR_STATUS_INVLD');
         hr_utility.set_message_token('USER_PROCEDURE',
                                    'the user batch header procedure');
         l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- p_batch_id,
       -- 'H',
       -- l_error_text);
       --
       g_head_err_msg := l_error_text;
       g_head_err_stat := 'F';
--
         close csr_status_chk;
--
         raise user_error;
--
       elsif upper(l_user_status) in ('U','T') then
--
-- A status has been returned that is not valid in this context, raise
-- an error.
--
         -- update pay_batch_headers  bah
         -- set    bah.batch_status = 'E'
         -- where  current of csr_header;
--
         hr_utility.set_message(801,'HR_7470_PLK_USR_STATUS_INVLD_C');
         hr_utility.set_message_token('USER_PROCEDURE',
                                    'the user batch header procedure');
         l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- p_batch_id,
       -- 'H',
       -- l_error_text);
       --
       g_head_err_msg := l_error_text;
       g_head_err_stat := 'F';
--
         close csr_status_chk;
--
         raise user_error;
--
       else
--
-- A valid status has been returned from the user header procedure,
-- therefore set the header to the appropriate status and insert a message
-- into the PAY_MESSAGE_LINES table if one has been returned.
--
        close csr_status_chk;
--
-- REMOVED THE FOLLOWING. This is logic is done as set_status procedure.
-- If the process is in transfer mode, we really want to
-- retain the batch status for now to 'P' to lock another
-- submission of the batch submission inadvertantly.
--   if(g_process_mode = 'VALIDATE') then
--        update pay_batch_headers  bah
--        set    bah.batch_status = decode(upper(l_user_status),
--                                         'W','V',
--                                         upper(l_user_status))
--        where  current of csr_header;
--  end if;
--
   -- store user status globally.
       g_user_status := l_user_status;
--
        if l_user_message is not null then
--
        --    insert into pay_message_lines
        -- (LINE_SEQUENCE,
        -- PAYROLL_ID,
        -- MESSAGE_LEVEL,
        -- SOURCE_ID,
        -- SOURCE_TYPE,
        -- LINE_TEXT)
        --    values (
        --    pay_message_lines_s.nextval,
        --    null,
        --    decode(upper(l_user_status),'W','W','E','F','I'),
        --    p_batch_id,
        --    'H',
        --    l_user_message);
           g_head_err_msg := l_user_message;
           if upper(l_user_status) = 'W' then
              g_head_err_stat := 'W';
           elsif upper(l_user_status) = 'E' then
              g_head_err_stat := 'F';
           else
              g_head_err_stat := 'I';
           end if;
       end if;
--
       if upper(l_user_status) = 'E' then
          raise user_error;
       end if;
     end if;
  end if;
--
 close csr_header;
--
 end if;
 hr_utility.set_location('payplnk.validate_header',55);
--
exception
  when column_is_null then
--
-- A value was required.
--
  g_header_error := true;
--
  -- update pay_batch_headers  bah
  -- set    bah.batch_status = 'E'
  -- where  current of csr_header;
--
  hr_utility.set_message(801,'HR_7449_PLK_COLUMN_NULL');
  hr_utility.set_message_token('COLUMN_NAME',l_column_name1);
  l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- p_batch_id,
       -- 'H',
       -- l_error_text);
       --
       g_head_err_msg := l_error_text;
       g_head_err_stat := 'F';
--
  close csr_header;
--
--
  when invalid_value then
--
-- An invalid value was entered.
--
  g_header_error := true;
--
  -- update pay_batch_headers  bah
  -- set    bah.batch_status = 'E'
  -- where  current of csr_header;
--
  hr_utility.set_message(801,'HR_7462_PLK_INVLD_VALUE');
  hr_utility.set_message_token('COLUMN_NAME',l_column_name1);
  l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- p_batch_id,
       -- 'H',
       -- l_error_text);
       --
       g_head_err_msg := l_error_text;
       g_head_err_stat := 'F';
--
  close csr_header;
--
--
  when core_error or user_error then
--
-- A handled error occurred during header validation.
--
  g_header_error := true;
--
  if csr_header%ISOPEN then
     close csr_header;
  end if;
--
--
  when others then
  if csr_header%ISOPEN then
     close csr_header;
  end if;
  rollback to BH;
  raise;
--
end validate_header;
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- payplnk.validate_controls                       PRIVATE PROCEDURE --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Validate batch control(s) details.  This includes the user defined--
 -- checks for the control(s) as well as the core validation checks   --
 -- carried out by the process. If and only if the control(s) have    --
 -- been validated successfully do we continue onto the next stage of --
 -- validation i.e. VALIDATE_LINES.                                   --
 -----------------------------------------------------------------------
--
procedure validate_controls (
p_batch_id in number
) is
--
-- LOCAL DECLARATIONS
--
l_exists                varchar2(1)  :=null;
l_usr_status_chk        varchar2(1)  :=null;
l_column_name1          varchar2(30) :=null;
l_error_text            pay_message_lines.line_text%TYPE := null;
l_user_status           pay_batch_control_totals.control_status%TYPE   :=null;
l_user_message          pay_message_lines.line_text%TYPE :=null;
-- Additions for standard totalling functionality
l_std_status            pay_batch_control_totals.control_status%TYPE   :=null;
l_std_message           pay_message_lines.line_text%TYPE :=null;
--
column_is_null            exception;
invalid_value             exception;
user_control_error        exception;
control_types_not_defined exception;
--
begin
--
 SAVEPOINT BC;
--
g_control_error := false;
g_control_count := 0;
g_ctl_id_tbl.delete;
g_ctl_stat_tbl.delete;
g_ctl_mess_tbl.delete;
--
 hr_utility.set_location('payplnk.validate_controls',5);
--
-- Check to see if user defined control types exist.
--
 begin
  select 'x'
  into   l_exists
  from   sys.dual
  where  exists
         (select null
          from   hr_lookups  hlk
          where upper( hlk.lookup_type) = 'CONTROL_TYPE'
          and    sysdate between nvl(hlk.start_date_active,sysdate)
                         and nvl(hlk.end_date_active,
                                 hr_general.end_of_time)
          and    hlk.enabled_flag = 'Y');
--
 exception
   when no_data_found then
--
-- If control type(s) have not been defined then terminate batch control
-- validation with an appropriate error message.
--
   raise control_types_not_defined;
--
 end;
--
 hr_utility.set_location('payplnk.validate_controls',10);
--
-- Otherwise validate the batch control details.
--
 for g_control_record in csr_all_controls(p_batch_id) loop
-- Ensure that a valid control type has been entered.
--
   begin
     l_column_name1 := 'CONTROL TYPE';
--
     if g_control_record.control_type is null then
        raise column_is_null;
     else
        begin
          select 'x'
          into   l_exists
          from   hr_lookups  hlk
          where  hlk.lookup_type = 'CONTROL_TYPE'
          and    sysdate between nvl(hlk.start_date_active,
                                    sysdate)
                         and nvl(hlk.end_date_active,
                                hr_general.end_of_time)
          and    hlk.enabled_flag = 'Y'
          and    upper(g_control_record.control_type) in (hlk.lookup_code);
--
          hr_utility.set_location('payplnk.validate_controls',15);
--
        exception
        when no_data_found then
           raise invalid_value;
        end;
-- The core batch control checks were validated successfully, therefore
-- carry out the control checks for the particular control.
-- See if its a standard control check first. If not, pass on to be dealt
-- with by user check routine


-- next block carries out standard totalling checks. l_std_status is returned as
-- Warning, Error or Custom (W,E,C). A status of custom is returned when
-- control_type is not a standard control total and is therefore assumed
-- to have been added as a part of customization

         begin

           pay_standard_check.check_control(p_batch_id,
                                       g_control_record.control_type,
                                       g_control_record.control_total,
                                       l_std_status,l_std_message);


         exception
           when others then
             -- update pay_batch_control_totals bac
             -- set bac.control_status = 'E'
             -- where current of csr_all_controls;

           select hlk.meaning into l_std_message -- we already checked to see if this
           from hr_lookups hlk                   -- control type exists so we can select meaning
           where   hlk.lookup_type = 'CONTROL_TYPE'
           and     hlk.lookup_code = g_control_record.control_type;

           hr_utility.set_message(801,'HR_34854_ERROR_IN_STD_TOTALS');
           hr_utility.set_message_token('NAME_OF_ENTITY_TO_SUM',l_std_message);
           l_error_text:=rpad(hr_utility.get_message||' '||sqlerrm,255);

        --    insert into pay_message_lines
        -- (LINE_SEQUENCE,
        -- PAYROLL_ID,
        -- MESSAGE_LEVEL,
        -- SOURCE_ID,
        -- SOURCE_TYPE,
        -- LINE_TEXT)
        --      values (
        --        pay_message_lines_s.nextval,
        --        null,
        --        'F',
        --        g_control_record.batch_control_id,
        --        'C',
        --        l_error_text);
           g_control_count := g_control_count +1;
           g_ctl_id_tbl(g_control_count) := g_control_record.batch_control_id;
           g_ctl_stat_tbl(g_control_count) := 'F';
           g_ctl_mess_tbl(g_control_count) := l_error_text;


           raise user_control_error;
         end;


         if(l_std_status <> 'C') then --control was a standard one and has been
                                      -- processed by the above routine

--  update control status. Both V and W -> V in pay_batch_control_totals

           -- update pay_batch_control_totals bac
           -- set bac.control_status = decode(l_std_status,'W','V',l_std_status)
           -- where current of csr_all_controls;

           if(l_std_status <> 'V') then  -- control not valid. Could be 'E' or 'W'
                                         -- insert message and level of error

        --    insert into pay_message_lines
        -- (LINE_SEQUENCE,
        -- PAYROLL_ID,
        -- MESSAGE_LEVEL,
        -- SOURCE_ID,
        -- SOURCE_TYPE,
        -- LINE_TEXT)
        --    values (
        --        pay_message_lines_s.nextval,
        --        null,
        --        decode(l_std_status,'E','F',l_std_status),
        --        g_control_record.batch_control_id,
        --        'C',
        --        l_std_message);
        g_control_count := g_control_count +1;
        g_ctl_id_tbl(g_control_count) := g_control_record.batch_control_id;
        g_ctl_mess_tbl(g_control_count) := l_std_message;
        if l_std_status = 'E' then
           g_ctl_stat_tbl(g_control_count) := 'F';
        else
           g_ctl_stat_tbl(g_control_count) := l_std_status;
        end if;

           if(l_std_status = 'E') then
             raise user_control_error;
           end if;

           end if;


        else    -- pass control onto user control routine.

--
     l_user_status := 'V';
--
     begin
--
       pay_user_check.check_control (
       p_batch_id,
       g_control_record.control_type,
       g_control_record.control_total,
       l_user_status,
       l_user_message);
--
       hr_utility.set_location('payplnk.validate_controls',20);
--
     exception
--
-- If an unhandled error occurred during the user control validation
-- then raise an error.
--

       when others then
--
       -- update pay_batch_control_totals  bac
       -- set    bac.control_status = 'E'
       -- where  current of csr_all_controls;
--
       hr_utility.set_message(801,'HR_7481_PLK_USR_CHECK_ERROR');
       hr_utility.set_message_token('USER_PROCEDURE',
                                    'the user batch control procedure');
       l_error_text := substrb((hr_utility.get_message||' '||sqlerrm),1,240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- g_control_record.batch_control_id,
       -- 'C',
       -- l_error_text);
        g_control_count := g_control_count +1;
        g_ctl_id_tbl(g_control_count) := g_control_record.batch_control_id;
        g_ctl_mess_tbl(g_control_count) := l_error_text;
        g_ctl_stat_tbl(g_control_count) := 'F';
--
       raise user_control_error;
     end;
--
     hr_utility.set_location('payplnk.validate_controls',25);
--
-- If a status has not been returned raise an error.
--
       if l_user_status is null then
--
          -- update pay_batch_control_totals  bac
          -- set    bac.control_status = 'E'
          -- where  current of csr_all_controls;
--
          hr_utility.set_message(801,'HR_7468_PLK_USR_STATUS_NULL');
          hr_utility.set_message_token('USER_PROCEDURE',
                                       'the user batch control procedure');
          l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- g_control_record.batch_control_id,
       -- 'C',
       -- l_error_text);
        g_control_count := g_control_count +1;
        g_ctl_id_tbl(g_control_count) := g_control_record.batch_control_id;
        g_ctl_mess_tbl(g_control_count) := l_error_text;
        g_ctl_stat_tbl(g_control_count) := 'F';
--
          raise user_control_error;
--
       else
          open csr_status_chk(l_user_status);
          fetch csr_status_chk into l_usr_status_chk;
--
          if csr_status_chk%NOTFOUND then
-- An invalid status has been returned, raise an error.
--
            -- update pay_batch_control_totals  bac
            -- set    bac.control_status = 'E'
            -- where  current of csr_all_controls;
--
            hr_utility.set_message(801,'HR_7469_PLK_USR_STATUS_INVLD');
            hr_utility.set_message_token('USER_PROCEDURE',
                                         'the user batch control procedure');
            l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- g_control_record.batch_control_id,
       -- 'C',
       -- l_error_text);
        g_control_count := g_control_count +1;
        g_ctl_id_tbl(g_control_count) := g_control_record.batch_control_id;
        g_ctl_mess_tbl(g_control_count) := l_error_text;
        g_ctl_stat_tbl(g_control_count) := 'F';
--
            close csr_status_chk;
--
            raise user_control_error;
--
          elsif upper(l_user_status) in ('U','T') then
--
-- A status has been returned that is not valid in this context, raise
-- an error.
--
            -- update pay_batch_control_totals  bac
            -- set    bac.control_status = 'E'
            -- where  current of csr_all_controls;
--
            hr_utility.set_message(801,'HR_7470_PLK_USR_STATUS_INVLD_C');
            hr_utility.set_message_token('USER_PROCEDURE',
                                         'the user batch control procedure');
            l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- g_control_record.batch_control_id,
       -- 'C',
       -- l_error_text);
        g_control_count := g_control_count +1;
        g_ctl_id_tbl(g_control_count) := g_control_record.batch_control_id;
        g_ctl_mess_tbl(g_control_count) := l_error_text;
        g_ctl_stat_tbl(g_control_count) := 'F';
--
            close csr_status_chk;
--
            raise user_control_error;
          else
--
-- A valid status has been returned from the user control procedure,
-- therefore set the batch control to the appropriate status and insert
-- a message into the PAY_MESSAGE_LINES table if one has been returned.
--
            close csr_status_chk;
--
            -- update pay_batch_control_totals  bac
            -- set    bac.control_status = decode(upper(l_user_status),
            --                                    'W','V',
            --                                    upper(l_user_status))
            -- where current of csr_all_controls;
--
            if l_user_message is not null then
--
            -- insert into pay_message_lines
            --  (LINE_SEQUENCE,
            --  PAYROLL_ID,
            --  MESSAGE_LEVEL,
            --  SOURCE_ID,
            --  SOURCE_TYPE,
            --  LINE_TEXT)
            -- values (
            -- pay_message_lines_s.nextval,
            -- null,
            -- decode(upper(l_user_status),'W','W','E','F','I'),
            -- g_control_record.batch_control_id,
            -- 'C',
            -- l_user_message);
             g_control_count := g_control_count +1;
             g_ctl_id_tbl(g_control_count) := g_control_record.batch_control_id;
             g_ctl_mess_tbl(g_control_count) := l_user_message;
             if upper(l_user_status) = 'W' then
                g_ctl_stat_tbl(g_control_count) := 'W';
             elsif upper(l_user_status) = 'E' then
                g_ctl_stat_tbl(g_control_count) := 'F';
             else
                g_ctl_stat_tbl(g_control_count) := 'I';
             end if;
            end if;
--
            if upper(l_user_status) = 'E' then
               raise user_control_error;
            end if;
          end if;
       end if;
--
    end if;
--
    hr_utility.set_location('payplnk.validate_controls',30);

-- end section dealing with user defined controls as opposed to standard controls
   end if;
--
   exception
     when column_is_null then

--
-- A value was required.
--
     g_control_error := true;
--
     -- update pay_batch_control_totals  bac
     -- set    bac.control_status = 'E'
     -- where  current of csr_all_controls;
--
     hr_utility.set_message(801,'HR_7449_PLK_COLUMN_NULL');
     hr_utility.set_message_token('COLUMN_NAME',l_column_name1);
     l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- g_control_record.batch_control_id,
       -- 'C',
       -- l_error_text);
        g_control_count := g_control_count +1;
        g_ctl_id_tbl(g_control_count) := g_control_record.batch_control_id;
        g_ctl_mess_tbl(g_control_count) := l_error_text;
        g_ctl_stat_tbl(g_control_count) := 'F';
--
     when invalid_value then
--
-- An invalid value was entered.
--
     g_control_error := true;
--
     -- update pay_batch_control_totals  bac
     -- set    bac.control_status = 'E'
     -- where  current of csr_all_controls;
--
     hr_utility.set_message(801,'HR_7462_PLK_INVLD_VALUE');
     hr_utility.set_message_token('COLUMN_NAME',l_column_name1);
     l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- g_control_record.batch_control_id,
       -- 'C',
       -- l_error_text);
        g_control_count := g_control_count +1;
        g_ctl_id_tbl(g_control_count) := g_control_record.batch_control_id;
        g_ctl_mess_tbl(g_control_count) := l_error_text;
        g_ctl_stat_tbl(g_control_count) := 'F';
--
     when user_control_error then
--
     g_control_error := true;
--
  end;
 end loop;
--
 hr_utility.set_location('payplnk.validate_controls',35);
--
exception
--
  when control_types_not_defined then
--
  g_control_error := true;
--
  for g_control_record in csr_all_controls(p_batch_id) loop
--
    -- update pay_batch_control_totals  bac
    -- set    bac.control_status = 'E'
    -- where  current of csr_all_controls;
--
    hr_utility.set_message(801,'HR_7477_PLK_NO_CONTROL_TYPES');
    l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       -- insert into pay_message_lines
       --  (LINE_SEQUENCE,
       --  PAYROLL_ID,
       --  MESSAGE_LEVEL,
       --  SOURCE_ID,
       --  SOURCE_TYPE,
       --  LINE_TEXT)
       -- values (
       -- pay_message_lines_s.nextval,
       -- null,
       -- 'F',
       -- g_control_record.batch_control_id,
       -- 'C',
       -- l_error_text);
        g_control_count := g_control_count +1;
        g_ctl_id_tbl(g_control_count) := g_control_record.batch_control_id;
        g_ctl_mess_tbl(g_control_count) := l_error_text;
        g_ctl_stat_tbl(g_control_count) := 'F';
--
  end loop;
--
--
  when others then
  if csr_all_controls%ISOPEN then
     close csr_all_controls;
  end if;
  rollback to BC;
  raise;
--
end validate_controls;
--
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- payplnk.validate_lines                          PRIVATE PROCEDURE --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Validates batch line(s) details.  This includes the user defined  --
 -- checks for the line(s) as well as the core validation checks      --
 -- carried out by the process.  This is the final stage of batch     --
 -- validation.                                                       --
 -----------------------------------------------------------------------
--
procedure validate_lines (
p_asg_id                in number,
p_asg_act_id            in number,
p_process_mode          in varchar,
-- p_line_id_tbl           in out hr_entry.number_table,
-- p_status_tbl            in out hr_entry.varchar2_table,
-- p_message_tbl           in out varchar2_table2,
p_batch_id              in number,
p_business_group_id     in number
--p_leg_line_check        in boolean
) is
--
-- LOCAL DECLARATIONS
--
--
l_line_check    number;
l_leg_line_check        boolean := false;
--
l_input_id_exists               boolean := false;
l_reject_if_future_changes_chk  boolean := false;
l_action_if_exists_chk          boolean := false;
l_date_effective_changes_chk    boolean := false;
l_general_message               boolean := false;
--
l_element_exists                varchar2(1) := null;
l_assignment_exists             varchar2(1) := null;
l_usr_status_chk                varchar2(1) := null;
l_dummy                         varchar2(1) := null;
--
l_column_name1                  varchar2(30) := null;
l_column_name2                  varchar2(30) := null;
l_update_mode                   varchar2(30) := null;
l_effective_end_date1           date := null;
-- l_business_group_id             number := null;
not_upper                       boolean := false;
--
l_element_type_id          pay_batch_lines.element_type_id%TYPE :=null;
l_assignment_id            pay_batch_lines.assignment_id%TYPE   :=null;
l_element_name             pay_batch_lines.element_name%TYPE    :=null;
l_assignment_number        pay_batch_lines.assignment_number%TYPE :=null;
l_error_text               pay_message_lines.line_text%TYPE       :=null;
l_input_value_id           pay_input_values_f.input_value_id%TYPE :=null;
l_uom                      pay_input_values_f.uom%TYPE :=null;
l_input_curr_code          pay_element_types_f.input_currency_code%TYPE := null;
l_lookup_type              pay_input_values_f.lookup_type%TYPE :=null;
l_value_set_id             pay_input_values_f.value_set_id%TYPE :=null;
l_costable_type            pay_element_links_f.costable_type%TYPE :=null;
l_effective_end_date       pay_element_entries_f.effective_end_date%TYPE:=null;
l_effective_start_date     pay_element_entries_f.effective_start_date%TYPE:=null;
l_element_entry_id         pay_element_entries_f.element_entry_id%TYPE :=null;
e_creator_type             pay_element_entries_f.creator_type%TYPE :=null;
e_creator_id               pay_element_entries_f.creator_id%TYPE :=null;
l_multiple_entries_allowed
      pay_element_types_f.multiple_entries_allowed_flag%TYPE :=null;
l_processing_type          pay_element_types_f.processing_type%TYPE :=null;
l_cost_allocation_structure
      per_business_groups_perf.cost_allocation_structure%TYPE :=null;
l_legislation_code         per_business_groups_perf.legislation_code%TYPE := null;
l_link_id                  pay_element_links_f.element_link_id%TYPE :=null;
l_user_status              pay_batch_lines.batch_line_status%TYPE :=null;
l_user_message             pay_message_lines.line_text%TYPE       :=null;
--
absence_entry_already_created boolean := false;
l_absence_attendance_type_id number;
l_absence_attendance_id    number;
l_hours_or_days            varchar2(1);
l_eligible                 varchar2(1);
l_creator_type             varchar2(1);
-- l_absence_days             number;
-- l_absence_hours            number;
l_start_date               date;
l_end_date                 date;
sql_curs                   number;
rows_processed             integer;
statem                     varchar2(256);
l_valid                    number;
l_leg_message              pay_message_lines.line_text%TYPE    := null;
l_line_changed             number;
l_allow_rollback           boolean;
--
c_entry_values          number :=0;
i                       binary_integer :=0;
k                       binary_integer :=0;
l                       binary_integer :=0;
t                       binary_integer :=0;
--
--l_entry_value_tbl       varchar2_table80; for bug9350651
l_entry_value_tbl       varchar2_table2;
l_passed_val_tbl        hr_entry.varchar2_table;
--l_passed_val_tbl        varchar2_table2;
l_passed_inp_tbl        hr_entry.number_table;
l_inpv_uom_tbl          hr_entry.varchar2_table;
l_abs_type_tbl          hr_entry.number_table;
l_abs_hod_tbl           hr_entry.varchar2_table;
l_line_id_tbl           hr_entry.number_table;
l_status_tbl            hr_entry.varchar2_table;
l_message_tbl           varchar2_table2;
l_error_table   per_absence_attendances_pkg3.t_message_table;
l_warning_table per_absence_attendances_pkg3.t_message_table;
l_error_num     number;
l_warning_num   number;
--(bug 372339).
l_health_plan_benefit boolean := TRUE;
l_fnd_sessions_date     date;
l_commit                number;
--
column_is_null                  exception;
both_nulls                      exception;
invalid_entry_value             exception;
non_costable_element            exception;
multiple_entries_not_allowed    exception;
element_entry_exists            exception;
more_than_one_entry             exception;
future_changes_exist            exception;
inputs_not_required             exception;
element_entry_not_eligible      exception;
no_cost_allocation_structure    exception;
line_error_occurred             exception;
invalid_date_format             exception;
non_updatable_creator_type      exception;
--
l_header_err     boolean;
l_control_err    boolean;
l_err_exists     varchar2(1) := null;
--
cursor csr_error_header is
  select 'Y'
  from   pay_batch_headers pbh
  where  pbh.batch_status = 'E'
  and    pbh.batch_id = p_batch_id;
--
--
cursor csr_chk_asg_lines (l_batch_id in number, l_asg_id in number) is
       select 'Y'
       from   pay_batch_lines pbl
       where  pbl.batch_id = l_batch_id
       and    pbl.assignment_id = l_asg_id
       and    pbl.batch_line_status in ('T','E');
--
l_chk_asg_lines  varchar2(1);
--
--
cursor csr_error_totals is
  select 'Y'
  from   pay_batch_control_totals pct
  where  pct.control_status = 'E'
  and    pct.batch_id = p_batch_id;
--
cursor cur_max is
  select fnd_number.canonical_to_number(parameter_value)
    from pay_action_parameters
   where parameter_name = 'BEE_LOCK_MAX_WAIT_SEC';
--
cursor cur_intw is
  select fnd_number.canonical_to_number(parameter_value)
    from pay_action_parameters
   where parameter_name = 'BEE_LOCK_INTERVAL_WAIT_SEC';
--
cursor csr_table_inp_ids(
-- Business group id was taken out because input value inherits the bg from the element type.
--                       l_business_group_id           in  number,
                         l_element_type_id             in number,
                         l_effective_date              in date) is
       select inv.input_value_id,
              inv.uom,
              inv.lookup_type,
              inv.value_set_id,
              etp.input_currency_code
       from   pay_input_values_f  inv,
              pay_element_types_f etp
       where  inv.element_type_id   = l_element_type_id
       and    etp.element_type_id   = l_element_type_id
--       and    ((inv.business_group_id +0 = l_business_group_id) OR
--               ((inv.business_group_id IS NULL) AND
--                (l_business_group_id IS NULL)))
       and    l_effective_date between inv.effective_start_date
                               and     inv.effective_end_date
       and    l_effective_date between etp.effective_start_date
                               and     etp.effective_end_date
       order by inv.display_sequence
       ,        inv.name;
--
cursor csr_element_entries(l_link_id      in number,
                           l_effective_date  in date,
                           l_element_type_id in number,
                           l_assignment_id   in number) is
       select ee.element_entry_id
       ,      ee.creator_type
       ,      ee.creator_id
       ,      ee.effective_end_date
       ,      ee.effective_start_date
       from   pay_element_entries_f  ee
       ,      pay_element_types_f    et
       ,      pay_element_links_f    el
       ,      per_all_assignments_f  asg
       where  el.element_link_id = ee.element_link_id
       and    et.element_type_id = el.element_type_id
       and    ee.assignment_id   = asg.assignment_id
       and    l_effective_date  between ee.effective_start_date
                                and     ee.effective_end_date
       and    l_effective_date  between el.effective_start_date
                                and     el.effective_end_date
       and    l_effective_date  between et.effective_start_date
                                and     et.effective_end_date
       and    l_effective_date  between asg.effective_start_date
                                and     asg.effective_end_date
       and    el.element_link_id = l_link_id
       and    et.element_type_id = l_element_type_id
       and    asg.assignment_id  = l_assignment_id
       and    ee.entry_type = 'E';
--
cursor csr_future_existence(l_link_id                     in number,
                            l_effective_date  in date,
                            l_element_type_id in number,
                            l_assignment_id   in number) is
       select null
       from   pay_element_entries_f  ee
       ,      pay_element_types_f    et
       ,      pay_element_links_f    el
       ,      per_all_assignments_f  asg
       where  el.element_link_id = ee.element_link_id
       and    et.element_type_id = el.element_type_id
       and    ee.assignment_id = asg.assignment_id
       and    ee.effective_start_date > l_effective_date
       and    el.element_link_id =l_link_id
       and    et.element_type_id =l_element_type_id
       and    asg.assignment_id = l_assignment_id
       and    ee.entry_type = 'E';
--
cursor csr_attendance_types(l_business_group_id in number,
                            l_passed_inp_val in number,
                            l_passed_start_date in date,
                            l_passed_end_date in date) is
       select paat.absence_attendance_type_id
       ,      paat.hours_or_days
       from   per_absence_attendance_types paat
       where  paat.input_value_id = l_passed_inp_val
       and    paat.business_group_id +0 = l_business_group_id
       and    date_effective <= l_passed_start_date
       and    (nvl(date_end,hr_general.end_of_time) >= l_passed_end_date
              or l_passed_end_date is null);
--
  -- Bug 488335 - new declaration to avoid invalid parameter modes in
  -- Oracle 8.  Declare temporary line_record variable in order to
  -- preserve original, since we will call api with a new 'in out'
  -- parameter mode on line_record.
  g_line_record1 csr_asg_lines%ROWTYPE;
  g_line_record2 pay_batch_lines%ROWTYPE;
  --
  l_bee_iv_upgrade varchar2(1);
  --
begin
--
  hr_utility.set_location('payplnk.validate_lines',5);
  -- Added the following call as part of the fix to the bug#7138224.
  fnd_profile.put('PER_ASSIGNMENT_ID',p_asg_id);
--
--Only validate batch lines if there are no eerrors in batch header or control totals.
--
  l_control_err := false;
  l_header_err  := false;
  --
  open csr_error_totals;
  fetch csr_error_totals into l_err_exists;
  if csr_error_totals%FOUND then
     l_control_err := true;
  end if;
  close csr_error_totals;
  --
  open csr_error_header;
  fetch csr_error_header into l_err_exists;
  if csr_error_header%FOUND then
     l_header_err := true;
  end if;
  close csr_error_header;
  --
  if (p_asg_id is not null) then
     --
     open csr_chk_asg_lines(p_batch_id,p_asg_id);
     fetch csr_chk_asg_lines into l_chk_asg_lines;
     close csr_chk_asg_lines;
     --
  end if;
  --
  if (l_control_err = true or l_header_err = true or l_chk_asg_lines = 'Y') then
     return;
  end if;
--
-- Set the global parameter to disable the triggers.
  payplnk.g_payplnk_call := true;
--
-- Set the retry duration and maximum wait values if one hasn't assigned.
  if g_lock_max_wait is null then
     --
     -- Attempt to find out the BEE interlock max wait time
     -- and polling interval time from pay_action_parameters. If values
     -- cannot be found in this table then default to a max wait of 0
     -- seconds and polling interval of 0 seconds.
     --
     open cur_max;
     fetch cur_max into g_lock_max_wait;
     if cur_max %notfound then
       close cur_max;
       -- Value not in table, set to the default
       g_lock_max_wait := 0;
     else
       close cur_max;
     end if;
     --
     open cur_intw;
     fetch cur_intw into g_lock_interval;
     if cur_intw %notfound then
       close cur_intw;
       -- Value not in table, set to the default
       g_lock_interval := 0;
     else
       close cur_intw;
     end if;
     --
  end if;
--
  SAVEPOINT BL;
--
  l_bee_iv_upgrade := get_upgrade_status(p_business_group_id,'BEE_IV_UPG');
--
  --
  -- Check whether the upgrade process is in progress.
  --
  if l_bee_iv_upgrade = 'E' then
     hr_utility.set_message(800, 'HR_449106_BEE_UPGRADING');
     hr_utility.raise_error;
  end if;
--
  open csr_bl_header(p_batch_id);
  fetch csr_bl_header into g_header_record;
--
  -- Empty global messages.
  g_count := 0;
  g_line_error := false;
  g_line_id_tbl.delete;
  g_status_tbl.delete;
  g_message_tbl.delete;
--
--
-- Retrieve the cost allocation structure for the business group.
--
  select fnd_number.canonical_to_number(bsg.cost_allocation_structure)
  ,      bsg.legislation_code
  into   l_cost_allocation_structure
  ,      l_legislation_code
  from   per_business_groups_perf  bsg
  where  bsg.business_group_id = p_business_group_id
  and    bsg.enabled_flag = 'Y';
--
--
-- legislative line check
--
  begin
    statem := 'BEGIN
            :line_check := pay_'||lower(l_legislation_code)||'_bee.line_check_supported; END;';
--
    if pay_core_utils.get_sql_cursor(statem,sql_curs) then
--
       dbms_sql.bind_variable(sql_curs, 'line_check', l_line_check);
--
       rows_processed := dbms_sql.execute(sql_curs);
--
       dbms_sql.variable_value(sql_curs, 'line_check', l_line_check);
--
       if l_line_check = 0 then
          l_leg_line_check := TRUE;
       else
          l_leg_line_check := FALSE;
       end if;
--
    else
       raise error_occurred;
    end if;
--
  exception
    when others then
--
      l_leg_line_check := FALSE;
--
  end;
--
--
-- Retrieve the cost allocation structure for the business group.
--
--  select fnd_number.canonical_to_number(bsg.cost_allocation_structure)
--  ,      bsg.legislation_code
--  into   l_cost_allocation_structure
--  ,      l_legislation_code
--  from   per_business_groups  bsg
--  where  bsg.business_group_id = p_business_group_id
--  and    bsg.enabled_flag = 'Y';
--
-- Check whether inserting entries for the element with benefit classification
-- and for this classification there are defined contributions.
-- Entries will have to be validated against valid coverage types (bug 372339).
--
   open csr_asg_lines(p_batch_id, p_asg_id);
       fetch csr_asg_lines into g_line_record;
       begin
       select null
         into l_dummy
         from dual
         where exists(select null
                        from pay_element_types_f ET,
                             ben_benefit_classifications BCL
                        where ET.element_type_id = g_line_record.element_type_id
                           and ET.benefit_classification_id = BCL.benefit_classification_id
                           and BCL.contributions_used = 'Y');
       exception
         when no_data_found then
            l_health_plan_benefit := FALSE;
       end;
       l_fnd_sessions_date := sysdate;
   close csr_asg_lines;
--
--
-- Validate each batch line in turn.
--
    for g_line_record in csr_asg_lines(p_batch_id, p_asg_id) loop
    begin
--
-- Truncate effective date just in case and update the record (335670)
--
-- label for start of validation
-- used when legislative hook has changed line
   <<start_validation>>
     g_line_record.effective_date := TRUNC (g_line_record.effective_date);
--
     UPDATE pay_batch_lines
       SET  effective_date = g_line_record.effective_date
       WHERE CURRENT OF csr_asg_lines;
--
-- If element is a benefit and effective_date for this line is
-- different from the previous one then update the row in fnd_sessions.
-- This will ensure that the entry is validated against coverage_type as on the
-- date when entry will start (bug 372339).
--
   if l_health_plan_benefit and
      g_line_record.effective_date <> l_fnd_sessions_date then
        dt_fndate.change_ses_date(g_line_record.effective_date,l_commit);
        l_fnd_sessions_date := g_line_record.effective_date;
   end if;
--
--
-- Initialise variables
--
     l_general_message := false;
     l_input_id_exists := false;
     c_entry_values := 0;
     i :=0;
     k :=0;
     l :=0;
     t :=0;
     l_creator_type := 'H';
     l_absence_attendance_id := 0;
     absence_entry_already_created := false;
--
     hr_utility.set_location('payplnk.validate_lines',10);
-- Moving the following code into the validate procedure.
-- --
-- -- Carry out the core line validation checks.
-- --
--     l_column_name1 := 'EFFECTIVE DATE';
-- --
-- -- Ensure that an effective date has been entered.
-- --
--     if g_line_record.effective_date is null then
--        raise column_is_null;
--     end if;
--
-- Ensure that a valid element type id or element name has been entered.
--
    l_column_name1 := 'ELEMENT TYPE ID';
    l_column_name2 := 'ELEMENT NAME';
--
-- If only an element name has been entered, ensure that it is valid.
--
    if (g_line_record.element_type_id is null) and
       (g_line_record.element_name is not null) then
       begin
         select elt.element_type_id -- ,business_group_id -- CWA
         into   l_element_type_id   -- ,l_business_group_id -- CWA
         from   pay_element_types_f  elt
         where  upper(elt.element_name) = upper(g_line_record.element_name)
         and    g_line_record.effective_date between elt.effective_start_date
                                 and     elt.effective_end_date
         and    (elt.business_group_id = p_business_group_id
                 or (elt.business_group_id is null
                     and elt.legislation_code = l_legislation_code)
                 or (elt.business_group_id is null
                     and elt.legislation_code is null));
-- Included the assumption legislation code can be null.
--
         g_line_record.element_type_id := l_element_type_id;
--
         update pay_batch_lines
         set element_type_id = g_line_record.element_type_id
         where current of csr_asg_lines;
--
       exception
         when no_data_found then
         g_line_error := true;
         g_count := g_count + 1;
--
         hr_utility.set_message(801,'HR_7465_PLK_NOT_ELGBLE_ELE_NME');
         hr_utility.set_message_token('ELEMENT_NAME',
                                      g_line_record.element_name);
         l_error_text := substrb(hr_utility.get_message, 1, 240);
--
         l_line_id_tbl(g_count) := g_line_record.batch_line_id;
         l_status_tbl(g_count)  :='F';
         l_message_tbl(g_count) := l_error_text;
--
         raise line_error_occurred;
       end;
--
       hr_utility.set_location('payplnk.validate_lines',15);
--
-- If neither an element type id or element name has been entered,
-- raise error.
--
    elsif (g_line_record.element_type_id is null) and
          (g_line_record.element_name is null) then
         raise both_nulls;
--
-- If both element type id and element name has been entered ensure they
-- are consistent.
--
    elsif (g_line_record.element_type_id is not null) and
          (g_line_record.element_name is not null)    then
       begin
         select 'x'              -- ,business_group_id -- CWA
         into   l_element_exists -- ,l_business_group_id -- CWA
         from   pay_element_types_f  elt
         where  upper(elt.element_name) = upper(g_line_record.element_name)
         and    elt.element_type_id = g_line_record.element_type_id
         and    g_line_record.effective_date between elt.effective_start_date
                                 and     elt.effective_end_date
         and    (elt.business_group_id +0 = p_business_group_id
                 or (elt.business_group_id is null
                     and elt.legislation_code = l_legislation_code)
                 or (elt.business_group_id is null
                     and elt.legislation_code is null));
--
       exception
         when no_data_found then
         g_line_error := true;
         g_count := g_count + 1;
--
         hr_utility.set_message(801,'HR_7478_PLK_INCONSISTENT_ELE');
         hr_utility.set_message_token('ELEMENT_TYPE_ID',
                                      g_line_record.element_type_id);
         hr_utility.set_message_token('ELEMENT_NAME',
                                      g_line_record.element_name);
--
         l_error_text := substrb(hr_utility.get_message, 1, 240);
--
         l_line_id_tbl(g_count) := g_line_record.batch_line_id;
         l_status_tbl(g_count)  :='F';
         l_message_tbl(g_count) := l_error_text;
--
         raise line_error_occurred;
       end;
--
       hr_utility.set_location('payplnk.validate_lines',20);
--
-- If only an element type id has been entered, ensure it is valid.
--
    else
       begin
         select 'x'               -- ,business_group_id -- CWA
         into   l_element_exists  -- ,l_business_group_id -- CWA
         from   pay_element_types_f  elt
         where  elt.element_type_id = g_line_record.element_type_id
         and    g_line_record.effective_date between elt.effective_start_date
                                 and     elt.effective_end_date
         and    (elt.business_group_id +0 = p_business_group_id
                 or (elt.business_group_id is null
                     and elt.legislation_code = l_legislation_code)
                 or (elt.business_group_id is null
                     and elt.legislation_code is null));
--
       exception
         when no_data_found then
         g_line_error := true;
         g_count := g_count + 1;
--
         hr_utility.set_message(801,'HR_7464_PLK_NOT_ELGBLE_ELE_TYP');
         hr_utility.set_message_token('ELEMENT_TYPE_ID',
                                      g_line_record.element_type_id);
         l_error_text := substrb(hr_utility.get_message, 1, 240);
--
         l_line_id_tbl(g_count) := g_line_record.batch_line_id;
         l_status_tbl(g_count)  :='F';
         l_message_tbl(g_count) := l_error_text;
--
         raise line_error_occurred;
       end;
     end if;
--
     hr_utility.set_location('payplnk.validate_lines',25);
-- Moving the following code into the validate procedure.
-- --
-- -- Ensure valid assignment details have been entered.
-- --
--      l_column_name1 := 'ASSIGNMENT ID';
--      l_column_name2 := 'ASSIGNMENT NUMBER';
-- --
-- --
-- -- If only an assignment number has been entered, ensure it is valid.
-- --
--      if (g_line_record.assignment_id is null)  and
--         (g_line_record.assignment_number is not null) then
--        begin
--          select asg.assignment_id
--          into   l_assignment_id
--          from   per_assignments_f  asg
--          where  asg.assignment_number =
--                 g_line_record.assignment_number
--          and    g_line_record.effective_date between asg.effective_start_date
--                                  and     asg.effective_end_date
--          and    asg.business_group_id + 0 = p_business_group_id;
-- --
--          g_line_record.assignment_id := l_assignment_id;
--          not_upper := false;
-- --
--        exception
--          when no_data_found then
--            not_upper := true;
--        end;
-- -- If upper case is not found, try again for mixed case
-- --
--        begin
--          if(not_upper = true) then
--               select asg.assignment_id
--               into l_assignment_id
--               from per_assignments_f asg
--               where upper(asg.assignment_number) =
--                   (g_line_record.assignment_number)
--               and   g_line_record.effective_date between
--                     asg.effective_start_date
--               and   asg.effective_end_date
--               and   asg.business_group_id = p_business_group_id;
--          end if;
--          exception
--              when no_data_found then
--              g_line_error := true;
--              g_count := g_count +1;
-- --
--               hr_utility.set_message(801,'HR_7466_PLK_NOT_ELGBLE_ASS_NUM');
--               hr_utility.set_message_token('ASSIGNMENT_NUMBER',
--                                       g_line_record.assignment_number);
--               l_error_text := substrb(hr_utility.get_message, 1, 240);
-- --
--               l_line_id_tbl(g_count) := g_line_record.batch_line_id;
--               l_status_tbl(g_count)  :='F';
--               l_message_tbl(g_count) := l_error_text;
-- --
--          raise line_error_occurred;
--        end;
-- --
--        hr_utility.set_location('payplnk.validate_lines',30);
-- --
-- -- If both assignment id and assignment number are null, raise error.
-- --
--     elsif (g_line_record.assignment_id is null) and
--           (g_line_record.assignment_number is null) then
--          raise both_nulls;
-- --
-- -- If both assignment id and assignment number have been entered, ensure
-- -- that they are consistent.
-- --
-- --
--     elsif (g_line_record.assignment_id is not null)     and
--           (g_line_record.assignment_number is not null) then
--       begin
--         select 'x'
--         into   l_assignment_exists
--         from   per_assignments_f  asg
--         where  asg.assignment_number =
--                g_line_record.assignment_number
--         and    asg.assignment_id = g_line_record.assignment_id
--         and    g_line_record.effective_date between asg.effective_start_date
--                                 and     asg.effective_end_date
--         and    asg.business_group_id + 0 = p_business_group_id;
-- --
--         not_upper := false;
-- --
--       exception
--         when no_data_found then
--         not_upper := true;
--       end;
-- --
-- --
-- --
--       begin
--         if(not_upper = true) then
--            select 'x'
--            into   l_assignment_exists
--            from   per_assignments_f  asg
--            where  upper(asg.assignment_number) =
--                   upper(g_line_record.assignment_number)
--            and    asg.assignment_id = g_line_record.assignment_id
--            and    g_line_record.effective_date between asg.effective_start_date
--                                 and     asg.effective_end_date
--            and    asg.business_group_id +0 = p_business_group_id;
--       end if;
--       exception
--         when no_data_found then
--         g_line_error := true;
--         g_count := g_count + 1;
-- --
--         hr_utility.set_message(801,'HR_7479_PLK_INCONSISTENT_ASS');
--         hr_utility.set_message_token('ASSIGNMENT_ID',
--                                      g_line_record.assignment_id);
--         hr_utility.set_message_token('ASSIGNMENT_NUMBER',
--                                      g_line_record.assignment_number);
--         l_error_text := substrb(hr_utility.get_message, 1, 240);
-- --
--         l_line_id_tbl(g_count) := g_line_record.batch_line_id;
--         l_status_tbl(g_count)  :='F';
--         l_message_tbl(g_count) := l_error_text;
-- --
--         raise line_error_occurred;
--       end;
-- --
--       hr_utility.set_location('payplnk.validate_lines',35);
-- --
-- -- If only an assignment id has been entered, ensure that it is valid.
-- --
--     else
--       begin
--         select 'x'
--         into   l_assignment_exists
--         from   per_assignments_f  asg
--         where  asg.assignment_id = g_line_record.assignment_id
--         and    g_line_record.effective_date between asg.effective_start_date
--                                 and     asg.effective_end_date
--         and    asg.business_group_id +0 = p_business_group_id;
-- --
--       exception
--         when no_data_found then
--         g_line_error := true;
--         g_count := g_count + 1;
-- --
--         hr_utility.set_message(801,'HR_7467_PLK_NOT_ELGBLE_ASS_ID');
--         hr_utility.set_message_token('ASSIGNMENT_ID',
--                                      g_line_record.assignment_id);
--         l_error_text := substrb(hr_utility.get_message, 1, 240);
-- --
--         l_line_id_tbl(g_count) := g_line_record.batch_line_id;
--         l_status_tbl(g_count)  :='F';
--         l_message_tbl(g_count) := l_error_text;
-- --
--         raise line_error_occurred;
--       end;
--     end if;
--
    hr_utility.set_location('payplnk.validate_lines',40);
--
-- Validate the entry values, if entered.
--
    l_entry_value_tbl(1) := g_line_record.value_1;
    l_entry_value_tbl(2) := g_line_record.value_2;
    l_entry_value_tbl(3) := g_line_record.value_3;
    l_entry_value_tbl(4) := g_line_record.value_4;
    l_entry_value_tbl(5) := g_line_record.value_5;
    l_entry_value_tbl(6) := g_line_record.value_6;
    l_entry_value_tbl(7) := g_line_record.value_7;
    l_entry_value_tbl(8) := g_line_record.value_8;
    l_entry_value_tbl(9) := g_line_record.value_9;
    l_entry_value_tbl(10) := g_line_record.value_10;
    l_entry_value_tbl(11) := g_line_record.value_11;
    l_entry_value_tbl(12) := g_line_record.value_12;
    l_entry_value_tbl(13) := g_line_record.value_13;
    l_entry_value_tbl(14) := g_line_record.value_14;
    l_entry_value_tbl(15) := g_line_record.value_15;
--
-- If input values id(s) exist for the element type, pass it and its
-- corressponding entry value into a temporary PL/SQL table.
--
    open csr_table_inp_ids(
--                         p_business_group_id,
                           g_line_record.element_type_id,
                           g_line_record.effective_date);
    loop
      fetch csr_table_inp_ids into l_input_value_id, l_uom,
                                   l_lookup_type, l_value_set_id,
                                   l_input_curr_code;
      exit when csr_table_inp_ids%NOTFOUND;
--
      i := i+1;
      l_input_id_exists := true;
      l_passed_inp_tbl(i) := l_input_value_id;
      l_inpv_uom_tbl(i) := l_uom;
      l_abs_type_tbl(i) := 0;
      if l_entry_value_tbl(i) is not null then
         --
         -- Checks whether the upgrade has been performed.
         --
         if l_bee_iv_upgrade = 'N' THEN
         hr_utility.set_location('payplnk.validate_lines',41);
            --
            -- BEE now handles input value of date in canonical format.
            -- However the EE API expects the data in the DD-MON-YYYY format.
            -- The DD-MON-YYYY is the default format of the fnd_date.
            --
            if l_inpv_uom_tbl(i) = 'D' then
               begin
	         -- bug no. 3734946
                /* l_passed_val_tbl(i) := substrb(
                                          fnd_date.date_to_displaydate(
                                            fnd_date.canonical_to_date(l_entry_value_tbl(i))
                                          ),1,60); */

                 l_passed_val_tbl(i) :=   fnd_date.date_to_displaydate(
                                            fnd_date.canonical_to_date(l_entry_value_tbl(i)));
               exception
                 when others then
                    close csr_table_inp_ids;
                    raise invalid_date_format;
               end;
            else
               -- bug no. 3734946
               /* l_passed_val_tbl(i) := substrb(l_entry_value_tbl(i),1,60);*/
	          hr_utility.set_location('payplnk.validate_lines',42);
               l_passed_val_tbl(i) := l_entry_value_tbl(i);
            end if;
            --
         else
            --
            -- bug no. 3734946
            /* l_passed_val_tbl(i) := substrb(convert_internal_to_display(l_entry_value_tbl(i),
                                                                       l_uom,
                                                                       l_lookup_type,
                                                                       l_value_set_id,
                                                                       l_input_curr_code),1,60); */
             hr_utility.set_location('payplnk.validate_lines',43);
	     l_passed_val_tbl(i) := convert_internal_to_display(l_entry_value_tbl(i),
                                                                       l_uom,
                                                                       l_lookup_type,
                                                                       l_value_set_id,
                                                                       l_input_curr_code);
             hr_utility.set_location('payplnk.validate_lines',44);
            --
         end if;
         --
      else
         l_passed_val_tbl(i) := null;
      end if;
      --
      hr_utility.trace('INPUT VALUE ID :'||l_passed_inp_tbl(i));
      hr_utility.trace('INPUT VALUE    :'||l_passed_val_tbl(i));
      --
      c_entry_values := c_entry_values + 1;

      -- Exit the loop if it has reached the 15th input value.
      if i >= 15 then
         exit;
      end if;

    end loop;
    close csr_table_inp_ids;
--
    hr_utility.set_location('payplnk.validate_lines',45);
--
-- If there are no input value ids  for the element type or the
-- entry values exceed the number of input value id(s) , raise an error.
--
    i := i+1;
--
    for k in i..15 loop
       if (l_entry_value_tbl(k) is not null) and
          (l_input_id_exists = false) then
--
         raise inputs_not_required;
       elsif (l_entry_value_tbl(k) is not null) and
             (l_input_id_exists = true) then
--
         raise invalid_entry_value;
       end if;
    end loop;
--
    hr_utility.set_location('payplnk.validate_lines', 50);
--
-- Retrieve the link id for the element type and assignment combination.
--
    hr_utility.trace('ASS: '||g_line_record.assignment_id);
    hr_utility.trace('ETI: '||g_line_record.element_type_id);
    hr_utility.trace('EDT: '||g_line_record.effective_date);
    hr_utility.trace('LLI: '||l_link_id);
    hr_utility.trace('END');
--
    l_link_id := hr_entry_api.get_link(g_line_record.assignment_id,
                                       g_line_record.element_type_id,
                                       g_line_record.effective_date);
--
    hr_utility.set_location('payplnk.validate_lines',55);
--
-- Raise an error if a link does not exist on the effective date.
--
    if l_link_id is null then
       raise element_entry_not_eligible;
    end if;
--
--
-- Check for time unit, and if so absence attendance type and accrual plan
--
   t := i-1;
--
   for l in 1..t loop
--
      --
      -- if a time unit get absence_attendance_type + check with accrual plan
      --
      if (l_inpv_uom_tbl(l) = 'ND' or l_inpv_uom_tbl(l) = 'H_HH' or l_inpv_uom_tbl(l) = 'H_HHMM'
          or l_inpv_uom_tbl(l) = 'H_HHMMSS' or l_inpv_uom_tbl(l) = 'H_DECIMAL1'
          or l_inpv_uom_tbl(l) = 'H_DECIMAL2' or l_inpv_uom_tbl(l) = 'H_DECIMAL3'
          or l_inpv_uom_tbl(l) = 'HOURS') then
--
         hr_utility.set_location('payplnk.validate_lines',53);
--
         l_absence_attendance_type_id := null;
         --
         -- The hours input value may be associated with an Absence
         -- Attendance Type, so need to try to retrieve these details.
         --
         open csr_attendance_types(p_business_group_id,
                                   l_passed_inp_tbl(l),
                                   nvl(g_line_record.effective_start_date,
                                       nvl(g_line_record.effective_end_date,
                                           g_line_record.effective_date)),
                                   nvl(g_line_record.effective_end_date,
                                       nvl(g_line_record.effective_start_date,
                                           g_line_record.effective_date)));
         fetch csr_attendance_types into l_absence_attendance_type_id,
                                         l_hours_or_days;
         close csr_attendance_types;
         -- The above cursor replaces the select statement below. This is due to more
         -- than one entry available for a given input_value_id and a business_group_id.
         -- begin
         --     select paat.absence_attendance_type_id
         --     ,      paat.hours_or_days
         --     into   l_absence_attendance_type_id
         --     ,      l_hours_or_days
         --     from   per_absence_attendance_types paat
         --     where  paat.input_value_id = l_passed_inp_tbl(l)
         --     and    paat.business_group_id +0 = p_business_group_id;
         -- exception
         --    when no_data_found then null;
         -- end;
--
        hr_utility.set_location('payplnk.validate_lines',54);
--
        if l_absence_attendance_type_id is not null then
--
           l_abs_type_tbl(l) := l_absence_attendance_type_id;
           l_abs_hod_tbl(l)  := l_hours_or_days;
           l_creator_type    := 'A';
--
        end if;
--
        hr_utility.set_location('payplnk.validate_lines',56);
--
        --
        -- WW Bug# 282299
        -- The hours input value may also be associated with an Accrual Plan.
        -- If it is, check the ineligibility period for the Accrual.  Prevent
        -- entry of time taken against an accrual during the ineligible period.
        -- This can be handled thru PayMIX, and should also be handled when
        -- accrual time taken entries are created via the core Element Entry
        -- screen; furthermore, it should be handled by the core Enter Absence
        -- screen - ie. absences and accruals can share the same time taken
        -- input value.
        --
        hr_us_accrual_plans.get_accrual_ineligibility(
                p_iv_id         => l_passed_inp_tbl(l),
                p_bg_id         => p_business_group_id,
                p_asg_id        => g_line_record.assignment_id,
                p_sess_date     => g_line_record.effective_date,
                p_eligible      => l_eligible);
--
        hr_utility.set_location('payplnk.validate_lines',57);
--
        if l_eligible = 'N' then
           hr_utility.set_location('payplnk.validate_lines',58);
           hr_utility.trace('Assignment is in ineligible period for this accrual plan. ');
           hr_utility.set_message(801,'PAY_7853_PDT_INELIG_ACCRUAL');
           hr_utility.raise_error;
        end if;
      end if;
   end loop;
--
   hr_utility.set_location('payplnk.validate_lines',59);
--
-- Validate the costing details entered.
--
-- S.Sinha pseudo bug 493304, for performance fix for BT.
-- The statement below has the business group id index disabled now.
--
    select el.costable_type
    into   l_costable_type
    from   pay_element_links_f  el
    where  el.element_link_id   = l_link_id
    and    el.business_group_id + 0 = p_business_group_id
    and    g_line_record.effective_date between el.effective_start_date
                                            and el.effective_end_date;
--
-- Check if any costing details have been entered
--
    if  (g_line_record.concatenated_segments is not null) or -- { costing exists
        (g_line_record.segment1 is not null) or
        (g_line_record.segment2 is not null) or
        (g_line_record.segment3 is not null) or
        (g_line_record.segment4 is not null) or
        (g_line_record.segment5 is not null) or
        (g_line_record.segment6 is not null) or
        (g_line_record.segment7 is not null) or
        (g_line_record.segment8 is not null) or
        (g_line_record.segment9 is not null) or
        (g_line_record.segment10 is not null) or
        (g_line_record.segment11 is not null) or
        (g_line_record.segment12 is not null) or
        (g_line_record.segment13 is not null) or
        (g_line_record.segment14 is not null) or
        (g_line_record.segment15 is not null) or
        (g_line_record.segment16 is not null) or
        (g_line_record.segment17 is not null) or
        (g_line_record.segment18 is not null) or
        (g_line_record.segment19 is not null) or
        (g_line_record.segment20 is not null) or
        (g_line_record.segment21 is not null) or
        (g_line_record.segment22 is not null) or
        (g_line_record.segment23 is not null) or
        (g_line_record.segment24 is not null) or
        (g_line_record.segment25 is not null) or
        (g_line_record.segment26 is not null) or
        (g_line_record.segment27 is not null) or
        (g_line_record.segment28 is not null) or
        (g_line_record.segment29 is not null) or
        (g_line_record.segment30 is not null)  then

                 if (l_costable_type = 'N') then -- { Costable_type N
--
                        g_count := g_count + 1;
                        hr_utility.set_message(801, 'HR_7453_PLK_NON_COSTABLE_ELE');
                        l_error_text := substrb(hr_utility.get_message, 1, 240);
                        l_line_id_tbl(g_count) := g_line_record.batch_line_id;
                        l_status_tbl(g_count)  := 'W';
                        l_message_tbl(g_count) := l_error_text;
--
    else
--
-- Check if a cost_allocation_structure exists, if not, raise error.
--
       if l_cost_allocation_structure is null then -- { no structure
             raise no_cost_allocation_structure;
       end if;                                     -- } no structure
--
-- Retrieve/generate a cost keyflex id for the costing details.
--
       hr_utility.set_location('payplnk.validate_lines',60);
--
       g_line_record.cost_allocation_keyflex_id :=
         hr_entry.maintain_cost_keyflex(
                            l_cost_allocation_structure,
                            -1,
                            g_line_record.concatenated_segments,
                            'N',
                            null,
                            null,
                            g_line_record.segment1,
                            g_line_record.segment2,
                            g_line_record.segment3,
                            g_line_record.segment4,
                            g_line_record.segment5,
                            g_line_record.segment6,
                            g_line_record.segment7,
                            g_line_record.segment8,
                            g_line_record.segment9,
                            g_line_record.segment10,
                            g_line_record.segment11,
                            g_line_record.segment12,
                            g_line_record.segment13,
                            g_line_record.segment14,
                            g_line_record.segment15,
                            g_line_record.segment16,
                            g_line_record.segment17,
                            g_line_record.segment18,
                            g_line_record.segment19,
                            g_line_record.segment20,
                            g_line_record.segment21,
                            g_line_record.segment22,
                            g_line_record.segment23,
                            g_line_record.segment24,
                            g_line_record.segment25,
                            g_line_record.segment26,
                            g_line_record.segment27,
                            g_line_record.segment28,
                            g_line_record.segment29,
                            g_line_record.segment30);
--
--
        end if; --  } costable_type N else
--
    end if; --  } costing exists
--
    hr_utility.set_location('payplnk.validate_lines',65);
--
-- The batch line core validation checks have been carried out
-- successfully, hence the legislative hook checks (if any) and
-- then the user line validation checks can be called.
--
    l_user_status := 'V';

--  The legislative hook to line validation should be executed here
--
-- call legislative header check hook if required
--
    hr_utility.set_location('payplnk.validate_lines',66);
 if l_leg_line_check = TRUE then
--
   begin
    hr_utility.set_location('payplnk.validate_lines',67);
     statem := 'BEGIN
             pay_'||lower(l_legislation_code)||'_bee.validate_line(:batch_line_id, :valid, :leg_message, :line_changed); END;';
--
     if pay_core_utils.get_sql_cursor(statem,sql_curs) then
--
        dbms_sql.bind_variable(sql_curs, 'batch_line_id', g_line_record.batch_line_id);
        dbms_sql.bind_variable(sql_curs, 'valid', l_valid);
        dbms_sql.bind_variable(sql_curs, 'leg_message', l_leg_message, 240);
        dbms_sql.bind_variable(sql_curs, 'line_changed', l_line_changed);
--
        rows_processed := dbms_sql.execute(sql_curs);
--
        dbms_sql.variable_value(sql_curs, 'valid', l_valid);
        dbms_sql.variable_value(sql_curs, 'leg_message', l_leg_message);
        dbms_sql.variable_value(sql_curs, 'line_changed', l_line_changed);
--
     else
        raise error_occurred;
     end if;
--
   exception
     when others then
       hr_utility.set_location('payplnk.validate_lines',68);
--
       g_line_error := true;
       g_count := g_count + 1;
--
       hr_utility.set_message(801,'HR_7481_PLK_USR_CHECK_ERROR');
       hr_utility.set_message_token('USER_PROCEDURE',
                                    'the legislative batch line procedure');
       l_error_text := substrb((hr_utility.get_message||' '||sqlerrm),1,240);
--
       l_line_id_tbl(g_count) := g_line_record.batch_line_id;
       l_status_tbl(g_count) := 'F';
       l_message_tbl(g_count) := l_error_text;
--
       raise line_error_occurred;
   end;
--
   if l_valid = 1 then
    hr_utility.set_location('payplnk.validate_lines',688);
--
     g_line_error := true;
     g_count := g_count + 1;
--
     hr_utility.set_message(801,'HR_7469_PLK_USR_STATUS_INVLD');
     hr_utility.set_message_token('USER_PROCEDURE',
                                'the legislative batch line procedure');
     l_error_text := substrb((hr_utility.get_message||' '||l_leg_message),1,240);
--
     l_line_id_tbl(g_count) := g_line_record.batch_line_id;
     l_status_tbl(g_count) := 'F';
     l_message_tbl(g_count) := l_error_text;
--
     raise line_error_occurred;
   end if;
--
   if l_line_changed = 0 then
   --
   -- legislative hook changed the line details
   -- so we select them back and go back to beginning of validation for
   -- the line
   --
       select *
       into   g_line_record2
       from   pay_batch_lines  bal
       where  bal.batch_id = p_batch_id
       and    bal.batch_line_id = g_line_record.batch_line_id;

       g_line_record := g_line_record2;

    goto start_validation;
   end if;
--
 end if;
--
-- call user line validation checks
--
    begin
      pay_user_check.validate_line (g_line_record.batch_line_id,
                                l_user_status,
                                l_user_message);
    exception
--
-- If an unhandled error occurred during the user line validation then
-- raise an error.
--


    when others then
--
      g_line_error := true;
      g_count := g_count + 1;
--
      hr_utility.set_message(801,'HR_7481_PLK_USR_CHECK_ERROR');
      hr_utility.set_message_token('USER_PROCEDURE',
                                   'the user batch line procedure');
      l_error_text := substrb((hr_utility.get_message||' '||sqlerrm),1,240);
--
      l_line_id_tbl(g_count) := g_line_record.batch_line_id;
      l_status_tbl(g_count) := 'F';
      l_message_tbl(g_count) := l_error_text;
--
      raise line_error_occurred;
    end;
--
    hr_utility.set_location('payplnk.validate_lines',70);
--
-- If a status has not been returned raise an error.
--
      if l_user_status is null then
--
         g_line_error := true;
         g_count := g_count + 1;
--
         hr_utility.set_message(801,'HR_7468_PLK_USR_STATUS_NULL');
         hr_utility.set_message_token('USER_PROCEDURE',
                                      'the user batch line procedure');
         l_error_text := substrb(hr_utility.get_message, 1, 240);
--
         l_line_id_tbl(g_count) := g_line_record.batch_line_id;
         l_status_tbl(g_count)  := 'F';
         l_message_tbl(g_count) := l_error_text;
--
         raise line_error_occurred;
--
      else
         open csr_status_chk(l_user_status);
         fetch csr_status_chk into l_usr_status_chk;
--
         if csr_status_chk%NOTFOUND then
--
-- An invalid status has been returned, raise an error.
--
         g_line_error := true;
         g_count := g_count + 1;
--
         hr_utility.set_message(801,'HR_7469_PLK_USR_STATUS_INVLD');
         hr_utility.set_message_token('USER_PROCEDURE',
                                      'the user batch line procedure');
         l_error_text := substrb(hr_utility.get_message, 1, 240);
--
         l_line_id_tbl(g_count) := g_line_record.batch_line_id;
         l_status_tbl(g_count)  := 'F';
         l_message_tbl(g_count) := l_error_text;
--
         close csr_status_chk;
--
         raise line_error_occurred;
--
      elsif upper(l_user_status) in ('U','T') then
--
-- A status has been returned tht is not valid in this context, raise
-- an error.
--
         g_line_error := true;
         g_count := g_count + 1;
--
         hr_utility.set_message(801,'HR_7470_PLK_USR_STATUS_INVLD_C');
         hr_utility.set_message_token('USER_PROCEDURE',
                                      'the user batch line procedure');
         l_error_text := substrb(hr_utility.get_message, 1, 240);
--
         l_line_id_tbl(g_count) := g_line_record.batch_line_id;
         l_status_tbl(g_count)  := 'F';
         l_message_tbl(g_count) := l_error_text;
--
         close csr_status_chk;
--
         raise line_error_occurred;
--
-- A vaid status has been returned. If status is valid or warning and a
-- message has been returned
--
    else
       close csr_status_chk;
--
       if (upper(l_user_status) in ('V','W')) and
          (l_user_message is not null) then
          l_general_message := true;
          g_count := g_count + 1;
--
          l_line_id_tbl(g_count) := g_line_record.batch_line_id;
--
          if upper(l_user_status) = 'W' then
             l_status_tbl(g_count) := 'W';
          else
             l_status_tbl(g_count) := 'I';
          end if;
--
          l_message_tbl(g_count) := l_user_message;
--
       elsif upper(l_user_status) = 'E' then
          g_line_error := true;
          g_count := g_count + 1;
          l_line_id_tbl(g_count) := g_line_record.batch_line_id;
          l_status_tbl(g_count) := 'F';
          l_message_tbl(g_count) := l_user_message;
          raise line_error_occurred;
       end if;
    end if;
  end if;
--
  hr_utility.set_location('payplnk.validate_lines',75);
--
-- Batch line has been validated successfully. Attempt to insert/update
-- an element entry into the base tables.
--

      select et.multiple_entries_allowed_flag
      ,      et.processing_type
      into   l_multiple_entries_allowed
      ,      l_processing_type
      from   pay_element_types_f  et
      where  et.element_type_id =g_line_record.element_type_id
      and    g_line_record.effective_date between
             et.effective_start_date and et.effective_end_date;

      -- If there is an associated Absence Attendance Type, then need
      -- to insert the absence attendance details for the assignment.
      --
      -- Use the optionally entered effective start and effective end dates

      if (g_line_record.effective_start_date is not null) then
          l_start_date := g_line_record.effective_start_date;
      else
          if (g_line_record.effective_end_date is not null) then
              l_start_date := g_line_record.effective_end_date;
          else
              l_start_date := g_line_record.effective_date;
          end if;
      end if;

      if (g_line_record.effective_end_date is not null) then
          l_end_date := g_line_record.effective_end_date;
      elsif l_processing_type = 'N' then
            --
            -- Default the end date if its non-recurring.  Recurring entries
            -- can continue through to the end of time.
            -- .
          if (g_line_record.effective_start_date is not null) then
              l_end_date := g_line_record.effective_start_date;
          else
              l_end_date := g_line_record.effective_date;
          end if;
      end if;
--
      for l in 1..t loop
          if (l_abs_type_tbl(l) <> 0) then

              -- if (l_abs_hod_tbl(l) = 'D') then
                  -- l_absence_days := l_passed_val_tbl(l);
                  -- l_absence_hours := NULL;
              -- else
                  -- l_absence_days := NULL;
                  -- -- Start of fix 3156665
                  -- /* Converting the value entered to a numberic value in hours.
                  --    1) If value entered in HH:MI format, then calculating the
                  --       the total absence hours.
                  --    2) If value entered in decimal format like 23.5, will be treated
                  --       as 23 hours 30 minutes  */
                  -- --
                  -- --l_absence_hours := l_passed_val_tbl(l);
                  -- l_passed_val_tbl(l) := ltrim(rtrim(l_passed_val_tbl(l)));
	        	  -- if substr(l_passed_val_tbl(l), 3, 1) = ':' then
	        	  --    l_absence_hours := to_number((((substr(l_passed_val_tbl(l), 1, 2) * 60) +
		          --                                    substr(l_passed_val_tbl(l), 4, 2))/60));
		          -- else
		          --    l_absence_hours := to_number(substr(l_passed_val_tbl(l), 1, 5));
                  --         end if;
                  -- -- End of 3156665
              -- end if;

              -- per_absence_attendances_pkg3.insert_abs_for_bee(
              --      p_session_date          => g_line_record.effective_date,
              --      p_absence_att_type_id   => l_abs_type_tbl(l),
              --      p_absence_attendance_id => l_absence_attendance_id,
              --      p_batch_id              => p_batch_id,
              --      p_assignment_id         => g_line_record.assignment_id,
              --      p_absence_days          => l_absence_days,
              --      p_absence_hours         => l_absence_hours,
              --      p_date_start            => l_start_date,
              --      p_date_end              => l_end_date,
              --      p_warning_table         => l_warning_table,
              --      p_error_table           => l_error_table);

              -- per_absence_attendances_pkg3.insert_abs_for_bee(
              --                p_session_date          => g_line_record.effective_date,
              --                p_absence_att_type_id   => l_abs_type_tbl(l),
              --                p_assignment_id         => g_line_record.assignment_id,
              --                p_batch_id              => p_batch_id,
              --                p_hours_or_days         => l_abs_hod_tbl(l),
              --                p_format                => l_inpv_uom_tbl(l),
              --                p_value                 => l_passed_val_tbl(l),
              --                p_date_start            => l_start_date,
              --                p_date_end              => l_end_date,
              --                p_absence_attendance_id => l_absence_attendance_id,
              --                p_warning_table         => l_warning_table,
              --                p_error_table           => l_error_table);

              --
              -- This overloaded Absence API handles creation of both
              -- the absence and element entry.
              --
              per_absence_attendances_pkg3.insert_abs_for_bee(
                     p_absence_att_type_id   => l_abs_type_tbl(l),
                     p_batch_id              => p_batch_id,
                     p_asg_act_id            => p_asg_act_id,
                     p_entry_values_count    => c_entry_values,
                     p_hours_or_days         => l_abs_hod_tbl(l),
                     p_format                => l_inpv_uom_tbl(l),
                     p_value                 => l_passed_val_tbl(l), -- A
                     p_date_start            => l_start_date,
                     p_date_end              => l_end_date,
                     p_absence_attendance_id => l_absence_attendance_id,
                     p_line_record           => g_line_record,
                     p_passed_inp_tbl        => l_passed_inp_tbl,
                     p_passed_val_tbl        => l_passed_val_tbl,    -- B
                     p_warning_table         => l_warning_table,
                     p_error_table           => l_error_table);
              --

              if l_warning_table.COUNT <> 0 then
                hr_utility.set_location('payplnk.validate_lines',76);
                 for l_warning_num in 1..l_warning_table.COUNT loop
                hr_utility.trace(l_warning_table(l_warning_num));
                     if l_warning_table(l_warning_num) = 'EE_CREATED_BY_ABSENCE_API' then
                        hr_utility.set_location('payplnk.validate_lines',77);
                        absence_entry_already_created := TRUE;
                     else
                        g_count := g_count + 1;
                        hr_utility.set_message(801,l_warning_table(l_warning_num));
                        l_error_text := substrb(hr_utility.get_message, 1, 240);
--
                        l_line_id_tbl(g_count) := g_line_record.batch_line_id;
                        -- Changed from ' V' to 'W'. So that Pay_message_lines would not
                        -- error outs.
                        l_status_tbl(g_count)  := 'W';
                        l_message_tbl(g_count) := l_error_text;
                     end if;
                 end loop;
              end if;

              if l_error_table.COUNT <> 0 then
                 for l_error_num in 1..l_error_table.COUNT loop
                     g_line_error := true;
                     g_count := g_count + 1;
                     hr_utility.set_message(801,l_error_table(l_error_num));
                     l_error_text := substrb(hr_utility.get_message, 1, 240);
--
                     l_line_id_tbl(g_count) := g_line_record.batch_line_id;
                     l_status_tbl(g_count)  := 'F';
                     l_message_tbl(g_count) := l_error_text;
                 end loop;
                 raise line_error_occurred;
              end if;

          end if;
      end loop;
--
-- The per_absence_attendances_pkg3.insert_abs_for_bee procedure now creates both
-- an absence record AND an absence element entry.  Hence we should move to next
-- batch line if an absence entry has been made.
--

   if absence_entry_already_created = FALSE then

--
-- Check to see if any element entry(s) for the required combination
-- exist.
--
     open csr_element_entries(l_link_id,
                              g_line_record.effective_date,
                              g_line_record.element_type_id,
                              g_line_record.assignment_id);
     fetch csr_element_entries into l_element_entry_id,
                                    e_creator_type,
                                    e_creator_id,
                                    l_effective_end_date,
                                    l_effective_start_date;
     if csr_element_entries%NOTFOUND then
       close csr_element_entries;

-- If no entries of the required combination exist, check the
-- appropriate processing flags to see if an attempt can be
-- made to insert the element entry.
--
     if l_reject_if_future_changes_chk = false then
--
       l_column_name1 := 'REJECT IF FUTURE CHANGES';
--
       if g_header_record.reject_if_future_changes is null then
          raise column_is_null;
       end if;
--
       l_reject_if_future_changes_chk := true;
     end if;
--
     if (g_header_record.reject_if_future_changes = 'Y') and
        (l_multiple_entries_allowed = 'N') then
--
        open csr_future_existence(l_link_id,
                                  g_line_record.effective_date,
                                  g_line_record.element_type_id,
                                  g_line_record.assignment_id);
        fetch csr_future_existence into l_dummy;
        if csr_future_existence%FOUND then
           close csr_future_existence;
           raise future_changes_exist;
        end if;
        close csr_future_existence;
     end if;
--
     hr_utility.set_location('payplnk.validate_lines',80);
--
-- An attempt can be made to insert the element entry as all the
-- prerequisite conditions are in place.
--
      -- Bug 488335 - new declaration to avoid invalid parameter
      -- mode in Oracle 8
      g_line_record1 := g_line_record;
      begin
         payplnk.insert_element_entry(l_link_id,
                                   g_line_record1,
                                   p_asg_act_id,
                                   l_creator_type,
                                   l_absence_attendance_id,
                                   c_entry_values,
                                   l_passed_inp_tbl,
                                   l_passed_val_tbl);
      exception
--
-- If an unhandled error occurred during the element entry validation then
-- raise an error.
--
      when others then
--
       g_line_error := true;
       g_count := g_count + 1;
--
      l_error_text := substrb((hr_utility.get_message||' '||sqlerrm),1,240);
--
      l_line_id_tbl(g_count) := g_line_record.batch_line_id;
      l_status_tbl(g_count) := 'F';
      l_message_tbl(g_count) := l_error_text;
--
      raise line_error_occurred;
    end;

--
    else
--
-- An element entry(s) does already exist for the required combination.
-- Check the appropriate processing flags and wether or not multiple
-- entries are allowed to see if either the entry can be inserted or
-- the existing entry updated.
--
   if l_action_if_exists_chk = false then
--
       l_column_name1 := 'ACTION IF EXISTS';
--
       if g_header_record.action_if_exists is null then
          raise column_is_null;
       end if;
--
       l_action_if_exists_chk := true;
   end if;
--
   hr_utility.set_location('payplnk.validate_lines',85);
--
   if (l_multiple_entries_allowed = 'Y') and
      (g_header_record.action_if_exists = 'I') then
--
      g_line_record1 := g_line_record;
      begin
         payplnk.insert_element_entry (l_link_id,
                            g_line_record1,
                            p_asg_Act_id,
                            l_creator_type,
                            l_absence_attendance_id,
                            c_entry_values,
                            l_passed_inp_tbl,
                            l_passed_val_tbl);
      exception
--
-- If an unhandled error occurred during the element entry validation then
-- raise an error.
--
       when others then
--
       g_line_error := true;
       g_count := g_count + 1;
--
      l_error_text := substrb((hr_utility.get_message||' '||sqlerrm),1,240);
--
      l_line_id_tbl(g_count) := g_line_record.batch_line_id;
      l_status_tbl(g_count) := 'F';
      l_message_tbl(g_count) := l_error_text;
--
      raise line_error_occurred;
    end;
--
   elsif (l_multiple_entries_allowed = 'N') and
         (g_header_record.action_if_exists = 'I') then
--
           raise multiple_entries_not_allowed;
   end if;
--
   hr_utility.set_location('payplnk.validate_lines',90);
--
   if g_header_record.action_if_exists = 'R' then
--
      raise element_entry_exists;
   elsif g_header_record.action_if_exists = 'U' then
--
       --
       -- Bug 2672143. If creator type is 'SP' then don't allow
       -- BEE to update the entry.
       --
       if e_creator_type = 'SP' then
          raise non_updatable_creator_type;
       end if;
       --
          fetch csr_element_entries into l_element_entry_id,
                                         e_creator_type,
                                         e_creator_id,
                                         l_effective_end_date,
                                         l_effective_start_date;
       if csr_element_entries%FOUND then
        close csr_element_entries;
        raise more_than_one_entry;
       else
--
        close csr_element_entries;
--
        if l_processing_type = 'N' then
--
           update_element_entry('CORRECTION',
                                l_element_entry_id,
                                e_creator_type,
                                e_creator_id,
                                FALSE,
                                p_asg_act_id,
                                g_line_record,
                                c_entry_values,
                                l_passed_inp_tbl,
                                l_passed_val_tbl);
--
        else
--
          if l_reject_if_future_changes_chk = false then
             l_column_name1 := 'REJECT IF FUTURE CHANGES';
--
             if g_header_record.reject_if_future_changes is null then
                raise column_is_null;
             end if;
--
             l_reject_if_future_changes_chk := true;
          end if;
--
          if (g_header_record.reject_if_future_changes = 'Y') and
             (l_effective_end_date <> hr_general.end_of_time) then
              raise future_changes_exist;
          elsif l_date_effective_changes_chk = false then
             l_column_name1 := 'DATE EFFECTIVE CHANGES';
--
             if g_header_record.date_effective_changes is null then
                raise column_is_null;
             end if;
--
             l_date_effective_changes_chk := true;
          end if;
--
          if (l_effective_end_date = hr_general.end_of_time) then
--
            if g_header_record.date_effective_changes = 'C' then
               l_update_mode := 'CORRECTION';
               l_allow_rollback := FALSE;
            else
               l_update_mode := 'UPDATE';
               --
               if l_effective_start_date = g_line_record.effective_date then
                  l_allow_rollback := FALSE;
               else
                  l_allow_rollback := TRUE;
                  e_creator_id   := p_batch_id;
                  e_creator_type := 'H';
               end if;
               --
            end if;
--
-- The prerequisite conditions allow for an attempt to be made to update
-- the existing element entry.
--
            update_element_entry(l_update_mode,
                                 l_element_entry_id,
                                 e_creator_type,
                                 e_creator_id,
                                 l_allow_rollback,
                                 p_asg_act_id,
                                 g_line_record,
                                 c_entry_values,
                                 l_passed_inp_tbl,
                                 l_passed_val_tbl);
--
          elsif (g_header_record.reject_if_future_changes = 'N') and
                (l_effective_end_date <> hr_general.end_of_time) then
--
                if g_header_record.date_effective_changes = 'C' then
                   l_update_mode := 'CORRECTION';
                   l_allow_rollback := FALSE;
                elsif g_header_record.date_effective_changes = 'U' then
                   l_update_mode := 'UPDATE_CHANGE_INSERT';
                   --
                   if l_effective_start_date = g_line_record.effective_date then
                      l_allow_rollback := FALSE;
                   else
                      l_allow_rollback := TRUE;
                      e_creator_id   := p_batch_id;
                      e_creator_type := 'H';
                   end if;
                   --
                else
                   l_update_mode := 'UPDATE_OVERRIDE';
                   l_allow_rollback := FALSE;
                end if;
--
                update_element_entry(l_update_mode,
                                     l_element_entry_id,
                                     e_creator_type,
                                     e_creator_id,
                                     l_allow_rollback,
                                     p_asg_act_id,
                                     g_line_record,
                                     c_entry_values,
                                     l_passed_inp_tbl,
                                     l_passed_val_tbl);
           end if;
         end if;
        end if;
      end if;
   end if;
--
   end if;
--
   hr_utility.set_location('payplnk.validate_lines',95);
--
   exception
     when no_data_found then
       g_line_error := true;
       if l_general_message = false then
         g_count := g_count + 1;
       end if;
--
       hr_utility.set_message(801,'HR_7462_PLK_INVLD_VALUE');
       hr_utility.set_message_token('COLUMN_NAME',l_column_name1);
       l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       l_line_id_tbl(g_count) := g_line_record.batch_line_id;
       l_status_tbl(g_count)  := 'F';
       l_message_tbl(g_count) := l_error_text;
--
     when column_is_null then
       g_line_error := true;
       if l_general_message = false then
          g_count := g_count + 1;
       end if;
--
       hr_utility.set_message(801,'HR_7449_PLK_COLUMN_NULL');
       hr_utility.set_message_token('COLUMN_NAME',l_column_name1);
       l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       l_line_id_tbl(g_count) := g_line_record.batch_line_id;
       l_status_tbl(g_count)  := 'F';
       l_message_tbl(g_count) := l_error_text;
--
     when both_nulls then
       g_line_error := true;
       g_count := g_count + 1;
--
       hr_utility.set_message(801,'HR_7482_PLK_BOTH_COLUMNS_NULL');
       hr_utility.set_message_token('COL1',l_column_name1);
       hr_utility.set_message_token('COL2',l_column_name2);
       l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       l_line_id_tbl(g_count) := g_line_record.batch_line_id;
       l_status_tbl(g_count)  := 'F';
       l_message_tbl(g_count) := l_error_text;
--
     when invalid_entry_value then
       g_line_error := true;
       g_count := g_count + 1;
--
       hr_utility.set_message(801,'HR_7452_PLK_VALS_EXCEED_INPUTS');
       l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       l_line_id_tbl(g_count) := g_line_record.batch_line_id;
       l_status_tbl(g_count)  := 'F';
       l_message_tbl(g_count) := l_error_text;
--
--
     when invalid_date_format then
       g_line_error := true;
       g_count := g_count + 1;
--
       hr_utility.set_message(801,'HR_51155_INVAL_DATE_FORMAT');
       l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       l_line_id_tbl(g_count) := g_line_record.batch_line_id;
       l_status_tbl(g_count)  := 'F';
       l_message_tbl(g_count) := l_error_text;
--
     when no_cost_allocation_structure then
       g_line_error := true;
       g_count := g_count + 1;
--
       hr_utility.set_message(801,'HR_7460_PLK_NO_CST_ALLC_STRUCT');
       hr_utility.set_message_token('BUSINESS_GROUP_ID',p_business_group_id);
       l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       l_line_id_tbl(g_count) := g_line_record.batch_line_id;
       l_status_tbl(g_count)  := 'F';
       l_message_tbl(g_count) := l_error_text;
--
     when non_costable_element then
       g_line_error := true;
       g_count := g_count + 1;
--
       hr_utility.set_message(801,'HR_7453_PLK_NON_COSTABLE_ELE');
       l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       l_line_id_tbl(g_count) := g_line_record.batch_line_id;
       l_status_tbl(g_count)  := 'F';
       l_message_tbl(g_count) := l_error_text;
--
     when multiple_entries_not_allowed then
       g_line_error := true;
       if l_general_message = false then
        g_count := g_count + 1;
       end if;
--
       hr_utility.set_message(801,'HR_7454_PLK_MULT_ENTS_NOT_ALLD');
       l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       l_line_id_tbl(g_count) := g_line_record.batch_line_id;
       l_status_tbl(g_count) := 'F';
       l_message_tbl(g_count) := l_error_text;
--
     when element_entry_exists then
       g_line_error := true;
       if l_general_message = false then
          g_count := g_count + 1;
       end if;
--
       hr_utility.set_message(801,'HR_7455_PLK_ELE_ENTRY_EXISTS');
       l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       l_line_id_tbl(g_count) := g_line_record.batch_line_id;
       l_status_tbl(g_count)  := 'F';
       l_message_tbl(g_count) := l_error_text;
--
     when more_than_one_entry then
       g_line_error := true;
       if l_general_message = false then
          g_count := g_count + 1;
       end if;
--
       hr_utility.set_message(801,'HR_7456_PLK_MORE_THAN_ONE_ENT');
       l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       l_line_id_tbl(g_count) := g_line_record.batch_line_id;
       l_status_tbl(g_count)  := 'F';
       l_message_tbl(g_count) := l_error_text;
--
     when future_changes_exist then
       g_line_error := true;
       if l_general_message = false then
          g_count := g_count + 1;
       end if;
--
       hr_utility.set_message(801,'HR_7457_PLK_FUTURE_CHGS_EXIST');
       l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       l_line_id_tbl(g_count) := g_line_record.batch_line_id;
       l_status_tbl(g_count)  := 'F';
       l_message_tbl(g_count) := l_error_text;
--
     when element_entry_not_eligible then
       g_line_error := true;
       g_count := g_count + 1;
--
       hr_utility.set_message(801,'HR_7459_PLK_NOT_ELGBLE_ELE_ENT');
       l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       l_line_id_tbl(g_count) := g_line_record.batch_line_id;
       l_status_tbl(g_count)  := 'F';
       l_message_tbl(g_count) := l_error_text;
--
     when non_updatable_creator_type then
       g_line_error := true;
       g_count := g_count + 1;
--
       hr_utility.set_message(801,'HR_7014_ELE_ENTRY_CREATOR_UPD');
       hr_utility.set_message_token('CREATOR_MEANING', hr_general.decode_lookup('CREATOR_TYPE','SP'));
       l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       l_line_id_tbl(g_count) := g_line_record.batch_line_id;
       l_status_tbl(g_count)  := 'F';
       l_message_tbl(g_count) := l_error_text;
--
     when hr_utility.hr_error then
       g_line_error := true;
       if l_general_message = false then
          g_count := g_count + 1;
       end if;
--
       l_line_id_tbl(g_count) := g_line_record.batch_line_id;
       l_status_tbl(g_count)  := 'F';
       l_message_tbl(g_count) := substrb(hr_utility.get_message, 1, 240);
--
     when inputs_not_required then
       g_line_error := true;
       g_count := g_count + 1;
--
       hr_utility.set_message(801,'HR_7458_PLK_ENT_VALS_NOT_REQD');
       l_error_text := substrb(hr_utility.get_message, 1, 240);
--
       l_line_id_tbl(g_count) := g_line_record.batch_line_id;
       l_status_tbl(g_count)  := 'F';
       l_message_tbl(g_count) := l_error_text;
--
     when line_error_occurred then
       null;
   end;
--
-- Close any cursors left open.
--
   if csr_element_entries%ISOPEN then
      close csr_element_entries;
   end if;
--
  end loop;
--
--
  g_line_id_tbl := l_line_id_tbl;
  g_status_tbl  := l_status_tbl;
  g_message_tbl := l_message_tbl;
  --
  --
  -- Successfully validated line(s) may as a result have created
  -- element entrie(s) in the base tables, therefore the entries must be
  -- ROLLED BACK as the requested batch operation was 'VALIDATE'.
  --
  if p_process_mode = 'VALIDATE' then
     rollback to BL;
  end if;
  --
  -- Raise error if there is a failed line exists.
  if g_line_error then
     raise no_data_found;
  end if;
  --
  hr_utility.set_location('payplnk.validate_lines',500);
  --
  -- Close the header cursor if it is open.
  if csr_bl_header%ISOPEN then
     close csr_bl_header;
  end if;
  --
  --Set the global parameter to enable the triggers.
  payplnk.g_payplnk_call := false;
  --
--
 exception
 when others then
 if csr_asg_lines%ISOPEN then
    close csr_asg_lines;
 end if;
  if csr_bl_header%ISOPEN then
     close csr_bl_header;
  end if;
 rollback to BL;
 --Set the global parameter to enable the triggers.
 payplnk.g_payplnk_call := false;
 hr_utility.set_message(800, 'HR_289719_BEE_LINE_ERROR');
 hr_utility.raise_error;
 -- raise;
--
end validate_lines;
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- payplnk.purge_messages                       PRIVATE PROCEDURE    --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Deletes all messages associated with the batch from the           --
 -- PAY_MESSAGE_LINES table.                                          --
 -- This can either be for whole batch or non-transferred part        --
 -- of the batch, where p_mode can be either Y or N.                  --
 -----------------------------------------------------------------------
--
procedure purge_messages
(
p_batch_id      in number,
p_mode          in varchar2
) is
--
  cursor pcl (p_batch_id number) is
  select batch_control_id
    from pay_batch_control_totals
   where batch_id = p_batch_id
     and (control_status <> 'T' or p_mode='Y');
--
  cursor pbl (p_batch_id number) is
  select batch_line_id
    from pay_batch_lines
   where batch_id = p_batch_id
     and (batch_line_status <> 'T' or p_mode='Y');
--
begin
--
 hr_utility.set_location('payplnk.purge_messages',5);
--
 for pclrec in pcl(p_batch_id) loop
    delete from pay_message_lines
    where  source_type = 'C'
    and    source_id = pclrec.batch_control_id;
 end loop;
--
 hr_utility.set_location('payplnk.purge_messages',10);
--
 for pblrec in pbl(p_batch_id) loop
    delete from pay_message_lines
    where  source_type = 'L'
    and    source_id = pblrec.batch_line_id;
 end loop;
--
 hr_utility.set_location('payplnk.purge_messages',20);
--
 delete from pay_message_lines
    where  source_type = 'H'
    and    source_id = p_batch_id
    and   (not exists
               (select null
                  from pay_batch_lines pbl
                 where pbl.batch_id = p_batch_id
                   and pbl.batch_line_status = 'T')
           or p_mode='Y');
--
 hr_utility.set_location('payplnk.purge_messages',25);
--
end purge_messages;
--
 ----------------------------------------------------------------------
 -- NAME                                                             --
 -- payplnk.insert_element_entry                 PRIVATE PROCEDURE   --
 --                                                                  --
 -- DESCRIPTION                                                      --
 -- Inserts an element entry into the PAY_ELEMENT_ENTRIES_F table    --
 ----------------------------------------------------------------------
--
procedure insert_element_entry
(
p_link_id               in     number,
l_line_record           in out nocopy csr_all_lines%ROWTYPE,
p_asg_act_id            in     number,
p_creator_type          in     varchar2,
p_absence_attendance_id in     number,
p_entry_values_count    in     number,
p_passed_inp_tbl        in     hr_entry.number_table,
p_passed_val_tbl        in     hr_entry.varchar2_table
) is
--
l_effective_end_date    date := null;
l_effective_start_date  date := null;
l_element_entry_id      number := null;
l_reason                hr_lookups.lookup_code%TYPE := null;
l_creator_id            number;
c_passed_inp_tbl        hr_entry.number_table;
c_passed_val_tbl        hr_entry.varchar2_table;
i                       binary_integer :=0;
j                       number;
--
cursor csr_check_classification is
select 'Y'
  from pay_element_types_f pet,
       pay_element_classifications pec
 where pet.element_type_id = l_line_record.element_type_id
   and pet.CLASSIFICATION_ID = pec.CLASSIFICATION_ID
   and pet.PROCESSING_TYPE = 'R'
   and pec.legislation_code is not null
   and pec.CLASSIFICATION_name like 'EXTERNAL_REPORTING%'
   and pec.legislation_code = 'GB';
--
l_dummy_chk varchar2(1);
l_stime          number(30);
l_etime          number(30);
l_time_out       boolean := FALSE;
--
begin
--
 hr_utility.set_location('payplnk.insert_element_entry',5);
--
-- Bug 423237 - Convert passed in reason to lookup_code for api
--
     IF l_line_record.reason IS NOT NULL THEN
        select hl.lookup_code
        into   l_reason
        from   hr_lookups hl
        where  hl.lookup_type = 'ELE_ENTRY_REASON'
        and    hl.meaning = l_line_record.reason;
     END IF;
--
--   If the element is an Abssnce Creator_type is 'A' and
--   Creator_id is the absence_attendance_id.
--   Otherwise creator_type is 'H' and the creator_id
--   is the batch_id.
--
     if (p_creator_type = 'A') then
        l_creator_id := p_absence_attendance_id;
     else
        l_creator_id := g_line_record.batch_id;
     end if;
--
     j := 1;
     --  Overiding version of the bug 1002790 fixes.
     for i in 1..p_entry_values_count loop
/** sbilling **/
         if p_passed_val_tbl.exists(i) and
                  p_passed_val_tbl(i) is not null then
            c_passed_inp_tbl(j) := p_passed_inp_tbl(i);
            c_passed_val_tbl(j) := p_passed_val_tbl(i);
            j := j + 1;
         end if;
     end loop;
--
     j := j - 1;

     if ghr_utility.is_ghr = 'TRUE' then
        hr_utility.set_location('GHR Installed....insert_element_entry .. Pre...',5);
        ghr_session.set_session_var_for_core
        (p_effective_date  => l_line_record.effective_date);
     end if;

     -- This is to support the predefined duration of the element, especially for GB.
     open csr_check_classification;
     fetch csr_check_classification into l_dummy_chk;
     if (csr_check_classification%found and l_line_record.effective_start_date is not null) then
        l_effective_start_date := l_line_record.effective_start_date;
     else
        l_effective_start_date := l_line_record.effective_date;
     end if;
     close csr_check_classification;

     -- Sets the start time.
     --
     if ( g_lock_max_wait > 0 ) then
        l_time_out := TRUE;
        select to_number(((to_char(sysdate, 'J') - 1 ) * 86400) +
               to_char(sysdate, 'SSSSS'))
          into l_stime
          from sys.dual;
     end if;
     --
     loop
        --
        begin
           --
           if (l_time_out) then
              savepoint INS_EE;
           end if;
           --
           hr_entry_api.insert_element_entry(
                 p_effective_start_date => l_effective_start_date,
                 p_effective_end_date => l_effective_end_date,
                 p_element_entry_id => l_element_entry_id,
                 p_assignment_id => l_line_record.assignment_id,
                 p_element_link_id => p_link_id,
                 p_creator_type => p_creator_type,
                 p_creator_id => l_creator_id,
                 p_entry_type => 'E',
                 p_cost_allocation_keyflex_id =>
                          l_line_record.cost_allocation_keyflex_id,
                 p_reason => l_reason,
                 --
                 p_subpriority => l_line_record.subpriority,
                 p_date_earned => l_line_record.date_earned,
                 p_personal_payment_method_id => l_line_record.personal_payment_method_id,
                 --
                 p_attribute_category => l_line_record.attribute_category,
                 p_attribute1 => l_line_record.attribute1,
                 p_attribute2 => l_line_record.attribute2,
                 p_attribute3 => l_line_record.attribute3,
                 p_attribute4 => l_line_record.attribute4,
                 p_attribute5 => l_line_record.attribute5,
                 p_attribute6 => l_line_record.attribute6,
                 p_attribute7 => l_line_record.attribute7,
                 p_attribute8 => l_line_record.attribute8,
                 p_attribute9 => l_line_record.attribute9,
                 p_attribute10 =>l_line_record.attribute10,
                 p_attribute11 =>l_line_record.attribute11,
                 p_attribute12 =>l_line_record.attribute12,
                 p_attribute13 =>l_line_record.attribute13,
                 p_attribute14 =>l_line_record.attribute14,
                 p_attribute15 =>l_line_record.attribute15,
                 p_attribute16 =>l_line_record.attribute16,
                 p_attribute17 =>l_line_record.attribute17,
                 p_attribute18 =>l_line_record.attribute18,
                 p_attribute19 =>l_line_record.attribute19,
                 p_attribute20 =>l_line_record.attribute20,
                 p_entry_information_category  => l_line_record.entry_information_category,
                 p_entry_information1          => l_line_record.entry_information1,
                 p_entry_information2          => l_line_record.entry_information2,
                 p_entry_information3          => l_line_record.entry_information3,
                 p_entry_information4          => l_line_record.entry_information4,
                 p_entry_information5          => l_line_record.entry_information5,
                 p_entry_information6          => l_line_record.entry_information6,
                 p_entry_information7          => l_line_record.entry_information7,
                 p_entry_information8          => l_line_record.entry_information8,
                 p_entry_information9          => l_line_record.entry_information9,
                 p_entry_information10         => l_line_record.entry_information10,
                 p_entry_information11         => l_line_record.entry_information11,
                 p_entry_information12         => l_line_record.entry_information12,
                 p_entry_information13         => l_line_record.entry_information13,
                 p_entry_information14         => l_line_record.entry_information14,
                 p_entry_information15         => l_line_record.entry_information15,
                 p_entry_information16         => l_line_record.entry_information16,
                 p_entry_information17         => l_line_record.entry_information17,
                 p_entry_information18         => l_line_record.entry_information18,
                 p_entry_information19         => l_line_record.entry_information19,
                 p_entry_information20         => l_line_record.entry_information20,
                 p_entry_information21         => l_line_record.entry_information21,
                 p_entry_information22         => l_line_record.entry_information22,
                 p_entry_information23         => l_line_record.entry_information23,
                 p_entry_information24         => l_line_record.entry_information24,
                 p_entry_information25         => l_line_record.entry_information25,
                 p_entry_information26         => l_line_record.entry_information26,
                 p_entry_information27         => l_line_record.entry_information27,
                 p_entry_information28         => l_line_record.entry_information28,
                 p_entry_information29         => l_line_record.entry_information29,
                 p_entry_information30         => l_line_record.entry_information30,
      /** sbilling **/
                 --p_num_entry_values => p_entry_values_count,
                 p_num_entry_values => j,
                 p_input_value_id_tbl => c_passed_inp_tbl,
                 p_entry_value_tbl => c_passed_val_tbl);
           --
           -- Exit the loop.
           exit;
           --
        exception
           --
           when others then
              hr_message.provide_error;
              if (l_time_out and hr_message.last_message_name = 'HR_7165_OBJECT_LOCKED') then
                 --
                 select to_number(((to_char(sysdate, 'J') - 1 ) * 86400) +
                        to_char(sysdate, 'SSSSS'))
                   into l_etime
                   from sys.dual;
                 --
                 if ( (l_etime - l_stime) >= g_lock_max_wait) then
                    raise;
                 end if;
                 --
                 rollback to INS_EE;
                 dbms_lock.sleep(g_lock_interval);
                 --
              else
                 raise;
              end if;
              --
           --
        end;
        --
     end loop;

     -- Set the origin of the entry as the batch and its assignment action.
     update pay_element_entries_f
        set source_id = p_asg_act_id
      where element_entry_id = l_element_entry_id;
     --

     open csr_check_classification;
     fetch csr_check_classification into l_dummy_chk;
     if (csr_check_classification%found and l_line_record.effective_end_date is not null and l_element_entry_id is not null) then
        l_effective_end_date := l_line_record.effective_end_date;
        hr_entry_api.delete_element_entry(p_dt_delete_mode   => 'DELETE',
                                          p_session_date     => l_effective_end_date,
                                          p_element_entry_id =>l_element_entry_id);
     end if;
     close csr_check_classification;


     if ghr_utility.is_ghr = 'TRUE' then
        hr_utility.set_location('GHR Installed....insert_element_entry .. Post ',6);
        ghr_history_api.post_update_process;
     end if;
--
 hr_utility.set_location('payplnk.insert_element_entry',10);
--
end insert_element_entry;
--
--
 ---------------------------------------------------------------------
 -- NAME                                                            --
 -- payplnk.update_element_entry                PRIVATE PROCEDURE   --
 --                                                                 --
 -- DESCRIPTION                                                     --
 -- Updates an existing element entry in the PAY_ELEMENT_ENTRIES_F  --
 -- table.                                                          --
 ---------------------------------------------------------------------
--
procedure update_element_entry
(
p_update_mode           in varchar2,
p_element_entry_id      in number,
p_creator_type          in varchar2,
p_creator_id            in number,
p_allow_rollback        in boolean,
p_asg_act_id            in number,
l_line_record           in csr_all_lines%ROWTYPE,
p_entry_values_count    in number,
p_passed_inp_tbl        in hr_entry.number_table,
p_passed_val_tbl        in hr_entry.varchar2_table
) is
--
l_reason                hr_lookups.lookup_code%TYPE := null;
--
l_stime          number(30);
l_etime          number(30);
l_time_out       boolean := FALSE;
--
begin
--
 hr_utility.set_location('payplnk.update_element_entry',5);
--
-- Bug 423237 - Convert passed in reason to lookup_code for api
--
     IF l_line_record.reason IS NOT NULL THEN
        select hl.lookup_code
        into   l_reason
        from   hr_lookups hl
        where  hl.lookup_type = 'ELE_ENTRY_REASON'
        and    hl.meaning = l_line_record.reason;
     END IF;
--
     if ghr_utility.is_ghr = 'TRUE' then
        hr_utility.set_location('GHR Installed....update_element_entry .. Pre ',5);
       ghr_session.set_session_var_for_core
       (p_effective_date  => l_line_record.effective_date);
     end if;

     -- Sets the start time.
     --
     if ( g_lock_max_wait > 0 ) then
        l_time_out := TRUE;
        select to_number(((to_char(sysdate, 'J') - 1 ) * 86400) +
               to_char(sysdate, 'SSSSS'))
          into l_stime
          from sys.dual;
     end if;
     --
     loop
        --
        begin
           --
           if (l_time_out) then
              savepoint UPD_EE;
           end if;
           --
           hr_entry_api.update_element_entry(
              p_dt_update_mode => p_update_mode,
              p_session_date => l_line_record.effective_date,
              p_element_entry_id => p_element_entry_id,
              p_cost_allocation_keyflex_id =>
                     l_line_record.cost_allocation_keyflex_id,
              p_reason => l_reason,
              --
              p_subpriority => l_line_record.subpriority,
              p_date_earned => l_line_record.date_earned,
              p_personal_payment_method_id => l_line_record.personal_payment_method_id,
              --
              p_creator_id => null,
              p_attribute_category => l_line_record.attribute_category,
              p_attribute1 => l_line_record.attribute1,
              p_attribute2 => l_line_record.attribute2,
              p_attribute3 => l_line_record.attribute3,
              p_attribute4 => l_line_record.attribute4,
              p_attribute5 => l_line_record.attribute5,
              p_attribute6 => l_line_record.attribute6,
              p_attribute7 => l_line_record.attribute7,
              p_attribute8 => l_line_record.attribute8,
              p_attribute9 => l_line_record.attribute9,
              p_attribute10 => l_line_record.attribute10,
              p_attribute11 => l_line_record.attribute11,
              p_attribute12 => l_line_record.attribute12,
              p_attribute13 => l_line_record.attribute13,
              p_attribute14 => l_line_record.attribute14,
              p_attribute15 => l_line_record.attribute15,
              p_attribute16 => l_line_record.attribute16,
              p_attribute17 => l_line_record.attribute17,
              p_attribute18 => l_line_record.attribute18,
              p_attribute19 => l_line_record.attribute19,
              p_attribute20 => l_line_record.attribute20,
             p_entry_information_category  => l_line_record.entry_information_category,
             p_entry_information1          => l_line_record.entry_information1,
             p_entry_information2          => l_line_record.entry_information2,
             p_entry_information3          => l_line_record.entry_information3,
             p_entry_information4          => l_line_record.entry_information4,
             p_entry_information5          => l_line_record.entry_information5,
             p_entry_information6          => l_line_record.entry_information6,
             p_entry_information7          => l_line_record.entry_information7,
             p_entry_information8          => l_line_record.entry_information8,
             p_entry_information9          => l_line_record.entry_information9,
             p_entry_information10         => l_line_record.entry_information10,
             p_entry_information11         => l_line_record.entry_information11,
             p_entry_information12         => l_line_record.entry_information12,
             p_entry_information13         => l_line_record.entry_information13,
             p_entry_information14         => l_line_record.entry_information14,
             p_entry_information15         => l_line_record.entry_information15,
             p_entry_information16         => l_line_record.entry_information16,
             p_entry_information17         => l_line_record.entry_information17,
             p_entry_information18         => l_line_record.entry_information18,
             p_entry_information19         => l_line_record.entry_information19,
             p_entry_information20         => l_line_record.entry_information20,
             p_entry_information21         => l_line_record.entry_information21,
             p_entry_information22         => l_line_record.entry_information22,
             p_entry_information23         => l_line_record.entry_information23,
             p_entry_information24         => l_line_record.entry_information24,
             p_entry_information25         => l_line_record.entry_information25,
             p_entry_information26         => l_line_record.entry_information26,
             p_entry_information27         => l_line_record.entry_information27,
             p_entry_information28         => l_line_record.entry_information28,
             p_entry_information29         => l_line_record.entry_information29,
             p_entry_information30         => l_line_record.entry_information30,
              p_num_entry_values => p_entry_values_count,
              p_input_value_id_tbl => p_passed_inp_tbl,
              p_entry_value_tbl => p_passed_val_tbl);
           --
           -- Exit the loop.
           exit;
           --
        exception
           --
           when others then
              hr_message.provide_error;
              if (l_time_out and hr_message.last_message_name = 'HR_7165_OBJECT_LOCKED') then
                 --
                 select to_number(((to_char(sysdate, 'J') - 1 ) * 86400) +
                        to_char(sysdate, 'SSSSS'))
                   into l_etime
                   from sys.dual;
                 --
                 if ( (l_etime - l_stime) >= g_lock_max_wait) then
                    raise;
                 end if;
                 --
                 rollback to UPD_EE;
                 dbms_lock.sleep(g_lock_interval);
                 --
              else
                 raise;
              end if;
              --
           --
        end;
        --
     end loop;


  if ghr_utility.is_ghr = 'TRUE' then
     hr_utility.set_location('GHR Installed....update_element_entry .. Post ',5);
     ghr_history_api.post_update_process;
  end if;

  -- For MIX rollback -  for non absence must set creator_id to null after update
                      -- for absence null batch_id on per_absence_attendances
                      -- for this element

  if (p_creator_type = 'A') then
--
      hr_utility.set_location('payplnk.update_element_entry',10);
--
      update per_absence_attendances
      set batch_id = null
      where absence_attendance_id = p_creator_id;
  else
--
      hr_utility.set_location('payplnk.update_element_entry',15);
--
      if p_allow_rollback then
         --Recurring element of creator type 'H' or 'F' with update and update insert change.
         --
         update pay_element_entries_f
         set    creator_id = p_creator_id,
                creator_type = p_creator_type,
                source_id = p_asg_act_id
         where  element_entry_id = p_element_entry_id
         and    l_line_record.effective_date between effective_start_date
                                                 and effective_end_date
         and    creator_type     in ('H','F');
      else
         --Non-recurring.
         --
         update pay_element_entries_f
         set    creator_id = null,
                source_id = null
         where  element_entry_id = p_element_entry_id
         and    l_line_record.effective_date between effective_start_date
                                                 and effective_end_date
         and    creator_type ='H';
      end if;
  end if;

--
 hr_utility.set_location('payplnk.update_element_entry',20);
--
end update_element_entry;
--
end payplnk;

/
