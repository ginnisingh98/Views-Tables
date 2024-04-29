--------------------------------------------------------
--  DDL for Package Body CN_COLLECTION_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COLLECTION_GEN" AS
-- $Header: cncogenb.pls 120.13.12010000.11 2009/08/20 04:44:52 rajukum ship $

----+
-- Private package variables
  -- a constant which has a null value for passing to the insert_row
  -- procedures of table handler APIs as the primary key value
----+


	null_id	CONSTANT	NUMBER := NULL;

	l_org_id NUMBER;


FUNCTION isParallelEnabled
return boolean IS
g_cn_db_parallel_enabled	VARCHAR2(1) := fnd_profile.value('CN_DB_PARALLEL_ENABLE');
BEGIN
    IF (g_cn_db_parallel_enabled IS NOT NULL AND g_cn_db_parallel_enabled = 'Y') THEN
        return true;
    else
        return false;
    end if;
END;

----+
-- Private package procedures
----+

-- Procedure Name
--   Install_package_Object
-- Purpose
--   Gets code for a package Spec or Body from CN_SOURCE and uses AD_DDL to create that object
--   IF p_test = 'Y' then '_T' is appended to the package name - this allows you to test
--   creating  the package without destroying the original in the database

 PROCEDURE Install_Package_Object(
                 p_object_id   IN NUMBER,
			  p_object_name IN VARCHAR2,
			  p_test        IN VARCHAR2 := 'N',
		x_comp_error  OUT NOCOPY VARCHAR2,
		x_org_id      IN NUMBER)
 IS

    -----+
    -- Removed Hardcoded 'APPS'
    -- l_applsys_schema  VARCHAR2(20) := 'APPS';
    -- Hithanki/24-Dec-2003/Bug Fix : 3322008
    -----+

    l_applsys_schema  VARCHAR2(20);
    k                 NUMBER;
    l_object_name     VARCHAR2(80) := p_object_name;
    l_line_length     NUMBER;
    l_send_position     NUMBER;

    CURSOR	pkg_start (p_object_id NUMBER)
	IS
    SELECT cs.line_no, cs.text
      FROM cn_source cs
     WHERE cs.object_id = p_object_id
       AND substr(cs.text, 1, 25) = 'CREATE OR REPLACE PACKAGE'
    AND 	org_id = x_org_id
     ORDER BY line_no;

    l_pkg_start_rec pkg_start%ROWTYPE;

    CURSOR pkg_end (p_object_id NUMBER)
	IS
    SELECT cs.line_no, cs.text
      FROM cn_source cs
     WHERE cs.object_id = p_object_id
	AND 	cs.text LIKE 'END%'
	AND 	org_id = x_org_id
     ORDER BY line_no DESC;

    l_pkg_end_rec pkg_end%ROWTYPE;

    CURSOR fetch_code (p_pks_start NUMBER,
                       p_pks_end   NUMBER,
                       p_pks_object_id NUMBER) IS
    SELECT cs.text
      FROM cn_source cs
     WHERE cs.object_id = p_pks_object_id
	AND 	cs.line_no BETWEEN p_pks_start AND (p_pks_end - 1)
	AND  	org_id = x_org_id
     ORDER BY line_no;

  BEGIN
    IF p_test = 'Y' THEN
	 l_object_name := l_object_name || '_T';
    END IF;

    --dbms_output.put_line('In install_package_object l_object_name '||l_object_name);

    -- Find the locations of the first and last
    -- lines of the package Spec or Body in the cn_source table, fetch the code
    -- between these lines and then create the spec / body

    OPEN pkg_start(p_object_id);
    FETCH pkg_start INTO l_pkg_start_rec;
    CLOSE pkg_start;

    OPEN pkg_end(p_object_id);
    FETCH pkg_end INTO l_pkg_end_rec;
    CLOSE pkg_end;

	k := 1;

    FOR j IN fetch_code(l_pkg_start_rec.line_no, l_pkg_end_rec.line_no, p_object_id)
    LOOP
	 l_line_length := LENGTHB(j.text);
	 l_send_position := 1;

      -- If it's a test, create the package with the _T name instead

      IF k = 1 AND p_test = 'Y' THEN
        j.text := REPLACE(UPPER(j.text), UPPER(p_object_name), l_object_name);
        --dbms_output.put_line(' k = 1 AND p_test = Y so j.text = '||j.text);
      END IF;


      LOOP
        --if k=1 then dbms_output.put_line('k = '||k||', Text = '||j.text); end if;
        ad_ddl.build_package(SUBSTRB(j.text,l_send_position,255), k);
        k := k + 1;
	   l_send_position := l_send_position + 255;
	   IF l_line_length - l_send_position < 0 THEN
	     EXIT;
        END IF;
      END LOOP;
    END LOOP;
    ad_ddl.build_package('END;', k);

    -----+
    -- Added Select..Into.. From. Statement
    -- Hithanki/24-Dec-2003/Bug Fix : 3322008
    -----+

	--Added to reomve hardcoded Schema
	 SELECT	user
	 INTO	l_applsys_schema
	 FROM	dual;

    ad_ddl.create_plsql_object(
		  applsys_schema         => l_applsys_schema,
		  application_short_name => 'CN',
		  object_name            => SUBSTR(l_object_name,1,30),
		  lb                     => 1,
		  ub                     => k,
		  insert_newlines        => 'FALSE',
		  comp_error             => x_comp_error);

	      --dbms_output.put_line('In install_package_object object_name '||l_object_name);
	      --dbms_output.put_line('In install_package_object comp_error '||x_comp_error);

  END Install_Package_Object;

