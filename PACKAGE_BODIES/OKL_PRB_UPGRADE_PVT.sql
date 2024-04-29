--------------------------------------------------------
--  DDL for Package Body OKL_PRB_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PRB_UPGRADE_PVT" AS
/* $Header: OKLRPRBB.pls 120.0.12010000.6 2009/09/29 17:33:01 racheruv noship $ */

  PROCEDURE log_msg(
              p_destination  IN NUMBER
             ,p_msg          IN VARCHAR2)
  IS
  BEGIN
   FND_FILE.PUT_LINE(p_destination, p_msg );
  END;

  PROCEDURE log_n_print_msg(
             p_msg          IN VARCHAR2)
  IS
  BEGIN
   FND_FILE.PUT_LINE(FND_FILE.LOG, p_msg );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, p_msg );
  END;

  ------------------------------------------------------------------------------
  -- Start of comments
  --   API name        : eff_dated_rbk_upgrade
  --   Pre-reqs        : None
  --   Description     : API to request PRB Upgrade of an ESG Lease Contract
  --   Parameters      :
  --   IN              :
  --       Workers  ID              Mandatory
  --   History         : Ravindranath Gooty created
  --   Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE eff_dated_rbk_upgrade(
    errbuf                    OUT      NOCOPY  VARCHAR2
   ,retcode                   OUT      NOCOPY  NUMBER
   ,p_worker_id               IN               VARCHAR2
  )
  IS
    CURSOR get_esg_upgw_contracts_csr(
      p_worker_id            VARCHAR2
    )
    IS
      SELECT   opp.khr_id             khr_id
              ,opp.object_value       contract_number
              ,opp.volume             no_of_assets
        FROM   okl_parallel_processes opp
       WHERE   opp.object_type      =  G_ESG_PRB_KHR_UPG_OBJ_TYPE -- 'ESG_PRB_UPGRADE_CONTRACT'
         AND   opp.process_status   = 'ASSIGNED'    -- Dont fetch any unallocated contracts for processing
         AND   opp.assigned_process =  p_worker_id; -- Fetch only this worker related contracts
    TYPE esg_upg_cntrcts_tbl_type IS TABLE OF get_esg_upgw_contracts_csr%ROWTYPE
      INDEX BY BINARY_INTEGER;
    -- Local Variable Declaration
    l_outer_error_msg_tbl        Okl_Accounting_Util.Error_Message_Type;
    l_esg_upg_cntrcts_tbl        esg_upg_cntrcts_tbl_type;
    l_khr_id                     NUMBER;
    -- Common Local Variables
    l_api_name                   CONSTANT VARCHAR2(30) := 'EFF_DATED_RBK_UPGRADE';
    l_init_msg_list              VARCHAR2(2000)        := OKL_API.G_FALSE;
    -- Local Variables specific to ESG request
    l_request_id                 NUMBER;
    l_trans_status               VARCHAR2(100);
    l_rep_request_id             NUMBER;
    l_rep_trans_status           VARCHAR2(100);
    l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);
    l_api_version                CONSTANT NUMBER := 1.0;

    l_khr_id_tbl                 Okl_Streams_Util.NumberTabTyp;
    khr_index                    NUMBER;
    l_text                       VARCHAR2(4000);
    l_time_taken                 NUMBER;
    l_start_mark                 DATE;
  BEGIN
    -- Assign the input params to the Local Variables
    log_msg(FND_FILE.LOG, 'Parameters: ' );
    log_msg(FND_FILE.LOG, ' Worker ID = ' || p_worker_id );
    -- Initialize the khr_index
    khr_index := 0;
    -- Fetch all the OKL Assets for which FA has generated Depreciation Transactions
    --  in the inputted Asset Book and Period
    log_msg(FND_FILE.LOG, 'Before Executing the Cursor get_esg_upgw_contracts_csr' );
    OPEN get_esg_upgw_contracts_csr( p_worker_id => p_worker_id );
    LOOP
      log_msg(FND_FILE.LOG, 'After Executing the Cursor get_esg_upgw_contracts_csr-Start: '
                            || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
      FETCH get_esg_upgw_contracts_csr BULK COLLECT INTO l_esg_upg_cntrcts_tbl
        LIMIT 10000;
      log_msg(FND_FILE.LOG, 'After Executing the Cursor get_esg_upgw_contracts_csr-End  : '
                            || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
      -- Exit when there are no Assets to be Processed
      EXIT WHEN get_esg_upgw_contracts_csr%ROWCOUNT = 0;
      log_msg(FND_FILE.LOG, 'Number of Contracts to be Processed: ' || l_esg_upg_cntrcts_tbl.COUNT );
      IF l_esg_upg_cntrcts_tbl.COUNT > 0
      THEN
        log_msg(FND_FILE.OUTPUT, '------------------------------------------------------------------------------------------------------------------------------------' );
        log_msg(FND_FILE.OUTPUT, 'Contract #                                         Primary                    Secondary                     Time        Error         ');
        log_msg(FND_FILE.OUTPUT, ' Number                                    Trx Number  Trx. Status          Trx. Number  Trx. Status        Taken(Sec)  Message       ' );
        log_msg(FND_FILE.OUTPUT, '------------------------------------------------------------------------------------------------------------------------------------' );
        FOR i IN l_esg_upg_cntrcts_tbl.FIRST .. l_esg_upg_cntrcts_tbl.LAST
        LOOP
          -- Logic:
          --  Frame the appropriate Parameters and call the Granular API
          --    to request Stream Generation for the eligible Contract
          -- Increment the khr_index and store the contract number in the l_khr_id_tbl
          l_khr_id_tbl(khr_index) := l_esg_upg_cntrcts_tbl(i).khr_id;
          khr_index := khr_index + 1;
          -- Re-Initialize things
          l_return_status    := NULL;
          l_msg_count        := NULL;
          l_msg_data         := NULL;
          l_request_id       := NULL;
          l_trans_status     := NULL;
          l_rep_request_id   := NULL;
          l_rep_trans_status := NULL;
          log_msg(FND_FILE.LOG, 'ESG for ' || l_esg_upg_cntrcts_tbl(i).contract_number ||
                                ' - Start: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
          l_start_mark := SYSDATE;
          l_time_taken := NULL;
          l_text       := NULL;

		  -- establish the external_id values for the contracts, if they don't have one.
          OKL_LLA_UTIL_PVT.update_external_id(p_chr_id => l_esg_upg_cntrcts_tbl(i).khr_id,
                                              x_return_status => l_return_status);

          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
          THEN
            log_msg(FND_FILE.LOG, 'Error: ' || SUBSTR(l_msg_data, 1, 2000) );
          END IF;

          okl_la_stream_pvt.upgrade_esg_khr_for_prb(
             p_chr_id             => l_esg_upg_cntrcts_tbl(i).khr_id
            ,x_return_status      => l_return_status
            ,x_msg_count          => l_msg_count
            ,x_msg_data           => l_msg_data
            ,x_request_id         => l_request_id
            ,x_trans_status       => l_trans_status
            ,x_rep_request_id     => l_rep_request_id
            ,x_rep_trans_status   => l_rep_trans_status );
          l_time_taken := ( SYSDATE - l_start_mark ) * 86400; -- To convert in seconds
          log_msg(FND_FILE.LOG, 'ESG for ' || l_esg_upg_cntrcts_tbl(i).contract_number ||
                                ' - End  : ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
          log_msg(FND_FILE.LOG,'Return Status: ' || l_return_status );
          l_text := SUBSTR(
                      RPAD(l_esg_upg_cntrcts_tbl(i).contract_number, 35, ' ' ) ||
                      LPAD(l_request_id, 10, ' ' )     || '  ' ||
                      RPAD(l_trans_status, 30, ' ' ) || '  ' ||
                      LPAD(l_rep_request_id, 10, ' ' )     || '  ' ||
                      RPAD(l_rep_trans_status, 30, ' ' )  || '   ' ||
                      LPAD(l_time_taken, 10, ' ') || '     ' ||
                      SUBSTR(l_msg_data, 1, 2000)
                      , 1, 4000);
          log_msg(FND_FILE.OUTPUT, l_text );
          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
          THEN
            log_msg(FND_FILE.LOG, 'Error: ' || SUBSTR(l_msg_data, 1, 2000) );
          END IF;
        END LOOP; -- FOR i IN l_deprn_assets_tbl.FIRST .. l_deprn_assets_tbl.LAST
      END IF; -- IF l_esg_upg_cntrcts_tbl.COUNT > 0
      -- Exit When Cursor Has been Exhausted fetching all the Records
      EXIT WHEN get_esg_upgw_contracts_csr%NOTFOUND;
    END LOOP; -- Loop on get_esg_upgw_contracts_csr
    CLOSE get_esg_upgw_contracts_csr;  -- Close the Cursor
    -- Now Delete all the processed records from parallel process table
    log_msg(FND_FILE.LOG, 'Deletion of Processed Records - Start: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
    FORALL khr_index IN l_khr_id_tbl.FIRST .. l_khr_id_tbl.LAST
      DELETE  OKL_PARALLEL_PROCESSES opp
       WHERE  khr_id               = l_khr_id_tbl(khr_index)
         AND  opp.object_type      =  G_ESG_PRB_KHR_UPG_OBJ_TYPE -- 'ESG_PRB_UPGRADE_CONTRACT'
         AND  opp.assigned_process =  p_worker_id; -- Fetch only this worker related contracts;
    log_msg(FND_FILE.LOG, 'Deletion of Processed Records - End  : ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
    -- Return the Proper Return status
    retcode := 0; -- 0 Indicates 'S'uccess Status
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN Okl_Api.G_EXCEPTION_ERROR
    THEN
      l_return_status := Okl_Api.G_RET_STS_ERROR;
      -- print the error message in the log file and output files
      log_msg(FND_FILE.OUTPUT,'');
      log_msg(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_ERROR'));
      log_msg(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
      IF (l_outer_error_msg_tbl.COUNT > 0) THEN
        FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
        LOOP
           log_msg(FND_FILE.LOG, l_outer_error_msg_tbl(i));
        END LOOP;
      END IF;
      retcode := 2;

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      -- print the error message in the log file
      log_msg(FND_FILE.OUTPUT,'');
      log_msg(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_ERROR'));
      log_msg(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
      IF (l_outer_error_msg_tbl.COUNT > 0)
      THEN
        FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
        LOOP
          log_msg(FND_FILE.LOG, l_outer_error_msg_tbl(i));
        END LOOP;
      END IF;
      retcode := 2;

    WHEN OTHERS
    THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      -- print the error message in the log file
      log_msg(FND_FILE.OUTPUT,'');
      log_msg(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_ERROR'));
      log_msg(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
      IF (l_outer_error_msg_tbl.COUNT > 0)
      THEN
        FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
        LOOP
          log_msg(FND_FILE.LOG, l_outer_error_msg_tbl(i));
        END LOOP;
      END IF;
      errbuf := SQLERRM;
      retcode := 2;
  END eff_dated_rbk_upgrade;
  ------------------------------------------------------------------------------
  -- Start of comments
  --   API name        : eff_dated_rbk_upgrade_conc
  --   Pre-reqs        : None
  --   Description     : API to identify eligible contracts for ESG PRB Upgrade
  --                      based on the Criteria given and launch multiple workers
  --   Parameters      :
  --   IN              :
  --       Operating Unit              Mandatory
  --       Criteria Set                Mandatory  [CONTRACT/REVISION]
  --       Legal Entity                Optional
  --       Contract Number             Optional
  --       Book Classification         Optional
  --       Product                     Optional
  --       Interest Calculation Method Optional
  --       Revenue Recognition Method  Optional
  --       Start Date [Low]            Optional
  --       Start Date [High]           Optional
  --       End Date   [Low]            Optional
  --       End Date   [High]           Optional
  --       In-Transit Category         Optional
  --       Mode                        Optional  [REVIEW/SUBMIT]
  --       Tag Name                    Optional
  --       # of Workers                Optional
  --   History         : Ravindranath Gooty created
  --   Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE eff_dated_rbk_upgrade_conc(
    errbuf                    OUT      NOCOPY  VARCHAR2
   ,retcode                   OUT      NOCOPY  NUMBER
   ,p_org_id                  IN               NUMBER
   ,p_criteria_set            IN               VARCHAR2
   ,p_dummy_crit_set_contract IN               VARCHAR2
   ,p_dummy_crit_set_revision IN               VARCHAR2
   ,p_le_id                   IN               NUMBER
   ,p_khr_id                  IN               NUMBER
   ,p_book_classification     IN               VARCHAR2
   ,p_pdt_id                  IN               NUMBER
   ,p_int_calc_method         IN               VARCHAR2
   ,p_rev_rec_method          IN               VARCHAR2
   ,p_start_date_low          IN               VARCHAR2
   ,p_start_date_high         IN               VARCHAR2
   ,p_end_date_low            IN               VARCHAR2
   ,p_end_date_high           IN               VARCHAR2
   ,p_in_transit_category     IN               VARCHAR2
   ,p_mode_of_run             IN               VARCHAR2
   ,p_tag_name                IN               VARCHAR2
   ,p_no_of_workers           IN               NUMBER

  )
  IS
    -- Cursor Definitions
    -- Cursor: To fetch the eligible Contracts for Processing the ESG Upgrade
    CURSOR get_esg_upg_contracts_csr( p_process_sequence IN VARCHAR2 )
    IS
      SELECT  khr_id                 khr_id
             ,object_value           contract_number
             ,volume                 no_of_assets
             ,process_status         status
             ,'Pending Assignment'   status_meaning
        FROM  OKL_PARALLEL_PROCESSES opp
       WHERE opp.object_type      =  G_ESG_PRB_KHR_UPG_OBJ_TYPE -- 'ESG_PRB_UPGRADE_CONTRACT'
         AND opp.process_status   =  'PENDING_ASSIGNMENT'
         AND opp.assigned_process = p_process_sequence
     UNION ALL
      SELECT  khr_id                 khr_id
             ,object_value           contract_number
             ,volume                 no_of_assets
             ,process_status         status
             ,'Revision in Progress'           status_meaning
        FROM  OKL_PARALLEL_PROCESSES opp
             --,fnd_lookups            lkup
       WHERE opp.object_type      =  G_ESG_PRB_KHR_UPG_OBJ_TYPE -- 'ESG_PRB_UPGRADE_CONTRACT'
         AND opp.process_status   <> 'PENDING_ASSIGNMENT'
         AND opp.assigned_process =  p_process_sequence;
         --AND lkup.lookup_type     =  'OKL_UPG_INTRANSIT_CAT'
         --AND opp.process_status   =  lkup.lookup_code;

    TYPE esg_upg_contracts_tbl_type IS TABLE OF get_esg_upg_contracts_csr%ROWTYPE
      INDEX BY BINARY_INTEGER;

    -- Cursor to get the meaning of the Parameters appropriately
    CURSOR get_params_def_csr
    IS
      SELECT
       (SELECT name from hr_operating_units where organization_id = p_org_id)                org_id
       ,DECODE(p_criteria_set, 'CONTRACT', 'Contract - Criteria', 'Revision - Criteria' )    criteria_set
       ,( SELECT DISTINCT legal_entity_name from XLE_LE_OU_LEDGER_V
           WHERE legal_entity_id = p_le_id
             AND rownum <= 1 ) le_id
       ,( SELECT contract_number FROM OKC_K_HEADERS_B WHERE id = p_khr_id )                  khr_id
       ,OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_BOOK_CLASS',p_book_classification)      book_classification
       ,( SELECT name from okl_products where id = p_pdt_id )                                pdt_id
       ,OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING('OKL_INTEREST_CALCULATION_BASIS',p_int_calc_method) int_calc_method
       ,OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING('OKL_REVENUE_RECOGNITION_METHOD',p_rev_rec_method)  rev_rec_method
       ,p_start_date_low  start_date_low
       ,p_start_date_high start_date_high
       ,p_end_date_low    end_date_low
       ,p_end_date_high   end_date_high
       ,OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_UPG_INTRANSIT_CAT',p_in_transit_category)     in_transit_category
       ,DECODE(p_mode_of_run, 'REVIEW', 'Review', 'SUBMIT', 'Submit' ) mode_of_run
       ,p_tag_name           tag_name
       ,p_no_of_workers      no_of_workers
    FROM DUAL;

    l_temp_upg_contracts_tbl      esg_upg_contracts_tbl_type;
    l_upg_contracts_tbl           esg_upg_contracts_tbl_type;
    l_non_upg_contracts_tbl       esg_upg_contracts_tbl_type;
    upg_index                     NUMBER := 0; -- Index for the l_upg_contracts_tbl
    non_upg_index                 NUMBER := 0;
    -- Variable Declarations
    l_object_value_tbl            Okl_Streams_Util.Var240TabTyp;
    l_assigned_process_tbl        Okl_Streams_Util.Var30TabTyp;
    l_khr_id_tbl                  Okl_Streams_Util.NumberTabTyp;
    l_volume_tbl                  Okl_Streams_Util.NumberTabTyp;
    -- Local Variable Declaration
    req_data                      VARCHAR2(10);
    l_num_workers                 NUMBER;
    l_seq_next                    NUMBER;
    l_worker_id                   VARCHAR2(2000);
    l_worker_load                 worker_load_tab;
    i                             NUMBER;
    l_lightest_worker             NUMBER;
    l_lightest_load               NUMBER;
    l_reqid                       FND_CONCURRENT_REQUESTS.request_id%TYPE;
    l_query_string                VARCHAR2(4000);
    G_LIMIT_SIZE                  CONSTANT NUMBER       := 10000;
    -- Date related variables
    l_start_date_low              DATE;
    l_start_date_high             DATE;
    l_end_date_low                DATE;
    l_end_date_high               DATE;

	l_prb_enabled                 VARCHAR2(1);
	l_k_status                    VARCHAR2(15);

  BEGIN
    req_data := fnd_conc_global.request_data;
    log_msg(FND_FILE.LOG, 'Request Data= ' || req_data );
    IF req_data IS NOT NULL
    THEN
      errbuf:='Done';
      retcode := 0;
      log_msg(FND_FILE.LOG, 'Returning Out Successfully !' );
      RETURN;
    ELSE
      log_msg(FND_FILE.LOG, 'MOAC Org Context : ' || mo_global.get_current_org_id );
      l_start_date_low    := FND_DATE.CANONICAL_TO_DATE( p_start_date_low  );
      l_start_date_high   := FND_DATE.CANONICAL_TO_DATE( p_start_date_high );
      l_end_date_low      := FND_DATE.CANONICAL_TO_DATE( p_end_date_low );
      l_end_date_high     := FND_DATE.CANONICAL_TO_DATE( p_end_date_high );
      FOR t_rec IN get_params_def_csr
      LOOP
         -- When the req_data is NULL, it means that this is the first run of the Program ..
         -- in the Sense, the current request is the run before triggerring off any parallel workers
         -- Log the Input Variables
         log_n_print_msg( 'Parameters: ' );
         log_n_print_msg( '  Operating Unit              : ' || t_rec.org_id             );
         log_n_print_msg( '  Criteria Set                : ' || t_rec.criteria_set       );
         log_n_print_msg( '  Legal Entity                : ' || t_rec.le_id              );
         log_n_print_msg( '  Contract Number             : ' || t_rec.khr_id             );
         log_n_print_msg( '  Book Classification         : ' || t_rec.book_classification);
         log_n_print_msg( '  Product                     : ' || t_rec.pdt_id             );
         log_n_print_msg( '  Interest Calculation Method : ' || t_rec.int_calc_method    );
         log_n_print_msg( '  Revenue Recognition Method  : ' || t_rec.rev_rec_method     );
         log_n_print_msg( '  Start Date [Low]            : ' || t_rec.start_date_low );
         log_n_print_msg( '  Start Date [High]           : ' || t_rec.start_date_high);
         log_n_print_msg( '  End Date   [Low]            : ' || t_rec.end_date_low   );
         log_n_print_msg( '  End Date   [High]           : ' || t_rec.end_date_high  );
         log_n_print_msg( '  In-Transit Category         : ' || t_rec.in_transit_category);
         log_n_print_msg( '  Mode                        : ' || t_rec.mode_of_run        );
         log_n_print_msg( '  Tag Name                    : ' || t_rec.tag_name           );
         log_n_print_msg( '  # of Workers                : ' || t_rec.no_of_workers      );
         log_n_print_msg( '  ');
         log_n_print_msg( '  ');
      END LOOP;
      -- Validations

	  -- check if the effective dated rebook feature is enabled.
	  -- Bugs 8928055, 8927961
      select nvl(AMORT_INC_ADJ_REV_DT_YN, 'N')
		into l_prb_enabled
	    from okl_sys_acct_opts_all
       where org_id = p_org_id;

      if l_prb_enabled = 'N' then
        log_msg(FND_FILE.LOG, FND_MESSAGE.GET_STRING('OKL', 'OKL_PRB_UPG_NOT_VALID'));
	    return;
	  end if;
	  --

      IF p_mode_of_run = 'SUBMIT'
      THEN
        -- Fetch the Number of Workers to be Assigned
        l_num_workers := p_no_of_workers;  -- FND_PROFILE.VALUE(G_OKL_DEPRN_WORKERS);
        log_msg(FND_FILE.LOG, 'Number of Workers ' || TO_CHAR(l_num_workers) );
        IF l_num_workers IS NULL OR l_num_workers <= 0
        THEN
          log_msg(FND_FILE.LOG, 'Please specify positive value for the Parameter "Number of Workers".');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF; -- IF p_mode_of_run = 'SUBMIT'
      IF p_criteria_set = 'REVISION'
      THEN
        IF p_in_transit_category IS NULL
        THEN
          log_msg(FND_FILE.LOG, 'Please select a valid In-Trasit Category.');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      -- Select sequence for marking processes
      SELECT  okl_opp_seq.NEXTVAL
        INTO  l_seq_next
        FROM  DUAL;
      log_msg(FND_FILE.LOG, 'Process Sequence ID:' || l_seq_next );
      -- Fetch all Contracts eligible for Upgrade and Store them in OKL_PARALLEL_PROCESSES
      log_msg(FND_FILE.LOG, 'Before calling the Bulk Insert into the OKL_PARALLEL_PROCESSES' );
      l_query_string :=
        'INSERT INTO OKL_PARALLEL_PROCESSES(OBJECT_TYPE,OBJECT_VALUE,ASSIGNED_PROCESS' ||
        ',PROCESS_STATUS,CREATION_DATE,KHR_ID,VOLUME) ' ||
        'SELECT ''' || G_ESG_PRB_KHR_UPG_OBJ_TYPE || ''' ' || -- OBJECT_TYPE
        ' ,chr.contract_number' ||        -- OBJECT_VALUE
        ' ,TO_CHAR( ''' || l_seq_next || ''' ) ' ||        -- ASSIGNED_PROCESS
        ' ,''PENDING_ASSIGNMENT'' ' ||      -- PROCESS_STATUS
        ' ,SYSDATE ' || -- CREATION_DATE
        ' ,chr.id  ' || -- KHR_ID
        ' ,COUNT(cle.id) ' || -- VOLUME = Number of Assets
        ' FROM okc_k_headers_b  chr, okl_k_headers khr, okc_k_lines_b cle ' ||
        ' ,okl_products pdt ,okl_ae_tmpt_sets aes , okl_st_gen_tmpt_sets gts '    ;
      -- Appending the Where Caluse including the Mandatory Predicates
      l_query_string := l_query_string
        || ' WHERE chr.id = khr.id AND chr.id = cle.dnz_chr_id AND cle.lse_id = 33 '  -- FREE_FORM1 for Assets
        || ' AND chr.scs_code = ''LEASE'' AND chr.template_yn = ''N'' AND chr.orig_system_source_code <>  ''OKL_REBOOK'' '
        || ' AND khr.pdt_id = pdt.id AND pdt.aes_id = aes.id AND aes.gts_id = gts.id AND gts.pricing_engine = ''EXTERNAL'' '
        -- Predicate to check whether an Upgrade ESG Transaction which is completed/in process exists for this contracts or not
        -- Predicate to check whether this contract has the PRM content already or not
        || ' AND NOT EXISTS ( SELECT 1 FROM okl_stream_trx_data trx, okl_stream_interfaces osi  '
        || ' WHERE osi.transaction_number = trx.transaction_number AND osi.khr_id = chr.id '
        || ' AND ( ( trx.last_trx_state = ''Y'' AND '
	|| ' ((osi.orp_code = ''UPGRADE'' AND osi.sis_code = ''PROCESS_COMPLETE'') OR '
        || '  (osi.orp_code = ''AUTH''    AND osi.sis_code = ''PROCESS_COMPLETE'')) ) OR '
        || '  (osi.orp_code = ''UPGRADE'' AND osi.sis_code IN (''PROCESSING_REQUEST'', ''RET_DATA_RECEIVED'' )) )) '
        -- Operating Unit related predicate
        || ' AND chr.authoring_org_id = ' || p_org_id || ' ';
      IF p_criteria_set = 'CONTRACT'
      THEN
        -- Append the another default predicate
        l_query_string := l_query_string
            || ' AND chr.sts_code IN (' || ' ''COMPLETE'', ''BOOKED'', ''APPROVED'', ''EVERGREEN'' ' || ') ' ;
        IF p_le_id IS NOT NULL
        THEN
          l_query_string := l_query_string || ' AND khr.legal_entity_id = ' || p_le_id || ' ';
        END IF;
        IF p_khr_id IS NOT NULL
        THEN
          l_query_string := l_query_string || ' AND chr.id = ' || p_khr_id || ' ';
        END IF;
        log_msg(FND_FILE.LOG,'Handling the Date Criteria: Start ');
        IF p_start_date_low IS NOT NULL THEN
          l_query_string := l_query_string
            || ' AND chr.start_date >= FND_DATE.CANONICAL_TO_DATE(''' ||p_start_date_low || ''') ';
        END IF;
        IF p_start_date_high IS NOT NULL THEN
          l_query_string := l_query_string
            || ' AND chr.start_date <= FND_DATE.CANONICAL_TO_DATE(''' ||p_start_date_high || ''') ';
        END IF;
        IF p_end_date_low IS NOT NULL THEN
          l_query_string := l_query_string
            || ' AND chr.end_date >= FND_DATE.CANONICAL_TO_DATE(''' ||p_end_date_low || ''') ';
        END IF;
        IF p_end_date_high IS NOT NULL THEN
          l_query_string := l_query_string
            || ' AND chr.end_date <= FND_DATE.CANONICAL_TO_DATE(''' ||p_end_date_high || ''') ';
        END IF;
        log_msg(FND_FILE.LOG,'Handling the Date Criteria: End ');
        IF p_pdt_id IS NOT NULL
        THEN
          l_query_string := l_query_string  || ' AND pdt.id = ' || p_pdt_id || ' ';
        END IF;
        IF p_book_classification IS NOT NULL THEN
          l_query_string := l_query_string  || ' AND khr.deal_type = ''' || p_book_classification || ''' ';
        END IF;
        IF p_int_calc_method IS NOT NULL THEN
          l_query_string := l_query_string  || ' AND gts.interest_calc_meth_code = ''' || p_int_calc_method || ''' ';
        END IF;
        IF p_rev_rec_method IS NOT NULL THEN
          l_query_string := l_query_string  || ' AND gts.revenue_recog_meth_code = ''' || p_rev_rec_method || ''' ';
        END IF;
      END IF; -- IF p_criteria_set = 'CONTRACT'

      IF p_criteria_set = 'REVISION'
      THEN
        -- Start the Contract ID Not in Predicate
        l_query_string := l_query_string  || ' AND chr.id IN ( ';
        IF p_in_transit_category = 'ONLINE_RBK'
        THEN
          -- Online Rebook not Activated
          l_query_string := l_query_string  || ' SELECT trx.khr_id orig_contract_id FROM okl_trx_contracts trx '
             || ' WHERE trx.khr_id_new IS NOT NULL AND trx.tsu_code = ''ENTERED'' AND trx.rbr_code is NOT NULL '
             || ' AND trx.tcn_type = ''TRBK'' AND trx.representation_type = ''PRIMARY'' ';
        ELSIF p_in_transit_category = 'ONLINE_MASS_RBK'
        THEN
          -- Online Mass Rebook Not Processed
          l_query_string := l_query_string  || ' SELECT rsc.khr_id orig_contract_id FROM okl_rbk_selected_contract rsc, okc_k_headers_b chrb '
            || ' WHERE rsc.transaction_id IS NULL AND rsc.status <> ''PROCESSED'' AND chrb.id = rsc.khr_id ';
        ELSIF p_in_transit_category = 'PAYDOWN'
        THEN
          -- Paydown Not Accepted
          l_query_string := l_query_string  || ' SELECT trq.dnz_khr_id khr_id FROM okl_trx_requests trq '
            || ' WHERE trq.request_type_code = ''PRINCIPAL_PAYDOWN'' AND trq.request_status_code NOT IN '
            || ' (''ACCEPTED'', ''REJECTED'', ''ERROR'' ,''PROCESSED'' '
            || '  ,''CANCELLED'' ,''REBOOK_IN_PROCESS'' ,''REBOOK_COMPLETE'' ) '
            || ' AND trq.tcn_id IS NULL AND trq.org_id = ' || p_org_id;
        ELSIF p_in_transit_category = 'RESIDUAL'
        THEN
          -- Residual Value Writedown not Processed
          l_query_string := l_query_string  || ' SELECT l.dnz_khr_id FROM OKL_TRX_ASSETS h, okl_txl_assets_b l '
            || ' WHERE h.id = l.tas_id AND h.tsu_code IN (''ENTERED'',''ERROR'') AND h.tas_type = ''ARC'' ';
        ELSIF p_in_transit_category = 'TERMINATION'
        THEN
          -- Termination Quote Not Accepted
          l_query_string := l_query_string || ' SELECT khr_id FROM okl_trx_quotes_b '
            || ' WHERE partial_yn = ''Y'' and qst_code not IN (''ACCEPTED'',''COMPLETE'',''IN_PROCESS'') ';
        END IF; -- IF p_in_transit_category
        l_query_string := l_query_string  || ' ) ';
      END IF; -- IF p_criteria_set = 'REVISION'

      -- Group By Clause: Addition
      l_query_string := l_query_string  || ' GROUP BY chr.contract_number, chr.id ';

      log_msg(FND_FILE.LOG, 'Query has been formulated: Start' );
      log_msg(FND_FILE.LOG, l_query_string );
      log_msg(FND_FILE.LOG, 'Executing the Formulated Query - Start: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
      EXECUTE IMMEDIATE l_query_string;
      log_msg(FND_FILE.LOG, 'Executing the Formulated Query - End: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
      -- Commit the Records
      COMMIT;
      log_msg(FND_FILE.LOG, 'Committed the Insertion of the OKL_PARALLEL_PROCESSES Records' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );

	  -- Identify the contracts which are ineligible for upgrade. Following fall into that category:
	  -- 1. Termination quote accepted and before it raised the termination transaction the quote failed
	  -- 2. Termination transaction has been raised but the termination transaction has errored out
	  -- 3. Any mass rebook transactions in progress.

      IF p_criteria_set = 'CONTRACT'
      THEN
	   -- Case 1: TQ accepted and before it raised the termination transaction the quote failed
	   log_msg(FND_FILE.LOG, 'Checking: TQ accepted and fails before trx created - Start: '
                             || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );

       UPDATE OKL_PARALLEL_PROCESSES opp
          SET process_status = 'OKL_REVISION_IN_PROGRESS'
        WHERE opp.object_type      =  G_ESG_PRB_KHR_UPG_OBJ_TYPE
          AND opp.process_status   = 'PENDING_ASSIGNMENT'
          AND opp.assigned_process = TO_CHAR(l_seq_next)
          AND exists
           (
             select q.khr_id
               from okl_trx_quotes_b q
              where q.qtp_code like 'TER%' -- Termination quote
                and NVL(q.consolidated_yn,'N') = 'N'
                and q.partial_yn = 'Y'
                and q.qst_code = 'ACCEPTED'
                and q.khr_id = opp.khr_id
                and q.id not in (select t.qte_id from okl_trx_contracts_all t where q.id = t.qte_id)
           );

        log_msg(FND_FILE.LOG, 'Checking: TQ accepted and fails before trx created - End  : ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );

        -- Case 2: Termination transaction has been raised but the termination transaction phase has errored out
        log_msg(FND_FILE.LOG, 'Checking: TQ accepted and termination trx phase fails - Start: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );

        UPDATE OKL_PARALLEL_PROCESSES opp
           SET process_status = 'OKL_REVISION_IN_PROGRESS'
         WHERE opp.object_type      =  G_ESG_PRB_KHR_UPG_OBJ_TYPE
           AND opp.process_status   = 'PENDING_ASSIGNMENT'
           AND opp.assigned_process = TO_CHAR(l_seq_next)
           AND exists
           (
            select q.khr_id
              from okl_trx_quotes_b q, okl_trx_contracts_all t
             where q.qtp_code like 'TER%'
               and NVL(q.consolidated_yn,'N') = 'N'
               and q.partial_yn = 'Y'
               and q.khr_id = opp.khr_id
               and q.id = t.qte_id
               and t.tcn_type = 'ALT'
               and t.tmt_status_code not in ('PROCESSED')
           );

        log_msg(FND_FILE.LOG, 'Checking: TQ accepted and termination trx phase fails - End  : ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );

        -- Case 3: Mass Rebook in progress
        log_msg(FND_FILE.LOG, 'Checking: Mass Rebook in progress - Start: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );

        UPDATE OKL_PARALLEL_PROCESSES opp
           SET process_status = 'OKL_REVISION_IN_PROGRESS'
         WHERE opp.object_type      =  G_ESG_PRB_KHR_UPG_OBJ_TYPE
           AND opp.process_status   = 'PENDING_ASSIGNMENT'
           AND opp.assigned_process = TO_CHAR(l_seq_next)
           AND exists
           (
            SELECT 1
              FROM okl_trx_contracts ktrx
             where ktrx.khr_id     =  opp.khr_id
               AND ktrx.khr_id_new IS NULL
               AND ktrx.tsu_code   = 'ENTERED'
               AND ktrx.rbr_code   IS NOT NULL
               AND ktrx.tcn_type   = 'TRBK'
               AND ktrx.representation_type = 'PRIMARY'
               AND EXISTS (SELECT '1'
                             FROM okl_rbk_selected_contract rbk_khr
                            WHERE rbk_khr.khr_id = ktrx.khr_id
                              AND rbk_khr.status <> 'PROCESSED')
           );

        log_msg(FND_FILE.LOG, 'Checking: Mass Rebook in progres - End  : ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
        -- Finally Commiting: Marking the Contracts not eligible for the Upgrade
        COMMIT;
      END IF; -- IF p_criteria_set = 'CONTRACT'

	  /*********
      -- Step:
      --  When the Parameter Criteria is Contract, we need to list out the reason in case if there exists a Pending
      --   Rebook Transaction for a contract
      IF p_criteria_set = 'CONTRACT'
      THEN
        -- 1. Handling the Condition: "Online Rebook not Activated"
        log_msg(FND_FILE.LOG, 'Checking: Online Rebook Not Activated - Start: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
        UPDATE OKL_PARALLEL_PROCESSES opp
           SET process_status = 'ONLINE_RBK'
         WHERE opp.object_type      =  G_ESG_PRB_KHR_UPG_OBJ_TYPE
           AND opp.process_status   = 'PENDING_ASSIGNMENT'
           AND opp.assigned_process = TO_CHAR(l_seq_next)
           AND opp.khr_id IN
           (
             SELECT trx.khr_id orig_contract_id
               FROM okl_trx_contracts trx
              WHERE  trx.khr_id_new IS NOT NULL
                AND  trx.rbr_code IS NOT NULL
                AND  trx.tsu_code = 'ENTERED'
                AND  trx.tcn_type = 'TRBK'
                AND  trx.representation_type = 'PRIMARY'
           );
        log_msg(FND_FILE.LOG, 'Checking: Online Rebook Not Activated - End  : ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );

        -- 2. Handling the Condition: "Online Mass Rebook Not Processed"
        log_msg(FND_FILE.LOG, 'Checking: Online Mass Rebook Not Processed - Start: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
        UPDATE OKL_PARALLEL_PROCESSES opp
           SET process_status = 'ONLINE_MASS_RBK'
         WHERE opp.object_type      =  G_ESG_PRB_KHR_UPG_OBJ_TYPE
           AND opp.process_status   = 'PENDING_ASSIGNMENT'
           AND opp.assigned_process = TO_CHAR(l_seq_next)
           AND opp.khr_id IN
           (
             SELECT rsc.khr_id orig_contract_id
               FROM okl_rbk_selected_contract rsc,
                    okc_k_headers_b chrb
              WHERE rsc.transaction_id IS NULL
                AND rsc.status <> 'PROCESSED'
                AND chrb.id = rsc.khr_id
           );
        log_msg(FND_FILE.LOG, 'Checking: Online Mass Rebook Not Processed - End  : ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );

        -- 3. Handling the Condition: "Paydown Not Accepted"
        log_msg(FND_FILE.LOG, 'Checking: Paydown Not Accepted - Start: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
        UPDATE OKL_PARALLEL_PROCESSES opp
           SET process_status = 'PAYDOWN'
         WHERE opp.object_type      =  G_ESG_PRB_KHR_UPG_OBJ_TYPE
           AND opp.process_status   = 'PENDING_ASSIGNMENT'
           AND opp.assigned_process = TO_CHAR(l_seq_next)
           AND opp.khr_id IN
           (
             SELECT trq.dnz_khr_id
               FROM okl_trx_requests trq
              WHERE trq.request_type_code = 'PRINCIPAL_PAYDOWN'
                AND trq.request_status_code NOT IN
                     ('ACCEPTED','REJECTED','ERROR','PROCESSED','CANCELLED'
                     ,'REBOOK_IN_PROCESS','REBOOK_COMPLETE')
                AND trq.tcn_id IS NULL
                AND trq.org_id = p_org_id
           );
        log_msg(FND_FILE.LOG, 'Checking: Paydown Not Accepted - End  : ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );

        -- 4. Handling the Condition: "Paydown Not Accepted"
        log_msg(FND_FILE.LOG, 'Checking: Termination Quote Not Accepted - Start: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
        UPDATE OKL_PARALLEL_PROCESSES opp
           SET process_status = 'TERMINATION'
         WHERE opp.object_type      =  G_ESG_PRB_KHR_UPG_OBJ_TYPE
           AND opp.process_status   = 'PENDING_ASSIGNMENT'
           AND opp.assigned_process = TO_CHAR(l_seq_next)
           AND opp.khr_id IN
           (
              SELECT khr_id
                FROM okl_trx_quotes_b
               WHERE partial_yn = 'Y'
                 AND qst_code NOT IN ('ACCEPTED','COMPLETE','IN_PROCESS')
           );
        log_msg(FND_FILE.LOG, 'Checking: Termination Quote Not Accepted - End  : ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );

        -- 5. Handling the Condition: "Residual Value Writedown not Processed"
        log_msg(FND_FILE.LOG, 'Checking: Residual Value Writedown Not Processed - Start: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
        UPDATE OKL_PARALLEL_PROCESSES opp
           SET process_status = 'RESIDUAL'
         WHERE opp.object_type      =  G_ESG_PRB_KHR_UPG_OBJ_TYPE
           AND opp.process_status   = 'PENDING_ASSIGNMENT'
           AND opp.assigned_process = TO_CHAR(l_seq_next)
           AND opp.khr_id IN
           (
             SELECT l.dnz_khr_id
               FROM okl_trx_assets h
                   ,okl_txl_assets_b l
              WHERE h.id = l.tas_id
                AND h.tsu_code IN ( 'ENTERED','ERROR')
                AND h.tas_type = 'ARC'
           );
        log_msg(FND_FILE.LOG, 'Checking: Residual Value Writedown Not Processed - End  : ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
        -- Finally Commiting: Marking the Contracts not eligible for the Upgrade
        COMMIT;
      END IF; -- IF p_criteria_set = 'CONTRACT'
        *************************************/

      -- First of all fetch the Total Information into a PL/SQL table
      log_msg(FND_FILE.LOG, 'Opening the Cursor get_esg_upg_contracts_csr' );
      OPEN get_esg_upg_contracts_csr( p_process_sequence => TO_CHAR(l_seq_next)  );
      LOOP
        -- Bulk Collect the Contracts which has Assets depreciated in the inputted
        --  Book Type and Period
        log_msg(FND_FILE.LOG, 'Before Executing the fetch on the Cursor get_esg_upg_contracts_csr: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
        FETCH get_esg_upg_contracts_csr BULK COLLECT INTO l_temp_upg_contracts_tbl
          LIMIT G_LIMIT_SIZE;
        log_msg(FND_FILE.LOG, 'After Executing the fetch on the Cursor get_esg_upg_contracts_csr: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
        log_msg(FND_FILE.LOG, 'Distinct Contracts fetched in this Loop ' || l_temp_upg_contracts_tbl.COUNT );
        -- Exit Conditionally ..
        EXIT WHEN get_esg_upg_contracts_csr%ROWCOUNT = 0;
        -- Loop on the l_temp_upg_contracts_tbl and append the records at the end of the
        -- l_upg_contracts_tbl / l_non_upg_contracts_tbl
        log_msg(FND_FILE.LOG, 'Copying the Contracts [' || l_temp_upg_contracts_tbl.COUNT
                              || '] fetched in this Loop - Start: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
        FOR i IN l_temp_upg_contracts_tbl.FIRST .. l_temp_upg_contracts_tbl.LAST
        LOOP
          IF l_temp_upg_contracts_tbl(i).status = 'PENDING_ASSIGNMENT'
          THEN
            l_upg_contracts_tbl(upg_index) := l_temp_upg_contracts_tbl(i);
            -- Increment the upg_index
            upg_index := upg_index + 1;
          ELSE
            l_non_upg_contracts_tbl(non_upg_index) := l_temp_upg_contracts_tbl(i);
            -- Increment the non_upg_index
            non_upg_index := non_upg_index + 1;
          END IF;
        END LOOP;
        log_msg(FND_FILE.LOG, 'Copying the Contracts [' || l_temp_upg_contracts_tbl.COUNT
                              || '] fetched in this Loop - End  : ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
        -- Delete the Temporary Table now ..
        l_temp_upg_contracts_tbl.DELETE;
        -- Exit when there are no Assets to be Processed
        EXIT WHEN get_esg_upg_contracts_csr%NOTFOUND;
      END LOOP; -- Loop on get_esg_upg_contracts_csr
      CLOSE get_esg_upg_contracts_csr;  -- Close the Cursor

      -- Log n Print the Following Data:
      --   Number of Contracts picked for Processing
      log_n_print_msg( 'Number of Contracts matching the Criteria     : ' ||
                       NVL( NVL(l_non_upg_contracts_tbl.COUNT,0) +
                            NVL(l_upg_contracts_tbl.COUNT,0)
                           ,0) );
      log_n_print_msg( 'Number of Contracts eligible for Upgrade      : ' ||
                       NVL(l_upg_contracts_tbl.COUNT,0) );
      log_n_print_msg( 'Number of Contracts NOT eligible for Upgrade  : ' ||
                       NVL(l_non_upg_contracts_tbl.COUNT,0) );

      IF l_non_upg_contracts_tbl.COUNT > 0
      THEN
        log_msg(FND_FILE.OUTPUT, ' ');
        log_msg(FND_FILE.OUTPUT, ' ');
        log_msg(FND_FILE.OUTPUT, 'The following contracts cannot be upgraded as processing is in progress :' );
        log_msg(FND_FILE.OUTPUT, '-------------------------------------------------------------------------' );
        log_msg(FND_FILE.OUTPUT, ' ');
        log_msg(FND_FILE.OUTPUT, 'SL. #     Contract Number                                Status                                   ');
        log_msg(FND_FILE.OUTPUT, '--------------------------------------------------------------------------------------------------');
        FOR non_upg_index IN l_non_upg_contracts_tbl.FIRST .. l_non_upg_contracts_tbl.LAST
        LOOP
		  select b.meaning
		    into l_k_status
			from okc_k_headers_all_b a, okc_statuses_tl b
           where a.contract_number = l_non_upg_contracts_tbl(non_upg_index).contract_number
		     and a.sts_code = b.code
			 and b.language = userenv('LANG');

          log_msg(FND_FILE.OUTPUT,
                  LPAD(non_upg_index+1, 8, ' ' ) || '  ' ||
                  RPAD(l_non_upg_contracts_tbl(non_upg_index).contract_number, 43, ' ' ) ||
                   ' -  ' || l_k_status);
        END LOOP;
        log_msg(FND_FILE.OUTPUT, '----------------------------------------------------------------------------------------');
      END IF; -- IF l_non_upg_contracts_tbl.COUNT > 0

      IF l_upg_contracts_tbl.COUNT > 0
      THEN
        log_msg(FND_FILE.OUTPUT, ' ');
        log_msg(FND_FILE.OUTPUT, ' ');
        log_msg(FND_FILE.OUTPUT, 'Contracts Eligible :' );
        log_msg(FND_FILE.OUTPUT, '--------------------');
        log_msg(FND_FILE.OUTPUT, ' ');
        log_msg(FND_FILE.OUTPUT, '   SL. #   Contract Number                                ');
        log_msg(FND_FILE.OUTPUT, '----------------------------------------------------------');
        FOR upg_index IN l_upg_contracts_tbl.FIRST .. l_upg_contracts_tbl.LAST
        LOOP
          log_msg(FND_FILE.OUTPUT,LPAD(upg_index+1, 8, ' ' ) || '  ' ||
            l_upg_contracts_tbl(upg_index).contract_number);
        END LOOP;
        log_msg(FND_FILE.OUTPUT, '----------------------------------------------------------------------------------------');
      END IF; -- IF l_non_upg_contracts_tbl.COUNT > 0

      IF p_mode_of_run = 'SUBMIT'
      THEN
        IF l_upg_contracts_tbl.COUNT > 0
        THEN
          log_msg(FND_FILE.LOG, 'Total Number of records fetched=' || l_upg_contracts_tbl.COUNT );
          -- Assign the data from the l_deprn_contracts_tbl to l_pp_deprn_khrs_tbl
          FOR upg_index IN l_upg_contracts_tbl.FIRST .. l_upg_contracts_tbl.LAST
          LOOP
            l_object_value_tbl(upg_index)     := l_upg_contracts_tbl(upg_index).contract_number;
            l_khr_id_tbl(upg_index)           := l_upg_contracts_tbl(upg_index).khr_id;
            l_volume_tbl(upg_index)           := l_upg_contracts_tbl(upg_index).no_of_assets;
            l_assigned_process_tbl(upg_index) := TO_CHAR(l_seq_next);
          END LOOP;

          -- Create l_num_workers number of Workers
          FOR i in 1..l_num_workers
          LOOP -- put all workers into a table
            l_worker_load(i).worker_number := i;
            l_worker_load(i).worker_load := 0; -- initialize load with zero
            l_worker_load(i).used := FALSE; -- Initialize with FALSE as none are assigned to this
          END LOOP;
          log_msg(FND_FILE.LOG, 'Initialized totally ' || l_num_workers || ' workers ' );
          log_msg(FND_FILE.LOG, 'Allocation of Workers for every contract is in Progress .. ' );
          l_lightest_worker := 1;

          -- Loop through the Depreciation Contracts and Assign the Workers
          FOR upg_index IN l_upg_contracts_tbl.FIRST .. l_upg_contracts_tbl.LAST
          LOOP
            l_assigned_process_tbl(upg_index) := l_lightest_worker;
            -- put current contract into the lightest worker
            IF l_worker_load.EXISTS(l_lightest_worker)
            THEN
              -- Increment the Assigned Worker Load by Number of Assets
              l_worker_load(l_lightest_worker).worker_load :=
                l_worker_load(l_lightest_worker).worker_load +
                l_upg_contracts_tbl(upg_index).no_of_assets;
              -- Update the used flag of the current lightest worker to indicate that its used.
              l_worker_load(l_lightest_worker).used := TRUE;
            END IF;
            -- default the lighest load with the first element as a starting point
            IF l_worker_load.EXISTS(1)
            THEN
              l_lightest_load := l_worker_load(1).worker_load;
              l_lightest_worker := l_worker_load(1).worker_number;
              -- logic to find lightest load
              FOR i in 1..l_worker_load.COUNT
              LOOP
                IF (l_worker_load(i).worker_load = 0)
                   OR (l_worker_load(i).worker_load < l_lightest_load)
                THEN
                  l_lightest_load   := l_worker_load(i).worker_load;
                  l_lightest_worker := l_worker_load(i).worker_number;
                END IF;
              END LOOP;
            END IF;
          END LOOP; -- FOR upg_index IN l_upg_contracts_tbl.FIRST .. l_upg_contracts_tbl.LAST
          log_msg(FND_FILE.LOG, 'Done with allocation of Workers for every contract.' );
          log_msg(FND_FILE.LOG, 'Process Sequence Number    = ' || l_seq_next );
          log_msg(FND_FILE.LOG, 'G_ESG_PRB_KHR_UPG_OBJ_TYPE = ' || G_ESG_PRB_KHR_UPG_OBJ_TYPE );

--          log_msg(FND_FILE.LOG, 'Assigned Process              Contract Number                         KHR_ID                           Volume           ');
--          log_msg(FND_FILE.LOG, '------------------------------------------------------------------------------------------------------------------------');
--
--          FOR upg_index in l_upg_contracts_tbl.FIRST .. l_upg_contracts_tbl.LAST
--          LOOP
--            log_msg(FND_FILE.LOG, RPAD(l_assigned_process_tbl(upg_index),30, ' ') ||
--                                  RPAD(l_object_value_tbl(upg_index),40, ' ')  ||
--                                  RPAD(l_khr_id_tbl(upg_index),32, ' ' ) ||
--                                  LPAD(l_volume_tbl(upg_index),15, ' ') );
--          END LOOP;

          -- Now Bulk Update the Contract Numbers in Parallel Processes with the
          -- Assigned Worker Number
          log_msg(FND_FILE.LOG, 'Updated the Records in OKL_PARALLEL_PROCESSES with the Assigned Process - Start: '
                   || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
          FORALL upg_index in l_upg_contracts_tbl.FIRST .. l_upg_contracts_tbl.LAST
            UPDATE  OKL_PARALLEL_PROCESSES
               SET  assigned_process =  l_seq_next || '-' || l_assigned_process_tbl(upg_index)
                   ,process_status   = 'ASSIGNED'
             WHERE  object_type      = G_ESG_PRB_KHR_UPG_OBJ_TYPE
               AND  object_value     = l_object_value_tbl(upg_index)
               AND  process_status   = 'PENDING_ASSIGNMENT'
               AND  khr_id           = l_khr_id_tbl(upg_index);
          log_msg(FND_FILE.LOG, 'Updated the Records in OKL_PARALLEL_PROCESSES with the Assigned Process - End  : '
                   || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
          -- COMMIT the Updation;
          COMMIT;
          log_msg(FND_FILE.LOG, 'Committed the Updation Changes: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );

          FOR i in l_worker_load.FIRST .. l_worker_load.LAST
          LOOP
            -- Request only if the Worker is used and has some load to process ..
            IF l_worker_load(i).used
            THEN
              l_worker_id := TO_CHAR(l_seq_next)||'-'||TO_CHAR(i);
              -- FND_REQUEST.set_org_id(MO_GLOBAL.get_current_org_id); --MOAC- Concurrent request
              log_msg(FND_FILE.LOG, 'Submitted the Request with worker_id=' || l_worker_id );
              l_reqid := FND_REQUEST.submit_request(
                            application  => 'OKL'
                           ,program      => 'OKLESGPRBCONCW' -- Parallel Worker Conc. Program
                           ,sub_request  => TRUE
                           ,argument1    => l_worker_id);
              log_msg(FND_FILE.LOG, '  Returned request_id=' || l_reqid );
              IF l_reqid = 0
              THEN
                -- Request Submission failed with Error .. Hence, Exit with Error
                errbuf := fnd_message.get;
                retcode := 2;
              ELSE
                errbuf := 'Sub-Request submitted successfully';
                retcode := 0 ;
              END IF;
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Launching Process '||l_worker_id||' with Request ID '||l_reqid);
            END IF; -- IF l_worker_load(i).used
          END LOOP; -- FOR j in 1 .. l_worker_load.LAST
          -- Set the Request Data to be used in the re-run of the Master Program ..
          FND_CONC_GLOBAL.set_req_globals(
              conc_status => 'PAUSED'
             ,request_data => '2 RUN'); -- Instead of NULL, it was i here ..
        ELSE
          log_msg(FND_FILE.LOG, 'No Workers Assigned. Reason: No Data Found for Processing!');
        END IF; -- IF l_upg_contracts_tbl.COUNT > 0
      ELSIF p_mode_of_run = 'REVIEW'
      THEN
        -- Delete the records populated here finally
        log_msg(FND_FILE.LOG, 'Review Mode: Deletion of Records - Start: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );

        DELETE  OKL_PARALLEL_PROCESSES opp
         WHERE  opp.object_type      =  G_ESG_PRB_KHR_UPG_OBJ_TYPE -- 'ESG_PRB_UPGRADE_CONTRACT'
           AND opp.assigned_process = TO_CHAR(l_seq_next);

        log_msg(FND_FILE.LOG, 'Review Mode: Deletion of Records - End  : ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
      END IF; -- IF p_mode_of_run = 'SUBMIT'
    END IF; -- IF req_data IS NOT NULL
  END eff_dated_rbk_upgrade_conc;

END OKL_PRB_UPGRADE_PVT;

/
