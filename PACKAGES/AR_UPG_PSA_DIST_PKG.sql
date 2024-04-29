--------------------------------------------------------
--  DDL for Package AR_UPG_PSA_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_UPG_PSA_DIST_PKG" AUTHID CURRENT_USER AS
/* $Header: ARPSAUPS.pls 120.0 2006/08/16 21:51:41 hyu noship $ */

PROCEDURE upgrade_adjustments(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2);

PROCEDURE upgrade_applications(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2);

PROCEDURE upgrade_misc_cash_dist(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2);

PROCEDURE UPGRADE_TRANSACTIONS(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2);


END;

 

/
