--------------------------------------------------------
--  DDL for Package Body PJI_LAUNCH_UPP_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_LAUNCH_UPP_MAIN" as
  /* $Header: PJILN01B.pls 120.0.12010000.8 2010/06/09 06:08:21 rkuttiya noship $ */

PROCEDURE log1
(p_msg IN VARCHAR2 ,
 p_module IN VARCHAR2 DEFAULT '5701238')
IS
pragma autonomous_transaction;
BEGIN
        insert into FND_LOG_MESSAGES
      (MODULE, LOG_LEVEL, MESSAGE_TEXT
      , SESSION_ID, USER_ID, TIMESTAMP
      , LOG_SEQUENCE, ENCODED, NODE
      , NODE_IP_ADDRESS, PROCESS_ID, JVM_ID
      , THREAD_ID, AUDSID, DB_INSTANCE
      , TRANSACTION_CONTEXT_ID)
      values
      (p_module, 6, p_msg, -1, 0, sysdate
	  , FND_LOG_MESSAGES_S.NEXTVAL, 'Y', null
	  , null, NULL, NULL, NULL, NULL, 1, NULL);
      COMMIT;
END log1;

PROCEDURE UPDATE_BATCH_CONC_STATUS
(
  p_first_time_flag   in  varchar2,
  x_count_batches     out  NOCOPY  number,
  x_count_running     out  NOCOPY  number,
  x_count_errored     out  NOCOPY  number,
  x_count_completed   out NOCOPY   number,
  x_count_pending     out  NOCOPY  number
)
IS

   TYPE Prg_Batch_t IS
         TABLE OF pji_prg_batch%ROWTYPE
         INDEX BY BINARY_INTEGER;


   l_Prg_Batch_t    Prg_Batch_t;

   CURSOR prg_group IS
   SELECT
        *
   FROM
        pji_prg_batch
   ORDER BY
         DECODE(nvl(curr_request_status,'PENDING') ,
                     'PENDING' , 1,
                     'ERRORED'  , 2, 3 ) ;

   l_count_batches  number := 0;
   l_count_running  number := 0;
   l_count_errored  number := 0;
   l_count_completed  number := 0;
   l_count_pending  number := 0;

   l_first_time_flag  varchar2(1) := 'N';

   l_rowcount number := 0;

BEGIN

       l_first_time_flag := nvl(p_first_time_flag,'N' );

      l_Prg_Batch_t.delete;
       OPEN prg_group;
       FETCH prg_group BULK COLLECT
                 INTO l_Prg_Batch_t;

       l_rowcount := prg_group%rowcount;

       CLOSE prg_group;

       --- Get the status of the already launched concurrent request and update the
       --- status into the local table and also database table.

       l_count_running := 0;
       l_count_errored := 0;
       l_count_pending := 0;

    IF l_rowcount > 0 THEN

       FOR i IN l_Prg_Batch_t.first..l_Prg_Batch_t.last LOOP


        IF ( nvl(l_Prg_Batch_t(i).curr_request_id,-1)  > 0 )  THEN
           IF  ( PJI_PROCESS_UTIL.REQUEST_STATUS(
                               'OKAY',
                               l_Prg_Batch_t(i).curr_request_id,
                               'PJI_PJP_SUMMARIZE_INCR')  )
           THEN
               IF ( PJI_PROCESS_UTIL.REQUEST_STATUS(
                                  'RUNNING',
                                  l_Prg_Batch_t(i).curr_request_id,
                                  'PJI_PJP_SUMMARIZE_INCR') )
               THEN
                 l_Prg_Batch_t(i).curr_request_status := 'RUNNING';
                 l_count_running := l_count_running + 1;

                 l_count_batches := l_count_batches + 1;

               ELSE
                 l_Prg_Batch_t(i).curr_request_status := 'COMPLETED';
                 l_count_completed := l_count_completed + 1;
               END IF;

            ELSE

             -- l_first_time_flag is set to 'Y' means that
             -- the status are re-update , the earlier failed
             -- process should be marked as ERRORED
             --
             -- l_first_time_flag is set to 'N' means that
             -- the status are re-update during the running loop,
             -- f concurrent request is failed means the process
             -- should be marked as R-ERRORED so that this is not
             -- re-submitted during this run only.

             if (l_first_time_flag = 'Y' ) then
               l_Prg_Batch_t(i).curr_request_status := 'ERRORED';
             else
               l_Prg_Batch_t(i).curr_request_status := 'R-ERRORED';
             end if;

             l_count_errored := l_count_errored + 1;
            END IF;

         ELSE

           -- when you come first time then only you need to update
           -- the status to PENDING when either the request_id is null
           -- or -1.
           -- During the second run they should not be marked as pending
           --- as these might be updated as SUBMIT-ERRORED.
           -- due to some reason if the concurrent program is not getting
           -- submitted then we should not submit in infinite loop.

           if (l_first_time_flag = 'Y' ) then

             l_Prg_Batch_t(i).curr_request_status := 'PENDING';
             l_count_pending := l_count_pending + 1;

           end if;


         END IF;

          -- Update the current status of the concurrent request back
          -- into the table . for the request that are marked as
          -- ERRORED we should not mark then back to R-ERRORED.
          -- R-ERRORED is mainly  for the process that are errored
          -- during this run , so that these need not be picked up for
          -- re-submission

          UPDATE
            pji_prg_batch
          SET
            curr_request_status = decode(nvl(curr_request_status,'PENDING'),
                                         'ERRORED',
                                         decode(l_Prg_Batch_t(i).curr_request_status,
                                                'R-ERRORED',curr_request_status,
                                                l_Prg_Batch_t(i).curr_request_status ),
                                         l_Prg_Batch_t(i).curr_request_status )
          WHERE
            batch_name = l_Prg_Batch_t(i).batch_name;

         END LOOP;

         commit;

--Sridhar July - 10th change

           BEGIN

           UPDATE pji_prg_batch
           SET curr_request_status = 'ERRORED'
           WHERE nvl(curr_request_id,-1) > 0
           and curr_request_status = 'COMPLETED'
           and not exists
           (  select 'x' from fnd_concurrent_requests x where x.request_id = curr_request_id );

            EXCEPTION
                WHEN no_data_found THEN
                  null;
           END;

        END IF;  -- l_rowcount if statement


x_count_batches  := l_count_batches;
x_count_running  := l_count_running;
x_count_errored  := l_count_errored;
x_count_completed  := l_count_completed;
x_count_pending  := l_count_pending;

end UPDATE_BATCH_CONC_STATUS;

PROCEDURE LAUNCH_UPP_PROCESS
(
    errbuf                    out  NOCOPY  varchar2,
    retcode                   out  NOCOPY  varchar2,
    p_num_of_projects           in     number ,
    p_temp_table_size           in     number ,
    p_num_parallel_runs         in     number ,
    p_num_of_batches            in     number ,
    p_wait_time_seconds         in     number ,
    p_regenerate_batches        in     varchar2  ,
    p_incremental_mode          in     varchar2,
    P_OPERATING_UNIT            in     number,
    p_project_status            in     varchar2
)
is

   TYPE Prg_Batch_t IS
      TABLE OF pji_prg_batch%ROWTYPE
      INDEX BY BINARY_INTEGER;

   l_Prg_Batch_t    Prg_Batch_t;

   curr_count_batches  number := 0;

   l_count_batches  number := 0;
   l_count_running  number := 0;
   l_count_errored  number := 0;
   l_count_completed  number := 0;
   l_count_pending  number := 0;
   l_count_rerrored number := 0;  /* Added for bug 8416116 */

   l_num_parallel_runs  number := 0;
   l_test number := 0;
   l_request_id number := -1;
   l_first_time_flag varchar2(1) := 'Y';
   l_no_running_request varchar2(1) := 'N';
   l_num_of_batches  number := 0;

   CURSOR prg_group IS
   SELECT *
   FROM pji_prg_batch
   ORDER BY
         DECODE(nvl(curr_request_status,'PENDING') ,
                     'PENDING' , 2,
                     'ERRORED'  , 1, 3 ) , batch_name ; --Bug 7121511

   l_time_in_seconds number ;

