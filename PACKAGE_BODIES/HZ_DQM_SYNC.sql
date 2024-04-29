--------------------------------------------------------
--  DDL for Package Body HZ_DQM_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DQM_SYNC" AS
/* $Header: ARHDQSNB.pls 120.56.12010000.2 2010/03/24 10:54:55 amstephe ship $ */

--------------------------------------------------------------------------------
-- Note that when this profile option is not set, the default value is Y
-- i.e., SYNC is assumed to be in REALTIME.
-- Need to look into the impact of this, for customers who do not need DQM out of the box.
---------------------------------------------------------------------------------
L_REALTIME_SYNC_VALUE VARCHAR2(15) := nvl(FND_PROFILE.VALUE('HZ_DQM_ENABLE_REALTIME_SYNC'), 'Y');


PROCEDURE  REALTIME_SYNC_INDEXES(i_party IN boolean,
i_party_sites IN boolean,
i_contacts IN boolean,
i_contact_points IN boolean
) ;


PROCEDURE insert_interface_rec (
        p_party_id      IN      NUMBER,
        p_record_id     IN      NUMBER,
        p_party_site_id IN      NUMBER,
        p_org_contact_id IN     NUMBER,
        p_entity        IN      VARCHAR2,
        p_operation     IN      VARCHAR2,
	p_staged_flag   IN      VARCHAR2 DEFAULT 'N'
);
PROCEDURE out(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
         RETURN VARCHAR2;

FUNCTION check_for_transaction RETURN VARCHAR2;

g_commit_counter NUMBER := 1;

-- VJN INTRODUCED FOR SYNC FUNCTIONALITY IN R12

-- This will take a request id and return TRUE if the concurrent program
-- is either Running or Pending
FUNCTION is_conc_complete ( p_request_id IN NUMBER) RETURN BOOLEAN ;

FUNCTION is_sync_success
  (p_entity IN VARCHAR2
  ,p_record_id IN NUMBER
  ,p_party_id IN NUMBER
  ) RETURN BOOLEAN ;

-- Will submit a concurrent request to call the Serial Sync Index Concurrent Program
PROCEDURE call_sync_index_serial IS
  l_sub_request         NUMBER ;
  l_ignore_conc_limits  VARCHAR2(80);
  l_conc_req_limit      VARCHAR2(80);
BEGIN
  -- Fix for bug 5061761.
  -- Check for Profile Value to decide if conc req limit per user can be ignored.
  l_ignore_conc_limits := nvl(FND_PROFILE.VALUE('HZ_DQM_IGNORE_CONC_LIMITS'), 'N');
  IF l_ignore_conc_limits = 'Y' THEN
     l_conc_req_limit := nvl(FND_PROFILE.VALUE('CONC_REQUEST_LIMIT'), '0');
     IF l_conc_req_limit <> '0' THEN
       FND_PROFILE.PUT (
         NAME => 'CONC_REQUEST_LIMIT',
         VAL  => NULL
       );
     END IF;
    l_sub_request :=  FND_REQUEST.SUBMIT_REQUEST(
                        'AR',
                        'ARHDQMSS',
                        'DQM Serial Sync Index Program',
                        NULL,
                        FALSE
                      );
    FND_PROFILE.PUT (
      NAME => 'CONC_REQUEST_LIMIT',
      VAL  => l_conc_req_limit
    );
  ELSE
    l_sub_request :=  FND_REQUEST.SUBMIT_REQUEST(
                        'AR',
                        'ARHDQMSS',
                        'DQM Serial Sync Index Program',
                        NULL,
                        FALSE
                      );
  END IF;

EXCEPTION WHEN OTHERS THEN
  NULL ;
END ;

PROCEDURE insert_into_interface(p_party_id	IN	NUMBER
)  IS
l_char NUMBER;
BEGIN
 -- check if record already exists in HZ_DQM_SYNC_INTERFACE
	BEGIN
            select 'Y' into l_char
            from hz_dqm_sync_interface
            where party_id = p_party_id
            and entity = 'PARTY'
            and staged_flag in ('N', 'Y')
	    and rownum = 1;
	EXCEPTION WHEN NO_DATA_FOUND THEN
             insert_interface_rec (p_party_id, null, null, null, 'PARTY', 'U', 'Y');
	END;
EXCEPTION WHEN others THEN
   NULL;
END insert_into_interface;

-- REPURI. Bug 4884742. Introduced this function to check if Shadow Staging completely succesfully.
-- This function would return TRUE if the shadow staging program has run successfully

FUNCTION is_shadow_staging_complete RETURN BOOLEAN
IS
  l_num            NUMBER;
  func_ret_status  BOOLEAN := FALSE;

  CURSOR c_sh_stage_log_count IS
    SELECT 1
    FROM hz_dqm_stage_log
    WHERE operation = 'SHADOW_STAGING'
    AND STEP = 'COMPLETE';

BEGIN
  OPEN c_sh_stage_log_count;
  FETCH c_sh_stage_log_count INTO l_num;
  IF c_sh_stage_log_count%FOUND THEN
    func_ret_status := TRUE;
  END IF;
  CLOSE c_sh_stage_log_count;

  RETURN func_ret_status;
EXCEPTION WHEN OTHERS THEN
  RETURN func_ret_status;
END is_shadow_staging_complete;


PROCEDURE set_to_batch_sync
IS
BEGIN
   L_REALTIME_SYNC_VALUE := 'N' ;
END set_to_batch_sync;

FUNCTION is_prof_enable_for_sync
RETURN BOOLEAN
IS
l_prof VARCHAR2(1);
BEGIN
    l_prof := nvl(FND_PROFILE.VALUE('HZ_DQM_ENABLE_REALTIME_SYNC'), 'Y');
    IF (l_prof = 'Y') THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
    EXCEPTION WHEN OTHERS THEN
        RETURN FALSE;
END is_prof_enable_for_sync;

PROCEDURE sync_index_realtime(
        p_index_name            IN     VARCHAR2,
        retcode                 OUT    NOCOPY VARCHAR2,
        err                     OUT    NOCOPY VARCHAR2) IS

cursor l_party_cur is select rowid, party_id, record_id
            from hz_dqm_sync_interface a
            where a.staged_flag = 'Y'
            and a.entity = 'PARTY' AND REALTIME_SYNC_FLAG='Y';
cursor l_ps_cur is select rowid, party_id, record_id
                from hz_dqm_sync_interface a
                where a.staged_flag = 'Y'
                and a.entity = 'PARTY_SITES' AND REALTIME_SYNC_FLAG='Y';
cursor l_ct_cur is select rowid, party_id, record_id
                from hz_dqm_sync_interface a
                where a.staged_flag = 'Y'
                and entity = 'CONTACTS'  AND REALTIME_SYNC_FLAG='Y';
cursor l_cp_cur is select rowid, party_id, record_id
                from hz_dqm_sync_interface a
                where a.staged_flag = 'Y'
                and entity = 'CONTACT_POINTS' AND REALTIME_SYNC_FLAG='Y';

l_limit NUMBER := 1000;
TYPE RowList IS TABLE OF VARCHAR2(255);
L_ROWID RowList;
TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
L_PARTY_ID NumberList;
L_RECORD_ID NumberList;
l_last_fetch BOOLEAN := FALSE;
l_index_name VARCHAR2(100);

BEGIN
  retcode := 0;
  err := null;
  l_index_name := lower(p_index_name);
  IF (INSTRB(l_index_name,'hz_stage_parties_t1') > 0) THEN
     ad_ctx_Ddl.Sync_Index ( p_index_name );
     OPEN l_party_cur;
     LOOP
         FETCH l_party_cur BULK COLLECT INTO
           L_ROWID
           , L_PARTY_ID
           , L_RECORD_ID  LIMIT l_limit;
         IF l_party_cur%NOTFOUND THEN
             l_last_fetch:=TRUE;
         END IF;
         IF L_PARTY_ID.COUNT=0 AND l_last_fetch THEN
             EXIT;
         END IF;
         FORALL I in L_PARTY_ID.FIRST..L_PARTY_ID.LAST
             update hz_staged_parties a set concat_col = concat_col
              where a.party_id = L_PARTY_ID(I);
         FORALL I in L_PARTY_ID.FIRST..L_PARTY_ID.LAST
             delete from hz_dqm_sync_interface
              where rowid = L_ROWID(I);
         ad_ctx_Ddl.Sync_Index ( p_index_name );
         IF l_last_fetch THEN
             EXIT;
         END IF;
         FND_CONCURRENT.AF_Commit;
      END LOOP;
      CLOSE l_party_cur;
  ELSIF (INSTRB(l_index_name,'hz_stage_party_sites_t1') > 0) THEN
     ad_ctx_Ddl.Sync_Index ( p_index_name );
     OPEN l_ps_cur;
     LOOP
         FETCH l_ps_cur BULK COLLECT INTO
             L_ROWID
           , L_PARTY_ID
           , L_RECORD_ID  LIMIT l_limit;
         IF l_ps_cur%NOTFOUND THEN
             l_last_fetch:=TRUE;
         END IF;
         IF L_RECORD_ID.COUNT=0 AND l_last_fetch THEN
             EXIT;
         END IF;
         FORALL I in L_RECORD_ID.FIRST..L_RECORD_ID.LAST
               update hz_staged_party_sites a set concat_col = concat_col
                where a.party_site_id = L_RECORD_ID(I);
         FORALL I in L_RECORD_ID.FIRST..L_RECORD_ID.LAST
               delete from hz_dqm_sync_interface
                where rowid = L_ROWID(I);
        ad_ctx_Ddl.Sync_Index ( p_index_name );
         IF l_last_fetch THEN
             EXIT;
         END IF;
         FND_CONCURRENT.AF_Commit;
      END LOOP;
      CLOSE l_ps_cur;
  ELSIF (INSTRB(l_index_name,'hz_stage_contact_t1') > 0) THEN
      ad_ctx_Ddl.Sync_Index ( p_index_name );
      OPEN l_ct_cur;
      LOOP
         FETCH l_ct_cur BULK COLLECT INTO
             L_ROWID
           , L_PARTY_ID
           , L_RECORD_ID  LIMIT l_limit;
         IF l_ct_cur%NOTFOUND THEN
             l_last_fetch:=TRUE;
         END IF;
         IF L_RECORD_ID.COUNT=0 AND l_last_fetch THEN
             EXIT;
         END IF;
         FORALL I in L_RECORD_ID.FIRST..L_RECORD_ID.LAST
                update hz_staged_contacts a set concat_col = concat_col
                 where a.org_contact_id  = L_RECORD_ID(I);
         FORALL I in L_RECORD_ID.FIRST..L_RECORD_ID.LAST
               delete from hz_dqm_sync_interface
                where rowid = L_ROWID(I);
        ad_ctx_Ddl.Sync_Index ( p_index_name );
         IF l_last_fetch THEN
             EXIT;
         END IF;
         FND_CONCURRENT.AF_Commit;
      END LOOP;
      CLOSE l_ct_cur;
 ELSIF (INSTRB(l_index_name,'hz_stage_cpt_t1') > 0) THEN
     ad_ctx_Ddl.Sync_Index ( p_index_name );
     OPEN l_cp_cur;
     LOOP
         FETCH l_cp_cur BULK COLLECT INTO
             L_ROWID
           , L_PARTY_ID
           , L_RECORD_ID  LIMIT l_limit;
         IF l_cp_cur%NOTFOUND THEN
            l_last_fetch:=TRUE;
         END IF;
         IF L_RECORD_ID.COUNT=0 AND l_last_fetch THEN
             EXIT;
         END IF;
         FORALL I in L_RECORD_ID.FIRST..L_RECORD_ID.LAST
               update hz_staged_contact_points a set concat_col = concat_col
                where a.contact_point_id  = L_RECORD_ID(I);
         FORALL I in L_RECORD_ID.FIRST..L_RECORD_ID.LAST
               delete from hz_dqm_sync_interface
                where rowid = L_ROWID(I);
         ad_ctx_Ddl.Sync_Index ( p_index_name );
         IF l_last_fetch THEN
             EXIT;
         END IF;
         FND_CONCURRENT.AF_Commit;
      END LOOP;
      CLOSE l_cp_cur;
  END IF;
  --Call to sync index
END sync_index_realtime;



PROCEDURE sync_index(
        p_index_name            IN     VARCHAR2,
        retcode                 OUT    NOCOPY VARCHAR2,
        err                     OUT    NOCOPY VARCHAR2) IS

cursor l_party_cur is select rowid, party_id, record_id
            from hz_dqm_sync_interface a
            where a.staged_flag = 'Y'
            and a.entity = 'PARTY';
cursor l_ps_cur is select rowid, party_id, record_id
                from hz_dqm_sync_interface a
                where a.staged_flag = 'Y'
                and a.entity = 'PARTY_SITES';
cursor l_ct_cur is select rowid, party_id, record_id
                from hz_dqm_sync_interface a
                where a.staged_flag = 'Y'
                and entity = 'CONTACTS' ;
cursor l_cp_cur is select rowid, party_id, record_id
                from hz_dqm_sync_interface a
                where a.staged_flag = 'Y'
                and entity = 'CONTACT_POINTS';

l_limit NUMBER := 1000;
TYPE RowList IS TABLE OF VARCHAR2(255);
L_ROWID RowList;
TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
L_PARTY_ID NumberList;
L_RECORD_ID NumberList;
l_last_fetch BOOLEAN := FALSE;
l_index_name VARCHAR2(100);

BEGIN
  retcode := 0;
  err := null;
  l_index_name := lower(p_index_name);
  IF (INSTRB(l_index_name,'hz_stage_parties_t1') > 0) THEN
     ad_ctx_Ddl.Sync_Index ( p_index_name );
     OPEN l_party_cur;
     LOOP
         FETCH l_party_cur BULK COLLECT INTO
           L_ROWID
           , L_PARTY_ID
           , L_RECORD_ID  LIMIT l_limit;
         IF l_party_cur%NOTFOUND THEN
             l_last_fetch:=TRUE;
         END IF;
         IF L_PARTY_ID.COUNT=0 AND l_last_fetch THEN
             EXIT;
         END IF;
         FORALL I in L_PARTY_ID.FIRST..L_PARTY_ID.LAST
             update hz_staged_parties a set concat_col = concat_col
              where a.party_id = L_PARTY_ID(I);
         FORALL I in L_PARTY_ID.FIRST..L_PARTY_ID.LAST
             delete from hz_dqm_sync_interface
              where rowid = L_ROWID(I);
	 ad_ctx_Ddl.Sync_Index ( p_index_name );
         IF l_last_fetch THEN
             EXIT;
         END IF;
         FND_CONCURRENT.AF_Commit;
      END LOOP;
      CLOSE l_party_cur;
  ELSIF (INSTRB(l_index_name,'hz_stage_party_sites_t1') > 0) THEN
     ad_ctx_Ddl.Sync_Index ( p_index_name );
     OPEN l_ps_cur;
     LOOP
         FETCH l_ps_cur BULK COLLECT INTO
             L_ROWID
           , L_PARTY_ID
           , L_RECORD_ID  LIMIT l_limit;
         IF l_ps_cur%NOTFOUND THEN
             l_last_fetch:=TRUE;
         END IF;
         IF L_RECORD_ID.COUNT=0 AND l_last_fetch THEN
             EXIT;
         END IF;
         FORALL I in L_RECORD_ID.FIRST..L_RECORD_ID.LAST
               update hz_staged_party_sites a set concat_col = concat_col
                where a.party_site_id = L_RECORD_ID(I);
         FORALL I in L_RECORD_ID.FIRST..L_RECORD_ID.LAST
               delete from hz_dqm_sync_interface
                where rowid = L_ROWID(I);
        ad_ctx_Ddl.Sync_Index ( p_index_name );
         IF l_last_fetch THEN
             EXIT;
         END IF;
         FND_CONCURRENT.AF_Commit;
      END LOOP;
      CLOSE l_ps_cur;
  ELSIF (INSTRB(l_index_name,'hz_stage_contact_t1') > 0) THEN
      ad_ctx_Ddl.Sync_Index ( p_index_name );
      OPEN l_ct_cur;
      LOOP
         FETCH l_ct_cur BULK COLLECT INTO
             L_ROWID
           , L_PARTY_ID
           , L_RECORD_ID  LIMIT l_limit;
         IF l_ct_cur%NOTFOUND THEN
             l_last_fetch:=TRUE;
         END IF;
         IF L_RECORD_ID.COUNT=0 AND l_last_fetch THEN
             EXIT;
         END IF;
         FORALL I in L_RECORD_ID.FIRST..L_RECORD_ID.LAST
                update hz_staged_contacts a set concat_col = concat_col
                 where a.org_contact_id  = L_RECORD_ID(I);
         FORALL I in L_RECORD_ID.FIRST..L_RECORD_ID.LAST
               delete from hz_dqm_sync_interface
                where rowid = L_ROWID(I);
        ad_ctx_Ddl.Sync_Index ( p_index_name );
         IF l_last_fetch THEN
             EXIT;
         END IF;
         FND_CONCURRENT.AF_Commit;
      END LOOP;
      CLOSE l_ct_cur;
 ELSIF (INSTRB(l_index_name,'hz_stage_cpt_t1') > 0) THEN
     ad_ctx_Ddl.Sync_Index ( p_index_name );
     OPEN l_cp_cur;
     LOOP
         FETCH l_cp_cur BULK COLLECT INTO
             L_ROWID
           , L_PARTY_ID
           , L_RECORD_ID  LIMIT l_limit;
         IF l_cp_cur%NOTFOUND THEN
            l_last_fetch:=TRUE;
         END IF;
         IF L_RECORD_ID.COUNT=0 AND l_last_fetch THEN
             EXIT;
         END IF;
         FORALL I in L_RECORD_ID.FIRST..L_RECORD_ID.LAST
               update hz_staged_contact_points a set concat_col = concat_col
                where a.contact_point_id  = L_RECORD_ID(I);
         FORALL I in L_RECORD_ID.FIRST..L_RECORD_ID.LAST
               delete from hz_dqm_sync_interface
                where rowid = L_ROWID(I);
         ad_ctx_Ddl.Sync_Index ( p_index_name );
         IF l_last_fetch THEN
             EXIT;
         END IF;
         FND_CONCURRENT.AF_Commit;
      END LOOP;
      CLOSE l_cp_cur;
  END IF;
  --Call to sync index
EXCEPTION
  WHEN OTHERS THEN
    retcode :=  2;
    err := SQLERRM;
    log ('Error:' || SQLERRM);
END sync_index;


PROCEDURE optimize_index(
        p_index_name            IN           VARCHAR2,
        p_level                 IN           VARCHAR2,
        p_max_time              IN           NUMBER,
        retcode                 OUT NOCOPY   VARCHAR2,
        err                     OUT NOCOPY    VARCHAR2) IS
l_max_time NUMBER ;
BEGIN

  retcode := 0;
  err := null;

   IF (p_max_time <> null) THEN
    l_max_time := to_number(p_max_time);
 ELSE
    l_max_time := null;
  END IF;

  --Call to optimize index
  ad_ctx_Ddl.Optimize_Index( p_index_name, p_level, l_max_time, null);
 EXCEPTION
  WHEN OTHERS THEN
/*    retcode :=  1;
    err := SQLERRM; */
   null;
END optimize_index;


FUNCTION is_sync_success (
    p_entity      IN   VARCHAR2
   ,p_record_id   IN   NUMBER
   ,p_party_id    IN   NUMBER
 ) RETURN BOOLEAN IS
  CURSOR c_entity_sync_err (p_entity IN VARCHAR2, p_record_id IN NUMBER) IS
    SELECT 1 from hz_dqm_sync_interface
    WHERE entity       = p_entity
    AND   record_id    = p_record_id
    AND   staged_flag  = 'E';

  CURSOR c_party_sync_err (p_entity IN VARCHAR2, p_party_id IN NUMBER) IS
    SELECT 1 from hz_dqm_sync_interface
    WHERE entity       = p_entity
    AND   party_id     = p_party_id
    AND   staged_flag  = 'E';

  l_num     NUMBER;
  x_status  BOOLEAN  := TRUE;
BEGIN
  IF p_entity = 'PARTY' THEN
    OPEN c_party_sync_err (p_entity, p_party_id);
    FETCH c_party_sync_err INTO l_num;
    IF c_party_sync_err%FOUND THEN
      x_status := FALSE;
    END IF;
    CLOSE c_party_sync_err;
  ELSE
    OPEN c_entity_sync_err (p_entity, p_record_id);
    FETCH c_entity_sync_err INTO l_num;
    IF  c_entity_sync_err%FOUND THEN
      x_status := FALSE;
    END IF;
    CLOSE c_entity_sync_err;
  END IF;
  RETURN x_status;
EXCEPTION
  WHEN OTHERS THEN
    IF c_entity_sync_err%ISOPEN THEN
      CLOSE c_entity_sync_err;
    END IF;
    IF c_party_sync_err%ISOPEN THEN
      CLOSE c_party_sync_err;
    END IF;
    x_status := TRUE;
    RETURN x_status;

END is_sync_success;


PROCEDURE sync_org (
  p_party_id     IN   NUMBER,
  p_create_upd   IN   VARCHAR2
) IS
  l_sql_err_message  VARCHAR2(2000);
BEGIN
  L_REALTIME_SYNC_VALUE := nvl(FND_PROFILE.VALUE('HZ_DQM_ENABLE_REALTIME_SYNC'), 'Y');
  IF ( L_REALTIME_SYNC_VALUE = 'Y') THEN
    -- REPURI. SYNC Perf Improvements. Insert directly into staging tables
    HZ_STAGE_MAP_TRANSFORM.sync_single_party_online(p_party_id, p_create_upd);
    --Check if sync went through successfully
    IF (is_sync_success('PARTY',null,p_party_id)) THEN
      -- Call sync index serial concurrent program
      call_sync_index_serial ;
    END IF;
  ELSIF ( L_REALTIME_SYNC_VALUE = 'N') THEN
    insert_interface_rec(p_party_id,null,null,null,'PARTY',p_create_upd);
    --  REPURI. Bug 4884742. Added this to insert data into hz_dqm_sh_sync_interface table
    --  if shadow staging conc prog completed successfully.
    IF (is_shadow_staging_complete) THEN
      insert_sh_interface_rec(p_party_id,null,null,null,'PARTY',p_create_upd);
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    hz_common_pub.enable_cont_source_security;
    FND_MESSAGE.SET_NAME('AR', 'HZ_SYNC_SQL_EXCEP');
    FND_MESSAGE.SET_TOKEN('PROC','sync_org');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END sync_org;


PROCEDURE sync_person (
  p_party_id      IN      NUMBER,
  p_create_upd    IN      VARCHAR2
) IS
    l_org_contact_id NUMBER;
    l_sql_err_message VARCHAR2(2000);

    CURSOR c_contact IS
      SELECT oc.org_contact_id
      FROM  HZ_RELATIONSHIPS pr, HZ_ORG_CONTACTS oc
      WHERE pr.relationship_id    = oc.party_relationship_id
      AND   pr.subject_id         = p_party_id
      AND   pr.subject_table_name = 'HZ_PARTIES'
      AND   pr.object_table_name  = 'HZ_PARTIES'
      AND   pr.directional_flag   = 'F';
BEGIN
  L_REALTIME_SYNC_VALUE := nvl(FND_PROFILE.VALUE('HZ_DQM_ENABLE_REALTIME_SYNC'), 'Y');
  IF (L_REALTIME_SYNC_VALUE = 'Y') THEN
    -- REPURI. SYNC Perf Improvements. Insert directly into staging tables
    HZ_STAGE_MAP_TRANSFORM.sync_single_party_online(p_party_id, p_create_upd);
    --Check if sync went through successfully
    IF (is_sync_success('PARTY',null,p_party_id)) THEN
      -- Call sync index serial concurrent program
      call_sync_index_serial ;
    END IF;
  ELSIF ( L_REALTIME_SYNC_VALUE = 'N') THEN
    insert_interface_rec(p_party_id,null,null,null,'PARTY',p_create_upd);
    --  REPURI. Bug 4884742. Added this to insert data into hz_dqm_sh_sync_interface table
    --  if shadow staging conc prog completed successfully.
    IF (is_shadow_staging_complete) THEN
      insert_sh_interface_rec(p_party_id,null,null,null,'PARTY',p_create_upd);
    END IF;
    IF p_create_upd = 'U' THEN
      OPEN c_contact;
      LOOP
        FETCH c_contact INTO l_org_contact_id;
        EXIT WHEN c_contact%NOTFOUND;
        insert_interface_rec(p_party_id,l_org_contact_id,null,null,'CONTACTS','U');
    --  REPURI. Bug 4884742. Added this to insert data into hz_dqm_sh_sync_interface table
    --  if shadow staging conc prog completed successfully.
        IF (is_shadow_staging_complete) THEN
          insert_sh_interface_rec(p_party_id,l_org_contact_id,null,null,'CONTACTS','U');
        END IF;
      END LOOP;
    END IF ;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_SYNC_SQL_EXCEP');
    FND_MESSAGE.SET_TOKEN('PROC','sync_person');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END sync_person;


PROCEDURE sync_party_site (
  p_party_site_id   IN   NUMBER,
  p_create_upd      IN   VARCHAR2
) IS
  l_party_id         NUMBER;
  l_party_id1        NUMBER;
  l_org_contact_id   NUMBER;
  l_party_type       VARCHAR2(255);
  l_sql_err_message  VARCHAR2(2000) ;
BEGIN
  L_REALTIME_SYNC_VALUE := nvl(FND_PROFILE.VALUE('HZ_DQM_ENABLE_REALTIME_SYNC'), 'Y');
  IF (L_REALTIME_SYNC_VALUE = 'Y') THEN
    -- REPURI. SYNC Perf Improvements. Insert directly into staging tables
    HZ_STAGE_MAP_TRANSFORM.sync_single_party_site_online(p_party_site_id, p_create_upd);
    --Check if sync went through successfully
    IF (is_sync_success('PARTY_SITES',p_party_site_id,null)) THEN
      -- Call sync index serial concurrent program
      call_sync_index_serial ;
    END IF;
  ELSIF (L_REALTIME_SYNC_VALUE = 'N') THEN
    BEGIN
      SELECT ps.party_id,p.party_type INTO l_party_id, l_party_type
      FROM HZ_PARTY_SITES ps, HZ_PARTIES p
      WHERE party_site_id = p_party_site_id
      AND p.PARTY_ID = ps.PARTY_ID;
    EXCEPTION
      /* Bug No: 2707873. Added this exception because the above sql
         will not retrive any record for party_id -1. */
      WHEN NO_DATA_FOUND THEN
        RETURN;
    END;
    IF l_party_type = 'PARTY_RELATIONSHIP' THEN
      BEGIN
        SELECT r.object_id, org_contact_id INTO l_party_id1,l_org_contact_id
        FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS r
        WHERE r.party_id = l_party_id
        AND r.relationship_id = oc.party_relationship_id
        AND r.directional_flag='F'
        AND r.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
        AND r.OBJECT_TABLE_NAME = 'HZ_PARTIES';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN;
      END;
    ELSE
      l_party_id1:=l_party_id;
      l_org_contact_id:=NULL;
    END IF;
    insert_interface_rec(l_party_id1,p_party_site_id,null,l_org_contact_id,'PARTY_SITES',p_create_upd);
    --  REPURI. Bug 4884742. Added this to insert data into hz_dqm_sh_sync_interface table
    --  if shadow staging conc prog completed successfully.
    IF (is_shadow_staging_complete) THEN
      insert_sh_interface_rec(l_party_id1,p_party_site_id,null,l_org_contact_id,'PARTY_SITES',p_create_upd);
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    hz_common_pub.enable_cont_source_security;
    FND_MESSAGE.SET_NAME('AR', 'HZ_SYNC_SQL_EXCEP');
    FND_MESSAGE.SET_TOKEN('PROC','sync_party_site');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END sync_party_site;


PROCEDURE sync_contact (
  p_org_contact_id   IN   NUMBER,
  p_create_upd       IN   VARCHAR2
) IS
  l_party_id NUMBER;
  l_sql_err_message VARCHAR2(2000);
BEGIN
  L_REALTIME_SYNC_VALUE := nvl(FND_PROFILE.VALUE('HZ_DQM_ENABLE_REALTIME_SYNC'), 'Y');
  IF (L_REALTIME_SYNC_VALUE = 'Y') THEN
    -- REPURI. SYNC Perf Improvements. Insert directly into staging tables
    HZ_STAGE_MAP_TRANSFORM.sync_single_contact_online(p_org_contact_id, p_create_upd);
    --Check if sync went through successfully
    IF (is_sync_success('CONTACTS',p_org_contact_id,null)) THEN
      -- Call sync index serial concurrent program
      call_sync_index_serial ;
    END IF;
  ELSIF ( L_REALTIME_SYNC_VALUE = 'N') THEN
    SELECT r.object_id INTO l_party_id
    FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS r
    WHERE oc.org_contact_id = p_org_contact_id
    AND oc.party_relationship_id =  r.relationship_id
    AND r.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND r.OBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND subject_type ='PERSON'
    AND DIRECTIONAL_FLAG= 'F'
    AND (oc.status is null OR oc.status = 'A' or oc.status = 'I')
    AND (r.status is null OR r.status = 'A' or r.status = 'I') ;

    insert_interface_rec(l_party_id,p_org_contact_id,null,null,'CONTACTS',p_create_upd);
    --  REPURI. Bug 4884742. Added this to insert data into hz_dqm_sh_sync_interface table
    --  if shadow staging conc prog completed successfully.
    IF (is_shadow_staging_complete) THEN
       insert_sh_interface_rec(l_party_id,p_org_contact_id,null,null,'CONTACTS',p_create_upd);
    END IF;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    hz_common_pub.enable_cont_source_security;
    FND_MESSAGE.SET_NAME('AR', 'HZ_SYNC_SQL_EXCEP');
    FND_MESSAGE.SET_TOKEN('PROC','sync_contact');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END sync_contact;


PROCEDURE sync_contact_point (
  p_contact_point_id   IN   NUMBER,
  p_create_upd         IN   VARCHAR2
) IS
  l_party_id         NUMBER := 0;
  l_party_id1        NUMBER;
  l_org_contact_id   NUMBER;
  l_party_site_id    NUMBER;
  l_pr_id            NUMBER;
  l_num_ocs          NUMBER;
  l_ot_id            NUMBER;
  l_ot_table         VARCHAR2(60);
  l_party_type       VARCHAR2(60);
  l_sql_err_message  VARCHAR2(2000);
BEGIN
  l_party_id := 0;
  L_REALTIME_SYNC_VALUE := nvl(FND_PROFILE.VALUE('HZ_DQM_ENABLE_REALTIME_SYNC'), 'Y');
  IF (L_REALTIME_SYNC_VALUE = 'Y') THEN
    -- REPURI. SYNC Perf Improvements. Insert directly into staging tables
    HZ_STAGE_MAP_TRANSFORM.sync_single_cpt_online(p_contact_point_id, p_create_upd);
    --Check if sync went through successfully
    IF (is_sync_success('CONTACT_POINTS',p_contact_point_id,null)) THEN
      -- Call sync index serial concurrent program
      call_sync_index_serial ;
    END IF;
  ELSIF ( L_REALTIME_SYNC_VALUE = 'N') THEN
    SELECT owner_table_name,owner_table_id INTO l_ot_table, l_ot_id
    FROM hz_contact_points
    WHERE contact_point_id = p_contact_point_id;

    IF l_ot_table = 'HZ_PARTY_SITES' THEN
      SELECT p.party_id, ps.party_site_id, party_type
        INTO l_party_id1, l_party_site_id, l_party_type
      FROM HZ_PARTY_SITES ps, HZ_PARTIES p
      WHERE party_site_id = l_ot_id
      AND   p.party_id    = ps.party_id;

      IF l_party_type = 'PARTY_RELATIONSHIP' THEN
        BEGIN
          SELECT r.object_id, org_contact_id INTO l_party_id,l_org_contact_id
          FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS r
          WHERE r.party_id = l_party_id1
          AND r.relationship_id = oc.party_relationship_id
          AND r.directional_flag='F'
          AND r.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
          AND r.OBJECT_TABLE_NAME = 'HZ_PARTIES';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
           RETURN;
        END;
      ELSE
        l_party_id:=l_party_id1;
        l_org_contact_id:=NULL;
      END IF;
    ELSIF l_ot_table = 'HZ_PARTIES' THEN
      l_party_site_id := NULL;
      SELECT party_type INTO l_party_type
      FROM hz_parties
      WHERE party_id = l_ot_id;

      IF l_party_type <> 'PARTY_RELATIONSHIP' THEN
        l_party_id := l_ot_id;
        l_org_contact_id:=NULL;
      ELSE
        BEGIN
          SELECT r.object_id, org_contact_id INTO l_party_id,l_org_contact_id
          FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS r
          WHERE r.party_id = l_ot_id
          AND r.relationship_id = oc.party_relationship_id
          AND r.directional_flag='F'
          AND r.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
          AND r.OBJECT_TABLE_NAME = 'HZ_PARTIES';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RETURN;
        END;
      END IF;
    END IF;

    insert_interface_rec(l_party_id,p_contact_point_id,l_party_site_id, l_org_contact_id, 'CONTACT_POINTS',p_create_upd);
    --  REPURI. Bug 4884742. Added this to insert data into hz_dqm_sh_sync_interface table
    --  if shadow staging conc prog completed successfully.
    IF (is_shadow_staging_complete) THEN
      insert_sh_interface_rec(l_party_id,p_contact_point_id,l_party_site_id, l_org_contact_id, 'CONTACT_POINTS',p_create_upd);
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    hz_common_pub.enable_cont_source_security;
    FND_MESSAGE.SET_NAME('AR', 'HZ_SYNC_SQL_EXCEP');
    FND_MESSAGE.SET_TOKEN('PROC','sync_contact_point');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END sync_contact_point;


PROCEDURE sync_relationship (
        p_relationship_id  IN      NUMBER,
        p_create_upd       IN      VARCHAR2
) IS

  CURSOR org_contacts IS
  SELECT org_contact_id
  FROM hz_org_contacts
  WHERE party_relationship_id  = p_relationship_id
  AND status = 'A';

  l_org_contact_id NUMBER;

BEGIN
    L_REALTIME_SYNC_VALUE := nvl(FND_PROFILE.VALUE('HZ_DQM_ENABLE_REALTIME_SYNC'), 'Y');
    IF ( L_REALTIME_SYNC_VALUE = 'Y' OR L_REALTIME_SYNC_VALUE = 'N')
    THEN
      OPEN org_contacts;
      LOOP
        FETCH org_contacts INTO l_org_contact_id;
        EXIT WHEN org_contacts%NOTFOUND;
        sync_contact(l_org_contact_id,'U');
      END LOOP;
      CLOSE org_contacts;
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    hz_common_pub.enable_cont_source_security;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    hz_common_pub.enable_cont_source_security;
    FND_MESSAGE.SET_NAME('AR', 'HZ_SYNC_SQL_EXCEP');
    FND_MESSAGE.SET_TOKEN('PROC','sync_relationship');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

--- VJN CHANGED THIS PROCEDURE TO INCLUDE THE CHECK OF 'I' FOR THE
--  party_sites CURSOR (Bug 3139325)
PROCEDURE sync_location (
        p_location_id 	IN      NUMBER,
        p_create_upd       IN      VARCHAR2
) IS

  CURSOR party_sites IS
  SELECT party_site_id
  FROM hz_party_Sites
  WHERE location_id = p_location_id
  AND (status = 'A' or status = 'I') ;

  l_party_site_id NUMBER;

BEGIN
L_REALTIME_SYNC_VALUE := nvl(FND_PROFILE.VALUE('HZ_DQM_ENABLE_REALTIME_SYNC'), 'Y');
IF ( L_REALTIME_SYNC_VALUE = 'Y' OR L_REALTIME_SYNC_VALUE = 'N')
THEN
      OPEN party_sites;
      LOOP
        FETCH party_sites INTO l_party_site_id;
        EXIT WHEN party_sites%NOTFOUND;
        sync_party_site(l_party_site_id,'U');
      END LOOP;
      CLOSE party_sites;
END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    hz_common_pub.enable_cont_source_security;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    hz_common_pub.enable_cont_source_security;
    FND_MESSAGE.SET_NAME('AR', 'HZ_SYNC_SQL_EXCEP');
    FND_MESSAGE.SET_TOKEN('PROC','sync_location');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

PROCEDURE sync_cust_account (
	p_cust_acct_id	IN	NUMBER,
	p_create_upd	IN	VARCHAR2
) IS

  CURSOR c_cust_party IS
    SELECT c.PARTY_ID, p.PARTY_TYPE
    FROM HZ_CUST_ACCOUNTS c, HZ_PARTIES p
    WHERE c.cust_account_id = p_cust_acct_id
    AND p.party_id = c.party_id
    AND NOT EXISTS (
      SELECT d.PARTY_ID
      FROM HZ_DQM_SYNC_INTERFACE d
      WHERE d.ENTITY = 'PARTY'
      AND d.PARTY_ID = c.PARTY_ID
      AND d.STAGED_FLAG = 'N');

  l_party_id NUMBER;
  l_party_type VARCHAR2(200);

BEGIN
L_REALTIME_SYNC_VALUE := nvl(FND_PROFILE.VALUE('HZ_DQM_ENABLE_REALTIME_SYNC'), 'Y');
IF ( L_REALTIME_SYNC_VALUE = 'Y' OR L_REALTIME_SYNC_VALUE = 'N')
THEN
      OPEN c_cust_party;
      FETCH c_cust_party INTO l_party_id, l_party_type;
      IF c_cust_party%FOUND THEN
        IF l_party_type = 'ORGANIZATION' THEN
          HZ_DQM_SYNC.sync_org(l_party_id,'U');
        ELSIF l_party_type = 'PERSON' THEN
          HZ_DQM_SYNC.sync_person(l_party_id,'U');
        END IF;
      END IF;
      CLOSE c_cust_party;
END IF;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    hz_common_pub.enable_cont_source_security;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    hz_common_pub.enable_cont_source_security;
    FND_MESSAGE.SET_NAME('AR', 'HZ_SYNC_SQL_EXCEP');
    FND_MESSAGE.SET_TOKEN('PROC','sync_cust_account');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- VJN added for Reporting errored records into HZ_DQM_SYNC_INTERFACE

PROCEDURE insert_error_rec (
	p_party_id	IN	NUMBER,
	p_record_id	IN	NUMBER,
	p_party_site_id	IN	NUMBER,
	p_org_contact_id IN	NUMBER,
	p_entity	IN	VARCHAR2,
	p_operation	IN	VARCHAR2,
	p_staged_flag   IN      VARCHAR2 DEFAULT 'E',
    p_realtime_sync_flag IN      VARCHAR2 DEFAULT 'Y',
    p_error_data IN VARCHAR2
) IS

BEGIN

  INSERT INTO hz_dqm_sync_interface (
	PARTY_ID,
	RECORD_ID,
    PARTY_SITE_ID,
    ORG_CONTACT_ID,
	ENTITY,
	OPERATION,
	STAGED_FLAG,
    REALTIME_SYNC_FLAG,
    ERROR_DATA,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATE_LOGIN,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
    SYNC_INTERFACE_NUM
  ) VALUES (
	p_party_id,
	p_record_id,
    p_party_site_id,
    p_org_contact_id,
	p_entity,
	p_operation,
	p_staged_flag,
    p_realtime_sync_flag,
    p_error_data,
	hz_utility_pub.created_by,
        hz_utility_pub.creation_date,
        hz_utility_pub.last_update_login,
        hz_utility_pub.last_update_date,
        hz_utility_pub.user_id,
        HZ_DQM_SYNC_INTERFACE_S.nextval
  );
END insert_error_rec;

-- REPURI. Bug 4884742. Added this procedure to insert data into hz_dqm_sh_sync_interface table.
-- This is the interface table for Shadow Sync.

PROCEDURE insert_sh_interface_rec (
  p_party_id       IN  NUMBER,
  p_record_id      IN  NUMBER,
  p_party_site_id  IN  NUMBER,
  p_org_contact_id IN  NUMBER,
  p_entity         IN  VARCHAR2,
  p_operation      IN  VARCHAR2,
  p_staged_flag    IN  VARCHAR2 DEFAULT 'N'
) IS

  is_real_time VARCHAR2(1);

BEGIN
  L_REALTIME_SYNC_VALUE := nvl(FND_PROFILE.VALUE('HZ_DQM_ENABLE_REALTIME_SYNC'), 'Y');
  IF (L_REALTIME_SYNC_VALUE = 'Y') THEN
    is_real_time := 'Y';
  END IF;

    -- REPURI. Bug 4968126.
    -- Using the Merge instead of Insert statement
    -- so that duplicate records dont get inserted.

    MERGE INTO hz_dqm_sh_sync_interface S
      USING (
        SELECT
           p_entity          AS entity
          ,p_party_id        AS party_id
          ,p_record_id       AS record_id
          ,p_party_site_id   AS party_site_id
          ,p_org_contact_id  AS org_contact_id
        FROM dual ) T
      ON (S.entity                  = T.entity                  AND
          S.party_id                = T.party_id                AND
          NVL(S.record_id,-99)      = NVL(T.record_id,-99)      AND
          NVL(S.party_site_id, -99) = NVL(T.party_site_id,-99)  AND
          NVL(S.org_contact_id,-99) = NVL(T.org_contact_id,-99) AND
          S.staged_flag             <> 'E')
      WHEN NOT MATCHED THEN
      INSERT (
        PARTY_ID,
        RECORD_ID,
        PARTY_SITE_ID,
        ORG_CONTACT_ID,
        ENTITY,
        OPERATION,
        STAGED_FLAG,
        REALTIME_SYNC_FLAG,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        SYNC_INTERFACE_NUM
        ) VALUES (
        p_party_id,
        p_record_id,
        p_party_site_id,
        p_org_contact_id,
        p_entity,
        p_operation,
        p_staged_flag,
        is_real_time,
        hz_utility_pub.created_by,
        hz_utility_pub.creation_date,
        hz_utility_pub.last_update_login,
        hz_utility_pub.last_update_date,
        hz_utility_pub.user_id,
        HZ_DQM_SH_SYNC_INTERFACE_S.nextval
      );

END insert_sh_interface_rec;


PROCEDURE insert_interface_rec (
  p_party_id       IN  NUMBER,
  p_record_id      IN  NUMBER,
  p_party_site_id  IN  NUMBER,
  p_org_contact_id IN  NUMBER,
  p_entity         IN  VARCHAR2,
  p_operation      IN  VARCHAR2,
  p_staged_flag    IN  VARCHAR2  DEFAULT 'N'
) IS

  is_real_time VARCHAR2(1);

BEGIN
  L_REALTIME_SYNC_VALUE := nvl(FND_PROFILE.VALUE('HZ_DQM_ENABLE_REALTIME_SYNC'), 'Y');
  IF (L_REALTIME_SYNC_VALUE = 'Y') THEN
    is_real_time := 'Y';
  END IF;

    -- REPURI. Bug 4968126.
    -- Using the Merge instead of Insert statement
    -- so that duplicate records dont get inserted.

    MERGE INTO hz_dqm_sync_interface S
      USING (
        SELECT
           p_entity          AS entity
          ,p_party_id        AS party_id
          ,p_record_id       AS record_id
          ,p_party_site_id   AS party_site_id
          ,p_org_contact_id  AS org_contact_id
        FROM dual ) T
      ON (S.entity                  = T.entity                  AND
          S.party_id                = T.party_id                AND
          NVL(S.record_id,-99)      = NVL(T.record_id,-99)      AND
          NVL(S.party_site_id, -99) = NVL(T.party_site_id,-99)  AND
          NVL(S.org_contact_id,-99) = NVL(T.org_contact_id,-99) AND
          S.staged_flag             <> 'E')
      WHEN NOT MATCHED THEN
      INSERT (
        PARTY_ID,
        RECORD_ID,
        PARTY_SITE_ID,
        ORG_CONTACT_ID,
        ENTITY,
        OPERATION,
        STAGED_FLAG,
        REALTIME_SYNC_FLAG,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        SYNC_INTERFACE_NUM
        ) VALUES (
        p_party_id,
        p_record_id,
        p_party_site_id,
        p_org_contact_id,
        p_entity,
        p_operation,
        p_staged_flag,
        is_real_time,
        hz_utility_pub.created_by,
        hz_utility_pub.creation_date,
        hz_utility_pub.last_update_login,
        hz_utility_pub.last_update_date,
        hz_utility_pub.user_id,
        HZ_DQM_SYNC_INTERFACE_S.nextval
      );

END insert_interface_rec;


PROCEDURE optimize_indexes (
        errbuf                  OUT     NOCOPY VARCHAR2,
        retcode                 OUT     NOCOPY VARCHAR2
) IS

l_bool BOOLEAN;
l_status VARCHAR2(255);
l_index_owner VARCHAR2(255);
l_tmp VARCHAR2(2000);

l_prof VARCHAR2(255);
l_prof_val NUMBER;
idx_retcode VARCHAR2(1);
idx_err     VARCHAR2(2000);

BEGIN
  retcode := 0;

  outandlog('Starting Concurrent Program ''Synchronize Stage Schema''');
  outandlog('Start Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
  outandlog('NEWLINE');

 BEGIN
    l_prof := FND_PROFILE.VALUE('HZ_DQM_OPT_MAXTIME');
    IF upper(l_prof) = 'UNLIMITED' THEN
      l_prof_val := null;
    ELSE
      l_prof_val := TO_NUMBER(l_prof);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      l_prof_val := null;
  END;

  -- Initialize return status and message stack
  FND_MSG_PUB.initialize;

  log('Optimizing Intermedia indexes');
  log('Optimizing party index .. ', TRUE);

  l_bool := fnd_installation.GET_APP_INFO('AR',l_status,l_tmp,l_index_owner);
  OPTIMIZE_INDEX(l_index_owner || '.hz_stage_parties_t1', 'FULL', l_prof_val, idx_retcode , idx_err);
      IF idx_retcode = 1 THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
  log('Done');

  log('Optimizing party site index .. ', TRUE);
  OPTIMIZE_INDEX(l_index_owner || '.hz_stage_party_sites_t1', 'FULL', l_prof_val, idx_retcode , idx_err);
      IF idx_retcode = 1 THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
  log('Done');

  log('Optimizing contact index .. ', TRUE);
  OPTIMIZE_INDEX(l_index_owner || '.hz_stage_contact_t1', 'FULL', l_prof_val, idx_retcode , idx_err);
      IF idx_retcode = 1 THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
  log('Done');

  log('Optimizing contact point index .. ', TRUE);
  OPTIMIZE_INDEX(l_index_owner || '.hz_stage_cpt_t1', 'FULL', l_prof_val, idx_retcode , idx_err);
      IF idx_retcode = 1 THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
  log('Done');

  outandlog('Concurrent Program Execution completed ');
  outandlog('End Time : '|| TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));


END;

/**
* Procedure to write a message to the out NOCOPY file
**/
PROCEDURE out(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF message = 'NEWLINE' THEN
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.output,message);
  ELSE
    FND_FILE.put(fnd_file.output,message);
  END IF;
END out;

/**
* Procedure to write a message to the log file
**/
PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE
) IS
BEGIN
  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put(fnd_file.log,message);
  END IF;
