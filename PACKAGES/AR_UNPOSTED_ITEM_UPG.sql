--------------------------------------------------------
--  DDL for Package AR_UNPOSTED_ITEM_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_UNPOSTED_ITEM_UPG" AUTHID CURRENT_USER AS
/* $Header: ARCBUPGS.pls 120.0 2006/07/25 22:01:09 hyu noship $ */
PROCEDURE upgrade_11i_cash_basis
(l_table_owner  IN VARCHAR2, -- AR
 l_table_name   IN VARCHAR2, -- AR_RECEIVABLE_APPLICATIONS_ALL
 l_script_name  IN VARCHAR2, -- ar120cbupi.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2);

PROCEDURE upgrade_11i_cm_cash_basis
(l_table_owner  IN VARCHAR2, -- AR
 l_table_name   IN VARCHAR2, -- AR_RECEIVABLE_APPLICATIONS_ALL
 l_script_name  IN VARCHAR2, -- ar120cbupi.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2);

END;

 

/