l_reg_flag  varchar2(1);
l_reg_num   number ;

BEGIN

 if ( nvl(p_regenerate_batches,'N') = 'Y' )  then

     l_reg_num := 10000;

     begin

       select 'Y' into l_reg_flag
       from dual
       where exists
       ( select 'x' from pji_prg_batch where substr(batch_name,10,3) = '-R-' );

       select to_number(substr(batch_name,13,5)) into l_reg_num
       from pji_prg_batch
       where substr(batch_name,10,3) = '-R-'
       and rownum = 1;

       if ( l_reg_num >= 99999 ) then
           l_reg_num := 10000;
       else
           l_reg_num := l_reg_num + 1;
       end if;

     exception
           when no_data_found then
             l_reg_flag := 'N';
     end;

    create_upp_batches(p_temp_table_size,
                       p_num_of_projects,
                       p_incremental_mode,
                       P_OPERATING_UNIT,
                       p_project_status) ; -- Call here the batch creation procedure

    update pji_prg_group
    set batch_name = 'UPP-BATCH'||'-R-'||l_reg_num||substr(batch_name,10,5) ;

    update pji_prg_batch
    set batch_name = 'UPP-BATCH'||'-R-'||l_reg_num||substr(batch_name,10,5) ;

    --bug 7121511 start
    update pji_prg_group c set c.batch_name = c.batch_name||'-ERR'
    where c.prg_group in
    ( select distinct b.prg_group
	     from pji_pjp_proj_batch_map a,
	       pji_prg_group b
	     where a.project_id = b.project_id
             and b.prg_group is not null
    );

    update pji_prg_group c set c.batch_name = c.batch_name||'-ERR'
    where c.project_id  in
    ( select distinct b.project_id
	     from pji_pjp_proj_batch_map a,
	       pji_prg_group b
	     where a.project_id = b.project_id
             and b.prg_group is  null
    );
	--bug 7121511 end

      Insert into pji_prg_batch
            ( batch_name,
              wbs_total,
              prg_total,
              delta_total,
              total_count,
              project_count
            )
      select distinct batch_name ,0,0,0,0,0
      from pji_prg_group where batch_name like '%-ERR';

-- bug 6276970 & 6505683
-- Sridhar Added below insert and update statement

      update pji_prg_group c set c.batch_name =  ( select d1.value
       from pji_system_parameters d1 , pji_pjp_proj_batch_map a1,
       pji_prg_group b1
       where a1.project_id = b1.project_id
       and c.batch_name like '%-ERR'
       and b1.prg_group = c.prg_group
       and to_number(substr(d1.name,8,instr(d1.name,'$',1) - 8)) = a1.worker_id   -- Sridhar changed  added substr june-11th  V1_CHANGE
       and d1.name like '%FROM_PROJECT'
       and d1.value like 'UPP-BATCH%'
       and b1.prg_group is not null   -- Sridhar changed  added not null condition june-11th  V1_CHANGE
       and rownum=1)
       where
     c.batch_name like '%-ERR'
     and exists
    ( select 'x'
      from pji_system_parameters d2 , pji_pjp_proj_batch_map a2,
      pji_prg_group b2
      where a2.project_id = b2.project_id
      and b2.prg_group = c.prg_group
      and to_number(substr(d2.name,8,instr(d2.name,'$',1) - 8)) = a2.worker_id   -- Sridhar changed added substr june-11th  V1_CHANGE
      and d2.name like '%FROM_PROJECT'
      and b2.prg_group is not null   -- Sridhar changed added not null condition june-11th  V1_CHANGE
      and d2.value like 'UPP-BATCH%' );

-- Sridhar changed  june-11th Added new Update Statement START  V1_CHANGE

      update pji_prg_group c set c.batch_name =  ( select d1.value
       from pji_system_parameters d1 , pji_pjp_proj_batch_map a1,
       pji_prg_group b1
       where a1.project_id = b1.project_id
       and c.batch_name like '%-ERR'
       and b1.project_id = c.project_id
       and to_number(substr(d1.name,8,instr(d1.name,'$',1) - 8)) = a1.worker_id
       and d1.name like '%FROM_PROJECT'
       and d1.value like 'UPP-BATCH%'
       and b1.prg_group is null
       and rownum=1)
       where
     c.batch_name like '%-ERR'
     and exists
    ( select 'x'
      from pji_system_parameters d2 , pji_pjp_proj_batch_map a2,
      pji_prg_group b2
      where a2.project_id = b2.project_id
      and b2.project_id = c.project_id
      and to_number(substr(d2.name,8,instr(d2.name,'$',1) - 8)) = a2.worker_id
      and d2.name like '%FROM_PROJECT'
      and b2.prg_group is  null
      and d2.value like 'UPP-BATCH%' );

       Insert into pji_prg_batch
            ( batch_name,
              wbs_total,
              prg_total,
              delta_total,
              total_count,
              project_count
            )
      select distinct batch_name ,0,0,0,0,0
      from pji_prg_group a2 where a2.batch_name  not in ( select c1.batch_name from pji_prg_batch c1 );

      UPDATE pji_prg_batch  c
      SET c.curr_request_id  =
      	(
      	select b.value
        from pji_system_parameters a ,  pji_system_parameters b
        where a.name like 'PJI_PJP%FROM_PROJECT'
        and to_number(substr(a.name,8,instr(a.name,'$',1) - 8)) = to_number(substr(b.name,8,instr(b.name,'$',1) - 8))
        and b.name like 'PJI_PJP%PJI_PJP%'
        and c.batch_name = a.value
        and b.value is not null
      	)
       WHERE exists
       ( select b.value
        from pji_system_parameters a ,  pji_system_parameters b
        where a.name like 'PJI_PJP%FROM_PROJECT'
        and to_number(substr(a.name,8,instr(a.name,'$',1) - 8)) = to_number(substr(b.name,8,instr(b.name,'$',1) - 8))
        and b.name like 'PJI_PJP%PJI_PJP%'
        and c.batch_name = a.value
        and b.value is not null ) ;

      delete from pji_prg_batch a
      where not exists
      (
       select 'x'
       from pji_prg_group b
       where a.batch_name = b.batch_name );

     commit;
 end if; /* if statement for re-generate batches */

   l_time_in_seconds :=  nvl(p_wait_time_seconds,60*5) ;

   if ( l_time_in_seconds <= 0 ) then
      l_time_in_seconds := 60*5;
   end if;

   if ( nvl(p_num_of_batches,0) <= 0 )  then
    l_num_of_batches := 50;  /* Changed the default value from 3 to 50 for bug 	7639329 */
   else
     l_num_of_batches := p_num_of_batches;
   end if;

   if ( nvl(p_num_parallel_runs,0) <= 0 )  then
    l_num_parallel_runs := 3;
   else
     l_num_parallel_runs := p_num_parallel_runs;
   end if;

   l_count_batches := 0;

    UPDATE_BATCH_CONC_STATUS
    (
      'Y'   ,
      l_count_batches     ,
      l_count_running     ,
      l_count_errored     ,
      l_count_completed   ,
      l_count_pending
    );

    curr_count_batches := l_count_batches;

