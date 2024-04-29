--------------------------------------------------------
--  DDL for Package Body AMW_PURGE_MVIEW_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_PURGE_MVIEW_LOG" AS
/* $Header: amwslprb.pls 120.2 2006/01/06 17:44:14 appldev noship $ */

  FUNCTION GET_ROW_COUNT (schema_name VARCHAR2, table_name VARCHAR2)
      RETURN NUMBER IS

    p_query  VARCHAR2(1000);
    p_result NUMBER := 0;

  BEGIN

    -- define the Query
    p_query := 'SELECT COUNT(1) FROM '||schema_name||'.'||table_name;

    execute immediate p_query INTO p_result;
    commit;

    return (p_result);


  END GET_ROW_COUNT;


-- disable this function due to the limited access privilege to the sys table.  bug 4883995
 PROCEDURE PURGE_LOG(errbuf OUT NOCOPY VARCHAR2,
                     retcode OUT NOCOPY VARCHAR2) IS

   BEGIN

   NULL;

     END PURGE_LOG;


 PROCEDURE REFRESH_ALL(errbuf  OUT NOCOPY VARCHAR2,
                      retcode OUT NOCOPY VARCHAR2,
                      p_mview_name IN VARCHAR2)
       IS

       -- stop using sys table due to bug 4883995
        --CURSOR C_mview IS
 	--  SELECT distinct mview_name, owner FROM sys.dba_mviews
          		--WHERE mview_name LIKE 'AMW_%';

     --p_mview      dba_mviews.mview_name%type;
     --p_owner      dba_mviews.owner%type;

   BEGIN

   IF (p_mview_name is not null) THEN
     DBMS_MVIEW.REFRESH(p_mview_name , 'C');
   ELSE
     --OPEN C_mview;
     --LOOP
--	FETCH C_mview  INTO p_mview, p_owner;
--	EXIT WHEN C_mview%NOTFOUND;
--        DBMS_MVIEW.REFRESH(p_owner||'.'|| p_mview, 'C');
--        COMMIT;
--    END LOOP;

   DBMS_MVIEW.REFRESH('AMW_OPINION_LOG_MV', 'C');
   DBMS_MVIEW.REFRESH('AMW_OPINION_MV', 'C');

    END IF;


    EXCEPTION
     WHEN NO_DATA_FOUND THEN
         fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in AMW_PURGE_MVIEW_LOG.REFRESH_ALL'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));
     WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in AMW_PURGE_MVIEW_LOG.REFRESH_ALL'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));
         errbuf := SQLERRM;
         retcode := FND_API.G_RET_STS_UNEXP_ERROR;


END  REFRESH_ALL;


END  AMW_PURGE_MVIEW_LOG;

/