END log;

/**
* Procedure to write a message to the out NOCOPY and log files
**/
PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  out(message, newline);
  log(message, newline);
END outandlog;

/**
* Function to fetch messages of the stack and log the error
* Also returns the error
**/
FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS

  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
  END LOOP;
  IF (SQLERRM IS NOT NULL) THEN
    l_msg_data := l_msg_data || SQLERRM;
  END IF;
  log(l_msg_data);
  RETURN l_msg_data;
END logerror;

PROCEDURE stage_party_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT  NOCOPY NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status OUT          NOCOPY VARCHAR2
) IS

l_party_type VARCHAR2(30);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT party_type INTO l_party_type
  FROM HZ_PARTIES
  WHERE party_id = p_from_id;

--Bug 9249643
 	 IF     l_party_type='ORGANIZATION' THEN
 	             sync_org(p_to_fk_id, 'U');
 	     ELSIF  l_party_type='PERSON' THEN
 	             sync_person(p_to_fk_id, 'U');
 	 END IF;

  IF l_party_type <> 'PARTY_RELATIONSHIP' THEN
    BEGIN
      UPDATE HZ_STAGED_PARTIES
      SET STATUS = 'M'
      WHERE party_id = p_from_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END stage_party_merge;

PROCEDURE stage_party_site_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT  NOCOPY NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status OUT          NOCOPY VARCHAR2
) IS

