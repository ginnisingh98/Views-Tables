--------------------------------------------------------
--  DDL for Package FND_ADG_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ADG_UTILITY" AUTHID CURRENT_USER as
/* $Header: AFDGUTLS.pls 120.0.12010000.2 2010/09/17 16:36:07 rsanders noship $ */

/*
	fnd_adg_utility
	===============

	There are two pieces that go to make up Active Data Guard [ ADG ]
	support:

		Infrastructure
		RPC Usage

	Infrastructure is a completely new feature and the infrastructure patch
	can be applied at any time to a supported R12 EBS system.

	RPC Usage depends on the infrastructure and is a set of updates
	to existing EBS packages. The RPC Usage patch must be at the
	correct revision for your EBS system.

	This package is used to manage the infrastructure components of
	Active Data Guard support.

	For backwards compatibility, ADG support patches can be
	applied to 10g databases but they cannot be actived as ADG is
	an 11g only feature.

	ADG Support
	-----------

	EBS ADG support is currently only available for concurrent requests .
        There is no support for online queries to be redirected to an
	ADG instance.

	Concurrent request support is further restricted as follows:

		- Only standalone programs can be redirected to ADG.
		- At present standalone programs are further restricted
		  to just reportwriter reports.
		- Only reportwriter reports that have no direct or indirect
		  DML dependency can be run on ADG
		    - e.g. Reports that use sequences cannot be used as
		           the database uses DML to manage the sequence cache.
		- Reportwriter reports can only be run on ADG if they have
		  been run at least once on the primary database. This is
	          again a database restriction in the way it manages remote
		  PL/SQL dependencies which can result in dictionary DML being
		  executed during PL/SQL execution.

	The infrastructure is in part provided to allow customers to
	provide information and shortcuts to address some of the above
	issues.

	In future releases of the database, it is hoped that many of these
	restrictions will be lifted.

	How is ADG Support implemented?
	===============================

 	Although there is no support for report program updates	, the
	concurrent manager does have DML dependencies and these cannot be
	avoided without major code changes. These dependencies can only be
        addressed by executing updates on the primary via db links. For reasons
	that are too numerous to mention, this poses significant challenges for
 	EBS  - the broad issue is our direct and indirect use of PL/SQL and
	PL/SQL state.

	To provide ADG support, the RPC usage piece contains standard EBS
	packages that contain calls to shadow packages which then invoke
	the original procedure/function remotely - it is a non-transparent
	form or RMI.

	These shadow packages are built by the infrastructure and then
	invoked by standard packages such as FND_CONCURRENT.

	To avoid introducing db link dependencies into the core EBS code,
	RPC access is controlled by compile directives. This is all
	transparent. However, when switching to/from RPC usage, package bodies
	dependent on this directive will become invalid and require
	recompilation. Switching on RPC usage is a one off operation,
	as whether ADG is actually used is independent of package
	compilation - i.e. ADG support can be disabled even if RPC usage
	has been enabled.

	How is ADG Support enabled?
	===========================

	In addition to RPC code being in place, there are various
	steps to go through before a report can be directed to an ADG
	instance. First, it is important to understand how a manager works
	in a ADG environment.

	To use ADG you need to have Parallel Concurrent Processing [ PCP ]
	set up, with one or more nodes dedicated to serving ADG requests.
	These managers would in most circumstances be co-located with the
	ADG instance, as the majority of SQL traffic will be between
	the report and the database.

	ADG support makes use of the concurrent manage feature that allows
	the report connection [ TWO_TASK ] to be separate from the manager
	connection. The manager connection will always be to the primary
	database whereas the report will connect to the ADG instance.

	Connections depend on connect strings [ TNSNAMES.ORA ] and at
	present autoconfig does not provide support for ADG connect strings.
	These need to be set up manually.

	It is possible [ and quite probable ] that customers are already
	using PCP with complex shift and exclude/include rules. Although
	report definitions can be changed to use a different connection string,
        that becomes problematic when the ADG instance is unavailable for
	read access. This is addressed in the infrastructure by providing
	support for transparent redirection to ADG concurrent managers.
	This is achieved by defining include rules on the
	ADG managers with corresponding exclude rules on all other
	managers. When a concurrent request is created, triggers determine
	whether a request can be run on ADG and if all tests are met,
	the request is changed to use the include rule along with the
	ADG connection alias. If the tests are not met and/or the ADG managers
	are not running the request is run as is, using the existing rules
	set down for the report.

	Basic steps for setting up ADG support
	======================================

	1. Install infrastructure patch.
	2. Prepare for rpc :  - prepare_for_rpc_system
	3. At this point no further steps are possible until
	   the RPC usage patch has been installed. All triggers are
	   no-op and the compile directive is disabled.
	4. Install RPC usage patch - again this is a no-op until
	   compile directive is enabled.
	5. Register the dblink for connecting from standby to primary - i.e.
	   a dblink to connect to the primary database. For security
	   reasons this link should be a public database link - i.e. it does
	   not require any passwords to be specified.
	6. Switch the RPC system on. This will perform various validations
	   and if all ok, the compile directive will be enabled. This will
	   result in invalid objects. Either use standard RDBMS scripts
	   or use the convenience procedure, compile_rpc_dependents.
	7. At this point you can enable ADG support but apart from
	   seed data, there are no reports that are candidates for switching
	   to ADG and there are no registered ADG [ standby ] connection
	   strings.
	8. Register ADG [ standby ] connections - up to 5 ADG databases are
	   supported.
	9. Register a simulated standby connection. This is optional but allows
	   reports to be run in simulation mode on the primary database. This,
	   in conjunction with server patch xxxxxx, allows ADG violations to
	   be recorded.
	10.Register class type for ADG include rules.
	11.Manage the reports available for ADG redirection.
	12.For simulation mode, installed database triggers must be
	   enabled.
	13.Determine how ADG support is managed.
        14.Enable ADG support.
*/


