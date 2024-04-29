--------------------------------------------------------
--  DDL for Package Body OKL_BILLING_CONTROLLER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BILLING_CONTROLLER_PVT" AS
/* $Header: OKLPBICB.pls 120.37.12010000.5 2010/05/07 05:54:19 rgooty ship $*/

TYPE req_tab_type is TABLE of NUMBER index by binary_integer;
TYPE batch_tab_type is TABLE of VARCHAR2(30) index by binary_integer;

-- Bug 4546873
g_opp_seq_num   okl_parallel_processes.assigned_process%type;
-- end Bug 4546873;

  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.BILLING';
  L_DEBUG_ENABLED VARCHAR2(10);
--  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;

  -- Contract or Investor Agreement type
  L_IA_TYPE   VARCHAR2(10) :='IA';
  L_CONTRACT_TYPE   VARCHAR2(10) :='CONTRACT';
  -- Contract or Investor Agreement type

  -- Bug 4520466
  FUNCTION get_next_bill_date ( p_khr_id IN NUMBER )
  return date IS

    l_bill_date     okl_strm_elements.stream_element_date%type;

    cursor next_bill_date_csr( p_khr_id IN NUMBER ) IS
        SELECT	MIN(ste.stream_element_date)
       	FROM	OKL_STRM_ELEMENTS		ste,
			OKL_STREAMS			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			OKL_K_HEADERS			khl,
			okc_k_lines_b			kle,
			okc_statuses_b			khs,
			okc_statuses_b			kls
		WHERE ste.amount 	    <> 0
		AND	stm.id				= ste.stm_id
		AND	ste.date_billed		IS NULL
		AND	stm.active_yn		= 'Y'
		AND	stm.say_code		= 'CURR'
		AND	sty.id				= stm.sty_id
		AND	sty.billable_yn		= 'Y'
		AND	khr.id				= stm.khr_id
	-- changed by zrehman for Bug#6788005 start
		AND	((khr.scs_code	IN ('LEASE', 'LOAN') AND khl.deal_type IS NOT NULL) OR (khr.scs_code = 'INVESTOR'))
        -- changed by zrehman for Bug#6788005 start
        --AND khr.sts_code        IN ( 'BOOKED','EVERGREEN','TERMINATED')
		AND	khr.id	= p_khr_id
		AND	khl.id				= stm.khr_id
		--AND	khl.deal_type		IS NOT NULL
		AND	khs.code			= khr.sts_code
		AND	kle.id			(+)	= stm.kle_id
		AND	kls.code		(+)	= kle.sts_code;
        --AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED');

  begin

      l_bill_date := null;

      open  next_bill_date_csr( p_khr_id );
      fetch next_bill_date_csr into l_bill_date;
      close next_bill_date_csr;

      return l_bill_date;

  exception
    when others then
         fnd_file.put_line(fnd_file.log,' **** Error deriving NEXT BILL DATE: '||SQLERRM||'. ****');
         return null;
  end get_next_bill_date;

  procedure track_next_bill_date ( p_khr_id IN NUMBER )

  is

    cursor khr_bill_date_csr( p_khr_id NUMBER ) is
        select nbd.khr_id
        from okl_k_control nbd,
             okl_k_headers_full_v khr
        where nbd.khr_id = khr.id
        and khr.id = p_khr_id;

    l_khr_id         number;
    l_next_bill_date date;

  -- Org Id and standard who columns
  l_last_updated_by     okl_k_control.last_updated_by%TYPE := Fnd_Global.USER_ID;
  l_last_update_login   okl_k_control.last_update_login%TYPE := Fnd_Global.LOGIN_ID;
  l_request_id          okl_k_control.request_id%TYPE := Fnd_Global.CONC_REQUEST_ID;
  l_program_id          okl_k_control.program_id%TYPE := Fnd_Global.CONC_PROGRAM_ID;

  begin

    if p_khr_id is null then
        fnd_file.put_line(fnd_file.log,' **** KHR_ID must be supplied for TRACK_NEXT_BILL_DATE. ****');
        return;
    end if;

    l_khr_id := null;

    open  khr_bill_date_csr( p_khr_id );
    fetch khr_bill_date_csr into l_khr_id;
    close khr_bill_date_csr;

    l_next_bill_date := null;
    l_next_bill_date := get_next_bill_date( p_khr_id );

    -- if a record exists in NBD, then update it, else create a new entry
    if l_khr_id is not null then

        update okl_k_control
        set EARLIEST_STRM_BILL_DATE = l_next_bill_date,
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = l_last_updated_by,
            LAST_UPDATE_LOGIN = l_last_update_login,
            REQUEST_ID = l_request_id,
            PROGRAM_ID = l_program_id,
            PROGRAM_UPDATE_DATE = sysdate
        where khr_id = l_khr_id;

    else -- if no entry exists in NBD

        INSERT INTO okl_k_control
        (
         khr_id, EARLIEST_STRM_BILL_DATE,
         CREATED_BY,CREATION_DATE,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN,
         REQUEST_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE
        )
        VALUES
        ( p_khr_id, l_next_bill_date,
         l_last_updated_by,sysdate,sysdate,l_last_updated_by,l_last_update_login,
         l_request_id,l_program_id,sysdate
        );

    end if;

  exception
    when others then
         null;
  end track_next_bill_date;
  -- End Bug 4520466
  -- -------------------------------------------------
  -- To purge parallel processes table
  -- -------------------------------------------------
  -- Bug 4546873;
PROCEDURE PURGE_PARALLEL_PROCESSES (
                            errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY NUMBER,
                            p_source           IN VARCHAR2 DEFAULT NULL)
  IS

    -- --------------------------------------
    -- To check for running concurrent pgms
    -- --------------------------------------
    CURSOR cnt_csr (p_conc_pgm1 VARCHAR2, p_conc_pgm2 VARCHAR2) IS
        select count(*)
        from fnd_concurrent_requests req,
             fnd_concurrent_programs_vl pgm
        where pgm.USER_CONCURRENT_PROGRAM_NAME
            IN ( p_conc_pgm1, p_conc_pgm2)
        and req.concurrent_program_id = pgm.concurrent_program_id
        and req.PHASE_CODE <> 'C';

  l_strm_bill_cnt     NUMBER;
  l_cnsld_cnt         NUMBER;
  l_xfer_cnt          NUMBER;
  l_prep_cnt          NUMBER;

  -- Bug 4546873
  -- Org Id and standard who columns
  l_last_updated_by     okl_parallel_processes.last_updated_by%TYPE := Fnd_Global.USER_ID;
  l_last_update_login   okl_parallel_processes.last_update_login%TYPE := Fnd_Global.LOGIN_ID;
  l_request_id          okl_parallel_processes.request_id%TYPE := Fnd_Global.CONC_REQUEST_ID;
  l_program_id          okl_parallel_processes.program_id%TYPE := Fnd_Global.CONC_PROGRAM_ID;
  l_org_id              okl_parallel_processes.org_id%type;
  -- End Bug 4546873

  -- Print variables
  l_print_strm_cnt   NUMBER;
  l_print_cons_cnt   NUMBER;
  l_print_xfer_cnt   NUMBER;
  l_print_prep_cnt   NUMBER;

  -- ----------------------------------------------------------
  -- Operating Unit
  -- ----------------------------------------------------------
  CURSOR op_unit_csr IS
         SELECT Name org_name, organization_id org_id
         FROM hr_operating_units
         WHERE mo_global.check_access(organization_id) = 'Y'; --MOAC



  l_op_unit_name      hr_operating_units.name%TYPE;
  l_op_unit_id      hr_operating_units.organization_id%TYPE;--MOAC

  BEGIN



For I in op_unit_csr --for Multi Org
Loop

    l_org_id := I.org_id;

    -- ----------------------------
    -- Initialize print variables
    -- ----------------------------
    l_print_strm_cnt   := 0;
    l_print_cons_cnt   := 0;
    l_print_xfer_cnt   := 0;


    Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
    fnd_file.put_line(fnd_file.log,'p_source: '||p_source);
    Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));

    IF p_source = 'STREAM_BILLING' THEN

           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,'** START: Delete all Stream Billing records from OKL_PARALLEL_PROCESSES. **');

           l_strm_bill_cnt := 0;
           OPEN  cnt_csr ('Master Program -- Process Billable Streams',
                          'Process Billable Streams');
           FETCH cnt_csr INTO l_strm_bill_cnt;
           CLOSE cnt_csr;

           IF l_strm_bill_cnt > 0 THEN

              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
              fnd_file.put_line(fnd_file.log,' => Could not perform a delete all for Stream Billing '
                                         ||'records because not all requests have Completed.');
              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));

           ELSE
              delete from okl_parallel_processes
              where OBJECT_TYPE = 'CONTRACT';

              l_print_strm_cnt := l_print_strm_cnt + (sql%rowcount);

              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
              fnd_file.put_line(fnd_file.log,' => Deleted '||sql%rowcount||' row(s).');
              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));

              commit;
           END IF;
           fnd_file.put_line(fnd_file.log,'** END: Delete all Stream Billing records from OKL_PARALLEL_PROCESSES. **');

           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,'** START: Delete Org specific Stream Billing records from OKL_PARALLEL_PROCESSES. **');

           delete from okl_parallel_processes
           where OBJECT_TYPE = 'CONTRACT'
           and org_id = l_org_id
           and request_id in (
                select req.request_id
                from fnd_concurrent_requests req,
                     fnd_concurrent_programs_vl pgm
                where pgm.USER_CONCURRENT_PROGRAM_NAME IN ( 'Master Program -- Process Billable Streams',
                                                            'Process Billable Streams')
                and req.concurrent_program_id = pgm.concurrent_program_id
                and req.PHASE_CODE = 'C');

           l_print_strm_cnt := l_print_strm_cnt + (sql%rowcount);

           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,' => Deleted '||sql%rowcount||' row(s).');
           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,'** END: Delete Org specific Stream Billing records from OKL_PARALLEL_PROCESSES. **');

           commit;
-- rmunjulu R12 fixes -- comment out consolidation
/*
    ELSIF p_source = 'CONSOLIDATION' THEN

           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,'** START: Delete all Consolidation records from OKL_PARALLEL_PROCESSES. **');
           l_cnsld_cnt := 0;
           OPEN  cnt_csr ('Master Program -- Receivables Bills Consolidation',
                          'Receivables Bills Consolidation');
           FETCH cnt_csr INTO l_cnsld_cnt;
           CLOSE cnt_csr;

           IF l_cnsld_cnt > 0 THEN
              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
              fnd_file.put_line(fnd_file.log,' => Could not perform a delete all for Consolidation '
                                         ||'records because not all requests have Completed.');
              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           ELSE
              delete from okl_parallel_processes
              where OBJECT_TYPE = 'CUSTOMER';

              l_print_cons_cnt := l_print_cons_cnt + (sql%rowcount);

              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
              fnd_file.put_line(fnd_file.log,' => Deleted '||sql%rowcount||' row(s).');
              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));

              commit;
           END IF;
           fnd_file.put_line(fnd_file.log,'** END: Delete all Consolidation records from OKL_PARALLEL_PROCESSES. **');

           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,'** START: Delete Org specific Consolidation records from OKL_PARALLEL_PROCESSES. **');
           delete from okl_parallel_processes
           where OBJECT_TYPE = 'CUSTOMER'
           and org_id = l_org_id
           and request_id in (
                select req.request_id
                from fnd_concurrent_requests req,
                     fnd_concurrent_programs_vl pgm
                where pgm.USER_CONCURRENT_PROGRAM_NAME IN ( 'Master Program -- Receivables Bills Consolidation',
                                                            'Receivables Bills Consolidation')
                and req.concurrent_program_id = pgm.concurrent_program_id
                and req.PHASE_CODE = 'C');

           l_print_cons_cnt := l_print_cons_cnt + (sql%rowcount);

           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,' => Deleted '||sql%rowcount||' row(s).');
           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));

           commit;
           fnd_file.put_line(fnd_file.log,'** END: Delete Org specific Consolidation records from OKL_PARALLEL_PROCESSES. **');
*/
    ELSIF p_source = 'AR_TRANSFER' THEN
           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,'** START: Delete all Transfer records from OKL_PARALLEL_PROCESSES. **');
           l_xfer_cnt := 0;
           OPEN  cnt_csr ('Master Program -- Receivables Invoice Transfer',
                          'Receivables Invoice Transfer to AR');
           FETCH cnt_csr INTO l_xfer_cnt;
           CLOSE cnt_csr;

           IF l_xfer_cnt > 0 THEN
              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
              fnd_file.put_line(fnd_file.log,' => Could not perform a delete all for Transfer '
                                         ||'records because not all requests have Completed.');
              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           ELSE
              delete from okl_parallel_processes
              where OBJECT_TYPE = 'XTRX_CONTRACT';

              l_print_xfer_cnt := l_print_xfer_cnt + (sql%rowcount);

              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
              fnd_file.put_line(fnd_file.log,' => Deleted '||sql%rowcount||' row(s).');
              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));

              commit;
           END IF;
           fnd_file.put_line(fnd_file.log,'** END: Delete all Transfer records from OKL_PARALLEL_PROCESSES. **');

           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,'** START: Delete Org Specific Transfer records from OKL_PARALLEL_PROCESSES. **');
           delete from okl_parallel_processes
           where OBJECT_TYPE = 'XTRX_CONTRACT'
           and org_id = l_org_id
           and request_id in (
                select req.request_id
                from fnd_concurrent_requests req,
                     fnd_concurrent_programs_vl pgm
                where pgm.USER_CONCURRENT_PROGRAM_NAME IN ( 'Master Program -- Receivables Invoice Transfer',
                                                            'Receivables Invoice Transfer to AR')
                and req.concurrent_program_id = pgm.concurrent_program_id
                and req.PHASE_CODE = 'C');

           l_print_xfer_cnt := l_print_xfer_cnt + (sql%rowcount);

           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,' => Deleted '||sql%rowcount||' row(s).');
           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));

           commit;
           fnd_file.put_line(fnd_file.log,'** END: Delete Org Specific Transfer records from OKL_PARALLEL_PROCESSES. **');
    --fmiao 5209209 change
-- rmunjulu R12 fixes -- comment out prepare recvbles
/*
    ELSIF p_source = 'AR_PREPARE' THEN
           Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));
           Fnd_File.put_line(Fnd_File.LOG,'** START: Delete all Prepare Receivables records from OKL_PARALLEL_PROCESSES. **');
           l_prep_cnt := 0;
           OPEN  cnt_csr ('Master Program -- Prepare Receivables',
                          'Prepare Receivables Bills');
           FETCH cnt_csr INTO l_prep_cnt;
           CLOSE cnt_csr;

           IF l_prep_cnt > 0 THEN
              Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));
              Fnd_File.put_line(Fnd_File.LOG,' => Could not perform a delete all for Prepare Receivables '
                                         ||'records because not all requests have Completed.');
              Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));
           ELSE
              DELETE FROM okl_parallel_processes
              WHERE OBJECT_TYPE = 'PREP_CONTRACT';

              l_print_prep_cnt := l_print_prep_cnt + (SQL%rowcount);

              Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));
              Fnd_File.put_line(Fnd_File.LOG,' => Deleted '||SQL%rowcount||' row(s).');
              Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));

              COMMIT;
           END IF;
           Fnd_File.put_line(Fnd_File.LOG,'** END: Delete all Prepare Receivables records from OKL_PARALLEL_PROCESSES. **');

           Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));
           Fnd_File.put_line(Fnd_File.LOG,'** START: Delete Org Specific Prepare Receivables records from OKL_PARALLEL_PROCESSES. **');
           DELETE FROM okl_parallel_processes
           WHERE OBJECT_TYPE = 'PREP_CONTRACT'
           AND org_id = l_org_id
           AND request_id IN (
                SELECT req.request_id
                FROM fnd_concurrent_requests req,
                     fnd_concurrent_programs_vl pgm
                WHERE pgm.USER_CONCURRENT_PROGRAM_NAME IN ( 'Master Program -- Prepare Receivables',
                                                            'Prepare Receivables Bills')
                AND req.concurrent_program_id = pgm.concurrent_program_id
                AND req.PHASE_CODE = 'C');

           l_print_prep_cnt := l_print_prep_cnt + (SQL%rowcount);

           Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));
           Fnd_File.put_line(Fnd_File.LOG,' => Deleted '||SQL%rowcount||' row(s).');
           Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));

           COMMIT;
           Fnd_File.put_line(Fnd_File.LOG,'** END: Delete Org Specific Prepare Receivables records from OKL_PARALLEL_PROCESSES. **');

           --fmiao 5209209 end
*/
    ELSIF p_source = 'ALL' THEN

           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,'** START: Delete all Stream Billing records from OKL_PARALLEL_PROCESSES. **');
           l_strm_bill_cnt := 0;
           OPEN  cnt_csr ('Master Program -- Process Billable Streams',
                          'Process Billable Streams');
           FETCH cnt_csr INTO l_strm_bill_cnt;
           CLOSE cnt_csr;

           IF l_strm_bill_cnt > 0 THEN

              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
              fnd_file.put_line(fnd_file.log,' => Could not perform a delete all for Stream Billing '
                                         ||'records because not all requests have Completed.');
              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));

           ELSE
              delete from okl_parallel_processes
              where OBJECT_TYPE = 'CONTRACT';

              l_print_strm_cnt := l_print_strm_cnt + (sql%rowcount);

              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
              fnd_file.put_line(fnd_file.log,' => Deleted '||sql%rowcount||' row(s).');
              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));

              commit;
           END IF;
           fnd_file.put_line(fnd_file.log,'** END: Delete all Stream Billing records from OKL_PARALLEL_PROCESSES. **');

           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,'** START: Delete Org specific Stream Billing records from OKL_PARALLEL_PROCESSES. **');

           delete from okl_parallel_processes
           where OBJECT_TYPE = 'CONTRACT'
           and org_id = l_org_id
           and request_id in (
                select req.request_id
                from fnd_concurrent_requests req,
                     fnd_concurrent_programs_vl pgm
                where pgm.USER_CONCURRENT_PROGRAM_NAME IN ( 'Master Program -- Process Billable Streams',
                                                            'Process Billable Streams')
                and req.concurrent_program_id = pgm.concurrent_program_id
                and req.PHASE_CODE = 'C');

           l_print_strm_cnt := l_print_strm_cnt + (sql%rowcount);

           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,' => Deleted '||sql%rowcount||' row(s).');
           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,'** END: Delete Org specific Stream Billing records from OKL_PARALLEL_PROCESSES. **');

           commit;

-- rmunjulu R12 fixes -- comment out consolidation
/*
           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,'** START: Delete all Consolidation records from OKL_PARALLEL_PROCESSES. **');
           l_cnsld_cnt := 0;
           OPEN  cnt_csr ('Master Program -- Receivables Bills Consolidation',
                          'Receivables Bills Consolidation');
           FETCH cnt_csr INTO l_cnsld_cnt;
           CLOSE cnt_csr;

           IF l_cnsld_cnt > 0 THEN
              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
              fnd_file.put_line(fnd_file.log,' => Could not perform a delete all for Consolidation '
                                         ||'records because not all requests have Completed.');
              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           ELSE
              delete from okl_parallel_processes
              where OBJECT_TYPE = 'CUSTOMER';

              l_print_cons_cnt := l_print_cons_cnt + (sql%rowcount);

              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
              fnd_file.put_line(fnd_file.log,' => Deleted '||sql%rowcount||' row(s).');
              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
              commit;
           END IF;
           fnd_file.put_line(fnd_file.log,'** END: Delete all Consolidation records from OKL_PARALLEL_PROCESSES. **');

           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,'** START: Delete Org specific Consolidation records from OKL_PARALLEL_PROCESSES. **');

           delete from okl_parallel_processes
           where OBJECT_TYPE = 'CUSTOMER'
           and org_id = l_org_id
           and request_id in (
                select req.request_id
                from fnd_concurrent_requests req,
                     fnd_concurrent_programs_vl pgm
                where pgm.USER_CONCURRENT_PROGRAM_NAME IN ( 'Master Program -- Receivables Bills Consolidation',
                                                            'Receivables Bills Consolidation')
                and req.concurrent_program_id = pgm.concurrent_program_id
                and req.PHASE_CODE = 'C');

           l_print_cons_cnt := l_print_cons_cnt + (sql%rowcount);

           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,' => Deleted '||sql%rowcount||' row(s).');
           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));

           commit;
           fnd_file.put_line(fnd_file.log,'** END: Delete Org specific Consolidation records from OKL_PARALLEL_PROCESSES. **');
*/
           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,'** START: Delete all Transfer records from OKL_PARALLEL_PROCESSES. **');

           l_xfer_cnt := 0;

           OPEN  cnt_csr ('Master Program -- Receivables Invoice Transfer',
                          'Receivables Invoice Transfer to AR');
           FETCH cnt_csr INTO l_xfer_cnt;
           CLOSE cnt_csr;

           IF l_xfer_cnt > 0 THEN
              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
              fnd_file.put_line(fnd_file.log,' => Could not perform a delete all for Transfer '
                                         ||'records because not all requests have Completed.');
              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           ELSE
              delete from okl_parallel_processes
              where OBJECT_TYPE = 'XTRX_CONTRACT';

              l_print_xfer_cnt := l_print_xfer_cnt + (sql%rowcount);

              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
              fnd_file.put_line(fnd_file.log,' => Deleted '||sql%rowcount||' row(s).');
              Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));

              commit;
           END IF;

           fnd_file.put_line(fnd_file.log,'** END: Delete all Transfer records from OKL_PARALLEL_PROCESSES. **');

           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,'** START: Delete Org Specific Transfer records from OKL_PARALLEL_PROCESSES. **');
           delete from okl_parallel_processes
           where OBJECT_TYPE = 'XTRX_CONTRACT'
           and org_id = l_org_id
           and request_id in (
                select req.request_id
                from fnd_concurrent_requests req,
                     fnd_concurrent_programs_vl pgm
                where pgm.USER_CONCURRENT_PROGRAM_NAME IN ( 'Master Program -- Receivables Invoice Transfer',
                                                            'Receivables Invoice Transfer to AR')
                and req.concurrent_program_id = pgm.concurrent_program_id
                and req.PHASE_CODE = 'C');

           l_print_xfer_cnt := l_print_xfer_cnt + (sql%rowcount);

           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));
           fnd_file.put_line(fnd_file.log,' => Deleted '||sql%rowcount||' row(s).');
           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));

           commit;

           fnd_file.put_line(fnd_file.log,'** END: Delete Org Specific Transfer records from OKL_PARALLEL_PROCESSES. **');
           Fnd_File.PUT_LINE (fnd_file.log,RPAD(' ', 132, ' '));

-- rmunjulu R12 fixes -- comment out prepare recvbles
/*
			   --fmiao 5209209 change
           Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));
           Fnd_File.put_line(Fnd_File.LOG,'** START: Delete all Prepare Receivables records from OKL_PARALLEL_PROCESSES. **');

           l_prep_cnt := 0;

           OPEN  cnt_csr ('Master Program -- Prepare Receivables',
                          'Prepare Receivables Bills');
           FETCH cnt_csr INTO l_prep_cnt;
           CLOSE cnt_csr;

           IF l_prep_cnt > 0 THEN
              Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));
              Fnd_File.put_line(Fnd_File.LOG,' => Could not perform a delete all for Prepare Receivables '
                                         ||'records because not all requests have Completed.');
              Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));
           ELSE
              DELETE FROM okl_parallel_processes
              WHERE OBJECT_TYPE = 'PREP_CONTRACT';

              l_print_prep_cnt := l_print_prep_cnt + (SQL%rowcount);

              Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));
              Fnd_File.put_line(Fnd_File.LOG,' => Deleted '||SQL%rowcount||' row(s).');
              Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));

              COMMIT;
           END IF;

           Fnd_File.put_line(Fnd_File.LOG,'** END: Delete all Prepare Receivables records from OKL_PARALLEL_PROCESSES. **');

           Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));
           Fnd_File.put_line(Fnd_File.LOG,'** START: Delete Org Specific Prepare Receivables records from OKL_PARALLEL_PROCESSES. **');
           DELETE FROM okl_parallel_processes
           WHERE OBJECT_TYPE = 'PREP_CONTRACT'
           AND org_id = l_org_id
           AND request_id IN (
                SELECT req.request_id
                FROM fnd_concurrent_requests req,
                     fnd_concurrent_programs_vl pgm
                WHERE pgm.USER_CONCURRENT_PROGRAM_NAME IN ( 'Master Program -- Prepare Receivables',
                                                            'Prepare Receivables Bills')
                AND req.concurrent_program_id = pgm.concurrent_program_id
                AND req.PHASE_CODE = 'C');

           l_print_prep_cnt := l_print_prep_cnt + (SQL%rowcount);

           Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));
           Fnd_File.put_line(Fnd_File.LOG,' => Deleted '||SQL%rowcount||' row(s).');
           Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));

           COMMIT;

           Fnd_File.put_line(Fnd_File.LOG,'** END: Delete Org Specific Prepare Receivables records from OKL_PARALLEL_PROCESSES. **');
           Fnd_File.PUT_LINE (Fnd_File.LOG,RPAD(' ', 132, ' '));
	          --fmiao 5209209 end
*/
    END IF;
  -- ------------------------
  -- Print Summary report
  -- ------------------------
    l_op_unit_name := NULL;

--for multi org
    l_op_unit_name:=I.org_name;

/*    OPEN  op_unit_csr;
    FETCH op_unit_csr INTO l_op_unit_name;
    CLOSE op_unit_csr; */ --commented for Multi Org records

    -- Start New Out File stmathew 15-OCT-2004
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 54, ' ')||'Oracle Leasing and Finance Management'||LPAD(' ', 55, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 51, ' ')||'Purge Parallel Porcesses Table'||LPAD(' ', 51, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 51, ' ')||'------------------------------'||LPAD(' ', 51, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Operating Unit: '||l_op_unit_name);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Request Id: '||l_request_id||LPAD(' ',74,' ') ||'Run Date: '||TO_CHAR(SYSDATE));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Currency: '||Okl_Accounting_Util.get_func_curr_code);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD('-', 132, '-'));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Billing Source  : ' ||p_source);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD('-', 132, '-'));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));

    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Processing Details:'||LPAD(' ', 113, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '                Number of Deleted Stream Billing Records: '||l_print_strm_cnt);
-- rmunjulu R12 Fixes - comment out consolidation
--    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '                Number of Deleted Consolidation Records : '||l_print_cons_cnt);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '                Number of Deleted AR Transfer Records   : '||l_print_xfer_cnt);
    --fmiao 5209209 change
-- rmunjulu R12 fixes -- comment out prepare recvbles
--    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '                Number of Deleted Prepare Recievables Records   : '||l_print_prep_cnt);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '                Total: '||(l_print_strm_cnt+l_print_cons_cnt+l_print_xfer_cnt+l_print_prep_cnt));
    -- fmiao 5209209 end
    --Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '                Total: '||(l_print_strm_cnt+l_print_cons_cnt+l_print_xfer_cnt));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
