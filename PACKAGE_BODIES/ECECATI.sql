--------------------------------------------------------
--  DDL for Package Body ECECATI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECECATI" as
-- $Header: ECWCATIB.pls 120.4 2006/03/06 00:23:35 arsriniv ship $
procedure process_cati_docs
	(
	i_transaction_type	IN	varchar2,
	i_run_id		IN	number,
	o_po_batch_id		OUT NOCOPY	number
	)
is
m_stack_pos	number;
m_plsql_pos	number;
m_var_found	BOOLEAN := FALSE;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('ECECATI.PROCESS_CATI_DOCS');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_run_id',i_run_id);
END IF;
	/**
        Initialize the Stack Table
        **/
        ec_utils.g_stack.DELETE;
        if EC_DEBUG.G_debug_level >= 1 then
	ec_debug.pl(1,'EC','ECE_START_GENERIC_INBOUND','TRANSACTION_TYPE',i_transaction_type);
        END IF;
        ece_inbound.process_run_inbound
                (
                i_transaction_type => i_transaction_type,
                i_run_id => i_run_id
                );
       if EC_DEBUG.G_debug_level >= 1 then
	ec_debug.pl(1,'EC','ECE_FINISH_GENERIC_INBOUND','TRANSACTION_TYPE',i_transaction_type);
       END IF;
        ---Get out variables from the Stack .
	m_var_found := ec_utils.find_variable
			(
			0,
			'P_PO_BATCH_ID',
			m_stack_pos,
			m_plsql_pos
			);
	if ( m_var_found )
	then
		o_po_batch_id := ec_utils.g_stack(m_stack_pos).variable_value;
	else
            if EC_DEBUG.G_debug_level >= 3 then
		ec_debug.pl(3,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME','P_PO_BATCH_ID');
            end if;
		ec_utils.i_ret_code :=2;
		raise ec_utils.program_exit;
	end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pl(3,'o_po_batch_id',o_po_batch_id);
ec_debug.pop('ECECATI.PROCESS_CATI_DOCS');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECECATI.PROCESS_CATI_DOCS');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code :=2;
	raise ec_utils.program_exit;
end process_cati_docs;

procedure process_cati_inbound
	(
	errbuf			OUT NOCOPY	varchar2,
	retcode			OUT NOCOPY	varchar2,
	i_file_path             IN      varchar2,
        i_file_name             IN      varchar2,
        i_run_import            IN      varchar2,
	i_default_buyer		IN	varchar2,
	i_po_document_type	IN	varchar2,
	i_po_document_sub_type	IN	varchar2,
	i_po_create_item_flag	IN	varchar2,
	i_po_sourcing_rules	IN	varchar2,
	i_po_approval_status	IN	varchar2,
	i_po_release_method	In	varchar2,
	i_transaction_type      IN	varchar2,
	i_map_id		IN	number,
	i_debug_mode		IN	number,
        i_source_charset        IN      varchar2
        )
is
i_submit_id		number;
i_run_id		number;
o_po_batch_id		number;
i_map_type		varchar2(40);
      cEnabled                   VARCHAR2(1)          := 'Y';
      ece_transaction_disabled   EXCEPTION;
begin
ec_debug.enable_debug(i_debug_mode);
if EC_DEBUG.G_debug_level >= 1 then
ec_debug.pl(1,'EC','ECE_START_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.push('ECECATI.PROCESS_CATI_INBOUND');
ec_debug.pl(3,'i_file_path',i_file_path);
ec_debug.pl(3,'i_file_name',i_file_name);
ec_debug.pl(3,'i_run_import',i_run_import);
ec_debug.pl(3,'i_default_buyer',i_default_buyer);
ec_debug.pl(3,'i_po_document_type',i_po_document_type);
ec_debug.pl(3,'i_po_document_sub_type',i_po_document_sub_type);
ec_debug.pl(3,'i_po_create_item_flag',i_po_create_item_flag);
ec_debug.pl(3,'i_po_sourcing_rules',i_po_sourcing_rules);
ec_debug.pl(3,'i_po_approval_status',i_po_approval_status);
ec_debug.pl(3,'i_po_release_method',i_po_release_method);
ec_debug.pl(3,'i_map_id',i_map_id);
ec_debug.pl(3,'i_debug_mode',i_debug_mode);
ec_debug.pl(3,'i_source_charset',i_source_charset);
end if;
         /* Check to see if the transaction is enabled. If not, abort */
         fnd_profile.get('ECE_' || i_transaction_type || '_ENABLED',cEnabled);
         IF cEnabled = 'N' THEN
            RAISE ece_transaction_disabled;
         END IF;
        if EC_DEBUG.G_debug_level >= 1 then
	ec_debug.pl(1,'EC','ECE_BEGIN_STAGING','TRANSACTION_TYPE',i_transaction_type);
        end if;
	select map_type into i_map_type
        from ece_mappings
        where map_id = i_map_id
          and enabled ='Y';

        /* bug 2110652 : Set the global variable for the characterset based on the input characterset */

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
        if EC_DEBUG.G_debug_level >= 1 then
	ec_debug.pl(1,'EC','ECE_END_STAGING','TRANSACTION_TYPE',i_transaction_type);
        end if;

	process_cati_docs
		(
		i_transaction_type,
		i_run_id,
		o_po_batch_id
		);

	if i_run_import = 'Y'
	then

        /* bug2321102: Modified the Argument for batch_id from Argument8 to Argument9 */
	/* Bug 2513695: Added the argument9(Org_id) to the following submit request */

	        ec_debug.pl(3,'o_PO_batch_id',o_PO_batch_id);

		i_submit_id := fnd_request.submit_request
				(
                           	application => 'PO',
                           	program     => 'POXPDOI',
                           	Start_Time  =>  NULL,
                           	Sub_Request =>  FALSE,
                           	Argument1   =>  i_default_buyer,
                           	Argument2   =>  i_PO_document_type,
                           	Argument3   =>  i_PO_document_sub_type,
                           	Argument4   =>  i_PO_create_item_flag,
                           	Argument5   =>  i_PO_sourcing_rules,
                           	Argument6   =>  i_PO_approval_status,
                           	Argument7   =>  i_PO_release_method,
                           	Argument8   =>  o_PO_batch_id,
                           	Argument9   =>  NULL,
                                Argument10  =>  NULL,
				Argument11  =>  NULL,
				Argument12  =>  NULL,
				Argument13  =>  NULL,
				Argument14  =>  NULL,
				Argument15  =>  NULL,
                                Argument16   => NULL,
                                Argument17  =>  NULL,
                                Argument18  =>  NULL,
                                Argument19  =>  NULL,
                                Argument20  =>  NULL,
                                Argument21  =>  NULL,
                                Argument22  =>  NULL,
				Argument23   => NULL,
                                Argument24  =>  NULL,
                                Argument25  =>  NULL,
                                Argument26  =>  NULL,
                                Argument27  =>  NULL,
                                Argument28  =>  NULL,
                                Argument29  =>  NULL,
                                Argument30   => NULL,
                                Argument31  =>  NULL,
                                Argument32  =>  NULL,
                                Argument33  =>  NULL,
                                Argument34  =>  NULL,
                                Argument35  =>  NULL,
                                Argument36  =>  NULL,
				Argument37   => NULL,
                                Argument38  =>  NULL,
                                Argument39  =>  NULL,
                                Argument40  =>  NULL,
                                Argument41  =>  NULL,
                                Argument42  =>  NULL,
                                Argument43  =>  NULL,
				Argument44   => NULL,
                                Argument45  =>  NULL,
                                Argument46  =>  NULL,
                                Argument47  =>  NULL,
                                Argument48  =>  NULL,
                                Argument49  =>  NULL,
                                Argument50  =>  NULL,
				Argument51   => NULL,
                                Argument52  =>  NULL,
                                Argument53  =>  NULL,
                                Argument54  =>  NULL,
                                Argument55  =>  NULL,
                                Argument56  =>  NULL,
                                Argument57  =>  NULL,
                                Argument58  =>  NULL,
                                Argument59  =>  NULL,
                                Argument60  =>  NULL,
                                Argument61  =>  NULL,
                                Argument62  =>  NULL,
                                Argument63  =>  NULL,
				Argument64   => NULL,
                                Argument65  =>  NULL,
                                Argument66  =>  NULL,
                                Argument67  =>  NULL,
                                Argument68  =>  NULL,
                                Argument69  =>  NULL,
                                Argument70  =>  NULL,
				Argument71  =>  NULL,
                                Argument72  =>  NULL,
                                Argument73  =>  NULL,
				Argument74   => NULL,
                                Argument75  =>  NULL,
                                Argument76  =>  NULL,
                                Argument77  =>  NULL,
                                Argument78  =>  NULL,
                                Argument79  =>  NULL,
                                Argument80  =>  NULL,
				Argument81   => NULL,
                                Argument82  =>  NULL,
                                Argument83  =>  NULL,
                                Argument84  =>  NULL,
                                Argument85  =>  NULL,
                                Argument86  =>  NULL,
                                Argument87  =>  NULL,
                                Argument88  =>  NULL,
                                Argument89  =>  NULL,
                                Argument90  =>  NULL,
                                Argument91  =>  NULL,
                                Argument92  =>  NULL,
                                Argument93  =>  NULL,
				Argument94   => NULL,
                                Argument95  =>  NULL,
                                Argument96  =>  NULL,
                                Argument97  =>  NULL,
                                Argument98  =>  NULL,
                                Argument99  =>  NULL,
                                Argument100 =>  NULL
				);

                if EC_DEBUG.G_debug_level >= 1 then
		ec_debug.pl(1,'EC','ECE_EXECUTE_OPEN_INTERFACE','TRANSACTION_TYPE',i_transaction_type,
                                'REQUEST_ID',i_Submit_Id);
                end if;

	end if;
commit;

retcode := ec_utils.i_ret_code;

IF ec_mapping_utils.ec_get_trans_upgrade_status(i_transaction_type, i_map_id)  = 'U' THEN
   ec_debug.pl(0,'EC','ECE_REC_TRANS_PENDING',NULL);
   retcode := 1;
END IF;
if EC_DEBUG.G_debug_level >= 1 then
ec_debug.pl(3,'i_submit_id',i_submit_id);
ec_debug.pl(3,'retcode',retcode);
ec_debug.pl(3,'errbuf',errbuf);
ec_debug.pop('ECECATI.PROCESS_CATI_INBOUND');
ec_debug.pl(1,'EC','ECE_END_INBOUND','TRANSACTION_TYPE',i_transaction_type);
end if;
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
	rollback work;
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECECATI.PROCESS_CATI_INBOUND');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ece_flatfile_pvt.print_attributes;
	retcode :=2;
	ec_debug.disable_debug;
end process_cati_inbound;

procedure process_rrqi_inbound
	(
	errbuf			OUT NOCOPY	varchar2,
	retcode			OUT NOCOPY	varchar2,
	i_file_path             IN      varchar2,
        i_file_name             IN      varchar2,
        i_run_import            IN      varchar2,
	i_default_buyer		IN	varchar2,
	i_po_document_type	IN	varchar2,
	i_po_document_sub_type	IN	varchar2,
	i_po_create_item_flag	IN	varchar2,
	i_po_sourcing_rules	IN	varchar2,
	i_po_approval_status	IN	varchar2,
	i_po_release_method	In	varchar2,
	i_transaction_type	IN	varchar2,
	i_map_id		IN	number,
	i_debug_mode		IN	number,
	i_source_charset        IN      varchar2
        )
is
i_submit_id		number;
i_run_id		number;
o_po_batch_id		number;
i_map_type		varchar2(40);
      cEnabled                   VARCHAR2(1)          := 'Y';
      ece_transaction_disabled   EXCEPTION;

begin
ec_debug.enable_debug(i_debug_mode);
ec_debug.pl(0,'EC','ECE_START_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.push('ECECATI.PROCESS_RRQI_INBOUND');
if EC_DEBUG.G_debug_level >= 3 then
ec_debug.pl(3,'i_file_path',i_file_path);
ec_debug.pl(3,'i_file_name',i_file_name);
ec_debug.pl(3,'i_run_import',i_run_import);
ec_debug.pl(3,'i_default_buyer',i_default_buyer);
ec_debug.pl(3,'i_po_document_type',i_po_document_type);
ec_debug.pl(3,'i_po_document_sub_type',i_po_document_sub_type);
ec_debug.pl(3,'i_po_create_item_flag',i_po_create_item_flag);
ec_debug.pl(3,'i_po_sourcing_rules',i_po_sourcing_rules);
ec_debug.pl(3,'i_po_approval_status',i_po_approval_status);
ec_debug.pl(3,'i_po_release_method',i_po_release_method);
ec_debug.pl(3,'i_map_id',i_map_id);
ec_debug.pl(3,'i_debug_mode',i_debug_mode);
end if;
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

	process_cati_docs
		(
		i_transaction_type,
		i_run_id,
		o_po_batch_id
		);

	if i_run_import = 'Y'
	then

	/* bug2321102: Modified the Argument for batch_id from Argument8 to Argument9 */
	/* Bug 2513695: Added the argument8(Org_id) to the following submit request */

	        ec_debug.pl(3,'o_PO_batch_id',o_PO_batch_id);

		i_submit_id := fnd_request.submit_request
				(
                           	application => 'PO',
                           	program     => 'POXPDOI',
                           	Start_Time  =>  NULL,
                           	Sub_Request =>  FALSE,
                           	Argument1   =>  i_default_buyer,
                           	Argument2   =>  i_PO_document_type,
                           	Argument3   =>  i_PO_document_sub_type,
                           	Argument4   =>  i_PO_create_item_flag,
                           	Argument5   =>  i_PO_sourcing_rules,
                           	Argument6   =>  i_PO_approval_status,
                           	Argument7   =>  i_PO_release_method,
                           	Argument8   =>  o_PO_batch_id,
                                Argument9   =>  NULL,
                                Argument10  =>  NULL,
                                Argument11  =>  NULL,
                                Argument12  =>  NULL,
                                Argument13  =>  NULL,
                                Argument14  =>  NULL,
                                Argument15  =>  NULL,
                                Argument16   => NULL,
                                Argument17  =>  NULL,
                                Argument18  =>  NULL,
                                Argument19  =>  NULL,
                                Argument20  =>  NULL,
                                Argument21  =>  NULL,
                                Argument22  =>  NULL,
				Argument23   => NULL,
                                Argument24  =>  NULL,
                                Argument25  =>  NULL,
                                Argument26  =>  NULL,
                                Argument27  =>  NULL,
                                Argument28  =>  NULL,
                                Argument29  =>  NULL,
                                Argument30   => NULL,
                                Argument31  =>  NULL,
                                Argument32  =>  NULL,
                                Argument33  =>  NULL,
                                Argument34  =>  NULL,
                                Argument35  =>  NULL,
                                Argument36  =>  NULL,
				Argument37   => NULL,
                                Argument38  =>  NULL,
                                Argument39  =>  NULL,
                                Argument40  =>  NULL,
                                Argument41  =>  NULL,
                                Argument42  =>  NULL,
                                Argument43  =>  NULL,
				Argument44   => NULL,
                                Argument45  =>  NULL,
                                Argument46  =>  NULL,
                                Argument47  =>  NULL,
                                Argument48  =>  NULL,
                                Argument49  =>  NULL,
                                Argument50  =>  NULL,
				Argument51   => NULL,
                                Argument52  =>  NULL,
                                Argument53  =>  NULL,
                                Argument54  =>  NULL,
                                Argument55  =>  NULL,
                                Argument56  =>  NULL,
                                Argument57  =>  NULL,
                                Argument58  =>  NULL,
                                Argument59  =>  NULL,
                                Argument60  =>  NULL,
                                Argument61  =>  NULL,
                                Argument62  =>  NULL,
                                Argument63  =>  NULL,
				Argument64   => NULL,
                                Argument65  =>  NULL,
                                Argument66  =>  NULL,
                                Argument67  =>  NULL,
                                Argument68  =>  NULL,
                                Argument69  =>  NULL,
                                Argument70  =>  NULL,
				Argument71  =>  NULL,
                                Argument72  =>  NULL,
                                Argument73  =>  NULL,
				Argument74   => NULL,
                                Argument75  =>  NULL,
                                Argument76  =>  NULL,
                                Argument77  =>  NULL,
                                Argument78  =>  NULL,
                                Argument79  =>  NULL,
                                Argument80  =>  NULL,
				Argument81   => NULL,
                                Argument82  =>  NULL,
                                Argument83  =>  NULL,
                                Argument84  =>  NULL,
                                Argument85  =>  NULL,
                                Argument86  =>  NULL,
                                Argument87  =>  NULL,
                                Argument88  =>  NULL,
                                Argument89  =>  NULL,
                                Argument90  =>  NULL,
                                Argument91  =>  NULL,
                                Argument92  =>  NULL,
                                Argument93  =>  NULL,
				Argument94   => NULL,
                                Argument95  =>  NULL,
                                Argument96  =>  NULL,
                                Argument97  =>  NULL,
                                Argument98  =>  NULL,
                                Argument99  =>  NULL,
                                Argument100 =>  NULL
                                );

		ec_debug.pl(0,'EC','ECE_EXECUTE_OPEN_INTERFACE','TRANSACTION_TYPE',i_transaction_type,
                                'REQUEST_ID',i_Submit_Id);

	end if;
commit;

retcode := ec_utils.i_ret_code;

IF ec_mapping_utils.ec_get_trans_upgrade_status(i_transaction_type, i_map_id)  = 'U' THEN
   ec_debug.pl(0,'EC','ECE_REC_TRANS_PENDING',NULL);
   retcode := 1;
END IF;
if EC_DEBUG.G_debug_level >= 3 then
ec_debug.pl(3,'i_submit_id',i_submit_id);
ec_debug.pl(3,'retcode',retcode);
ec_debug.pl(3,'errbuf',errbuf);
end if;
ec_debug.pop('ECECATI.PROCESS_RRQI_INBOUND');
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
	rollback work;
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECECATI.PROCESS_RRQI_INBOUND');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ece_flatfile_pvt.print_attributes;
	retcode :=2;
	ec_debug.disable_debug;
end process_rrqi_inbound;

end ececati;

/
