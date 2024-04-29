--------------------------------------------------------
--  DDL for Package Body HXC_RDB_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RDB_PROCESS" AS
/* $Header: hxcrdbproc.pkb 120.0.12010000.6 2010/05/06 10:15:45 asrajago noship $ */

PROCEDURE  SUBMIT_REQUEST ( p_application   IN VARCHAR2,
                            p_ret_user_id   IN NUMBER,
                            p_start_date    IN VARCHAR2 DEFAULT NULL,
                            p_end_date      IN VARCHAR2 DEFAULT NULL,
                            p_gre_id        IN NUMBER DEFAULT NULL,
                            p_org_id        IN NUMBER DEFAULT NULL,
                            p_loc_id        IN NUMBER DEFAULT NULL,
                            p_payroll_id    IN NUMBER DEFAULT NULL,
                            p_person_id     IN NUMBER DEFAULT NULL,
                            p_trans_code    IN VARCHAR2 DEFAULT NULL,
                            p_old_new       IN VARCHAR2 DEFAULT NULL,
                            p_batch_ref     IN VARCHAR2 DEFAULT NULL,
                            p_new_batch_ref IN VARCHAR2 DEFAULT NULL,
                            p_bee_status    IN VARCHAR2 DEFAULT NULL,
                            p_changes_since IN VARCHAR2 DEFAULT NULL,
                            p_op_unit       IN NUMBER DEFAULT NULL,
                            p_request_id    OUT NOCOPY NUMBER )
IS

  l_request_id   NUMBER;
  l_conc_id      NUMBER;
  l_sysdate      DATE;

  l_phase        VARCHAR2(30);
  l_status       VARCHAR2(30);