End Loop; --for Multi Org records

  EXCEPTION
    WHEN OTHERS THEN
       fnd_file.put_line (fnd_file.log,'Purge Program failed with error: '||SQLERRM);
  END PURGE_PARALLEL_PROCESSES;
  -- End Bug 4546873;

  -- -------------------------------------------------
  -- To print log messages
  -- -------------------------------------------------
  PROCEDURE print_to_log(p_message	IN	VARCHAR2)
  IS
  BEGIN

    if (L_DEBUG_ENABLED='Y' and fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
       fnd_log.string(fnd_log.level_statement,'okl_bill_controll',
              p_message );

    end if;

   if L_DEBUG_ENABLED = 'Y' then
     fnd_file.put_line (fnd_file.log,p_message);
     okl_debug_pub.logmessage(p_message);
   end if;

--     dbms_output.put_line(p_message);
  END print_to_log;

PROCEDURE write_to_log(
                         p_message IN VARCHAR2
                        ) IS
  BEGIN
    --dbms_output.put_line(p_message);
    fnd_file.put_line(fnd_file.output, p_message);
  END write_to_log;


  PROCEDURE Process_Spawner (
                            errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY NUMBER,
                            p_num_processes    IN NUMBER,
                            p_start_date_from  IN VARCHAR2,
                            p_start_date_to    IN VARCHAR2,
                            p_contract_number  IN VARCHAR2,
                            p_cust_acct_id     IN NUMBER,
                            p_inv_msg          IN VARCHAR2,
                            p_source           IN VARCHAR2,
-- modified by zrehman for Bug#6788005 on 01-Feb-2008 start
                            p_ia_contract_type   IN VARCHAR2,
                            p_inv_cust_acct_id        IN NUMBER
-- modified by zrehman for Bug#6788005 on 01-Feb-2008 end
                           ) IS
  request_id NUMBER := 0;

  cursor chk_update_header_csr ( p_date date, orgId VARCHAr2 ) is -- rmunjulu R12 Forward Port missing on R12 (oklh bug 4728636)
                                              -- -- bug# 5872306 (ssiruvol)
       SELECT  khr.contract_number contract_number, khr.id khr_id
       FROM    okc_k_headers_b khr,  -- rmunjulu R12 Forward Port missing on R12 (oklh bug 4728636)
               okl_k_control nbd -- rmunjulu R12 Forward Port missing on R12 (oklh bug 4728636)
       WHERE ((p_contract_number is not null and KHR.CONTRACT_NUMBER=p_contract_number)
            or (p_contract_number is null and KHR.CONTRACT_NUMBER=KHR.CONTRACT_NUMBER))
        AND ((p_cust_acct_id is not null and KHR.CUST_ACCT_ID=p_cust_acct_id)
            or (p_cust_acct_id is null and KHR.CUST_ACCT_ID=KHR.CUST_ACCT_ID))
        AND    khr.scs_code IN ('LEASE', 'LOAN')
        AND    khr.sts_code IN ( 'BOOKED','EVERGREEN','TERMINATED', 'EXPIRED')  -- Bug 6472228  added - Expired status
        AND    p_source = 'BILL_STREAMS'
        AND    khr.id = nbd.khr_id -- rmunjulu R12 Forward Port missing on R12 (oklh bug 4728636)
 -- rmunjulu R12 Forward Port missing on R12 (oklh bug 4728636) + fixes for bug 5634652 logic to check for print lead days
         AND     nbd.earliest_strm_bill_date <= (NVL(p_date, SYSDATE) +
                                                  --Bug# 7701159 - Susbtitute SQL query for PL/SQL call
                                                  NVL( NVL(
                                                  (SELECT RULE.RULE_INFORMATION3 FROM OKC_RULES_B RULE, OKC_RULE_GROUPS_B RGP
                                                  WHERE RGP.ID = RULE.RGP_ID AND RGP.DNZ_CHR_ID                 = KHR.ID
                                                  AND RGP.RGD_CODE = 'LABILL' AND RULE.RULE_INFORMATION_CATEGORY = 'LAINVD'
                                                  ),
                                                  (SELECT TERM.PRINTING_LEAD_DAYS FROM HZ_CUSTOMER_PROFILES CP,
                                                  RA_TERMS TERM where KHR.BILL_TO_SITE_USE_ID = CP.SITE_USE_ID AND CP.STANDARD_TERMS = TERM.TERM_ID)
                                                  ),0)
                                                 )

         -- OKL_STREAM_BILLING_PVT.get_printing_lead_days(khr.id)) -- Added for Bug#6794547
        AND    KHR.authoring_org_id   = NVL(TO_NUMBER(orgId),-99)
        AND    nvl(p_ia_contract_type, L_CONTRACT_TYPE) = L_CONTRACT_TYPE
	AND    NOT EXISTS
		       (SELECT '1'
			    FROM OKL_PARALLEL_PROCESSES opp
		        WHERE khr.contract_number = opp.object_value
		        AND opp.object_type = 'CONTRACT'
		        AND opp.process_status in ('PENDING_ASSIGNMENT', 'ASSIGNED'))
        --fmiao 5209209 change
-- rmunjulu R12 fixes - comment out Prepare Recvbles
/*        UNION
	--3 levels
	SELECT  khr.contract_number contract_number, khr.id khr_id
	FROM okc_k_headers_b khr
	WHERE id IN (
                SELECT  CHR.id
                FROM    okl_txd_ar_ln_dtls_b tld,
                okl_txl_ar_inv_lns_b til,
                okl_trx_ar_invoices_b tai,
				okl_strm_type_v       sty,
                okc_k_headers_b    CHR
		WHERE tai.trx_status_code = 'SUBMITTED'
		AND   tai.khr_id          = CHR.id
		AND   til.tai_id = tai.id
		AND   tld.til_id_details = til.id
		AND   sty.id = tld.sty_id
		AND    p_source = 'AR_PREPARE'
        AND    NOT EXISTS
 		       (SELECT '1'
 			    FROM OKL_PARALLEL_PROCESSES opp
 		        WHERE CHR.contract_number = opp.object_value
 		        AND opp.object_type = 'PREP_CONTRACT'
 		        AND opp.process_status IN ('PENDING_ASSIGNMENT', 'ASSIGNED')) )
        GROUP BY khr.contract_number, khr.id

		UNION
		-- 2 levels
		SELECT  khr.contract_number contract_number, khr.id khr_id
		FROM okc_k_headers_b khr
		WHERE id IN (
        SELECT  CHR.id
        FROM    okl_txl_ar_inv_lns_b til,
                okl_trx_ar_invoices_b tai,
				    okl_strm_type_v       sty,
                okc_k_headers_b    CHR
		    WHERE tai.trx_status_code = 'SUBMITTED'
		    AND   tai.khr_id          = CHR.id
		    AND   til.tai_id = tai.id
		    AND   til.sty_id = sty.id
		    AND    p_source = 'AR_PREPARE'
		    AND    NOT EXISTS
		       (SELECT *
			  	FROM okl_txd_ar_ln_dtls_b tld
			   	WHERE tld.til_id_details = til.id
			  	)
        AND    NOT EXISTS
 		       (SELECT '1'
 			    FROM OKL_PARALLEL_PROCESSES opp
 		        WHERE CHR.contract_number = opp.object_value
 		        AND opp.object_type = 'PREP_CONTRACT'
 		        AND opp.process_status IN ('PENDING_ASSIGNMENT', 'ASSIGNED')) )
        GROUP BY khr.contract_number, khr.id
		    --fmiao 5209209 end
*/
-- rmunjulu R12 Fixes modify AR Transfer
        UNION
        SELECT  khr.contract_number contract_number, khr.id khr_id
        FROM okc_k_headers_b khr
        WHERE id in (
        SELECT  TAI.khr_id -- rmunjulu R12 fixes - changed to TAI
        FROM    --okl_ext_sell_invs_b xsi, -- rmunjulu R12 fixes - commented
                --okl_xtl_sell_invs_b xls, -- rmunjulu R12 fixes - commented
                --okl_txd_ar_ln_dtls_b tld,-- rmunjulu R12 fixes - commented
                --okl_txl_ar_inv_lns_b til,-- rmunjulu R12 fixes - commented
                okl_trx_ar_invoices_b tai,
                okc_k_headers_b    chr-- rmunjulu R12 fixes - commented
        WHERE  tai.TRX_STATUS_CODE = 'SUBMITTED'  -- rmunjulu R12 fixes - changed to TAI + SUBMITTED
        --AND    XSI.ID = XLS.XSI_ID_DETAILS -- rmunjulu R12 fixes - commented
        --AND    xls.tld_id = tld.id  -- rmunjulu R12 fixes - commented
        --and    tld.til_id_details = til.id -- rmunjulu R12 fixes - commented
        --and    til.tai_id = tai.id -- rmunjulu R12 fixes - commented
        and    tai.khr_id = chr.id
        AND    p_source = 'AR_TRANSFER'
        AND    NOT EXISTS
 		       (SELECT '1'
 			    FROM OKL_PARALLEL_PROCESSES opp
 		        WHERE chr.contract_number = opp.object_value
 		        AND opp.object_type = 'XTRX_CONTRACT'
 		        AND opp.process_status in ('PENDING_ASSIGNMENT', 'ASSIGNED')) )
        group by khr.contract_number, khr.id
-- rmunjulu R12 Fixes -- below select not needed as will be same as above select
/*
        UNION
        SELECT  khr.contract_number contract_number, khr.id khr_id
        FROM okc_k_headers_b khr
        WHERE id in (
        SELECT  chr.id
        FROM    okl_ext_sell_invs_b xsi,
                okl_xtl_sell_invs_b xls,
                okl_txl_ar_inv_lns_b til,
                okl_trx_ar_invoices_b tai,
                okc_k_headers_b    chr
        WHERE  XSI.TRX_STATUS_CODE = 'WORKING'
        AND    XSI.ID = XLS.XSI_ID_DETAILS
        AND    xls.til_id = til.id
        and    til.tai_id = tai.id
        and    tai.khr_id = chr.id
        AND    p_source = 'AR_TRANSFER'
        AND    NOT EXISTS
 		       (SELECT '1'
 			    FROM OKL_PARALLEL_PROCESSES opp
 		        WHERE chr.contract_number = opp.object_value
 		        AND opp.object_type = 'XTRX_CONTRACT'
 		        AND opp.process_status in ('PENDING_ASSIGNMENT', 'ASSIGNED')) )
        group by khr.contract_number, khr.id
*/
-- rmunjulu R12 Fixes -- comment out Consolidation
/*
        UNION
        SELECT to_char(CUSTOMER_ID), null khr_id
        FROM OKL_EXT_SELL_INVS_B ext
        WHERE ext.TRX_STATUS_CODE    = 'SUBMITTED'
        AND p_source = 'CONSOLIDATION'
        AND    NOT EXISTS
		       (SELECT '1'
			    FROM OKL_PARALLEL_PROCESSES opp
		        WHERE ext.CUSTOMER_ID = to_number(opp.object_value)
		        AND opp.object_type = 'CUSTOMER'
		        AND opp.process_status in ('PENDING_ASSIGNMENT', 'ASSIGNED'));
*/
-- modified by zrehman for Bug#6788005 on 01-Feb-2008 start
        UNION
        SELECT  khr.contract_number contract_number, khr.id khr_id
        FROM    okc_k_headers_b khr,
                okl_k_control nbd,
		okc_k_lines_b cle
        WHERE ((p_contract_number is not null and KHR.CONTRACT_NUMBER=p_contract_number)
             or (p_contract_number is null and KHR.CONTRACT_NUMBER=KHR.CONTRACT_NUMBER))
         AND ((p_inv_cust_acct_id is not null and cle.CUST_ACCT_ID IS NOT NULL AND cle.CUST_ACCT_ID = p_inv_cust_acct_id )
            or (p_inv_cust_acct_id is null and cle.CUST_ACCT_ID = cle.CUST_ACCT_ID))
	 AND cle.dnz_chr_id = khr.id
	 AND khr.scs_code ='INVESTOR'
         AND khr.sts_code = 'ACTIVE'
         AND p_source = 'BILL_STREAMS'
         AND nvl(p_ia_contract_type, L_IA_TYPE) = L_IA_TYPE
	 AND khr.id = nbd.khr_id
         AND nbd.earliest_strm_bill_date <= (NVL(p_date, SYSDATE) + OKL_STREAM_BILLING_PVT.get_printing_lead_days(khr.id))
         AND KHR.authoring_org_id   = NVL(TO_NUMBER(orgId),-99)
         AND NOT EXISTS
 		       (SELECT '1'
              		FROM OKL_PARALLEL_PROCESSES opp
		        WHERE khr.contract_number = opp.object_value
		        AND opp.object_type = 'CONTRACT'
		        AND opp.process_status in ('PENDING_ASSIGNMENT', 'ASSIGNED'))
-- modified by zrehman for Bug#6788005 on 01-Feb-2008 end
;
  cursor chk_data_volume_csr(p_date_from DATE,
                             p_date_to DATE,
							 p_seq_next VARCHAR2 )  is
        SELECT
          opp.object_value CONTRACT_NUMBER,
          COUNT(STE.ID) LINE_COUNT
        FROM
          OKL_STRM_ELEMENTS STE,
          OKL_STREAMS STM,
          OKL_STRM_TYPE_V STY,
          OKL_PARALLEL_PROCESSES OPP
        WHERE
          OPP.ASSIGNED_PROCESS = p_seq_next AND
          OPP.OBJECT_TYPE =     'CONTRACT' AND
         (
            (p_date_from is not null and STE.STREAM_ELEMENT_DATE >= p_date_from)
            OR
            (p_date_from is null)
         ) AND
           STE.STREAM_ELEMENT_DATE <= (NVL(p_date_to, SYSDATE) +
                                            NVL( NVL(
                                            (SELECT RULE.RULE_INFORMATION3 FROM OKC_RULES_B RULE, OKC_RULE_GROUPS_B RGP, okc_k_headers_b khr
                                              WHERE opp.khr_id = khr.id AND RGP.ID = RULE.RGP_ID AND RGP.DNZ_CHR_ID = KHR.ID
                                                AND RGP.RGD_CODE = 'LABILL' AND RULE.RULE_INFORMATION_CATEGORY = 'LAINVD'
                                            ),
                                            (SELECT TERM.PRINTING_LEAD_DAYS FROM HZ_CUSTOMER_PROFILES CP, RA_TERMS TERM, okc_k_headers_b khr
                                              WHERE opp.khr_id = khr.id AND KHR.BILL_TO_SITE_USE_ID = CP.SITE_USE_ID AND CP.STANDARD_TERMS = TERM.TERM_ID)
                                            ),0)
                                                  --Bug# 7701159 - Susbtitute SQL query for PL//*/*SQL call
                                                  /*NVL((SELECT NVL(RULE.RULE_INFORMATION3,TERM.PRINTING_LEAD_DAYS)
                                                       FROM   OKC_RULES_B          RULE,
                                                              OKC_RULE_GROUPS_B    RGP,
                                                              HZ_CUSTOMER_PROFILES CP,
                                                              RA_TERMS             TERM
                                                               ,okc_k_headers_b khr
                                                       WHERE  opp.khr_id = khr.id and
                                                             RGP.ID         = RULE.RGP_ID
                                                          AND RGP.DNZ_CHR_ID = KHR.ID
                                                          AND RGP.RGD_CODE   = 'LABILL'
                                                          AND RULE.RULE_INFORMATION_CATEGORY = 'LAINVD'
                                                          AND KHR.BILL_TO_SITE_USE_ID        = CP.SITE_USE_ID
                                                          AND CP.STANDARD_TERMS              = TERM.TERM_ID),
                                                         0)*/
                                      ) and
--          STE.STREAM_ELEMENT_DATE <= (NVL(p_date_to, SYSDATE) + OKL_STREAM_BILLING_PVT.get_printing_lead_days(opp.khr_id))  AND -- Bug 6377127
          STE.AMOUNT <> 0 AND
          STM.ID = STE.STM_ID AND
          STE.DATE_BILLED IS NULL     AND
          STM.ACTIVE_YN = 'Y' AND
          STM.SAY_CODE = 'CURR' AND
          STY.ID = STM.STY_ID     AND
          STY.BILLABLE_YN = 'Y' AND
          opp.khr_id = STM.KHR_ID AND
          p_source =     'BILL_STREAMS'
	  GROUP BY opp.object_value
        --fmiao 5209209 change
-- rmunjulu R12 Fixes comment out Prepare Recevbles
/*
        UNION
        -- 3 levels
	SELECT
          CHR.CONTRACT_NUMBER CONTRACT_NUMBER,
          COUNT(*) LINE_COUNT
        FROM
          OKL_TXD_AR_LN_DTLS_B TLD,
          OKL_TXL_AR_INV_LNS_B TIL,
          OKL_TRX_AR_INVOICES_B TAI,
          OKC_K_HEADERS_B CHR,
		  OKL_STRM_TYPE_V       STY,
          OKL_PARALLEL_PROCESSES OPP
		WHERE tai.trx_status_code = 'SUBMITTED'
		AND   tai.khr_id          = CHR.id
		AND   til.tai_id = tai.id
		AND   tld.til_id_details = til.id
		AND   sty.id = tld.sty_id
		AND   OPP.OBJECT_VALUE =     CHR.CONTRACT_NUMBER
		AND   OPP.ASSIGNED_PROCESS = p_seq_next
		AND   OPP.OBJECT_TYPE =     'PREP_CONTRACT'
		AND   p_source = 'AR_PREPARE'
        GROUP BY CHR.CONTRACT_NUMBER
        UNION
		--2 levels
        SELECT
          CHR.CONTRACT_NUMBER     CONTRACT_NUMBER,
          COUNT(*) LINE_COUNT
        FROM
          OKL_TXL_AR_INV_LNS_B TIL,
          OKL_TRX_AR_INVOICES_B TAI,
          OKC_K_HEADERS_B CHR,
		  OKL_STRM_TYPE_V       STY,
          OKL_PARALLEL_PROCESSES OPP
		WHERE tai.trx_status_code = 'SUBMITTED'
		AND   tai.khr_id          = CHR.id
		AND   til.tai_id = tai.id
		AND   til.sty_id = sty.id
		AND   OPP.OBJECT_VALUE = CHR.CONTRACT_NUMBER
		AND	  OPP.ASSIGNED_PROCESS = p_seq_next
		AND	  OPP.OBJECT_TYPE = 'PREP_CONTRACT'
		AND	  p_source = 'AR_PREPARE'
		AND    NOT EXISTS
		       (SELECT *
			  	FROM okl_txd_ar_ln_dtls_b tld
			   	WHERE tld.til_id_details = til.id
			  	)
        GROUP BY CHR.CONTRACT_NUMBER
		--fmiao 5209209 end
*/
-- rmunjulu R12 Fixes Modify AR TRANSFER
        UNION
-- transfer 3
        SELECT
          KHR.CONTRACT_NUMBER CONTRACT_NUMBER,
          COUNT(*) LINE_COUNT
        FROM
          --OKL_EXT_SELL_INVS_B XSI, -- rmunjulu R12 fixes - commented
          --OKL_XTL_SELL_INVS_B XLS, -- rmunjulu R12 fixes - commented
          --OKL_TXD_AR_LN_DTLS_B TLD, -- rmunjulu R12 fixes - commented
          --OKL_TXL_AR_INV_LNS_B TIL, -- rmunjulu R12 fixes - commented
          OKL_TRX_AR_INVOICES_B TAI,
          OKC_K_HEADERS_B KHR,
          OKL_PARALLEL_PROCESSES OPP
        WHERE
          TAI.TRX_STATUS_CODE = 'SUBMITTED' AND -- rmunjulu R12 fixes - changed to TAI and SUBMITTED
          --XSI.ID =     XLS.XSI_ID_DETAILS AND -- rmunjulu R12 fixes - commented
          --XLS.TLD_ID = TLD.ID AND -- rmunjulu R12 fixes - commented
          --TLD.TIL_ID_DETAILS = TIL.ID     AND -- rmunjulu R12 fixes - commented
          --TIL.TAI_ID = TAI.ID AND -- rmunjulu R12 fixes - commented
          TAI.KHR_ID = KHR.ID AND
          OPP.OBJECT_VALUE =     KHR.CONTRACT_NUMBER AND
          OPP.ASSIGNED_PROCESS = p_seq_next AND
          OPP.OBJECT_TYPE =     'XTRX_CONTRACT' AND
          p_source = 'AR_TRANSFER'
        GROUP BY KHR.CONTRACT_NUMBER
/* -- rmunjulu R12 Fixes -- below select not needed as will be same as above select
        UNION
-- transfer 2
        SELECT
          KHR.CONTRACT_NUMBER     CONTRACT_NUMBER,
          COUNT(*) LINE_COUNT
        FROM
          OKL_EXT_SELL_INVS_V XSI,
          OKL_XTL_SELL_INVS_V XLS,
          OKL_TXL_AR_INV_LNS_V TIL,
          OKL_TRX_AR_INVOICES_V TAI,
          OKC_K_HEADERS_B KHR,
          OKL_PARALLEL_PROCESSES OPP
        WHERE
          XSI.TRX_STATUS_CODE = 'WORKING' AND
          XSI.ID = XLS.XSI_ID_DETAILS AND
          XLS.TIL_ID = TIL.ID AND
          TIL.TAI_ID = TAI.ID     AND
          TAI.KHR_ID = KHR.ID AND
          OPP.OBJECT_VALUE = KHR.CONTRACT_NUMBER AND
          OPP.ASSIGNED_PROCESS = p_seq_next AND
          OPP.OBJECT_TYPE = 'XTRX_CONTRACT' AND
          p_source = 'AR_TRANSFER'
        GROUP BY KHR.CONTRACT_NUMBER

        UNION
*/
-- consolidation
/* -- rmunjulu -- comment out consolidation
        SELECT
          TO_CHAR(CUSTOMER_ID) CONTRACT_NUMBER,
          COUNT(*)
        FROM
          OKL_EXT_SELL_INVS_B EXT,
          OKL_PARALLEL_PROCESSES OPP
        WHERE
          EXT.TRX_STATUS_CODE = 'SUBMITTED' AND
          OPP.OBJECT_VALUE = EXT.CUSTOMER_ID AND
          OPP.ASSIGNED_PROCESS =  p_seq_next AND
          OPP.OBJECT_TYPE = 'CUSTOMER' AND
          p_source = 'CONSOLIDATION'
        GROUP BY CUSTOMER_ID;
*/
;
  type l_contract_rec is
    record (batch_number     VARCHAR2(60),
	        contract_number  VARCHAR2(60),
			line_count       NUMBER,
            worker_number    NUMBER,
			khr_id           NUMBER);

  type contract_tab is table of l_contract_rec index by PLS_INTEGER;

  type worker_load_rec is
    record (worker_number    NUMBER,
	        worker_load      NUMBER);

  type worker_load_tab IS TABLE OF worker_load_rec index by PLS_INTEGER;

  type contract_list is
    record (contract_number  VARCHAR2(60));

  type contract_list_tab is table of contract_list index by PLS_INTEGER;

  l_contract_list     contract_list_tab;
  l_worker_load       worker_load_tab;

  l_contract_tab      contract_tab;
  l_sort_tab1         contract_tab;
  l_temp_tab          contract_tab;

  l_int_counter       INTEGER;
  l_max_lines         NUMBER;
  l_init_loop         BOOLEAN := TRUE;
  l_sort_int_counter  INTEGER;
  l_next_highest_val  NUMBER;
  l_lightest_worker   NUMBER;
  l_lightest_load     NUMBER;
  l_seq_next          NUMBER;
  l_data_found        BOOLEAN := FALSE;
  lp_date_from        DATE;
  lp_date_to          DATE;
  l_req_data          VARCHAR2(10);
  l_req_counter       NUMBER;

  -- Bug 4546873
  -- Org Id and standard who columns
  l_last_updated_by     okl_parallel_processes.last_updated_by%TYPE := Fnd_Global.USER_ID;
  l_last_update_login   okl_parallel_processes.last_update_login%TYPE := Fnd_Global.LOGIN_ID;
  l_request_id          okl_parallel_processes.request_id%TYPE := Fnd_Global.CONC_REQUEST_ID;
  l_program_id          okl_parallel_processes.program_id%TYPE := Fnd_Global.CONC_PROGRAM_ID;
  l_org_id              okl_parallel_processes.org_id%type;

  --
  cursor parent_sts_csr(p_request_id NUMBER) IS
	--start modified abhsaxen for performance SQLID 20562749
	select count(*)
		from fnd_concurrent_requests req,
		     fnd_concurrent_programs pgm
		where req.PRIORITY_REQUEST_ID = p_request_id
		and req.concurrent_program_id = pgm.concurrent_program_id
		and req.PHASE_CODE = 'C'
		and request_id <> p_request_id
		and STATUS_CODE = 'E'
	--end modified abhsaxen for performance SQLID 20562749
	;
  l_child_in_error       NUMBER;
  -- End Bug 4546873


  -- Start Bug 4581177;
  cursor parent_warn_sts_csr(p_request_id NUMBER) IS
--start modified abhsaxen for performance SQLID 20562754
	select count(*)
        from fnd_concurrent_requests req,
             fnd_concurrent_programs pgm
        where req.priority_request_id = p_request_id
        and req.concurrent_program_id = pgm.concurrent_program_id
        and req.phase_code = 'C'
        and request_id <> p_request_id
        and status_code = 'G'
--end modified abhsaxen for performance SQLID 20562754
	;
  l_child_in_warn       NUMBER;
  -- End Bug 4581177;
  orgId VARCHAr2(200);

  cursor check_contract_type(p_contract_number VARCHAR2) IS
        select decode(chr.scs_code, 'INVESTOR', 'IA', 'LEASE', 'C', null)
	from
	okc_k_headers_all_b chr
	,okl_k_headers khr
	where chr.id = khr.id
	and chr.scs_code in ('INVESTOR', 'LEASE')
	and chr.contract_number = p_contract_number;

l_contr_type VARCHAR2(3);

begin

  -- MDokal
  -- 10-May-2005
  -- The following block has been added to control the sub-request program
  -- submission. It ensures that this program is not executed recurrsively.
  l_req_data := fnd_conc_global.request_data;
  -- If l_req_data has a value within this session, the program is attempting to
  -- run again, therefore break out of the loop.

  -- Start  Bug 4546873
  if l_req_data is not null then
    write_to_log('## 1 : '||l_req_data);
    l_child_in_error := 0;
    OPEN  parent_sts_csr( l_request_id );
    FETCH parent_sts_csr INTO l_child_in_error;
    CLOSE parent_sts_csr;

    l_child_in_warn := 0;
    OPEN  parent_warn_sts_csr( l_request_id );
    FETCH parent_warn_sts_csr INTO l_child_in_warn;
    CLOSE parent_warn_sts_csr;


    if l_child_in_error > 0 then
        errbuf := 'Done, but with error!';
        retcode := 2;
        return;
    end if;

    if l_child_in_warn > 0 then
        errbuf := 'Done, but with warning(s)!';
        retcode := 1;
        return;
    end if;

    errbuf := 'Done!';
    retcode := 0;
    return;

  end if;
  -- End Bug 4546873

  -- MDokal
  -- 10-May-2005
  -- If p_num_processes is 0 or 1 then no need to go through the algorithm.
  if nvl(p_num_processes,0) = 0 then
    write_to_log('No workers specified');
    return;
  end if;

/* MDOKAL  28-JUL-2005
  if p_num_processes = 1 and p_source = 'BILL_STREAMS' then
        request_id := FND_REQUEST.SUBMIT_REQUEST(
                          application => 'OKL',
                          program => 'OKL_STREAM_BILLING',
                          sub_request => FALSE,
                          argument1   => p_start_date_from,
                          argument2   => p_start_date_to,
                          argument3   => p_contract_number,
                          argument4   => p_cust_acct_id,
                          argument5   => NULL
                         );
	if (request_id = 0) then
      errbuf := fnd_message.get;
      retcode := 2;
    end if;
	return;
  end if;
*/
-- modified by zrehman for Bug#6788005 on 01-Feb-2008 start
-- put validations for Investor Agreement Number or Contract number depending on Contract/Investor Agreement type
IF p_ia_contract_type IS NOT NULL THEN
   IF p_contract_number IS NOT NULL THEN
     OPEN check_contract_type(p_contract_number);
     FETCH check_contract_type INTO l_contr_type;
     CLOSE check_contract_type;
     IF p_ia_contract_type = 'CONTRACT' AND l_contr_type IS NOT NULL AND l_contr_type = 'IA' THEN
         write_to_log('Please enter valid Contract Number');
         return;
     ELSIF p_ia_contract_type = 'IA' AND l_contr_type IS NOT NULL AND l_contr_type = 'C' THEN
         write_to_log('Please enter valid Investor Agreement Number');
         return;
     ELSIF l_contr_type IS NULL THEN
         write_to_log('Please enter valid Contract or Investor Agreement Number');
         return;
     END IF;
   END IF;
