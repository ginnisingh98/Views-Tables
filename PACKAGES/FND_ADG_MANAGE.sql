--------------------------------------------------------
--  DDL for Package FND_ADG_MANAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ADG_MANAGE" AUTHID CURRENT_USER as
/* $Header: AFDGMGRS.pls 120.0.12010000.2 2010/09/17 16:30:07 rsanders noship $ */

/*      fnd_adg_manage
        ==============

        This package is part of Active Data Guard [ADG ] support.

	It is for INTERNAL use only and is NEVER referenced outside of
	FND_ADG packages. It should never be called by product developers.

	Documentation is intended only for developers maintaining this package.
*/

/*	validate_standby_to_primary
	===========================

	This is a support function invoked by the RPC packages. It is a
	runtime check that the database link resolves to the correct primary
	database. It is a protection against DB link and TNS alias
	tampering.
*/

  procedure validate_standby_to_primary
                      (p_err out nocopy number,
                       p_msg out nocopy varchar2,
                       p_once_per_session boolean default false);

/*	validate_primary_private
	========================

	This method is the RPC called invoked by validate_standby_to_primary.
	Although private it of course must be in the spec. in order for the
	RPC to work.
*/

  procedure validate_primary_private(p_dbid number, p_dbname varchar2,
                                     p_slave_session_id out nocopy number,
                                     p_sid number, p_serial number,
                                     p_audsid number,p_is_true_standby boolean,
                                     p_valid out nocopy number);

/*	rpcDescriptor
	=============

	This is used in the RPC packages to record package information. The data
	is used for runtime and compile time support.
*/

  type rpcDescriptor is record
     ( owner            fnd_adg_package.owner%type,
       package_name	fnd_adg_package.package_name%type,
       rpc_package_name fnd_adg_package.rpc_package_name%type,
       rpc_synonym_name fnd_adg_package.rpc_synonym_name%type,
       method_name      varchar2(30),
       auto_tx_wrapper  varchar2(10),
       use_commit_wait_on_autotx varchar2(10)
     );

/*	raise_rpc_exec_error
	====================

	This is used by the RPC packages to format are raise RPC runtime
	errors.
*/

  procedure raise_rpc_exec_error(p_rpcDescriptor rpcDescriptor,
                                 p_location varchar2,
                                 p_additional_info varchar2 default null);

/*	validate_rpc_timestamp
	======================

	This is used by the RPC packages for runtime validation. It ensures
	that the RPC package timestamp is ahead of the referencing package. This
	should always be the case as the RPC spec. has an embedded constant
	time string which ensures that the RPC spec is always compiled.

	It is possible to disable this validation if you need to apply
	a patch to the referencing package. See

	  fnd_adg_utility.set_control_options
                     ( ... p_runtime_validate_timestamp ... )

	Howeever, a better solution is to just switch the rpc state off and on.
*/

  function  validate_rpc_timestamp(p_rpcDescriptor rpcDescriptor) return boolean;

/*	validate_rpc_synonym
	====================

  	This is used by the RPC packages for runtime validation. It checks that
	the synonym used to invoke the remote package resolves to the same
	link used by validate_standby_to_primary. This protects against
	db link and TNS alias tampering.
*/

  function  validate_rpc_synonym(p_rpcDescriptor rpcDescriptor) return boolean;

/*	is_session_slave_to_standby
	===========================

	Returns true if the session is the slave RPC session running
	on primary. Used internally for simulation support - see
	fnd_adg_support.
*/

  function is_session_slave_to_standby return boolean;

/*	handle_rpc_debug
	================

	This is used in the RPC packages to enable standby trace.

	Currently only SQL_TRACE is supported. It is enabled via:

	   fnd_adg_utility.set_control_options
                     ( ... p_debug_rpc ... )

	See fnd_adg_utility for further details.
*/

  procedure handle_rpc_debug(p_once_per_session boolean default true);

/*	handle_slave_rpc_debug
	======================

        This is used in the RPC packages to enable slave RPC trace - i.e.
	the session running on the primary.

        Currently only SQL_TRACE is supported. It is enabled via:

           fnd_adg_utility.set_control_options
                     ( ... p_debug_slave_rpc ... )

        See fnd_adg_utility for further details.

*/

  procedure handle_slave_rpc_debug(p_once_per_session boolean default true);

/*	get_commit_wait_seq
	===================

	This is used in the RPC packages to record the commit wait
	sequence when commit-wait processing has been enabled. Used by the
	RPC session.
*/

  function get_commit_wait_seq(p_rpcDescriptor rpcDescriptor) return number;

/*	increment_commit_count
	======================

	This is used in the RPC packages to increment the commit wait
	count when commit-wait processing has been enabled. Used by the
	slave RPC session.
*/

  procedure increment_commit_count(p_rpcDescriptor rpcDescriptor);

/*	wait_for_commit_count
	=====================

	This is used in the RPC packages to wait for the next commit sequence
	to arrive on the standby. Used by the RPC session.
*/

  function wait_for_commit_count(p_rpcDescriptor rpcDescriptor,
                                 p_wait_seq number) return boolean;

/*	boolean_to_char
	===============

	Support function to convert boolean to Y|N.
*/

  function boolean_to_char(p_bool boolean) return varchar2;

/*	invoke_standby_error_handler
	============================

	This is used by the error handler trigger. It is the slave RPC
	entry point to record read only errors - i.e. it is invoked as an
	RPC.
*/

  procedure invoke_standby_error_handler(p_request_id number);

/*	rpc_invoke_standby_error
	========================

	This is used by the error handler trigger. It is the RPC entry point for
	remote execution of invoke_standby_error_handler.
*/

  procedure rpc_invoke_standby_error ( p_request_id number);

end fnd_adg_manage;

/