/*	Constants
	=========
*/

  C_MAX_COMMIT_WAIT_TIME       constant       number := 300;

/*	Constants for registering connections.
*/

  C_CONNECT_STANDBY_TO_PRIMARY	constant	number := 1;
  C_CONNECT_PRIMARY_TO_STANDBY    constant        number := 2;
  C_CONNECT_TO_SIMULATED_STANDBY  constant        number := 3;

/*	Package Documentation
	=====================

	The procedures/functions are divided into two parts:

		Part I - Public Utility Methods
		Part II- Support Methods

	The support methods are for the most part informational and are not
	required for general use.
*/

/*	Part I - Public Utility Methods
	===============================

	Part I covers utility methods that are used to manage and
	control the ADG support environment.
*/

/*	Cleanup and clone
	=================

	If you clone from primary to development/test, data tables need to be
	cleaned up.

	clone_clean would be typically used for cloning. It does the following:

		Purge trace and commit_wait tables.
		Resets control data to initial values
		   - i.e. no ADG support, no RPC support, no registered
		          connections.

        clean_all is as per clone_clean with the addition of :

		Initialise the RPC package list
		Purge the concurrent programs report list.

	clean_all should only be used if you want to completely reset
	ADG support.
*/

  procedure clone_clean(p_commit boolean default true);

  procedure clean_all(p_commit boolean default true);

/*	prepare_for_rpc_system
	======================

	This procedure builds and compiles the RPC packages. To run
	both ADG and RPC support must be disabled.
*/

  procedure prepare_for_rpc_system;

/*	switch_rpc_system_on
	====================

	Switches on a prepared RPC system. The switch will fail unless
        the following is true:

		- RPC system is enabled.
		- ADG support is disabled.
		- RPC usage has been installed
		- Standby to Primary connection has been registered and is
		  valid.

	If all conditions are met, the RPC synonyms are built, the compile
	directive is set to ENABLE and RPC is marked as being enabled.

	Switching the compile directive will cause dependent package bodies
	to be invalidated. Either use standard scripts to recompile or
	use the convenience procedure,compile_rpc_dependents, to recompile
	affected packages.
*/

  procedure switch_rpc_system_on;

/*	switch_rpc_system_off
	=====================

	Switches off the RPC system. The switch will fail unless
        the following is true:

		- RPC system is enabled.
		- ADG support is disabled.

	If all conditions are met, the compile directive is set to DISABLE.

        Switching the compile directive will cause dependent package bodies
        to be invalidated. Either use standard scripts to recompile or
        use the convienence procedure,compile_rpc_dependents, to recompile
        affected packages.
*/

  procedure switch_rpc_system_off;

/*	resync_compile_directive
	========================

	If the shipped package spec for the compile directive is accidentally
	reloaded, perhaps by an incorrect inclusion in a patch, it is possible
	that the RPC system will be effectively disabled.

	This procedure validates that the internal RPC state is in sync
	with the compile directive. If they are out of sync [ source of truth
	being the internal RPC state ] then the compile directive is changed
	accordingly.
*/

  procedure resync_compile_directive;