END IF;
-- modified by zrehman for Bug#6788005 on 01-Feb-2008 end
  lp_date_from := FND_DATE.CANONICAL_TO_DATE(p_start_date_from);
  lp_date_to   := FND_DATE.CANONICAL_TO_DATE(p_start_date_to);

  -- Start Bug 4520466
  if lp_date_to is null then
     lp_date_to := sysdate;
  end if;
  -- End Bug 4520466

  l_int_counter := 0;
  l_max_lines   := 0;

  -- Select sequence for marking processes
  select okl_opp_seq.nextval
  into l_seq_next
  from dual ;

  -- Bug 4546873
  g_opp_seq_num := to_char(l_seq_next);
  -- End Bug 4546873

  WRITE_TO_LOG('p_source: '||p_source);
  WRITE_TO_LOG('p_seq: '||l_seq_next);

  -- mark records for processing

  --dbms_application_info.READ_CLIENT_INFO(orgId); -- -- bug# 5872306 (ssiruvol)
  orgId := mo_global.get_current_org_id();
  for chk_update_header_csr_rec in chk_update_header_csr (lp_date_to, orgId) loop -- rmunjulu R12 Forward Port missing on R12 (oklh bug 4728636)

    INSERT INTO OKL_PARALLEL_PROCESSES
    (
     object_type, object_value, assigned_process, process_status, start_date, khr_id,
     ORG_ID,CREATED_BY,CREATION_DATE,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN,
     REQUEST_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE
    )
    VALUES
    (decode (p_source,'BILL_STREAMS','CONTRACT',
             'AR_TRANSFER','XTRX_CONTRACT',
             'CONSOLIDATION','CUSTOMER',
             --fmiao 5209209 change
	     'AR_PREPARE','PREP_CONTRACT',NULL), -- fmiao 5209209 end
     chk_update_header_csr_rec.contract_number, to_char(l_seq_next),'PENDING_ASSIGNMENT', sysdate, chk_update_header_csr_rec.khr_id,
     l_org_id,l_last_updated_by,sysdate,sysdate,l_last_updated_by,l_last_update_login,
     l_request_id,l_program_id,sysdate
    );
    COMMIT;

    l_data_found := TRUE;
  end loop;

  if l_data_found then

    -- Start Bug 4520466
    if ( p_source = 'BILL_STREAMS' ) then

        -- Set initial volume
        update okl_parallel_processes opp
        set volume =  (select count(*)
                       from okc_k_lines_b chl
                       where chl.dnz_chr_id = opp.khr_id)
        WHERE OPP.ASSIGNED_PROCESS = TO_CHAR(l_seq_next); -- bug# 5872306 (ssiruvol)
        commit;

        -- update volume with number of months
        update okl_parallel_processes opp
        -- set volume = volume* (select ceil((lp_date_to - nbd.earliest_strm_bill_date)/30) -- rmunjulu R12 Forward Port bug 5634652
        SET volume = volume* (SELECT CEIL((lp_date_to
-- rmunjulu R12 Forward Port bug 5634652 logic to check print lead days
                                      +
                                      NVL( NVL(
                                      (SELECT RULE.RULE_INFORMATION3 FROM OKC_RULES_B RULE, OKC_RULE_GROUPS_B RGP, okc_k_headers_b khr
                                        WHERE opp.khr_id = khr.id AND RGP.ID = RULE.RGP_ID AND RGP.DNZ_CHR_ID = KHR.ID
                                          AND RGP.RGD_CODE = 'LABILL' AND RULE.RULE_INFORMATION_CATEGORY = 'LAINVD'
                                      ),
                                      (SELECT TERM.PRINTING_LEAD_DAYS FROM HZ_CUSTOMER_PROFILES CP, RA_TERMS TERM, okc_k_headers_b khr
                                        WHERE opp.khr_id = khr.id AND KHR.BILL_TO_SITE_USE_ID = CP.SITE_USE_ID AND CP.STANDARD_TERMS = TERM.TERM_ID)
                                      ),0)
                                       --Bug# 7701159   - Susbtitute SQL query for PL/SQL call
                                       /*NVL((SELECT NVL(RULE.RULE_INFORMATION3,TERM.PRINTING_LEAD_DAYS)
                                                       FROM   OKC_RULES_B          RULE,
                                                              OKC_RULE_GROUPS_B    RGP,
                                                              HZ_CUSTOMER_PROFILES CP,
                                                              RA_TERMS             TERM
                                                               ,okc_k_headers_b khr
                                                       WHERE  opp.khr_id = khr.id and
                                                             RGP.ID         = RULE.RGP_ID
                                                          AND RGP.DNZ_CHR_ID = KHR.ID
                                                          AND RGP.RGD_CODE   = 'LABILL'
                                                          AND RULE.RULE_INFORMATION_CATEGORY = 'LAINVD'
                                                          AND KHR.BILL_TO_SITE_USE_ID        = CP.SITE_USE_ID
                                                          AND CP.STANDARD_TERMS              = TERM.TERM_ID),
                                                         0)*/
--                                + OKL_STREAM_BILLING_PVT.get_printing_lead_days(opp.khr_id)
-- rmunjulu R12 Forward Port bug 5710903 Add ONE to account for scenario where these dates are same
                                - nbd.earliest_strm_bill_date + 1)/30)
                              from okl_k_control nbd
                              where nbd.khr_id = opp.khr_id)

        WHERE OPP.ASSIGNED_PROCESS = TO_CHAR(l_seq_next); -- bug# 5872306 (ssiruvol)
        commit;

    end if;
    -- End Bug 4520466

    for chk_data_volume_csr_rec in chk_data_volume_csr(lp_date_from, lp_date_to, l_seq_next) loop


      l_int_counter := l_int_counter + 1;

      if l_init_loop then -- initialize minimum and maximum lines
        l_init_loop := FALSE;
        l_max_lines := chk_data_volume_csr_rec.line_count;
      end if;

      l_contract_tab(l_int_counter).contract_number := chk_data_volume_csr_rec.contract_number;
      l_contract_tab(l_int_counter).line_count := chk_data_volume_csr_rec.line_count;
      if chk_data_volume_csr_rec.line_count > l_max_lines then
        l_max_lines := chk_data_volume_csr_rec.line_count;
      end if;
    end loop;

    -- reset, ready for use again
    l_init_loop := TRUE;

    if l_int_counter = 0 then
      write_to_log('No Data Found for criteria passed ');
    end if;

    -- find the maximum line count from the original table and delete it
    -- put this as the first element of the new sorted table
    l_sort_int_counter := 0;
    for i in 1..l_int_counter loop
      if l_contract_tab(i).line_count = l_max_lines then
        l_sort_int_counter := l_sort_int_counter+1;
        l_sort_tab1(l_sort_int_counter).contract_number := l_contract_tab(i).contract_number;
        l_sort_tab1(l_sort_int_counter).line_count := l_contract_tab(i).line_count;
        l_contract_tab.DELETE(i);
      end if;
    end loop;

    -- start sorting
    if l_contract_tab.FIRST is not null then

      for i in 1..l_contract_tab.COUNT loop
        -- find the next highest value in original table
        for i in 1..l_contract_tab.LAST loop
          if l_init_loop  then
            if l_contract_tab.EXISTS(i) then
              l_next_highest_val := l_contract_tab(i).line_count;
              l_init_loop := FALSE;
            end if;
          end if;
          if l_contract_tab.EXISTS(i) and l_contract_tab(i).line_count > l_next_highest_val then
           l_next_highest_val := l_contract_tab(i).line_count;
          end if;
        end loop;

        -- reset flag, ready for use again
        l_init_loop := TRUE;
        -- continue populating sort table in order
        for i in 1..l_contract_tab.LAST loop
          if l_contract_tab.EXISTS(i) and l_contract_tab(i).line_count = l_next_highest_val then
            l_sort_int_counter := l_sort_int_counter+1;
            l_sort_tab1(l_sort_int_counter).contract_number := l_contract_tab(i).contract_number;
            l_sort_tab1(l_sort_int_counter).line_count := l_contract_tab(i).line_count;
            l_contract_tab.DELETE(i);
          end if;
        end loop;
        exit when l_contract_tab.LAST is null;
      end loop;
    end if; -- end sorting

    -- begin processing load for workers
    for i in 1..p_num_processes loop -- put all workers into a table
      l_worker_load(i).worker_number := i;
      l_worker_load(i).worker_load := 0; -- initialize load with zero
    end loop;

    if p_num_processes > 0 then

      l_lightest_worker := 1;
      -- loop through the sorted table and ensure each contract has a worker
      for i in 1..l_sort_tab1.COUNT loop
        l_sort_tab1(i).worker_number := l_lightest_worker;
        -- put current contract into the lightest worker
        if l_worker_load.EXISTS(l_lightest_worker) then
          l_worker_load(l_lightest_worker).worker_load := l_worker_load(l_lightest_worker).worker_load + l_sort_tab1(i).line_count;
        end if;
        -- default the lighest load with the first element as a starting point
        if l_worker_load.EXISTS(1) then
          l_lightest_load := l_worker_load(1).worker_load;
          l_lightest_worker := l_worker_load(1).worker_number;
          -- logic to find lightest load
          for i in 1..l_worker_load.COUNT loop
            if (l_worker_load(i).worker_load = 0) or (l_worker_load(i).worker_load < l_lightest_load) then
              l_lightest_load   := l_worker_load(i).worker_load;
              l_lightest_worker := l_worker_load(i).worker_number;
            end if;
          end loop;
        end if;
      end loop;
    end if;


    l_sort_int_counter := 0;

    for j in l_worker_load.FIRST..l_worker_load.LAST loop
      if l_sort_tab1.count > 0 THEN
        for i in l_sort_tab1.FIRST..l_sort_tab1.LAST loop
          if l_sort_tab1.EXISTS(i) and(l_sort_tab1(i).worker_number = l_worker_load(j).worker_number )then

           IF p_source = 'BILL_STREAMS' THEN

              UPDATE OKL_PARALLEL_PROCESSES
              SET
  		      assigned_process =  l_seq_next||'-'||l_sort_tab1(i).worker_number,
                volume = l_sort_tab1(i).line_count,
                process_status = 'ASSIGNED'
              WHERE object_Type = 'CONTRACT'
              AND   object_value = l_sort_tab1(i).contract_number
              AND   process_status = 'PENDING_ASSIGNMENT';
           --fmiao 5209209 change
-- rmunjulu R12 Fixes - comment out PRepare recvbles
/*
           ELSIF p_source = 'AR_PREPARE' THEN

              UPDATE OKL_PARALLEL_PROCESSES
              SET
  		      assigned_process =  l_seq_next||'-'||l_sort_tab1(i).worker_number,
                volume = l_sort_tab1(i).line_count,
                process_status = 'ASSIGNED'
              WHERE object_Type = 'PREP_CONTRACT'
              AND   object_value = l_sort_tab1(i).contract_number
              AND   process_status = 'PENDING_ASSIGNMENT';
           -- fmiao 5209209 end
*/
           ELSIF p_source = 'AR_TRANSFER' THEN

              UPDATE OKL_PARALLEL_PROCESSES
              SET
  		      assigned_process =  l_seq_next||'-'||l_sort_tab1(i).worker_number,
                volume = l_sort_tab1(i).line_count,
                process_status = 'ASSIGNED'
              WHERE object_Type = 'XTRX_CONTRACT'
              AND   object_value = l_sort_tab1(i).contract_number
              AND   process_status = 'PENDING_ASSIGNMENT';
-- rmunjulu R12 Fixes comment out consolidation
/*
           ELSIF p_source = 'CONSOLIDATION' THEN

              UPDATE OKL_PARALLEL_PROCESSES
              SET
  		      assigned_process =  l_seq_next||'-'||l_sort_tab1(i).worker_number,
                volume = l_sort_tab1(i).line_count,
                process_status = 'ASSIGNED'
              WHERE object_Type = 'CUSTOMER'
              AND   object_value = l_sort_tab1(i).contract_number
              AND   process_status = 'PENDING_ASSIGNMENT';
*/
           ELSE
              NULL;
           END IF;


            COMMIT;
            l_sort_tab1.DELETE(i);
          end if;
        end loop;   -- Sort Tab Loop
      end if; -- Sort tab count check
    end loop; -- Worker Tab Loop

    for j in l_worker_load.FIRST..l_worker_load.LAST loop

      -- MDokal
      -- 28-Jul-2005
      -- Do not spawn a worker if theres no data to process
      -- This occurs if more workers are requested and the
      -- distribution of data does not utilize them all
      IF l_worker_load(j).worker_load > 0 THEN

        IF p_source = 'BILL_STREAMS' THEN

        -- MDokal
        -- 10-May-2005
        -- Default processing for managing sub-requests, starts here
        l_req_data := fnd_conc_global.request_data;
        if (l_req_data is not null) then
          l_req_counter := l_req_counter + to_number(l_req_data);
        else
          l_req_counter := 1;
        end if;

        if l_req_counter < (p_num_processes+1) then
          FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
          request_id := FND_REQUEST.SUBMIT_REQUEST(
                          application => 'OKL',
                          program => 'OKL_STREAM_BILLING',
                          sub_request => TRUE,
                          argument1   => p_ia_contract_type,
			  argument2   => p_start_date_from,
                          argument3   => p_start_date_to,
                          argument4   => p_contract_number,
                          argument5   => p_cust_acct_id,
 -- modified by zrehman for Bug#6788005 on 01-Feb-2008 start
			  argument6   => p_inv_cust_acct_id,
-- modified by zrehman for Bug#6788005 on 01-Feb-2008 end
                          argument7   => l_seq_next||'-'||j
                         );

          write_to_log('Launching Process '||l_seq_next||'-'||j ||' with Request ID '||request_id);

          if (request_id = 0) then
             -- If request submission failed, exit with error
             errbuf := fnd_message.get;
             retcode := 2;
          else
             -- Set the globals to put the master into PAUSED mode
             fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                     request_data => to_char(1));
             errbuf := 'Sub-Request submitted!';
             retcode := 0;
          end if;
        end if;
        -- MDokal
        -- 10-May-2005
        -- Default processing for managing sub-requests, ends here
        --fmiao 5209209 change

-- rmunjulu R12 Fixes comment out Prepare Recvbles
/*
        ELSIF p_source = 'AR_PREPARE' THEN

           l_req_data := Fnd_Conc_Global.request_data;
           IF (l_req_data IS NOT NULL) THEN
             l_req_counter := l_req_counter + TO_NUMBER(l_req_data);
           ELSE
             l_req_counter := 1;
           END IF;


           IF l_req_counter < (p_num_processes+1) THEN
             FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
             request_id := Fnd_Request.SUBMIT_REQUEST(
                             application => 'OKL',
                             program => 'OKL_INTERNAL_TO_EXTERNAL',
                             sub_request => TRUE,
                             argument1   => p_contract_number,
                             argument2   => l_seq_next||'-'||j
                            );

             IF (request_id = 0) THEN
                -- If request submission failed, exit with error
                errbuf := Fnd_Message.get;
                retcode := 2;
             ELSE
                -- Set the globals to put the master into PAUSED mode
                Fnd_Conc_Global.set_req_globals(conc_status => 'PAUSED',
                                        request_data => TO_CHAR(1));
                errbuf := 'Sub-Request submitted!';
                retcode := 0;
             END IF;
           END IF;
           --fmiao 5209209 end
*/
     ELSIF p_source = 'AR_TRANSFER' THEN

        -- MDokal
        -- 10-May-2005
        -- Default processing for managing sub-requests, starts here
        l_req_data := fnd_conc_global.request_data;
        if (l_req_data is not null) then
          l_req_counter := l_req_counter + to_number(l_req_data);
        else
          l_req_counter := 1;
        end if;

        if l_req_counter < (p_num_processes+1) then
          FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
          request_id := FND_REQUEST.SUBMIT_REQUEST(
                          application => 'OKL',
                          program => 'OKL_ARINTF',
                          sub_request => TRUE,
                          argument1   => NULL,
                          argument2   => NULL,
                          argument3   => l_seq_next||'-'||j
                         );

          write_to_log('Launching Process '||l_seq_next||'-'||j ||' with Request ID '||request_id);

          if (request_id = 0) then
             -- If request submission failed, exit with error
             errbuf := fnd_message.get;
             retcode := 2;
          else
             -- Set the globals to put the master into PAUSED mode
             fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                     request_data => to_char(1));
             errbuf := 'Sub-Request submitted!';
             retcode := 0;
          end if;
        end if;
        -- MDokal
        -- 10-May-2005
        -- Default processing for managing sub-requests, ends here
-- rmunjulu R12 Fixes comment out consolidation
/*
     ELSIF p_source = 'CONSOLIDATION' THEN

        -- MDokal
        -- 10-May-2005
        -- Default processing for managing sub-requests, starts here
        l_req_data := fnd_conc_global.request_data;
        if (l_req_data is not null) then
          l_req_counter := l_req_counter + to_number(l_req_data);
        else
          l_req_counter := 1;
        end if;

        if l_req_counter < (p_num_processes+1) then
          FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
          request_id := FND_REQUEST.SUBMIT_REQUEST(
                          application => 'OKL',
                          program => 'OKL_CONS_BILL',
                          sub_request => TRUE,
                          argument1   => p_inv_msg,
                          argument2   => l_seq_next||'-'||j
                         );

          write_to_log('Launching Process '||l_seq_next||'-'||j ||' with Request ID '||request_id);

          if (request_id = 0) then
             -- If request submission failed, exit with error
             errbuf := fnd_message.get;
             retcode := 2;
          else
             -- Set the globals to put the master into PAUSED mode
             fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                     request_data => to_char(1));
             errbuf := 'Sub-Request submitted!';
             retcode := 0;
          end if;
        end if;
            -- MDokal
            -- 10-May-2005
            -- Default processing for managing sub-requests, ends here
*/
        ELSE
            NULL;
        END IF;
      END IF; -- check worker load before spwaning
    end loop;

  else
    write_to_log('No workers assigned due to no data found for prcocesing');
  end if; -- l_data_found

    -- clean up
    -- Delete records from in chk_update_header_csr that were unassigned
    DELETE OKL_PARALLEL_PROCESSES
    WHERE process_status = 'PENDING_ASSIGNMENT'
    AND assigned_process =  to_char(l_seq_next);

    -- Start Bug 4520466
    commit;

    DELETE OKL_PARALLEL_PROCESSES
    WHERE volume = 0
    AND assigned_process like  to_char(l_seq_next)||'%';
    -- End Bug 4520466

    COMMIT;

  exception
  when others then
    write_to_log('Unhandled Exception '||sqlerrm);

    DELETE OKL_PARALLEL_PROCESSES
    WHERE assigned_process =  to_char(l_seq_next);
    COMMIT;

END Process_Spawner;

PROCEDURE BILL_STREAMS_MASTER (
                            errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY NUMBER,
                            p_ia_contract_type   IN VARCHAR2,
			    p_start_date_from  IN VARCHAR2,
                            p_start_date_to    IN VARCHAR2,
                            p_contract_number  IN VARCHAR2,
                            p_cust_acct_id     IN NUMBER,
                            p_inv_cust_acct_id        IN NUMBER,
			    p_num_processes    IN NUMBER
                           )
IS

BEGIN
        WRITE_TO_LOG('p_num_processes: '||p_num_processes);
        WRITE_TO_LOG('p_start_date_from: '||p_start_date_from);
        WRITE_TO_LOG('p_start_date_to: '||p_start_date_to);
        WRITE_TO_LOG('p_cust_acct_id: '||p_cust_acct_id);

        Process_Spawner (
                      errbuf             => errbuf,
                      retcode            => retcode,
                      p_num_processes    => NVL(p_num_processes,1),
                      p_start_date_from  => p_start_date_from,
                      p_start_date_to    => p_start_date_to,
                      p_contract_number  => p_contract_number,
                      p_cust_acct_id     => p_cust_acct_id,
                      p_source           => 'BILL_STREAMS',
		      p_ia_contract_type => p_ia_contract_type,
                      p_inv_cust_acct_id      => p_inv_cust_acct_id);
EXCEPTION
  WHEN OTHERS THEN
    WRITE_TO_LOG('UNHANDLED EXCEPTION '||SQLERRM);

    DELETE OKL_PARALLEL_PROCESSES
    WHERE assigned_process =  to_char(g_opp_seq_num);
    COMMIT;

END BILL_STREAMS_MASTER;

PROCEDURE AR_TRANSFER_MASTER (
                            errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY NUMBER,
                            p_start_date_from  IN VARCHAR2,
                            p_start_date_to    IN VARCHAR2,
                            p_num_processes    IN NUMBER
                           )
IS

BEGIN

        Process_Spawner (
                      errbuf             => errbuf,
                      retcode            => retcode,
                      p_num_processes    => NVL(p_num_processes,1),
                      p_start_date_from  => p_start_date_from,
                      p_start_date_to    => p_start_date_to,
                      p_cust_acct_id     => NULL,
                      p_source           => 'AR_TRANSFER',
		      p_ia_contract_type => NULL,
                      p_inv_cust_acct_id      => NULL);
EXCEPTION
  WHEN OTHERS THEN
    WRITE_TO_LOG('UNHANDLED EXCEPTION '||SQLERRM);

    DELETE OKL_PARALLEL_PROCESSES
    WHERE assigned_process =  to_char(g_opp_seq_num);
    COMMIT;

END AR_TRANSFER_MASTER;



PROCEDURE OKL_CONS_MASTER ( errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY NUMBER,
                            p_inv_msg          IN VARCHAR2,
                            p_num_processes    IN NUMBER
                           )
IS

BEGIN
/* -- rmunjulu R12 Fixes -- comment out consolidation
        Process_Spawner (
                      errbuf             => errbuf,
                      retcode            => retcode,
                      p_num_processes    => NVL(p_num_processes,1),
                      p_inv_msg          => p_inv_msg,
                      p_source           => 'CONSOLIDATION');
*/
NULL; -- rmunjulu R12 Fixes
EXCEPTION
  WHEN OTHERS THEN
    WRITE_TO_LOG('UNHANDLED EXCEPTION '||SQLERRM);

    DELETE OKL_PARALLEL_PROCESSES
    WHERE assigned_process =  to_char(g_opp_seq_num);
    COMMIT;

END OKL_CONS_MASTER;

--fmiao  5209209 change
PROCEDURE PREPARE_RECEIVABLES_MASTER (
                            errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY NUMBER,
                            p_num_processes    IN NUMBER
                           )
IS

BEGIN
-- rmunjulu R12 Fixes -- comment out Prepare Recvbles
/*
        WRITE_TO_LOG('p_num_processes: '||p_num_processes);

        Process_Spawner (
                      errbuf             => errbuf,
                      retcode            => retcode,
                      p_num_processes    => NVL(p_num_processes,1),
                      p_source           => 'AR_PREPARE');
*/
NULL;  -- rmunjulu R12 Fixes, added
EXCEPTION
  WHEN OTHERS THEN
    WRITE_TO_LOG('UNHANDLED EXCEPTION '||SQLERRM);

    DELETE OKL_PARALLEL_PROCESSES
    WHERE assigned_process =  TO_CHAR(g_opp_seq_num);
    COMMIT;

END PREPARE_RECEIVABLES_MASTER;

--fmiao 5209209 change end

PROCEDURE process_break(
           p_contract_number    IN  VARCHAR2,
           p_commit             IN  VARCHAR2,
           saved_bill_rec       IN OUT NOCOPY saved_bill_rec_type,
           l_update_tbl         IN OUT NOCOPY update_tbl_type)
IS

    l_old_cnr_id                NUMBER;
    l_old_lln_id                NUMBER;
    l_cnr_amount                okl_cnsld_ar_hdrs_v.amount%TYPE;
    l_lln_amount                okl_cnsld_ar_lines_v.amount%TYPE;

BEGIN

-- rmunjulu R12 Fixes -- comment out entire code and put NULL
NULL;
/*
    IF (L_DEBUG_ENABLED='Y' and FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'okl_cons_bill'
									,'Process_Break Begin(+)');
    END IF;

   -- ------------------------------------
   -- Start header break detection logic
   -- ------------------------------------

   -- If there was no error processing any records then
   IF l_update_tbl.COUNT > 0 THEN
      IF saved_bill_rec.l_overall_status IS NULL THEN
         l_old_cnr_id := -9;
         --PRINT_TO_LOG( 'Updating Consolidated Invoice Header');
         -- PRINT_TO_LOG( 'Done updating Consolidated Invoice Line');

         PRINT_TO_LOG( 'Updating External Transaction Header');
         FOR m in l_update_tbl.FIRST..l_update_tbl.LAST LOOP

            PRINT_TO_LOG( 'l_update_tbl.cnr_id '||l_update_tbl(m).cnr_id);
            PRINT_TO_LOG( 'l_update_tbl.cons_inv_number '||l_update_tbl(m).cons_inv_number);
            PRINT_TO_LOG( 'l_update_tbl.lln_id '||l_update_tbl(m).lln_id);
            PRINT_TO_LOG( 'l_update_tbl.lsm_id '||l_update_tbl(m).lsm_id);
            PRINT_TO_LOG( 'l_update_tbl.asset_number '||l_update_tbl(m).asset_number);
            PRINT_TO_LOG( 'l_update_tbl.invoice_format '||l_update_tbl(m).invoice_format);
            PRINT_TO_LOG( 'l_update_tbl.line_type '||l_update_tbl(m).line_type);
            PRINT_TO_LOG( 'l_update_tbl.sty_name '||l_update_tbl(m).sty_name);
            PRINT_TO_LOG( 'l_update_tbl.contract_number '||l_update_tbl(m).contract_number);
            PRINT_TO_LOG( 'l_update_tbl.lsm_amount '||l_update_tbl(m).lsm_amount);
            PRINT_TO_LOG( 'l_update_tbl.xsi_id '||l_update_tbl(m).xsi_id);
            PRINT_TO_LOG( 'l_update_tbl.xls_id '||l_update_tbl(m).xls_id);

            g_xsi_counter := g_xsi_counter + 1;
            g_xsi_tbl(g_xsi_counter).id :=l_update_tbl(m).xsi_id;
            g_xsi_tbl(g_xsi_counter).xtrx_invoice_pull_yn := 'Y';
            IF p_contract_number IS NULL THEN
                g_xsi_tbl(g_xsi_counter).trx_status_code := 'WORKING';
            ELSE
                g_xsi_tbl(g_xsi_counter).trx_status_code := 'ENTERED';
            END IF;

            g_xsi_tl_counter := g_xsi_tl_counter + 1;
            g_xsi_tl_tbl(g_xsi_tl_counter).id :=l_update_tbl(m).xsi_id;
            -- mdokal, Bug 4442702
            g_xsi_tl_tbl(g_xsi_tl_counter).xtrx_cons_invoice_number := l_update_tbl(m).cons_inv_number;
            g_xsi_tl_tbl(g_xsi_tl_counter).xtrx_format_type := l_update_tbl(m).invoice_format;
            g_xsi_tl_tbl(g_xsi_tl_counter).xtrx_private_label := l_update_tbl(m).private_label;

            g_xls_counter := g_xls_counter + 1;
            g_xls_tbl(g_xls_counter).id :=l_update_tbl(m).xls_id;
            g_xls_tbl(g_xls_counter).lsm_id :=l_update_tbl(m).LSM_ID;
            g_xls_tbl(g_xls_counter).xtrx_cons_stream_id :=l_update_tbl(m).lsm_id;

            g_xls_tl_counter := g_xls_tl_counter + 1;
            g_xls_tl_tbl(g_xls_tl_counter).id :=l_update_tbl(m).xls_id;
            g_xls_tl_tbl(g_xls_tl_counter).xtrx_contract := l_update_tbl(m).contract_number;
            g_xls_tl_tbl(g_xls_tl_counter).xtrx_asset := l_update_tbl(m).asset_number;
            g_xls_tl_tbl(g_xls_tl_counter).xtrx_stream_type := l_update_tbl(m).sty_name;
            g_xls_tl_tbl(g_xls_tl_counter).xtrx_stream_group := l_update_tbl(m).line_type;

        END LOOP;
     END IF;
     l_update_tbl.DELETE;
  END IF;
                 PRINT_TO_LOG( 'Done updating External Transaction Header');

                -- PRINT_TO_LOG( 'Updating External Transaction Line');

        -- ------------------------------------
        -- End header break detection logic
        -- ------------------------------------

--   IF saved_bill_rec.l_commit_cnt > G_Commit_Max THEN
--         IF FND_API.To_Boolean( p_commit ) THEN
--              COMMIT;
--         END IF;
--         saved_bill_rec.l_commit_cnt := 0;
--   END IF;

    IF (L_DEBUG_ENABLED='Y' and FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'okl_cons_bill'
									,'Process_Break End(-)');
    END IF;
*/
EXCEPTION
    WHEN OTHERS THEN
        IF (L_DEBUG_ENABLED='Y' and FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_cons_bill',
               'EXCEPTION (OTHERS) :'||SQLERRM);
        END IF;

    	PRINT_TO_LOG( 'EXCEPTION in Procedure Process_Break: '||SQLERRM);
