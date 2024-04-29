--------------------------------------------------------
--  DDL for Package HR_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DATA_PUMP" AUTHID CURRENT_USER as
/* $Header: hrdpump.pkh 120.1 2006/01/05 11:14:13 arashid noship $ */
/*
  Notes
  o This package holds definition for the Data Pump engine.
    The procedures in this package are public but should not be
    called directly.  Concurrent manager definitions exist to
    allow Data Pump to be run via the manager.
*/
g_disable_lookup_checks boolean := false;

/*---------------------------------------------------------------------------*/
/*------------------------ public logging procedures ------------------------*/
/*---------------------------------------------------------------------------*/
/*
 *  These procedures are designed specifically to implement parts
 *  of the Data Pump logging strategy.  They are complemented by
 *  other, private procedures.  These particular ones are declared
 *  public so they can be called from within Meta Mapper generated
 *  and get_id function calls, where appropriate.
 */

------------------------------------ entry ------------------------------------
/*
  NAME
    entry
  DESCRIPTION
    This logs an entry message.
  NOTES
    Logging procedure to flag entry to procedure.
*/

procedure entry
(
   p_procedure_name in varchar2
);

------------------------------------ exit -------------------------------------
/*
  NAME
    exit
  DESCRIPTION
    This logs an exit message.
  NOTES
    Logging procedure to flag exit from procedure.
*/

procedure exit
(
   p_procedure_name in varchar2
);

---------------------------------- api_trc_on ---------------------------------
/*
  NAME
    api_trc_on
  DESCRIPTION
    This turns tracing on before an API call.
*/

procedure api_trc_on;

---------------------------------- api_trc_off --------------------------------
/*
  NAME
    api_trc_off
  DESCRIPTION
    Turns tracing off after an API call.
*/

procedure api_trc_off;

----------------------------------- message -----------------------------------
/*
  NAME
    message
  DESCRIPTION
    General message logging.
  NOTES
    Will log the message text passed to this procedure.
*/

procedure message
(
   p_message varchar2
);

------------------------------------- fail ------------------------------------
/*
  NAME
    fail
  DESCRIPTION
    Log failure information.
  NOTES
    This logs the failure information text to an internal
    data structure, which can then be output as necessary.
*/
procedure fail
(
   p_function_name in varchar2,
   p_error_message in varchar2,
   p_arg01         in varchar2 default null,
   p_arg02         in varchar2 default null,
   p_arg03         in varchar2 default null,
   p_arg04         in varchar2 default null,
   p_arg05         in varchar2 default null,
   p_arg06         in varchar2 default null,
   p_arg07         in varchar2 default null,
   p_arg08         in varchar2 default null
);
pragma restrict_references (fail, WNDS);

/*---------------------------------------------------------------------------*/
/*------------------------ main interface procedures ------------------------*/
/*---------------------------------------------------------------------------*/

---------------------------------- slave --------------------------------------
/*
  NAME
    slave
  DESCRIPTION
    Entry point for slave process.
  NOTES
    This procedure should be called via the concurrent manager.
    Under normal circumstances, it should NOT be called directly.
*/

procedure slave
(
   errbuf              out nocopy varchar2,
   retcode             out nocopy number,
   p_business_group_id in  number,
   p_security_group_id in  number,
   p_batch_id          in  number,
   p_max_errors        in  binary_integer,
   p_validate          in  varchar2 default 'N'
  ,p_pap_group_id      in  number   default null
);

---------------------------------- main ---------------------------------------
/*
  NAME
    main
  DESCRIPTION
    Main entry point for Data Pump engine.
  NOTES
    This procedure should be called via the concurrent manager.
    Under normal circumstances, it should NOT be called directly.
*/

procedure main
(
   errbuf     out nocopy varchar2,
   retcode    out nocopy number,
   p_batch_id in  number,
   p_validate in  varchar2 default 'N'
  ,p_pap_group_id in  number default null
);

-------------------------------- purgemain ------------------------------------
/*
  NAME
    purgemain
  DESCRIPTION
    Main entry point for Data Pump purge.
  NOTES
    This procedure should be called via the concurrent manager.
    Under normal circumstances, it should NOT be called directly.
*/

procedure purgemain
(errbuf                  out nocopy varchar2
,retcode                 out nocopy number
,p_batch_id           in            number   default null
,p_all_batches        in            varchar2 default 'N'
,p_preserve_user_keys in            varchar2 default 'N'
,p_purge_unprocessed  in            varchar2 default 'Y'
,p_purge_errored      in            varchar2 default 'Y'
,p_purge_completed    in            varchar2 default 'Y'
,p_delete_header      in            varchar2 default 'Y'
,p_pap_group_id       in            number   default null
);

-------------------------------- purgeslave -----------------------------------
/*
  NAME
    purgeslave
  DESCRIPTION
    Entry point for Data Pump purge slave process.
  NOTES
    This procedure should be called via the concurrent manager.
    Under normal circumstances, it should NOT be called directly.
*/
procedure purgeslave
(errbuf                  out nocopy varchar2
,retcode                 out nocopy number
,p_batch_id           in            number   default null
,p_all_batches        in            varchar2 default 'N'
,p_preserve_user_keys in            varchar2 default 'N'
,p_purge_unprocessed  in            varchar2 default 'Y'
,p_purge_errored      in            varchar2 default 'Y'
,p_purge_completed    in            varchar2 default 'Y'
,p_delete_header      in            varchar2 default 'Y'
,p_chunk_size         in            number
,p_thread_number      in            number
,p_threads            in            number
,p_pap_group_id       in            number
,p_lower_bound        in            number
,p_upper_bound        in            number
);

end hr_data_pump;

 

/
