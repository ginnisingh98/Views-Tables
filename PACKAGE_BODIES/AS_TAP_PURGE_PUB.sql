--------------------------------------------------------
--  DDL for Package Body AS_TAP_PURGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_TAP_PURGE_PUB" as
/* $Header: asxtprgb.pls 120.6 2006/01/09 00:33:33 amagupta noship $ */

G_CURSOR_LIMIT    CONSTANT NUMBER := 10000;
G_NUM_REC         CONSTANT NUMBER := 10000;
G_ENTITY CONSTANT VARCHAR2(25) := 'PURGE TAP RECORDS';
PROCEDURE Purge_Access_Tables (
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2,
    p_debug_mode          IN  VARCHAR2,
    p_trace_mode          IN  VARCHAR2
) IS
    CURSOR c_get_corrupt IS
	SELECT /*+ INDEX_FFS(AS_TERRITORY_ACCESSES AS_TERRITORY_ACCESSES_U1) parallel_index(AS_TERRITORY_ACCESSES,AS_TERRITORY_ACCESSES_U1,5)  parallel(AS_ACCESSES_U1,5) */
	      rowid,access_id
	 from AS_TERRITORY_ACCESSES
        where not exists
	 (select 1
	    from AS_ACCESSES_ALL_ALL acc
	   where AS_TERRITORY_ACCESSES.access_id = acc.access_id)
union
  SELECT /*+ INDEX_FFS(AS_TERRITORY_ACCESSES AS_TERRITORY_ACCESSES_U1)
  parallel_index(AS_TERRITORY_ACCESSES,AS_TERRITORY_ACCESSES_U1,5)
  parallel(AS_ACCESSES_U1,5) */
           rowid,access_id
      from AS_TERRITORY_ACCESSES
         where not exists
      (select 1
         from JTF_TERR_ALL terr
        where AS_TERRITORY_ACCESSES.TERRITORY_ID = terr.TERR_ID
              and sysdate between terr.start_date_active and
  terr.end_date_active) ;

    TYPE TBL_ROWID_TYPE IS TABLE OF VARCHAR2(2000);
    TYPE ACC_NUM_TYPE IS TABLE OF NUMBER;
    TYPE TERRACC_REC_TYPE IS RECORD ( tbl_rowid TBL_ROWID_TYPE,
                                      access_id ACC_NUM_TYPE );
    l_terracc_rec TERRACC_REC_TYPE;

    l_cursor_limit  NUMBER  := G_CURSOR_LIMIT;
    l_limit_flag    BOOLEAN := FALSE;
    l_loop_count    NUMBER  := 0;
    l_flag          BOOLEAN := TRUE;
    l_first         NUMBER := 0;
    l_last          NUMBER := 0;
    l_count          NUMBER := 0;


    l_MinNumParallelProc   NUMBER;
    l_NumChildWorker       NUMBER;
    l_ActualWorkers        NUMBER;

    l_req_id               NUMBER;
    l_msg                  VARCHAR2(2000);
    l_prg_name             VARCHAR2(100) :='ON_LINE_MODE';
    l_status               BOOLEAN;