END process_break;

FUNCTION get_invoice_group(p_khr_id NUMBER)
RETURN VARCHAR2 IS
CURSOR grp_csr ( cp_khr_id NUMBER ) IS
    select RULE_INFORMATION1
    from okc_rule_groups_v      rgp,
        okc_rules_v            rul
    where rgp.dnz_chr_id = cp_khr_id AND
    rgp.chr_id             = rgp.dnz_chr_id                  AND
    rgp.id                 = rul.rgp_id                      AND
    rgp.cle_id             IS NULL                           AND
    rgp.rgd_code           = 'LABILL'                        AND
    rul.rule_information_category = 'LAINVD';

    l_grp    okc_rules_v.rule_information1%type:= 'NONE';

BEGIN

    OPEN grp_csr(p_khr_id);
    FETCH grp_csr INTO l_grp;
    CLOSE grp_csr;

    return l_grp;

END get_invoice_group;

PROCEDURE create_new_invoice(
		  					 p_ibt_id            IN NUMBER,
		  					 p_ixx_id            IN NUMBER,
		  					 p_currency_code     IN VARCHAR2,
		  					 p_irm_id		   	 IN NUMBER,
		  					 p_inf_id		     IN NUMBER,
		  					 p_set_of_books_id   IN NUMBER,
		  					 p_private_label	 IN VARCHAR2,
							 p_date_consolidated IN DATE,
							 p_org_id			 IN NUMBER,
							 p_legal_entity_id   IN NUMBER, -- for LE Uptake project 08-11-2006
							 p_last_rec          IN BOOLEAN,
						 	 x_cnr_id			 OUT NOCOPY NUMBER,
                             x_cons_inv_num      OUT NOCOPY VARCHAR2
							 )
IS

   x_cnrv_rec Okl_Cnr_Pvt.cnrv_rec_type;
   x_cnrv_tbl Okl_Cnr_Pvt.cnrv_tbl_type;

   p_cnrv_rec  Okl_Cnr_Pvt.cnrv_rec_type;
   p_cnrv_tbl  Okl_Cnr_Pvt.cnrv_tbl_type;

   p_imav_rec  Okl_ima_pvt.imav_rec_type;
   x_imav_rec  Okl_ima_pvt.imav_rec_type;


   p_api_version                  NUMBER := 1.0;
   p_init_msg_list                VARCHAR2(1) := Okl_Api.g_false;
   x_return_status                VARCHAR2(1);
   x_msg_count                    NUMBER;
   x_msg_data                     VARCHAR2(2000);
   -- For automatic generation of sequence numbers from
   -- the database
   l_Invoice_Number          NUMBER    := '';
   l_document_category 		 VARCHAR2(100):= 'OKL Lease Receipt Invoices';
   l_application_id 	 	 NUMBER(3) := 540 ;
   x_dbseqnm 				 VARCHAR2(100):= NULL;
   x_dbseqid 				 NUMBER;

   CURSOR msg_csr IS
   		  SELECT id,
		  		 priority,
		  		 pkg_name,
				 proc_name
		  FROM okl_invoice_mssgs_v;

   l_save_priority			 okl_invoice_mssgs_v.priority%TYPE;
   l_save_ims_id			 okl_invoice_mssgs_v.id%TYPE;

   l_priority				 okl_invoice_mssgs_v.priority%TYPE;
   l_pkg_name				 okl_invoice_mssgs_v.pkg_name%TYPE;
   l_proc_name				 okl_invoice_mssgs_v.proc_name%TYPE;

   l_bind_proc               VARCHAR2(3000);
   l_msg_return				 VARCHAR2(1); --BOOLEAN;
   l_ims_id					 okl_invoice_mssgs_v.id%TYPE;


BEGIN

-- rmunjulu R12 Fixes -- comment out entire code and put NULL
NULL;
/*
	 PRINT_TO_LOG( '*** HEADER RECORD CREATION FOR : ***');
	 PRINT_TO_LOG( '*** ++++++++++++++++++++++++++++ ***');
	 PRINT_TO_LOG( '*    ====>  CUSTOMER_ID: '||p_ixx_id||' CURRENCY: '||p_currency_code);
	 PRINT_TO_LOG( '*    ====>  BILL_TO_SITE: '||p_ibt_id||' PAYMENT_METHOD: '||p_irm_id);
	 PRINT_TO_LOG( '*    ====>  PRIVATE_LABEL: '||p_private_label||' DATE_CONSOLIDATED: '||p_date_consolidated);
	 PRINT_TO_LOG( '*    ====>  INF_ID: '||p_inf_id||' SET_OF_BOOKS_ID: '||p_set_of_books_id);
	 PRINT_TO_LOG( '*    ====>  ORG_ID: '||p_org_id);
	 PRINT_TO_LOG( '*** ++++++++++++++++++++++++++++ ***');

     g_header_counter := g_header_counter+1;

	 g_cnr_tbl(g_header_counter).id := Okc_P_Util.raw_to_number(sys_guid());
	 g_cnr_tbl(g_header_counter).IBT_ID           := p_ibt_id;
	 g_cnr_tbl(g_header_counter).IXX_ID           := p_ixx_id;
	 g_cnr_tbl(g_header_counter).CURRENCY_CODE    := p_currency_code;
	 g_cnr_tbl(g_header_counter).IRM_ID           := p_irm_id;
	 g_cnr_tbl(g_header_counter).INF_ID           := p_inf_id;
	 g_cnr_tbl(g_header_counter).SET_OF_BOOKS_ID  := p_set_of_books_id;
	 g_cnr_tbl(g_header_counter).ORG_ID           := p_org_id;
 	 g_cnr_tbl(g_header_counter).LEGAL_ENTITY_ID  := p_legal_entity_id; -- for LE Uptake project 08-11-2006
	 g_cnr_tbl(g_header_counter).date_consolidated := p_date_consolidated;
	 g_cnr_tbl(g_header_counter).invoice_pull_yn  := 'Y';
	 g_cnr_tbl(g_header_counter).trx_status_code  := 'PROCESSED'; --'SUBMITTED';
     -- stmathew, added on 07/20/2005
	 g_cnr_tbl(g_header_counter).amount           := 0;
     -- end addition

	 g_cnr_tbl(g_header_counter).consolidated_invoice_number :=
               	Fnd_Seqnum.get_next_sequence (       l_application_id,
                                                     l_document_category,
   													 p_set_of_books_id,
   													 'A',
  													 SYSDATE,
  													 x_dbseqnm,
  													 x_dbseqid);


	 -- DB generated sequence number for the Consolidated Invoice
   	 PRINT_TO_LOG( '====> Generating Cons Bill SEQUENCE');
	 g_cnr_tbl(g_header_counter).creation_date := SYSDATE;
	 g_cnr_tbl(g_header_counter).created_by := Fnd_Global.USER_ID;
	 g_cnr_tbl(g_header_counter).last_update_date := SYSDATE;
	 g_cnr_tbl(g_header_counter).last_updated_by := Fnd_Global.USER_ID;
	 g_cnr_tbl(g_header_counter).object_version_number := 1;
	 g_cnr_tbl(g_header_counter).request_id := Fnd_Global.CONC_REQUEST_ID;
	 g_cnr_tbl(g_header_counter).program_application_id := Fnd_Global.PROG_APPL_ID;
	 g_cnr_tbl(g_header_counter).program_id := Fnd_Global.CONC_PROGRAM_ID;
     if Fnd_Global.CONC_REQUEST_ID <> -1 then
	 g_cnr_tbl(g_header_counter).program_update_date := SYSDATE;
     end if;

   	 PRINT_TO_LOG( '====> Cons Bill Number: '||g_cnr_tbl(g_header_counter).consolidated_invoice_number);


  --MDOKAL
	 x_cnr_id := g_cnr_tbl(g_header_counter).id;
     x_cons_inv_num :=	g_cnr_tbl(g_header_counter).CONSOLIDATED_INVOICE_NUMBER;
*/
EXCEPTION
     --Seed FND_MESSAGE like 'Could NOT CREATE Header RECORD'
	 WHEN OTHERS THEN
	    PRINT_TO_LOG('*=> Error Message(H1): '||SQLERRM);
   	      Okl_Api.SET_MESSAGE( p_app_name => G_APP_NAME,
        	      			   p_msg_name => G_OTHERS);
END create_new_invoice;

--This function checks for the existence of an consolidated invoice line
-- in okl_cnsld_ar_lines_v.This function is called when the
-- group_by_assets flag is set to 'Y'
PROCEDURE line_exist (p_cnr_id  		      IN NUMBER,
		 			  p_khr_id			 	  IN NUMBER,
					  p_kle_id				  IN NUMBER,
					  p_ilt_id			 	  IN NUMBER,
					  p_sequence_number 	  IN NUMBER,
					  p_group_by_contract_yn  IN VARCHAR2,
					  p_group_by_assets_yn    IN VARCHAR2,
					  x_lln_id			 	  OUT NOCOPY NUMBER,
					  exists_flag		 	  OUT NOCOPY VARCHAR2
		 			 )
IS

BEGIN

-- rmunjulu R12 Fixes -- comment out entire code and put NULL
NULL;
/*
	 -- Prime Local Variable
	 exists_flag := 'Y';
	 x_lln_id := NULL;

	 PRINT_TO_LOG( '*** CONSOLIDATED LINES CHECK: if a line exists for the following: ***');
	 PRINT_TO_LOG( '*    ====>  CNR_ID: '||p_cnr_id);
	 PRINT_TO_LOG( '*    ====>  KHR_ID: '||p_khr_id);
	 PRINT_TO_LOG( '*    ====>  KLE_ID: '||p_kle_id);
	 PRINT_TO_LOG( '*    ====>  ILT_ID: '||p_ilt_id);
	 PRINT_TO_LOG( '*    ====>  SEQUENCE_NUMBER: '||p_sequence_number);
	 PRINT_TO_LOG( '*    ====>  GROUP_BY_CONTRACT_YN: '||p_group_by_contract_yn);
	 PRINT_TO_LOG( '*    ====>  GROUP_BY_ASSETS_YN: '||p_group_by_assets_yn);
	 PRINT_TO_LOG( '*    ====>  GROUP_BY_ASSETS_YN: '||p_group_by_assets_yn);
	 PRINT_TO_LOG( '*** End Invoice Group Details        ***');

--MDOKAL
if g_lln_tbl.COUNT > 0 then
   for n in g_lln_tbl.first..g_lln_tbl.last loop

     if p_group_by_contract_yn = 'Y' and
        p_group_by_assets_yn = 'Y'  and
        g_lln_tbl(n).cnr_id = p_cnr_id and
        g_lln_tbl(n).khr_id = p_khr_id and
        g_lln_tbl(n).ilt_id = p_ilt_id and
        g_lln_tbl(n).sequence_number = p_sequence_number
     then
        PRINT_TO_LOG( '====>  Using SQL in check_line1 ');
	    PRINT_TO_LOG('=***********> SELECT id FROM okl_cnsld_ar_lines_v');
	    PRINT_TO_LOG('=***********> WHERE cnr_id 	       = '||p_cnr_id||' AND ');
	    PRINT_TO_LOG('=***********>       khr_id 	       = '||p_khr_id||' AND ');
   	    PRINT_TO_LOG('=***********> 	  ilt_id	  	   = '||p_ilt_id||'	AND ');
	    PRINT_TO_LOG('=***********>	   sequence_number = '||p_sequence_number||';');
        x_lln_id := g_lln_tbl(n).id;
        exit;
     elsif
        p_group_by_contract_yn = 'Y' and
        p_group_by_assets_yn = 'Y'  and
        p_kle_id is not null        and
        g_lln_tbl(n).cnr_id = p_cnr_id and
        g_lln_tbl(n).khr_id = p_khr_id and
        g_lln_tbl(n).kle_id = p_kle_id and
        g_lln_tbl(n).ilt_id = p_ilt_id and
        g_lln_tbl(n).sequence_number = p_sequence_number
     then
        PRINT_TO_LOG( '====>  Using SQL in check_line2 ');
   	    PRINT_TO_LOG('=***********> SELECT id FROM okl_cnsld_ar_lines_v');
   	    PRINT_TO_LOG('=***********> WHERE cnr_id 	       = '||p_cnr_id||' AND ');
   	    PRINT_TO_LOG('=***********>       khr_id 	       = '||p_khr_id||' AND ');
   	    PRINT_TO_LOG('=***********>       kle_id 	       = '||p_kle_id||'	AND ');
   	    PRINT_TO_LOG('=***********> 	  ilt_id	  	   = '||p_ilt_id||'	AND ');
   	    PRINT_TO_LOG('=***********>	   sequence_number = '||p_sequence_number||';');
        x_lln_id := g_lln_tbl(n).id;
        exit;
     elsif
        p_group_by_contract_yn = 'Y' and
        p_group_by_assets_yn = 'Y'  and
        p_kle_id is null            and
        g_lln_tbl(n).cnr_id = p_cnr_id and
        g_lln_tbl(n).khr_id = p_khr_id and
        g_lln_tbl(n).kle_id  is null  and
        g_lln_tbl(n).ilt_id = p_ilt_id and
        g_lln_tbl(n).sequence_number = p_sequence_number
     then
  	    PRINT_TO_LOG( '====>  Using SQL in check_line3 ');
        PRINT_TO_LOG('=***********> SELECT id FROM okl_cnsld_ar_lines_v');
  	    PRINT_TO_LOG('=***********> WHERE cnr_id 	       = '||p_cnr_id||' AND ');
  	    PRINT_TO_LOG('=***********>       khr_id 	       = '||p_khr_id||' AND ');
  	    PRINT_TO_LOG('=***********>       kle_id 	       is null			AND ');
 	    PRINT_TO_LOG('=***********> 	  ilt_id	  	   = '||p_ilt_id||'	AND ');
   	    PRINT_TO_LOG('=***********>	   sequence_number = '||p_sequence_number||';');
        x_lln_id := g_lln_tbl(n).id;
        exit;
      elsif
        p_group_by_contract_yn <> 'Y' and
        g_lln_tbl(n).cnr_id = p_cnr_id and
        g_lln_tbl(n).ilt_id = p_ilt_id and
        g_lln_tbl(n).sequence_number = p_sequence_number
      then
   	    PRINT_TO_LOG( '====>  Using SQL in check_line4 ');
	    PRINT_TO_LOG('=***********> SELECT id FROM okl_cnsld_ar_lines_v');
	    PRINT_TO_LOG('=***********> WHERE cnr_id 	       = '||p_cnr_id||' AND ');
   	    PRINT_TO_LOG('=***********> 	   ilt_id	  	   = '||p_ilt_id||'	AND ');
	    PRINT_TO_LOG('=***********>	   sequence_number = '||p_sequence_number||';');
        x_lln_id := g_lln_tbl(n).id;
        exit;
     end if;
   end loop;
end if;

IF ( x_lln_id IS NULL ) THEN
   exists_flag := 'N';
   PRINT_TO_LOG( '====>  No Line Exists for this combination.  ');
ELSE
   PRINT_TO_LOG( '====>  Found an existing line for this combination. The id is '||x_lln_id);
END IF;

 PRINT_TO_LOG( '*** END CONSOLIDATED LINES CHECK                                      ***');
*/
EXCEPTION
  	 		  WHEN NO_DATA_FOUND THEN
	    	  	   PRINT_TO_LOG('*=> Error Message(L1): '||SQLERRM);
	  		  	   Okl_Api.SET_MESSAGE( p_app_name => G_APP_NAME,
        	              				p_msg_name => G_NO_DATA_FOUND);

  				   exists_flag		:= 'N';
 	 		  WHEN TOO_MANY_ROWS THEN
	    	  	   PRINT_TO_LOG('*=> Error Message(L2): '||SQLERRM);
	  		  	   Okl_Api.SET_MESSAGE( p_app_name => G_APP_NAME,
        	              				p_msg_name => G_TOO_MANY_ROWS);

  				   exists_flag		:= NULL;
			  WHEN OTHERS THEN
	    	  	   PRINT_TO_LOG('*=> Error Message(L3): '||SQLERRM);
	  		  	   Okl_Api.SET_MESSAGE( p_app_name => G_APP_NAME,
        	              				p_msg_name => G_OTHERS);
				   exists_flag := NULL;

END line_exist;

--This procedure creates a new consolidated invoice line
--based on the parameters passed
PROCEDURE create_new_line(
				p_khr_id 			IN NUMBER,
				p_cnr_id		    IN NUMBER,
				p_kle_id		    IN NUMBER,
				p_ilt_id		    IN NUMBER,
				p_currency_code 	IN VARCHAR2,
				p_sequence_number	IN NUMBER,
				p_line_type			IN VARCHAR2,
				p_group_by_contract_yn IN VARCHAR2,
				p_group_by_assets_yn   IN VARCHAR2,
				p_contract_level_yn    IN VARCHAR2,
				x_lln_id		 OUT NOCOPY NUMBER
			  )

IS

   x_llnv_rec Okl_Lln_Pvt.llnv_rec_type;
   x_llnv_tbl Okl_Lln_Pvt.llnv_tbl_type;

   p_llnv_rec  Okl_Lln_Pvt.llnv_rec_type;
   p_llnv_tbl  Okl_Lln_Pvt.llnv_tbl_type;


   p_api_version                  NUMBER := 1.0;
   p_init_msg_list                VARCHAR2(1) := Okl_Api.g_false;
   x_return_status                VARCHAR2(1) := 'S';
   x_msg_count                    NUMBER;
   x_msg_data                     VARCHAR2(2000);


BEGIN
     --MDOKAL
-- rmunjulu R12 Fixes -- comment out entire code and put NULL
NULL;
/*
     g_line_counter := g_line_counter+1;
     g_lln_tbl(g_line_counter).id := Okc_P_Util.raw_to_number(sys_guid());
     g_lln_tbl(g_line_counter).sequence_number := nvl(p_sequence_number, 1);
     if (nvl(p_group_by_contract_yn, 'N')  = 'Y' OR nvl(p_contract_level_yn, 'N') = 'N') then
       if  nvl(p_group_by_assets_yn, 'N') = 'N' then
          g_lln_tbl(g_line_counter).kle_id := p_kle_id;
       end if;
     end if;
     if (nvl(p_group_by_contract_yn, 'N')  = 'Y' OR nvl(p_contract_level_yn, 'N') = 'N') then
       g_lln_tbl(g_line_counter).khr_id := p_khr_id;
     end if;
     g_lln_tbl(g_line_counter).cnr_id := p_cnr_id;
     g_lln_tbl(g_line_counter).ilt_id := p_ilt_id;
     g_lln_tbl(g_line_counter).line_type := SUBSTR(p_line_type,1,50);
     g_lln_tbl(g_line_counter).creation_date := SYSDATE;
     g_lln_tbl(g_line_counter).created_by := Fnd_Global.USER_ID;
     g_lln_tbl(g_line_counter).last_update_date := SYSDATE;
     g_lln_tbl(g_line_counter).last_updated_by := Fnd_Global.USER_ID;
     g_lln_tbl(g_line_counter).object_version_number := 1;
     g_lln_tbl(g_line_counter).request_id := Fnd_Global.CONC_REQUEST_ID;
     g_lln_tbl(g_line_counter).program_application_id := Fnd_Global.PROG_APPL_ID;

     -- stmathew added on 07/20/2005
     g_lln_tbl(g_line_counter).amount := 0;
     -- end

     g_lln_tbl(g_line_counter).program_id := Fnd_Global.CONC_PROGRAM_ID;
     if Fnd_Global.CONC_REQUEST_ID <> -1 then
       g_lln_tbl(g_line_counter).program_update_date := SYSDATE;
     end if;

   PRINT_TO_LOG( '*** LINE RECORD CREATION FOR : ***');
   PRINT_TO_LOG( '*** ++++++++++++++++++++++++++++ ***');
   PRINT_TO_LOG( '*    ====>  KHR_ID: '||g_lln_tbl(g_line_counter).khr_id||' KLE_ID: '||g_lln_tbl(g_line_counter).kle_id);
   PRINT_TO_LOG( '*    ====>  CNR_ID: '||g_lln_tbl(g_line_counter).cnr_id ||' ILT_ID: '||g_lln_tbl(g_line_counter).ilt_id);
   PRINT_TO_LOG( '*    ====>  SEQUENCE_NUMBER: '||g_lln_tbl(g_line_counter).sequence_number||' LINE_TYPE: '||g_lln_tbl(g_line_counter).line_type);
   PRINT_TO_LOG( '*** ++++++++++++++++++++++++++++ ***');

   IF ( x_return_status = 'S' ) THEN
      PRINT_TO_LOG('====>  Consolidated Line Created.');
   ELSE
      PRINT_TO_LOG('*=> FAILED: Consolidated Line NOT Created.');
   END IF;

  --MDOKAL
  -- running totals

  if  nvl(g_prev_cnr_id, 1) = p_cnr_id then
      null;
    --g_cnr_total := g_cnr_total + g_lln_total;
  else

    if g_cnr_tbl.exists(g_header_counter-1) then
      if g_cnr_total = 0 and g_header_counter = 2 then
          null;
        --g_cnr_tbl(g_header_counter-1).amount := g_lln_total;
      else
          null;
       -- g_cnr_tbl(g_header_counter-1).amount := g_cnr_total;
      end if;
    end if;

    --g_cnr_total := g_lln_total;
    g_prev_cnr_id := p_cnr_id;

  end if;

  x_lln_id :=   g_lln_tbl(g_line_counter).id;
*/
EXCEPTION
     --Seed FND_MESSAGE like 'Could NOT CREATE Line RECORD'
	 WHEN OTHERS THEN
	    PRINT_TO_LOG('*=> Error Message(L1): '||SQLERRM);
   	      Okl_Api.SET_MESSAGE( p_app_name => G_APP_NAME,
        	      			   p_msg_name => G_OTHERS);
END create_new_line;


--This procedure creates a new consolidated invoice streams
--based on the parameters passed
PROCEDURE create_new_streams(
				p_lln_id 		IN NUMBER,
				p_sty_id		IN NUMBER,
				p_kle_id		IN NUMBER,
				p_khr_id		IN NUMBER,
				p_amount		IN NUMBER,
                p_sel_id        IN NUMBER,
                p_cnr_id        IN NUMBER,
				x_lsm_id	 OUT NOCOPY NUMBER,
				x_return_status OUT NOCOPY VARCHAR2
			  )

IS

   x_cnrv_rec Okl_Cnr_Pvt.cnrv_rec_type;
   x_cnrv_tbl Okl_Cnr_Pvt.cnrv_tbl_type;

   x_lsmv_rec Okl_Lsm_Pvt.lsmv_rec_type;
   x_lsmv_tbl Okl_Lsm_Pvt.lsmv_tbl_type;

   p_lsmv_rec  Okl_Lsm_Pvt.lsmv_rec_type;
   p_lsmv_tbl  Okl_Lsm_Pvt.lsmv_tbl_type;

   -- fmiao - Bug#5232919 - Modified - Start
   -- Commenting the decalration of Invoice Message Attribute Records as
   -- henceforth these are tracked as global records
   --p_imav_rec  Okl_ima_pvt.imav_rec_type;
   --x_imav_rec  Okl_ima_pvt.imav_rec_type;

   -- Defining table record for out record of Invoice Message Attribute
   x_imav_tbl  Okl_Ima_Pvt.imav_tbl_type;
   -- fmiao - Bug#5232919 - Modified - end

-- ssiruvol - Bug#5354130 - Added - Start
-- temporary records for storing CNR table of records
l_cnr_tbl cnr_tbl_type;
-- ssiruvol - Bug#5354130 - Added - End

   l_save_ims_id			 okl_invoice_mssgs_v.id%TYPE;
   l_save_priority			 okl_invoice_mssgs_v.priority%TYPE;
   l_bind_proc               VARCHAR2(3000);
   l_msg_return				 VARCHAR2(1);

   p_api_version                  NUMBER := 1.0;
   p_init_msg_list                VARCHAR2(1) := Okl_Api.g_false;
   x_msg_count                    NUMBER;
   x_msg_data                     VARCHAR2(2000);
   l_cnr_rec                 cnr_rec_type;
   l_lln_rec                 lln_rec_type;

   -- fmiao - Bug#5232919 - Modified - Start
   l_date_consolidated DATE;
   -- fmiao - Bug#5232919 - Modified - end

-- BUG#4621302
-- cursor to fetch the installed languages
   CURSOR get_languages IS
       SELECT language_code
       FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');

   TYPE lang_tbl_type  IS TABLE OF get_languages%ROWTYPE INDEX BY BINARY_INTEGER;

   l_lang_tbl     lang_tbl_type;
   lang_count     NUMBER;
   tl_count       NUMBER;
-- BUG#4621302
BEGIN
   --MDOKAL, if headers have reached max size then perform insert
   -- and keep the last record for ongoing processing.

-- rmunjulu R12 Fixes - comment out entire code and put NULL
NULL;
/*


   if (g_lsm_tbl.COUNT > G_Commit_Max )
   --and
   --   g_lln_tbl(g_line_counter).id <> g_lsm_tbl(g_stream_counter).lln_id)
   then

      if g_cnr_tbl.count >= 1 then

        -- First store the last record locally
        l_cnr_rec:= g_cnr_tbl(g_header_counter);
        -- Now delete the last record from the main table
		-- because it will be inserted next time around
        g_cnr_tbl.DELETE(g_header_counter);
        g_header_counter := g_header_counter-1;

        -- #4621302
        lang_count := 1;
        FOR l_lang_rec in get_languages
        LOOP
           l_lang_tbl(lang_count) := l_lang_rec;
           lang_count := lang_count+1;
        END LOOP;

        -- check table count
        if g_cnr_tbl.count > 0 then
            tl_count := g_cnr_tbl.first;
        -- Create TL Records
        for z in g_cnr_tbl.first..g_cnr_tbl.last loop
          -- #4621302
          FOR lang_count IN l_lang_tbl.first..l_lang_tbl.last LOOP
            g_cnr_tl_tbl(tl_count).id                := g_cnr_tbl(z).id;
            g_cnr_tl_tbl(tl_count).language          := l_lang_tbl(lang_count).language_code;
            g_cnr_tl_tbl(tl_count).source_lang       :=  USERENV('LANG');
            g_cnr_tl_tbl(tl_count).sfwt_flag         := 'N';
            g_cnr_tl_tbl(tl_count).created_by        := fnd_global.user_id;
            g_cnr_tl_tbl(tl_count).creation_date     := sysdate;
            g_cnr_tl_tbl(tl_count).last_updated_by   := fnd_global.user_id;
            g_cnr_tl_tbl(tl_count).last_update_date  := sysdate;
            g_cnr_tl_tbl(tl_count).last_update_login := fnd_global.login_id;
            tl_count                                 := tl_count + 1;
          END LOOP; -- languages loop

           -- invoice messaging processing
           if g_inv_msg = 'TRUE' and g_msg_tbl.COUNT > 0 then
	          -- Find message with the highest priority
	  	      l_save_priority := NULL;
              for e in  g_msg_tbl.FIRST..g_msg_tbl.LAST loop
              -- fmiao - Bug#5232919 - Modified - Start
                  l_date_consolidated := TRUNC(g_cnr_tbl(z).date_consolidated);
                  -- Check if the invoice message is effective for this consolidated invoice
                  IF ( l_date_consolidated BETWEEN NVL(g_msg_tbl(e).start_date,l_date_consolidated)
                                           AND NVL(g_msg_tbl(e).end_date,l_date_consolidated)) THEN

    	 	  	 PRINT_TO_LOG('====> IMS_ID: '||g_msg_tbl(e).id);
    	 	  	 PRINT_TO_LOG('====> PKG: '||g_msg_tbl(e).pkg_name);
  	    	  	 PRINT_TO_LOG('====> PROC: '||g_msg_tbl(e).proc_name);

                 l_bind_proc := 'BEGIN OKL_QUAL_INV_MSGS.'||g_msg_tbl(e).proc_name||'(:1,:2); END;';

                 PRINT_TO_LOG('l_bind_proc : '||l_bind_proc);
                 PRINT_TO_LOG('g_cnr_tbl(z).id : '||g_cnr_tbl(z).id);
                 BEGIN
                    EXECUTE IMMEDIATE l_bind_proc USING IN g_cnr_tbl(z).id, OUT l_msg_return;
                 EXCEPTION
                    WHEN OTHERS THEN
                     PRINT_TO_LOG('Invoice Message error -- '||SQLERRM);
                 END;

				 if (l_msg_return = '1' ) then
		  	 	    if (l_save_priority is null) or (g_msg_tbl(e).priority < l_save_priority) then
		  	 	       l_save_priority := g_msg_tbl(e).priority;
				       l_save_ims_id   := g_msg_tbl(e).id;
		            end if;
		         end if;
                      END IF;
                  -- end of check for effective dates of invoice message
                  -- fmiao  - Bug#5232919  - Modified - End

               end loop; -- end of message table loop

		    -- Create Intersection Record
		    if (l_save_priority is not null) then
                      -- fmiao  - Bug#5232919  - Modified - Started
                      -- Populating the global Inv Messg Attr records
                      g_imav_counter := g_imav_counter + 1;
                      g_imav_tbl(g_imav_counter).cnr_id  := g_cnr_tbl(z).id;
                      g_imav_tbl(g_imav_counter).ims_id  := l_save_ims_id;

		   	   --p_imav_rec.cnr_id  := x_cnrv_rec.id;
 			   --p_imav_rec.ims_id  := l_save_ims_id;
                      -- Commenting code that inserts record into Inv Msg Attr table because
                      -- at this point the CNR_ID is not yet in the CNSLD HDR table and this will
                      -- fail validation at TAPI of Inv Msg Attr table
*/
                      /*
               -- Start of wraper code generated automatically by Debug code generator for okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT
               IF(IS_DEBUG_PROCEDURE_ON) THEN
                  BEGIN
                     OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRKONB.pls call okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT ');
                  END;
               END IF;

		  	   okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT(
	  	  		     p_api_version
    				,p_init_msg_list
    				,x_return_status
    				,x_msg_count
    				,x_msg_data
    				,p_imav_rec
    				,x_imav_rec
			  );
              IF(IS_DEBUG_PROCEDURE_ON) THEN
                 BEGIN
                   OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRKONB.pls call okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT ');
                 END;
              END IF;
              -- End of wraper code generated automatically by Debug code generator for okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT
   			  IF ( x_return_status = 'S' ) THEN
      		  	 PRINT_TO_LOG('====> Message Created.');
			  ELSE
      		  	 PRINT_TO_LOG('*=> FAILED:Message Creation');
			  END IF;
              */
              -- fmiao - Bug#5232919 - Modified - End
