--------------------------------------------------------
--  DDL for Package Body FND_SET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SET" AS
/* $Header: AFRSSETB.pls 120.6.12010000.3 2017/10/20 15:56:44 ckclark ship $ */


/* START_PUBLIC */
bad_parameter EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_parameter, -06501); -- program error
/* END_PUBLIC */

who_mode VARCHAR2(20) := 'customer_data';  /* customer_data or seed_data */


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

PROCEDURE print(msg IN VARCHAR2) IS
BEGIN
   IF(debug_mode_on) THEN
      --dbms_output.enable;
      --dbms_output.put(msg);
      null;
   END IF;
END;

PROCEDURE println IS
BEGIN
   IF(debug_mode_on) THEN
      --dbms_output.enable;
      --dbms_output.put_line('');
      null;
   END IF;
END;

PROCEDURE println(msg IN VARCHAR2) IS
BEGIN
   IF(debug_mode_on) THEN
      --dbms_output.enable;
      --dbms_output.put_line(msg);
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

   SELECT application_id
     INTO application_id_ret
     FROM fnd_application
     WHERE application_short_name = application_name_in;
   RETURN application_id_ret;
EXCEPTION
   when NO_DATA_FOUND then
      message('Invalid application name: ' || application_name_in);
      RAISE bad_parameter;
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


/* Get a request set ID given appl ID and set short name */
FUNCTION request_set_id_f(set_application_id number,
			  request_set varchar2) return number is
  set_id fnd_request_sets.request_set_id%TYPE;
BEGIN
  SELECT request_set_id
    INTO set_id
    FROM fnd_request_sets
   WHERE application_id = set_application_id
     AND request_set_name = request_set;

  RETURN set_id;

EXCEPTION
  WHEN no_data_found THEN
    message('Could not find set: '||request_set);
    RAISE bad_parameter;
END;


/* Get a request set stage ID given appl ID, set ID, and
   stage number */
FUNCTION request_set_stage_id_f(set_appl_id number,
			        set_id      varchar2,
                                stage       varchar2) return number is
  stage_id fnd_request_set_stages.request_set_stage_id%TYPE;
BEGIN
  SELECT request_set_stage_id
    INTO stage_id
    FROM fnd_request_set_stages
   WHERE set_application_id = set_appl_id
     AND request_set_id = set_id
     AND stage = stage_name;

  RETURN stage_id;

EXCEPTION
  WHEN no_data_found THEN
    message('Could not find stage: '||stage);
    RAISE bad_parameter;
END;


/* Get a request set stage function ID given appl ID, function_name */
FUNCTION function_id_f(fn_appl_id number,
                                name       varchar2) return number is
  fn_id fnd_executables.executable_id%TYPE;
BEGIN
  SELECT executable_id
    INTO fn_id
    FROM fnd_executables
   WHERE application_id = fn_appl_id
     AND executable_name = name;

  RETURN fn_id;

EXCEPTION
  WHEN no_data_found THEN
    message('Could not find function: '||name);
    RAISE bad_parameter;
END;


/* Get a stage function parameter ID given appl ID, function_id, param name */
FUNCTION parameter_id_f(fn_appl_id number,
                        fn_id      number,
                        name       varchar2) return number is
  param_id fnd_stage_fn_parameters_vl.parameter_id%TYPE;
BEGIN
  SELECT parameter_id
    INTO param_id
    FROM fnd_stage_fn_parameters_vl
   WHERE application_id = fn_appl_id
     AND function_id = fn_id
     AND parameter_name = name;

  RETURN param_id;

EXCEPTION
  WHEN no_data_found THEN
    message('Could not find parameter: '||name);
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



-- Function
--   CREATE_PROGRAM
--
-- Purpose
--   Create a concurrent program for a Request Set or Stage
--   that can have incompatibilities.
--   This logic is mostly copied from the form FNDRSSET.fmb.
--
-- Arguments
--   request_set         - Name of set
--   set_application_id  - Appl ID of set
--   set_id              - ID of set
--   stage_id            - ID of request set stage
--   stage_number        - Stage number.
--   description         - Description of set
--   lang                - language code
--
FUNCTION create_program(request_set        in varchar2,
                        set_application_id in number,
                        set_id             in number DEFAULT NULL,
                        stage_id           in number DEFAULT NULL,
                        stage_name         in VARCHAR2 DEFAULT NULL,
                        description        in varchar2,
                        lang               in varchar2,
                        set_short_name     in varchar2 DEFAULT NULL,
                        stage_short_name   in varchar2 DEFAULT NULL)
                        return number is
   ra fnd_concurrent_programs.run_alone_flag%TYPE;
   srs fnd_concurrent_programs.srs_flag%TYPE;
   enabled fnd_concurrent_programs.enabled_flag%TYPE;
   qc fnd_concurrent_programs.queue_control_flag%TYPE;
   qmc fnd_concurrent_programs.queue_method_code%TYPE;
   amc fnd_concurrent_programs.argument_method_code%TYPE;
   so fnd_concurrent_programs.save_output_flag%TYPE;
   print fnd_concurrent_programs.print_flag%TYPE;
   rs fnd_concurrent_programs.required_style%TYPE;
   printer fnd_concurrent_programs.printer_name%TYPE;
   style fnd_concurrent_programs.output_print_style%TYPE;
   eo fnd_concurrent_programs.execution_options%TYPE;
   ex_app_id  fnd_concurrent_programs.executable_application_id%TYPE;
   ex_id fnd_concurrent_programs.executable_id%TYPE;
   cl_app_id fnd_concurrent_programs.class_application_id%TYPE;
   cl_id fnd_concurrent_programs.concurrent_class_id%TYPE;

   last_update_login fnd_concurrent_programs.last_update_login%TYPE
     := last_update_login_f;
   last_update_date fnd_concurrent_programs.last_update_date%TYPE
     := last_update_date_f;
   last_updated_by fnd_concurrent_programs.last_updated_by%TYPE
     := last_updated_by_f;
   creation_date fnd_concurrent_programs.creation_date%TYPE
     := creation_date_f;
   created_by fnd_concurrent_programs.created_by%TYPE
     := created_by_f;
   program_id fnd_concurrent_programs.concurrent_program_id%TYPE;
   request_set_text varchar2(256);

   program_name varchar2(10);
   user_program_name varchar2(240);
   new_name     varchar2(30);
BEGIN
   -- insert into fnd concurrent programs.
   -- get id first


   select fnd_concurrent_programs_s.nextval
		into program_id
   from sys.dual;

   if (stage_id is not null) then
     fnd_message.set_name('FND', 'SRS-Request Set Stage');
     request_set_text := fnd_message.get;
     program_name := 'FNDRSSTG';
     user_program_name := substr(request_set_text||' '||stage_name, 1, 240);
     fnd_message.set_name('FND', 'SRS-Report Set');
     request_set_text := fnd_message.get;
     user_program_name := substr(user_program_name||' -  '||request_set_text
                                 ||' '||request_set, 1, 240);
     new_name := stage_short_name;
   else
     fnd_message.set_name('FND', 'SRS-Report Set');
     request_set_text := fnd_message.get;
     program_name := 'FNDRSSUB';
     user_program_name := substr(request_set_text||' '||request_set, 1, 240);
     new_name := set_short_name;
   end if;

   begin
     select argument_method_code, queue_control_flag, queue_method_code,
         run_alone_flag, enabled_flag, srs_flag,
         print_flag, output_print_style, required_style, execution_options,
         class_application_id, concurrent_class_id,
         executable_application_id, executable_id,
         save_output_flag, printer_name
     into  amc, qc, qmc, ra, enabled, srs, print, style, rs, eo,
         cl_app_id, cl_id, ex_app_id, ex_id, so, printer
     from fnd_concurrent_programs
     where  application_id = 0
     and    concurrent_program_name = program_name;
   exception
     when no_data_found then
       message('Could not find program '||program_name||' for copy!');
       raise program_error;
   END;

   insert into fnd_concurrent_programs
    (application_id, concurrent_program_id, concurrent_program_name,
     last_update_date, last_updated_by, execution_method_code,
     queue_method_code, argument_method_code, queue_control_flag,
     run_alone_flag, enabled_flag,
     print_flag, output_print_style, required_style, execution_options,
     class_application_id, concurrent_class_id, srs_flag,
     created_by, creation_date, last_update_login,
     executable_application_id, executable_id, save_output_flag,
     printer_name, request_set_flag, restart, nls_compliant, enable_trace,
     output_file_type)
   values( set_application_id, program_id,
       new_name, last_update_date, last_updated_by,
       'I', qmc, 'D', qc, ra, enabled, print, style, rs, eo,
       cl_app_id, cl_id, srs,
       created_by, creation_date, last_update_login,
       ex_app_id, ex_id, so, printer, 'Y', 'Y', 'N', 'N', 'TEXT');


   --
   -- Insert into TL table
   --
   insert into fnd_concurrent_programs_tl
    (application_id,
     concurrent_program_id,
     last_update_date,
     last_updated_by,
     description,
     user_concurrent_program_name,
     created_by,
     creation_date,
     last_update_login,
     language,
     source_lang
     )
     select
       set_application_id,
       program_id,
       create_program.last_update_date,
       create_program.last_updated_by,
       create_program.description,
       user_program_name,
       create_program.created_by,
       create_program.creation_date,
       create_program.last_update_login,
       l.language_code,
       lang
         from fnd_languages l
        where l.installed_flag in ('I', 'B');

   return program_id;

END create_program;


--
-- Return the ID of the "incompatibility" program for a set or stage
--
function get_prog_id(set_appl_id number, set_id number, stage_id number)
							  return number  is
  prog_id number;
begin
   /* Get a concurrent program ID from the source set/stage */
   if (stage_id is not null) then  /* source is STAGE */
     select concurrent_program_id
       into prog_id
       from fnd_request_set_stages
      where set_application_id = set_appl_id
        and request_set_id = set_id
        and request_set_stage_id = stage_id;

     if (prog_id is null) then
       message('Stage is not configured for incompatibilities.');
       RAISE bad_parameter;
     end if;

   else   /* source is SET */
      select concurrent_program_id
        into prog_id
        from fnd_request_sets
       where application_id = set_appl_id
         and request_set_id = set_id;

      if (prog_id is null) then
        message('Set is not configured for incompatibilities.');
        RAISE bad_parameter;
      end if;
   end if;

   return (prog_id);
