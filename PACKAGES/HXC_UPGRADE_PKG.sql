--------------------------------------------------------
--  DDL for Package HXC_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_UPGRADE_PKG" 
/* $Header: hxcupgpkg.pkh 120.0.12010000.6 2010/02/22 13:15:59 asrajago noship $ */
AUTHID CURRENT_USER AS

    TYPE VARCHARTABLE IS TABLE OF VARCHAR2(2500);
    TYPE NUMTABLE IS TABLE OF NUMBER;
    TYPE DATETABLE IS TABLE OF DATE;


    TYPE VARCHAR_ASSOCARRAY IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(50);
    g_upg_name  VARCHAR_ASSOCARRAY;

  PROCEDURE upgrade( errbuff   OUT NOCOPY VARCHAR2,
                     retcode   OUT NOCOPY NUMBER,
                     p_type IN VARCHAR2,
                     p_stop_after IN NUMBER DEFAULT -999,
                     p_num_workers IN NUMBER DEFAULT -1);

  PROCEDURE upgrade_wk( errbuff  OUT NOCOPY VARCHAR2,
                        retcode  OUT NOCOPY VARCHAR2,
                        p_type   IN VARCHAR2,
                        p_start  IN NUMBER,
                        p_stop   IN NUMBER,
                        p_stop_after IN NUMBER DEFAULT -999);

 PROCEDURE put_log(p_text   IN VARCHAR2);

 PROCEDURE insert_into_upg_defn
                  (p_upg_type   IN VARCHAR2);

 FUNCTION ret_upgrade_completed
 RETURN BOOLEAN;

 FUNCTION txn_upgrade_completed
 RETURN BOOLEAN;

 FUNCTION get_ret_process_id (p_process  IN VARCHAR2)
 RETURN NUMBER;

 FUNCTION upgrade_name(p_lookup_code  IN VARCHAR2)
 RETURN VARCHAR2;


 FUNCTION performance_upgrade_complete(p_upg_type  IN VARCHAR2)
 RETURN BOOLEAN;



END HXC_UPGRADE_PKG;

/
