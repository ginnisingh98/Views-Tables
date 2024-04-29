--------------------------------------------------------
--  DDL for Package Body RLM_INBOUND_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_INBOUND_SV" as
/* $Header: RLMEDINB.pls 120.1 2005/07/17 18:34:03 rlanka noship $*/
/*=========================RLM_INBOUND_SV ===========================*/


/*===========================================================================

        PROCEDURE NAME:  PROCESS_INBOUND

===========================================================================*/
-- MOAC : Added p_org_id parameter.

PROCEDURE PROCESS_INBOUND
        (
        errbuf                  OUT NOCOPY             VARCHAR2,
        retcode                 OUT NOCOPY             VARCHAR2,
        p_org_id                IN              number,
        p_file_path             IN              VARCHAR2,
        p_file_name             IN              VARCHAR2,
        p_transaction_type      IN              VARCHAR2,
        p_map_id                IN              NUMBER,
        p_debug_mode            IN              NUMBER,
        p_run_import            IN              VARCHAR2,
        p_enable_warn           IN              varchar2,
        p_warn_replace_schedule IN              VARCHAR2,
        p_child_processes       IN              NUMBER DEFAULT 0,
        p_data_file_char_set    IN              VARCHAR2
        )
IS
   --
   i_submit_id	NUMBER:=0;
   i_run_id	NUMBER;
   i_header_id	NUMBER;
   i_count      NUMBER:=0;
   v_submit     NUMBER:=0;
   i_map_type	VARCHAR2(40);
   v_warn_replace VARCHAR2(1) := 'N';

   cEnabled        VARCHAR2(1):= 'Y';
   ece_transaction_disabled   EXCEPTION;

 /*  CURSOR c_header_cur IS
     SELECT   header_id
     FROM     rlm_interface_headers
     WHERE    request_id = i_run_id;
*/

   --
BEGIN
   --
   ec_debug.enable_debug(p_debug_mode);
   ec_debug.pl(0,'EC','ECE_START_INBOUND','TRANSACTION_TYPE',p_transaction_type);
   ec_debug.push('RLM_INBOUND_SV.PROCESS_INBOUND');
   ec_debug.pl(3,'p_file_path',p_file_path);
   ec_debug.pl(3,'p_file_name',p_file_name);
   ec_debug.pl(3,'p_run_import',p_run_import);
   ec_debug.pl(3,'p_map_id',p_map_id);
   ec_debug.pl(3,'p_debug_mode',p_debug_mode);
   ec_debug.pl(3,'p_transaction_type',p_transaction_type);
   ec_debug.pl(3,'p_data_file_char_set',p_data_file_char_set);

   /* Check to see if the transaction is enabled. If not, abort */
   fnd_profile.get('ECE_' || p_transaction_type || '_ENABLED',cEnabled);
   --
   IF cEnabled = 'N' THEN
      RAISE ece_transaction_disabled;
   END IF;
   --
   ec_debug.pl(0,'EC','ECE_BEGIN_STAGING','TRANSACTION_TYPE',
                         p_transaction_type);
   ec_inbound_stage.g_source_charset := p_data_file_char_set;

   -- MOAC changes
   MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id => p_org_id);

   --
   SELECT map_type
   INTO i_map_type
   FROM ece_mappings
   WHERE map_id = p_map_id
   AND enabled ='Y';
   --
   IF i_map_type = 'XML' THEN
       --
       ec_xml_utils.ec_xml_processor_in_generic
                (
                p_map_id,
                i_run_id,
                p_file_path,
                p_file_name
                );
       --
   ELSE
       --
       ec_inbound_stage.load_data
			(
			p_transaction_type,
			p_file_name,
			p_file_path,
			p_map_id,
			i_run_id
			);
   END IF;
   --
   /** Initialize the Stack Table **/
   ec_debug.pl(0,'EC','ECE_END_STAGING','TRANSACTION_TYPE',p_transaction_type);
   --
   ec_utils.g_stack.DELETE;
   --
   ec_debug.pl(0,'EC','ECE_START_GENERIC_INBOUND',
                      'TRANSACTION_TYPE', p_transaction_type);
   --
   ece_inbound.process_run_inbound (
		i_transaction_type => p_transaction_type,
		i_run_id => i_run_id);
   --
   ec_debug.pl(0,'EC','ECE_FINISH_GENERIC_INBOUND',
                      'TRANSACTION_TYPE',p_transaction_type);
   --
   --4316744: Time zone uptake in RLM

   UpdateHorizonDates(p_run_id => i_run_id);

   IF (p_Run_Import = 'Y') THEN
       --
       i_count :=  GetCountInterfaceHeaderId(i_run_id);
       --

       ec_debug.pl(3,'i_count', i_count);

       --
       IF (i_count >0) THEN
          --
          ec_debug.pl(0,'EC','ECE_EXECUTE_OPEN_INTERFACE','TRANSACTION_TYPE',
                         p_transaction_type,'REQUEST_ID',i_run_id);

--bug 1873870