/*
		   ELSE
      	  	   PRINT_TO_LOG('====> NO Message Qualified');
		   END IF;
            END IF; -- end of check for invoice message processing
        end loop; -- End Create TL Records

        end if; -- check table count

	    PRINT_TO_LOG('Performing bulk insert for cnr, record count is '||g_cnr_tbl.count);
        BEGIN
           savepoint H1;

           -- check table count
           if g_cnr_tbl.count > 0 then
                forall x in g_cnr_tbl.first..g_cnr_tbl.last
                    save exceptions
                    insert into okl_cnsld_ar_hdrs_b
                    values g_cnr_tbl(x);

                forall d in g_cnr_tl_tbl.first..g_cnr_tl_tbl.last
                    save exceptions
                    insert into okl_cnsld_ar_hdrs_tl
                    values g_cnr_tl_tbl(d);

          end if; -- check table count

        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Header Insertion, rollback to H1');
           rollback to H1;
           g_cnr_tbl.DELETE;
           g_cnr_tl_tbl.DELETE;
           g_lln_tbl.DELETE;
           g_lln_tl_tbl.DELETE;
           g_lsm_tbl.DELETE;
           g_lsm_tl_tbl.DELETE;
           g_xsi_tbl.DELETE;
           g_xsi_tl_tbl.DELETE;
           g_xls_tbl.DELETE;
           g_xls_tl_tbl.DELETE;
           RAISE;
        END;

     end if;
     g_header_counter := 0;
     -- flush tables
     g_cnr_tbl.delete;
     g_cnr_tl_tbl.delete;

      -- add the last record back into the pl/sql table
      if l_cnr_rec.id is not null then
         g_header_counter := 1;
         g_cnr_tbl(g_header_counter) := l_cnr_rec;
         --g_cnr_tbl(g_header_counter).amount := g_cnr_total;
      end if;
      -- End Header Inserts

      --MDOKAL, if lines have reached max size then perform insert
      -- and keep the last record for ongoing processing.

      if g_lln_tbl.count >= 1 then

        -- First store the last record locally
        l_lln_rec:= g_lln_tbl(g_line_counter);
        -- Now delete the last record from the main table
		-- because it will be inserted next time around
        g_lln_tbl.DELETE(g_line_counter);
        g_line_counter := g_line_counter-1;

        -- check table count
        if g_lln_tbl.count > 0 then

        -- Create TL Records
        tl_count := g_lln_tbl.first;
        for x in g_lln_tbl.first..g_lln_tbl.last loop
          -- BUG#4621302
          FOR lang_count in l_lang_tbl.first..l_lang_tbl.last
          LOOP
            g_lln_tl_tbl(tl_count).id                := g_lln_tbl(x).id;
            g_lln_tl_tbl(tl_count).language          := l_lang_tbl(lang_count).language_code;
            g_lln_tl_tbl(tl_count).source_lang       := USERENV('LANG');
            g_lln_tl_tbl(tl_count).sfwt_flag         := 'N';
            g_lln_tl_tbl(tl_count).created_by        := fnd_global.user_id;
            g_lln_tl_tbl(tl_count).creation_date     := sysdate;
            g_lln_tl_tbl(tl_count).last_updated_by   := fnd_global.user_id;
            g_lln_tl_tbl(tl_count).last_update_date  := sysdate;
            g_lln_tl_tbl(tl_count).last_update_login := fnd_global.login_id;
            tl_count                                 := tl_count + 1;
          END LOOP; -- languages loop
        end loop;

        end if; -- check table count

        BEGIN
        savepoint L1;
	    PRINT_TO_LOG('Performing bulk insert for lln, record count is '||g_lln_tbl.count);

        -- check table count
        if g_lln_tbl.count > 0 then

        forall x in g_lln_tbl.first..g_lln_tbl.last
           save exceptions
           insert into okl_cnsld_ar_lines_b
           values g_lln_tbl(x);

        forall e in g_lln_tl_tbl.first..g_lln_tl_tbl.last
           save exceptions
           insert into okl_cnsld_ar_lines_tl
           values g_lln_tl_tbl(e);

        end if; -- check table count

        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Line Insertion, rollback to L1');
           rollback to L1;
           g_lln_tl_tbl.DELETE;
           g_lsm_tbl.DELETE;
           g_lsm_tl_tbl.DELETE;
           g_xsi_tbl.DELETE;
           g_xsi_tl_tbl.DELETE;
           g_xls_tbl.DELETE;
           g_xls_tl_tbl.DELETE;

           -- check table count
           if g_lln_tbl.count > 0 then

           for e in g_lln_tbl.FIRST..g_lln_tbl.LAST loop
              delete from okl_cnsld_ar_hdrs_b
              where id = g_lln_tbl(e).cnr_id;
           end loop;

           end if; -- check table count

           g_lln_tbl.DELETE;
           RAISE;
        END;

      end if;
      g_line_counter := 0;
      -- flush tables
      g_lln_tbl.delete;
      g_lln_tl_tbl.delete;

      -- add the last record back into the pl/sql table
      if l_lln_rec.id is not null then
         g_line_counter := 1;
         g_lln_tbl(g_line_counter) := l_lln_rec;
         --g_lln_tbl(g_line_counter).amount := g_lln_total;
      end if;

   -- End Line Inserts

     --MDOKAL --process inserts

     -- insert consolidated streams
     if g_lsm_tbl.count > 0 then

        -- Create TL Records
        tl_count := g_lsm_tbl.first;
        for y in g_lsm_tbl.first..g_lsm_tbl.last loop
          -- BUG#4621302
          FOR lang_count in l_lang_tbl.first..l_lang_tbl.last
          LOOP
             g_lsm_tl_tbl(tl_count).id                := g_lsm_tbl(y).id;
             g_lsm_tl_tbl(tl_count).language          := l_lang_tbl(lang_count).language_code;
             g_lsm_tl_tbl(tl_count).source_lang       := USERENV('LANG');
             g_lsm_tl_tbl(tl_count).sfwt_flag         := 'N';
             g_lsm_tl_tbl(tl_count).created_by        := fnd_global.user_id;
             g_lsm_tl_tbl(tl_count).creation_date     := sysdate;
             g_lsm_tl_tbl(tl_count).last_updated_by   := fnd_global.user_id;
             g_lsm_tl_tbl(tl_count).last_update_date  := sysdate;
             g_lsm_tl_tbl(tl_count).last_update_login := fnd_global.login_id;
             tl_count                                 := tl_count + 1;
          END LOOP; -- languages loop
       end loop;

	   PRINT_TO_LOG('Performing bulk insert for lsm, record count is '||g_lsm_tbl.count);

       BEGIN
       savepoint D1;
       forall x in g_lsm_tbl.first..g_lsm_tbl.last
         save exceptions
         insert into okl_cnsld_ar_strms_b
         values g_lsm_tbl(x);

       forall f in g_lsm_tl_tbl.first..g_lsm_tl_tbl.last
         save exceptions
         insert into okl_cnsld_ar_strms_tl
         values g_lsm_tl_tbl(f);

        commit;
        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Stream Insertion, rollback to D1');
           rollback to D1;
           g_cnr_tl_tbl.delete;
           g_lln_tl_tbl.DELETE;
           g_lsm_tl_tbl.DELETE;
           g_xsi_tbl.DELETE;
           g_xsi_tl_tbl.DELETE;
           g_xls_tbl.DELETE;
           g_xls_tl_tbl.DELETE;

           -- check table count
           if g_lsm_tbl.count > 0 then

           for e in g_lsm_tbl.FIRST..g_lsm_tbl.LAST loop

              -- check table count
              if g_lln_tbl.count > 0 then

              for f in g_lln_tbl.FIRST..g_lln_tbl.LAST loop
                 delete from okl_cnsld_ar_hdrs_b
                 where id = g_lln_tbl(f).cnr_id;
              end loop;

              end if; -- check table count

              delete from okl_cnsld_ar_lines_b
              where id = g_lsm_tbl(e).lln_id;
           end loop;

           end if; -- check table count

           g_lsm_tbl.DELETE;
           g_lln_tbl.DELETE;
           g_cnr_tbl.DELETE;
           RAISE;
        END;
     end if;
     -- flush tables
     g_lsm_tbl.delete;
     g_lsm_tl_tbl.delete;

     g_stream_counter := 0;

     -- fmiao - Bug#5232919 - Modified - Start
      -- Code to insert the table of records into OKL_INV_MSSG_ATT
      IF ( g_imav_tbl.COUNT > 0) THEN
        -- Start of wraper code generated automatically by Debug code generator for okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT
        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRKONB.pls call okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT ');
          END;
        END IF;

        Okl_Inv_Mssg_Att_Pub.INSERT_INV_MSSG_ATT(
                            p_api_version
                           ,p_init_msg_list
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,g_imav_tbl
                           ,x_imav_tbl
                 );

       IF(IS_DEBUG_PROCEDURE_ON) THEN
         BEGIN
           Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRKONB.pls call okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT ');
         END;
       END IF;
       -- End of wraper code generated automatically by Debug code generator for okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT
       IF ( x_return_status = 'S' ) THEN
         PRINT_TO_LOG('====> Message Created.');
       ELSE
         PRINT_TO_LOG('*=> FAILED:Message Creation');
       END IF;

        -- flush the global table of records
        g_imav_tbl.DELETE;
        g_imav_counter := 0;
      END IF; -- end of checking for presence of g_imav_tbl records
      -- fmiao - Bug#5232919 - Modified - End

   end if; -- main
   g_stream_counter  := g_stream_counter+1;
   g_lsm_tbl(g_stream_counter).id := Okc_P_Util.raw_to_number(sys_guid());
   g_lsm_tbl(g_stream_counter).KLE_ID         := p_kle_id;
   g_lsm_tbl(g_stream_counter).KHR_ID         := p_khr_id;
   g_lsm_tbl(g_stream_counter).STY_ID         := p_sty_id;
   g_lsm_tbl(g_stream_counter).LLN_ID         := p_lln_id;
   g_lsm_tbl(g_stream_counter).AMOUNT         := p_amount;
   g_lsm_tbl(g_stream_counter).SEL_ID         := p_sel_id;
   g_lsm_tbl(g_stream_counter).receivables_invoice_id          := -99999;
   g_lsm_tbl(g_stream_counter).creation_date := (SYSDATE);
   g_lsm_tbl(g_stream_counter).created_by := Fnd_Global.USER_ID;
   g_lsm_tbl(g_stream_counter).last_update_date := (SYSDATE);
   g_lsm_tbl(g_stream_counter).last_updated_by := Fnd_Global.USER_ID;
   g_lsm_tbl(g_stream_counter).object_version_number := 1;
   g_lsm_tbl(g_stream_counter).request_id := Fnd_Global.CONC_REQUEST_ID;
   g_lsm_tbl(g_stream_counter).program_application_id := Fnd_Global.PROG_APPL_ID;
   g_lsm_tbl(g_stream_counter).program_id := Fnd_Global.CONC_PROGRAM_ID;
   if Fnd_Global.CONC_REQUEST_ID <> -1 then
     g_lsm_tbl(g_stream_counter).program_update_date := (SYSDATE);
   end if;
   PRINT_TO_LOG( '*** STREAM RECORD CREATION FOR : ***');
   PRINT_TO_LOG( '*** ++++++++++++++++++++++++++++ ***');
   PRINT_TO_LOG( '*    ====>  KHR_ID: '||g_lsm_tbl(g_stream_counter).KHR_ID||' KLE_ID: '||g_lsm_tbl(g_stream_counter).KLE_ID);
   PRINT_TO_LOG( '*    ====>  STY_ID: '||g_lsm_tbl(g_stream_counter).STY_ID||' LLN_ID: '||g_lsm_tbl(g_stream_counter).LLN_ID);
   PRINT_TO_LOG( '*    ====>  AMOUNT: '||g_lsm_tbl(g_stream_counter).AMOUNT);
   PRINT_TO_LOG( '*** ++++++++++++++++++++++++++++ ***');

  x_return_status := 'S';
   IF ( x_return_status = 'S' ) THEN
	  	 PRINT_TO_LOG('====>  Consolidated Streams Created.');
   ELSE
	  	 PRINT_TO_LOG('*=> FAILED: Consolidated Streams NOT Created.');
   END IF;

  --MDOKAL
  -- running totals

  if  nvl(g_prev_lln_id, 1) = p_lln_id then
    null;
    --g_lln_total := g_lln_total + p_amount;
  else
    if g_lln_tbl.exists(g_line_counter-1) then
      if nvl(g_lln_total, 0) = 0 then
         null;
         --g_lln_tbl(g_line_counter-1).amount := p_amount;
      else
        null;
        --g_lln_tbl(g_line_counter-1).amount := g_lln_total;
      end if;
    end if;
    --g_lln_total := p_amount;
    g_prev_lln_id := p_lln_id;
  end if;

   if g_xls_tbl.COUNT > G_Commit_Max or
      g_xsi_tbl.COUNT > G_Commit_Max or
      g_xls_tl_tbl.COUNT >  G_Commit_Max or
      g_xsi_tl_tbl.COUNT >  G_Commit_Max
   then
     if g_xsi_tbl.COUNT > 0 then
	    PRINT_TO_LOG('Performing  bulk update for xsi, record count is '||g_xsi_tbl.COUNT );
        BEGIN
        savepoint U1;
           for indx in g_xsi_tbl.first..g_xsi_tbl.last loop
            -- rseela BUG#4733028 removed the updation of xtrx_invoice_pull_yn
            update okl_ext_sell_invs_b
            set trx_status_code = g_xsi_tbl(indx).trx_status_code,
--                xtrx_invoice_pull_yn = g_xsi_tbl(indx).xtrx_invoice_pull_yn,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
            where id = g_xsi_tbl(indx).id;
           end loop;
        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Update of okl_ext_sell_invs_b, rollback to U1');
           rollback to U1;
           RAISE;
        END;
        commit;
     end if;
     -- flush table
     g_xsi_tbl.delete;
     g_xsi_counter := 0;

     if g_xls_tbl.COUNT > 0 then
	    PRINT_TO_LOG('Performing  bulk update for xls, record count is '||g_xls_tbl.COUNT );
        BEGIN
           savepoint U2;
           for s in g_xls_tbl.first..g_xls_tbl.last loop
              update okl_xtl_sell_invs_b
              set lsm_id              = g_xls_tbl(s).lsm_id,
                  xtrx_cons_stream_id  = g_xls_tbl(s).lsm_id,
                  last_update_date     = sysdate,
                  last_updated_by      = fnd_global.user_id,
                  last_update_login    = fnd_global.login_id
              where id = g_xls_tbl(s).id;
           end loop;
        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Update of okl_xtl_sell_invs_b, rollback to U2');
           rollback to U2;
           RAISE;
        END;
        commit;
     end if;
     -- flush table
     g_xls_tbl.delete;
     g_xls_counter := 0;

     if g_xsi_tl_tbl.COUNT > 0 then
	    PRINT_TO_LOG('Performing bulk update for xsi tl, record count is '||g_xsi_tl_tbl.COUNT );
	    BEGIN
	    savepoint U3;
        for u in g_xsi_tl_tbl.first..g_xsi_tl_tbl.last loop
           update okl_ext_sell_invs_tl
           set xtrx_cons_invoice_number = g_xsi_tl_tbl(u).xtrx_cons_invoice_number,
               xtrx_format_type = g_xsi_tl_tbl(u).xtrx_format_type,
               xtrx_private_label = g_xsi_tl_tbl(u).xtrx_private_label,
               last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id
           where id = g_xsi_tl_tbl(u).id;
        end loop;
        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Update of okl_ext_sell_invs_tl, rollback to U3');
           rollback to U3;
           RAISE;
        END;
        commit;
     end if;
     -- flush table
     g_xsi_tl_tbl.delete;
     g_xsi_tl_counter := 0;

     if g_xls_tl_tbl.COUNT > 0 then
	    PRINT_TO_LOG('Performing bulk update for xls tl, record count is '||g_xls_tl_tbl.COUNT );
        BEGIN
        savepoint U4;
        for t in g_xls_tl_tbl.first..g_xls_tl_tbl.last loop

           update okl_xtl_sell_invs_tl
           set    xtrx_contract     = g_xls_tl_tbl(t).xtrx_contract,
                  xtrx_asset        = g_xls_tl_tbl(t).xtrx_asset,
                  xtrx_stream_type  = g_xls_tl_tbl(t).xtrx_stream_type,
                  xtrx_stream_group = g_xls_tl_tbl(t).xtrx_stream_group,
                  last_update_date  = sysdate,
                  last_updated_by   = fnd_global.user_id,
                  last_update_login = fnd_global.login_id
           where id = g_xls_tl_tbl(t).id;
        end loop;
        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Update of okl_xtl_sell_invs_tl, rollback to U4');
           rollback to U4;
           RAISE;
        END;
        commit;
     end if;
     -- flush table
     g_xls_tl_tbl.delete;
     g_xls_tl_counter := 0;
   end if;

  x_lsm_id := g_lsm_tbl(g_stream_counter).id;
*/
EXCEPTION
     --Seed FND_MESSAGE like 'Could NOT CREATE Stream RECORD'
	 WHEN OTHERS THEN
	    PRINT_TO_LOG('*=> Error Message(D1): '||SQLERRM);
   	      Okl_Api.SET_MESSAGE( p_app_name => G_APP_NAME,
        	      			   p_msg_name => G_OTHERS);
END create_new_streams;


PROCEDURE process_cons_bill_tbl(
           p_contract_number	IN  VARCHAR2,
	       p_api_version        IN NUMBER,
    	   p_init_msg_list      IN VARCHAR2,
           p_commit             IN  VARCHAR2,
    	   x_return_status      OUT NOCOPY VARCHAR2,
    	   x_msg_count          OUT NOCOPY NUMBER,
    	   x_msg_data           OUT NOCOPY VARCHAR2,
           p_cons_bill_tbl      IN OUT NOCOPY cons_bill_tbl_type,
           p_saved_bill_rec     IN OUT NOCOPY saved_bill_rec_type,
           p_update_tbl         IN OUT NOCOPY update_tbl_type)
IS


    l_api_name	                 CONSTANT VARCHAR2(30)  := 'process_cons_bill_tbl';
    l_format_name                okl_invoice_formats_v.name%TYPE;
	l_contract_level_yn			 VARCHAR2(3);
	l_group_asset_yn			 VARCHAR2(3);
	l_group_by_contract_yn		 VARCHAR2(3);
	l_ilt_id					 NUMBER;
	l_cnr_id					 NUMBER;
    l_lln_id					 NUMBER;
	l_lsm_id					 NUMBER;

	l_line_name					 VARCHAR2(150);
	l_ity_id					 NUMBER;
    l_format_type                okl_invoice_types_v.name%TYPE;

	l_sequence_number	         okl_invc_line_types_v.sequence_number%TYPE;
 	l_cons_line_name			 VARCHAR2(150);
	l_stream_name				 VARCHAR2(150);
    i                            NUMBER;
    l_funct_return	 		     VARCHAR2(1);

    l_cons_inv_num               okl_cnsld_ar_hdrs_v.consolidated_invoice_number%TYPE;
    l_cnr_amount                 okl_cnsld_ar_hdrs_v.amount%TYPE;
    l_lln_amount                 okl_cnsld_ar_lines_v.amount%TYPE;

    l_update_tbl                 update_tbl_type;

	l_kle_id 		             NUMBER;
    l_top_kle_id                 NUMBER;
    l_chr_id                     okc_k_lines_b.chr_id%TYPE;
    l_asset_name                 varchar2(2000);
    l_prev_khr_id                NUMBER;
    l_asset_tbl                  asset_tbl;

    CURSOR check_top_line ( p_cle_id NUMBER ) IS
       SELECT chr_id
       FROM okc_k_lines_b
       WHERE id = p_cle_id;

    CURSOR top_line_asset ( p_cle_id NUMBER ) IS
            SELECT name
            FROM  okc_k_lines_v
            WHERE id = p_cle_id;

    CURSOR derive_top_line_id (p_lsm_id   NUMBER) IS
           SELECT FA.ID
           FROM OKC_K_HEADERS_B CHR,
                OKC_K_LINES_B TOP_CLE,
                OKC_LINE_STYLES_b TOP_LSE,
                OKC_K_LINES_B SUB_CLE,
                OKC_LINE_STYLES_b SUB_LSE,
                OKC_K_ITEMS CIM,
                OKC_K_LINES_V  FA,
                OKC_LINE_STYLES_B AST_LSE,
                OKL_CNSLD_AR_STRMS_B LSM
            WHERE
                CHR.ID           = TOP_CLE.DNZ_CHR_ID              AND
                TOP_CLE.LSE_ID   = TOP_LSE.ID                      AND
                TOP_LSE.LTY_CODE IN('SOLD_SERVICE','FEE')          AND
                TOP_CLE.ID       = SUB_CLE.CLE_ID                  AND
                SUB_CLE.LSE_ID   = SUB_LSE.ID                      AND
                SUB_LSE.LTY_CODE IN ('LINK_SERV_ASSET', 'LINK_FEE_ASSET') AND
                SUB_CLE.ID       =  LSM.KLE_ID                     AND
                LSM.ID           =  p_lsm_id                       AND
                CIM.CLE_ID       = SUB_CLE.ID                      AND
                CIM.JTOT_OBJECT1_CODE = 'OKX_COVASST'              AND
                CIM.OBJECT1_ID1  = FA.ID                           AND
                FA.LSE_ID        = AST_LSE.ID                      AND
                AST_LSE.LTY_CODE = 'FREE_FORM1';


    CURSOR inv_format_csr ( p_format_id IN NUMBER, p_stream_id IN NUMBER ) IS
		      SELECT
				inf.name inf_name,
				inf.contract_level_yn,
				ity.id ity_id,
		        ity.name ity_name,
				ity.group_asset_yn,
				ity.group_by_contract_yn,
				ilt.id	ilt_id,
				ilt.sequence_number,
				ilt.name ilt_name,
       			sty.name sty_name
	           FROM   okl_invoice_formats_v   inf,
       			      okl_invoice_types_v     ity,
       			      okl_invc_line_types_v   ilt,
       			      okl_invc_frmt_strms_v   frs,
       			      okl_strm_type_v         sty
		      WHERE   inf.id                  = p_format_id
		      AND     ity.inf_id              = inf.id
		      AND     ilt.ity_id              = ity.id
		      AND     frs.ilt_id              = ilt.id
		      AND     sty.id                  = frs.sty_id
		      AND	  frs.sty_id		      = p_stream_id;

    CURSOR inv_format_default_csr ( p_format_id IN NUMBER ) IS
	 	     SELECT
    		  	inf.name inf_name,
    			inf.contract_level_yn,
    			ity.id ity_id,
            	ity.name ity_name,
    			ity.group_asset_yn,
    			ity.group_by_contract_yn,
    			ilt.id ilt_id,
    			ilt.sequence_number,
    			ilt.name ilt_name
       		 FROM    okl_invoice_formats_v   inf,
      		  		 okl_invoice_types_v     ity,
            		 okl_invc_line_types_v   ilt
    		 WHERE   inf.id                 = p_format_id
    		 AND     ity.inf_id             = inf.id
    		 AND     ilt.ity_id             = ity.id
    		 AND 	inf.ilt_id 				= ilt.id;

    l_cons_invoice_num 	OKL_CNSLD_AR_HDRS_B.CONSOLIDATED_INVOICE_NUMBER%TYPE;
    l_invoice_format	OKL_INVOICE_FORMATS_V.NAME%TYPE;
    l_sty_name          OKL_STRM_TYPE_V.NAME%TYPE;

    l_old_cnr_id        NUMBER;
    l_old_lln_id        NUMBER;
    l_cnt               NUMBER;

    -- Get all Streams and cache locally
    CURSOR strm_csr_perf IS
	       SELECT id, name
	       FROM okl_strm_type_v;

    TYPE stream_rec_type IS RECORD (
             id            okl_strm_type_v.id%TYPE,
             name          okl_strm_type_v.name%TYPE);

    TYPE stream_table IS TABLE OF stream_rec_type
        INDEX BY BINARY_INTEGER;

    l_stream_table  stream_table;

    -- Get invoice formats and cache locally
    CURSOR inv_format_csr_perf IS
		      SELECT
                inf.id inf_id,
				inf.name inf_name,
				inf.contract_level_yn,
				ity.id ity_id,
		        ity.name ity_name,
				ity.group_asset_yn,
				ity.group_by_contract_yn,
				ilt.id	ilt_id,
				ilt.sequence_number,
				ilt.name ilt_name,
       			sty.name sty_name,
       			frs.sty_id  sty_id
	           FROM   okl_invoice_formats_v   inf,
       			      okl_invoice_types_v     ity,
       			      okl_invc_line_types_v   ilt,
       			      okl_invc_frmt_strms_v   frs,
       			      okl_strm_type_v         sty
		      WHERE   ity.inf_id              = inf.id
		      AND     ilt.ity_id              = ity.id
		      AND     frs.ilt_id              = ilt.id
		      AND     sty.id                  = frs.sty_id
           UNION -- default invlice format
   	 	     SELECT
   	 	        inf.id inf_id,
    		  	inf.name inf_name,
    			inf.contract_level_yn,
    			ity.id ity_id,
            	ity.name ity_name,
    			ity.group_asset_yn,
    			ity.group_by_contract_yn,
    			ilt.id ilt_id,
    			ilt.sequence_number,
    			ilt.name ilt_name,
       			'DEFAULT FORMAT' sty_name,
       			NULL
       		 FROM    okl_invoice_formats_v   inf,
      		  		 okl_invoice_types_v     ity,
            		 okl_invc_line_types_v   ilt
    		 WHERE   ity.inf_id             = inf.id
    		 AND     ilt.ity_id             = ity.id
    		 AND 	inf.ilt_id 				= ilt.id;
    TYPE inv_format_type IS RECORD (
                inf_id               okl_invoice_formats_v.id%type,
				inf_name             okl_invoice_formats_v.name%type,
				contract_level_yn    okl_invoice_formats_v.contract_level_yn%type,
				ity_id               okl_invoice_types_v.id%type,
		        ity_name             okl_invoice_types_v.name%type,
				group_asset_yn       okl_invoice_types_v.group_asset_yn%type,
				group_by_contract_yn okl_invoice_types_v.group_by_contract_yn%type,
				ilt_id               okl_invc_line_types_v.id%type,
				sequence_number      okl_invc_line_types_v.sequence_number%type,
				ilt_name             okl_invc_line_types_v.name%type,
       			sty_name             okl_strm_type_v.name%type,
       			sty_id               okl_invc_frmt_strms_v.sty_id%type);

    TYPE inv_format_table IS TABLE OF inv_format_type
        INDEX BY BINARY_INTEGER;

    l_inv_format_table  inv_format_table;
    l_lln_tbl           lln_tbl_type;
    l_line_counter      NUMBER := 0;
    l_inf_id            okl_invoice_formats_v.id%type;
    l_sty_id            okl_invc_frmt_strms_v.sty_id%type;
    l_loop_counter      NUMBER := 0;
    l_asset_counter     NUMBER := 0;

    -- fmiao - Bug#5232919 - Modified - Start
    -- query the effective dates of the invoice message to restrict the messages
    -- based on the consolidated invoice date
    CURSOR msg_csr_perf IS
   	   SELECT id, priority, pkg_name, proc_name
                    , start_date, end_date
	   FROM okl_invoice_mssgs_v;
    -- fmiao - Bug#5232919 - Modified - End