end;

/* ------------------------------------------------------------ */
/* ------------------------------------------------------------ */

/* START_PUBLIC */




-- Procedure
--   Incompatibility
--
-- Purpose
--   Register an incompatibility for a set or stage.
--
--   Examples:
--     1. Set X is incompatible with program Y
--        fnd_set.incompatibility(request_set=>'X',
--                                application=>'APPX',
--                                inc_prog=>'Y',
--                                inc_prog_application=>'APPY');
--
--     2. Set X is incompatible withset Y.
--        fnd_set.incompatibility(request_set=>'X',
--                                application=>'APPX',
--                                inc_request_set=>'Y',
--                                inc_set_application=>'APPY');
--
--     3. Set X is incompatible with stage Y of set Y.
--        fnd_set.incompatibility(request_set=>'X',
--                                application=>'APPX',
--                                inc_request_set=>'Y',
--                                inc_set_application=>'APPY',
--                                inc_stage=>'Y');
--
--     4. Stage X of set X is incompatable with program Y.
--        fnd_set.incompatibility(request_set=>'X',
--                                application=>'APPX',
--                                stage=>'X',
--                                inc_prog=>'Y',
--                                inc_prog_application=>'APPY');
--
--
-- Arguments
--   request_set         - Request set short name.
--   application         - Application short name of request set.
--   stage               - Stage short name (for stage incompatibility).
--   inc_prog            - Short name of the incompatible program.
--   inc_prog_application- Application of the incompatible program.
--   inc_request_set     - Sort name of the incompatible reuqest set.
--   inc_set_application - Applicaiton short name of the incompatible set.
--   inc_stage           - Stage short name to the incompatible stage.
--   inc_type            - Incompatibility type - (D)omain-specific or (G)lobal
--
PROCEDURE incompatibility(request_set              IN VARCHAR2,
		  	  application   	   IN VARCHAR2,
                          stage                    IN VARCHAR2 DEFAULT NULL,
			  inc_prog                 IN VARCHAR2 DEFAULT NULL,
			  inc_prog_application     IN VARCHAR2 DEFAULT NULL,
                          inc_request_set          IN VARCHAR2 DEFAULT NULL,
                          inc_set_application      IN VARCHAR2 DEFAULT NULL,
                          inc_stage                IN VARCHAR2 DEFAULT NULL,
			  inc_type                 IN VARCHAR2 DEFAULT 'D')
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
     set_id number;
     stage_id number;
BEGIN
   message_init;

   check_notnull(request_set);
   check_notnull(application);
   check_notnull(inc_type);

   IF inc_type <> 'D' AND inc_type <> 'G' THEN
      message('Invalid incompatibility type: ' ||inc_type);
      RAISE bad_parameter;
   END IF;

   -- Get ID of first program
   application_id_i := application_id_f(application);
   set_id := request_set_id_f(application_id_i, request_set);
   if (stage is not null) then
     stage_id := request_set_stage_id_f(application_id_i, set_id,
                                        stage);
   else
     stage_id := null;
   end if;
   concurrent_program_id_i := get_prog_id(application_id_i, set_id, stage_id);


   -- Get ID of second program
   if (inc_prog_application is not null) then  /* incompatible PROGRAM */
     to_run_application_id_i :=
           application_id_f(inc_prog_application);
     to_run_concurrent_program_id_i :=
	concurrent_program_id_f(to_run_application_id_i, inc_prog);
   else  /* incompatible SET or STAGE */
     to_run_application_id_i :=
           application_id_f(inc_set_application);
     set_id := request_set_id_f(to_run_application_id_i, inc_request_set);
     if (inc_stage is not null) then
       stage_id := request_set_stage_id_f(to_run_application_id_i, set_id,
                                          inc_stage);
     else
       stage_id := null;
     end if;
     to_run_concurrent_program_id_i := get_prog_id(to_run_application_id_i,
                                                   set_id, stage_id);
   end if;


   /* update program definitions */
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
	    'S',
	    to_run_concurrent_program_id_i,
	    to_run_application_id_i,
	    'S',
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
		  'S',
		  concurrent_program_id_i,
		  application_id_i,
		  'S',
		  last_update_date,
		  last_updated_by,
		  creation_date,
		  created_by,
	          last_update_login,
		  inc_type);
      END;
   END IF;

   println('created incompatibility entries.');
END;




-- Procedure
--   CREATE_SET
--
-- Purpose
--   Register a request set.
--
-- Arguments
--   name                - Name of request set.
--   short_name          - Short name.  Dev key.
--   application         - Short name of set's application.
--   description         - Optional description of the set.
--   owner               - Optional user ID of set owner. (e.g. SYSADMIN)
--   start_date          - Date set becomes effective.
--   end_date            - Optional date set becomes outdated.
--   print_together      - 'Y' or 'N'
--   incompatibilities_allowed - 'Y' or 'N'
--   language_code       - Language code for the above data. (e.g. US)
--
PROCEDURE create_set(  name                          IN VARCHAR2,
                       short_name                    IN VARCHAR2,
	      	       application	     	     IN VARCHAR2,
	               description                   IN VARCHAR2 DEFAULT NULL,
	               owner 	                     IN VARCHAR2 DEFAULT NULL,
	               start_date                    IN DATE   DEFAULT SYSDATE,
	               end_date                      IN DATE     DEFAULT NULL,
	               print_together                IN VARCHAR2 DEFAULT 'N',
                       incompatibilities_allowed     IN VARCHAR2 DEFAULT 'N',
                       recalc_parameters             IN VARCHAR2 DEFAULT 'N',
		       language_code                 IN VARCHAR2 DEFAULT 'US')
is
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
   set_appl_id fnd_application.application_id%TYPE;
   set_id fnd_request_sets.request_set_id%TYPE;
   owner_id fnd_user.user_id%TYPE;
   program_id fnd_concurrent_programs.concurrent_program_id%TYPE;

BEGIN
   message_init;

   check_notnull(application);
   check_notnull(name);
   check_notnull(short_name);
   check_notnull(start_date);
   check_notnull(print_together);
   check_notnull(incompatibilities_allowed);

   check_yesno(print_together);
   check_yesno(incompatibilities_allowed);


   set_appl_id := application_id_f(application);

   select fnd_request_sets_s.nextval into set_id from sys.dual;

   if (owner is not null) then
     BEGIN
       select user_id
         into owner_id
         from fnd_user
        where user_name = owner;
     EXCEPTION
       when no_data_found then
         message('Could not find user '||owner);
         raise bad_parameter;
     END;
   end if;

   program_id := NULL;

   if (upper(incompatibilities_allowed) = 'Y') then
     program_id := create_program(request_set=>name,
                                  set_application_id=>set_appl_id,
				  set_id=>set_id,
                                  description=>description,
                                  lang=>language_code,
                                  set_short_name => short_name);
   end if;

   insert into fnd_request_sets
     (application_id, request_set_id, request_set_name,
      last_update_date, last_updated_by, creation_date,
      created_by, last_update_login,
      allow_constraints_flag, print_together_flag, recalc_parameters,
      start_date_active, end_date_active,
      concurrent_program_id, owner)
   values
     (set_appl_id, set_id, short_name,
      last_update_date, last_updated_by, creation_date,
      created_by, last_update_login,
      upper(incompatibilities_allowed), upper(print_together),
upper(recalc_parameters),
      start_date, end_date, program_id, owner_id);

  --   insert rows for each installed language into the tl table
  insert into FND_REQUEST_SETS_TL (
    application_id, request_set_id, creation_date,
    created_by, last_update_date, last_updated_by,
    last_update_login, user_request_set_name, description,
    language, source_lang
  ) select
    set_appl_id, set_id, create_set.creation_date,
    create_set.created_by, create_set.last_update_date,
    create_set.last_updated_by,
    create_set.last_update_login,
    create_set.name, create_set.description,
    L.LANGUAGE_CODE,
    create_set.language_code
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B');

   println('Request set '|| name ||' created.');

END create_set;



-- Procedure
--   ADD_STAGE
--
-- Purpose
--   Add a stage to a request set.
--
-- Arguments
--   name                 - Stage name.
--   request_set          - Short name of request set.
--   set_application      - Application short name of the request_set.
--   short_name           - Stage short (non-translated) name.
--   description          - Stage description.
--   display_sequence     - Display sequence.
--   function_short_name  - Funciton (executable) short name.
--   function_application - Function application short name.
--   critical             - Is this a "critical" stage?  (Determines set outcome.)
--   incompatibilities_allowed - 'Y' or 'N'
--   start_stage          - Is this the start stage for the set? 'Y' or 'N'
--   language_code        - Language code for the above data. (e.g. US)
--
PROCEDURE add_stage(name                          IN VARCHAR2,
	            request_set                     IN VARCHAR2,
	            set_application	              IN VARCHAR2,
                    short_name                    IN VARCHAR2,
                    description                   IN VARCHAR2 DEFAULT NULL,
                    display_sequence              IN NUMBER,
                    function_short_name           IN VARCHAR2
							DEFAULT 'FNDRSSTE',
                    function_application          IN VARCHAR2 DEFAULT 'FND',
                    critical                      IN VARCHAR2 DEFAULT 'N',
                    incompatibilities_allowed     IN VARCHAR2 DEFAULT 'N',
                    start_stage                   IN VARCHAR2 DEFAULT 'N',
                    language_code                 IN VARCHAR2 DEFAULT 'US'
                    )
is
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
   set_appl_id fnd_application.application_id%TYPE;
   set_id fnd_request_sets.request_set_id%TYPE;
   print_style_name fnd_printer_styles.printer_style_name%TYPE;
   stage_id fnd_request_set_stages_tl.request_set_stage_id%TYPE;
   dummy varchar2(1);
   program_id fnd_concurrent_programs.concurrent_program_id%TYPE;
   outcome_meaning varchar2(1);
   function_id number := null;
   function_appl_id number := null;
   set_name varchar2(240);