l_party_id NUMBER;
l_party_site_id         NUMBER;
l_party_site_search_rec HZ_PARTY_SEARCH.party_site_search_rec_type;
l_party_site_stage_rec  HZ_PARTY_STAGE.PARTY_SITE_STAGE_REC_TYPE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    DELETE FROM HZ_STAGED_PARTY_SITES
    WHERE party_site_id = p_from_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

  IF p_from_fk_id = p_to_fk_id THEN
    SELECT party_id INTO l_party_id
    FROM HZ_PARTY_SITES
    WHERE party_site_id = p_from_id;

    l_party_site_id := p_from_id;

    SAVEPOINT party_site_sync;

    BEGIN
      sync_party_site (l_party_site_id,'C');

    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO party_site_sync;
        sync_party_site (p_from_id, 'C');
    END;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END stage_party_site_merge;

PROCEDURE stage_contact_point_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT  NOCOPY NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status OUT          NOCOPY VARCHAR2
) IS

l_contact_point_id      NUMBER;
l_cpt_search_rec        HZ_PARTY_SEARCH.contact_point_search_rec_type;
l_contact_pt_stage_rec  HZ_PARTY_STAGE.CONTACT_PT_STAGE_REC_TYPE;
l_party_id NUMBER := 0;
l_pr_id NUMBER;
l_num_ocs NUMBER;
l_ot_id NUMBER;
l_ot_table VARCHAR2(60);
l_party_type VARCHAR2(60);

  CURSOR c_cp_party_site (cp_id NUMBER) IS
    SELECT owner_table_id
    FROM HZ_CONTACT_POINTS
    WHERE owner_table_name = 'HZ_PARTY_SITES'
    AND contact_point_id = cp_id;

  CURSOR c_cp_org_contact (cp_id NUMBER) IS
    SELECT oc.org_contact_id
    FROM HZ_CONTACT_POINTS cp, HZ_RELATIONSHIPS rl, HZ_ORG_CONTACTS oc
    WHERE owner_table_name = 'HZ_PARTIES'
    AND contact_point_id = cp_id
    AND rl.PARTY_ID = cp.owner_table_id
    AND oc.party_relationship_id = rl.relationship_id
    AND rl.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND rl.OBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND rl.DIRECTIONAL_FLAG = 'F';

  CURSOR c_ps_org_contact (ps_id NUMBER) IS
    SELECT oc.org_contact_id
    FROM HZ_PARTY_SITES ps, HZ_RELATIONSHIPS rl, HZ_ORG_CONTACTS oc
    WHERE ps.party_site_id = ps_id
    AND rl.PARTY_ID = ps.party_id
    AND oc.party_relationship_id = rl.relationship_id
    AND rl.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND rl.OBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND rl.DIRECTIONAL_FLAG = 'F';

