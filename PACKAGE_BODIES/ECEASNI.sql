--------------------------------------------------------
--  DDL for Package Body ECEASNI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECEASNI" as
-- $Header: ECWASNIB.pls 120.2 2005/09/30 07:25:45 arsriniv ship $
procedure process_asni_docs
	(
	i_transaction_type	IN	varchar2,
	i_run_id		IN	number
	)
is
BEGIN
ec_debug.push('ECEASNI.PROCESS_ASNI_DOCS');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_run_id',i_run_id);

	/**
	Initialize the Stack Table
	**/
	ec_utils.g_stack.DELETE;

	ec_debug.pl(0,'EC','ECE_START_GENERIC_INBOUND','TRANSACTION_TYPE',i_transaction_type);
        ece_inbound.process_run_inbound
                (
                i_transaction_type => i_transaction_type,
                i_run_id => i_run_id
                );
	ec_debug.pl(0,'EC','ECE_FINISH_GENERIC_INBOUND','TRANSACTION_TYPE',i_transaction_type);

ec_debug.pop('ECEASNI.PROCESS_ASNI_DOCS');
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECEASNI.PROCESS_ASNI_DOCS');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code :=2;
	raise EC_UTILS.PROGRAM_EXIT;
end process_asni_docs;

procedure process_asni_inbound
	(
	errbuf			OUT NOCOPY	varchar2,
	retcode			OUT NOCOPY	varchar2,
	i_file_path             IN      varchar2,
        i_file_name             IN      varchar2,
        i_run_import            IN      varchar2,
	i_transaction_type	IN	varchar2,
	i_map_id		IN	number,
	i_debug_mode		IN	number,
	i_source_charset	IN	varchar2
        )
is
	i_submit_id		number;
	i_run_id		number;
      	i_map_type		varchar2(40);
	cEnabled                   VARCHAR2(1)          := 'Y';
      	ece_transaction_disabled   EXCEPTION;

