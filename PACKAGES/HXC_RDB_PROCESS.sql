--------------------------------------------------------
--  DDL for Package HXC_RDB_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RDB_PROCESS" AUTHID CURRENT_USER AS
/* $Header: hxcrdbproc.pkh 120.0.12010000.4 2010/05/05 12:07:22 asrajago noship $ */


TYPE VARCHARTABLE IS TABLE OF NUMBER INDEX BY VARCHAR2(50);
g_conc_id VARCHARTABLE;

PROCEDURE  SUBMIT_REQUEST ( p_application   IN VARCHAR2,
                            p_ret_user_id   IN NUMBER,
                            p_start_date    IN VARCHAR2 DEFAULT NULL,
                            p_end_date      IN VARCHAR2 DEFAULT NULL,
                            p_gre_id        IN NUMBER   DEFAULT NULL,
                            p_org_id        IN NUMBER   DEFAULT NULL,
                            p_loc_id        IN NUMBER   DEFAULT NULL,
                            p_payroll_id    IN NUMBER   DEFAULT NULL,
                            p_person_id     IN NUMBER   DEFAULT NULL,
                            p_trans_code    IN VARCHAR2 DEFAULT NULL,
                            p_old_new       IN VARCHAR2 DEFAULT NULL,
                            p_batch_ref     IN VARCHAR2 DEFAULT NULL,
                            p_new_batch_ref IN VARCHAR2 DEFAULT NULL,
                            p_bee_status    IN VARCHAR2 DEFAULT NULL,
                            p_changes_since IN VARCHAR2 DEFAULT NULL,
                            p_op_unit       IN NUMBER   DEFAULT NULL,
                            p_request_id    OUT NOCOPY NUMBER ) ;

PROCEDURE load_conc_ids;

PROCEDURE refresh;


END HXC_RDB_PROCESS;


/