/*	compile_rpc_dependents
	======================

	This procedure compiles all dependent package bodies used by the
	RPC system. This procedure should only be run during maintenance
	periods.
*/

  procedure compile_rpc_dependents;

/*	Managing Connections
	====================

	There are three types of database connections that can be
	registered:

		Standby -> Primary
		Primary -> Standby
	        Primary -> Simulated Standby

	When you register a connection you are registering a database link
	and connection string [ TNS alias ]. Each connection is discussed in
	turn.

	Standby -> Primary

		This is a database link that resolves to primary and is used
		from the standby to connect back to the primary for RPC
		calls.

	Primary -> Standby

		This is a database link that resolves to a standby database The
		link is not directly used but the connection string is
		used by the concurrent manager for setting the
		TWO_TASK variable.

		Up to five Primary -> Standby connections can be registered.

	Primary -> Simulated Standby

		This is a database link that resolves to primary. The
		link is not directly used but the connection string is
                used by the conncurrent manager for setting the
                TWO_TASK variable.

		Simulation is discussed further under
		set_simulated_standby_options

	All the connections must be valid before they can be used.

		Standby to Primary connection must be valid before the RPC
		system can be enabled.

		Primary to Standby must be valid for requests to be redirected
		to standby.

		Primary to Simulated Standby must be valid for requests to
		be redirected to simulated standby.
*/

/*	register_connection
	===================

	p_type	- see constants.
	p_link_name - database link name
	p_link_owner- only valid value is PUBLIC
	p_link_connstr - the TNS connect string [ alias ]
	p_create_db_link_if_undefined
		- auto create the database link. In most cases it is expected
		  that customers will create their own database links.
        p_standby_number - 1 to 5.

	A connection is not usable until is has been validated - see below.

	Prerequisites:

                - RPC system is disabled if type is Standby -> Primary.
                - ADG support is disabled.
*/

  procedure register_connection(p_type number,
                                p_link_name varchar2,
                                p_link_owner varchar2 default 'PUBLIC',
                                p_link_connstr varchar2 default null,
                                p_create_db_link_if_undefined
                                                 boolean default false,
                                p_standby_number number default null
                               );

/*	clear_connection
	================

	Clear specified connection.

	Prerequisites:

                - RPC system is disabled if type Standby -> Primary.
                - ADG support is disabled.
*/

  procedure clear_connection(p_type number,
                             p_standby_number number default null);

/*	validate_connection
	===================

	Validate specified connection.

	The validation includes connecting to the end point [ dblink ] and
	ensuring it is the correct database running in the correct mode.

        Prerequisites:

                - RPC system is disabled if type Standby -> Primary.
                - ADG support is disabled.
*/

  procedure validate_connection(p_type number,
                                p_standby_number number default null);

/*
	get_connection_data
	===================

	Retrieve connect string and state of connection.
*/

  procedure get_connection_data(p_type number,
                                p_valid out nocopy boolean,
                                p_connstr out nocopy varchar2,
                                p_standby_number number default null
                               );

/*      is_connection_registered
        ========================

        Check whether the given connect string is registered as either
        a standby or simulated standby connection.

	  p_check_valid     - connection string must be valid.
          p_check_available - connection target [ database ] must be open.
*/

  function is_connection_registered(p_connstr varchar2,
                                    p_check_valid boolean default false,
                                    p_check_available boolean default false)
              return boolean;

/*	register_standby_cm_class
	=========================

	Register the Concurrent Manager Class Id that maps
	to Include Rule for given Standby.

        Prerequisites:

                - ADG support is disabled.
		- is_standby_manager_defined() returns true - see below.
*/

  procedure register_standby_cm_class  (p_standby_number number,
                                        p_req_class_app_id number,
                                        p_req_class_id number );

/*	get_standby_cm_class
	====================

	Retreive class/app id for given standby.
*/

  procedure get_standby_cm_class       (p_standby_number number,
                                        p_req_class_app_id out nocopy number,
                                        p_req_class_id out nocopy number );

/*	is_standby_manager_defined
	==========================

	Queries FND_CONCURRENT_QUEUES to check that class/app id are
	defined as an include rule.

	Optionally check that Concurrent manager is running.
*/

  function is_standby_manager_defined(p_req_class_app_id number,
                                      p_req_class_id     number,
                                      p_must_be_running boolean) return boolean;