BEGIN
   message_init;

   check_notnull(name);
   check_notnull(short_name);
   check_notnull(request_set);
   check_notnull(set_application);
   check_notnull(critical);
   check_notnull(incompatibilities_allowed);

   check_yesno(critical);
   check_yesno(incompatibilities_allowed);

   if (function_short_name is not null) then
     function_appl_id := application_id_f(function_application);
     begin
       select executable_id
         into function_id
         from fnd_executables
        where application_id = function_appl_id
          and executable_name = function_short_name;
     exception
       when no_data_found then
         message('Invalid function short name:'||function_short_name);
         raise bad_parameter;
     end;
   end if;

   set_appl_id := application_id_f(set_application);
   set_id := request_set_id_f(set_appl_id, request_set);

   select fnd_request_set_stages_s.nextval
     into stage_id
     from sys.dual;

   if (upper(incompatibilities_allowed) = 'Y') then
     select user_request_set_name
       into set_name
       from fnd_request_sets_vl
      where request_set_id = set_id
        and application_id = set_appl_id;

     program_id := create_program(request_set=>set_name,
                                  set_application_id=>set_appl_id,
                                  stage_id=>stage_id,
                                  stage_name=>name,
                                  description=>description,
                                  lang=>language_code,
                                  stage_short_name => short_name);
   else
     program_id := null;
   end if;

   insert into fnd_request_set_stages
     (set_application_id, request_set_id, request_set_stage_id,
      stage_name,
      last_update_date, last_updated_by, creation_date,
      created_by, last_update_login,
      allow_constraints_flag,
      concurrent_program_id, critical, outcome,
      function_id, function_application_id,
      display_sequence)
   values
     (set_appl_id, set_id, stage_id, short_name,
      last_update_date, last_updated_by, creation_date,
      created_by, last_update_login,
      upper(incompatibilities_allowed),
      program_id,
      upper(critical), 'C', function_id, function_appl_id,
      display_sequence);

   --   insert rows for each installed language into the tl table
  insert into FND_REQUEST_SET_STAGES_TL (
    set_application_id, request_set_id, request_set_stage_id,
    creation_date, created_by, last_update_date,
    last_updated_by, last_update_login, user_stage_name,
    description, language, source_lang
  ) select
    set_appl_id, set_id, stage_id,
    add_stage.creation_date, add_stage.created_by,
    add_stage.last_update_date,
    add_stage.last_updated_by, add_stage.last_update_login, name,
    add_stage.description, l.language_code, add_stage.language_code
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B');

  println('Added stage ' || name ||
	' to set ' || request_set || '.');

  if (start_stage = 'Y') then
   update fnd_request_sets
      set start_stage = stage_id
    where request_set_id = set_id
      and application_id = set_appl_id;
  end if;

END add_stage;


-- Procedure
--   Link_Stages
--
-- Purpose
--   Link Two Stages.
--
-- Arguments
--   request_set         - Short name of request set.
--   set_application     - Application of the request set.
--   from_stage          - From stage short name.
--   to_stage            - To stage short name. (null to erase a link)
--   success             - Create success link. 'Y' or 'N'
--   warning             - Create warning link. 'Y' or 'N'
--   error               - Create error link. 'Y' or 'N'
--
procedure link_stages (request_set varchar2,
                       set_application varchar2,
                       from_stage varchar2,
                       to_stage varchar2 default null,
                       success varchar2 default 'N',
                       warning varchar2 default 'N',
                       error varchar2 default 'N')
is
   last_update_login fnd_request_groups.last_update_login%TYPE
       := last_update_login_f;
   last_update_date fnd_request_groups.last_update_date%TYPE
       := last_update_date_f;
   last_updated_by fnd_request_groups.last_updated_by%TYPE
       := last_updated_by_f;
   set_appl_id fnd_application.application_id%TYPE;
   set_id fnd_request_sets.request_set_id%TYPE;
   from_stage_id fnd_request_set_stages_tl.request_set_stage_id%TYPE;
   to_stage_id fnd_request_set_stages_tl.request_set_stage_id%TYPE;
   dummy varchar2(1);
BEGIN
   message_init;

   check_notnull(request_set);
   check_notnull(set_application);
   check_notnull(from_stage);

   set_appl_id := application_id_f(set_application);
   set_id := request_set_id_f(set_appl_id, request_set);
   from_stage_id := request_set_stage_id_f(set_appl_id, set_id, from_stage);

   if (to_stage is not null) then
     to_stage_id := request_set_stage_id_f(set_appl_id, set_id, to_stage);
   else
     to_stage_id := null;
   end if;

   if (success = 'Y') then
     update fnd_request_set_stages
        set success_link = to_stage_id
      where set_application_id = set_appl_id
        and request_set_id = set_id
        and request_set_stage_id = from_stage_id;
   end if;

   if (warning = 'Y') then
     update fnd_request_set_stages
        set warning_link = to_stage_id
      where set_application_id = set_appl_id
        and request_set_id = set_id
        and request_set_stage_id = from_stage_id;
   end if;

   if (error = 'Y') then
     update fnd_request_set_stages
        set error_link = to_stage_id
      where set_application_id = set_appl_id
        and request_set_id = set_id
        and request_set_stage_id = from_stage_id;
   end if;
end;


-- Procedure
--   ADD_PROGRAM
--
-- Purpose
--   Add a concurrent program to a request set stage.
--
-- Arguments
--   program             - Short name of the program. (e.g. FNDSCRMT)
--   program_application - Application short name of the program.(e.g. 'FND')
--   request_set         - Short name of request set.
--   set_application     - Application of the request set.
--   stage               - Short name of stage.
--   program_sequence    - Must be unique!
--   critical            - Use this program in stage outcome?
--   number_of_copies    - Copies to Print. (optional)
--   save_output         - 'Y' or 'N'
--   style               - Print style name. (optional)
--   printer             - Printer name. (optional)
--
PROCEDURE add_program(program                      IN VARCHAR2,
	             program_application	   IN VARCHAR2,
	             request_set                   IN VARCHAR2,
	             set_application               IN VARCHAR2,
                     stage                         IN VARCHAR2,
                     program_sequence              IN NUMBER,
                     critical                      IN VARCHAR2,
                     number_of_copies              IN NUMBER   DEFAULT 0,
                     save_output                   IN VARCHAR2 DEFAULT 'Y',
                     style                         IN VARCHAR2 DEFAULT NULL,
                     printer                       IN VARCHAR2 DEFAULT NULL) is
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
   set_appl_id fnd_application.application_id%TYPE;
   program_appl_id fnd_application.application_id%TYPE;
   set_id fnd_request_sets.request_set_id%TYPE;
   stage_id fnd_request_set_stages.request_set_stage_id%TYPE;
   program_id fnd_concurrent_programs.concurrent_program_id%TYPE;
   print_style_name fnd_printer_styles.printer_style_name%TYPE;
   dummy varchar2(1);
BEGIN
  message_init;

  check_notnull(program);
  check_notnull(program_application);
  check_notnull(set_application);
  check_notnull(program_sequence);
  check_notnull(stage);
  check_notnull(critical);

  check_yesno(critical);

  program_appl_id := application_id_f(program_application);
  set_appl_id := application_id_f(set_application);

  if (style is not null) then
    BEGIN  /* First check developer key */
      SELECT printer_style_name
        INTO print_style_name
	FROM fnd_printer_styles
       WHERE printer_style_name = style;
    EXCEPTION
      WHEN no_data_found THEN  /* Check translated value */
        BEGIN
	  SELECT printer_style_name
	    INTO print_style_name
	    FROM fnd_printer_styles_tl
	    WHERE user_printer_style_name = style
              AND rownum = 1;
        EXCEPTION
	  WHEN no_data_found THEN
	    message('Cannot find print style: '||style);
	    RAISE bad_parameter;
        END;
    END;
  end if;

  if (printer is not null) then
    BEGIN
      select 'x'
        into dummy
        from fnd_printer
       where printer_name = printer;
    EXCEPTION
      when no_data_found then
        message('Cannot find printer : '|| printer);
        raise bad_parameter;
    END;
  end if;

  program_id :=
	concurrent_program_id_f(program_appl_id, program);
  set_id := request_set_id_f(set_appl_id, request_set);
  stage_id := request_set_stage_id_f(set_appl_id, set_id, stage);

  insert into fnd_request_set_programs
    (set_application_id, request_set_id, request_set_program_id,
     request_set_stage_id,
     sequence, last_update_date, last_updated_by,
     creation_date, created_by, last_update_login,
     program_application_id, concurrent_program_id,
     number_of_copies, save_output_flag,
     printer, print_style, critical)
  values
    (set_appl_id, set_id, fnd_request_set_programs_s.nextval,
     stage_id,
     program_sequence, last_update_date, last_updated_by,
     creation_date, created_by, last_update_login,
     program_appl_id, program_id,
     number_of_copies, save_output,
     printer, print_style_name, upper(add_program.critical));

  println('Added program ' || program ||
	' to set ' || request_set || '.');

END add_program;



-- Procedure
--   REMOVE_STAGE
--
-- Purpose
--   Remove a stage from a request set.
--
-- Arguments
--   request_set         - Short name of request set.
--   set_application     - Application short name of the request set.
--   stage               - Stage short name
--
PROCEDURE remove_stage(request_set                 IN VARCHAR2,
		       set_application             IN VARCHAR2,
                       stage                       IN VARCHAR2)
is
   set_appl_id fnd_application.application_id%TYPE;
   set_id fnd_request_sets.request_set_id%TYPE;
   stage_id fnd_request_set_stages.request_set_stage_id%TYPE;
   program_short_name fnd_concurrent_programs.concurrent_program_name%TYPE;
