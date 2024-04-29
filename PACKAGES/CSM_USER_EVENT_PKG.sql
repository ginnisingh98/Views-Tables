--------------------------------------------------------
--  DDL for Package CSM_USER_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_USER_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmeusrs.pls 120.6.12010000.1 2008/07/28 16:15:05 appldev ship $ */

-- Generated 6/13/2002 8:01:57 PM from APPS@MOBSVC01.US.ORACLE.COM

--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date       Comments
-- saradhak   6-Dec-2005  added spawn_perz_ins and spawn_dashboard_srch_cols_ins
-- ---------   ------     ------------------------------------------
   -- Enter package declarations as shown below

FUNCTION is_omfs_palm_responsibility(p_responsibility_id IN NUMBER, p_user_id IN NUMBER) RETURN BOOLEAN;

PROCEDURE disable_user_pub_synch(p_user_id IN NUMBER);

FUNCTION is_first_omfs_palm_user(p_user_id IN NUMBER) RETURN BOOLEAN;

PROCEDURE user_resp_ins_initializer (p_responsibility_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE spawn_task_ins(p_user_id IN NUMBER);

PROCEDURE spawn_incident_ins(p_user_id IN NUMBER);

PROCEDURE spawn_task_assignment_ins(p_user_id IN NUMBER);

PROCEDURE spawn_perz_ins(p_user_id IN NUMBER);

PROCEDURE spawn_dashboard_srch_cols_ins(p_user_id IN NUMBER);

PROCEDURE items_acc_processor(p_user_id IN NUMBER);

PROCEDURE spawn_inv_loc_assignment_ins(p_resource_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE spawn_po_loc_ass_all_ins(p_resource_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE spawn_csp_req_headers_ins(p_resource_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE spawn_csp_req_lines_ins(p_resource_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE enable_user_pub_synch(p_user_id IN NUMBER);

PROCEDURE user_del_init(p_user_id IN NUMBER);

PROCEDURE purge_all_acc_tables(p_user_id IN NUMBER);

--Bug
PROCEDURE spawn_mat_txn(p_user_id IN NUMBER);

PROCEDURE spawn_mtl_serial_Numbers(p_resource_id IN NUMBER,p_user_id IN NUMBER);

--12.1
PROCEDURE INSERT_ACC (p_user_id IN NUMBER
                                    ,x_return_status OUT NOCOPY VARCHAR2
                                    , x_error_message OUT NOCOPY VARCHAR2);

PROCEDURE DELETE_ACC (p_user_id IN NUMBER
                                    ,x_return_status OUT NOCOPY VARCHAR2
                                    , x_error_message OUT NOCOPY VARCHAR2);

PROCEDURE INSERT_ACC (p_user_id IN NUMBER,p_owner_id IN NUMBER);

PROCEDURE DELETE_ACC (p_user_id IN NUMBER,p_owner_id IN NUMBER);

END; -- Package spec


/
