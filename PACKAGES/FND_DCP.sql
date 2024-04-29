--------------------------------------------------------
--  DDL for Package FND_DCP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DCP" AUTHID CURRENT_USER as
/* $Header: AFCPDCPS.pls 120.3 2007/12/07 19:09:32 ckclark ship $ */

	procedure get_lk_handle	(apid	in     number,
				 qid	in     number,
				 pid	in     number,
				 hndl	in out nocopy varchar2,
				 e_code in out nocopy number,
				 exp_sec in number default 86400000);

        procedure check_process_status_by_handle (hndl   in   varchar2,
                                 result  out   nocopy number,
                                 alive   out   nocopy number);

        procedure check_process_status_by_ids (apid    in     number,
                                 qid     in     number,
                                 pid     in     number,
                                 result  out    nocopy number,
                                 alive   out    nocopy number);

	procedure request_session_lock	(apid	 in     number,
				 qid	 in     number,
				 pid	 in     number,
				 lk	 in out nocopy varchar2,
				 hndl	 in out nocopy varchar2,
				 result	 in out nocopy number);

  -- ### OVERLOADED ###
  /*------------------------------------------------------------------|
   | Obsolete: Please use request_session_lock,                       |
   |           check_process_status_by_handle, or                     |
   |           check_process_status_by_ids                            |
   +------------------------------------------------------------------*/
	procedure request_lock	(apid	in     number,
				 qid	in     number,
				 pid	in     number,
				 lk	in out nocopy varchar2,
				 hndl	in out nocopy varchar2,
				 e_code in out nocopy number);

  -- ### OVERLOADED ###
  /*------------------------------------------------------------------|
   | Obsolete: Please use request_session_lock,                       |
   |           check_process_status_by_handle, or                     |
   |           check_process_status_by_ids                            |
   +------------------------------------------------------------------*/
	procedure request_lock	(hndl	in     varchar2,
				 status	in out nocopy number,
				 e_code in out nocopy number);

	procedure release_lock	(hndl	in     varchar2,
				 e_code in out nocopy number);

	procedure reassign_lkh	(e_code in out nocopy number);

	procedure clean_mgrs	(e_code in out nocopy number);

	procedure monitor_icm	(hndl   in out nocopy varchar2,
				 up	in out nocopy number,
				 logf	in out nocopy varchar2,
				 node	in out nocopy varchar2,
				 inst	in out nocopy varchar2,
				 cpid   in out nocopy number,
				 mthd	in     number,	-- PMON method
				 e_code in out nocopy number);

	procedure monitor_im	(apid	in     number,
				 qid	in     number,
				 pid	in     number,
				 cnode  in     varchar2,
				 status	in out nocopy number,
				 e_code in out nocopy number);

	/* function get_inst_num
	 *
	 * This function is used to determine the OPS instance
	 * to which a manager should "specialize".  For Parallel
         * Concurrent Processing, we want the a manager to
         * service requests only for the instance associated with
         * its primary node.
	 *
         */
	function get_inst_num	(queue_appl_id	in	number,
				 queue_id	in	number,
				 current_node	in	varchar2)
				return number;

  /* function target_node_mgr_chk
   * If a request is targeted to a specific node, the concurrent
   * manager will use this function in his request query (afpgrq)
   * to filter it out if it doesn't meet any of the following conditions:
   * a) request's target node is the same as manager's current node
   * b)	request's target node is different from manager's current node, but the
   *    FND_NODES status is 'N' or node_mode is not 'O' (online).
   * c)	There are no managers specialized to run this request on request's
   *    target node
   *
   * Parameters:
   *   request_id - id of request that is targeted to a secific node
   *
   * Returns:
   *   NTRUE/TRUE/1   if this request can appear in query results
   *   NFALSE/FALSE/0 if this request should be filtered from query results
   *
   * Assumptions:
   *   The manager's target_node in fnd_concurrent_queues is it's current
   *   node.  This should always be true for active managers in afpgrq.
   *
   * Error conditions:
   *
   *   All other exceptions are unhandled.
   */

   function target_node_mgr_chk (req_id  in number) return number;

  --
  -- Name
  --   is_dcp
  -- Purpose
  --   Returns TRUE if the environment has multiple CP nodes,
  --   FALSE if not.
  --
  -- Parameters:
  -- None
  --
  -- Returns:
  --   NTRUE/TRUE/1   - environment is DCP
  --   NFALSE/FALSE/0 - environment is non-DCP
  --
  function is_dcp return number;

end FND_DCP;

/

  GRANT EXECUTE ON "APPS"."FND_DCP" TO "EM_OAM_MONITOR_ROLE";