BEGIN
  message_init;

  check_notnull(set_application);
  check_notnull(request_set);
  check_notnull(stage);

  set_appl_id := application_id_f(set_application);
  set_id := request_set_id_f(set_appl_id, request_set);
  stage_id := request_set_stage_id_f(set_appl_id, set_id, stage);

  -- Delete program args
  delete from fnd_request_set_program_args
   where (application_id, request_set_id, request_set_program_id) in
         (select p.set_application_id, p.request_set_id,
		 p.request_set_program_id
            from fnd_request_set_programs p
           where p.set_application_id = set_appl_id
             and p.request_set_id = set_id
             and p.request_set_stage_id = stage_id);

  -- Delete member programs
  delete from fnd_request_set_programs
   where set_application_id = set_appl_id
     and request_set_id = set_id
     and request_set_stage_id = stage_id;

  -- Delete stage program (if any)
  begin
    select concurrent_program_name
      into program_short_name
      from fnd_concurrent_programs p,
           fnd_request_set_stages r
     where r.set_application_id = set_appl_id
       and r.request_set_id = set_id
       and r.request_set_stage_id = stage_id
       and r.set_application_id = p.application_id
       and r.concurrent_program_id = p.concurrent_program_id;

     fnd_program.delete_program(program_short_name, set_application);
  exception
    when others then
      message_init;
      null;  -- We don't care if the program does not exist
  end;

  -- Delete fn params
  delete from fnd_stage_fn_parameter_values
   where set_application_id = set_appl_id
     and request_set_id = set_id
     and request_set_stage_id = stage_id;

  -- Delete translations
  delete from fnd_request_set_stages_tl
   where set_application_id = set_appl_id
     and request_set_id  = set_id
     and request_set_stage_id = stage_id;

  -- Delete stage
  delete from fnd_request_set_stages
   where set_application_id = set_appl_id
     and request_set_id  = set_id
     and request_set_stage_id = stage_id;

  -- Update links
  update fnd_request_set_stages
     set success_link = null
   where set_application_id = set_appl_id
     and request_set_id  = set_id
     and success_link = stage_id;

  update fnd_request_set_stages
     set warning_link = null
   where set_application_id = set_appl_id
     and request_set_id  = set_id
     and warning_link = stage_id;

  update fnd_request_set_stages
     set error_link = null
   where set_application_id = set_appl_id
     and request_set_id  = set_id
     and error_link = stage_id;

END remove_stage;



-- Procedure
--   REMOVE_PROGRAM
--
-- Purpose
--   Remove a concurrent program from a request set.
--
-- Arguments
--   program             - Short name of the program. (e.g. FNDSCRMT)
--   program_application - Application of the program. (e.g. 'FND')
--   request_set         - Short name of request set.
--   set_application     - Application short name of the request set.
--   stage      r        - Stage short name.
--   program_sequence    - Program sequence number.
--
PROCEDURE remove_program(program                      IN VARCHAR2,
	                  program_application         IN VARCHAR2,
	                  request_set                 IN VARCHAR2,
		          set_application             IN VARCHAR2,
                          stage                       IN VARCHAR2,
                          program_sequence            IN NUMBER)
is
   set_appl_id fnd_application.application_id%TYPE;
   program_appl_id fnd_application.application_id%TYPE;
   set_id fnd_request_sets.request_set_id%TYPE;
   stage_id fnd_request_set_stages.request_set_stage_id%TYPE;
   program_id fnd_concurrent_programs.concurrent_program_id%TYPE;
BEGIN
  message_init;

  check_notnull(program);
  check_notnull(program_application);
  check_notnull(set_application);
  check_notnull(program_sequence);
  check_notnull(stage);
  check_notnull(request_set);

  program_appl_id := application_id_f(program_application);
  set_appl_id := application_id_f(set_application);
  program_id :=
	concurrent_program_id_f(program_appl_id, program);
  set_id := request_set_id_f(set_appl_id, request_set);
  stage_id := request_set_stage_id_f(set_appl_id, set_id, stage);

  delete from fnd_request_set_program_args
   where (application_id, request_set_id, request_set_program_id) in
         (select p.set_application_id, p.request_set_id,
		 p.request_set_program_id
            from fnd_request_set_programs p
           where p.set_application_id = set_appl_id
             and p.request_set_id = set_id
             and p.program_application_id = program_appl_id
             and p.concurrent_program_id = program_id
             and p.request_set_stage_id = stage_id
             and p.sequence = program_sequence);

  delete from fnd_request_set_programs
   where set_application_id = set_appl_id
     and request_set_id = set_id
     and program_application_id = program_appl_id
     and concurrent_program_id = program_id
     and request_set_stage_id = stage_id
     and sequence = program_sequence;

END remove_program;



-- Procedure
--   PROGRAM_PARAMETER
--
-- Purpose
--   Register a parameter for a request set program
--
-- Arguments:
--   program            - e.g. FNDSCRMT
--   application        - Program application. e.g.'FND'
--   request_set        - Short name of request set.
--   set_application    - Application short name of the request set.
--   stage              - Stage short name.
--   program_sequence   - Program sequence number.
--   parameter          - Name of the program parameter.  (NOT the prompt!)
--   display            - 'Y' or 'N'
--   modify             - 'Y' or 'N'
--   shared_parameter   - Name of shared parameter. (optional)
--   default_type       - 'Constant', 'Profile', 'SQL Statement', 'Segment'
--                        (Optional)
--   default_value      - Parameter default (Required if default_type is not
--                        Null)
--
PROCEDURE program_parameter(
	program                       IN VARCHAR2,
	program_application           IN VARCHAR2,
	request_set                   IN VARCHAR2,
	set_application               IN VARCHAR2,
        stage                         IN VARCHAR2,
        program_sequence              IN NUMBER,
	parameter                     IN VARCHAR2,
	display                       IN VARCHAR2 DEFAULT 'Y',
	modify                        IN VARCHAR2 DEFAULT 'Y',
	shared_parameter              IN VARCHAR2 DEFAULT NULL,
	default_type                  IN VARCHAR2 DEFAULT NULL,
	default_value                 IN VARCHAR2 DEFAULT NULL) is
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
   set_appl_id fnd_application.application_id%TYPE;
   program_appl_id fnd_application.application_id%TYPE;
   set_id fnd_request_sets.request_set_id%TYPE;
   stage_id fnd_request_set_stages.request_set_stage_id%TYPE;
   program_id fnd_concurrent_programs.concurrent_program_id%TYPE;
   default_type_code fnd_request_set_program_args.default_type%TYPE;
   set_program_id fnd_request_set_programs.request_set_program_id%TYPE;
   appl_column_name
	fnd_descr_flex_column_usages.application_column_name%TYPE;

BEGIN
  message_init;

  check_notnull(program);
  check_notnull(program_application);
  check_notnull(set_application);
  check_notnull(program_sequence);
  check_notnull(stage);
  check_notnull(parameter);
  check_notnull(display);
  check_notnull(modify);

  check_yesno(display);
  check_yesno(modify);


  program_appl_id := application_id_f(program_application);
  set_appl_id := application_id_f(set_application);
  program_id :=
	concurrent_program_id_f(program_appl_id, program);
  set_id := request_set_id_f(set_appl_id, request_set);
  stage_id := request_set_stage_id_f(set_appl_id, set_id, stage);

  BEGIN
    select request_set_program_id
      into set_program_id
      from fnd_request_set_programs
     where request_set_id = set_id
       and set_application_id = set_appl_id
       and concurrent_program_id = program_id
       and program_application_id = program_appl_id
       and request_set_stage_id = stage_id
       and sequence = program_sequence;
  EXCEPTION
    when no_data_found then

      message('Could not find program ' || program ||
              ' in set ' || request_set);
      raise bad_parameter;
  END;

  -- validate default type name
  BEGIN
     if(default_type is not null) then
	select lookup_code
	  into default_type_code
	  from fnd_lookup_values l
	  where l.lookup_type = 'FLEX_DEFAULT_TYPE'
	  and l.enabled_flag = 'Y'
	  and sysdate between nvl(l.start_date_active, Sysdate)
	  and nvl(l.end_date_active, Sysdate)
	  and upper(meaning) = upper(default_type)
          and rownum = 1;
     end if;
  EXCEPTION
     when no_data_found then
	message('bad default type:' || default_type);
	raise bad_parameter;
  END;

  BEGIN
    select application_column_name
      into appl_column_name
      from fnd_descr_flex_column_usages
     where descriptive_flexfield_name = '$SRS$.'||program
       and descriptive_flex_context_code = 'Global Data Elements'
       and end_user_column_name = parameter
       and application_id = program_appl_id;
  EXCEPTION
     when no_data_found then
	message('Could not find paramter' || parameter ||
                ' for program ' || program);
	raise bad_parameter;
  END;


  if((default_type is null) and (default_value is not null)) then
     message('default type required when default value specified');
     raise bad_parameter;
  end if;

  insert into fnd_request_set_program_args
    (application_id, request_set_id, request_set_program_id,
     descriptive_flex_appl_id, descriptive_flexfield_name,
     application_column_name, last_update_date, last_updated_by,
     creation_date, created_by, last_update_login, display_flag,
     insert_flag, update_flag, default_type, default_value,
     shared_parameter_name)
  values
    (set_appl_id, set_id, set_program_id,
     program_appl_id, '$SRS$.'||program,
     appl_column_name, last_update_date, last_updated_by,
     creation_date, created_by, last_update_login, upper(display),
     upper(modify), upper(modify), default_type_code, default_value,
     shared_parameter);

END program_parameter;



-- Procedure
--   ADD_SET_TO_GROUP
--
-- Purpose
--   Add a request set to a request group.
--
-- Arguments
--   request_set         - Short name of set.
--   set_application     - Application short name of the set.
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
PROCEDURE add_set_to_group(request_set             IN VARCHAR2,
	                   set_application	   IN VARCHAR2,
	                   request_group           IN VARCHAR2,
		           group_application       IN VARCHAR2)
is
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
   set_application_id
       fnd_application.application_id%TYPE;
   group_application_id
       fnd_application.application_id%TYPE;
   set_id
       fnd_request_sets.request_set_id%TYPE;
   group_id
       fnd_request_groups.request_group_id%TYPE;
BEGIN
   message_init;

   check_notnull(set_application);
   check_notnull(request_set);
   check_notnull(request_group);
   check_notnull(group_application);

   set_application_id := application_id_f(set_application);
   group_application_id := application_id_f(group_application);

   set_id := request_set_id_f(set_application_id, request_set);
   group_id :=
	request_group_id_f(group_application_id, request_group);

  insert into Fnd_Request_Group_Units( APPLICATION_ID,
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
				       'S',
				       set_application_id,
				       set_id,
				       last_update_date,
				       last_updated_by,
				       creation_date,
                                       created_by,
                                       last_update_login);

  println('Added set '|| request_set || ' to group '
	||request_group);

END;




-- Procedure
--   REMOVE_SET_FROM_GROUP
--
-- Purpose
--   Remove a set from a request group.
--
-- Arguments
--   request_set         - Short name of set.
--   set_application     - Application short name of the set.
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
PROCEDURE remove_set_from_group(request_set         IN VARCHAR2,
	                        set_application	    IN VARCHAR2,
	                        request_group       IN VARCHAR2,
		                group_application   IN VARCHAR2)