l_cp_party_site_id         NUMBER;
l_cp_org_contact_id        NUMBER;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    DELETE FROM HZ_STAGED_CONTACT_POINTS
    WHERE contact_point_id = p_from_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

  IF p_from_fk_id = p_to_fk_id THEN

    l_contact_point_id := p_from_id;
    l_party_id := 0;

    SELECT owner_table_name,owner_table_id INTO l_ot_table, l_ot_id
    FROM hz_contact_points
    WHERE contact_point_id = l_contact_point_id;

    IF l_ot_table = 'HZ_PARTY_SITES' THEN
      SELECT party_id INTO l_party_id
      FROM HZ_PARTY_SITES
      WHERE party_site_id = l_ot_id;

    ELSIF l_ot_table = 'HZ_PARTIES' THEN
      SELECT party_type INTO l_party_type
      FROM hz_parties
      WHERE party_id = l_ot_id;

      IF l_party_type = 'ORGANIZATION' OR l_party_type = 'PERSON' THEN
        l_party_id := l_ot_id;
      ELSIF l_party_type = 'PARTY_RELATIONSHIP' THEN
        SELECT relationship_id, object_id INTO l_pr_id, l_party_id
        FROM hz_relationships                      --bug 4500011 replaced hz_party_relationships with hz_relationships
        WHERE party_id = l_ot_id
        AND subject_table_name = 'HZ_PARTIES'
        AND object_table_name = 'HZ_PARTIES'
        AND directional_flag = 'F';

        SELECT count(1) INTO l_num_ocs
        FROM HZ_ORG_CONTACTS
        WHERE party_relationship_id = l_pr_id;

        IF l_num_ocs = 0 THEN
          l_party_id := 0;
        END IF;
      END IF;
    END IF;

    IF l_party_id <> 0 AND l_party_id IS NOT NULL THEN
    fnd_file.put_line(fnd_file.log,'pt 11');
      SAVEPOINT contact_point_sync;
    fnd_file.put_line(fnd_file.log,'pt 12');
      BEGIN
        sync_contact_point (l_contact_point_id,'C');


      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO contact_point_sync;
          sync_contact_point (p_from_id, 'C');
      END;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.log,'Error here1 '||SQLERRM);
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END stage_contact_point_merge;


