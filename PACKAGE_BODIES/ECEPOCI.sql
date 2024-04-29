--------------------------------------------------------
--  DDL for Package Body ECEPOCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECEPOCI" AS
/* $Header: ECPOCIB.pls 120.2.12010000.2 2008/11/24 17:24:13 akemiset ship $ */

PROCEDURE Process_POCI_Inbound (
	errbuf			OUT NOCOPY	varchar2,
	retcode			OUT NOCOPY	varchar2,
	i_file_path             IN      varchar2,
        i_file_name             IN      varchar2,
        i_debug_mode            IN      number,
        i_run_import            IN      varchar2,
        i_num_instances     IN  number default 1,
	i_transaction_type	IN	varchar2,
	i_map_id		IN	number,
        i_data_file_characterset  IN    varchar2
--	i_debug_mode		IN	number
--        i_num_instances     IN  number default 1
        )
IS
	i_submit_id		number;
	i_run_id		number;
	i_map_type		varchar2(40);

      cEnabled                   VARCHAR2(1)          := 'Y';
      ece_transaction_disabled   EXCEPTION;

begin
	ec_debug.enable_debug(i_debug_mode);
	ec_debug.pl(0,'EC','ECE_START_INBOUND','TRANSACTION_TYPE',i_transaction_type);
	ec_debug.push('ECEPOCI.PROCESS_POCI_INBOUND');
	ec_debug.pl(3,'i_file_path',i_file_path);
	ec_debug.pl(3,'i_file_name',i_file_name);
	ec_debug.pl(3,'i_run_import',i_run_import);
	ec_debug.pl(3,'i_map_id',i_map_id);
	ec_debug.pl(3,'i_debug_mode',i_debug_mode);
        ec_debug.pl(3,'i_num_instances',i_num_instances);

         /* Check to see if the transaction is enabled. If not, abort */
        fnd_profile.get('ECE_' || i_transaction_type || '_ENABLED',cEnabled);
        IF cEnabled = 'N' THEN
           RAISE ece_transaction_disabled;
        END IF;

	ec_debug.pl(0,'EC','ECE_BEGIN_STAGING','TRANSACTION_TYPE',i_transaction_type);

	select map_type into i_map_type
        from ece_mappings
        where map_id = i_map_id
          and enabled ='Y';

       ec_inbound_stage.g_source_charset := i_data_file_characterset;

	IF i_map_type = 'XML' THEN
           ec_xml_utils.ec_xml_processor_in_generic (
                i_map_id,
                i_run_id,
                i_file_path,
                i_file_name
                );
	ELSE
	   ec_inbound_stage.load_data (
                i_transaction_type,
                i_file_name,
                i_file_path,
                i_map_id,
                i_run_id
                );
        END IF;

	ec_debug.pl(0,'EC','ECE_END_STAGING','TRANSACTION_TYPE',i_transaction_type);

	/**
	Initialize the Stack Table
	**/
	ec_utils.g_stack.DELETE;

	ec_debug.pl(0,'EC','ECE_START_GENERIC_INBOUND','TRANSACTION_TYPE',i_transaction_type);
        ece_inbound.process_run_inbound (
                i_transaction_type => i_transaction_type,
                i_run_id => i_run_id
                );

	ec_debug.pl(0,'EC','ECE_FINISH_GENERIC_INBOUND','TRANSACTION_TYPE',i_transaction_type);

	IF i_Run_Import = 'Y' THEN
           i_Submit_ID := fnd_request.submit_request (
            		application => 'ONT',
            		program     => 'OEOIMP',
			argument1   => NULL , --Operating_unit_id  bug6918092
            		argument2   => '6',	-- Order_Source_Id =6 for EDI
            		argument3   => '',	-- Order Ref = all
            		argument4   => 'UPDATE',-- Operation code = UPDATE
            		argument5   => 'N',	-- Validate_Only = 'N'
            		argument6   => '1',	-- Debug Level = 1
                        argument7   => i_num_instances -- No. of Instances
			);

	   ec_debug.pl(0,'EC','ECE_EXECUTE_OPEN_INTERFACE',
			      'TRANSACTION_TYPE',i_transaction_type,
			      'REQUEST_ID',i_Submit_Id);
      	END IF;

	COMMIT;
	retcode := ec_utils.i_ret_code;

	IF ec_mapping_utils.ec_get_trans_upgrade_status(i_transaction_type)  = 'U' THEN
   	   ec_debug.pl(0,'EC','ECE_REC_TRANS_PENDING',NULL);
   	   retcode := 1;
	END IF;

	ec_debug.pl(3,'i_submit_id',i_submit_id);
	ec_debug.pl(3,'retcode',retcode);
	ec_debug.pl(3,'errbuf',errbuf);
	ec_debug.pop('ECEPOCI.PROCESS_POCI_INBOUND');

	ec_debug.pl(0,'EC','ECE_END_INBOUND','TRANSACTION_TYPE',i_transaction_type);
	ec_debug.disable_debug;

   EXCEPTION
     WHEN ece_transaction_disabled THEN
         ec_debug.pl(0,'EC','ECE_TRANSACTION_DISABLED','TRANSACTION',i_transaction_type);
         retcode := 1;
         ec_debug.disable_debug;
         ROLLBACK WORK;

     WHEN EC_UTILS.PROGRAM_EXIT then
	errbuf := ec_utils.i_errbuf;
	retcode := ec_utils.i_ret_code;
	ece_flatfile_pvt.print_attributes;
	rollback work;
	ec_debug.disable_debug;

     WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',
			   'ECEPOCI.PROCESS_POCI_INBOUND');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	retcode := 2;
	rollback work;
	ece_flatfile_pvt.print_attributes;
	ec_debug.disable_debug;

