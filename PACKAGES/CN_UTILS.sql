--------------------------------------------------------
--  DDL for Package CN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_UTILS" AUTHID CURRENT_USER AS
-- $Header: cnsyutls.pls 120.3 2005/09/08 10:55:59 ymao ship $



  --+
  -- Public types and variables
  --+

  -- Type for passing code text and indentation info
  TYPE code_type IS RECORD (
     object_id	NUMBER,
     line	INTEGER,
     indent	INTEGER,
     text	VARCHAR2(32700) );

  TYPE clob_code_type IS RECORD (
     object_id	NUMBER,
     line	INTEGER,
     indent	INTEGER,
     text	CLOB );

  --+
  -- Public functions and procedures
  --+

PROCEDURE set_org_id(p_org_id IN NUMBER);
PROCEDURE unset_org_id;

  --+
  -- Procedure Name
  --   delete_module
  -- Purpose
  --   Deletes old entries from cn_source and cn_mod_obj_depends
  -- History
  --   22-APR-94		Devesh Khatu		Created
  --+
  PROCEDURE delete_module (x_module_id	      cn_modules.module_id%TYPE,
			               x_package_spec_id  cn_objects.object_id%TYPE,
			               x_package_body_id  cn_objects.object_id%TYPE,
                           p_org_id           NUMBER) ;

  --+
  -- Procedure Name
  --   init_code
  -- Purpose
  --   Initializes code.text, code.indent, code.line for a code_object.
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+

  PROCEDURE init_code	(
	    X_object_id     cn_objects.object_id%TYPE,
	    code    IN OUT NOCOPY  cn_utils.code_type);

  --+
  -- Procedure Name
  --   init_code
  -- Purpose
  --   Initializes code.text, code.indent, code.line for a code_object.
  -- History
  --   		RK		Created
  --+

  PROCEDURE init_code	(
	    X_object_id     cn_objects.object_id%TYPE,
	    code    IN OUT NOCOPY  cn_utils.clob_code_type);


  --+
  -- Procedure Name
  --   indent
  -- Purpose
  --   updates code.indent depending on the nesting level
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE indent (
	code	IN OUT NOCOPY cn_utils.code_type,
	nesting_level	NUMBER);

  --+
  -- Procedure Name
  --   indent
  -- Purpose
  --   updates code.indent depending on the nesting level
  -- History
  --   		RK		Created
  --+
  PROCEDURE indent (
	code	IN OUT NOCOPY cn_utils.clob_code_type,
	nesting_level	NUMBER);


  --+
  -- Procedure Name
  --   unindent
  -- Purpose
  --   updates code.unindent depending on the nesting level
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE unindent (
	code	IN OUT NOCOPY cn_utils.code_type,
	nesting_level	NUMBER);


  --+
  -- Procedure Name
  --   unindent
  -- Purpose
  --   updates code.unindent depending on the nesting level
  -- History
  --   18-NOV-93		RK		Created
  --+
  PROCEDURE unindent (
	code	IN OUT NOCOPY cn_utils.clob_code_type,
	nesting_level	NUMBER);


  --+
  -- Procedure Name
  --   append
  -- Purpose
  --   append a string to code.text
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE append (code IN OUT NOCOPY cn_utils.code_type, str2 VARCHAR2);


  --+
  -- Procedure Name
  --   append
  -- Purpose
  --   append a string to code.text
  -- History
  --   18-NOV-93		RK		Created
  --+
  PROCEDURE append (code IN OUT NOCOPY cn_utils.clob_code_type, str2 VARCHAR2);


  --+
  -- Procedure Name
  --   append
  -- Purpose
  --   append a string to code.text
  -- History
  --   18-NOV-93		RK		Created
  --+
  PROCEDURE append (code IN OUT NOCOPY cn_utils.clob_code_type,expr clob,str2 VARCHAR2);


  --+
  -- Procedure Name
  --   appind
  -- Purpose
  --   append a string to code.text after indenting code.indent spaces
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE appind (code IN OUT NOCOPY cn_utils.code_type, str2 VARCHAR2);


  --+
  -- Procedure Name
  --   appind
  -- Purpose
  --   append a string to code.text after indenting code.indent spaces
  -- History
  --   18-NOV-93		RK		Created
  --+
  PROCEDURE appind (code IN OUT NOCOPY cn_utils.clob_code_type, str2 VARCHAR2);


  --+
  -- Procedure Name
  --   appendcr
  -- Purpose
  --   append a string to code.text along with a cr
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE appendcr (code IN OUT NOCOPY cn_utils.code_type, str2 VARCHAR2);


  --+
  -- Procedure Name
  --   appendcr
  -- Purpose
  --   append a string to code.text along with a cr
  -- History
  --   18-NOV-93		RK		Created
  --+
  PROCEDURE appendcr (code IN OUT NOCOPY cn_utils.clob_code_type, str2 VARCHAR2);


  --+
  -- Procedure Name
  --   appendcr
  -- Purpose
  --   appends a cr to code.text
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE appendcr(code IN OUT NOCOPY cn_utils.code_type);


    --+
    -- Procedure Name
    --   appendcr
    -- Purpose
    --   appends a cr to code.text
    -- History
    --   18-NOV-93		RK		Created
    --+
  PROCEDURE appendcr(code IN OUT NOCOPY cn_utils.clob_code_type);


  --+
  -- Procedure Name
  --   appindcr
  -- Purpose
  --   append a string to code.text along with a cr, after indenting
  --   code.indent spaces, and
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE appindcr(code IN OUT NOCOPY cn_utils.code_type, str2 VARCHAR2);

    --+
    -- Procedure Name
    --   appindcr
    -- Purpose
    --   append a string to code.text along with a cr, after indenting
    --   code.indent spaces, and
    -- History
    --   18-NOV-93		RK		Created
    --+
  PROCEDURE appindcr(code IN OUT NOCOPY cn_utils.clob_code_type, str2 VARCHAR2);



  --+
  -- Procedure Name
  --   strip
  -- Purpose
  --   strip code.text of its trailing i characters
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE strip (code IN OUT NOCOPY cn_utils.code_type, i NUMBER);

  --+
  -- Procedure Name
  --   strip
  -- Purpose
  --   strip code.text of its trailing i characters
  -- History
  --   18-NOV-93		RK		Created
  --+
  --PROCEDURE strip (code IN OUT cn_utils.clob_code_type, i NUMBER);


  --+
  -- Procedure Name
  --   strip_prev
  -- Purpose
  --   strip previous code.text of its trailing i characters after
  --   it has been written out to cn_source.  i number of bytes are
  --   removed at the end of the line, before the CR.
  -- History
  --   24-AUG-95		Amy Erickson		Created
  --+
  PROCEDURE strip_prev (code IN OUT NOCOPY cn_utils.code_type, i NUMBER);

  --+
  -- Procedure Name
  --   strip_prev
  -- Purpose
  --   strip previous code.text of its trailing i characters after
  --   it has been written out to cn_source.  i number of bytes are
  --   removed at the end of the line, before the CR.
  -- History
  --   24-AUG-95		RK		Created
  --+
  --PROCEDURE strip_prev (code IN OUT cn_utils.clob_code_type, i NUMBER);


  --+
  -- Procedure Name
  --   dump_line
  -- Purpose
  --   Dump generated code line into cn_source table
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE dump_line ( code  IN OUT NOCOPY cn_utils.code_type) ;

  --+
  -- Procedure Name
  --   dump_line
  -- Purpose
  --   Dump generated code line into cn_source table
  -- History
  --   18-NOV-93		RK		Created
  --+
  PROCEDURE dump_line ( code  IN OUT NOCOPY cn_utils.clob_code_type) ;

  --+
  -- Procedure Name
  --   record_process_start
  -- Purpose
  --   Generates some text to record the start of a process
  -- History
  --   17-NOV-93		Devesh Khatu		Created
  --   22-MAR-94		Devesh Khatu		Modified
  --+
  PROCEDURE record_process_start (
	audit_type	VARCHAR2,
	audit_desc	VARCHAR2,
	parent_audit_id VARCHAR2,
	code	IN OUT NOCOPY cn_utils.code_type);

  --+
  -- Procedure Name
  --   record_process_success
  -- Purpose
  --   Generate some boilerplate text to record success of the process
  -- History
  --   22-MAR-94		Devesh Khatu		Created
  --+
  PROCEDURE record_process_success (
	message 	VARCHAR2,
	code	IN OUT NOCOPY cn_utils.code_type);

  --+
  -- Procedure Name
  --   record_process_exception
  -- Purpose
  --   Generates some boilerplate text to record exception of the process
  -- History
  --   22-MAR-94		Devesh Khatu		Created
  --+
  PROCEDURE record_process_exception (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	savepoint_name		VARCHAR2,
	code	IN OUT NOCOPY 	cn_utils.code_type);


  --+
  -- Procedure Name
  --   record_process_exception
  -- Purpose
  --   Generates some boilerplate text to record exception of the process
  -- History
  --   22-MAR-94		RK		Created
  --+
  PROCEDURE record_process_exception (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	savepoint_name		VARCHAR2,
	code	IN OUT NOCOPY 	cn_utils.clob_code_type);



  --+
  -- Procedure Name
  --   pkg_init
  -- Purpose
  --   Create a new package and do initialization
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE pkg_init (
	module_id		  cn_modules.module_id%TYPE,
	package_name		  cn_obj_packages_v.name%TYPE,
	package_org_append        VARCHAR2,
	package_type		  cn_obj_packages_v.package_type%TYPE,
	package_spec_id   IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
	package_body_id   IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
	package_spec_desc IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
	package_body_desc IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
	spec_code	  IN OUT NOCOPY  cn_utils.code_type,
	body_code	  IN OUT NOCOPY  cn_utils.code_type);

  --+
  -- Procedure Name
  --   pkg_end
  -- Purpose
  --   End a package
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE pkg_end (
	package_name		cn_obj_packages_v.name%TYPE,
	package_spec_id 	cn_obj_packages_v.package_id%TYPE,
	package_body_id 	cn_obj_packages_v.package_id%TYPE,
	spec_code	IN OUT NOCOPY cn_utils.code_type,
		     body_code	IN OUT NOCOPY cn_utils.code_type);


  --+
    -- Procedure Name
    --   pkg_init
    -- Purpose
    --   Create a new package and do initialization
    -- History
    --   18-NOV-93		RK		Created
    --+
    /*PROCEDURE pkg_init (
  	module_id		  cn_modules.module_id%TYPE,
  	package_name		  cn_obj_packages_v.name%TYPE,
  	package_org_append        VARCHAR2,
  	package_type		  cn_obj_packages_v.package_type%TYPE,
  	package_spec_id   IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
  	package_body_id   IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
  	package_spec_desc IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
  	package_body_desc IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
  	spec_code	  IN OUT NOCOPY  cn_utils.clob_code_type,
  	body_code	  IN OUT NOCOPY  cn_utils.clob_code_type);*/

    --+
    -- Procedure Name
    --   pkg_end
    -- Purpose
    --   End a package
    -- History
    --   18-NOV-93		RK		Created
    --+
    PROCEDURE pkg_end (
  	package_name		cn_obj_packages_v.name%TYPE,
  	package_spec_id 	cn_obj_packages_v.package_id%TYPE,
  	package_body_id 	cn_obj_packages_v.package_id%TYPE,
  	spec_code	IN OUT NOCOPY cn_utils.clob_code_type,
  		     body_code	IN OUT NOCOPY cn_utils.clob_code_type);

  --+
  -- Procedure Name
  --   overloaded pkg_init
  -- Purpose
  --   Create a new package and do initialization
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE pkg_init (
	module_id		  cn_modules.module_id%TYPE,
	package_name		  cn_obj_packages_v.name%TYPE,
	package_org_append        VARCHAR2,
	package_type		  cn_obj_packages_v.package_type%TYPE,
	package_flag              VARCHAR2,
	package_spec_id   IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
	package_body_id   IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
	package_spec_desc IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
	package_body_desc IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
	spec_code	  IN OUT NOCOPY  cn_utils.code_type,
	body_code	  IN OUT NOCOPY  cn_utils.code_type);


    --+
    -- Procedure Name
    --   overloaded pkg_init
    -- Purpose
    --   Create a new package and do initialization
    -- History
    --   18-NOV-93		RK		Created
    --+
    PROCEDURE pkg_init (
  	module_id		  cn_modules.module_id%TYPE,
  	package_name		  cn_obj_packages_v.name%TYPE,
  	package_org_append        VARCHAR2,
  	package_type		  cn_obj_packages_v.package_type%TYPE,
  	package_flag              VARCHAR2,
  	package_spec_id   IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
  	package_body_id   IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
  	package_spec_desc IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
  	package_body_desc IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
  	spec_code	  IN OUT NOCOPY  cn_utils.clob_code_type,
	body_code	  IN OUT NOCOPY  cn_utils.clob_code_type);


  --+
  -- Procedure Name
  --   overloaded pkg_end for use in formula generation
  -- Purpose
  --   End a package
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE pkg_end (
	package_name		cn_obj_packages_v.name%TYPE,
	spec_code	IN OUT NOCOPY cn_utils.code_type,
	body_code	IN OUT NOCOPY cn_utils.code_type);


    --+
    -- Procedure Name
    --   overloaded pkg_end for use in formula generation
    -- Purpose
    --   End a package
    -- History
    --   18-NOV-93		RK		Created
    --+
    PROCEDURE pkg_end (
  	package_name		cn_obj_packages_v.name%TYPE,
  	spec_code	IN OUT NOCOPY cn_utils.clob_code_type,
	body_code	IN OUT NOCOPY cn_utils.clob_code_type);



  --+
  -- Procedure Name
  --   pkg_end_boilerplate
  -- Purpose
  --+
  -- History
  --+
  --+
  PROCEDURE pkg_end_boilerplate (
	code		IN OUT NOCOPY cn_utils.code_type,
	object_type		cn_obj_packages_v.object_type%TYPE);



    --+
    -- Procedure Name
    --   pkg_end_boilerplate
    -- Purpose
    --+
    -- History
    --+   CLOB
    --+
    PROCEDURE pkg_end_boilerplate (
  	code		IN OUT NOCOPY cn_utils.clob_code_type,
	object_type		cn_obj_packages_v.object_type%TYPE);





  --+
  -- Procedure Name
  --   proc_init
  -- Purpose
  --   Generate procedure init code
  -- History
  --   17-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE proc_init (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	description		cn_obj_procedures_v.description%TYPE,
	parameter_list		cn_obj_procedures_v.parameter_list%TYPE,
	procedure_type		cn_obj_procedures_v.procedure_type%TYPE,
	return_type		cn_obj_procedures_v.return_type%TYPE,
	package_id		cn_obj_procedures_v.package_id%TYPE,
	repository_id		cn_obj_procedures_v.repository_id%TYPE,
	spec_code	IN OUT NOCOPY cn_utils.code_type,
	body_code	IN OUT NOCOPY cn_utils.code_type);


  --+
  -- Procedure Name
  --   proc_init
  -- Purpose
  --   Generate procedure init code
  -- History
  --   17-NOV-93		RK		Created
  --+
  PROCEDURE proc_init (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	description		cn_obj_procedures_v.description%TYPE,
	parameter_list		cn_obj_procedures_v.parameter_list%TYPE,
	procedure_type		cn_obj_procedures_v.procedure_type%TYPE,
	return_type		cn_obj_procedures_v.return_type%TYPE,
	package_id		cn_obj_procedures_v.package_id%TYPE,
	repository_id		cn_obj_procedures_v.repository_id%TYPE,
	spec_code	IN OUT NOCOPY cn_utils.clob_code_type,
	body_code	IN OUT NOCOPY cn_utils.clob_code_type);


  --+
  -- Procedure Name
  --   proc_begin
  -- Purpose
  --   Generate procedure begin code
  -- History
  --   17-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE proc_begin (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	generate_debug_pipe	VARCHAR2,
	code	IN OUT NOCOPY 	cn_utils.code_type);

    --+
    -- Procedure Name
    --   proc_begin
    -- Purpose
    --   Generate procedure begin code
    -- History
    --   17-NOV-93		RK		Created
    --+
    PROCEDURE proc_begin (
  	procedure_name		cn_obj_procedures_v.name%TYPE,
  	generate_debug_pipe	VARCHAR2,
	code	IN OUT NOCOPY 	cn_utils.clob_code_type);


  --+
  -- Procedure Name
  --   proc_end
  -- Purpose
  --   Generates procedure end code
  -- History
  --   17-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE proc_end (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	exception_flag		VARCHAR2,
	code	IN OUT NOCOPY 	cn_utils.code_type);

  --+
  -- Procedure Name
  --   proc_end
  -- Purpose
  --   Generates procedure end code
  -- History
  --   17-NOV-93		RK		Created
  --+
  PROCEDURE proc_end (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	exception_flag		VARCHAR2,
	code	IN OUT NOCOPY 	cn_utils.clob_code_type);


  --+
  -- Function Name
  --   get_proc_audit_id
  -- Purpose
  --   returns a unique proc_audit_id from the sequence cn_process_audits_s
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  FUNCTION get_proc_audit_id
	RETURN cn_process_audits.process_audit_id%TYPE;

  --+
  -- Function Name
  --   get_object_id
  -- Purpose
  --   returns a unique object_id from the sequence cn_objects_s
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  FUNCTION get_object_id
	RETURN cn_objects.object_id%TYPE;

  --+
  -- Function Name
  --   get_mod_obj_depends_id
  -- Purpose
  --   returns a unique mod_obj_depends_id
  -- History
  --   11-JUN-94		Devesh Khatu		Created
  --+
  FUNCTION get_mod_obj_depends_id
	RETURN cn_mod_obj_depends.mod_obj_depends_id%TYPE;

  --+
  -- Function Name
  --   get_object_name
  -- Purpose
  --   returns the object_name from the cn_objects table, given the object id.
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  FUNCTION get_object_name (X_object_id cn_objects.object_id%TYPE, p_org_id IN NUMBER)
	RETURN cn_objects.name%TYPE;

  --+
  -- Function Name
  --   get_repository
  -- Purpose
  --   returns the repository_id corresponding to the given module_id
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  FUNCTION get_repository (X_module_id	cn_modules.module_id%TYPE, p_org_id IN NUMBER)
	RETURN cn_repositories.repository_id%TYPE;


  -- Function Name
  --   get_event
  -- Purpose
  --   returns the event_id corresponding to the given module_id
  -- History
  --   08-JUN-94		Devesh Khatu		Created
  --+
  FUNCTION get_event (X_module_id	cn_modules.module_id%TYPE, p_org_id  IN NUMBER)
	RETURN cn_events.event_id%TYPE;

  --+
  -- Procedure Name
  --   find_object
  -- Purpose
  --   Find an object in cn_objects
  -- History
  --   01-08-96 		Amy Erickson		Created
  --+
  PROCEDURE find_object (
	x_name			cn_objects.name%TYPE,
	x_object_type		cn_objects.object_type%TYPE,
	x_object_id	IN OUT NOCOPY cn_objects.object_id%TYPE,
	x_description	IN OUT NOCOPY cn_objects.description%TYPE,
    p_org_id        IN NUMBER) ;

  --+
  -- Procedure Name
  --   compute_hierarchy_levels
  -- Purpose
  --   This procedure orders nodes in cn_hierarchy_nodes by computing absolute
  --   hierarchy levels using data from the cn_hierarchy_edges table.
  -- History
  --   22-JUN-94		Devesh Khatu		Created
  --+
  PROCEDURE compute_hierarchy_levels (
	X_dim_hierarchy_id	cn_dim_hierarchies.dim_hierarchy_id%TYPE);

  --+
  -- Procedure Name
  --   next_period
  -- Purpose
  --   get the next period
  -- History
  --   24-Nov-98	Angela Chung		Created
  --+
   FUNCTION next_period (x_period_id NUMBER,p_org_id        IN NUMBER)
   RETURN cn_periods.period_id%TYPE;

END cn_utils;
 

/
