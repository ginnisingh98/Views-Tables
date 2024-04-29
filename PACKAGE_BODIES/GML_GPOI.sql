--------------------------------------------------------
--  DDL for Package Body GML_GPOI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_GPOI" as
-- $Header: GMLWPOIB.pls 115.5 2002/11/08 07:09:21 gmangari ship $

procedure process_gpoi_inbound
	(
	errbuf			OUT	NOCOPY varchar2,
	retcode			OUT	NOCOPY varchar2,
	i_file_path             IN      varchar2,
        i_file_name             IN      varchar2,
        i_run_import            IN      varchar2,
	i_transaction_type	IN	varchar2,
	i_map_id		IN	number,
	i_debug_mode		IN	number
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
ec_debug.push('GML_GPOI.PROCESS_GPOI_INBOUND');
ec_debug.pl(3,'i_file_path',i_file_path);
ec_debug.pl(3,'i_file_name',i_file_name);
ec_debug.pl(3,'i_run_import',i_run_import);
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_map_id',i_transaction_type);
ec_debug.pl(3,'i_debug_mode',i_debug_mode);

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

	IF (i_Run_Import = 'Y' OR i_Run_Import = 'Yes')
	THEN
         	i_Submit_ID := fnd_request.submit_request
			(
            		application => 'GML',
            		program     => 'GMLOEOI'
			);
		ec_debug.pl(0,'EC','ECE_EXECUTE_OPEN_INTERFACE','TRANSACTION_TYPE',i_transaction_type,
				'REQUEST_ID',i_Submit_Id);
      	END IF;

commit;
retcode := ec_utils.i_ret_code;
ec_debug.pl(3,'i_submit_id',i_submit_id);
ec_debug.pl(3,'retcode',retcode);
ec_debug.pl(3,'errbuf',errbuf);
ec_debug.pop('GML_GPOI.PROCESS_GPOI_INBOUND');
ec_debug.pl(0,'EC','ECE_END_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.disable_debug;
EXCEPTION
      WHEN ece_transaction_disabled THEN
         ec_debug.pl(0,'EC','ECE_TRANSACTION_DISABLED','TRANSACTION',i_transaction_type);
         retcode := 2;
         ec_debug.disable_debug;
         ROLLBACK WORK;
         RAISE;

WHEN EC_UTILS.PROGRAM_EXIT then
	errbuf := ec_utils.i_errbuf;
	retcode := ec_utils.i_ret_code;
	ece_flatfile_pvt.print_attributes;
	rollback work;
	ec_debug.disable_debug;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','GML_GPOI.PROCESS_GPOI_INBOUND');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	retcode := 2;
	rollback work;
	ece_flatfile_pvt.print_attributes;
	ec_debug.disable_debug;
end process_gpoi_inbound;

end GML_GPOI;

/
