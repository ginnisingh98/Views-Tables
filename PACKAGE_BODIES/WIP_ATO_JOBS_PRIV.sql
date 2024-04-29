--------------------------------------------------------
--  DDL for Package Body WIP_ATO_JOBS_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_ATO_JOBS_PRIV" AS
/* $Header: wipvfasb.pls 120.8.12010000.2 2010/03/11 09:50:36 ntungare ship $ */
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : WIPVFASB.PLS                                               |
|                                                                           |
| DESCRIPTION  : Package Boody for Autocreate FAS.                          |
|                                                                           |
| Coders       : Amit Garg                                                  |
|                                                                           |
| PURPOSE:      Create Discrete Jobs to satisfy sales order demand for      |
|               replenish-to-order items that meet the user-input criteria. |
|                                                                           |
|                                                                           |
| PROGRAM SYNOPSIS:                                                         |
|  1.  Update records in mtl_demand that meet criteria with a group_id      |
|  2.  Insert records into wip_entities_interface for mtl_demands records   |
|      marked with group_id                                                 |
|  3.  Read wip_entities_interface records and inform OE of sales order     |
|      lines that have been linked to WIP                                   |
|  4.  Call mass load routine to create jobs from wip_entities_interface    |
|      records                                                              |
|  5.  Do feedback:                                                         |
|      1.  Update mtl_demand for jobs successfully loaded                   |
|      2.  Create records in wip_so_allocations                             |
|      3.  Read wip_entities_interface and inform OE of sales order         |
|          lines that should be unlinked from WIP                           |
|      4.  Update mtl_demand for jobs that failed load so they can be       |
|          picked up again                                                  |
|  6.  Launch report of what occurred in process                            |
|  7.  Delete records from interface table                                  |
|                                                                           |
| CALLED BY: Concurrent Program                                             |
|                                                                           |
|
|         Date         Fixed by       FIX
|         06-Feb-2006  Kiran Konada   bugfix#4865485
|                                     When no orders are loaded AFAS will
|                                     complete with warning
+===========================================================================*/

--Global Vars
G_PKG_NAME  CONSTANT VARCHAR2(30):='WIP_ATO_JOBS_PRIV';

/*------------------------------------------------------------------+
| Local vars                                                        |
+-------------------------------------------------------------------*/
DEBUG_FLAG boolean := true;

/*------------------------------------------------------------------+
|              Start WIP_AUTO_CREATE_JOBS                           |
+-------------------------------------------------------------------*/
PROCEDURE CREATE_JOBS(
          ERRBUF            OUT   NOCOPY VARCHAR2 ,
          RETCODE           OUT   NOCOPY VARCHAR2 ,
          P_ORDER_NUMBER    IN    VARCHAR2 ,
          P_DUMMY_FIELD     IN    VARCHAR2 ,
          P_OFFSET_DAYS     IN    VARCHAR2 ,
          P_LOAD_TYPE       IN    VARCHAR2 ,
          P_STATUS_TYPE     IN    VARCHAR2 ,
          P_ORG_ID          IN    VARCHAR2 ,
          P_CLASS_CODE      IN    VARCHAR2 ,
          P_FAILED_REQ_ID   IN    VARCHAR2 ,
          P_ORDER_LINE_ID   IN    VARCHAR2 ,
          P_BATCH_ID        IN    VARCHAR2 )


IS

  x_return_status   VARCHAR2(240);
  P_API_VERSION     NUMBER      := 1.0;
  L_ORDER_NUMBER    NUMBER      := -1;
  L_DUMMY_FIELD     NUMBER      := -1;
  L_OFFSET_DAYS     NUMBER      := -10000; -- Bug Fix 5169003. Off set days should defult to -10000 as -1 can be a valid value.
  L_LOAD_TYPE       NUMBER      := -1;
  L_STATUS_TYPE     NUMBER      := -1;
  L_ORG_ID          NUMBER      := -1;
  L_FAILED_REQ_ID   NUMBER      := -1;
  L_ORDER_LINE_ID   NUMBER      := -1;
  L_BATCH_ID        NUMBER      := -1;

  L_API_VERSION   CONSTANT NUMBER      := 1.0;
  L_API_NAME      CONSTANT VARCHAR2(30) := 'CREATE_JOBS';

  x_msg_count           NUMBER;
  x_msg_data            VARCHAR2(1000);
  P_INIT_MSG_LIST       VARCHAR2(10) := FND_API.G_FALSE;
  P_COMMIT              VARCHAR2(10) := FND_API.G_FALSE;

  l_all_records_success NUMBER := -1;
  batch_mode_flag boolean := false;

  log_file    VARCHAR2(255);
  output_file VARCHAR2(255);

  --variables for WIP_logger
  l_params        wip_logger.param_tbl_t;
  l_logLevel      NUMBER := fnd_log.g_current_runtime_level;
  l_returnStatus  VARCHAR2(1);
  l_audsid        NUMBER;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT WIP_ATO_JOBS_PRIV;


  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  select userenv('SESSIONID') into l_audsid from dual;
--  fnd_file.log('AUDSID of current session: ' || l_audsid);

 fnd_message.set_name('FND', 'CONC-PARAMETERS');
 fnd_file.put_line(which => fnd_file.log, buff =>  'AUDSID of current session: ' || l_audsid);

  IF (fnd_profile.value('MRP_DEBUG') = 'Y') THEN
    DEBUG_FLAG := TRUE;
  ELSE
    DEBUG_FLAG := FALSE;
  END IF;