--- Check if any rows exists in the pji_prg_batches that
--- are still pending or errored or the table is empty
---- if YES then call the procedure that creates the batches.

   BEGIN

       SELECT count(*) into l_test
       FROM pji_prg_batch
       WHERE nvl(curr_request_status,'PENDING') <> 'COMPLETED' ;

       IF ( l_test = 0 ) THEN

          create_upp_batches(p_temp_table_size,
                             p_num_of_projects,
                             p_incremental_mode,
                             P_OPERATING_UNIT,
                             p_project_status) ; -- Call here the batch creation procedure

          UPDATE_BATCH_CONC_STATUS  -- after creating
          (
            'Y'   ,  -- value has to 'Y'
            l_count_batches     ,
            l_count_running     ,
            l_count_errored     ,
            l_count_completed   ,
            l_count_pending
          );

          curr_count_batches := l_count_batches;

       END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
       null;
      WHEN OTHERS THEN
       raise;
   END ;


  l_first_time_flag := 'N';

  -- This is the loop will will run till the input number of batches are launched
  --- or there are no batches left to be processed.

   l_no_running_request := 'N';

  LOOP

        -- Check if the total number of current running process is equal or greater than
        -- then number of batches that is requested via input parameters.
        --  If yes then come-out and generate report saying currenly running/newly launched
        --  batches equals or exceeds the input parameter

       EXIT WHEN (curr_count_batches >= l_num_of_batches AND l_no_running_request = 'Y' )
            OR (l_count_running = 0 AND l_count_rerrored >= PJI_PJP_SUM_MAIN.g_parallel_processes);
            /* Added above condition for bug 8416116 */

       -- Re-open the cursor and re-initialze the l_prg_batch_t record set
       -- This is done to re-order the rows and get the PENDING and ERRORED
       -- on top of the array.

       l_Prg_Batch_t.delete;
       OPEN prg_group;
       FETCH prg_group BULK COLLECT
                 INTO l_Prg_Batch_t;

       CLOSE prg_group;

       ---  This for loop will launch the concurrent program for the batches
       ---  that are PENDING or ERRORED earlier.
       ---

   if ( ( curr_count_batches < l_num_of_batches )
                 AND ( l_count_running < l_num_parallel_runs )
                 AND ((l_count_running+l_count_rerrored) < PJI_PJP_SUM_MAIN.g_parallel_processes)) THEN
                 /* Added above condition for bug 8416116 */

       FOR i IN l_Prg_Batch_t.first..l_Prg_Batch_t.last LOOP

           IF  ( ( curr_count_batches < l_num_of_batches )
                 AND ( l_Prg_Batch_t(i).curr_request_status  in ( 'PENDING','ERRORED' ))
                 AND ( l_count_running < l_num_parallel_runs )
                 AND ((l_count_running+l_count_rerrored) < PJI_PJP_SUM_MAIN.g_parallel_processes)) THEN
                 /* Added above condition for bug 8416116 */

             l_request_id := -1;

             DBMS_LOCK.SLEEP(60); --Bug 7235411 Added sleep to delay conc. request process to avoid deadlock.

             l_request_id := FND_REQUEST.SUBMIT_REQUEST
                 (
                 application => PJI_UTILS.GET_PJI_SCHEMA_NAME ,	-- Application Name
                 program     => g_incr_disp_name,	-- Program Name
                 sub_request => FALSE,		-- Sub Request
                 argument1 => 'I',			-- p_run_mode
                 argument2 => P_OPERATING_UNIT,  -- p_operating_unit  /* added for bug 9059519 */
                 argument3 => NULL,  -- p_project_organization_id
                 argument4 => NULL,   -- p_project_type
                 argument5 => l_Prg_Batch_t(i).batch_name , -- p_from_project_num
                 argument6 => l_Prg_Batch_t(i).batch_name ,	-- p_to_project_num
                 argument7 => NULL ,           -- p_plan_type_id
    	         argument8 => NULL,     -- p_rbs_header_id
                 argument9 => NULL,     -- p_transaction_type
                 argument10 =>NULL,     -- p_plan_version
                 argument11 => p_project_status -- new parameter Project Status
                 );

              IF ( l_request_id > 0 )  THEN

                UPDATE
                  pji_prg_batch
                SET
                  curr_request_id = l_request_id ,
                  curr_request_status = 'RUNNING'
                WHERE
                  batch_name = l_Prg_Batch_t(i).batch_name ;

                 INSERT INTO pji_prg_batch_log
                 ( run_date_key, run_date , request_id, batch_name , wbs_total, prg_total,
                   delta_total, total_count, project_count, custom1, custom2, custom3
                 )
                 values
                 ( to_char(sysdate,'DD-Mon-YYYY HH24:MI:SS'), sysdate , l_request_id,
                   l_Prg_Batch_t(i).batch_name , l_Prg_Batch_t(i).wbs_total,
                   l_Prg_Batch_t(i).prg_total,   l_Prg_Batch_t(i).delta_total,
                   l_Prg_Batch_t(i).total_count, l_Prg_Batch_t(i).project_count,
                   l_Prg_Batch_t(i).custom1,     l_Prg_Batch_t(i).custom2,
                   l_Prg_Batch_t(i).custom3
                 );

                curr_count_batches := curr_count_batches + 1;
                l_count_running := l_count_running + 1;

              ELSE

                UPDATE
                  pji_prg_batch
                SET
                  curr_request_id = l_request_id ,
                  message =  'Error calling FND_REQUEST.SUBMIT_REQUEST',
                  curr_request_status = 'SUBMIT-ERRORED'
                WHERE
                  batch_name = l_Prg_Batch_t(i).batch_name ;

              END IF ;

             commit;  -- commit the status after each  update. This will allow
                      -- to check the status from outside.

         g_stat_count := g_stat_count+1; /* Added for bug 8416116 */

           END IF;

       END LOOP;  -- end of for loop for the batches

      END IF;

/* Code added for bug 8416116 starts */
	if (mod(g_stat_count,10) = 0) then

	    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
					 tabname => 'PJI_FP_XBS_ACCUM_F',
					 percent => 5,
					 degree  => PJI_UTILS.GET_DEGREE_OF_PARALLELISM());

	end if;
/* Code added for bug 8416116 ends */

       -- After the loop the following two  scenarios exists :
       ---  (1) All the batches are either running or completed
       ---  (2) Some batches might be pending or errored but the
       ---      EITHER the total batches submitted reached the
       ---      input parameter l_num_of_batches OR the total
       ---      number of process running parallely has reached
       ---      the input parameter l_num_parallel_runs


       -- Check if any batches that are left pending or errored
       -- if not then it means either all the batches are  in completed or running status or
       -- has issue submittiing now ( submit-errored ) .
       -- then come out of the loop and complete the process

    IF ( curr_count_batches < l_num_of_batches )  THEN

       SELECT count(*) into l_test
       FROM pji_prg_batch
       WHERE nvl(curr_request_status,'PENDING') not in ( 'COMPLETED' ,'SUBMIT-ERRORED' ,'R-ERRORED') ;

       IF ( l_test = 0 ) THEN

          -- this means there are no batches that are left pending or errored and
          --  which means we can set the curr_count_batches to its l_num_of_batches
          -- and meet one of the exit criteria
          -- But you have to be in the loop for any batch that is in running state
          -- so that we can update the status and then exit

          curr_count_batches := l_num_of_batches;

       END IF;

     END IF;

       -- l_test > 0 means there are still batches that are either PENDING OR ERRORED
       -- and these batches need to be submiited for processing

       -- Now check if the total number of batches that are running are more than the
       -- the input parameter , if YES then one exit criteria of the loop can is met
       -- and we need to check the second criteria that is if there are any still running

       IF ( curr_count_batches >= l_num_of_batches ) THEN

          -- now check if there are any process that are running
          -- if yes then we have continue in the loop and

         SELECT count(*) into l_test
         FROM pji_prg_batch
         WHERE nvl(curr_request_status,'PENDING') in ( 'RUNNING') ;

         IF ( l_test = 0 ) THEN
            l_no_running_request := 'Y';
         END IF;

       END IF;

       -- If l_test > 0 in the above if statement then it means that there are still
       --   some batches that  in running state
       -- then continue the loop, else here both the exit criteria are met.
       -- the loop should exit after updating the status

     IF ( l_no_running_request = 'N' ) THEN
          DBMS_LOCK.SLEEP(l_time_in_seconds);
     END IF;

       -- After Sleeping for the above set time , now re-update the status of the
       -- current running processes.

       -- the p_first_time_flag has to N here as we need not update the pending status
       -- we should not change the count of the batches

       UPDATE_BATCH_CONC_STATUS
       (
           'N'   ,
           l_count_batches     ,
           l_count_running     ,
           l_count_errored     ,
           l_count_completed   ,
           l_count_pending
       );