BEGIN

     load_conc_ids;

     IF p_application = 'PAY'
     THEN
         l_request_id :=
          FND_REQUEST.SUBMIT_REQUEST(application => 'PER'
                                               ,program     => 'PYTSHPRI'
                                               ,description => NULL
                                               ,sub_request => FALSE
                                               ,argument1   => FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
                                               ,argument2   => FND_DATE.DATE_TO_CANONICAL(TRUNC(SYSDATE))
                                               ,argument3   => FND_DATE.DATE_TO_CANONICAL(
                                                                 TO_DATE(p_start_date,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'))
                                                                                          )
                                               ,argument4   => FND_DATE.DATE_TO_CANONICAL(
                                                                 TO_DATE(p_end_date,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'))
                                                                                         )
                                               ,argument5   => NULL
                                               ,argument6   => NULL
                                               ,argument7   => p_gre_id
                                               ,argument8   => p_org_id
                                               ,argument9   => p_loc_id
                                               ,argument10   => p_payroll_id
                                               ,argument11   => p_person_id
                                               ,argument12   => NVL(p_trans_code,TO_CHAR(SYSDATE,'RRRRMONDD'))
                                               ,argument13   => NULL
                                               ,argument14   => NULL
                                               ,argument15   => p_batch_ref
                                               ,argument16   => p_new_batch_ref
                                               ,argument17   => NULL
                                               ,argument18   => p_bee_status
                                               ,argument19   => NULL
                                               ,argument20   => FND_DATE.DATE_TO_CANONICAL(NVL(TO_DATE(p_changes_since,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')),
                                                                                               SYSDATE- fnd_profile.value('HXC_RETRIEVAL_CHANGES_DATE')
                                                                                               )
                                                                                           )
                                  );

        COMMIT;
        l_conc_id := g_conc_id('PYTSHPRI');
        l_sysdate := SYSDATE;

        -- Bug 9626621
        -- Added the select to update correct status and phase
        SELECT phase_code,
               status_code
          INTO l_phase,
               l_status
          FROM fnd_concurrent_requests
         WHERE request_id = l_request_id;

        INSERT INTO hxc_rdb_processes
         ( request_id,
           conc_program_id,
           conc_program_name,
           date_start,
           phase,
           status,
           ret_user_id )
        VALUES ( l_request_id,
                 l_conc_id,
                 'PYTSHPRI',
                  l_sysdate,
                  l_phase,
                  l_status,
                  FND_GLOBAL.USER_ID);

        COMMIT;


    END IF;

    IF p_application = 'PA'
    THEN
        FND_REQUEST.SET_ORG_ID(FND_PROFILE.VALUE('ORG_ID'));
        l_request_id :=
         FND_REQUEST.SUBMIT_REQUEST(application => 'PA'
                                              ,program     => 'PAXTRTRX'
                                              ,description => NULL
                                              ,sub_request => FALSE
                                              ,argument1   => 'ORACLE TIME AND LABOR'
                                              ,argument2   => NULL );

       COMMIT;
       l_conc_id := g_conc_id('PAXTRTRX');
       l_sysdate := SYSDATE;

        -- Bug 9626621
        -- Added the select to update correct status and phase
        SELECT phase_code,
               status_code
          INTO l_phase,
               l_status
          FROM fnd_concurrent_requests
         WHERE request_id = l_request_id;


       INSERT INTO hxc_rdb_processes
        ( request_id,
          conc_program_id,
          conc_program_name,
          date_start,
           phase,
           status,
          ret_user_id  )
       VALUES ( l_request_id,
                l_conc_id,
                'PAXTRTRX',
                 l_sysdate,
                  l_phase,
                  l_status,
                 FND_GLOBAL.USER_ID);

       COMMIT;


    END IF;


    p_request_id := l_request_id;


END submit_request;


PROCEDURE load_conc_ids
IS

   CURSOR get_conc_ids( p_conc_name   VARCHAR2,
                        p_application_id  NUMBER)
       IS SELECT concurrent_program_id
            FROM fnd_concurrent_programs
           WHERE concurrent_program_name = p_conc_name
             AND application_id = p_application_id ;

    l_conc_id   NUMBER;

  BEGIN
      IF NOT g_conc_id.EXISTS('PYTSHPRI')
      THEN
          OPEN get_conc_ids( 'PYTSHPRI',
                              800);
          FETCH get_conc_ids INTO l_conc_id;
          CLOSE get_conc_ids;

          g_conc_id('PYTSHPRI') := l_conc_id;

     END IF;


      IF NOT g_conc_id.EXISTS('PAXTRTRX')
      THEN
          OPEN get_conc_ids( 'PAXTRTRX',
                              275);
          FETCH get_conc_ids INTO l_conc_id;
          CLOSE get_conc_ids;

          g_conc_id('PAXTRTRX') := l_conc_id;

     END IF;

 END load_conc_ids;


PROCEDURE refresh
IS

  -- Bug 9626621
  -- Added phase and altered the WHERE clause

  CURSOR pick_request_status
      IS SELECT status_code,
                phase_code,
                actual_completion_date,
                ROWIDTOCHAR(rdb.rowid)
           FROM hxc_rdb_processes rdb,
                fnd_concurrent_requests fnd
          WHERE rdb.ret_user_id = FND_GLOBAL.user_id
            AND rdb.request_id = fnd.request_id
            AND fnd.requested_by = rdb.ret_user_id
            AND rdb.phase <> 'C';

  TYPE VARCHARTABLE IS TABLE OF VARCHAR2(50);
  TYPE DATETABLE    IS TABLE OF DATE;

  l_status_tab  VARCHARTABLE;
  l_phase_tab   VARCHARTABLE;
  l_comp_tab    DATETABLE;
  l_row_tab     VARCHARTABLE;

BEGIN

     OPEN pick_request_status;
     FETCH pick_request_status BULK COLLECT INTO l_status_tab,
                                                 l_phase_tab,
                                                 l_comp_tab,
                                                 l_row_tab;
     CLOSE pick_request_status;

     IF l_status_tab.COUNT > 0
     THEN
        FORALL i IN l_status_tab.FIRST..l_status_tab.LAST
           UPDATE hxc_rdb_processes
              SET status = l_status_tab(i),
                  phase  = l_phase_tab(i),
                  date_end = l_comp_tab(i)
            WHERE ROWID = CHARTOROWID(l_row_tab(i));

     END IF;

    COMMIT;


END refresh;


END HXC_RDB_PROCESS;


/
