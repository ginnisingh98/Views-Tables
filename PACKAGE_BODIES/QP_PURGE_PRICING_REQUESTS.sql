--------------------------------------------------------
--  DDL for Package Body QP_PURGE_PRICING_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PURGE_PRICING_REQUESTS" AS
/* $Header: QPXDLDBB.pls 120.1 2005/06/09 23:56:24 appldev  $ */

  PROCEDURE Purge
   (err_buff                 out NOCOPY /* file.sql.39 change */ VARCHAR2,
    retcode                  out NOCOPY /* file.sql.39 change */ NUMBER,
    x_no_of_days             in  NUMBER,
    x_request_name           in  VARCHAR2) IS

  l_request_name varchar2(240);
  l_no_of_days   number;
  l_count        number := 0;
  l_qp_schema            VARCHAR2(30);
  l_stmt                 VARCHAR2(200);
  l_status               VARCHAR2(30);
  l_industry             VARCHAR2(30);

  BEGIN

    l_no_of_days := x_no_of_days;

    IF (l_no_of_days is not null) and (x_request_name is not null)  THEN
       l_request_name := x_request_name || '%';

       SELECT COUNT(*) INTO l_count FROM QP_DEBUG_REQ
       WHERE TO_DATE(creation_date, 'DD-MM-YYYY') <=
             TO_DATE((SYSDATE - l_no_of_days), 'DD-MM-YYYY') AND
             request_name like l_request_name;

       IF l_count = 0 THEN
          RAISE NO_DATA_FOUND;
       END IF;


       LOOP
          DELETE QP_DEBUG_REQ_LINES WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE TO_DATE(creation_date, 'DD-MM-YYYY') <=
                 TO_DATE((SYSDATE - l_no_of_days), 'DD-MM-YYYY') AND
                 request_name like l_request_name
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_REQ_LDETS WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE TO_DATE(creation_date, 'DD-MM-YYYY') <=
                 TO_DATE((SYSDATE - l_no_of_days), 'DD-MM-YYYY') AND
                 request_name like l_request_name
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_REQ_LINE_ATTRS WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE TO_DATE(creation_date, 'DD-MM-YYYY') <=
                 TO_DATE((SYSDATE - l_no_of_days), 'DD-MM-YYYY') AND
                 request_name like l_request_name
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_REQ_RLTD_LINES WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE TO_DATE(creation_date, 'DD-MM-YYYY') <=
                 TO_DATE((SYSDATE - l_no_of_days), 'DD-MM-YYYY') AND
                 request_name like l_request_name
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_FORMULA_STEP_VALUES WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE TO_DATE(creation_date, 'DD-MM-YYYY') <=
                 TO_DATE((SYSDATE - l_no_of_days), 'DD-MM-YYYY') AND
                 request_name like l_request_name
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_TEXT WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE TO_DATE(creation_date, 'DD-MM-YYYY') <=
                 TO_DATE((SYSDATE - l_no_of_days), 'DD-MM-YYYY') AND
                 request_name like l_request_name
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_REQ
          WHERE TO_DATE(creation_date, 'DD-MM-YYYY') <=
                TO_DATE((SYSDATE - l_no_of_days), 'DD-MM-YYYY') AND
                request_name like l_request_name AND
                rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;


    ELSIF (l_no_of_days is not null) and (x_request_name is null) THEN


       SELECT COUNT(*) INTO l_count FROM QP_DEBUG_REQ
       WHERE TO_DATE(creation_date, 'DD-MM-YYYY') <=
             TO_DATE((SYSDATE - l_no_of_days), 'DD-MM-YYYY');

       IF l_count = 0 THEN
          RAISE NO_DATA_FOUND;
       END IF;

       LOOP
          DELETE QP_DEBUG_REQ_LINES WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE TO_DATE(creation_date, 'DD-MM-YYYY') <=
                 TO_DATE((SYSDATE - l_no_of_days), 'DD-MM-YYYY')
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_REQ_LDETS WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE TO_DATE(creation_date, 'DD-MM-YYYY') <=
                 TO_DATE((SYSDATE - l_no_of_days), 'DD-MM-YYYY')
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_REQ_LINE_ATTRS WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE TO_DATE(creation_date, 'DD-MM-YYYY') <=
                 TO_DATE((SYSDATE - l_no_of_days), 'DD-MM-YYYY')
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_REQ_RLTD_LINES WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE TO_DATE(creation_date, 'DD-MM-YYYY') <=
                 TO_DATE((SYSDATE - l_no_of_days), 'DD-MM-YYYY')
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_FORMULA_STEP_VALUES WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE TO_DATE(creation_date, 'DD-MM-YYYY') <=
                 TO_DATE((SYSDATE - l_no_of_days), 'DD-MM-YYYY')
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_TEXT WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE TO_DATE(creation_date, 'DD-MM-YYYY') <=
                 TO_DATE((SYSDATE - l_no_of_days), 'DD-MM-YYYY')
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_REQ
          WHERE TO_DATE(creation_date, 'DD-MM-YYYY') <=
                TO_DATE((SYSDATE - l_no_of_days), 'DD-MM-YYYY') AND
                rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;


    ELSIF (l_no_of_days is null) and (x_request_name is not null)  THEN

       l_request_name := x_request_name || '%';


       SELECT COUNT(*) INTO l_count FROM QP_DEBUG_REQ
       WHERE request_name like l_request_name;

       IF l_count = 0 THEN
          RAISE NO_DATA_FOUND;
       END IF;

       LOOP
          DELETE QP_DEBUG_REQ_LINES WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE request_name like l_request_name
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_REQ_LDETS WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE request_name like l_request_name
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_REQ_LINE_ATTRS WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE request_name like l_request_name
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_REQ_RLTD_LINES WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE request_name like l_request_name
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_FORMULA_STEP_VALUES WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE request_name like l_request_name
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_TEXT WHERE request_id in
          (SELECT request_id FROM qp_debug_req
           WHERE request_name like l_request_name
          ) AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

       LOOP
          DELETE QP_DEBUG_REQ
          WHERE request_name like l_request_name AND
                rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;


    ELSIF (l_no_of_days is null) and (x_request_name is null) THEN

       SELECT COUNT(*) INTO l_count FROM QP_DEBUG_REQ;

       IF l_count = 0 THEN
          RAISE NO_DATA_FOUND;
       END IF;

       IF (FND_INSTALLATION.GET_APP_INFO('QP', l_status, l_industry, l_qp_schema)) THEN

         l_stmt := 'TRUNCATE TABLE ' || l_qp_schema || '.QP_DEBUG_REQ_LINES';
         EXECUTE IMMEDIATE l_stmt;

         l_stmt := 'TRUNCATE TABLE ' || l_qp_schema || '.QP_DEBUG_REQ_LDETS';
         EXECUTE IMMEDIATE l_stmt;

         l_stmt := 'TRUNCATE TABLE ' || l_qp_schema || '.QP_DEBUG_REQ_LINE_ATTRS';
         EXECUTE IMMEDIATE l_stmt;

         l_stmt := 'TRUNCATE TABLE ' || l_qp_schema || '.QP_DEBUG_REQ_RLTD_LINES';
         EXECUTE IMMEDIATE l_stmt;

         l_stmt := 'TRUNCATE TABLE ' || l_qp_schema || '.QP_DEBUG_FORMULA_STEP_VALUES';
         EXECUTE IMMEDIATE l_stmt;

         l_stmt := 'TRUNCATE TABLE ' || l_qp_schema || '.QP_DEBUG_TEXT';
         EXECUTE IMMEDIATE l_stmt;

         l_stmt := 'TRUNCATE TABLE ' || l_qp_schema || '.QP_DEBUG_REQ';
         EXECUTE IMMEDIATE l_stmt;

       END IF;

    END IF;

    COMMIT;
    fnd_file.put_line(FND_FILE.LOG,'Purging Pricing Engine Requests completed successfully');
    err_buff := 'Purging Pricing Engine Requests completed successfully';
    retcode := 0;


    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            retcode := 1;
            --fnd_file.put_line(FND_FILE.LOG,substr(sqlerrm,1,300));
            --fnd_file.put_line(FND_FILE.LOG,sqlcode);
            --err_buff := substr(sqlerrm,1,240);
            fnd_file.put_line(FND_FILE.LOG,'No Data Found - 0 Records Deleted');
            err_buff := 'No Data Found - 0 Records Deleted';

       WHEN OTHERS THEN
            retcode := 2;
            fnd_file.put_line(FND_FILE.LOG,substr(sqlerrm,1,300));
            fnd_file.put_line(FND_FILE.LOG,sqlcode);
            err_buff := substr(sqlerrm,1,240);
            RAISE;

  END Purge;

END QP_PURGE_PRICING_REQUESTS;

/