PROCEDURE stage_contact_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT  NOCOPY NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status OUT          NOCOPY VARCHAR2
) IS

l_org_contact_id NUMBER;
l_party_id NUMBER;
l_contact_search_rec    HZ_PARTY_SEARCH.contact_search_rec_type;
l_contact_stage_rec     HZ_PARTY_STAGE.CONTACT_STAGE_REC_TYPE;
l_rel_party_id NUMBER;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    DELETE FROM HZ_STAGED_CONTACTS
    WHERE org_contact_id = p_from_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

  IF p_from_fk_id = p_to_fk_id THEN
    l_org_contact_id := p_from_id;

    SELECT pr.party_id, pr.object_id INTO l_rel_party_id, l_party_id
    FROM HZ_RELATIONSHIPS pr, HZ_ORG_CONTACTS oc             --bug 4500011 replaced hz_party_relationships with hz_relationships
    WHERE oc.org_contact_id = l_org_contact_id
    AND pr.relationship_id = oc.party_relationship_id
    AND pr.subject_table_name = 'HZ_PARTIES'
    AND pr.object_table_name = 'HZ_PARTIES'
    AND pr.directional_flag = 'F';

    SAVEPOINT contact_sync;
    BEGIN
      sync_contact(l_org_contact_id,'C');

      UPDATE HZ_STAGED_PARTY_SITES
      SET party_id = l_party_id
      WHERE party_site_id in (
          SELECT party_site_id
          FROM HZ_PARTY_SITES
          WHERE party_id = l_rel_party_id
          AND (nvl(STATUS,'A') = 'A' OR nvl(STATUS,'A')='I'));

      UPDATE HZ_STAGED_CONTACT_POINTS
      SET party_id = l_party_id
      WHERE contact_point_id in (
          SELECT contact_point_id
          FROM HZ_CONTACT_POINTS
          WHERE owner_table_name = 'HZ_PARTIES'
          AND owner_table_id = l_rel_party_id
          AND (nvl(STATUS,'A') = 'A' OR nvl(STATUS,'A')='I'));


    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO contact_sync;
        sync_contact(p_from_id, 'C');
    END;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END stage_contact_merge;


-- procedure to sync data realtime from hx_dqm_sync_interface table
-- the program sets staged_flag = 'P' as an intermediate step during complete processing of rows in going on.
FUNCTION realtime_sync  (p_subscription_guid  IN RAW,
   p_event              IN OUT NOCOPY WF_EVENT_T) return VARCHAR2
 AS

 TYPE PartyIdList IS TABLE OF NUMBER;
 TYPE OperationList IS TABLE OF VARCHAR2(1);
 TYPE EntityList IS TABLE OF VARCHAR2(30);

 l_party_id PartyIdList;
 l_record_id PartyIdList;
 l_entity EntityList;
 l_operation OperationList;
 l_party_type VARCHAR2(30);
 l_sql_error_message VARCHAR2(2000);
 l_rowid EntityList;

 errbuf VARCHAR2(1000);
 retcode VARCHAR2(10);

 i_party boolean := false;
 i_party_sites boolean := false;
 i_contacts boolean := false;
 i_contact_points boolean  := false;
 l_dqm_run VARCHAR2(1);


BEGIN

  select 'Y' into l_dqm_run
  from HZ_TRANS_FUNCTIONS_VL
  where STAGED_FLAG='Y'
  and nvl(ACTIVE_FLAG,'Y')='Y'
  and rownum = 1;

  IF (l_dqm_run = 'Y') THEN

      update HZ_DQM_SYNC_INTERFACE set STAGED_FLAG = 'P'
        where STAGED_FLAG = 'N' and REALTIME_SYNC_FLAG = 'Y'
        returning party_id, record_id, entity, operation, rowid BULK COLLECT into
        l_party_id, l_record_id, l_entity, l_operation, l_rowid;

   COMMIT;

   FOR i in 1..l_party_id.COUNT LOOP
     BEGIN
     IF (l_entity(i) = 'PARTY') THEN
        select party_type into l_party_type from hz_parties where party_id = l_party_id(i);
        hz_trans_pkg.set_party_type(l_party_type);
        HZ_STAGE_MAP_TRANSFORM.sync_single_party(l_party_id(i), l_party_type, l_operation(i));
        i_party := true;
     ELSIF (l_entity(i) = 'PARTY_SITES') THEN
        HZ_STAGE_MAP_TRANSFORM.sync_single_party_site(l_record_id(i), l_operation(i));
        i_party := true;
        i_party_sites := true;
     ELSIF (l_entity(i) = 'CONTACTS') THEN
        HZ_STAGE_MAP_TRANSFORM.sync_single_contact(l_record_id(i), l_operation(i));
        i_party := true;
        i_contacts := true;
     ELSIF (l_entity(i) = 'CONTACT_POINTS') THEN
        HZ_STAGE_MAP_TRANSFORM.sync_single_contact_point(l_record_id(i), l_operation(i));
        i_party := true;
        i_contact_points := true;
     END IF;

     BEGIN
          IF (l_entity(i) <> 'PARTY') THEN
              insert_into_interface(l_party_id(i));
          END IF;
          IF l_operation(i) = 'C' THEN
               DELETE FROM hz_dqm_sync_interface WHERE rowid = l_rowid(i) ;
          ELSE
               UPDATE hz_dqm_sync_interface SET staged_flag = 'Y' WHERE rowid = l_rowid(i);
          END IF;
     EXCEPTION WHEN OTHERS THEN
          NULL;
     END;

     EXCEPTION
       WHEN OTHERS THEN
          -- update staged_flag to 'E' if program generates an error.
          l_sql_error_message := SQLERRM;
          UPDATE hz_dqm_sync_interface SET error_data = l_sql_error_message, staged_flag = 'E' WHERE ROWID = l_rowid(i);
     END;

     COMMIT;
  END LOOP ;
  COMMIT;

   REALTIME_SYNC_INDEXES(i_party, i_party_sites, i_contacts, i_contact_points);
   RETURN 'SUCCESS';
 END IF;
 EXCEPTION
        when others then
        IF p_subscription_guid IS NOT NULL THEN
          WF_CORE.context('HZ_DQM_SYNC', 'REALTIME_SYNC', p_event.getEventName(), p_subscription_guid);
          WF_EVENT.setErrorInfo(p_event, 'ERROR');
        END IF;
        return 'ERROR';

END REALTIME_SYNC;



-- procedure to sync indexes real time.  Commented code will be useful later.
PROCEDURE realtime_sync_indexes(i_party IN boolean,
  i_party_sites IN boolean,
  i_contacts IN boolean,
  i_contact_points IN boolean
)
AS

  idx_retcode varchar2(1);
  idx_err     varchar2(2000);

  l_status VARCHAR2(255);
  l_index_owner VARCHAR2(255);
  l_tmp		VARCHAR2(2000);

BEGIN
 IF(fnd_installation.GET_APP_INFO('AR',l_status,l_tmp,l_index_owner)) THEN
  IF (i_party) THEN
        SYNC_INDEX_REALTIME(l_index_owner || '.hz_stage_parties_t1',
                                       idx_retcode , idx_err);
        IF idx_retcode = 1 THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

  END IF;
  IF (i_party_sites) THEN
        SYNC_INDEX_REALTIME(l_index_owner || '.hz_stage_party_sites_t1',
                                       idx_retcode , idx_err);
        IF idx_retcode = 1 THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

  END IF;
  IF (i_contacts) THEN
      SYNC_INDEX_REALTIME(l_index_owner || '.hz_stage_contact_t1',
                                       idx_retcode , idx_err);
      IF idx_retcode = 1 THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

  END IF;
  IF (i_contact_points) THEN
      SYNC_INDEX_REALTIME(l_index_owner || '.hz_stage_cpt_t1',
                                       idx_retcode , idx_err);
      IF idx_retcode = 1 THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF;
 END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    outandlog('Error : Aborting Program');
    outandlog(idx_err);
  WHEN OTHERS THEN
    outandlog('Error : Aborting Program');
    outandlog(SQLERRM);
END REALTIME_SYNC_INDEXES;

-- returns 'Y' if at least one row present in the global temporary table.
-- This is done to reduce the number of events fired.
FUNCTION check_for_transaction
RETURN VARCHAR2 IS

bool varchar2(1) := 'N';

BEGIN
    SELECT 'Y' INTO bool
    FROM HZ_DQM_SYNC_GT
    WHERE ROWNUM = 1;
    IF bool <> 'Y' THEN
        bool := 'N';
    END IF;
   RETURN bool;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN bool;
END check_for_transaction;


PROCEDURE sync_work_unit(
    retcode     OUT NOCOPY  VARCHAR2,
    err         OUT NOCOPY  VARCHAR2,
    p_from_rec  IN  VARCHAR2,
    p_to_rec    IN  VARCHAR2,
    p_sync_type IN  VARCHAR2
) IS

  -- REPURI - Removed all the variable declarations not being used,
  -- as part of code changes for Sync Performance Improvement Project.

  l_sql_error_message   VARCHAR2(2000);
  l_do_exec boolean     := TRUE;
  l_sync_party_cur      HZ_DQM_SYNC.SyncCurTyp;
  l_sync_party_site_cur HZ_DQM_SYNC.SyncCurTyp;
  l_sync_contact_cur    HZ_DQM_SYNC.SyncCurTyp;
  l_sync_cpt_cur        HZ_DQM_SYNC.SyncCurTyp;

