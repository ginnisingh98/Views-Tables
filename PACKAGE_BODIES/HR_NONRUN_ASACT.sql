--------------------------------------------------------
--  DDL for Package Body HR_NONRUN_ASACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NONRUN_ASACT" as
/* $Header: pynonrun.pkb 120.15.12010000.5 2009/09/10 06:56:24 pparate ship $ */
--
--
g_lckhandle varchar2(128);
cached      boolean := FALSE;
g_many_procs_in_period varchar2(80);
g_plsql_proc_insert varchar2(80);
g_set_date_earned      pay_action_parameters.parameter_value%type;
g_contrib_payments_exist boolean := null;
--
   -------------------------------- rangerow ----------------------------------
   /*
      NAME
         update_pact - update payroll action row.
      DESCRIPTION
         Updates relevant information on the payroll action row.
         This includes the action_population_status and the
         date_earned value.  This is obtained in accordance with
         the new period dates fix.
      NOTES
         <none>
   */
   procedure update_pact
   (
      p_payroll_action_id           in number,
      p_action_population_status    in varchar2,
      p_action_type                 in varchar2,
      p_last_update_date            in date,
      p_last_updated_by             in number,
      p_last_update_login           in number
   ) is
      l_date_earned date;
   begin
       if (g_set_date_earned = 'Y') then
--
          select /*+ USE_NL(locked_pact locked locking locks)*/
                 max(date_earned)
          into   l_date_earned
          from   pay_payroll_actions    locked_pact,
                 pay_assignment_actions locked,
                 pay_assignment_actions locking,
                 pay_action_interlocks  locks
          where  locking.payroll_action_id    = p_payroll_action_id
          and    locking.assignment_action_id = locks.locking_action_id
          and    locked.assignment_action_id  = locks.locked_action_id
          and    locked.payroll_action_id     = locked_pact.payroll_action_id;
--
       else
          l_date_earned := null;
       end if;
--
     if (p_action_type in ('R', 'Q', 'B', 'V')) then
        update pay_payroll_actions pac
        set    pac.action_population_status = p_action_population_status,
               pac.last_update_date         = p_last_update_date,
               pac.last_updated_by          = p_last_updated_by,
               pac.last_update_login        = p_last_update_login
        where  pac.payroll_action_id        = p_payroll_action_id;
     elsif (p_action_type not in ('X', 'H')) then
        update pay_payroll_actions pac
        set    pac.action_population_status = p_action_population_status,
               pac.last_update_date         = p_last_update_date,
               pac.last_updated_by          = p_last_updated_by,
               pac.last_update_login        = p_last_update_login,
               pac.date_earned              = l_date_earned
        where  pac.payroll_action_id        = p_payroll_action_id;
     else
        update pay_payroll_actions pac
        set    pac.action_population_status = p_action_population_status,
               pac.last_update_date         = p_last_update_date,
               pac.last_updated_by          = p_last_updated_by,
               pac.last_update_login        = p_last_update_login,
               pac.date_earned              = l_date_earned
        where  pac.payroll_action_id        = p_payroll_action_id;
     end if;
--
   end update_pact;
--
   ---------------------------get_next_pop_chunk_seq-------------------------
   /*
      NAME
         get_next_pop_chunk - Get the Next Popultaion chunk by Sequence
      DESCRIPTION
         Locks and returns person range information from
         pay_population_ranges. This is used to insert
         a chunk of assignments at a time.
      NOTES
         <none>
   */
   procedure get_next_pop_chunk_seq
   (
      pactid      in            number,   -- payroll_action_id.
      atype       in            varchar2, -- action type.
      p_lckhandle in            varchar2, -- dbms_lock id
      lub         in            varchar2, -- last_updated_by.
      lul         in            varchar2, -- last_update_login.
      stperson       out nocopy number,  -- starting_person_id.
      endperson      out nocopy number,  -- ending_person_id.
      chunk          out nocopy number,  -- chunk_number.
      rand_chunk     out nocopy number   -- chunk_number.
   ) is
      actpopstat varchar2(30);
      norows     boolean;      -- used to decide if sql stat has returned rows.
      dummy      number;       -- need because must select into something.
      found      boolean;
      ret        number;
--
   begin
      -- get current action_population_status.
      found := FALSE;
      while (found = FALSE) loop

         /* First thing to do is get a lock before entering the
            critical section
         */
         ret := dbms_lock.request(
                  lockhandle         => p_lckhandle,
                  lockmode           => dbms_lock.x_mode,
                  release_on_commit  => TRUE);
--
         if (ret <> 0) then
            hr_utility.set_message(801,'HR_289135_NO_LOCK_GAINED');
            hr_utility.set_message_token('LOCKNAME','PAY_PAYROLL_ACTIONS_'||pactid);
            hr_utility.set_message_token('LOCKERR',ret);
            hr_utility.raise_error;
         end if;
--
         select pac.action_population_status
         into   actpopstat
         from   pay_payroll_actions pac
         where  pac.payroll_action_id = pactid;
--
         -- only bother to process if status is not complete.
         if(actpopstat <> 'C'and actpopstat <> 'A' and actpopstat <> 'E') then
            -- select a range row for update.
            begin
               norows := FALSE;
               -- check to see if want to use randomised chnks or sequential
--
               select rge.starting_person_id,
                   rge.ending_person_id,
                   rge.chunk_number,
                   nvl(rge.rand_chunk_number,rge.chunk_number)
               into   stperson,
                   endperson,
                   chunk,
                   rand_chunk
               from   pay_population_ranges rge
               where  rge.payroll_action_id = pactid
               and    rge.range_status      = 'U'
               and    rownum < 2;
               found := TRUE;
--
               exception
               when no_data_found then norows := TRUE;
--
               when others then
                    rollback;
                    raise;
            end;
--
            -- if no rows remain unprocessed.
            if(norows) then
               -- see if there are any rows at all.
               -- there may be if other processes are still
               -- inserting assignment actions.
               begin
                  norows := FALSE;
--
                  select null
                  into   dummy
                  from   pay_population_ranges rge
                  where  rge.payroll_action_id = pactid
                  and    rownum < 2;
--
               exception
                  when no_data_found then
                       norows := TRUE;
               end;
--
               -- if there are no rows at all, i.e. no one is
               -- doing any processing, indicate everything is done.
               -- This should only be done if the Range code has finished
               -- processing.
               if(norows) then
                  if (actpopstat <> 'R') then
                     update_pact(pactid, 'A', atype,sysdate,lub,lul);
                     found := TRUE;
--
                  end if;
                  commit;
                  chunk := NULL;
               else
                  chunk := NULL;
                  /* Release dbms_lock */
                  commit;
               end if;
            end if;
         else

            -- see if there any Errored rows

            if(actpopstat = 'E') then
               -- raise the error to cause death of thread

               rollback;
               hr_utility.set_message(801,'HR_34988_TERMINATE_THREAD');
               hr_utility.raise_error;

            else
               chunk := NULL; -- nothing left to process.
               found := TRUE;
               /* Release dbms_lock */
               commit;
            end if;
         end if;
      end loop;
   end get_next_pop_chunk_seq;
--
   ---------------------------lock_pop_chunk----------------------
   /*
      NAME
         lock_pop_chunk - Lock population Chunk
      DESCRIPTION
         This locks the population Chunk using the PAY_CHUNK_STATUS table
      NOTES
         <none>
   */
   procedure lock_pop_chunk
   (
      pactid       in            number,  -- payroll_action_id.
      p_next_chunk in            number,  -- Chunk to be locked
      p_found      in out nocopy boolean, -- Able to lock row.
      stperson        out nocopy number,  -- starting_person_id.
      endperson       out nocopy number,  -- ending_person_id.
      chunk           out nocopy number,  -- chunk_number.
      rand_chunk      out nocopy number   -- chunk_number.
   ) is
     l_lckhandle varchar2(128);
     ret        number;
     chk_pop_status pay_chunk_status.population_status%type;
     act_pop_status pay_payroll_actions.action_population_status%type;
   begin
        /* OK we have the next chunk lets lock it and confirm that its
           unprocessed
        */
--
        dbms_lock.allocate_unique(
           lockname         => 'PAY_CHUNK_STATUS'||pactid||'_'||p_next_chunk,
           lockhandle       => l_lckhandle);
--
        ret := dbms_lock.request(
                 lockhandle         => l_lckhandle,
                 lockmode           => dbms_lock.x_mode,
                 release_on_commit  => TRUE);
        if (ret <> 0) then
           hr_utility.set_message(801,'HR_289135_NO_LOCK_GAINED');
           hr_utility.set_message_token('LOCKNAME',
                             'PAY_CHUNK_STATUS'||pactid||'_'||p_next_chunk);
           hr_utility.set_message_token('LOCKERR',ret);
           hr_utility.raise_error;
        end if;
--
        /* OK we need to be careful here.
           We are looping through the chunks
           to populate them, but the status columns
           belong to the processing side of the code.
           This causes a problem with randomisation
           We need to update the randonised status columns
        */
        select pcs_rand.population_status,
               ppa.action_population_status
          into chk_pop_status,
               act_pop_status
          from pay_payroll_actions ppa,
               pay_chunk_status    pcs_pop,
               pay_chunk_status    pcs_rand
         where pcs_pop.payroll_action_id  = pactid
           and pcs_pop.chunk_number       = p_next_chunk
           and pcs_rand.payroll_action_id = pcs_pop.payroll_action_id
           and pcs_rand.chunk_number      = pcs_pop.rand_chunk_number
           and ppa.payroll_action_id = pcs_pop.payroll_action_id;
--
        if (    act_pop_status <> 'C'
            and act_pop_status <> 'A'
            and act_pop_status <> 'E') then
--
          /* If the chunk is unprocessed then process it
             other wise look to mark the population status
          */

          if (chk_pop_status = 'U') then
--
            select rge.starting_person_id,
                   rge.ending_person_id,
                   rge.chunk_number,
                   nvl(rge.rand_chunk_number,rge.chunk_number)
              into
                   stperson,
                   endperson,
                   chunk,
                   rand_chunk
              from pay_population_ranges rge
             where rge.payroll_action_id = pactid
               and rge.chunk_number = p_next_chunk
               and rownum = 1;
--
            p_found := TRUE;
--
          else
--
            /* Another thread must have processed the chunk */
--
            chunk := NULL;
            /* Release dbms_lock */
            commit;
          end if;
--
        else
            -- see if there any Errored rows

            if(act_pop_status = 'E') then
               -- raise the error to cause death of thread

               rollback;
               hr_utility.set_message(801,'HR_34988_TERMINATE_THREAD');
               hr_utility.raise_error;

            else
               chunk := NULL; -- nothing left to process.
               p_found := TRUE;
               /* Release dbms_lock */
               commit;
            end if;
        end if;
   end  lock_pop_chunk;
--
   ---------------------------get_next_pop_chunk_unalloc----------------------
   /*
      NAME
         get_next_pop_chunk_unalloc - Get the Next Popultaion chunk by
                                    Unalloaction
      DESCRIPTION
         Use the Unallocation method to get the next chunk.
      NOTES
         <none>
   */
   procedure get_next_pop_chunk_unalloc
   (
      pactid      in            number,   -- payroll_action_id.
      atype       in            varchar2, -- action type.
      p_lckhandle in            varchar2, -- dbms_lock id for pactid
      lub         in            varchar2, -- last_updated_by.
      lul         in            varchar2, -- last_update_login.
      stperson       out nocopy number,  -- starting_person_id.
      endperson      out nocopy number,  -- ending_person_id.
      chunk          out nocopy number,  -- chunk_number.
      rand_chunk     out nocopy number   -- chunk_number.
   ) is
     next_chunk number;
     found      boolean;
     l_lckhandle varchar2(128);
     ret        number;
     act_pop_status pay_payroll_actions.action_population_status%type;
     norows     boolean;      -- used to decide if sql stat has returned rows.
     dummy      number;       -- need because must select into something.
   begin
--
     found := FALSE;
     while (found = FALSE) loop
--
        select max(chunk_number)
          into next_chunk
          from pay_chunk_status
         where payroll_action_id = pactid
           and population_status = 'U';
--
        if (next_chunk is null) then
--
           -- There doesn't seem to be any rows left to process
           -- hence lock the payroll action, and update the population
           -- status, when there are no rows
--
           /* First thing to do is get a lock before entering the
              critical section
           */
           ret := dbms_lock.request(
                    lockhandle         => p_lckhandle,
                    lockmode           => dbms_lock.x_mode,
                    release_on_commit  => TRUE);
--
           if (ret <> 0) then
              hr_utility.set_message(801,'HR_289135_NO_LOCK_GAINED');
              hr_utility.set_message_token('LOCKNAME','PAY_PAYROLL_ACTIONS_'||pactid);
              hr_utility.set_message_token('LOCKERR',ret);
              hr_utility.raise_error;
           end if;
--
           select
                  ppa.action_population_status
             into
                  act_pop_status
             from pay_payroll_actions ppa
            where ppa.payroll_action_id = pactid;
--
           if (    act_pop_status <> 'C'
               and act_pop_status <> 'A'
               and act_pop_status <> 'E') then
--
               -- see if there are any rows at all.
               -- there may be if other processes are still
               -- inserting assignment actions.
               begin
                  norows := FALSE;
--
                  select null
                  into   dummy
                  from   pay_population_ranges rge
                  where  rge.payroll_action_id = pactid
                  and    rownum < 2;
--
               exception
                  when no_data_found then
                       norows := TRUE;
               end;
--
               -- if there are no rows at all, i.e. no one is
               -- doing any processing, indicate everything is done.
               -- This should only be done if the Range code has finished
               -- processing.
               if(norows) then
                  if (act_pop_status <> 'R') then
                     update_pact(pactid, 'A', atype,sysdate,lub,lul);
                     found := TRUE;
--
                  end if;
                  commit;
                  chunk := NULL;
               else
                  chunk := NULL;
                  /* Release dbms_lock */
                  commit;
               end if;
--
           else
               -- see if there any Errored rows

               if(act_pop_status = 'E') then
                  -- raise the error to cause death of thread

                  rollback;
                  hr_utility.set_message(801,'HR_34988_TERMINATE_THREAD');
                  hr_utility.raise_error;

               else
                  chunk := NULL; -- nothing left to process.
                  found := TRUE;
                  /* Release dbms_lock */
                  commit;
               end if;
           end if;
--
        else
--
          lock_pop_chunk
          (
            pactid       => pactid,
            p_next_chunk => next_chunk,
            p_found      => found,
            stperson     => stperson,
            endperson    => endperson,
            chunk        => chunk,
            rand_chunk   => rand_chunk
          );
--
        end if;
--
     end loop;
   end get_next_pop_chunk_unalloc;
--
   ---------------------------get_next_pop_chunk_prealloc----------------------
   /*
      NAME
         get_next_pop_chunk_prealloc - Get the Next Popultaion chunk by
                                    Prealloaction
      DESCRIPTION
         Use the Preallocation method to get the next chunk.
      NOTES
         <none>
   */
   procedure get_next_pop_chunk_prealloc
   (
      pactid      in            number,   -- payroll_action_id.
      atype       in            varchar2, -- action type.
      p_lckhandle in            varchar2, -- dbms_lock id for pact
      lub         in            varchar2, -- last_updated_by.
      lul         in            varchar2, -- last_update_login.
      chunk_type  in out nocopy varchar2, -- method for allocating chunk
      threads     in            number   default 1, -- Number of Threads
      slave_no    in            number   default 1, -- Slave no
      curr_chunk  in            number   default 1, -- current chunk
      max_chunks  in            number   default 9999, -- Max no of Chunks
      stperson       out nocopy number,  -- starting_person_id.
      endperson      out nocopy number,  -- ending_person_id.
      chunk          out nocopy number,  -- chunk_number.
      rand_chunk     out nocopy number   -- chunk_number.
   ) is
     next_chunk number;
     found      boolean;
     pay_pop_status pay_payroll_actions.action_population_status%type;
     chk_pop_status pay_chunk_status.population_status%type;
     get_paused boolean;
   begin
--
     found := FALSE;
     next_chunk := curr_chunk;
     get_paused := FALSE;
     while (found = FALSE) loop
--
        if (get_paused <> TRUE) then
          if (next_chunk = 0 ) then
             next_chunk := slave_no;
          else
             next_chunk := next_chunk + threads;
          end if;
        end if;
        get_paused := FALSE;
--
        select action_population_status
          into pay_pop_status
          from pay_payroll_actions
         where payroll_action_id = pactid;
--
        begin
--
          select population_status
            into chk_pop_status
            from pay_chunk_status
           where payroll_action_id = pactid
             and chunk_number = next_chunk;
--
           /* Now lock the chunk for processing */
--
           lock_pop_chunk
           (
             pactid       => pactid,
             p_next_chunk => next_chunk,
             p_found      => found,
             stperson     => stperson,
             endperson    => endperson,
             chunk        => chunk,
             rand_chunk   => rand_chunk
           );
--
        exception
           when no_data_found then
--
              /* If we've processed all our Preallocated
                 chunks, search for any unallocated chunks
              */
--
              if (pay_pop_status = 'R') then
                get_paused := TRUE;
              else
                 get_next_pop_chunk_unalloc
                 (
                    pactid      => pactid,
                    atype       => atype,
                    p_lckhandle => p_lckhandle,
                    lub         => lub,
                    lul         => lul,
                    stperson    => stperson,
                    endperson   => endperson,
                    chunk       => chunk,
                    rand_chunk  => rand_chunk
                 );
                 chunk_type := 'UNALLOCATED';
                 found := TRUE;
              end if;
        end;
--
      end loop;
--
   end get_next_pop_chunk_prealloc;
--
   ---------------------------get_next_pop_chunk----------------------------
   /*
      NAME
         get_next_pop_chunk - Get the Next Popultaion chunk to process
      DESCRIPTION
         Locks and returns person range information from
         pay_population_ranges. This is used to insert
         a chunk of assignments at a time.
      NOTES
         <none>
   */
   procedure get_next_pop_chunk
   (
      pactid      in            number,   -- payroll_action_id.
      atype       in            varchar2, -- action type.
      p_lckhandle in            varchar2, -- dbms_lock id
      lub         in            varchar2, -- last_updated_by.
      lul         in            varchar2, -- last_update_login.
      chunk_type  in out nocopy varchar2, -- method for allocating chunk
      threads     in            number   default 1, -- Number of Threads
      slave_no    in            number   default 1, -- Slave no
      curr_chunk  in            number   default 1, -- current chunk
      max_chunks  in            number   default 9999, -- Max no of Chunks
      stperson       out nocopy number,  -- starting_person_id.
      endperson      out nocopy number,  -- ending_person_id.
      chunk          out nocopy number,  -- chunk_number.
      rand_chunk     out nocopy number   -- chunk_number.
   ) is
      actpopstat varchar2(30);
      norows     boolean;      -- used to decide if sql stat has returned rows.
      dummy      number;       -- need because must select into something.
      found      boolean;
      ret        number;
--
   begin
--
     if (chunk_type = 'PREALLOCATED') then
        get_next_pop_chunk_prealloc
        (
           pactid      => pactid,
           atype       => atype,
           p_lckhandle => p_lckhandle,
           lub         => lub,
           lul         => lul,
           chunk_type  => chunk_type,
           threads     => threads,
           slave_no    => slave_no,
           curr_chunk  => curr_chunk,
           max_chunks  => max_chunks,
           stperson    => stperson,
           endperson   => endperson,
           chunk       => chunk,
           rand_chunk  => rand_chunk
        );
     elsif (chunk_type = 'UNALLOCATED') then
        get_next_pop_chunk_unalloc
        (
           pactid      => pactid,
           atype       => atype,
           p_lckhandle => p_lckhandle,
           lub         => lub,
           lul         => lul,
           stperson    => stperson,
           endperson   => endperson,
           chunk       => chunk,
           rand_chunk  => rand_chunk
        );
     else
--
        /* Both ORIGINAL and SEQUENCED use sequenced method */
