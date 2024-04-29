--------------------------------------------------------
--  DDL for Package FND_ADG_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ADG_SUPPORT" AUTHID CURRENT_USER as
/* $Header: AFDGSUPS.pls 120.1.12010000.3 2010/09/17 16:16:18 rsanders noship $ */

/*      fnd_adg_support
        ===============

        This package is part of Active Data Guard [ADG ] support.

        Although it is not an internal package, the only methods that
	developers should ever need to call are:

		 is_standby
		 is_connstr_registered

	The other methods are not required for RPC coding.
*/

/*	Constants
	=========

	Oracle Read Only Error number
*/

   C_READ_ONLY_ERROR	constant	number 	:= 16000;

/*	is_standby
	==========

	This method is public and returns true if standby RPC code should
	be executed:

	  - "if is_standby " to demarcate RPC calls.
	  - "if not is_standby " to demarcate code that should not run
 		                 on the standby process.

	is_standby returning TRUE does not mean that the session is
	running on a standby instance. In simulation mode, is_standby will
	return TRUE on primary. Users need not be concerned about this -
        they just need to follow the above coding rules.

	So long as is_standby is used for demarcation that's all that matters.

	Because of simulation mode, never use is_standby to determine whether
	you are running on a standby instance.

	If you ever need to do this, use is_true_standby.
*/

   function is_standby return boolean;

/*	is_primary
	==========

	Return true if running on a READ-WRITE primary database.
*/

   function is_primary return boolean;

/*	is_connstr_registered
	=====================

	This function is for concurrent manager support. It checks
        whether the given connect string is registered as either
        a standby or simulated standby connection.

	The default is to just check that the connect string has been
	registered. This is acceptable for admin forms.

	The concurrent managers should in addition check that the connection
	string is valid. The manager can optionally check that the target
	database is open.

          p_check_valid     - connection string must be valid and
			      ADG support enabled.
          p_check_available - connection target [ database ] must be open.

*/

   function is_connstr_registered(p_connstr varchar2,
                                  p_check_valid boolean default false,
                                  p_check_available boolean default false)
                 return boolean;

   function is_connstr_registered(p_connstr varchar2,
                                  p_check_valid number,
                                  p_check_available number)
                        return number;

/*	is_rpc_from_standby
	===================

	Returns true if the session is a slave RPC session
	  - wrapper for fnd_adg_manage.is_session_slave_to_standby
*/


   function is_rpc_from_standby return boolean;

/*	log_unhandled_exception
	=======================

	Logs information to the trace file for unhandled exceptions.
*/

   procedure log_unhandled_exception(p_location varchar2,p_sqlerr varchar2);

/*	is_true_standby
	===============

	Returns true if running on a READ-ONLY standby database.
*/

   function is_true_standby return boolean;

/*	handle_request_row_change
	=========================

	Invoked by INSERT/UPDATE row trigger on FND_CONCURRENT_REQUESTS.

	Only the INSERT trigger will update the column values.

	The values that can be changed are :

		p_connstr1
		p_nodename1
		p_request_class_application_id
		p_concurrent_request_class_id

	which map to the corresponding table columns.
*/

   procedure handle_request_row_change(p_is_inserting boolean,
                                       p_program_application_id number,
                                       p_concurrent_program_id number,
                                       p_connstr1 in out nocopy varchar2,
                                       p_nodename1 in out nocopy varchar2,
                                       p_request_class_application_id
                                                  in out nocopy number,
                                       p_concurrent_request_class_id
                                                  in out nocopy number,
                                       p_phase_code varchar2,
                                       p_status_code varchar2
                                      );

/*	handle_concurrent_program
	=========================

	This procedure is for administrative updates to
	FND_ADG_CONCURRENT_PROGRAM.

	It is never called directly - always use
		fnd_adg_utility.manage_concurrent_program
*/

   procedure handle_concurrent_program
                       (p_code                        number,
                        p_application_id              number,
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

/*	handle_standby_error
	====================

	This procedure is used to record either standby or
	simulation errors. It is called either as a result of an
	RPC call [ standby error trigger ] or at the end of a
	simulation run.
*/

   procedure handle_standby_error ( p_request_id number,
                                    p_simulation boolean,
                                    p_logoff boolean,
                                    p_error_count number);

/*	handle_standby_error
	====================

	As per previous procedure except uses app/program ids
	rather than request_id.
*/

   procedure handle_standby_error ( p_program_application_id number,
                                    p_concurrent_program_id number,
                                    p_simulation boolean,
                                    p_logoff boolean,
                                    p_error_count number);

end fnd_adg_support;

/