is
   set_application_id
       fnd_application.application_id%TYPE;
   group_application_id
       fnd_application.application_id%TYPE;
   set_id
       fnd_request_sets.request_set_id%TYPE;
   group_id
       fnd_request_groups.request_group_id%TYPE;
BEGIN
   message_init;

   check_notnull(set_application);
   check_notnull(request_set);
   check_notnull(request_group);
   check_notnull(group_application);

   set_application_id := application_id_f(set_application);
   group_application_id := application_id_f(group_application);

   set_id := request_set_id_f(set_application_id, request_set);
   group_id :=
	request_group_id_f(group_application_id, request_group);

   delete from fnd_request_group_units u
    where application_id = group_application_id
      and request_group_id = group_id
      and request_unit_type = 'S'
      and unit_application_id = set_application_id
      and request_unit_id = set_id;
END;



-- Procedure
--   DELETE_PROGRAM_PARAMETER
--
-- Purpose
--   Delete a concurrent program request set parameter.
--
-- Arguments
--   program             - Short name of the program. (e.g. FNDSCRMT)
--   program_application - Application short name of the program. (e.g. 'FND')
--   request_set         - Short name of request set.
--   set_application     - Application short name of the request set.
--   stage               - Stage number.
--   program_sequence    - Program sequence number.
--   parameter           - Name of the program parameter. (NOT the prompt!)
--
PROCEDURE delete_program_parameter(program               IN VARCHAR2,
	                       program_application   IN VARCHAR2,
	                       request_set           IN VARCHAR2 DEFAULT NULL,
                               stage                 IN VARCHAR2,
	                       set_application       IN VARCHAR2,
                               program_sequence      IN NUMBER,
                               parameter             IN VARCHAR2)
is
  set_id
       fnd_request_sets.request_set_id%TYPE;
  stage_id
       fnd_request_set_stages.request_set_stage_id%TYPE;
  program_appl_id
	fnd_application.application_id%TYPE;
  set_appl_id
	fnd_application.application_id%TYPE;
  set_program_id
        fnd_request_set_program_args.request_set_program_id%TYPE;
BEGIN
   message_init;

   check_notnull(program);
   check_notnull(program_application);
   check_notnull(set_application);
   check_notnull(stage);
   check_notnull(program_sequence);
   check_notnull(parameter);

   set_appl_id := application_id_f(set_application);
   program_appl_id := application_id_f(program_application);

   set_id := request_set_id_f(set_appl_id, request_set);
   stage_id := request_set_stage_id_f(set_appl_id, set_id, stage);

   BEGIN
      select request_set_program_id
        into set_program_id
        from fnd_request_set_programs s,
             fnd_concurrent_programs  p
       where p.concurrent_program_name = program
         and p.application_id = program_appl_id
         and p.concurrent_program_id = s.concurrent_program_id
         and p.application_id = s.program_application_id
         and s.request_set_id = set_id
         and s.set_application_id = set_appl_id
         and s.request_set_stage_id = stage_id
         and s.sequence = program_sequence;
   EXCEPTION
      WHEN no_data_found THEN
	 message('Could not find program '|| program
                 || ' in set '|| request_set || ' with seq# ' ||
                 to_char(program_sequence));
	 RAISE bad_parameter;
   END;

   delete from fnd_request_set_program_args a
    where a.application_id = set_appl_id
      and a.request_set_id = set_id
      and a.request_set_program_id = set_program_id
      and (a.descriptive_flex_appl_id,
           a.descriptive_flexfield_name,
           a.application_column_name) in
         (select u.application_id,
                 u.descriptive_flexfield_name,
                 u.application_column_name
            from fnd_descr_flex_column_usages u
           where u.application_id = program_appl_id
             and u.descriptive_flexfield_name = '$SRS$.'||program
             and u.descriptive_flex_context_code = 'Global Data Elements'
             and u.end_user_column_name = parameter);

END delete_program_parameter;




-- Procedure
--   DELETE_SET
--
-- Purpose
--   Delete a request set, and references to that set.
--
-- Arguments
--   request_set     - Short name of the set.
--   application     - Application short name of the executable.
--
PROCEDURE delete_set(request_set         IN VARCHAR2,
	             application    	 IN VARCHAR2) is
   set_appl_id
       fnd_application.application_id%TYPE;
   set_id
       fnd_request_sets.request_set_id%TYPE;
   program_short_name
       fnd_concurrent_programs.concurrent_program_name%TYPE;

   cursor c (set_appl_id number, set_id number) is
     select request_set_stage_id
       from fnd_request_set_stages
      where request_set_id = set_id
        and set_application_id = set_appl_id;
BEGIN
   message_init;

   check_notnull(application);
   check_notnull(request_set);

   set_appl_id := application_id_f(application);

   BEGIN
     set_id := request_set_id_f(set_appl_id, request_set);
   EXCEPTION
     when others then  -- If set doesn't exist then exit normally
       println('Set '|| request_set || ' not found.');
       message_init;
       return;
   END;

   -- Delete the program if it exists
   BEGIN
     select concurrent_program_name
       into program_short_name
       from fnd_concurrent_programs p,
            fnd_request_sets r
      where r.application_id = set_appl_id
        and r.request_set_id = set_id
        and r.application_id = p.application_id
        and r.concurrent_program_id = p.concurrent_program_id;

      fnd_program.delete_program(program_short_name, application);
   EXCEPTION
     when others then
       message_init;
       null;  -- We don't care if the program does not exist
   END;

   -- Of course delete program might have already executed the
   -- following deletes, but there's really no way to tell.
   -- It doesn't matter anyway.  This will be rare.

   -- Remove set from request groups

   DELETE FROM fnd_request_group_units
   WHERE request_unit_type = 'S'
   AND request_unit_id = set_id
   AND unit_application_id = set_appl_id;

   -- Remove member program arguments

   DELETE FROM fnd_request_set_program_args
   WHERE application_id = set_appl_id
   AND request_set_id = set_id;

   -- Remove member programs

   DELETE FROM fnd_request_set_programs
   WHERE set_application_id = set_appl_id
   AND request_set_id = set_id;

   -- Delete stage master programs (if any)
   for rec in c(set_appl_id, set_id) loop
     begin
       select concurrent_program_name
         into program_short_name
         from fnd_concurrent_programs p,
              fnd_request_set_stages r
        where r.set_application_id = set_application_id
          and r.request_set_id = set_id
          and r.request_set_stage_id = rec.request_set_stage_id
          and r.set_application_id = p.application_id
          and r.concurrent_program_id = p.concurrent_program_id;

        fnd_program.delete_program(program_short_name, application);
     exception
       when others then
         message_init;
         null;  -- We don't care if the program does not exist
     end;
   end loop;

   -- Remove stages
   DELETE from fnd_stage_fn_parameter_values
    where set_application_id = set_appl_id
      and request_set_id = set_id;

   DELETE FROM fnd_request_set_stages_tl
   WHERE set_application_id = set_appl_id
   AND request_set_id = set_id;

   DELETE FROM fnd_request_set_stages
   WHERE set_application_id = set_appl_id
   AND request_set_id = set_id;

   -- Remove the set

   DELETE FROM fnd_request_sets_tl
   WHERE application_id = set_appl_id
   AND request_set_id = set_id;

   DELETE FROM fnd_request_sets
   WHERE application_id = set_appl_id
   AND request_set_id = set_id;

END delete_set;



-- Procedure
--   DELETE_INCOMPATIBILITY
--
-- Purpose
--   Delete a request set incompatibility rule.
--
-- Arguments
--   request_set         - Short name of the request set.
--   application         - Application short name of the request set.
--   stage               - Stage short name (for stage incompatibility).
--   inc_prog_short_name - Short name of the incompatible program.
--   inc_prog_application- Application of the incompatible program.
--   inc_request_set     - Sort name of the incompatible reuqest set.
--   inc_set_application - Application short name of the incompatible set.
--   inc_stage           - Stage short name to the incompatible stage.
--
-- See examples from fnd_set.incompatibility() for argument usage.
--
PROCEDURE delete_incompatibility(request_set          IN VARCHAR2,
		  	         application   	      IN VARCHAR2,
                                 stage                IN VARCHAR2 DEFAULT NULL,
			         inc_prog             IN VARCHAR2 DEFAULT NULL,
			         inc_prog_application IN VARCHAR2 DEFAULT NULL,
                                 inc_request_set      IN VARCHAR2 DEFAULT NULL,
                                 inc_set_application  IN VARCHAR2 DEFAULT NULL,
                                 inc_stage            IN VARCHAR2 DEFAULT NULL)
  IS
     application_id_i fnd_application.application_id%TYPE;
     concurrent_program_id_i
       fnd_concurrent_programs.concurrent_program_id%TYPE;
     to_run_concurrent_program_id_i
       fnd_concurrent_programs.concurrent_program_id%TYPE;
     to_run_application_id_i fnd_application.application_id%TYPE;
     dummy varchar2(1);
     set_id number;
     stage_id number;
BEGIN
   message_init;

   check_notnull(request_set);
   check_notnull(application);

   -- Get ID of first program
   application_id_i := application_id_f(application);
   set_id := request_set_id_f(application_id_i, request_set);
   if (stage is not null) then
     stage_id := request_set_stage_id_f(application_id_i, set_id,
                                        stage);
   else
     stage_id := null;
   end if;
   concurrent_program_id_i := get_prog_id(application_id_i, set_id, stage_id);

   -- Get ID of second program
   if (inc_prog_application is not null) then  /* incompatible PROGRAM */
     to_run_application_id_i :=
           application_id_f(inc_prog_application);
     to_run_concurrent_program_id_i :=
	concurrent_program_id_f(to_run_application_id_i, inc_prog);
   else  /* incompatible SET or STAGE */
     to_run_application_id_i :=
           application_id_f(inc_set_application);
     set_id := request_set_id_f(to_run_application_id_i, inc_request_set);
     if (inc_stage is not null) then
       stage_id := request_set_stage_id_f(to_run_application_id_i, set_id,
                                          inc_stage);
     else
       stage_id := null;
     end if;
     to_run_concurrent_program_id_i := get_prog_id(to_run_application_id_i,
                                                   set_id, stage_id);
   end if;

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