/*	get_standby_to_primary_dblink
	=============================

	Return standby -> primary dblink.
*/

  function get_standby_to_primary_dblink return varchar2;

/*	find_registered_standby
	=======================

	Find registered standby for given connect string.
*/

  procedure find_registered_standby(p_connstr varchar2,
                                    p_exists  out nocopy boolean,
                                    p_valid   out nocopy boolean,
                                    p_req_class_app_id out nocopy number,
                                    p_req_class_id out nocopy number
                                   );

/*	get_max_standby_systems
	=======================

	Return maximum number of standby databases supported.
*/

  function get_max_standby_systems return number;

/*	validate_adg_support
	====================

	This procedure validates all registered connections.

                - RPC system is disabled.
                - ADG support is disabled.
*/

  procedure validate_adg_support(p_no_standby_systems number default null);

/*	enable_adg_support
	==================

	Validates that all RPC dependent packages are enabled and valid.

        Prerequisites:

                - RPC system is enabled.
                - ADG support is disabled.
*/

  procedure enable_adg_support;

/*	disable_adg_support
	===================

	Disables ADG support.

        Prerequisites:

                - RPC system is enabled.
                - ADG support is enabled.
*/

  procedure disable_adg_support;

/*	is_adg_support_enabled
	======================

	Returns true if ADG support is enabled.
*/

  function is_adg_support_enabled return boolean;

/*	enable_database_triggers
	========================

	Enable schema logon,logoff and error triggers.
*/

  procedure enable_database_triggers;

/*	disable_database_triggers
	=========================

	Disable schema logon,logoff and error triggers.
*/

  procedure disable_database_triggers;

/*	set_control_options
	===================

	Control options that affect how runtime support is used.

        Prerequisites:

                - ADG support is disabled.

	p_enable_commit_wait

		If an RPC has been built to use commit-wait processing,
		then the RPC will wait until DML changes have arrived
		on the standby before returning to the caller.

		The default setting for this option is TRUE.

	p_max_commit_wait_time

		The maximum time to wait for committed changes to
		arrive on the standby.

		The default setting is 60 seconds. The maximum time allowed
		is 300 seconds.

	p_runtime_validate_timestamp

	 	Validate that the RPC timestamp is >= caller timestamp.

		Can be disabled if packages have been recompiled by patches
	 	and it is not possible to call "compile_rpc_dependents".

		The default setting for this option is TRUE.

	p_always_collect_primary_data

		Even if ADG support has not been enabled always record
		that a report has been run at least once on primary.

		The default setting for this option is TRUE.

	p_enable_redirect_if_valid

		In addition to program level options, this is a system
		wide override option to enable/disable redirection of valid
		reports.

		The default setting for this option is TRUE.

	p_enable_standby_error_checks

		If database triggers are enabled,then standby READ-WRITE
		errors are recorded for the redirected program. Errors
		will only be recorded if the the number of errors exceed
		p_standby_error_threshold

		The default setting for this option is TRUE.

	p_enable_automatic_redirection

		Reports that are valid will be automatically redirected to
		standby, regardless of requested node/connect string.

		The default setting for this option is FALSE.

	p_standby_error_threshold

		Threshold above which standby READ-WRITE errors will be
		recorded.

	p_debug_rpc

		Enable RPC trace - i.e. trace for the standby session.

		1 - SQL_TRACE

		The default setting for this option is none.

	p_debug_slave_rpc

		Enable slave RPC trace - i.e. trace for the dblink session.

		1 - SQL_TRACE

               	The default setting for this option is none.
*/

  procedure set_control_options(p_enable_commit_wait boolean default null,
                                p_max_commit_wait_time number default null,
                                p_runtime_validate_timestamp
                                                     boolean default null,
                                p_always_collect_primary_data
                                                     boolean default null,
                                p_enable_redirect_if_valid
                                                     boolean default null,
                                p_enable_standby_error_checks
                                                     boolean default null,
                                p_enable_automatic_redirection
                                                     boolean default null,
                                p_standby_error_threshold number default null,
                                p_debug_rpc number default null,
                                p_debug_slave_rpc number default null
                               );

/*	Simulated Standby
	=================

	The goal of simulated standby is to allow reports to be run on
	primary as if they were on the standby. Read-write failures
	can then be analysed and recorded.

	To effectively use simulation mode the following must be true:

		simulated standby must be enabled.
		simulated standby service must be registered
		trace directory object must be registered
		database triggers must be enabled
		simulated standby connection must be registered and valid

	With these settings in place you can set the program definition
	to use the simulated standby connect string. Alternatively
	use the auto-simulation mode.
*/