-- Procedure Name
--   call_start_debug
-- Purpose
--   Generates code to call start debugging message procedure.
-- History
--   01-26-96	     Jin Cheng		Created

  PROCEDURE call_start_debug(
		procedure_name	IN  cn_obj_procedures_v.NAME%TYPE,
		x_event_id      IN  cn_events.event_id%TYPE,
		code    		IN OUT NOCOPY  cn_utils.code_type,
		x_org_id        IN NUMBER)
	IS

    x_event_name           cn_lookups.lookup_code%TYPE := 'CUSTOM';

  BEGIN

    cn_utils.set_org_id(x_org_id);

    cn_utils.appendcr(code);

    cn_utils.appindcr(code, 'x_proc_audit_id := NULL;   -- Will get a value in the call below FOR TESTING');

  IF (x_event_id = cn_global.inv_event_id)  THEN
      x_event_name := 'INV';

    ELSIF (x_event_id = cn_global.pmt_event_id)  THEN
      x_event_name := 'PMT/GB';

    ELSIF (x_event_id = cn_global.cbk_event_id)  THEN
      x_event_name := 'CB';

    ELSIF (x_event_id = cn_global.wo_event_id)	THEN
      x_event_name := 'WO';

    ELSIF (x_event_id = cn_global.ram_event_id)  THEN
      x_event_name := 'RAM';

    ELSIF (x_event_id = cn_global.ord_event_id)  THEN
      x_event_name := 'ORD';

  END IF;

    IF(x_event_id > 0)
    THEN
        IF CN_COLLECTION_GEN.isParallelEnabled THEN
            cn_utils.appindcr(code, 'EXECUTE IMMEDIATE ''ALTER SESSION ENABLE PARALLEL DML'';');
         END IF;
    END IF;

    cn_utils.appindcr(code, 'cn_message_pkg.begin_batch(');
    cn_utils.indent(code, 5);

    cn_utils.appindcr(code, ' x_parent_proc_audit_id  => dummy_num');
    cn_utils.appindcr(code, ',x_process_audit_id      => x_proc_audit_id');
    cn_utils.appindcr(code, ',x_request_id            => fnd_global.conc_request_id');
    cn_utils.appindcr(code, ',x_process_type          => '''|| x_event_name ||'''');
    cn_utils.appindcr(code, ',p_org_id                =>  x_org_id );');

    cn_utils.unindent(code, 5);

    cn_utils.appindcr(code, 'x_col_audit_id := x_proc_audit_id;');

    --Condition added to fix bug 6203234
    -- Fix for bug 8371984
    IF(x_event_id > 0)
    THEN
      null;
    --cn_utils.record_process_start('COL', '''Collection run for process '' || x_proc_audit_id', 'x_col_audit_id', code);
    END IF;

    cn_utils.appindcr(code, 'cn_message_pkg.debug('''|| procedure_name || '>>'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, '''|| procedure_name || '>>'');');
     cn_utils.appindcr(code, 'MO_GLOBAL.SET_POLICY_CONTEXT (''S'','||x_org_id||');');
    cn_utils.appendcr(code);

    cn_utils.unset_org_id();

  END call_start_debug;



-- Procedure Name
--   call_notify
-- Purpose
--   Generates code to call the notification procedure.
-- History

  PROCEDURE call_notify (
	x_package_id		cn_obj_packages_v.package_id%TYPE,
	procedure_name		cn_obj_procedures_v.NAME%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_repository_id 	cn_repositories.repository_id%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code				IN OUT NOCOPY 	cn_utils.code_type,
	x_org_id        	IN NUMBER) IS

    x_row_count 		NUMBER;

  BEGIN

    cn_utils.set_org_id(x_org_id);

    cn_utils.appendcr(code);
    cn_utils.appendcr(code, '--******** NOTIFY PROCESS ********-- ');
    cn_utils.appendcr(code);
    cn_utils.unset_org_id();
    cn_debug.print_msg('call_notify >>', 1);
    fnd_file.put_line(fnd_file.Log, 'call_notify >>');

    -- Translate the incoming period_names into period_ids.   AE 02-28-96
    -- We had to do this because AOL only passes VARCHAR2 input parms.

	cn_utils.set_org_id(x_org_id);
    cn_utils.appindcr(code, 'cn_message_pkg.debug('''|| procedure_name || ': Call notify process begin.'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, '''|| procedure_name || ': Call notify process begin.'');');
    cn_utils.appindcr(code, 'SELECT period_id ');
    cn_utils.appindcr(code, '  INTO x_start_period_id ');
    cn_utils.appindcr(code, '  FROM cn_periods ');
    cn_utils.appindcr(code, 'WHERE 	period_name = x_start_period_name' );
    cn_utils.appindcr(code, 'AND    org_id = '||x_org_id||' ;');

    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'SELECT period_id ');
    cn_utils.appindcr(code, '  INTO x_end_period_id ');
    cn_utils.appindcr(code, '  FROM cn_periods ');
    cn_utils.appindcr(code, 'WHERE 	period_name = x_end_period_name' );
    cn_utils.appindcr(code, 'AND    org_id = '||x_org_id||' ;');
    cn_utils.appendcr(code);
	cn_utils.unset_org_id();

    -- Generate the call statement
    cn_debug.print_msg('call_notify: Generating CALL statement.', 1);
    fnd_file.put_line(fnd_file.Log, 'call_notify: Generating CALL statement.');

	cn_utils.set_org_id(x_org_id);
    cn_utils.appindcr(code, 'cn_message_pkg.debug('''|| procedure_name || ': entering notify.'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, '''|| procedure_name || ': entering notify.'');');

    IF (x_event_id = cn_global.inv_event_id)  THEN
      cn_utils.appindcr(code, 'cn_notify_invoices.notify(x_start_period_id, x_end_period_id, debug_pipe, debug_level,x_org_id);' );

    ELSIF (x_event_id = cn_global.pmt_event_id)  THEN
      cn_utils.appindcr(code, 'cn_notify_payments.notify(x_start_period_id, x_end_period_id, debug_pipe, debug_level,x_org_id);' );

    ELSIF (x_event_id = cn_global.cbk_event_id)  THEN
      cn_utils.appindcr(code, 'cn_notify_clawbacks.notify(x_start_period_id, x_end_period_id, debug_pipe, debug_level,x_org_id);' );

    ELSIF (x_event_id = cn_global.wo_event_id)	THEN
      cn_utils.appindcr(code, 'cn_notify_writeoffs.notify(x_start_period_id, x_end_period_id, debug_pipe, debug_level,x_org_id);' );

    ELSIF (x_event_id = cn_global.ord_event_id)	THEN
      cn_utils.appindcr(code, 'cn_notify_orders.regular_col_notify(');
      cn_utils.indent(code, 8);
      cn_utils.appindcr(code, ' x_start_period 		=> x_start_period_id');
      cn_utils.appindcr(code, ',x_end_period            => x_end_period_id');
      cn_utils.appindcr(code, ',x_adj_flag            	=> ''N''');
      cn_utils.appindcr(code, ',parent_proc_audit_id    => x_proc_audit_id');
      cn_utils.appindcr(code, ',debug_pipe            	=> debug_pipe');
      cn_utils.appindcr(code, ',debug_level         	=> debug_level');
      cn_utils.appindcr(code, ',x_org_id                => '||x_org_id ||' );');
      cn_utils.unindent(code, 8);

    ELSIF (x_event_id = cn_global.aia_event_id)  THEN
      cn_utils.appindcr(code, 'cn_notify_aia.notify(x_start_period_id, x_end_period_id, debug_pipe, debug_level,x_org_id);' );
    ELSIF (x_event_id = cn_global.aia_om_event_id)  THEN
      cn_utils.appindcr(code, 'cn_notify_aia_om.notify(x_start_period_id, x_end_period_id, debug_pipe, debug_level,x_org_id);' );

    END IF;
    cn_utils.appendcr(code);
	cn_utils.unset_org_id();

    cn_debug.print_msg('call_notify <<', 1);
    fnd_file.put_line(fnd_file.Log, 'call_notify <<');

    cn_utils.set_org_id(x_org_id);
    cn_utils.appindcr(code, 'cn_message_pkg.debug('''|| procedure_name || ': exit from notify and start collection run.'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, '''|| procedure_name || ': exit from notify and start collection run.'');');

    IF (x_event_id = cn_global.ord_event_id)  THEN
      	cn_utils.appendcr(code, '--******** COLLECT AJUSTMENTS (NEGATE IN API) ********-- ');
      	cn_utils.appindcr(code, '-- This will negate those adjusted trx in the API table');
	cn_utils.appindcr(code, 'cn_not_trx_grp.col_adjustments(p_api_version => 1.0,');
	cn_utils.appindcr(code, '                               x_return_status => x_return_status,');
	cn_utils.appindcr(code, '                               x_msg_count => x_msg_count,');
	cn_utils.appindcr(code, '                               x_msg_data => x_msg_data,');
	cn_utils.appindcr(code, '                               p_org_id   => '||x_org_id ||');');
      	cn_utils.appendcr(code);

    END IF;

    cn_utils.appendcr(code);

    cn_utils.unset_org_id();

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('call_notify: in exception handler for NO_DATA_FOUND', 1);
      fnd_file.put_line(fnd_file.Log, 'call_notify: in exception handler for NO_DATA_FOUND');
      RETURN;
  END call_notify;


-- Procedure Name
--   call_identify
-- Purpose
--   Generates code to call the RAM identify procedure.
-- History
--   03-26-02		Harlen Chen		Created


  PROCEDURE call_identify (
	x_package_id		cn_obj_packages_v.package_id%TYPE,
	procedure_name		cn_obj_procedures_v.NAME%TYPE,
	x_module_id		    cn_modules.module_id%TYPE,
	x_repository_id 	cn_repositories.repository_id%TYPE,
	x_event_id		    cn_events.event_id%TYPE,
	code	IN OUT NOCOPY 	cn_utils.code_type,
	x_org_id IN NUMBER)
IS

    x_row_count 		NUMBER;

  BEGIN

  l_org_id := x_org_id;

	cn_utils.set_org_id(x_org_id);

    cn_utils.appendcr(code);
    cn_utils.appendcr(code, '--******** IDENTIFY PROCESS ********-- ');
    cn_utils.appendcr(code);
    cn_utils.unset_org_id();

    cn_debug.print_msg('call_identify >>', 1);
    fnd_file.put_line(fnd_file.Log, 'call_identify >>');

	cn_utils.set_org_id(x_org_id);
    cn_utils.appindcr(code, 'cn_message_pkg.debug('''|| procedure_name || ': start identify process.'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, '''|| procedure_name || ': start identify process.'');');
    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'SELECT period_id ');
    cn_utils.appindcr(code, '  INTO x_start_period_id ');
    cn_utils.appindcr(code, '  FROM cn_periods ');
    cn_utils.appindcr(code, 'WHERE 	period_name = x_start_period_name' );
    cn_utils.appindcr(code, 'AND    org_id = '||X_org_id||' ;');
    cn_utils.appendcr(code);

    cn_utils.appindcr(code, 'SELECT period_id ');
    cn_utils.appindcr(code, '  INTO x_end_period_id ');
    cn_utils.appindcr(code, '  FROM cn_periods ');
    cn_utils.appindcr(code, 'WHERE period_name = x_end_period_name' );
    cn_utils.appindcr(code, 'AND    org_id = '||X_org_id||' ;');
    cn_utils.appendcr(code);
	cn_utils.unset_org_id();

    -- Generate the call statement
    cn_debug.print_msg('call_identify: Generating CALL statement.', 1);
    fnd_file.put_line(fnd_file.Log, 'call_identify: Generating CALL statement.');

	cn_utils.set_org_id(x_org_id);
    cn_utils.appindcr(code, 'cn_ram_adjustments_pkg.identify(x_start_period_id, x_end_period_id, debug_pipe, debug_level,x_org_id);' );
    cn_utils.appendcr(code);
	cn_utils.unset_org_id();

    cn_debug.print_msg('call_identify <<', 1);
    fnd_file.put_line(fnd_file.Log, 'call_identify <<');

    cn_utils.set_org_id(x_org_id);
    cn_utils.appindcr(code, 'cn_message_pkg.debug('''|| procedure_name || ': end identify process.'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, '''|| procedure_name || ': end identify process.'');');
    cn_utils.appendcr(code);

	cn_utils.unset_org_id();
  EXCEPTION

    WHEN NO_DATA_FOUND
	THEN
      cn_debug.print_msg('call_identify: in exception handler for NO_DATA_FOUND', 1);
    	fnd_file.put_line(fnd_file.Log, 'call_identify: in exception handler for NO_DATA_FOUND');
      RETURN;

  END call_identify;


-- Procedure Name
--   call_negate
-- Purpose
--   Generates code to call the RAM identify procedure.
-- History
--   03-26-02		Harlen Chen		Created

  PROCEDURE call_negate (
	x_package_id		cn_obj_packages_v.package_id%TYPE,
	procedure_name		cn_obj_procedures_v.NAME%TYPE,
	x_module_id		    cn_modules.module_id%TYPE,
	x_repository_id 	cn_repositories.repository_id%TYPE,
	x_event_id		    cn_events.event_id%TYPE,
	code	IN OUT NOCOPY 	cn_utils.code_type,
	x_org_id IN NUMBER)
IS

    x_row_count 		NUMBER;

  BEGIN

    cn_utils.set_org_id(x_org_id);

    cn_utils.appendcr(code);
    cn_utils.appendcr(code, '--******** NEGATE PROCESS ********-- ');
    cn_utils.appendcr(code);
    cn_utils.unset_org_id();

    cn_debug.print_msg('call_negate >>', 1);
    fnd_file.put_line(fnd_file.Log, 'call_negate >>');

    cn_utils.set_org_id(x_org_id);
    cn_utils.appindcr(code, 'x_ram_negate_profile := CN_SYSTEM_PARAMETERS.value(''CN_RAM_NEGATE'','|| x_org_id ||');');
    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'cn_message_pkg.debug('''|| procedure_name ||
    ': Profile OSC: Negate during Revenue Adjustments Collection = '' || x_ram_negate_profile);');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, '''|| procedure_name ||
    ': Profile OSC: Negate during Revenue Adjustments Collection = '' || x_ram_negate_profile);');
    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'IF x_ram_negate_profile = ''Y'' THEN  ');
    cn_utils.appindcr(code, '   cn_message_pkg.debug('''|| procedure_name || ': start negate process.'');');
    cn_utils.appindcr(code, '   fnd_file.put_line(fnd_file.Log, '''|| procedure_name || ': start negate process.'');');
    cn_utils.appindcr(code, '   cn_ram_adjustments_pkg.negate(debug_pipe, debug_level,'||x_org_id||');' );
    cn_utils.appindcr(code, '   cn_message_pkg.debug('''|| procedure_name || ': end negate process.'');');
    cn_utils.appindcr(code, '   fnd_file.put_line(fnd_file.Log, '''|| procedure_name || ': end negate process.'');');
    cn_utils.appindcr(code, 'ELSE');
    cn_utils.appindcr(code, '   cn_message_pkg.debug('''|| procedure_name || ': skip negate process.'');');
    cn_utils.appindcr(code, '   fnd_file.put_line(fnd_file.Log, '''|| procedure_name || ': skip negate process.'');');
    cn_utils.appendcr(code);
    cn_utils.appindcr(code, '   UPDATE cn_trx_lines ctl');
    cn_utils.appindcr(code, '      SET negated_flag = ''Y''');
    cn_utils.appindcr(code, '    WHERE ctl.adjusted_flag  = ''Y'' and');
    cn_utils.appindcr(code, '          ctl.negated_flag   = ''N'' and');
    cn_utils.appindcr(code, '          ctl.collected_flag = ''N'' and');
    cn_utils.appindcr(code, '          ctl.event_id = cn_global.inv_event_id');
    cn_utils.appindcr(code, '		   AND  ctl.org_id = '||x_org_id||' ;');
    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'END IF;');
    cn_utils.appendcr(code);
    cn_utils.unset_org_id();

    cn_debug.print_msg('call_negate <<', 1);
    fnd_file.put_line(fnd_file.Log, 'call_negate <<');

  cn_message_pkg.DEBUG('collect: Profile OSC: Negate during Revenue Adjustments Collection = ' ||
  		        CN_SYSTEM_PARAMETERS.value('CN_RAM_NEGATE',x_org_id));
  fnd_file.put_line(fnd_file.Log,'collect: Profile OSC: Negate during Revenue Adjustments Collection = ' ||
  		        CN_SYSTEM_PARAMETERS.value('CN_RAM_NEGATE',x_org_id));

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('call_negate: in exception handler for NO_DATA_FOUND', 1);
      fnd_file.put_line(fnd_file.Log, 'call_negate: in exception handler for NO_DATA_FOUND');
      RETURN;
  END call_negate;



