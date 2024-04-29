--------------------------------------------------------
--  DDL for Package Body FND_PROGRAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PROGRAM" AS
/* $Header: AFCPRCPB.pls 120.1.12010000.3 2013/12/16 21:50:34 pferguso ship $ */


/* START_PUBLIC */
bad_parameter EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_parameter, -06501); -- program error
/* END_PUBLIC */

who_mode VARCHAR2(20) := 'customer_data';  /* customer_data or seed_data */

NTRUE     constant     number :=1;
NFALSE    constant     number :=0;


/* ------------------------------------------------------------ */
/*  messaging                                                   */
/* ------------------------------------------------------------ */


debug_mode_on BOOLEAN := FALSE;
internal_messages VARCHAR2(10000);

/* START_PUBLIC */
PROCEDURE debug_on IS
BEGIN
   debug_mode_on := TRUE;
END;

PROCEDURE debug_off IS
BEGIN
   debug_mode_on := FALSE;
END;
/* END_PUBLIC */

PROCEDURE message(msg VARCHAR2) IS
BEGIN
   internal_messages := internal_messages || msg || fnd_global.newline;
--   internal_messages := internal_messages || Sqlerrm; /* error stamp */
END;

PROCEDURE message_init IS
BEGIN
   internal_messages := '';
END;

/* START_PUBLIC */
FUNCTION message RETURN VARCHAR2 IS
BEGIN
   RETURN internal_messages;
END;
/* END_PUBLIC */


/* print functions only used in testing */
/***********************************
 * Uncomment dbms_output calls and upload to database to enable debugging
 * commented to remove GSCC dated warnings
 ***********************************/
PROCEDURE print(msg IN VARCHAR2) IS
BEGIN
   IF(debug_mode_on) THEN
--      dbms_output.enable;
--      dbms_output.put(msg);
      null;
   END IF;
END;

PROCEDURE println IS
BEGIN
   IF(debug_mode_on) THEN
--      dbms_output.enable;
--      dbms_output.put_line('');
      null;
   END IF;
END;

PROCEDURE println(msg IN VARCHAR2) IS
BEGIN
   IF(debug_mode_on) THEN
--      dbms_output.enable;
--      dbms_output.put_line(msg);
      null;
   END IF;
END;


/* ------------------------------------------------------------ */
/*  who information                                             */
/* ------------------------------------------------------------ */

PROCEDURE set_session_mode(session_mode IN VARCHAR2) IS
BEGIN
   IF(session_mode NOT IN ('customer_data', 'seed_data')) THEN
      message('bad mode:'|| session_mode);
      message('valid values are: customer_data, seed_data');
      RAISE bad_parameter;
   END IF;
   who_mode := session_mode;
END;


FUNCTION customer_mode RETURN BOOLEAN IS
BEGIN
   IF(who_mode = 'customer_data') THEN
      RETURN TRUE;
    ELSIF(who_mode = 'seed_data') THEN
      RETURN FALSE;
    ELSE
      message('bad session mode:' || who_mode);
      message('use set_session_mode to specify');
      RAISE bad_parameter;
   END IF;
END;


FUNCTION created_by_f RETURN NUMBER IS
BEGIN
   IF(customer_mode) THEN
      RETURN 0;
    ELSE
      RETURN 1;
   END IF;
END;

FUNCTION creation_date_f RETURN DATE IS
BEGIN
   IF(customer_mode) THEN
      RETURN Sysdate;
    ELSE
      RETURN To_date('01011980', 'MMDDYYYY');
   END IF;
END;

FUNCTION last_updated_by_f RETURN NUMBER IS
BEGIN
   RETURN created_by_f;
END;

FUNCTION last_update_date_f RETURN DATE IS
BEGIN
   RETURN creation_date_f;
END;

FUNCTION last_update_login_f RETURN NUMBER IS
BEGIN
   return 0;
END;



/* ------------------------------------------------------------ */

/* get the application id, given the name (or short name) */
FUNCTION application_id_f(application_name_in IN VARCHAR2)
  RETURN fnd_application.application_id%TYPE
  IS
     application_id_ret fnd_application.application_id%TYPE;
BEGIN
   IF(application_name_in IS NULL) THEN
      message('A null application_name was specified.');
      RAISE bad_parameter;
   END IF;
   /* Check the short name first. */
   SELECT application_id
     INTO application_id_ret
     FROM fnd_application
     WHERE application_short_name = application_name_in;
   RETURN application_id_ret;
EXCEPTION
   WHEN no_data_found THEN  /* Try the translated name. */
     BEGIN
       SELECT application_id
         INTO application_id_ret
         FROM fnd_application_tl
        WHERE application_name = application_name_in
          AND rownum = 1;
       RETURN application_id_ret;
     EXCEPTION
       when NO_DATA_FOUND then
         message('Invalid application name: ' || application_name_in);
         RAISE bad_parameter;
     END;
END;


/* Get the application short name, given the name (or short name).
 * This is a kludge used because the CP and Flex APIs
 * handle application_name and short_name parameters
 * differently.
 */
FUNCTION application_short_name_f(application_name_in IN VARCHAR2)
  RETURN fnd_application.application_short_name%TYPE
  IS
     application_sn_ret fnd_application.application_short_name%TYPE;
BEGIN
   IF(application_name_in IS NULL) THEN
      message('A null application_name was specified.');
      RAISE bad_parameter;
   END IF;
   /* Check the short name first. */
   SELECT application_short_name
     INTO application_sn_ret
     FROM fnd_application
     WHERE application_short_name = application_name_in;
   RETURN application_sn_ret;
EXCEPTION
   WHEN no_data_found THEN  /* Try the translated name. */
     BEGIN
       SELECT application_short_name
         INTO application_sn_ret
         FROM fnd_application_tl t,
              fnd_application b
        WHERE t.application_name = application_name_in
          AND rownum = 1
          AND t.application_id = b.application_id;
       RETURN application_sn_ret;
     EXCEPTION
       when NO_DATA_FOUND then
         message('Invalid application name: ' || application_name_in);
         RAISE bad_parameter;
     END;
END;


/* Get a concurrent program ID given appl ID and short name */
FUNCTION concurrent_program_id_f(program_application_id number,
				 program_short_name varchar2) return number is
  program_id fnd_concurrent_programs.concurrent_program_id%TYPE;
BEGIN
  SELECT concurrent_program_id
    INTO program_id
    FROM fnd_concurrent_programs
   WHERE application_id = program_application_id
     AND concurrent_program_name = program_short_name;

  RETURN program_id;

EXCEPTION
  WHEN no_data_found THEN
    message('Could not find program: '||program_short_name);
    RAISE bad_parameter;
END;


/* Get a request group ID given name and appl ID */
FUNCTION request_group_id_f(group_application_id number,
		            request_group varchar2) return number is
  group_id fnd_request_groups.request_group_id%TYPE;
BEGIN
  SELECT request_group_id
    INTO group_id
    FROM fnd_request_groups
   WHERE application_id = group_application_id
     AND request_group_name = request_group;

  RETURN group_id;

EXCEPTION
  WHEN no_data_found THEN
    message('Could not find group: '|| request_group);
    RAISE bad_parameter;
END;


PROCEDURE check_yesno(val IN VARCHAR2) IS
BEGIN
   if (upper(val) not in ('Y', 'N')) then
      message('Y/N value expected, but not found.');
      raise bad_parameter;
   end if;
END;


PROCEDURE check_notnull(val IN VARCHAR2) IS
BEGIN
   IF(val IS NULL) THEN
      message('A NULL value was specified for a NOT NULL parameter.');
      RAISE bad_parameter;
   END IF;
END;

PROCEDURE check_notnull(val IN NUMBER) IS
BEGIN
   IF(val IS NULL) THEN
      message('A NULL value was specified for a NOT NULL parameter.');
      RAISE bad_parameter;
   END IF;
END;

PROCEDURE check_notnull(val IN DATE) IS
BEGIN
   IF(val IS NULL) THEN
      message('A NULL value was specified for a NOT NULL parameter.');
      RAISE bad_parameter;
   END IF;
END;



PROCEDURE check_srs(application_id_i IN fnd_application.application_id%TYPE,
		    concurrent_pgm_name_in IN VARCHAR2)
  IS
   srs_flag_i fnd_concurrent_programs.srs_flag%TYPE;
   /* make sure the program exists, and can support SRS */
BEGIN
   SELECT srs_flag
     INTO srs_flag_i
     FROM fnd_concurrent_programs
     WHERE concurrent_program_name = concurrent_pgm_name_in
     AND application_id = application_id_i;
   IF(srs_flag_i = 'N') THEN
      message('SRS not enabled for: '||concurrent_pgm_name_in);
      RAISE bad_parameter;
   END IF;
EXCEPTION
   WHEN no_data_found THEN
      message('Could not find definition of program: '||
	      concurrent_pgm_name_in);
      RAISE bad_parameter;
END;


/* ------------------------------------------------------------ */
/* ------------------------------------------------------------ */

/* START_PUBLIC */

