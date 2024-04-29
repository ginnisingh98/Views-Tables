--------------------------------------------------------
--  DDL for Package Body ECEINI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECEINI" AS
-- $Header: ECWINIB.pls 120.2 2005/09/30 07:34:31 arsriniv ship $

l_group_id  	number;     --Bug 2598743

   PROCEDURE process_invoice_inbound(
   	errbuf        		OUT NOCOPY VARCHAR2,
   	retcode       		OUT NOCOPY VARCHAR2,
   	i_file_path   		IN  VARCHAR2,
   	i_file_name   		IN  VARCHAR2,
   	i_run_import  		IN  VARCHAR2,
   	i_batch_name  		IN  VARCHAR2,
   	i_hold_name   		IN  VARCHAR2,
   	i_hold_reason 		IN  VARCHAR2,
   	i_gl_date     		IN  varchar2,
   	i_purge       		IN  VARCHAR2,
	i_summarize_flag	IN  VARCHAR2,
	i_transaction_type	IN  VARCHAR2,
	i_map_id		IN  NUMBER,
   	i_debug_mode  		IN  NUMBER,
	i_source_charset	IN  VARCHAR2
				) IS

     o_group_id               VARCHAR2(240):= NULL;     --Bug 2101935
     o_invoice_id             NUMBER(15);               --Bug 2204431
     i_submit_id              NUMBER;
      i_run_id                 NUMBER;
      i_map_type               VARCHAR2(40);
      m_stack_pos              NUMBER;
      m_plsql_pos              NUMBER;
      m_var_found              BOOLEAN      := FALSE;
      cEnabled                 VARCHAR2(1)  := 'Y';
      ece_transaction_disabled EXCEPTION;

      BEGIN
         ec_debug.enable_debug(i_debug_mode);
         ec_debug.push('ECEINI.PROCESS_INVOICE_INBOUND');
         ec_debug.pl(3,'i_file_path',i_file_path);
         ec_debug.pl(3,'i_file_name',i_file_name);
         ec_debug.pl(3,'i_run_import',i_run_import);
         ec_debug.pl(3,'i_debug_mode',i_debug_mode);
         ec_debug.pl(3,'i_batch_name',i_batch_name);
         ec_debug.pl(3,'i_hold_name',i_hold_name);
         ec_debug.pl(3,'i_hold_reason',i_hold_reason);
         ec_debug.pl(3,'i_gl_date',i_gl_date);
         ec_debug.pl(3,'i_purge',i_purge);
         ec_debug.pl(3,'i_summarize_flag',i_summarize_flag);
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

	      -- Initialize the Stack Table
         ec_utils.g_stack.DELETE;

      	--- Put the IN Variables on the Stack.
      	--- None for INI

	      ec_debug.pl(0,'EC','ECE_START_GENERIC_INBOUND','TRANSACTION_TYPE',i_transaction_type);
         ece_inbound.process_run_inbound
		(i_transaction_type => i_transaction_type,
		 i_run_id => i_run_id);

	      ec_debug.pl(0,'EC','ECE_FINISH_GENERIC_INBOUND','TRANSACTION_TYPE',i_transaction_type);

         --- Get out variables from the Stack .
