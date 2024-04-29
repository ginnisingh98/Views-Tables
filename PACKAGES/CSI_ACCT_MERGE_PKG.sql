--------------------------------------------------------
--  DDL for Package CSI_ACCT_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ACCT_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: csiatmgs.pls 120.0.12000000.1 2007/01/16 15:29:56 appldev ship $ */

   PROCEDURE MERGE(req_id   IN NUMBER,
                   set_num   IN NUMBER,
                   process_mode IN VARCHAR2);

   PROCEDURE CSI_ITEM_INSTANCES_MERGE(req_id   IN NUMBER,
			         set_num   IN NUMBER,
			         process_mode IN VARCHAR2);

   PROCEDURE CSI_SYSTEMS_B_MERGE(req_id   IN NUMBER,
			         set_num   IN NUMBER,
			         process_mode IN VARCHAR2);

   PROCEDURE CSI_IP_ACCOUNTS_MERGE(req_id   IN NUMBER,
			           set_num   IN NUMBER,
  			           process_mode IN VARCHAR2);

   PROCEDURE CSI_T_PARTY_ACCOUNTS_MERGE(req_id   IN NUMBER,
			                set_num   IN NUMBER,
  			                process_mode IN VARCHAR2);

   PROCEDURE CSI_T_TXN_SYSTEMS_MERGE(req_id   IN NUMBER,
			             set_num   IN NUMBER,
  			             process_mode IN VARCHAR2);

   g_debug_on   number := to_number(nvl( fnd_profile.value('CSI_DEBUG_LEVEL'), '0'));


END CSI_ACCT_MERGE_PKG;

 

/