END PROCESS_POCI_INBOUND;


PROCEDURE def_creation_date(
          p_operation_code     IN VARCHAR2,
          p_creation_date_in   IN  DATE,
          p_creation_date_out  OUT NOCOPY DATE
          )
IS
BEGIN

  IF (UPPER(p_operation_code) = 'INSERT') AND
           p_creation_date_in IS NULL THEN
    p_creation_date_out := SYSDATE;
  ELSE
    p_creation_date_out := p_creation_date_in;
  END IF;

END def_creation_date;

PROCEDURE def_automatic_flag(
          p_operation_code    IN VARCHAR2,
          p_automatic_flag_in IN VARCHAR2,
          p_automatic_flag_out OUT NOCOPY VARCHAR2
          )
IS
BEGIN

  IF (UPPER(p_operation_code) = 'INSERT') AND
           p_automatic_flag_in IS NULL THEN
    p_automatic_flag_out := 'N';
  ELSE
    p_automatic_flag_out := p_automatic_flag_in;
  END IF;

END def_automatic_flag;

PROCEDURE def_calc_prc_flag(
          p_operation_code    IN VARCHAR2,
          p_calc_prc_flag_in  IN VARCHAR2,
          p_calc_prc_flag_out OUT NOCOPY VARCHAR2
          )
IS
BEGIN

  IF (UPPER(p_operation_code) = 'INSERT') AND
           p_calc_prc_flag_in IS NULL THEN
    p_calc_prc_flag_out := 'Y';
  ELSE
    p_calc_prc_flag_out := p_calc_prc_flag_in;
  END IF;

END def_calc_prc_flag;

PROCEDURE def_created_by(
          p_operation_code    IN VARCHAR2,
          p_created_by_in     IN NUMBER,
          p_created_by_out    OUT NOCOPY NUMBER
          )
IS
BEGIN

  IF (UPPER(p_operation_code) = 'INSERT') AND
           p_created_by_in IS NULL THEN
    p_created_by_out := FND_GLOBAL.USER_ID;
  ELSE
    p_created_by_out := p_created_by_in;
  END IF;

END def_created_by;


END ECEPOCI;

/