BEGIN

  log(' p_from_rec = '|| p_from_rec);
  log(' p_to_rec = '|| p_to_rec);
  log(' p_sync_type = ' || p_sync_type);
  LOOP
    BEGIN
      IF (l_do_exec = FALSE) THEN
        log('l_do_exec is false');
        EXIT;
      ELSE
        log('l_do_exec is true');
        l_do_exec := FALSE;
      END IF;

      -- Part of DQM Sync Peformance Improvements Project (REPURI).

      -- Instead of calling the sync_single_xxx in a LOOP for each row, we now call
      -- the new open_sync_xxx_cursor and pass the IN OUT CURSOR to sync_all_xxx APIs
      -- for all the 4 entities, to Fetch and Insert/Update data in Bulk Mode.

      log ('-----------------------------');
      log ('Begin DQM SYNC');
      log ('-----------------------------');

      -- Sync all organization parties
      -- For Create
      log ('-----------------------------');
      log ('For Create Organization Party');
      log ('-----------------------------');
      log ('Calling HZ_STAGE_MAP_TRANSFORM.open_sync_party_cursor');
      HZ_STAGE_MAP_TRANSFORM.open_sync_party_cursor ('C','ORGANIZATION', p_from_rec, p_to_rec, l_sync_party_cur);
      log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_parties');
      HZ_STAGE_MAP_TRANSFORM.sync_all_parties ('C', 'DQM_SYNC' ,l_sync_party_cur);
      -- For Update
      log ('-----------------------------');
      log ('For Update Organization Party');
      log ('-----------------------------');
      log ('Calling HZ_STAGE_MAP_TRANSFORM.open_sync_party_cursor');
      HZ_STAGE_MAP_TRANSFORM.open_sync_party_cursor ('U','ORGANIZATION', p_from_rec, p_to_rec, l_sync_party_cur);
      log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_parties');
      HZ_STAGE_MAP_TRANSFORM.sync_all_parties ('U', 'DQM_SYNC' , l_sync_party_cur);

      -- Sync all person parties
      -- For Create
      log ('-----------------------');
      log ('For Create Person Party');
      log ('-----------------------');
      log ('Calling HZ_STAGE_MAP_TRANSFORM.open_sync_party_cursor');
      HZ_STAGE_MAP_TRANSFORM.open_sync_party_cursor ('C','PERSON', p_from_rec, p_to_rec, l_sync_party_cur);
      log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_parties');
      HZ_STAGE_MAP_TRANSFORM.sync_all_parties ('C', 'DQM_SYNC', l_sync_party_cur);
      -- For Update
      log ('-----------------------');
      log ('For Update Person Party');
      log ('-----------------------');
      log ('Calling HZ_STAGE_MAP_TRANSFORM.open_sync_party_cursor');
      HZ_STAGE_MAP_TRANSFORM.open_sync_party_cursor ('U','PERSON', p_from_rec, p_to_rec, l_sync_party_cur);
      log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_parties');
      HZ_STAGE_MAP_TRANSFORM.sync_all_parties ('U', 'DQM_SYNC', l_sync_party_cur);

      -- Sync all party_sites
      -- For Create
      log ('----------------------');
      log ('For Create Party Sites');
      log ('----------------------');
      log ('Calling HZ_STAGE_MAP_TRANSFORM.open_sync_party_site_cursor');
      HZ_STAGE_MAP_TRANSFORM.open_sync_party_site_cursor ('C', p_from_rec, p_to_rec, l_sync_party_site_cur);
      log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_party_sites');
      HZ_STAGE_MAP_TRANSFORM.sync_all_party_sites ('C', 'DQM_SYNC', l_sync_party_site_cur);
      -- For Update
      log ('----------------------');
      log ('For Update Party Sites');
      log ('----------------------');
      log ('Calling HZ_STAGE_MAP_TRANSFORM.open_sync_party_site_cursor');
      HZ_STAGE_MAP_TRANSFORM.open_sync_party_site_cursor ('U', p_from_rec, p_to_rec, l_sync_party_site_cur);
      log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_party_sites');
      HZ_STAGE_MAP_TRANSFORM.sync_all_party_sites ('U', 'DQM_SYNC', l_sync_party_site_cur);

      -- Sync all contacts
      -- For Create
      log ('-------------------');
      log ('For Create Contacts');
      log ('-------------------');
      log ('Calling HZ_STAGE_MAP_TRANSFORM.open_sync_contact_cursor');
      HZ_STAGE_MAP_TRANSFORM.open_sync_contact_cursor ('C', p_from_rec, p_to_rec, l_sync_contact_cur);
      log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_contacts');
      HZ_STAGE_MAP_TRANSFORM.sync_all_contacts ('C', 'DQM_SYNC', l_sync_contact_cur);
      -- For Update
      log ('-------------------');
      log ('For Update Contacts');
      log ('-------------------');
      log ('Calling HZ_STAGE_MAP_TRANSFORM.open_sync_contact_cursor');
      HZ_STAGE_MAP_TRANSFORM.open_sync_contact_cursor ('U', p_from_rec, p_to_rec, l_sync_contact_cur);
      log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_contacts');
      HZ_STAGE_MAP_TRANSFORM.sync_all_contacts ('U', 'DQM_SYNC', l_sync_contact_cur);

      -- Sync all contact_points
      -- For Create
      log ('-------------------------');
      log ('For Create Contact Points');
      log ('-------------------------');
      log ('Calling HZ_STAGE_MAP_TRANSFORM.open_sync_cpt_cursor');
      HZ_STAGE_MAP_TRANSFORM.open_sync_cpt_cursor ('C', p_from_rec, p_to_rec, l_sync_cpt_cur);
      log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_contact_points');
      HZ_STAGE_MAP_TRANSFORM.sync_all_contact_points ('C', 'DQM_SYNC', l_sync_cpt_cur);
      -- For Update
      log ('-------------------------');
      log ('For Update Contact Points');
      log ('-------------------------');
      log ('Calling HZ_STAGE_MAP_TRANSFORM.open_sync_cpt_cursor');
      HZ_STAGE_MAP_TRANSFORM.open_sync_cpt_cursor ('U', p_from_rec, p_to_rec, l_sync_cpt_cur);
      log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_contact_points');
      HZ_STAGE_MAP_TRANSFORM.sync_all_contact_points ('U', 'DQM_SYNC', l_sync_cpt_cur);

      -- Delete from from hz_dqm_sync_interface table, all the range
      -- of records that are already processed
      DELETE FROM hz_dqm_sync_interface
      WHERE staged_flag = 'N'
      AND error_data IS NULL
	  AND sync_interface_num BETWEEN p_from_rec AND p_to_rec;

    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE = -1555 THEN
          l_do_exec := true;
          log(' Snapshot too old exception raised and caught. Cursor re-executed. ');
        ELSE
          retcode :=  2;
          err := SQLERRM;
          log(err);
          RAISE;
          EXIT;
        END IF;
      END;

    END LOOP ;

  EXCEPTION
    WHEN OTHERS THEN
      retcode :=  2;
      err := SQLERRM;
      log(err);

END sync_work_unit;


PROCEDURE sync_parties(retcode  OUT NOCOPY   VARCHAR2,
    err             OUT NOCOPY    VARCHAR2,
    p_num_of_workers  IN  VARCHAR2,
    p_indexes_only  IN VARCHAR2
) IS

l_num_of_workers NUMBER;
l_min_id NUMBER;
l_max_id NUMBER;
l_range NUMBER;
l_count NUMBER;
l_from_rec NUMBER;
l_to_rec NUMBER;
l_from_rec_v VARCHAR2(255);
l_to_rec_v VARCHAR2(255);
idx_name VARCHAR2(300); -- VJN Increased Size of this for P1 4096839, from 30 to 300
l_index_owner VARCHAR2(255);
l_status VARCHAR2(255);
l_tmp		VARCHAR2(2000);
idx_retcode varchar2(1);
idx_err     varchar2(2000);
TYPE nTable IS TABLE OF NUMBER index by binary_integer;
l_sub_requests nTable;

l_range1 NUMBER;
j number := 0;
req_data            varchar2(30);
l_indexes_only      VARCHAR2(30);
l_workers_completed boolean ;



-- VJN Introduced

FIRST BOOLEAN ;
l_index_conc_program_req_id NUMBER ;
l_request_id NUMBER ;
--Start of bug 4915282
CURSOR c_non_indexed IS select 1 from hz_dqm_stage_log where operation= 'ALTER_INDEX'
                        and start_flag = 'Y' and end_flag ='Y';