/* Code added for bug 8416116 starts */
      begin
      select count(*) into
      l_count_rerrored  /* Modified for bug 9387564 */
      from pji_prg_batch
      where curr_request_status = 'R-ERRORED';

      exception
      when others then
      l_count_rerrored  := 0;
      end;
/* Code added for bug 8416116 ends */

  END LOOP;

-- call the upodate_batch_conc_status at the end
-- this is to convert the R-ERRORED into ERRORED

       UPDATE_BATCH_CONC_STATUS
       (
           'Y'   ,
           l_count_batches     ,
           l_count_running     ,
           l_count_errored     ,
           l_count_completed   ,
           l_count_pending
       );

exception when others then

    rollback;
    retcode := 2;
    errbuf := sqlerrm;
    raise;

END LAUNCH_UPP_PROCESS;

PROCEDURE CREATE_UPP_BATCHES
(
    p_wbs_temp_table_size           in   number ,
    p_num_of_projects               in   number ,
    p_incremental_mode              in   varchar2,
    P_OPERATING_UNIT                in   number ,
    p_project_status                in   varchar2
)
is
pragma autonomous_transaction;

Cursor c_program_count is
  select prg_group, count(distinct project_id) cnt, 'ALL' prg_type
    from pa_proj_element_versions ver
   where nvl(p_incremental_mode,'N') = 'N'
   and   object_type = 'PA_STRUCTURES'
   and   prg_group is not null
   and exists (  select 'x' from
                  pa_projects_all p1
                  where p1.project_id = ver.project_id
                  and nvl(p1.org_id,-1) = nvl(P_OPERATING_UNIT,nvl(p1.org_id,-1)))
   group by prg_group
   union all
select /*+ ordered index(ver PA_PROJ_ELEMENT_VERSIONS_N5) */
 ver.PRG_GROUP ,  count( distinct ver.project_id ) cnt, 'PRG_CHANGE' prg_type
   from
   PJI_LAUNCH_INCR grp           ,
   PA_PROJ_ELEMENT_VERSIONS ver
    where    nvl(p_incremental_mode,'N') = 'Y' and
    ver.object_type = 'PA_STRUCTURES' and
    grp.incr_type   =  'PRG_BASE' and
    ver.prg_group  = grp.prg_group
   group by ver.prg_group
   union all
   select grp.prg_group ,count( distinct grp.project_id ) cnt, 'PRG_PARENT' prg_type
   from
    PJI_LAUNCH_INCR grp
   where  nvl(p_incremental_mode,'N') = 'Y' and
     grp.incr_type <> 'PRG_BASE' and
     grp.prg_group > 0
     group by grp.prg_group;

cursor c_program(x_prg_group number, x_prg_type varchar2 ) is
select prg_group, prg_level, project_id
  from pa_proj_element_versions
 where x_prg_type <> 'PRG_PARENT'
   and object_type = 'PA_STRUCTURES'
   and prg_group IS NOT NULL
   and prg_group = x_prg_group
 UNION
select /*+ index(pji_xbs_denorm pji_xbs_denorm_n5) */
  prg_group, sup_level, sup_project_id
  from pji_xbs_denorm
 where x_prg_type <> 'PRG_PARENT'
   and struct_type  = 'PRG_BASE'
   and prg_group is not null
   and struct_type is null
   and sub_level = sup_level
   and prg_group = x_prg_group
  UNION
  select prg_group , prg_level , project_id
  from  PJI_LAUNCH_INCR grp
  where grp.prg_group = x_prg_group
  and   x_prg_type = 'PRG_PARENT'
  and   grp.incr_type <> 'PRG_BASE'
  and   grp.prg_group > 0 ;

   l_batch_name    varchar2(30):= 'UPP-BATCH-';
   l_batch_var     number := 1;
   l_batch_size    number := 5000;
   l_cnt           number:=0;
   l_flag          varchar2(1) := 'N';

   l_wbs_prg_size   number := 500000;

   l_wbs_count number := 0;
   l_prg_count number := 0;
   l_delta_count number := 0;

   l_wbs_total number := 0;
   l_prg_total number := 0;
   l_delta_total number := 0;

   l_batch_count number := 0;

   l_count number := 0;


   l_prg_event_exists varchar2(1) := 'N';
   l_prg_event_total number := 0;

/* Added for bug 8416116 */
   l_prj_list  PJI_LAUNCH_EXT.prg_proj_tbl;
   l_curr_lines_cnt number := 0;
   l_budget_lines_cnt number := 0;
   L_context  varchar2(20);
   L_budget_lines_count number := 0;