begin
ec_debug.enable_debug(i_debug_mode);
ec_debug.pl(0,'EC','ECE_START_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.push('ECEASNI.PROCESS_ASNI_INBOUND');
ec_debug.pl(3,'i_file_path',i_file_path);
ec_debug.pl(3,'i_file_name',i_file_name);
ec_debug.pl(3,'i_run_import',i_run_import);
ec_debug.pl(3,'i_map_id',i_map_id);
ec_debug.pl(3,'i_debug_mode',i_debug_mode);
ec_debug.pl(3,'i_source_charset',i_source_charset);

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

	/* bug 2162062 : Set the global variable for the characterset based on the input characterset */

        ec_inbound_stage.g_source_charset:= i_source_charset;

        IF i_map_type = 'XML' THEN
        ec_xml_utils.ec_xml_processor_in_generic
                (
                i_map_id,
                i_run_id,
                i_file_path,
                i_file_name
                );
        ELSE
        ec_inbound_stage.load_data
                (
                i_transaction_type,
                i_file_name,
                i_file_path,
                i_map_id,
                i_run_id
                );
        END IF;
	ec_debug.pl(0,'EC','ECE_END_STAGING','TRANSACTION_TYPE',i_transaction_type);

	process_ASNI_docs
		(
		i_transaction_type,
		i_run_id
		);

	IF (i_Run_Import = 'Y')
	THEN
         	i_Submit_ID := fnd_request.submit_request(
            		application => 'PO',
            		program     => 'RVCTP',
            		argument1   => 'BATCH',
            		argument2   => NULL);
		ec_debug.pl(0,'EC','ECE_EXECUTE_OPEN_INTERFACE','TRANSACTION_TYPE',i_transaction_type,
				'REQUEST_ID',i_Submit_Id);
      	END IF;

commit;
retcode := ec_utils.i_ret_code;

IF ec_mapping_utils.ec_get_trans_upgrade_status(i_transaction_type, i_map_id)  = 'U' THEN
   ec_debug.pl(0,'EC','ECE_REC_TRANS_PENDING',NULL);
   retcode := 1;
END IF;

ec_debug.pl(3,'retcode',retcode);
ec_debug.pl(3,'errbuf',errbuf);
ec_debug.pl(3,'i_submit_id',i_submit_id);
ec_debug.pop('ECEASNI.PROCESS_ASNI_INBOUND');
ec_debug.pl(0,'EC','ECE_END_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.disable_debug;
EXCEPTION
      WHEN ece_transaction_disabled THEN
         ec_debug.pl(0,'EC','ECE_TRANSACTION_DISABLED','TRANSACTION',i_transaction_type);
         retcode := 1;
         ec_debug.disable_debug;
         ROLLBACK WORK;

WHEN EC_UTILS.PROGRAM_EXIT then
	rollback work;
	retcode := ec_utils.i_ret_code;
	ece_flatfile_pvt.print_attributes;
        ec_debug.disable_debug;
WHEN OTHERS THEN
	retcode := 2;
	rollback work;
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECEASNI.PROCESS_ASNI_INBOUND');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ece_flatfile_pvt.print_attributes;
        ec_debug.disable_debug;
end process_ASNI_inbound;

procedure process_sbni_inbound
	(
	errbuf			OUT NOCOPY	varchar2,
	retcode			OUT NOCOPY	varchar2,
	i_file_path             IN      varchar2,
        i_file_name             IN      varchar2,
        i_run_import            IN      varchar2,
	i_transaction_type	In	varchar2,
	i_map_id		IN	number,
	i_debug_mode		IN	number,
	i_source_charset	IN	varchar2
        )
is
i_submit_id		number;
i_run_id		number;
i_map_type		varchar2(40);
      cEnabled                   VARCHAR2(1)          := 'Y';
      ece_transaction_disabled   EXCEPTION;

begin
ec_debug.enable_debug(i_debug_mode);
ec_debug.pl(0,'EC','ECE_START_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.push('ECEASNI.PROCESS_SBNI_INBOUND');
ec_debug.pl(3,'i_file_path',i_file_path);
ec_debug.pl(3,'i_file_name',i_file_name);
ec_debug.pl(3,'i_run_import',i_run_import);
ec_debug.pl(3,'i_map_id',i_map_id);
ec_debug.pl(3,'i_debug_mode',i_debug_mode);
ec_debug.pl(3,'i_source_charset',i_source_charset);

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

	/* bug 2162062 : Set the global variable for the characterset based on the input characterset */

        ec_inbound_stage.g_source_charset:= i_source_charset;

        IF i_map_type = 'XML' THEN
        ec_xml_utils.ec_xml_processor_in_generic
                (
                i_map_id,
                i_run_id,
                i_file_path,
                i_file_name
                );
        ELSE
        ec_inbound_stage.load_data
                (
                i_transaction_type,
                i_file_name,
                i_file_path,
                i_map_id,
                i_run_id
                );
        END IF;
	ec_debug.pl(0,'EC','ECE_END_STAGING','TRANSACTION_TYPE',i_transaction_type);

	process_ASNI_docs
		(
		i_transaction_type,
		i_run_id
		);

	IF (i_Run_Import = 'Y')
	THEN
         	i_Submit_ID := fnd_request.submit_request(
            		application => 'PO',
            		program     => 'RVCTP',
            		argument1   => 'BATCH',
            		argument2   => NULL);
		ec_debug.pl(0,'EC','ECE_EXECUTE_OPEN_INTERFACE','TRANSACTION_TYPE',i_transaction_type,
				'REQUEST_ID',i_Submit_Id);
      	END IF;
commit;
retcode := ec_utils.i_ret_code;

IF ec_mapping_utils.ec_get_trans_upgrade_status(i_transaction_type,i_map_id)  = 'U' THEN
   ec_debug.pl(0,'EC','ECE_REC_TRANS_PENDING',NULL);
   retcode := 1;
END IF;

ec_debug.pl(3,'retcode',retcode);
ec_debug.pl(3,'errbuf',errbuf);
ec_debug.pl(3,'i_submit_id',i_submit_id);
ec_debug.pop('ECEASNI.PROCESS_SBNI_INBOUND');
ec_debug.pl(0,'EC','ECE_END_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.disable_debug;
EXCEPTION
      WHEN ece_transaction_disabled THEN
         ec_debug.pl(0,'EC','ECE_TRANSACTION_DISABLED','TRANSACTION',i_transaction_type);
         retcode := 1;
         ec_debug.disable_debug;
         ROLLBACK WORK;

WHEN EC_UTILS.PROGRAM_EXIT then
	rollback work;
	retcode := ec_utils.i_ret_code;
	ece_flatfile_pvt.print_attributes;
        ec_debug.disable_debug;
WHEN OTHERS THEN
	retcode := 2;
	rollback work;
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECEASNI.PROCESS_SBNI_INBOUND');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ece_flatfile_pvt.print_attributes;
        ec_debug.disable_debug;
end process_SBNI_inbound;

end eceasni;

/