BEGIN

-- rmunjulu R12 Fixes -- comment out entire code and put NULL
NULL;
/*
	x_return_status := Okl_Api.G_RET_STS_SUCCESS;
 	PRINT_TO_LOG( 'Total rec count is : '||p_cons_bill_tbl.count);

    g_cons_bill_tbl := p_cons_bill_tbl.count;

    if p_cons_bill_tbl.count > 0 then
      if l_stream_table.COUNT = 0 then
        open strm_csr_perf;
        loop
           fetch strm_csr_perf bulk collect into l_stream_table;
           exit when strm_csr_perf%notfound;
        end loop;
        close strm_csr_perf;
      end if;

      if l_inv_format_table.COUNT = 0 then
        open inv_format_csr_perf;
        loop
           fetch inv_format_csr_perf bulk collect into l_inv_format_table;
           exit when inv_format_csr_perf%notfound;
        end loop;
        close inv_format_csr_perf;
      end if;

	  -- Cache messages
      if g_msg_tbl.COUNT = 0 then
        open msg_csr_perf;
        loop
           fetch msg_csr_perf bulk collect into g_msg_tbl;
           exit when msg_csr_perf%notfound;
        end loop;
        close msg_csr_perf;
       end if;
    end if;


    FOR k IN p_cons_bill_tbl.FIRST..p_cons_bill_tbl.LAST LOOP

        --MDOKAL
        if p_cons_bill_tbl(k).sty_id <> nvl(l_sty_id, 1) then

           l_sty_name := NULL;
           for t in l_stream_table.first..l_stream_table.count loop
             if p_cons_bill_tbl(k).sty_id = l_stream_table(t).id then
               l_sty_name := l_stream_table(t).name;
               exit;
            end if;
           end loop;
        end if;

    	PRINT_TO_LOG( '*** CONSOLIDATION DETAILS      ***');
    	PRINT_TO_LOG( '*** PREVIOUS RECORD WAS FOR:     ***');
    	PRINT_TO_LOG( '*** ++++++++++++++++++++++++++++ ***');
    	PRINT_TO_LOG( '*    ====>  CUSTOMER_ID: '||p_saved_bill_rec.l_customer_id||' CURRENCY: '||p_saved_bill_rec.l_currency);
    	PRINT_TO_LOG( '*    ====>  BILL_TO_SITE: '||p_saved_bill_rec.l_bill_to_site||' PAYMENT_METHOD: '||p_saved_bill_rec.l_payment_method);
    	PRINT_TO_LOG( '*    ====>  PRIVATE_LABEL: '||NVL(p_saved_bill_rec.l_private_label,'N/A')||' DATE_CONSOLIDATED: '||TRUNC(p_saved_bill_rec.l_date_consolidated));
    	PRINT_TO_LOG( '*    ====>  CONTRACT_ID: '||p_saved_bill_rec.l_prev_khr_id||' INVOICE GROUP ID: '||p_saved_bill_rec.l_saved_format_id);
    	PRINT_TO_LOG( '*    ====>  ORIGINAL CONS INV (For credit memos): '||p_saved_bill_rec.l_saved_prev_cons_num);
    	PRINT_TO_LOG( '*    ====>  Overall Error Status: '||p_saved_bill_rec.l_overall_status);
    	PRINT_TO_LOG( '*** ++++++++++++++++++++++++++++ ***');

    	PRINT_TO_LOG( '*** CURRENT RECORD IS FOR:     ***');
    	PRINT_TO_LOG( '*** ++++++++++++++++++++++++++++ ***');
    	PRINT_TO_LOG( '*    ====>  CUSTOMER_ID: '||p_cons_bill_tbl(k).customer_id||' CURRENCY: '||p_cons_bill_tbl(k).currency);
    	PRINT_TO_LOG( '*    ====>  BILL_TO_SITE: '||p_cons_bill_tbl(k).bill_to_site||' PAYMENT_METHOD: '||p_cons_bill_tbl(k).payment_method);
    	PRINT_TO_LOG( '*    ====>  PRIVATE_LABEL: '||NVL(p_cons_bill_tbl(k).private_label,'N/A')||' DATE_CONSOLIDATED: '||TRUNC(p_cons_bill_tbl(k).date_consolidated));
    	PRINT_TO_LOG( '*    ====>  CONTRACT_ID: '||p_cons_bill_tbl(k).contract_id||' INVOICE GROUP ID: '||p_cons_bill_tbl(k).inf_id);
    	PRINT_TO_LOG( '*    ====>  ORIGINAL CONS INV (For credit memos): '||p_cons_bill_tbl(k).prev_cons_invoice_num);
    	PRINT_TO_LOG( '*** ++++++++++++++++++++++++++++ ***');
    	PRINT_TO_LOG( '*** END CONSOLIDATION DETAILS  ***');

		i:= 0;
   		PRINT_TO_LOG( '====>  Invoice Groups: Checking If Stream assigned to a Line Type.');

        --MDOKAL
        -- check if the last invoice format is still the required format
        -- to prevent unecessary looping.

        -- mdokal, Bug 4442702, nvl around parameters
        --vthiruva..Bug 4473916..05-JUL-05..modified AND to OR condition in IF clause
        if (nvl(p_cons_bill_tbl(k).inf_id , 0) <> nvl(l_inf_id, 1)
               or nvl(p_cons_bill_tbl(k).sty_id, 0) <> nvl(l_sty_id, 1)) then

           if l_inv_format_table.exists(1) then
            for j in l_inv_format_table.first..l_inv_format_table.count loop
             if (nvl(p_cons_bill_tbl(k).inf_id, 0) = nvl(l_inv_format_table(j).inf_id, 1) and
                p_cons_bill_tbl(k).sty_id = l_inv_format_table(j).sty_id) then
                l_format_name 		   := l_inv_format_table(j).inf_name;
    			l_contract_level_yn    := l_inv_format_table(j).contract_level_yn;
    			l_ity_id			   := l_inv_format_table(j).ity_id;
    			l_format_type		   := l_inv_format_table(j).ity_name;
    			l_group_asset_yn	   := l_inv_format_table(j).group_asset_yn;
    			l_group_by_contract_yn := l_inv_format_table(j).group_by_contract_yn;
    			l_ilt_id			   := l_inv_format_table(j).ilt_id;
    			l_sequence_number	   := l_inv_format_table(j).sequence_number;
    			l_cons_line_name 	   := l_inv_format_table(j).ilt_name;
           		l_stream_name		   := l_inv_format_table(j).sty_name;
           		l_inf_id               := l_inv_format_table(j).inf_id;
           		l_sty_id               := l_inv_format_table(j).sty_id;
           		i := i+1;
                exit;
     		  elsif (nvl(p_cons_bill_tbl(k).inf_id, 0) = nvl(l_inv_format_table(j).inf_id, 1))
     		    and i = 0
                and nvl(l_inv_format_table(j).sty_name, 'x') = 'DEFAULT FORMAT' then
   		        PRINT_TO_LOG( '====>  Invoice Groups: Stream not assigned to a Line Type.');
   		        PRINT_TO_LOG( '====>  Invoice Groups: Checking If Default Line Type exists. ');
                l_format_name 		   := l_inv_format_table(j).inf_name;
    			l_contract_level_yn    := l_inv_format_table(j).contract_level_yn;
    			l_ity_id			   := l_inv_format_table(j).ity_id;
    			l_format_type		   := l_inv_format_table(j).ity_name;
    			l_group_asset_yn	   := l_inv_format_table(j).group_asset_yn;
    			l_group_by_contract_yn := l_inv_format_table(j).group_by_contract_yn;
    			l_ilt_id			   := l_inv_format_table(j).ilt_id;
    			l_sequence_number	   := l_inv_format_table(j).sequence_number;
    			l_cons_line_name 	   := l_inv_format_table(j).ilt_name;
           		l_stream_name		   := null;
           		l_inf_id               := l_inv_format_table(j).inf_id;
           		l_sty_id               := l_inv_format_table(j).sty_id;
                exit;
              else
                l_format_name 		   := null;
    			l_contract_level_yn    := null;
    			l_ity_id			   := null;
    			l_format_type		   := null;
    			l_group_asset_yn	   := null;
    			l_group_by_contract_yn := null;
    			l_ilt_id			   := null;
    			l_sequence_number	   := null;
    			l_cons_line_name 	   := null;
           		l_stream_name		   := null;
           		l_inf_id               := null;
           		l_sty_id               := null;
     		  end if;
		     end loop;
		    end if;
        end if;

   		PRINT_TO_LOG( '*** Qualifying Invoice Group Details ***');
   		PRINT_TO_LOG( '*    ====>  NAME: '||l_format_name);
   		PRINT_TO_LOG( '*    ====>  CONTRACT_LEVEL_YN: '||l_contract_level_yn);
   		PRINT_TO_LOG( '*    ====>  INVOICE TYPE NAME: '||l_format_type||' With Id of:  '||l_ity_id);
   		PRINT_TO_LOG( '*    ====>  GROUP_ASSET_YN: '||l_group_asset_yn);
   		PRINT_TO_LOG( '*    ====>  LINE NAME: '||l_cons_line_name||' With Id of: '||l_ilt_id);
   		PRINT_TO_LOG( '*    ====>  SEQUENCE NUMBER: '||l_sequence_number);
   		PRINT_TO_LOG( '*** End Invoice Group Details        ***');

     	IF ( 	(p_cons_bill_tbl(k).customer_id   = p_saved_bill_rec.l_customer_id)
            AND (p_cons_bill_tbl(k).currency      = p_saved_bill_rec.l_currency)
            AND (p_cons_bill_tbl(k).bill_to_site  = p_saved_bill_rec.l_bill_to_site)
            AND (NVL(p_cons_bill_tbl(k).payment_method,-999)= NVL(p_saved_bill_rec.l_payment_method,-999))
            AND (NVL(p_cons_bill_tbl(k).private_label,'N/A') = NVL(p_saved_bill_rec.l_private_label,'N/A'))
            AND (TRUNC(p_cons_bill_tbl(k).date_consolidated) = TRUNC(p_saved_bill_rec.l_date_consolidated) )
            AND	(p_cons_bill_tbl(k).ity_id = p_saved_bill_rec.l_saved_ity_id)    --bug 5138822
            AND	(p_cons_bill_tbl(k).inf_id = p_saved_bill_rec.l_saved_format_id)
            AND (p_cons_bill_tbl(k).prev_cons_invoice_num = p_saved_bill_rec.l_saved_prev_cons_num)
	       )
        THEN
		        PRINT_TO_LOG( '====>  No Break Detected, Check Contract Level YN: '||l_contract_level_yn);
	        	-- -------------------------------------------------------------------
	        	-- Check multi-contract invoices
	        	-- -------------------------------------------------------------------
	        	IF ( p_saved_bill_rec.l_prev_khr_id <> p_cons_bill_tbl(k).contract_id ) THEN

                    IF (l_contract_level_yn = 'Y') THEN
                        PRINT_TO_LOG( '====> Reusing CNR_ID, as Contract Level YN is Y : '||p_saved_bill_rec.l_cnr_id);
                    ELSE
                        -- ---------------------------
                        -- Process Header Break Logic
                        -- ---------------------------

                        process_break(p_contract_number,
	                                  p_commit,
                                      p_saved_bill_rec,
                                      p_update_tbl);

                        -- Reset update table after processing
                        p_update_tbl     := l_update_tbl;

                        -- ------------------------------------
                        -- Finish post header break detection logic
                        -- ------------------------------------

                        PRINT_TO_LOG( '====> Create new Invoice as Contract Level YN is N.');
                        l_cnr_id := NULL;

                        PRINT_TO_LOG( '*** CREATE CONSOLIDATED INVOICE HEADER ***');
                        l_cons_inv_num := NULL;

                        create_new_invoice(
					       p_cons_bill_tbl(k).bill_to_site,
		  			       p_cons_bill_tbl(k).customer_id,
		  			       p_cons_bill_tbl(k).currency,
		  			       p_cons_bill_tbl(k).payment_method,
		  			       p_cons_bill_tbl(k).inf_id,
		  			       p_cons_bill_tbl(k).set_of_books_id,
		  			       p_cons_bill_tbl(k).private_label,
					       p_cons_bill_tbl(k).date_consolidated,
					       p_cons_bill_tbl(k).org_id,
					       p_cons_bill_tbl(k).legal_entity_id, -- for LE Uptake project 08-11-2006
					       g_last_rec,
					       l_cnr_id,
                           l_cons_inv_num);

                       p_saved_bill_rec.l_cnr_id        := l_cnr_id;
                       p_saved_bill_rec.l_cons_inv_num  := l_cons_inv_num;

	                   PRINT_TO_LOG( '*** DONE CREATION OF CONSOLIDATED INVOICE HEADER.Assigned Id: '||l_cnr_id||' ***'||'p_saved_bill_rec.l_cons_inv_num: '||p_saved_bill_rec.l_cons_inv_num );
                    END IF;
	        	ELSE
            	       PRINT_TO_LOG( '====> Reusing CNR_ID (Same Contract) : '||l_cnr_id);
	        	END IF;

	        	PRINT_TO_LOG( '*** ++++++++++++++++++++++++++++ ***');
	        	PRINT_TO_LOG( '*** CHECK IF A CONSOLIDATED LINE EXISTS ***');
	        	l_lln_id := NULL;
	        	line_exist (l_cnr_id,
		  	 	    p_cons_bill_tbl(k).contract_id,
					p_cons_bill_tbl(k).kle_id,
					l_ilt_id,
					l_sequence_number,
					l_group_by_contract_yn,
					l_group_asset_yn,
					l_lln_id,
					l_funct_return
					);

                p_saved_bill_rec.l_lln_id := l_lln_id;

	        	PRINT_TO_LOG( '*** END CHECK FOR CONSOLIDATED LINE ***');
	        	PRINT_TO_LOG( '*** ++++++++++++++++++++++++++++ ***');

	        	IF l_funct_return = 'N' THEN
                    -- -----------------------------------------------------
                    -- Line break detected, update LLN record with amount
                    -- -----------------------------------------------------

	        	    PRINT_TO_LOG( '*** CREATE CONSOLIDATED INVOICE LINE *** for CNR_ID: '||l_cnr_id);
	        	    l_lln_id := NULL;
                    l_cnr_id := p_saved_bill_rec.l_cnr_id;

	        	    create_new_line(
					  	 p_cons_bill_tbl(k).contract_id,
					  	 l_cnr_id,
					  	 p_cons_bill_tbl(k).kle_id,
					  	 l_ilt_id,
					  	 p_cons_bill_tbl(k).currency,
					  	 l_sequence_number,
					  	 'CHARGE',
						 l_group_by_contract_yn,
						 l_group_asset_yn,
						 l_contract_level_yn,
						 l_lln_id
		 			  	 );

                p_saved_bill_rec.l_lln_id := l_lln_id;
	        	PRINT_TO_LOG( '*** DONE CREATION OF CONSOLIDATED INVOICE LINE.Assigned Id: '||l_lln_id||' ***');
	        	END IF;
	ELSE -- 'ELSE' for the Uppermost level 'IF' for hierarchy checks

        -- ------------------------------------
        -- Start header break detection logic
        -- ------------------------------------

                        process_break(p_contract_number,
	                                  p_commit,
                                      p_saved_bill_rec,
                                      p_update_tbl);

        -- Reset update table after processing
        p_update_tbl     := l_update_tbl;

         -- ------------------------------------
         -- Finish post header break detection logic
         -- ------------------------------------

        -- -----------------------------------
		-- Break detected
        -- -----------------------------------
		PRINT_TO_LOG( '====> Break Detected.');
   	    PRINT_TO_LOG( '*** CREATE CONSOLIDATED INVOICE HEADER ***');
		-- Null out current value in local variable.
		l_cnr_id        := NULL;
        l_cons_inv_num  := NULL;

        create_new_invoice(
			 p_cons_bill_tbl(k).bill_to_site,
			 p_cons_bill_tbl(k).customer_id,
			 p_cons_bill_tbl(k).currency,
	 		 p_cons_bill_tbl(k).payment_method,
		  	 p_cons_bill_tbl(k).inf_id,
		  	 p_cons_bill_tbl(k).set_of_books_id,
		  	 p_cons_bill_tbl(k).private_label,
			 p_cons_bill_tbl(k).date_consolidated,
			 p_cons_bill_tbl(k).org_id,
			 p_cons_bill_tbl(k).legal_entity_id, -- for LE Uptake project 08-11-2006
			 g_last_rec,
			 l_cnr_id,
             l_cons_inv_num);

        p_saved_bill_rec.l_cnr_id        := l_cnr_id;
        p_saved_bill_rec.l_cons_inv_num  := l_cons_inv_num;

        PRINT_TO_LOG( '*** DONE CREATION OF CONSOLIDATED INVOICE HEADER.Assigned Id: '||l_cnr_id||' ***'||'p_saved_bill_rec.l_cons_inv_num: '||p_saved_bill_rec.l_cons_inv_num );

   	    PRINT_TO_LOG( '*** CREATE CONSOLIDATED INVOICE LINE *** for CNR_ID '||l_cnr_id);
		-- Null out current value in local variable.
		l_lln_id := NULL;

        l_cnr_id := p_saved_bill_rec.l_cnr_id;
  	 	create_new_line(
		  	 p_cons_bill_tbl(k).contract_id,
		  	 l_cnr_id,
		  	 p_cons_bill_tbl(k).kle_id,
		  	 l_ilt_id,
		  	 p_cons_bill_tbl(k).currency,
		  	 l_sequence_number,
		  	 'CHARGE',
			 l_group_by_contract_yn,
			 l_group_asset_yn,
			 l_contract_level_yn,
			 l_lln_id);

        p_saved_bill_rec.l_lln_id := l_lln_id;

        PRINT_TO_LOG( '*** DONE CREATION OF CONSOLIDATED INVOICE LINE.Assigned Id: '||l_lln_id||' ***');
	END IF;
 	PRINT_TO_LOG( '*** CREATE CONSOLIDATED INVOICE STREAMS *** for CNR_ID: '||l_cnr_id||' and LLN_ID: '||l_lln_id);
	--Null out local variable.
	l_lsm_id := null;

    l_lln_id := p_saved_bill_rec.l_lln_id;

	create_new_streams(
	  		l_lln_id,
	  		p_cons_bill_tbl(k).sty_id,
	  		p_cons_bill_tbl(k).kle_id,
			p_cons_bill_tbl(k).contract_id,
			p_cons_bill_tbl(k).amount,
            p_cons_bill_tbl(k).sel_id,
            l_cnr_id,
			l_lsm_id,
			x_return_status);

    PRINT_TO_LOG( '*** DONE CREATION OF CONSOLIDATED INVOICE STREAMS.Assigned Id: '||l_lsm_id||' ***');


	--Set local variables to cursor values for
	--comparison purposes
	p_saved_bill_rec.l_customer_id   		 := p_cons_bill_tbl(k).customer_id;
  	p_saved_bill_rec.l_currency	   	 	     := p_cons_bill_tbl(k).currency;
	p_saved_bill_rec.l_bill_to_site		 	 := p_cons_bill_tbl(k).bill_to_site;
	p_saved_bill_rec.l_payment_method		 := p_cons_bill_tbl(k).payment_method;
	p_saved_bill_rec.l_private_label		 := p_cons_bill_tbl(k).private_label;
	p_saved_bill_rec.l_date_consolidated	 := p_cons_bill_tbl(k).date_consolidated;
	p_saved_bill_rec.l_saved_ity_id          := p_cons_bill_tbl(k).ity_id; -- 5138822
	p_saved_bill_rec.l_saved_format_id       := p_cons_bill_tbl(k).inf_id;
	p_saved_bill_rec.l_prev_khr_id           := p_cons_bill_tbl(k).contract_id;
	p_saved_bill_rec.l_saved_prev_cons_num   := p_cons_bill_tbl(k).prev_cons_invoice_num;
    p_saved_bill_rec.l_commit_cnt            := NVL(p_saved_bill_rec.l_commit_cnt,0) + 1;

    -- -----------------------
    -- Work out asset name
    -- -----------------------
    l_chr_id := NULL;

--MDOKAL

  l_asset_name := NULL;

  IF p_cons_bill_tbl(k).contract_id = p_saved_bill_rec.l_prev_khr_id  then

    if l_asset_tbl.count > 0 then
      for l in l_asset_tbl.FIRST..l_asset_tbl.LAST loop
         if l_asset_tbl(l).id = p_cons_bill_tbl(k).kle_id then
            l_asset_name := l_asset_tbl(l).name;
            exit;
         end if;
      end loop;
    end if;
  ELSE
     l_asset_tbl.delete;
  END IF;

    if l_asset_name is null then
       OPEN  check_top_line( p_cons_bill_tbl(k).kle_id );
       FETCH check_top_line INTO l_chr_id;
       CLOSE check_top_line;

       IF l_chr_id IS NOT NULL THEN
          l_kle_id := p_cons_bill_tbl(k).kle_id;
       ELSE
          l_top_kle_id := NULL;
          OPEN  derive_top_line_id ( l_lsm_id );
          FETCH derive_top_line_id INTO l_top_kle_id;
          CLOSE derive_top_line_id;
          l_kle_id := l_top_kle_id;
       END IF;

       l_asset_name := NULL;
       OPEN  top_line_asset ( l_kle_id );
       FETCH top_line_asset INTO l_asset_name;
       CLOSE top_line_asset;

      l_asset_counter := l_asset_counter + 1;
      l_asset_tbl(l_asset_counter).id  := p_cons_bill_tbl(k).kle_id;
      l_asset_tbl(l_asset_counter).name  := l_asset_name;

     end if;

    -- --------------------------
    -- Index counter
    -- --------------------------
    l_cnt := p_update_tbl.count;
    l_cnt := l_cnt + 1;

    PRINT_TO_LOG( 'DEL Updates (p_saved_bill_rec.l_cons_inv_num)'||p_saved_bill_rec.l_cons_inv_num);
    PRINT_TO_LOG( 'DEL Updates (l_format_name)'||l_format_name);

    p_update_tbl(l_cnt).cnr_id			    := p_saved_bill_rec.l_cnr_id;
    p_update_tbl(l_cnt).cons_inv_number     := p_saved_bill_rec.l_cons_inv_num;
    p_update_tbl(l_cnt).lln_id			    := p_saved_bill_rec.l_lln_id;
    p_update_tbl(l_cnt).lsm_id			    := l_lsm_id;
    p_update_tbl(l_cnt).asset_number        := l_asset_name;
    p_update_tbl(l_cnt).invoice_format      := l_format_name;
    p_update_tbl(l_cnt).line_type           := l_cons_line_name;
    p_update_tbl(l_cnt).sty_name            := l_sty_name;
    p_update_tbl(l_cnt).contract_number     := p_cons_bill_tbl(k).contract_number;

    -- Start; Bug 4525643; STMATHEW
    p_update_tbl(l_cnt).private_label     := p_cons_bill_tbl(k).private_label;
    -- End; Bug 4525643; STMATHEW

    p_update_tbl(l_cnt).lsm_amount          := p_cons_bill_tbl(k).amount;
    p_update_tbl(l_cnt).xsi_id			    := p_cons_bill_tbl(k).xsi_id;
    p_update_tbl(l_cnt).xls_id			    := p_cons_bill_tbl(k).xls_id;

    if p_saved_bill_rec.l_cnr_id = l_old_cnr_id then
      p_update_tbl(l_cnt).cnr_total           := p_update_tbl(l_cnt).cnr_total + p_cons_bill_tbl(k).amount;
    else
      p_update_tbl(l_cnt).cnr_total           := p_cons_bill_tbl(k).amount;
      l_old_cnr_id := p_saved_bill_rec.l_cnr_id;
    end if;

    if p_saved_bill_rec.l_lln_id = l_old_lln_id then
      p_update_tbl(l_cnt).lln_total           := p_update_tbl(l_cnt).lln_total + p_cons_bill_tbl(k).amount;
    else
      p_update_tbl(l_cnt).lln_total           := p_cons_bill_tbl(k).amount;
      l_old_lln_id := p_saved_bill_rec.l_lln_id;
    end if;

    END LOOP;

*/
EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN OTHERS THEN
        IF (L_DEBUG_ENABLED='Y' and FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_cons_bill',
               'EXCEPTION :'||'OTHERS');
        END IF;

	    PRINT_TO_LOG('*=> Error Message(O3): '||SQLERRM);
        x_return_status := 'E';

END process_cons_bill_tbl;

PROCEDURE create_cons_bill(
           p_contract_number              IN  VARCHAR2,
	       p_api_version                  IN  NUMBER,
    	   p_init_msg_list                IN  VARCHAR2,
           p_commit                       IN  VARCHAR2,
           p_inv_msg                      IN  VARCHAR2,
           p_assigned_process             IN  VARCHAR2,
    	   x_return_status                OUT NOCOPY VARCHAR2,
    	   x_msg_count                    OUT NOCOPY NUMBER,
    	   x_msg_data                     OUT NOCOPY VARCHAR2)

IS

