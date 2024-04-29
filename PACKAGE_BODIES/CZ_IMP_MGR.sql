--------------------------------------------------------
--  DDL for Package Body CZ_IMP_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_IMP_MGR" as
/*  $Header: czimngrb.pls 120.0 2005/05/25 06:45:39 appldev noship $	*/

TYPE tRunId IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE tName  IS TABLE OF dba_tables.table_name%TYPE INDEX BY BINARY_INTEGER;
-------------------------------------------
PROCEDURE delete_runs(p_run_id_tbl tRunId) IS
 l_schema_owner dba_tables.owner%TYPE := 'CZ';
 l_str          VARCHAR2(2000);
 l_tab_name_tbl tName;
 l_count        NUMBER:=0;
BEGIN
   BEGIN
    SELECT TO_NUMBER(VALUE) INTO CZ_IMP_MGR.BATCH_SIZE
    FROM cz_db_settings
    WHERE UPPER(setting_id)='BATCHSIZE';
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
       NULL;
   END;
   l_tab_name_tbl.DELETE;
   SELECT table_name BULK COLLECT INTO l_tab_name_tbl
   FROM dba_tables
   WHERE table_name like 'CZ_IMP%' AND owner = UPPER(l_schema_owner);
   IF p_run_id_tbl.COUNT > 0 THEN
     FOR i IN p_run_id_tbl.FIRST..p_run_id_tbl.LAST LOOP
       FOR j IN l_tab_name_tbl.FIRST..l_tab_name_tbl.LAST LOOP
         l_str := 'DELETE FROM '||l_tab_name_tbl(j) || ' WHERE run_id = :1';
         EXECUTE IMMEDIATE l_str USING p_run_id_tbl(i);
         l_count := l_count + SQL%ROWCOUNT;
         IF l_count >= BATCH_SIZE THEN
         COMMIT;
           l_count := 0;
         END IF;
       END LOOP;
       l_str := 'DELETE FROM cz_xfr_run_results WHERE run_id = :1';
       EXECUTE IMMEDIATE l_str USING p_run_id_tbl(i);
       l_str := 'DELETE FROM cz_xfr_run_infos WHERE run_id = :1';
       EXECUTE IMMEDIATE l_str USING p_run_id_tbl(i);
     END LOOP;
   END IF;
   COMMIT;
END delete_runs;
-------------------------------------------
PROCEDURE purge
IS
 l_schema_owner dba_tables.owner%TYPE := 'CZ';
 l_error      BOOLEAN;
BEGIN
   CZ_ADMIN.SPX_SYNC_IMPORTSESSIONS;
   DBMS_APPLICATION_INFO.SET_MODULE('CZIMPORT','');
   FOR i IN (SELECT table_name FROM dba_tables WHERE table_name like 'CZ_IMP%' AND owner = UPPER(l_schema_owner)) LOOP
     EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema_owner||'.'|| i.table_name;
   END LOOP;
   EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema_owner||'.'||'CZ_XFR_RUN_INFOS';
   EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema_owner||'.'||'CZ_XFR_RUN_RESULTS';
   COMMIT;
   DBMS_APPLICATION_INFO.SET_MODULE('','');
EXCEPTION
 WHEN CZ_ADMIN.IMP_ACTIVE_SESSION_EXISTS THEN
   l_error := cz_utils.log_report(cz_utils.get_text('CZ_IMP_ACTIVE_SESSION_EXISTS'),1,'CZ_IMP_MGR.PURGE',11276);
   RAISE;
 WHEN OTHERS THEN
   l_error:=cz_utils.log_report(SQLERRM,1,'CZ_IMP_MGR.PURGE',11276);
   DBMS_APPLICATION_INFO.SET_MODULE('','');
   RAISE;
END purge;
-------------------------------------------
PROCEDURE purge_to_date(p_days IN NUMBER)
IS
 l_run_id_tbl   tRunId;
 l_error        BOOLEAN;
BEGIN
   CZ_ADMIN.SPX_SYNC_IMPORTSESSIONS;
   DBMS_APPLICATION_INFO.SET_MODULE('CZIMPORT','');
   l_run_id_tbl.DELETE;
   SELECT run_id BULK COLLECT INTO l_run_id_tbl
   FROM cz_xfr_run_infos
   WHERE TRUNC(started) < (SELECT TRUNC(SYSDATE) - p_days  FROM DUAL);
   IF (l_run_id_tbl.COUNT > 0) THEN
     delete_runs(l_run_id_tbl);
   END IF;
   DBMS_APPLICATION_INFO.SET_MODULE('','');