Begin

  if ( p_incremental_mode = 'Y' )  then
     create_incr_project_list(p_operating_unit);
  end if;

  delete from pji_prg_group;
  delete from pji_prg_batch;

  commit;

   if ( nvl(p_wbs_temp_table_size,0) <= 0 )  then
      l_wbs_prg_size := 200000;
   else
      l_wbs_prg_size := p_wbs_temp_table_size;
   end if;


   if ( nvl(p_num_of_projects,0) <= 0 )  then
      l_batch_size := 5000;
   else
      l_batch_size := p_num_of_projects;
   end if;

  l_flag := 'N';
  For i in c_program_count Loop

    begin

    select 'Y'
    into l_prg_event_exists
    from dual
    where exists
    ( select 'x'
      from PA_PJI_PROJ_EVENTS_LOG log
      where
         log.EVENT_TYPE   =  'PRG_CHANGE' and
         log.EVENT_OBJECT <> -1           and
         i.PRG_GROUP    in (log.EVENT_OBJECT, log.ATTRIBUTE1)
     );

    exception
       when no_data_found then
          l_prg_event_exists := 'N';

    end;

        select count(*)
        into l_wbs_count
        from pa_proj_element_versions A
        where l_prg_event_exists = 'Y' and
        a.parent_structure_version_id in
         ( select  B.element_version_id
           from pa_proj_element_versions B
           where B.prg_group = i.prg_group
           and B.object_type = 'PA_STRUCTURES'
         )
         and A.object_type = 'PA_TASKS';

        select lw_lf.lw_lf_count + pa_struct.pa_struct_count
        into  l_prg_count
        from
          (     select count(*)  lw_lf_count from
          		(
          		 select
          		 distinct
          		 prg_node.prg_group,
          		 PRG_NODE.element_version_id  sub_id,
          		 pvt_parent1.parent_structure_version_id sup_id ,
          		 pvt_parent1.project_id ,
          			pvt_parent1.proj_element_id ,
          			prt_parent.object_id_from1,
          			prt_parent.relationship_type,
          			ver.prg_level
          		 from 	PA_OBJECT_RELATIONSHIPS prt_parent,
          			PA_PROJ_ELEMENT_VERSIONS ver          ,
          			PA_PROJ_ELEMENT_VERSIONS pvt_parent1   ,
          			pa_proj_element_versions PRG_NODE
          		 where 	1=1
          		 and  PRG_NODE.prg_group = i.prg_group
          		 and 	prt_parent.object_id_to1 = PRG_NODE.element_version_id
          		 and PRG_NODE.object_type = 'PA_STRUCTURES'
          		 and 	prt_parent.object_type_from = 'PA_TASKS'
          		 and 	prt_parent.object_type_to = 'PA_STRUCTURES'
          		 and 	(
          			 prt_parent.relationship_type = 'LF'
          			 or
          			 prt_parent.relationship_type = 'LW'
          			)
          		 and 	ver.element_version_id = prt_parent.object_id_from1
          		 and pvt_parent1.element_version_id = prt_parent.object_id_from1
          		 )
        where  l_prg_event_exists = 'Y' ) lw_lf,
    	   (
    	      select count(*) pa_struct_count
    	      from  pa_proj_element_versions  a
    	      where l_prg_event_exists = 'Y'
    	      and a.prg_group = i.prg_group
    	      and a.object_type = 'PA_STRUCTURES'
    	   ) pa_struct   ;

     For j in c_program(i.prg_group,i.prg_type) loop
        Insert into pji_prg_group
            ( batch_name,
              prg_group,
              prg_level,
              project_id,
              parent_program_id
            ) values (
              l_batch_name||l_batch_var,
              i.prg_group,
              j.prg_level,
              j.project_id,
              null);
     End Loop;
         commit;

       l_cnt := l_cnt + i.cnt;

       l_delta_count := trunc((l_wbs_count + l_prg_count ) * .25 );

       l_wbs_total := l_wbs_total + l_wbs_count ;
       l_prg_total := l_prg_total + l_prg_count ;
       l_delta_total := l_delta_total + l_delta_count ;

       l_batch_count := l_batch_count + l_delta_count + l_wbs_count + l_prg_count ;

        if ( l_prg_event_exists = 'Y' ) then
          l_prg_event_total := l_prg_event_total + l_delta_count + l_wbs_count + l_prg_count ;
        end if;

         If ( ( l_cnt >= l_batch_size ) or ( l_batch_count >= l_wbs_prg_size ) ) then

            Insert into pji_prg_batch
            ( batch_name,
              wbs_total,
              prg_total,
              delta_total,
              total_count,
              project_count,
              custom1
            ) values (
              l_batch_name||l_batch_var,
              l_wbs_total,
              l_prg_total,
              l_delta_total,
              l_batch_count,
              l_cnt,
              l_prg_event_total);

            l_cnt := 0;
            l_batch_count := 0;
            l_wbs_total := 0;
            l_prg_total := 0;
            l_delta_total := 0;

            l_batch_var := l_batch_var+1;

            l_prg_event_total := 0;

            commit;

         End if;

  End loop;

  if ( l_cnt > 0 )  then

            Insert into pji_prg_batch
            ( batch_name,
              wbs_total,
              prg_total,
              delta_total,
              total_count,
              project_count
            ) values (
              l_batch_name||l_batch_var,
              l_wbs_total,
              l_prg_total,
              l_delta_total,
              l_batch_count,
              l_cnt);

            l_cnt := 0;

            commit;

  end if ;

            l_batch_count := null;
            l_wbs_total := null;
            l_prg_total := null;
            l_delta_total := null;


  l_cnt := 0;
  l_batch_var := l_batch_var + 1;

/* Call to Launch process client extension PJI_LAUNCH_EXT.PROJ_LIST
   The client extension returns the following parameters :
   p_prg_proj_tbl - plsql tables containing the project_id's to be processed
   p_context - UPGRADE or INCREMENTAL
   p_budget_lines_count - If p_context = UPGRADE, this is the number of budget
                          lines that should be used to divide batches. This
                          value will ONLY be conidered when p_context = UPGRADE.
   The following combination of extension parameters will be considered valid
   and will be used for creating batches :
   1. p_context = UPGRADE, p_budget_lines_count > 0, p_prg_proj_tbl.count > 0
   2. p_context = UPGRADE, p_budget_lines_count > 0, p_prg_proj_tbl.count = 0
   3. p_context = INCREMENTAL/UPGRADE(p_budget_lines_count=0), p_prg_proj_tbl.count > 0
   4. p_context = INCREMENTAL(p_budget_lines_count=0), p_prg_proj_tbl.count = 0
*/