--
        get_next_pop_chunk_seq(
                 pactid      => pactid,
                 atype       => atype,
                 p_lckhandle => p_lckhandle,
                 lub         => lub,
                 lul         => lul,
                 stperson    => stperson,
                 endperson   => endperson,
                 chunk       => chunk,
                 rand_chunk  => rand_chunk
              );
     end if;
--
   end get_next_pop_chunk;
--
   ---------------------------get_next_pop_chunk_seq-------------------------
   /*
      NAME
         get_next_pop_chunk - Get the Next Process chunk by Sequence
      DESCRIPTION
         Use the Sequence method to get the next chunk.
      NOTES
         <none>
   */
   procedure get_next_proc_chunk_seq
   (
      pactid      in            number,   -- payroll_action_id.
      curr_chunk  in out nocopy number   -- chunk_number.
   )
   is
--
   next_chunk        number;
   pop_chunk_number number;
   action_status     pay_payroll_actions.action_status%type;
   action_pop_status pay_payroll_actions.action_population_status%type;
   l_dummy           number;
   found             boolean;
--
   begin
--
     found := FALSE;
     while (found = FALSE) loop
--
       select PAC.current_chunk_number + 1,
              PAC.action_status,
              PAC.action_population_status
       into   next_chunk,
              action_status,
              action_pop_status
       from   pay_payroll_actions PAC
       where  PAC.payroll_action_id = pactid
       for update of PAC.current_chunk_number;
--
       if (action_status = 'C') then
         curr_chunk := 0;
         found := TRUE;
       elsif (action_status = 'E') then
         curr_chunk := 0;
         hr_utility.set_message(801,'HR_6859_HRPROC_OTHER_PROC_ERR');
         hr_utility.raise_error;
       elsif (action_status = 'P') then
--
         declare
           got_chunk      boolean;
           chk_pop_status pay_chunk_status.population_status%type;
         begin
--
           select pcs.population_status
             into chk_pop_status
             from pay_chunk_status pcs
            where pcs.payroll_action_id    = pactid
              and pcs.chunk_number         = next_chunk;
--
           got_chunk := FALSE;
           if (chk_pop_status = 'C') then
             got_chunk := TRUE;
           elsif (chk_pop_status = 'E') then
              curr_chunk := 0;
              hr_utility.set_message(801,'HR_6859_HRPROC_OTHER_PROC_ERR');
              hr_utility.raise_error;
           end if;
--
           if (got_chunk = TRUE) then
--
             update pay_payroll_actions pac
             set    pac.current_chunk_number = next_chunk
             where  pac.payroll_action_id    = pactid;
--
             update pay_chunk_status
                set process_status = 'P'
              where payroll_action_id       = pactid
                and chunk_number = next_chunk;
--
             curr_chunk := next_chunk;
             found := TRUE;
--
           else
--
             /* Release the lock, let something else try locking the
                payroll action
             */
             rollback;
           end if;
--
         exception
            when no_data_found then
               if (action_pop_status <> 'R') then
                  got_chunk := FALSE;
                  curr_chunk := 0;
                  found := TRUE;
               end if;
--
         end;
       else
              pay_core_utils.assert_condition(
                       'hr_nonrun_asact.get_next_proc_chunk_seq:1',
                       1 = 2);
       end if;
     end loop;
--
   end get_next_proc_chunk_seq;
--
   ---------------------------get_next_proc_chunk_unalloc----------------------
   /*
      NAME
         get_next_proc_chunk_unalloc - Get the Next Process chunk by
                                    Unalloaction
      DESCRIPTION
         Use the Unallocation method to get the next chunk.
      NOTES
   */
   procedure get_next_proc_chunk_unalloc
   (
      pactid      in            number,   -- payroll_action_id.
      curr_chunk  in out nocopy number    -- Current Chunk
   ) is
     next_chunk        number;
     proc_chunk_number number;
     found             boolean;
     pact_act_status   varchar2(30);
     act_pop_status    varchar2(30);
     chk_status        varchar2(30);
   begin
--
     found := FALSE;
     while (found = FALSE) loop
--
        select max(chunk_number)
          into next_chunk
          from pay_chunk_status
         where payroll_action_id = pactid
           and process_status = 'U'
           and population_status = 'C';
--
        select action_status,
               action_population_status
          into pact_act_status,
               act_pop_status
          from pay_payrolL_actions
         where payroll_action_id = pactid;
--
        if (next_chunk is not null) then
--
          select process_status
            into chk_status
            from pay_chunk_status
           where payroll_action_id = pactid
             and chunk_number = next_chunk
             for update of process_status;
--
          if (pact_act_status = 'C') then
--
             next_chunk := 0;
             found := TRUE;
--
          elsif (pact_act_status = 'E') then
--
             hr_utility.set_message(801,'HR_6859_HRPROC_OTHER_PROC_ERR');
             hr_utility.raise_error;
--
          elsif (pact_act_status = 'P') then
--
             if (chk_status = 'U') then
--
               update pay_chunk_status
                  set process_status = 'P'
                where payroll_action_id = pactid
                  and chunk_number = next_chunk;

               curr_chunk := next_chunk;
               found := TRUE;
--
             end if;
--
          else
              pay_core_utils.assert_condition(
                       'hr_nonrun_asact.get_next_proc_chunk_unalloc:1',
                       1 = 2);
          end if;
        else
              /* Either there is nothing left
                 or a population error has occured
                 or populations not got this far
              */
              if (   act_pop_status = 'C'
                  or act_pop_status = 'A'
                 ) then
--
                 /* No chunks left
                 */
                 curr_chunk := 0;
                 found := TRUE;
--
              elsif (act_pop_status = 'E') then
--
                hr_utility.set_message(801,'HR_6859_HRPROC_OTHER_PROC_ERR');
                hr_utility.raise_error;
--
              end if;
        end if;
--
     end loop;
--
   end get_next_proc_chunk_unalloc;
--
   ---------------------------get_next_proc_chunk_prealloc--------------------
   /*
      NAME
         get_next_proc_chunk_prealloc - Get the Next Process chunk by
                                    Prealloaction
      DESCRIPTION
         Use the Preallocation method to get the next chunk.
      NOTES
         <none>
   */
   procedure get_next_proc_chunk_prealloc
   (
      pactid      in            number,   -- payroll_action_id.
      chunk_type  in out nocopy varchar2, -- method for allocating chunk
      threads     in            number   default 1, -- Number of Threads
      slave_no    in            number   default 1, -- Slave no
      curr_chunk  in out nocopy number    -- current chunk
   ) is
     next_chunk number;
     found      boolean;
     pact_act_status pay_payroll_actions.action_status%type;
     act_pop_status  pay_payroll_actions.action_population_status%type;
     chk_status      pay_chunk_status.process_status%type;
   begin
--
     found := FALSE;
     next_chunk := curr_chunk;
     while (found = FALSE) loop
--
        if (next_chunk = 0 ) then
           next_chunk := slave_no;
        else
           next_chunk := next_chunk + threads;
        end if;
--
        select action_status, action_population_status
          into pact_act_status,
               act_pop_status
          from pay_payroll_actions
         where payroll_action_id = pactid;
--
        begin
--
          select process_status
            into chk_status
            from pay_chunk_status
           where payroll_action_id = pactid
             and chunk_number = next_chunk
             for update of process_status;
--
          if (pact_act_status = 'C') then
--
             next_chunk := 0;
             found := TRUE;
--
          elsif (pact_act_status = 'E') then
--
             hr_utility.set_message(801,'HR_6859_HRPROC_OTHER_PROC_ERR');
             hr_utility.raise_error;
--
          elsif (pact_act_status = 'P') then
--
             if (chk_status = 'U') then
--
               update pay_chunk_status
                  set process_status = 'P'
                where payroll_action_id = pactid
                  and chunk_number = next_chunk;
--
               curr_chunk := next_chunk;
               found := TRUE;
--
             end if;
--
           else
             pay_core_utils.assert_condition(
                      'hr_nonrun_asact.get_next_proc_chunk_prealloc:1',
                      1 = 2);
           end if;
--
        exception
           when no_data_found then
--
              /* Either there is nothing left thats
                 been preallocated for this thread
                 or a population error has occured
                 or populations not got this far
              */
              if (   act_pop_status = 'C'
                  or act_pop_status = 'A'
                 ) then
--
                 /* No preallocated left, go for
                    the unallocated
                 */
                 get_next_proc_chunk_unalloc
                 (
                    pactid      => pactid,
                    curr_chunk  => curr_chunk
                 );
--
                 chunk_type := 'UNALLOCATED';
                 found := TRUE;
--
              elsif (act_pop_status = 'E') then
--
                hr_utility.set_message(801,'HR_6859_HRPROC_OTHER_PROC_ERR');
                hr_utility.raise_error;
--
              end if;
        end;
--
     end loop;
--
   end get_next_proc_chunk_prealloc;
--
   ---------------------------get_next_proc_chunk----------------------------
   /*
      NAME
         get_next_proc_chunk - Get the Next Process chunk to process
      DESCRIPTION
         Locks and returns person range information from
         pay_population_ranges. This is used to insert
         a chunk of assignments at a time.
      NOTES
         There is a COMMIT in this procedure to release
         the locks and update tables.
   */
   procedure get_next_proc_chunk
   (
      pactid      in            number,   -- payroll_action_id.
      chunk_type  in out nocopy varchar2, -- method for allocating chunk
      threads     in            number   default 1, -- Number of Threads
      slave_no    in            number   default 1, -- Slave no
      curr_chunk  in out nocopy number    -- current chunk
   ) is
--
   begin
--
     -- Before we do any thing mark the previous chunk as complete
     if (curr_chunk <> 0) then
--
       update pay_chunk_status
          set process_status = 'C'
        where payroll_action_id = pactid
          and chunk_number = curr_chunk;
--
     end if;
--
     if (chunk_type = 'PREALLOCATED') then
--
        get_next_proc_chunk_prealloc
        (
           pactid      => pactid,
           chunk_type  => chunk_type,
           threads     => threads,
           slave_no    => slave_no,
           curr_chunk  => curr_chunk
        );
--
     elsif (chunk_type = 'UNALLOCATED') then
--
        get_next_proc_chunk_unalloc
        (
          pactid      => pactid,
          curr_chunk  => curr_chunk
        );
--
     elsif (chunk_type = 'SEQUENCED') then
--
        get_next_proc_chunk_seq
        (
           pactid      => pactid,
           curr_chunk  => curr_chunk
        );
--
     else
--
        /* Should not get here, ORIGINAL method is done by C Code */
--
        pay_core_utils.assert_condition(
                  'hr_nonrun_asact.get_next_proc_chunk:1',
                  1 = 2);
--
     end if;
--
     commit;
--
   end get_next_proc_chunk;
--
   -------------------------------- rangerow ----------------------------------
   /*
      NAME
         rangerow - return info from range row.
      DESCRIPTION
         Locks and returns person range information from
         pay_population_ranges. This is used to insert
         a chunk of assignments at a time.

         This is a cover for get_next_pop_chunk
      NOTES
         <none>
   */
   procedure rangerow
   (
      pactid    in            number,   -- payroll_action_id.
      lub       in            varchar2, -- last_updated_by.
      lul       in            varchar2, -- last_update_login.
      stperson     out nocopy number,  -- starting_person_id.
      endperson    out nocopy number,  -- ending_person_id.
      chunk        out nocopy number,  -- chunk_number.
      rand_chunk   out nocopy number,  -- chunk_number.
      atype     in            varchar2  -- action type.
   ) is
   l_chunk_type varchar2(30);
   begin
       l_chunk_type := 'ORIGINAL';
       get_next_pop_chunk
         (
           pactid      => pactid,
           atype       => atype,
           p_lckhandle => g_lckhandle,
           lub         => lub,
           lul         => lul,
           chunk_type  => l_chunk_type,
           stperson    => stperson,
           endperson   => endperson,
           chunk       => chunk,
           rand_chunk  => rand_chunk
         );
   end rangerow;
--
   ---------------------------- reinterlock_child  -----------------------------
   /*
      NAME
         reinterlock - Re Inserts Interlocks.
      DESCRIPTION
         Simply re inserts interlock rows for a child action.
      NOTES
         This procedure recursively calls itself in case the child action
         has children of its own.
   */
   procedure reinterlock_child
   (
      p_pp_assact number,
      p_run_assact number,
      p_asg_id     number,
      p_pact_id    number,
      p_actype varchar2
   ) is
     cursor get_lockers (p_run_act number,
                         p_pre_act number,
                         p_asg_id number,
                         p_pact_id number)
     is
     select paa.assignment_action_id
       from pay_assignment_actions paa
      where paa.source_action_id = p_run_act
        and paa.assignment_id = p_asg_id
        and paa.payroll_action_id = p_pact_id
        and not exists (select ''
                          from pay_action_interlocks pai2
                         where pai2.locking_action_id = p_pre_act
                           and pai2.locked_action_id = paa.assignment_action_id
                       );
--
      cursor get_cost_lockers (p_cost_act number, p_run_act number)
     is
     select paa.assignment_action_id
       from pay_action_classifications pcl,
            pay_payroll_actions pac,
            pay_assignment_actions paa,
            pay_action_interlocks  pai
      where pai.locked_action_id = p_run_act
        and pai.locking_action_id = paa.assignment_action_id
        and paa.assignment_action_id <> p_cost_act
        and pac.payroll_action_id = paa.payroll_action_id
        and pcl.action_type = pac.action_type
        and pcl.classification_name = 'TRANSGL'
        and not exists (select ''
                          from pay_action_interlocks pai2
                         where pai2.locking_action_id = p_cost_act
                           and pai2.locked_action_id = paa.assignment_action_id
                       );
--
   begin
--
     for locrec in get_lockers(p_run_assact,
                               p_pp_assact,
                               p_asg_id,
                               p_pact_id) loop
--
       insint(p_pp_assact, locrec.assignment_action_id);

       if (p_actype = 'S') then
           for costrec in get_cost_lockers(p_pp_assact, locrec.assignment_action_id) loop
               insint(p_pp_assact, costrec.assignment_action_id);
           end loop;
       end if;
--
       -- Now recursively call the procedure to create interlocks for its
       -- Child actions.
       reinterlock_child(
                          p_pp_assact,
                          locrec.assignment_action_id,
                          p_asg_id,
                          p_pact_id,
                          p_actype
                        );
--
     end loop;
--
   end reinterlock_child;
--
   ---------------------------------- reinterlock  ----------------------------------
   /*
      NAME
         reinterlock - Re Inserts Interlocks.
      DESCRIPTION
         Simply re inserts interlock rows. Based on the primary (master) interlocked
         action.
      NOTES
         <none>
   */
   procedure reinterlock
   (
      p_assact number,
      p_actype varchar2 default 'U'
   ) is
--
     cursor get_master_actions(p_act number)
     is
     select paa.assignment_action_id,
            paa.assignment_id,
            paa.payroll_action_id
       from pay_action_interlocks pai,
            pay_assignment_actions paa
      where pai.locking_action_id = p_act
        and pai.locked_action_id = paa.assignment_action_id
        and paa.source_action_id is null;
--
   begin
      for masterrec in get_master_actions(p_assact) loop
         reinterlock_child(p_assact,
                           masterrec.assignment_action_id,
                           masterrec.assignment_id,
                           masterrec.payroll_action_id,
                           p_actype);
      end loop;
   end reinterlock;
--
   ---------------------------------- insint ----------------------------------
   /*
      NAME
         insint - insert interlock row.
      DESCRIPTION
         Simply inserts an interlock row. Does not commit.
      NOTES
         <none>
   */
   procedure insint
   (
      lockingactid in number,
      lockedactid  in number
   ) is
   begin
      insert  into pay_action_interlocks (
              locking_action_id,
              locked_action_id)
      values (lockingactid,
              lockedactid);
   end insint;
--
   ---------------------------------- insact ----------------------------------
   /*
      NAME
         insact - insert assignment action row.
      DESCRIPTION
         inserts row into pay_assignment_actions. Does not commit.
      NOTES
         <none>
   */
   procedure insact
   (
      lockingactid in number,                -- locking_action_id.
      assignid     in number default null,   -- assignment_id
      pactid       in number,                -- payroll_action_id
      chunk        in number,                -- chunk_number
      greid        in number default null,   -- GRE id.
      prepayid     in number   default null, -- pre_payment_id.
      status       in varchar2 default 'U',  -- action_status.
      source_act   in number default null,   -- source_action_id
      object_id    in number default null,   -- object id
      object_type  in varchar2 default null, -- object type
      start_date   in date default null,     -- start date
      end_date     in date default null,     -- end date
      p_transient_action in boolean default false -- Transient Action
   ) is
--
   l_transient_action boolean;
   l_action_type      pay_payroll_actions.action_type%type;
   l_report_type      pay_payroll_actions.report_type%type;
   l_report_qualifier pay_payroll_actions.report_qualifier%type;
   l_report_category  pay_payroll_actions.report_category%type;
   l_eff_date         pay_payroll_actions.effective_date%type;
   l_temp_act_flag    pay_report_format_mappings_f.temporary_action_flag%type;
--
   begin
--
     select action_type,
            report_type,
            report_qualifier,
            report_category,
            effective_date
       into l_action_type,
            l_report_type,
            l_report_qualifier,
            l_report_category,
            l_eff_date
       from pay_payroll_actions
      where payroll_action_id = pactid;
--
     l_transient_action := FALSE;
--
     if (l_action_type = 'X') then
--
        select temporary_action_flag
          into l_temp_act_flag
          from pay_report_format_mappings_f
         where report_type = l_report_type
           and report_qualifier = l_report_qualifier
           and report_category = l_report_category
           and l_eff_date between effective_start_date
                              and effective_end_date;
--
        if (l_temp_act_flag = 'Y') then
          l_transient_action := TRUE;
        elsif (p_transient_action) then
          l_transient_action := TRUE;
        end if;
--
     end if;
--
     if (l_transient_action) then
--
      if (object_type not in ('PER', 'ASG', 'PET')) then
--
            pay_core_utils.assert_condition(
                     'hr_nonrun_asact.insact:1',
                     1 = 2);
--
      end if;
--
      insert into pay_temp_object_actions (
             object_action_id,
             object_id,
             object_type,
             payroll_action_id,
             action_status,
             chunk_number,
             action_sequence,
             object_version_number
             )
      select lockingactid,
             object_id,
             object_type,
             pactid,
             status,
             chunk,
             pay_assignment_actions_s.nextval,
             1
      from   dual;
     else
      insert into pay_assignment_actions (
             assignment_action_id,
             assignment_id,
             payroll_action_id,
             action_status,
             chunk_number,
             action_sequence,
             pre_payment_id,
             object_version_number,
             tax_unit_id,
             source_action_id,
             object_id,
             object_type,
             start_date,
             end_date)
      select lockingactid,
             assignid,
             pactid,
             status,
             chunk,
             pay_assignment_actions_s.nextval,
             prepayid,
             1,
             greid,
             source_act,
             object_id,
             object_type,
             start_date,
             end_date
      from   dual;
     end if;
   end insact;