EXCEPTION
 WHEN NO_DATA_FOUND THEN
   DBMS_APPLICATION_INFO.SET_MODULE('','');
 WHEN CZ_ADMIN.IMP_ACTIVE_SESSION_EXISTS THEN
   l_error := cz_utils.log_report(cz_utils.get_text('CZ_IMP_ACTIVE_SESSION_EXISTS'),1,'CZ_IMP_MGR.PURGE',11276);
   RAISE;
 WHEN OTHERS THEN
   l_error:=cz_utils.log_report(SQLERRM,1,'CZ_IMP_MGR.PURGE_to_date',11276);
   DBMS_APPLICATION_INFO.SET_MODULE('','');
   RAISE;
END purge_to_date;
-------------------------------------------
PROCEDURE purge_to_runid(p_run_id IN NUMBER)
IS
 l_run_id_tbl   tRunId;
 l_error        BOOLEAN;
BEGIN
   CZ_ADMIN.SPX_SYNC_IMPORTSESSIONS;
   DBMS_APPLICATION_INFO.SET_MODULE('CZIMPORT','');
   l_run_id_tbl.DELETE;
   SELECT run_id BULK COLLECT INTO l_run_id_tbl
   FROM cz_xfr_run_infos
   WHERE run_id <= p_run_id;
   IF (l_run_id_tbl.COUNT > 0) THEN
     delete_runs(l_run_id_tbl);
   END IF;
   DBMS_APPLICATION_INFO.SET_MODULE('','');
EXCEPTION
 WHEN NO_DATA_FOUND THEN
   DBMS_APPLICATION_INFO.SET_MODULE('','');
 WHEN CZ_ADMIN.IMP_ACTIVE_SESSION_EXISTS THEN
   l_error := cz_utils.log_report(cz_utils.get_text('CZ_IMP_ACTIVE_SESSION_EXISTS'),1,'CZ_IMP_MGR.PURGE',11276);
   RAISE;
 WHEN OTHERS THEN
   l_error:=cz_utils.log_report(SQLERRM,1,'CZ_IMP_MGR.PURGE_TO_RUNID',11276);
   DBMS_APPLICATION_INFO.SET_MODULE('','');
   RAISE;
END purge_to_runid;
-------------------------------------------
PROCEDURE purge_cp(errbuf  IN OUT NOCOPY VARCHAR2,
		   retcode IN OUT NOCOPY pls_integer) IS
BEGIN
   retcode := G_CONCURRENT_SUCCESS;
   purge;
EXCEPTION
  WHEN CZ_ADMIN.IMP_ACTIVE_SESSION_EXISTS THEN
     retcode := G_CONCURRENT_ERROR;
     errbuf := cz_utils.get_text('CZ_IMP_ACTIVE_SESSION_EXISTS');
  WHEN OTHERS THEN
     retcode := G_CONCURRENT_ERROR;
     errbuf := cz_utils.get_text('CZ_PURGE_FATAL_ERR', 'SQLERRM',Sqlerrm);
     DBMS_APPLICATION_INFO.SET_MODULE('','');
END purge_cp;
-------------------------------------------
PROCEDURE purge_to_date_cp(errbuf    IN OUT NOCOPY VARCHAR2,
                           retcode   IN OUT NOCOPY pls_integer,
                           p_days    IN            NUMBER) IS
BEGIN
   retcode := G_CONCURRENT_SUCCESS;
   purge_to_date(p_days);
EXCEPTION
  WHEN CZ_ADMIN.IMP_ACTIVE_SESSION_EXISTS THEN
     retcode := G_CONCURRENT_ERROR;
     errbuf := cz_utils.get_text('CZ_IMP_ACTIVE_SESSION_EXISTS');
  WHEN OTHERS THEN
     retcode := G_CONCURRENT_ERROR;
     errbuf := cz_utils.get_text('CZ_PURGE_FATAL_ERR', 'SQLERRM',Sqlerrm);
     DBMS_APPLICATION_INFO.SET_MODULE('','');
END purge_to_date_cp;
-------------------------------------------
PROCEDURE purge_to_runid_cp(errbuf    IN OUT NOCOPY VARCHAR2,
		            retcode   IN OUT NOCOPY pls_integer,
                            p_run_id  IN            NUMBER) IS
BEGIN
   retcode := G_CONCURRENT_SUCCESS;
   purge_to_runid(p_run_id);
EXCEPTION
  WHEN CZ_ADMIN.IMP_ACTIVE_SESSION_EXISTS THEN
     retcode := G_CONCURRENT_ERROR;
     errbuf := cz_utils.get_text('CZ_IMP_ACTIVE_SESSION_EXISTS');
  WHEN OTHERS THEN
     retcode := G_CONCURRENT_ERROR;
     errbuf := cz_utils.get_text('CZ_PURGE_FATAL_ERR', 'SQLERRM',Sqlerrm);
     DBMS_APPLICATION_INFO.SET_MODULE('','');
END purge_to_runid_cp;

END CZ_IMP_MGR;

/