-- Procedure
--   PARAMETER
--
-- Purpose
--   Register an SRS parameter for a program
--
-- Arguments:
--   program_short_name - e.g. FNDSCRMT
--   application        - Program application.
--                        e.g.'Application Object Library'
--   sequence           - Parameter sequence number
--   parameter          - Name of parameter
--   description        - Parameter description (Optional)
--   enabled            - 'Y' or 'N'
--   value_set          - Name of value set (e.g. '30 Characters Optional')
--   default_type       - 'Constant', 'Profile', 'SQL Statement', 'Segment'
--                        (Optional)
--   default_value      - Parameter default (Required if default_type is not
--                        Null)
--   required           - 'Y' or 'N'
--   enable_security    - 'Y' or 'N', Enables security if value set allows.
--   range              - 'High', 'Low', or 'Pair' (Optional)
--   display            - 'Y' or 'N'
--   display_size       - Length of item in parameter window
--   description_size   - Length of item description in parameter window
--   concatenated_description_size - Length of description in concatenated
--                                   parameters field.
--   prompt             - Item prompt in parameter window
--   token              - Required token for Oracle Reports parameters
--   cd_parameter       - 'Y' sets this parameter to be this program's cd_parameter
--
PROCEDURE parameter(
	program_short_name            IN VARCHAR2,
	application                   IN VARCHAR2,
	sequence                      IN NUMBER,
	parameter                     IN VARCHAR2,
	description                   IN VARCHAR2 DEFAULT NULL,
	enabled                       IN VARCHAR2 DEFAULT 'Y',
	value_set                     IN VARCHAR2,
	default_type                  IN VARCHAR2 DEFAULT NULL,
	default_value                 IN VARCHAR2 DEFAULT NULL,
	required                      IN VARCHAR2 DEFAULT 'N',
	enable_security               IN VARCHAR2 DEFAULT 'N',
	range                         IN VARCHAR2 DEFAULT NULL,
	display                       IN VARCHAR2 DEFAULT 'Y',
	display_size                  IN NUMBER,
	description_size              IN NUMBER,
	concatenated_description_size IN NUMBER,
	prompt                        IN VARCHAR2 DEFAULT NULL,
        token                         IN VARCHAR2 DEFAULT NULL,
        cd_parameter                  IN VARCHAR2 DEFAULT 'N')
  IS
     descriptive_flexfield_name_in
       fnd_descriptive_flexs.descriptive_flexfield_name%TYPE;
     form_prompt fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE;
     application_id_i fnd_application.application_id%TYPE;
     column_name VARCHAR2(100);
     emc varchar2(1);
     appl_short_name fnd_application.application_short_name%TYPE;
BEGIN
   message_init;

   fnd_flex_dsc_api.set_session_mode(session_mode=>who_mode);

   check_notnull(program_short_name);
   check_notnull(application);
   check_notnull(sequence);
   check_notnull(parameter);
   check_notnull(enabled);
   check_notnull(value_set);
   check_notnull(required);
   check_notnull(enable_security);
   check_notnull(display);

   check_yesno(enabled);
   check_yesno(required);
   check_yesno(enable_security);
   check_yesno(display);
   check_yesno(cd_parameter);

   application_id_i := application_id_f(application);
   appl_short_name := application_short_name_f(application);



   BEGIN
     select execution_method_code
       into emc
       from fnd_concurrent_programs
      where application_id_i = application_id
        and concurrent_program_name = program_short_name;
   EXCEPTION
     when no_data_found then
       message('Could not find definition of program: '
               || program_short_name);
       raise bad_parameter;
   END;

   if ((emc in ('P','K')) and (token is null)) then
     message('Token required for Oracle Reports and Java Concurrent Program parameters.');
     raise bad_parameter;
   end if;

   if ((emc not in ('P','K')) and (token is not null)) then
     message('Token must be null except for Oracle Reports and Java Concurrent program parameters.');
     raise bad_parameter;
   end if;

   descriptive_flexfield_name_in := '$SRS$.'||program_short_name;
   check_srs(application_id_i, program_short_name);

   IF(prompt IS NOT NULL) THEN
      form_prompt := prompt;
    ELSE
      form_prompt := parameter;
   END IF;
   /* get the first available column name (viz ATTRIBUTEn)
   and use it in creating the segment */
   DECLARE
      CURSOR column_name_cursor IS
	 SELECT column_name
	   FROM fnd_columns c, fnd_tables t
	   WHERE t.table_id = c.table_id
	   AND t.table_name = 'FND_SRS_MASTER'  -- hardwired
	   AND t.application_id = 0             -- hardwired
	   AND c.application_id = t.application_id
	   AND c.flexfield_usage_code = 'D'
	   AND NOT EXISTS (SELECT NULL
			   FROM fnd_descr_flex_column_usages cu
			   WHERE cu.application_id = application_id_i
			   AND cu.descriptive_flexfield_name
			   = descriptive_flexfield_name_in
			   AND cu.application_column_name = c.column_name);
   BEGIN
      OPEN column_name_cursor;
      FETCH column_name_cursor INTO column_name;
      IF column_name_cursor%NOTFOUND THEN
	 message('No available columns in FND_SRS_MASTER.');
	 RAISE bad_parameter;
      END IF;
      BEGIN
	 fnd_flex_dsc_api.create_segment(
	       appl_short_name => appl_short_name,
	       flexfield_name => descriptive_flexfield_name_in,
	       context_name => 'Global Data Elements',
	       name => parameter,
	       column => column_name,
	       description => description,
	       sequence_number => sequence,
	       enabled => upper(enabled),
	       displayed => upper(display),
	       value_set => value_set,
	       default_type => default_type,
	       default_value => default_value,
	       required => upper(required),
	       security_enabled => upper(enable_security),
	       display_size => display_size,
	       description_size => description_size,
	       concatenated_description_size => concatenated_description_size,
	       list_of_values_prompt => prompt,
	       window_prompt => prompt,
	       range => range,
	       srw_parameter => token);
      EXCEPTION
	 WHEN bad_parameter THEN
	    message(fnd_flex_dsc_api.message);
	    RAISE bad_parameter;
      END;
      CLOSE column_name_cursor;

   END;

   IF cd_parameter = 'Y' THEN
       UPDATE fnd_concurrent_programs
       SET    cd_parameter = parameter
       WHERE  application_id = application_id_i
       AND    concurrent_program_name = program_short_name;
   END IF;

   println('created parameter:'||parameter);
END;



-- Procedure
--   REGISTER
--
-- Purpose
--   Register a concurrent program.
--
-- Arguments
--   program                - User-visible program name. e.g. 'Menu Report'
--   application            - Program application.
--                            e.g. 'Application Object Library'
--   enabled                - 'Y' or 'N'
--   short_name             - Internal program name.  e.g. 'FNDSCRMT'
--   description            - Description of program.
--   executable_name        - Name of the registered executable.
--   executable_application - Name of the application under which the
--                            executable is registered.
--   execution_options      - Special options string for certain executables.
--   priority               - Program level priority. 1..99
--   save_output            - Save 'report' file? 'Y' or 'N'
--   print                  - 'Y' or 'N'
--   cols                   - Report columns (page width).
--   rows                   - Report rows (page length).
--   style                  - Print style name. (e.g. 'Landwide')
--   style_required         - Prevent style changes in SRS form. 'Y' or 'N'
--   printer                - Named printer cannot be changed in SRS form.
--   request_type           - User-defined request type
--   request_type_application - Application of request type.
--   use_in_srs             - Allow program to be submitted from SRS form
--                            'Y' or 'N'
--   allow_disabled_values  - Allow parameters based on outdated value sets
--                            to validate anyway.
--   run_alone              - Program must have the whole system to itself.
--                            'Y' or 'N'
--   output_type            - Type of output generated by the concurrent
--                            program. 'HTML', 'PS', 'PDF', 'TEXT', 'PCL',
--			      'XML'
--   enable_trace           - Enable SQL trace for this program.
--   restart                - Restart program if it was running during a
--                            general system failure.
--   nls_compliant          - Certifies NLS standards compliance.
--   icon_name              - Icon used in Web Interfaces. Not yet supported.
--   language_code          - Code for language of name and description.
--                            e.g. 'US'
--   mls_function_short_name- Name of the registered mls function
--   mls_function_application- Name of the application under which mls function
--				was registered
--   incrementor	    - Incrementor pl/sql function name
--   refresh_portlet        - Refresh Portlet based on the specified program
--                            outcome ('Never','On Success', 'Always',
--                                     'On Success or Warning')
--
PROCEDURE register(program                      IN VARCHAR2,
		    application  		IN VARCHAR2,
		    enabled     		IN VARCHAR2,
		    short_name  	        IN VARCHAR2,
		    description			IN VARCHAR2 DEFAULT NULL,
		    executable_short_name	IN VARCHAR2,
		    executable_application	IN VARCHAR2,
		    execution_options		IN VARCHAR2 DEFAULT NULL,
		    priority			IN NUMBER   DEFAULT NULL,
		    save_output			IN VARCHAR2 DEFAULT 'Y',
		    print			IN VARCHAR2 DEFAULT 'Y',
		    cols			IN NUMBER   DEFAULT NULL,
		    rows			IN NUMBER   DEFAULT NULL,
		    style			IN VARCHAR2 DEFAULT NULL,
		    style_required		IN VARCHAR2 DEFAULT 'N',
		    printer			IN VARCHAR2 DEFAULT NULL,
		    request_type		IN VARCHAR2 DEFAULT NULL,
		    request_type_application    IN VARCHAR2 DEFAULT NULL,
		    use_in_srs			IN VARCHAR2 DEFAULT 'N',
		    allow_disabled_values	IN VARCHAR2 DEFAULT 'N',
		    run_alone			IN VARCHAR2 DEFAULT 'N',
                    output_type                 IN VARCHAR2 DEFAULT 'TEXT',
                    enable_trace                IN VARCHAR2 DEFAULT 'N',
                    restart                     IN VARCHAR2 DEFAULT 'Y',
                    nls_compliant               IN VARCHAR2 DEFAULT 'Y',
                    icon_name                   IN VARCHAR2 DEFAULT NULL,
                    language_code               IN VARCHAR2 DEFAULT 'US',
		    mls_function_short_name	IN VARCHAR2 DEFAULT NULL,
		    mls_function_application    IN VARCHAR2 DEFAULT NULL,
                    incrementor			IN VARCHAR2 DEFAULT NULL,
                    refresh_portlet             IN VARCHAR2 DEFAULT NULL
		    )
  IS
     last_update_login fnd_flex_value_sets.last_update_login%TYPE
       := last_update_login_f;
     last_update_date fnd_flex_value_sets.last_update_date%TYPE
       := last_update_date_f;
     last_updated_by fnd_flex_value_sets.last_updated_by%TYPE
       := last_updated_by_f;
     creation_date fnd_flex_value_sets.creation_date%TYPE
       := creation_date_f;
     created_by fnd_flex_value_sets.created_by%TYPE
       := created_by_f;
     execution_method_code_i
       fnd_executables.execution_method_code%TYPE;
     argument_method_code_i
       fnd_concurrent_programs.argument_method_code%TYPE;
     srs_flag_i VARCHAR2(1);
     application_id_i fnd_application.application_id%TYPE;
     concurrent_program_id_i
       fnd_concurrent_programs.concurrent_program_id%TYPE;
     type_application_id_i fnd_application.application_id%TYPE;
     concurrent_class_id_i
       fnd_concurrent_request_class.request_class_id%TYPE;
     executable_application_id_i fnd_application.application_id%TYPE;
     executable_id_i fnd_executables.executable_id%TYPE;
     output_print_style_i fnd_printer_styles.printer_style_name%TYPE;
     swidth fnd_printer_styles.width%TYPE;
     slength fnd_printer_styles.length%TYPE;
     appl_short_name fnd_application.application_short_name%TYPE;
     mls_function_application_id_i fnd_application.application_id%TYPE;
     mls_function_exe_id_i fnd_executables.executable_id%TYPE;

     srs1_i VARCHAR2(1);
     srs2_i VARCHAR2(1);
     dummy  VARCHAR2(1);
     refresh_portlet_code VARCHAR2(1);