-- ------------------------------------------------------------------------
-- Cursor for consolidated invoices having headers, lines and details for
-- a txn.  Excludes UBB records, Quote and Collections records
-- ------------------------------------------------------------------------
CURSOR C IS
	--start modified abhsaxen for performance SQLID 20563033
		SELECT
	xsib.customer_id	 customer_id,
	xsib.currency_code currency,
	xsib.customer_address_id	 bill_to_site,
	xsib.receipt_method_id	 payment_method,
	xsit.xtrx_private_label	 private_label,
	TRUNC(xsiB.TRX_DATE)	 date_consolidated,
	NVL(
		nvl(
		(SELECT ity.id ity_id
		 FROM  okl_invoice_types_b     ity,
			okl_invc_line_types_b   ilt,
			okl_invc_frmt_strms   frs
		WHERE    ity.inf_id    = inf.id
			AND     ilt.ity_id     = ity.id
			AND     frs.ilt_id     = ilt.id
			AND     tld.sty_id     = frs.sty_id),
		 (select ity1.id
		 from okl_invoice_types_b ity1,
				  okl_invc_line_types_b ilt1
		  where ilt1.id = inf.ilt_id
			and ilt1.ity_id = ity1.id)),  -1
	) inv_type,
	xsib.inf_id         inf_id,
	tai.khr_id	contract_id,
	chr.contract_number  contract_number,
	'-1'                  prev_cons_invoice_num,
	xsib.org_id	 org_id,
	xsib.set_of_books_id set_of_books_id,
	til.kle_id	kle_id,
	tld.sty_id	stream_id,
	xsib.id		 xsi_id,
	xls.id		xls_id,
	xls.amount	c_amount,
	xls.sel_id       sel_id,
	xsib.legal_entity_id  legal_entity_id -- for LE Uptake project 08-11-2006
	FROM
	okl_ext_sell_invs_b	   xsib,
	okl_ext_sell_invs_tl	   xsit,
	okl_xtl_sell_invs_b	   xls,
	okl_txd_ar_ln_dtls_b   tld,
	okl_txl_ar_inv_lns_b   til,
	okl_trx_ar_invoices_b  tai,
	okc_k_headers_b	       chr,
	okl_invoice_formats_b   inf, -- 5138822
	okl_parallel_processes pws
	WHERE
	xsiB.TRX_STATUS_CODE    = 'SUBMITTED' AND
	xls.xsi_id_details 	   = xsiB.id		AND
	tld.id				   = xls.tld_id AND
	til.id				   = tld.TIL_ID_DETAILS AND
	tai.id				   = til.tai_id 		AND
	tai.khr_id             = chr.id
	AND
	chr.contract_number    = NVL(p_contract_number,chr.contract_number) AND
	tai.clg_id			   IS NULL				AND
	tai.cpy_id			   IS NULL				AND
	tai.qte_id			   IS NULL				AND
	xls.amount >=0                              AND
	xsiB.inf_id           = inf.id (+)           AND
	pws.object_type = 'CUSTOMER'           AND
	XSIB.CUSTOMER_ID = to_number(pws.object_value) AND
	pws.assigned_process = p_assigned_process    AND
	XSIB.ID = XSIT.ID
	and XSIT.LANGUAGE = USERENV('LANG')
	UNION
	SELECT
	xsib.customer_id			   	 customer_id,
	xsib.currency_code   		 currency,
	xsib.customer_address_id		 bill_to_site,
	xsib.receipt_method_id		 payment_method,
	xsit.xtrx_private_label		 private_label,
	TRUNC(xsib.TRX_DATE)			 date_consolidated,
	NVL(
	NVL((SELECT ity.id ity_id
	FROM  okl_invoice_types_b     ity,
	okl_invc_line_types_b   ilt,
	okl_invc_frmt_strms   frs
	WHERE    ity.inf_id    = inf.id
	AND     ilt.ity_id     = ity.id
	AND     frs.ilt_id     = ilt.id
	AND     tld.sty_id     = frs.sty_id),
		 (select ity1.id from okl_invoice_types_b ity1,
				   okl_invc_line_types_b ilt1
	where ilt1.id = inf.ilt_id
		  and ilt1.ity_id = ity1.id)),  -1
	) inv_type,                            -- bug 5138822
	xsib.inf_id                   inf_id,
	tai.khr_id					 contract_id, -- get contract Id
	chr.contract_number          contract_number,
	'-1'                         prev_cons_invoice_num,
	xsib.org_id					 org_id,
	xsib.set_of_books_id			 set_of_books_id,
	til.kle_id					 kle_id,
	tld.sty_id					 stream_id, -- to get the line seq #
	xsib.id						 xsi_id,
	xls.id						 xls_id,
	xls.amount					 c_amount,
	xls.sel_id                   sel_id,
	xsib.legal_entity_id                      legal_entity_id -- for LE Uptake project 08-11-2006
	FROM
	okl_ext_sell_invs_b	   xsib,
	okl_ext_sell_invs_tl	   xsit,
	okl_xtl_sell_invs_b	   xls,
	okl_txd_ar_ln_dtls_b   tld,
	okl_txl_ar_inv_lns_b   til,
	okl_trx_ar_invoices_b  tai,
	okc_k_headers_b	       chr,
	okl_invoice_formats_b   inf  -- 5138822
	WHERE
	xsib.TRX_STATUS_CODE    = 'SUBMITTED' AND
	xls.xsi_id_details 	   = xsib.id		AND
	tld.id				   = xls.tld_id AND
	til.id				   = tld.TIL_ID_DETAILS AND
	tai.id				   = til.tai_id 		AND
	tai.khr_id             = chr.id
	AND
	chr.contract_number    = p_contract_number AND
	tai.clg_id			   IS NULL				AND
	tai.cpy_id			   IS NULL				AND
	tai.qte_id			   IS NULL				AND
	xls.amount >= 0                             AND
	xsib.inf_id           = inf.id (+)          and
	XSIB.ID = XSIT.ID and
	XSIT.LANGUAGE = USERENV('LANG')
	ORDER BY 1,2,3,4,5,6,7,8,9,10
	--end modified abhsaxen for performance SQLID 20563033
	;
---------------------------------------------------------------------------
-- Cursor for consolidated invoices having only headers and lines for a txn
-- Excludes UBB records, Quote and Collections records
---------------------------------------------------------------------------
CURSOR c1 IS SELECT
	   	 		xsi.customer_id			   	 customer_id,
				xsi.currency_code   		 currency,
				xsi.customer_address_id		 bill_to_site,
				xsi.receipt_method_id		 payment_method,
				xsi.xtrx_private_label		 private_label,
				TRUNC(xsi.TRX_DATE)			 date_consolidated,
				NVL(
				    NVL((SELECT ity.id ity_id
       			         FROM  okl_invoice_types_b     ity,
       			               okl_invc_line_types_b   ilt,
       			               okl_invc_frmt_strms   frs
		                 WHERE    ity.inf_id    = inf.id
		                 AND     ilt.ity_id     = ity.id
		                 AND     frs.ilt_id     = ilt.id
		                 AND     til.sty_id     = frs.sty_id),
						 (select ity1.id from okl_invoice_types_b ity1,
						                   okl_invc_line_types_b ilt1
			              where ilt1.id = inf.ilt_id
						  and ilt1.ity_id = ity1.id)),  -1
				   ) inv_type,                            -- bug 5138822
                xsi.inf_id                   inf_id,
				tai.khr_id					 contract_id,
                chr.contract_number          contract_number,
                '-1'                         prev_cons_invoice_num,
				xsi.org_id					 org_id,
				xsi.set_of_books_id			 set_of_books_id,
				til.kle_id					 kle_id,
				til.sty_id					 stream_id,
				xsi.id						 xsi_id,
				xls.id						 xls_id,
				xls.amount					 c1_amount,
                                xls.sel_id                   sel_id,
                 		xsi.legal_entity_id          legal_entity_id -- for LE Uptake project 08-11-2006
	     	 FROM
				okl_ext_sell_invs_v	   xsi,
				okl_xtl_sell_invs_v	   xls,
				okl_txl_ar_inv_lns_v   til,
				okl_trx_ar_invoices_v  tai,
                okc_k_headers_b	       chr,
				okl_invoice_formats_b   inf, -- 5138822
                okl_parallel_processes pws
			 WHERE
				xsi.TRX_STATUS_CODE    = 'SUBMITTED' AND
				xls.xsi_id_details 	   = xsi.id		 AND
				til.id				   = xls.til_id  AND
				tai.id				   = til.tai_id  AND
                tai.khr_id             = chr.id    AND
                -- Contract Specific consolidation
                chr.contract_number    = NVL(p_contract_number,chr.contract_number) AND
                -- Contract Specific consolidation
  				tai.clg_id			   IS NULL		AND
				tai.cpy_id			   IS NULL		AND
				tai.qte_id			   IS NULL		AND
				xls.amount >= 0                     AND
				xsi.inf_id           = inf.id (+)   AND    -- 5138822
                pws.object_type = 'CUSTOMER'             AND
                XSI.CUSTOMER_ID = to_number(pws.object_value) AND
                pws.assigned_process = p_assigned_process
			 ORDER BY 1,2,3,4,5,6,7,8,9,10;

-- BUG#4621302
-- cursor to fetch the installed languages
CURSOR get_languages IS
   SELECT language_code
   FROM FND_LANGUAGES
   WHERE INSTALLED_FLAG IN ('I', 'B');

TYPE lang_tbl_type  IS TABLE OF get_languages%ROWTYPE INDEX BY BINARY_INTEGER;
l_lang_tbl  lang_tbl_type;
lang_count  NUMBER;
tl_count    NUMBER;

-- Billing performance fix
cons_bill_tbl        cons_bill_tbl_type;
saved_bill_rec       saved_bill_rec_type;
l_init_bill_rec      saved_bill_rec_type;

l_update_tbl         update_tbl_type;

-- ssiruvol - Bug#5354130 - Added - Start
-- temporary records for storing CNR table of records
l_cnr_tbl cnr_tbl_type;
-- ssiruvol - Bug#5354130 - Added - End

L_FETCH_SIZE         NUMBER := 5000;

l_cons_inv_num               okl_cnsld_ar_hdrs_v.consolidated_invoice_number%TYPE;
-- Billing performance fix

CURSOR line_seq_csr(p_cnr_id NUMBER) IS
	SELECT *
	FROM okl_cnsld_ar_lines_v
	WHERE cnr_id = p_cnr_id
	ORDER BY sequence_number;

	l_cnr_id					 NUMBER;
	l_lln_id					 NUMBER;
	l_lsm_id					 NUMBER;
	l_seq_num					 NUMBER;


	l_line_amount				NUMBER;
	l_consbill_amount			NUMBER;

    TYPE cnr_update_rec_type IS RECORD (
	 cnr_id			NUMBER,
	 lln_id			NUMBER,
	 lsm_id			NUMBER,
	 xsi_id			NUMBER,
	 xls_id			NUMBER,
	 return_status  VARCHAR2(1)
	);

    TYPE cnr_update_tbl_type IS TABLE OF cnr_update_rec_type
	     INDEX BY BINARY_INTEGER;

	cnr_update_tbl 				 cnr_update_tbl_type;
	cnr_tab_idx	  		NUMBER;

    -- In and Out records for the external sell invoice tables
	l_xsiv_rec     Okl_Xsi_Pvt.xsiv_rec_type;
	x_xsiv_rec     Okl_Xsi_Pvt.xsiv_rec_type;
 	null_xsiv_rec  Okl_Xsi_Pvt.xsiv_rec_type;

	l_xlsv_rec     Okl_Xls_Pvt.xlsv_rec_type;
	x_xlsv_rec     Okl_Xls_Pvt.xlsv_rec_type;
	null_xlsv_rec  Okl_Xls_Pvt.xlsv_rec_type;

	-- For Updating header and line amnounts and sequences
	u_cnrv_rec 	   Okl_Cnr_Pvt.cnrv_rec_type;
	x_cnrv_rec 	   Okl_Cnr_Pvt.cnrv_rec_type;
	null_cnrv_rec  Okl_Cnr_Pvt.cnrv_rec_type;

	u_llnv_rec 	   Okl_Lln_Pvt.llnv_rec_type;
	x_llnv_rec 	   Okl_Lln_Pvt.llnv_rec_type;
	null_llnv_rec  Okl_Lln_Pvt.llnv_rec_type;

    --All the below variables for a successful rules invocation
    l_rul_format_name	OKC_RULES_B.RULE_INFORMATION1%TYPE;
	l_init_msg_list 	VARCHAR2(1) ;
	l_msg_count 		NUMBER ;
	l_msg_data 			VARCHAR2(2000);
	l_rulv_rec			Okl_Rule_Apis_Pvt.rulv_rec_type;
	null_rulv_rec		Okl_Rule_Apis_Pvt.rulv_rec_type;

	------------------------------------------------------------
	-- Declare variables required by UBB Billing Consolidation
	------------------------------------------------------------
	l_clg_id			NUMBER;

	------------------------------------------------------------
	-- Declare variables required by Termination Quote Billing
	------------------------------------------------------------
	l_qte_id   			NUMBER := -1;

	l_qte_cust_id 		okl_ext_sell_invs_v.Customer_id%TYPE;
	------------------------------------------------------------
	-- Declare variables required by Collections Billing
	------------------------------------------------------------
	l_cpy_id   			NUMBER := -1;

	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------

	l_api_version	CONSTANT NUMBER := 1;
	l_api_name	CONSTANT VARCHAR2(30)  := 'CONSOLIDATED BILLING';
	l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

CURSOR cntrct_csr ( p_id NUMBER ) IS
	   SELECT contract_number
	   FROM okc_k_headers_b
	   WHERE id = p_id;

CURSOR strm_csr ( p_id NUMBER ) IS
	   SELECT name
	   FROM okl_strm_type_v
	   WHERE id = p_id;

	   l_contract_number   	  okc_k_headers_b.contract_number%TYPE;
	   l_stream_name1		  okl_strm_type_v.name%TYPE;


	   l_temp_khr_id		  NUMBER;

CURSOR get_khr_id ( p_lsm_id NUMBER ) IS
	   SELECT khr_id
	   FROM okl_cnsld_ar_strms_b
	   WHERE id = p_lsm_id;


-- Variable to track commit record size
l_commit_cnt        NUMBER;

-- --------------------------------------------------------
-- To Print log messages
-- --------------------------------------------------------
l_request_id      NUMBER;

CURSOR req_id_csr IS
  SELECT
        DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID)
  FROM dual;

------------------------------------------------------------
-- Operating Unit
------------------------------------------------------------
CURSOR op_unit_csr IS
       SELECT NAME
       FROM hr_operating_units
       WHERE ORGANIZATION_ID=MO_GLOBAL.GET_CURRENT_ORG_ID;--MOAC- Concurrent request


l_succ_cnt          NUMBER;
l_err_cnt           NUMBER;
l_op_unit_name      hr_operating_units.name%TYPE;
lx_msg_data         VARCHAR2(450);
l_msg_index_out     NUMBER :=0;
processed_sts       okl_cnsld_ar_hdrs_v.trx_status_code%TYPE;
error_sts           okl_cnsld_ar_hdrs_v.trx_status_code%TYPE;

    -- -----------------------------
    -- New fields
    -- -----------------------------
    l_old_cnr_id        NUMBER;
    l_old_lln_id        NUMBER;
    l_cnr_amount        okl_cnsld_ar_hdrs_v.amount%TYPE;
    l_lln_amount        okl_cnsld_ar_lines_v.amount%TYPE;

   x_cnrv_tbl Okl_Cnr_Pvt.cnrv_tbl_type;

   -- fmiao - Bug#5232919 - Modified - Start
   -- Commenting the decalration of Invoice Message Attribute Records as
   -- henceforth these are tracked as global records
   --p_imav_rec  Okl_ima_pvt.imav_rec_type;
   --x_imav_rec  Okl_ima_pvt.imav_rec_type;

   -- Defining table record for out record of Invoice Message Attribute
   x_imav_tbl  Okl_Ima_Pvt.imav_tbl_type;
   -- fmiao - Bug#5232919 - Modified - End

   l_save_ims_id			 okl_invoice_mssgs_v.id%TYPE;
   l_save_priority			 okl_invoice_mssgs_v.priority%TYPE;
   l_bind_proc               VARCHAR2(3000);
   l_msg_return				 VARCHAR2(1);

    l_temp_cnr_id            number;

    -- fmiao - Bug#5232919 - Modified - Start
    l_date_consolidated DATE;
    -- fmiao - Bug#5232919 - Modified - End
BEGIN

-- rmunjulu R12 Fixes -  Comment out entire code and Put NULL
NULL;
/*
    L_DEBUG_ENABLED := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;

    IF (L_DEBUG_ENABLED='Y' and FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'okl_cons_bill'
									,'Begin(+)');
    END IF;

    -- ------------------------
    -- Print Input variables
    -- ------------------------
    PRINT_TO_LOG('p_commit '||p_commit);
    PRINT_TO_LOG('p_contract_number '||p_contract_number);
    PRINT_TO_LOG('p_assigned_process '||p_assigned_process);

    g_inv_msg := p_inv_msg;
	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

	x_return_status := Okl_Api.G_RET_STS_SUCCESS;
*/
/*
	l_return_status := Okl_Api.START_ACTIVITY(
		p_api_name	=> l_api_name,
		p_pkg_name	=> G_PKG_NAME,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	=> '_PVT',
		x_return_status	=> l_return_status);

	IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
		RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;
*/
/*
	PRINT_TO_LOG( '========== **** BEGIN PROGRAM EXECUTION **** ============');

--    IF p_contract_number IS NULL THEN

        PRINT_TO_LOG( '========== START: Three LEVEL Processing ============');
        -- ---------------------------------------
        -- Initialize table and record parameters
        -- ---------------------------------------
        saved_bill_rec := l_init_bill_rec;
        cons_bill_tbl.delete;
        l_update_tbl.delete;

        OPEN c;
        LOOP
        cons_bill_tbl.delete;
        FETCH C BULK COLLECT INTO cons_bill_tbl LIMIT L_FETCH_SIZE;
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'C cons_bill_tbl count is: '||cons_bill_tbl.COUNT);
        IF cons_bill_tbl.COUNT > 0 THEN
            process_cons_bill_tbl(
                p_contract_number	=> p_contract_number,
	            p_api_version       => p_api_version,
    	        p_init_msg_list     => p_init_msg_list,
                p_commit            => p_commit,
    	        x_return_status     => x_return_status,
    	        x_msg_count         => x_msg_count,
    	        x_msg_data          => x_msg_data,
                p_cons_bill_tbl     => cons_bill_tbl,
                p_saved_bill_rec    => saved_bill_rec,
                p_update_tbl        => l_update_tbl);
        END IF;
        EXIT WHEN C%NOTFOUND;
        END LOOP;
        CLOSE C;

        -- -----------------------------
        -- Process Last set of records
        -- -----------------------------
        process_break(p_contract_number,
                      p_commit,
                      saved_bill_rec,
                      l_update_tbl);

--        IF FND_API.To_Boolean( p_commit ) THEN
--            COMMIT;
--        END IF;

-- insert remaining records here
-- main insert is in create_new_invoice
     -- bulk inserts
     -- insert consolidated headers
-- BUG#4621302
lang_count := 1;
FOR l_lang_rec IN get_languages
LOOP
   l_lang_tbl(lang_count) := l_lang_rec;
   lang_count             := lang_count + 1;
END LOOP;

     if g_cnr_tbl.count > 0 then
        -- Create TL Records
        tl_count := g_cnr_tbl.first;

        for z in g_cnr_tbl.first..g_cnr_tbl.last loop
          -- BUG#4621302
          FOR lang_count IN l_lang_tbl.first..l_lang_tbl.last
		  LOOP
            g_cnr_tl_tbl(tl_count).id                := g_cnr_tbl(z).id;
            g_cnr_tl_tbl(tl_count).language          := l_lang_tbl(lang_count).language_code;
            g_cnr_tl_tbl(tl_count).source_lang       :=  USERENV('LANG');
            g_cnr_tl_tbl(tl_count).sfwt_flag         := 'N';
            g_cnr_tl_tbl(tl_count).created_by        := fnd_global.user_id;
            g_cnr_tl_tbl(tl_count).creation_date     := sysdate;
            g_cnr_tl_tbl(tl_count).last_updated_by   := fnd_global.user_id;
            g_cnr_tl_tbl(tl_count).last_update_date  := sysdate;
            g_cnr_tl_tbl(tl_count).last_update_login := fnd_global.login_id;
            tl_count                                 := tl_count + 1;
          END LOOP;  -- languages loop
          -- invoice messaging processing
           if g_inv_msg = 'TRUE' then
              if g_msg_tbl.COUNT > 0 then
  	             -- Find message with the highest priority
	  	         l_save_priority := NULL;
                 for e in  g_msg_tbl.FIRST..g_msg_tbl.LAST loop
                    -- fmiao - Bug#5232919 - Modified - Start
                    l_date_consolidated := TRUNC(g_cnr_tbl(z).date_consolidated);
                    -- Check if the invoice message is effective for this consolidated invoice
                    IF ( l_date_consolidated BETWEEN NVL(g_msg_tbl(e).start_date,l_date_consolidated)
                                             AND NVL(g_msg_tbl(e).end_date,l_date_consolidated)) THEN

    	 	  	    PRINT_TO_LOG('====> IMS_ID: '||g_msg_tbl(e).id);
    	 	  	    PRINT_TO_LOG('====> PKG: '||g_msg_tbl(e).pkg_name);
  	    	  	    PRINT_TO_LOG('====> PROC: '||g_msg_tbl(e).proc_name);

                    l_bind_proc := 'BEGIN OKL_QUAL_INV_MSGS.'||g_msg_tbl(e).proc_name||'(:1,:2); END;';

                    PRINT_TO_LOG('l_bind_proc 2 : '||l_bind_proc);
                    PRINT_TO_LOG('g_cnr_tbl(z).id  2: '||g_cnr_tbl(z).id);

                    BEGIN
                        EXECUTE IMMEDIATE l_bind_proc USING IN g_cnr_tbl(z).id, OUT l_msg_return;
                    EXCEPTION
                        WHEN OTHERS THEN
                            PRINT_TO_LOG('Invoice Message error 2 -- '||SQLERRM);
                    END;

				    if (l_msg_return = '1' ) then
		  	 	       if (l_save_priority is null) or (g_msg_tbl(e).priority < l_save_priority) then
		  	 	          l_save_priority := g_msg_tbl(e).priority;
				          l_save_ims_id   := g_msg_tbl(e).id;
		               end if;
		            end if;
                      END IF; -- end of check for effective dates of invoice message
                      -- fmiao - Bug#5232919 - Modified - End
                  end loop;
		       end if;
		       -- Create Intersection Record
		       if (l_save_priority is not null) then
                          -- fmiao - Bug#5232919 - Modified - Start
                          -- Populating the global Inv Messg Attr records
                          g_imav_counter := g_imav_counter + 1;
                          g_imav_tbl(g_imav_counter).cnr_id  := g_cnr_tbl(z).id;
                          g_imav_tbl(g_imav_counter).ims_id  := l_save_ims_id;
		   	      --p_imav_rec.cnr_id  := x_cnrv_rec.id;
 			      --p_imav_rec.ims_id  := l_save_ims_id;
                          -- Commenting code that inserts record into Inv Msg Attr table because
                          -- at this point the CNR_ID is not yet in the CNSLD HDR table and this will
                          -- fail validation at TAPI of Inv Msg Attr table
*/
                          /*
                  -- Start of wraper code generated automatically by Debug code generator for okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT
                  IF(IS_DEBUG_PROCEDURE_ON) THEN
                     BEGIN
                        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRKONB.pls call okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT ');
                     END;
                  END IF;

		  	      okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT(
	  	  		     p_api_version
    				,p_init_msg_list
    				,x_return_status
    				,x_msg_count
    				,x_msg_data
    				,p_imav_rec
    				,x_imav_rec);

			     IF(IS_DEBUG_PROCEDURE_ON) THEN
                    BEGIN
                      OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRKONB.pls call okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT ');
                    END;
                 END IF;
                 -- End of wraper code generated automatically by Debug code generator for okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT
   			     IF ( x_return_status = 'S' ) THEN
      		  	    PRINT_TO_LOG('====> Message Created.');
			     ELSE
      		  	    PRINT_TO_LOG('*=> FAILED:Message Creation');
			     END IF;
                             */
                             -- fmiao - Bug#5232919 - Modified - End