/* Code added for bug 8416116 starts */
  PJI_LAUNCH_EXT.PROJ_LIST(p_prg_proj_tbl => l_prj_list,
                           p_context => l_context,
                           p_budget_lines_count => l_budget_lines_count);


  if (l_prj_list.count > 0 and
      l_context = 'UPGRADE' and
      l_budget_lines_count > 0 ) then

        l_budget_lines_cnt := 0;

        FOR a IN l_prj_list.first..l_prj_list.last LOOP

              l_curr_lines_cnt := 0;
              select count(*)
              into l_curr_lines_cnt
              from pa_budget_versions pbv,
                   pa_budget_lines pbl
              where pbv.project_id = l_prj_list(a) and
                    pbv.budget_version_id = pbl.budget_version_id;

              if (( l_budget_lines_cnt + l_curr_lines_cnt
                    <= l_budget_lines_count) or l_cnt = 0) THEN

                   Insert into pji_prg_group
                      ( batch_name,
                        prg_group,
                        prg_level,
                        project_id,
                        parent_program_id
                      ) values (
                        l_batch_name||l_batch_var,
                        Null,
                        Null,
                        l_prj_list(a),
                        null );

                    l_budget_lines_cnt := l_budget_lines_cnt + l_curr_lines_cnt;
                    l_cnt := l_cnt + 1;

               else
                     Insert into pji_prg_batch
                     ( batch_name,
                       wbs_total,
                       prg_total,
                       delta_total,
                       total_count,
                       project_count
                     ) values (
                       l_batch_name||l_batch_var,
                       l_wbs_total,
                       l_prg_total,
                       l_delta_total,
                       l_batch_count,
                       l_cnt);

                      l_cnt := 0;
                      l_batch_var := l_batch_var + 1;
                      l_budget_lines_cnt := 0;

                       Insert into pji_prg_group
                          ( batch_name,
                            prg_group,
                            prg_level,
                            project_id,
                            parent_program_id
                          ) values (
                            l_batch_name||l_batch_var,
                            Null,
                            Null,
                            l_prj_list(a),
                            null );

                        l_budget_lines_cnt := l_budget_lines_cnt + l_curr_lines_cnt;
                        l_cnt := l_cnt + 1;

              end if; /* if (( l_budget_lines_cnt + l_curr_lines_cnt
                         <= l_budget_lines_count) or l_cnt = 0) */

        end loop;

  elsif (l_prj_list.count = 0 and l_context = 'UPGRADE' and
         l_budget_lines_count > 0 ) then

        l_budget_lines_cnt := 0;

        For k in (select a.project_id
                   from pa_projects_all a
                   where nvl(p_incremental_mode,'N') = 'N'
                   and template_flag = 'N' -- Bug 9059688
                   and nvl(a.org_id,-1) = nvl(p_operating_unit,nvl(a.org_id,-1))
                   --added for 12.1.3 feature for new parameter Project Status
                   --commenting out the below clause as not needed in this scenario
                  /* and nvl(a.project_status_code,'PS') =
                   nvl(p_project_status,nvl(a.project_status_code,'PS'))*/
                   and not exists
                       (select 'x' from pji_prg_group b
                        where a.project_id = b.project_id)
                   union all
                   select project_id
                   from pji_launch_incr a
                   where  nvl(p_incremental_mode,'N') = 'Y'
                   and   incr_type like 'PROJ%'
                   and   prg_group = -1
                   and not exists
                       (select 'x' from pji_prg_group b
                        where a.project_id = b.project_id )) loop

              l_curr_lines_cnt := 0;

              select count(*)
              into l_curr_lines_cnt
              from pa_budget_versions pbv,
                   pa_budget_lines pbl
              where pbv.project_id = k.project_id
              and pbv.budget_version_id = pbl.budget_version_id;

              if (( l_budget_lines_cnt + l_curr_lines_cnt
                    <= l_budget_lines_count) or l_cnt = 0) THEN

                   Insert into pji_prg_group
                      ( batch_name,
                        prg_group,
                        prg_level,
                        project_id,
                        parent_program_id
                      ) values (
                        l_batch_name||l_batch_var,
                        Null,
                        Null,
                        k.project_id,
                        null );

                    l_budget_lines_cnt := l_budget_lines_cnt + l_curr_lines_cnt;
                    l_cnt := l_cnt + 1;

               else
                     Insert into pji_prg_batch
                     ( batch_name,
                       wbs_total,
                       prg_total,
                       delta_total,
                       total_count,
                       project_count
                     ) values (
                       l_batch_name||l_batch_var,
                       l_wbs_total,
                       l_prg_total,
                       l_delta_total,
                       l_batch_count,
                       l_cnt);

                      l_cnt := 0;
                      l_batch_var := l_batch_var + 1;
                      l_budget_lines_cnt := 0;

                       Insert into pji_prg_group
                          ( batch_name,
                            prg_group,
                            prg_level,
                            project_id,
                            parent_program_id
                          ) values (
                            l_batch_name||l_batch_var,
                            Null,
                            Null,
                            k.project_id,
                            null );

                        l_budget_lines_cnt := l_budget_lines_cnt + l_curr_lines_cnt;
                        l_cnt := l_cnt + 1;

              end if; /* if (( l_budget_lines_cnt + l_curr_lines_cnt
                         <= l_budget_lines_count) or l_cnt = 0) */

        end loop;

  elsif (l_prj_list.count > 0 and (l_context = 'INCREMENTAL' or l_context = 'UPGRADE')) then

    FOR a IN l_prj_list.first..l_prj_list.last LOOP

             Insert into pji_prg_group
              ( batch_name,
                prg_group,
                prg_level,
                project_id,
                parent_program_id
              ) values (
                l_batch_name||l_batch_var,
                Null,
                Null,
                l_prj_list(a),
                null );

              l_cnt := l_cnt + 1;

              if l_cnt >= l_batch_size then

                 Insert into pji_prg_batch
                 ( batch_name,
                   wbs_total,
                   prg_total,
                   delta_total,
                   total_count,
                   project_count
                 ) values (
                   l_batch_name||l_batch_var,
                   l_wbs_total,
                   l_prg_total,
                   l_delta_total,
                   l_batch_count,
                   l_cnt);

                   l_cnt := 0;
                   l_batch_var := l_batch_var + 1;

              end if;

    end loop;

  else
/* Code added for bug 8416116 ends */

        For k in (  select a.project_id
                    from pa_projects_all a
                   where nvl(p_incremental_mode,'N') = 'N'
                   and template_flag = 'N' -- Bug 9059688
                   and nvl(a.org_id,-1) = nvl(p_operating_unit,nvl(a.org_id,-1))
                   and
nvl(a.project_status_code,'PS')=nvl(p_project_status,nvl(a.project_status_code,'PS'))
                   and not exists
                       ( select 'x'
                        from pji_prg_group b where a.project_id = b.project_id )
                   union all
                   select a.project_id
                   from pji_launch_incr a, pa_projects_all b /*  added for bug 9712797 */
                   where  nvl(p_incremental_mode,'N') = 'Y'
                   and a. project_id = b.project_id /* added for bug 9712797 */
                   and nvl(b.project_status_code,'PS') =
nvl(p_project_status,nvl(b.project_status_code,'PS')) /* added for bug
9712797 */
                   and   incr_type like 'PROJ%'
                   and   prg_group = -1
                   and not exists
                       ( select 'x'
                        from pji_prg_group b where a.project_id = b.project_id )
                  )
                   loop
                   Insert into pji_prg_group
                    ( batch_name,
                      prg_group,
                      prg_level,
                      project_id,
                      parent_program_id
                    ) values (
                      l_batch_name||l_batch_var,
                      Null,
                      Null,
                      k.project_id,
                      null );

                    l_cnt := l_cnt + 1;

                    if l_cnt >= l_batch_size then

                       Insert into pji_prg_batch
                       ( batch_name,
                         wbs_total,
                         prg_total,
                         delta_total,
                         total_count,
                         project_count
                       ) values (
                         l_batch_name||l_batch_var,
                         l_wbs_total,
                         l_prg_total,
                         l_delta_total,
                         l_batch_count,
                         l_cnt);

                    l_cnt := 0;
                    l_batch_var := l_batch_var + 1;
                    end if;
           End loop;

  end if; /* Added for bug 8416116 */

           if l_cnt >= 0 then

                 Insert into pji_prg_batch
                 ( batch_name,
                   wbs_total,
                   prg_total,
                   delta_total,
                   total_count,
                   project_count
                 ) values (
                   l_batch_name||l_batch_var,
                   l_wbs_total,
                   l_prg_total,
                   l_delta_total,
                   l_batch_count,
                   l_cnt);

              l_cnt := 0;
           end if;

commit;

Exception
  When Others then
    rollback;
    raise;
End CREATE_UPP_BATCHES;

PROCEDURE CREATE_INCR_PROJECT_LIST (p_operating_unit in number) IS

l_prg_parent number;
l_prg_count number;

BEGIN

-- NOTES :
---  This procedure created rows into the table pji_launch_incr
---  Following type of rows are created
--   INCR_TYPE :
---           PRG_BASE :-> These are PRG_CHANGE events
--            PROJ_BASE :-> These are proejcts that has incremental data
--            PROJ_PRG    :-> These are the updated rows of PROJ_BASE to
--                         PROJ_PRG , which belongs to program and the
--                         corresponding program is part of the
--                         PRG_BASE rows.
--            PROJ_B_PARENT :-> These are the updated rows of PROJ_BASE to
--                         PROJ_PRG , which belongs to program and the
--                         corresponding program is not part of the
--                         PRG_BASE rows.
--            PROJ_PARENT :-> These are the rows that parents of the rows
--                            of type PROJ_PRG.
--
--
  DELETE FROM PJI_LAUNCH_INCR;
--
--
  COMMIT;

--
-- INSERT 001
--
  INSERT INTO PJI_LAUNCH_INCR
  (incr_type, prg_group , project_id, prg_level )
  SELECT /*+ ordered use_nl(log ver ) index(ver PA_PROJ_ELEMENT_VERSIONS_N5) */
   DISTINCT
   'PRG_BASE' incr_type ,
   ver.PRG_GROUP ,
   - 1 project_id ,
   -1  prg_level
     FROM
     PA_PJI_PROJ_EVENTS_LOG LOG ,
     PA_PROJ_ELEMENT_VERSIONS ver
      WHERE
   ver.object_type = 'PA_STRUCTURES' AND
   log.EVENT_TYPE = 'PRG_CHANGE' AND
   log.EVENT_OBJECT <>  - 1 AND
   ver.PRG_GROUP IN (log.EVENT_OBJECT, log.ATTRIBUTE1)
   and exists (  select 'x' from
                  pa_projects_all p1
                  where p1.project_id = ver.project_id
                  and nvl(p1.org_id,-1) = nvl(p_operating_unit,nvl(p1.org_id,-1)));