/*
          --
          i_Submit_ID := fnd_request.submit_request
                        (
                          'RLM', 'RLMDSP', NULL, NULL, FALSE,
                          NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, i_header_id,
                          p_warn_replace_schedule
                         );
          --

*/

          --
          -- MOAC: Added p_rog_id to the following API call.

          i_Submit_ID := fnd_request.submit_request
                        (
                          'RLM', 'RLMDSP', NULL, NULL, FALSE,
                          p_org_id,NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL,NULL,NULL,
                          p_warn_replace_schedule,NULL,p_child_processes,i_run_id
                         );
          --


          ec_debug.pl(0,'EC','ECE_EXECUTE_OPEN_INTERFACE','TRANSACTION_TYPE',
                         p_transaction_type,'REQUEST_ID',i_Submit_Id);
          --
       END IF;
       --
   END IF;
   --
   COMMIT;
   --
   retcode := ec_utils.i_ret_code;
   ec_debug.pl(3,'retcode',retcode);
   ec_debug.pl(3,'errbuf',errbuf);
   ec_debug.pop('RLM_INBOUND_SV.PROCESS_INBOUND');
   ec_debug.pl(0,'EC','ECE_END_INBOUND','TRANSACTION_TYPE',p_transaction_type);
   ec_debug.disable_debug;
   --
EXCEPTION
   --
   WHEN NO_DATA_FOUND THEN
        --
        ec_debug.pl(0,'EC','ECE_NO_MAP_TYPE',
                     'TRANSACTION',p_transaction_type);
        retcode := 1;
        ec_debug.disable_debug;
        ROLLBACK WORK;
        --
   WHEN ece_transaction_disabled THEN
        --
        ec_debug.pl(0,'EC','ECE_TRANSACTION_DISABLED',
                     'TRANSACTION',p_transaction_type);
        retcode := 1;
        ec_debug.disable_debug;
        ROLLBACK WORK;
        --
   WHEN EC_UTILS.PROGRAM_EXIT then
        --
        errbuf := ec_utils.i_errbuf;
        retcode := ec_utils.i_ret_code;
        ece_flatfile_pvt.print_attributes;
        ROLLBACK WORK;
        ec_debug.disable_debug;
        --
   WHEN OTHERS THEN
        --
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',
                      'RLM_INBOUND_SV.PROCESS_INBOUND');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        retcode := 2;
        ROLLBACK WORK;
        ece_flatfile_pvt.print_attributes;
        ec_debug.disable_debug;
        --
END PROCESS_INBOUND;

FUNCTION   GetCountInterfaceHeaderId(x_request_id  IN NUMBER)
RETURN NUMBER
IS
  --
  x_count NUMBER;
  --
BEGIN
  --
  ec_debug.pl(0,'EC','ECE_START_GET_HEADER','REQUEST_ID',x_request_id);
  ec_debug.push('RLM_INBOUND_SV.GetCountInterfaceHeaderId');
  ec_debug.pl(3,'request_id',x_request_id);
  --
  SELECT count(*)
  INTO   x_count
  FROM   rlm_interface_headers
  where  request_id = x_request_id;
  --
  ec_debug.pl(3,'count',x_count);
  ec_debug.pop('RLM_INBOUND_SV.GetCountInterfaceHeaderId');
  ec_debug.pl(0,'EC','ECE_END_GET_HEADER','REQUEST_ID',x_request_id);
  RETURN x_count;
  --
EXCEPTION
   --
   WHEN NO_DATA_FOUND THEN
        --
        ec_debug.pl(0,'EC','ECE_NO_HEADER',
                     'REQUEST',x_request_id);
        ec_debug.pop('RLM_INBOUND_SV.GETCOUNTINTERFACEHEADERID');
        RETURN NULL;
        --

   WHEN OTHERS THEN
        --
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',
                      'RLM_INBOUND_SV.GETCOUNTINTERFACEHEADERID');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_debug.pop('RLM_INBOUND_SV.GETCOUNTINTERFACEHEADERID');
        raise;
        --
END GetCountInterfaceHeaderId;

--4316744: Timezone uptake in RLM.Added the following new procedure.

/*===========================================================================

        PROCEDURE NAME: UpdateHorizonDates

===========================================================================*/

PROCEDURE UpdateHorizonDates(p_run_id IN NUMBER) IS
BEGIN
  --
  ec_debug.pl(0,'EC','ECE_START_UPDATE_HZ_DATES','RUN_ID',p_run_id);
  ec_debug.push('RLM_INBOUND_SV.UpdateHorizonDates');
  ec_debug.pl(3,'p_run_id', p_run_id);
  --
  UPDATE rlm_interface_headers_all
  SET sched_horizon_start_date = TRUNC(sched_horizon_start_date),
      sched_horizon_end_date   = TRUNC(sched_horizon_end_date) + 0.99999
  WHERE header_id IN
        (SELECT header_id
         FROM rlm_interface_headers
         WHERE request_id = p_run_id);
  --
  ec_debug.pl(3, 'Number of headers updated', SQL%ROWCOUNT);
  ec_debug.pop('RLM_INBOUND_SV.UpdateHorizonDates');
  ec_debug.pl(0,'EC','ECE_END_UPDATE_HZ_DATES', 'p_run_id', p_run_id);
  --
EXCEPTION
  --
  WHEN NO_DATA_FOUND THEN
   --
   ec_debug.pl(0,'EC','ECE_NO_HEADER',
               'p_run_id', p_run_id);
   ec_debug.pop('RLM_INBOUND_SV.UpdateHorizonDates');
   --
  WHEN OTHERS THEN
   --
   ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',
               'RLM_INBOUND_SV.UpdateHorizonDates');
   ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
   ec_debug.pop('RLM_INBOUND_SV.UpdateHorizonDates');
   raise;
   --
END UpdateHorizonDates;


END RLM_INBOUND_SV;

/