BEGIN
   message_init;
   println('creating concurrent program...');

   check_notnull(program);
   check_notnull(application);
   check_notnull(enabled);
   check_notnull(short_name);
   check_notnull(executable_short_name);
   check_notnull(executable_application);
   check_notnull(save_output);
   check_notnull(print);
   check_notnull(use_in_srs);
   check_notnull(allow_disabled_values);
   check_notnull(run_alone);
   check_notnull(enable_trace);
   check_notnull(restart);
   check_notnull(nls_compliant);

   check_yesno(enabled);
   check_yesno(save_output);
   check_yesno(print);
   check_yesno(style_required);
   check_yesno(run_alone);
   check_yesno(enable_trace);
   check_yesno(restart);
   check_yesno(nls_compliant);

   check_yesno(use_in_srs);
   check_yesno(allow_disabled_values);

   srs1_i := upper(use_in_srs);
   srs2_i := upper(allow_disabled_values);

   SELECT fnd_concurrent_programs_s.NEXTVAL       /* get next cp id */
     INTO concurrent_program_id_i
     FROM sys.dual;

   application_id_i := application_id_f(application);
   appl_short_name := application_short_name_f(application);

   executable_application_id_i :=
     application_id_f(executable_application);
   /* figure out the executable info */
   BEGIN
      SELECT executable_id, execution_method_code
	INTO executable_id_i, execution_method_code_i
	FROM fnd_executables
	WHERE application_id = executable_application_id_i
	AND fnd_executables.executable_name = executable_short_name;
   EXCEPTION
      WHEN no_data_found THEN
	 message('Invalid executable short name: '||executable_short_name);
	 message('Application: '||executable_application);
	 RAISE bad_parameter;
   END;
   IF (execution_method_code_i = 'A') THEN
      argument_method_code_i := 'D';
    ELSE
      argument_method_code_i := '4';
   END IF;

   /* set the srs flag */
   IF(srs1_i = 'Y') THEN
      IF(srs2_i = 'N') THEN
	 srs_flag_i := 'Y';
       ELSE
	 srs_flag_i := 'Q';
      END IF;
    ELSE
      IF(srs2_i = 'N') THEN
	 srs_flag_i := 'N';
       ELSE
	 message('Cannot "allow disabled values" for non-SRS programs.');
	 RAISE bad_parameter;
      END IF;
   END IF;

   IF(request_type IS NOT null) THEN
      type_application_id_i := application_id_f(request_type_application);
      BEGIN
	 SELECT request_class_id
	   INTO concurrent_class_id_i
	   FROM fnd_concurrent_request_class
	   WHERE application_id = type_application_id_i
	   AND request_class_name = request_type;
      EXCEPTION
	 WHEN no_data_found THEN
	    message('Invalid request_type: '||request_type);
	    RAISE bad_parameter;
      END;
   END IF;

   IF(output_type IS NOT null) THEN
     if (upper(output_type) not in ('PS', 'PDF', 'HTML', 'TEXT', 'PCL', 'XML')) then
       message('Output_Type must be ''PS'', ''PDF'', ''HTML'', ''TEXT'', ''PCL'', or ''XML''');
       RAISE bad_parameter;
     end if;
   END IF;

   /* printer style */
   IF(style IS NOT NULL) THEN
      BEGIN  /* First check developer key */
	 SELECT printer_style_name, width, length
	   INTO output_print_style_i, swidth, slength
	   FROM fnd_printer_styles
	   WHERE printer_style_name = style;
      EXCEPTION
	 WHEN no_data_found THEN  /* Check translated value */
           BEGIN
	     SELECT b.printer_style_name, b.width, b.length
	       INTO output_print_style_i, swidth, slength
	       FROM fnd_printer_styles_tl t,
                    fnd_printer_styles b
	       WHERE t.user_printer_style_name = style
                 AND rownum = 1
                 AND b.printer_style_name = t.printer_style_name;
           EXCEPTION
	     WHEN no_data_found THEN
	       message('Cannot find print style: '||style);
	       RAISE bad_parameter;
           END;
      END;

      IF ((output_print_style_i = 'DYNAMIC') and (cols is not null)) then
        message('Number of columns cannot be specified with DYNAMIC styles.');
        RAISE bad_parameter;
      END IF;

      IF (((cols is not null) and (swidth < cols)) or
          ((rows is not null) and (slength < rows))) then
        message('Style dimensions are less than program columns and rows.');
        RAISE bad_parameter;
      END IF;

   ELSIF(upper(style_required) = 'Y') THEN -- if no print style, can't require
       message('Cannot require a NULL print style.');
       RAISE bad_parameter;
   END IF;

   /* Check printer */
   if (printer is not null) then
     BEGIN
       select 'x' into dummy
         from sys.dual
         where printer in
             (select distinct printer_name
                from fnd_printer p
               where (output_print_style_i is not null
                      and p.printer_type in
                           (select i.printer_type
                              from fnd_printer_information i,
                                   fnd_printer_styles s
                             where i.printer_style = output_print_style_i
                               and s.printer_style_name = i.printer_style))
                   or (output_print_style_i is null
                       and p.printer_type in
                           (select i.printer_type
                              from fnd_printer_information i,
                                   fnd_printer_styles s
                             where i.printer_style = s.printer_style_name
                               and s.width >= nvl(cols, s.width)
                               and s.length >= nvl(rows, s.length))));
     EXCEPTION
       when no_data_found then
         message('Invalid or non-existent printer.');
         RAISE bad_parameter;
     END;
  end if;

   IF((output_print_style_i = 'DYNAMIC') AND
      (upper(style_required) <> 'Y')) THEN
      message('Style_required must be "Y" for DYNAMIC style: '||style);
      RAISE bad_parameter;
   END IF;
   IF((execution_method_code_i = 'P') AND
      (style IS NULL)) THEN
      message('A print style is required for the executable: ' ||
	      executable_short_name);
      RAISE bad_parameter;
   END IF;

   if ((execution_options is not null) and
       (execution_method_code_i not in ('R','P','X','H','L','K','E'))) then
     message ('Execution options are not allowed for this executable.');
     RAISE bad_parameter;
   end if;

   if ((mls_function_short_name is not null) and
	(mls_function_application is not null)) then
        mls_function_application_id_i :=
     		application_id_f(mls_function_application);
        /* figure out the executable info */
   	BEGIN
      	   SELECT executable_id
	     INTO mls_function_exe_id_i
	     FROM fnd_executables
	    WHERE application_id = mls_function_application_id_i
	      AND fnd_executables.executable_name = mls_function_short_name;
   	EXCEPTION
      	   WHEN no_data_found THEN
	     message('Invalid mls function short name: '||mls_function_short_name);
	     message('Application: '||mls_function_application);
	     RAISE bad_parameter;
        END;
   end if;

   if ( refresh_portlet is not null ) then

     BEGIN
       select lookup_code
         into refresh_portlet_code
         from fnd_lookup_values
         where upper(meaning) = upper(refresh_portlet)
           and lookup_type = 'CONC_REFRESH_PORTLET'
           and enabled_flag = 'Y'
           and rownum = 1;
     EXCEPTION
       WHEN no_data_found THEN
         message('Unknown Refresh Portlet value: ' || refresh_portlet);
         RAISE bad_parameter;
     END;

   end if;

   INSERT INTO fnd_concurrent_programs(
        application_id, concurrent_program_id, concurrent_program_name,
        last_update_date, last_updated_by,
        creation_date, created_by, last_update_login,
 	executable_application_id, executable_id, execution_method_code,
	argument_method_code, queue_control_flag, queue_method_code,
	request_set_flag, enabled_flag, print_flag,
	run_alone_flag, srs_flag,
	class_application_id, concurrent_class_id, execution_options,
	save_output_flag, required_style, output_print_style,
	printer_name, minimum_width, minimum_length,
	request_priority, output_file_type, enable_trace,
        restart, nls_compliant, icon_name,
        mls_executable_app_id, mls_executable_id, increment_proc,
	refresh_portlet)
     VALUES (application_id_i, concurrent_program_id_i, upper(short_name),
	     last_update_date, last_updated_by,
	     creation_date, created_by, last_update_login,
	     executable_application_id_i, executable_id_i,
	     execution_method_code_i,
	     argument_method_code_i, 'N', 'I',
	     'N', upper(enabled), upper(print),
	     upper(run_alone), srs_flag_i,
	     type_application_id_i, concurrent_class_id_i,
	     execution_options,
             upper(save_output), upper(style_required), output_print_style_i,
	     printer, cols, rows,
	     priority, output_type, enable_trace,
             restart, nls_compliant, null,
             mls_function_application_id_i, mls_function_exe_id_i, incrementor,
	     refresh_portlet_code);
   println('inserted into concurrent programs');

   --   insert rows for each installed language into the tl table */

   insert into FND_CONCURRENT_PROGRAMS_TL (
     APPLICATION_ID, CONCURRENT_PROGRAM_ID, USER_CONCURRENT_PROGRAM_NAME,
     CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
     LAST_UPDATED_BY, LAST_UPDATE_LOGIN, DESCRIPTION,
     LANGUAGE, SOURCE_LANG
   ) select
     application_id_i, concurrent_program_id_i, program,
     register.creation_date, register.created_by, register.last_update_date,
     register.last_updated_by, register.last_update_login,
     register.description,
     L.LANGUAGE_CODE,
     register.language_code
   from FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and not exists
     (select NULL
     from FND_CONCURRENT_PROGRAMS_TL T
     where T.APPLICATION_ID = application_id_i
     and T.CONCURRENT_PROGRAM_ID = concurrent_program_id_i
     and T.LANGUAGE = L.LANGUAGE_CODE);


   println('inserted into concurrent programs tl');

   -- create the flexfield now as well
   -- since we are not supporting changes is is cleaner to
   -- do it here, rather than in parameters.
   IF(srs_flag_i <> 'N') THEN
      println('creating a descriptive flexfield');

      fnd_flex_dsc_api.set_session_mode(session_mode=>who_mode);

      DECLARE
	 descriptive_flexfield_name
	   fnd_descriptive_flexs.descriptive_flexfield_name%TYPE;
	 title fnd_descriptive_flexs_vl.title%TYPE;
      BEGIN
	 descriptive_flexfield_name := '$SRS$.'||short_name;
	 title := '$SRS$.' || short_name;
	 fnd_flex_dsc_api.register(
	    appl_short_name => appl_short_name,
	    flexfield_name => descriptive_flexfield_name,
	    title => title,
	    description => NULL,
	    table_appl_short_name => 'FND',
	    table_name => 'FND_SRS_MASTER',
	    structure_column => 'STRUCTURE_COLUMN',
	    protected_flag => 'S');
	 fnd_flex_dsc_api.setup_context_field(
	    appl_short_name => appl_short_name,
	    flexfield_name => descriptive_flexfield_name,
	    segment_separator => ':',
	    prompt => 'Context Value',
	    default_value => NULL,
	    reference_field => NULL,
	    value_required => 'N',
	    override_allowed => 'N',
	    freeze_flexfield_definition =>  'Y');
      EXCEPTION
	 WHEN bad_parameter THEN
	    message(fnd_flex_dsc_api.message);
	    RAISE bad_parameter;
      END;
   END IF;
   println('created concurrent program:' || program);