--
--
-- INSERT 002
--
--
  INSERT INTO PJI_LAUNCH_INCR
  (incr_type, prg_group , project_id , prg_level)
  SELECT
   DISTINCT
   'PROJ_BASE',
   - 1,
    to_number(log.attribute1),
   - 1
     FROM
     PA_PJI_PROJ_EVENTS_LOG LOG
      WHERE
   log.EVENT_TYPE = 'PRG_CHANGE' AND
   log.EVENT_OBJECT =  - 1
   AND NOT EXISTS
   (SELECT 'x' FROM
       PJI_LAUNCH_INCR grp2
       WHERE grp2.incr_type = 'PROJ_BASE'
       AND grp2.prg_group =  - 1
       AND grp2.project_id = to_number(log.attribute1) )
       and exists (  select 'x' from
                  pa_projects_all p1
                  where p1.project_id = to_number(log.attribute1)
                  and nvl(p1.org_id,-1) = nvl(p_operating_unit,nvl(p1.org_id,-1)));

--
-- INSERT 003
--
--
  INSERT INTO PJI_LAUNCH_INCR
  (incr_type, prg_group , project_id, prg_level )
  SELECT
   DISTINCT
   'PROJ_BASE',
   - 1,
    to_number(log.attribute1),
    -1
     FROM
     PA_PJI_PROJ_EVENTS_LOG LOG
      WHERE
   log.EVENT_TYPE IN ('RBS_ASSOC', 'RBS_PRG' )
   AND NOT EXISTS
   (SELECT 'x' FROM
       PJI_LAUNCH_INCR grp2
       WHERE grp2.incr_type = 'PROJ_BASE'
       AND grp2.prg_group =  - 1
       AND grp2.project_id = to_number(log.attribute1) )
       and exists (  select 'x' from
                  pa_projects_all p1
                  where p1.project_id = to_number(log.attribute1)
                  and nvl(p1.org_id,-1) = nvl(p_operating_unit,nvl(p1.org_id,-1)));

--
-- INSERT 003
--
--
  INSERT INTO PJI_LAUNCH_INCR
  (incr_type, prg_group , project_id , prg_level)
  SELECT
   DISTINCT
   'PROJ_BASE',
   - 1,
    asg.project_id,
   -1
  FROM
      PA_PJI_PROJ_EVENTS_LOG LOG,
     PA_RBS_PRJ_ASSIGNMENTS asg
   WHERE
   log.EVENT_TYPE = 'RBS_PUSH' AND
   asg.RBS_VERSION_ID IN (log.EVENT_OBJECT, log.ATTRIBUTE2)
   AND NOT EXISTS
   (SELECT 'x' FROM
       PJI_LAUNCH_INCR grp2
       WHERE grp2.incr_type = 'PROJ_BASE'
       AND grp2.prg_group =  - 1
       AND grp2.project_id = asg.project_id )
       and exists (  select 'x' from
                  pa_projects_all p1
                  where p1.project_id = asg.project_id
                  and nvl(p1.org_id,-1) = nvl(p_operating_unit,nvl(p1.org_id,-1)));

--
-- INSERT 004
--
--
  INSERT INTO PJI_LAUNCH_INCR
  (incr_type, prg_group , project_id , prg_level)
  SELECT
   DISTINCT
   'PROJ_BASE',
   - 1,
    asg.project_id,
   - 1
  FROM
      PA_PJI_PROJ_EVENTS_LOG LOG,
     PA_RBS_PRJ_ASSIGNMENTS asg
   WHERE
   log.EVENT_TYPE = 'RBS_DELETE' AND
   asg.RBS_VERSION_ID = log.EVENT_OBJECT
   AND NOT EXISTS
   (SELECT 'x' FROM
       PJI_LAUNCH_INCR grp2
       WHERE grp2.incr_type = 'PROJ_BASE'
       AND grp2.prg_group =  - 1
       AND grp2.project_id = asg.project_id )
       and exists (  select 'x' from
                  pa_projects_all p1
                  where p1.project_id = asg.project_id
                  and nvl(p1.org_id,-1) = nvl(p_operating_unit,nvl(p1.org_id,-1))) ;

-- INSERT 005
--
--
/* Not required. based on the reply from Kranthi

insert into PJI_LAUNCH_INCR
( incr_type, prg_group , project_id )
select
 distinct
 'PROJ_BASE',
 -1    ,
 project_id
from
pji_fm_extr_plan_lines a1
 where not exists
 (  select 'x' from
     PJI_LAUNCH_INCR grp2
     where grp2.incr_type = 'PROJ_BASE'
     and grp2.prg_group = -1
     and grp2.project_id = a1.project_id );

*/
--
--
-- INSERT 006
--
--
  INSERT INTO PJI_LAUNCH_INCR
  (incr_type, prg_group , project_id , prg_level)
  SELECT
   DISTINCT
   'PROJ_BASE',
   - 1,
   project_id,
   - 1
   FROM PJI_FM_AGGR_FIN7 a1
  WHERE NOT EXISTS
   (SELECT 'x' FROM
       PJI_LAUNCH_INCR grp2
       WHERE grp2.incr_type = 'PROJ_BASE'
       AND grp2.prg_group =  - 1
       AND grp2.project_id = a1.project_id )
       and exists (  select 'x' from
                  pa_projects_all p1
                  where p1.project_id = a1.project_id
                  and nvl(p1.org_id,-1) = nvl(p_operating_unit,nvl(p1.org_id,-1)));

-- INSERT 007
--
  INSERT INTO PJI_LAUNCH_INCR
  (incr_type, prg_group , project_id , prg_level )
  SELECT
   DISTINCT
   'PROJ_BASE',
   - 1,
   project_id ,
   - 1
  FROM PJI_FM_AGGR_ACT4 a1
  WHERE NOT EXISTS
   (SELECT 'x' FROM
       PJI_LAUNCH_INCR grp2
       WHERE grp2.incr_type = 'PROJ_BASE'
       AND grp2.prg_group =  - 1
       AND grp2.project_id = a1.project_id )
         and exists (  select 'x' from
                  pa_projects_all p1
                  where p1.project_id = a1.project_id
                  and nvl(p1.org_id,-1) = nvl(p_operating_unit,nvl(p1.org_id,-1)));

  INSERT INTO PJI_LAUNCH_INCR
  (incr_type, prg_group , project_id , prg_level )
  SELECT
   DISTINCT
   'PROJ_BASE',
   - 1,
   project_id,
   - 1
  FROM PA_BUDGET_VERSIONS a1
  WHERE budget_status_code = 'B' AND
        pji_summarized_flag = 'P' AND
  NOT EXISTS
   (SELECT 'x' FROM
       PJI_LAUNCH_INCR grp2
       WHERE grp2.incr_type = 'PROJ_BASE'
       AND grp2.prg_group =  - 1
       AND grp2.project_id = a1.project_id )
       and exists (  select 'x' from
                  pa_projects_all p1
                  where p1.project_id = a1.project_id
                  and nvl(p1.org_id,-1) = nvl(p_operating_unit,nvl(p1.org_id,-1)));

