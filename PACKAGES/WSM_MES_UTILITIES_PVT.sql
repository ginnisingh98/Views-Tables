--------------------------------------------------------
--  DDL for Package WSM_MES_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSM_MES_UTILITIES_PVT" AUTHID CURRENT_USER AS
/* $Header: WSMMESUS.pls 120.5 2006/08/10 09:13:23 mprathap noship $ */

mrp_debug      varchar2(1):= fnd_profile.value('mrp_debug');


/*
 * Will return a codemask, indicate whether move in, move out, move to next is allowed
 *
 * 2^16 = 65536     move in
 * 2^17 = 131072    move out
 * 2^18 = 262144    move to next op
 */
function move_txn_allowed(
            p_responsibility_id         in number,
            p_wip_entity_id             in number,
            p_org_id                    in number,
            p_job_op_seq_num            in number,
            p_standard_op_id            in number,
            p_intraop_step              in number,
            p_status_type               in number
) return number;


/*
 * Will return 1 if allowed, 0 otherwise
 *
 * p_transaction_type:
 *
 * 2^4  = 16            Split Job
 * 2^5  = 32            Merge Jobs
 * 2^6  = 64            Update Assembly
 * 2^7  = 128           Update Routing
 * 2^8  = 256           Update Lot Name
 * 2^9  = 512           Update Quantity
 * 2^10 = 1024          Transact Materials
 * 2^11 = 2048          Jump To Operation
 * 2^12 = 4096          Undo Move
 */
procedure wsm_transaction_allowed(
            p_transaction_type          in number,
            p_responsibility_id         in number,
            p_wip_entity_id             in number,
            p_org_id                    in number,
            p_job_op_seq_num            in number,
            p_standard_op_id            in number,
            p_intraop_step              in number,
            p_status_type               in number,
            x_allowed                   out nocopy number,
            x_error_msg_name            out nocopy varchar2
);

/*
 * Will return 1 if job status changed, 0 otherwise
 */
function wsm_job_changed(
            p_wip_entity_id             in number,
            p_job_op_seq_num            in number,
            p_intraop_step              in number,
            p_status_type               in number,
            p_quantity                  in number,
            p_job_name                  in varchar2
) return number;


/*
 * find corrent job operations for that is with a give resource / instance
 */
function get_current_job_op (
        p_organization_id               in number,
        p_department_id                 in number,
        p_resource_id                   in number,
        p_instance_id                   in number,
        p_serial_number                 in varchar2) return varchar2;

/*
 * Bugfix 5356648 OSP warnings.  Check for po reqs and orders.
 */
function check_po_req_exists(
	p_txn_type			in number,
	p_wip_entity_id			in number) return number;
--Bug 5409116: Function to get the share_from_dept_id of a given
--resource and department is added.
function get_share_from_dept(
        p_department_id                 in number,
        p_resource_id                   in number) return number;

END;

 

/
