--------------------------------------------------------
--  DDL for Package Body CS_CONTPNTS_AUDIT_UPD_CON_PRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CONTPNTS_AUDIT_UPD_CON_PRG" AS
/* $Header: csxacptb.pls 120.5 2005/08/02 12:58:42 allau noship $ */

PROCEDURE Create_Cpt_Audit_Manager
  (x_errbuf         OUT  NOCOPY VARCHAR2,
   x_retcode        OUT  NOCOPY VARCHAR2,
   p_cutoff_date     IN  VARCHAR2          -- <4507823/>
  ) IS
BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start Create_Cpt_Audit_Manager');
  -- Parent Processing

  AD_CONC_UTILS_PKG.Submit_Subrequests
    (x_errbuf     => x_errbuf,
     x_retcode    => x_retcode,
     x_workerconc_app_shortname  => 'CS', --l_product,
     x_workerconc_progname => 'CSSRCPTAW',
     x_batch_size           => 1000,
     x_num_workers          => 3,
     x_argument4            => p_cutoff_date,                      -- <4507823/>
     x_argument5            =>  to_char(sysdate, 'yymmddhh24miss') -- <4507823>to ensure re-runnable</4507823>
    );

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'x_errbuf: ' || x_errbuf);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'x_retcode: ' || x_retcode);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'End Create_Cpt_Audit_Manager');
END Create_Cpt_Audit_Manager;

PROCEDURE Create_Cpt_Audit_Worker
  (x_errbuf       OUT  NOCOPY VARCHAR2,
   x_retcode      OUT  NOCOPY VARCHAR2,
   x_batch_size    IN  NUMBER,
   x_worker_id     IN  NUMBER,
   x_num_workers   IN  NUMBER,
   p_cutoff_date   IN  VARCHAR2,    -- <4507823/>
   p_update_date   IN  VARCHAR2     -- <4507823/>
  ) IS

  l_product               VARCHAR2(30) := 'CS';
  l_status                VARCHAR2(30);
  l_industry              VARCHAR2(30);
  l_retstatus             BOOLEAN;
  l_table_owner           VARCHAR2(30);
  l_table_name            VARCHAR2(30) := 'CS_HZ_SR_CONTACT_POINTS';
  l_update_name           VARCHAR2(30) := 'csxacptb.pls';  -- l_update_name will be appended with sysdate, do not make this longer than 18 characters
  l_start_rowid           ROWID;
  l_end_rowid             ROWID;
  l_any_rows_to_process   BOOLEAN;
  l_rows_processed        NUMBER;
  l_cutoff_date           DATE;

BEGIN -- a

  --
  -- get schema name of the table for ROWID range processing
  --
  l_retstatus := fnd_installation.get_app_info(
                     l_product, l_status, l_industry, l_table_owner);

  IF ((l_retstatus = FALSE) OR (l_table_owner IS NULL)) THEN
       RAISE_APPLICATION_ERROR(-20001,
          'Cannot get schema name for product : '||l_product);
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.LOG, '  X_Worker_Id : '||X_Worker_Id);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'X_Num_Workers : '||X_Num_Workers);

  --
  -- Worker processing
  --
  -- The following could be coded to use EXECUTE IMMEDIATE inorder to remove
  -- build time dependencies as the processing could potentially reference
  -- some tables that could be obsoleted in the current release
  --
  BEGIN -- b
    l_cutoff_date := to_date(p_cutoff_date, 'YYYY/MM/DD HH24:MI:SS');

    FND_FILE.Put_Line(fnd_file.log, 'p_cutoff_date=' || p_cutoff_date);

    ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           l_update_name || p_update_date, -- to ensure it is rerunnable
           x_worker_id,
           x_num_workers,
           x_batch_size, 0);

    ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           x_batch_size,
           TRUE);

    WHILE (l_any_rows_to_process = TRUE) LOOP
      INSERT INTO cs_hz_sr_contact_pnts_audit
      (sr_contact_point_audit_id,
       sr_contact_point_id,
       incident_id,
       party_id,
       old_party_id,
       primary_flag,
       old_primary_flag,
       contact_type,
       old_contact_type,
       contact_point_type,
       old_contact_point_type,
       contact_point_id,              --<4510186>
       old_contact_point_id,          --</4510186>
       contact_point_modified_by,
       contact_point_modified_on,
       object_version_number,
       party_role_code,
       old_party_role_code,
       start_date_active,
       old_start_date_active,
       end_date_active,
       old_end_date_active,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login
      )
        SELECT /*+ rowid(cp) */
               cs_hz_sr_cont_pnts_audit_s.NEXTVAL,
               sr_contact_point_id,
               incident_id,
               party_id,
               NULL,
               primary_flag,
               NULL,
               contact_type,
               NULL,
               contact_point_type,
               NULL,
               contact_point_id,
               NULL,
               last_updated_by,
               last_update_date,
               object_version_number,
               party_role_code,
               NULL,
               start_date_active,
               NULL,
               end_date_active,
               NULL,
               SYSDATE,
               -1,
               SYSDATE,
               -1,
               -1
        FROM   cs_hz_sr_contact_points cp
        WHERE  rowid BETWEEN l_start_rowid AND l_end_rowid
        AND    creation_date > l_cutoff_date                    -- <4507823/>
        AND    NOT EXISTS (
               SELECT 'x'
               FROM cs_hz_sr_contact_pnts_audit a
               WHERE a.sr_contact_point_id = cp.sr_contact_point_id);

      l_rows_processed := SQL%ROWCOUNT;

      ad_parallel_updates_pkg.processed_rowid_range(
         l_rows_processed,
         l_end_rowid);

      --
      -- commit transaction here
      --
      COMMIT;
      --

      -- get new range of rowids
      --
      ad_parallel_updates_pkg.get_rowid_range(
         l_start_rowid,
         l_end_rowid,
         l_any_rows_to_process,
         x_batch_size,
         FALSE);
    END LOOP;

    x_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

    EXCEPTION
      WHEN OTHERS THEN
        x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
        RAISE;
  END; -- b
END; -- a
END CS_CONTPNTS_AUDIT_UPD_CON_PRG;

/