/* Bug 2204431    start.
   Get the Invoice Id and derive Group Id,
   since Group id at Variable level 1 will be overwritten
   in g_file_tbl
   Do this only if i_run_import = 'Y'
   or else no need to derive.
 */

 IF i_run_import = 'Y' THEN
   m_var_found := ec_utils.find_variable(0,'L_HEADER_ID',m_stack_pos,m_plsql_pos);

         IF m_var_found THEN
            o_invoice_id := ec_utils.g_stack(m_stack_pos).variable_value;
            ec_debug.pl(0,'o_invoice_id ',o_invoice_id);
         ELSE
            ec_debug.pl(3,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME','L_HEADER_ID');
            ec_utils.i_ret_code :=2;
            raise EC_UTILS.PROGRAM_EXIT;
         END IF;

        begin
        select group_id
        into o_group_id
        from ap_invoices_interface
        where  invoice_id = o_invoice_id;
        ec_debug.pl(0,'o_group_id ',o_group_id);
        exception
        when no_data_found then
        ec_debug.pl(3,'o_group_id ',o_group_id);
        ec_debug.pl(3,'Group id not found for invoice id');
        raise EC_UTILS.PROGRAM_EXIT;
        when others then
        ec_debug.pl(3,'Unable to derive Group id from invoice id');
        ec_debug.pl(3,'o_group_id ',o_group_id);
        end;


/*   	   --- Get the GROUP_ID

	      m_var_found := ec_utils.find_variable(0,'L_GROUP_ID',m_stack_pos,m_plsql_pos);
  	      Bug No: 2101935 Commented the If condition and modified the search for group_id.

             ec_utils.find_pos(1,'GROUP_ID',m_plsql_pos);
             o_group_id := ec_utils.g_file_tbl(m_plsql_pos).value;

         IF m_var_found THEN
            o_group_id := ec_utils.g_stack(m_stack_pos).variable_value;
         ELSE
            ec_debug.pl(3,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME','L_GROUP_ID');
            ec_utils.i_ret_code :=2;
            raise EC_UTILS.PROGRAM_EXIT;
         END IF;

	      IF i_run_import = 'Y' THEN
Bug 2204431 end
 */
		      i_submit_id := fnd_request.submit_request(
				                  application => 'SQLAP',
                           	program     => 'APXIIMPT',
                           	argument1   => 'EDI GATEWAY',  -- Source Name
                           	argument2   =>  o_Group_id,
                           	argument3   =>  i_Batch_name,
                           	argument4   =>  i_Hold_Name,
                           	argument5   =>  i_Hold_Reason,
                           	argument6   =>  i_gl_date,
                           	argument7   =>  i_Purge,
                           	argument8   =>  null,
                           	argument9   =>  null,
                           	argument10   =>  i_summarize_flag
				);
                           	----argument6   =>  i_gl_date,to_char(i_Date,'YYYY/MM/DD HH24:MI:SS'),

		      ec_debug.pl(0,'EC','ECE_EXECUTE_OPEN_INTERFACE','TRANSACTION_TYPE',i_transaction_type,'REQUEST_ID',i_Submit_Id);
	      END IF;

         COMMIT;

         retcode := ec_utils.i_ret_code;

         IF ec_mapping_utils.ec_get_trans_upgrade_status(i_transaction_type, i_map_id)  = 'U' THEN
            ec_debug.pl(0,'EC','ECE_REC_TRANS_PENDING',NULL);
            retcode := 1;
         END IF;

         ec_debug.pl(3,'retcode',retcode);
         ec_debug.pl(3,'errbuf',errbuf);
         ec_debug.pl(3,'i_submit_id',i_submit_id);
         ec_debug.pop('ECEINI.PROCESS_INVOICE_INBOUND');
         ec_debug.pl(0,'EC','ECE_END_INBOUND','TRANSACTION_TYPE',i_transaction_type);
         ec_debug.disable_debug;

      EXCEPTION
         WHEN ece_transaction_disabled THEN
            ec_debug.pl(0,'EC','ECE_TRANSACTION_DISABLED','TRANSACTION',i_transaction_type);
            retcode := 1;
            ec_debug.disable_debug;
            ROLLBACK WORK;

         WHEN ec_utils.program_exit then
         	retcode := ec_utils.i_ret_code;
         	ece_flatfile_pvt.print_attributes;
         	ROLLBACK WORK;
         	ec_debug.disable_debug;

         WHEN OTHERS THEN
	         ROLLBACK WORK;
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECEINI.PROCESS_INVOICE_INBOUND');
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
         	ece_flatfile_pvt.print_attributes;
         	retcode := 2;
         	ec_debug.disable_debug;

      END process_invoice_inbound;

/* Bug 2598743 */

      PROCEDURE get_group_id
      IS
        plsql_pos               pls_integer;
      BEGIN
        ec_debug.push('ECEINI.GET_GROUP_ID');

        if l_group_id IS NULL then
            select AP_INTERFACE_GROUPS_S.NEXTVAL
            into   l_group_id
            from dual;
        end if;
        ec_debug.pl(3,'l_group_id',l_group_id);

        ec_utils.find_pos(1,'GROUP_ID',plsql_pos);
        ec_utils.g_file_tbl(plsql_pos).value:=to_char(l_group_id);

        ec_debug.pop('ECEINI.GET_GROUP_ID');

      EXCEPTION
      WHEN OTHERS then
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.GET_NEXTVAL_SEQ');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code := 2;
        raise EC_UTILS.PROGRAM_EXIT;
      END get_group_id;

END eceini;


/
