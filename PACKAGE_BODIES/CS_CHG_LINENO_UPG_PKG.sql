--------------------------------------------------------
--  DDL for Package Body CS_CHG_LINENO_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CHG_LINENO_UPG_PKG" AS

PROCEDURE Upgrade_Chg_LineNo_Mgr(
                  X_errbuf     OUT NOCOPY VARCHAR2,
                  X_retcode    OUT NOCOPY VARCHAR2)
IS
BEGIN
 --
 -- Manager processing
 --
 AD_CONC_UTILS_PKG.Submit_Subrequests(
               X_errbuf                   => X_errbuf,
               X_retcode                  => X_retcode,
               X_WorkerConc_app_shortname => 'CS',
               X_WorkerConc_progname      => 'CSCHGLINENOWKR',
               X_batch_size               => 10000,
               X_Num_Workers              => 3,
               X_Argument4                => null,
               X_Argument5                => null,
               X_Argument6                => null,
               X_Argument7                => null,
               X_Argument8                => null,
               X_Argument9                => null,
               X_Argument10               => null);

END Upgrade_Chg_LineNo_Mgr;

PROCEDURE Upgrade_Chg_LineNo_Wkr(
                  X_errbuf     OUT NOCOPY VARCHAR2,
                  X_retcode    OUT NOCOPY VARCHAR2,
                  X_batch_size  IN NUMBER,
                  X_Worker_Id   IN NUMBER,
                  X_Num_Workers IN NUMBER)
IS

 l_worker_id           NUMBER;
 l_product             VARCHAR2(30) := 'CS';
 l_table_name          VARCHAR2(30) := 'CS_ESTIMATE_DETAILS';
 l_id_column           VARCHAR2(30) := 'INCIDENT_ID';
 l_update_name         VARCHAR2(30) := 'csxelnub.120.1';
 l_status              VARCHAR2(30);
 l_industry            VARCHAR2(30);
 l_retstatus           BOOLEAN;
 l_table_owner         VARCHAR2(30);
 l_any_rows_to_process BOOLEAN;
 l_start_id            NUMBER;
 l_end_id              NUMBER;
 l_rows_processed      NUMBER;

 CURSOR Get_Charges_Lines ( v_start_incident NUMBER, v_end_incident NUMBER) IS
  SELECT Row_Id,
         Rn
  FROM ( SELECT rowid AS Row_Id,
                Line_Number,
                Row_Number() over (PARTITION BY Incident_Id
                                   ORDER BY Creation_Date asc,
                                            Estimate_Detail_Id ) rn
         FROM CS_ESTIMATE_DETAILS
         WHERE Incident_id between v_start_incident and v_end_incident )
  WHERE nvl(Line_Number,-1) <> Rn;

 TYPE num_tbl_type  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE row_tbl_type IS TABLE OF ROWID INDEX BY BINARY_INTEGER;

 --Populate the variables for Bulk Update
 v_row_id            row_tbl_type;
 v_row_number        num_tbl_type;

 l_cur_fetch  NUMBER := 0;
 l_prev_fetch NUMBER := 0;

BEGIN

 --
 -- get schema name of the table for ROWID range processing
 --
 l_retstatus := FND_INSTALLATION.Get_App_Info( l_product,
                                               l_status,
                                               l_industry,
                                               l_table_owner );

 IF ((l_retstatus = FALSE) OR (l_table_owner is null))
 THEN
   raise_application_error( -20001,
                            'Cannot get schema name for product : '||l_product);
 END IF;

 --
 -- Worker processing
 --

 BEGIN

  AD_PARALLEL_UPDATES_PKG.initialize_id_range(
           ad_parallel_updates_pkg.ID_RANGE_SCAN_EQUI_ROWSETS,  --ID_RANGE
           l_table_owner,
           l_table_name,
           l_update_name,
           l_id_column,
           x_worker_id,
           x_num_workers,
           x_batch_size,
           0,
           ' SELECT ed.incident_id id_value
             FROM CS_ESTIMATE_DETAILS ed ', --> X_SQL_Stmt
           null,                            --> X_Begin_ID
           null                             --> X_End_ID
           );

  /*
   AD converts the SQL passed above into the following to determine the Ranges:
   ---------------------------------------------------------------------------
   SELECT unit_id+1        AS unit_id,
          MIN(incident_id) AS start_id_value,
          MAX(incident_id) AS end_id_value
   FROM ( SELECT ed.incident_id,
	             FLOOR( RANK() OVER (ORDER BY ed.incident_id)/:batchsize ) unit_id
	      FROM CS_ESTIMATE_DETAILS ed )
   GROUP BY unit_id
  */


  AD_PARALLEL_UPDATES_PKG.get_id_range(
           l_start_id,
           l_end_id,
           l_any_rows_to_process,
           x_batch_size,
           TRUE);



  WHILE (l_any_rows_to_process = TRUE) LOOP
    --Test Code:
    --fnd_file.put_line(FND_FILE.LOG, 'After  get_id_range: '||l_start_id||' '||l_end_id);
    --dbms_lock.sleep(20);

    OPEN  Get_Charges_Lines(l_start_id,l_end_id);
    FETCH Get_Charges_Lines bulk collect into
                                       v_row_id,
                                       v_row_number;
    CLOSE Get_Charges_Lines;

    l_rows_processed := v_row_id.COUNT;

    FORALL i in 1..l_rows_processed
     UPDATE CS_ESTIMATE_DETAILS
     SET line_number = v_row_number(i)
     WHERE rowid = v_row_id(i);

    AD_PARALLEL_UPDATES_PKG.processed_id_range(
                                l_rows_processed,
                                l_end_id);

    COMMIT;

    AD_PARALLEL_UPDATES_PKG.get_id_range(
                      l_start_id,
                      l_end_id,
                      l_any_rows_to_process,
                      x_batch_size,
                      FALSE);

  END LOOP;

  X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

 EXCEPTION
  WHEN OTHERS THEN
    X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
    raise;
 END;

END Upgrade_Chg_LineNo_Wkr;

END CS_CHG_LINENO_UPG_PKG;

/