--
   --------------------------------- proccash ---------------------------------
   /*
      NAME
         proccash - process a single chunk for cash action.
      DESCRIPTION
         This function takes a range as defined by the starting and
         ending person_id and inserts a chunk of assignment actions
         plus their associated interlock rows. This function for the
         cash action only.
      NOTES
         <none>
   */
   procedure proccash
   (
      pactid    in number,   -- payroll_action_id.
      stperson  in number,   -- starting person_id of range.
      endperson in number,   -- ending person_id of range.
      chunk     in number,   -- current chunk_number.
      rand_chunk in number,   -- current chunk_number.
      itpflg    in varchar2, -- legislation type.
      use_pop_person in number -- use population_ranges person_id column
   ) is
      cursor cashpopcur
      (
         pactid    number,
         chunk     number,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             INDEX(pa2 PAY_PAYROLL_ACTIONS_N5)
             INDEX(pos PER_PERIODS_OF_SERVICE_N3)
             INDEX(as1 PER_ASSIGNMENTS_N4)
             INDEX(as2 PER_ASSIGNMENTS_F_PK)
             INDEX(act PAY_ASSIGNMENT_ACTIONS_N51)
             index(opm PAY_ORG_PAYMENT_METHODS_F_PK)
             USE_NL(pop pos ppp opm as1 act as2) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppp.pre_payment_id
      from   pay_payroll_actions            pa1,
             pay_payroll_actions            pa2,
             pay_action_classifications     pcl,
             pay_population_ranges          pop,
             per_periods_of_service         pos,
             per_all_assignments_f          as1,
             pay_assignment_actions         act,
             per_all_assignments_f          as2,
             pay_pre_payments               ppp,
             pay_org_payment_methods_f      opm
      where  pa1.payroll_action_id          = pactid
      and    pa2.consolidation_set_id  +0   = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id          = pa2.payroll_action_id
      and    act.action_status              = 'C'
      and    pcl.classification_name        = 'CASHED'
      and    pa2.action_type                = pcl.action_type
      and    as1.assignment_id              = act.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id              = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id + 0             = as1.payroll_id + 0
      and    pos.period_of_service_id       = as1.period_of_service_id
      and    pop.payroll_action_id          = pactid
      and    pop.chunk_number               = chunk
      and    pos.person_id                  = pop.person_id
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    ppp.assignment_action_id       = act.assignment_action_id
      and    opm.org_payment_method_id      = ppp.org_payment_method_id
      and    pa1.effective_date between
             opm.effective_start_date and opm.effective_end_date
      and    opm.payment_type_id            = pa1.payment_type_id
      and   (opm.org_payment_method_id = pa1.org_payment_method_id
          or pa1.org_payment_method_id is null)
      and    not exists (
             select null
             from   pay_assignment_actions ac2,
                    pay_action_interlocks  int
             where  int.locked_action_id     = act.assignment_action_id
             and    ac2.assignment_action_id = int.locking_action_id
             and    ac2.pre_payment_id       = ppp.pre_payment_id)
      and    not exists (
             select null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
      cursor cashcur
      (
         pactid    number,
         stperson  number,
         endperson number,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             INDEX(pa2 PAY_PAYROLL_ACTIONS_N5)
             INDEX(pos PER_PERIODS_OF_SERVICE_N3)
             INDEX(as1 PER_ASSIGNMENTS_N4)
             INDEX(as2 PER_ASSIGNMENTS_F_PK)
             INDEX(act PAY_ASSIGNMENT_ACTIONS_N51)
             index(opm PAY_ORG_PAYMENT_METHODS_F_PK)
             USE_NL(pos ppp opm as1 act as2) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppp.pre_payment_id
      from   pay_payroll_actions            pa1,
             pay_payroll_actions            pa2,
             pay_action_classifications     pcl,
             per_periods_of_service         pos,
             per_all_assignments_f          as1,
             pay_assignment_actions         act,
             per_all_assignments_f          as2,
             pay_pre_payments               ppp,
             pay_org_payment_methods_f      opm
      where  pa1.payroll_action_id          = pactid
      and    pa2.consolidation_set_id  +0   = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id          = pa2.payroll_action_id
      and    act.action_status              = 'C'
      and    pcl.classification_name        = 'CASHED'
      and    pa2.action_type                = pcl.action_type
      and    as1.assignment_id              = act.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id              = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id + 0             = as1.payroll_id + 0
      and    pos.period_of_service_id       = as1.period_of_service_id
      and    pos.person_id between stperson and endperson
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    ppp.assignment_action_id       = act.assignment_action_id
      and    opm.org_payment_method_id      = ppp.org_payment_method_id
      and    pa1.effective_date between
             opm.effective_start_date and opm.effective_end_date
      and    opm.payment_type_id            = pa1.payment_type_id
      and   (opm.org_payment_method_id = pa1.org_payment_method_id
          or pa1.org_payment_method_id is null)
      and    not exists (
             select null
             from   pay_assignment_actions ac2,
                    pay_action_interlocks  int
             where  int.locked_action_id     = act.assignment_action_id
             and    ac2.assignment_action_id = int.locking_action_id
             and    ac2.pre_payment_id       = ppp.pre_payment_id)
      and    not exists (
             select null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
      cursor cashmpipcur
      (
         pactid    number,
         chunk     number,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             INDEX(pa2 PAY_PAYROLL_ACTIONS_PK)
             INDEX(pos PER_PERIODS_OF_SERVICE_N3)
             INDEX(as1 PER_ASSIGNMENTS_N4)
             INDEX(as2 PER_ASSIGNMENTS_F_PK)
             INDEX(act PAY_ASSIGNMENT_ACTIONS_N51)
             index(opm PAY_ORG_PAYMENT_METHODS_F_PK)
             USE_NL(pos pop ppp opm as1 act as2) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppp.pre_payment_id
      from   pay_payroll_actions            pa1,
             pay_population_ranges          pop,
             per_periods_of_service         pos,
             per_all_assignments_f          as1,
             pay_assignment_actions         act,
             pay_payroll_actions            pa2,
             pay_action_classifications     pcl,
             per_all_assignments_f          as2,
             pay_pre_payments               ppp,
             pay_org_payment_methods_f      opm
      where  pa1.payroll_action_id          = pactid
      and    pa2.consolidation_set_id  +0   = pa1.consolidation_set_id
      and    pa1.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id          = pa2.payroll_action_id
      and    act.action_status              = 'C'
      and    pcl.classification_name        = 'CASHED'
      and    pa2.action_type                = pcl.action_type
      and    as1.assignment_id              = act.assignment_id
      and    pa1.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id              = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id + 0             = as1.payroll_id + 0
      and    pos.period_of_service_id       = as1.period_of_service_id
      and    pop.payroll_action_id          = pactid
      and    pop.chunk_number               = chunk
      and    pos.person_id                  = pop.person_id
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    ppp.assignment_action_id       = act.assignment_action_id
      and    opm.org_payment_method_id      = ppp.org_payment_method_id
      and    pa1.effective_date between
             opm.effective_start_date and opm.effective_end_date
      and    opm.payment_type_id            = pa1.payment_type_id
      and   (opm.org_payment_method_id = pa1.org_payment_method_id
          or pa1.org_payment_method_id is null)
      and    not exists (
             select null
             from   pay_assignment_actions ac2,
                    pay_action_interlocks  int
             where  int.locked_action_id     = act.assignment_action_id
             and    ac2.assignment_action_id = int.locking_action_id
             and    ac2.pre_payment_id       = ppp.pre_payment_id)
      and    not exists (
             select null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
      lockingactid  number;
      lockedactid   number;
      assignid      number;
      prepayid      number;
      greid         number;
--
   begin
      if (g_many_procs_in_period = 'Y') then
         open cashmpipcur(pactid,chunk,itpflg);
      elsif (use_pop_person = 1) then
         open cashpopcur(pactid,chunk,itpflg);
      else
         open cashcur(pactid,stperson,endperson,itpflg);
      end if;
      loop
         if (g_many_procs_in_period = 'Y') then
            fetch cashmpipcur into lockedactid,assignid,greid,prepayid;
            exit when cashmpipcur%notfound;
         elsif (use_pop_person = 1) then
            fetch cashpopcur into lockedactid,assignid,greid,prepayid;
            exit when cashpopcur%notfound;
         else
            fetch cashcur into lockedactid,assignid,greid,prepayid;
            exit when cashcur%notfound;
         end if;
--
         -- want to insert an assignment action for each of the
         -- rows that we return from the cursor, i.e. one for
         -- each assignment/pre-payment.
         select pay_assignment_actions_s.nextval
         into   lockingactid
         from   dual;
--
         -- insert the action record.
         -- Note, insert as complete, because we need no further processing.
         insact(lockingactid,assignid,pactid,rand_chunk,greid,prepayid,'C');
--
         -- insert an interlock to this action.
         insint(lockingactid,lockedactid);
--
      end loop;
      if (g_many_procs_in_period = 'Y') then
         close cashmpipcur;
      elsif (use_pop_person = 1) then
         close cashpopcur;
      else
         close cashcur;
      end if;
      commit;
   end proccash;
--
   procedure procpru
   (
      pactid        in number,
      stperson      in number,
      endperson     in number,
      chunk         in number,
      rand_chunk    in number,
      class         in varchar2,
      itpflg        in varchar2,
      use_pop_person in number
   )
   is
      cursor prupaycur
      (
         pactid    number,
         stperson  number,
         endperson number,
         class     varchar2,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_N5)
             index(as1 PER_ASSIGNMENTS_F_N4)
             USE_NL(pos as1) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_payroll_actions        pa1,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             per_periods_of_service     pos,
             per_all_assignments_f      as1,
             pay_assignment_actions     act
      where  pa1.payroll_action_id    = pactid
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    pa2.consolidation_set_id      = pa1.consolidation_set_id
      and    act.payroll_action_id         = pa2.payroll_action_id
      and    act.action_status             in ('C','S')
      and    pcl.classification_name       = class
      and    pa2.action_type               = pcl.action_type
      and    as1.assignment_id             = act.assignment_id
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    pos.period_of_service_id = as1.period_of_service_id
      and    pos.person_id between stperson and endperson
      and    exists (
                  select ''
                    from pay_pre_payments           ppp
                   where ppp.assignment_action_id = act.assignment_action_id
                     and ppp.organization_id is not null
                     and nvl(ppp.effective_date, pa2.effective_date)
                                          <= pa1.effective_date
                     and    not exists (
                            select null
                              from pay_contributing_payments
                             where contributing_pre_payment_id =
                                                   ppp.pre_payment_id
                            )
                      )
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ( 'C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as1.person_id)
      order by as1.person_id,as1.primary_flag desc ,as1.effective_start_date,act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
      cursor prupaypopcur
      (
         pactid    number,
         chunk     number,
         class     varchar2,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_N5)
             index(as1 PER_ASSIGNMENTS_F_N4)
             USE_NL(pos as1) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_payroll_actions        pa1,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             pay_population_ranges      pop,
             per_periods_of_service     pos,
             per_all_assignments_f      as1,
             pay_assignment_actions     act
      where  pa1.payroll_action_id    = pactid
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    pa2.consolidation_set_id      = pa1.consolidation_set_id
      and    act.payroll_action_id         = pa2.payroll_action_id
      and    act.action_status             in ('C','S')
      and    pcl.classification_name       = class
      and    pa2.action_type               = pcl.action_type
      and    as1.assignment_id             = act.assignment_id
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    pos.period_of_service_id = as1.period_of_service_id
      and    pop.chunk_number              = chunk
      and    pop.payroll_action_id         = pactid
      and    pos.person_id                 = pop.person_id
      and    exists (
                  select ''
                    from pay_pre_payments           ppp
                   where ppp.assignment_action_id = act.assignment_action_id
                     and ppp.organization_id is not null
                     and nvl(ppp.effective_date, pa2.effective_date)
                                          <= pa1.effective_date
                     and    not exists (
                            select null
                              from pay_contributing_payments
                             where contributing_pre_payment_id =
                                                   ppp.pre_payment_id
                            )
                      )
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ( 'C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as1.person_id)
      order by as1.person_id,as1.primary_flag desc ,as1.effective_start_date,act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
--
   lockingactid  number;
   lockedactid   number;
   assignid      number;
   prev_assignid number;
   greid         number;
--
   begin
--
      pay_proc_logging.PY_ENTRY('hr_nonrun_asact.procpru');
--
      prev_assignid := null;
--
      pay_proc_logging.PY_LOG('stperson '||stperson);
      pay_proc_logging.PY_LOG('endperson '||endperson);
      pay_proc_logging.PY_LOG('chunk '||chunk);
--
      if (use_pop_person = 1) then
         open prupaypopcur(pactid,chunk,class,itpflg);
      else
         open prupaycur(pactid,stperson,endperson,class,itpflg);
      end if;
      loop
         if (use_pop_person = 1) then
            fetch prupaypopcur into lockedactid,
                                 assignid,
                                 greid;
            exit when prupaypopcur%notfound;
         else
            fetch prupaycur into lockedactid,
                                 assignid,
                                 greid;
            exit when prupaycur%notfound;
         end if;

         /* process the insert of assignment actions */
         /* logic prevents more than one action per assignment */
         if(prev_assignid is null OR prev_assignid <> assignid) then
            -- get a value for the action id that is locking.
            select pay_assignment_actions_s.nextval
            into   lockingactid
            from   dual;
--
            -- insert into pay_assignment_actions.
            insact(lockingactid,assignid,pactid,rand_chunk,greid);
         end if;
--
         -- insert into interlocks table.
         insint(lockingactid,lockedactid);
         prev_assignid := assignid;

      end loop;
--
      if (use_pop_person = 1) then
         close prupaypopcur;
      else
         close prupaycur;
      end if;
      commit;
--
      pay_proc_logging.PY_EXIT('hr_nonrun_asact.procpru');
--
   end procpru;
--
   procedure procorgpyt
   (
      pactid    in number,   -- payroll_action_id.
      chunk     in number,   -- current chunk_number.
      rand_chunk in number,   -- current chunk_number.
      ptype     in number,   -- payment_type_id.
      class     in varchar2  -- payment classification.
   )
   is
      cursor paymentorg
      (
         pactid    number,
         chunk  number,
         ptype     number,
         class     varchar2
      ) is
      SELECT  /*+ ORDERED
              */
             pcp.assignment_action_id,
             hou.organization_id,
             ppp.pre_payment_id
      from   pay_payroll_actions        pa1,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             pay_population_ranges      pop,
             hr_organization_units      hou,
             pay_pre_payments               ppp,
             pay_org_payment_methods_f      opm,
             pay_contributing_payments      pcp
      where  pa1.payroll_action_id          = pactid
      and    pa2.consolidation_set_id +0    = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    pa2.action_status              = 'C'
      and    pcl.classification_name        = class
      and    pa2.action_type                = pcl.action_type
--
      and    pop.payroll_action_id          = pactid
      and    pop.chunk_number               = chunk
      and    hou.organization_id            = pop.source_id
--
      and   (pa2.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    ppp.payroll_action_id          = pa2.payroll_action_id
      and    ppp.organization_id            = hou.organization_id
      and    opm.org_payment_method_id      = ppp.org_payment_method_id
      and    pa1.effective_date between
             opm.effective_start_date and opm.effective_end_date
      and    opm.payment_type_id +0         = ptype
      and   (opm.org_payment_method_id = pa1.org_payment_method_id
             or pa1.org_payment_method_id is null)
      and    pcp.pre_payment_id             = ppp.pre_payment_id
--
      and   not exists (
         select /*+ ORDERED*/
                null
         from
                pay_assignment_actions ac2
         where ac2.pre_payment_id        = ppp.pre_payment_id
        )
      order by hou.organization_id, ppp.pre_payment_id
      for update of hou.organization_id;
--
      l_prepayid    pay_pre_payments.pre_payment_id%type;
      prev_prepayid pay_pre_payments.pre_payment_id%type;
      lockedactid   pay_assignment_actions.assignment_action_id%type;
      lockingactid  pay_assignment_actions.assignment_action_id%type;
      orgid         hr_organization_units.organization_id%type;
      l_cp          number;
--
   begin
--
      pay_proc_logging.PY_ENTRY('hr_nonrun_asact.procorgpyt');
--
--    Check if need to run this cursor - by looking for rows in
--    pay_contributing_payments
--
      if (g_contrib_payments_exist is null) then
         begin
            select 1
            into l_cp
            from pay_payroll_actions pa1
            where pa1.payroll_action_id = pactid
            and exists
                (select 1
                 from pay_payroll_actions pa2,
                      pay_contributing_payments pcp
                 where pa2.payroll_action_id = pcp.payroll_action_id
                 and   pa2.action_type       = 'PRU'
                 and   pa2.business_group_id = pa1.business_group_id);

            g_contrib_payments_exist := TRUE;
         exception
            when others then
                g_contrib_payments_exist := FALSE;
         end;
      end if;
--
      if (g_contrib_payments_exist = TRUE) then
--
         pay_proc_logging.PY_LOG('chunk '||chunk);
--
         prev_prepayid := null;
         open paymentorg(pactid,chunk,ptype, class);
         loop
            fetch paymentorg into lockedactid,
                                  orgid,
                                  l_prepayid;
            exit when paymentorg%notfound;

            /* process the insert of assignment actions */
            /* logic prevents more than one action per assignment */
            if(prev_prepayid is null OR prev_prepayid <> l_prepayid) then
               -- get a value for the action id that is locking.
               select pay_assignment_actions_s.nextval
               into   lockingactid
               from   dual;
--
               -- insert into pay_assignment_actions.
               insact(lockingactid => lockingactid,
                      pactid       => pactid,
                      chunk        => rand_chunk,
                      prepayid     => l_prepayid,
                      object_id    => orgid,
                      object_type  => 'HOU');
            end if;
--
            -- insert into interlocks table.
            insint(lockingactid,lockedactid);
            prev_prepayid := l_prepayid;
--
         end loop;
--
         close paymentorg;
--
      end if;
--
      pay_proc_logging.PY_EXIT('hr_nonrun_asact.procorgpyt');
--
   end procorgpyt;
--
   procedure procchq
   (
      pactid    in number,   -- payroll_action_id.
      stperson  in number,   -- starting person_id of range.
      endperson in number,   -- ending person_id of range.
      chunk     in number,   -- current chunk_number.
      rand_chunk in number,   -- current chunk_number.
      itpflg    in varchar2, -- legislation type.
      ptype     in number,   -- payment_type_id.
      class     in varchar2, -- payment classification.
      use_pop_person in number -- use population_ranges person_id column
   ) is
--
      cursor paymentpopcur
      (
         pactid    number,
         chunk  number,
         itpflg    varchar2,
         ptype     number,
         class     varchar2
      ) is
      SELECT  /*+ ORDERED
            index(pa2 PAY_PAYROLL_ACTIONS_N5)
             index(as1 PER_ASSIGNMENTS_F_N4)
             index(as2 PER_ASSIGNMENTS_F_PK)
             index(opm PAY_ORG_PAYMENT_METHODS_F_PK)
             USE_NL(pop pos as1 as2) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppp.pre_payment_id,
             pa1.assignment_set_id,
             as1.payroll_id
      from   pay_payroll_actions        pa1,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             pay_population_ranges      pop,
             per_periods_of_service     pos,
             per_all_assignments_f      as1,
             pay_assignment_actions     act,
             pay_pre_payments               ppp,
             per_all_assignments_f          as2,
             pay_org_payment_methods_f      opm
      where  pa1.payroll_action_id          = pactid
      and    pa2.consolidation_set_id +0    = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id          = pa2.payroll_action_id
      and    act.action_status              = 'C'
      and    pcl.classification_name        = class
      and    pa2.action_type                = pcl.action_type
      and    as1.assignment_id              = act.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id              = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id + 0             = as1.payroll_id + 0
      and    pos.period_of_service_id       = as1.period_of_service_id
      and    pop.payroll_action_id          = pactid
      and    pop.chunk_number               = chunk
      and    pos.person_id                  = pop.person_id
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    ppp.assignment_action_id       = act.assignment_action_id
      and    opm.org_payment_method_id      = ppp.org_payment_method_id
      and    ppp.organization_id is null
      and    pa1.effective_date between
             opm.effective_start_date and opm.effective_end_date
      and    opm.payment_type_id +0         = ptype
      and   (opm.org_payment_method_id = pa1.org_payment_method_id
             or pa1.org_payment_method_id is null)
      and   not exists (
         select /*+ ORDERED*/
                null
         from   pay_action_interlocks  int,
                pay_assignment_actions ac2
         where  int.locked_action_id      = act.assignment_action_id
         and    ac2.assignment_action_id  = int.locking_action_id
         and    ac2.pre_payment_id        = ppp.pre_payment_id
         and  not exists (
             select null
               from pay_assignment_actions paa_void,
                    pay_action_interlocks  pai_void,
                    pay_payroll_actions    ppa_void
              where pai_void.locked_action_id = ac2.assignment_action_id
                and pai_void.locking_action_id = paa_void.assignment_action_id
                and paa_void.payroll_action_id = ppa_void.payroll_action_id
                and ppa_void.action_type = 'D')
        )
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
              and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status   not in ('C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
      cursor paymentcur
      (
         pactid    number,
         stperson  number,
         endperson number,
         itpflg    varchar2,
         ptype     number,
         class     varchar2
      ) is
      SELECT  /*+ ORDERED
            index(pa2 PAY_PAYROLL_ACTIONS_N5)
             index(as1 PER_ASSIGNMENTS_F_N4)
             index(as2 PER_ASSIGNMENTS_F_PK)
             index(opm PAY_ORG_PAYMENT_METHODS_F_PK)
             USE_NL(pos as1 as2) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppp.pre_payment_id,
             pa1.assignment_set_id,
             as1.payroll_id
      from   pay_payroll_actions        pa1,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             per_periods_of_service     pos,
             per_all_assignments_f      as1,
             pay_assignment_actions     act,
             pay_pre_payments               ppp,
             per_all_assignments_f          as2,
             pay_org_payment_methods_f      opm
      where  pa1.payroll_action_id          = pactid
      and    pa2.consolidation_set_id +0    = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id          = pa2.payroll_action_id
      and    act.action_status              = 'C'
      and    pcl.classification_name        = class
      and    pa2.action_type                = pcl.action_type
      and    as1.assignment_id              = act.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id              = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id + 0             = as1.payroll_id + 0
      and    pos.period_of_service_id       = as1.period_of_service_id
      and    pos.person_id between stperson and endperson
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    ppp.assignment_action_id       = act.assignment_action_id
      and    opm.org_payment_method_id      = ppp.org_payment_method_id
      and    ppp.organization_id is null
      and    pa1.effective_date between
             opm.effective_start_date and opm.effective_end_date
      and    opm.payment_type_id +0         = ptype
      and   (opm.org_payment_method_id = pa1.org_payment_method_id
             or pa1.org_payment_method_id is null)
      and   not exists (
         select /*+ ORDERED*/
                null
         from   pay_action_interlocks  int,
                pay_assignment_actions ac2
         where  int.locked_action_id      = act.assignment_action_id
         and    ac2.assignment_action_id  = int.locking_action_id
         and    ac2.pre_payment_id        = ppp.pre_payment_id
         and  not exists (
             select null
               from pay_assignment_actions paa_void,
                    pay_action_interlocks  pai_void,
                    pay_payroll_actions    ppa_void
              where pai_void.locked_action_id = ac2.assignment_action_id
                and pai_void.locking_action_id = paa_void.assignment_action_id
                and paa_void.payroll_action_id = ppa_void.payroll_action_id
                and ppa_void.action_type = 'D')
        )
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
              and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status   not in ('C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
      cursor paymentmpipcur
      (
         pactid    number,
         chunk     number,
         itpflg    varchar2,
         ptype     number,
         class     varchar2
      ) is
      SELECT /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_PK)
             index(pos PER_PERIODS_OF_SERVICE_N3)
             index(as1 PER_ASSIGNMENTS_F_N4)
             index(act PAY_ASSIGNMENT_ACTIONS_N51)
             index(as2 PER_ASSIGNMENTS_F_PK)
             index(opm PAY_ORG_PAYMENT_METHODS_F_PK)
             USE_NL(pos pop act pa2 as1 as2) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppp.pre_payment_id,
             pa1.assignment_set_id,
             as1.payroll_id
      from   pay_payroll_actions        pa1,
             pay_population_ranges      pop,
             per_periods_of_service     pos,
             per_all_assignments_f      as1,
             pay_assignment_actions     act,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             pay_pre_payments               ppp,
             per_all_assignments_f          as2,
             pay_org_payment_methods_f      opm
      where  pa1.payroll_action_id          = pactid
      and    pa2.consolidation_set_id + 0       = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id          = pa2.payroll_action_id
      and    act.action_status              = 'C'
      and    pcl.classification_name        = class
      and    pa2.action_type                = pcl.action_type
      and    as1.assignment_id              = act.assignment_id
      and    pa1.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id              = act.assignment_id
      and    pa2.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id + 0             = as1.payroll_id + 0
      and    pos.period_of_service_id       = as1.period_of_service_id
      and    pop.payroll_action_id          = pactid
      and    pop.chunk_number               = chunk
      and    pos.person_id                  = pop.person_id
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    ppp.assignment_action_id       = act.assignment_action_id
      and    opm.org_payment_method_id      = ppp.org_payment_method_id
      and    pa1.effective_date between
             opm.effective_start_date and opm.effective_end_date
      and    opm.payment_type_id +0         = ptype
      and    ppp.organization_id is null
      and   (opm.org_payment_method_id = pa1.org_payment_method_id
             or pa1.org_payment_method_id is null)
      and   not exists (
         select /*+ ORDERED*/
                null
         from   pay_action_interlocks  int,
                pay_assignment_actions ac2
         where  int.locked_action_id      = act.assignment_action_id
         and    ac2.assignment_action_id  = int.locking_action_id
         and    ac2.pre_payment_id        = ppp.pre_payment_id
         and  not exists (
             select null
               from pay_assignment_actions paa_void,
                    pay_action_interlocks  pai_void,
                    pay_payroll_actions    ppa_void
              where pai_void.locked_action_id = ac2.assignment_action_id
                and pai_void.locking_action_id = paa_void.assignment_action_id
                and paa_void.payroll_action_id = ppa_void.payroll_action_id
                and ppa_void.action_type = 'D')
        )
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
              and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status   not in ('C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
      cursor chkasg
      (
         pasgsetid  number,
         ppayrollid number,
         pasgid     number,
         plockedid  number
      ) is
      SELECT 1
        FROM hr_assignment_sets aset
       WHERE aset.assignment_set_id = pasgsetid
         and nvl(aset.payroll_id,ppayrollid) = ppayrollid
         and (not exists
                 (select 1
                    from hr_assignment_set_amendments hasa
                   where hasa.assignment_set_id = aset.assignment_set_id
                     and hasa.include_or_exclude = 'I')
              or exists
                 (select 1
                    from hr_assignment_set_amendments hasa
                   where hasa.assignment_set_id = aset.assignment_set_id
                     and hasa.assignment_id = pasgid
                     and hasa.include_or_exclude = 'I'))
         and not exists
                 (select 1
                    from hr_assignment_set_amendments hasa
                   where hasa.assignment_set_id = aset.assignment_set_id
                     and hasa.assignment_id = pasgid
                     and hasa.include_or_exclude = 'E')
         -- Ensure there exists a voided check for this payment.
         and exists
             (select 1
                from pay_action_interlocks lck1,
                     pay_assignment_actions chk_paa,
                     pay_payroll_actions chk_ppa,
                     pay_action_interlocks lck2,
                     pay_assignment_actions vd_paa,
                     pay_payroll_actions vd_ppa
               where lck1.locked_action_id = plockedid
                 and lck1.locking_action_id = chk_paa.assignment_action_id
                 and chk_paa.payroll_action_id = chk_ppa.payroll_action_id
                 and chk_ppa.action_type = 'H'
                 and lck2.locked_action_id = chk_paa.assignment_action_id
                 and lck2.locking_action_id = vd_paa.assignment_action_id
                 and vd_paa.payroll_action_id = vd_ppa.payroll_action_id
                 and vd_ppa.action_type = 'D');
--
      lockingactid  number;
      lockedactid   number;
      assignid      number;
      prepayid      number;
      greid         number;
--
      asgsetid      number;
      payrollid     number;
      inasgset      boolean;
      dummy         number;
--
   -- algorithm is quite similar to the other process cases,
   -- but we have to take into account assignments and
   -- personal payment methods.
   begin
      if (g_many_procs_in_period = 'Y') then
         open paymentmpipcur(pactid,chunk,itpflg,ptype,class);
      elsif (use_pop_person = 1) then
         open paymentpopcur(pactid,chunk,itpflg,ptype,class);
      else
         open paymentcur(pactid,stperson,endperson,itpflg,ptype,class);
      end if;
      loop
         if (g_many_procs_in_period = 'Y') then
            fetch paymentmpipcur into lockedactid,assignid,greid,prepayid,asgsetid,payrollid;
            exit when paymentmpipcur%notfound;
         elsif (use_pop_person = 1) then
            fetch paymentpopcur into lockedactid,assignid,greid,prepayid,asgsetid,payrollid;
            exit when paymentpopcur%notfound;
         else
            fetch paymentcur into lockedactid,assignid,greid,prepayid,asgsetid,payrollid;
            exit when paymentcur%notfound;
         end if;
--
        inasgset := TRUE;
        --
        if asgsetid is not null then
           open chkasg(asgsetid,payrollid,assignid,lockedactid);
           fetch chkasg into dummy;
           --
           if chkasg%notfound then
              inasgset := FALSE;
           end if;
           --
           close chkasg;
        end if;
--
        -- Only create the assignment action if the assignment is part
        -- of the assignment set.
        if inasgset then
           -- we need to insert one action for each of the
           -- rows that we return from the cursor (i.e. one
           -- for each assignment/pre-payment).
           select pay_assignment_actions_s.nextval
           into   lockingactid
           from   dual;
--
           -- insert the action record.
           insact(lockingactid,assignid,pactid,rand_chunk,greid,prepayid);
--
           -- insert an interlock to this action.
           insint(lockingactid,lockedactid);
        end if;
--
      end loop;
      if (g_many_procs_in_period = 'Y') then
         close paymentmpipcur;
      elsif (use_pop_person = 1) then
         close paymentpopcur;
      else
         close paymentcur;
      end if;
--
      -- Now populate the org payments
      procorgpyt
      (
         pactid     => pactid,
         chunk      => chunk,
         rand_chunk => rand_chunk,
         ptype      => ptype,
         class      => class
      );
--
      commit;
   end procchq;
--
   ---------------------------------- procmag ---------------------------------
   /*
      NAME
         procmag - process a single chunk for magnetic transfer process.
      DESCRIPTION
         This function takes a range as defined by the starting and
         ending person_id and inserts a chunk of assignment actions
         plus their associated interlock rows. This function for the
         magnetic transfer action only.
      NOTES
         <none>
   */
   procedure procmag
   (
      pactid    in number,   -- payroll_action_id.
      stperson  in number,   -- starting person_id of range.
      endperson in number,   -- ending person_id of range.
      chunk     in number,   -- current chunk_number.
      rand_chunk in number,   -- current chunk_number.
      itpflg    in varchar2, -- legislation type.
      ptype     in number,    -- payment_type_id.
      use_pop_person in number -- use population_ranges person_id column
   ) is
      cursor magpopcur
      (
         pactid    number,
         chunk     number,
         itpflg    varchar2,
         ptype     number
      ) is
      select /*+ ORDERED
             INDEX(pa2 PAY_PAYROLL_ACTIONS_N5)
             INDEX(pos PER_PERIODS_OF_SERVICE_N3)
             INDEX(as1 PER_ASSIGNMENTS_N4)
             INDEX(as2 PER_ASSIGNMENTS_F_PK)
             INDEX(act PAY_ASSIGNMENT_ACTIONS_N51)
             index(opm PAY_ORG_PAYMENT_METHODS_F_PK)
             USE_NL(pop pos ppp opm as1 act as2) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppp.pre_payment_id
      from   pay_payroll_actions            pa1,
             pay_payroll_actions            pa2,
             pay_action_classifications     pcl,
             pay_population_ranges          pop,
             per_periods_of_service         pos,
             per_all_assignments_f          as1,
             pay_assignment_actions         act,
             per_all_assignments_f          as2,
             pay_pre_payments               ppp,
             pay_org_payment_methods_f      opm
      where  pa1.payroll_action_id          = pactid
      and    pa2.consolidation_set_id +0    = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id          = pa2.payroll_action_id
      and    act.action_status              = 'C'
      and    pcl.classification_name        = 'MAGTAPE'
      and    pa2.action_type                = pcl.action_type
      and    as1.assignment_id              = act.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id              = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id + 0             = as1.payroll_id + 0
      and    pos.period_of_service_id       = as1.period_of_service_id
      and    pop.payroll_action_id          = pactid
      and    pop.chunk_number               = chunk
      and    pos.person_id                  = pop.person_id
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    ppp.assignment_action_id       = act.assignment_action_id
      and    opm.org_payment_method_id      = ppp.org_payment_method_id
      and    pa1.effective_date between
             opm.effective_start_date and opm.effective_end_date
      and    opm.payment_type_id         +0 = ptype
      and   (opm.org_payment_method_id = pa1.org_payment_method_id
             or pa1.org_payment_method_id is null)
      and    not exists (
             select null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      and    not exists (
             select /*+ ORDERED*/
                     null
             from   pay_action_interlocks  int,
                    pay_assignment_actions ac2
             where  int.locked_action_id      = act.assignment_action_id
             and    ac2.assignment_action_id  = int.locking_action_id
             and    ac2.pre_payment_id        = ppp.pre_payment_id
             and  not exists (
                 select null
                   from pay_assignment_actions paa_void,
                        pay_action_interlocks  pai_void,
                        pay_payroll_actions    ppa_void
                  where pai_void.locked_action_id = ac2.assignment_action_id
                    and pai_void.locking_action_id = paa_void.assignment_action_id
                    and paa_void.payroll_action_id = ppa_void.payroll_action_id
                    and ppa_void.action_type = 'D')
             )
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
      cursor magcur
      (
         pactid    number,
         stperson  number,
         endperson number,
         itpflg    varchar2,
         ptype     number
      ) is
      select /*+ ORDERED
             INDEX(pa2 PAY_PAYROLL_ACTIONS_N5)
             INDEX(pos PER_PERIODS_OF_SERVICE_N3)
             INDEX(as1 PER_ASSIGNMENTS_N4)
             INDEX(as2 PER_ASSIGNMENTS_F_PK)
             INDEX(act PAY_ASSIGNMENT_ACTIONS_N51)
             index(opm PAY_ORG_PAYMENT_METHODS_F_PK)
             USE_NL(pos ppp opm as1 act as2) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppp.pre_payment_id
      from   pay_payroll_actions            pa1,
             pay_payroll_actions            pa2,
             pay_action_classifications     pcl,
             per_periods_of_service         pos,
             per_all_assignments_f          as1,
             pay_assignment_actions         act,
             per_all_assignments_f          as2,
             pay_pre_payments               ppp,
             pay_org_payment_methods_f      opm
      where  pa1.payroll_action_id          = pactid
      and    pa2.consolidation_set_id +0    = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id          = pa2.payroll_action_id
      and    act.action_status              = 'C'
      and    pcl.classification_name        = 'MAGTAPE'
      and    pa2.action_type                = pcl.action_type
      and    as1.assignment_id              = act.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id              = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id + 0             = as1.payroll_id + 0
      and    pos.period_of_service_id       = as1.period_of_service_id
      and    pos.person_id between stperson and endperson
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    ppp.assignment_action_id       = act.assignment_action_id
      and    opm.org_payment_method_id      = ppp.org_payment_method_id
      and    pa1.effective_date between
             opm.effective_start_date and opm.effective_end_date
      and    opm.payment_type_id         +0 = ptype
      and   (opm.org_payment_method_id = pa1.org_payment_method_id
             or pa1.org_payment_method_id is null)
      and    not exists (
             select null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      and    not exists (
             select /*+ ORDERED*/
                     null
             from   pay_action_interlocks  int,
                    pay_assignment_actions ac2
             where  int.locked_action_id      = act.assignment_action_id
             and    ac2.assignment_action_id  = int.locking_action_id
             and    ac2.pre_payment_id        = ppp.pre_payment_id
             and  not exists (
                 select null
                   from pay_assignment_actions paa_void,
                        pay_action_interlocks  pai_void,
                        pay_payroll_actions    ppa_void
                  where pai_void.locked_action_id = ac2.assignment_action_id
                    and pai_void.locking_action_id = paa_void.assignment_action_id
                    and paa_void.payroll_action_id = ppa_void.payroll_action_id
                    and ppa_void.action_type = 'D')
             )
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
      cursor magmpipcur
      (
         pactid    number,
         chunk     number,
         itpflg    varchar2,
         ptype     number
      ) is
      select /*+ ORDERED
             INDEX(pa2 PAY_PAYROLL_ACTIONS_PK)
             INDEX(pos PER_PERIODS_OF_SERVICE_N3)
             INDEX(as1 PER_ASSIGNMENTS_N4)
             INDEX(as2 PER_ASSIGNMENTS_F_PK)
             INDEX(act PAY_ASSIGNMENT_ACTIONS_N51)
             index(opm PAY_ORG_PAYMENT_METHODS_F_PK)
             USE_NL(pos pop ppp opm as1 act as2) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppp.pre_payment_id
      from   pay_payroll_actions            pa1,
             pay_population_ranges          pop,
             per_periods_of_service         pos,
             per_all_assignments_f          as1,
             pay_assignment_actions         act,
             pay_payroll_actions            pa2,
             pay_action_classifications     pcl,
             per_all_assignments_f          as2,
             pay_pre_payments               ppp,
             pay_org_payment_methods_f      opm
      where  pa1.payroll_action_id          = pactid
      and    pa2.consolidation_set_id +0    = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id          = pa2.payroll_action_id
      and    act.action_status              = 'C'
      and    pcl.classification_name        = 'MAGTAPE'
      and    pa2.action_type                = pcl.action_type
      and    as1.assignment_id              = act.assignment_id
      and    pa1.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id              = act.assignment_id
      and    pa2.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id + 0             = as1.payroll_id + 0
      and    pos.period_of_service_id       = as1.period_of_service_id
      and    pop.payroll_action_id          = pactid
      and    pop.chunk_number               = chunk
      and    pos.person_id                  = pop.person_id
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    ppp.assignment_action_id       = act.assignment_action_id
      and    opm.org_payment_method_id      = ppp.org_payment_method_id
      and    pa1.effective_date between
             opm.effective_start_date and opm.effective_end_date
      and    opm.payment_type_id         +0 = ptype
      and   (opm.org_payment_method_id = pa1.org_payment_method_id
             or pa1.org_payment_method_id is null)
      and    not exists (
             select null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      and    not exists (
             select /*+ ORDERED*/
                     null
             from   pay_action_interlocks  int,
                    pay_assignment_actions ac2
             where  int.locked_action_id      = act.assignment_action_id
             and    ac2.assignment_action_id  = int.locking_action_id
             and    ac2.pre_payment_id        = ppp.pre_payment_id
             and  not exists (
                 select null
                   from pay_assignment_actions paa_void,
                        pay_action_interlocks  pai_void,
                        pay_payroll_actions    ppa_void
                  where pai_void.locked_action_id = ac2.assignment_action_id
                    and pai_void.locking_action_id = paa_void.assignment_action_id
                    and paa_void.payroll_action_id = ppa_void.payroll_action_id
                    and ppa_void.action_type = 'D')
             )
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
      lockingactid  number;
      lockedactid   number;
      assignid      number;
      prepayid      number;
      greid         number;
--
   -- algorithm is quite similar to the other process cases,
   -- but we have to take into account assignments and
   -- personal payment methods.
   begin
      if (g_many_procs_in_period = 'Y') then
         open magmpipcur(pactid,chunk,itpflg,ptype);
      elsif (use_pop_person = 1) then
         open magpopcur(pactid,chunk,itpflg,ptype);
      else
         open magcur(pactid,stperson,endperson,itpflg,ptype);
      end if;
      loop
         if (g_many_procs_in_period = 'Y') then
            fetch magmpipcur into lockedactid,assignid,greid,prepayid;
            exit when magmpipcur%notfound;
         elsif (use_pop_person = 1) then
            fetch magpopcur into lockedactid,assignid,greid,prepayid;
            exit when magpopcur%notfound;
         else
            fetch magcur into lockedactid,assignid,greid,prepayid;
            exit when magcur%notfound;
         end if;
--
        -- we need to insert one action for each of the
        -- rows that we return from the cursor (i.e. one
        -- for each assignment/pre-payment).
        select pay_assignment_actions_s.nextval
        into   lockingactid
        from   dual;
--
        -- insert the action record.
        insact(lockingactid,assignid,pactid,rand_chunk,greid,prepayid);
--
         -- insert an interlock to this action.
         insint(lockingactid,lockedactid);
--
      end loop;
      if (g_many_procs_in_period = 'Y') then
         close magmpipcur;
      elsif (use_pop_person = 1) then
         close magpopcur;
      else
         close magcur;
      end if;
--
      -- Now populate the org payments
      procorgpyt
      (
         pactid     => pactid,
         chunk      => chunk,
         rand_chunk => rand_chunk,
         ptype      => ptype,
         class      => 'MAGTAPE'
      );
      commit;
   end procmag;
--
   -------------------------------- proc_prepay -------------------------------
   /*
      NAME
         proc_prepay - insert actions for pre-payment action type.
      DESCRIPTION
         For the range defined by the starting and ending person_id,
         inserts a chunk of assignment actions and associated interlocks.
      NOTES
         <none>
   */
   procedure proc_prepay
   (
      pactid        in number,
      stperson      in number,
      endperson     in number,
      chunk         in number,
      rand_chunk    in number,
      class         in varchar2,
      itpflg        in varchar2,
      mult_asg_flag in varchar2 default 'N',
      use_pop_person in number
   ) is
      --
      cursor prepaypopcur
      (
         pactid    number,
         chunk     number,
         class     varchar2,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_N5)
             index(as1 PER_ASSIGNMENTS_F_N4)
             index(as2 PER_ASSIGNMENTS_F_PK)
             USE_NL(pop pos as1) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             as1.person_id,
             as1.effective_start_date,
	     as1.primary_flag
      from   pay_payroll_actions        pa1,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             pay_population_ranges      pop,
             per_periods_of_service     pos,
             per_all_assignments_f      as1,
             pay_assignment_actions     act,
             per_all_assignments_f      as2
      where  pa1.payroll_action_id    = pactid
      and    pa2.payroll_id           = pa1.payroll_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id         = pa2.payroll_action_id
      and    act.action_status             in ('C','S')
      and    pcl.classification_name       = class
      and    pa2.consolidation_set_id      = pa1.consolidation_set_id
      and    pa2.action_type               = pcl.action_type
      and    nvl(pa2.future_process_mode, 'Y') = 'Y'
      and    as1.assignment_id             = act.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id        = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id           = as1.payroll_id
      and    pos.period_of_service_id = as1.period_of_service_id
      and    pop.payroll_action_id    = pactid
      and    pop.chunk_number         = chunk
      and    pos.person_id            = pop.person_id
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    not exists (
             select null
             from   pay_assignment_actions ac2,
                    pay_payroll_actions    pa3,
                    pay_action_interlocks  int
             where  int.locked_action_id     = act.assignment_action_id
             and    ac2.assignment_action_id = int.locking_action_id
             and    pa3.payroll_action_id    = ac2.payroll_action_id
             and    pa3.action_type          in ('P', 'U'))
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ( 'C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      order by as1.person_id,as1.primary_flag desc ,as1.effective_start_date,act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
      --
      cursor prepaycur
      (
         pactid    number,
         stperson  number,
         endperson number,
         class     varchar2,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_N5)
             index(as1 PER_ASSIGNMENTS_F_N4)
             index(as2 PER_ASSIGNMENTS_F_PK)
             USE_NL(pos as1) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             as1.person_id,
             as1.effective_start_date,
	     as1.primary_flag
      from   pay_payroll_actions        pa1,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             per_periods_of_service     pos,
             per_all_assignments_f      as1,
             pay_assignment_actions     act,
             per_all_assignments_f      as2
      where  pa1.payroll_action_id    = pactid
      and    pa2.payroll_id           = pa1.payroll_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id         = pa2.payroll_action_id
      and    act.action_status             in ('C','S')
      and    pcl.classification_name       = class
      and    pa2.consolidation_set_id      = pa1.consolidation_set_id
      and    pa2.action_type               = pcl.action_type
      and    nvl(pa2.future_process_mode, 'Y') = 'Y'
      and    as1.assignment_id             = act.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id        = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id           = as1.payroll_id
      and    pos.period_of_service_id = as1.period_of_service_id
      and    pos.person_id between stperson and endperson
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    not exists (
             select null
             from   pay_assignment_actions ac2,
                    pay_payroll_actions    pa3,
                    pay_action_interlocks  int
             where  int.locked_action_id     = act.assignment_action_id
             and    ac2.assignment_action_id = int.locking_action_id
             and    pa3.payroll_action_id    = ac2.payroll_action_id
             and    pa3.action_type          in ('P', 'U'))
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ( 'C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      order by as1.person_id,as1.primary_flag desc ,as1.effective_start_date,act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
     --
      cursor prepaympipcur
      (
         pactid    number,
         chunk     number,
         class     varchar2,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_PK)
             index(pos PER_PERIODS_OF_SERVICE_N3)
             index(act PAY_ASSIGNMENT_ACTIONS_N51)
             index(as1 PER_ASSIGNMENTS_F_N4)
             index(as2 PER_ASSIGNMENTS_F_PK)
             USE_NL(pos pop act as1 as2 pa2) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             as1.person_id,
             as1.effective_start_date,
             as1.primary_flag
      from   pay_payroll_actions        pa1,
             pay_population_ranges      pop,
             per_periods_of_service     pos,
             per_all_assignments_f      as1,
             pay_assignment_actions     act,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             per_all_assignments_f      as2
      where  pa1.payroll_action_id    = pactid
      and    pa2.payroll_id           = pa1.payroll_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id         = pa2.payroll_action_id
      and    act.action_status             in ('C','S')
      and    pcl.classification_name       = class
      and    pa2.consolidation_set_id      = pa1.consolidation_set_id
      and    pa2.action_type               = pcl.action_type
      and    nvl(pa2.future_process_mode, 'Y') = 'Y'
      and    as1.assignment_id             = act.assignment_id
      and    pa1.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id        = act.assignment_id
      and    pa2.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id           = as1.payroll_id
      and    pos.period_of_service_id = as1.period_of_service_id
      and    pop.payroll_action_id         = pactid
      and    pop.chunk_number              = chunk
      and    pos.person_id                 = pop.person_id
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    not exists (
             select null
             from   pay_assignment_actions ac2,
                    pay_payroll_actions    pa3,
                    pay_action_interlocks  int
             where  int.locked_action_id     = act.assignment_action_id
             and    ac2.assignment_action_id = int.locking_action_id
             and    pa3.payroll_action_id    = ac2.payroll_action_id
             and    pa3.action_type          in ('P', 'U'))
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ( 'C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      order by as1.person_id,as1.primary_flag desc ,as1.effective_start_date,act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
   lockingactid  number;
   lockedactid   number;
   assignid      number;
   prev_assignid number;
   greid         number;
--
   person_id  number;
   primary_flag varchar2(30);
   asg_start_date date;
   prev_person_id number;
   begin
      prev_assignid := null;
      prev_person_id := null;
      if (g_many_procs_in_period = 'Y') then
         open prepaympipcur(pactid,chunk,class,itpflg);
      elsif (use_pop_person = 1) then
         open prepaypopcur(pactid,chunk,class,itpflg);
      else
         open prepaycur(pactid,stperson,endperson,class,itpflg);
      end if;
      loop
         if (g_many_procs_in_period = 'Y') then
            fetch prepaympipcur into lockedactid,assignid,greid,person_id,asg_start_date,primary_flag;
            exit when prepaympipcur%notfound;
         elsif (use_pop_person = 1) then
            fetch prepaypopcur into lockedactid,assignid,greid,person_id,asg_start_date,primary_flag;
            exit when prepaypopcur%notfound;
         else
            fetch prepaycur into lockedactid,assignid,greid,person_id,asg_start_date,primary_flag;
            exit when prepaycur%notfound;
         end if;
--
       if (mult_asg_flag = 'Y')
       then
        -- insert master actions
        if (prev_person_id is null or prev_person_id <> person_id) then
            select pay_assignment_actions_s.nextval
            into   lockingactid
            from   dual;

            -- insert into pay_assignment_actions.
            insact(lockingactid,assignid,pactid,rand_chunk,greid);

        end if;
          -- insert interlocks
           insint(lockingactid,lockedactid);
        prev_assignid := assignid;
        prev_person_id := person_id;

       else
         /* process the insert of assignment actions */
         /* logic prevents more than one action per assignment */
         if(prev_assignid is null OR prev_assignid <> assignid) then
            -- get a value for the action id that is locking.
            select pay_assignment_actions_s.nextval
            into   lockingactid
            from   dual;
--
            -- insert into pay_assignment_actions.
            insact(lockingactid,assignid,pactid,rand_chunk,greid);
         end if;
--
         -- insert into interlocks table.
         insint(lockingactid,lockedactid);
         prev_assignid := assignid;
       end if;
--
      end loop;
      if (g_many_procs_in_period = 'Y') then
         close prepaympipcur;
      elsif (use_pop_person = 1) then
         close prepaypopcur;
      else
         close prepaycur;
      end if;
      commit;
   end proc_prepay;
--
   ------------------------------- proc_costing -------------------------------
   /*
      NAME
         proc_costing - insert actions for non Costing action type.
      DESCRIPTION
         For the range defined by the starting and ending person_id,
         inserts a chunk of assignment actions and associated interlocks.
      NOTES
         <none>
   */
   procedure proc_costing
   (
      pactid    in number,
      stperson  in number,
      endperson in number,
      chunk     in number,
      rand_chunk in number,
      class     in varchar2,
      itpflg    in varchar2,
      use_pop_person in number
   ) is
      --
      cursor costingpopcur
      (
         pactid    number,
         chunk     number,
         class     varchar2,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_N5)
             index(as1 PER_ASSIGNMENTS_F_N4)
             index(as2 PER_ASSIGNMENTS_F_PK)
             USE_NL(pos pop as1) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_payroll_actions        pa1,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             pay_population_ranges      pop,
             per_periods_of_service     pos,
             per_all_assignments_f      as1,
             pay_assignment_actions     act,
             per_all_assignments_f      as2
      where  pa1.payroll_action_id    = pactid
      and    pa2.consolidation_set_id  = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id    = pa2.payroll_action_id
      and    act.action_status        in ('C','S')
      and    pcl.classification_name  = class
      and    pa2.action_type          = pcl.action_type
      and    as1.assignment_id        = act.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id        = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    pop.payroll_action_id    = pactid
      and    pop.chunk_number         = chunk
      and    pos.person_id            = pop.person_id
      and    pos.period_of_service_id = as1.period_of_service_id
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    not exists (
             select null
             from   pay_assignment_actions ac2,
                    pay_payroll_actions    pa3,
                    pay_action_interlocks  int
             where  int.locked_action_id     = act.assignment_action_id
             and    ac2.assignment_action_id = int.locking_action_id
             and    pa3.payroll_action_id    = ac2.payroll_action_id
             and    pa3.action_type          in ('C', 'S'))
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C','S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
      --
      cursor costingcur
      (
         pactid    number,
         stperson  number,
         endperson number,
         class     varchar2,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_N5)
             index(as1 PER_ASSIGNMENTS_F_N4)
             index(as2 PER_ASSIGNMENTS_F_PK)
             USE_NL(pos as1) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_payroll_actions        pa1,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             per_periods_of_service     pos,
             per_all_assignments_f      as1,
             pay_assignment_actions     act,
             per_all_assignments_f      as2
      where  pa1.payroll_action_id    = pactid
      and    pa2.consolidation_set_id  = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id    = pa2.payroll_action_id
      and    act.action_status        in ('C','S')
      and    pcl.classification_name  = class
      and    pa2.action_type          = pcl.action_type
      and    as1.assignment_id        = act.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id        = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    pos.period_of_service_id = as1.period_of_service_id
      and    pos.person_id between stperson and endperson
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    not exists (
             select null
             from   pay_assignment_actions ac2,
                    pay_payroll_actions    pa3,
                    pay_action_interlocks  int
             where  int.locked_action_id     = act.assignment_action_id
             and    ac2.assignment_action_id = int.locking_action_id
             and    pa3.payroll_action_id    = ac2.payroll_action_id
             and    pa3.action_type          in ('C', 'S'))
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C','S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
      --
      cursor costingmpipcur
      (
         pactid    number,
         chunk     number,
         class     varchar2,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_PK)
             index(pos PER_PERIODS_OF_SERVICE_N3)
             index(as1 PER_ASSIGNMENTS_F_N4)
             index(act PAY_ASSIGNMENT_ACTIONS_N51)
             index(as2 PER_ASSIGNMENTS_F_PK)
             USE_NL(pos pop act pa2 as2 as1) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_payroll_actions        pa1,
             pay_population_ranges      pop,
             per_periods_of_service     pos,
             per_all_assignments_f      as1,
             pay_assignment_actions     act,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             per_all_assignments_f      as2
      where  pa1.payroll_action_id    = pactid
      and    pa2.consolidation_set_id  = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id    = pa2.payroll_action_id
      and    act.action_status        in ('C','S')
      and    pcl.classification_name  = class
      and    pa2.action_type          = pcl.action_type
      and    as1.assignment_id        = act.assignment_id
      and    pa1.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id        = act.assignment_id
      and    pa2.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    pos.period_of_service_id = as1.period_of_service_id
      and    pop.payroll_action_id    = pactid
      and    pop.chunk_number         = chunk
      and    pos.person_id            = pop.person_id
      and   (as2.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    not exists (
             select null
             from   pay_assignment_actions ac2,
                    pay_payroll_actions    pa3,
                    pay_action_interlocks  int
             where  int.locked_action_id     = act.assignment_action_id
             and    ac2.assignment_action_id = int.locking_action_id
             and    pa3.payroll_action_id    = ac2.payroll_action_id
             and    pa3.action_type          in ('C', 'S'))
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C','S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
   lockingactid  number;
   lockedactid   number;
   assignid      number;
   prev_assignid number;
   greid         number;
--
   begin
      prev_assignid := null;
      if (g_many_procs_in_period = 'Y') then
         open costingmpipcur(pactid,chunk,class,itpflg);
      elsif (use_pop_person = 1) then
         open costingpopcur(pactid,chunk,class,itpflg);
      else
         open costingcur(pactid,stperson,endperson,class,itpflg);
      end if;
      loop
         if (g_many_procs_in_period = 'Y') then
            fetch costingmpipcur into lockedactid,assignid,greid;
            exit when costingmpipcur%notfound;
         elsif (use_pop_person = 1) then
            fetch costingpopcur into lockedactid,assignid,greid;
            exit when costingpopcur%notfound;
         else
            fetch costingcur into lockedactid,assignid,greid;
            exit when costingcur%notfound;
         end if;
--
         /* process the insert of assignment actions */
         /* logic prevents more than one action per assignment */
         if(prev_assignid is null OR prev_assignid <> assignid) then
            -- get a value for the action id that is locking.
            select pay_assignment_actions_s.nextval
            into   lockingactid
            from   dual;
--
            -- insert into pay_assignment_actions.
            insact(lockingactid,assignid,pactid,rand_chunk,greid);
         end if;
--
         -- insert into interlocks table.
         insint(lockingactid,lockedactid);
--
         prev_assignid := assignid;
      end loop;
      if (g_many_procs_in_period = 'Y') then
         close costingmpipcur;
      elsif (use_pop_person = 1) then
         close costingpopcur;
      else
         close costingcur;
      end if;
      commit;
   end proc_costing;
--
   ------------------------------- proc_paymcosting ---------------------------
   /*
      NAME
         proc_paymcosting - insert actions for Payment Costing action type.
      DESCRIPTION
         For the range defined by the starting and ending person_id,
         inserts a chunk of assignment actions and associated interlocks.
      NOTES
         <none>
   */
   procedure proc_paymcosting
   (
      pactid    in number,
      stperson  in number,
      endperson in number,
      chunk     in number,
      rand_chunk in number,
      class     in varchar2,
      itpflg    in varchar2,
      use_pop_person in number
   ) is
      --
      cursor pmcostingpopcur
      (
         pactid    number,
         chunk     number,
         class     varchar2,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_N5)
             index(as1 PER_ASSIGNMENTS_F_N4)
             index(as2 PER_ASSIGNMENTS_F_PK)
             USE_NL(pos pop as1) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             act.payroll_action_id
      from   pay_payroll_actions        pa1,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             pay_population_ranges      pop,
             per_periods_of_service     pos,
             per_all_assignments_f      as1,
             pay_assignment_actions     act,
             per_all_assignments_f      as2
      where  pa1.payroll_action_id    = pactid
      and    pa2.consolidation_set_id  = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id    = pa2.payroll_action_id
      and    act.action_status        in ('C','S')
      and    pcl.classification_name  = class
      and    pa2.action_type          = pcl.action_type
      and    as1.assignment_id        = act.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id        = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    pop.payroll_action_id    = pactid
      and    pop.chunk_number         = chunk
      and    pos.person_id            = pop.person_id
      and    pos.period_of_service_id = as1.period_of_service_id
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    not exists (
             select null
             from   pay_assignment_actions ac2,
                    pay_payroll_actions    pa3,
                    pay_action_interlocks  int
             where  int.locked_action_id     = act.assignment_action_id
             and    ac2.assignment_action_id = int.locking_action_id
             and    pa3.payroll_action_id    = ac2.payroll_action_id
             and    pa3.action_type          = 'CP')
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C','S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      and ((pa2.action_type in ('P', 'U')
            and pa1.batch_process_mode in ('UNCLEARED', 'ALL')
            and exists (select 1
                        from  pay_pre_payments ppp,
                              pay_org_payment_methods_f pom
                        where ppp.assignment_action_id = act.assignment_action_id
                        and   pom.org_payment_method_id = ppp.org_payment_method_id
                        and   pom.cost_payment = 'Y'
                        and   pa2.effective_date between
                              pom.effective_start_date and pom.effective_end_date))
        or (pa2.action_type in ('H', 'M')
            and pa1.batch_process_mode in ('CLEARED', 'ALL')
            and exists (select 1
                        from  pay_pre_payments ppp,
                              pay_org_payment_methods_f pom,
                              pay_ce_reconciled_payments crp
                        where ppp.pre_payment_id = act.pre_payment_id
                        and   pom.org_payment_method_id = ppp.org_payment_method_id
                        and   pom.cost_cleared_payment = 'Y'
                        and   crp.assignment_action_id = act.assignment_action_id
                        and   pa2.effective_date between
                              pom.effective_start_date and pom.effective_end_date))
        or (pa2.action_type = 'E'
            and pa1.batch_process_mode in ('CLEARED', 'ALL')
            and exists (select 1
                        from  pay_pre_payments ppp,
                              pay_org_payment_methods_f pom,
                              pay_ce_reconciled_payments crp
                        where ppp.pre_payment_id = act.pre_payment_id
                        and   pom.org_payment_method_id = ppp.org_payment_method_id
                        and   pom.cost_cleared_payment = 'Y'
                        and   nvl(pom.exclude_manual_payment, 'N') = 'N'
                        and   crp.assignment_action_id = act.assignment_action_id
                        and   pa2.effective_date between
                              pom.effective_start_date and pom.effective_end_date))
        or (pa2.action_type = 'D'
            and ((pa1.batch_process_mode in ('CLEARED', 'ALL')
                  and exists (select 1
                        from  pay_action_interlocks int,
                              pay_assignment_actions chq,
                              pay_payroll_actions pcq,
                              pay_pre_payments ppp,
                              pay_org_payment_methods_f pom,
                              pay_ce_reconciled_payments crp
                        where int.locking_action_id = act.assignment_action_id
                        and   chq.assignment_action_id = int.locked_action_id
                        and   pcq.payroll_action_id = chq.payroll_action_id
                        and   pcq.action_type = 'H'
                        and   ppp.pre_payment_id = chq.pre_payment_id
                        and   pom.org_payment_method_id = ppp.org_payment_method_id
                        and   pom.cost_cleared_payment = 'Y'
                        and   crp.assignment_action_id = act.assignment_action_id
                        and   pa2.effective_date between
                              pom.effective_start_date and pom.effective_end_date))
             or (pa1.batch_process_mode in ('UNCLEARED', 'ALL')
                 and exists (select 1
                        from  pay_action_interlocks int,
                              pay_assignment_actions chq,
                              pay_payroll_actions pcq,
                              pay_pre_payments ppp,
                              pay_org_payment_methods_f pom
                        where int.locking_action_id = act.assignment_action_id
                        and   chq.assignment_action_id = int.locked_action_id
                        and   pcq.payroll_action_id = chq.payroll_action_id
                        and   pcq.action_type = 'H'
                        and   ppp.pre_payment_id = chq.pre_payment_id
                        and   pom.org_payment_method_id = ppp.org_payment_method_id
                        and   pom.cost_payment = 'Y'
                        and   pom.cost_cleared_void_payment = 'N'
                        and   pa2.effective_date between
                              pom.effective_start_date and pom.effective_end_date)))))
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
      --
      cursor pmcostingcur
      (
         pactid    number,
         stperson  number,
         endperson number,
         class     varchar2,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_N5)
             index(as1 PER_ASSIGNMENTS_F_N4)
             index(as2 PER_ASSIGNMENTS_F_PK)
             USE_NL(pos as1) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             act.payroll_action_id
      from   pay_payroll_actions        pa1,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             per_periods_of_service     pos,
             per_all_assignments_f      as1,
             pay_assignment_actions     act,
             per_all_assignments_f      as2
      where  pa1.payroll_action_id    = pactid
      and    pa2.consolidation_set_id  = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id    = pa2.payroll_action_id
      and    act.action_status        in ('C','S')
      and    pcl.classification_name  = class
      and    pa2.action_type          = pcl.action_type
      and    as1.assignment_id        = act.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id        = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    pos.period_of_service_id = as1.period_of_service_id
      and    pos.person_id between stperson and endperson
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    not exists (
             select null
             from   pay_assignment_actions ac2,
                    pay_payroll_actions    pa3,
                    pay_action_interlocks  int
             where  int.locked_action_id     = act.assignment_action_id
             and    ac2.assignment_action_id = int.locking_action_id
             and    pa3.payroll_action_id    = ac2.payroll_action_id
             and    pa3.action_type          = 'CP')
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C','S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      and ((pa2.action_type in ('P', 'U')
            and pa1.batch_process_mode in ('UNCLEARED', 'ALL')
            and exists (select 1
                        from  pay_pre_payments ppp,
                              pay_org_payment_methods_f pom
                        where ppp.assignment_action_id = act.assignment_action_id
                        and   pom.org_payment_method_id = ppp.org_payment_method_id
                        and   pom.cost_payment = 'Y'
                        and   pa2.effective_date between
                              pom.effective_start_date and pom.effective_end_date))
        or (pa2.action_type in ('H', 'M')
            and pa1.batch_process_mode in ('CLEARED', 'ALL')
            and exists (select 1
                        from  pay_pre_payments ppp,
                              pay_org_payment_methods_f pom,
                              pay_ce_reconciled_payments crp
                        where ppp.pre_payment_id = act.pre_payment_id
                        and   pom.org_payment_method_id = ppp.org_payment_method_id
                        and   pom.cost_cleared_payment = 'Y'
                        and   crp.assignment_action_id = act.assignment_action_id
                        and   pa2.effective_date between
                              pom.effective_start_date and pom.effective_end_date))
        or (pa2.action_type = 'E'
            and pa1.batch_process_mode in ('CLEARED', 'ALL')
            and exists (select 1
                        from  pay_pre_payments ppp,
                              pay_org_payment_methods_f pom,
                              pay_ce_reconciled_payments crp
                        where ppp.pre_payment_id = act.pre_payment_id
                        and   pom.org_payment_method_id = ppp.org_payment_method_id
                        and   pom.cost_cleared_payment = 'Y'
                        and   nvl(pom.exclude_manual_payment, 'N') = 'N'
                        and   crp.assignment_action_id = act.assignment_action_id
                        and   pa2.effective_date between
                              pom.effective_start_date and pom.effective_end_date))
        or (pa2.action_type = 'D'
            and ((pa1.batch_process_mode in ('CLEARED', 'ALL')
                  and exists (select 1
                        from  pay_action_interlocks int,
                              pay_assignment_actions chq,
                              pay_payroll_actions pcq,
                              pay_pre_payments ppp,
                              pay_org_payment_methods_f pom,
                              pay_ce_reconciled_payments crp
                        where int.locking_action_id = act.assignment_action_id
                        and   chq.assignment_action_id = int.locked_action_id
                        and   pcq.payroll_action_id = chq.payroll_action_id
                        and   pcq.action_type = 'H'
                        and   ppp.pre_payment_id = chq.pre_payment_id
                        and   pom.org_payment_method_id = ppp.org_payment_method_id
                        and   pom.cost_cleared_payment = 'Y'
                        and   crp.assignment_action_id = act.assignment_action_id
                        and   pa2.effective_date between
                              pom.effective_start_date and pom.effective_end_date))
             or (pa1.batch_process_mode in ('UNCLEARED', 'ALL')
                 and exists (select 1
                        from  pay_action_interlocks int,
                              pay_assignment_actions chq,
                              pay_payroll_actions pcq,
                              pay_pre_payments ppp,
                              pay_org_payment_methods_f pom
                        where int.locking_action_id = act.assignment_action_id
                        and   chq.assignment_action_id = int.locked_action_id
                        and   pcq.payroll_action_id = chq.payroll_action_id
                        and   pcq.action_type = 'H'
                        and   ppp.pre_payment_id = chq.pre_payment_id
                        and   pom.org_payment_method_id = ppp.org_payment_method_id
                        and   pom.cost_payment = 'Y'
                        and   pom.cost_cleared_void_payment = 'N'
                        and   pa2.effective_date between
                              pom.effective_start_date and pom.effective_end_date)))))
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
      --
      cursor pmcostingmpipcur
      (
         pactid    number,
         chunk     number,
         class     varchar2,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_PK)
             index(pos PER_PERIODS_OF_SERVICE_N3)
             index(as1 PER_ASSIGNMENTS_F_N4)
             index(act PAY_ASSIGNMENT_ACTIONS_N51)
             index(as2 PER_ASSIGNMENTS_F_PK)
             USE_NL(pos pop act pa2 as2 as1) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             act.payroll_action_id
      from   pay_payroll_actions        pa1,
             pay_population_ranges      pop,
             per_periods_of_service     pos,
             per_all_assignments_f      as1,
             pay_assignment_actions     act,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             per_all_assignments_f      as2
      where  pa1.payroll_action_id    = pactid
      and    pa2.consolidation_set_id  = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id    = pa2.payroll_action_id
      and    act.action_status        in ('C','S')
      and    pcl.classification_name  = class
      and    pa2.action_type          = pcl.action_type
      and    as1.assignment_id        = act.assignment_id
      and    pa1.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id        = act.assignment_id
      and    pa2.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    pos.period_of_service_id = as1.period_of_service_id
      and    pop.payroll_action_id    = pactid
      and    pop.chunk_number         = chunk
      and    pos.person_id            = pop.person_id
      and   (as2.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    not exists (
             select null
             from   pay_assignment_actions ac2,
                    pay_payroll_actions    pa3,
                    pay_action_interlocks  int
             where  int.locked_action_id     = act.assignment_action_id
             and    ac2.assignment_action_id = int.locking_action_id
             and    pa3.payroll_action_id    = ac2.payroll_action_id
             and    pa3.action_type          = 'CP')
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C','S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      and ((pa2.action_type in ('P', 'U')
            and pa1.batch_process_mode in ('UNCLEARED', 'ALL')
            and exists (select 1
                        from  pay_pre_payments ppp,
                              pay_org_payment_methods_f pom
                        where ppp.assignment_action_id = act.assignment_action_id
                        and   pom.org_payment_method_id = ppp.org_payment_method_id
                        and   pom.cost_payment = 'Y'
                        and   pa2.effective_date between
                              pom.effective_start_date and pom.effective_end_date))
        or (pa2.action_type in ('H', 'M')
            and pa1.batch_process_mode in ('CLEARED', 'ALL')
            and exists (select 1
                        from  pay_pre_payments ppp,
                              pay_org_payment_methods_f pom,
                              pay_ce_reconciled_payments crp
                        where ppp.pre_payment_id = act.pre_payment_id
                        and   pom.org_payment_method_id = ppp.org_payment_method_id
                        and   pom.cost_cleared_payment = 'Y'
                        and   crp.assignment_action_id = act.assignment_action_id
                        and   pa2.effective_date between
                              pom.effective_start_date and pom.effective_end_date))
        or (pa2.action_type = 'E'
            and pa1.batch_process_mode in ('CLEARED', 'ALL')
            and exists (select 1
                        from  pay_pre_payments ppp,
                              pay_org_payment_methods_f pom,
                              pay_ce_reconciled_payments crp
                        where ppp.pre_payment_id = act.pre_payment_id
                        and   pom.org_payment_method_id = ppp.org_payment_method_id
                        and   pom.cost_cleared_payment = 'Y'
                        and   nvl(pom.exclude_manual_payment, 'N') = 'N'
                        and   crp.assignment_action_id = act.assignment_action_id
                        and   pa2.effective_date between
                              pom.effective_start_date and pom.effective_end_date))
        or (pa2.action_type = 'D'
            and ((pa1.batch_process_mode in ('CLEARED', 'ALL')
                  and exists (select 1
                        from  pay_action_interlocks int,
                              pay_assignment_actions chq,
                              pay_payroll_actions pcq,
                              pay_pre_payments ppp,
                              pay_org_payment_methods_f pom,
                              pay_ce_reconciled_payments crp
                        where int.locking_action_id = act.assignment_action_id
                        and   chq.assignment_action_id = int.locked_action_id
                        and   pcq.payroll_action_id = chq.payroll_action_id
                        and   pcq.action_type = 'H'
                        and   ppp.pre_payment_id = chq.pre_payment_id
                        and   pom.org_payment_method_id = ppp.org_payment_method_id
                        and   pom.cost_cleared_payment = 'Y'
                        and   crp.assignment_action_id = act.assignment_action_id
                        and   pa2.effective_date between
                              pom.effective_start_date and pom.effective_end_date))
             or (pa1.batch_process_mode in ('UNCLEARED', 'ALL')
                 and exists (select 1
                        from  pay_action_interlocks int,
                              pay_assignment_actions chq,
                              pay_payroll_actions pcq,
                              pay_pre_payments ppp,
                              pay_org_payment_methods_f pom
                        where int.locking_action_id = act.assignment_action_id
                        and   chq.assignment_action_id = int.locked_action_id
                        and   pcq.payroll_action_id = chq.payroll_action_id
                        and   pcq.action_type = 'H'
                        and   ppp.pre_payment_id = chq.pre_payment_id
                        and   pom.org_payment_method_id = ppp.org_payment_method_id
                        and   pom.cost_payment = 'Y'
                        and   pom.cost_cleared_void_payment = 'N'
                        and   pa2.effective_date between
                              pom.effective_start_date and pom.effective_end_date)))))
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
   lockingactid  number;
   lockedactid   number;
   assignid      number;
   prev_assignid number;
   lpactid       number;
   prev_pactid   number;
   greid         number;
--
   begin
      prev_assignid := null;
      prev_pactid := null;
      if (g_many_procs_in_period = 'Y') then
         open pmcostingmpipcur(pactid,chunk,class,itpflg);
      elsif (use_pop_person = 1) then
         open pmcostingpopcur(pactid,chunk,class,itpflg);
      else
         open pmcostingcur(pactid,stperson,endperson,class,itpflg);
      end if;
      loop
         if (g_many_procs_in_period = 'Y') then
            fetch pmcostingmpipcur into lockedactid,assignid,greid,lpactid;
            exit when pmcostingmpipcur%notfound;
         elsif (use_pop_person = 1) then
            fetch pmcostingpopcur into lockedactid,assignid,greid,lpactid;
            exit when pmcostingpopcur%notfound;
         else
            fetch pmcostingcur into lockedactid,assignid,greid,lpactid;
            exit when pmcostingcur%notfound;
         end if;
--
         /* process the insert of assignment actions */
         /* logic prevents more than one action per assignment */
         if(prev_assignid is null OR prev_assignid <> assignid OR
            prev_pactid <> lpactid) then
            -- get a value for the action id that is locking.
            select pay_assignment_actions_s.nextval
            into   lockingactid
            from   dual;
--
            -- insert into pay_assignment_actions.
            insact(lockingactid,assignid,pactid,rand_chunk,greid);
         end if;
--
         -- insert into interlocks table.
         insint(lockingactid,lockedactid);
--
         prev_assignid := assignid;
         prev_pactid := lpactid;
      end loop;
      if (g_many_procs_in_period = 'Y') then
         close pmcostingmpipcur;
      elsif (use_pop_person = 1) then
         close pmcostingpopcur;
      else
         close pmcostingcur;
      end if;
      commit;
   end proc_paymcosting;
--
   ------------------------------- proc_estcosts ------------------------------
   /*
      NAME
         proc_estcosts - insert actions for Estimate Costing action type.
      DESCRIPTION
         For the range defined by the starting and ending person_id,
         inserts a chunk of assignment actions
      NOTES
         <none>
   */
   procedure proc_estcosts
   (
      pactid    in number,
      stperson  in number,
      endperson in number,
      chunk     in number,
      rand_chunk in number,
      class     in varchar2,
      itpflg    in varchar2,
      use_pop_person in number
   ) is
      --
      cursor estcostingpopcur
      (
         pactid    number,
         chunk     number,
         class     varchar2,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_N5)
             index(as1 PER_ASSIGNMENTS_F_N4)
             index(as2 PER_ASSIGNMENTS_F_PK)
             USE_NL(pop pos as1) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_payroll_actions        pa1,
             pay_all_payrolls_f         pay,
             per_time_periods           ptp,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             pay_population_ranges      pop,
             per_periods_of_service     pos,
             per_all_assignments_f      as1,
             pay_assignment_actions     act,
             per_all_assignments_f      as2
      where  pa1.payroll_action_id    = pactid
      and    pay.consolidation_set_id = pa1.consolidation_set_id
      and    pa1.effective_date between
             pay.effective_start_date and pay.effective_end_date
      and    ptp.payroll_id           =  pay.payroll_id
      and    pa1.start_date between
             ptp.start_date and ptp.end_date
      and    pa2.consolidation_set_id  = pa1.consolidation_set_id
      and    pa2.effective_date between
             ptp.start_date and ptp.end_date
      and    act.payroll_action_id    = pa2.payroll_action_id
      and    act.action_status        in ('C','S')
      and    pcl.classification_name  = class
      and    pa2.action_type          = pcl.action_type
      and    as1.assignment_id        = act.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id        = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id           = as1.payroll_id
      and    pop.payroll_action_id    = pactid
      and    pop.chunk_number         = chunk
      and    pos.person_id            = pop.person_id
      and    pos.period_of_service_id = as1.period_of_service_id
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C','S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
      --
      cursor estcostingcur
      (
         pactid    number,
         stperson  number,
         endperson number,
         class     varchar2,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_N5)
             index(as1 PER_ASSIGNMENTS_F_N4)
             index(as2 PER_ASSIGNMENTS_F_PK)
             USE_NL(pos as1) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_payroll_actions        pa1,
             pay_all_payrolls_f         pay,
             per_time_periods           ptp,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             per_periods_of_service     pos,
             per_all_assignments_f      as1,
             pay_assignment_actions     act,
             per_all_assignments_f      as2
      where  pa1.payroll_action_id    = pactid
      and    pay.consolidation_set_id = pa1.consolidation_set_id
      and    pa1.effective_date between
             pay.effective_start_date and pay.effective_end_date
      and    ptp.payroll_id           =  pay.payroll_id
      and    pa1.start_date between
             ptp.start_date and ptp.end_date
      and    pa2.consolidation_set_id = pa1.consolidation_set_id
      and    pa2.effective_date between
             ptp.start_date and ptp.end_date
      and    act.payroll_action_id    = pa2.payroll_action_id
      and    act.action_status        in ('C','S')
      and    pcl.classification_name  = class
      and    pa2.action_type          = pcl.action_type
      and    as1.assignment_id        = act.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id        = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id           = as1.payroll_id
      and    pos.period_of_service_id = as1.period_of_service_id
      and    pos.person_id between stperson and endperson
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C','S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
   lockingactid  number;
   lockedactid   number;
   assignid      number;
   prev_assignid number;
   greid         number;
--
   begin
      prev_assignid := null;
      if (use_pop_person = 1) then
         open estcostingpopcur(pactid,chunk,class,itpflg);
      else
         open estcostingcur(pactid,stperson,endperson,class,itpflg);
      end if;
      loop
         if (use_pop_person = 1) then
            fetch estcostingpopcur into lockedactid,assignid,greid;
            exit when estcostingpopcur%notfound;
         else
            fetch estcostingcur into lockedactid,assignid,greid;
            exit when estcostingcur%notfound;
         end if;
--
         /* process the insert of assignment actions */
         /* logic prevents more than one action per assignment */
         if(prev_assignid is null OR prev_assignid <> assignid) then
            -- get a value for the action id that is locking.
            select pay_assignment_actions_s.nextval
            into   lockingactid
            from   dual;
--
            -- insert into pay_assignment_actions.
            insact(lockingactid,assignid,pactid,rand_chunk,greid);
         end if;
--
         prev_assignid := assignid;
      end loop;
      if (use_pop_person = 1) then
         close estcostingpopcur;
      else
         close estcostingcur;
      end if;
      commit;
   end proc_estcosts;
--
   ---------------------------------- procbee ---------------------------------
   /*
      NAME
         procbee - insert assignment actions for Batch Element Entry.
      DESCRIPTION
         Insert assignment actions for the Batch Element Entry process.
      NOTES
         The insert of assignment actions for Batch Element Entry is based
         on the followig logic: We select all the assignments within the
         specified range. One assignment action is then inserted
         for each of the assignment selected.
   */
   procedure procbee
   (
      pactid    in number,
      stperson  in number,
      endperson in number,
      chunk     in number,
      rand_chunk in number,
      use_pop_person in number
   ) is
--
      cursor beepopcur
      (
         pactid    number,
         chunk     number
      ) is
      select asg.assignment_id
        from pay_payroll_actions pac,
             pay_population_ranges pop,
             pay_batch_headers bth,
             pay_batch_lines btl,
             per_all_assignments_f asg
       where pac.payroll_action_id = pactid
         and pac.action_type = 'BEE'
         and pac.batch_id = bth.batch_id
         and bth.batch_id = btl.batch_id
         and btl.assignment_id = asg.assignment_id
         and btl.effective_date between asg.effective_start_date
                                    and asg.effective_end_date
         and pop.payroll_action_id = pactid
         and pop.chunk_number = chunk
         and asg.person_id = pop.person_id
       order by asg.assignment_id
         for update of asg.assignment_id, btl.batch_line_id;
--
      cursor beecur
      (
         pactid    number,
         stperson  number,
         endperson number
      ) is
      select asg.assignment_id
        from pay_payroll_actions pac,
             pay_batch_lines btl,
             per_all_assignments_f asg
       where pac.payroll_action_id = pactid
         and pac.action_type = 'BEE'
         and pac.batch_id = btl.batch_id
         and btl.assignment_id = asg.assignment_id
         and btl.effective_date between asg.effective_start_date
                                    and asg.effective_end_date
         and asg.person_id between stperson and endperson
       order by asg.assignment_id
         for update of asg.assignment_id, btl.batch_line_id;
--
      asgactid     number;
      assignid     number;
      preasgid     number;
--
   begin
      preasgid := null;
      if (use_pop_person = 1) then
         open beepopcur(pactid,chunk);
      else
         open beecur(pactid,stperson,endperson);
      end if;
      loop
         if (use_pop_person = 1) then
            fetch beepopcur into assignid;
            exit when beepopcur%notfound;
         else
            fetch beecur into assignid;
            exit when beecur%notfound;
         end if;
--
         -- Get an assignment_action_id.
         select pay_assignment_actions_s.nextval
         into   asgactid
         from   dual;
--
         if preasgid is null or preasgid <> assignid then
            -- Insert an assignment action for each action.
            insact(asgactid,assignid,pactid,rand_chunk,null,null);
            preasgid := assignid;
         end if;
--
      end loop;
      if (use_pop_person = 1) then
         close beepopcur;
      else
         close beecur;
      end if;
   end procbee;
--
   ---------------------------------- proctgl ---------------------------------
   /*
      NAME
         proctgl - insert assignment actions for Transfer to GL.
      DESCRIPTION
         Insert assignment actions for the Transfer to GL process.
      NOTES
         The insert of assignment actions for Transfer to GL is based
         on the followig logic: We select all the (Payroll Run)
         assignment actions that have been costed within the
         specified date range. One assignment action is then inserted
         for each of the assignment actions selected. In addition,
         an interlock row is inserted from the newly created TGL action
         to both the Costing action and to the Payroll Run actions that
         were costed by it. (Phew)
   */
   procedure proctgl
   (
      pactid    in number,
      stperson  in number,
      endperson in number,
      chunk     in number,
      rand_chunk in number,
      itpflg    in varchar2,
      use_pop_person in number
   ) is
      cursor tglpopcur
      (
         pactid    number,
         chunk     number,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_N5)
             index(as1 PER_ASSIGNMENTS_F_PK)
             index(as2 PER_ASSIGNMENTS_F_N4)
             USE_NL(pop pos as1 as2) */
             ac2.assignment_action_id,
             ac2.assignment_id,
             ac2.tax_unit_id,
             pa2.action_type
      from   pay_payroll_actions        pa,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             pay_population_ranges      pop,
             per_periods_of_service     pos,
             per_all_assignments_f      as2,
             pay_assignment_actions     ac2,
             per_all_assignments_f      as1
      where  pa.payroll_action_id      = pactid
      and    pa2.consolidation_set_id  = pa.consolidation_set_id
      and    pa2.effective_date between
             pa.start_date and pa.effective_date
      and    ac2.payroll_action_id      = pa2.payroll_action_id
      and    ac2.action_status          = 'C'
      and    pcl.classification_name    = 'TRANSGL'
      and    pa2.action_type            = pcl.action_type
      and    as2.assignment_id          = ac2.assignment_id
      and    pa.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as1.assignment_id          = ac2.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    nvl(decode(pa2.action_type, 'EC', nvl(pa.payroll_id, as1.payroll_id),
                                         'CP', nvl(pa.payroll_id, as1.payroll_id),
                                as1.payroll_id), -999) = nvl(as1.payroll_id, -999)
      and    pos.period_of_service_id   = as2.period_of_service_id
      and    pop.payroll_action_id      = pactid
      and    pop.chunk_number           = chunk
      and    pos.person_id              = pop.person_id
      and    not exists (
             select null
             from   pay_assignment_actions ac3,
                    pay_payroll_actions    pa3,
                    pay_action_interlocks  in3
             where  in3.locked_action_id     = ac2.assignment_action_id
             and    ac3.assignment_action_id = in3.locking_action_id
             and    pa3.payroll_action_id    = ac3.payroll_action_id
             and    pa3.action_type          = pa.action_type)
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status     not in ('C','S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as1.person_id)
      order by ac2.assignment_id, ac2.payroll_action_id, ac2.assignment_action_id
      for update of as2.assignment_id, pos.period_of_service_id;
--
      cursor tglcur
      (
         pactid    number,
         stperson  number,
         endperson number,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_N5)
             index(as1 PER_ASSIGNMENTS_F_PK)
             index(as2 PER_ASSIGNMENTS_F_N4)
             USE_NL(pos as1 as2) */
             ac2.assignment_action_id,
             ac2.assignment_id,
             ac2.tax_unit_id,
             pa2.action_type
      from   pay_payroll_actions        pa,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             per_periods_of_service     pos,
             per_all_assignments_f      as2,
             pay_assignment_actions     ac2,
             per_all_assignments_f      as1
      where  pa.payroll_action_id      = pactid
      and    pa2.consolidation_set_id  = pa.consolidation_set_id
      and    pa2.effective_date between
             pa.start_date and pa.effective_date
      and    ac2.payroll_action_id      = pa2.payroll_action_id
      and    ac2.action_status          = 'C'
      and    pcl.classification_name    = 'TRANSGL'
      and    pa2.action_type            = pcl.action_type
      and    as2.assignment_id          = ac2.assignment_id
      and    pa.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as1.assignment_id          = ac2.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    nvl(decode(pa2.action_type, 'EC', nvl(pa.payroll_id, as1.payroll_id),
                                         'CP', nvl(pa.payroll_id, as1.payroll_id),
                                as1.payroll_id), -999) = nvl(as1.payroll_id, -999)
      and    pos.period_of_service_id   = as2.period_of_service_id
      and    pos.person_id between
             stperson and endperson
      and    not exists (
             select null
             from   pay_assignment_actions ac3,
                    pay_payroll_actions    pa3,
                    pay_action_interlocks  in3
             where  in3.locked_action_id     = ac2.assignment_action_id
             and    ac3.assignment_action_id = in3.locking_action_id
             and    pa3.payroll_action_id    = ac3.payroll_action_id
             and    pa3.action_type          = pa.action_type)
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status     not in ('C','S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as1.person_id)
      order by ac2.assignment_id, ac2.payroll_action_id, ac2.assignment_action_id
      for update of as2.assignment_id, pos.period_of_service_id;
--
      cursor tglmpipcur
      (
         pactid    number,
         chunk     number,
         itpflg    varchar2
      ) is
      select /*+ ORDERED
             index(pa2 PAY_PAYROLL_ACTIONS_PK)
             index(pos PER_PERIODS_OF_SERVICE_N3)
             index(as2 PER_ASSIGNMENTS_F_N4)
             index(ac2 PAY_ASSIGNMENT_ACTIONS_N51)
             index(as1 PER_ASSIGNMENTS_F_PK)
             USE_NL(pos pop as1 as2) */
             ac2.assignment_action_id,
             ac2.assignment_id,
             ac2.tax_unit_id,
             pa2.action_type
      from   pay_payroll_actions        pa,
             pay_population_ranges      pop,
             per_periods_of_service     pos,
             per_all_assignments_f      as2,
             pay_assignment_actions     ac2,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             per_all_assignments_f      as1
      where  pa.payroll_action_id      = pactid
      and    pa2.consolidation_set_id  = pa.consolidation_set_id
      and    pa2.effective_date between
             pa.start_date and pa.effective_date
      and    ac2.payroll_action_id      = pa2.payroll_action_id
      and    ac2.action_status          = 'C'
      and    pcl.classification_name    = 'TRANSGL'
      and    pa2.action_type            = pcl.action_type
      and    as2.assignment_id          = ac2.assignment_id
      and    pa.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as1.assignment_id          = ac2.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    nvl(decode(pa2.action_type, 'EC', nvl(pa.payroll_id, as1.payroll_id),
                                         'CP', nvl(pa.payroll_id, as1.payroll_id),
                                as1.payroll_id), -999) = nvl(as1.payroll_id, -999)
      and    pos.period_of_service_id   = as2.period_of_service_id
      and    pop.payroll_action_id      = pactid
      and    pop.chunk_number           = chunk
      and    pos.person_id              = pop.person_id
      and    not exists (
             select null
             from   pay_assignment_actions ac3,
                    pay_payroll_actions    pa3,
                    pay_action_interlocks  in3
             where  in3.locked_action_id     = ac2.assignment_action_id
             and    ac3.assignment_action_id = in3.locking_action_id
             and    pa3.payroll_action_id    = ac3.payroll_action_id
             and    pa3.action_type          = pa.action_type)
      and    not exists (
             select /*+ ORDERED*/
                    null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status     not in ('C','S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as1.person_id)
      order by ac2.assignment_id, ac2.payroll_action_id, ac2.assignment_action_id
      for update of as2.assignment_id, pos.period_of_service_id;
--
      cursor costedacts
      (
         pactid    number,
         costactid number
      ) is
      select ac1.assignment_action_id
      from   pay_action_interlocks      in2,
             pay_assignment_actions     ac1,
             pay_payroll_actions        pa1,
             pay_action_classifications pcl1,
             per_all_assignments_f      as1,
             pay_payroll_actions        pa
      where  pa.payroll_action_id      = pactid
      and    in2.locking_action_id     = costactid
      and    ac1.assignment_action_id  = in2.locked_action_id
      and    ac1.source_action_id is null
      and    pa1.payroll_action_id     = ac1.payroll_action_id
      and    pcl1.action_type          = pa1.action_type
      and    pcl1.classification_name  = 'COSTED'
      and    as1.assignment_id         = ac1.assignment_id
      and   (as1.payroll_id = pa.payroll_id or pa.payroll_id is null)
      and    pa1.effective_date between
             as1.effective_start_date and as1.effective_end_date;
--
      lockingactid number;
      lockedactid  number;
      assignid     number;
      actype       pay_payroll_actions.action_type%TYPE;
      pmnt_act_type pay_payroll_actions.action_type%TYPE;
      prepay_aa_id  number;
      runactid     number;
      greid        number;
      not_paid     number;
--
   begin
      if (g_many_procs_in_period = 'Y') then
         open tglmpipcur(pactid,chunk,itpflg);
      elsif (use_pop_person = 1) then
         open tglpopcur(pactid,chunk,itpflg);
      else
         open tglcur(pactid,stperson,endperson,itpflg);
      end if;
      loop
         if (g_many_procs_in_period = 'Y') then
            fetch tglmpipcur into lockedactid,assignid,greid,actype;
            exit when tglmpipcur%notfound;
         elsif (use_pop_person = 1) then
            fetch tglpopcur into lockedactid,assignid,greid,actype;
            exit when tglpopcur%notfound;
         else
            fetch tglcur into lockedactid,assignid,greid,actype;
            exit when tglcur%notfound;
         end if;
--
         if (actype <> 'EC' and actype <> 'CP') then

            -- For costings and Retrocostings we create an assignment
            -- action for each run action - and interlock it
            open costedacts(pactid,lockedactid);
            loop
               fetch costedacts into runactid;
               exit when costedacts%notfound;
--
               --
               -- Get an assignment_action_id.
               select pay_assignment_actions_s.nextval
               into   lockingactid
               from   dual;
--
               -- Insert an assignment action for each action.
               insact(lockingactid,assignid,pactid,rand_chunk,greid,null);
--
               -- We follow this with the insert of two interlock
               -- rows. One interlock points to the Costing action
               -- and the other to the Payroll Run action that was
               -- costed in the first place.
               insint(lockingactid,lockedactid);  -- lock to the Costing.
               insint(lockingactid,runactid);  -- lock to original Payroll Run.
            end loop;
            close costedacts;
         else
            -- Estimate Costings and Payment Costings we're not interested
            -- in runs and don't
            -- interlock them

            not_paid := 0;

            -- if Payment Costing check that its from a Prepayment
            -- that hasn't had all pre payments paid
            if (actype = 'CP') then

               select distinct(pa.action_type)
                 into pmnt_act_type
               from pay_action_interlocks  int,
                    pay_assignment_actions aa,
                    pay_payroll_actions    pa
               where int.locking_action_id = lockedactid
                 and aa.assignment_action_id = int.locked_action_id
                 and pa.payroll_action_id = aa.payroll_action_id;

               if (pmnt_act_type in ('P', 'U')) then
                  -- Bug 6919216 - Fixed query to consider only payments
                  -- that are costed and needed be to transferred to GL.
                  select count(*)
                    into not_paid
                    from pay_action_interlocks  int,
                         pay_pre_payments       ppp,
                         pay_org_payment_methods_f opm,
                         pay_assignment_actions paa,
                         pay_payroll_actions ppa
                    where int.locking_action_id  = lockedactid
                      and ppp.assignment_action_id = int.locked_action_id
                      and paa.assignment_action_id = ppp.assignment_action_id
                      and paa.payroll_action_id = ppa.payroll_action_id /* Bug 8619201 - Date eff. join */
                      and ppa.effective_date between opm.effective_start_date and opm.effective_end_date
                      and opm.org_payment_method_id = ppp.org_payment_method_id
                      and opm.cost_payment = 'Y'
                      and opm.transfer_to_gl_flag = 'Y'
                      and not exists
                          (select 1
                           from pay_assignment_actions aa
                           where aa.pre_payment_id = ppp.pre_payment_id);

               end if;

            end if;

            if (not_paid = 0) then

               -- Get an assignment_action_id.
               select pay_assignment_actions_s.nextval
               into   lockingactid
               from   dual;
--
               -- Insert an assignment action for each action.
               insact(lockingactid,assignid,pactid,rand_chunk,greid,null);
--
               -- We interlock the costing action
               insint(lockingactid,lockedactid);  -- lock to the Costing.

            end if;
         end if;
      end loop;
      if (g_many_procs_in_period = 'Y') then
         close tglmpipcur;
      elsif (use_pop_person = 1) then
         close tglpopcur;
      else
         close tglcur;
      end if;
   end proctgl;
--
   ---------------------------------- proqpp ---------------------------------
   /*
      NAME
         proqpp - insert assignment actions for QuickPay prepayment
      DESCRIPTION
         Insert assignment actions for the QuickPay prepayment process
      NOTES
         An assignment action is inserted for the assignment which is specified
         on the target_payroll_action_id column of the Quick Pay action.
         When this is done the action population status is set to complete
   */
   procedure proqpp
   (
      pactid in number,
      lub    in varchar2,
      lul    in varchar2
   ) is
      cursor qpcur ( pactid number ) is
      select ac1.assignment_action_id,
             ac1.assignment_id,
             ac1.tax_unit_id,
             pa1.action_type
      from   pay_assignment_actions ac1,
             pay_payroll_actions    pa1
      where  pa1.payroll_action_id        = pactid
      and    pa1.target_payroll_action_id = ac1.payroll_action_id
      and    not exists (
             select 1
             from   pay_assignment_actions ac2
             where  ac2.payroll_action_id = pactid
             and    ac2.assignment_id     = ac1.assignment_id)
      for update of ac1.assignment_action_id ;
--
      lockingactid number;
      lockedactid  number;
      assignid     number;
      greid        number;
      atype        pay_payroll_actions.action_type%type;
--
   begin
      open qpcur(pactid);
      fetch qpcur into lockedactid, assignid, greid, atype;
      if qpcur%notfound then
           close qpcur ;
           return ;
      end if;
      close qpcur ;
--
      -- Get an assignment_action_id.
      select pay_assignment_actions_s.nextval
      into   lockingactid
      from   dual;
--
      -- Insert an assignment action for the action
      insact(lockingactid,assignid,pactid,1,greid);
--
      -- Insert an interlock row to lock the QuickPay run assignment action
      insint(lockingactid,lockedactid);
--
      -- Set the action population status to 'C' (complete)
      -- Also sets date_earned value.
      update_pact(pactid, 'C', atype, sysdate,lub,lul);
--
   end proqpp ;
   --
   ---------------------------------- procarc --------------------------------
   /*
      NAME
         procarc - insert assignment actions for Archive process
      DESCRIPTION
         Insert assignment actions for the Archive process
      NOTES
         This dynamically calls legislative code to perform the insertion
         of the assignment actions, since it is the legislation that
         knows which assignments are to be included in the archive.
   */
   procedure procarc(pactid    in  number,
                     stperson  in  number,
                     endperson in  number,
                     chunk     in  number
                          )
   is
   sql_cur number;
   ignore number;
   action_proc varchar2(60);
   statem varchar2(256);
   begin
       select assignment_action_code
         into action_proc
         from pay_report_format_mappings_f prfm,
              pay_payroll_actions          ppa
        where ppa.payroll_action_id = pactid
          and ppa.report_type = prfm.report_type
          and ppa.report_qualifier = prfm.report_qualifier
          and ppa.report_category  = prfm.report_category
          and ppa.effective_date between prfm.effective_start_date
                                     and prfm.effective_end_date;
--
      statem := 'BEGIN '||action_proc||'(:pactid, :stperson,'||
                         ' :endperson, :chunk); END;';
--
      sql_cur := dbms_sql.open_cursor;
      dbms_sql.parse(sql_cur,
                     statem,
                     dbms_sql.v7);
      dbms_sql.bind_variable(sql_cur, ':pactid', pactid);
      dbms_sql.bind_variable(sql_cur, ':stperson', stperson);
      dbms_sql.bind_variable(sql_cur, ':endperson', endperson);
      dbms_sql.bind_variable(sql_cur, ':chunk', chunk);
      ignore := dbms_sql.execute(sql_cur);
      dbms_sql.close_cursor(sql_cur);
--
      return;
--
   exception
      when others then
         if (dbms_sql.is_open(sql_cur)) then
           dbms_sql.close_cursor(sql_cur);
         end if;
         raise;
   end procarc;
--
   ---------------------------------- procpp ----------------------------------
   /*
      NAME
         procpp - process a single chunk for PP payment (Bank or Post Office payment)
         process.
      DESCRIPTION
         This function takes a range as defined by the starting and
         ending person_id and inserts a chunk of assignment actions
         plus their associated interlock rows. This function for the
         Bank or Post Office payment (PP) action only.
      NOTES
         <none>
   */
   procedure procpp
   (
      pactid         in number,   -- payroll_action_id.
      stperson       in number,   -- starting person_id of range.
      endperson      in number,   -- ending person_id of range.
      chunk          in number,   -- current chunk_number.
      rand_chunk     in number,   -- current chunk_number.
      itpflg         in varchar2, -- legislation type.
      ptype          in number,   -- payment_type_id.
      use_pop_person in number    -- use population_ranges person_id column
   ) is
      cursor pppopcur
      (
         pactid    number,
         chunk     number,
         itpflg    varchar2,
         ptype     number
      ) is
      select /*+ ORDERED
             INDEX(pa2 PAY_PAYROLL_ACTIONS_N5)
             INDEX(pos PER_PERIODS_OF_SERVICE_N3)
             INDEX(as1 PER_ASSIGNMENTS_N4)
             INDEX(as2 PER_ASSIGNMENTS_F_PK)
             INDEX(act PAY_ASSIGNMENT_ACTIONS_N51)
             index(opm PAY_ORG_PAYMENT_METHODS_F_PK)
             USE_NL(pop pos ppp opm as1 act as2) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppp.pre_payment_id
      from   pay_payroll_actions            pa1,
             pay_payroll_actions            pa2,
             pay_action_classifications     pcl,
             pay_population_ranges          pop,
             per_periods_of_service         pos,
             per_all_assignments_f          as1,
             pay_assignment_actions         act,
             per_all_assignments_f          as2,
             pay_pre_payments               ppp,
             pay_org_payment_methods_f      opm
      where  pa1.payroll_action_id          = pactid
      and    pa2.consolidation_set_id +0    = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id          = pa2.payroll_action_id
      and    act.action_status              = 'C'
      and    pcl.classification_name        = 'PPPAYMENT'
      and    pa2.action_type                = pcl.action_type
      and    as1.assignment_id              = act.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id              = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id + 0             = as1.payroll_id + 0
      and    pos.period_of_service_id       = as1.period_of_service_id
      and    pop.payroll_action_id          = pactid
      and    pop.chunk_number               = chunk
      and    pos.person_id                  = pop.person_id
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    ppp.assignment_action_id       = act.assignment_action_id
      and    opm.org_payment_method_id      = ppp.org_payment_method_id
      and    pa1.effective_date between
             opm.effective_start_date and opm.effective_end_date
      and    opm.payment_type_id         +0 = ptype
      and   (opm.org_payment_method_id = pa1.org_payment_method_id
             or pa1.org_payment_method_id is null)
      and    not exists (
             select null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      and    not exists (
             select /*+ ORDERED*/
                     null
             from   pay_action_interlocks  int,
                    pay_assignment_actions ac2
             where  int.locked_action_id      = act.assignment_action_id
             and    ac2.assignment_action_id  = int.locking_action_id
             and    ac2.pre_payment_id        = ppp.pre_payment_id
             and  not exists (
                 select null
                   from pay_assignment_actions paa_void,
                        pay_action_interlocks  pai_void,
                        pay_payroll_actions    ppa_void
                  where pai_void.locked_action_id = ac2.assignment_action_id
                    and pai_void.locking_action_id = paa_void.assignment_action_id
                    and paa_void.payroll_action_id = ppa_void.payroll_action_id
                    and ppa_void.action_type = 'D')
             )
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
      cursor ppcur
      (
         pactid    number,
         stperson  number,
         endperson number,
         itpflg    varchar2,
         ptype     number
      ) is
      select /*+ ORDERED
             INDEX(pa2 PAY_PAYROLL_ACTIONS_N5)
             INDEX(pos PER_PERIODS_OF_SERVICE_N3)
             INDEX(as1 PER_ASSIGNMENTS_N4)
             INDEX(as2 PER_ASSIGNMENTS_F_PK)
             INDEX(act PAY_ASSIGNMENT_ACTIONS_N51)
             index(opm PAY_ORG_PAYMENT_METHODS_F_PK)
             USE_NL(pos ppp opm as1 act as2) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppp.pre_payment_id
      from   pay_payroll_actions            pa1,
             pay_payroll_actions            pa2,
             pay_action_classifications     pcl,
             per_periods_of_service         pos,
             per_all_assignments_f          as1,
             pay_assignment_actions         act,
             per_all_assignments_f          as2,
             pay_pre_payments               ppp,
             pay_org_payment_methods_f      opm
      where  pa1.payroll_action_id          = pactid
      and    pa2.consolidation_set_id +0    = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id          = pa2.payroll_action_id
      and    act.action_status              = 'C'
      and    pcl.classification_name        = 'PPPAYMENT'
      and    pa2.action_type                = pcl.action_type
      and    as1.assignment_id              = act.assignment_id
      and    pa2.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id              = act.assignment_id
      and    pa1.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id + 0             = as1.payroll_id + 0
      and    pos.period_of_service_id       = as1.period_of_service_id
      and    pos.person_id between stperson and endperson
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    ppp.assignment_action_id       = act.assignment_action_id
      and    opm.org_payment_method_id      = ppp.org_payment_method_id
      and    pa1.effective_date between
             opm.effective_start_date and opm.effective_end_date
      and    opm.payment_type_id         +0 = ptype
      and   (opm.org_payment_method_id = pa1.org_payment_method_id
             or pa1.org_payment_method_id is null)
      and    not exists (
             select null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      and    not exists (
             select /*+ ORDERED*/
                     null
             from   pay_action_interlocks  int,
                    pay_assignment_actions ac2
             where  int.locked_action_id      = act.assignment_action_id
             and    ac2.assignment_action_id  = int.locking_action_id
             and    ac2.pre_payment_id        = ppp.pre_payment_id
             and  not exists (
                 select null
                   from pay_assignment_actions paa_void,
                        pay_action_interlocks  pai_void,
                        pay_payroll_actions    ppa_void
                  where pai_void.locked_action_id = ac2.assignment_action_id
                    and pai_void.locking_action_id = paa_void.assignment_action_id
                    and paa_void.payroll_action_id = ppa_void.payroll_action_id
                    and ppa_void.action_type = 'D')
             )
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
      cursor ppmpipcur
      (
         pactid    number,
         chunk     number,
         itpflg    varchar2,
         ptype     number
      ) is
      select /*+ ORDERED
             INDEX(pa2 PAY_PAYROLL_ACTIONS_PK)
             INDEX(pos PER_PERIODS_OF_SERVICE_N3)
             INDEX(as1 PER_ASSIGNMENTS_N4)
             INDEX(as2 PER_ASSIGNMENTS_F_PK)
             INDEX(act PAY_ASSIGNMENT_ACTIONS_N51)
             index(opm PAY_ORG_PAYMENT_METHODS_F_PK)
             USE_NL(pos pop ppp opm as1 act as2) */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppp.pre_payment_id
      from   pay_payroll_actions            pa1,
             pay_population_ranges          pop,
             per_periods_of_service         pos,
             per_all_assignments_f          as1,
             pay_assignment_actions         act,
             pay_payroll_actions            pa2,
             pay_action_classifications     pcl,
             per_all_assignments_f          as2,
             pay_pre_payments               ppp,
             pay_org_payment_methods_f      opm
      where  pa1.payroll_action_id          = pactid
      and    pa2.consolidation_set_id +0    = pa1.consolidation_set_id
      and    pa2.effective_date between
             pa1.start_date and pa1.effective_date
      and    act.payroll_action_id          = pa2.payroll_action_id
      and    act.action_status              = 'C'
      and    pcl.classification_name        = 'PPPAYMENT'
      and    pa2.action_type                = pcl.action_type
      and    as1.assignment_id              = act.assignment_id
      and    pa1.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    as2.assignment_id              = act.assignment_id
      and    pa2.effective_date between
             as2.effective_start_date and as2.effective_end_date
      and    as2.payroll_id + 0             = as1.payroll_id + 0
      and    pos.period_of_service_id       = as1.period_of_service_id
      and    pop.payroll_action_id          = pactid
      and    pop.chunk_number               = chunk
      and    pos.person_id                  = pop.person_id
      and   (as1.payroll_id = pa1.payroll_id or pa1.payroll_id is null)
      and    ppp.assignment_action_id       = act.assignment_action_id
      and    opm.org_payment_method_id      = ppp.org_payment_method_id
      and    pa1.effective_date between
             opm.effective_start_date and opm.effective_end_date
      and    opm.payment_type_id         +0 = ptype
      and   (opm.org_payment_method_id = pa1.org_payment_method_id
             or pa1.org_payment_method_id is null)
      and    not exists (
             select null
             from   per_all_assignments_f  as3,
                    pay_assignment_actions ac3
             where  itpflg                = 'N'
             and    ac3.payroll_action_id = pa2.payroll_action_id
             and    ac3.action_status    not in ('C', 'S')
             and    as3.assignment_id     = ac3.assignment_id
             and    pa2.effective_date between
                    as3.effective_start_date and as3.effective_end_date
             and    as3.person_id         = as2.person_id)
      and    not exists (
             select /*+ ORDERED*/
                     null
             from   pay_action_interlocks  int,
                    pay_assignment_actions ac2
             where  int.locked_action_id      = act.assignment_action_id
             and    ac2.assignment_action_id  = int.locking_action_id
             and    ac2.pre_payment_id        = ppp.pre_payment_id
             and  not exists (
                 select null
                   from pay_assignment_actions paa_void,
                        pay_action_interlocks  pai_void,
                        pay_payroll_actions    ppa_void
                  where pai_void.locked_action_id = ac2.assignment_action_id
                    and pai_void.locking_action_id = paa_void.assignment_action_id
                    and paa_void.payroll_action_id = ppa_void.payroll_action_id
                    and ppa_void.action_type = 'D')
             )
      order by act.assignment_id
      for update of as1.assignment_id, pos.period_of_service_id;
--
      lockingactid  number;
      lockedactid   number;
      assignid      number;
      prepayid      number;
      greid         number;
--
   -- algorithm is quite similar to the other process cases,
   -- but we have to take into account assignments and
   -- personal payment methods.
   begin
      if (g_many_procs_in_period = 'Y') then
         open ppmpipcur(pactid,chunk,itpflg,ptype);
      elsif (use_pop_person = 1) then
         open pppopcur(pactid,chunk,itpflg,ptype);
      else
         open ppcur(pactid,stperson,endperson,itpflg,ptype);
      end if;
      loop
         if (g_many_procs_in_period = 'Y') then
            fetch ppmpipcur into lockedactid,assignid,greid,prepayid;
            exit when ppmpipcur%notfound;
         elsif (use_pop_person = 1) then
            fetch pppopcur into lockedactid,assignid,greid,prepayid;
            exit when pppopcur%notfound;
         else
            fetch ppcur into lockedactid,assignid,greid,prepayid;
            exit when ppcur%notfound;
         end if;
--
        -- we need to insert one action for each of the
        -- rows that we return from the cursor (i.e. one
        -- for each assignment/pre-payment).
        select pay_assignment_actions_s.nextval
        into   lockingactid
        from   dual;
--
        -- insert the action record.
        insact(lockingactid,assignid,pactid,rand_chunk,greid,prepayid);
--
         -- insert an interlock to this action.
         insint(lockingactid,lockedactid);
--
      end loop;
      if (g_many_procs_in_period = 'Y') then
         close ppmpipcur;
      elsif (use_pop_person = 1) then
         close pppopcur;
      else
         close ppcur;
      end if;
      commit;
   end procpp;
   ----------------------------------- asact ----------------------------------
   /*
      NAME
         asact - insert assignment actions and interlocks
      DESCRIPTION
         Overall control of the insertion of assignment actions
         and interlocks for the non run payroll actions.
      NOTES
         <none>
   */
   procedure asact
   (
      pactid in number,   -- payroll_action_id
      atype  in varchar2, -- action_type.
      itpflg in varchar2, -- independent time periods flag.
      ptype  in number,   -- payment_type_id.
      lub    in varchar2, -- last_updated_by.
      lul    in varchar2, -- last_update_login.
      use_pop_person in number -- use population_ranges person_id column
   ) is
      QPPREPAY constant varchar2(1) := 'U';
      PREPAY   constant varchar2(1) := 'P';
      COSTING  constant varchar2(1) := 'C';
      ESTCOSTING  constant varchar2(2) := 'EC';
      PAYMCOSTING constant varchar2(2) := 'CP';
      TRANSGL  constant varchar2(1) := 'T';
      MAGTAPE  constant varchar2(1) := 'M';
      CASH     constant varchar2(1) := 'A';
      CHEQUE   constant varchar2(1) := 'H';
      ARCHIVE  constant varchar2(1) := 'X';
      BEE      constant varchar2(3) := 'BEE';
      PPPAYMENT constant varchar2(2) := 'PP';
--
      l_found   boolean;
      stperson  number;
      endperson number;
      chunk     number;
      rand_chunk     number;
      multi_asg_fg pay_all_payrolls_f.multi_assignments_flag%type;
      l_use_pop_person number := use_pop_person;
   begin
       pay_core_utils.get_action_parameter('SET_DATE_EARNED',
                                           g_set_date_earned,
                                           l_found);
       if (l_found = FALSE) then
          g_set_date_earned := 'N';
       end if;
--
      -- As quick pay only has a single assignment action process separately
      if (atype = QPPREPAY) then
          proqpp(pactid,lub,lul);
          commit ;
          return ;
      elsif (atype = PREPAY) then
        select nvl(multi_assignments_flag, 'N')
        into multi_asg_fg
        from pay_all_payrolls_f prl,
             pay_payroll_Actions pact
        where pact.payroll_action_id = pactid
        and   prl.payroll_id = pact.payroll_id
        and   pact.effective_date between prl.effective_start_date
                                      and prl.effective_end_date;
      end if;
--
      -- find value of MANY_PROCS_IN_PERIOD pay_action_parameter
      if cached = FALSE THEN
         begin
            select parameter_value
            into   g_many_procs_in_period
            from   pay_action_parameters
            where  parameter_name = 'MANY_PROCS_IN_PERIOD';
         exception
            when others then
               g_many_procs_in_period := 'N';
         end;
         begin
            select parameter_value
            into   g_plsql_proc_insert
            from   pay_action_parameters
            where  parameter_name = 'PLSQL_PROC_INSERT';
         exception
            when others then
               g_plsql_proc_insert := 'Y';
         end;
         cached := TRUE;
      end if;
--
      -- If a payment process AND PLSQL_PROC_INSERT
      -- enforce range_person_id (many_procs_in_period unless
      -- was disabled above)
      if (atype = MAGTAPE or atype = CHEQUE or
          atype = CASH or atype = PPPAYMENT) then
         if g_plsql_proc_insert = 'Y' then
            if g_many_procs_in_period = 'N' then
               l_use_pop_person := 1;
            else
               g_many_procs_in_period := 'Y';
            end if;
         end if;
      end if;
--
      -- MANY_PROCS_IN_PERIOD is now used if RANGE_PERSON_ID is set
      -- and MANY_PROCS_IN_PERIOD was not set to N
      if (l_use_pop_person = 1 and
          g_many_procs_in_period <> 'N') then
         g_many_procs_in_period := 'Y';
      end if;
--
      dbms_lock.allocate_unique(
         lockname         => 'PAY_PAYROLL_ACTIONS_'||pactid,
         lockhandle       => g_lckhandle);
--
      loop
         -- start by processing the range row.
         rangerow(pactid,lub,lul,stperson,endperson,chunk,rand_chunk,atype);
         -- chunk begin null indicates end of processing.
         exit when chunk is null;
--
         -- 'lock' the range row grabbed by updating is status.
         -- check to see if want to use randomised chnks or sequential
--
           update pay_population_ranges rge
           set    rge.range_status      = 'P'
           where  rge.payroll_action_id = pactid
           and    rge.chunk_number  = chunk;
--
         commit;
--
         begin
            if(atype = PREPAY) then
               proc_prepay(pactid,stperson,endperson,chunk,rand_chunk,'PREPAID',
                           itpflg,multi_asg_fg,l_use_pop_person);
            elsif(atype = COSTING) then
               proc_costing(pactid,stperson,endperson,chunk,rand_chunk,'COSTED',
                            itpflg,l_use_pop_person);
            elsif(atype = PAYMCOSTING) then
               proc_paymcosting(pactid,stperson,endperson,chunk,rand_chunk,'COSTEDPAYM',
                            itpflg,l_use_pop_person);
            elsif(atype = ESTCOSTING) then
               proc_estcosts(pactid,stperson,endperson,chunk,rand_chunk,'COSTED',
                             itpflg,l_use_pop_person);
            elsif(atype = TRANSGL) then
               proctgl(pactid,stperson,endperson,chunk,rand_chunk,itpflg,l_use_pop_person);
            elsif(atype = MAGTAPE) then
               procmag(pactid,stperson,endperson,chunk,rand_chunk,itpflg,ptype,
                       l_use_pop_person);
            elsif(atype = CASH) then
               proccash(pactid,stperson,endperson,chunk,rand_chunk,itpflg,l_use_pop_person);
            elsif(atype = CHEQUE) then
               procchq(pactid,stperson,endperson,chunk,rand_chunk,itpflg,ptype,
                           'CHEQUEWRITER',l_use_pop_person);
            elsif(atype = ARCHIVE) then
               procarc(pactid,stperson,endperson,chunk);
            elsif(atype = BEE) then
              procbee(pactid,stperson,endperson,chunk,rand_chunk,l_use_pop_person);
            elsif(atype = PPPAYMENT) then
               procpp(pactid,stperson,endperson,chunk,rand_chunk,itpflg,ptype,
                      l_use_pop_person);
            elsif(atype = pay_proc_environment_pkg.PYG_AT_PRU) then
               procpru(pactid,
                       stperson,
                       endperson,
                       chunk,
                       rand_chunk,
                       'P_ROLLEDUP',
                       itpflg,
                       l_use_pop_person
                      );
            else
               -- unrecognised action type.
               hr_utility.set_message(801,'HR_UNRECOGNISED_ACTION_TYPE');
               hr_utility.raise_error;
            end if;
--
            -- we have processed the range, so delete the row.
            delete from pay_population_ranges rge
            where  rge.payroll_action_id = pactid
            and    rge.chunk_number = chunk;
--
            commit;

         exception
            when others then

               rollback;
--
               -- set chunk to 'E'rrored
               update pay_population_ranges rge
               set   rge.range_status = 'E'
               where rge.payroll_action_id = pactid
               and   rge.chunk_number  = chunk;

               update_pact(pactid, 'E', itpflg,sysdate,stperson,endperson);

               commit;

               raise;
--
         end;
--

      end loop;
   end asact;
-----------------------------------------------------------------------------
-- Name: ins_additional_asg_action
-- Desc: Insert an assignment action to an already existing payroll action.
-----------------------------------------------------------------------------
Procedure ins_additional_asg_action(p_asg_id      number   default null
                                   ,p_pact_id     number
                                   ,p_gre_id      number   default null
                                   ,p_object_id   number   default null
                                   ,p_object_type varchar2 default null
                                   )
is
cursor pact_details
is
select ppa.action_status
,      ppa.action_type
,      rfm.report_name
from   pay_payroll_actions ppa
,      pay_report_format_mappings_f rfm
where  ppa.payroll_action_id = p_pact_id
and    ppa.report_type = rfm.report_type(+)
and    ppa.report_qualifier = rfm.report_qualifier(+)
and    ppa.report_category = rfm.report_category(+);
--
cursor get_existing_person_chunk(p_ppa_id number
                                ,p_paf_id number)
is
select paa.chunk_number
from   pay_assignment_actions paa
,      per_all_assignments_f paf
,      per_all_people_f ppf
where  paa.payroll_action_id = p_ppa_id
and    paa.assignment_id = p_paf_id
and    paa.assignment_id = paf.assignment_id
and    paf.person_id = ppf.person_id
and    rownum = 1;
--
-- This cursor returns the chunck number of the chunck with the least number
-- of assignment actions in it. If there is more than one chunk all with the
-- same min number of asg actions, then it will pick the min chunk number.
--
cursor get_min_chunk(p_ppa_id number)
is
select min(chunk_number)
from (select chunk_number, count(assignment_action_id) ct
      from   pay_assignment_actions
      where  payroll_action_id = p_ppa_id
      group by chunk_number) v1
where v1.ct = (select min(v2.ct) from (select count(assignment_action_id) ct
                                       from pay_assignment_actions
                                       where payroll_action_id = p_ppa_id
                                       group by chunk_number) v2);
--
l_act_status pay_payroll_actions.action_status%type;
l_act_type   pay_payroll_actions.action_type%type;
l_rep_name   pay_report_format_mappings_f.report_name%type;
l_chunk      pay_assignment_actions.chunk_number%type;
l_asg_act_id pay_assignment_actions.assignment_action_id%type;
--
BEGIN
--
-- Determine whether new action can be inserted: 1. if payroll_action is
-- still processing - error. 2. If it is an archive action and there is an
-- associated Oracle Reports report - error. 3. Else insert action
--
open pact_details;
fetch pact_details into l_act_status, l_act_type, l_rep_name;
if pact_details%notfound then
--
  close pact_details;
  hr_utility.set_message(801, 'PAY_33170_INVALID_PACT_ID');
  hr_utility.raise_error;
  --
else
  close pact_details;
  if l_act_status = 'P' then
  --
    hr_utility.set_message(801, 'PAY_33171_PACT_PROCESSING');
    hr_utility.raise_error;
  elsif l_act_type = 'X' then
  --
    if l_rep_name is not null then
    --
      hr_utility.set_message(801, 'PAY_33172_ARCH_REPORT');
      hr_utility.raise_error;
    end if;
  end if;
end if;
--
-- Determine what chunk number to give the new asg action
--
-- does this person already have a chunk?
--
open  get_existing_person_chunk(p_pact_id, p_asg_id);
fetch get_existing_person_chunk into l_chunk;
if get_existing_person_chunk%found then
--
  close get_existing_person_chunk;
  --
  -- insert action using l_chunk
  --
else -- new person, so figure out smallest chunk
--
  open  get_min_chunk(p_pact_id);
  fetch get_min_chunk into l_chunk;
  if get_min_chunk%notfound then
  --
    close get_min_chunk;
    --
  else
    close get_min_chunk;
  end if;
  --
end if;
--
select pay_assignment_actions_s.nextval
into l_asg_act_id
from dual;
--
-- insert the action
--
  insert into pay_assignment_actions
  (assignment_action_id
  ,assignment_id
  ,payroll_action_id
  ,action_status
  ,chunk_number
  ,action_sequence
  ,pre_payment_id
  ,object_version_number
  ,tax_unit_id
  ,source_action_id
  ,object_id
  ,object_type
  ,start_date
  ,end_date
  )
  values
  (l_asg_act_id
  ,p_asg_id
  ,p_pact_id
  ,'U'
  ,l_chunk
  ,l_asg_act_id
  ,''
  ,1
  ,p_gre_id
  ,''
  ,p_object_id
  ,p_object_type
  ,''
  ,''
  );
  --
END ins_additional_asg_action;
-----------------------------------------------------------------------------
end hr_nonrun_asact;

/
