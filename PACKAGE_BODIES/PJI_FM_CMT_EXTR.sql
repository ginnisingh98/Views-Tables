--------------------------------------------------------
--  DDL for Package Body PJI_FM_CMT_EXTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_CMT_EXTR" as
  /* $Header: PJISF14B.pls 120.5.12010000.3 2008/11/28 05:53:57 paljain ship $ */

PROCEDURE accum_projperf_commitments
	( x_project_id	IN  NUMBER,
	x_err_stage	 IN OUT NOCOPY  VARCHAR2,
	x_err_code	 IN OUT NOCOPY  NUMBER)
IS

	CURSOR selcmts IS
	SELECT
	pct.rowid,
	pct.cmt_line_id,
	pct.project_id,
	pct.task_id,
	pa_utils.GetWeekEnding(pct.expenditure_item_date) week_ending_date,
	LAST_DAY(pct.expenditure_item_date) month_ending_date,
	pct.pa_period,
	pct.gl_period,
	pct.organization_id,
	pct.vendor_id,
	pct.expenditure_type,
	pct.expenditure_category,
	pct.revenue_category,
	pct.system_linkage_function,
	pct.cmt_ind_compiled_set_id,
	pct.expenditure_item_date,
	pct.denom_currency_code,
	pct.denom_raw_cost,
	pct.denom_burdened_cost,
	pct.acct_currency_code,
	pct.acct_rate_date,
	pct.acct_rate_type,
	pct.acct_exchange_rate,
	pct.acct_raw_cost,
	pct.acct_burdened_cost,
	pct.receipt_currency_code,
	pct.receipt_currency_amount,
	pct.receipt_exchange_rate
	FROM
	pa_commitment_txns pct
	WHERE
	pct.project_id = x_project_id ;


	CURSOR	l_project_curr_code_csr
	(l_project_id pa_projects_all.project_id%TYPE)
	IS
	SELECT 	project_currency_code,projfunc_currency_code
	FROM	pa_projects_all p
	WHERE	p.project_id = l_project_id;


	l_proj_curr_OK              VARCHAR2(1) := 'Y';
	l_project_curr_code	      pa_projects_all.project_currency_code%TYPE   := NULL;


	cmtrec			selcmts%ROWTYPE;
	row_processed		NUMBER;
	l_cmtrec_curr_OK	VARCHAR2(1);
	l_cmt_rejection_code	pa_commitment_txns.cmt_rejection_code%TYPE;
	l_err_msg		VARCHAR2(2000);

	l_Project_Rate_Type	pa_commitment_txns.project_rate_type%TYPE;
	l_Project_Rate_Date	DATE;
	l_project_exch_rate	NUMBER;
	l_PROJECT_RAW_COST      NUMBER := NULL;
	l_PROJECT_BURDENED_COST	NUMBER := NULL;  -- added for FP.M

	l_amount_out		NUMBER;
	l_tot_cmt_raw_cost	NUMBER;
	l_tot_cmt_burdened_cost	NUMBER;
	l_status		VARCHAR2(200) := NULL;
	l_stage			NUMBER  := NULL;

	l_SYSTEM_LINKAGE            pa_expenditure_items_all.SYSTEM_LINKAGE_FUNCTION%TYPE :=NULL;


	l_PROJFUNC_CURR_CODE        pa_projects_all.project_currency_code%TYPE     := NULL;
	l_PROJFUNC_COST_RATE_TYPE   pa_commitment_txns.project_rate_type%TYPE  := NULL;
	l_PROJFUNC_COST_RATE_DATE   DATE  := NULL;
	l_PROJFUNC_COST_EXCH_RATE   NUMBER :=  NULL;