fnd_file.put_line(fnd_file.log, 'l_logLevel :'||l_logLevel ||'; wip_constants.trace_logging:'
  ||wip_constants.trace_logging);
    if (l_logLevel <= wip_constants.trace_logging) then
      fnd_file.put_line(fnd_file.log, 'Logging......');
      l_params(1).paramName   := 'P_ORDER_NUMBER ';
      l_params(1).paramValue  :=  P_ORDER_NUMBER ;
      l_params(2).paramName   := 'P_DUMMY_FIELD  ';
      l_params(2).paramValue  :=  P_DUMMY_FIELD ;
      l_params(3).paramName   := 'P_OFFSET_DAYS  ';
      l_params(3).paramValue  :=  P_OFFSET_DAYS  ;
      l_params(4).paramName   := 'P_LOAD_TYPE    ';
      l_params(4).paramValue  := P_LOAD_TYPE    ;
      l_params(5).paramName   := 'P_STATUS_TYPE  ';
      l_params(5).paramValue  := P_STATUS_TYPE ;
      l_params(6).paramName   := 'P_ORG_ID       ';
      l_params(6).paramValue  := P_ORG_ID       ;
      l_params(7).paramName   := 'P_CLASS_CODE   ';
      l_params(7).paramValue  := P_CLASS_CODE   ;
      l_params(8).paramName   := 'P_FAILED_REQ_ID';
      l_params(8).paramValue  := P_FAILED_REQ_ID;
      l_params(9).paramName   := 'P_ORDER_LINE_ID';
      l_params(9).paramValue  := P_ORDER_LINE_ID;
      l_params(10).paramName  := 'P_BATCH_ID     ';
      l_params(10).paramValue := P_BATCH_ID     ;
      l_params(11).paramName  := 'P_API_VERSION  ';
      l_params(11).paramValue := P_API_VERSION  ;

      wip_logger.entryPoint(p_procName      => 'WIP_ATO_JOBS_PRIV.CREATE_JOBS',
                            p_params        => l_params,
                            x_returnStatus  => x_return_status);

      if(x_return_status <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;


  wip_logger.log('WIP Autocreate Final Assembly Orders [PL/SQL]-Start', l_returnStatus);
  wip_logger.log( 'Value of fnd_file.log:'|| fnd_file.log, l_returnStatus);
  wip_logger.log('Value of fnd_file.output:'|| fnd_file.output, l_returnStatus);
  fnd_file.get_names(log_file, output_file);

  wip_logger.log('Log File Name:'|| log_file|| '; Output file name:'|| output_file, l_returnStatus);
  if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('ORDER_NUMBER         = '||P_ORDER_NUMBER    , l_returnStatus);
          wip_logger.log('DUMMY_FIELD          = '||P_DUMMY_FIELD     , l_returnStatus);
          wip_logger.log('OFFSET_DAYS          = '||P_OFFSET_DAYS     , l_returnStatus);
          wip_logger.log('P_LOAD_TYPE          = '||P_LOAD_TYPE       , l_returnStatus);
          wip_logger.log('P_STATUS_TYPE        = '||P_STATUS_TYPE     , l_returnStatus);
          wip_logger.log('P_ORG_ID             = '||P_ORG_ID          , l_returnStatus);
          wip_logger.log('P_CLASS_CODE         = '||P_CLASS_CODE      , l_returnStatus);
          wip_logger.log('P_FAILED_REQ_ID      = '||P_FAILED_REQ_ID   , l_returnStatus);
          wip_logger.log('ORDER_LINE_ID        = '||P_ORDER_LINE_ID   , l_returnStatus);
          wip_logger.log('BATCH_ID             = '||P_BATCH_ID        , l_returnStatus);
          wip_logger.log('P_API_VERSION        = '||P_API_VERSION     , l_returnStatus);
          wip_logger.log('P_INIT_MSG_LIST      = '||P_INIT_MSG_LIST   , l_returnStatus);
          wip_logger.log('P_COMMIT             = '||P_COMMIT          , l_returnStatus);

          fnd_file.new_line(FND_FIlE.LOG,3); --put new line as separators
  end if;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (  l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  wip_logger.log('************* WIP Autocreate Final Assembly Orders *************', l_returnStatus);



    /*---------------------------------------------------------------+
     |  VALIDATE parameter values.                                   |
     |  Substitute -1 if no value found.                             |
     +---------------------------------------------------------------+*/
    if (P_ORDER_NUMBER is NOT NULL) THEN
      L_ORDER_NUMBER     := TO_NUMBER(P_ORDER_NUMBER);
    end if;

    if (P_DUMMY_FIELD is NOT NULL) THEN
      L_DUMMY_FIELD      := TO_NUMBER(P_DUMMY_FIELD);
    end if;

    if (P_OFFSET_DAYS is NOT NULL) THEN
      L_OFFSET_DAYS     := TO_NUMBER(P_OFFSET_DAYS);
    end if;

    if (P_LOAD_TYPE is NOT NULL) THEN
      L_LOAD_TYPE     := TO_NUMBER(P_LOAD_TYPE);
    end if;

    if (P_STATUS_TYPE is NOT NULL) THEN
      L_STATUS_TYPE     := TO_NUMBER(P_STATUS_TYPE);
    end if;

    if (P_ORG_ID is NOT NULL) THEN
      L_ORG_ID     := TO_NUMBER(P_ORG_ID);
    end if;

    if (P_FAILED_REQ_ID is NOT NULL) THEN
      L_FAILED_REQ_ID     := TO_NUMBER(P_FAILED_REQ_ID);
    end if;

    if (P_ORDER_LINE_ID is NOT NULL) THEN
      L_ORDER_LINE_ID     := TO_NUMBER(P_ORDER_LINE_ID);
    end if;

    if (P_BATCH_ID is NOT NULL) THEN
      L_BATCH_ID     := TO_NUMBER(P_BATCH_ID);
    end if;
    /* END Validating parameters*/

    wip_logger.log('Parameters Validated.', l_returnStatus);

    if (l_logLevel <= wip_constants.full_logging) then
      if (L_BATCH_ID = -1) then
        wip_logger.log( 'No Batch id.', l_returnStatus);
      else
        wip_logger.log( 'BATCH STR = '||L_BATCH_ID||'.', l_returnStatus);
      end if;
    end if;

  if ( (L_BATCH_ID<>0) and (L_FAILED_REQ_ID = -1) )  then
  /* NS change */
    /* if there is no order # or order line id, AND there
       is a batch_id, then use order_number=-25 as a flag
       for batch mode.  Note that what we really should do
       is modify the paramptr structure to have a batch_id
       field, but since we can't do that right now, this is
       the temporary hack.  */
    l_all_records_success := -25; /* this is batch mode */
    batch_mode_flag := TRUE;
    L_failed_req_id := L_BATCH_ID;
  end if;

  wip_logger.log('Debug Profile Value:'|| fnd_profile.value('MRP_DEBUG')  , l_returnStatus);

  if (l_logLevel <= wip_constants.full_logging) then

    /* NS add the fact that it is running in batch mode */
    if (batch_mode_flag = true) then
      wip_logger.log('Currently in Batch Mode.  Failed_req_id contains the batch_id.', l_returnStatus);
    end if;

    wip_logger.log('After checks...........', l_returnStatus);
    wip_logger.log('Dbg:org_id = '|| l_org_id , l_returnStatus);
    wip_logger.log('Dbg:offset_days = '|| l_offset_days, l_returnStatus);

    wip_logger.log('Dbg:load_type = '  || l_load_type, l_returnStatus);
    wip_logger.log('Dbg:class_code = ' || P_class_code, l_returnStatus);
    wip_logger.log('Dbg:status_type = '|| l_status_type, l_returnStatus);
    wip_logger.log('Dbg:failed_req_id = '|| l_failed_req_id, l_returnStatus);
    wip_logger.log('Dbg:order_number = ' || l_order_number, l_returnStatus);
    wip_logger.log('Dbg:order_line_id = '|| l_order_line_id, l_returnStatus);
  end if;


    /*--------------------------------------------------------+
     |  Call LOAD_ORDERS, to load orders and do all the work. |
     +--------------------------------------------------------+*/

   if( LOAD_ORDERS
        (
          ERRBUF            =>  ERRBUF,
          RETCODE           =>  x_return_status,
          P_ORDER_NUMBER    =>  L_ORDER_NUMBER,
          p_DUMMY_FIELD     =>  L_DUMMY_FIELD,
          p_OFFSET_DAYS     =>  L_OFFSET_DAYS,
          p_LOAD_TYPE       =>  L_LOAD_TYPE,
          p_STATUS_TYPE     =>  L_STATUS_TYPE,
          p_ORG_ID          =>  L_ORG_ID,
          p_CLASS_CODE      =>  P_CLASS_CODE,
          p_FAILED_REQ_ID   =>  L_FAILED_REQ_ID,
          p_ORDER_LINE_ID   =>  L_ORDER_LINE_ID,
          p_BATCH_ID        =>  L_BATCH_ID,
          p_all_success_ptr =>  L_all_records_success
        )
        = false )
   THEN
         /*-------------------------------------+
           |  Program completion with problem.  |
           |  Handle failure of program         |
           +------------------------------------+*/
         if (l_logLevel <= wip_constants.full_logging) then
             wip_logger.log(
                      'Dbg:Exiting Sales Order Loaded w/errors', l_returnStatus);
         end if;
         APP_EXCEPTION.RAISE_EXCEPTION;

    else
        if (l_all_records_success <> -1) then
        /*--------------------------------------------------------+
          |  Program completion with no major problems             |
          +--------------------------------------------------------+*/
            if (l_logLevel <= wip_constants.full_logging) then
                wip_logger.log( 'Dbg:Exiting Sales Order Loaded w/success', l_returnStatus);
            end if;
        else
            if (l_logLevel <= wip_constants.full_logging) then
                wip_logger.log(
                         'Dbg:Exiting Sales Order Loaded w/warning', l_returnStatus);
            end if;
            --Put Warnings in Error Buffer
            --Log Warnings

        end if;
    end if;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'WIP_ATO_JOBS_PRIV.CREATE_JOBS',
                         p_procReturnStatus => x_return_Status,
                         p_msg => 'PROCEDURE COMPLETE.',
                         x_returnStatus => l_returnStatus);
  END IF;

  RETCODE := x_return_status;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
--    ROLLBACK TO SAVEPOINT WIP_ATO_JOBS_PRIV;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    GOTO END_program;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--    ROLLBACK TO SAVEPOINT WIP_ATO_JOBS_PRIV;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    GOTO END_program;

  WHEN OTHERS THEN
--    ROLLBACK TO SAVEPOINT WIP_ATO_JOBS_PRIV;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    GOTO END_program;

<<END_program>>
    RETCODE := 1;
    wip_utilities.get_message_stack(p_msg =>ERRBUF);
    IF(ERRBUF IS NULL) THEN
      ERRBUF := 'No error message found in the stack';
    END IF;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.log(ERRBUF, l_returnStatus);
      wip_logger.exitPoint(p_procName =>'WIP_ATO_JOBS.CREATE_JOBS',
                           p_procReturnStatus => x_return_status,
                           p_msg => ERRBUF,
                           x_returnStatus => l_returnStatus);
    END IF;
    -- close log file
    wip_logger.cleanUp(x_returnStatus => l_returnStatus);

END CREATE_JOBS;
/*------------------------------------------------------------------+
| End CREATE_JOBS                                                   |
+-------------------------------------------------------------------*/



  PROCEDURE WAIT_CONC_PROGRAM(
      p_request_id in number,
      errbuf          out NOCOPY varchar2,
      retcode         out NOCOPY number)
  is
      l_call_status   boolean;
      l_phase         varchar2(80);
      l_status        varchar2(80);
      l_dev_phase     varchar2(80);
      l_dev_status    varchar2(80);
      l_message       varchar2(240);
      l_counter	      number := 0;
  BEGIN

    LOOP
      l_call_status:= FND_CONCURRENT.WAIT_FOR_REQUEST
                    ( p_request_id,
                      10,
                      -1,
                      l_phase,
                      l_status,
                      l_dev_phase,
                      l_dev_status,
                      l_message);

      exit when l_call_status=false;

      if (l_dev_phase='COMPLETE') then
        if (l_dev_status = 'NORMAL') then
          retcode := -1;
        elsif (l_dev_status = 'WARNING') then
          retcode := 1;
        else
          retcode := 2;
        end if;
        errbuf := l_message;
        return;
      end if;

      l_counter := l_counter + 1;
      exit when l_counter >= 2;

    end loop;

    retcode := 2;
    return ;
END WAIT_CONC_PROGRAM;





/*------------------------------------------------------------------+
|                     Start LOAD_ORDERS                             |
+-------------------------------------------------------------------*/
FUNCTION LOAD_ORDERS
(
          ERRBUF            OUT   NOCOPY VARCHAR2,
          RETCODE           OUT   NOCOPY VARCHAR2,
          P_ORDER_NUMBER    IN    NUMBER DEFAULT -1,
          p_DUMMY_FIELD     IN    NUMBER DEFAULT -1,
          p_OFFSET_DAYS     IN    NUMBER DEFAULT -1,
          p_LOAD_TYPE       IN    NUMBER DEFAULT -1,
          p_STATUS_TYPE     IN    NUMBER DEFAULT -1,
          p_ORG_ID          IN    NUMBER DEFAULT -1,
          p_CLASS_CODE      IN    VARCHAR2 DEFAULT -1,
          p_FAILED_REQ_ID   IN    NUMBER DEFAULT -1,
          p_ORDER_LINE_ID   IN    NUMBER DEFAULT -1,
          p_BATCH_ID        IN    NUMBER DEFAULT -1,
          p_all_success_ptr IN OUT NOCOPY NUMBER )

RETURN    boolean

IS


/*-------------------------------------------------+
 |  Local Variables                                |
 +-------------------------------------------------+*/

    precision_profile VARCHAR2(5)    := NULL;

    l_message_name    varchar2(30);
    l_message_text    varchar2(150);
    l_order_number    NUMBER;
    l_dummy_field     NUMBER;
    l_offset_days     NUMBER;
    l_load_type       NUMBER;
    l_status_type     NUMBER;
    l_org_id          NUMBER;
    l_class_code      VARCHAR2(11);
    l_failed_req_id   NUMBER := P_FAILED_REQ_ID;
    l_order_line_id   NUMBER;
    l_batch_id        NUMBER;

    /* OM Variables */
    l_conc_request_id       NUMBER;
    l_appl_conc_program_id  NUMBER;
    l_program_id            NUMBER;
    l_conc_login_id         NUMBER;
    l_user_id               NUMBER;
    l_wip_group_id          NUMBER;
    l_orders_loaded         NUMBER;
    l_resp_id               NUMBER;
    l_resp_appl_id          NUMBER;

    l_status      NUMBER;
    errflg NUMBER := 0;
    process_rows NUMBER := 0;

    batch_id NUMBER;
    batch_flag NUMBER := 0;
    num_error_records NUMBER;
    wjsi_group_id NUMBER;

    report_status NUMBER := 0;

    L_orders_in_interface number;
    all_success_ptr NUMBER := p_all_success_ptr;
    l_result boolean;

    log_file VARCHAR2(255);
    output_file VARCHAR2(255);
    desname VARCHAR2(80);
    destype VARCHAR2(10);
    desformat VARCHAR2(10);

    --variables for WIP_logger
    l_params wip_logger.param_tbl_t;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_returnStatus VARCHAR2(1);

    report_retcode number;

BEGIN

    retCode := fnd_api.g_ret_sts_success;

    IF (DEBUG_FLAG) THEN
      DEBUG_FLAG := TRUE;
    ELSE
      DEBUG_FLAG := FALSE;
    END IF;


    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName   := 'P_ORDER_NUMBER ';
      l_params(1).paramValue  :=  P_ORDER_NUMBER ;
      l_params(2).paramName   := 'P_DUMMY_FIELD  ';
      l_params(2).paramValue  :=  P_DUMMY_FIELD ;
      l_params(3).paramName   := 'P_OFFSET_DAYS  ';
      l_params(3).paramValue  :=  P_OFFSET_DAYS  ;
      l_params(4).paramName   := 'P_LOAD_TYPE    ';
      l_params(4).paramValue  := P_LOAD_TYPE    ;
      l_params(5).paramName   := 'P_STATUS_TYPE  ';
      l_params(5).paramValue  := P_STATUS_TYPE ;
      l_params(6).paramName   := 'P_ORG_ID       ';
      l_params(6).paramValue  := P_ORG_ID       ;
      l_params(7).paramName   := 'P_CLASS_CODE   ';
      l_params(7).paramValue  := P_CLASS_CODE   ;
      l_params(8).paramName   := 'P_FAILED_REQ_ID';
      l_params(8).paramValue  := P_FAILED_REQ_ID;
      l_params(9).paramName   := 'P_ORDER_LINE_ID';
      l_params(9).paramValue  := P_ORDER_LINE_ID;
      l_params(10).paramName  := 'P_BATCH_ID';
      l_params(10).paramValue := P_BATCH_ID     ;
      l_params(11).paramName  := 'p_all_success_ptr';
      l_params(11).paramValue := p_all_success_ptr  ;

      wip_logger.entryPoint(p_procName      => 'WIP_ATO_JOBS_PRIV.LOAD_ORDERS',
                            p_params        => l_params,
                            x_returnStatus  => l_returnStatus);

      if(l_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    wip_logger.log('Inside Load_Orders.....', l_returnStatus);

    /*---------------------------------------------------------------+
     |  Print out values in argument stucture if in debug mode       |
     +---------------------------------------------------------------+*/
    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('Dbg:org_id = '||p_org_id , l_returnStatus);
      wip_logger.log('Dbg:offset_days = '||p_offset_days, l_returnStatus);

      wip_logger.log('Dbg:load_type = '||p_load_type, l_returnStatus);
      wip_logger.log('Dbg:class_code = '||p_class_code, l_returnStatus);
      wip_logger.log('Dbg:status_type = '||p_status_type, l_returnStatus);
      wip_logger.log('Dbg:failed_req_id = '||p_failed_req_id, l_returnStatus);
      wip_logger.log('Dbg:order_number = '||P_ORDER_NUMBER, l_returnStatus);
      wip_logger.log('Dbg:order_line_id = '||p_order_line_id, l_returnStatus);

      wip_logger.log('Dbg:all_success_rec = '||p_all_success_ptr, l_returnStatus);

    END IF;

    if (p_all_success_ptr = -25)   then
    /* Now we are back to previous version code */
      p_all_success_ptr := 1; /* i.e. TRUE */
      batch_id := L_FAILED_REQ_ID;
      L_FAILED_REQ_ID := -1;
      wip_logger.log('Setting Batch Flag... All_Success==-25', l_returnStatus);
      batch_flag:=1;
    END IF;

    /* As mentioned in CREATE_JOBS, we added a batch_id parameter
        without being able to change the header file, so we used
        p_all_success_ptr as a flag (val=-25) if we store a batch_id.
        In this case, failed_req_id stored out batch_id value, so we
        take the value out and reset failed_req_id to -1  */

    /*===============================================================+
     |  If failed_request_id is not equal to -1, then this process    |
     |  is being run to clean up data from a previously failed       |
     |  run of this program.                                         |
     |                                                               |
     |  When cleaning, up skip the sections that marks mtl_demand    |
     |  records that need to be loaded and inserts records into      |
     |  wip_job_schedule_interface.  Just perform the feedback loop. |
     +===============================================================+*/
    if (L_FAILED_REQ_ID = -1) then

      if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('Dbg: OM Installed: Enter get_order_lines.', l_returnStatus);
      END IF;

      l_org_id       := p_org_id;
      l_offset_days  := p_offset_days;
      l_load_type    := p_load_type;
      L_CLASS_CODE   := P_CLASS_CODE;
      l_status_type  := p_status_type;
      l_order_number := p_order_number;
      l_order_line_id := p_order_line_id;

      l_conc_request_id      := fnd_global.conc_request_id;
      l_appl_conc_program_id := fnd_global.prog_appl_id;
      l_conc_login_id        := fnd_global.conc_login_id;
      l_user_id              := fnd_global.user_id;
      l_program_id           := fnd_global.conc_program_id;

      --to later reset context to original values
      l_resp_id      := FND_GLOBAL.RESP_ID;
      l_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;

      wip_logger.log('Before CTO, Fnd_Global values: user_id:' || fnd_global.user_id, l_returnStatus);

      fnd_file.put_line(which => fnd_file.log, buff =>  'Calling CTO_WIP_WRAPPER.get_order_lines');


      l_status := CTO_WIP_WRAPPER.get_order_lines(
                                           l_org_id,
                                           l_offset_days,
                                           l_load_type,
                                           l_class_code,
                                           l_status_type,
                                           l_order_number,
                                           l_order_line_id,
                                           l_conc_request_id,
                                           l_program_id,
                                           l_conc_login_id,
                                           l_user_id,
                                           l_appl_conc_program_id,
                                           l_orders_loaded,
                                           l_wip_group_id,
                                           l_message_name,
                                           l_message_text);

      fnd_file.put_line(which => fnd_file.log, buff =>  'Return status from CTO_WIP_WRAPPER.get_order_lines:'|| l_status);
      fnd_file.put_line(which => fnd_file.log, buff =>  'Group_Id from CTO_WIP_WRAPPER.get_order_lines: '|| l_wip_group_id);

      --p_wei_group_id :=  l_wip_group_id;
      --p_orders_to_load :=  l_orders_loaded; /* order lines */
      L_orders_in_interface  :=  l_orders_loaded;

      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log(
        'Dbg: Exited get_order_lines with status '||l_status, l_returnStatus);
        wip_logger.log(
        'Dbg: wei_group_id = '||l_wip_group_id, l_returnStatus);
        wip_logger.log(
        'Dbg: Orders Loaded = '||l_orders_loaded, l_returnStatus);
      END IF;

      if (l_status <> 1) then
         APP_EXCEPTION.RAISE_EXCEPTION;
      else
        if (L_orders_loaded = 0) then
	   --start bugfix 4865485
	   p_all_success_ptr := -1;
	   fnd_file.put_line(which => fnd_file.log, buff =>  'L_orders_loaded=> '|| l_orders_loaded);
	   RETCODE := 1;--for warning
	   RETURN false;
	   --end bugfix 4865485
           null; --goto done;
        end if;
      END IF;


      /*----------------------------------------------------------+
        |  Call WIP mass interface routine to create discrete     |
        |  jobs for records loaded into the interface table.      |
        |                                                         |
        |  Calling MASSLOAD PL/SQL Routine                        |
        +---------------------------------------------------------+*/
      fnd_file.put_line(which => fnd_file.log, buff =>  'Calling wip_massload_pub.massLoadJobs with group Id: '|| l_wip_group_id);

      wip_massload_pub.massLoadJobs(
            p_groupID         => l_wip_group_id,
            p_validationLevel => 2,
            p_commitFlag      => 1, --commit in Massload
            x_returnStatus    => retCode,
            x_errorMsg        => errBuf);

      fnd_file.put_line(which => fnd_file.log, buff =>  'Returned from wip_massload_pub.massLoadJobs:');

      IF (retCode <> fnd_api.g_ret_sts_success) THEN
        fnd_file.put_line(which => fnd_file.log, buff =>  'Failed in wip_massload_pub.massLoadJobs.');

        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log( 'Dbg:Failed in wip_massload_pub.massLoadJobs', l_returnStatus);
        END IF;

        -- Bug 9314772.Should not raise exception here so that reservations
	-- are created for jobs created with warnings.In case when the status
	-- returned is error, the reservation api will not pick the record to
	-- create reservation.pdube
	-- APP_EXCEPTION.RAISE_EXCEPTION;
        fnd_file.put_line(which => fnd_file.log, buff =>  'Failed in wip_massload_pub.massLoadJobs returned with status retCode:'||retCode);
      END IF;

      fnd_file.put_line(which => fnd_file.log, buff =>  'Returned successfully from wip_massload_pub.massLoadJobs.');

    END IF;  /*  end of logic skipped when failed_req_id <> -1 */

    /*================================================================+
      |  Do feedback loop.  This means:                               |
      |  - updating MTL_DEMAND for jobs that loaded                   |
      |  - put jobs on hold where OE changed the order during the     |
      |    time THE order load process was running                    |
      |  - inserting records into WIP_SO_ALLOCATIONS                  |
      |  - informing OE to unlink any sales order whose job failed    |
      |    to load                                                    |
      |  - delete records from the interface table                    |
      |  - setting the supply_group_id in MTL_DEMAND back to null     |
      |                                                               |
      |  Feedback is executed regardless of failed_request_id value.  |
      |                                                               |
      |  If failed_request_id <> 0, the program is being run in       |
      |  'cleanup mode' -- see comment earlier in program for details |
      |  on what happens in 'cleanup' mode,  If this is the case,     |
      |  the group_ids used for feedback must be retrieved from       |
      |  MTL_DEMAND and WIP_JOB_SCHEDULE_INTERFACE.                   |
     +===============================================================+*/
    if (L_FAILED_REQ_ID <>  -1) THEN

        /* OM Installed - No Clean-up Mode Code Yet */
        if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log(
              'Dbg: OM Installed: No Clean-Up Mode', l_returnStatus);
        END IF;
    END IF; /* End of Logic for Clean up Mode */


    /* OM Installed */
    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log( 'Dbg: OM Installed: Enter reserve_work_order.', l_returnStatus);
    END IF;

    l_status := CTO_WIP_WRAPPER.reserve_wo_to_so(l_wip_group_id,
                                                  l_message_name,
                                                  l_message_text);

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('Dbg: Exited reserve_wo_to_so with status '||l_status, l_returnStatus);
    END IF;

    if (l_status <> 1) THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;


    /*-----------------------------------------------------------+
    |  Commit at this point so the report will see the latest   |
    |  data.                                                    |
    +-----------------------------------------------------------+*/
    COMMIT;

    /*--------------------------------------------------------------------+
    | Check if any records failed to process successfully. If so, pop   |
    | a warning message on the stack and set the all_success flag to    |
    | FALSE, causing the request to return a Warning.                   |
    +-------------------------------------------------------------------+*/

    wjsi_group_id := l_wip_group_id;

    SELECT COUNT(*) INTO num_error_records
    FROM wip_job_schedule_interface
        WHERE GROUP_ID = wjsi_group_id
          AND (PROCESS_STATUS <> WCOMPLETED
          OR PROCESS_PHASE <> WIP_ML_COMPLETE);

    if (num_error_records > 0) THEN
      all_success_ptr := -1;
    END IF;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log(num_error_records||'records failed to process', l_returnStatus);
    END IF;

    FND_MESSAGE.SET_NAME('WIP','WIP_WARNING_REPORT');
    FND_MSG_PUB.Add;


    /*--------------------------------------------------------------------+
     |  Call report to write results of load process.  Need to run        |
     |  SQL*ReportWriter from this conc program so that we can have the   |
     |  conc program re-submit itself.  That way the user can have orders |
     |  loaded 1 time per week, etc without having to launch the program  |
     |  all the time.  If we tied conc program and SRW together via a     |
     |  a report set they couldn't re-submit themselves as the parameters |
     |  would always be the same (and the report needs to use the group_id|
     |  used by the conc program).  And we can't make the group_id a      |
     |  defaulted param that is selected from the sequence as then the    |
     |  conc program would always use the same group id value when        |
     |  re-submitted.                                                     |
     +--------------------------------------------------------------------+*/

    precision_profile := fnd_profile.value('REPORT_QUANTITY_PRECISION');
    if ( precision_profile = NULL ) then
      precision_profile := 2;
    END IF;

    /*---------------------------------------------------+
     |  Run report.                                      |
     +---------------------------------------------------+*/
    if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('P_group_id='||l_wip_group_id
                          ||'; P_qty_precision='||precision_profile, l_returnStatus);
    END IF;

    fnd_file.new_line(FND_FILE.LOG);
    fnd_file.get_names(log_file, output_file);

    wip_logger.log('Before Report Submit, Fnd_Global values: user_id:' || fnd_global.user_id, l_returnStatus);

    --Since context has been changed in OE_Order_Context_GRP.Set_Created_By_Context
    --Reset Context back to current
    FND_GLOBAL.Apps_Initialize
                (user_id    =>    l_user_id
                ,resp_id    =>    l_resp_id
                ,resp_appl_id =>  l_resp_appl_id);
    wip_logger.log('Before Report, After context setup; Fnd_Global values: user_id:' || fnd_global.user_id, l_returnStatus);

    fnd_file.put_line(which => fnd_file.log, buff =>  'Calling WIPDJATO Report with group id:'|| l_wip_group_id||' and precision_profile:'||precision_profile);

    report_status :=
          FND_REQUEST.SUBMIT_REQUEST('WIP','WIPDJATO',
          '',
          '', false,
          l_wip_group_id, precision_profile, '', '', '', '', '', '', '', '',
          '',  '', '', '', '', '', '', '', '', '',
          '', '', '', '', '', '', '', '', '', '',
          '', '', '', '', '', '', '', '', '', '',
          '', '', '', '', '', '', '', '', '', '',
          '', '', '', '', '', '', '', '', '', '',
          '', '', '', '', '', '', '', '', '', '',
          '', '', '', '', '', '', '', '', '', '',
          '', '', '', '', '', '', '', '', '', '',
          '', '', '', '', '', '', '', '', '', '');

commit;

        wip_logger.log('Conc Request no:'||report_status, l_returnStatus);

        IF (report_status = 0) THEN
          report_retcode := 2;
        END IF;

      /* if report didn't launch*/
      if(report_status = 0 ) then

        wip_logger.log(errbuf, l_returnStatus);

        FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
        wip_logger.log('==========================================', l_returnStatus);
        if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('Could not execute report.', l_returnStatus);
        END IF;
        all_success_ptr := -1;

      /* if report launched succesfully*/
      else

        /* wait for report to finish */
        WAIT_CONC_PROGRAM(report_status,ERRBUF,report_retcode);

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Assemble to Order Massload Report return code : '||report_retcode);
        /* report returns with error or waning */
        if (report_retcode <> -1 ) then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Report has errored or has a warning');
          errbuf := fnd_message.get;
          raise FND_API.G_EXC_ERROR ;
        else
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('Report: Assemble To Order Mass Load Report ran successfully ', l_returnStatus);
            wip_logger.log('Check Output and Log file for Conc Request Number:'|| report_status, l_returnStatus);
          END IF;
        end if;

      END IF;


    if ( delete_interface_orders(p_wei_group_id  => l_wip_group_id) = false )
    THEN
        if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log(
                     'Dbg:Failed in delete_interface_orders', l_returnStatus);
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    /*--------------------------------------------------------+
     |  Program completion with no major problems             |
     +--------------------------------------------------------+*/
    if (l_logLevel <= wip_constants.full_logging) then
        /* OM Installed */
        wip_logger.log(
              'Dbg:Exiting Filter Order Lines w/success', l_returnStatus);
    END IF;

    if (L_FAILED_REQ_ID =  -1) THEN
      if (l_orders_loaded = 0) THEN
        FND_MESSAGE.SET_NAME('WIP', 'WIP_NO_ORDERS_TO_LOAD');
        ERRBUF := FND_MESSAGE.GET;
        fnd_file.put_line(FND_FILE.OUTPUT,errbuf);
      END IF;
      if (l_orders_in_interface = 0) THEN
        FND_MESSAGE.SET_NAME ('WIP', 'WIP_NO_ORDERS_IN_INTERFACE');
            ERRBUF := FND_MESSAGE.GET;
            fnd_file.put_line(FND_FILE.OUTPUT,errbuf);
      END IF;
    END IF;


  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'WIP_ATO_JOBS_PRIV.LOAD_ORDERS',
                         p_procReturnStatus => l_returnStatus,
                         p_msg => 'PROCEDURE COMPLETE.',
                         x_returnStatus => l_returnStatus);
  END IF;
--    COMMIT;
  return(TRUE);


    /*-------------------------------------+
      |  Program completion with probmlem. |
      |  Handle failure of program         |
      +------------------------------------+*/
-- error:
   /*  end LOAD_ORDERS */

EXCEPTION

  WHEN OTHERS THEN
    if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log(
          'Dbg:Exiting Sales Order Loader w/errors', l_returnStatus);
    END IF;
    return FALSE;

END LOAD_ORDERS;
/*------------------------------------------------------------------+
|                     End LOAD_ORDERS                               |
+-------------------------------------------------------------------*/





/*------------------------------------------------------------------+
|                 Start DELTE_INTERFACE_ORDERS                      |
+-------------------------------------------------------------------*/
Function delete_interface_orders(p_wei_group_id  NUMBER)
  return boolean

IS

  wei_group_id NUMBER;
  n_undeleted_records NUMBER ;

--variables for WIP_logger
  l_params wip_logger.param_tbl_t;
  l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  l_returnStatus VARCHAR2(1);
  x_return_status VARCHAR2(255);


BEGIN

  IF (DEBUG_FLAG) THEN
    DEBUG_FLAG := TRUE;
  ELSE
    DEBUG_FLAG := FALSE;
  END IF;


  if (l_logLevel <= wip_constants.trace_logging) then
    l_params(1).paramName   := 'p_wei_group_id ';
    l_params(1).paramValue  :=  p_wei_group_id ;
    wip_logger.entryPoint(p_procName      => 'WIP_ATO_JOBS_PRIV.DELETE_INTERFACE_ORDERS',
                          p_params        => l_params,
                          x_returnStatus  => x_return_status);

    if(x_return_status <> fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
  end if;


  wei_group_id := p_wei_group_id;

  /*-------------------------------------------+
   |  If in debug mode, print out parameters   |
   +-------------------------------------------+*/
  if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log(
               'Dbg: In delete_interface_orders function', l_returnStatus);
      wip_logger.log( 'Dbg:wei_group_id = '||wei_group_id, l_returnStatus);
  END IF;

    /*
     * Clean up the interface table and interface errors table.
     * When running in debug mode, we never delete from the errors table,
     * and we delete only those interface records which have been successfully
     * processed. When running in debug mode, we always delete all records
     * for the current group from both tables -- we rely on the WIPDJATO
     * report to have communicated any errors.
     *
     * This compromise between deleting everything and deleting only
     * non-problem records while in debug mode hopefully represents the
     * final fix for bug 775437 and its predecessors.
     */

    if (l_logLevel <= wip_constants.full_logging) then

       /* bugfix 4289455 : Remove the records from WIE since we are deleting WJSI record
                 with process phase and process status  COMPLETE else these may remain orphan */
       DELETE FROM WIP_INTERFACE_ERRORS
         WHERE INTERFACE_ID IN (
                 SELECT INTERFACE_ID
                 FROM   WIP_JOB_SCHEDULE_INTERFACE
                 WHERE  GROUP_ID = wei_group_id
                 AND    PROCESS_PHASE = WIP_ML_COMPLETE
                 AND    PROCESS_STATUS = WCOMPLETED);

       DELETE FROM WIP_JOB_SCHEDULE_INTERFACE I
         WHERE I.GROUP_ID = wei_group_id
           AND   I.PROCESS_PHASE = WIP_ML_COMPLETE
           AND   I.PROCESS_STATUS = WCOMPLETED;

       /* bugfix 4289455 : Remove the record from WJSI if process phase and
            process status is COMPLETE. If left as it is, we may encounter bug 2433627.
               AND   0 = (SELECT COUNT(*)
                          FROM WIP_INTERFACE_ERRORS E
                          WHERE E.INTERFACE_ID = I.INTERFACE_ID) ;
        */

    else

      DELETE FROM WIP_INTERFACE_ERRORS
        WHERE  INTERFACE_ID IN
                (SELECT INTERFACE_ID
                 FROM   WIP_JOB_SCHEDULE_INTERFACE
                 WHERE  GROUP_ID = wei_group_id);

      DELETE FROM wip_job_schedule_interface wei
        WHERE group_id = wei_group_id;

    END IF;


    if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('Dbg:'||SQL%ROWCOUNT||' records deleted from interface', l_returnStatus);

      SELECT COUNT(*) INTO n_undeleted_records
      FROM WIP_JOB_SCHEDULE_INTERFACE WHERE GROUP_ID = wei_group_id ;

      if(n_undeleted_records <> 0) THEN
        wip_logger.log('Dbg:Note: '||n_undeleted_records||' error/unprocessed records remain', l_returnStatus);
        wip_logger.log('Dbg:for WIP_JOB_SCHEDULE_INTERFACE.GROUP_ID='||wei_group_id||'.', l_returnStatus);
        wip_logger.log('Dbg:Join on INTERFACE_ID with WIP_INTERFACE_ERRORS', l_returnStatus);
        wip_logger.log('Dbg:for details.', l_returnStatus);
      END IF;

      wip_logger.log(
               'Dbg:Success in delete_interface_orders', l_returnStatus);
    END IF;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'WIP_ATO_JOBS_PRIV.DELETE_INTERFACE_ORDERS',
                         p_procReturnStatus => l_returnStatus,
                         p_msg => 'PROCEDURE COMPLETE.',
                         x_returnStatus => l_returnStatus);
  END IF;

  return(TRUE);


EXCEPTION
  WHEN OTHERS THEN
    if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log( 'Dbg:SQL error in delete_interface_orders', l_returnStatus);
    END IF;
    return(FALSE);

  /* end of delete_interface_orders  */

END delete_interface_orders;

/*------------------------------------------------------------------+
|                     End DELETE_INTERFACE_ORDERS                   |
+-------------------------------------------------------------------*/



END WIP_ATO_JOBS_PRIV;


/