--
/*
-- pji_fm_aggr_fin8 table is not required , based on the reply from shane.

insert into PJI_LAUNCH_INCR
( incr_type, prg_group , project_id )
select
 distinct
 'PROJ_BASE',
 -1    ,
 project_id
from  pji_fm_aggr_fin8 a1
where
not exists
 (  select 'x' from
     PJI_LAUNCH_INCR grp2
     where grp2.incr_type = 'PROJ_BASE'
     and grp2.prg_group = -1
     and grp2.project_id = a1.project_id );
*/
--
---
  COMMIT;

/** New Changes July-9th  START */
--
--
--
  BEGIN

    UPDATE PJI_LAUNCH_INCR a
    SET a.INCR_TYPE = 'PROJ_PRG'
    WHERE a.INCR_TYPE = 'PROJ_BASE'
    AND EXISTS
    (SELECT /*+ ordered index(c PA_PROJ_ELEMENT_VERSIONS_N6) */ 'x'
      FROM
           pa_proj_element_versions c,
           PJI_LAUNCH_INCR b
      WHERE a.project_id = c.project_id
      and c.object_type = 'PA_STRUCTURES'
      AND c.prg_group IS NOT NULL
      AND c.prg_group = b.prg_group
      AND b.incr_type = 'PRG_BASE'
    );

    COMMIT;

  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END ;

-- Update the rows to working rows, since the corresponding parent need to be fetched.
--

    UPDATE PJI_LAUNCH_INCR a
    SET a.INCR_TYPE = 'PROJ_WRK'
    WHERE a.INCR_TYPE = 'PROJ_BASE' and
    exists
    ( select 'x'
      from pa_proj_element_versions c
      where a.project_id = c.project_id
      and c.object_type = 'PA_STRUCTURES'
      AND c.prg_group IS NOT NULL ) ;

    commit;

  l_prg_count := 0;
  LOOP

  l_prg_parent := 0;

  FOR PRG_PARENT_NODE IN
    (
     SELECT /*+ ordered index(a PA_PROJ_ELEMENT_VERSIONS_N6) index(b PA_OBJECT_RELATIONSHIPS_N4) */
     DISTINCT
     a0.project_id child_proj_id , a.prg_level child_prg_level,
     c.project_id parent_proj_id , c.prg_group , c.prg_level parent_prg_level
     FROM pji_launch_incr a0,
          pa_proj_element_versions a,
          pa_object_relationships b,
          pa_proj_element_versions c
     WHERE a0.incr_type in ( 'PROJ_WRK', 'PROJ_WRK_NEW' )
     AND a.project_id = a0.project_id --51956 --5062 --5269 --51954
     AND a.prg_group IS NOT NULL
     AND a.object_type = 'PA_STRUCTURES'
     AND a.object_type = b.object_type_to
     AND a.element_version_id = b.object_id_to1
     AND c.element_version_id = b.object_id_from1
     AND b.relationship_type IN ('LW', 'LF')
     ) LOOP

     l_prg_parent := 1;

     UPDATE PJI_LAUNCH_INCR
     SET prg_group = PRG_PARENT_NODE.prg_group,
         incr_type = decode(incr_type,'PROJ_WRK','PROJ_B_PARENT','PROJ_PARENT'),
         prg_level = PRG_PARENT_NODE.child_prg_level
     WHERE project_id =  PRG_PARENT_NODE.child_proj_id
     AND  incr_type in ( 'PROJ_WRK', 'PROJ_WRK_NEW' );

     INSERT INTO PJI_LAUNCH_INCR a
      (a.incr_type, a.prg_group , a.project_id , a.prg_level)
      select
      'PROJ_WRK_NEW',
              PRG_PARENT_NODE.prg_group,
              PRG_PARENT_NODE.parent_proj_id ,
              PRG_PARENT_NODE.parent_prg_level
      from dual
      where not exists
      (
          select 'x'
          from PJI_LAUNCH_INCR b
          where  PRG_PARENT_NODE.parent_proj_id = b.project_id
          and    PRG_PARENT_NODE.prg_group = b.prg_group
          and   PRG_PARENT_NODE.parent_prg_level = b.prg_level
          and   b.incr_type in ('PROJ_PARENT','PROJ_B_PARENT','PROJ_WRK_NEW')
      );

     commit;

  END LOOP;

  exit when l_prg_parent = 0;

  l_prg_count := l_prg_count+1;

  END LOOP;

  UPDATE PJI_LAUNCH_INCR
  SET   incr_type = decode(incr_type,'PROJ_WRK','PROJ_BASE','PROJ_PARENT')
  WHERE incr_type in ( 'PROJ_WRK', 'PROJ_WRK_NEW' );


 commit;

--
-- INSERT 008
--
--
--
  INSERT INTO PJI_LAUNCH_INCR
  (incr_type, prg_group , project_id ,prg_level)
  SELECT /*+ ordered index(ver PA_PROJ_ELEMENT_VERSIONS_N6) */
     DISTINCT
     'PROJ_BASE_MAP' incr_type ,
     nvl(ver.PRG_GROUP,-1) ,
     map1.project_id project_id ,
     nvl(ver.prg_level,-1)
   FROM
     PJI_PJP_PROJ_BATCH_MAP map1 ,
     PA_PROJ_ELEMENT_VERSIONS ver
   WHERE
   ver.object_type = 'PA_STRUCTURES' AND
   ver.project_id = map1.project_id ;
--AND
--   NOT EXISTS (
--       SELECT 'x' FROM PJI_LAUNCH_INCR grp2
--       WHERE grp2.prg_group = nvl(ver.prg_group,-1) AND grp2.incr_type = 'PRG_BASE' AND grp2.project_id =  - 1) and
--   NOT EXISTS (
--       SELECT 'x' FROM PJI_LAUNCH_INCR grp3
--       WHERE grp3.project_id =  map1.project_id AND grp3.incr_type like 'PROJ%' ) ;
--
--
--

   UPDATE PJI_LAUNCH_INCR a
   set a.prg_group = -2
   where incr_type = 'PROJ_BASE_MAP'
   and exists
   (
       SELECT 'x' FROM PJI_LAUNCH_INCR grp2
       WHERE grp2.prg_group = nvl(a.prg_group,-1) AND grp2.incr_type = 'PRG_BASE' AND grp2.project_id =  - 1) ;

/** New Changes July-9th END */

  --test_logmessage('LAUNCH', 300,'Before Final Insert CREATE_INCR_PROJECT_LIST');
--
-- commented , since this is not required.
--  as the strategy is to pickup only those parent projects for all those projects which has
-- incremental runs and the program to which these projects belongs does not have PRG_CHANGE
-- event.
--
--
-- INSERT 009
--
--  INSERT INTO PJI_LAUNCH_INCR
--  (incr_type, prg_group , project_id )
--  SELECT /*+ ordered index(ver PA_PROJ_ELEMENT_VERSIONS_N3) */
--   DISTINCT
--   'PRG_BASE' incr_type ,
--   ver.PRG_GROUP ,
--   - 1 project_id
--     FROM
--     PJI_LAUNCH_INCR grp ,
--     PA_PROJ_ELEMENT_VERSIONS ver
--      WHERE
--   ver.object_type = 'PA_STRUCTURES' AND
--   grp.incr_type = 'PROJ_BASE' AND
--   grp.prg_group =  - 1 AND
--   ver.project_id = grp.project_id AND
--   ver.prg_group IS NOT NULL AND
--   NOT EXISTS (
--       SELECT 'x' FROM PJI_LAUNCH_INCR grp2
--       WHERE grp2.prg_group = ver.prg_group AND grp2.incr_type = 'PRG_BASE' AND grp2.project_id =  - 1) ;
----
----
----
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END CREATE_INCR_PROJECT_LIST;


end PJI_LAUNCH_UPP_MAIN;

/