/*	set_simulated_standby_options
	=============================

	Options for controlling standby simulation.

        Prerequisites:

                - ADG support is disabled.

	p_enable_simulated_standby

		When reports connect using the simulated standby
		service and this option is enabled, RPC calls will always
		be used - i.e. fnd_adg_support.is_standby will return true
		for primary sessions.

		To capture read-write violations, databases triggers
		must be enabled - see enable_database_triggers.

		The default setting for this option is TRUE.

	p_enable_auto_simulation

		This option will automatically direct requests to
		use simulation mode if not already done so.

		The default setting for this option is FALSE.

	p_simulated_standby_service

		The service used to identify a simulation session.

		If database triggers have been enabled, then the logon
		trigger checks to see which service a session is using.
		If it is this service and p_enable_simulated_standby is true,
		then the session is treated as being run on standby.

	p_simulation_error_threshold

		If running as a simulation session, then on logoff the
		session trace file is analysed and the number of
		read-write violations determined.  If the number of
		errors exceeds this threshold, then the difference is
		recorded for the program.

	p_trace_directory_obj

		The database directory object for the trace file directory.
*/

  procedure set_simulated_standby_options(p_enable_simulated_standby
                                                 boolean default null,
                                          p_enable_auto_simulation
                                                 boolean default null,
                                          p_simulated_standby_service
                                                 varchar2 default null,
                                          p_simulation_error_threshold
                                                 number default null,
                                          p_trace_directory_obj
                                                 varchar2 default null);

/*	Managing concurrent programs
	============================

	The ADG state for concurrent programs is managed by the
	manage_concurrent_program procedure.

	The underlying table is fnd_adg_concurrent_program and maps one-to-one
        with FND_CONCURRENT_PROGRAM. The table is dynamically populated but
	can be pre-populated - e.g.

               declare
                  cursor c1 is select a.APPLICATION_ID,a.CONCURRENT_PROGRAM_ID
                                 from fnd_concurrent_programs a;
               begin
                  for f_rec in c1 loop
                    fnd_adg_utility.manage_concurrent_program
                        (p_application_id => f_rec.APPLICATION_ID,
                         p_concurrent_program_id => f_rec.CONCURRENT_PROGRAM_ID
                        );
                  end loop;
               end;

	The state flags are also managed dynamically but can be overridden
	through the manage_concurrent_program API.

	For a concurrent program to be valid for standby the following must
	be true:

		p_has_run_on_primary is TRUE
		p_has_run_on_simulated_standby is TRUE
		p_run_on_standby is TRUE

		p_no_standby_failures < p_max_standby_failures and
		p_no_simulated_stdby_failures < p_max_simulated_stdby_failures

		If concurrent manager is not running
		then
		   p_always_redirect_if_valid is TRUE
                end if

		If Request:connstr is not a valid standby connection
                then
		   p_use_automatic_redirection is TRUE
                end if
*/

/*	manage_concurrent_program
	=========================

	p_application_id,
        p_concurrent_program_id

		FND_CONCURRENT_PROGRAM primary key.

	p_has_run_on_primary

		Set flag to indicate whether program has been run on primary.

		Default value is FALSE.

	p_has_run_on_simulated_standby

		Set flag to indicate whether program has run on simulated
		standby.

		Default value is FALSE.

	p_run_on_standby

		Set flag to indicate that report can run on standby.

		Default value is FALSE.

 	p_no_standby_failures

		Set/reset the number of standby failovers for this program.

		Default value is zero.

	p_max_standby_failures

		Maximum number of allowed standby failovers before
		p_run_on_standby is set to FALSE.

		Default value is zero.

	p_no_simulated_stdby_failures

		Set/reset the number of simulated standby failovers.

		Default value is zero.

	p_max_simulated_stdby_failures

		Maximum number of simulated standby failovers. If the number
		of simulated standby failovers exceeds the maximum, the request
		will be marked as not runnable on standby.

		Default value is zero.

	p_always_redirect_if_valid

		Program level option to always redirect valid reports to
		standby regardless of the state of the concurrent managers -
		i.e. if concurrent manager is inactive, report will just sit
		in the queue.

		Has no effect unless the control option
                "p_enable_redirect_if_valid" is also enabled.

		Default value is TRUE.

	p_use_automatic_redirection

 		If the report can be run on standby, then automatically
		redirect to the first available ADG database, ignoring
		any primary instance/node affinity.

		Default value is FALSE.
*/

  procedure manage_concurrent_program
                         (p_application_id              number,
                          p_concurrent_program_id       number,
                          p_has_run_on_primary          boolean default null,
                          p_has_run_on_simulated_standby boolean default null,
                          p_run_on_standby              boolean default null,
                          p_no_standby_failures         number default null,
                          p_max_standby_failures        number default null,
                          p_no_simulated_stdby_failures number default null,
                          p_max_simulated_stdby_failures number default null,
                          p_always_redirect_if_valid    boolean default null,
                          p_use_automatic_redirection   boolean default null
                         );