-- Function
--   INCOMPATIBILITY_EXISTS
--
-- Purpose
--   Return TRUE if an incompatibility exists.
--
-- Arguments
--   request_set         - Short name of the request set.
--   application         - Application short name of the request set.
--   stage               - Stage short name (for stage incompatibility).
--   inc_prog_short_name - Short name of the incompatible program.
--   inc_prog_application- Application of the incompatible program.
--   inc_request_set     - Sort name of the incompatible reuqest set.
--   inc_set_application - Application short name of the incompatible set.
--   inc_stage           - Stageshort name to the incompatible stage.
--
-- See examples from fnd_set.incompatibility() for argument usage.
--
FUNCTION incompatibility_exists(request_set          IN VARCHAR2,
		  	         application   	      IN VARCHAR2,
                                 stage                IN VARCHAR2 DEFAULT NULL,
			         inc_prog             IN VARCHAR2 DEFAULT NULL,
			         inc_prog_application IN VARCHAR2 DEFAULT NULL,
                                 inc_request_set      IN VARCHAR2 DEFAULT NULL,
                                 inc_set_application  IN VARCHAR2 DEFAULT NULL,
                                 inc_stage            IN VARCHAR2 DEFAULT NULL)
return boolean is

   application_id_i        fnd_application.application_id%TYPE;
   concurrent_program_id_i fnd_concurrent_programs.concurrent_program_id%TYPE;
   to_run_concurrent_program_id_i
                           fnd_concurrent_programs.concurrent_program_id%TYPE;
   to_run_application_id_i fnd_application.application_id%TYPE;
   dummy                   varchar2(1);
   set_id number;
   stage_id number;

BEGIN
   message_init;

   -- Get ID of first program
   application_id_i := application_id_f(application);
   set_id := request_set_id_f(application_id_i, request_set);
   if (stage is not null) then
     stage_id := request_set_stage_id_f(application_id_i, set_id,
                                        stage);
   else
     stage_id := null;
   end if;
   concurrent_program_id_i := get_prog_id(application_id_i, set_id, stage_id);

   -- Get ID of second program
   if (inc_prog_application is not null) then  /* incompatible PROGRAM */
     to_run_application_id_i :=
           application_id_f(inc_prog_application);
     to_run_concurrent_program_id_i :=
	concurrent_program_id_f(to_run_application_id_i, inc_prog);
   else  /* incompatible SET or STAGE */
     to_run_application_id_i :=
           application_id_f(inc_set_application);
     set_id := request_set_id_f(to_run_application_id_i, inc_request_set);
     if (inc_stage is not null) then
       stage_id := request_set_stage_id_f(to_run_application_id_i, set_id,
                                          inc_stage);
     else
       stage_id := null;
     end if;
     to_run_concurrent_program_id_i := get_prog_id(to_run_application_id_i,
                                                   set_id, stage_id);
   end if;

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
--   REQUEST_SET_EXISTS
--
-- Purpose
--   Returns TRUE if a request set exists.
--
-- Arguments
--   request_set - Short name of the set.
--   application - Application short name of the request set.
--
FUNCTION request_set_exists(request_set    IN VARCHAR2,
	             	    application    IN VARCHAR2)
RETURN BOOLEAN is
   set_application_id fnd_application.application_id%TYPE;
   set_id             fnd_request_sets.request_set_id%TYPE;

BEGIN
   message_init;

   set_application_id := application_id_f(application);
   set_id := request_set_id_f(set_application_id, request_set);

   return TRUE;
EXCEPTION
   when others then
     return FALSE;
END request_set_exists;




-- Function
--   STAGE_IN_SET
--
-- Purpose
--   Return TRUE if a stage is in a request set.
--
-- Arguments
--   stage               - Stage short name.
--   request_set         - Short name of request set.
--   set_application     - Application short name of the request set.
--   program_sequence    - Program sequence number.
--   request_set_id      - Optional.  Overrides parameter 'request_set'.
--
FUNCTION stage_in_set(stage                  IN VARCHAR2,
	              request_set            IN VARCHAR2,
		      set_application        IN VARCHAR2)
RETURN BOOLEAN is

   set_appl_id     fnd_application.application_id%TYPE;
   set_id          fnd_request_sets.request_set_id%TYPE;
   dummy           varchar2(1);

BEGIN
  message_init;

  set_appl_id := application_id_f(set_application);
  set_id := request_set_id_f(set_appl_id, request_set);

  select 'y'
    into dummy
    from fnd_request_set_stages f
   where set_application_id = set_appl_id
     and request_set_id = set_id
     and f.stage_name = stage;

  return TRUE;
EXCEPTION
  when others then
    return FALSE;
END stage_in_set;



-- Function
--   PROGRAM_IN_STAGE
--
-- Purpose
--   Return TRUE if a program is in a request set stage.
--
-- Arguments
--   program             - Short name of the program.
--   program_application - Application short name of the program.
--   request_set         - Short name of request set.
--   set_application     - Application short name of the request set.
--   stage               - Stage short name.
--   program_sequence    - Program sequence number.
--
FUNCTION program_in_stage(program                IN VARCHAR2,
	                  program_application    IN VARCHAR2,
	                  request_set            IN VARCHAR2,
		          set_application        IN VARCHAR2,
                          stage                  IN VARCHAR2,
                          program_sequence       IN NUMBER)
RETURN BOOLEAN is

   set_appl_id     fnd_application.application_id%TYPE;
   program_appl_id fnd_application.application_id%TYPE;
   set_id          fnd_request_sets.request_set_id%TYPE;
   stage_id        fnd_request_set_stages.request_set_stage_id%TYPE;
   program_id      fnd_concurrent_programs.concurrent_program_id%TYPE;
   dummy           varchar2(1);

BEGIN
  message_init;

  program_appl_id := application_id_f(program_application);
  set_appl_id := application_id_f(set_application);
  program_id := concurrent_program_id_f(program_appl_id, program);
  set_id := request_set_id_f(set_appl_id, request_set);
  stage_id := request_set_stage_id_f(set_appl_id, set_id, stage);

  select 'y'
    into dummy
    from fnd_request_set_programs
   where set_application_id = set_appl_id
     and request_set_id = set_id
     and request_set_stage_id = stage_id
     and program_application_id = program_appl_id
     and concurrent_program_id = program_id
     and sequence = program_sequence;

  return TRUE;
EXCEPTION
  when others then
    return FALSE;
END program_in_stage;




-- Function
--   PROGRAM_PARAMETER_EXISTS
--
-- Purpose
--   Return TRUE if a parameter has been registered for a request set.
--
-- Arguments
--   program            - Short name of the program.
--   program_application - Application short name of the program.
--   request_set         - Short name of request set.
--   set_application     - Application short name of the request set.
--   stage               - Stage short name.
--   program_sequence    - Program sequence number.
--   parameter           - Name of the program parameter. (NOT the prompt!)
--
FUNCTION program_parameter_exists(program              IN VARCHAR2,
	                      program_application  IN VARCHAR2,
	                      request_set          IN VARCHAR2,
	                      set_application      IN VARCHAR2,
                              stage                IN VARCHAR2,
                              program_sequence     IN NUMBER,
                              parameter            IN VARCHAR2)
RETURN BOOLEAN is

  set_id          fnd_request_sets.request_set_id%TYPE;
  stage_id        fnd_request_set_stages.request_set_stage_id%TYPE;
  program_appl_id fnd_application.application_id%TYPE;
  set_appl_id     fnd_application.application_id%TYPE;
  set_program_id  fnd_request_set_program_args.request_set_program_id%TYPE;
  dummy           varchar2(1);

BEGIN
  message_init;

  set_appl_id := application_id_f(set_application);
  program_appl_id := application_id_f(program_application);

  set_id := request_set_id_f(set_appl_id, request_set);
  stage_id := request_set_stage_id_f(set_appl_id, set_id, stage);

  select request_set_program_id
    into set_program_id
    from fnd_request_set_programs s,
         fnd_concurrent_programs  p
   where p.concurrent_program_name = program
     and p.application_id = program_appl_id
     and p.concurrent_program_id = s.concurrent_program_id
     and p.application_id = s.program_application_id
     and s.request_set_id = set_id
     and s.request_set_stage_id = stage_id
     and s.set_application_id = set_appl_id
     and s.sequence = program_sequence;

  select 'y'
    into dummy
    from fnd_request_set_program_args a
   where a.application_id = set_appl_id
     and a.request_set_id = set_id
     and a.request_set_program_id = set_program_id
     and (a.descriptive_flex_appl_id,
          a.descriptive_flexfield_name,
          a.application_column_name) in
        (select u.application_id,
                u.descriptive_flexfield_name,
                u.application_column_name
           from fnd_descr_flex_column_usages u
          where u.application_id = program_appl_id
            and u.descriptive_flexfield_name = '$SRS$.'||program
            and u.descriptive_flex_context_code = 'Global Data Elements'
            and u.end_user_column_name = parameter);

  return TRUE;
EXCEPTION
  when others then
    return FALSE;
END program_parameter_exists;




-- Function
--   SET_IN_GROUP
--
-- Purpose
--   Return TRUE if a request set is in a request group.
--
-- Arguments
--   request_set         - Short name of set.
--   set_application     - Application short name of the set.
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
FUNCTION set_in_group(request_set    	 IN VARCHAR2 DEFAULT NULL,
	              set_application	 IN VARCHAR2,
	              request_group      IN VARCHAR2,
		      group_application  IN VARCHAR2)
RETURN BOOLEAN is

  set_application_id   fnd_application.application_id%TYPE;
  group_application_id fnd_application.application_id%TYPE;
  set_id               fnd_request_sets.request_set_id%TYPE;
  group_id             fnd_request_groups.request_group_id%TYPE;
  dummy                varchar2(1);

BEGIN
  message_init;

  set_application_id := application_id_f(set_application);
  group_application_id := application_id_f(group_application);

  set_id := request_set_id_f(set_application_id, request_set);
  group_id := request_group_id_f(group_application_id, request_group);

  select 'y'
    into dummy
    from fnd_request_group_units u
    where application_id = group_application_id
      and request_group_id = group_id
      and request_unit_type = 'S'
      and unit_application_id = set_application_id
      and request_unit_id = set_id;

  return TRUE;
EXCEPTION
  when others then
    return FALSE;
END set_in_group;


