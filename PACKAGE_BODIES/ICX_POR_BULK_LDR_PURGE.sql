--------------------------------------------------------
--  DDL for Package Body ICX_POR_BULK_LDR_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_BULK_LDR_PURGE" AS
/* $Header: ICXBLKPB.pls 115.2 2004/03/31 18:43:51 vkartik ship $*/

/**
 ** Proc : purge_bulk_ldr_tables
 ** Desc : Purges Bulk Loader tables beyond the no of days specified.
 **/
PROCEDURE purge_bulk_ldr_tables(p_no_of_days IN NUMBER DEFAULT 30,
                                p_commit_size IN NUMBER DEFAULT 2500)AS
gDeleteJobNumbers		   dbms_sql.number_table;
gcommit_size                       NUMBER := 0;
l_continue                         BOOLEAN := TRUE;
xErrloc	                           INTEGER := 0;

BEGIN

xErrLoc := 100;

--Divide by 3 as deleting from three tables in one transaction
--Lower commit size will reduce the chances of Rollback Segment issues.
SELECT round(p_commit_size/3)
INTO   gcommit_size
FROM   dual;

WHILE l_continue LOOP
      DELETE FROM icx_por_batch_jobs
      WHERE  submission_datetime <= (SYSDATE-p_no_of_days)
      AND    ROWNUM <= gcommit_size
      RETURNING job_number BULK COLLECT INTO gDeleteJobNumbers;

      xErrLoc := 200;

      IF ( SQL%ROWCOUNT < gcommit_size ) THEN
         l_continue := FALSE;
      END IF;

      xErrLoc := 300;

      FORALL i IN 1..gDeleteJobNumbers.COUNT
	 DELETE FROM icx_por_failed_line_messages
         WHERE job_number = gDeleteJobNumbers(i);

      xErrLoc := 400;

      FORALL i IN 1..gDeleteJobNumbers.COUNT
	 DELETE FROM icx_por_failed_lines
	 WHERE job_number = gDeleteJobNumbers(i);

      xErrLoc := 500;

      FORALL i IN 1..gDeleteJobNumbers.COUNT
	 DELETE FROM icx_por_contract_references
	 WHERE job_number = gDeleteJobNumbers(i);

      xErrLoc := 600;

      COMMIT;
END LOOP;

EXCEPTION
   WHEN OTHERS THEN
	ROLLBACK;
        RAISE_APPLICATION_ERROR(-20000,
          'Exception at icx_por_bulk_ldr_purge.purge_bulk_ldr_tables('
          || xErrloc || '): ' ||SQLERRM);
END purge_bulk_ldr_tables;

END ICX_POR_BULK_LDR_PURGE;

/
