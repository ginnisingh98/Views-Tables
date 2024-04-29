--------------------------------------------------------
--  DDL for Package AR_LATE_CHARGE_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_LATE_CHARGE_UPG" AUTHID CURRENT_USER AS
/* $Header: ARLCUPS.pls 120.2 2006/06/28 21:32:48 hyu noship $ */

FUNCTION f_number(p_val IN VARCHAR2) RETURN NUMBER;

FUNCTION f_date(p_value IN VARCHAR2) RETURN DATE;


PROCEDURE upgrade_schedule
(l_table_owner  IN VARCHAR2, -- JG
 l_table_name   IN VARCHAR2, -- JG_ZZ_II_INT_RATES
 l_script_name  IN VARCHAR2, -- ar120lcjgr.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2);

PROCEDURE upgrade_profile_amount
(l_table_owner  IN VARCHAR2, -- AR
 l_table_name   IN VARCHAR2, -- HZ_CUST_PROFILE_AMTS
 l_script_name  IN VARCHAR2, -- ar120lccpa.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2);

PROCEDURE upgrade_profile
(l_table_owner  IN VARCHAR2, -- AR
 l_table_name   IN VARCHAR2, -- HZ_CUSTOMER_PROFILES
 l_script_name  IN VARCHAR2, -- ar120lccp.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2);

PROCEDURE upgrade_profile_class_amount
(l_table_owner  IN VARCHAR2, -- AR
 l_table_name   IN VARCHAR2, -- HZ_CUST_PROF_CLASS_AMTS
 l_script_name  IN VARCHAR2, -- ar120lccpca.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2);


PROCEDURE upgrade_profile_class
(l_table_owner  IN VARCHAR2, -- AR
 l_table_name   IN VARCHAR2, -- HZ_CUST_PROFILE_CLASSES
 l_script_name  IN VARCHAR2, -- ar120lccpc.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2);

PROCEDURE upgrade_lc_sysp
(l_table_owner  IN VARCHAR2, -- AR
 l_table_name   IN VARCHAR2, -- AR_SYSTEM_PARAMETERS_ALL
 l_script_name  IN VARCHAR2, -- ar120lcsysp.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2);

PROCEDURE upgrade_ps_for_adj
(l_table_owner  IN VARCHAR2, -- AR
 l_table_name   IN VARCHAR2, -- HZ_CUST_SITE_USES_ALL
 l_script_name  IN VARCHAR2, -- ar120lccsups.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2);

PROCEDURE upgrade_lc_site_use
(l_table_owner  IN VARCHAR2, --AR
 l_table_name   IN VARCHAR2, --HZ_CUST_ACCT_SITES_ALL
 l_script_name  IN VARCHAR2, --ar120lclcsu.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2);

END;

 

/