BEGIN
	pji_utils.write2log('Enering accum_projperf_commitments');
	x_err_code        :=0;
	x_err_stage       := 'Accumulating Commitments';

	row_processed     :=0;

	OPEN l_project_curr_code_csr(x_project_id);
	FETCH l_project_curr_code_csr INTO l_project_curr_code,l_projfunc_curr_code;
	CLOSE l_project_curr_code_csr;

	FOR cmtrec IN selcmts LOOP

		row_processed := row_processed + 1;

		l_cmtrec_curr_OK        := 'Y';
		l_project_Rate_Type     := NULL;
		l_project_Rate_Date     := cmtrec.expenditure_item_date;
		l_project_exch_rate     := NULL;
		l_project_raw_cost      := NULL;
		l_project_burdened_cost := NULL;

		l_amount_out            := NULL;
		l_tot_cmt_raw_cost      := NULL;
		l_tot_cmt_burdened_cost := NULL;
		l_status                := NULL;
		l_stage                 := NULL;
		l_cmt_rejection_code    := NULL;
		l_err_msg               := NULL;

		IF (l_cmtrec_curr_OK = 'Y')
		THEN

		pa_multi_currency_txn.get_currency_amounts
		(p_project_curr_code            => l_project_curr_code
		, p_ei_date                    => cmtrec.expenditure_item_date
		, p_task_id 		        => cmtrec.task_id
		, p_denom_raw_cost	        => cmtrec.denom_raw_cost
		, p_denom_curr_code            => cmtrec.denom_currency_code
		, p_acct_curr_code	        => cmtrec.acct_currency_code
		, p_accounted_flag              => 'Y'
		, p_acct_rate_date             => cmtrec.acct_rate_date
		, p_acct_rate_type             => cmtrec.acct_rate_type
		, p_acct_exch_rate             => cmtrec.acct_exchange_rate
		, p_acct_raw_cost              => cmtrec.acct_raw_cost
		, p_project_rate_type          => l_project_rate_type
		, p_project_rate_date          => l_project_rate_date
		, p_project_exch_rate          => l_project_exch_rate
		, P_PROJFUNC_RAW_COST          => l_amount_out
		, p_status                     => l_status
		, p_stage                      => l_stage
		, P_SYSTEM_LINKAGE             => l_SYSTEM_LINKAGE
		, P_PROJECT_RAW_COST           => l_PROJECT_RAW_COST
		, P_PROJFUNC_CURR_CODE         => l_PROJFUNC_CURR_CODE
		, P_PROJFUNC_COST_RATE_TYPE    => l_PROJFUNC_COST_RATE_TYPE
		, P_PROJFUNC_COST_RATE_DATE    => l_PROJFUNC_COST_RATE_DATE
		, P_PROJFUNC_COST_EXCH_RATE    => l_PROJFUNC_COST_EXCH_RATE
		);


		l_tot_cmt_raw_cost := l_amount_out;

		IF (l_status IS NOT NULL) THEN
			l_cmt_rejection_code    := l_status;
			l_cmtrec_curr_OK        := 'N';
		END IF;

		IF (l_cmtrec_curr_OK = 'Y') THEN

		IF  cmtrec.denom_raw_cost <> cmtrec.denom_burdened_cost THEN
		pa_multi_currency_txn.get_currency_amounts
		(p_project_curr_code            => l_project_curr_code
		, p_ei_date                    => cmtrec.expenditure_item_date
		, p_task_id 		        => cmtrec.task_id
		, p_denom_raw_cost	        => cmtrec.denom_burdened_cost
		, p_denom_curr_code            => cmtrec.denom_currency_code
		, p_acct_curr_code	        => cmtrec.acct_currency_code
		, p_accounted_flag             => 'Y'
		, p_acct_rate_date             => cmtrec.acct_rate_date
		, p_acct_rate_type             => cmtrec.acct_rate_type
		, p_acct_exch_rate             => cmtrec.acct_exchange_rate
		, p_acct_raw_cost              => cmtrec.acct_burdened_cost
		, p_project_rate_type          => l_project_rate_type
		, p_project_rate_date          => l_project_rate_date
		, p_project_exch_rate          => l_project_exch_rate
		, P_PROJFUNC_RAW_COST          => l_amount_out
		, p_status                     => l_status
		, p_stage                      => l_stage
		, P_SYSTEM_LINKAGE             => l_SYSTEM_LINKAGE
		, P_PROJECT_RAW_COST           => l_PROJECT_BURDENED_COST /*Bug#4137193*/
		, P_PROJFUNC_CURR_CODE         => l_PROJFUNC_CURR_CODE
		, P_PROJFUNC_COST_RATE_TYPE    => l_PROJFUNC_COST_RATE_TYPE
		, P_PROJFUNC_COST_RATE_DATE    => l_PROJFUNC_COST_RATE_DATE
		, P_PROJFUNC_COST_EXCH_RATE    => l_PROJFUNC_COST_EXCH_RATE
		);
		END IF;

		l_tot_cmt_burdened_cost := l_amount_out;

                /* placed the below statement within IF condition
		 for the bug 4137193 */

		IF l_PROJECT_BURDENED_COST IS null THEN
		  l_PROJECT_BURDENED_COST := l_PROJECT_RAW_COST;
                END IF;

		IF (l_status IS NOT NULL)  THEN
			l_cmt_rejection_code    := l_status;
			l_cmtrec_curr_OK        := 'N';
		END IF;

		END IF; --BURDENED COST

		END IF; -- DERIVATION SUBsection

		IF (l_cmtrec_curr_OK = 'Y') THEN
			UPDATE pa_commitment_txns
			SET tot_cmt_raw_cost     = l_tot_cmt_raw_cost
			, tot_cmt_burdened_cost  = l_tot_cmt_burdened_cost
			, project_currency_code  = l_project_curr_code
			, project_rate_date      = l_project_rate_date
			, project_rate_type      = l_project_rate_type
			, project_exchange_rate  = l_project_exch_rate
			, proj_raw_cost       = l_PROJECT_RAW_COST
			, proj_burdened_cost  = l_PROJECT_BURDENED_COST
			WHERE rowid = cmtrec.rowid;
		ELSE
			UPDATE pa_commitment_txns
			SET generation_error_flag = 'Y'
			, cmt_rejection_code = l_cmt_rejection_code
			WHERE rowid = cmtrec.rowid;

			l_proj_curr_OK := 'N';
		END IF; -- UPDATE COMMITMENT ROW

	END LOOP; -- CMTREC Processing

	pji_utils.write2log('Leaving accum_projperf_commitments');
EXCEPTION
WHEN OTHERS THEN
x_err_code := SQLCODE;
pji_utils.write2log('within exception block of accum_projperf_commitments');
RAISE;