-- Procedure Name
--   local_variables
-- Purpose
--   Generates some boilerplate text to declare local variables
-- History
--   17-NOV-93		Devesh Khatu		Created

  PROCEDURE local_variables (
	procedure_name	VARCHAR2,
	x_event_id	cn_events.event_id%TYPE,
	code	IN OUT NOCOPY cn_utils.code_type,
    x_org_id IN NUMBER) IS
  BEGIN



    IF (x_event_id = cn_global.ram_event_id) THEN

    cn_debug.print_msg('local_variables>>', 1);
    fnd_file.put_line(fnd_file.Log, 'local_variables>>');

    cn_utils.set_org_id(x_org_id);
    cn_utils.indent(code, 1);
    cn_utils.appindcr(code, 'trx_sales_line_count    NUMBER := 0;');
    cn_utils.appindcr(code, 'trx_update_count        NUMBER := 0;');
    cn_utils.appindcr(code, 'trx_line_update_count   NUMBER := 0;');
    cn_utils.appindcr(code, 'trx_sales_line_update_count  NUMBER := 0;');
    cn_utils.appindcr(code, 'comm_lines_api_count         NUMBER := 0;');
    cn_utils.appindcr(code, 'comm_lines_api_update_count  NUMBER := 0;');
    cn_utils.appindcr(code, 'x_start_period_id       NUMBER(15);');
    cn_utils.appindcr(code, 'x_end_period_id         NUMBER(15);');
    cn_utils.appindcr(code, 'x_col_audit_id          NUMBER;');
    cn_utils.appindcr(code, 'x_proc_audit_id         NUMBER;');
    cn_utils.appindcr(code, 'x_conc_program_id       NUMBER;');
    cn_utils.appindcr(code, 'x_adj_batch_id          NUMBER;');
    cn_utils.appindcr(code, 'x_rowid                 ROWID;');
    cn_utils.appindcr(code, 'debug_pipe              VARCHAR2(30);');
    cn_utils.appindcr(code, 'debug_level             NUMBER := 1 ;');
    cn_utils.appindcr(code, 'dummy_num               NUMBER ;');
    cn_utils.appindcr(code, 'x_return_status         VARCHAR2(1);');
    cn_utils.appindcr(code, 'x_msg_count             NUMBER;');
    cn_utils.appindcr(code, 'x_msg_data              VARCHAR(2000);');
    cn_utils.appindcr(code, 'x_created_by            NUMBER  := to_number(fnd_global.user_id);');
    cn_utils.appindcr(code, 'x_creation_date         DATE    := sysdate;');
    cn_utils.appindcr(code, 'x_last_updated_by       NUMBER  := to_number(fnd_global.user_id);');
    cn_utils.appindcr(code, 'x_last_update_date      DATE    := sysdate;');
    cn_utils.appindcr(code, 'x_last_update_login     NUMBER  := to_number(fnd_global.login_id);');
    cn_utils.appindcr(code, 'x_ram_negate_profile    VARCHAR2(1);');
    --cn_utils.appindcr(code, 'X_org_id             NUMBER;');

    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'CURSOR batches IS');
    cn_utils.appindcr(code, '  SELECT DISTINCT adj_batch_id');
    cn_utils.appindcr(code, '    FROM cn_trx_lines');
    cn_utils.appindcr(code, '   WHERE adjusted_flag  = ''Y'' AND');
	cn_utils.appindcr(code, '         negated_flag   = ''Y'' AND');
    cn_utils.appindcr(code, '         collected_flag = ''N'' AND');
    cn_utils.appindcr(code, '         event_id = cn_global.inv_event_id AND ');
    cn_utils.appindcr(code, '         org_id = '||x_org_id||' ;');
    cn_utils.appendcr(code);

    cn_utils.unindent(code, 1);
	cn_utils.unset_org_id();

    cn_debug.print_msg('local_variables<<', 1);
    fnd_file.put_line(fnd_file.Log, 'local_variables<<');

    ELSE

    cn_debug.print_msg('local_variables>>', 1);
    fnd_file.put_line(fnd_file.Log, 'local_variables<<');

    cn_utils.set_org_id(x_org_id);
    cn_utils.indent(code, 1);
    cn_utils.appindcr(code, 'trx_count               NUMBER := 0;');
    cn_utils.appindcr(code, 'trx_line_count          NUMBER := 0;');
    cn_utils.appindcr(code, 'trx_sales_line_count    NUMBER := 0;');
    cn_utils.appindcr(code, 'trx_update_count        NUMBER := 0;'); --JC 02-13-97
    cn_utils.appindcr(code, 'trx_line_update_count   NUMBER := 0;');
    cn_utils.appindcr(code, 'trx_sales_line_update_count  NUMBER := 0;');
    cn_utils.appindcr(code, 'comm_lines_api_count    NUMBER := 0;');
    cn_utils.appindcr(code, 'comm_lines_api_update_count  NUMBER := 0;');
    cn_utils.appindcr(code, 'x_start_period_id       NUMBER(15);'); --AE 02-28-96
    cn_utils.appindcr(code, 'x_end_period_id         NUMBER(15);'); --AE 02-28-96
    cn_utils.appindcr(code, 'x_col_audit_id          NUMBER;');   --AE 08-01-95
    cn_utils.appindcr(code, 'x_proc_audit_id         NUMBER;');
    cn_utils.appindcr(code, 'x_conc_program_id       NUMBER;');   --AE 01-18-96
    cn_utils.appindcr(code, 'x_batch_id              NUMBER;');
    cn_utils.appindcr(code, 'x_rowid                 ROWID;');
    cn_utils.appindcr(code, 'debug_pipe              VARCHAR2(30);'); --AE 02-28-96
    cn_utils.appindcr(code, 'debug_level             NUMBER := 1 ;'); --AE 02-28-96
    cn_utils.appindcr(code, 'dummy_num               NUMBER ;'); --JC 01-27-96
    cn_utils.appindcr(code, 'x_return_status         VARCHAR2(1);'); --DM 11-03-99
    cn_utils.appindcr(code, 'x_msg_count             NUMBER;'); --DM 11-03-99
    cn_utils.appindcr(code, 'x_msg_data              VARCHAR(2000);'); --DM 11-03-99
    cn_utils.appindcr(code, 'x_created_by            NUMBER  := to_number(fnd_global.user_id);');
    cn_utils.appindcr(code, 'x_creation_date         DATE    := sysdate;');
    cn_utils.appindcr(code, 'x_last_updated_by       NUMBER  := to_number(fnd_global.user_id);');
    cn_utils.appindcr(code, 'x_last_update_date      DATE    := sysdate;');
    cn_utils.appindcr(code, 'x_last_update_login     NUMBER  := to_number(fnd_global.login_id);');
    --cn_utils.appindcr(code, 'X_org_id                NUMBER ;');
    cn_utils.appendcr(code);


    -- Change made to fix bug 6203234
    -- Fix for bug 8371984
      --  if(x_event_id < 0)
      --  then
     IF (x_event_id = cn_global.aia_event_id or x_event_id = cn_global.aia_om_event_id) THEN
         cn_utils.appindcr(code, 'CURSOR batches IS');
         cn_utils.appindcr(code, '  SELECT DISTINCT batch_id');
         cn_utils.appindcr(code, '    FROM cn_not_trx');
         cn_utils.appindcr(code, '   WHERE collected_flag = ''N''');
	 cn_utils.appindcr(code, '     AND event_id = ' || x_event_id );
      	 cn_utils.appindcr(code, '   AND trunc(processed_date) >= (select start_date from cn_periods where period_name =  x_start_period_name) ' );
         cn_utils.appindcr(code, '   AND trunc(processed_date) <= (select end_date from cn_periods where period_name =  x_end_period_name) ' );
    	 cn_utils.appindcr(code, '     AND org_id = '||x_org_id||' ;');
      ELSE
         cn_utils.appindcr(code, 'CURSOR batches IS');
         cn_utils.appindcr(code, '  SELECT DISTINCT batch_id');
         cn_utils.appindcr(code, '    FROM cn_not_trx');
         cn_utils.appindcr(code, '   WHERE collected_flag = ''N''');
    	 cn_utils.appindcr(code, '     AND event_id = ' || x_event_id );
    	 cn_utils.appindcr(code, '     AND org_id = '||x_org_id||' ;');
      END IF;
            cn_utils.appendcr(code);
            cn_utils.unindent(code, 1);
    		cn_utils.unset_org_id();
      --  end if;
 			cn_debug.print_msg('local_variables<<', 1);
    		fnd_file.put_line(fnd_file.Log, 'local_variables<<');
    END IF; -- IF (procedure_name = 'cn_collect_ram')

    cn_utils.unset_org_id;

  END local_variables;
