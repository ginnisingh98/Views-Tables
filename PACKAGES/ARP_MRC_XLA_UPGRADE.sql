--------------------------------------------------------
--  DDL for Package ARP_MRC_XLA_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_MRC_XLA_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: ARMXLAUS.pls 120.1 2006/04/05 10:25:53 jvarkey noship $ */

PROCEDURE UPGRADE_MC_TRANSACTIONS(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2,
                       l_entity_type  IN VARCHAR2 DEFAULT NULL);

PROCEDURE UPGRADE_MC_RECEIPTS(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2,
                       l_entity_type  IN VARCHAR2 DEFAULT NULL);

PROCEDURE UPGRADE_MC_ADJUSTMENTS(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2,
                       l_entity_type  IN VARCHAR2 DEFAULT NULL);

END ARP_MRC_XLA_UPGRADE;

 

/