END;



-- Procedure
--   Incompatibility
--
-- Purpose
--   Register a concurrent program incompatibility.
--
-- Arguments
--   program_short_name  - Short name of the first program. (e.g. FNDSCRMT)
--   application         - Application of the first program.
--                         (e.g. 'Application Object Library')
--   inc_prog_short_name - Short name of the incompatible program.
--   inc_prog_application- Application of the incompatible program.
--   scope               - 'Set' or 'Program Only'
--   inc_type            - Incompatibility type - (D)omain-specific or (G)lobal
--
PROCEDURE incompatibility(program_short_name    IN VARCHAR2,
			  application		IN VARCHAR2,
			  inc_prog_short_name   IN VARCHAR2,
			  inc_prog_application  IN VARCHAR2,
                          scope                 IN VARCHAR2 DEFAULT 'Set',
			  inc_type              IN VARCHAR2 DEFAULT 'D')
  IS
     last_update_login fnd_flex_value_sets.last_update_login%TYPE
       := last_update_login_f;
     last_update_date fnd_flex_value_sets.last_update_date%TYPE
       := last_update_date_f;
     last_updated_by fnd_flex_value_sets.last_updated_by%TYPE
       := last_updated_by_f;
     creation_date fnd_flex_value_sets.creation_date%TYPE
       := creation_date_f;
     created_by fnd_flex_value_sets.created_by%TYPE
       := created_by_f;
     application_id_i fnd_application.application_id%TYPE;
     concurrent_program_id_i
       fnd_concurrent_programs.concurrent_program_id%TYPE;
     to_run_concurrent_program_id_i
       fnd_concurrent_programs.concurrent_program_id%TYPE;
     to_run_application_id_i fnd_application.application_id%TYPE;
     scope_code_i fnd_concurrent_program_serial.to_run_type%TYPE;
BEGIN
   message_init;

   check_notnull(program_short_name);
   check_notnull(application);
   check_notnull(inc_prog_short_name);
   check_notnull(inc_prog_application);
   check_notnull(scope);
   check_notnull(inc_type);

   application_id_i := application_id_f(application);
   to_run_application_id_i :=
         application_id_f(inc_prog_application);
   BEGIN
      SELECT lookup_code
	INTO scope_code_i
	FROM fnd_lookup_values
	WHERE lookup_type = 'CP_SERIAL_TYPE'
	AND upper(meaning) = upper(scope)
        AND rownum = 1;
   EXCEPTION
      WHEN no_data_found THEN
	 message('Invalid scope: '||scope);
	 RAISE bad_parameter;
   END;

   concurrent_program_id_i :=
	concurrent_program_id_f(application_id_i, program_short_name);

   to_run_concurrent_program_id_i :=
	concurrent_program_id_f(to_run_application_id_i, inc_prog_short_name);

   IF inc_type <> 'D' AND inc_type <> 'G' THEN
      message('Invalid incompatibility type: ' ||inc_type);
      RAISE bad_parameter;
   END IF;

   /* update incompatibilies */
   UPDATE fnd_concurrent_programs SET
     queue_method_code = 'B'
     WHERE ((application_id = application_id_i
	     AND concurrent_program_id = concurrent_program_id_i)
	    OR (application_id = to_run_application_id_i
		AND concurrent_program_id = to_run_concurrent_program_id_i));


   INSERT INTO fnd_concurrent_program_serial(running_concurrent_program_id,
					     running_application_id,
					     running_type,
					     to_run_concurrent_program_id,
					     to_run_application_id,
					     to_run_type,
					     last_update_date,
					     last_updated_by,
					     creation_date,
					     created_by,
                                             last_update_login,
                                             incompatibility_type)
     VALUES(concurrent_program_id_i,
	    application_id_i,
	    scope_code_i,
	    to_run_concurrent_program_id_i,
	    to_run_application_id_i,
	    scope_code_i,
	    last_update_date,
	    last_updated_by,
	    creation_date,
	    created_by,
            last_update_login,
            inc_type);

   /* and do the other side as well */
   IF((concurrent_program_id_i <> to_run_concurrent_program_id_i)
      OR
      (application_id_i <> to_run_application_id_i)) THEN
      BEGIN
	 INSERT
	   INTO fnd_concurrent_program_serial(running_concurrent_program_id,
					      running_application_id,
					      running_type,
					      to_run_concurrent_program_id,
					      to_run_application_id,
					      to_run_type,
					      last_update_date,
					      last_updated_by,
					      creation_date,
					      created_by,
	                                      last_update_login,
					      incompatibility_type)
	   VALUES(to_run_concurrent_program_id_i,
		  to_run_application_id_i,
		  scope_code_i,
		  concurrent_program_id_i,
		  application_id_i,
		  scope_code_i,
		  last_update_date,
		  last_updated_by,
		  creation_date,
		  created_by,
	          last_update_login,
		  inc_type);
      END;
   END IF;

   println('created incompatibility entries for:'||
	   program_short_name || ' with:' ||
	   inc_prog_short_name);
END;



-- Procedure
--   EXECUTABLE
--
-- Purpose
--   Register a concurrent program executable.
--
-- Arguments
--   executable          - Name of executable.  (e.g. 'FNDSCRMT')
--   application         - Name of executable's application.
--                        (e.g. 'Application Object Library')
--   short_name          - Short (non-translated) name of the executable.
--   description         - Optional description of the executable.
--   execution method    - 'FlexRpt', 'FlexSQL', 'Host', 'Immediate',
--                         'Oracle Reports', 'PL/SQL Stored Procedure',
--                         'Spawned', 'SQL*Loader', 'SQL*Plus', 'SQL*Report',
--                         'Request Set Stage Function',
--			   'Multi Language Function','Java Stored Procedure'
--   execution_file_name - Required for all but 'Immediate' programs.
--                         Cannot contain spaces or periods.
--   subroutine_name     - Used only for 'Immediate' programs.
--                         Cannot contain spaces or periods.
--   icon_name           - For future web interface.
--   language_code       - Language code for the name and description.
--                         (e.g. 'US')
--   execution_file_path - Used only for 'Java Concurrent Program'
--                         It is the package path for the class
--
PROCEDURE executable(executable            	     IN VARCHAR2,
	             application	     	     IN VARCHAR2,
                     short_name                      IN VARCHAR2,
	             description                     IN VARCHAR2 DEFAULT NULL,
		     execution_method                IN VARCHAR2,
		     execution_file_name             IN VARCHAR2 DEFAULT NULL,
	             subroutine_name                 IN VARCHAR2 DEFAULT NULL,
                     icon_name                       IN VARCHAR2 DEFAULT NULL,
                     language_code                   IN VARCHAR2 DEFAULT 'US',
		     execution_file_path	     IN VARCHAR2 DEFAULT NULL) is
  application_id        number;
  execution_method_code varchar2(1);
  executable_id         number;
  last_update_date      fnd_executables.last_update_date%TYPE;
  last_updated_by       fnd_executables.last_updated_by%TYPE;
  creation_date         fnd_executables.creation_date%TYPE;
  created_by            fnd_executables.created_by%TYPE;
  last_update_login     fnd_executables.last_update_login%TYPE;
  row_id                fnd_executables_vl.row_id%type;