/*
		      ELSE
      	  	      PRINT_TO_LOG('====> NO Message Qualified');
		      END IF;
		   end if;  -- Boolean test for invoice message processing
        end loop; --TL processing

        --g_cnr_tbl(g_cnr_tbl.count).amount := g_cnr_total + g_lln_total;

        BEGIN
        savepoint H2;
	    PRINT_TO_LOG('Performing bulk insert for cnr, record count is '||g_cnr_tbl.count);
        forall x in g_cnr_tbl.first..g_cnr_tbl.last
          save exceptions
          insert into okl_cnsld_ar_hdrs_b
          values g_cnr_tbl(x);

        forall d in g_cnr_tl_tbl.first..g_cnr_tl_tbl.last
          save exceptions
          insert into okl_cnsld_ar_hdrs_tl
          values g_cnr_tl_tbl(d);

        EXCEPTION
        WHEN OTHERS THEN
           rollback to H2;
           PRINT_TO_LOG('Error during Header Insertion, rollback to H2');
           g_cnr_tbl.DELETE;
           g_cnr_tl_tbl.DELETE;
           g_lln_tbl.DELETE;
           g_lln_tl_tbl.DELETE;
           g_lsm_tbl.DELETE;
           g_lsm_tl_tbl.DELETE;
           g_xsi_tbl.DELETE;
           g_xsi_tl_tbl.DELETE;
           g_xls_tbl.DELETE;
           g_xls_tl_tbl.DELETE;
           RAISE;
        END;

     end if;
     -- flush table
     g_cnr_tbl.delete;
     g_cnr_tl_tbl.delete;
     -- insert consolidated lines
     if g_lln_tbl.count > 0 then

        -- Create TL Records
        tl_count := g_lln_tbl.first;

        for x in g_lln_tbl.first..g_lln_tbl.last loop
          -- BUG#4621302
          FOR lang_count IN l_lang_tbl.first..l_lang_tbl.last
		  LOOP
            g_lln_tl_tbl(tl_count).id                := g_lln_tbl(x).id;
            g_lln_tl_tbl(tl_count).language          := l_lang_tbl(lang_count).language_code;
            g_lln_tl_tbl(tl_count).source_lang       := USERENV('LANG');
            g_lln_tl_tbl(tl_count).sfwt_flag         := 'N';
            g_lln_tl_tbl(tl_count).created_by        := fnd_global.user_id;
            g_lln_tl_tbl(tl_count).creation_date     := sysdate;
            g_lln_tl_tbl(tl_count).last_updated_by   := fnd_global.user_id;
            g_lln_tl_tbl(tl_count).last_update_date  := sysdate;
            g_lln_tl_tbl(tl_count).last_update_login := fnd_global.login_id;
            tl_count                                 := tl_count + 1;
          END LOOP; -- languages loop
        end loop;

       -- g_lln_tbl(g_lln_tbl.count).amount := g_lln_total;

        BEGIN
        savepoint L2;
	    PRINT_TO_LOG('Performing bulk insert for lln, record count is '||g_lln_tbl.count);
        forall x in g_lln_tbl.first..g_lln_tbl.last
           save exceptions
           insert into okl_cnsld_ar_lines_b
           values g_lln_tbl(x);

        forall e in g_lln_tl_tbl.first..g_lln_tl_tbl.last
           save exceptions
           insert into okl_cnsld_ar_lines_tl
           values g_lln_tl_tbl(e);

        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Line Insertion, rollback to L2');
           rollback to L2;
           g_lln_tl_tbl.DELETE;
           g_lsm_tbl.DELETE;
           g_lsm_tl_tbl.DELETE;
           g_xsi_tbl.DELETE;
           g_xsi_tl_tbl.DELETE;
           g_xls_tbl.DELETE;
           g_xls_tl_tbl.DELETE;

           for e in g_lln_tbl.FIRST..g_lln_tbl.LAST loop
              delete from okl_cnsld_ar_hdrs_b
              where id = g_lln_tbl(e).cnr_id;
           end loop;
           g_lln_tbl.DELETE;
           commit;
           RAISE;
        END;
     end if;
     -- flush table
     g_lln_tbl.delete;
     g_lln_tl_tbl.delete;

     -- insert consolidated streams
     if g_lsm_tbl.count > 0 then

        -- Create TL Records
         tl_count := g_lsm_tbl.first;

        for y in g_lsm_tbl.first..g_lsm_tbl.last loop
          -- BUG#4621302
          FOR lang_count IN l_lang_tbl.first..l_lang_tbl.last
		  LOOP
            g_lsm_tl_tbl(tl_count).id                := g_lsm_tbl(y).id;
            g_lsm_tl_tbl(tl_count).language          := l_lang_tbl(lang_count).language_code;
            g_lsm_tl_tbl(tl_count).source_lang       :=  USERENV('LANG');
            g_lsm_tl_tbl(tl_count).sfwt_flag         := 'N';
            g_lsm_tl_tbl(tl_count).created_by        := fnd_global.user_id;
            g_lsm_tl_tbl(tl_count).creation_date     := sysdate;
            g_lsm_tl_tbl(tl_count).last_updated_by   := fnd_global.user_id;
            g_lsm_tl_tbl(tl_count).last_update_date  := sysdate;
            g_lsm_tl_tbl(tl_count).last_update_login := fnd_global.login_id;
            tl_count                                 := tl_count + 1;
          END LOOP; -- languages loop
       end loop;


       BEGIN
       savepoint D2;
	   PRINT_TO_LOG('Performing bulk insert for lsm, record count is '||g_lsm_tbl.count);
       forall x in g_lsm_tbl.first..g_lsm_tbl.last
         save exceptions
         insert into okl_cnsld_ar_strms_b
         values g_lsm_tbl(x);

       forall f in g_lsm_tl_tbl.first..g_lsm_tl_tbl.last
         save exceptions
         insert into okl_cnsld_ar_strms_tl
         values g_lsm_tl_tbl(f);

         commit;
        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Stream Insertion, rollback to D2');
           rollback to D2;
           g_cnr_tl_tbl.delete;
           g_lln_tl_tbl.DELETE;
           g_lsm_tl_tbl.DELETE;
           g_xsi_tbl.DELETE;
           g_xsi_tl_tbl.DELETE;
           g_xls_tbl.DELETE;
           g_xls_tl_tbl.DELETE;

           for e in g_lsm_tbl.FIRST..g_lsm_tbl.LAST loop
              for f in g_lln_tbl.FIRST..g_lln_tbl.LAST loop
                 delete from okl_cnsld_ar_hdrs_b
                 where id = g_lln_tbl(f).cnr_id;
              end loop;
              delete from okl_cnsld_ar_lines_b
              where id = g_lsm_tbl(e).lln_id;
           end loop;
           g_lsm_tbl.DELETE;
           g_lln_tbl.DELETE;
           g_cnr_tbl.DELETE;
           commit;
           RAISE;
        END;
     end if;
     -- flush table
     g_lsm_tbl.delete;
     g_lsm_tl_tbl.delete;

      -- fmiao - Bug#5232919 - Modified - Start
      IF ( g_imav_tbl.COUNT > 0) THEN
        -- Code to insert the table of records into OKL_INV_MSSG_ATT
        -- Start of wraper code generated automatically by Debug code generator for okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT
        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRKONB.pls call okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT ');
          END;
        END IF;

        Okl_Inv_Mssg_Att_Pub.INSERT_INV_MSSG_ATT(
                            p_api_version
                           ,p_init_msg_list
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,g_imav_tbl
                           ,x_imav_tbl
                 );
       IF(IS_DEBUG_PROCEDURE_ON) THEN
         BEGIN
           Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRKONB.pls call okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT ');
         END;
       END IF;
       -- End of wraper code generated automatically by Debug code generator for okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT
       IF ( x_return_status = 'S' ) THEN
         PRINT_TO_LOG('====> Message Created.');
       ELSE
         PRINT_TO_LOG('*=> FAILED:Message Creation');
       END IF;

        -- flush the global table of records
        g_imav_tbl.DELETE;
        g_imav_counter := 0;
      END IF; -- end of check for presence of g_imav_tbl records
      -- fmiao - Bug#5232919 - Modified - End
     --MDOKAL final updates

     if g_xsi_tbl.COUNT > 0 then

	    PRINT_TO_LOG('Performing final bulk update for xsi, record count is '||g_xsi_tbl.COUNT );

        BEGIN
        savepoint U5;
        for indx in g_xsi_tbl.first..g_xsi_tbl.last loop
            -- rseela BUG#4733028 removed the updation of xtrx_invoice_pull_yn
            update okl_ext_sell_invs_b
            set trx_status_code = g_xsi_tbl(indx).trx_status_code,
--                xtrx_invoice_pull_yn = g_xsi_tbl(indx).xtrx_invoice_pull_yn,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
            where id = g_xsi_tbl(indx).id;
        end loop;
        commit;
        -- flush table
        g_xsi_tbl.delete;
        g_xsi_counter := 0;
        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Update of okl_ext_sell_invs_b, rollback to U5');
           rollback to U5;
           RAISE;
        END;
     end if;

     if g_xls_tbl.COUNT > 0 then

	    PRINT_TO_LOG('Performing final bulk update for xls, record count is '||g_xls_tbl.COUNT );
	    BEGIN
	    savepoint U6;
        for s in g_xls_tbl.first..g_xls_tbl.last loop
           update okl_xtl_sell_invs_b
           set lsm_id              = g_xls_tbl(s).lsm_id,
               xtrx_cons_stream_id  = g_xls_tbl(s).lsm_id,
               last_update_date     = sysdate,
               last_updated_by      = fnd_global.user_id,
               last_update_login    = fnd_global.login_id
           where id = g_xls_tbl(s).id;
        end loop;
        commit;
        -- flush table
        g_xls_tbl.delete;
        g_xls_counter := 0;
        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Update of okl_xtl_sell_invs_b, rollback to U6');
           rollback to U6;
           RAISE;
        END;
     end if;

     if g_xsi_tl_tbl.COUNT > 0 then

	    PRINT_TO_LOG('Performing final bulk update for xsi tl, record count is '||g_xsi_tl_tbl.COUNT );
	    BEGIN
	    savepoint U7;
        for u in g_xsi_tl_tbl.first..g_xsi_tl_tbl.last loop
           update okl_ext_sell_invs_tl
           set xtrx_cons_invoice_number = g_xsi_tl_tbl(u).xtrx_cons_invoice_number,
               xtrx_format_type = g_xsi_tl_tbl(u).xtrx_format_type,
               xtrx_private_label = g_xsi_tl_tbl(u).xtrx_private_label,
               last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id
           where id = g_xsi_tl_tbl(u).id;
        end loop;
        commit;
        -- flush table
        g_xsi_tl_tbl.delete;
        g_xsi_tl_counter := 0;
        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Update of okl_ext_sell_invs_tl, rollback to U7');
           rollback to U7;
           RAISE;
        END;
     end if;

     if g_xls_tl_tbl.COUNT > 0 then

	    PRINT_TO_LOG('Performing final bulk update for xls tl, record count is '||g_xls_tl_tbl.COUNT );
	    BEGIN
	    savepoint U8;
        for t in g_xls_tl_tbl.first..g_xls_tl_tbl.last loop
           update okl_xtl_sell_invs_tl
           set    xtrx_contract     = g_xls_tl_tbl(t).xtrx_contract,
                  xtrx_asset        = g_xls_tl_tbl(t).xtrx_asset,
                  xtrx_stream_type  = g_xls_tl_tbl(t).xtrx_stream_type,
                  xtrx_stream_group = g_xls_tl_tbl(t).xtrx_stream_group,
                  last_update_date  = sysdate,
                  last_updated_by   = fnd_global.user_id,
                  last_update_login = fnd_global.login_id
           where id = g_xls_tl_tbl(t).id;
        end loop;
        commit;
        -- flush table
        g_xls_tl_tbl.delete;
        g_xls_tl_counter := 0;
        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Update of okl_xtl_sell_invs_tl, rollback to U8');
           rollback to U8;
           RAISE;
        END;
     end if;

        PRINT_TO_LOG( '========== END: Three LEVEL Processing ============');

        PRINT_TO_LOG( '========== START: Two LEVEL Processing ============');
        -- ---------------------------------------
        -- Initialize table and record parameters
        -- ---------------------------------------
        saved_bill_rec := l_init_bill_rec;
        cons_bill_tbl.delete;
        l_update_tbl.delete;

        -- delete all other records
           g_cnr_tbl.DELETE;
           g_cnr_tl_tbl.DELETE;
           g_lln_tbl.DELETE;
           g_lln_tl_tbl.DELETE;
           g_lsm_tbl.DELETE;
           g_lsm_tl_tbl.DELETE;
           g_xsi_tbl.DELETE;
           g_xsi_tl_tbl.DELETE;
           g_xls_tbl.DELETE;
           g_xls_tl_tbl.DELETE;


        OPEN C1;
        LOOP
        cons_bill_tbl.delete;
        FETCH C1 BULK COLLECT INTO cons_bill_tbl LIMIT L_FETCH_SIZE;

        FND_FILE.PUT_LINE (FND_FILE.LOG, 'C1 cons_bill_tbl count is: '||cons_bill_tbl.COUNT);
        IF cons_bill_tbl.COUNT > 0 THEN
            process_cons_bill_tbl(
                p_contract_number	=> p_contract_number,
	            p_api_version       => p_api_version,
    	        p_init_msg_list     => p_init_msg_list,
                p_commit            => p_commit,
    	        x_return_status     => x_return_status,
    	        x_msg_count         => x_msg_count,
    	        x_msg_data          => x_msg_data,
                p_cons_bill_tbl     => cons_bill_tbl,
                p_saved_bill_rec    => saved_bill_rec,
                p_update_tbl        => l_update_tbl);
        END IF;
        EXIT WHEN C1%NOTFOUND;
        END LOOP;
        CLOSE C1;

        -- -----------------------------
        -- Process Last set of records
        -- -----------------------------
        process_break(p_contract_number,
                      p_commit,
                      saved_bill_rec,
                      l_update_tbl);

--        IF FND_API.To_Boolean( p_commit ) THEN
--            COMMIT;
--        END IF;

        PRINT_TO_LOG( '========== END: Two LEVEL Processing ============');

        PRINT_TO_LOG( '========== START: CREDIT MEMO Two LEVEL Processing ============');
        -- ---------------------------------------
        -- Initialize table and record parameters
        -- ---------------------------------------
        saved_bill_rec := l_init_bill_rec;
        cons_bill_tbl.delete;
        l_update_tbl.delete;


-- Update the XTRX columns in XSI and XLS and Resequence the
-- Consolidated bill lines

l_cnr_id  := -1;

PRINT_TO_LOG( '========== START: UPDATING Processed Records ============');

l_commit_cnt := 0;

PRINT_TO_LOG( '========== **** END PROGRAM EXECUTION **** ============');
--MDOKAL
-- insert remaining records here
-- main insert is in create_new_invoice
     -- bulk inserts
     -- insert consolidated headers


     if g_cnr_tbl.count > 0 then

        -- Create TL Records
        tl_count := g_cnr_tbl.first;

        for z in g_cnr_tbl.first..g_cnr_tbl.last loop
          -- BUG#4621302
          FOR lang_count IN l_lang_tbl.first..l_lang_tbl.last
		  LOOP
            g_cnr_tl_tbl(tl_count).id                := g_cnr_tbl(z).id;
            g_cnr_tl_tbl(tl_count).language          := l_lang_tbl(lang_count).language_code;
            g_cnr_tl_tbl(tl_count).source_lang       := USERENV('LANG');
            g_cnr_tl_tbl(tl_count).sfwt_flag         := 'N';
            g_cnr_tl_tbl(tl_count).created_by        := fnd_global.user_id;
            g_cnr_tl_tbl(tl_count).creation_date     := sysdate;
            g_cnr_tl_tbl(tl_count).last_updated_by   := fnd_global.user_id;
            g_cnr_tl_tbl(tl_count).last_update_date  := sysdate;
            g_cnr_tl_tbl(tl_count).last_update_login := fnd_global.login_id;
            tl_count                                 := tl_count + 1;
          END LOOP; -- languages code
          -- invoice messaging processing
           if g_inv_msg = 'TRUE' then
              if g_msg_tbl.COUNT > 0 then
  	             -- Find message with the highest priority
	  	         l_save_priority := NULL;
                 for e in  g_msg_tbl.FIRST..g_msg_tbl.LAST loop
                    -- fmiao - Bug#5232919 - Modified - Start
                    l_date_consolidated := TRUNC(g_cnr_tbl(z).date_consolidated);
                    -- Check if the invoice message is effective for this consolidated invoice
                    IF ( l_date_consolidated BETWEEN NVL(g_msg_tbl(e).start_date,l_date_consolidated)
                                             AND NVL(g_msg_tbl(e).end_date,l_date_consolidated)) THEN
    	 	  	    PRINT_TO_LOG('====> IMS_ID: '||g_msg_tbl(e).id);
    	 	  	    PRINT_TO_LOG('====> PKG: '||g_msg_tbl(e).pkg_name);
  	    	  	    PRINT_TO_LOG('====> PROC: '||g_msg_tbl(e).proc_name);

                    l_bind_proc := 'BEGIN OKL_QUAL_INV_MSGS.'||g_msg_tbl(e).proc_name||'(:1,:2); END;';

                    PRINT_TO_LOG('l_bind_proc 2 : '||l_bind_proc);
                    PRINT_TO_LOG('g_cnr_tbl(z).id  2: '||g_cnr_tbl(z).id);

                    BEGIN
                        EXECUTE IMMEDIATE l_bind_proc USING IN g_cnr_tbl(z).id, OUT l_msg_return;
                    EXCEPTION
                        WHEN OTHERS THEN
                            PRINT_TO_LOG('Invoice Message error 2 -- '||SQLERRM);
                    END;

				    if (l_msg_return = '1' ) then
		  	 	       if (l_save_priority is null) or (g_msg_tbl(e).priority < l_save_priority) then
		  	 	          l_save_priority := g_msg_tbl(e).priority;
				          l_save_ims_id   := g_msg_tbl(e).id;
		               end if;
		            end if;
                      END IF; -- end of check for effective dates of invoice message
                      -- fmiao - Bug#5232919 - Modified - End
                  end loop;
		       end if;
		       -- Create Intersection Record
		       if (l_save_priority is not null) then
                          -- fmiao - Bug#5232919 - Modified - Start
                          -- Populating the global Inv Messg Attr records
                          g_imav_counter := g_imav_counter + 1;
                          g_imav_tbl(g_imav_counter).cnr_id  := g_cnr_tbl(z).id;
                          g_imav_tbl(g_imav_counter).ims_id  := l_save_ims_id;
		   	      --p_imav_rec.cnr_id  := x_cnrv_rec.id;
 			      --p_imav_rec.ims_id  := l_save_ims_id;
                          -- Commenting code that inserts record into Inv Msg Attr table because
                          -- at this point the CNR_ID is not yet in the CNSLD HDR table and this will
                          -- fail validation at TAPI of Inv Msg Attr table
*/
                          /*
                  -- Start of wraper code generated automatically by Debug code generator for okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT
                  IF(IS_DEBUG_PROCEDURE_ON) THEN
                     BEGIN
                        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRKONB.pls call okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT ');
                     END;
                  END IF;

		  	      okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT(
	  	  		     p_api_version
    				,p_init_msg_list
    				,x_return_status
    				,x_msg_count
    				,x_msg_data
    				,p_imav_rec
    				,x_imav_rec);

			     IF(IS_DEBUG_PROCEDURE_ON) THEN
                    BEGIN
                      OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRKONB.pls call okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT ');
                    END;
                 END IF;
                 -- End of wraper code generated automatically by Debug code generator for okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT
   			     IF ( x_return_status = 'S' ) THEN
      		  	    PRINT_TO_LOG('====> Message Created.');
			     ELSE
      		  	    PRINT_TO_LOG('*=> FAILED:Message Creation');
			     END IF;
                      */
                      -- fmiao - Bug#5232919 - Modified - End
/*
		      ELSE
      	  	      PRINT_TO_LOG('====> NO Message Qualified');
		      END IF;
		   end if; -- Boolean test
        end loop; --TL processing

        --g_cnr_tbl(g_cnr_tbl.count).amount := g_cnr_total + g_lln_total;

        BEGIN
        savepoint H2;
	    PRINT_TO_LOG('Performing final bulk insert for cnr, record count is '||g_cnr_tbl.count);
        forall x in g_cnr_tbl.first..g_cnr_tbl.last
          save exceptions
          insert into okl_cnsld_ar_hdrs_b
          values g_cnr_tbl(x);

        forall d in g_cnr_tl_tbl.first..g_cnr_tl_tbl.last
          save exceptions
          insert into okl_cnsld_ar_hdrs_tl
          values g_cnr_tl_tbl(d);

        EXCEPTION
        WHEN OTHERS THEN
           rollback to H2;
           PRINT_TO_LOG('Error during Header Insertion, rollback to H2');
           g_cnr_tbl.DELETE;
           g_cnr_tl_tbl.DELETE;
           g_lln_tbl.DELETE;
           g_lln_tl_tbl.DELETE;
           g_lsm_tbl.DELETE;
           g_lsm_tl_tbl.DELETE;
           g_xsi_tbl.DELETE;
           g_xsi_tl_tbl.DELETE;
           g_xls_tbl.DELETE;
           g_xls_tl_tbl.DELETE;
           RAISE;
        END;

     end if;
     -- flush table
     g_cnr_tbl.delete;
     g_cnr_tl_tbl.delete;
     -- insert consolidated lines
     if g_lln_tbl.count > 0 then

        -- Create TL Records
        tl_count := g_lln_tbl.first;
        for x in g_lln_tbl.first..g_lln_tbl.last loop
          -- BUG#4621302
          FOR lang_count IN l_lang_tbl.first..l_lang_tbl.last
		  LOOP
            g_lln_tl_tbl(tl_count).id                := g_lln_tbl(x).id;
            g_lln_tl_tbl(tl_count).language          := l_lang_tbl(lang_count).language_code;
            g_lln_tl_tbl(tl_count).source_lang       := USERENV('LANG');
            g_lln_tl_tbl(tl_count).sfwt_flag         := 'N';
            g_lln_tl_tbl(tl_count).created_by        := fnd_global.user_id;
            g_lln_tl_tbl(tl_count).creation_date     := sysdate;
            g_lln_tl_tbl(tl_count).last_updated_by   := fnd_global.user_id;
            g_lln_tl_tbl(tl_count).last_update_date  := sysdate;
            g_lln_tl_tbl(tl_count).last_update_login := fnd_global.login_id;
            tl_count                                 := tl_count + 1;
          END LOOP; -- languages loop
        end loop;

        --g_lln_tbl(g_lln_tbl.count).amount := g_lln_total;

        BEGIN
        savepoint L2;
	    PRINT_TO_LOG('Performing final bulk insert for lln, record count is '||g_lln_tbl.count);
        forall x in g_lln_tbl.first..g_lln_tbl.last
           save exceptions
           insert into okl_cnsld_ar_lines_b
           values g_lln_tbl(x);

        forall e in g_lln_tl_tbl.first..g_lln_tl_tbl.last
           save exceptions
           insert into okl_cnsld_ar_lines_tl
           values g_lln_tl_tbl(e);

        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Line Insertion, rollback to L2');
           rollback to L2;
           g_lln_tl_tbl.DELETE;
           g_lsm_tbl.DELETE;
           g_lsm_tl_tbl.DELETE;
           g_xsi_tbl.DELETE;
           g_xsi_tl_tbl.DELETE;
           g_xls_tbl.DELETE;
           g_xls_tl_tbl.DELETE;

           for e in g_lln_tbl.FIRST..g_lln_tbl.LAST loop
              delete from okl_cnsld_ar_hdrs_b
              where id = g_lln_tbl(e).cnr_id;
           end loop;
           g_lln_tbl.DELETE;
           commit;
           RAISE;
        END;
     end if;
     -- flush table
     g_lln_tbl.delete;
     g_lln_tl_tbl.delete;

     -- insert consolidated streams
     if g_lsm_tbl.count > 0 then

        -- Create TL Records
        tl_count := g_lsm_tbl.first;
        for y in g_lsm_tbl.first..g_lsm_tbl.last loop
           -- BUG#4621302
          FOR lang_count IN l_lang_tbl.first..l_lang_tbl.last
		  LOOP
            g_lsm_tl_tbl(tl_count).id                := g_lsm_tbl(y).id;
            g_lsm_tl_tbl(tl_count).language          := l_lang_tbl(lang_count).language_code;
            g_lsm_tl_tbl(tl_count).source_lang       :=  USERENV('LANG');
            g_lsm_tl_tbl(tl_count).sfwt_flag         := 'N';
            g_lsm_tl_tbl(tl_count).created_by        := fnd_global.user_id;
            g_lsm_tl_tbl(tl_count).creation_date     := sysdate;
            g_lsm_tl_tbl(tl_count).last_updated_by   := fnd_global.user_id;
            g_lsm_tl_tbl(tl_count).last_update_date  := sysdate;
            g_lsm_tl_tbl(tl_count).last_update_login := fnd_global.login_id;
            tl_count                                 := tl_count + 1;
          END LOOP; -- languages loop
       end loop;


       BEGIN
       savepoint D2;
	   PRINT_TO_LOG('Performing final bulk insert for lsm, record count is '||g_lsm_tbl.count);
       forall x in g_lsm_tbl.first..g_lsm_tbl.last
         save exceptions
         insert into okl_cnsld_ar_strms_b
         values g_lsm_tbl(x);

       forall f in g_lsm_tl_tbl.first..g_lsm_tl_tbl.last
         save exceptions
         insert into okl_cnsld_ar_strms_tl
         values g_lsm_tl_tbl(f);

         commit;
        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Stream Insertion, rollback to D2');
           rollback to D2;
           g_cnr_tl_tbl.delete;
           g_lln_tl_tbl.DELETE;
           g_lsm_tl_tbl.DELETE;
           g_xsi_tbl.DELETE;
           g_xsi_tl_tbl.DELETE;
           g_xls_tbl.DELETE;
           g_xls_tl_tbl.DELETE;

           for e in g_lsm_tbl.FIRST..g_lsm_tbl.LAST loop
              for f in g_lln_tbl.FIRST..g_lln_tbl.LAST loop
                 delete from okl_cnsld_ar_hdrs_b
                 where id = g_lln_tbl(f).cnr_id;
              end loop;
              delete from okl_cnsld_ar_lines_b
              where id = g_lsm_tbl(e).lln_id;
           end loop;
           g_lsm_tbl.DELETE;
           g_lln_tbl.DELETE;
           g_cnr_tbl.DELETE;
           commit;
           RAISE;
        END;
     end if;
     -- flush table
     g_lsm_tbl.delete;
     g_lsm_tl_tbl.delete;
      IF ( g_imav_tbl.COUNT > 0) THEN
        -- Code to insert the table of records into OKL_INV_MSSG_ATT
        -- Start of wraper code generated automatically by Debug code generator for okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT
        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRKONB.pls call okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT ');
          END;
        END IF;

        Okl_Inv_Mssg_Att_Pub.INSERT_INV_MSSG_ATT(
                            p_api_version
                           ,p_init_msg_list
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,g_imav_tbl
                           ,x_imav_tbl
                 );
       IF(IS_DEBUG_PROCEDURE_ON) THEN
         BEGIN
           Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRKONB.pls call okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT ');
         END;
       END IF;
       -- End of wraper code generated automatically by Debug code generator for okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT
       IF ( x_return_status = 'S' ) THEN
         PRINT_TO_LOG('====> Message Created.');
       ELSE
         PRINT_TO_LOG('*=> FAILED:Message Creation');
       END IF;

        -- flush the global table of records
        g_imav_tbl.DELETE;
        g_imav_counter := 0;
      END IF; -- end of check for presence of g_imav_tbl records
     -- fmiao - Bug#5232919 - Modified - Start
     --MDOKAL final updates

     if g_xsi_tbl.COUNT > 0 then

	    PRINT_TO_LOG('Performing final bulk update for xsi, record count is '||g_xsi_tbl.COUNT );

        BEGIN
        savepoint U5;
        for indx in g_xsi_tbl.first..g_xsi_tbl.last loop
            -- rseela BUG#4733028 removed the updation of xtrx_invoice_pull_yn
            update okl_ext_sell_invs_b
            set trx_status_code = g_xsi_tbl(indx).trx_status_code,
--                xtrx_invoice_pull_yn = g_xsi_tbl(indx).xtrx_invoice_pull_yn,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
            where id = g_xsi_tbl(indx).id;
        end loop;
        commit;
        -- flush table
        g_xsi_tbl.delete;
        g_xsi_counter := 0;
        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Update of okl_ext_sell_invs_b, rollback to U5');
           rollback to U5;
           RAISE;
        END;
     end if;


     if g_xls_tbl.COUNT > 0 then

	    PRINT_TO_LOG('Performing final bulk update for xls, record count is '||g_xls_tbl.COUNT );
	    BEGIN
	    savepoint U6;
        for s in g_xls_tbl.first..g_xls_tbl.last loop
           update okl_xtl_sell_invs_b
           set lsm_id              = g_xls_tbl(s).lsm_id,
               xtrx_cons_stream_id  = g_xls_tbl(s).lsm_id,
               last_update_date     = sysdate,
               last_updated_by      = fnd_global.user_id,
               last_update_login    = fnd_global.login_id
           where id = g_xls_tbl(s).id;
        end loop;
        commit;
        -- flush table
        g_xls_tbl.delete;
        g_xls_counter := 0;
        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Update of okl_xtl_sell_invs_b, rollback to U6');
           rollback to U6;
           RAISE;
        END;
     end if;

     if g_xsi_tl_tbl.COUNT > 0 then

	    PRINT_TO_LOG('Performing final bulk update for xsi tl, record count is '||g_xsi_tl_tbl.COUNT );
	    BEGIN
	    savepoint U7;
        for u in g_xsi_tl_tbl.first..g_xsi_tl_tbl.last loop
           update okl_ext_sell_invs_tl
           set xtrx_cons_invoice_number = g_xsi_tl_tbl(u).xtrx_cons_invoice_number,
               xtrx_format_type = g_xsi_tl_tbl(u).xtrx_format_type,
               xtrx_private_label = g_xsi_tl_tbl(u).xtrx_private_label,
               last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id
           where id = g_xsi_tl_tbl(u).id;
        end loop;
        commit;
        -- flush table
        g_xsi_tl_tbl.delete;
        g_xsi_tl_counter := 0;
        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Update of okl_ext_sell_invs_tl, rollback to U7');
           rollback to U7;
           RAISE;
        END;
     end if;

     if g_xls_tl_tbl.COUNT > 0 then

	    PRINT_TO_LOG('Performing final bulk update for xls tl, record count is '||g_xls_tl_tbl.COUNT );
	    BEGIN
	    savepoint U8;
        for t in g_xls_tl_tbl.first..g_xls_tl_tbl.last loop
           update okl_xtl_sell_invs_tl
           set    xtrx_contract     = g_xls_tl_tbl(t).xtrx_contract,
                  xtrx_asset        = g_xls_tl_tbl(t).xtrx_asset,
                  xtrx_stream_type  = g_xls_tl_tbl(t).xtrx_stream_type,
                  xtrx_stream_group = g_xls_tl_tbl(t).xtrx_stream_group,
                  last_update_date  = sysdate,
                  last_updated_by   = fnd_global.user_id,
                  last_update_login = fnd_global.login_id
           where id = g_xls_tl_tbl(t).id;
        end loop;
        commit;
        -- flush table
        g_xls_tl_tbl.delete;
        g_xls_tl_counter := 0;
        EXCEPTION
        WHEN OTHERS THEN
           PRINT_TO_LOG('Error during Update of okl_xtl_sell_invs_tl, rollback to U8');
           rollback to U8;
           RAISE;
        END;
     end if;
*/
	------------------------------------------------------------
	-- End processing
	------------------------------------------------------------
/*
	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);
*/

EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        IF (L_DEBUG_ENABLED='Y' and FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_cons_bill',
               'EXCEPTION :'||'Okl_Api.G_EXCEPTION_ERROR');
        END IF;

	    PRINT_TO_LOG('*=> Error Message(O1): '||SQLERRM);
        -- -------------------------------------------
        -- purge data from the parallel process table
        -- -------------------------------------------
        if p_assigned_process is not null then
            delete okl_parallel_processes
            where assigned_process = p_assigned_process;
            commit;
        end if;

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN

        IF (L_DEBUG_ENABLED='Y' and FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_cons_bill',
               'EXCEPTION :'||'Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

	    PRINT_TO_LOG('*=> Error Message(O2): '||SQLERRM);
        -- -------------------------------------------
        -- purge data from the parallel process table
        -- -------------------------------------------
        if p_assigned_process is not null then
            delete okl_parallel_processes
            where assigned_process = p_assigned_process;
            commit;
        end if;

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        IF (L_DEBUG_ENABLED='Y' and FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_cons_bill',
               'EXCEPTION :'||'OTHERS');
        END IF;

	    PRINT_TO_LOG('*=> Error Message(O3): '||SQLERRM);
        -- -------------------------------------------
        -- purge data from the parallel process table
        -- -------------------------------------------
        if p_assigned_process is not null then
            delete okl_parallel_processes
            where assigned_process = p_assigned_process;
            commit;
        end if;

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

END create_cons_bill;

END OKL_BILLING_CONTROLLER_PVT;

/