-- Procedure
--   STAGE_FUNCTION
--
-- Purpose
--   Register a request set stage function.
--
-- Arguments
--   function_name       - Name of function.  (e.g. 'My Function')
--   application         - Short name of function's application.
--                        (e.g. 'FND')
--   short_name          - Short (non-translated) name of the function.
--   description         - Optional description of the function.
--   plsql_name 	 - Name of pl/sql stored function.
--   icon_name           - For future web interface. Use null for now.
--   language_code       - Language code for the name and description.
--                         (e.g. 'US')
--
PROCEDURE stage_function(function_name               IN VARCHAR2,
	                 application	     	     IN VARCHAR2,
                         short_name                  IN VARCHAR2,
	                 description                 IN VARCHAR2 DEFAULT NULL,
		         plsql_name                  IN VARCHAR2,
                         icon_name                   IN VARCHAR2 DEFAULT NULL,
                         language_code               IN VARCHAR2 DEFAULT 'US')
is
  application_id        number;
  executable_id         number;
  last_update_date      fnd_executables.last_update_date%TYPE;
  last_updated_by       fnd_executables.last_updated_by%TYPE;
  creation_date         fnd_executables.creation_date%TYPE;
  created_by            fnd_executables.created_by%TYPE;
  last_update_login     fnd_executables.last_update_login%TYPE;
  row_id                fnd_executables_vl.row_id%type;

begin
  message_init;

  check_notnull(function_name);
  check_notnull(short_name);
  check_notnull(application);
  check_notnull(plsql_name);

  last_update_date  := last_update_date_f;
  last_updated_by   := last_updated_by_f;
  creation_date     := creation_date_f;
  created_by        := created_by_f;
  last_update_login := last_update_login_f;
  application_id    := application_id_f(application);

  select fnd_executables_s.nextval into executable_id from sys.dual;

  insert into FND_EXECUTABLES (
    APPLICATION_ID, EXECUTABLE_ID, EXECUTABLE_NAME,
    EXECUTION_METHOD_CODE, EXECUTION_FILE_NAME, SUBROUTINE_NAME,
    CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_LOGIN, icon_name
  ) values (
    application_id, executable_id, short_name,
    'B', plsql_name, null,
    creation_date, created_by, last_update_date,
    last_updated_by, last_update_login, icon_name
  );

  insert into FND_EXECUTABLES_TL (
    APPLICATION_ID, EXECUTABLE_ID, CREATION_DATE,
    CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN, USER_EXECUTABLE_NAME, DESCRIPTION,
    LANGUAGE, SOURCE_LANG
  ) select
    stage_function.application_id, executable_id,
    stage_function.creation_date,
    stage_function.created_by, stage_function.last_update_date,
    stage_function.last_updated_by,
    stage_function.last_update_login, function_name,
    stage_function.description,
    l.language_code, stage_function.language_code
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B');

  println('created function for:'|| short_name);

end stage_function;



-- Function
--   FUNCTION_EXISTS
--
-- Purpose
--   Return TRUE if a stage function exists.
--
-- Arguments
--   function_short_name  - Short name of the function.
--   application - Application short name of the function.
--
FUNCTION function_exists(function_short_name IN VARCHAR2,
	         	 application	     IN VARCHAR2) RETURN BOOLEAN is
  exec_application_id fnd_application.application_id%TYPE;
  dummy               varchar2(1);

begin
  message_init;

  exec_application_id := application_id_f(application);

  select 'y'
    into dummy
    from fnd_executables
   where application_id = exec_application_id
     and executable_name = function_short_name;

  return TRUE;

EXCEPTION
   when others then
     return FALSE;
end function_exists;


-- Function
--   DELETE_FUNCTION
--
-- Purpose
--   Delete a stage function.
--
-- Arguments
--   function_short_name  - Short name of the function.
--   application - Application short name of the function.
--
PROCEDURE delete_function(function_short_name  IN VARCHAR2,
	         	   application	       IN VARCHAR2) is
  exec_application_id
	fnd_application.application_id%TYPE;
  exec_id
        fnd_executables.executable_id%TYPE;
  dummy varchar2(1);

begin
  message_init;

  check_notnull(function_short_name);
  check_notnull(application);

  exec_application_id := application_id_f(application);

  BEGIN
     SELECT executable_id
	INTO exec_id
	FROM fnd_executables
	WHERE application_id = exec_application_id
	AND executable_name = function_short_name;
  EXCEPTION
      WHEN no_data_found THEN
	 println('Could not find executable: '||function_short_name);
	 return;
  END;


  -- Can't delete an executable if it is in use
  BEGIN
    select 'x' into dummy
      from sys.dual
     where not exists
       (select 1
          from fnd_request_set_stages
         where function_application_id = exec_application_id
           and function_id = exec_id);
  EXCEPTION
    when no_data_found then
      message('Error - function is assigned to a stage.');
      RAISE bad_parameter;
  END;

  delete from fnd_stage_fn_parameters_tl
   where function_id = exec_id
     and application_id = exec_application_id;

  delete from fnd_executables_tl
   where executable_id = exec_id
     and application_id = exec_application_id;

  delete from fnd_executables
   where executable_id = exec_id
     and application_id = exec_application_id;

  delete from fnd_request_group_units
   where request_unit_id = exec_id
     and unit_application_id = exec_application_id
     and request_unit_type = 'F';

end delete_function;


-- Function
--   FUNCTION_IN_GROUP
--
-- Purpose
--   Return TRUE if a stage is in a request group.
--
-- Arguments
--   function_short_name - Short name of set.
--   function_application - Application short name of the function.
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
FUNCTION function_in_group(function_short_name  IN VARCHAR2,
	                   function_application IN VARCHAR2,
	                   request_group        IN VARCHAR2,
		           group_application    IN VARCHAR2)
                                                     RETURN BOOLEAN is
  fn_application_id   fnd_application.application_id%TYPE;
  group_application_id fnd_application.application_id%TYPE;
  fn_id               number;
  group_id             fnd_request_groups.request_group_id%TYPE;
  dummy                varchar2(1);

begin
  message_init;

  fn_application_id := application_id_f(function_application);
  group_application_id := application_id_f(group_application);

  fn_id := function_id_f(fn_application_id, function_short_name);
  group_id := request_group_id_f(group_application_id, request_group);

  select 'y'
    into dummy
    from fnd_request_group_units u
    where application_id = group_application_id
      and request_group_id = group_id
      and request_unit_type = 'F'
      and unit_application_id = fn_application_id
      and request_unit_id = fn_id;

  return TRUE;
exception
  when others then
    return FALSE;
end function_in_group;


-- Function
--   ADD_FUNCTION_TO_GROUP
--
-- Purpose
--   Adds a stage function to a request_group.
--
-- Arguments
--   function_short_name - Short name of set.
--   function_application - Application short name of the function.
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
procedure add_function_to_group(function_short_name IN VARCHAR2,
	                  function_application      IN VARCHAR2,
	                  request_group             IN VARCHAR2,
		          group_application         IN VARCHAR2) is
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
   fn_application_id
       fnd_application.application_id%TYPE;
   group_application_id
       fnd_application.application_id%TYPE;
   fn_id
       fnd_request_sets.request_set_id%TYPE;
   group_id
       fnd_request_groups.request_group_id%TYPE;
begin
   message_init;

   check_notnull(function_application);
   check_notnull(function_short_name);
   check_notnull(request_group);
   check_notnull(group_application);

   fn_application_id := application_id_f(function_application);
   group_application_id := application_id_f(group_application);

   fn_id := function_id_f(fn_application_id, function_short_name);
   group_id :=
	request_group_id_f(group_application_id, request_group);

  insert into Fnd_Request_Group_Units( APPLICATION_ID,
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
				       'F',
				       fn_application_id,
				       fn_id,
				       last_update_date,
				       last_updated_by,
				       creation_date,
                                       created_by,
                                       last_update_login);

  println('Added function '|| function_short_name || ' to group '
	||request_group);
end;


-- Function
--   REMOVE_FUNCTION_FROM_GROUP
--
-- Purpose
--   Removes a stage function from a request_group.
--
-- Arguments
--   function_short_name - Short name of set.
--   function_application - Application short name of the function.
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
procedure remove_function_from_group(function_short_name  IN VARCHAR2,
	                             function_application IN VARCHAR2,
	                             request_group        IN VARCHAR2,
		                     group_application    IN VARCHAR2) is
   fn_application_id
       fnd_application.application_id%TYPE;
   group_application_id
       fnd_application.application_id%TYPE;
   fn_id number;
   group_id
       fnd_request_groups.request_group_id%TYPE;
begin
   message_init;

   check_notnull(function_application);
   check_notnull(function_short_name);
   check_notnull(request_group);
   check_notnull(group_application);

   fn_application_id := application_id_f(function_application);
   group_application_id := application_id_f(group_application);

   fn_id := function_id_f(fn_application_id, function_short_name);
   group_id :=
	request_group_id_f(group_application_id, request_group);

   delete from fnd_request_group_units u
    where application_id = group_application_id
      and request_group_id = group_id
      and request_unit_type = 'F'
      and unit_application_id = fn_application_id
      and request_unit_id = fn_id;
end;


-- Procedure
--   FUNCTION_PARAMETER
--
-- Purpose
--   Register a request set stage function parameter.
--
-- Arguments
--   function_short_name - Short (non-translated) name of the function.
--   application         - Short name of function's application.
--                        (e.g. 'FND')
--   paramter_name       - Displayed name of parameter.
--   parameter_short_name - Short (non-translated) name of parameter.
--   description         - Optional description of the function.
--   language_code       - Language code for the name and description.
--                         (e.g. 'US')
--
PROCEDURE function_parameter(function_short_name     IN VARCHAR2,
	                     application	     IN VARCHAR2,
                             parameter_name          IN VARCHAR2,
                             parameter_short_name    IN VARCHAR2,
	                     description             IN VARCHAR2 DEFAULT NULL,
                             language_code           IN VARCHAR2 DEFAULT 'US')
is
  last_update_date      fnd_executables.last_update_date%TYPE;
  last_updated_by       fnd_executables.last_updated_by%TYPE;
  creation_date         fnd_executables.creation_date%TYPE;
  created_by            fnd_executables.created_by%TYPE;
  last_update_login     fnd_executables.last_update_login%TYPE;
  row_id                fnd_executables_vl.row_id%type;
  fn_appl_id            fnd_application.application_id%TYPE;
  fn_id                 number;
  param_id              number;