l_index_count number := 0;
--End of bug 4915282
BEGIN
    log (' -------------------------------------------');
    log ('Entering procedure sync_parties');
    log ('p_num_of_workers = ' || p_num_of_workers);
    log('p_indexes_only = '|| p_indexes_only);

    req_data := fnd_conc_global.request_data;

    log(' req_data = ' || req_data);

    l_indexes_only := nvl(p_indexes_only, 'N');

    log (' l_indexes_only = ' || l_indexes_only);



    /************* we don't have to support this  ************/
    -- IF ( l_indexes_only = 'Y') AND (req_data IS NULL) THEN
    --    req_data := 'PAUSED_FOR_INDEX';
    -- END IF;

    -- First Phase
    IF ( req_data IS NULL) THEN

	--Start Bug:5407223---
	/* Delete records from HZ_DQM_SYNC_INTERFACE table if that record already exists in staged table*/
	log('Start Time for delete statements = ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
	delete /*+ parallel(i)  */ from hz_dqm_sync_interface i where entity='PARTY' and operation='C'
	and party_id in (select /*+ parallel_index(s) index_ffs(s) */ party_id from hz_staged_parties s );
	log (' After delete duplicate party entity records, time= '||TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));

	delete /*+ parallel(i)  */ from hz_dqm_sync_interface i where entity='PARTY_SITES' and operation='C'
	and record_id in (select /*+ parallel_index(s) index_ffs(s) */ party_site_id from hz_staged_party_sites s );
	log (' After delete duplicate party site entity records '||TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS') );

	delete /*+ parallel(i)  */ from hz_dqm_sync_interface i where entity='CONTACTS' and operation='C'
	and record_id in (select /*+ parallel_index(s) index_ffs(s) */ org_contact_id from hz_staged_contacts s );
	log (' After delete duplicate contact entity records = '||TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS') );

	delete /*+ parallel(i)  */ from hz_dqm_sync_interface i where entity='CONTACT_POINTS' and operation='C'
	and record_id in (select /*+ parallel_index(s) index_ffs(s) */ contact_point_id from hz_staged_contact_points s );
	log (' After delete duplicate contact point entity records = '||TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS') );
	log('End Time for delete statements = ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));

	--End Bug:5407223---

	--start bug 5460390: Add commit
	COMMIT;
	FND_CONCURRENT.AF_Commit;
	log('Committed Records');
	--end bug 5460390
        -- Get number of workers
        l_num_of_workers := to_number(nvl(p_num_of_workers, '1'));

        -- If number of workers is 0, make it 1
        IF (l_num_of_workers <= 0) THEN
          l_num_of_workers := 1;
        END IF;

        -- Get range if any possible optimization could be done on the number of workers to
        -- be deployed
        SELECT min(sync_interface_num), max(sync_interface_num) into l_min_id, l_max_id
        FROM hz_dqm_sync_interface
        WHERE staged_flag = 'N';
        l_range := l_max_id - l_min_id;

        IF ( l_range <= l_num_of_workers) THEN
            l_num_of_workers := 1;
            log('Too less data to process hence reducing the number of workers. ');
        END IF;

          l_from_rec := l_min_id;
          l_range1 := floor(l_range/l_num_of_workers);

          log('Total number of Data Workers deployed = ' || l_num_of_workers );
          log ('Data Workers only create/update data');

          --get request_id of this program
          l_request_id := FND_GLOBAL.conc_request_id ;

        -- Deploy Data Workers

        FIRST := TRUE ;
        FOR I in 1..l_num_of_workers LOOP
            j := j + 1;
            l_to_rec := l_from_rec + l_range1;
            IF (l_to_rec > l_max_id) THEN
                l_to_rec := l_max_id;
            END IF;
           log ( 'Calling the DQM Import Sync child program for Data Worker ' || i);
           log ( 'l_from_rec and l_to_rec are : ' || to_char(l_from_rec) || ' , ' || TO_CHAR(l_to_rec) );

           l_sub_requests(i) := FND_REQUEST.SUBMIT_REQUEST('AR', 'ARHDCH',
                            'DQM Import Sync Child Program' || to_char(i),
                            NULL,--Bug No:3941365
                            true, to_char(l_from_rec), TO_CHAR(l_to_rec), 'BATCH');

           -- Boolean used to track the submission of the parallel sync concurrent program

           IF l_sub_requests(i) = 0 THEN
                log('Error submitting worker ' || i);
                log(fnd_message.get);
           ELSE
                log('Submitted request for Worker ' || TO_CHAR(I) );
                log('Request ID : ' || l_sub_requests(i));

                    IF FIRST
                    THEN
                        FIRST := FALSE ;

                        log('Calling Parallel Sync Index concurrent program');
                        log('Request Id of the program to be waited on, that is being passed to this : ' || l_request_id );
                        l_index_conc_program_req_id := FND_REQUEST.SUBMIT_REQUEST('AR',
                                                                 'ARHDQMPP',
                                                                 'DQM Parallel Sync Index Parent Program',
                                                                  NULL,
                                                                  FALSE,
                                                                  l_request_id
                                  );
                        log('Request Id of Parallel Sync concurrent Program is  : ' || l_index_conc_program_req_id );
                    END IF ;
           END IF;

           EXIT when l_sub_requests(i) = 0;
           l_from_rec := l_to_rec + 1;
           IF (l_to_rec >= l_max_id) THEN
                EXIT;
           END IF;
        END LOOP;

      -- be in paused status until all the concurrent requests submitted have completed
      fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                        request_data => 'END') ;
      err  := 'Concurrent Workers submitted.';
      retcode := 0;

  ELSIF( req_data = 'END') THEN
          -- This is for error handling, to make sure that after the
          -- control of this program returns here, that we catch any
          -- errored concurrent requests that were spawned by this program
          -- and if any of them errored out, we error out this program
          -- itself
          log ('checking completion status of child programs spawned by tis program' );
          l_workers_completed := TRUE;

          -- program id is hard coded since any conc program submitted by this program is construed
          -- as its child in FND_CONCURRENT_REQUESTS, regardless of the TRUE/FALSE flag
          -- used in FND_CONCURRENT.SUBMIT_REQUEST

          select request_id BULK COLLECT into l_sub_requests
          from fnd_concurrent_requests R
          where parent_request_id = l_request_id
          and concurrent_program_id = 46839
          and (phase_code<>'C' or status_code<>'C');

          IF  l_sub_requests.count > 0 THEN
            l_workers_completed := FALSE;
            FOR I in 1..l_sub_requests.COUNT LOOP
              outandlog('Worker with request id ' || l_sub_requests(I) );
              outandlog('Did not complete normally.');
              retcode := 2;
              log(' retcode = ' || retcode);
              RAISE FND_API.G_EXC_ERROR;
            END LOOP;
          END IF;
	  --Start of Bug No : 4915282
	  --Set the index transactional, if the search on non indexed records is enabled.
	  L_REALTIME_SYNC_VALUE := nvl(FND_PROFILE.VALUE('HZ_DQM_ENABLE_REALTIME_SYNC'), 'Y');
          IF(L_REALTIME_SYNC_VALUE = 'Y') THEN
	    OPEN c_non_indexed;
	    FETCH c_non_indexed INTO l_index_count;
	    if(c_non_indexed%FOUND) then
    	      HZ_DQM_SYNC.set_index_transactional(enabled=>'Y');
            end if;
	    CLOSE c_non_indexed;
          END IF;
	  --End of Bug No : 4915282
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    log('DQM Synchronization Program Aborted');
    retcode := 2;
    err := err || logerror || SQLERRM;
    RAISE;
  WHEN OTHERS THEN
    log('DQM Synchronization Program Aborted');
    retcode := 2;
    err := err || logerror || SQLERRM;
    RAISE;
END sync_parties;


PROCEDURE sync_index_conc(
        retcode                 OUT    NOCOPY VARCHAR2,
        err                     OUT    NOCOPY VARCHAR2,
        p_index_name            IN     VARCHAR2 ) IS
BEGIN
  log('Index being synched ...  ' || p_index_name);
  sync_index( p_index_name, retcode, err);
  if (retcode=2) then
   RAISE FND_API.G_EXC_ERROR;
  end if;
  EXCEPTION
  WHEN OTHERS THEN
    retcode :=  2;
    err := SQLERRM;
    RAISE FND_API.G_EXC_ERROR;--
END sync_index_conc;

----------------------------------------
-- VJN Changes for SYNC in R12
---------------------------------------

-- VJN modified for R12 for Bulk Import
-- This API would be called by the Bulk Import Post Processing Program, to directly insert
-- data into the STAGING tables

-- REPURI, Modifying to procedure signature to process the records in bulk mode. Bug 4884735.
PROCEDURE sync_work_unit_imp(
  p_batch_id        IN          NUMBER,
  p_batch_mode_flag IN          VARCHAR2,
  p_from_osr        IN          VARCHAR2,
  p_to_osr          IN          VARCHAR2,
  p_os              IN          VARCHAR2,
  x_return_status   OUT NOCOPY  VARCHAR2,
  x_msg_count       OUT NOCOPY  NUMBER,
  x_msg_data        OUT NOCOPY  VARCHAR2
)
IS

  l_sync_party_cur      HZ_DQM_SYNC.SyncCurTyp;
  l_sync_party_site_cur HZ_DQM_SYNC.SyncCurTyp;
  l_sync_contact_cur    HZ_DQM_SYNC.SyncCurTyp;
  l_sync_cpt_cur        HZ_DQM_SYNC.SyncCurTyp;

BEGIN
  -- Part of DQM Bulk Import Sync Peformance Improvements Project (REPURI). Bug 4884735.

  -- Instead of calling the sync_single_xxx_online in a LOOP for each row, we now call
  -- the new open_bulk_imp_sync_xxx_cur and pass the IN OUT CURSOR to sync_all_xxx APIs
  -- for all the 4 entities, to Fetch and Insert/Update data in Bulk Mode.

  log ('-----------------------------');
  log ('Begin Bulk Import SYNC');
  log ('-----------------------------');
  log ('');
  log ('------------------------');
  log ('Incoming variable values');
  log ('------------------------');
  log ('p_batch_id - '|| p_batch_id);
  log ('p_batch_mode_flag - '||p_batch_mode_flag);
  log ('p_from_osr - '||p_from_osr);
  log ('p_to_osr - '||p_to_osr);
  log ('p_os - '||p_os);
  log ('------------------------');

  -- Sync all organization parties
  -- For Create
  log ('-----------------------------');
  log ('For Create Organization Party');
  log ('-----------------------------');

  log ('Calling HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_party_cur');
  HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_party_cur (
     p_batch_id         => p_batch_id
    ,p_batch_mode_flag  => p_batch_mode_flag
    ,p_from_osr         => p_from_osr
    ,p_to_osr           => p_to_osr
    ,p_os               => p_os
    ,p_party_type       => 'ORGANIZATION'
    ,p_operation        => 'I'
    ,x_sync_party_cur   => l_sync_party_cur
  );

  log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_parties');
  HZ_STAGE_MAP_TRANSFORM.sync_all_parties ('C', 'IMPORT_SYNC', l_sync_party_cur);

  -- For Update
  log ('-----------------------------');
  log ('For Update Organization Party');
  log ('-----------------------------');

  log ('Calling HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_party_cur');
  HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_party_cur (
     p_batch_id         => p_batch_id
    ,p_batch_mode_flag  => p_batch_mode_flag
    ,p_from_osr         => p_from_osr
    ,p_to_osr           => p_to_osr
    ,p_os               => p_os
    ,p_party_type       => 'ORGANIZATION'
    ,p_operation        => 'U'
    ,x_sync_party_cur   => l_sync_party_cur
  );

  log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_parties');
  HZ_STAGE_MAP_TRANSFORM.sync_all_parties ('U', 'IMPORT_SYNC', l_sync_party_cur);

  -- Sync all person parties
  -- For Create

  log ('-----------------------');
  log ('For Create Person Party');
  log ('-----------------------');

  log ('Calling HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_party_cur');
  HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_party_cur (
     p_batch_id         => p_batch_id
    ,p_batch_mode_flag  => p_batch_mode_flag
    ,p_from_osr         => p_from_osr
    ,p_to_osr           => p_to_osr
    ,p_os               => p_os
    ,p_party_type       => 'PERSON'
    ,p_operation        => 'I'
    ,x_sync_party_cur   => l_sync_party_cur
  );

  log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_parties');
  HZ_STAGE_MAP_TRANSFORM.sync_all_parties ('C', 'IMPORT_SYNC', l_sync_party_cur);

  -- For Update

  log ('-----------------------');
  log ('For Update Person Party');
  log ('-----------------------');

  log ('Calling HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_party_cur');
  HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_party_cur (
     p_batch_id         => p_batch_id
    ,p_batch_mode_flag  => p_batch_mode_flag
    ,p_from_osr         => p_from_osr
    ,p_to_osr           => p_to_osr
    ,p_os               => p_os
    ,p_party_type       => 'PERSON'
    ,p_operation        => 'U'
    ,x_sync_party_cur   => l_sync_party_cur
  );

  log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_parties');
  HZ_STAGE_MAP_TRANSFORM.sync_all_parties ('U', 'IMPORT_SYNC', l_sync_party_cur);

  -- Sync all party_sites
  -- For Create

  log ('----------------------');
  log ('For Create Party Sites');
  log ('----------------------');

  log ('Calling HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_psite_cur');
  HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_psite_cur (
     p_batch_id            => p_batch_id
    ,p_batch_mode_flag     => p_batch_mode_flag
    ,p_from_osr            => p_from_osr
    ,p_to_osr              => p_to_osr
    ,p_os                  => p_os
    ,p_operation           => 'I'
    ,x_sync_party_site_cur => l_sync_party_site_cur
  );

  log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_party_sites');
  HZ_STAGE_MAP_TRANSFORM.sync_all_party_sites ('C', 'IMPORT_SYNC', l_sync_party_site_cur);

  -- For Update
  log ('----------------------');
  log ('For Update Party Sites');
  log ('----------------------');

  log ('Calling HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_psite_cur');
  HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_psite_cur (
     p_batch_id            => p_batch_id
    ,p_batch_mode_flag     => p_batch_mode_flag
    ,p_from_osr            => p_from_osr
    ,p_to_osr              => p_to_osr
    ,p_os                  => p_os
    ,p_operation           => 'U'
    ,x_sync_party_site_cur => l_sync_party_site_cur
  );

  log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_party_sites');
  HZ_STAGE_MAP_TRANSFORM.sync_all_party_sites ('U', 'IMPORT_SYNC', l_sync_party_site_cur);

  -- Sync all contacts
  -- For Create
  log ('-------------------');
  log ('For Create Contacts');
  log ('-------------------');

  log ('Calling HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_ct_cur');
  HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_ct_cur (
     p_batch_id            => p_batch_id
    ,p_batch_mode_flag     => p_batch_mode_flag
    ,p_from_osr            => p_from_osr
    ,p_to_osr              => p_to_osr
    ,p_os                  => p_os
    ,p_operation           => 'I'
    ,x_sync_contact_cur    => l_sync_contact_cur
  );

  log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_contacts');
  HZ_STAGE_MAP_TRANSFORM.sync_all_contacts ('C', 'IMPORT_SYNC', l_sync_contact_cur);
  -- For Update
  log ('-------------------');
  log ('For Update Contacts');
  log ('-------------------');

  log ('Calling HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_ct_cur');
  HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_ct_cur (
     p_batch_id            => p_batch_id
    ,p_batch_mode_flag     => p_batch_mode_flag
    ,p_from_osr            => p_from_osr
    ,p_to_osr              => p_to_osr
    ,p_os                  => p_os
    ,p_operation           => 'U'
    ,x_sync_contact_cur    => l_sync_contact_cur
  );

  log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_contacts');
  HZ_STAGE_MAP_TRANSFORM.sync_all_contacts ('U', 'IMPORT_SYNC', l_sync_contact_cur);

  -- Sync all contact_points
  -- For Create

  log ('-------------------------');
  log ('For Create Contact Points');
  log ('-------------------------');

  log ('Calling HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_cpt_cur');
  HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_cpt_cur (
     p_batch_id            => p_batch_id
    ,p_batch_mode_flag     => p_batch_mode_flag
    ,p_from_osr            => p_from_osr
    ,p_to_osr              => p_to_osr
    ,p_os                  => p_os
    ,p_operation           => 'I'
    ,x_sync_cpt_cur        => l_sync_cpt_cur
  );

  log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_contact_points');
  HZ_STAGE_MAP_TRANSFORM.sync_all_contact_points ('C', 'IMPORT_SYNC', l_sync_cpt_cur);

  -- For Update

  log ('-------------------------');
  log ('For Update Contact Points');
  log ('-------------------------');

  log ('Calling HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_cpt_cur');
  HZ_STAGE_MAP_TRANSFORM.open_bulk_imp_sync_cpt_cur (
     p_batch_id            => p_batch_id
    ,p_batch_mode_flag     => p_batch_mode_flag
    ,p_from_osr            => p_from_osr
    ,p_to_osr              => p_to_osr
    ,p_os                  => p_os
    ,p_operation           => 'U'
    ,x_sync_cpt_cur        => l_sync_cpt_cur
  );

  log ('Calling HZ_STAGE_MAP_TRANSFORM.sync_all_contact_points');
  HZ_STAGE_MAP_TRANSFORM.sync_all_contact_points ('U', 'IMPORT_SYNC', l_sync_cpt_cur);

END ;

-- This would take a request_id , see if the corresponding conc program is complete
-- and return TRUE or FALSE
FUNCTION is_conc_complete ( p_request_id IN NUMBER) RETURN BOOLEAN
IS
req_id NUMBER ;
rphase varchar2(30);
rstatus varchar2(30);
dphase varchar2(30);
dstatus varchar2(30);
message varchar2(240);
status boolean ;

BEGIN
-- set request id we want to query
req_id := p_request_id ;

-- call FND procedure to find status of concurrent program
status := FND_CONCURRENT.GET_REQUEST_STATUS(req_id, NULL, NULL, rphase,rstatus,dphase,dstatus,message);

-- Return true any time request is complete
-- IF dphase = 'RUNNING'  OR  dphase = 'PENDING'
 IF dphase = 'COMPLETE'
 THEN
    RETURN TRUE ;
 ELSE
    RETURN FALSE ;
 END IF ;

END ;

-- This will return true if the passed in index has any rows to be synced
-- else will return false
FUNCTION is_index_pending( p_index_name IN VARCHAR2,p_owner_name IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
       --bug 5929615
    FOR cur in
    ( SELECT 'Y' FROM
 (
 select
 u.name      pnd_index_owner,
 idx_name    pnd_index_name,
 ixp_name    pnd_partition_name,
 pnd_rowid,
 pnd_timestamp
 from ctxsys.dr$pending, ctxsys.dr$index i, ctxsys.dr$index_partition p,
 sys.user$ u
 where idx_owner# = u.user#
 and idx_id = ixp_idx_id
 and pnd_pid = ixp_id
 and pnd_pid <> 0
 and pnd_cid = idx_id
 UNION ALL
 select
 u.name      pnd_index_owner,
 idx_name    pnd_index_name,
 null        pnd_partition_name,
 pnd_rowid,
 pnd_timestamp
 from ctxsys.dr$pending, ctxsys.dr$index i, sys.user$ u
 where idx_owner# = u.user#
 and pnd_pid = 0
 and pnd_cid = idx_id
 )
 WHERE PND_INDEX_NAME = p_index_name
 and pnd_index_owner=p_owner_name
 and rownum =1

    )
    LOOP
        RETURN TRUE ;
    END LOOP ;

   RETURN FALSE ;
END ;

-- VJN Introduced for setting transactional property of Index, a new feature
-- for text indexes, available as part of 10g.
PROCEDURE set_index_transactional( enabled IN VARCHAR2 )
IS
l_bool boolean ;

l_status VARCHAR2(255);
l_temp VARCHAR2(255);
l_index_owner VARCHAR2(255);
index_cnt NUMBER;
BEGIN
     -- GET THE INDEX OWNER INSTEAD OF HARDCODING IT
     -- THIS FND FUNCTION, WILL TAKE THE APPLICATION SHORT NAME AND RETURN THE ORACLE_SCHEMA FOR THE USER
     -- AND THIS IS ESSENTIALLY THE INDEX OWNER

     l_bool := fnd_installation.GET_APP_INFO('AR',l_status,l_temp,l_index_owner);

     -- Propagating the changes done for Bug:4706376
     SELECT COUNT(*) INTO index_cnt FROM HZ_DQM_STAGE_LOG WHERE OPERATION='ALTER_INDEX';

     IF enabled = 'Y'
     THEN
            EXECUTE IMMEDIATE 'ALTER INDEX ' || l_index_owner ||
                              '.hz_stage_parties_t1 rebuild parameters(''replace metadata transactional'')';
            EXECUTE IMMEDIATE 'ALTER INDEX ' || l_index_owner ||
                              '.hz_stage_party_sites_t1 rebuild parameters(''replace metadata transactional'')';
            EXECUTE IMMEDIATE 'ALTER INDEX ' || l_index_owner ||
                              '.hz_stage_contact_t1 rebuild parameters(''replace metadata transactional'')';
            EXECUTE IMMEDIATE 'ALTER INDEX ' || l_index_owner ||
                              '.hz_stage_cpt_t1 rebuild parameters(''replace metadata transactional'')';

        -- Propagating the changes done for Bug:4706376
        if(index_cnt=null OR index_cnt=0) then
            insert into hz_dqm_stage_log(OPERATION, NUMBER_OF_WORKERS,WORKER_NUMBER,STEP,START_FLAG,START_TIME,END_FLAG,
                        END_TIME,LAST_UPDATE_DATE, CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_LOGIN )
                        values ('ALTER_INDEX',1,1,'STAGED_TABLES','Y',sysdate,'Y',null,sysdate,sysdate,
            fnd_global.user_id,fnd_global.user_id,fnd_global.login_id);
        else
            update hz_dqm_stage_log set start_flag='Y',end_flag='Y',start_time=sysdate,
            last_update_date=sysdate,last_update_login=fnd_global.login_id
            where operation='ALTER_INDEX';
        end if;

     ELSE
            EXECUTE IMMEDIATE 'ALTER INDEX ' || l_index_owner ||
                              '.hz_stage_parties_t1 rebuild parameters(''replace metadata nontransactional'')';
            EXECUTE IMMEDIATE 'ALTER INDEX ' || l_index_owner ||
                              '.hz_stage_party_sites_t1 rebuild parameters(''replace metadata nontransactional'')';
            EXECUTE IMMEDIATE 'ALTER INDEX ' || l_index_owner ||
                              '.hz_stage_contact_t1 rebuild parameters(''replace metadata nontransactional'')';
            EXECUTE IMMEDIATE 'ALTER INDEX ' || l_index_owner ||
                              '.hz_stage_cpt_t1 rebuild parameters(''replace metadata nontransactional'')';

        -- Propagating the changes done for Bug:4706376
        if(index_cnt=null OR index_cnt=0) then
            insert into hz_dqm_stage_log(OPERATION, NUMBER_OF_WORKERS,WORKER_NUMBER,STEP,START_FLAG,START_TIME,END_FLAG,
                        END_TIME,LAST_UPDATE_DATE, CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
                        values ('ALTER_INDEX',1,1,'STAGED_TABLES','N',sysdate,'N',null,sysdate,sysdate,
            fnd_global.user_id,fnd_global.user_id,fnd_global.login_id);
        else
            update hz_dqm_stage_log set start_flag='N',end_flag='N',start_time=sysdate,
            last_update_date=sysdate,last_update_login=fnd_global.login_id
            where operation='ALTER_INDEX';
        end if;

     END IF ;
     EXCEPTION WHEN OTHERS THEN
           NULL ;

END ;

-- conc program executable for Serial Sync Index Concurrent Program
-- This will be used only by online (API) flows
PROCEDURE sync_index_serial(
        retcode                 OUT    NOCOPY VARCHAR2,
        err                     OUT    NOCOPY VARCHAR2
        )
IS
idx_name VARCHAR2(300);
l_index_owner VARCHAR2(255);
l_status VARCHAR2(255);
l_tmp		VARCHAR2(2000);
BEGIN
     retcode := 0;
     err := null;

     -- Sequentially Sync all indexes one by one
     -- set OUT variables and write any messages to logs appropriately
     -- Fix for bug 5048604. Moved the call to Parties Sync Index to be the last, instead of being first.
     IF ( fnd_installation.GET_APP_INFO('AR', l_status, l_tmp, l_index_owner ))
     THEN
             log ( 'index_owner is ' || l_index_owner );
             BEGIN
                idx_name := l_index_owner || '.hz_stage_party_sites_t1';
                ad_ctx_Ddl.Sync_Index (idx_name);
                log ('Successful in syncing hz_stage_party_sites_t1 ');
             EXCEPTION
             WHEN OTHERS THEN
                retcode :=  2;
                err := SQLERRM;
                log ('Error syncing hz_stage_party_sites_t1 :' ||  SQLERRM);
             END ;

             BEGIN
                idx_name := l_index_owner || '.hz_stage_contact_t1';
                ad_ctx_Ddl.Sync_Index (idx_name);
                log ('Successful in syncing hz_stage_contact_t1 ');
             EXCEPTION
             WHEN OTHERS THEN
                retcode :=  2;
                err := SQLERRM;
                log ('Error syncing hz_stage_contact_t1 :' ||  SQLERRM);
             END ;

             BEGIN
                idx_name := l_index_owner || '.hz_stage_cpt_t1';
                ad_ctx_Ddl.Sync_Index (idx_name);
                log ('Successful in syncing hz_stage_cpt_t1 ');
             EXCEPTION
             WHEN OTHERS THEN
                retcode :=  2;
                err := SQLERRM;
                log ('Error syncing hz_stage_cpt_t1 :' ||  SQLERRM);
             END ;

             BEGIN
                idx_name := l_index_owner || '.hz_stage_parties_t1';
                ad_ctx_Ddl.Sync_Index (idx_name);
                log ('Successful in syncing hz_stage_parties_t1 ');
             EXCEPTION
             WHEN OTHERS THEN
                retcode :=  2;
                err := SQLERRM;
                log ('Error syncing hz_stage_parties_t1 :' ||  SQLERRM);
             END ;

     END IF ;

END ;

-- conc program executable for Parallel Sync Index Parent Concurrent Program
-- This will be used by both Manual ( Batch) Synchronization and Bulk Import

PROCEDURE sync_index_parallel_parent (
        retcode                 OUT    NOCOPY VARCHAR2,
        err                     OUT    NOCOPY VARCHAR2,
        p_request_id            IN     NUMBER
        )
IS
req_data VARCHAR2(100);
idx_name VARCHAR2(300);
l_index_owner VARCHAR2(255);
l_status VARCHAR2(255);
l_tmp		VARCHAR2(2000);
idx_retcode varchar2(1);
idx_err     varchar2(2000);
TYPE nTable IS TABLE OF NUMBER index by binary_integer;
l_sub_requests nTable;
l_workers_completed boolean ;

BEGIN
   -- req_data will be null the first time, by default
  req_data := fnd_conc_global.request_data;

  -- First Phase
  -- Submit the Parallel Sync Index Child Concurrent Progarm for each one of the indexes
  IF (req_data IS NULL)
  THEN
      retcode := 0;

      log('------------------------------');
      log('Starting DQM Parallel Sync Index Parent Program ');

      FND_MSG_PUB.initialize;


      IF ( fnd_installation.GET_APP_INFO('AR', l_status, l_tmp, l_index_owner ))
      THEN
        log ( 'index_owner is ' || l_index_owner );

        -- Submit requests for the Parallel Sync Index Child concurrent program
        -- for creating the four indexes
        FOR i in 1..4
        LOOP
          IF (i = 1) THEN
              idx_name := l_index_owner || '.hz_stage_parties_t1';
          ELSIF ( i = 2) THEN
              idx_name := l_index_owner || '.hz_stage_party_sites_t1';
          ELSIF ( i = 3) THEN
              idx_name := l_index_owner || '.hz_stage_contact_t1';
          ELSE
              idx_name :=l_index_owner || '.hz_stage_cpt_t1';
          END IF;

          log('Calling the Parallel Sync Index Child program for index ' || idx_name );
          l_sub_requests(i) := FND_REQUEST.SUBMIT_REQUEST('AR',
                                                          'ARHDQMPC',
                                                          'DQM Parallel Sync Index Child Program' || to_char(i),
                                                           NULL,
                                                           TRUE,
                                                           p_request_id,
                                                           idx_name);
           IF l_sub_requests(i) = 0 THEN
                log('Error submitting index worker for ' || idx_name);
                log(fnd_message.get);
           ELSE
                log('Submitted request for index worker ' || idx_name );
                log('Request ID : ' || l_sub_requests(i));
           END IF;
           EXIT when l_sub_requests(i) = 0;
         END LOOP;

        -- This will make sure that the parent is waits until the above requests complete
        fnd_conc_global.set_req_globals(conc_status => 'PAUSED', request_data => 'END') ;
        return;


        END IF;

  END IF ;

  -- Second Phase
  -- After all workers have completed, see if they have completed normally
  IF req_data = 'END'
  THEN


      -- assume that all concurrent dup workers completed normally, unless found otherwise
      l_workers_completed := TRUE;

      -- get request ids that did not complete
      Select request_id BULK COLLECT into l_sub_requests
      from Fnd_Concurrent_Requests R
      Where Parent_Request_Id = FND_GLOBAL.conc_request_id
      and (phase_code<>'C' or status_code<>'C');

      -- log these request_ids and set the return code of the parent concurrent program
      -- to 2 ie., ERROR
      IF  l_sub_requests.count>0 THEN
        l_workers_completed:=FALSE;
        FOR I in 1..l_sub_requests.COUNT LOOP
          log('Index worker with request id ' || l_sub_requests(I) );
          log('did not complete normally');
          retcode := 2;
        END LOOP;
      END IF;

      -- If any worker has not completed just return
      IF (l_workers_completed = false)
      THEN
        return;
      END IF ;

      -- This means success
      log('All the Child Index workers completed successfully');


  END IF ;

  EXCEPTION
  WHEN OTHERS THEN
    log('Parallel Sync Index Parent Program Aborted');
    retcode := 2;
    err := err || logerror || SQLERRM;


END ;

-- conc program executable for Parallel Sync Index Child Concurrent Program
-- This will be used by both Manual ( Batch) Synchronization and Bulk Import
PROCEDURE sync_index_parallel_child (
        retcode                 OUT    NOCOPY VARCHAR2,
        err                     OUT    NOCOPY VARCHAR2,
        p_request_id            IN     NUMBER,
        p_index_name            IN     VARCHAR2
        )
IS
idx_name varchar2(300);
owner_name VARCHAR2(30); --bug 5929615
BEGIN
  log ( ' Starting Sync Index Parallel Child concurrent Program for index ' || p_index_name );

  idx_name := substrb( upper(p_index_name),instrb( upper(p_index_name),'.' ) + 1 ) ;
   owner_name := SubStrB(Upper(p_index_name),0,instrb( upper(p_index_name),'.' )-1); --bug 5929615
  log ( ' Schema name stripped index is ' || idx_name );
   log ( ' index owner is ' || owner_name );


   retcode := 0;
   err := null;

   -- we make sure that we call the sync index atleast once, regardless of the status
   -- of the concurrent program to be waited on ( just to make sure, if the completion happens
   -- so fast that we have nothing to SYNC
   LOOP
          BEGIN
            -- SYNC THE INDEX IF THERE IS ANY IN THE PENDING QUEUE
            IF is_index_pending( idx_name,owner_name)    --bug 5929615
            THEN
                ad_ctx_Ddl.Sync_Index (p_index_name );
            END IF ;

            -- WHEN EXCEPTION HAPPENS GET THE HELL OUT OF HERE
            EXCEPTION
            WHEN OTHERS THEN
               retcode :=  2;
               err := SQLERRM;
               log ('Error syncing index ' || p_index_name || ' :' ||  SQLERRM);
               return ;
          END ;

          /********* will incorporate this in the future
          -- sleep for 2 minutes
          -- dbms_lock.sleep( 120 );

          ************/

          -- EXIT CONDITION
          -- GET THE HELL OUT OF HERE WHEN THE CONCURRENT PROGRAM WE ARE WAITING ON IS COMPLETE
          EXIT WHEN is_conc_complete(p_request_id) = TRUE ;

   END LOOP;

END ;

END HZ_DQM_SYNC;


/