BEGIN
  message_init;

  check_notnull(executable);
  check_notnull(short_name);
  check_notnull(application);
  check_notnull(execution_method);

  last_update_date  := last_update_date_f;
  last_updated_by   := last_updated_by_f;
  creation_date     := creation_date_f;
  created_by        := created_by_f;
  last_update_login := last_update_login_f;
  application_id := application_id_f(application);
  BEGIN
    select lookup_code
      into execution_method_code
      from fnd_lookup_values
      where upper(meaning) = upper(execution_method)
        and lookup_type = 'CP_EXECUTION_METHOD_CODE'
        and enabled_flag = 'Y'
        and rownum = 1;
  EXCEPTION
    WHEN no_data_found THEN
      message('Unknown execution method: ' || execution_method);
      RAISE bad_parameter;
  END;

  if ((execution_method_code = 'S') and (subroutine_name is null)) then
    message('Subroutine name required for Immediate Concurrent Programs.');
    RAISE bad_parameter;
  elsif ((execution_method_code <> 'S') and
         (execution_file_name is null)) then
    message('Execution file name required.');
    RAISE bad_parameter;
  elsif ((subroutine_name is not null) and
         (execution_method_code not in ('A','S'))) then
    message('Subroutine name must be null for the selected execution method.');
    RAISE bad_parameter;
  end if;

  if ((execution_method_code = 'K') and (execution_file_path is null)) then
    message('Execution File Path is required for Java Concurrent Programs.');
    RAISE bad_parameter;
  elsif ((execution_method_code <> 'K')  and
         (execution_file_path is not null)) then
    message('Execution File Path not required for the selected execution method.');
    RAISE bad_parameter;
  end if;

  if ((instr(subroutine_name, ' ') > 0)
       or (instr(subroutine_name, '.') > 0)) then
    message('Subroutine name must not contain spaces or periods.');
    RAISE bad_parameter;
  end if;

  if ((instr(execution_file_name, ' ') > 0)
       or ((execution_method_code not in ('I', 'B', 'M', 'J', 'Z', 'E')) and
           (instr(execution_file_name, '.') > 0))) then
    message('Execution file name must not contain spaces or periods.');
    RAISE bad_parameter;
  end if;


  select fnd_executables_s.nextval into executable_id from sys.dual;

  insert into FND_EXECUTABLES (
    APPLICATION_ID, EXECUTABLE_ID, EXECUTABLE_NAME,
    EXECUTION_METHOD_CODE, EXECUTION_FILE_NAME, SUBROUTINE_NAME,
    CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_LOGIN, icon_name, execution_file_path
  ) values (
    application_id, executable_id, short_name,
    execution_method_code, execution_file_name, subroutine_name,
    creation_date, created_by, last_update_date,
    last_updated_by, last_update_login, icon_name, execution_file_path
  );

  insert into FND_EXECUTABLES_TL (
    APPLICATION_ID, EXECUTABLE_ID, CREATION_DATE,
    CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN, USER_EXECUTABLE_NAME, DESCRIPTION,
    LANGUAGE, SOURCE_LANG
  ) select
    application_id, executable_id, fnd_program.executable.creation_date,
    fnd_program.executable.created_by, fnd_program.executable.last_update_date,
    fnd_program.executable.last_updated_by,
    fnd_program.executable.last_update_login, executable,
    fnd_program.executable.description,
    l.language_code, fnd_program.executable.language_code
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B');

  println('created executable for:'|| executable);

END executable;



-- Procedure
--   REQUEST_GROUP
--
-- Purpose
--   Registers a request group.
--
-- Arguments
--   group               - Name of request group.
--   application         - Name of group's application.
--                        (e.g. 'Application Object Library')
--   code                - Optional group code.
--   description         - Optional description of the set.
PROCEDURE request_group(request_group	     	     IN VARCHAR2,
	                application	     	     IN VARCHAR2,
	                code 		     	     IN VARCHAR2 DEFAULT NULL,
	                description                  IN VARCHAR2 DEFAULT NULL) is
   last_update_login fnd_request_groups.last_update_login%TYPE
       := last_update_login_f;
   last_update_date fnd_request_groups.last_update_date%TYPE
       := last_update_date_f;
   last_updated_by fnd_request_groups.last_updated_by%TYPE
       := last_updated_by_f;
   creation_date fnd_request_groups.creation_date%TYPE
       := creation_date_f;
   created_by fnd_request_groups.created_by%TYPE
       := created_by_f;
   group_application_id fnd_application.application_id%TYPE;
BEGIN
   message_init;

   check_notnull(request_group);
   check_notnull(application);

   group_application_id := application_id_f(application);

   insert into fnd_request_groups
	(application_id,
	 request_group_id,
	 request_group_name,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         description,
         request_group_code)
    values
	(group_application_id,
         fnd_request_groups_s.nextval,
         request_group,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         description,
         code);
END;



-- Procedure
--   ADD_TO_GROUP
--
-- Purpose
--   Add a concurrent program to a request group.
--
-- Arguments
--   program_short_name  - Short name of the program. (e.g. FNDSCRMT)
--   program_application - Application of the program.
--                         (e.g. 'Application Object Library')
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
PROCEDURE add_to_group(program_short_name            IN VARCHAR2,
	               program_application	     IN VARCHAR2,
	               request_group                 IN VARCHAR2,
		       group_application             IN VARCHAR2) is
   last_update_login fnd_request_groups.last_update_login%TYPE
       := last_update_login_f;
   last_update_date fnd_request_groups.last_update_date%TYPE
       := last_update_date_f;
   last_updated_by fnd_request_groups.last_updated_by%TYPE
       := last_updated_by_f;
   creation_date fnd_request_groups.creation_date%TYPE
       := creation_date_f;
   created_by fnd_request_groups.created_by%TYPE
       := created_by_f;
   program_application_id
       fnd_application.application_id%TYPE;
   group_application_id
       fnd_application.application_id%TYPE;
   concurrent_program_id
       fnd_concurrent_programs.concurrent_program_id%TYPE;
   group_id
       fnd_request_groups.request_group_id%TYPE;
BEGIN
   message_init;

   check_notnull(program_short_name);
   check_notnull(program_application);
   check_notnull(request_group);
   check_notnull(group_application);

   program_application_id := application_id_f(program_application);
   group_application_id := application_id_f(group_application);

   concurrent_program_id :=
	concurrent_program_id_f(program_application_id, program_short_name);

   group_id := request_group_id_f(group_application_id, request_group);

   insert into Fnd_Request_Group_Units(APPLICATION_ID,
                                       REQUEST_GROUP_ID,
                                       REQUEST_UNIT_TYPE,
                                       UNIT_APPLICATION_ID,
                                       REQUEST_UNIT_ID,
                                       LAST_UPDATE_DATE,
 				       LAST_UPDATED_BY,
                                       CREATION_DATE,
                                       CREATED_BY,
                                       LAST_UPDATE_LOGIN)
			       values( group_application_id,
				       group_id,
				       'P',
				       program_application_id,
				       concurrent_program_id,
				       last_update_date,
				       last_updated_by,
				       creation_date,
                                       created_by,
                                       last_update_login);

   println('Added program '|| program_short_name || ' to group '
	||request_group);

END;



-- Procedure
--   REMOVE_FROM_GROUP
--
-- Purpose
--   Remove a concurrent program to a request group.
--
-- Arguments
--   program_short_name  - Short name of the program. (e.g. FNDSCRMT)
--   program_application - Application of the program.
--                         (e.g. 'Application Object Library')
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
PROCEDURE remove_from_group(program_short_name            IN VARCHAR2,
	                    program_application	          IN VARCHAR2,
	                    request_group                 IN VARCHAR2,
		            group_application             IN VARCHAR2) is
   program_application_id
       fnd_application.application_id%TYPE;
   group_application_id
       fnd_application.application_id%TYPE;
   concurrent_program_id
       fnd_concurrent_programs.concurrent_program_id%TYPE;
   group_id
       fnd_request_groups.request_group_id%TYPE;
BEGIN
   message_init;

   check_notnull(program_short_name);
   check_notnull(program_application);
   check_notnull(request_group);
   check_notnull(group_application);

   program_application_id := application_id_f(program_application);
   group_application_id := application_id_f(group_application);


   concurrent_program_id :=
	concurrent_program_id_f(program_application_id, program_short_name);

   group_id := request_group_id_f(group_application_id, request_group);

   delete from fnd_request_group_units u
    where application_id = group_application_id
      and request_group_id = group_id
      and request_unit_type = 'P'
      and unit_application_id = program_application_id
      and request_unit_id = concurrent_program_id;
END;



-- Procedure
--   DELETE_PROGRAM
--
-- Purpose
--   Delete a concurrent program.
--
-- Arguments
--   program_short_name  - Short name of the program. (e.g. FNDSCRMT)
--   application         - Application of the program.
--                         (e.g. 'Application Object Library')
--
PROCEDURE delete_program(program_short_name          IN VARCHAR2,
	         	 application	     	     IN VARCHAR2) is
  program_application_id fnd_application.application_id%TYPE;
  program_id fnd_concurrent_programs.concurrent_program_id%TYPE;
  desc_flex_name fnd_descriptive_flexs.descriptive_flexfield_name%TYPE;
  rs_flag fnd_concurrent_programs.request_set_flag%TYPE;
  set_id fnd_request_sets.request_set_id%TYPE;
  prog_appl_short_name fnd_application.application_short_name%TYPE;

  cursor req_cursor(appl_id number, prog_id number) is
    select request_id
      from fnd_concurrent_requests
     where concurrent_program_id = prog_id
       and program_application_id = appl_id;