begin
  message_init;

  check_notnull(function_short_name);
  check_notnull(application);
  check_notnull(parameter_name);
  check_notnull(parameter_short_name);

  last_update_date  := last_update_date_f;
  last_updated_by   := last_updated_by_f;
  creation_date     := creation_date_f;
  created_by        := created_by_f;
  last_update_login := last_update_login_f;
  fn_appl_id        := application_id_f(application);
  fn_id             := function_id_f(fn_appl_id, function_short_name);

  select fnd_stage_fn_parameters_s.nextval into param_id from sys.dual;

  insert into FND_STAGE_FN_PARAMETERS_TL (
    APPLICATION_ID, FUNCTION_ID, PARAMETER_ID, CREATION_DATE,
    CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN, PARAMETER_NAME, USER_PARAMETER_NAME, DESCRIPTION,
    LANGUAGE, SOURCE_LANG
  ) select
    fn_appl_id,fn_id, param_id, function_parameter.creation_date,
    function_parameter.created_by, function_parameter.last_update_date,
    function_parameter.last_updated_by,
    function_parameter.last_update_login, parameter_short_name,
    parameter_name, function_parameter.description,
    l.language_code, function_parameter.language_code
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B');

  println('created function for:'|| function_short_name);
end;


-- Function
--   FUNCTION_PARAMETER_EXISTS
--
-- Purpose
--   Return TRUE if a stage function parameter exists.
--
-- Arguments
--   function_short_name  - Short name of the function.
--   application - Application short name of the function.
--   parameter   - Short (non-translated) name of parameter.
--
FUNCTION function_parameter_exists(function_short_name        IN VARCHAR2,
	         	           application	              IN VARCHAR2,
                                   parameter                  IN VARCHAR2)
         RETURN BOOLEAN is
  fn_appl_id fnd_application.application_id%TYPE;
  fn_id      number;
  dummy      varchar2(1);

begin
  message_init;

  fn_appl_id := application_id_f(application);
  fn_id := function_id_f(fn_appl_id, function_short_name);

  select 'y'
    into dummy
    from fnd_stage_fn_parameters_vl
   where application_id = fn_appl_id
     and function_id  = fn_id
     and parameter_name = parameter;

  return TRUE;

EXCEPTION
   when others then
     return FALSE;
end;


-- Function
--   DELETE_FUNCTION_PARAMETER
--
-- Purpose
--   Delete a stage function parameter.
--
-- Arguments
--   function_short_name  - Short name of the function.
--   application - Application short name of the function.
--   parameter - Short (non-translated) name of parameter.
--
PROCEDURE delete_function_parameter(function_short_name        IN VARCHAR2,
	         	  application	             IN VARCHAR2,
                          parameter                  IN VARCHAR2) is
  fn_appl_id fnd_application.application_id%TYPE;
  fn_id      number;
  param_id   number;
  dummy      varchar2(1);

begin
  message_init;

  check_notnull(function_short_name);
  check_notnull(application);
  check_notnull(parameter);

  fn_appl_id := application_id_f(application);
  fn_id := function_id_f(fn_appl_id, function_short_name);

  begin
     select parameter_id
	into param_id
        from fnd_stage_fn_parameters_vl
       where application_id = fn_appl_id
         and function_id  = fn_id
         and parameter_name = parameter;
  exception
      when no_data_found then
	 println('Could not find parameter: '||parameter);
	 return;
  end;


  delete from fnd_stage_fn_parameters_tl
   where function_id = fn_id
     and application_id = fn_appl_id
     and parameter_id = param_id;

  delete from fnd_stage_fn_parameter_values
   where function_id = fn_id
     and function_application_id = fn_appl_id
     and parameter_id = param_id;


end delete_function_parameter;


-- Function
--   FUNCTION_PARAMETER_VALUE
--
-- Purpose
--   Sets the value of a stage function parameter for a given stage.
--
-- Arguments
--   request_set  - Short name of the request set.
--   set_application - Application short name of the set.
--   stage_short_name - Short name of stage.
--   parameter  - Short name of parameter.
--   value - Value to which the paraemter is to be set.
--
PROCEDURE function_parameter_value(request_set        IN VARCHAR2,
                                 set_application      IN VARCHAR2,
                                 stage                IN VARCHAR2,
                                 parameter            IN VARCHAR2,
                                 value                IN VARCHAR2) is
  last_update_date      fnd_executables.last_update_date%TYPE;
  last_updated_by       fnd_executables.last_updated_by%TYPE;
  creation_date         fnd_executables.creation_date%TYPE;
  created_by            fnd_executables.created_by%TYPE;
  last_update_login     fnd_executables.last_update_login%TYPE;
  row_id                fnd_executables_vl.row_id%type;
  stage_id              number;
  param_id              number;
  set_id		number;
  set_appl_id		number;
  fn_id                 number;
  fn_appl_id            number;
begin
  message_init;

  check_notnull(request_set);
  check_notnull(set_application);
  check_notnull(stage);
  check_notnull(parameter);

  last_update_date  := last_update_date_f;
  last_updated_by   := last_updated_by_f;
  creation_date     := creation_date_f;
  created_by        := created_by_f;
  last_update_login := last_update_login_f;
  set_appl_id       := application_id_f(set_application);
  set_id            := request_set_id_f(set_appl_id, request_set);
  stage_id          := request_set_stage_id_f(set_appl_id, set_id, stage);

  begin
    select s.function_id, s.function_application_id, p.parameter_id
      into fn_id, fn_appl_id, param_id
      from fnd_request_set_stages s, fnd_stage_fn_parameters_vl p
     where s.request_set_id = set_id
       and s.set_application_id = set_appl_id
       and s.request_set_stage_id = stage_id
       and s.function_id = p.function_id
       and s.function_application_id = p.application_id
       and p.parameter_name = parameter;
  exception
    when no_data_found then
      println('Could not find parameter "'||parameter||'" in stage.' );
       return;
  end;



  insert into FND_STAGE_FN_PARAMETER_VALUES (
    SET_APPLICATION_ID, REQUEST_SET_ID, REQUEST_SET_STAGE_ID,
    FUNCTION_APPLICATION_ID, FUNCTION_ID,
    PARAMETER_ID, CREATION_DATE,
    CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN, VALUE
  ) values
    (set_appl_id, set_id, stage_id, fn_appl_id, fn_id,
    param_id, function_parameter_value.creation_date,
    function_parameter_value.created_by,
    function_parameter_value.last_update_date,
    function_parameter_value.last_updated_by,
    function_parameter_value.last_update_login,
    function_parameter_value.value );

  println('Added value');
end;
/* END_PUBLIC */


-- Function
--    RESTART_REQUEST_SET
--
-- Purpose
--  Restarts an Request Set only if it was failed in the last run.
--
-- Arguments
--  request_set_id - request_id of request set
--
-- Return
--  returns true if request set can be restarted, otherwise false.
--
FUNCTION restart_request_set( request_set_id IN number) RETURN BOOLEAN IS
requestId number;
phasecode varchar2(1);
statuscode varchar2(1);
queuemethod varchar2(1);
rset_id number;
req_type varchar2(1);
req_request_date date;
rset_last_updated_date date;
error_stage_id number;
appl_id number;
tmpDate date;
pos number;
pos2 number;
req_data varchar2(240);
current_run_number number;
tmp_number number;
BEGIN
  requestId := request_set_id;
  begin
    select phase_code, status_code, queue_method_code, request_type,
    REQUEST_DATE, to_number(argument2),to_number(argument1), req_information, RUN_NUMBER
      into phasecode, statuscode, queuemethod, req_type,
      req_request_date, rset_id, appl_id, req_data, current_run_number
      from fnd_concurrent_requests
      where request_id = requestId;
  exception
    when NO_DATA_FOUND then
    message('Invalid request id : ' || requestId);
    RAISE bad_parameter;
  end;
  BEGIN
    pos := instr(req_data, ',', 1, 1);
    pos2 := instr(req_data, ',', pos + 1, 1);
    error_stage_id := to_number(substr(req_data, pos + 1, pos2 - pos -1));
    select LAST_UPDATE_DATE into rset_last_updated_date from FND_REQUEST_SETS
    where REQUEST_SET_ID = rset_id AND application_id = appl_id;
    SELECT max(last_update_date) INTO tmpDate FROM fnd_request_set_stages
    WHERE request_set_id = rset_id AND set_application_id = appl_id;
    IF( tmpDate > rset_last_updated_date) THEN
      rset_last_updated_date := tmpDate;
    END IF;
    SELECT max(last_update_date) INTO tmpDate FROM fnd_request_set_programs
    WHERE request_set_id = rset_id AND set_application_id = appl_id;
    IF( tmpDate > rset_last_updated_date) THEN
      rset_last_updated_date := tmpDate;
    END IF;
    if( rset_last_updated_date > req_request_date ) then
      return false;
    end if;
    exception
    when no_data_found then
      NULL;
  end;
/*check whether any errored out program got deleted */
select count(r.request_set_program_id) INTO tmp_number
  from fnd_run_requests r,
             fnd_concurrent_requests fcr1, fnd_concurrent_requests fcr2
       where r.parent_request_id = requestId
         and fcr1.parent_request_id = fcr2.request_id
         and fcr1.concurrent_program_id = r.concurrent_program_id
         and r.request_id = fcr1.request_id
         and fcr1.status_code = 'E'
         and fcr2.parent_request_id = requestId
         and fcr2.run_number = current_run_number
         and error_stage_id = to_number(fcr2.argument3)
         and r.request_set_program_id IS NOT NULL
         AND r.request_set_program_id NOT IN
         (
           SELECT REQUEST_SET_PROGRAM_ID FROM FND_REQUEST_SET_PROGRAMS WHERE SET_APPLICATION_ID = appl_id
           AND REQUEST_SET_ID = rset_id AND REQUEST_SET_STAGE_ID = error_stage_id
         );
    if( tmp_number <> 0)then
         return false ;
    end if;

    IF( not(req_type = 'M' and phasecode ='C' and statuscode = 'E') ) then
      return false;
    end if;
    if( queuemethod = 'B' ) then
      update fnd_concurrent_requests set phase_code = 'P', status_code = 'Q' where request_id = requestId;
    else if ( queuemethod = 'I' ) then
      update fnd_concurrent_requests set phase_code = 'P', status_code = 'I' where request_id = requestId;
      else
        return false;
    end if;
    end if;
    return true;
END;
END fnd_set;
/* end package */

/