END accum_projperf_commitments;


  -- -----------------------------------------------------
  -- procedure REFRESH_PROJPERF_CMT_PRE
  -- -----------------------------------------------------
  procedure REFRESH_PROJPERF_CMT_PRE (p_worker_id in number) is

    l_extract_commitments varchar2(30);
    l_process             varchar2(30);

    l_operating_unit      number       := null;
    l_from_project        varchar2(50) := null;
    l_to_project          varchar2(50) := null;
    l_batch_size          number       := 1;

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
                'PJI_FM_CMT_EXTR.REFRESH_PROJPERF_CMT_PRE(p_worker_id);')) then
      return;
    end if;

    l_extract_commitments := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                             (PJI_FM_SUM_MAIN.g_process,
                              'EXTRACT_COMMITMENTS');

    if (l_extract_commitments = 'N') then
      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
        'PJI_FM_CMT_EXTR.REFRESH_PROJPERF_CMT_PRE(p_worker_id);');
      commit;
      return;
    end if;

    l_operating_unit := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                        (PJI_FM_SUM_MAIN.g_process, 'PROJECT_OPERATING_UNIT');

    l_from_project := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                      (PJI_FM_SUM_MAIN.g_process, 'FROM_PROJECT');

    l_to_project := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                    (PJI_FM_SUM_MAIN.g_process, 'TO_PROJECT');

    if (l_from_project is null) then

      begin

        select
          prj.SEGMENT1
        into
          l_from_project
        from
          PA_PROJECTS_ALL prj
        where
          prj.PROJECT_ID = PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                           (PJI_FM_SUM_MAIN.g_process, 'FROM_PROJECT_ID');

        exception when no_data_found then null;

      end;

    end if;

    if (l_to_project is null) then

      begin

        select
          prj.SEGMENT1
        into
          l_to_project
        from
          PA_PROJECTS_ALL prj
        where
          prj.PROJECT_ID = PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                           (PJI_FM_SUM_MAIN.g_process, 'TO_PROJECT_ID');

        exception when no_data_found then null;

      end;

    end if;

    insert into PJI_FM_EXTR_DREVN -- overload of draft revenues table for cmt
    (
      WORKER_ID,
      ROW_ID,
      LINE_SOURCE_TYPE,
      PROJECT_ID,
      PA_PERIOD_NAME,
      GL_PERIOD_NAME,
      BATCH_ID
    )
    select
      -1                          WORKER_ID,        -- not used
      cmt.ROW_ID                  ROW_ID,           -- not used
      'X'                         LINE_SOURCE_TYPE, -- not used
      cmt.PROJECT_ID              PROJECT_ID,
      cmt.PA_PERIOD               PA_PERIOD_NAME,
      cmt.GL_PERIOD               GL_PERIOD_NAME,
      ceil(ROWNUM / l_batch_size) BATCH_ID
    from
      (
      select /*+ ordered */
        prj.PROJECT_ID,
        prj.ROW_ID,
        per.PA_PERIOD,
        per.GL_PERIOD
      from
        (
        select /*+ index(prj, PA_PROJECTS_U1) */
          prj.PROJECT_ID,
          prj.ROWID ROW_ID,
          prj.ORG_ID ORG_ID,       /*5377131*/
          prj.PROJECT_STATUS_CODE
        from
          PA_PROJECTS_ALL prj
        where
          prj.ORG_ID = nvl(l_operating_unit,
                                    prj.ORG_ID) and  /*5377131*/
          prj.SEGMENT1 between nvl(l_from_project, prj.SEGMENT1) and
                                 nvl(l_to_project, prj.SEGMENT1) and
          prj.TEMPLATE_FLAG = 'N'
        ) prj,
        (
        select
          PROJECT_STATUS_CODE
        from
          (
          select /*+ index_ffs(prj, PA_PROJECTS_N4)
                     parallel_index(prj, PA_PROJECTS_N4) */
            distinct
            prj.PROJECT_STATUS_CODE
          from
            PA_PROJECTS_ALL prj
          )
        where
          PA_PROJECT_UTILS.CHECK_PRJ_STUS_ACTION_ALLOWED
            (PROJECT_STATUS_CODE, 'STATUS_REPORTING') = 'Y'
        ) psc,
        (
          select /*+ index(per, PA_PERIODS_N3) */
            nvl(per.ORG_ID, -1) ORG_ID,
            per.PERIOD_NAME     PA_PERIOD,
            per.GL_PERIOD_NAME  GL_PERIOD
          from
            PA_PERIODS_ALL per
          where
           --    per.CURRENT_PA_PERIOD_FLAG = 'Y'  Bug fix 7602463
          trunc(sysdate) between per.start_date and per.end_date
        ) per
      where
        prj.PROJECT_STATUS_CODE = psc.PROJECT_STATUS_CODE and
        prj.ORG_ID =  per.ORG_ID
      ) cmt
    where
      1 = 1
      -- The below API only checks for those projects that already
      -- have rows in PA_COMMITMENTS_TXNS.
      -- PA_CHECK_COMMITMENTS.COMMITMENTS_CHANGED(cmt.PROJECT_ID) = 'Y'
    order by
      cmt.PROJECT_ID;

    insert into PJI_HELPER_BATCH_MAP
    (
      BATCH_ID,
      WORKER_ID,
      STATUS
    )
    select
      distinct
      BATCH_ID,
      null,
      null
    from
      PJI_FM_EXTR_DREVN; -- overload of draft revenues table for commitments

    delete
    from   PA_COMMITMENT_TXNS
    where  PROJECT_ID in
           (
           select
             PROJECT_ID
           from
             PJI_FM_EXTR_DREVN -- overload of draft revenues table for cmt
           );

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
      'PJI_FM_CMT_EXTR.REFRESH_PROJPERF_CMT_PRE(p_worker_id);');

    commit;

  end REFRESH_PROJPERF_CMT_PRE;


  -- -----------------------------------------------------
  -- procedure REFRESH_PROJPERF_CMT
  -- -----------------------------------------------------
  procedure REFRESH_PROJPERF_CMT (p_worker_id in number) is

    l_extract_commitments varchar2(30);
    l_process             varchar2(30);

    l_leftover_batches    number;
    l_helper_batch_id     number;
    l_row_count           number;
    l_parallel_processes  number;

    x_run_id              number;
    x_status              number;
    x_stage               number;
    x_err_stage           varchar2(120);
    x_err_code            number;

    l_project_id          number;
    l_org_id              number; -- bug 6847113

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
                'PJI_FM_CMT_EXTR.REFRESH_PROJPERF_CMT(p_worker_id);')) then
      return;
    end if;

    l_parallel_processes := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                            (PJI_FM_SUM_MAIN.g_process, 'PARALLEL_PROCESSES');

    l_extract_commitments := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                             (PJI_FM_SUM_MAIN.g_process,
                              'EXTRACT_COMMITMENTS');

    if (l_extract_commitments = 'N') then

      for x in 2 .. l_parallel_processes loop

        update PJI_SYSTEM_PRC_STATUS
        set    STEP_STATUS = 'C'
        where  PROCESS_NAME like PJI_FM_SUM_MAIN.g_process || x and
               STEP_NAME =
                       'PJI_FM_CMT_EXTR.REFRESH_PROJPERF_CMT(p_worker_id);' and
               START_DATE is null;

        commit;

      end loop;

      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
        (l_process, 'PJI_FM_CMT_EXTR.REFRESH_PROJPERF_CMT(p_worker_id);');

      commit;

      return;

    end if;

    select count(*)
    into   l_leftover_batches
    from   PJI_HELPER_BATCH_MAP
    where  WORKER_ID = p_worker_id and
           STATUS = 'P';

    l_helper_batch_id   := 0;

    while l_helper_batch_id >= 0 loop

      if (l_leftover_batches > 0) then

        l_leftover_batches := l_leftover_batches - 1;

        select  BATCH_ID
        into    l_helper_batch_id
        from    PJI_HELPER_BATCH_MAP
        where   WORKER_ID = p_worker_id and
                STATUS = 'P' and
                ROWNUM = 1;

      else

        update    PJI_HELPER_BATCH_MAP
        set       WORKER_ID = p_worker_id,
                  STATUS = 'P'
        where     WORKER_ID is null and
                  ROWNUM = 1
        returning BATCH_ID
        into      l_helper_batch_id;

      end if;

      if (sql%rowcount <> 0) then

        commit;
	 -- bug 6847113
        select org_id into l_org_id
	   from pa_projects_all
	   where project_id  =
	           ( select project_id from PJI_FM_EXTR_DREVN
		     where  BATCH_ID = l_helper_batch_id
		     and rownum=1);
	PA_CURRENCY.G_org_id := l_org_id;

	-- Bug 6847113


        PA_TXN_ACCUMS.CREATE_CMT_TXNS(null,
                                      l_helper_batch_id, -- overload of to
                                      null,              --   project parameter
                                      x_err_stage,
                                      x_err_code);

        for c in (select PROJECT_ID
                  from   PJI_FM_EXTR_DREVN -- overload of drev table for cmt
                  where  BATCH_ID = l_helper_batch_id) loop

          begin

            -- Create summarized burden commitment transactions

            PA_BURDEN_COSTING.CREATE_BURDEN_CMT_TRANSACTION
             (x_project_id => c.PROJECT_ID,
              status       => x_status,
              stage        => x_stage ,
              x_run_id     => x_run_id);

            ACCUM_PROJPERF_COMMITMENTS(c.PROJECT_ID,
                                       x_err_stage,
                                       x_err_code);

            exception when others then

              x_err_code := SQLCODE;

          end;

        end loop;

        update PJI_HELPER_BATCH_MAP
        set    STATUS = 'C'
        where  WORKER_ID = p_worker_id and
               BATCH_ID = l_helper_batch_id;

        commit;
	PA_CURRENCY.G_org_id := NULL;  -- bug 6847113

      else

        select count(*)
        into   l_row_count
        from   PJI_HELPER_BATCH_MAP
        where  nvl(STATUS, 'X') <> 'C';

        if (l_row_count = 0) then

          for x in 2 .. l_parallel_processes loop

            update PJI_SYSTEM_PRC_STATUS
            set    STEP_STATUS = 'C'
            where  PROCESS_NAME like PJI_FM_SUM_MAIN.g_process || x and
                   STEP_NAME =
                       'PJI_FM_CMT_EXTR.REFRESH_PROJPERF_CMT(p_worker_id);' and
                   START_DATE is null;

            commit;

          end loop;

          l_helper_batch_id := -1;

        else

          PJI_PROCESS_UTIL.SLEEP(1); -- so the CPU is not bombarded

        end if;

      end if;

      if (l_helper_batch_id >= 0) then

        for x in 2 .. l_parallel_processes loop
          if (not PJI_FM_SUM_EXTR.WORKER_STATUS(x, 'OKAY')) then
            l_helper_batch_id := -2;
          end if;
        end loop;

      end if;

    end loop;

    if (l_helper_batch_id <> -2) then

      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
        'PJI_FM_CMT_EXTR.REFRESH_PROJPERF_CMT(p_worker_id);');

    end if;

    commit;

  end REFRESH_PROJPERF_CMT;


  -- -----------------------------------------------------
  -- procedure REFRESH_PROJPERF_CMT_POST
  -- -----------------------------------------------------
  procedure REFRESH_PROJPERF_CMT_POST (p_worker_id in number) is

    l_extract_commitments varchar2(30);
    l_process             varchar2(30);
    l_schema              varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
              'PJI_FM_CMT_EXTR.REFRESH_PROJPERF_CMT_POST(p_worker_id);')) then
      return;
    end if;

    l_extract_commitments := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                             (PJI_FM_SUM_MAIN.g_process,
                              'EXTRACT_COMMITMENTS');

    if (l_extract_commitments = 'N') then
      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
        'PJI_FM_CMT_EXTR.REFRESH_PROJPERF_CMT_POST(p_worker_id);');
      commit;
      return;
    end if;

    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FM_EXTR_DREVN',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_HELPER_BATCH_MAP',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
      'PJI_FM_CMT_EXTR.REFRESH_PROJPERF_CMT_POST(p_worker_id);');

    commit;

  end REFRESH_PROJPERF_CMT_POST;


  -- -----------------------------------------------------
  -- procedure FIN_CMT_SUMMARY
  -- -----------------------------------------------------
  procedure FIN_CMT_SUMMARY (p_worker_id in number) is

    l_extract_commitments varchar2(30);
    l_process             varchar2(30);

    l_transition_flag     varchar2(1);
    l_params_cost_flag    varchar2(1);
    l_params_util_flag    varchar2(1);
    l_g2_currency_code    varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
                         'PJI_FM_CMT_EXTR.FIN_CMT_SUMMARY(p_worker_id);')) then
      return;
    end if;

    l_extract_commitments := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                             (PJI_FM_SUM_MAIN.g_process,
                              'EXTRACT_COMMITMENTS');

    if (l_extract_commitments = 'N') then
      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
        'PJI_FM_CMT_EXTR.FIN_CMT_SUMMARY(p_worker_id);');
      commit;
      return;
    end if;

	pji_utils.write2log('Entering FIN_CMT_SUMMARY');
	l_transition_flag := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_FM_SUM_MAIN.g_process, 'TRANSITION');

	if (l_transition_flag = 'Y') then
		l_params_cost_flag := nvl(PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_FM_SUM_MAIN.g_process,'CONFIG_COST_FLAG'), 'N');
	else -- l_transition is null or 'N'
		l_params_cost_flag := nvl(PJI_UTILS.GET_PARAMETER('CONFIG_COST_FLAG'), 'N');
	end if;

    l_g2_currency_code := PJI_UTILS.GET_GLOBAL_SECONDARY_CURRENCY;

    if (l_g2_currency_code is not null) then
      l_g2_currency_code := 'Y';
    else
      l_g2_currency_code := 'N';
    end if;

    insert /*+ append parallel(fin2_i) */ into PJI_FM_AGGR_FIN2 fin2_i  --  in FIN_SUMMARY
    (
      WORKER_ID,
      ROW_ID,
      RECORD_TYPE,
      CMT_RECORD_TYPE,
      DANGLING_RECVR_GL_RATE_FLAG,
      DANGLING_RECVR_PA_RATE_FLAG,
      DANGLING_RECVR_GL_RATE2_FLAG,
      DANGLING_RECVR_PA_RATE2_FLAG,
      DANGLING_PRVDR_EN_TIME_FLAG,
      DANGLING_PRVDR_GL_TIME_FLAG,
      DANGLING_PRVDR_PA_TIME_FLAG,
      DANGLING_RECVR_EN_TIME_FLAG,
      DANGLING_RECVR_GL_TIME_FLAG,
      DANGLING_RECVR_PA_TIME_FLAG,
      DANGLING_EXP_EN_TIME_FLAG,
      DANGLING_EXP_GL_TIME_FLAG,
      DANGLING_EXP_PA_TIME_FLAG,
      PJI_PROJECT_RECORD_FLAG,
      PJI_RESOURCE_RECORD_FLAG,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PERSON_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      WORK_TYPE_ID,
      JOB_ID,
      EXP_EVT_TYPE_ID,
      PROJECT_TYPE_CLASS,
      TASK_ID,
      VENDOR_ID,
      EXPENDITURE_TYPE,
      EVENT_TYPE,
      EVENT_TYPE_CLASSIFICATION,
      EXPENDITURE_CATEGORY,
      REVENUE_CATEGORY,
      NON_LABOR_RESOURCE,
      BOM_LABOR_RESOURCE_ID,
      BOM_EQUIPMENT_RESOURCE_ID,
      INVENTORY_ITEM_ID,
      SYSTEM_LINKAGE_FUNCTION,
      RESOURCE_CLASS_CODE,
      PRVDR_GL_TIME_ID,
      RECVR_GL_TIME_ID,
      GL_PERIOD_NAME,
      PRVDR_PA_TIME_ID,
      RECVR_PA_TIME_ID,
      PA_PERIOD_NAME,
      EXPENDITURE_ITEM_TIME_ID,
      PJ_GL_CALENDAR_ID,
      PJ_PA_CALENDAR_ID,
      RS_GL_CALENDAR_ID,
      RS_PA_CALENDAR_ID,
      TXN_CURRENCY_CODE,
      TXN_REVENUE,
      TXN_RAW_COST,
      TXN_BRDN_COST,
      TXN_BILL_RAW_COST,
      TXN_BILL_BRDN_COST,
      PRJ_REVENUE,
      PRJ_LABOR_REVENUE,
      PRJ_RAW_COST,
      PRJ_BRDN_COST,
      PRJ_BILL_RAW_COST,
      PRJ_BILL_BRDN_COST,
      PRJ_LABOR_RAW_COST,
      PRJ_LABOR_BRDN_COST,
      PRJ_BILL_LABOR_RAW_COST,
      PRJ_BILL_LABOR_BRDN_COST,
      PRJ_REVENUE_WRITEOFF,
      POU_REVENUE,
      POU_LABOR_REVENUE,
      POU_RAW_COST,
      POU_BRDN_COST,
      POU_BILL_RAW_COST,
      POU_BILL_BRDN_COST,
      POU_LABOR_RAW_COST,
      POU_LABOR_BRDN_COST,
      POU_BILL_LABOR_RAW_COST,
      POU_BILL_LABOR_BRDN_COST,
      POU_REVENUE_WRITEOFF,
      EOU_REVENUE,
      EOU_RAW_COST,
      EOU_BRDN_COST,
      EOU_BILL_RAW_COST,
      EOU_BILL_BRDN_COST,
      LABOR_HRS,
      BILL_LABOR_HRS,
      TOTAL_HRS_A,
      BILL_HRS_A,
      GG1_REVENUE,
      GG1_LABOR_REVENUE,
      GG1_RAW_COST,
      GG1_BRDN_COST,
      GG1_BILL_RAW_COST,
      GG1_BILL_BRDN_COST,
      GG1_LABOR_RAW_COST,
      GG1_LABOR_BRDN_COST,
      GG1_BILL_LABOR_RAW_COST,
      GG1_BILL_LABOR_BRDN_COST,
      GG1_REVENUE_WRITEOFF,
      GP1_REVENUE,
      GP1_LABOR_REVENUE,
      GP1_RAW_COST,
      GP1_BRDN_COST,
      GP1_BILL_RAW_COST,
      GP1_BILL_BRDN_COST,
      GP1_LABOR_RAW_COST,
      GP1_LABOR_BRDN_COST,
      GP1_BILL_LABOR_RAW_COST,
      GP1_BILL_LABOR_BRDN_COST,
      GP1_REVENUE_WRITEOFF,
      GG2_REVENUE,
      GG2_LABOR_REVENUE,
      GG2_RAW_COST,
      GG2_BRDN_COST,
      GG2_BILL_RAW_COST,
      GG2_BILL_BRDN_COST,
      GG2_LABOR_RAW_COST,
      GG2_LABOR_BRDN_COST,
      GG2_BILL_LABOR_RAW_COST,
      GG2_BILL_LABOR_BRDN_COST,
      GG2_REVENUE_WRITEOFF,
      GP2_REVENUE,
      GP2_LABOR_REVENUE,
      GP2_RAW_COST,
      GP2_BRDN_COST,
      GP2_BILL_RAW_COST,
      GP2_BILL_BRDN_COST,
      GP2_LABOR_RAW_COST,
      GP2_LABOR_BRDN_COST,
      GP2_BILL_LABOR_RAW_COST,
      GP2_BILL_LABOR_BRDN_COST,
      GP2_REVENUE_WRITEOFF
    )
    select /*+ no_merge(tmp1) */
      1                                            WORKER_ID,
      null                                         ROW_ID,
      'M'                                          RECORD_TYPE,
      tmp1.LINE_TYPE                               CMT_RECORD_TYPE,
      tmp1.DANGLING_RECVR_GL_RATE_FLAG,
      tmp1.DANGLING_RECVR_PA_RATE_FLAG,
      tmp1.DANGLING_RECVR_GL_RATE2_FLAG,
      tmp1.DANGLING_RECVR_PA_RATE2_FLAG,
      null                                         DANGLING_PRVDR_EN_TIME_FLAG,
      null                                         DANGLING_PRVDR_GL_TIME_FLAG,
      null                                         DANGLING_PRVDR_PA_TIME_FLAG,
      tmp1.DANGLING_RECVR_EN_TIME_FLAG,
      tmp1.DANGLING_RECVR_GL_TIME_FLAG,
      tmp1.DANGLING_RECVR_PA_TIME_FLAG,
      tmp1.DANGLING_EXP_EN_TIME_FLAG,
      tmp1.DANGLING_EXP_GL_TIME_FLAG,
      tmp1.DANGLING_EXP_PA_TIME_FLAG,
      decode(l_params_cost_flag,'N','N','Y')       PJI_PROJECT_RECORD_FLAG,
      'N'                                          PJI_RESOURCE_RECORD_FLAG,
      tmp1.PROJECT_ID,
      tmp1.PROJECT_ORG_ID,
      tmp1.PROJECT_ORGANIZATION_ID,
      -1                                           PERSON_ID,
      -1                                           EXPENDITURE_ORG_ID,
      tmp1.EXPENDITURE_ORGANIZATION_ID,
      -1                                           WORK_TYPE_ID,
      -1                                           JOB_ID,
      et.EXPENDITURE_TYPE_ID                       EXP_EVT_TYPE_ID,
      tmp1.PROJECT_TYPE_CLASS,
      tmp1.TASK_ID,
      tmp1.VENDOR_ID,
      et.EXPENDITURE_TYPE                          EXPENDITURE_TYPE,
      'PJI$NULL'                                   EVENT_TYPE,
      'PJI$NULL'                                   EVENT_TYPE_CLASSIFICATION,
      tmp1.EXPENDITURE_CATEGORY,
      et.REVENUE_CATEGORY_CODE                     REVENUE_CATEGORY,
      'PJI$NULL'                                   NON_LABOR_RESOURCE,
      tmp1.BOM_LABOR_RESOURCE_ID,
      tmp1.BOM_EQUIPMENT_RESOURCE_ID,
      tmp1.INVENTORY_ITEM_ID,
      tmp1.SYSTEM_LINKAGE_FUNCTION,
      tmp1.RESOURCE_CLASS_CODE,
      -1                                           PRVDR_GL_TIME_ID,
      tmp1.RECVR_GL_TIME_ID,
      tmp1.GL_PERIOD_NAME,
      -1                                           PRVDR_PA_TIME_ID,
      tmp1.RECVR_PA_TIME_ID,
      tmp1.PA_PERIOD_NAME,
      tmp1.EXPENDITURE_ITEM_TIME_ID,
      tmp1.PJ_GL_CALENDAR_ID,
      tmp1.PJ_PA_CALENDAR_ID,
      -1                                           RS_GL_CALENDAR_ID,
      -1                                           RS_PA_CALENDAR_ID,
      tmp1.DENOM_CURRENCY_CODE                     TXN_CURRENCY_CODE,
      to_number(null)                              TXN_REVENUE,
      tmp1.DENOM_RAW_COST                          TXN_RAW_COST,
      tmp1.DENOM_BURDENED_COST                     TXN_BRDN_COST,
      to_number(null)                              TXN_BILL_RAW_COST,
      to_number(null)                              TXN_BILL_BRDN_COST,
      to_number(null)                              PRJ_REVENUE,
      to_number(null)                              PRJ_LABOR_REVENUE,
      tmp1.PRJ_RAW_COST,
      tmp1.PRJ_BRDN_COST,
      to_number(null)                              PRJ_BILL_RAW_COST,
      to_number(null)                              PRJ_BILL_BRDN_COST,
      tmp1.PRJ_LABOR_RAW_COST,
      tmp1.PRJ_LABOR_BRDN_COST,
      to_number(null)                              PRJ_BILL_LABOR_RAW_COST,
      to_number(null)                              PRJ_BILL_LABOR_BRDN_COST,
      to_number(null)                              PRJ_REVENUE_WRITEOFF,
      to_number(null)                              POU_REVENUE,
      to_number(null)                              POU_LABOR_REVENUE,
      tmp1.POU_RAW_COST,
      tmp1.POU_BRDN_COST,
      to_number(null)                              POU_BILL_RAW_COST,
      to_number(null)                              POU_BILL_BRDN_COST,
      tmp1.POU_LABOR_RAW_COST,
      tmp1.POU_LABOR_BRDN_COST,
      to_number(null)                              POU_BILL_LABOR_RAW_COST,
      to_number(null)                              POU_BILL_LABOR_BRDN_COST,
      to_number(null)                              POU_REVENUE_WRITEOFF,
      to_number(null)                              EOU_REVENUE,
      tmp1.EOU_RAW_COST,
      tmp1.EOU_BRDN_COST,
      to_number(null)                              EOU_BILL_RAW_COST,
      to_number(null)                              EOU_BILL_BRDN_COST,
      to_number(null)                              LABOR_HRS,
      to_number(null)                              BILL_LABOR_HRS,
      to_number(null)                              TOTAL_HRS_A,
      to_number(null)                              BILL_HRS_A,
      to_number(null)                              GG1_REVENUE,
      to_number(null)                              GG1_LABOR_REVENUE,
      round(tmp1.POU_RAW_COST * tmp1.PRJ_PA_RATE / MAU) * MAU
                                                   GG1_RAW_COST,
      round(tmp1.POU_BRDN_COST * tmp1.PRJ_PA_RATE / MAU) * MAU
                                                   GG1_BRDN_COST,
      to_number(null)                              GG1_BILL_RAW_COST,
      to_number(null)                              GG1_BILL_BRDN_COST,
      round(tmp1.POU_LABOR_RAW_COST * tmp1.PRJ_PA_RATE / MAU) * MAU
                                                   GG1_LABOR_RAW_COST,
      round(tmp1.POU_LABOR_BRDN_COST * tmp1.PRJ_PA_RATE / MAU) * MAU
                                                   GG1_LABOR_BRDN_COST,
      to_number(null)                              GG1_BILL_LABOR_RAW_COST,
      to_number(null)                              GG1_BILL_LABOR_BRDN_COST,
      to_number(null)                              GG1_REVENUE_WRITEOFF,
      to_number(null)                              GP1_REVENUE,
      to_number(null)                              GP1_LABOR_REVENUE,
      round(tmp1.POU_RAW_COST * tmp1.PRJ_PA_RATE / MAU) * MAU
                                                   GP1_RAW_COST,
      round(tmp1.POU_BRDN_COST * tmp1.PRJ_PA_RATE / MAU) * MAU
                                                   GP1_BRDN_COST,
      to_number(null)                              GP1_BILL_RAW_COST,
      to_number(null)                              GP1_BILL_BRDN_COST,
      round(tmp1.POU_LABOR_RAW_COST * tmp1.PRJ_PA_RATE / MAU) * MAU
                                                   GP1_LABOR_RAW_COST,
      round(tmp1.POU_LABOR_BRDN_COST * tmp1.PRJ_PA_RATE / MAU) * MAU
                                                   GP1_LABOR_BRDN_COST,
      to_number(null)                              GP1_BILL_LABOR_RAW_COST,
      to_number(null)                              GP1_BILL_LABOR_BRDN_COST,
      to_number(null)                              GP1_REVENUE_WRITEOFF,
      to_number(null)                              GG2_REVENUE,
      to_number(null)                              GG2_LABOR_REVENUE,
      round(tmp1.POU_RAW_COST * tmp1.PRJ_PA_RATE2 / MAU2) * MAU2
                                                   GG2_RAW_COST,
      round(tmp1.POU_BRDN_COST * tmp1.PRJ_PA_RATE2 / MAU2) * MAU2
                                                   GG2_BRDN_COST,
      to_number(null)                              GG2_BILL_RAW_COST,
      to_number(null)                              GG2_BILL_BRDN_COST,
      round(tmp1.POU_LABOR_RAW_COST * tmp1.PRJ_PA_RATE2 / MAU2) * MAU2
                                                   GG2_LABOR_RAW_COST,
      round(tmp1.POU_LABOR_BRDN_COST * tmp1.PRJ_PA_RATE2 / MAU2) * MAU2
                                                   GG2_LABOR_BRDN_COST,
      to_number(null)                              GG2_BILL_LABOR_RAW_COST,
      to_number(null)                              GG2_BILL_LABOR_BRDN_COST,
      to_number(null)                              GG2_REVENUE_WRITEOFF,
      to_number(null)                              GP2_REVENUE,
      to_number(null)                              GP2_LABOR_REVENUE,
      round(tmp1.POU_RAW_COST * tmp1.PRJ_PA_RATE2 / MAU2) * MAU2
                                                   GP2_RAW_COST,
      round(tmp1.POU_BRDN_COST * tmp1.PRJ_PA_RATE2 / MAU2) * MAU2
                                                   GP2_BRDN_COST,
      to_number(null)                              GP2_BILL_RAW_COST,
      to_number(null)                              GP2_BILL_BRDN_COST,
      round(tmp1.POU_LABOR_RAW_COST * tmp1.PRJ_PA_RATE2 / MAU2) * MAU2
                                                   GP2_LABOR_RAW_COST,
      round(tmp1.POU_LABOR_BRDN_COST * tmp1.PRJ_PA_RATE2 / MAU2) * MAU2
                                                   GP2_LABOR_BRDN_COST,
      to_number(null)                              GP2_BILL_LABOR_RAW_COST,
      to_number(null)                              GP2_BILL_LABOR_BRDN_COST,
      to_number(null)                              GP2_REVENUE_WRITEOFF
    from
		(
		select /*+ no_merge(tmp1) */
			decode(prj_rt.RATE,-3,'E' -- EUR conversion rate for 01-JAN-1999 is missing
				,decode(sign(prj_rt.RATE),-1,'Y',null))  DANGLING_RECVR_GL_RATE_FLAG,
			decode(prj_rt.RATE,-3,'E' -- EUR conversion rate for 01-JAN-1999 is missing
				,decode(sign(prj_rt.RATE),-1,'Y',null))  DANGLING_RECVR_PA_RATE_FLAG,
			decode(l_g2_currency_code,
			       'Y', decode(prj_rt.RATE2,-3,'E' -- EUR conversion rate for 01-JAN-1999 is missing
				            ,decode(sign(prj_rt.RATE2),-1,'Y',null)),
			       null)                                     DANGLING_RECVR_GL_RATE2_FLAG,
			decode(l_g2_currency_code,
			       'Y', decode(prj_rt.RATE2,-3,'E' -- EUR conversion rate for 01-JAN-1999 is missing
				            ,decode(sign(prj_rt.RATE2),-1,'Y',null)),
			       null)                                     DANGLING_RECVR_PA_RATE2_FLAG,
			decode(sign(prj_info.EN_CALENDAR_MIN_DATE-tmp1.RECVR_GL_TIME_ID)+
				sign(tmp1.RECVR_GL_TIME_ID-prj_info.EN_CALENDAR_MAX_DATE),
				0,'Y',null)       DANGLING_RECVR_EN_TIME_FLAG,
			decode(sign(prj_info.EN_CALENDAR_MIN_DATE-tmp1.EXPENDITURE_ITEM_TIME_ID)+
				sign(tmp1.EXPENDITURE_ITEM_TIME_ID-prj_info.EN_CALENDAR_MAX_DATE),
				0,'Y',null)       DANGLING_EXP_EN_TIME_FLAG,
			decode(sign(prj_info.GL_CALENDAR_MIN_DATE-tmp1.RECVR_GL_TIME_ID)+
				sign(tmp1.RECVR_GL_TIME_ID-prj_info.GL_CALENDAR_MAX_DATE),
				0,'Y',null)       DANGLING_RECVR_GL_TIME_FLAG,
			decode(sign(prj_info.GL_CALENDAR_MIN_DATE-tmp1.EXPENDITURE_ITEM_TIME_ID)+
				sign(tmp1.EXPENDITURE_ITEM_TIME_ID-prj_info.GL_CALENDAR_MAX_DATE),
				0,'Y',null)       DANGLING_EXP_GL_TIME_FLAG,
			decode(sign(prj_info.PA_CALENDAR_MIN_DATE-tmp1.RECVR_PA_TIME_ID)+
				sign(tmp1.RECVR_PA_TIME_ID-prj_info.PA_CALENDAR_MAX_DATE),
				0,'Y',null)       DANGLING_RECVR_PA_TIME_FLAG,
			decode(sign(prj_info.PA_CALENDAR_MIN_DATE-tmp1.EXPENDITURE_ITEM_TIME_ID)+
				sign(tmp1.EXPENDITURE_ITEM_TIME_ID-prj_info.PA_CALENDAR_MAX_DATE),
				0,'Y',null)       DANGLING_EXP_PA_TIME_FLAG,
			'Y',
			tmp1.PROJECT_ID,
			tmp1.PROJECT_ORG_ID,
			tmp1.PROJECT_ORGANIZATION_ID,
			tmp1.PROJECT_TYPE_CLASS,
			tmp1.EXPENDITURE_ORGANIZATION_ID,
			tmp1.RECVR_GL_TIME_ID,
			tmp1.RECVR_PA_TIME_ID,
			tmp1.EXPENDITURE_ITEM_TIME_ID,
                        tmp1.GL_PERIOD_NAME,
                        tmp1.PA_PERIOD_NAME,
			prj_info.GL_CALENDAR_ID			PJ_GL_CALENDAR_ID,
			prj_info.PA_CALENDAR_ID			PJ_PA_CALENDAR_ID,
			prj_rt.RATE				PRJ_PA_RATE,
			prj_rt.MAU				MAU,
			prj_rt.RATE2				PRJ_PA_RATE2,
			prj_rt.MAU2				MAU2,
			tmp1.PRJ_RAW_COST,
			tmp1.PRJ_BRDN_COST,
			tmp1.PRJ_LABOR_RAW_COST,
			tmp1.PRJ_LABOR_BRDN_COST,
			tmp1.POU_RAW_COST,
			tmp1.POU_BRDN_COST,
			tmp1.POU_LABOR_RAW_COST,
			tmp1.POU_LABOR_BRDN_COST,
			tmp1.EOU_RAW_COST,
			tmp1.EOU_BRDN_COST,
			tmp1.DENOM_CURRENCY_CODE,
			tmp1.DENOM_RAW_COST,
			tmp1.DENOM_BURDENED_COST,
			tmp1.TASK_ID,
			tmp1.VENDOR_ID,
			tmp1.EXPENDITURE_TYPE,
			tmp1.EXPENDITURE_CATEGORY,
			tmp1.SYSTEM_LINKAGE_FUNCTION,
			tmp1.RESOURCE_CLASS_CODE,
			tmp1.LINE_TYPE,
			tmp1.INVENTORY_ITEM_ID,
			tmp1.BOM_LABOR_RESOURCE_ID,
			tmp1.BOM_EQUIPMENT_RESOURCE_ID
		from
			PJI_ORG_EXTR_INFO     prj_info,
			(
			select /*+ parallel(tmp1) */
				tmp1.PROJECT_ID,
				proj.org_id PROJECT_ORG_ID,
				proj.carrying_out_organization_id PROJECT_ORGANIZATION_ID,
				DECODE(projtyp.PROJECT_TYPE_CLASS_CODE,
				       'CAPITAL',  'C',
				       'CONTRACT', 'B',
				       'INDIRECT', 'I') PROJECT_TYPE_CLASS,
				tmp1.ORGANIZATION_ID EXPENDITURE_ORGANIZATION_ID,
				decode(l_params_cost_flag,'N',-1,
					to_number(to_char(nvl(tmp1.CMT_PROMISED_DATE,nvl(tmp1.CMT_NEED_BY_DATE,tmp1.EXPENDITURE_ITEM_DATE)), 'J')))
					RECVR_GL_TIME_ID,
				decode(l_params_cost_flag,'N',-1,
					to_number(to_char(nvl(tmp1.CMT_PROMISED_DATE,nvl(tmp1.CMT_NEED_BY_DATE,tmp1.EXPENDITURE_ITEM_DATE)), 'J')))
					RECVR_PA_TIME_ID,
				to_number(to_char(tmp1.EXPENDITURE_ITEM_DATE,'J'))                  EXPENDITURE_ITEM_TIME_ID,
                                null                                GL_PERIOD_NAME,
                                null                                PA_PERIOD_NAME,
				sum(tmp1.PROJ_RAW_COST)                   PRJ_RAW_COST,
				sum(tmp1.PROJ_BURDENED_COST)              PRJ_BRDN_COST,
			      sum(decode(NVL(tmp1.SRC_SYSTEM_LINKAGE_FUNCTION,
                                             tmp1.SYSTEM_LINKAGE_FUNCTION),
					 'ST', tmp1.PROJ_RAW_COST,
					 'OT', tmp1.PROJ_RAW_COST, 0))  PRJ_LABOR_RAW_COST,
			      sum(decode(NVL(tmp1.SRC_SYSTEM_LINKAGE_FUNCTION,
                                             tmp1.SYSTEM_LINKAGE_FUNCTION),
					 'ST', tmp1.PROJ_BURDENED_COST,
					 'OT', tmp1.PROJ_BURDENED_COST,
					 0))                           PRJ_LABOR_BRDN_COST,
				sum(tmp1.TOT_CMT_RAW_COST)                   POU_RAW_COST,
				sum(tmp1.TOT_CMT_BURDENED_COST)              POU_BRDN_COST,
			      sum(decode(NVL(tmp1.SRC_SYSTEM_LINKAGE_FUNCTION,
                                             tmp1.SYSTEM_LINKAGE_FUNCTION),
					 'ST', tmp1.TOT_CMT_RAW_COST,
					 'OT', tmp1.TOT_CMT_RAW_COST,
					 0))                           POU_LABOR_RAW_COST,
			      sum(decode(NVL(tmp1.SRC_SYSTEM_LINKAGE_FUNCTION,
                                             tmp1.SYSTEM_LINKAGE_FUNCTION),
					 'ST', tmp1.TOT_CMT_BURDENED_COST,
					 'OT', tmp1.TOT_CMT_BURDENED_COST,
					 0))                           POU_LABOR_BRDN_COST,
				sum(tmp1.ACCT_RAW_COST)                   EOU_RAW_COST,
				sum(tmp1.ACCT_BURDENED_COST)              EOU_BRDN_COST,
				tmp1.DENOM_CURRENCY_CODE,
				sum(tmp1.DENOM_RAW_COST)  		DENOM_RAW_COST,
				sum(tmp1.DENOM_BURDENED_COST) 		DENOM_BURDENED_COST,
				tmp1.TASK_ID,
				tmp1.VENDOR_ID,
				tmp1.EXPENDITURE_TYPE,
				tmp1.EXPENDITURE_CATEGORY,
				NVL(tmp1.SRC_SYSTEM_LINKAGE_FUNCTION,
                                    tmp1.SYSTEM_LINKAGE_FUNCTION)       SYSTEM_LINKAGE_FUNCTION, --Bug 3964738
				tmp1.RESOURCE_CLASS                     RESOURCE_CLASS_CODE,
				tmp1.LINE_TYPE,
                                tmp1.INVENTORY_ITEM_ID,
			        tmp1.BOM_LABOR_RESOURCE_ID,
				tmp1.BOM_EQUIPMENT_RESOURCE_ID
			from
				PA_COMMITMENT_TXNS tmp1,
				PA_PROJECTS_ALL proj,
				PA_PROJECT_TYPES_ALL projtyp
			where
				tmp1.project_id      = proj.project_id and
				proj.project_type    = projtyp.project_type and
                                proj.org_id = projtyp.org_id   /*5377131*/
			group by
				tmp1.PROJECT_ID,
				proj.org_id,
				proj.carrying_out_organization_id,
				projtyp.PROJECT_TYPE_CLASS_CODE,
				tmp1.ORGANIZATION_ID,
				decode(l_params_cost_flag,'N',-1,to_number(to_char(nvl(tmp1.CMT_PROMISED_DATE,nvl(tmp1.CMT_NEED_BY_DATE,tmp1.EXPENDITURE_ITEM_DATE)), 'J'))),
				decode(l_params_cost_flag,'N',-1,to_number(to_char(nvl(tmp1.CMT_PROMISED_DATE,nvl(tmp1.CMT_NEED_BY_DATE,tmp1.EXPENDITURE_ITEM_DATE)), 'J'))),
				to_number(to_char(tmp1.EXPENDITURE_ITEM_DATE,'J')),
                                tmp1.GL_PERIOD,
                                tmp1.PA_PERIOD,
				tmp1.DENOM_CURRENCY_CODE,
				tmp1.TASK_ID,
				tmp1.VENDOR_ID,
				tmp1.EXPENDITURE_TYPE,
				tmp1.EXPENDITURE_CATEGORY,
				NVL(tmp1.SRC_SYSTEM_LINKAGE_FUNCTION,
                                    tmp1.SYSTEM_LINKAGE_FUNCTION), --Bug 3964738
				tmp1.RESOURCE_CLASS,
				tmp1.LINE_TYPE,
                                tmp1.INVENTORY_ITEM_ID,
			        tmp1.BOM_LABOR_RESOURCE_ID,
				tmp1.BOM_EQUIPMENT_RESOURCE_ID
			) tmp1,
			PJI_FM_AGGR_DLY_RATES prj_rt
		where
			tmp1.PROJECT_ORG_ID                 = prj_info.ORG_ID            and
			prj_rt.WORKER_ID                    = -1                         and
			--tmp1.RECVR_PA_TIME_ID               = prj_rt.TIME_ID             and --Bug 6894858
			to_number(to_char(trunc(sysdate), 'J'))  = prj_rt.TIME_ID        and
			prj_info.PF_CURRENCY_CODE           = prj_rt.PF_CURRENCY_CODE
		) tmp1,
      PA_EXPENDITURE_TYPES et
    where
      tmp1.EXPENDITURE_TYPE = et.EXPENDITURE_TYPE;

pji_utils.write2log('Leaving FIN_CMT_SUMMARY');

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
      'PJI_FM_CMT_EXTR.FIN_CMT_SUMMARY(p_worker_id);');

    commit;

  end FIN_CMT_SUMMARY;

end PJI_FM_CMT_EXTR;

/