BEGIN

    IF p_trace_mode = 'Y' THEN AS_GAR.SETTRACE; END IF;
    AS_GAR.g_debug_flag := p_debug_mode;

    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_prg_name|| AS_GAR.G_START);

    -- Get the cursor limit
    begin
      l_cursor_limit :=
          nvl(to_number(fnd_profile.value('AS_TERR_RECORDS_TO_OPEN')),
              G_CURSOR_LIMIT) ;
      if l_cursor_limit < 1 then
         l_cursor_limit := G_CURSOR_LIMIT;
      end if;
    exception
      when others then
          l_cursor_limit := G_CURSOR_LIMIT;
    end;
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_prg_name || 'Cursor Limit'|| l_cursor_limit);
    l_limit_flag    := FALSE;
    l_loop_count    := 0;

    -- Delete with incremental commit
    LOOP
        if (l_limit_flag) then EXIT;    End If;
        l_loop_count := l_loop_count + 1;

        -- Open Cursor - get access_ids from working table
        BEGIN
            OPEN c_get_corrupt;
            FETCH c_get_corrupt
              BULK COLLECT INTO l_terracc_rec.tbl_rowid,
                                l_terracc_rec.access_id
              LIMIT l_cursor_limit;
            CLOSE c_get_corrupt;
        EXCEPTION
            WHEN OTHERS THEN
              IF c_get_corrupt%ISOPEN THEN
                  CLOSE c_get_corrupt;
              END IF;
	      AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_prg_name || 'Others - OPEN c_get_corrupt');
              RAISE;
        END;

        IF l_terracc_rec.access_id.count < l_cursor_limit THEN
            l_limit_flag := TRUE;
        END IF;

        -- Delete from tables
        AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_prg_name || 'Deleting corrupted data in AS_TERRITORY_ACCESSES');
        IF l_terracc_rec.access_id.count > 0 THEN
            l_flag := TRUE;
            l_first := l_terracc_rec.access_id.first;
            l_last := l_first + G_NUM_REC;

            WHILE l_flag LOOP
                IF l_last > l_terracc_rec.access_id.last THEN
                    l_last := l_terracc_rec.access_id.last;
                END IF;
                    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_prg_name || 'Records to be deleted: ' ||
                                          l_terracc_rec.access_id.first || '-'
                                          || l_terracc_rec.access_id.last);
                FORALL i in l_first..l_last
                    DELETE FROM AS_TERRITORY_ACCESSES
                    WHERE rowid = l_terracc_rec.tbl_rowid(i);
                COMMIT;
	        AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_prg_name||  'Records deleted: ' || l_first ||'-'|| l_last);
                l_first := l_last + 1;
                l_last := l_first + G_NUM_REC;
                IF l_first > l_terracc_rec.access_id.last THEN
                    l_flag := FALSE;
                END IF;
            END LOOP;
        END IF;
        COMMIT;
    END LOOP;


    --
    -- Spawn parallel working ASTPON
    --
    -- Prepare for parallel processing
    select /*+ INDEX_FFS(ABC AS_ACCESSES_U2)*/ count(*) into l_count
    from AS_ACCESSES_ALL_ALL ABC
    where delete_flag='Y';

    l_MinNumParallelProc :=
        nvl(TO_NUMBER(fnd_profile.value('AS_TERR_MIN_NUM_PARALLEL_PROC')),100);
    l_NumChildWorker :=
        nvl(TO_NUMBER(fnd_profile.value('AS_TAP_PURGE_NUM_CHILD_WORKERS')),1);
    IF l_NumChildWorker < 1 THEN
        l_NumChildWorker := 1;
    END IF;
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_prg_name || 'Min records for Parallel Processing: '||l_MinNumParallelProc);
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_prg_name || 'Max Parallel Workers: '||l_NumChildWorker);

    Prepare_Parallel_Processing (
        P_Count               => l_count,
        P_MinNumParallelProc  => l_MinNumParallelProc,
        P_NumChildWorker      => l_NumChildWorker,
        X_ActualWorkersUsed   => l_ActualWorkers );


    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_prg_name || 'Actual no. of Parallel Workers: '||l_ActualWorkers);

    -- submit concurrent request ASTPON
    FOR i in 1..l_ActualWorkers LOOP
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_prg_name || 'Submiting ASTPON -- worker: '||i);
        l_req_id := FND_REQUEST.SUBMIT_REQUEST(
                        application => 'AS',
                        program     => 'ASTPON',
                        start_time  => '',
                        sub_request => FALSE,
                        argument1   => AS_GAR.g_debug_flag,
                        argument2   => p_trace_mode,
                        argument3   => i );

        IF l_req_id = 0 THEN
            l_msg:=FND_MESSAGE.GET;
            AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_prg_name || 'Error in Submittingb Request:' || l_msg);
        END IF;
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_prg_name || 'Submitted Request:' || l_req_id);
    END LOOP;
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_prg_name || AS_GAR.G_END);
EXCEPTION
    WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY, SQLERRM, TO_CHAR(SQLCODE));
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);