/*	purge_commit_wait_data
	======================

	Purge old commit-wait data.
*/

  procedure purge_commit_wait_data;

/*      Part II- Support Methods
        ========================

        These methods are for the most part informational.
*/

/*	is_standby_access_supported
	===========================

	Returns true if database version is >= 11.
*/

  function is_standby_access_supported return boolean;

/*	is_session_simulated_standby
	============================

	Returns true if session is running as a simulated standby session.
*/

  function is_session_simulated_standby return boolean;

/*	is_simulated_standby_enabled
	============================

	Returns true if this option has been enabled.
		- see set_simulated_standby_options.
*/

  function is_simulated_standby_enabled return boolean;

/*	is_auto_simulation_enabled
	==========================

	Returns true if this option has been enabled.
		- see set_simulated_standby_options.
*/

  function is_auto_simulation_enabled return boolean;

/*	is_automatic_redirection
	========================

	Returns true if this option has been enabled.
		- see set_control_options.
*/

  function is_automatic_redirection return boolean;

/*	is_commit_wait_enabled
	======================

	Returns true if this option has been enabled.
		- see set_control_options.
*/

  function is_commit_wait_enabled return boolean;

/*	is_runtime_validate_timestamp
	=============================

	Returns true if this option has been enabled.
		- see set_control_options.
*/

  function is_runtime_validate_timestamp return boolean;

/*	is_always_collect_primary_data
	==============================

	Returns true if this option has been enabled.
		- see set_control_options.
*/

  function is_always_collect_primary_data return boolean;

/*	is_enable_redirect_if_valid
	===========================

	Returns true if this option has been enabled.
                - see set_control_options.
*/

  function is_enable_redirect_if_valid return boolean;

/*	get_rpc_debug
	=============

	Get the rpc debug options
		- see set_control_options.
*/

  procedure get_rpc_debug(p_debug_rpc out nocopy number,
                          p_debug_slave_rpc out nocopy number);

/*	get_max_commit_wait_time
	========================

	Return the maximum commit wait time
		 see set_control_options.
*/

  function get_max_commit_wait_time return number;

/*	get_standby_error_threshold
	===========================

	Returns standby error threshold
		- see set_control_options.
*/

  function get_standby_error_threshold return number;

/*	get_simulation_error_threshold
	==============================

	Returns simulation error threshold
		- see set_simulated_standby_options.
*/

  function get_simulation_error_threshold return number;

/*	is_standby_error_checking
	=========================

	Returns true if this option has been enabled.
                - see set_control_options.
*/

  function is_standby_error_checking return boolean;

/*	process_adg_violations
	======================

	Called during logoff processing for simulated standby session.
*/

  procedure process_adg_violations(p_logoff boolean,
                                   p_application_id number default null,
                                   p_concurrent_program_id number default null);

/*	enable_violation_trace
	======================

	Called during logon rocessing for simulated standby session.
*/

  procedure enable_violation_trace;

/*	disable_violation_trace
	=======================

        Called during logoff processing for simulated standby session.
*/

  procedure disable_violation_trace;

/*	get_program_access_code
	=======================

	Internal security check function.
*/

  function get_program_access_code return number;

/*	disable_control_cache
	=====================

	Disable control record caching - see enable_control_cache.
*/

  procedure disable_control_cache(p_previous_state boolean default false);

/*	enable_control_cache
	====================

        Improve performance of ADG control queries by caching the control
        record. The control data is rarely changed so runtime caching
        improves performance.
*/

  function enable_control_cache return boolean;

/*	refresh_control_cache
	=====================

	Refresh cached copy of control record.
*/

  procedure refresh_control_cache;

end fnd_adg_utility;

/