BEGIN
  message_init;

  check_notnull(program_short_name);
  check_notnull(application);

  program_application_id := application_id_f(application);
  prog_appl_short_name := application_short_name_f(application);

  desc_flex_name := '$SRS$.'||program_short_name;

  BEGIN
     SELECT concurrent_program_id, request_set_flag
	INTO program_id, rs_flag
	FROM fnd_concurrent_programs
	WHERE application_id = program_application_id
	AND concurrent_program_name = program_short_name;
  EXCEPTION
      WHEN no_data_found THEN
	 println('Could not find program: '||program_short_name);
	 return;
  END;

  -- If the program is a request_set parent, then
  -- we delete the entire request set definition

  if (rs_flag = 'Y') then

    BEGIN

      SELECT request_set_id
      INTO set_id
      FROM fnd_request_sets
      WHERE application_id = program_application_id
      AND concurrent_program_id = program_id;

      -- Remove set from request groups

      DELETE FROM fnd_request_group_units
      WHERE request_unit_type = 'S'
      AND request_unit_id = set_id
      AND unit_application_id = program_application_id;

      -- Remove member program arguments

      DELETE FROM fnd_request_set_program_args
      WHERE application_id = program_application_id
      AND request_set_id = set_id;

      -- Remove member programs

      DELETE FROM fnd_request_set_programs
      WHERE set_application_id = program_application_id
      AND request_set_id = set_id;

      -- Remove the set

      DELETE FROM fnd_request_sets_tl
      WHERE application_id = program_application_id
      AND REQUEST_SET_ID = set_id;

      DELETE FROM fnd_request_sets
      WHERE application_id = program_application_id
      AND request_set_id = set_id;

    exception
      when NO_DATA_FOUND then
        null; -- The request set did not exist for
              -- some starnge reason.
              -- Just continue.
    end;
  else  -- Program is not a set

    -- Remove any request set program arguments if this program is
    -- a set member

    DELETE FROM fnd_request_set_program_args
    WHERE application_id = program_application_id
    AND request_set_program_id in
          (SELECT request_set_program_id
           FROM fnd_request_set_programs frsp
           WHERE frsp.program_application_id
		= delete_program.program_application_id
           AND concurrent_program_id = program_id);

    -- Remove the program from request sets

    DELETE FROM fnd_request_set_programs frs
    WHERE frs.program_application_id = delete_program.program_application_id
    AND concurrent_program_id = program_id;

    -- Remove the program from request groups

    DELETE fnd_request_group_units
    WHERE request_unit_type = 'P'
    AND request_unit_id = program_id
    AND unit_application_id = program_application_id;

  end if;

  -- Delete the program's incompatibilities

  DELETE fnd_concurrent_program_serial
  WHERE running_concurrent_program_id = program_id
  AND running_application_id = program_application_id;

  DELETE fnd_concurrent_program_serial
  WHERE to_run_concurrent_program_id = program_id
  AND to_run_application_id = program_application_id;

  -- Finally, delete the program
  DELETE fnd_concurrent_programs_tl
  WHERE application_id = program_application_id
  AND concurrent_program_id = program_id;

  DELETE fnd_concurrent_programs
  WHERE concurrent_program_id = program_id
  AND application_id = program_application_id;

  -- Delete flex.
  fnd_flex_dsc_api.delete_flexfield(
     appl_short_name => prog_appl_short_name,
     flexfield_name =>desc_flex_name);

  for req in req_cursor(program_application_id, program_id) loop
    delete from fnd_concurrent_requests
      where request_id = req.request_id;

    delete from fnd_run_requests
      where request_id = req.request_id;

    delete from fnd_conc_release_periods_tl
      where (application_id, concurrent_period_id) in
            (select application_id, concurrent_period_id
               from fnd_conc_release_periods
              where owner_req_id = req.request_id);

    delete from fnd_conc_release_periods
      where owner_req_id = req.request_id;

    delete from fnd_conc_release_states_tl
      where (application_id, concurrent_state_id) in
        (select application_id, concurrent_state_id
           from fnd_conc_release_states
          where owner_req_id = req.request_id);

    delete from fnd_conc_release_states
      where owner_req_id = req.request_id;

    delete from fnd_conc_release_classes_tl
      where (application_id, release_class_id) in
            (select application_id, release_class_id
               from fnd_conc_release_classes
              where owner_req_id = req.request_id);

    delete from fnd_conc_release_classes
      where owner_req_id = req.request_id;

    delete from fnd_conc_release_disjs_tl
      where (application_id, disjunction_id) in
            (select application_id, disjunction_id
               from fnd_conc_release_disjs
              where owner_req_id = req.request_id);

    delete from fnd_conc_release_disjs
      where owner_req_id = req.request_id;

    delete from fnd_conc_rel_disj_members
      where owner_req_id = req.request_id;

    delete from fnd_conc_rel_conj_members
      where owner_req_id = req.request_id;

    delete from fnd_conc_pp_actions
      where concurrent_request_id = req.request_id;

    delete from fnd_run_req_pp_actions
      where parent_request_id = req.request_id;

    delete from fnd_file_temp
      where request_id = req.request_id;

    /* in case parent was cancelled before running: */
    delete from fnd_run_requests
      where parent_request_id = req.request_id;

    delete from fnd_conc_request_arguments
      where request_id = req.request_id;
  end loop;

  println('Program '|| program_short_name || 'deleted.');

END delete_program;



-- Procedure
--   DELETE_PARAMETER
--
-- Purpose
--   Delete a concurrent program parameter.
--
-- Arguments
--   program_short_name  - Short name of the program. (e.g. FNDSCRMT)
--   application         - Application of the program.
--                         (e.g. 'Application Object Library')
--   parameter           - Parameter name.
PROCEDURE delete_parameter(program_short_name          IN VARCHAR2,
	                   application	     	       IN VARCHAR2,
                           parameter                   IN VARCHAR2) is

  program_appl_id
	fnd_application.application_id%TYPE;
  program_id
        fnd_concurrent_programs.concurrent_program_id%TYPE;
  desc_flex_name
	fnd_descriptive_flexs.descriptive_flexfield_name%TYPE;
  prog_appl_short_name fnd_application.application_short_name%TYPE;

BEGIN
  message_init;

  check_notnull(program_short_name);
  check_notnull(application);
  check_notnull(parameter);

  program_appl_id := application_id_f(application);
  prog_appl_short_name := application_short_name_f(application);

  desc_flex_name := '$SRS$.'||program_short_name;

  program_id := concurrent_program_id_f(program_appl_id, program_short_name);

  -- Delete param references in request sets
  delete from fnd_request_set_program_args a
   where (a.application_id, a.request_set_id, a.request_set_program_id)
         in (select sp.set_application_id,
                     sp.request_set_id,
                     sp.request_set_program_id
               from fnd_request_set_programs sp
               where sp.program_application_id = program_appl_id
                 and sp.concurrent_program_id = program_id)
     and (a.descriptive_flex_appl_id,
          a.descriptive_flexfield_name,
          a.application_column_name) in
         (select u.application_id,
                 u.descriptive_flexfield_name,
                 u.application_column_name
            from fnd_descr_flex_column_usages u
           where u.application_id = program_appl_id
             and u.descriptive_flexfield_name = desc_flex_name
             and u.descriptive_flex_context_code = 'Global Data Elements'
             and u.end_user_column_name = parameter);

   -- Delete the param
   fnd_flex_dsc_api.delete_segment(appl_short_name=> prog_appl_short_name,
				   flexfield_name=>desc_flex_name,
                                   context=>'Global Data Elements',
				   segment=>parameter);

END delete_parameter;



-- Procedure
--   DELETE_EXECUTABLE
--
-- Purpose
--   Delete a concurrent program executable.
--
-- Arguments
--   executable_short_name  - Name of the executable. (e.g. FNDSCRMT)
--   application - Application of the executable.
--                 (e.g. 'Application Object Library')
--
PROCEDURE delete_executable(executable_short_name          IN VARCHAR2,
	         	    application	         IN VARCHAR2) is
  exec_application_id
	fnd_application.application_id%TYPE;
  exec_id
        fnd_executables.executable_id%TYPE;
  dummy varchar2(1);

BEGIN
  message_init;

  check_notnull(executable_short_name);
  check_notnull(application);

  exec_application_id := application_id_f(application);

  BEGIN
     SELECT executable_id
	INTO exec_id
	FROM fnd_executables
	WHERE application_id = exec_application_id
	AND executable_name = executable_short_name;
  EXCEPTION
      WHEN no_data_found THEN
	 println('Could not find executable: '||executable_short_name);
	 return;
  END;

  -- Can't delete an executable if it is in use
  BEGIN
    select 'x' into dummy
      from sys.dual
     where not exists
       (select 1
          from fnd_concurrent_programs
         where executable_application_id = exec_application_id
           and executable_id = exec_id);
  EXCEPTION
    when no_data_found then
      message('Error - Executable is assigned to a concurrent program.');
      RAISE bad_parameter;
  END;

  delete from fnd_executables_tl
   where executable_id = exec_id
     and application_id = exec_application_id;

  delete from fnd_executables
   where executable_id = exec_id
     and application_id = exec_application_id;

END delete_executable;



-- Procedure
--   DELETE_GROUP
--
-- Purpose
--   Delete a request group.
--
-- Arguments
--   request_group - Name of the group. (e.g. FNDSCRMT)
--   application - Application of the executable.
--                 (e.g. 'Application Object Library')
--
PROCEDURE delete_group(request_group  IN VARCHAR2,
	               application    IN VARCHAR2) is
  group_application_id
	fnd_application.application_id%TYPE;
BEGIN
  message_init;

  check_notnull(request_group);
  check_notnull(application);

  group_application_id := application_id_f(application);

  delete from fnd_request_group_units
   where (request_group_id, application_id) in
         (select request_group_id, application_id
            from fnd_request_groups
           where request_group_name = request_group
             and application_id = group_application_id);

  delete from fnd_request_groups
   where request_group_name = request_group
     and application_id = group_application_id;

END delete_group;


-- Procedure
--   Delete_Incompatibility
--
-- Purpose
--   Delete a concurrent program incompatibility rule.
--
-- Arguments
--   program_short_name  - Short name of the first program. (e.g. FNDSCRMT)
--   application         - Application of the first program.
--                         (e.g. 'Application Object Library')
--   inc_prog_short_name - Short name of the incompatible program.
--   inc_prog_application- Application of the incompatible program.
--
PROCEDURE delete_incompatibility(program_short_name    IN VARCHAR2,
			  application		IN VARCHAR2,
			  inc_prog_short_name   IN VARCHAR2,
			  inc_prog_application  IN VARCHAR2)
  IS
     application_id_i fnd_application.application_id%TYPE;
     concurrent_program_id_i
       fnd_concurrent_programs.concurrent_program_id%TYPE;
     to_run_concurrent_program_id_i
       fnd_concurrent_programs.concurrent_program_id%TYPE;
     to_run_application_id_i fnd_application.application_id%TYPE;
     scope_code_i fnd_concurrent_program_serial.to_run_type%TYPE;
     dummy varchar2(1);