-- Procedure Name
--   who
-- Purpose
--   Generates some text to record the start of a collection
-- History
--   17-NOV-93		Devesh Khatu		Created

  PROCEDURE who (
	procedure_name	cn_obj_procedures_v.NAME%TYPE,
	code	IN OUT NOCOPY cn_utils.code_type,
    x_org_id IN NUMBER) IS
  BEGIN
    -- The who code has been temporarily commented out since the who package
    -- is yet to be implemented.

    cn_debug.print_msg('who>>', 1);
    fnd_file.put_line(fnd_file.Log, 'who>>');

    cn_utils.set_org_id(x_org_id);
    cn_utils.appindcr(code, '-- who.set_program_name(''' || procedure_name || ''');');
    cn_utils.appendcr(code);
    cn_utils.unset_org_id();

    cn_debug.print_msg('who<<', 1);
    fnd_file.put_line(fnd_file.Log, 'who<<');

  END who;

-- Procedure Name
--   proc_exception
-- Purpose
--   Generates some text to handle the exception
-- History
--   01-27-97		Jin Cheng 		Created

  PROCEDURE proc_exception (
        x_procedure_name	cn_obj_procedures_v.NAME%TYPE,
        savepoint_name		VARCHAR2,
        location                VARCHAR2,
		code		 IN OUT NOCOPY 	cn_utils.code_type,
        x_org_id     IN NUMBER)
	IS
  BEGIN

 	cn_utils.set_org_id(x_org_id);
    cn_utils.unindent(code, 1);
    cn_utils.appindcr(code, 'EXCEPTION');
    cn_utils.indent(code, 1);
    IF (savepoint_name IS NOT NULL) THEN
      cn_utils.appindcr(code, 'WHEN OTHERS THEN ROLLBACK TO ' || savepoint_name || ';');
      cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || x_procedure_name || ': Rollback.'');');
      cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log,''' || x_procedure_name || ': Rollback.'');');
    ELSE
      cn_utils.appindcr(code, 'WHEN OTHERS THEN ');
    END IF;

    cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || x_procedure_name || ': In exception handler ' || location ||'.'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || x_procedure_name || ': In exception handler ' || location ||'.'');');
    cn_utils.appendcr(code);

    cn_utils.appindcr(code, 'cn_process_audits_pkg.update_row(x_proc_audit_id, NULL, SYSDATE, SQLCODE,');
    cn_utils.appindcr(code, '  SQLERRM);');
    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'cn_message_pkg.debug(sqlcode ||'''||' '||'''||sqlerrm);');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, sqlcode ||'''||' '||'''||sqlerrm);');
    cn_utils.appindcr(code, 'cn_message_pkg.end_batch(x_proc_audit_id);');
    cn_utils.appendcr(code);

    cn_utils.appindcr(code, 'app_exception.raise_exception;');
    cn_utils.appendcr(code);
    cn_utils.unset_org_id();

  END proc_exception;

-- Procedure Name
--   pkg_proc_init
-- Purpose
--   This procedure generates procedure init code
-- History
--   17-NOV-93		Devesh Khatu		Created

  PROCEDURE pkg_proc_init (
	x_table_map_id      cn_table_maps.table_map_id%TYPE,
	x_procedure_name	cn_obj_procedures_v.NAME%TYPE,
	x_description		cn_obj_procedures_v.description%TYPE,
	x_parameter_list	cn_obj_procedures_v.parameter_list%TYPE,
	x_package_id		cn_obj_packages_v.package_id%TYPE,
	x_module_id		    cn_modules.module_id%TYPE,    --AE 01-26-96
	x_repository_id 	cn_repositories.repository_id%TYPE,
	x_event_id		    cn_events.event_id%TYPE,
	x_generic           BOOLEAN,
	spec_code	IN OUT NOCOPY cn_utils.code_type,
	body_code	IN OUT NOCOPY cn_utils.code_type,
    x_org_id     IN NUMBER)
  IS

  BEGIN

  l_org_id := x_org_id;

    cn_debug.print_msg('pkg_proc_init>>', 1);
    fnd_file.put_line(fnd_file.Log, 'pkg_proc_init>>');

	cn_utils.set_org_id(X_org_id);
    cn_utils.proc_init(x_procedure_name, x_description, x_parameter_list,
	'P', NULL, x_package_id, x_repository_id, spec_code, body_code);

    -- Generate code for declaring local variables
    local_variables(x_procedure_name, x_event_id, body_code,l_org_id);

	cn_utils.set_org_id(X_org_id);
    cn_utils.proc_begin(x_procedure_name, 'Y', body_code);

    -- Generate code to update who information
    -- who(x_procedure_name, body_code);

    -- Generate code to start debugging messages

    --dbms_output.put_line(' Call Start Debug <<< ');
    call_start_debug(x_procedure_name, x_event_id, body_code,X_org_id);
    --dbms_output.put_line(' Call Start Debug >>> ');


    -- Call_Notify generates different fixed notification code for
    -- either the AR or OC mappings. For a completely generic (data-
    -- driven) source, different code, generated by the cn_collection_custom_gen
    -- package, is used.
    IF NOT x_generic THEN

      -- Insert any User Code specified for the 'Pre-Notification' location
	  cn_utils.unset_org_id();

      cn_collection_custom_gen.Generate_User_Code(
                 p_table_map_id   => x_table_map_id,
			  p_location_name => 'Pre-Notification',
			  code            => body_code,
              X_ORG_ID       => X_ORG_ID);

      IF (x_event_id = cn_global.ram_event_id) THEN -- RAM identify process
        call_identify(x_package_id, x_procedure_name, x_module_id,x_repository_id, x_event_id, body_code,X_ORG_ID);
      ELSE -- other notify process
        call_notify(x_package_id, x_procedure_name, x_module_id,x_repository_id, x_event_id, body_code,X_ORG_ID);
      END IF;

    ELSIF (x_event_id = cn_global.aia_event_id or x_event_id = cn_global.aia_om_event_id) THEN
     -- Insert any User Code specified for the 'Pre-Notification' location
	  cn_utils.unset_org_id();

      cn_collection_custom_gen.Generate_User_Code(
                 p_table_map_id   => x_table_map_id,
			  p_location_name => 'Pre-Notification',
			  code            => body_code,
              X_ORG_ID       => X_ORG_ID);

      call_notify(x_package_id, x_procedure_name, x_module_id,x_repository_id, x_event_id, body_code,X_ORG_ID);
    ELSE
      cn_utils.unset_org_id();
      cn_collection_custom_gen.insert_cn_not_trx (
                             x_table_map_id => x_table_map_id,
                             x_event_id     => x_event_id,
                             code           => body_code,
                             X_ORG_ID       => X_ORG_ID);
    END IF;


    -- Insert any User Code specified for the 'Post-Notification' location
	cn_utils.unset_org_id();
    cn_collection_custom_gen.Generate_User_Code(
                 p_table_map_id   => x_table_map_id,
			  p_location_name => 'Post-Notification',
			  code            => body_code,
              X_ORG_ID       => X_ORG_ID);

    IF (x_event_id = cn_global.ram_event_id) THEN -- RAM identify process
        call_negate(x_package_id, x_procedure_name, x_module_id,x_repository_id, x_event_id, body_code,X_org_id);
    END IF;

	cn_utils.set_org_id(X_org_id);
    cn_utils.appendcr(body_code, '--******** COLLECT PROCESS ********-- ');
    cn_utils.appendcr(body_code);
    cn_utils.appindcr(body_code, 'cn_message_pkg.debug('''|| x_procedure_name || ': start collection process.'');');

  /* -- Generate code to record start of the collection
    cn_utils.record_process_start('COL', '''Collection run''', 'NULL', body_code);

    cn_utils.appindcr(body_code, 'x_col_audit_id := x_proc_audit_id;');   --AE 08-10-95
    cn_utils.appendcr(body_code); */ -- JC 01-26-97

    cn_utils.appindcr(body_code, 'x_conc_program_id := fnd_global.conc_program_id;');   --AE 01-18-96

    --Condition added to fix bug 6203234
    -- Fix for bug 8371984
    --IF(x_event_id < 0)
    --THEN
	    cn_utils.appindcr(body_code, 'cn_message_pkg.debug('''|| x_procedure_name || ': entering cursor Batches loop.'');');
    cn_utils.appindcr(body_code, 'fnd_file.put_line(fnd_file.Log, '''|| x_procedure_name || ': entering cursor Batches loop.'');');
	    cn_utils.appendcr(body_code);

	    cn_utils.appindcr(body_code, 'FOR b IN batches LOOP');
	    cn_utils.appendcr(body_code);
	    cn_utils.indent(body_code, 1);

	    IF (x_event_id = cn_global.ram_event_id) THEN -- RAM identify process
	      cn_utils.appindcr(body_code, 'x_adj_batch_id := b.adj_batch_id;');
	      cn_utils.appendcr(body_code);
	      cn_utils.record_process_start('COL', '''RAM Adjustments Collection run for batch '' || x_adj_batch_id', 'x_col_audit_id', body_code);
	    ELSE
	      cn_utils.appindcr(body_code, 'x_batch_id := b.batch_id;');
	      cn_utils.appendcr(body_code);
	      cn_utils.record_process_start('COL', '''Collection run for batch '' || x_batch_id', 'x_col_audit_id', body_code);
	    END IF;

	    cn_utils.appindcr(body_code, 'BEGIN');
	    cn_utils.indent(body_code, 1);
	    cn_utils.appindcr(body_code, 'SAVEPOINT start_transaction;');
	    cn_utils.appendcr(body_code);
    --END IF;
	cn_utils.unset_org_id();
    cn_debug.print_msg('pkg_proc_init<<', 1);
    fnd_file.put_line(fnd_file.Log, 'pkg_proc_init<<');


  END pkg_proc_init;



-- Procedure Name
--   collect_stmts
-- Purpose
--   This procedure generates the collection code
-- History
--   17-NOV-93		Devesh Khatu		Created

  PROCEDURE collect_stmts (
	x_package_id		cn_obj_packages_v.package_id%TYPE,
	x_procedure_name	cn_obj_procedures_v.NAME%TYPE,
	x_table_map_id		cn_table_maps.table_map_id%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_repository_id 	cn_repositories.repository_id%TYPE,
	x_generic           BOOLEAN,
	x_event_id		cn_events.event_id%TYPE,
	code		IN OUT NOCOPY cn_utils.code_type,
    x_org_id IN NUMBER) IS

  BEGIN

  l_org_id := x_org_id;

    cn_debug.print_msg('collect_stmts>>', 1);
    fnd_file.put_line(fnd_file.Log, 'collect_stmts>>');

    IF x_generic OR
       x_event_id = cn_global.ord_event_id THEN
      IF x_generic THEN

        -- This is a package whose contents are comletely data-driven
        -- Generate code to insert into API table for collection.

        cn_collection_custom_gen.insert_comm_lines_api (x_table_map_id, x_event_id, code,X_org_id);
      ELSE

        -- This is for Order Capture.
        -- Generate code to insert into API table for OE collection.
        cn_collection_oe_gen.insert_comm_lines_api
                  (x_table_map_id, x_package_id, x_procedure_name, x_module_id,
		         x_repository_id, x_event_id, code,X_org_id);
      END IF;

      -- Insert any User Code specified for the 'Pre-Api-Update' location

      cn_collection_custom_gen.Generate_User_Code(p_table_map_id   => x_table_map_id,
			          p_location_name => 'Pre-Api-Update',
			          code            => code,
                      X_ORG_ID       => X_ORG_ID);

      -- Generate code to apply Indirect Mappings to cn_comm_lines_api
      --dbms_output.put_line('B4 cn_collection_custom_gen.update_comm_lines_api');
      --COMMIT;
      cn_collection_custom_gen.update_comm_lines_api (x_table_map_id, code,X_org_id);
      --dbms_output.put_line('After cn_collection_custom_gen.update_comm_lines_api');
      --+
      -- Insert any User Code specified for the 'Pre-Api-Filter' location
      --+

      cn_collection_custom_gen.Generate_User_Code(p_table_map_id   => x_table_map_id,
			          p_location_name => 'Pre-Api-Filter',
			          code            => code,
                      X_ORG_ID       => X_ORG_ID);
      --+
      -- Generate code to apply Filters to cn_comm_lines_api
      --+

      cn_collection_custom_gen.filter_comm_lines_api (x_table_map_id, code,X_org_id);

      --+
      -- Insert any User Code specified for the 'Post-Api-Filter' location
      --+
      cn_collection_custom_gen.Generate_User_Code(p_table_map_id   => x_table_map_id,
			          p_location_name => 'Post-Api-Filter',
			          code            => code,
                      X_ORG_ID        => X_ORG_ID);

    ELSE  -- Receivables package
      IF (x_event_id = cn_global.ram_event_id) THEN -- RAM Collection

	  cn_utils.set_org_id(X_org_id);
      cn_utils.appendcr(code);
      cn_utils.appendcr(code, '--******** UPDATE CN_TRX CN_TRX_LINES ********-- ');
      cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || x_procedure_name || ': update CN_TRX and CN_TRX_LINES.''); ');
      cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || x_procedure_name || ': update CN_TRX and CN_TRX_LINES.''); ');
      cn_utils.appendcr(code);
      cn_utils.appindcr(code, 'UPDATE cn_trx ');
      cn_utils.appindcr(code, '   SET adj_collection_run_id = x_proc_audit_id    ');
      cn_utils.appindcr(code, ' WHERE trx_id IN (SELECT trx_id from cn_trx_lines ');
      cn_utils.appindcr(code, '                   WHERE adjusted_flag  = ''Y'' ');
      cn_utils.appindcr(code, '                     AND negated_flag   = ''Y'' ');
      cn_utils.appindcr(code, '                     AND collected_flag = ''N'' ');
      cn_utils.appindcr(code, '                     AND event_id = cn_global.inv_event_id ');
      cn_utils.appindcr(code, '                     AND adj_batch_id = x_adj_batch_id ');
      cn_utils.appindcr(code, '                     AND org_id = '||x_org_id||')');
      cn_utils.appindcr(code, ' AND org_id = '||x_org_id||';');
      cn_utils.appendcr(code);
      cn_utils.appindcr(code, 'trx_update_count := SQL%ROWCOUNT; ');
      cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || x_procedure_name || ': Updated '' || trx_update_count || '' records in cn_trx.''); ');
      cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || x_procedure_name || ': Updated '' || trx_update_count || '' records in cn_trx.''); ');
      cn_utils.appendcr(code);
      cn_utils.appindcr(code, 'UPDATE cn_trx_lines ');
      cn_utils.appindcr(code, '   SET adj_collection_run_id = x_proc_audit_id    ');
      cn_utils.appindcr(code, ' WHERE adjusted_flag  = ''Y'' ');
      cn_utils.appindcr(code, '   AND negated_flag   = ''Y'' ');
      cn_utils.appindcr(code, '   AND collected_flag = ''N'' ');
      cn_utils.appindcr(code, '   AND event_id = cn_global.inv_event_id ');
      cn_utils.appindcr(code, '   AND adj_batch_id = x_adj_batch_id ');
      cn_utils.appindcr(code, '   AND org_id = '||x_org_id||';');
      cn_utils.appendcr(code);
      cn_utils.appindcr(code, 'trx_line_update_count := SQL%ROWCOUNT; ');
      cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || x_procedure_name || ': Updated '' || trx_line_update_count || '' records in cn_trx_lines.''); ');
      cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || x_procedure_name || ': Updated '' || trx_line_update_count || '' records in cn_trx_lines.''); ');
      cn_utils.appendcr(code);
      cn_utils.indent(code, 1);

      ELSE -- Regular Receivables Collection

      -- Call procedure to generate code for updating trx headers
      cn_utils.unset_org_id();
      cn_collection_ar_gen.insert_trx(x_procedure_name, x_module_id, x_event_id, code,X_org_id);

	  cn_utils.set_org_id(X_org_id);
      cn_utils.appindcr(code, 'IF (trx_count <> 0) THEN         -- Any New Transactions?');
      cn_utils.appendcr(code);
      cn_utils.indent(code, 1);
	  cn_utils.unset_org_id();

      -- Generate code to update headers foreign key columns
      cn_collection_ar_gen.update_trx(x_procedure_name, x_module_id, x_event_id, code,X_org_id);

      -- Generate code to insert into lines
      cn_collection_ar_gen.insert_lines(x_procedure_name, x_module_id, x_event_id, code,X_org_id);

      -- Generate code to update invoice_total in  CN_TRX  table
      cn_collection_ar_gen.update_invoice_total(x_procedure_name, code,l_org_id);

      -- Generate code to update lines
      cn_collection_ar_gen.update_lines(x_procedure_name, x_module_id, x_event_id, code,X_org_id);

      END IF; --IF (x_event_id = cn_global.ram_event_id)

	  cn_utils.unset_org_id();
      -- Generate code to insert into sales lines 	--AE 11-16-95
      cn_collection_ar_gen.insert_sales_lines(x_procedure_name, x_module_id, x_event_id, code,X_org_id);

      -- Generate code to update sales_lines
      cn_collection_ar_gen.update_sales_lines(x_procedure_name, x_module_id, x_event_id, code,X_org_id);

      -- Generate code to insert into cn_comm_lines_api	--AE 08-29-95
      cn_collection_ar_gen.insert_comm_lines (x_procedure_name, x_module_id, x_event_id, code,X_org_id);
      --+
      -- Insert any User Code specified for the 'Pre-Api-Update' location
      --+
      cn_collection_custom_gen.Generate_User_Code(p_table_map_id   => x_table_map_id,
			          p_location_name => 'Pre-Api-Update',
			          code            => code,
                      X_ORG_ID       => X_ORG_ID);
      --+
      -- Generate code to apply Indirect Mappings to cn_comm_lines_api
      --+
      cn_collection_custom_gen.update_comm_lines_api (x_table_map_id, code,X_org_id);
      --+
      -- Insert any User Code specified for the 'Pre-Api-Filter' location
      --+
      cn_collection_custom_gen.Generate_User_Code(p_table_map_id   => x_table_map_id,
			          p_location_name => 'Pre-Api-Filter',
			          code            => code,
                      X_ORG_ID       => X_ORG_ID);
      --+
      -- Generate code to apply Filters to cn_comm_lines_api
      --+
      cn_collection_custom_gen.filter_comm_lines_api (x_table_map_id, code,X_org_id);
      --+
      -- Insert any User Code specified for the 'Post-Api-Filter' location
      --+
      cn_collection_custom_gen.Generate_User_Code(p_table_map_id   => x_table_map_id,
			          p_location_name => 'Post-Api-Filter',
			          code            => code,
                      X_ORG_ID       => X_ORG_ID);

      IF (x_event_id <> cn_global.ram_event_id) THEN
         cn_utils.set_org_id(X_org_id);
         cn_utils.unindent(code, 1);
         cn_utils.appindcr(code, 'END IF;         -- Any New Transactions?');
         cn_utils.appendcr(code);
      END IF;
    END IF;
	cn_utils.unset_org_id();

    cn_debug.print_msg('collect_stmts<<', 1);
    fnd_file.put_line(fnd_file.Log, 'collect_stmts<<');


  END collect_stmts;