END Purge_Access_Tables;


PROCEDURE Prepare_Parallel_Processing(
    P_Count               IN  NUMBER,
    P_MinNumParallelProc  IN  NUMBER,
    P_NumChildWorker      IN  NUMBER,
    X_ActualWorkersUsed   OUT NOCOPY NUMBER)
IS
    l_st               VARCHAR2(3000);
    stmt               VARCHAR2(8000);

    l_ActualWorker     NUMBER := 0;
    l_WorkerLoad       NUMBER := 0;
    l_pkg_name         VARCHAR2(100) := 'PREPARE_PARALLEL_PROCESSING';

    l_fnd_status        VARCHAR2(2);
    l_industry          VARCHAR2(2);
    l_oracle_schema     VARCHAR2(32) := 'OSM';
    l_schema_return     BOOLEAN;

BEGIN

    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_pkg_name || AS_GAR.G_START);

    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_pkg_name || 'TRUNCATE TABLE AS_TAP_PURGE_WORKING');

    l_schema_return := FND_INSTALLATION.get_app_info('AS', l_fnd_status, l_industry, l_oracle_schema);

    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_oracle_schema||'.AS_TAP_PURGE_WORKING';

    --
    -- Populate the working table
    --
    X_ActualWorkersUsed := 0;
    l_ActualWorker   := 0;
    l_WorkerLoad     := 0;

    l_WorkerLoad := CEIL(P_Count / P_NumChildWorker);
    If l_WorkerLoad < P_MinNumParallelProc then
        l_WorkerLoad := P_MinNumParallelProc;
    End If;

    l_ActualWorker := CEIL(P_Count/l_WorkerLoad);
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_pkg_name || 'ActualWorker: '||l_ActualWorker);


    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_pkg_name || 'Inseting into AS_TAP_PURGE_WORKING');

    commit;
    EXECUTE IMMEDIATE 'alter session enable parallel dml';

    stmt :=  'INSERT /*+ append parallel(i) */ INTO as_tap_purge_working i
        (ROW_ID,
         WORKER_ID,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN)
    SELECT /*+  PARALLEL_INDEX(AS_ACCESSES_ALL_ALL,5) INDEX_FFS(AS_ACCESSES_ALL_ALL AS_ACCESSES_U2)*/
     ROWID,NTILE('||l_ActualWorker||') OVER(ORDER BY ROWID) as workerid, sysdate,
        :1,
        sysdate,
        :2,
        :3
  FROM AS_ACCESSES_ALL_ALL where delete_flag = ''Y''';

    EXECUTE IMMEDIATE stmt using NVL(to_number(fnd_profile.value('USER_ID')),0),NVL(to_number(fnd_profile.value('USER_ID')),0),
    NVL(to_number(fnd_profile.value('CONC_LOGIN_ID')),0);
    X_ActualWorkersUsed := l_ActualWorker;
    commit;
    EXECUTE IMMEDIATE 'alter session disable parallel dml';

    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_pkg_name || AS_GAR.G_END);

END Prepare_Parallel_Processing;

PROCEDURE Delete_Access_Records (
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2,
    p_debug_mode          IN  VARCHAR2,
    p_trace_mode          IN  VARCHAR2,
    p_worker_id           IN  NUMBER )
IS
    CURSOR c_get_del_access (c_worker_id number) IS
        select row_id
        from as_tap_purge_working
        where worker_id = c_worker_id;

    TYPE ACC_NUM_TYPE IS TABLE OF rowid;
    TYPE ACC_REC_TYPE IS RECORD ( access_id  ACC_NUM_TYPE);

    l_acc_rec ACC_REC_TYPE;

    TYPE ACC_NUM_TYPE1 IS TABLE OF NUMBER;
    TYPE ACC_REC_TYPE1 IS RECORD ( access_id  ACC_NUM_TYPE1);

    l_acc_rec1 ACC_REC_TYPE1;

    l_flag          BOOLEAN := TRUE;
    l_first         NUMBER := 0;
    l_last          NUMBER := 0;
    l_limit_flag    BOOLEAN := FALSE;
    l_cursor_limit  NUMBER  := G_CURSOR_LIMIT;
    l_loop_count    NUMBER  := 0;

    l_st      VARCHAR2(3000);
    l_status               BOOLEAN;
    l_pkg_name  VARCHAR2(100) := 'DELETE_ACCESS_RECORDS';

BEGIN
    IF p_trace_mode = 'Y' THEN AS_GAR.SETTRACE; END IF;

    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_pkg_name|| AS_GAR.G_START);
    -- Get the cursor limit
    begin
      l_cursor_limit :=
          nvl(to_number(fnd_profile.value('AS_TERR_RECORDS_TO_OPEN')),
              G_CURSOR_LIMIT) ;
      if l_cursor_limit < 1 then
         l_cursor_limit := G_CURSOR_LIMIT;
      end if;
    exception
      when others then
          l_cursor_limit := G_CURSOR_LIMIT;
    end;
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_pkg_name || 'Cursor Limit: '||l_cursor_limit);

    l_limit_flag    := FALSE;
    l_loop_count    := 0;

    -- Delete with incremental commit

    -- Open Cursor - get access_ids from working table
    begin
        OPEN c_get_del_access (p_worker_id);

        LOOP
            IF (l_limit_flag) THEN EXIT;    END IF;
            l_loop_count := l_loop_count + 1;

            FETCH c_get_del_access
              BULK COLLECT INTO l_acc_rec.access_id
              LIMIT l_cursor_limit;

            IF l_acc_rec.access_id.count < l_cursor_limit THEN
                l_limit_flag := TRUE;
            END IF;

            -- Delete from tables
	    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_pkg_name || '---DELETE FROM AS_ACCESSES_ALL_ALL::START');

            IF l_acc_rec.access_id.count > 0 THEN
                l_flag := TRUE;
                l_first := l_acc_rec.access_id.first;
                l_last := l_first + G_NUM_REC;

                WHILE l_flag LOOP
                    IF l_last > l_acc_rec.access_id.last THEN
                    l_last := l_acc_rec.access_id.last;
                    END IF;
		    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_pkg_name ||
                                              'Records to be deleted: ' ||
                                              l_acc_rec.access_id.first || '-'
                                              || l_acc_rec.access_id.last);

                    FORALL i in l_first..l_last
                        DELETE FROM AS_ACCESSES_ALL_ALL
                        WHERE rowid = l_acc_rec.access_id(i)
			RETURNING access_id BULK COLLECT INTO l_acc_rec1.access_id;
                    COMMIT;

                    FORALL j in l_first..l_last
                        DELETE /*+ index(TERRACC AS_TERRITORY_ACCESSES_u1) */
                        FROM   AS_TERRITORY_ACCESSES TERRACC
                        WHERE TERRACC.access_id = l_acc_rec1.access_id(j);
                    COMMIT;

                    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_pkg_name ||
                                              'Records deleted: ' || l_first ||
                                              '-'|| l_last);

                    l_first := l_last + 1;
                    l_last := l_first + G_NUM_REC;
                    IF l_first > l_acc_rec.access_id.last THEN
                        l_flag := FALSE;
                    END IF;
                END LOOP;
            END IF;
            COMMIT;
        END LOOP;

        CLOSE c_get_del_access;
    EXCEPTION
        WHEN OTHERS THEN
          IF c_get_del_access%ISOPEN THEN
              CLOSE c_get_del_access;
          END IF;
          AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_pkg_name ||
                                    'Others - OPEN c_get_del_access');
          RAISE;
    END;
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || l_pkg_name || AS_GAR.G_END);
EXCEPTION
    WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY, SQLERRM, TO_CHAR(SQLCODE));
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
END Delete_Access_Records;

END AS_TAP_PURGE_PUB;

/