BEGIN
   message_init;

   check_notnull(program_short_name);
   check_notnull(application);
   check_notnull(inc_prog_short_name);
   check_notnull(inc_prog_application);

   application_id_i := application_id_f(application);
   to_run_application_id_i :=
         application_id_f(inc_prog_application);

   concurrent_program_id_i :=
	concurrent_program_id_f(application_id_i, program_short_name);

   to_run_concurrent_program_id_i :=
	concurrent_program_id_f(to_run_application_id_i, inc_prog_short_name);

   delete from fnd_concurrent_program_serial
     where to_run_application_id = to_run_application_id_i
       and to_run_concurrent_program_id = to_run_concurrent_program_id_i
       and running_application_id = application_id_i
       and running_concurrent_program_id = concurrent_program_id_i;

   delete from fnd_concurrent_program_serial
     where to_run_application_id = application_id_i
       and to_run_concurrent_program_id = concurrent_program_id_i
       and running_application_id = to_run_application_id_i
       and running_concurrent_program_id = to_run_concurrent_program_id_i;

   /* update incompatibilies */
   BEGIN
     update fnd_concurrent_programs
        set queue_method_code = 'I'
      WHERE application_id = application_id_i
	AND concurrent_program_id = concurrent_program_id_i
        AND NOT EXISTS
            (select 'x'
               from fnd_concurrent_program_serial
              where running_application_id = application_id_i
                and running_concurrent_program_id =
                    concurrent_program_id_i);
   EXCEPTION
     when no_data_found then null;
   END;

   BEGIN
     update fnd_concurrent_programs
        set queue_method_code = 'I'
      WHERE application_id = to_run_application_id_i
	AND concurrent_program_id = to_run_concurrent_program_id_i
        AND NOT EXISTS
            (select 'x'
               from fnd_concurrent_program_serial
              where running_application_id = to_run_application_id_i
                and running_concurrent_program_id =
                    to_run_concurrent_program_id_i);
   EXCEPTION
     when no_data_found then null;
   END;

END delete_incompatibility;


-- Procedure
--   enable_program
--
-- Purpose
--   enable or disable the concurrent program.
--
-- Arguments
--   program_short_name  - Short name of the program.
--   program_application - Application of the program.
--   enabled     	 - 'Y' or 'N' values.
--
PROCEDURE enable_program(short_name        IN VARCHAR2,
                         application       IN VARCHAR2,
                         enabled           IN VARCHAR2)
  IS

     last_update_login_p  fnd_flex_value_sets.last_update_login%TYPE
       := last_update_login_f;
     last_update_date_p   fnd_flex_value_sets.last_update_date%TYPE
       := last_update_date_f;
     last_updated_by_p   fnd_flex_value_sets.last_updated_by%TYPE
       := last_updated_by_f;
     creation_date fnd_flex_value_sets.creation_date%TYPE
       := creation_date_f;
     created_by fnd_flex_value_sets.created_by%TYPE
       := created_by_f;

        application_id_p fnd_application.application_id%TYPE;
        concurrent_program_id_p
	    fnd_concurrent_programs.concurrent_program_id%TYPE;
        temp_enabled_flag VARCHAR2(10);

BEGIN

   /* Check to ensure caller passed in all parameters */
   check_notnull(short_name);
   check_notnull(application);
   check_notnull(enabled);

   /* Check to ensure caller passed in Y or N for enabled */
   check_yesno(enabled);


   /* Get the application id based on the application code
      passed in */
   application_id_p := application_id_f(application);

   /* Make sure the concurrent program exists */
   BEGIN
    SELECT concurrent_program_id
      INTO concurrent_program_id_p
      FROM fnd_concurrent_programs
     WHERE application_id = application_id_p
       AND concurrent_program_name = upper(short_name);

    EXCEPTION
     when no_data_found THEN
        message('fnd_program.enable_program: Program Not Found');
        RAISE bad_parameter;
     when others then
        message('fnd_program.enable_program: '||SQLERRM);
        RETURN;
   END;

   /* Now go and update the concurrent program table */
   UPDATE fnd_concurrent_programs
   SET    enabled_flag = enabled,
          last_update_date = last_update_date_p,
          last_updated_by  = last_updated_by_p,
          last_update_login = last_update_login_p
   WHERE  application_id = application_id_p
   AND    concurrent_program_id = concurrent_program_id_p;

EXCEPTION
        when OTHERS then
            message('Error updating concurrent program');
            message(SQLERRM);
            return;

END enable_program;


-- Function
--   PROGRAM_EXISTS
--
-- Purpose
--   Return TRUE if a concurrent program exists.
--
-- Arguments
--   program     - Short name of the program.
--   application - Application short name of the program.
--
FUNCTION program_exists(program 	IN VARCHAR2,
			application	IN VARCHAR2) RETURN BOOLEAN is
  program_application_id fnd_application.application_id%TYPE;
  program_id fnd_concurrent_programs.concurrent_program_id%TYPE;
BEGIN
  message_init;

  program_application_id := application_id_f(application);
  program_id := concurrent_program_id_f(program_application_id, program);

  return TRUE;

EXCEPTION
  when others then
    return FALSE;
END program_exists;




-- Function
--   PARAMETER_EXISTS
--
-- Purpose
--   Return TRUE if a program parameter exists.
--
-- Arguments
--   program_short_name - Short name of program.
--   application        - Application short name of the program.
--   parameter          - Name of the parameter.
--
FUNCTION parameter_exists(program_short_name IN VARCHAR2,
			  application        IN VARCHAR2,
			  parameter	     IN VARCHAR2) RETURN BOOLEAN is

  program_appl_id      fnd_application.application_id%TYPE;
  program_id           fnd_concurrent_programs.concurrent_program_id%TYPE;
  desc_flex_name       fnd_descriptive_flexs.descriptive_flexfield_name%TYPE;
  prog_appl_short_name fnd_application.application_short_name%TYPE;
  dummy                varchar2(1);

BEGIN
  message_init;

  program_appl_id := application_id_f(application);

  desc_flex_name := '$SRS$.'||program_short_name;


  select 'y'
    into dummy
    from fnd_descr_flex_column_usages
    where application_id = program_appl_id
      and descriptive_flexfield_name = desc_flex_name
      and descriptive_flex_context_code = 'Global Data Elements'
      and end_user_column_name = parameter;

  return TRUE;

EXCEPTION
  when others then
    return FALSE;
END parameter_exists;




-- Function
--   INCOMPATIBILITY_EXISTS
--
-- Purpose
--   Return TRUE if a program incompatibility exists.
--
-- Arguments
--   program_short_name  - Short name of the first program.
--   application         - Application short name of the first program.
--   inc_prog_short_name - Short name of the incompatible program.
--   inc_prog_application- Application short name of the incompatible program.
--
FUNCTION incompatibility_exists(program_short_name         IN VARCHAR2,
			  	application     	    IN VARCHAR2,
			  	inc_prog_short_name  	    IN VARCHAR2,
			  	inc_prog_application        IN VARCHAR2)
				RETURN BOOLEAN is

     application_id_i        fnd_application.application_id%TYPE;
     concurrent_program_id_i fnd_concurrent_programs.concurrent_program_id%TYPE;
     to_run_concurrent_program_id_i
                             fnd_concurrent_programs.concurrent_program_id%TYPE;
     to_run_application_id_i fnd_application.application_id%TYPE;
     scope_code_i            fnd_concurrent_program_serial.to_run_type%TYPE;
     dummy                   varchar2(1);

BEGIN
   message_init;

   application_id_i := application_id_f(application);
   to_run_application_id_i := application_id_f(inc_prog_application);

   concurrent_program_id_i :=
	concurrent_program_id_f(application_id_i, program_short_name);

   to_run_concurrent_program_id_i :=
	concurrent_program_id_f(to_run_application_id_i, inc_prog_short_name);

   select 'Y'
     into dummy
     from fnd_concurrent_program_serial
     where to_run_application_id = to_run_application_id_i
       and to_run_concurrent_program_id = to_run_concurrent_program_id_i
       and running_application_id = application_id_i
       and running_concurrent_program_id = concurrent_program_id_i;

   return TRUE;

EXCEPTION
  when others then
    return FALSE;
END incompatibility_exists;




-- Function
--   EXECUTABLE_EXISTS
--
-- Purpose
--   Return TRUE if a program executable exists.
--
-- Arguments
--   executable_short_name  - Short name of the executable.
--   application - Application short name of the executable.
--
FUNCTION executable_exists(executable_short_name        IN VARCHAR2,
	         	   application	     IN VARCHAR2) RETURN BOOLEAN is

  exec_application_id fnd_application.application_id%TYPE;
  dummy               varchar2(1);

BEGIN
  message_init;

  exec_application_id := application_id_f(application);

  select 'y'
    into dummy
    from fnd_executables
   where application_id = exec_application_id
     and executable_name = executable_short_name;

  return TRUE;

EXCEPTION
   when others then
     return FALSE;
END executable_exists;




-- Function
--   REQUEST_GROUP_EXISTS
--
-- Purpose
--   Return TRUE if a request group exists.
--
-- Arguments
--   group       - Name of the group.
--   application - Application short name of the executable.
--
FUNCTION request_group_exists(request_group  IN VARCHAR2,
	              application    IN VARCHAR2) RETURN BOOLEAN is

  group_application_id fnd_application.application_id%TYPE;
  dummy                varchar2(1);

BEGIN
  message_init;

  group_application_id := application_id_f(application);

  select 'y'
    into dummy
    from fnd_request_groups
   where request_group_name = request_group
     and application_id = group_application_id;

  return TRUE;

EXCEPTION
  when others then
    return FALSE;
END request_group_exists;




-- Function
--   PROGRAM_IN_GROUP
--
-- Purpose
--   Returns true if a program is in a request group.
--
-- Arguments
--   program_short_name  - Short name of the program.
--   program_application - Application of the program.
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
FUNCTION program_in_group(program_short_name	IN VARCHAR2,
	                  program_application	IN VARCHAR2,
	                  request_group         IN VARCHAR2,
		          group_application     IN VARCHAR2) RETURN BOOLEAN is

   program_application_id  fnd_application.application_id%TYPE;
   group_application_id    fnd_application.application_id%TYPE;
   concurrent_program_id   fnd_concurrent_programs.concurrent_program_id%TYPE;
   group_id                fnd_request_groups.request_group_id%TYPE;
   dummy                   varchar2(1);