--
-- Procedure Name
--   pkg_proc_end
-- Purpose
--   This procedure generates procedure end code
-- History
--   17-NOV-93		Devesh Khatu		Created
--
  PROCEDURE pkg_proc_end (
	x_table_map_id		cn_table_maps.table_map_id%TYPE,
	x_procedure_name	cn_objects.NAME%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code	IN OUT NOCOPY cn_utils.code_type,
    x_org_id IN NUMBER) IS
  BEGIN

    cn_debug.print_msg('pkg_proc_end>>', 1);
    fnd_file.put_line(fnd_file.Log, 'pkg_proc_end>>');
    cn_utils.set_org_id(x_org_id);
    -- Generate code to record success or failure of batch
    -- Fix for bug 8371984
    --IF(x_event_id < 0)
    --THEN
	    IF (x_event_id = cn_global.ram_event_id) THEN
		cn_utils.record_process_success('''Finished collection run for batch '' || x_adj_batch_id', code);
	    ELSE
		cn_utils.record_process_success('''Finished collection run for batch '' || x_batch_id', code);
	    END IF;

	    cn_utils.appindcr(code, 'cn_message_pkg.debug('''|| x_procedure_name || ': inside loop<<'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, '''|| x_procedure_name || ': inside loop<<'');');
	    cn_utils.appindcr(code, 'cn_message_pkg.end_batch(x_proc_audit_id);');
	    cn_utils.appindcr(code, 'COMMIT;');
	    cn_utils.appendcr(code);

	   --  cn_utils.record_process_exception(x_procedure_name, 'start_transaction', code);
	   -- proc_exception(x_procedure_name, 'start_transaction', 'inside the loop', code);

	    cn_utils.unindent(code, 1);
	    cn_utils.appindcr(code, 'END;');
	    cn_utils.unindent(code, 1);
	    cn_utils.appindcr(code, 'END LOOP;');
	    cn_utils.appendcr(code);
    --END IF;
	cn_utils.unset_org_id();
    --+
    -- Insert any User Code specified for the 'Post-Collection' location
    --+
    cn_collection_custom_gen.Generate_User_Code(
                 p_table_map_id   => x_table_map_id,
			  p_location_name => 'Post-Collection',
			  code            => code,
			  X_ORG_ID       => X_ORG_ID);

	cn_utils.set_org_id(x_org_id);
    cn_utils.appindcr(code, 'COMMIT;');

	IF(x_event_id > 0)
	THEN
        IF CN_COLLECTION_GEN.isparallelenabled THEN
		cn_utils.appindcr(code, 'EXECUTE IMMEDIATE ''ALTER SESSION DISABLE PARALLEL DML'';');
        END IF;
         -- Fix for bug 8371984
		-- cn_utils.record_process_success('''Finished collection run for batch '' || x_proc_audit_id', code);
		null;
    END IF;

    cn_utils.appendcr(code);

    cn_utils.appindcr(code, 'x_proc_audit_id := x_col_audit_id;'); --AE 08-01-95

    cn_utils.appindcr(code, 'cn_message_pkg.debug('''|| x_procedure_name ||'<<'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, '''|| x_procedure_name ||'<<'');');

    cn_utils.appindcr(code, 'cn_message_pkg.end_batch(x_proc_audit_id);');
    cn_utils.appendcr(code);

    --  cn_utils.proc_end(x_procedure_name, 'Y', code);

    --proc_exception(x_procedure_name, NULL, 'outside the loop', code);

   IF (x_event_id = cn_global.aia_om_event_id)  THEN
      cn_utils.unindent(code, 1);
      cn_utils.appindcr(code, 'exception when others then');
      cn_utils.appendcr(code, 'errbuf := SQLCODE||'' ''||SQLERRM;' );
      cn_utils.appendcr(code, 'retcode := 2;' );
      cn_utils.appindcr(code, 'cn_message_pkg.debug(SQLCODE||'' ''||SQLERRM);');
      cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, SQLCODE||'' ''||SQLERRM);');
      cn_utils.appindcr(code, 'cn_notify_aia_om.notify_failed_trx(x_batch_id,x_start_period_id, x_end_period_id, debug_pipe, debug_level,x_org_id);' );
      cn_utils.appindcr(code, 'x_proc_audit_id := x_col_audit_id;');
      cn_utils.appindcr(code, 'cn_message_pkg.end_batch(x_proc_audit_id);');
      cn_utils.appendcr(code);
    END IF;

    -- Generate end of procedure statement
    cn_utils.appendcr(code);
    cn_utils.unindent(code, 1);
    cn_utils.appindcr(code, 'END ' ||x_procedure_name || ';');
    cn_utils.appendcr(code);
	cn_utils.unset_org_id();

    cn_debug.print_msg('pkg_proc_end<<', 1);
    fnd_file.put_line(fnd_file.Log, 'pkg_proc_end<<');

  END pkg_proc_end;


  --+
  -- Procedure Name
  --   collection_proc
  -- Purpose
  --   This procedure generates a procedure for collecting source data.
  -- History
  --   17-NOV-93		Devesh Khatu		Created
  --   08-JUN-94		Devesh Khatu		Modified
  --+
  PROCEDURE collection_proc (
	package_name		cn_objects.NAME%TYPE,
	package_id		cn_objects.package_id%TYPE,
	x_table_map_id		cn_table_maps.table_map_id%TYPE,
	module_id		cn_modules.module_id%TYPE,
	repository_id		cn_repositories.repository_id%TYPE,
	event_id		cn_events.event_id%TYPE,
	x_generic           BOOLEAN,
	spec_code	IN OUT NOCOPY cn_utils.code_type,
	body_code	IN OUT NOCOPY cn_utils.code_type,
    x_org_id IN NUMBER) IS

    -- Declare and initialize procedure variables

    procedure_name	cn_objects.NAME%TYPE   := 'collect';
    short_name		cn_objects.NAME%TYPE := SUBSTR(package_name, 12) ;
    description 	cn_objects.description%TYPE
	:= 'Collection procedure for ' || short_name ;
    parameter_list	cn_objects.parameter_list%TYPE
	:= 'errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY NUMBER';

  BEGIN

    -- Non-generic collection packages (AR and OC, require start and end period names
    -- as input parameters

    --dbms_output.put_line(' In collection_proc ');

    IF NOT x_generic THEN
      parameter_list := parameter_list ||
	   ', x_start_period_name IN VARCHAR2, x_end_period_name IN VARCHAR2, x_org_id IN NUMBER ';
    ELSIF (event_id = cn_global.aia_event_id or event_id = cn_global.aia_om_event_id)  THEN
      parameter_list := parameter_list ||
	   ', x_start_period_name IN VARCHAR2, x_end_period_name IN VARCHAR2, x_org_id IN NUMBER ';
    ELSE
        parameter_list := parameter_list ||
	   ', x_org_id IN NUMBER ';
    END IF;
    --dbms_output.put_line('--- NOT x_generic parameter_list');
    --dbms_output.put_line(parameter_list);

    cn_debug.print_msg('collection_proc>>', 1);
    fnd_file.put_line(fnd_file.Log, 'collection_proc>>');

    -- Generate procedure definition, boilerplate text, local variables etc.
    --dbms_output.put_line(' Before pkg_proc_init ');

    pkg_proc_init(x_table_map_id, procedure_name, description, parameter_list, package_id,
	module_id, repository_id, event_id, x_generic, spec_code, body_code,X_org_id);

    --dbms_output.put_line(' after pkg_proc_init ');

    -- Call procedure to generate code for updating trx headers

    --dbms_output.put_line(' Before collect_stmts ');

    collect_stmts(package_id, procedure_name, x_table_map_id, module_id,
	repository_id, x_generic, event_id, body_code,X_org_id);

    --dbms_output.put_line(' after collect_stmts ');

    -- Generate procedure end boilerplate text

    pkg_proc_end(x_table_map_id, procedure_name, event_id,body_code,X_org_id);

    cn_debug.print_msg('collection_proc<<', 1);
    fnd_file.put_line(fnd_file.Log, 'collection_proc<<');

  END collection_proc;
  --+
  -- Procedure Name
  --   null_proc
  -- Purpose
  --   Generate a null procedure when collect flag= NO.
  -- History
  --   12-08-95 	A. Erickson	Created
  --+
  PROCEDURE null_proc(
	package_name		cn_objects.NAME%TYPE,
	package_id		cn_obj_packages_v.package_id%TYPE,
	module_id		cn_modules.module_id%TYPE,
	repository_id		cn_repositories.repository_id%TYPE,
	event_id		cn_events.event_id%TYPE,
	spec_code	IN OUT NOCOPY cn_utils.code_type,
	body_code	IN OUT NOCOPY cn_utils.code_type,
    x_org_id IN NUMBER) IS

    -- Declare and initialize procedure variables

    procedure_name	cn_objects.NAME%TYPE   := 'collect';
    short_name		cn_objects.NAME%TYPE := SUBSTR(package_name, 12) ;
    description 	cn_objects.description%TYPE
	:= 'NULL collection procedure for ' || short_name;
    parameter_list	cn_objects.parameter_list%TYPE
	:= 'errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY NUMBER, x_start_period_name IN VARCHAR2, x_end_period_name IN VARCHAR2, x_org_id IN NUMBER ';

  BEGIN

    l_org_id := x_org_id;

    cn_debug.print_msg('null_proc>>', 1);
    fnd_file.put_line(fnd_file.Log, 'null_proc>>');

    -- Generate procedure definition, boilerplate text, local variables etc.

    cn_utils.set_org_id(X_org_id);
    cn_utils.proc_init(procedure_name, description, parameter_list,
	'P', NULL, package_id, repository_id, spec_code, body_code);

    -- generate local variables.
    cn_utils.indent(body_code, 1);
    cn_utils.appindcr(body_code, 'x_proc_audit_id        NUMBER := NULL ;');
    cn_utils.appindcr(body_code, 'x_col_audit_id         NUMBER;');
    cn_utils.appindcr(body_code, 'debug_pipe             VARCHAR2(30);');  --J.C 02-FEB-97
    cn_utils.appindcr(body_code, 'debug_level            NUMBER := 1 ;');  --J.C 02-FEB-97
    cn_utils.appindcr(body_code, 'dummy_num              NUMBER ;');
    cn_utils.appendcr(body_code);
    cn_utils.unindent(body_code, 1);

    cn_utils.proc_begin(procedure_name, 'Y', body_code);
    call_start_debug(procedure_name, event_id, body_code,X_org_id);

	cn_utils.set_org_id(X_org_id);
    cn_utils.appindcr(body_code, 'NULL;');
    cn_utils.appendcr(body_code);

    cn_utils.appindcr(body_code, 'cn_message_pkg.debug('''|| procedure_name || ': Nothing is being collected.'');');
    cn_utils.appindcr(body_code, 'fnd_file.put_line(fnd_file.Log, '''|| procedure_name || ': Nothing is being collected.'');');
    cn_utils.appindcr(body_code, 'cn_message_pkg.debug('''|| procedure_name ||'<<'');');
    cn_utils.appindcr(body_code, 'fnd_file.put_line(fnd_file.Log, '''|| procedure_name ||'<<'');');
    cn_utils.appindcr(body_code, 'cn_message_pkg.end_batch(x_proc_audit_id);');
    cn_utils.appendcr(body_code);


    -- Generate procedure end.
    -- Generate end of procedure statement
    cn_utils.appendcr(body_code);
    cn_utils.unindent(body_code, 1);
    cn_utils.appindcr(body_code, 'END ' || procedure_name || ';');
    cn_utils.appendcr(body_code);
	cn_utils.unset_org_id();

    cn_debug.print_msg('null_proc<<', 1);
    fnd_file.put_line(fnd_file.Log, 'null_proc<<');

  END null_proc;


  --+
  -- Procedure Name
  --   collection_pkg_code
  -- Purpose
  --   Generate collection package code
  -- History
  --   03-17-00 	Dave Maskell Created
  --+
  PROCEDURE collection_pkg_code (
	debug_pipe           VARCHAR2,
	debug_level          NUMBER := 1,
     x_package_name       cn_objects.NAME%TYPE,
     x_org_append         VARCHAR2,
     x_collect_flag       cn_modules.collect_flag%TYPE,
     x_module_id          cn_modules.module_id%TYPE,
     x_generic            BOOLEAN,
     x_table_map_id       cn_table_maps.table_map_id%TYPE,
     x_org_id IN NUMBER) IS

    l_package_type       cn_objects.package_type%TYPE;
    l_package_spec_id    cn_obj_packages_v.package_id%TYPE;
    l_package_body_id    cn_obj_packages_v.package_id%TYPE;
    l_package_spec_desc  cn_obj_packages_v.description%TYPE;
    l_package_body_desc  cn_obj_packages_v.description%TYPE;
    l_repository_id      cn_repositories.repository_id%TYPE
      := cn_utils.get_repository(X_MODULE_ID,x_org_id);
    l_spec_code          cn_utils.code_type;
    l_body_code          cn_utils.code_type;
    l_event_id           cn_events.event_id%TYPE
      := cn_utils.get_event(x_module_id,x_org_id);

  BEGIN


  --dbms_output.put_line(' In collection_pkg_code');
  --dbms_output.put_line('--- l_repository_id '||l_repository_id);
  --dbms_output.put_line('---      l_event_id '||l_event_id);


    IF (debug_pipe IS NOT NULL) THEN
      cn_debug.init_pipe(debug_pipe, debug_level);
    END IF;
    cn_debug.print_msg('collection_pkg_code>>', 1);
    fnd_file.put_line(fnd_file.Log, 'collection_pkg_code>>');

    --+
    -- Define package in Commissions dictionary, initialize code etc.
    -- Note: pkg_init calls delete_module in cn_utils to delete current mod.
    -- Note: l_package_type can be left NULL - it's not actually used.
    --+

  	cn_utils.set_org_id(x_org_id);

    cn_utils.pkg_init(x_module_id, x_package_name, x_org_append, l_package_type,
                      l_package_spec_id, l_package_body_id, l_package_spec_desc,
                      l_package_body_desc, l_spec_code, l_body_code);

    IF x_collect_flag = 'YES' THEN
       -- Generate the collection procedure to collect invoices data
       collection_proc(x_package_name, l_package_spec_id, x_table_map_id, x_module_id,
                       l_repository_id, l_event_id, x_generic, l_spec_code, l_body_code,X_org_id);
    ELSE
      -- Generate the a null procedure.
      null_proc(x_package_name, l_package_spec_id, x_module_id,
                l_repository_id, l_event_id, l_spec_code, l_body_code,X_org_id);
    END IF;

    -- Generate end package statements, dump code into cn_objects

    cn_utils.set_org_id(X_org_id);
    cn_utils.pkg_end(x_package_name, l_package_spec_id, l_package_body_id,
                     l_spec_code, l_body_code);

    cn_utils.unset_org_id();
    cn_debug.print_msg('collection_pkg_code<<', 1);
	fnd_file.put_line(fnd_file.Log, 'collection_pkg_code<<');

  END collection_pkg_code;

--------------------------------------------------------+
-- Public procedures
--------------------------------------------------------+

  FUNCTION get_org_append
     RETURN VARCHAR2 IS
    l_org_append      VARCHAR2(10);
  BEGIN
    --+
    -- Get org_id for current user and use it to derive Org_Id suffix (e.g. _204)
    --+

    --MO_GLOBAL.INIT('CN');
    IF l_org_id IS NULL OR l_org_id = '' OR l_org_id = -1 then
    l_org_id := mo_global.get_current_org_id;
    END IF;

    IF l_org_id = -99 THEN
      l_org_append := '_M99';
    ELSE
      l_org_append := '_' || l_org_id;
    END IF;
    RETURN l_org_append;

  END get_org_append;

PROCEDURE unset_org_id  --Added by Ashley as part of MOAC Changes
IS
BEGIN
  l_org_id := null;
END;

PROCEDURE set_org_id(p_org_id IN NUMBER)  --Added by Ashley as part of MOAC Changes
IS
BEGIN
  l_org_id := p_org_id;
END;

  --+
  -- Procedure Name
  --   collection_pkg
  -- Purpose
  --   Generate any collection package
  -- History
  --   03-17-00 	Dave Maskell Created
  --+
  PROCEDURE collection_pkg (
	debug_pipe	VARCHAR2,
	debug_level	NUMBER := 1,
     x_table_map_id cn_table_maps.table_map_id%TYPE,
     x_org_id IN NUMBER) IS

    l_generic  		BOOLEAN := FALSE;
    l_module_id          cn_modules.module_id%TYPE;
    l_package_name       cn_objects.NAME%TYPE;
    l_mapping_type       cn_objects.package_type%TYPE;
    --l_org_append         VARCHAR2(100) := get_org_append;
l_org_append         VARCHAR2(100);
  BEGIN

  l_org_id := x_org_id;
  l_org_append := get_org_append;
  --dbms_output.put_line('x_org_id:1'||x_org_id);
    --dbms_output.put_line('l_org_id:1'||l_org_id);


    IF (debug_pipe IS NOT NULL) THEN
      cn_debug.init_pipe(debug_pipe, debug_level);
    END IF;
    cn_debug.print_msg('collection_pkg>>', 1);
    fnd_file.put_line(fnd_file.Log, 'collection_pkg>>');
    --+
    -- Get info about this data source from cn_table_maps
    --+
    SELECT mapping_type, module_id
    INTO   l_mapping_type, l_module_id
    FROM cn_table_maps
    WHERE  table_map_id = x_table_map_id
    AND    org_id = X_ORG_ID;
    --+
    -- Process according to the mapping data source
    --+
    IF l_mapping_type = 'AR' THEN
      --+
      -- If source is Receivables then we must generate up to
      -- four collection packages, depending on whether they
      -- are currently flagged for collection
      --+
      FOR rec IN
        (SELECT module_id, module_type, collect_flag FROM cn_modules
         WHERE module_type IN ('INV','CBK','PMT','WO','RAM') AND org_id = x_org_id)
      LOOP
        IF rec.module_type = 'INV' THEN
          l_package_name := 'cn_collect_invoices';
        ELSIF rec.module_type = 'PMT' THEN
          l_package_name := 'cn_collect_payments';
        ELSIF rec.module_type = 'WO' THEN
          l_package_name := 'cn_collect_writeoffs';
        ELSIF rec.module_type = 'CBK' THEN
          l_package_name := 'cn_collect_clawbacks';
        ELSIF rec.module_type = 'RAM' THEN
          l_package_name := 'cn_collect_ram';
        END IF;
        --+
        -- Generate package internals
        --+

        collection_pkg_code (
	     debug_pipe           => debug_pipe,
	     debug_level          => debug_level,
          x_package_name       => l_package_name,
          x_org_append         => l_org_append,
          x_collect_flag       => rec.collect_flag,
          x_module_id          => rec.module_id,
          x_generic            => l_generic,
          x_table_map_id       => x_table_map_id,
          x_org_id             => X_org_id);
      END LOOP;
    ELSE
      --+
      -- For Order Capture (OC) and custom data sources there is only one package
      -- and it is always generated (collect_flag = 'YES')
      -- +
      IF l_mapping_type <> 'OC' THEN
	   l_generic := TRUE;
        --+
        -- For custom packages, the package name (as stored in CN_OBJECTS)
        -- is of the format cn_collect_<mapping_type>_<org_id>
        --+
        IF l_mapping_type <> 'AIA' and l_mapping_type <> 'AAOM' THEN
	   l_org_append := NULL;
        END IF;

      END IF;

	 SELECT OBJ.name OBJECT_NAME
	 INTO   l_package_name
	 FROM   cn_table_map_objects tmov, cn_objects obj
	 WHERE  tmov.table_map_id = x_table_map_id
	        AND tmov.tm_object_type = 'PKS'
	        and tmov.org_id = obj.org_id
	        and tmov.object_id = obj.object_id
			AND tmov.org_id = X_org_id;

      --dbms_output.put_line(' l_org_append before collection_pkg_code in collection_pkg');
      --dbms_output.put_line(' l_org_append '||l_org_append);
      --dbms_output.put_line(' l_package_name '||l_package_name);

	  --dbms_output.put_line(' After Select '||l_package_name);

	  --dbms_output.put_line(' Before collection_pkg_code ');

      collection_pkg_code (
	   debug_pipe           => debug_pipe,
	   debug_level          => debug_level,
        x_package_name       => l_package_name,
        x_org_append         => l_org_append,
        x_collect_flag       => 'YES',
        x_module_id          => l_module_id,
	   x_generic            => l_generic,
       x_table_map_id       => x_table_map_id,
       x_org_id             => X_org_id);

	--dbms_output.put_line(' Out OF collection_pkg_code ');
    END IF;
	--COMMIT;
    cn_debug.print_msg('collection_pkg<<', 1);
    fnd_file.put_line(fnd_file.Log, 'collection_pkg<<');
  END collection_pkg;

  PROCEDURE Collection_Install(
                 x_errbuf OUT NOCOPY VARCHAR2,
                 x_retcode OUT NOCOPY NUMBER,
                 p_table_map_id IN cn_table_maps.table_map_id%TYPE,
			     p_test        IN VARCHAR2 ,
                 x_org_id IN NUMBER)
  IS
    l_org_append      VARCHAR2(10);
    l_test_append     VARCHAR2(5);
    l_mapping_type    cn_table_maps.mapping_type%TYPE;
    l_module_id       cn_table_maps.module_id%TYPE;
    l_comp_error      VARCHAR2(10);
    l_errors          BOOLEAN := FALSE;
    l_max_len         NUMBER := 1800;
    l_remainder       NUMBER;
     -- Variable for Notes
     l_note_msg	   VARCHAR2(4000);
     x_note_id	   NUMBER;
     l_context_code	   VARCHAR2(4000);
     l_context_id	   NUMBER;
     l_pkg_name  VARCHAR2(4000);
     x_return_status  VARCHAR2(4000);
     x_msg_count NUMBER;
     x_msg_data  VARCHAR2(4000);



  BEGIN
    x_retcode := 0;
    x_errbuf := ' ';

    l_org_id := x_org_id;

    --dbms_output.put_line(' In Collection Install ');
    --dbms_output.put_line('p_table_map_id '||p_table_map_id);
    --dbms_output.put_line('l_org_id '||l_org_id);

    --+
    -- We need to get the exact package name. For custom
    -- data sources, this is the same as the name stored in CN_OBJECTS. For AR and OC
    -- the name stored in CN_OBJECTS does not have the Org_id on it, so we must
    -- append this. (Also get module_id for later use)
    --+

    SELECT mapping_type, module_id
    INTO   l_mapping_type, l_module_id
    FROM   cn_table_maps
    WHERE  table_map_id = p_table_map_id
    AND    org_id = X_org_id;

    --dbms_output.put_line(' In Collection Install l_mapping_type : '||l_mapping_type);
    --dbms_output.put_line(' In Collection Install l_module_id'||l_module_id);

    IF l_mapping_type NOT IN ('AR','OC', 'AIA', 'AAOM')
    THEN
      l_org_append := NULL;
    ELSE
      l_org_append := get_org_append;
    END IF;

    --dbms_output.put_line(' In Collection Install l_org_append '||l_org_append);

    --+
    -- Loop for each package belonging to the source, getting
    -- the object_ids for the Spec and Body, plus the package
    -- name (from CN_OBJECTS). For AR there will
    -- be 4 packages, for any other source there will only be one.
    --+

    FOR rec IN
      (SELECT
         UPPER(OBJ.name) NAME ,
         MAX(DECODE(tmov.tm_object_type,'PKS',tmov.object_id,NULL)) spec_id,
         MAX(DECODE(tmov.tm_object_type,'PKB',tmov.object_id,NULL)) body_id
       FROM cn_table_map_objects tmov, cn_objects obj
       WHERE tmov.tm_object_type IN ('PKS','PKB')
       and obj.object_id = tmov.object_id
       and tmov.org_id = obj.org_id
             AND tmov.table_map_id = p_table_map_id
             AND tmov.org_id = X_org_id
       GROUP BY OBJ.name)
    LOOP
      --+
      -- Create the Spec and Body.
      --+
	 install_package_object(
			    p_object_id   => rec.spec_id,
			    p_object_name => rec.name||l_org_append,
			    p_test => p_test,
			    x_comp_error  => l_comp_error,
                x_org_id => X_org_id);

	 IF l_comp_error = 'TRUE' THEN
	   l_errors := TRUE;
      END IF;
	 install_package_object(
			    p_object_id   => rec.body_id,
			    p_object_name => rec.name||l_org_append,
			    p_test => p_test,
			    x_comp_error  => l_comp_error,
                x_org_id => X_org_id);



	 IF l_comp_error = 'TRUE' THEN
	   l_errors := TRUE;
      END IF;
    END LOOP;
    ------------------------------------------------------------------------------+
    -- The rest of the procedure is concerned with providing log messages if the
    -- creation of any of the packages failed
    ------------------------------------------------------------------------------+
    IF l_errors THEN						-- some specs/bodies were in error
      x_retcode := 1;						-- set failure return code
      --+
      -- If p_test = 'Y', we have generated a test package, which will
      -- have the _T suffix.
      --+
      IF p_test = 'Y' THEN
	   l_test_append := '_T';
      ELSE
	   l_test_append := NULL;
      END IF;
      --+
      -- Search the User_Errors table, for errors belonging to any of the Collection
      -- packages for this Org.
      --+
      FOR obj_rec IN
        (SELECT
           DISTINCT UPPER(OBJ.name) NAME
         FROM cn_table_map_objects tmov, cn_objects obj
         WHERE tm_object_type IN ('PKS','PKB')
               AND tmov.table_map_id = p_table_map_id
               and tmov.object_id = obj.object_id
               and tmov.org_id = obj.org_id
               AND tmov.org_id = X_org_id
         GROUP BY OBJ.name)
      LOOP  <<outer>>
        FOR err_rec IN
          (SELECT
           '*** '||TYPE||' '||LOWER(NAME)||' LINE: '||line||'/'||position||
		   fnd_global.local_chr(10)||text||fnd_global.local_chr(10) outstr
           FROM user_errors WHERE NAME = obj_rec.name||l_org_append||l_test_append)
        LOOP  <<inner>>
          -- If there is enough space, append this error to the end of the
	     -- Errbuf, otherwise aappend as mauch as possible and then quit
	     -- the loop.
	     IF LENGTHB(x_errbuf) + LENGTHB(err_rec.outstr) <= l_max_len THEN
	       x_errbuf := x_errbuf || err_rec.outstr;
          ELSE
	       l_remainder := l_max_len - LENGTHB(x_errbuf);
	       x_errbuf := x_errbuf || SUBSTRB(err_rec.outstr,1,l_remainder);
	       EXIT outer;
          END IF;
        END LOOP;
      END LOOP;
    END IF;

    -- Update the status of the module to 'GENERATED' if we were installing
    -- the actual package rather than the test version.
    IF p_test = 'N' and x_retcode<>1 THEN
      cn_modules_pkg.update_row(x_module_id     => l_module_id,
		                      x_module_status => 'GENERATED',
                              x_org_id => X_org_id);
      FOR pkg_names IN
        (SELECT
           DISTINCT UPPER(OBJ.name) NAME
         FROM cn_table_map_objects tmov, cn_objects obj
         WHERE tm_object_type IN ('PKS','PKB')
               AND tmov.table_map_id = p_table_map_id
               and tmov.object_id = obj.object_id
               and tmov.org_id = obj.org_id
               AND tmov.org_id = X_org_id
         GROUP BY OBJ.name)
      LOOP

      IF(p_table_map_id < 0)
      THEN
        l_pkg_name := pkg_names.NAME||l_org_append;
        l_context_code := 'CN_REPOSITORIES';
        l_context_id := x_org_id;
      ELSE
        l_pkg_name := pkg_names.NAME;
        l_context_code := 'CN_MODULES';
        l_context_id := l_module_id;
    END IF;
    -- Adding notes for Transaction Source Type
    FND_MESSAGE.SET_NAME('CN', 'CN_COL_PKG_GEN_SUC');
    FND_MESSAGE.SET_TOKEN('PACKAGENAME', l_pkg_name);
    l_note_msg := FND_MESSAGE.GET;

    jtf_notes_pub.create_note
     ( p_api_version           => 1.0,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_source_object_id      => l_context_id,
       p_source_object_code    => l_context_code,
       p_notes                 => l_note_msg,
       p_notes_detail          => l_note_msg,
       p_note_type             => 'CN_SYSGEN',
       x_jtf_note_id           => x_note_id
       );
       END LOOP;

    END IF;

    IF p_test = 'N' and x_retcode=1 THEN
      FOR pkg_names IN
        (SELECT
           DISTINCT UPPER(OBJ.name) NAME
         FROM cn_table_map_objects tmov, cn_objects obj
         WHERE tm_object_type IN ('PKS','PKB')
               AND tmov.table_map_id = p_table_map_id
               and tmov.object_id = obj.object_id
               and tmov.org_id = obj.org_id
               AND tmov.org_id = X_org_id
         GROUP BY OBJ.name)
      LOOP

      IF(p_table_map_id < 0)
      THEN
        l_pkg_name := pkg_names.NAME||l_org_append;
        l_context_code := 'CN_REPOSITORIES';
        l_context_id := x_org_id;
      ELSE
        l_pkg_name := pkg_names.NAME;
        l_context_code := 'CN_MODULES';
        l_context_id := l_module_id;
      END IF;
    -- Adding notes for Transaction Source Type
    FND_MESSAGE.SET_NAME('CN', 'CN_COL_PKG_GEN_FAIL');
    FND_MESSAGE.SET_TOKEN('PACKAGENAME', l_pkg_name);
    l_note_msg := FND_MESSAGE.GET;

    jtf_notes_pub.create_note
     ( p_api_version           => 1.0,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_source_object_id      => l_context_id,
       p_source_object_code    => l_context_code,
       p_notes                 => l_note_msg,
       p_notes_detail          => l_note_msg,
       p_note_type             => 'CN_SYSGEN',
       x_jtf_note_id           => x_note_id
       );
       END LOOP;

    END IF;
    --dbms_output.put_line('Leaving In Collection Install  l_comp_error ');
	--COMMIT;
  END Collection_Install;

-- Procedure to be called by CN_COLLECT_GEN concurrent program
PROCEDURE generate_collect_conc(
        errbuf OUT NOCOPY VARCHAR2,
        retcode OUT NOCOPY NUMBER,
        p_org_id NUMBER)
IS
    l_return_status    VARCHAR2(30);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);
    l_debug_pipe  VARCHAR2(2000);
    l_debug_level NUMBER;

    CURSOR maps IS
	SELECT tm.table_map_id,
	       tm.org_id,
	       tm.module_id,
	       mo.module_status
	FROM   cn_table_maps_all tm,
	       cn_modules_all_b mo
	WHERE  tm.module_id = mo.module_id
    AND    tm.org_id = mo.org_id
    AND    mo.module_status = 'GENERATED'
    AND    mo.org_id = nvl(p_org_id, mo.org_id)
    AND    mo.org_id <> -3113
	ORDER BY tm.table_map_id, tm.org_id, tm.module_id;

  CURSOR compile_pkg_cur IS
     SELECT object_name || ' ' ||
     decode(object_type, 'PACKAGE BODY','compile body','PACKAGE','compile') stmt
     FROM user_objects
     WHERE object_name LIKE 'CN_COLLECT%'
     AND substr(object_name, (INSTR(object_name,'_',1,3)+1), 1)IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
     AND object_type LIKE 'PACKAGE%'
     AND status = 'INVALID';


  CURSOR drop_pkg_cur IS
     SELECT object_name stmt
     FROM user_objects
     WHERE object_name LIKE 'CN_COLLECT%'
     AND substr(object_name, (INSTR(object_name,'_',1,3)+1), 1)IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
     AND object_type LIKE 'PACKAGE%'
     AND status = 'INVALID';



BEGIN
  -- ==============================
  -- Regenerate Collection packages
  -- ==============================

  FOR tablemaprec IN maps LOOP

     -- 	dbms_application_info.set_client_info(map.org_id);

    	-- Generate Collection code. Code is stored in CN_SOURCE.
    	collection_pkg(
            l_debug_pipe,
            l_debug_level,
            tablemaprec.table_map_id,
            tablemaprec.org_id);

        -- Install the collection test package.
        collection_install(
            x_errbuf => errbuf,
            x_retcode => retcode,
            p_table_map_id => tablemaprec.table_map_id,
            p_test => 'Y',
            x_org_id => tablemaprec.org_id);

        -- Install the collection package.
        collection_install(
            x_errbuf => errbuf,
            x_retcode => retcode,
            p_table_map_id => tablemaprec.table_map_id,
            p_test => 'N',
            x_org_id => tablemaprec.org_id);

  END LOOP;

   -- Try one round of compiling the invalid formula packages

   FOR i IN compile_pkg_cur

   LOOP

     BEGIN

      execute IMMEDIATE  'alter package '|| i.stmt;

     EXCEPTION

      WHEN others THEN

          NULL;

     END;

   END LOOP;



   -- Drop the collection package if still invalid

   FOR i IN drop_pkg_cur

   LOOP

     BEGIN

      execute immediate 'drop package '|| i.stmt;

     EXCEPTION

      WHEN others

        THEN

        NULL;

     END;

   END LOOP;

retcode := 0;

errbuf := 'Batch runner completes successfully.';

COMMIT;

EXCEPTION

   WHEN OTHERS THEN

     retcode := 2;

     errbuf  := sqlerrm;

END generate_collect_conc;

END cn_collection_gen;


/