BEGIN
  message_init;

  program_application_id := application_id_f(program_application);
  group_application_id := application_id_f(group_application);

  concurrent_program_id :=
	concurrent_program_id_f(program_application_id, program_short_name);

  group_id := request_group_id_f(group_application_id, request_group);

  select 'y'
    into dummy
    from fnd_request_group_units u
   where application_id = group_application_id
     and request_group_id = group_id
     and request_unit_type = 'P'
     and unit_application_id = program_application_id
     and request_unit_id = concurrent_program_id;

  return TRUE;

EXCEPTION
  when others then
    return FALSE;
END program_in_group;

-- Procedure
--   ADD_APPLICATION_TO_GROUP
--
-- Purpose
--   Add a applicaiton to a request group.
--
-- Arguments
--   application_name - Application of the program.
--                         (e.g. 'Application Object Library')
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
PROCEDURE add_application_to_group(
		       application_name 	     IN VARCHAR2,
	               request_group                 IN VARCHAR2,
		       group_application             IN VARCHAR2) is
   last_update_login fnd_request_groups.last_update_login%TYPE
       := last_update_login_f;
   last_update_date fnd_request_groups.last_update_date%TYPE
       := last_update_date_f;
   last_updated_by fnd_request_groups.last_updated_by%TYPE
       := last_updated_by_f;
   creation_date fnd_request_groups.creation_date%TYPE
       := creation_date_f;
   created_by fnd_request_groups.created_by%TYPE
       := created_by_f;
   application_id
       fnd_application.application_id%TYPE;
   group_application_id
       fnd_application.application_id%TYPE;
   group_id
       fnd_request_groups.request_group_id%TYPE;
BEGIN
   message_init;

   check_notnull(application_name);
   check_notnull(request_group);
   check_notnull(group_application);

   application_id := application_id_f(application_name);
   group_application_id := application_id_f(group_application);


   group_id := request_group_id_f(group_application_id, request_group);

   insert into Fnd_Request_Group_Units(APPLICATION_ID,
                                       REQUEST_GROUP_ID,
                                       REQUEST_UNIT_TYPE,
                                       UNIT_APPLICATION_ID,
                                       REQUEST_UNIT_ID,
                                       LAST_UPDATE_DATE,
 				       LAST_UPDATED_BY,
                                       CREATION_DATE,
                                       CREATED_BY,
                                       LAST_UPDATE_LOGIN)
			       values( group_application_id,
				       group_id,
				       'A',
				       application_id,
				       application_id,
				       last_update_date,
				       last_updated_by,
				       creation_date,
                                       created_by,
                                       last_update_login);

   println('Added Application '|| application_name || ' to group '
	||request_group);

END;

-- Procedure
--   REMOVE_APPLICATION_FROM_GROUP
--
-- Purpose
--   Remove a application from a request group.
--
-- Arguments
--   application_name - Application of the program.
--                         (e.g. 'Application Object Library')
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
PROCEDURE remove_application_from_group(
			    application_name	          IN VARCHAR2,
	                    request_group                 IN VARCHAR2,
		            group_application             IN VARCHAR2) is
   application_id
       fnd_application.application_id%TYPE;
   group_application_id
       fnd_application.application_id%TYPE;
   group_id
       fnd_request_groups.request_group_id%TYPE;
BEGIN
   message_init;

   check_notnull(application_name);
   check_notnull(request_group);
   check_notnull(group_application);

   application_id := application_id_f(application_name);
   group_application_id := application_id_f(group_application);


   group_id := request_group_id_f(group_application_id, request_group);

   delete from fnd_request_group_units u
    where application_id = group_application_id
      and request_group_id = group_id
      and request_unit_type = 'A'
      and request_unit_id = application_id;
END;


-- Function
--   APPLICATION_IN_GROUP
--
-- Purpose
--   Returns true if a program is in a request group.
--
-- Arguments
--   application_name    - Application of the program.
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
FUNCTION application_in_group(application_name	IN VARCHAR2,
	                  request_group         IN VARCHAR2,
		          group_application     IN VARCHAR2) RETURN BOOLEAN is

   application_id  	   fnd_application.application_id%TYPE;
   group_application_id    fnd_application.application_id%TYPE;
   group_id                fnd_request_groups.request_group_id%TYPE;
   dummy                   varchar2(1);

BEGIN
  message_init;

  application_id := application_id_f(application_name);
  group_application_id := application_id_f(group_application);

  group_id := request_group_id_f(group_application_id, request_group);

  select 'y'
    into dummy
    from fnd_request_group_units u
   where application_id = group_application_id
     and request_group_id = group_id
     and request_unit_type = 'A'
     and request_unit_id = application_id;

  return TRUE;

EXCEPTION
  when others then
    return FALSE;
END application_in_group;

-- Function
--   PROGRAM_IS_MLS
--
-- Purpose
--   Returns NTRUE (1) if the program, uniquely identified by the program name
--   and the program application short name, has a valid mls function
--   otherwise returns NFALSE (0).
--
-- Arguments
--   program_short_name  - Short name of the program.
--   program_application - Application short name of the program.
--
FUNCTION program_is_mls(program_short_name	IN VARCHAR2,
	                  program_application	IN VARCHAR2) RETURN NUMBER is

   program_application_id  fnd_application.application_id%TYPE;
   retval    number;

BEGIN
  message_init;

  program_application_id := application_id_f(program_application);

  select NTRUE
    into retval
    from fnd_concurrent_programs FCP, fnd_executables FE
   where FCP.concurrent_program_name = program_short_name
     and FCP.application_id = program_application_id
     and FCP.mls_executable_app_id is not null
     and FCP.mls_executable_id is not null
     and FE.application_id = FCP.mls_executable_app_id
     and FE.executable_id = FCP.mls_executable_id;

  return retval;

EXCEPTION
  when others then
    return NFALSE;
END program_is_mls;




-- Procedure
--   SET_SHELF_LIFE
--
-- Purpose
--   Set shelf_life for a single program
--
-- Arguments
--   program_application - Application of the program
--   program_short_name  - Concurrent program short name
--   shelf_life          - New shelf_life value
--
PROCEDURE set_shelf_life(program_application IN VARCHAR2,
                         program_short_name  IN VARCHAR2,
                         shelf_life          IN NUMBER) is

   program_application_id  fnd_application.application_id%TYPE;
   concurrent_program_id   fnd_concurrent_programs.concurrent_program_id%TYPE;

BEGIN

  program_application_id := application_id_f(program_application);
  concurrent_program_id :=
	concurrent_program_id_f(program_application_id, program_short_name);

  set_shelf_life(program_application_id, concurrent_program_id, shelf_life);

END set_shelf_life;



-- Procedure
--   SET_SHELF_LIFE
--
-- Purpose
--   Set shelf_life for a single program
--
-- Arguments
--   program_application_id - Application id of the program
--   concurrent_program_id  - Concurrent program id
--   shelf_life             - New shelf_life value
--
PROCEDURE set_shelf_life(program_application_id IN NUMBER,
                         concurrent_program_id  IN NUMBER,
                         shelf_life             IN NUMBER) is

BEGIN

  update fnd_conc_prog_onsite_info
    set shelf_life = set_shelf_life.shelf_life,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
    where program_application_id = set_shelf_life.program_application_id
    and concurrent_program_id = set_shelf_life.concurrent_program_id;


END set_shelf_life;



-- Procedure
--   SET_SHELF_LIFE
--
-- Purpose
--   Set shelf_life for a list of programs
--
-- Arguments
--   program_application_id - Application id of the program
--   programs               - List of concurrent program ids
--                            Pass an empty program_list to update all programs
--                            belonging to the application
--   shelf_life             - New shelf_life value
--
PROCEDURE set_shelf_life(program_application_id IN NUMBER,
                         programs               IN program_list,
                         shelf_life             IN NUMBER) is

  user_id  number := fnd_global.user_id;
  login_id number := fnd_global.login_id;
BEGIN

  -- If program_list is empty, update all programs belonging to the application
  if programs.COUNT = 0 then

    update fnd_conc_prog_onsite_info
      set shelf_life = set_shelf_life.shelf_life,
        last_update_date = sysdate,
        last_updated_by = user_id,
        last_update_login = login_id
      where program_application_id = set_shelf_life.program_application_id;

  else

    forall i in programs.FIRST .. programs.LAST
      update fnd_conc_prog_onsite_info
      set shelf_life = set_shelf_life.shelf_life,
        last_update_date = sysdate,
        last_updated_by = user_id,
        last_update_login = login_id
      where program_application_id = set_shelf_life.program_application_id
      and concurrent_program_id = programs(i);

  end if;


END set_shelf_life;



-- Procedure
--   SET_ALL_SHELF_LIFE
--
-- Purpose
--   Set shelf_life for all programs that currently have a certain
--   shelf_life value
--
-- Arguments
--   current_value - Current shelf_life value
--                   Can be NULL to update all programs that currently
--                   have a NULL shelf_life
--   new_value     - New shelf_life value
--
PROCEDURE set_all_shelf_life(current_value  IN NUMBER,
                             new_value      IN NUMBER) is

  user_id  number := fnd_global.user_id;
  login_id number := fnd_global.login_id;
BEGIN

    if current_value is null then
      update fnd_conc_prog_onsite_info
      set shelf_life = new_value,
        last_update_date = sysdate,
        last_updated_by = user_id,
        last_update_login = login_id
      where shelf_life is null;

    else
      update fnd_conc_prog_onsite_info
        set shelf_life = new_value,
        last_update_date = sysdate,
        last_updated_by = user_id,
        last_update_login = login_id
        where shelf_life = current_value;
    end if;

END set_all_shelf_life;



-- Procedure
--   SET_ALL_SHELF_LIFE
--
-- Purpose
--   Set shelf_life for all programs
--
-- Arguments
--   new_value     - New shelf_life value
--
PROCEDURE set_all_shelf_life(new_value      IN NUMBER) is

BEGIN

      update fnd_conc_prog_onsite_info
        set shelf_life = new_value,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id;


END set_all_shelf_life;


/* END_PUBLIC */

END fnd_program;			/* end package */

/
