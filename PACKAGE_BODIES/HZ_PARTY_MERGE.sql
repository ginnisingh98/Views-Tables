--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_MERGE" AS
/* $Header: ARHPMERB.pls 120.66.12010000.4 2010/02/04 23:14:02 awu ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'HZ_PARTY_MERGE';
G_TCA_APP_ID CONSTANT VARCHAR2(30) := '222';
G_REQUEST_TYPE VARCHAR2(30);

/*******************Private Procedures forward declarations ********/
PROCEDURE do_merge(
        p_batch_party_id        IN      NUMBER,
        p_entity_name           IN      VARCHAR2,
        p_par_entity_name       IN      VARCHAR2,
        p_from_id               IN      NUMBER,
        p_to_id                 IN OUT NOCOPY  NUMBER,
        p_par_from_id           IN      NUMBER,
        p_par_to_id             IN      NUMBER,
        p_rule_set_name         IN      VARCHAR2,
        p_batch_id              IN      NUMBER,
        p_batch_commit		IN      VARCHAR2,
        p_preview		IN      VARCHAR2,
        p_dict_id               IN      NUMBER,
        p_log_padding           IN      VARCHAR2,
        x_error_msg		IN OUT NOCOPY	VARCHAR2,
        x_return_status         IN OUT NOCOPY  VARCHAR2);

PROCEDURE  exec_merge_r(
        p_entity_name   IN      VARCHAR2,
        p_proc_name     IN      HZ_MERGE_DICTIONARY.PROCEDURE_NAME%TYPE,
        p_from_id       IN      ROWID,
        x_to_id         IN OUT NOCOPY  ROWID,
        p_par_from_id   IN      NUMBER,
        p_par_to_id     IN      NUMBER,
        p_parent_entity IN      HZ_MERGE_DICTIONARY.ENTITY_NAME%TYPE,
        p_batch_id      IN      NUMBER,
        p_batch_party_id IN     NUMBER,
        x_return_status IN OUT NOCOPY  VARCHAR2);


PROCEDURE  exec_merge(
        p_entity_name   IN      VARCHAR2,
        p_proc_name     IN      HZ_MERGE_DICTIONARY.PROCEDURE_NAME%TYPE,
        p_from_id       IN      NUMBER,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_par_from_id   IN      NUMBER,
        p_par_to_id     IN      NUMBER,
        p_parent_entity IN      HZ_MERGE_DICTIONARY.ENTITY_NAME%TYPE,
        p_batch_id      IN      NUMBER,
        p_batch_party_id IN     NUMBER,
        x_return_status IN OUT NOCOPY  VARCHAR2);

PROCEDURE lock_batch(
        p_batch_id              IN      VARCHAR2,
        x_return_status         IN OUT NOCOPY  VARCHAR2);

PROCEDURE lock_records(
        p_entity_name		IN	VARCHAR2,
        p_pk_column_name	IN	VARCHAR2,
        p_fk_column_name	IN	VARCHAR2,
        p_join_str		IN	VARCHAR2,
        p_join_clause		IN	VARCHAR2,
        p_rule_set_name         IN      VARCHAR2,
	x_return_status		IN OUT NOCOPY	VARCHAR2);

PROCEDURE delete_merged_records(
        p_batch_party_id IN     NUMBER,
        x_return_status         IN OUT NOCOPY  VARCHAR2);


FUNCTION get_record_desc(
        p_record_pk     IN      NUMBER,
        p_entity_name   IN      VARCHAR2,
        p_pk_col_name   IN      VARCHAR2,
        p_desc_col_name IN      VARCHAR2,
        x_return_status         IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_record_desc_r(
        p_record_pk     IN      ROWID,
        p_entity_name   IN      VARCHAR2,
        p_desc_col_name IN      VARCHAR2,
        x_return_status         IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2;

PROCEDURE setup_dnb_data(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY NUMBER,
        p_batch_party_id IN     NUMBER
);

PROCEDURE insert_party_site_details (
        p_from_party_id      IN NUMBER,
        p_to_party_id        IN NUMBER,
        p_batch_party_id     IN NUMBER
);

PROCEDURE do_same_party_merge (
        p_batch_party_id        IN      NUMBER,
        p_entity_name           IN      VARCHAR2,
        p_from_id               IN      NUMBER,
        p_to_id                 IN OUT NOCOPY  NUMBER,
        p_rule_set_name         IN      VARCHAR2,
        p_batch_id              IN      NUMBER,
        p_batch_commit          IN      VARCHAR2,
        p_preview               IN      VARCHAR2,
        p_log_padding           IN      VARCHAR2,
        x_error_msg             IN OUT NOCOPY  VARCHAR2,
        x_return_status         IN OUT NOCOPY  VARCHAR2);


PROCEDURE out(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);


PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

PROCEDURE pre_merge(
   p_to_party_id IN NUMBER,
   p_batch_id    IN NUMBER);

FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

/*FUNCTION get_col_type(
        p_table         VARCHAR2,
        p_column        VARCHAR2,
        p_app_name      VARCHAR2)
  RETURN VARCHAR2;*/

FUNCTION alternate_get_col_type(
    p_table		VARCHAR2,
	p_column	VARCHAR2)
  RETURN VARCHAR2;

--bug 4634891
PROCEDURE  exec_merge(
        p_entity_name   IN      VARCHAR2,
        p_proc_name     IN      VARCHAR2,
        p_batch_id      IN      NUMBER,
        p_request_id    IN      NUMBER,
        x_return_status IN OUT NOCOPY  VARCHAR2);

PROCEDURE check_int_ext_party_type(
    p_dup_set_id  IN NUMBER,
    p_int_party   OUT  NOCOPY VARCHAR2,
    p_ext_party   OUT  NOCOPY VARCHAR2,
	p_merge_ok    OUT  NOCOPY VARCHAR2);

-------------Global Variables and lists--------------------
g_request_id                  HZ_MERGE_PARTY_HISTORY.request_id%TYPE;
g_user_id                     HZ_MERGE_PARTY_HISTORY.last_updated_by%TYPE;
g_created_by                  HZ_MERGE_PARTY_HISTORY.created_by%TYPE;
g_last_update_login           HZ_MERGE_PARTY_HISTORY.last_update_login%TYPE;
g_creation_date               DATE;
g_last_update_date            DATE;

g_merge_delete_flag VARCHAR2(1);
g_cur_merge_dict_id NUMBER := 0;
g_num_sub_entities NUMBER :=-1;
g_cur_proc_name VARCHAR2(255);
G_PROC_CURSOR INTEGER;

TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE CharList IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
TYPE ErrorList IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

H_batch_party_id NumberList;
H_from_id NumberList;
H_to_id NumberList;
H_from_fk_id NumberList;
H_to_fk_id NumberList;

/****  Bug 2541514
H_from_desc CharList;
H_to_desc CharList;
****/
H_from_desc ErrorList;
H_to_desc ErrorList;

H_merge_dict_id NumberList;
H_op_type CharList;

I_batch_party_id NumberList;
I_from_id NumberList;
I_to_id NumberList;
I_from_fk_id NumberList;
I_to_fk_id NumberList;

/**** Bug 2541514
I_from_desc CharList;
I_to_desc CharList;
****/
I_from_desc ErrorList;
I_to_desc ErrorList;

I_merge_dict_id NumberList;
I_op_type CharList;
I_Error ErrorList;

H_Counter NUMBER := 0;
I_Counter NUMBER := 0;

g_crm_app_list NumberList;
g_skip_dict_id NumberList;

g_inv_merge_dict VARCHAR2(4000);
g_inv_merge_dict_cnt NUMBER;

--------------------Public procedures body---------------------------

PROCEDURE init_globals IS
--4534175
l_count number;
TYPE ref_cur IS REF CURSOR;
c1 ref_cur;
--4534175
l_count1 number;
BEGIN

  g_request_id       :=hz_utility_pub.request_id;
  g_created_by       :=hz_utility_pub.created_by;
  g_creation_date    :=hz_utility_pub.creation_date;
  g_last_update_login:=hz_utility_pub.last_update_login;
  g_last_update_date :=hz_utility_pub.last_update_date;
  g_user_id          :=hz_utility_pub.user_id;

  FND_FILE.put_line(FND_FILE.log,'Request ID:'||g_request_id||'#');
  FND_FILE.put_line(FND_FILE.log,'User ID:'||g_user_id||'#');
  FND_FILE.put_line(FND_FILE.log,'Creation Date:'||TO_CHAR(g_creation_date)||'#');
  FND_FILE.put_line(FND_FILE.log,'Last Update Date:'||TO_CHAR(g_last_update_date)||'#');
  FND_FILE.put_line(FND_FILE.log,'Last Update Login:'||g_last_update_login||'#');
  FND_FILE.put_line(FND_FILE.log,'Created By:'||g_created_by||'#');
  FND_FILE.put_line(FND_FILE.log,'Request ID:'||g_request_id||'#');
  g_skip_dict_id.DELETE;
  FOR ENTITY IN (
    SELECT DISTINCT MERGE_DICT_ID, ENTITY_NAME
    FROM HZ_MERGE_DICTIONARY WHERE DICT_APPLICATION_ID<>222
				   AND   NVL(batch_merge_flag, 'N') <> 'Y') LOOP

    BEGIN
--4534175      EXECUTE IMMEDIATE 'DECLARE x NUMBER; BEGIN SELECT 1 INTO x FROM dual where exists ( select 1 from '||ENTITY.ENTITY_NAME||'); END;';
    l_count := 0;

    IF ENTITY.ENTITY_NAME = 'JTF_FM_CONTENT_HISTORY_V' THEN

 	    l_count1 := 0;
	    OPEN c1 FOR  'SELECT 1 FROM jtf_fm_content_history WHERE rownum = 1';
	    FETCH c1 into l_count;
	    CLOSE c1;

            OPEN c1 FOR  'SELECT 1 FROM jtf_fm_processed WHERE rownum = 1';
            FETCH c1 into l_count1;
            CLOSE c1;

            IF l_count = 0 OR l_count1 = 0 THEN
	       g_skip_dict_id(ENTITY.MERGE_DICT_ID):=1;
	    END IF;

    --Modified for bug 8370389
    ELSIF ENTITY.ENTITY_NAME = 'WSH_SUPPLIER_SF_SITES_V' THEN
        l_count := 0;
        OPEN c1 FOR  'select 1
                        from dual
                       where exists(
                                    SELECT    /*+ first_rows(1) index_ffs(hp HZ_PARTY_SITE_USES_N1)*/ 1
                                      FROM    hz_party_site_uses hp
                                     WHERE    site_use_type = ''SUPPLIER_SHIP_FROM''
                                       AND    ROWNUM=1)  ';
         FETCH c1 into l_count;
         CLOSE c1;

         IF l_count = 0 THEN
             g_skip_dict_id(ENTITY.MERGE_DICT_ID):=1;
         END IF;
    --End of  modifications for bug 8370389

    ELSE

	   OPEN c1 FOR  'SELECT 1 FROM '||ENTITY.ENTITY_NAME||' WHERE rownum = 1';
            FETCH c1 into l_count;
            CLOSE c1;
            IF l_count = 0 THEN
               g_skip_dict_id(ENTITY.MERGE_DICT_ID):=1;
            END IF;
   END IF; --ENTITY_NAME
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        g_skip_dict_id(ENTITY.MERGE_DICT_ID):=1;
      WHEN OTHERS THEN  /*bug 3754365*/
        NULL;
    END;
  END LOOP;
END;


PROCEDURE batch_merge(
        errbuf                  OUT NOCOPY     VARCHAR2,
        retcode                 OUT NOCOPY     VARCHAR2,
	p_batch_id		IN	VARCHAR2,
	p_preview		IN	VARCHAR2
) IS

  CURSOR c_batch(cp_batch_id NUMBER) IS
    SELECT batch_name, rule_set_name, batch_status, batch_delete, batch_commit
    FROM HZ_MERGE_BATCH
    WHERE batch_id = cp_batch_id;

  -----Cursor for grouping parties based on distinct merge_to party-----
  CURSOR c_pre_merge(cp_batch_id NUMBER) IS
    SELECT DISTINCT(to_party_id)
    FROM HZ_MERGE_PARTIES mp, hz_parties p
    WHERE batch_id = cp_batch_id
    AND p.party_id = mp.from_party_id
    AND p.party_type <> 'PARTY_RELATIONSHIP';

   CURSOR c_pre_merge_type(cp_batch_id NUMBER, cp_to_party_id NUMBER) IS
    SELECT mp.merge_type
    FROM HZ_MERGE_PARTIES mp, hz_parties p
    WHERE mp.batch_id = cp_batch_id
    AND mp.to_party_id = cp_to_party_id
    AND p.party_id = mp.to_party_id
    AND p.party_type <> 'PARTY_RELATIONSHIP'
    AND mp.merge_type = 'PARTY_MERGE'
    AND rownum=1;

  -----Cursor to get merge from-merge to pair parties and the type-----
  CURSOR c_batch_details(cp_batch_id NUMBER,cp_to_party_id IN NUMBER) IS
SELECT batch_party_id, merge_type, from_party_id, to_party_id, merge_status,party_type, decode(op.actual_content_source, 'DNB', 'DNB', NULL)
    FROM HZ_MERGE_PARTIES mp, HZ_PARTIES pt, hz_organization_profiles op
    WHERE batch_id = cp_batch_id
    AND pt.party_id = mp.from_party_id
    AND op.party_id(+) = pt.party_id
    AND op.actual_content_source(+) = 'DNB'
    AND ( mp.to_party_id = cp_to_party_id
          OR (pt.party_type = 'PARTY_RELATIONSHIP'
              AND exists (
                 select 1 FROM HZ_RELATIONSHIPS r
                 WHERE (r.party_id = mp.to_party_id or r.party_id = mp.from_party_id)
                 AND r.OBJECT_ID = cp_to_party_id)) )
    ORDER BY decode(pt.party_type, 'PARTY_RELATIONSHIP',1,
                    decode(mp.merge_type, 'PARTY_MERGE',2,
                                          'SAME_PARTY_MERGE',3,4)), op.effective_end_date desc, 7, op.last_update_date desc;  --5000614


  -----Cursor for the merge of party sites within the same party-----
  CURSOR c_batch_party_sites(cp_batch_party_id NUMBER) IS
    SELECT merge_from_entity_id, merge_to_entity_id
    FROM HZ_MERGE_PARTY_DETAILS
    WHERE batch_party_id = cp_batch_party_id
    AND   ENTITY_NAME = 'HZ_PARTY_SITES'
    AND merge_from_entity_id <> merge_to_entity_id;

  -----Cursor for the merge of Contact Points within the same party-----
  CURSOR c_batch_contact_points(cp_batch_party_id NUMBER) IS
    SELECT merge_from_entity_id, merge_to_entity_id
    FROM HZ_MERGE_PARTY_DETAILS
    WHERE batch_party_id = cp_batch_party_id
    AND   ENTITY_NAME = 'HZ_CONTACT_POINTS'
    AND merge_from_entity_id <> merge_to_entity_id;

  -----Cursor for the merge of Relationships/Contacts within the same party-----
  CURSOR c_batch_relationships(cp_batch_party_id NUMBER) IS
    SELECT merge_from_entity_id, merge_to_entity_id
    FROM HZ_MERGE_PARTY_DETAILS
    WHERE batch_party_id = cp_batch_party_id
    AND  ENTITY_NAME = 'HZ_PARTY_RELATIONSHIPS'
    AND merge_from_entity_id <> merge_to_entity_id;


  CURSOR c_dict_id(cp_ruleset_name VARCHAR2, cp_entity_name VARCHAR2) IS
    SELECT merge_dict_id
    FROM HZ_MERGE_DICTIONARY
    WHERE RULE_SET_NAME = cp_ruleset_name
    AND ENTITY_NAME = cp_entity_name;

  cursor c_request_type(cp_batch_id NUMBER) is
	select dbat.request_type
	from
		HZ_DUP_BATCH dbat,
		HZ_DUP_SETS dset,
		HZ_MERGE_BATCH mb
	where
		dbat.dup_batch_id = dset.dup_batch_id
		and mb.batch_id  = dset.dup_set_id
		and mb.batch_id = cp_batch_id;

  cursor c_dict_no_fktype is
	 select entity_name, fk_column_name, merge_dict_id, dict_application_id
	 from hz_merge_dictionary
	 where fk_data_type is null;

  cursor app_name(app_id NUMBER) IS
Select application_short_name from fnd_application where application_id=app_id;

  cursor get_batch_party_id_csr is
  	select batch_party_id
  	from hz_merge_parties
  	where batch_id = p_batch_id
  	and rownum=1;

--start bug 4634891

  CURSOR batch_merge_procedures IS
        select merge_dict_id, entity_name, procedure_name
        from hz_merge_dictionary
        where merge_dict_id in (
        select min(merge_dict_id)
        from HZ_MERGE_DICTIONARY where batch_merge_flag = 'Y'
        group by procedure_name);

 CURSOR merge_to_parties IS
	select DISTINCT(to_party_id)
        from HZ_MERGE_PARTIES mp
        where batch_id = p_batch_id
	and   merge_status = 'DONE';


  l_proc_name           HZ_MERGE_DICTIONARY.PROCEDURE_NAME%TYPE;
--end bug 4634891

  l_batch_name 		HZ_MERGE_BATCH.BATCH_NAME%TYPE;
  l_rule_set_name       HZ_MERGE_BATCH.RULE_SET_NAME%TYPE;
  l_batch_status        HZ_MERGE_BATCH.BATCH_STATUS%TYPE;
  l_merge_status        HZ_MERGE_PARTIES.MERGE_STATUS%TYPE;

  l_batch_commit        HZ_MERGE_BATCH.BATCH_COMMIT%TYPE;
  l_batch_delete        HZ_MERGE_BATCH.BATCH_DELETE%TYPE;

  l_pre_merge_to_party_id HZ_MERGE_PARTIES.TO_PARTY_ID%TYPE;
  l_pre_merge_type        HZ_MERGE_PARTIES.MERGE_TYPE%TYPE;

  l_batch_party_id 	HZ_MERGE_PARTIES.BATCH_PARTY_ID%TYPE;
  l_merge_type  	HZ_MERGE_PARTIES.MERGE_TYPE%TYPE;

  l_from_party_id  	HZ_MERGE_PARTIES.FROM_PARTY_ID%TYPE;
  l_to_party_id  	HZ_MERGE_PARTIES.TO_PARTY_ID%TYPE;

  l_from_site_id  	HZ_MERGE_PARTIES.FROM_PARTY_ID%TYPE;
  l_to_site_id  	HZ_MERGE_PARTIES.TO_PARTY_ID%TYPE;

  l_from_cp_id          HZ_CONTACT_POINTS.CONTACT_POINT_ID%TYPE;
  l_to_cp_id            HZ_CONTACT_POINTS.CONTACT_POINT_ID%TYPE;

  l_from_rel_id         HZ_RELATIONSHIPS.RELATIONSHIP_ID%TYPE;
  l_to_rel_id           HZ_RELATIONSHIPS.RELATIONSHIP_ID%TYPE;

  l_sub_entity_name 	HZ_MERGE_DICTIONARY.ENTITY_NAME%TYPE;
  l_sub_fk_column_name 	HZ_MERGE_DICTIONARY.FK_COLUMN_NAME%TYPE;


  l_num_merged		NUMBER;

  l_glob_return_status	VARCHAR2(200);
  l_return_status	VARCHAR2(200);

  l_dict_id		NUMBER;
  l_merge_dict_id		NUMBER;
  l_batch_id 		NUMBER;
  l_error_msg 	        VARCHAR2(2000);

  l_dict_app_id 	NUMBER;
  l_app_id		NUMBER;
  error 		VARCHAR2(2000);

  l_mb_spt		BOOLEAN := FALSE;
  l_mr_spt		BOOLEAN := FALSE;

  --Bug No: 3267877--
  l_batch_merge_spt     BOOLEAN := FALSE;
  --End of Bug No: 3267877--

  l_from_rel_party_id	NUMBER;
  l_to_rel_party_id	NUMBER;
  l_tmp 		NUMBER;
  l_party_type 		VARCHAR2(255);

  l_ret_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_source_if_dnb VARCHAR2(2000);

  l_data_type          VARCHAR2(255);
  l_app_name           VARCHAR2(100);
  l_dss_orig_prof_val     varchar2(30);
  l_dss_update_flag    varchar2(1);
  l_batch_pid 	HZ_MERGE_PARTIES.BATCH_PARTY_ID%TYPE;
--4230396
  l_key                VARCHAR2(240);
  l_list               WF_PARAMETER_LIST_T;
 --4230396
 l_int_party     VARCHAR2(4000);
 l_ext_party     VARCHAR2(4000);
 l_ret_merge_ok  VARCHAR2(1);

BEGIN
  g_inv_merge_dict := null;
  g_inv_merge_dict_cnt := 0;

  I_Counter := 0;
  H_Counter := 0;

  retcode := 0;


  outandlog('Starting Concurrent Program ''Batch Party Merge''');
  outandlog('Start Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
  outandlog('NEWLINE');

  outandlog('*********** Processing Merge Batch. ID: '||p_batch_id);

  ---Bug 2440553 Savepoint for the start of batch_merge
  --SAVEPOINT batch_merge; commented out and moved to after commit for bug 3267877.

  FND_MSG_PUB.initialize;
  init_globals;

  --Initialize API return status to success.
  l_glob_return_status := FND_API.G_RET_STS_SUCCESS;
  l_return_status := FND_API.G_RET_STS_SUCCESS;


  open get_batch_party_id_csr;
  fetch get_batch_party_id_csr into l_batch_pid;
  close get_batch_party_id_csr;
  --log('l batch party id'|| l_batch_pid);

  -- If batch not found error out
  IF (p_batch_id IS NOT NULL) THEN
    l_batch_id := TO_NUMBER(p_batch_id);
  ELSE
    FND_MESSAGE.SET_NAME('AR', 'HZ_BATCH_NOTFOUND');
    FND_MESSAGE.SET_TOKEN('BATCHID', p_batch_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Open the batch cursor and fetch batch details
  OPEN c_batch(l_batch_id);
  FETCH c_batch INTO l_batch_name, l_rule_set_name, l_batch_status,
                     l_batch_delete, l_batch_commit;
  IF (c_batch%NOTFOUND) THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_BATCH_NOTFOUND');
    FND_MESSAGE.SET_TOKEN('BATCHID', p_batch_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- If batch already complete error out
  IF (l_batch_status = 'COMPLETE') THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_BATCH_COMPLETE');
    FND_MESSAGE.SET_TOKEN('BATCHID', p_batch_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_batch;

  -- bug 4865280 :check for internal external party types. Veto merge if both party types are present in batch
  check_int_ext_party_type(
    p_dup_set_id => l_batch_id,
    p_int_party  => l_int_party,
    p_ext_party  => l_ext_party,
	p_merge_ok   => l_ret_merge_ok);

  IF (l_ret_merge_ok = 'N') THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_INTERNAL_PARTY_IND');
    FND_MESSAGE.SET_TOKEN('PARTY_INT', l_int_party);
    FND_MESSAGE.SET_TOKEN('PARTY_EXT', l_ext_party);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  HZ_MERGE_DUP_PVT.validate_overlapping_merge_req(
  p_dup_set_id     => null,
  p_merge_batch_id => l_batch_id,
  p_init_msg_list  => FND_API.G_FALSE,
  p_reject_req_flag => 'Y',
  x_return_status  => l_ret_status,
  x_msg_count      => l_msg_count,
  x_msg_data       => l_msg_data);

  /* error messages have been pushed into message stack in above procedure */
   IF l_ret_status = 'E' THEN
     RAISE  FND_API.G_EXC_ERROR;
   ELSIF l_ret_status = 'U' THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- check party merge DSS - update party privilege.
   hz_dup_pvt.party_merge_dss_check(p_merge_batch_id => l_batch_id,
			    x_dss_update_flag => l_dss_update_flag,
			    x_return_status   => l_ret_status,
  			    x_msg_count       => l_msg_count,
  			    x_msg_data        => l_msg_data);

    /* error messages have been pushed into message stack in above procedure */
   IF l_ret_status = 'E' THEN
     RAISE  FND_API.G_EXC_ERROR;
   ELSIF l_ret_status = 'U' THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Disable DSS in party merge for sub entities. Will enabled it at the end of the merge.
   l_dss_orig_prof_val := NVL(fnd_profile.value('HZ_DSS_ENABLED'), 'N');
   if l_dss_orig_prof_val = 'Y'
   then
	fnd_profile.put('HZ_DSS_ENABLED','N');
   end if;

  open c_dict_no_fktype;
  loop
	fetch c_dict_no_fktype into l_sub_entity_name, l_sub_fk_column_name,
                              l_merge_dict_id, l_app_id;
	EXIT WHEN c_dict_no_fktype%NOTFOUND;

        open app_name(l_app_id);
         fetch app_name into l_app_name;
        close app_name;

        l_data_type:=get_col_type(l_sub_entity_name,l_sub_fk_column_name,l_app_name);

        update hz_merge_dictionary
        set fk_data_type = l_data_type
        where merge_dict_id = l_merge_dict_id;

   end loop;
   close c_dict_no_fktype;

  open c_request_type(l_batch_id);
  fetch c_request_type into G_REQUEST_TYPE;
  close c_request_type;

-- Log messages to out and log files
  outandlog('Batch Name: '||l_batch_name);
  outandlog('Request Type: ' || G_REQUEST_TYPE);
  outandlog('Ruleset: '||l_rule_set_name);
  outandlog('NEWLINE');

  hz_common_pub.disable_cont_source_security;


-- Stamp concurrent request id to batch
  UPDATE HZ_MERGE_BATCH
  SET REQUEST_ID = hz_utility_pub.request_id
  WHERE batch_id = p_batch_id;

  -- If not preview mode update batch status to COMPLETE
  IF p_preview <> 'Y' then
    -- Update the merge batch status to COMPLETE
    UPDATE HZ_MERGE_BATCH
    SET BATCH_STATUS = 'SUBMITTED'
    WHERE BATCH_ID = p_batch_id;

    BEGIN
      UPDATE HZ_DUP_SETS
      SET STATUS = 'SUBMITTED'
      WHERE dup_set_id = p_batch_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      NULL;
    END;

  END IF;

  COMMIT;
 --Bug No: 3267877
 SAVEPOINT batch_merge;
 l_batch_merge_spt:=TRUE;

-- Lock HZ_MERGE_BATCH, HZ_MERGE_PARTIES and HZ_MERGE_PARTY_DETAILS records
  log ('.... Locking batch for execution');
  lock_batch(p_batch_id, l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    ROLLBACK to batch_merge;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  -----Pre-Merge for all the distict merge_to parties where the parties are
  -----not present on the to side and something else is also getting merged
  -----to it.

  OPEN c_pre_merge(l_batch_id);
  LOOP
    FETCH c_pre_merge INTO l_pre_merge_to_party_id;
    EXIT WHEN c_pre_merge%NOTFOUND;

    open c_pre_merge_type(l_batch_id, l_pre_merge_to_party_id);
    fetch c_pre_merge_type into l_pre_merge_type;
    close c_pre_merge_type;

    if l_pre_merge_type is null
    then
	l_pre_merge_type := 'SAME_PARTY_MERGE';
    end if;

    -- Save point for the start of the batch
    SAVEPOINT merge_group;
    l_mb_spt := TRUE;

    -----Call Pre-Merge for across parties type merge
    if l_pre_merge_type <> 'SAME_PARTY_MERGE' then
       pre_merge(p_to_party_id => l_pre_merge_to_party_id,
                 p_batch_id    => l_batch_id);
    end if;
    ------Loop through org in batch and setup DNB data for merge.
    OPEN c_batch_details(l_batch_id, l_pre_merge_to_party_id);
    LOOP
      -- Fetch the merge party details
      FETCH c_batch_details INTO l_batch_party_id, l_merge_type, l_from_party_id,
            l_to_party_id, l_merge_status,l_party_type,l_source_if_dnb;
      EXIT WHEN c_batch_details%NOTFOUND;

      IF l_party_type = 'ORGANIZATION' AND l_merge_type = 'PARTY_MERGE' THEN  -- Bug 3313609
            setup_dnb_data(
               l_from_party_id,l_to_party_id,l_batch_party_id);
      END IF;
    END LOOP;
    CLOSE c_batch_details;

    ----- Loop through each pre merge party and perform the merge
    OPEN c_batch_details(l_batch_id, l_pre_merge_to_party_id);
    LOOP
      FND_MSG_PUB.initialize;

      --  Initialize return status and error buffer
      l_return_status := FND_API.G_RET_STS_SUCCESS;
      l_error_msg := '';

      -- Fetch the merge party details
      FETCH c_batch_details INTO l_batch_party_id, l_merge_type, l_from_party_id,
            l_to_party_id, l_merge_status,l_party_type,l_source_if_dnb;
      EXIT WHEN c_batch_details%NOTFOUND;

      -- If this party has not already been merge proceed with merge
      IF l_merge_status <> 'DONE' THEN
         g_merge_delete_flag := l_batch_delete;

         -- Check type of merge
         IF l_merge_type = 'PARTY_MERGE' THEN
            outandlog('.... Merging Parties: From Party ID='||l_from_party_id ||
                  ',To Party ID='||l_to_party_id);

            -- Fetch the dictionary id for the HZ_PARTIES entity
            OPEN c_dict_id(l_rule_set_name,'HZ_PARTIES');
            FETCH c_dict_id INTO l_dict_id;
            IF c_dict_id%NOTFOUND THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_DICT_ENTRY');
              FND_MESSAGE.SET_TOKEN('ENTITY' ,'HZ_PARTIES');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE c_dict_id;

            log('');
            log('Parties');
            g_cur_merge_dict_id := 0;
            g_num_sub_entities :=-1;

            --4307667
	    IF (HZ_PARTY_USG_ASSIGNMENT_PVT.allow_party_merge('T',l_from_party_id,l_to_party_id,l_msg_count,l_error_msg) <> 'Y') THEN
	    l_return_status := FND_API.G_RET_STS_ERROR;
	    raise FND_API.G_EXC_ERROR;
	    END IF;

            -- Call the recursive merge procedure performing this merge
            do_merge(p_batch_party_id	=>l_batch_party_id,
             p_entity_name	=>'HZ_PARTIES',
             p_par_entity_name  =>NULL,
             p_from_id	        =>l_from_party_id,
             p_to_id		=>l_to_party_id,
             p_par_from_id	=>NULL,
             p_par_to_id	=>NULL,
             p_rule_set_name	=>l_rule_set_name,
             p_batch_id	        =>l_batch_id,
             p_batch_commit	=>l_batch_commit,
             p_preview	        =>p_preview,
  	     p_dict_id	        =>l_dict_id,
  	     p_log_padding	=>'  ',
             x_error_msg  	=>l_error_msg,
             x_return_status    =>l_return_status);

        ---For merging party sites/contact points/relationships within same party
         ELSIF l_merge_type = 'SAME_PARTY_MERGE' THEN

           OPEN c_dict_id(l_rule_set_name,'HZ_PARTY_SITES');
           FETCH c_dict_id INTO l_dict_id;
           IF c_dict_id%NOTFOUND THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_DICT_ENTRY');
             FND_MESSAGE.SET_TOKEN('ENTITY' ,'HZ_PARTY_SITES');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
           END IF;
           CLOSE c_dict_id;

           -- Loop through the merge party sites
           OPEN c_batch_party_sites(l_batch_party_id);
           LOOP
             FETCH c_batch_party_sites INTO l_from_site_id, l_to_site_id;
             EXIT WHEN c_batch_party_sites%NOTFOUND;

             IF l_to_site_id IS NOT NULL THEN
                log('');
                log('Party Sites');

                g_cur_merge_dict_id := 0;
                g_num_sub_entities :=-1;

                -- Perform the party site merge within the same party
                do_merge(p_batch_party_id	=>l_batch_party_id,
                 p_entity_name	        =>'HZ_PARTY_SITES',
                 p_par_entity_name      =>NULL,
                 p_from_id	        =>l_from_site_id,
                 p_to_id		=>l_to_site_id,
                 p_par_from_id	        =>l_pre_merge_to_party_id,   --5093366 passing party_id to do_merge for history
                 p_par_to_id	        =>l_pre_merge_to_party_id,
                 p_rule_set_name	=>l_rule_set_name,
                 p_batch_id	        =>l_batch_id,
                 p_batch_commit	        =>l_batch_commit,
                 p_preview	        =>p_preview,
    	         p_dict_id	        =>l_dict_id,
  	         p_log_padding	        =>'  ',
                 x_error_msg  	        =>l_error_msg,
                 x_return_status        =>l_return_status);

             END IF;
             EXIT WHEN l_return_status <> FND_API.G_RET_STS_SUCCESS;
           END LOOP;
           CLOSE c_batch_party_sites;

           --if the prev. merge  was success only then do the next step
           if l_return_status = FND_API.G_RET_STS_SUCCESS then
              OPEN c_dict_id(l_rule_set_name,'HZ_CONTACT_POINTS');
              FETCH c_dict_id INTO l_dict_id;
              IF c_dict_id%NOTFOUND THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_DICT_ENTRY');
                FND_MESSAGE.SET_TOKEN('ENTITY' ,'HZ_CONTACT_POINTS');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
              CLOSE c_dict_id;

              -- Loop through the merge contact points
              OPEN c_batch_contact_points(l_batch_party_id);
              LOOP
                FETCH c_batch_contact_points INTO l_from_cp_id, l_to_cp_id;
                EXIT WHEN c_batch_contact_points%NOTFOUND;

                IF l_to_cp_id IS NOT NULL THEN
                   outandlog('.... Merging Contact Points for party, ID='||l_from_party_id);
                  log('');
                  log('Contact Points');

                  g_cur_merge_dict_id := 0;
                  g_num_sub_entities :=-1;

                 -- Perform the Contact Points merge
                 do_merge(
                  p_batch_party_id       =>l_batch_party_id,
                  p_entity_name          =>'HZ_CONTACT_POINTS',
                  p_par_entity_name      =>NULL,
                  p_from_id              =>l_from_cp_id,
                  p_to_id                =>l_to_cp_id,
                  p_par_from_id          =>l_pre_merge_to_party_id,  --5093366 passing party_id to do_merge for history
                  p_par_to_id            =>l_pre_merge_to_party_id,
                  p_rule_set_name        =>l_rule_set_name,
                  p_batch_id             =>l_batch_id,
                  p_batch_commit         =>l_batch_commit,
                  p_preview              =>p_preview,
                  p_dict_id              =>l_dict_id,
                  p_log_padding          =>'  ',
                  x_error_msg            =>l_error_msg,
                  x_return_status        =>l_return_status);

                END IF;
              EXIT WHEN l_return_status <> FND_API.G_RET_STS_SUCCESS;
              END LOOP;
              CLOSE c_batch_contact_points;

          end if; --l_return status



          ---if the prev. merge  was success only then do the next step
          if l_return_status = FND_API.G_RET_STS_SUCCESS then
             OPEN c_dict_id(l_rule_set_name,'HZ_PARTY_RELATIONSHIPS');
             FETCH c_dict_id INTO l_dict_id;
             IF c_dict_id%NOTFOUND THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_DICT_ENTRY');
                FND_MESSAGE.SET_TOKEN('ENTITY' ,'HZ_PARTY_RELATIONSHIPS');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
             CLOSE c_dict_id;

             -- Loop through the merge relationships
             OPEN c_batch_relationships(l_batch_party_id);
             LOOP
               FETCH c_batch_relationships INTO l_from_rel_id, l_to_rel_id;
               EXIT WHEN c_batch_relationships%NOTFOUND;

               l_from_rel_party_id :=
                          HZ_MERGE_UTIL.get_reln_party_id(l_from_rel_id);
               l_to_rel_party_id   :=
                          HZ_MERGE_UTIL.get_reln_party_id(l_to_rel_id);

               IF l_from_rel_party_id IS NOT NULL AND
                  l_to_rel_party_id IS NOT NULL AND
                  l_from_rel_party_id<>l_to_rel_party_id THEN
                 BEGIN
                   SELECT 1 INTO l_tmp
                   FROM HZ_MERGE_PARTIES
                   WHERE batch_id = l_batch_id
                   AND from_party_id = l_from_rel_party_id
                   AND to_party_id = l_to_rel_party_id
                   AND merge_status = 'DONE';

                   l_to_rel_id := NULL;
                 EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                     NULL;
                 END;
               END IF;


               IF l_to_rel_id IS NOT NULL THEN
                 outandlog('....Merging Contacts for party, ID='||l_from_party_id);
                 log('');
                 log('Contacts');
                 g_cur_merge_dict_id := 0;
                 g_num_sub_entities :=-1;

                 -- Perform the Contact merge
                 do_merge(
                  p_batch_party_id       =>l_batch_party_id,
                  p_entity_name          =>'HZ_PARTY_RELATIONSHIPS',
                  p_par_entity_name      =>NULL,
                  p_from_id              =>l_from_rel_id,
                  p_to_id                =>l_to_rel_id,
                  p_par_from_id          =>l_pre_merge_to_party_id,  --5093366 passing party_id to do_merge for history
                  p_par_to_id            =>l_pre_merge_to_party_id,
                  p_rule_set_name        =>l_rule_set_name,
                  p_batch_id             =>l_batch_id,
                  p_batch_commit         =>l_batch_commit,
                  p_preview              =>p_preview,
                  p_dict_id              =>l_dict_id,
                  p_log_padding          =>'  ',
                  x_error_msg            =>l_error_msg,
                  x_return_status        =>l_return_status);

               END IF;
               EXIT WHEN l_return_status <> FND_API.G_RET_STS_SUCCESS;
             END LOOP;
             CLOSE c_batch_relationships;
          end if; --l_return_status

         ELSE     --type of merge
           FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_MERGE_TYPE');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;  --type of merge

         -- If the party was successfully merged, update merge status to 'DONE'
         IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

            store_merge_history(null,null,null,null,null,null,null,null,null,'Y');
            -- If delete not vetoed, perform delete
            IF g_merge_delete_flag = 'Y' THEN
              delete_merged_records(l_batch_party_id, l_return_status);
            END IF;

            UPDATE HZ_MERGE_PARTIES
            SET MERGE_STATUS = 'DONE',
                last_update_date = hz_utility_v2pub.last_update_date,
                last_updated_by = hz_utility_v2pub.last_updated_by,
                last_update_login = hz_utility_v2pub.last_update_login
            WHERE batch_party_id = l_batch_party_id;

         ELSE -- Errors encountered in merge
            -- Save the global return status (Across all merge parties in batch)
            l_glob_return_status := l_return_status;
            out('Error (check log)');
            retcode := 1;
            errbuf := errbuf || l_error_msg;
            EXIT;
         END IF;

         log('*************************************************');

      ELSE  --l_merge_status = 'DONE'
        outandlog('.... Merging Partes: From Party ID='||l_from_party_id ||
                  ',To Party ID='||l_to_party_id);
        outandlog('Merge already complete');
      END IF;

      IF g_cur_proc_name IS NOT NULL THEN
        g_cur_proc_name := null;
        dbms_sql.close_cursor(g_proc_cursor);
      END IF;
    END LOOP;
    CLOSE c_batch_details;

    if l_pre_merge_type <> 'SAME_PARTY_MERGE' AND
       l_return_status = FND_API.G_RET_STS_SUCCESS then

      /* Merge all to records that are getting merged into the transferred from records */
      FOR TO_RECORDS IN (
            SELECT mp.batch_party_id, merge_from_entity_id, merge_to_entity_id, ENTITY_NAME
            FROM HZ_MERGE_PARTIES mp, HZ_MERGE_PARTY_DETAILS md
            WHERE mp.batch_party_id=md.batch_party_id
            AND mp.to_party_id = l_pre_merge_to_party_id
            AND mp.batch_id = l_batch_id
            AND md.mandatory_merge = 'T') LOOP
         do_same_party_merge (
		p_batch_party_id=>TO_RECORDS.batch_party_id,
		p_entity_name=>TO_RECORDS.ENTITY_NAME,
		p_from_id=>TO_RECORDS.merge_from_entity_id,
		p_to_id=>TO_RECORDS.merge_to_entity_id,
		p_rule_set_name=>l_rule_set_name,
		p_batch_id=>l_batch_id,
		p_batch_commit=>l_batch_commit,
		p_preview=>p_preview,
		p_log_padding=>'  ',
		x_error_msg=>l_error_msg,
		x_return_status=>l_return_status);
         EXIT WHEN l_return_status <> FND_API.G_RET_STS_SUCCESS;
      END LOOP;

      IF l_return_status = FND_API.G_RET_STS_SUCCESS then
        BEGIN

          SELECT 1 INTO l_tmp
          FROM HZ_MERGE_ENTITY_ATTRIBUTES
          WHERE merge_to_party_id = l_pre_merge_to_party_id
          AND merge_batch_id = l_batch_id
          AND ROWNUM=1;

          SELECT decode(party_type,'PERSON','HZ_PERSON_PROFILES',
                       'ORGANIZATION','HZ_ORGANIZATION_PROFILES',
                       'HZ_ORGANIZATION_PROFILES') INTO l_party_type
          FROM HZ_PARTIES
          WHERE party_id=l_pre_merge_to_party_id;


          HZ_MERGE_ENTITY_ATTRI_PVT.do_profile_attribute_merge(
            l_batch_id,
            l_pre_merge_to_party_id,
            l_party_type,
            l_return_status);

          ---Bug 2723616 raise the message passed by profile attr API
          IF l_return_status <>  FND_API.G_RET_STS_SUCCESS  THEN
             l_msg_data :=  logerror;
          END IF;


        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
          WHEN OTHERS THEN
            FND_FILE.put_line(FND_FILE.log,'l_return_status ' || l_return_status);
            FND_FILE.put_line(FND_FILE.log,'Error ' || SQLERRM);
            l_return_status:= FND_API.G_RET_STS_ERROR;
        END;
      END IF;
    END IF;

--4114041
IF (l_glob_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    l_glob_return_status := l_return_status;
END IF;

    --If merge mode is not preview
    IF p_preview <> 'Y'AND
       l_return_status = FND_API.G_RET_STS_SUCCESS THEN
	null;
    --   COMMIT; Should not commit here, need to run batch merge procs after this. 4634891
    ELSE
       ROLLBACK to merge_group;
    END IF;

   END LOOP;
   CLOSE c_pre_merge;

--bug 4634891
-- populate hz_merge_party_log table before executing batch merge procs for team to query
store_merge_log(null, null, null,null, null,null, null, null, null,null,'Y');


OPEN batch_merge_procedures;
LOOP

l_sub_entity_name := NULL;
l_merge_dict_id := NULL;
FETCH batch_merge_procedures INTO l_merge_dict_id, l_sub_entity_name, l_proc_name;
EXIT WHEN batch_merge_procedures%NOTFOUND;
exec_merge(l_sub_entity_name,l_proc_name,p_batch_id,g_request_id,l_return_status);

IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
	outandlog('Executed batch merge procedure '||l_proc_name||' successfully');
ELSE
	l_glob_return_status := l_return_status;
	ROLLBACK TO batch_merge;
	outandlog('Batch merge procedure '||l_proc_name||' is not successful');
	l_error_msg := logerror;
--bug 4916777
  IF  FND_MSG_PUB.Count_Msg <=0  THEN
       l_error_msg := 'Error executing batch merge procedure ' || l_proc_name || ' for entity ' || l_sub_entity_name;
  END IF;
     I_Counter:=0;
     store_merge_log(l_batch_pid, -1,
			    -1,-1, -1,null,null,
			    -1, 'Error', l_error_msg);
     store_merge_log(null, null, null,null, null,null, null, null, null,null,'Y');
--bug 4916777
  outandlog('****ERROR*** : '||l_error_msg);

        EXIT;
END IF;
END LOOP;
CLOSE batch_merge_procedures;
--bug 4634891


 IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED','BO_EVENTS_ENABLED')) THEN

  	HZ_BES_BO_UTIL_PKG.upd_entity_ids(hz_utility_pub.request_id);

  END IF;

  -- Check if the whole batch was successfully executed
  IF l_glob_return_status = FND_API.G_RET_STS_SUCCESS THEN
    outandlog('.... Merge batch successfully executed');

    -- If not preview mode update batch status to COMPLETE
    IF p_preview <> 'Y' then
      -- Update the merge batch status to COMPLETE
      UPDATE HZ_MERGE_BATCH
      SET BATCH_STATUS = 'COMPLETE'
      WHERE BATCH_ID = p_batch_id;

      BEGIN
        UPDATE HZ_DUP_SETS
        SET STATUS = 'COMPLETED'
        WHERE dup_set_id = p_batch_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        NULL;
      END;

    END IF;

    -- If not preview mode and batch commit set at batch level, commit the batch
    IF p_preview <> 'Y'  THEN
      outandlog('.... Commit complete');
      COMMIT;
    -- If preview mode, rollback all the merged parties
    ELSIF p_preview='Y' THEN
      ROLLBACK to batch_merge ;
      outandlog('.... Preview generation complete. Merge transaction rolled back');
      outandlog('.... To Execute and commit run merge without preview');
    END IF;
  ELSE
    outandlog('.... One or more of the Merges in the batch had errors.');
    outandlog('.... Please check the log file');

    -- If not preview mode and batch commit is set at merge party level,
    -- the set batch status to PART_COMPLETE if any of the merged parties
    -- is succesfully complete
    IF p_preview <> 'Y' THEN

      SELECT count(*) INTO l_num_merged FROM HZ_MERGE_PARTIES
      WHERE batch_id = p_batch_id
      AND merge_status = 'DONE';

      IF l_num_merged > 0 THEN
        UPDATE HZ_MERGE_BATCH
        SET BATCH_STATUS = 'PART_COMPLETE'
        WHERE BATCH_ID = p_batch_id;

      ELSE
--BUG 4199594
        UPDATE HZ_MERGE_BATCH
        SET BATCH_STATUS = 'ERROR'
        WHERE BATCH_ID = p_batch_id;

        retcode:=2;
      END IF;

      BEGIN
        UPDATE HZ_DUP_SETS
        SET STATUS = 'ERROR'
        WHERE DUP_SET_ID = p_batch_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        NULL;
      END;

      COMMIT;
    END IF;

--4114041
    IF l_num_merged > 0 THEN
        outandlog('.... Party merge concurrent program completed partially');
    ELSE
        outandlog('.... No changes from the batch have been applied');
    END IF;
  END IF;

  -- set back orig. DSS profile
  fnd_profile.put('HZ_DSS_ENABLED',l_dss_orig_prof_val);

  hz_common_pub.enable_cont_source_security;

  IF g_inv_merge_dict is not null THEN
    log('');
    log('CAUTION: The following tables that are registered in the Party Merge');
    log('dictionary were introduced(or modified) in 11.5.6.  If you are not at 11.5.6, Party Merge');
    log('will skip over these tables and columns because they are not be available in');
    log('your database.  This should not affect the functionality of Party Merge.');
    log('');
    log(g_inv_merge_dict);
    g_inv_merge_dict := NULL;
    g_inv_merge_dict_cnt := 0;
  END IF;

  outandlog('Concurrent Program Execution completed ');
  outandlog('End Time : '|| TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));

--  FND_FILE.close;
--4634891
IF p_preview <> 'Y' THEN
OPEN merge_to_parties;
LOOP
l_pre_merge_to_party_id := NULL;
FETCH merge_to_parties INTO l_pre_merge_to_party_id;
EXIT WHEN merge_to_parties%NOTFOUND;
--4230396
	l_key := HZ_EVENT_PKG.item_key('oracle.apps.ar.hz.Party.merge');
       -- initialization of object variables
       l_list := WF_PARAMETER_LIST_T();
       -- add parameters to list
       wf_event.addParameterToList(p_name  => 'batch_id',
                         	   p_value => l_batch_id,
				   p_parameterlist => l_list);
       wf_event.addParameterToList(p_name  => 'merge_to_party_id',
                                   p_value => l_pre_merge_to_party_id,
                                   p_parameterlist => l_list);
       wf_event.addParameterToList(p_name  => 'Q_CORRELATION_ID',
                                   p_value => 'oracle.apps.ar.hz.Party.merge',
                                   p_parameterlist => l_list);
        -- Raise Event
       HZ_EVENT_PKG.raise_event(
            p_event_name        => 'oracle.apps.ar.hz.Party.merge',
            p_event_key         => l_key,
            p_parameters        => l_list );
       l_list.DELETE;
--4230396
END LOOP;
CLOSE merge_to_parties;
END IF;
--4634891


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    --store_merge_log(null, null, null,null, null,null, null, null, null,null,'Y');
    IF p_preview = 'Y' AND l_batch_merge_spt THEN
      ROLLBACK to batch_merge;
    ELSE
        IF l_mb_spt THEN
          ROLLBACK to merge_group;
        ELSIF l_batch_merge_spt THEN
          ROLLBACK to batch_merge;
        END IF;
    END IF;
    UPDATE HZ_DUP_SETS
    set status = 'ERROR'
    where dup_set_id = p_batch_id;
    commit;
    hz_common_pub.enable_cont_source_security;
    outandlog('Error: Aborting Batch');
    retcode := 2;
    errbuf := errbuf || logerror;
    store_merge_log(l_batch_pid, -1,
			    -1,-1, -1,null,null,
			    -1, 'Error', errbuf);
    store_merge_log(null, null, null,null, null,null, null, null, null,null,'Y');
--  FND_FILE.close;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --store_merge_log(null, null, null,null, null,null, null, null, null,null,'Y');
    IF p_preview = 'Y' AND l_batch_merge_spt THEN
      ROLLBACK to batch_merge;
    ELSE
        IF l_mr_spt THEN
          ROLLBACK to merge_group;
        ELSIF l_batch_merge_spt THEN
          ROLLBACK to batch_merge;
        END IF;
    END IF;
    UPDATE HZ_DUP_SETS
    set status = 'ERROR'
    where dup_set_id = p_batch_id;
    commit;
    hz_common_pub.enable_cont_source_security;
    outandlog('Error: Aborting Batch');
    retcode := 2;
    errbuf := errbuf || logerror;
    store_merge_log(l_batch_pid, -1,
			    -1,-1, -1,null,null,
			    -1, 'Error', errbuf);
    store_merge_log(null, null, null,null, null,null, null, null, null,null,'Y');
--  FND_FILE.close;
  WHEN OTHERS THEN
    --store_merge_log(null, null, null,null, null,null, null, null, null,null,'Y');
    IF p_preview = 'Y' AND l_batch_merge_spt THEN
      ROLLBACK to batch_merge;
    ELSE
        IF l_mr_spt THEN
          ROLLBACK to merge_group;
        ELSIF l_batch_merge_spt THEN
          ROLLBACK to batch_merge;
        END IF;
    END IF;
    UPDATE HZ_DUP_SETS
    set status = 'ERROR'
    where dup_set_id = p_batch_id;
    commit;
    hz_common_pub.enable_cont_source_security;
    outandlog('Error: Aborting Batch');
    retcode := 2;
    errbuf := errbuf || logerror;
    store_merge_log(l_batch_pid, -1,
			    -1,-1, -1,null,null,
			    -1, 'Error', errbuf);
    store_merge_log(null, null, null,null, null,null, null, null, null,null,'Y');
--  FND_FILE.close;
END batch_merge;

/*
Procedure to perform merge for a to_record merging into a from_record
*/
PROCEDURE do_same_party_merge (
	p_batch_party_id        IN      NUMBER,
        p_entity_name           IN      VARCHAR2,
        p_from_id               IN      NUMBER,
        p_to_id                 IN OUT NOCOPY  NUMBER,
	p_rule_set_name         IN      VARCHAR2,
        p_batch_id              IN      NUMBER,
        p_batch_commit          IN      VARCHAR2,
        p_preview               IN      VARCHAR2,
	p_log_padding           IN      VARCHAR2,
        x_error_msg             IN OUT NOCOPY  VARCHAR2,
        x_return_status         IN OUT NOCOPY  VARCHAR2) IS

  CURSOR c_dict_id(cp_ruleset_name VARCHAR2, cp_entity_name VARCHAR2) IS
    SELECT merge_dict_id, DESCRIPTION
    FROM HZ_MERGE_DICTIONARY
    WHERE RULE_SET_NAME = cp_ruleset_name
    AND ENTITY_NAME = cp_entity_name;

  l_dict_id NUMBER;
  l_desc HZ_MERGE_DICTIONARY.DESCRIPTION%TYPE;

BEGIN
  OPEN c_dict_id(p_rule_set_name,p_entity_name);
  FETCH c_dict_id INTO l_dict_id, l_desc;
  IF c_dict_id%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_DICT_ENTRY');
      FND_MESSAGE.SET_TOKEN('ENTITY' ,'HZ_PARTY_SITES');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_dict_id;

  log('');
  log(l_desc);

  g_cur_merge_dict_id := 0;
  g_num_sub_entities :=-1;

  -- Perform the party site merge within the same party
  do_merge(p_batch_party_id       =>p_batch_party_id,
        p_entity_name          => p_entity_name,
        p_par_entity_name      =>NULL,
        p_from_id              =>p_from_id,
        p_to_id                =>p_to_id,
        p_par_from_id          =>NULL,
        p_par_to_id            =>NULL,
        p_rule_set_name        =>p_rule_set_name,
        p_batch_id             =>p_batch_id,
        p_batch_commit         =>p_batch_commit,
        p_preview              =>p_preview,
        p_dict_id              =>l_dict_id,
        p_log_padding          =>p_log_padding||'  ',
        x_error_msg            =>x_error_msg,
        x_return_status        =>x_return_status);
END;

/*-----------------------------------------------------------------------------
| The main engine procedure that performs the merge
| Recursively calls the merge procedures for each sub-record of each subentity
|------------------------------------------------------------------------------*/

PROCEDURE do_merge(
	p_batch_party_id	IN	NUMBER,
	p_entity_name		IN	VARCHAR2,
	p_par_entity_name	IN	VARCHAR2,
	p_from_id		IN	NUMBER,
	p_to_id			IN OUT NOCOPY 	NUMBER,
	p_par_from_id		IN	NUMBER,
	p_par_to_id		IN	NUMBER,
	p_rule_set_name		IN	VARCHAR2,
	p_batch_id		IN	NUMBER,
	p_batch_commit		IN	VARCHAR2,
	p_preview		IN	VARCHAR2,
	p_dict_id		IN	NUMBER,
        p_log_padding		IN	VARCHAR2,
        x_error_msg		IN OUT NOCOPY	VARCHAR2,
        x_return_status		IN OUT NOCOPY	VARCHAR2) IS

  -- Fetch dictionary details for the entity (Merge procedure)
  CURSOR c_dict_details(cp_merge_dict_id NUMBER) IS
    SELECT PROCEDURE_NAME, PK_COLUMN_NAME,nvl(DESC_COLUMN_NAME,PK_COLUMN_NAME),
           FK_COLUMN_NAME, PARENT_ENTITY_NAME
    FROM hz_merge_dictionary
    WHERE merge_dict_id = cp_merge_dict_id;

  -- Fecth merge party details from the dictionary
  CURSOR c_party_details(cp_ent_name VARCHAR2, cp_pk_value NUMBER) IS
      SELECT merge_to_entity_id
      FROM hz_merge_party_details
      WHERE merge_from_entity_id = cp_pk_value AND
            batch_party_id = p_batch_party_id AND
            entity_name = cp_ent_name;


  l_proc_name 		HZ_MERGE_DICTIONARY.PROCEDURE_NAME%TYPE;
  l_pk_column_name 	HZ_MERGE_DICTIONARY.PK_COLUMN_NAME%TYPE;
  l_desc_column_name 	HZ_MERGE_DICTIONARY.DESC_COLUMN_NAME%TYPE;
  l_fk_column_name 	HZ_MERGE_DICTIONARY.FK_COLUMN_NAME%TYPE;
  l_parent_entity_name 	HZ_MERGE_DICTIONARY.PARENT_ENTITY_NAME%TYPE;
  l_sub_entity_name 	HZ_MERGE_DICTIONARY.ENTITY_NAME%TYPE;
  l_sub_fk_column_name 	HZ_MERGE_DICTIONARY.FK_COLUMN_NAME%TYPE;
  l_sub_fk_column_type 	HZ_MERGE_DICTIONARY.FK_DATA_TYPE%TYPE;
  l_sub_pk_column_name 	HZ_MERGE_DICTIONARY.PK_COLUMN_NAME%TYPE;
  l_proc_name_b 	HZ_MERGE_DICTIONARY.PROCEDURE_NAME%TYPE;
  l_pk_column_name_b 	HZ_MERGE_DICTIONARY.PK_COLUMN_NAME%TYPE;
  l_desc_column_name_b 	HZ_MERGE_DICTIONARY.DESC_COLUMN_NAME%TYPE;
  l_fk_column_name_b 	HZ_MERGE_DICTIONARY.FK_COLUMN_NAME%TYPE;
  l_parent_entity_name_b HZ_MERGE_DICTIONARY.PARENT_ENTITY_NAME%TYPE;

  l_sub_to_id		NUMBER;
  l_op_type		VARCHAR2(50);
  l_join_clause		VARCHAR2(2000);

  -- REF Cursor to fetch sub-records in each sub-entity
  TYPE SubRecType IS REF CURSOR;
  c_sub_records SubRecType;
  l_sub_pk_value NUMBER;
  l_sub_pk_value_r ROWID;

  l_merge_dict_id NUMBER;
  l_from_rec_desc VARCHAR2(2000);
  l_to_rec_desc VARCHAR2(2000);
  l_desc VARCHAR2(2000);

  l_pmerge_apps VARCHAR2(2000) := NULL;

  TYPE SubEntType IS REF CURSOR;
  c_sub_entities SubEntType;

  l_subrec_str VARCHAR2(2000);
  l_subent_cnt NUMBER := 0;
  l_null_id NUMBER;
  l_null_id_r ROWID;

  l_bulk_flag 		VARCHAR2(1);

  l_op VARCHAR2(30);
  rownumber NUMBER;
  l_mand VARCHAR2(30);
  l_hint VARCHAR2(255);

BEGIN

  -- Merge this entity

  -- Fetch dict details (merge procedure)
  OPEN c_dict_details(p_dict_id);
  FETCH c_dict_details INTO l_proc_name, l_pk_column_name,l_desc_column_name,
            l_fk_column_name, l_parent_entity_name;

  -- If not found error out
  IF (c_dict_details%NOTFOUND or l_proc_name = null) THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_DICT_ENTRY');
    FND_MESSAGE.SET_TOKEN('ENTITY' ,p_entity_name);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_dict_details;


  l_from_rec_desc :=  get_record_desc(p_from_id,p_entity_name, l_pk_column_name,
                         l_desc_column_name, x_return_status);
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

    -- Write a log message
    log(p_log_padding|| l_from_rec_desc, FALSE);

    -- Execute the merge procedure for the entity
    exec_merge(p_entity_name,
             l_proc_name,
	     p_from_id,
             p_to_id,
             p_par_from_id,
             p_par_to_id,
             p_par_entity_name,
             p_batch_id,
             p_batch_party_id,
             x_return_status);

    -- Check if the merge procedure returned an error
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS OR
        x_return_status = 'N') THEN
      -- Log the merged records

      -- If the to_id is different from from_id .. then the operation performed
      -- is a merge
      IF ((p_to_id IS NOT NULL AND p_to_id <> FND_API.G_MISS_NUM)
           AND p_to_id <> p_from_id) THEN
        -- Store in the history and log

        IF (p_to_id <> 0) THEN
          l_mand := 'N';
          IF x_return_status='N' THEN
            l_mand := 'C';
            l_op := 'Copy';
          ELSE
            l_op := 'Merge';
          END IF;

          x_return_status := FND_API.G_RET_STS_SUCCESS;

          l_to_rec_desc :=  get_record_desc(p_to_id,p_entity_name, l_pk_column_name,
                         l_desc_column_name, x_return_status);
          IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

            IF p_entity_name = 'HZ_PARTY_SITES' AND l_mand <> 'C' THEN
              BEGIN
                SELECT mandatory_merge INTO l_mand
                FROM hz_merge_party_details
                WHERE batch_party_id = p_batch_party_id
                AND merge_from_entity_id = p_from_id
                AND entity_name = p_entity_name;

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_mand := 'N';
              END;
            END IF;

            IF l_mand IS NOT NULL AND l_mand = 'C' THEN
              l_op := 'Copy';
              -- Write to log file
              log(' copied to ' || l_to_rec_desc);
            ELSE
              -- Write to log file
              log(' merged with ' || l_to_rec_desc);
            END IF;

            store_merge_history(p_batch_party_id, p_from_id,
                        p_to_id,p_par_from_id, p_par_to_id,l_from_rec_desc,
                        l_to_rec_desc, p_dict_id, l_op);
          END IF;
        ELSE
          log(' discarded (DNB data)');
        END IF;

      -- Else the operation performed is transfer
      -- However also check of the parent IDs are different.
      ELSIF p_par_from_id <> p_par_to_id THEN
        store_merge_history(p_batch_party_id,p_from_id,
                        p_from_id,p_par_from_id, p_par_to_id,l_from_rec_desc, null, p_dict_id,  --5093366 replaced p_to_id with p_from_id
                        'Transfer');

        -- Since the id of the record does not change, the to_id is the
        -- same as the from_id
        p_to_id := p_from_id;
        log(' : Transferred '|| l_fk_column_name ||' from '|| p_par_from_id ||' to '||p_par_to_id);
      --return do not go for sub-entities if its transfer
       return;

      -- To and From Ids are same, and Parent IDs are same ..
      -- nothing has been done
      ELSE
        -- Set To Id to the From ID .. this is just to continue further down the
        -- the hierarchy
        log(' : Record not modified');
        p_to_id := p_from_id;
      END IF;
    ELSE
      log('', TRUE);
      log(' **** Error **** ', TRUE);
      log('Error: Merge failed in procedure '||l_proc_name||' for entity '||p_entity_name,TRUE); --4634891
      x_error_msg := logerror;

--bug 4916777
      IF  FND_MSG_PUB.Count_Msg <=0  THEN
          x_error_msg := 'Error executing procedure ' || l_proc_name || ' for entity ' || p_entity_name;
          log(x_error_msg);
      END IF;
--bug 4916777
      -- Log the error in the table and return
      store_merge_log(p_batch_party_id, p_from_id,
                    p_to_id,p_par_from_id, p_par_to_id,l_from_rec_desc,null,
                    p_dict_id, 'Error', x_error_msg);
      RETURN;
    END IF;
  ELSE
    log('', TRUE);
    log(' **** Error **** ',TRUE);
    log('Error: Merge failed in procedure HZ_PARTY_MERGE.GET_RECORD_DESC for entity '||p_entity_name); --4634891
    x_error_msg := logerror;

    -- Log the error in the table and return
    store_merge_log(p_batch_party_id, p_from_id,
                    p_to_id,p_par_from_id, p_par_to_id,l_from_rec_desc,null, p_dict_id, 'Error',
                    x_error_msg);
    RETURN;
  END IF;

  IF g_cur_merge_dict_id = p_dict_id AND g_num_sub_entities = 0 THEN
    RETURN;
  END IF;
  g_cur_merge_dict_id:=p_dict_id;
  g_num_sub_entities:=-1;

  -- Merge the sub-entities .. For each subentity fetch the records and
  -- call the merge procedure
  -- If data from 'IMPORT', only TCA entities need to be merged.

  l_pmerge_apps:=null;
  if G_REQUEST_TYPE = 'IMPORT'
  then
        l_pmerge_apps := G_TCA_APP_ID;
  else

        IF FND_PROFILE.VALUE('HZ_PARTY_MERGE_APPLICATIONS') IS NOT NULL THEN
          l_pmerge_apps := '(' || G_TCA_APP_ID || ', ' ||
                  FND_PROFILE.VALUE('HZ_PARTY_MERGE_APPLICATIONS') || ')';
        END IF;
  END IF;

  IF l_pmerge_apps IS NOT NULL THEN



	  OPEN c_sub_entities FOR
      'SELECT MERGE_DICT_ID, ENTITY_NAME, FK_COLUMN_NAME, FK_DATA_TYPE, PK_COLUMN_NAME,'||
      'JOIN_CLAUSE, DESCRIPTION, PROCEDURE_NAME, BULK_FLAG '||
      'FROM HZ_MERGE_DICTIONARY ' ||
      'WHERE PARENT_ENTITY_NAME = :pentity' ||
      ' AND RULE_SET_NAME = :ruleset '||
      ' AND DICT_APPLICATION_ID IN ' || l_pmerge_apps ||
      ' AND NVL(BATCH_MERGE_FLAG,''N'') <> ''Y'' '|| --bug4634891
      ' ORDER BY SEQUENCE_NO ' USING p_entity_name, p_rule_set_name;
   ELSE
        OPEN c_sub_entities FOR
      'SELECT MERGE_DICT_ID, ENTITY_NAME, FK_COLUMN_NAME, FK_DATA_TYPE, PK_COLUMN_NAME,'||
      'JOIN_CLAUSE, DESCRIPTION, PROCEDURE_NAME, BULK_FLAG '||
      'FROM HZ_MERGE_DICTIONARY ' ||
      'WHERE PARENT_ENTITY_NAME = :pentity' ||
      ' AND RULE_SET_NAME = :ruleset '||
      ' AND NVL(BATCH_MERGE_FLAG,''N'') <> ''Y'' '|| --bug4634891
      ' ORDER BY SEQUENCE_NO ' USING p_entity_name, p_rule_set_name;

  end if;


  l_subent_cnt := 0;
  LOOP
    -- Fetch the subentities
    FETCH c_sub_entities INTO l_merge_dict_id, l_sub_entity_name,
               l_sub_fk_column_name, l_sub_fk_column_type,l_sub_pk_column_name, l_join_clause, l_desc,
               l_proc_name, l_bulk_flag;
    EXIT WHEN c_sub_entities%NOTFOUND;

    IF NOT g_skip_dict_id.EXISTS(l_merge_dict_id) THEN

    l_subent_cnt := l_subent_cnt+1;

    -- Invalid subentity in dictionary .. error out
    IF (l_sub_entity_name is null or l_sub_fk_column_name is null or
       l_sub_fk_column_name is null) THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_DICT_ENTRY');
      FND_MESSAGE.SET_TOKEN('ENTITY' ,l_sub_entity_name);
      FND_MSG_PUB.ADD;

      x_error_msg:=logerror;
      store_merge_log(p_batch_party_id, -1,
			    -1,p_from_id, p_to_id,null,null,
			    l_merge_dict_id, 'Error', x_error_msg);
      log('Error Entity Name: '||l_sub_entity_name);
      log('Error FK Column: '||l_sub_fk_column_name);

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;
    END IF;

    --log('fk data type: '||l_sub_fk_column_type);

    l_hint := '';
    IF l_desc IS NOT NULL AND l_desc like 'HINT:%' THEN
      l_hint := substr(l_desc,6,instr(l_desc, '/',1,2)-5);
      l_desc := replace(l_desc,'HINT:'||l_hint);
    END IF;

    IF l_hint IS NULL THEN
      IF (l_sub_entity_name = 'HZ_PARTY_RELATIONSHIPS') THEN  --4500011
         l_subrec_str := 'SELECT RELATIONSHIP_ID FROM HZ_RELATIONSHIPS'
         ||' WHERE '|| l_sub_fk_column_name;
      ELSE
         l_subrec_str := 'SELECT ' || l_sub_pk_column_name || ' FROM '
         ||l_sub_entity_name || ' WHERE '|| l_sub_fk_column_name;
      END IF;
    ELSE
        l_subrec_str := 'SELECT ' || l_hint ||' '|| l_sub_pk_column_name || ' FROM '
         ||l_sub_entity_name || ' S WHERE '|| l_sub_fk_column_name;
    END IF;

    IF l_sub_fk_column_type = 'VARCHAR2' THEN
      l_subrec_str := l_subrec_str || ' = TO_CHAR(:p_from_id)';
    ELSE
      l_subrec_str := l_subrec_str || ' = :p_from_id';
    END IF;

    IF l_join_clause IS NOT NULL THEN
      l_subrec_str := l_subrec_str || ' AND ' || l_join_clause;
    END IF;
--4500011
    IF (l_sub_entity_name = 'HZ_PARTY_RELATIONSHIPS') THEN
       l_subrec_str := l_subrec_str || ' AND ' || ' subject_table_name = ''HZ_PARTIES'' AND object_table_name = ''HZ_PARTIES'' AND directional_flag = ''F''';
   END IF;

    BEGIN
      OPEN c_sub_records FOR l_subrec_str using p_from_id;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE=-904 THEN

          IF nvl(instrb(g_inv_merge_dict, l_sub_entity_name),0)=0 THEN
             g_inv_merge_dict_cnt := g_inv_merge_dict_cnt+1;
             IF g_inv_merge_dict_cnt = 1 THEN
               g_inv_merge_dict := g_inv_merge_dict || rpad(l_sub_entity_name,28);
             ELSIF g_inv_merge_dict_cnt = 3 THEN
               g_inv_merge_dict := g_inv_merge_dict || ' ' || l_sub_entity_name || fnd_global.local_chr(13) || fnd_global.local_chr(10);
               g_inv_merge_dict_cnt:=0;
             ELSE
               g_inv_merge_dict := g_inv_merge_dict || ' ' || rpad(l_sub_entity_name,28);
             END IF;
          END IF;
          l_subrec_str:=NULL;
        ELSIF SQLCODE=-942 THEN
          IF nvl(instrb(g_inv_merge_dict, l_sub_entity_name),0)=0 THEN
             g_inv_merge_dict_cnt := g_inv_merge_dict_cnt+1;
             IF g_inv_merge_dict_cnt = 1 THEN
               g_inv_merge_dict := g_inv_merge_dict || rpad(l_sub_entity_name,28);
             ELSIF g_inv_merge_dict_cnt = 3 THEN
               g_inv_merge_dict := g_inv_merge_dict || '  ' || l_sub_entity_name ||
fnd_global.local_chr(13) || fnd_global.local_chr(10);
               g_inv_merge_dict_cnt:=0;
             ELSE
               g_inv_merge_dict := g_inv_merge_dict || '  ' || rpad(l_sub_entity_name,28);
             END IF;
          END IF;
          l_subrec_str:=NULL;
        ELSE
          FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
          FND_MESSAGE.SET_TOKEN('ERROR' ,'do_merge ' || SQLERRM);
          FND_MSG_PUB.ADD;

          x_error_msg:=logerror;
          store_merge_log(p_batch_party_id, -1,
                            -1,p_from_id, p_to_id,null,null,
                            l_merge_dict_id, 'Error', x_error_msg);
          log('Error Entity Name: '||l_sub_entity_name);
          log('Error FK Column: '||l_sub_fk_column_name);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RETURN;
        END IF;
    END;

    -- Handle the case where the Primary key has been defined as the
    -- ROWID. No recursion for this type of PK definition.
    IF l_sub_pk_column_name='ROWID' THEN

      -- Fetch dictionary details
      OPEN c_dict_details(l_merge_dict_id);
      FETCH c_dict_details INTO l_proc_name_b, l_pk_column_name_b,l_desc_column_name_b,
              l_fk_column_name_b, l_parent_entity_name_b;
      -- If not found error out
      IF (c_dict_details%NOTFOUND or l_proc_name = null) THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_DICT_ENTRY');
        FND_MESSAGE.SET_TOKEN('ENTITY' ,l_sub_entity_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_dict_details;
      log(p_log_padding || '   '|| l_desc);

      rownumber := 0;

      LOOP
        EXIT WHEN l_subrec_str IS NULL;
        l_sub_pk_value_r := NULL;
        FETCH c_sub_records INTO l_sub_pk_value_r;
        EXIT WHEN c_sub_records%NOTFOUND;

        rownumber:=rownumber+1;

        IF l_bulk_flag IS NULL OR l_bulk_flag = 'N' THEN
          l_from_rec_desc :=  get_record_desc_r(l_sub_pk_value_r,l_sub_entity_name,
                                              l_desc_column_name_b, x_return_status);
          log(p_log_padding || '     ' || l_from_rec_desc, FALSE);
        END IF;

        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

          IF rownumber=1 OR l_bulk_flag IS NULL OR l_bulk_flag <> 'Y' THEN
            -- Execute the merge procedure for the entity
            exec_merge_r(l_sub_entity_name,
                   l_proc_name_b,
                   l_sub_pk_value_r,
                   l_null_id_r,
                   p_from_id,
                   p_to_id,
                   p_entity_name,
                   p_batch_id,
                   p_batch_party_id,
                   x_return_status);
          END IF;

          -- Check if the merge procedure returned an error
          IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            IF p_from_id <> p_to_id THEN
              store_merge_history(p_batch_party_id,-1,
                        -1,p_from_id, p_to_id,l_from_rec_desc, null, p_dict_id,
                        'Transfer');

              IF l_bulk_flag IS NOT NULL AND l_bulk_flag = 'Y' THEN
                 IF rownumber = 1 THEN
                   log(p_log_padding || '         ' || ' Bulk merge completed. Transferred '|| l_fk_column_name_b ||' from '|| p_from_id ||' to '||p_to_id);
                 END IF;
              ELSE
                -- Since the id of the record does not change, the to_id is the
                -- same as the from_id
                log(' : Transferred '|| l_fk_column_name_b ||' from '|| p_from_id ||' to '||p_to_id);
              END IF;

            -- To and From Ids are same, and Parent IDs are same ..
            -- nothing has been done
            ELSE
              -- Set To Id to the From ID .. this is just to continue further down the
              -- the hierarchy
              log(' : Record not modified');
            END IF;
          ELSE
            log('', TRUE);
            log(' **** Error **** ', TRUE);
	    log('Error: Merge failed in procedure '||l_proc_name_b||' for entity '||l_sub_entity_name,TRUE); --4634891
            x_error_msg := logerror;
--bug 4916777
            IF  FND_MSG_PUB.Count_Msg <=0    THEN
                x_error_msg := 'Error executing procedure ' || l_proc_name || ' for entity ' || p_entity_name;
                log(x_error_msg);
            END IF ;
--bug 4916777
            -- Log the error in the table and return
            store_merge_log(p_batch_party_id, -1,
                            -1,p_from_id, p_to_id,l_from_rec_desc,null,
                            l_merge_dict_id, 'Error', x_error_msg);
            RETURN;
          END IF;
        ELSE
          log('', TRUE);
          log(' **** Error **** ', TRUE);
	  log('Error: Merge failed in procedure HZ_PARTY_MERGE.GET_RECORD_DESC for entity '||l_sub_entity_name); --4634891
          x_error_msg := logerror;

          -- Log the error in the table and return
          store_merge_log(p_batch_party_id, -1,
                          -1,p_from_id, p_to_id,null,null,
                          l_merge_dict_id, 'Error', x_error_msg);
          RETURN;
        END IF;
        EXIT WHEN l_bulk_flag IS NOT NULL AND l_bulk_flag = 'Y';
      END LOOP;

    ELSE

      IF l_bulk_flag IS NOT NULL AND l_bulk_flag = 'Y' THEN
        rownumber := 0;


        LOOP
          EXIT WHEN l_subrec_str IS NULL;
          FETCH c_sub_records INTO l_sub_pk_value;
          EXIT WHEN c_sub_records%NOTFOUND;

          rownumber:=rownumber+1;

          IF rownumber=1 THEN
            log(p_log_padding || '   '|| l_desc);

            -- Fetch dict details (merge procedure)
            OPEN c_dict_details(l_merge_dict_id);
            FETCH c_dict_details INTO l_proc_name_b, l_pk_column_name_b,l_desc_column_name_b,
              l_fk_column_name_b, l_parent_entity_name_b;

            -- If not found error out
            IF (c_dict_details%NOTFOUND or l_proc_name = null) THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_DICT_ENTRY');
              FND_MESSAGE.SET_TOKEN('ENTITY' ,l_sub_entity_name);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE c_dict_details;
          END IF;

          IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            IF rownumber=1 THEN

              -- Execute the merge procedure for the entity
              exec_merge(l_sub_entity_name,
                         l_proc_name_b,
                         null,
                         l_null_id,
                         p_from_id,
                         p_to_id,
                         p_entity_name,
                         p_batch_id,
                         p_batch_party_id,
                         x_return_status);
              log(p_log_padding || '       Bulk merge completed. Transferred '|| l_fk_column_name_b ||' from '|| p_from_id ||' to '||p_to_id);
            END IF;

            -- Check if the merge procedure returned an error
            IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                -- Write to log file
                store_merge_history(p_batch_party_id, l_sub_pk_value ,
                                    null,p_from_id, p_to_id,null,
                                    null, l_merge_dict_id, 'Transfer');
            ELSE
              log('', TRUE);
              log(' **** Error **** ', TRUE);
	      log('Error: Merge failed in procedure '||l_proc_name_b||' for entity '||l_sub_entity_name,TRUE); --4634891
              x_error_msg := logerror;
--bug 4916777
              IF  FND_MSG_PUB.Count_Msg <=0  THEN
                  x_error_msg := 'Error executing procedure ' || l_proc_name || ' for entity ' || p_entity_name;
                  log(x_error_msg);
              END IF ;
--bug 4916777
              -- Log the error in the table and return
              store_merge_log(p_batch_party_id, -1,
                              -1,p_from_id, p_to_id,null,null,
                              l_merge_dict_id, 'Error', x_error_msg);
              RETURN;
            END IF;
          ELSE
            log('', TRUE);
            log(' **** Error **** ', TRUE);
            x_error_msg := logerror;

            -- Log the error in the table and return
            store_merge_log(p_batch_party_id, -1,
                            -1,p_from_id, p_to_id,null,null,
                            l_merge_dict_id, 'Error', x_error_msg);
            RETURN;
          END IF;

        END LOOP;
      ELSE
        -- Loop through each sub-entity record
        LOOP
          EXIT WHEN l_subrec_str IS NULL;
          l_sub_to_id := NULL;
          l_sub_pk_value := NULL;
          FETCH c_sub_records INTO l_sub_pk_value;
          EXIT WHEN c_sub_records%NOTFOUND;

          -- Fetch party details for the sub-entity
          OPEN c_party_details(l_sub_entity_name, l_sub_pk_value);
          FETCH c_party_details INTO l_sub_to_id;
          CLOSE c_party_details;

          log(p_log_padding || '   '|| l_desc);

          -- Recursive call to merge the sub-entity record
          do_merge(p_batch_party_id	=>	p_batch_party_id,
                   p_entity_name	=>	l_sub_entity_name,
                   p_par_entity_name=>	p_entity_name,
                   p_from_id	=>	l_sub_pk_value,
                   p_to_id		=>	l_sub_to_id,
                   p_par_from_id	=>	p_from_id,
                   p_par_to_id	=>	p_to_id,
                   p_rule_set_name	=>	p_rule_set_name,
                   p_batch_id	=>	p_batch_id,
                   p_batch_commit	=>	p_batch_commit,
                   p_preview	=>	p_preview,
                   p_dict_id	=>	l_merge_dict_id,
                   p_log_padding    =>      p_log_padding || '      ',
                   x_error_msg  	=>      x_error_msg,
                   x_return_status  =>      x_return_status);

          -- If not successful abort merge and return
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
          END IF;
        END LOOP;
      END IF;
    END IF;
    IF l_subrec_str IS NOT NULL THEN
      CLOSE c_sub_records;
    END IF;

    END IF; /* skip_dict_id */
  END LOOP;
  CLOSE c_sub_entities;
  IF l_subent_cnt = 0 THEN
    g_num_sub_entities := 0;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,'do_merge ' || SQLERRM);
    FND_MSG_PUB.ADD;

    x_error_msg:=logerror;
    store_merge_log(p_batch_party_id, -1,
                            -1,p_from_id, p_to_id,null,null,
                            l_merge_dict_id, 'Error', x_error_msg);
    log('Error Entity Name: '||l_sub_entity_name);
    log('Error FK Column: '||l_sub_fk_column_name);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_merge;

/*------------------------------------------------------------------------------
| Procedure to lock HZ_MERGE_BATCH, HZ_MERGE_PARTIES and HZ_MERGE_PARTY_DETAILS
| for a given batch
|-------------------------------------------------------------------------------*/

PROCEDURE lock_batch(
	p_batch_id 		IN	VARCHAR2,
        x_return_status         IN OUT NOCOPY  VARCHAR2) IS

BEGIN
  -- Lock merge party details
  EXECUTE IMMEDIATE 'SELECT batch_party_id from HZ_MERGE_PARTY_DETAILS ' ||
  'WHERE batch_party_id IN ' ||
     ' (SELECT batch_party_id from HZ_MERGE_PARTIES '||
      ' WHERE batch_id = :batchid )  FOR UPDATE NOWAIT' USING p_batch_id;

  -- Lock merge parties
  EXECUTE IMMEDIATE 'SELECT batch_party_id from HZ_MERGE_PARTIES ' ||
  'WHERE batch_id = :batchid FOR UPDATE NOWAIT' USING p_batch_id;

  -- Lock batch
  EXECUTE IMMEDIATE 'SELECT batch_id from HZ_MERGE_BATCH ' ||
  'WHERE batch_id = :batchid FOR UPDATE NOWAIT' USING p_batch_id;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_BATCH_LOCK_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END lock_batch;

/*---------------------------------------------------------------------------------------
| Procedure to recursively lock all records for entities defined in the merge dictionary
| for a given party id or party site id
|---------------------------------------------------------------------------------------*/
PROCEDURE lock_records(
        p_entity_name		IN	VARCHAR2,
        p_pk_column_name	IN	VARCHAR2,
        p_fk_column_name	IN	VARCHAR2,
        p_join_str		IN	VARCHAR2,
        p_join_clause		IN	VARCHAR2,
	p_rule_set_name		IN	VARCHAR2,
	x_return_status		IN OUT NOCOPY	VARCHAR2) IS

  -- Dummy join clause
  l_join_clause  VARCHAR2(2000) := '1=1';

  l_sub_ent_name 	HZ_MERGE_DICTIONARY.ENTITY_NAME%TYPE;
  l_sub_fkcol 	HZ_MERGE_DICTIONARY.FK_COLUMN_NAME%TYPE;
  l_sub_pkcol 	HZ_MERGE_DICTIONARY.PK_COLUMN_NAME%TYPE;
  l_sub_joincl		VARCHAR2(2000);

  lockstr VARCHAR2(32000);
  str_lockstr VARCHAR2(32000);
  l_sqlstr VARCHAR2(2000);
  l_pmerge_apps VARCHAR2(2000) := NULL;
  l_app_name VARCHAR2(100);
  l_app_id NUMBER;

  TYPE SubEntType IS REF CURSOR;
  c_dict_details SubEntType;

    cursor app_name(app_id NUMBER) IS
Select application_short_name from fnd_application where application_id=app_id;

BEGIN

  -- Dynamically constructed SQL statement for locking all records
  -- The where clause in this statement builds up with each recursive call
  IF p_join_clause is not null THEN
    lockstr := 'SELECT ' || p_pk_column_name || ' FROM ' ||
               p_entity_name || ' WHERE ' ||
               p_fk_column_name || ' IN ' || p_join_str || ' AND ' ||
               replace(upper(p_join_clause), 'GROUP BY ' ||
               upper(p_pk_column_name));
  ELSE
    lockstr := 'SELECT ' || p_pk_column_name || ' FROM ' ||
               p_entity_name || ' WHERE ' || p_fk_column_name ||
               ' IN ' || p_join_str;
  END IF;

  BEGIN
     -- Execute the dynamic SQL statement and lock records
     EXECUTE IMMEDIATE lockstr || ' FOR UPDATE NOWAIT';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE=-904 THEN
        lockstr:=null;
      ELSIF SQLCODE=-942 THEN
        lockstr:=null;
      ELSE
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END;

  IF lockstr IS NULL THEN
    RETURN;
  END IF;

  IF lockstr IS NOT NULL THEN
    IF FND_PROFILE.VALUE('HZ_PARTY_MERGE_APPLICATIONS') IS NOT NULL THEN
      l_pmerge_apps := '(' || G_TCA_APP_ID || ', ' ||
                    FND_PROFILE.VALUE('HZ_PARTY_MERGE_APPLICATIONS') || ')';
      OPEN c_dict_details FOR
        'SELECT ENTITY_NAME, PK_COLUMN_NAME, FK_COLUMN_NAME, JOIN_CLAUSE, DICT_APPLICATION_ID'||
        'FROM HZ_MERGE_DICTIONARY ' ||
        'WHERE PARENT_ENTITY_NAME = :pentity' ||
        ' AND RULE_SET_NAME = :ruleset '||
        ' AND DICT_APPLICATION_ID IN ' || l_pmerge_apps ||
        ' ORDER BY SEQUENCE_NO ' USING p_entity_name, p_rule_set_name;
    ELSE
      OPEN c_dict_details FOR
        'SELECT ENTITY_NAME, PK_COLUMN_NAME, FK_COLUMN_NAME, JOIN_CLAUSE, DICT_APPLICATION_ID '||
        'FROM HZ_MERGE_DICTIONARY ' ||
        'WHERE PARENT_ENTITY_NAME = :pentity' ||
        ' AND RULE_SET_NAME = :ruleset '||
        ' ORDER BY SEQUENCE_NO ' USING p_entity_name, p_rule_set_name;
    END IF;
  END IF;


  -- Loop through all sub entities
  LOOP
    EXIT WHEN lockstr is null;
    FETCH c_dict_details INTO l_sub_ent_name, l_sub_pkcol, l_sub_fkcol,
          l_sub_joincl,l_app_id;
    EXIT WHEN c_dict_details%NOTFOUND;
     open app_name(l_app_id);
      fetch app_name into l_app_name;
     close app_name;
    -- Recursive call to lock records for each sub-entity
    -- (NOTE: The key here is passing the current "lockstr" to the recursive
    -- call .. this is added as part of the nested where clause in the next leve)
    IF get_col_type(l_sub_ent_name, l_sub_fkcol,l_app_name) = 'VARCHAR2' THEN
      str_lockstr := 'SELECT TO_CHAR(' || p_pk_column_name || ') FROM ' ||
             p_entity_name || ' WHERE ' || p_fk_column_name || ' IN ' ||
             p_join_str || ' AND ' || l_join_clause;
      lock_records(l_sub_ent_name, l_sub_pkcol, l_sub_fkcol, '(' ||str_lockstr
                ||')', l_sub_joincl,p_rule_set_name, x_return_status);
    ELSE
      lock_records(l_sub_ent_name, l_sub_pkcol, l_sub_fkcol, '(' ||lockstr
                ||')', l_sub_joincl,p_rule_set_name, x_return_status);
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;

  END LOOP;
  CLOSE c_dict_details;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_LOCK_ERROR');
    FND_MESSAGE.SET_TOKEN('ENTITY', p_entity_name);
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM || ' : ' || lockstr || ' subent ' || l_sub_ent_name);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END lock_records;

/*------------------------------------------------------------------------------
| Procedure to delete the merged records for a batch party
|------------------------------------------------------------------------------*/
PROCEDURE delete_merged_records(
	p_batch_party_id IN	NUMBER,
        x_return_status         IN OUT NOCOPY  VARCHAR2) IS

CURSOR c_deleted_records IS
  SELECT h.from_entity_id, d.entity_name, d.pk_column_name
  FROM HZ_MERGE_PARTY_HISTORY h, HZ_MERGE_DICTIONARY d
  WHERE h.merge_dict_id = d.merge_dict_id
  AND h.batch_party_id = p_batch_party_id
  AND h.request_id = hz_utility_pub.request_id
  AND h.operation_type = 'Merge'
  ORDER BY h.merge_dict_id desc;

l_record_id HZ_MERGE_PARTY_HISTORY.FROM_ENTITY_ID%TYPE;
l_entity_name HZ_MERGE_DICTIONARY.ENTITY_NAME%TYPE;
l_pkcol HZ_MERGE_DICTIONARY.PK_COLUMN_NAME%TYPE;

rec_delete VARCHAR2(2000);

BEGIN

  log('Deleting merged records');

  OPEN c_deleted_records;
  LOOP
    FETCH c_deleted_records INTO l_record_id, l_entity_name, l_pkcol;

    EXIT WHEN c_deleted_records%NOTFOUND;

    IF l_entity_name = 'HZ_PARTIES' OR
       l_entity_name =  'HZ_PARTY_SITES' OR
       l_entity_name =  'HZ_ORGANIZATION_PROFILES' OR
       l_entity_name =  'HZ_PERSON_PROFILES' OR
       l_entity_name =  'HZ_ORG_CONTACTS'    OR
       l_entity_name =  'HZ_PARTY_USG_ASSIGNMENTS' --4307667
    THEN
      rec_delete := 'UPDATE ' || l_entity_name ||
                   ' SET STATUS = ''D'' WHERE ' ||
                   l_pkcol || ' = :pk';
    ELSIF l_entity_name =  'HZ_PARTY_RELATIONSHIPS' THEN --4500011
      rec_delete := 'UPDATE HZ_RELATIONSHIPS' ||
                   ' SET STATUS = ''D'' WHERE ' ||
                   'RELATIONSHIP_ID' || ' = :pk'||'AND subject_table_name = ''HZ_PARTIES''  AND object_table_name = ''HZ_PARTIES'' AND directional_flag = ''F''';
    ELSE
      -- Construct dynamic SQL query to fetch description
      rec_delete := 'DELETE FROM ' || l_entity_name ||
               ' WHERE ' || l_pkcol || ' = :pk';
    END IF;
    EXECUTE IMMEDIATE rec_delete USING l_record_id;
  END LOOP;
  log('Delete complete');
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_DELETE_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END delete_merged_records;

/*-------------------------------------------------------------------
| Function to fetch a record description
|--------------------------------------------------------------------*/

FUNCTION get_record_desc(
	p_record_pk 	IN	NUMBER,
	p_entity_name	IN	VARCHAR2,
	p_pk_col_name	IN	VARCHAR2,
	p_desc_col_name	IN	VARCHAR2,
        x_return_status IN OUT NOCOPY	VARCHAR2)
RETURN VARCHAR2 IS

rec_query VARCHAR2(2000);
l_desc    VARCHAR2(2000);

BEGIN

  IF p_desc_col_name = p_pk_col_name THEN
   RETURN TO_CHAR(p_record_pk);
  END IF;

   -- Counstruct dynamic SQL query to fetch description
--4500011

 IF (p_entity_name = 'HZ_PARTY_RELATIONSHIPS') THEN
  rec_query := 'SELECT hz_merge_util.get_party_reln_description(relationship_id) FROM HZ_RELATIONSHIPS'
               || ' WHERE RELATIONSHIP_ID = '|| ':pk'
	       || ' AND subject_table_name = ''HZ_PARTIES'' AND object_table_name = ''HZ_PARTIES'' AND directional_flag = ''F''';

 ELSE
  rec_query := 'SELECT ' || p_desc_col_name ||
               ' FROM ' || p_entity_name || ' WHERE ' ||
 	       p_pk_col_name || ' = :pk';
 END IF;

  -- Execute dynamic SQL query
  EXECUTE IMMEDIATE rec_query INTO l_desc USING p_record_pk;
  RETURN '"' || l_desc || '" (ID:' || p_record_pk || ')';
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_REC_DESC_ERROR');
    FND_MESSAGE.SET_TOKEN('ENTITY' ,p_entity_name);
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN NULL;
END get_record_desc;

/*------------------------------------------------------------------------------
| Function to fetch a record description
|------------------------------------------------------------------------------*/

FUNCTION get_record_desc_r(
        p_record_pk     IN      ROWID,
        p_entity_name   IN      VARCHAR2,
        p_desc_col_name IN      VARCHAR2,
        x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

rec_query VARCHAR2(2000);
l_desc    VARCHAR2(2000);

BEGIN

  IF p_desc_col_name IS NULL THEN
   RETURN p_record_pk;
  END IF;

  -- Construct dynamic SQL query to fetch description
  rec_query := 'SELECT ' || p_desc_col_name ||
               ' FROM ' || p_entity_name || ' WHERE ROWID  = :pk';

  -- Execute dynamic SQL query
  EXECUTE IMMEDIATE rec_query INTO l_desc USING p_record_pk;
  RETURN '"' || l_desc || '" (ROWID:' || p_record_pk || ')';
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_REC_DESC_ERROR');
    FND_MESSAGE.SET_TOKEN('ENTITY' ,p_entity_name);
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN NULL;
END get_record_desc_r;


/*------------------------------------------------------------------
| Procedure to execute the merge procedure using Dynamic SQL
|------------------------------------------------------------------*/

PROCEDURE  exec_merge(
        p_entity_name   IN      VARCHAR2,
        p_proc_name     IN      HZ_MERGE_DICTIONARY.PROCEDURE_NAME%TYPE,
        p_from_id       IN      NUMBER,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_par_from_id   IN      NUMBER,
        p_par_to_id     IN      NUMBER,
        p_parent_entity IN      HZ_MERGE_DICTIONARY.ENTITY_NAME%TYPE,
        p_batch_id      IN      NUMBER,
        p_batch_party_id IN     NUMBER,
        x_return_status IN OUT NOCOPY  VARCHAR2) IS

plsql_block VARCHAR2(400);
l_return_status VARCHAR2(30);
r NUMBER;

BEGIN

  l_return_status :=  FND_API.G_RET_STS_SUCCESS;
  IF p_proc_name <> g_cur_proc_name OR g_cur_proc_name IS NULL THEN
    IF g_cur_proc_name IS NOT NULL THEN
      dbms_sql.close_cursor(g_proc_cursor);
    END IF;
    g_cur_proc_name := p_proc_name;
    -- Create a dynamic SQL block to execute the merge procedure
    plsql_block := 'BEGIN '||
                 p_proc_name||'(:p_entity_name, :from_id,'||
                 ':to_id, :par_from_id,:par_to_id,:par_entity, :batch_id, '||
                 ':batch_party_id,:x_return_status);'||
                 'END;';

    g_proc_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(g_proc_cursor, plsql_block, 2);
  END IF;

  dbms_sql.bind_variable(g_proc_cursor, 'p_entity_name', p_entity_name);
  dbms_sql.bind_variable(g_proc_cursor, 'from_id', p_from_id);
  dbms_sql.bind_variable(g_proc_cursor, 'to_id', x_to_id);
  dbms_sql.bind_variable(g_proc_cursor, 'par_from_id', p_par_from_id);
  dbms_sql.bind_variable(g_proc_cursor, 'par_to_id', p_par_to_id);
  dbms_sql.bind_variable(g_proc_cursor, 'par_entity', p_parent_entity);
  dbms_sql.bind_variable(g_proc_cursor, 'batch_id', p_batch_id);
  dbms_sql.bind_variable(g_proc_cursor, 'batch_party_id', p_batch_party_id);
  dbms_sql.bind_variable(g_proc_cursor, 'x_return_status', l_return_status);
  r := dbms_sql.execute(g_proc_cursor);
  dbms_sql.variable_value(g_proc_cursor,'to_id',x_to_id);
  dbms_sql.variable_value(g_proc_cursor,'x_return_status',l_return_status);

  x_return_status := l_return_status;

/*
  l_return_status :=  FND_API.G_RET_STS_SUCCESS;
  -- Create a dynamic SQL block to execute the merge procedure
  plsql_block := 'BEGIN '||
                 p_proc_name||'(:p_entity_name, :from_id,'||
                 ':to_id, :par_from_id,:par_to_id,:par_entity, :batch_id, '||
                 ':batch_party_id,:x_return_status);'||
                 'END;';

  -- Execute the dynamic PLSQL block
  EXECUTE IMMEDIATE plsql_block USING
      p_entity_name, p_from_id, IN OUT NOCOPY x_to_id, p_par_from_id, p_par_to_id,
      p_parent_entity, p_batch_id,p_batch_party_id,IN OUT NOCOPY l_return_status;

  -- Set return status
  x_return_status := l_return_status;
*/

EXCEPTION
  WHEN OTHERS THEN
    log('');
    log('');
    log('****** Error executing merge procedure : ' || p_proc_name );
    log('for table : ' || p_entity_name);
    log('Data exists in table for the merge-to party. Aborting merge');
    log('');
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END exec_merge;

/*-----------------------------------------------------------------
| Procedure to execute the merge procedure using Dynamic SQL
|-----------------------------------------------------------------*/

PROCEDURE  exec_merge_r(
        p_entity_name   IN      VARCHAR2,
	p_proc_name	IN	HZ_MERGE_DICTIONARY.PROCEDURE_NAME%TYPE,
        p_from_id	IN	ROWID,
        x_to_id		IN OUT NOCOPY	ROWID,
        p_par_from_id	IN      NUMBER,
        p_par_to_id	IN	NUMBER,
        p_parent_entity	IN	HZ_MERGE_DICTIONARY.ENTITY_NAME%TYPE,
        p_batch_id	IN	NUMBER,
        p_batch_party_id IN     NUMBER,
        x_return_status IN OUT NOCOPY	VARCHAR2) IS

plsql_block VARCHAR2(400);
l_return_status VARCHAR2(30);
r NUMBER;

BEGIN

  l_return_status :=  FND_API.G_RET_STS_SUCCESS;
  IF p_proc_name <> g_cur_proc_name OR g_cur_proc_name IS NULL THEN
    IF g_cur_proc_name IS NOT NULL THEN
      dbms_sql.close_cursor(g_proc_cursor);
    END IF;
    g_cur_proc_name := p_proc_name;
    -- Create a dynamic SQL block to execute the merge procedure
    plsql_block := 'BEGIN '||
                 p_proc_name||'(:p_entity_name, :from_id,'||
                 ':to_id, :par_from_id,:par_to_id,:par_entity, :batch_id, '||
                 ':batch_party_id,:x_return_status);'||
                 'END;';

    g_proc_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(g_proc_cursor, plsql_block, 2);
  END IF;

  dbms_sql.bind_variable(g_proc_cursor, 'p_entity_name', p_entity_name);
  dbms_sql.bind_variable(g_proc_cursor, 'from_id', p_from_id);
  dbms_sql.bind_variable(g_proc_cursor, 'to_id', x_to_id);
  dbms_sql.bind_variable(g_proc_cursor, 'par_from_id', p_par_from_id);
  dbms_sql.bind_variable(g_proc_cursor, 'par_to_id', p_par_to_id);
  dbms_sql.bind_variable(g_proc_cursor, 'par_entity', p_parent_entity);
  dbms_sql.bind_variable(g_proc_cursor, 'batch_id', p_batch_id);
  dbms_sql.bind_variable(g_proc_cursor, 'batch_party_id', p_batch_party_id);
  dbms_sql.bind_variable(g_proc_cursor, 'x_return_status', l_return_status);
  r := dbms_sql.execute(g_proc_cursor);
  dbms_sql.variable_value(g_proc_cursor,'to_id',x_to_id);
  dbms_sql.variable_value(g_proc_cursor,'x_return_status',l_return_status);

  x_return_status := l_return_status;

/*
  l_return_status :=  FND_API.G_RET_STS_SUCCESS;
  -- Create a dynamic SQL block to execute the merge procedure
  plsql_block := 'BEGIN '||
                 p_proc_name||'(:p_entity_name, :from_id,'||
                 ':to_id, :par_from_id,:par_to_id,:par_entity, :batch_id, '||
                 ':batch_party_id,:x_return_status);'||
                 'END;';

  -- Execute the dynamic PLSQL block
  EXECUTE IMMEDIATE plsql_block USING
      p_entity_name, p_from_id, IN OUT NOCOPY x_to_id, p_par_from_id, p_par_to_id,
      p_parent_entity, p_batch_id,p_batch_party_id,IN OUT NOCOPY l_return_status;

  -- Set return status
  x_return_status := l_return_status;
*/

EXCEPTION
  WHEN OTHERS THEN
    log('');
    log('');
    log('****** Error executing merge procedure : ' || p_proc_name );
    log('for table : ' || p_entity_name);
    log('Data exists in table for the merge-to party. Aborting merge');
    log('');
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END exec_merge_r;

--bug 4634891 created overloaded procedure exec_merge
/*------------------------------------------------------------------
| Procedure to execute the batch merge procedure using Dynamic SQL
|------------------------------------------------------------------*/

PROCEDURE  exec_merge(
        p_entity_name   IN      VARCHAR2,
        p_proc_name     IN      VARCHAR2,
        p_batch_id      IN      NUMBER,
        p_request_id    IN      NUMBER,
        x_return_status IN OUT NOCOPY  VARCHAR2) IS

plsql_block VARCHAR2(400);
l_return_status VARCHAR2(30);
r NUMBER;

BEGIN

  l_return_status :=  FND_API.G_RET_STS_SUCCESS;
  IF p_proc_name <> g_cur_proc_name OR g_cur_proc_name IS NULL THEN
    IF g_cur_proc_name IS NOT NULL THEN
      dbms_sql.close_cursor(g_proc_cursor);
    END IF;
    g_cur_proc_name := p_proc_name;
    -- Create a dynamic SQL block to execute the merge procedure
    plsql_block := 'BEGIN '||
                 p_proc_name||'(:batch_id, '||
                 ':request_id,:x_return_status);'||
                 'END;';

    g_proc_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(g_proc_cursor, plsql_block, 2);
  END IF;


  dbms_sql.bind_variable(g_proc_cursor, 'batch_id', p_batch_id);
  dbms_sql.bind_variable(g_proc_cursor, 'request_id', p_request_id);
  dbms_sql.bind_variable(g_proc_cursor, 'x_return_status', l_return_status);
  r := dbms_sql.execute(g_proc_cursor);
  dbms_sql.variable_value(g_proc_cursor,'x_return_status',l_return_status);

  x_return_status := l_return_status;

EXCEPTION
  WHEN OTHERS THEN
    log('');
    log('');
    log('****** Error executing merge procedure : ' || p_proc_name );
    log('for table : ' || p_entity_name);
    log('Data exists in table for the merge-to party. Aborting merge');
    log('');
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END exec_merge;

/*------------------------------------------------------------------------
| Procedure to store merge history record
|------------------------------------------------------------------------*/

PROCEDURE store_merge_history(
	p_batch_party_id	IN	HZ_MERGE_PARTIES.BATCH_PARTY_ID%TYPE,
	p_from_id		IN	HZ_MERGE_PARTIES.FROM_PARTY_ID%TYPE,
	p_to_id			IN	HZ_MERGE_PARTIES.TO_PARTY_ID%TYPE,
	p_from_fk_id		IN	HZ_MERGE_PARTIES.TO_PARTY_ID%TYPE,
	p_to_fk_id		IN	HZ_MERGE_PARTIES.TO_PARTY_ID%TYPE,
	p_from_desc		IN	HZ_MERGE_PARTY_HISTORY.FROM_ENTITY_DESC%TYPE,
	p_to_desc		IN	HZ_MERGE_PARTY_HISTORY.TO_ENTITY_DESC%TYPE,
	p_merge_dict_id		IN	HZ_MERGE_DICTIONARY.MERGE_DICT_ID%TYPE,
	p_op_type		IN	HZ_MERGE_PARTY_HISTORY.OPERATION_TYPE%TYPE,
        p_flush 		IN	VARCHAR2 := 'N') IS

BEGIN

  IF p_flush <> 'Y' THEN
    -- Store in the log table
    store_merge_log(
        p_batch_party_id, p_from_id, p_to_id, p_from_fk_id, p_to_fk_id,
        p_from_desc, p_to_desc, p_merge_dict_id, p_op_type);
  END IF;

  IF H_Counter = 1000 OR p_flush = 'Y' THEN
    FORALL I IN 1..H_Counter
       -- Store in the history table
       INSERT INTO HZ_MERGE_PARTY_HISTORY(
              batch_party_id,
              request_id,
              from_entity_id,
              to_entity_id,
              from_parent_entity_id,
              to_parent_entity_id,
              from_entity_desc,
              to_entity_desc,
              merge_dict_id,
              operation_type,
              created_by,
              creation_date,
              last_update_login,
              last_update_date,
              last_updated_by)
        VALUES (
              H_batch_party_id(I),
              g_request_id,        -- Bug No : 2998004 hz_utility_pub.request_id,
              H_from_id(I),
              H_to_id(I),
              H_from_fk_id(I),
              H_to_fk_id(I),
              H_from_desc(I),
              H_to_desc(I),
              H_merge_dict_id(I),
              H_op_type(I),
              g_created_by,        -- hz_utility_pub.created_by,
              g_creation_date,     -- hz_utility_pub.creation_date,
              g_last_update_login, -- hz_utility_pub.last_update_login,
              g_last_update_date,  -- hz_utility_pub.last_update_date,
              g_user_id            -- hz_utility_pub.user_id
        );
    H_Counter := 0;
  END IF;
  IF p_flush = 'Y' THEN
    RETURN;
  END IF;

  H_Counter := H_Counter+1;
  H_batch_party_id(H_Counter) := p_batch_party_id;
  IF p_from_id=FND_API.G_MISS_NUM THEN
    H_from_id(H_Counter) := null;
  ELSE
    H_from_id(H_Counter) := p_from_id;
  END IF;
  IF p_to_id=FND_API.G_MISS_NUM THEN
    H_to_id(H_Counter) := null;
  ELSE
    H_to_id(H_Counter) := p_to_id;
  END IF;
  IF p_from_fk_id=FND_API.G_MISS_NUM THEN
    H_from_fk_id(H_Counter) := null;
  ELSE
    H_from_fk_id(H_Counter) := p_from_fk_id;
  END IF;
  IF p_to_fk_id=FND_API.G_MISS_NUM THEN
    H_to_fk_id(H_Counter) := null;
  ELSE
    H_to_fk_id(H_Counter) := p_to_fk_id;
  END IF;
  H_from_desc(H_Counter) := p_from_desc;
  H_to_desc(H_Counter) := p_to_desc;
  H_merge_dict_id(H_Counter) := p_merge_dict_id;
  H_op_type(H_Counter) := p_op_type;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
END store_merge_history;

/*---------------------------------------------------------------------------
| Procedure to store the merge procedure in the log table.
| Executes in an autonomous transaction since we always want this to
| be commited irrespective of the merge mode or result
|---------------------------------------------------------------------------*/

PROCEDURE store_merge_log(
	p_batch_party_id	IN	HZ_MERGE_PARTIES.BATCH_PARTY_ID%TYPE,
	p_from_id		IN	HZ_MERGE_PARTIES.FROM_PARTY_ID%TYPE,
	p_to_id			IN	HZ_MERGE_PARTIES.TO_PARTY_ID%TYPE,
	p_from_fk_id		IN	HZ_MERGE_PARTIES.TO_PARTY_ID%TYPE,
	p_to_fk_id		IN	HZ_MERGE_PARTIES.TO_PARTY_ID%TYPE,
	p_from_desc		IN	HZ_MERGE_PARTY_HISTORY.FROM_ENTITY_DESC%TYPE,
	p_to_desc		IN	HZ_MERGE_PARTY_HISTORY.TO_ENTITY_DESC%TYPE,
	p_merge_dict_id		IN	HZ_MERGE_DICTIONARY.MERGE_DICT_ID%TYPE,
	p_op_type		IN	HZ_MERGE_PARTY_LOG.OPERATION_TYPE%TYPE,
	p_error			IN	HZ_MERGE_PARTY_LOG.ERROR_MESSAGES%TYPE
				DEFAULT NULL,
        p_flush                 IN      VARCHAR2 := 'N') IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF I_Counter = 1000 OR p_flush = 'Y' THEN
    FORALL I IN 1..I_Counter
      -- Insert inyo the log table
      INSERT INTO HZ_MERGE_PARTY_LOG(
	batch_party_id,
	request_id,
	from_entity_id,
	to_entity_id,
	from_parent_entity_id,
	to_parent_entity_id,
	from_entity_desc,
	to_entity_desc,
	merge_dict_id,
	error_messages,
	operation_type,
	created_by,
	creation_date,
	last_update_login,
	last_update_date,
	last_updated_by)
      VALUES (
	I_batch_party_id(I),
        g_request_id,          -- Bug No : 2998004 hz_utility_pub.request_id,
        I_from_id(I),
        I_to_id(I),
        I_from_fk_id(I),
        I_to_fk_id(I),
	I_from_desc(I),
	I_to_desc(I),
	I_merge_dict_id(I),
	I_error(I),
	I_op_type(I),
        g_created_by,         -- hz_utility_pub.created_by,
	g_creation_date,      -- hz_utility_pub.creation_date,
	g_last_update_login,  -- hz_utility_pub.last_update_login,
	g_last_update_date,   -- hz_utility_pub.last_update_date,
	g_user_id             -- hz_utility_pub.user_id
	);

    I_Counter := 0;
    -- Commit the log entry
    COMMIT;
  END IF;

  I_Counter := I_Counter+1;
  I_batch_party_id(I_Counter) := p_batch_party_id;
  IF p_from_id=FND_API.G_MISS_NUM THEN
    I_from_id(I_Counter) := null;
  ELSE
    I_from_id(I_Counter) := p_from_id;
  END IF;
  IF p_to_id=FND_API.G_MISS_NUM THEN
    I_to_id(I_Counter) := null;
  ELSE
    I_to_id(I_Counter) := p_to_id;
  END IF;
  IF p_from_fk_id=FND_API.G_MISS_NUM THEN
    I_from_fk_id(I_Counter) := null;
  ELSE
    I_from_fk_id(I_Counter) := p_from_fk_id;
  END IF;
  IF p_to_fk_id=FND_API.G_MISS_NUM THEN
    I_to_fk_id(I_Counter) := null;
  ELSE
    I_to_fk_id(I_Counter) := p_to_fk_id;
  END IF;

  I_from_desc(I_Counter) := p_from_desc;
  I_to_desc(I_Counter) := p_to_desc;
  I_merge_dict_id(I_Counter) := p_merge_dict_id;
  I_op_type(I_Counter) := p_op_type;
  I_error(I_Counter) := p_error;

EXCEPTION
  WHEN OTHERS THEN
    -- ROLLBACK to batch_merge;
    ROLLBACK; -- bug 3947633
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
END store_merge_log;

/*---------------------------------------------------------------------------
| Procedure to write a message to the out NOCOPY file
|----------------------------------------------------------------------------*/

PROCEDURE out(
   message 	IN	VARCHAR2,
   newline	IN	BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF message = 'NEWLINE' THEN
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.output,message);
  ELSE
    FND_FILE.put(fnd_file.output,message);
  END IF;
END out;

/*------------------------------------------------------------------------
| Procedure to write a message to the log file
|------------------------------------------------------------------------*/

PROCEDURE log(
   message 	IN	VARCHAR2,
   newline	IN	BOOLEAN DEFAULT TRUE) IS
BEGIN

  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put(fnd_file.log,message);
  END IF;
END log;

/*------------------------------------------------------------------------
| Procedure to write a message to the out NOCOPY and log files
|-------------------------------------------------------------------------*/

PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  out(message, newline);
  log(message, newline);
END outandlog;

/*--------------------------------------------------------------------------
| NAME: pre_merge
| PARAMETERS: p_to_party_id IN NUMBER and p_batch_id IN NUMBER
| DESCRIPTION: This procedure transfers the party site, contacts and
|              contact points  to the to_party_id from the from party if
|              the from party is getting transferred and the another record
|              is merging into that record.
----------------------------------------------------------------------------*/
PROCEDURE pre_merge(
   p_to_party_id IN NUMBER,
   p_batch_id    IN NUMBER) IS

 CURSOR pre_batch(cp_batch_id NUMBER) IS
    SELECT batch_name, rule_set_name ,batch_status, batch_delete, batch_commit
    FROM HZ_MERGE_BATCH
    WHERE batch_id = cp_batch_id;


 CURSOR party_sites_for_pre_merge(cp_to_party_id IN NUMBER, cp_batch_id IN NUMBER) IS
  select merge_to_entity_id, p.from_party_id, p.batch_party_id
  from hz_merge_party_details d1, hz_merge_parties p
  where entity_name = 'HZ_PARTY_SITES'
  and p.batch_party_id = d1.batch_party_id
  and d1.batch_party_id IN ( select batch_party_id
                          from hz_merge_parties
                          where to_party_id = cp_to_party_id
                          and to_party_id<>from_party_id
                          and batch_id      = cp_batch_id)
  and merge_from_entity_id = merge_to_entity_id   --transfer operation
  and exists (                                    --it should be a merge-to
              select 1                            --for another mapping
              from hz_merge_party_details d2
              where d2.merge_to_entity_id = d1.merge_from_entity_id
              and d2.entity_name = 'HZ_PARTY_SITES'
              and batch_party_id IN ( select batch_party_id
                                      from hz_merge_parties
                                      where to_party_id = cp_to_party_id
                                      and to_party_id<>from_party_id
                                      and batch_id      = cp_batch_id)
             and  d2.merge_from_entity_id <> d1.merge_to_entity_id );

CURSOR rel_for_pre_merge(cp_to_party_id IN NUMBER, cp_batch_id IN NUMBER) IS
  select merge_to_entity_id, p.from_party_id, p.batch_party_id
  from hz_merge_party_details d1, hz_merge_parties p
  where entity_name = 'HZ_PARTY_RELATIONSHIPS'
  and p.batch_party_id = d1.batch_party_id
  and d1.batch_party_id IN ( select batch_party_id
                          from hz_merge_parties
                          where to_party_id = cp_to_party_id
                          and to_party_id<>from_party_id
                          and batch_id      = cp_batch_id)
  and merge_from_entity_id = merge_to_entity_id --transfer operation
  and exists (                                  --it should be a merge-to
              select 1                          --for another mapping
              from hz_merge_party_details d2
              where d2.merge_to_entity_id = d1.merge_from_entity_id
              and d2.entity_name = 'HZ_PARTY_RELATIONSHIPS'
              and batch_party_id IN (
                                     select batch_party_id
                                     from hz_merge_parties
                                     where to_party_id = cp_to_party_id
                                     and to_party_id<>from_party_id
                                     and batch_id      = cp_batch_id)
             and  d2.merge_from_entity_id <> d1.merge_to_entity_id );

  l_batch_name          HZ_MERGE_BATCH.BATCH_NAME%TYPE;
  l_rule_set_name       HZ_MERGE_BATCH.RULE_SET_NAME%TYPE;
  l_batch_status        HZ_MERGE_BATCH.BATCH_STATUS%TYPE;
  l_merge_status        HZ_MERGE_PARTIES.MERGE_STATUS%TYPE;

  l_batch_commit        HZ_MERGE_BATCH.BATCH_COMMIT%TYPE;
  l_batch_delete        HZ_MERGE_BATCH.BATCH_DELETE%TYPE;

  l_batch_party_id      HZ_MERGE_PARTIES.BATCH_PARTY_ID%TYPE;
  l_from_id       HZ_MERGE_PARTIES.FROM_PARTY_ID%TYPE;
  l_merge_to_entity_id  hz_merge_party_details.merge_to_entity_id%TYPE;
  l_new_party_site_id   hz_party_sites.party_site_id%type;
  l_proc_name           hz_merge_dictionary.procedure_name%type;
  l_subject_id          HZ_RELATIONSHIPS.SUBJECT_ID%TYPE;
  l_object_id           HZ_RELATIONSHIPS.OBJECT_ID%TYPE;

  l_return_status       VARCHAR2(200);

  l_from_party_id NUMBER;
  l_from_rec_desc varchar2(2000);
  l_to_rec_desc   varchar2(2000);
  pre_return_status       VARCHAR2(200);
  pre_log_padding         VARCHAR2(2000) := ' ';

  l_merge_dict_id NUMBER;

BEGIN

  --- Open the batch cursor and fetch batch details---
  OPEN pre_batch(p_batch_id);
  FETCH pre_batch INTO l_batch_name, l_rule_set_name,
                       l_batch_status, l_batch_delete,l_batch_commit;
  IF (pre_batch%NOTFOUND) THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_BATCH_NOTFOUND');
    FND_MESSAGE.SET_TOKEN('BATCHID', p_batch_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE pre_batch;

   --Initialise the log variables
   l_from_rec_desc := null;
   l_to_rec_desc   := null;
   pre_return_status := null;
   pre_log_padding := ' ';


   ----------Pre merge for HZ_PARTY_SITES ---------------
   OPEN party_sites_for_pre_merge(p_to_party_id , p_batch_id);
   LOOP
     l_return_status := FND_API.G_RET_STS_SUCCESS;
     FETCH party_sites_for_pre_merge INTO l_merge_to_entity_id, l_from_party_id, l_batch_party_id;
     EXIT WHEN party_sites_for_pre_merge%NOTFOUND;
     l_new_party_site_id := l_merge_to_entity_id;
     IF l_merge_to_entity_id IS NOT NULL THEN

       l_proc_name :=  'HZ_MERGE_PKG.party_site_merge';
       g_cur_merge_dict_id := 0;
       g_num_sub_entities :=-1;

       l_from_rec_desc :=hz_merge_util.get_party_site_description(l_merge_to_entity_id);

       -- Execute the merge procedure for the entity
       exec_merge(
            p_entity_name =>  'HZ_PARTY_SITES',
            p_proc_name   =>  l_proc_name,
            p_from_id     =>   l_merge_to_entity_id,
            x_to_id       =>   l_new_party_site_id,
            p_par_from_id =>   l_from_party_id,
            p_par_to_id   =>   p_to_party_id,
            p_parent_entity => 'HZ_PARTIES',
            p_batch_id      => p_batch_id,
            p_batch_party_id=>   l_batch_party_id,
            x_return_status => l_return_status);


       -- Check if the merge procedure returned an error
       IF (l_return_status = FND_API.G_RET_STS_SUCCESS OR
           l_return_status = 'N' ) THEN
         IF l_new_party_site_id <> 0 THEN

           -- Write to log file
           log('Pre Merge: '|| l_from_rec_desc ||' copied to ID:' || l_new_party_site_id );
         ELSE
           log('Pre Merge: '|| l_from_rec_desc ||'discarded (DNB data) ');
         END IF;

       ELSE
         RAISE FND_API.G_EXC_ERROR;
       END IF;

      -- set the party sites status to A so that it is picked in merge that follows
      --the hz_merge_pkg.do_party_site_merge sets it to 'M' in pre-merge
       UPDATE HZ_PARTY_SITES
       SET
         STATUS = 'A',
         last_update_date = hz_utility_pub.last_update_date,
         last_updated_by = hz_utility_pub.user_id,
         last_update_login = hz_utility_pub.last_update_login,
         request_id =  hz_utility_pub.request_id,
         program_application_id = hz_utility_pub.program_application_id,
         program_id = hz_utility_pub.program_id,
         program_update_date = sysdate
       WHERE party_site_id = l_merge_to_entity_id;


       UPDATE hz_merge_party_details
       set merge_to_entity_id = l_new_party_site_id
       where batch_party_id IN (select batch_party_id from hz_merge_parties
                                where batch_id = p_batch_id)
       and merge_to_entity_id = l_merge_to_entity_id
       and entity_name = 'HZ_PARTY_SITES';

       UPDATE hz_merge_party_details
       set mandatory_merge = 'C'
       where batch_party_id IN (select batch_party_id from hz_merge_parties
                                where batch_id = p_batch_id)
       and merge_from_entity_id = l_merge_to_entity_id
       and merge_to_entity_id = l_new_party_site_id
       and entity_name = 'HZ_PARTY_SITES';

    END IF;
   END LOOP;

   l_return_status := FND_API.G_RET_STS_SUCCESS;
   ----------Pre merge for HZ_RELATIONSHIPS ---------------

   --Initialise the log variables
   l_from_rec_desc := null;
   l_to_rec_desc   := null;

   OPEN rel_for_pre_merge(p_to_party_id , p_batch_id);
   LOOP
   BEGIN
     FETCH rel_for_pre_merge INTO l_merge_to_entity_id, l_from_party_id, l_batch_party_id;
     EXIT WHEN rel_for_pre_merge%NOTFOUND;

     IF l_merge_to_entity_id IS NOT NULL THEN

       ----subject object stuff------
       select subject_id , object_id
       into l_subject_id , l_object_id
       from HZ_RELATIONSHIPS --4500011
       where relationship_id = l_merge_to_entity_id
       and subject_table_name = 'HZ_PARTIES'
       and object_table_name = 'HZ_PARTIES'
       and directional_flag = 'F';

       if l_subject_id = l_from_party_id then
         l_proc_name :=  'HZ_MERGE_PKG.party_reln_subject_merge';
         l_merge_dict_id := 8;
       elsif l_object_id = l_from_party_id then
         l_proc_name :=  'HZ_MERGE_PKG.party_reln_object_merge';
         l_merge_dict_id := 6;
       else
         l_proc_name := null;
       end if;


       g_cur_merge_dict_id := 0;
       g_num_sub_entities :=-1;

       IF l_proc_name IS NOT NULL THEN

         -- Execute the merge procedure for the entity
         exec_merge(
             p_entity_name =>  'HZ_PARTY_RELATIONSHIPS',
             p_proc_name   =>   l_proc_name,
             p_from_id     =>   l_merge_to_entity_id,
             x_to_id       =>   l_merge_to_entity_id,
             p_par_from_id =>   l_from_party_id,
             p_par_to_id   =>   p_to_party_id,
             p_parent_entity => 'HZ_PARTIES',
             p_batch_id      => p_batch_id,
             p_batch_party_id=> l_batch_party_id,
             x_return_status => l_return_status);

         l_from_rec_desc := hz_merge_util.get_party_reln_description(l_merge_to_entity_id);

         -- Check if the merge procedure returned an error
         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            -- Write to log file
            store_merge_history(l_batch_party_id, l_merge_to_entity_id ,
                                l_merge_to_entity_id,l_from_party_id, p_to_party_id,l_from_rec_desc,
                                null, l_merge_dict_id, 'Transfer');
            -- Write to log file
            IF l_subject_id = l_from_party_id THEN
              log('Pre Merge : '||l_from_rec_desc||' transferred subject ID to ' || p_to_party_id);
            ELSIF l_object_id = l_from_party_id THEN
              log('Pre Merge : '||l_from_rec_desc||' transferred object ID to ' || p_to_party_id);
            END IF;

         ELSE
           -- Log the error in the table and return
           store_merge_log(l_batch_party_id, l_merge_to_entity_id,
                           l_merge_to_entity_id,l_from_party_id, p_to_party_id,
                           l_from_rec_desc,null,
                           l_merge_dict_id, 'Error', logerror);
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF; --l_proc_name
    END IF; --l_merge_to_entity_id


    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    exit;

    END;
    END LOOP;


END pre_merge;


/*-----------------------------------------------------------------------
| Function to fetch messages of the stack and log the error
| Also returns the error
|-----------------------------------------------------------------------*/
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

/*-----------------------------------------------------------------------
| Procedure for vetoing the delete
|-----------------------------------------------------------------------*/

PROCEDURE veto_delete IS

BEGIN
  IF g_merge_delete_flag = 'Y' THEN
    g_merge_delete_flag := 'N';
  END IF;
END veto_delete;

PROCEDURE get_merge_to_record_id
(
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2:=FND_API.G_FALSE,
        p_record_id                     IN      NUMBER,
        p_entity_name                   IN      VARCHAR2,
        x_is_merged                     OUT NOCOPY     VARCHAR2,
        x_merge_to_record_id            OUT NOCOPY     NUMBER,
        x_merge_to_record_desc          OUT NOCOPY     VARCHAR2,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2
) IS

  CURSOR c_merge_to_rec (cp_merge_from_id NUMBER) IS
    SELECT mh.TO_ENTITY_ID, mh.TO_ENTITY_DESC
    FROM HZ_MERGE_PARTY_HISTORY mh, HZ_MERGE_DICTIONARY md
    WHERE mh.merge_dict_id = md.merge_dict_id
    AND md.entity_name = p_entity_name
    AND mh.from_entity_id = cp_merge_from_id;

  l_api_name    CONSTANT        VARCHAR2(30) := 'get_merge_to_record_id';
  l_api_version CONSTANT        NUMBER       := 1.0;
  l_merge_to_id                 NUMBER;
  l_merge_to_desc               HZ_MERGE_PARTY_HISTORY.TO_ENTITY_DESC%TYPE;

BEGIN

--Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
               l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

--Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_merge_to_id := p_record_id;

  LOOP
    OPEN c_merge_to_rec(l_merge_to_id);
    FETCH c_merge_to_rec INTO l_merge_to_id, l_merge_to_desc;
    EXIT WHEN c_merge_to_rec%NOTFOUND;
    CLOSE c_merge_to_rec;
  END LOOP;
  CLOSE c_merge_to_rec;

  IF l_merge_to_id <> p_record_id THEN
    x_merge_to_record_id := l_merge_to_id;
    x_merge_to_record_desc := l_merge_to_desc;
    x_is_merged := FND_API.G_TRUE;
  ELSE
    x_is_merged := FND_API.G_FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;

    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
END get_merge_to_record_id;

/*-----------------------------------------------------------------------
| FUNCTION alternate_get_col_type
|-----------------------------------------------------------------------*/
FUNCTION alternate_get_col_type(
    p_table		VARCHAR2,
	p_column	VARCHAR2)
  RETURN VARCHAR2 IS

  c number;
  d number;
  col_cnt integer;
  f boolean;
  rec_tab dbms_sql.desc_tab;
  col_num number;
  dtype VARCHAR2(255);

BEGIN
   c := dbms_sql.open_cursor;
   dbms_sql.parse(c, 'select '||p_column||' from '||p_table, dbms_sql.NATIVE);
   d := dbms_sql.execute(c);
   dbms_sql.describe_columns(c, col_cnt, rec_tab);
   IF rec_tab(1).col_type = 1 THEN
     dtype:='VARCHAR2';
   ELSIF rec_tab(1).col_type = 2 THEN
    dtype:='NUMBER';
   ELSIF rec_tab(1).col_type = 12 THEN
    dtype:='DATE';
   END IF;
   dbms_sql.close_cursor(c);

   RETURN dtype;
 EXCEPTION
  WHEN OTHERS THEN
   /* FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;*/
    RETURN NULL;
END;

/*-----------------------------------------------------------------------
| FUNCTION get_col_type
|-----------------------------------------------------------------------*/
FUNCTION get_col_type(
	p_table		VARCHAR2,
	p_column	VARCHAR2,
    p_app_name  VARCHAR2)
  RETURN VARCHAR2 IS

CURSOR data_type(l_schema1 VARCHAR2) IS
   SELECT DATA_TYPE FROM sys.all_tab_columns
   WHERE table_name = p_table
   AND COLUMN_NAME = p_column and owner = l_schema1;

l_data_type VARCHAR2(106);
l_bool BOOLEAN;
  l_status VARCHAR2(255);
  l_schema VARCHAR2(255);
  l_tmp    VARCHAR2(2000);

BEGIN

 l_bool := fnd_installation.GET_APP_INFO(p_app_name,l_status,l_tmp,l_schema);

  OPEN data_type(l_schema);
  FETCH data_type INTO l_data_type;
  IF data_type%NOTFOUND THEN
    CLOSE data_type;
     RETURN alternate_get_col_type(p_table,p_column);
  END IF;
  CLOSE data_type;

  RETURN l_data_type;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
END get_col_type;


/*-----------------------------------------------------------------------
| PROCEDURE check_party_in_merge_batch
|-----------------------------------------------------------------------*/

PROCEDURE check_party_in_merge_batch
(
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2:=FND_API.G_FALSE,
        p_party_id                      IN      NUMBER,
        x_in_merge                      OUT NOCOPY     VARCHAR2,
        x_batch_id                      OUT NOCOPY     NUMBER,
        x_batch_name                    OUT NOCOPY     VARCHAR2,
        x_batch_created_by              OUT NOCOPY     VARCHAR2,
        x_batch_creation_date           OUT NOCOPY     DATE,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2
) IS

  CURSOR c_merge_batch IS
	SELECT b.batch_id, b.batch_name, b.created_by, b.creation_date
	FROM HZ_MERGE_PARTIES p, HZ_MERGE_BATCH b
	WHERE b.batch_id = p.batch_id
        AND b.batch_status <> 'COMPLETE'
        AND (p.from_party_id = p_party_id
	     OR p.to_party_id = p_party_id);

  l_api_name    CONSTANT        VARCHAR2(30) := 'check_party_in_merge_batch';
  l_api_version CONSTANT        NUMBER       := 1.0;

  l_batch_id NUMBER;
  l_batch_name VARCHAR2(200);
  l_batch_created_by NUMBER;
  l_batch_created_on DATE;

BEGIN

--Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
               l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

--Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_in_merge := FND_API.G_FALSE;

  OPEN c_merge_batch;
  FETCH c_merge_batch INTO l_batch_id, l_batch_name, l_batch_created_by,
                           l_batch_created_on;
  IF c_merge_batch%FOUND THEN
    x_batch_id := l_batch_id;
    x_batch_name := l_batch_name;
    x_batch_created_by := l_batch_created_by;
    x_batch_creation_date := l_batch_created_on;
    x_in_merge := FND_API.G_TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;

    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
END check_party_in_merge_batch;


PROCEDURE setup_dnb_data(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id    	IN OUT NOCOPY  NUMBER,
        p_batch_party_id IN	NUMBER
) IS

CURSOR c_party_type(cp_party_id NUMBER) IS
  SELECT party_type
  FROM HZ_PARTIES
  WHERE party_id = cp_party_id;

CURSOR c_duns IS
  SELECT duns_number_c, last_update_date, organization_profile_id,actual_content_source
  FROM HZ_ORGANIZATION_PROFILES
  WHERE party_id = p_from_id
  AND   EFFECTIVE_END_DATE IS NULL
  AND   actual_content_source = 'DNB'
  AND   nvl(status, 'A') = 'A';

CURSOR c_duns1 IS
  SELECT duns_number_c , last_update_date, organization_profile_id,actual_content_source
  FROM HZ_ORGANIZATION_PROFILES
  WHERE party_id = x_to_id
  AND   EFFECTIVE_END_DATE IS NULL
  AND   actual_content_source = 'DNB'
  AND   nvl(status, 'A') = 'A';

CURSOR c_branch IS
   SELECT 1
   FROM HZ_RELATIONSHIPS           --4500011
   WHERE content_source_type = 'DNB'
   AND subject_id = p_from_id
   AND object_id = x_to_id
   AND RELATIONSHIP_CODE = 'HEADQUARTERS_OF'
   AND subject_table_name = 'HZ_PARTIES'
   AND object_table_name = 'HZ_PARTIES'
   AND directional_flag = 'F';

l_from_party_type HZ_PARTIES.PARTY_TYPE%TYPE;
l_to_party_type HZ_PARTIES.PARTY_TYPE%TYPE;
l_from_duns_number VARCHAR2(255);
l_to_duns_number VARCHAR2(255);
l_temp NUMBER;

l_to_is_branch VARCHAR2(1) := 'N';

case1 BOOLEAN := FALSE;
case2 BOOLEAN := FALSE;
case3 BOOLEAN := FALSE;
case_new VARCHAR2(5) := 'FALSE';

l_from NUMBER;
l_to NUMBER;
l_to_loc_id NUMBER;
l_to_subj_id NUMBER;

l_to_profile_id NUMBER;
l_from_profile_id NUMBER;
l_from_last_upd_date DATE;
l_to_last_upd_date DATE;

l_msg_data VARCHAR2(2000);
l_msg_count NUMBER;
l_return_status VARCHAR2(255);
l_actual_content_source VARCHAR2(2000);
l_obj_version_number NUMBER;
l_rel_to_party_id NUMBER;
l_organization_rec HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
l_batch_party_id NUMBER;
l_batch_id NUMBER;

--5404244
CURSOR c_check_duplicates(from_subject_id number,from_start_date date, from_end_date date, from_rel_code varchar2, from_directional_flag varchar2) IS
  SELECT relationship_id, party_id
  FROM   HZ_RELATIONSHIPS
  WHERE  object_id = x_to_id
  AND actual_content_source = 'USER_ENTERED'
  AND subject_id = from_subject_id
  AND subject_id NOT IN
  ((SELECT from_party_id FROM hz_merge_parties WHERE to_party_id = x_to_id AND merge_status='PENDING' )) --bug 4867151
  AND subject_id NOT IN
  ((SELECT to_party_id FROM hz_merge_parties WHERE to_party_id = x_to_id AND merge_status='PENDING' )) --bug 4867151
  AND relationship_code = from_rel_code
  AND DIRECTIONAL_FLAG = from_directional_flag
  AND ((start_date between from_start_date and from_end_date)
          or (nvl(end_date,to_date('12/31/4712','MM/DD/YYYY')) between from_start_date and from_end_date)
          or(start_date<from_start_date and nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))>from_end_date))
  AND status IN ('A','I');

BEGIN

  -- Handle DNB Data in the parties

  -- Firstly check how DNB data needs to be handled.
  -- case1 or case2 or case3 -> both parties have DNB data
  -- case1 - FROM has newer DNB
  -- case2 - TO has newer DNB
  -- case3 - TO and FROM have different DUNS numbers
  -- l_to_is_branch - TO is a branch of FROM

  OPEN c_duns;
  FETCH c_duns INTO l_from_duns_number, l_from_last_upd_date, l_from_profile_id,l_actual_content_source;
  IF c_duns%FOUND THEN
    OPEN c_duns1;
    FETCH c_duns1 INTO l_to_duns_number, l_to_last_upd_date, l_to_profile_id,l_actual_content_source;
    IF c_duns1%FOUND THEN
      IF l_from_duns_number = l_to_duns_number THEN
        IF l_to_last_upd_date>=l_from_last_upd_date THEN -- Case 2
          case2 := true;
        ELSE
          case1 := true;
        END IF;
      ELSE
        case3 := true;

        OPEN c_branch;
        FETCH c_branch INTO l_temp;
        IF c_branch%FOUND THEN
          l_to_is_branch := 'Y';
        END IF;
        CLOSE c_branch;

      END IF;
    END IF;
    CLOSE c_duns1;
  END IF;
  CLOSE c_duns;

  -- IF both parties have DNB data, populate HZ_MERGE_PARTY_DETAILS to
  -- indicate how the DNB data needs to be handled.
  if case1 OR case2 OR case3 THEN

     -- *******************************************
     -- Handle DNB data in HZ_ORGANIZATION_PROFILES

     IF case1 OR (case3 and l_to_is_branch = 'Y') THEN
       HZ_PARTY_V2PUB.get_organization_rec(
         FND_API.G_FALSE,
         p_from_id,
         'DNB',
         l_organization_rec,
         l_return_status,
         l_msg_count,
         l_msg_data);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF l_msg_data IS NULL THEN
             FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
               l_msg_data := l_msg_data ||
                    FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
             END LOOP;
         END IF;
         RETURN;
       END IF;

       SELECT object_version_number INTO l_obj_version_number
       FROM HZ_PARTIES
       WHERE party_id = x_to_id;

       l_organization_rec.party_rec.party_id := x_to_id;
       l_organization_rec.created_by_module := NULL;
       l_organization_rec.application_id := NULL;
       l_organization_rec.party_rec.party_number := NULL;
       l_organization_rec.party_rec.orig_system_reference := NULL;
       HZ_PARTY_V2PUB.update_organization(
         FND_API.G_FALSE,
         l_organization_rec,
         l_obj_version_number,
         l_to_profile_id,
         l_return_status,
         l_msg_count,
         l_msg_data);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF l_msg_data IS NULL THEN
             FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
               l_msg_data := l_msg_data ||
                    FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
             END LOOP;
         END IF;
         FND_FILE.put_line (FND_FILE.log,'Warning .. Error updating Org Profile of x_to_id ' || l_msg_data);
         -- Bug Fix : 3116262.
         --RETURN;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

     END IF;

     HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
                p_batch_party_id,
                'HZ_ORGANIZATION_PROFILES',
                l_from_profile_id,
                l_to_profile_id,
                'Y',
                hz_utility_pub.created_by,
                hz_utility_pub.creation_Date,
                hz_utility_pub.last_update_login,
                hz_utility_pub.last_update_date,
                hz_utility_pub.last_updated_by);



     -- *******************************************
     -- Handle DNB data in HZ_PARTY_SITES/HZ_LOCATIONS

     -- Keep to's data.
     -- Inactivate the from's active party site.
     IF case2 OR (case3 and l_to_is_branch<>'Y') THEN
       UPDATE HZ_PARTY_SITES ps
       SET STATUS = 'I',
         end_date_active = trunc(SYSDATE-1),
         last_update_date = hz_utility_pub.last_update_date,
         last_updated_by = hz_utility_pub.user_id,
         last_update_login = hz_utility_pub.last_update_login,
         request_id =  hz_utility_pub.request_id,
         program_application_id = hz_utility_pub.program_application_id,
         program_id = hz_utility_pub.program_id,
         program_update_date = sysdate
       WHERE party_id= p_from_id
       AND actual_content_source = 'DNB'
       AND nvl(status,'A') = 'A';
     END IF;

     FOR FROM_PS IN (
       SELECT party_site_id, ps.location_id, end_date_active
       FROM HZ_PARTY_SITES ps
       WHERE actual_content_source = 'DNB'
       AND ps.party_id = p_from_id) LOOP


       IF FROM_PS.end_date_active IS NULL THEN
         -- (Will only hold for case1 OR (case3 and l_to_is_branch = 'Y')
         BEGIN
           SELECT party_site_id, location_id INTO l_to, l_to_loc_id
           FROM (SELECT party_site_id, ps.location_id
                 FROM HZ_PARTY_SITES ps
                 WHERE actual_content_source = 'DNB'
                 AND ps.party_id = x_to_id
                 AND end_date_active is null
                 AND nvl(status,'A')='A'
                 ORDER BY decode(ps.location_id,FROM_PS.location_id,1,2))
           WHERE rownum = 1;

           IF l_to_loc_id = FROM_PS.location_id THEN
             -- Merge to_ps to from_ps
             HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
                p_batch_party_id,
                'HZ_PARTY_SITES',
                l_to,
                FROM_PS.party_site_id,
                'T',
                hz_utility_pub.created_by,
                hz_utility_pub.creation_Date,
                hz_utility_pub.last_update_login,
                hz_utility_pub.last_update_date,
                hz_utility_pub.last_updated_by);
           ELSE
   -- Do the exact comparison betn the from_dnb_ps and to_dnb ps.
-- If exactly same: merge to into from
               BEGIN
               Select 'True' into case_new
                 FROM HZ_PARTY_SITES ps,HZ_LOCATIONS l
                     WHERE ps.party_site_id = FROM_PS.party_site_id
                     AND ps.location_id = FROM_PS.location_id
                     AND l.location_id = ps.location_id
                     AND (ps.status IS NULL OR ps.status = 'A')
                     AND UPPER(TRIM(ADDRESS1) ||
                               TRIM(ADDRESS2) ||
                               TRIM(ADDRESS3) ||
                               TRIM(ADDRESS4) ||
                               TRIM(COUNTRY)  ||
                               TRIM(STATE)    ||
                               TRIM(CITY)     ||
                               TRIM(PROVINCE) ||
                               TRIM(COUNTY)   ||
                               TRIM(POSTAL_CODE)) =
                 (SELECT UPPER(TRIM(ADDRESS1) ||
                               TRIM(ADDRESS2) ||
                               TRIM(ADDRESS3) ||
                               TRIM(ADDRESS4) ||
                               TRIM(COUNTRY)  ||
                               TRIM(STATE)    ||
                               TRIM(CITY)     ||
                               TRIM(PROVINCE) ||
                               TRIM(COUNTY)   ||
                               TRIM(POSTAL_CODE))
	       FROM HZ_LOCATIONS
	       WHERE LOCATION_ID = l_to_loc_id) AND rownum =1;
         EXCEPTION
         WHEN No_Data_Found   THEN
         NULL;
         END;

 IF case_new = 'True' THEN
               HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
                p_batch_party_id,
                'HZ_PARTY_SITES',
                l_to,
                FROM_PS.party_site_id,
                'T',
                hz_utility_pub.created_by,
                hz_utility_pub.creation_Date,
                hz_utility_pub.last_update_login,
                hz_utility_pub.last_update_date,
                hz_utility_pub.last_updated_by);
 ELSE
 UPDATE HZ_PARTY_SITES
             SET actual_content_source = 'USER_ENTERED',
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               request_id =  hz_utility_pub.request_id,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
              WHERE party_site_id = l_to;
----Inactivating SSM Record
    UPDATE HZ_ORIG_SYS_REFERENCES
        SET STATUS = 'I',
        END_DATE_ACTIVE =trunc(SYSDATE-1),
        last_update_date = hz_utility_pub.last_update_date,
        last_updated_by = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        request_id =  hz_utility_pub.request_id,
        program_application_id = hz_utility_pub.program_application_id,
        program_id = hz_utility_pub.program_id,
        program_update_date = sysdate
        WHERE OWNER_TABLE_NAME = 'HZ_PARTY_SITES'
        AND OWNER_TABLE_ID = l_to
        AND ORIG_SYSTEM = 'DNB'
        AND STATUS = 'A';

END IF;


-- Inactivate to_ps
             /*UPDATE HZ_PARTY_SITES
             SET status = 'I',
               end_date_active=trunc(SYSDATE-1),
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               request_id =  hz_utility_pub.request_id,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
             WHERE party_site_id = l_to;*/

             -- Transfer From_ps
           END IF;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             -- Transfer From_ps
             NULL;
         END;
       ELSE
         BEGIN
           BEGIN
           SELECT party_site_id, ps.location_id,'True' INTO l_to, l_to_loc_id,case_new
           FROM HZ_PARTY_SITES ps
           WHERE actual_content_source = 'DNB'
           AND ps.party_id = x_to_id
           AND (ps.location_id = FROM_PS.location_id OR ('Y' = (Select 'Y'
                     FROM HZ_PARTY_SITES ps1,HZ_LOCATIONS   l
                     WHERE ps1.party_site_id = FROM_PS.party_site_id
                     AND ps1.location_id = FROM_PS.location_id
                     AND l.location_id = ps1.location_id
                     --AND (ps1.status IS NULL OR ps1.status = 'A')
                     AND UPPER(TRIM(ADDRESS1) ||
                               TRIM(ADDRESS2) ||
                               TRIM(ADDRESS3) ||
                               TRIM(ADDRESS4) ||
                               TRIM(COUNTRY)  ||
                               TRIM(STATE)    ||
                               TRIM(CITY)     ||
                               TRIM(PROVINCE) ||
                               TRIM(COUNTY)   ||
                               TRIM(POSTAL_CODE)) =
                 (SELECT UPPER(TRIM(ADDRESS1) ||
                               TRIM(ADDRESS2) ||
                               TRIM(ADDRESS3) ||
                               TRIM(ADDRESS4) ||
                               TRIM(COUNTRY)  ||
                               TRIM(STATE)    ||
                               TRIM(CITY)     ||
                               TRIM(PROVINCE) ||
                               TRIM(COUNTY)   ||
                               TRIM(POSTAL_CODE))
	       FROM HZ_LOCATIONS
	       WHERE LOCATION_ID = ps.location_id) AND rownum =1))) AND rownum =1 ;

         EXCEPTION
         WHEN No_Data_Found   THEN
         NULL;
         END;


           IF case_new = 'True' THEN
           -- Merge from_ps with to_ps
           HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
              p_batch_party_id,
              'HZ_PARTY_SITES',
              FROM_PS.party_site_id,
              l_to,
              'Y',
              hz_utility_pub.created_by,
              hz_utility_pub.creation_Date,
              hz_utility_pub.last_update_login,
              hz_utility_pub.last_update_date,
              hz_utility_pub.last_updated_by);
          ELSE
          ---Activate the from party site(which we previously inactivated) and change the content source to USER_ENTERED.
          UPDATE HZ_PARTY_SITES
          SET status = 'A',
              end_date_active = NULL,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
                request_id =  hz_utility_pub.request_id,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
           WHERE request_id = hz_utility_pub.request_id;

           UPDATE HZ_PARTY_SITES
             SET actual_content_source = 'USER_ENTERED',
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               request_id =  hz_utility_pub.request_id,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
             WHERE party_site_id =FROM_PS.party_site_id ;

     ----Inactivating SSM Record
    UPDATE HZ_ORIG_SYS_REFERENCES
        SET STATUS = 'I',
        END_DATE_ACTIVE =trunc(SYSDATE-1),
        last_update_date = hz_utility_pub.last_update_date,
        last_updated_by = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        request_id =  hz_utility_pub.request_id,
        program_application_id = hz_utility_pub.program_application_id,
        program_id = hz_utility_pub.program_id,
        program_update_date = sysdate
        WHERE OWNER_TABLE_NAME = 'HZ_PARTY_SITES'
        AND OWNER_TABLE_ID =FROM_PS.party_site_id
        AND ORIG_SYSTEM = 'DNB'
        AND STATUS = 'A';
          END IF;

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             -- Transfer From_ps
             NULL;
         END;
       END IF;
     END LOOP;

     -- *******************************************
     -- Handle DNB data in HZ_RELATIONSHIPS
     FOR FROM_REL IN (
       SELECT relationship_id, relationship_type, subject_id, DIRECTIONAL_FLAG, PARTY_ID, relationship_code, start_date, end_date --5404244
       FROM HZ_RELATIONSHIPS
       WHERE actual_content_source = 'DNB'
       AND nvl(status, 'A') = 'A'
       AND object_id = p_from_id
       AND (end_date is null OR end_date>SYSDATE)) LOOP

       BEGIN
         SELECT relationship_id, subject_id, party_id INTO l_to, l_to_subj_id, l_rel_to_party_id
         FROM (
           SELECT relationship_id, subject_id, party_id
           FROM HZ_RELATIONSHIPS
           WHERE actual_content_source = 'DNB'
           AND nvl(status, 'A') = 'A'
           AND relationship_type = FROM_REL.relationship_type
           AND object_id = x_to_id
           AND DIRECTIONAL_FLAG=FROM_REL.DIRECTIONAL_FLAG
           AND (end_date is null OR end_date >SYSDATE)
           ORDER by decode(subject_id,FROM_REL.subject_id,1,2))
         WHERE ROWNUM=1;
         IF l_to_subj_id=FROM_REL.subject_id THEN
           -- From Newer
           IF case1 OR (case3 and l_to_is_branch = 'Y') THEN
             -- Merge to into from


              IF FROM_REL.PARTY_ID IS NOT NULL AND
                l_rel_to_party_id IS NOT NULL AND
                l_rel_to_party_id<>FROM_REL.PARTY_ID THEN
                FOR BATCH IN (
                  SELECT BATCH_ID FROM HZ_MERGE_PARTIES
                  WHERE BATCH_PARTY_ID = p_batch_party_id) LOOP
                  l_batch_id := BATCH.BATCH_ID;
                END LOOP;
                l_batch_party_id:=null;
                HZ_MERGE_PARTIES_PKG.Insert_Row(
                  l_batch_party_id,
                   l_BATCH_ID,
                  'PARTY_MERGE',
                  l_rel_to_party_id,
                  FROM_REL.PARTY_ID,
                  'DUPLICATE_RELN_PARTY',
                  'PENDING',
                   HZ_UTILITY_PUB.CREATED_BY,
                   HZ_UTILITY_PUB.CREATION_DATE,
                   HZ_UTILITY_PUB.LAST_UPDATE_LOGIN,
                   HZ_UTILITY_PUB.LAST_UPDATE_DATE,
                   HZ_UTILITY_PUB.LAST_UPDATED_BY);

                  insert_party_site_details(l_rel_to_party_id,FROM_REL.PARTY_ID,
                                   l_batch_party_id);
	---Bug No. 5349866
	  	        HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
                p_batch_party_id,
                'HZ_PARTY_RELATIONSHIPS',
                l_to,
                FROM_REL.relationship_id,
                'T',
                hz_utility_pub.created_by,
                hz_utility_pub.creation_Date,
                hz_utility_pub.last_update_login,
                hz_utility_pub.last_update_date,
                hz_utility_pub.last_updated_by);
	--Bug No. 5349866
              ELSE
               HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
                p_batch_party_id,
                'HZ_PARTY_RELATIONSHIPS',
                l_to,
                FROM_REL.relationship_id,
                'T',
                hz_utility_pub.created_by,
                hz_utility_pub.creation_Date,
                hz_utility_pub.last_update_login,
                hz_utility_pub.last_update_date,
                hz_utility_pub.last_updated_by);
              END IF;

           ELSE -- To Newer
             -- Merge from into to


              IF FROM_REL.PARTY_ID IS NOT NULL AND
                l_rel_to_party_id IS NOT NULL AND
                l_rel_to_party_id<>FROM_REL.PARTY_ID THEN
                FOR BATCH IN (
                  SELECT BATCH_ID FROM HZ_MERGE_PARTIES
                  WHERE BATCH_PARTY_ID = p_batch_party_id) LOOP
                  l_batch_id := BATCH.BATCH_ID;
                END LOOP;
                l_batch_party_id:=null;
                HZ_MERGE_PARTIES_PKG.Insert_Row(
                  l_batch_party_id,
                   l_BATCH_ID,
                  'PARTY_MERGE',
                  FROM_REL.PARTY_ID,
                  l_rel_to_party_id,
                  'DUPLICATE_RELN_PARTY',
                  'PENDING',
                   HZ_UTILITY_PUB.CREATED_BY,
                   HZ_UTILITY_PUB.CREATION_DATE,
                   HZ_UTILITY_PUB.LAST_UPDATE_LOGIN,
                   HZ_UTILITY_PUB.LAST_UPDATE_DATE,
                   HZ_UTILITY_PUB.LAST_UPDATED_BY);

                  insert_party_site_details(FROM_REL.PARTY_ID,
                                   l_rel_to_party_id,
                                   l_batch_party_id);
--bug 5349866
	        HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
                p_batch_party_id,
                'HZ_PARTY_RELATIONSHIPS',
                FROM_REL.relationship_id,
                l_to,
                'Y',
                hz_utility_pub.created_by,
                hz_utility_pub.creation_Date,
                hz_utility_pub.last_update_login,
                hz_utility_pub.last_update_date,
                hz_utility_pub.last_updated_by);
--bug 5349866
              ELSE

               HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
                p_batch_party_id,
                'HZ_PARTY_RELATIONSHIPS',
                FROM_REL.relationship_id,
                l_to,
                'Y',
                hz_utility_pub.created_by,
                hz_utility_pub.creation_Date,
                hz_utility_pub.last_update_login,
                hz_utility_pub.last_update_date,
                hz_utility_pub.last_updated_by);
              END IF;
           END IF;

         ELSE
           IF case1 OR (case3 and l_to_is_branch = 'Y') THEN
             -- From Newer
             -- End Date the to-relationship
             --Instead of updating the status to  'I'and end_date to SYSDATE
             -- Updating the Actual content source to UE.
             UPDATE HZ_RELATIONSHIPS
             SET actual_content_source = 'USER_ENTERED',
             last_update_date = hz_utility_pub.last_update_date,
             last_updated_by = hz_utility_pub.user_id,
             last_update_login = hz_utility_pub.last_update_login,
             request_id =  hz_utility_pub.request_id,
             program_application_id = hz_utility_pub.program_application_id,
             program_id = hz_utility_pub.program_id,
             program_update_date = sysdate
             WHERE relationship_id = l_to;
             ----Inactivating SSM Record
        UPDATE HZ_ORIG_SYS_REFERENCES
        SET STATUS = 'I',
        END_DATE_ACTIVE =trunc(SYSDATE-1),
        last_update_date = hz_utility_pub.last_update_date,
        last_updated_by = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        request_id =  hz_utility_pub.request_id,
        program_application_id = hz_utility_pub.program_application_id,
        program_id = hz_utility_pub.program_id,
        program_update_date = sysdate
        WHERE OWNER_TABLE_NAME = 'HZ_PARTIES'
        AND OWNER_TABLE_ID =l_rel_to_party_id
        AND ORIG_SYSTEM = 'DNB'
        AND STATUS = 'A';


             /*--Bug 4114254 UPDATE HZ_RELATIONSHIPS
             SET end_date = TRUNC(SYSDATE-1),
                 status = 'I',
                 last_update_date = hz_utility_pub.last_update_date,
                 last_updated_by = hz_utility_pub.user_id,
                 last_update_login = hz_utility_pub.last_update_login,
                 request_id =  hz_utility_pub.request_id,
                 program_application_id = hz_utility_pub.program_application_id,
                 program_id = hz_utility_pub.program_id,
                 program_update_date = sysdate
             WHERE relationship_id = l_to;*/
           ELSE -- To Newer
             -- End Date the from-relationship

            UPDATE HZ_RELATIONSHIPS
             SET actual_content_source = 'USER_ENTERED',
             last_update_date = hz_utility_pub.last_update_date,
             last_updated_by = hz_utility_pub.user_id,
             last_update_login = hz_utility_pub.last_update_login,
             request_id =  hz_utility_pub.request_id,
             program_application_id = hz_utility_pub.program_application_id,
             program_id = hz_utility_pub.program_id,
             program_update_date = sysdate
             WHERE relationship_id =FROM_REL.RELATIONSHIP_ID;

            ----Inactivating SSM Record
        UPDATE HZ_ORIG_SYS_REFERENCES
        SET STATUS = 'I',
        END_DATE_ACTIVE =trunc(SYSDATE-1),
        last_update_date = hz_utility_pub.last_update_date,
        last_updated_by = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        request_id =  hz_utility_pub.request_id,
        program_application_id = hz_utility_pub.program_application_id,
        program_id = hz_utility_pub.program_id,
        program_update_date = sysdate
        WHERE OWNER_TABLE_NAME = 'HZ_PARTIES'
        AND OWNER_TABLE_ID = FROM_REL.PARTY_ID
        AND ORIG_SYSTEM = 'DNB'
        AND STATUS = 'A';
             /* --Bug 4114254 UPDATE HZ_RELATIONSHIPS
             SET status = 'I',
                 end_date = TRUNC(SYSDATE-1),
                 last_update_date = hz_utility_pub.last_update_date,
                 last_updated_by = hz_utility_pub.user_id,
                 last_update_login = hz_utility_pub.last_update_login,
                 request_id =  hz_utility_pub.request_id,
                 program_application_id = hz_utility_pub.program_application_id,
                 program_id = hz_utility_pub.program_id,
                 program_update_date = sysdate
             WHERE relationship_id = FROM_REL.RELATIONSHIP_ID;*/
--5404244
	OPEN c_check_duplicates (FROM_REL.subject_id, FROM_REL.start_date, FROM_REL.end_date, FROM_REL.relationship_code, FROM_REL.directional_flag);
        FETCH c_check_duplicates INTO l_to,l_rel_to_party_id;
        IF c_check_duplicates%FOUND THEN
		l_batch_party_id:=null;
		SELECT batch_id INTO l_batch_id
		FROM HZ_MERGE_PARTIES
		WHERE batch_party_id = p_batch_party_id;

                HZ_MERGE_PARTIES_PKG.Insert_Row(
                  l_batch_party_id,
                   l_BATCH_ID,
                  'PARTY_MERGE',
                  FROM_REL.PARTY_ID,
                  l_rel_to_party_id,
                  'DUPLICATE_RELN_PARTY',
                  'PENDING',
                   HZ_UTILITY_PUB.CREATED_BY,
                   HZ_UTILITY_PUB.CREATION_DATE,
                   HZ_UTILITY_PUB.LAST_UPDATE_LOGIN,
                   HZ_UTILITY_PUB.LAST_UPDATE_DATE,
                   HZ_UTILITY_PUB.LAST_UPDATED_BY);

		   insert_party_site_details(FROM_REL.PARTY_ID,
                                   l_rel_to_party_id,
                                   l_batch_party_id);

		HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
                p_batch_party_id,
                'HZ_PARTY_RELATIONSHIPS',
                FROM_REL.relationship_id,
                l_to,
                'Y',
                hz_utility_pub.created_by,
                hz_utility_pub.creation_Date,
                hz_utility_pub.last_update_login,
                hz_utility_pub.last_update_date,
                hz_utility_pub.last_updated_by);

        END IF; --c_check_duplicates
	CLOSE c_check_duplicates;
--5404244
           END IF;

           -- Transfer From
         END IF;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           -- Transfer From
           NULL;
           FND_FILE.put_line(FND_FILE.log,'To Not found');
       END;
    END LOOP;

    -- *******************************************
    -- Handle DNB data in HZ_CONTACT_POINTS


    FOR FROM_CP IN (
       SELECT contact_point_id, phone_line_type, contact_point_type
       FROM HZ_CONTACT_POINTS
       WHERE owner_table_name = 'HZ_PARTIES'
       AND actual_content_source = 'DNB'
       AND nvl(status, 'A') = 'A'
       AND owner_table_id = p_from_id) LOOP
       case_new := 'FALSE';
       BEGIN
         BEGIN
         SELECT contact_point_id INTO l_to
         FROM HZ_CONTACT_POINTS
         WHERE owner_table_name = 'HZ_PARTIES'
         AND actual_content_source = 'DNB'
	 AND nvl(phone_line_type,'X') = nvl(FROM_CP.phone_line_type,'X')--bug 5221273
         AND contact_point_type = FROM_CP.contact_point_type --bug 5221273
         AND nvl(status, 'A') = 'A'
         AND owner_table_id = x_to_id
	 and rownum = 1; --bug 5221273;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
         NULL;
         END;


         -- From Newer
         IF case1 OR (case3 and l_to_is_branch = 'Y') THEN
           -- Merge to into from
           --If Exactly same then Merge

        BEGIN
        Select 'True' INTO case_new FROM HZ_CONTACT_POINTS
         WHERE contact_point_id = FROM_CP.contact_point_id
         AND    (CONTACT_POINT_TYPE ||
   STATUS ||
   EDI_TRANSACTION_HANDLING ||
   EDI_ID_NUMBER ||
   EDI_PAYMENT_METHOD ||
   EDI_PAYMENT_FORMAT ||
   EDI_REMITTANCE_METHOD ||
   EDI_REMITTANCE_INSTRUCTION ||
   EDI_TP_HEADER_ID ||
   EDI_ECE_TP_LOCATION_CODE ||
   EMAIL_FORMAT ||
   TO_CHAR(BEST_TIME_TO_CONTACT_START, 'DD/MM/YYYY') ||
   TO_CHAR(BEST_TIME_TO_CONTACT_END, 'DD/MM/YYYY') ||
   PHONE_CALLING_CALENDAR ||
   DECLARED_BUSINESS_PHONE_FLAG ||
   PHONE_PREFERRED_ORDER ||
   TELEPHONE_TYPE ||
   TIME_ZONE ||
   PHONE_TOUCH_TONE_TYPE_FLAG ||
   PHONE_AREA_CODE ||
   PHONE_COUNTRY_CODE ||
   PHONE_NUMBER ||
   PHONE_EXTENSION ||
   PHONE_LINE_TYPE ||
   TELEX_NUMBER ||
   WEB_TYPE )
       = (SELECT
   		CONTACT_POINT_TYPE ||
   		STATUS ||
   		EDI_TRANSACTION_HANDLING ||
   		EDI_ID_NUMBER ||
   		EDI_PAYMENT_METHOD ||
   		EDI_PAYMENT_FORMAT ||
   		EDI_REMITTANCE_METHOD ||
   		EDI_REMITTANCE_INSTRUCTION ||
   		EDI_TP_HEADER_ID ||
   		EDI_ECE_TP_LOCATION_CODE ||
   		EMAIL_FORMAT ||
   		TO_CHAR(BEST_TIME_TO_CONTACT_START, 'DD/MM/YYYY') ||
   		TO_CHAR(BEST_TIME_TO_CONTACT_END, 'DD/MM/YYYY') ||
   		PHONE_CALLING_CALENDAR ||
   		DECLARED_BUSINESS_PHONE_FLAG ||
   		PHONE_PREFERRED_ORDER ||
   		TELEPHONE_TYPE ||
   		TIME_ZONE ||
   		PHONE_TOUCH_TONE_TYPE_FLAG ||
   		PHONE_AREA_CODE ||
   		PHONE_COUNTRY_CODE ||
   		PHONE_NUMBER ||
   		PHONE_EXTENSION ||
   		PHONE_LINE_TYPE ||
   		TELEX_NUMBER ||
   		WEB_TYPE
           FROM HZ_CONTACT_POINTS
           WHERE contact_point_id = l_to)
   AND nvl(EMAIL_ADDRESS,'NOEMAIL') = (
           SELECT nvl(EMAIL_ADDRESS,'NOEMAIL')
           FROM HZ_CONTACT_POINTS
           WHERE contact_point_id = l_to)
   AND nvl(URL, 'NOURL') = (
           SELECT nvl(URL, 'NOURL')
           FROM HZ_CONTACT_POINTS
           WHERE contact_point_id = l_to);

      EXCEPTION
       WHEN NO_DATA_FOUND THEN
           NULL;

       END;

    IF case_new = 'True' THEN
           HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
                p_batch_party_id,
                'HZ_CONTACT_POINTS',
                l_to,
                FROM_CP.contact_point_id,
                'T',
                hz_utility_pub.created_by,
                hz_utility_pub.creation_Date,
                hz_utility_pub.last_update_login,
                hz_utility_pub.last_update_date,
                hz_utility_pub.last_updated_by);
     ELSE
             UPDATE HZ_CONTACT_POINTS
             SET actual_content_source = 'USER_ENTERED',
             last_update_date =hz_utility_pub.last_update_date,
             last_updated_by = hz_utility_pub.last_updated_by,
             last_update_login=hz_utility_pub.last_update_login,
             request_id = hz_utility_pub.request_id,
             program_application_id = hz_utility_pub.program_application_id,
             program_id = hz_utility_pub.program_id,
             program_update_date = sysdate
             WHERE contact_point_id = l_to;
----Inactivating SSM Record
             UPDATE HZ_ORIG_SYS_REFERENCES
             SET STATUS = 'I',
             END_DATE_ACTIVE =trunc(SYSDATE-1),
             last_update_date = hz_utility_pub.last_update_date,
             last_updated_by = hz_utility_pub.user_id,
              last_update_login = hz_utility_pub.last_update_login,
             request_id =  hz_utility_pub.request_id,
             program_application_id = hz_utility_pub.program_application_id,
             program_id = hz_utility_pub.program_id,
             program_update_date = sysdate
             WHERE OWNER_TABLE_NAME = 'HZ_CONTACT_POINTS'
             AND OWNER_TABLE_ID = l_to
             AND ORIG_SYSTEM = 'DNB'
             AND STATUS = 'A';
     END IF;
         ELSE -- To Newer
           -- Merge from into to
           --Perform Exact Dup check

        BEGIN
        Select 'True' INTO case_new FROM HZ_CONTACT_POINTS
         WHERE contact_point_id = FROM_CP.contact_point_id
         AND
   CONTACT_POINT_TYPE ||
   STATUS ||
   EDI_TRANSACTION_HANDLING ||
   EDI_ID_NUMBER ||
   EDI_PAYMENT_METHOD ||
   EDI_PAYMENT_FORMAT ||
   EDI_REMITTANCE_METHOD ||
   EDI_REMITTANCE_INSTRUCTION ||
   EDI_TP_HEADER_ID ||
   EDI_ECE_TP_LOCATION_CODE ||
   EMAIL_FORMAT ||
   TO_CHAR(BEST_TIME_TO_CONTACT_START, 'DD/MM/YYYY') ||
   TO_CHAR(BEST_TIME_TO_CONTACT_END, 'DD/MM/YYYY') ||
   PHONE_CALLING_CALENDAR ||
   DECLARED_BUSINESS_PHONE_FLAG ||
   PHONE_PREFERRED_ORDER ||
   TELEPHONE_TYPE ||
   TIME_ZONE ||
   PHONE_TOUCH_TONE_TYPE_FLAG ||
   PHONE_AREA_CODE ||
   PHONE_COUNTRY_CODE ||
   PHONE_NUMBER ||
   PHONE_EXTENSION ||
   PHONE_LINE_TYPE ||
   TELEX_NUMBER ||
   WEB_TYPE
       = (SELECT
   		CONTACT_POINT_TYPE ||
   		STATUS ||
   		EDI_TRANSACTION_HANDLING ||
   		EDI_ID_NUMBER ||
   		EDI_PAYMENT_METHOD ||
   		EDI_PAYMENT_FORMAT ||
   		EDI_REMITTANCE_METHOD ||
   		EDI_REMITTANCE_INSTRUCTION ||
   		EDI_TP_HEADER_ID ||
   		EDI_ECE_TP_LOCATION_CODE ||
   		EMAIL_FORMAT ||
   		TO_CHAR(BEST_TIME_TO_CONTACT_START, 'DD/MM/YYYY') ||
   		TO_CHAR(BEST_TIME_TO_CONTACT_END, 'DD/MM/YYYY') ||
   		PHONE_CALLING_CALENDAR ||
   		DECLARED_BUSINESS_PHONE_FLAG ||
   		PHONE_PREFERRED_ORDER ||
   		TELEPHONE_TYPE ||
   		TIME_ZONE ||
   		PHONE_TOUCH_TONE_TYPE_FLAG ||
   		PHONE_AREA_CODE ||
   		PHONE_COUNTRY_CODE ||
   		PHONE_NUMBER ||
   		PHONE_EXTENSION ||
   		PHONE_LINE_TYPE ||
   		TELEX_NUMBER ||
   		WEB_TYPE
           FROM HZ_CONTACT_POINTS
           WHERE contact_point_id = l_to)
   AND nvl(EMAIL_ADDRESS,'NOEMAIL') = (
           SELECT nvl(EMAIL_ADDRESS,'NOEMAIL')
           FROM HZ_CONTACT_POINTS
           WHERE contact_point_id = l_to)
   AND nvl(URL, 'NOURL') = (
           SELECT nvl(URL, 'NOURL')
           FROM HZ_CONTACT_POINTS
           WHERE contact_point_id = l_to);

     EXCEPTION
     WHEN No_Data_Found THEN
     NULL;

     END;

    IF case_new = 'True' THEN --Populate HZ_MERGE_PARTY_DETAILS
        HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
                p_batch_party_id,
                'HZ_CONTACT_POINTS',
                FROM_CP.contact_point_id,
                l_to,
                'Y',
                hz_utility_pub.created_by,
                hz_utility_pub.creation_Date,
                hz_utility_pub.last_update_login,
                hz_utility_pub.last_update_date,
                hz_utility_pub.last_updated_by);
    ELSE
      UPDATE HZ_CONTACT_POINTS
             SET actual_content_source = 'USER_ENTERED',
             last_update_date =hz_utility_pub.last_update_date,
             last_updated_by = hz_utility_pub.last_updated_by,
             last_update_login=hz_utility_pub.last_update_login,
             request_id = hz_utility_pub.request_id,
             program_application_id = hz_utility_pub.program_application_id,
             program_id = hz_utility_pub.program_id,
             program_update_date = sysdate
             WHERE contact_point_id = FROM_CP.contact_point_id;
    ----Inactivating SSM Record
             UPDATE HZ_ORIG_SYS_REFERENCES
             SET STATUS = 'I',
             END_DATE_ACTIVE =trunc(SYSDATE-1),
             last_update_date = hz_utility_pub.last_update_date,
             last_updated_by = hz_utility_pub.user_id,
              last_update_login = hz_utility_pub.last_update_login,
             request_id =  hz_utility_pub.request_id,
             program_application_id = hz_utility_pub.program_application_id,
             program_id = hz_utility_pub.program_id,
             program_update_date = sysdate
             WHERE OWNER_TABLE_NAME = 'HZ_CONTACT_POINTS'
             AND OWNER_TABLE_ID =FROM_CP.contact_point_id
             AND ORIG_SYSTEM = 'DNB'
             AND STATUS = 'A';
      END IF;
         END IF;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           -- Transfer
           NULL;
       END;
     END LOOP;

    -- *******************************************
    -- Handle DNB data in HZ_CREDIT_RATINGS
    FOR FROM_CR IN (
       SELECT credit_rating_id, rated_as_of_date
       FROM HZ_CREDIT_RATINGS
       WHERE actual_content_source = 'DNB'
       AND party_id = p_from_id) LOOP


       BEGIN
         SELECT credit_rating_id INTO l_to
         FROM HZ_CREDIT_RATINGS
         WHERE actual_content_source = 'DNB'
         AND party_id = x_to_id
         AND trunc(rated_as_of_date)=trunc(FROM_CR.rated_as_of_date);

           -- From Newer
           IF case1 OR (case3 and l_to_is_branch = 'Y') THEN
             -- Bug 3236556 - Delete the credit ratings of the to party
	     DELETE FROM HZ_CREDIT_RATINGS
	     WHERE credit_rating_id = l_to;
             -- Bug 3236556 - Since the to party no longer exists we must not insert a row with merge details.
             /*-- Merge to into from
             HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
                  p_batch_party_id,
                  'HZ_CREDIT_RATINGS',
                  l_to,
                    FROM_CR.credit_rating_id,
                  'T',
                  hz_utility_pub.created_by,
                  hz_utility_pub.creation_Date,
                  hz_utility_pub.last_update_login,
                  hz_utility_pub.last_update_date,
                  hz_utility_pub.last_updated_by);
	     */
           ELSE -- To Newer
             -- Merge from into to
             HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
                  p_batch_party_id,
                  'HZ_CREDIT_RATINGS',
                  FROM_CR.credit_rating_id,
                  l_to,
                  'Y',
                  hz_utility_pub.created_by,
                  hz_utility_pub.creation_Date,
                  hz_utility_pub.last_update_login,
                  hz_utility_pub.last_update_date,
                  hz_utility_pub.last_updated_by);
           END IF;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           -- Transfer
           NULL;
       END;
     END LOOP;

    -- *******************************************
    -- Handle DNB data in HZ_CODE_ASSIGNMENTS
    FOR FROM_CA IN (
       SELECT code_assignment_id, class_category, class_code
       FROM HZ_CODE_ASSIGNMENTS
       WHERE owner_table_name = 'HZ_PARTIES'
       AND content_source_type = 'DNB'
       AND nvl(status, 'A') = 'A'
       AND owner_table_id = p_from_id) LOOP

       BEGIN
         SELECT code_assignment_id INTO l_to
         FROM HZ_CODE_ASSIGNMENTS
         WHERE owner_table_name = 'HZ_PARTIES'
         AND content_source_type = 'DNB'
         AND nvl(status, 'A') = 'A'
         AND owner_table_id = x_to_id
         AND class_category = FROM_CA.class_category
         AND class_code = FROM_CA.class_code
	 AND rownum=1; --3197084

         -- From Newer
         IF case1 OR (case3 and l_to_is_branch = 'Y') THEN
           -- Merge to into from
           HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
                p_batch_party_id,
                'HZ_CODE_ASSIGNMENTS',
                FROM_CA.code_assignment_id,
                l_to,
                'Y',
                hz_utility_pub.created_by,
                hz_utility_pub.creation_Date,
                hz_utility_pub.last_update_login,
                hz_utility_pub.last_update_date,
                hz_utility_pub.last_updated_by);
         ELSE -- To Newer
           -- Merge from into to
           HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
                p_batch_party_id,
                'HZ_CODE_ASSIGNMENTS',
                FROM_CA.code_assignment_id,
                l_to,
                'Y',
                hz_utility_pub.created_by,
                hz_utility_pub.creation_Date,
                hz_utility_pub.last_update_login,
                hz_utility_pub.last_update_date,
                hz_utility_pub.last_updated_by);
         END IF;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           -- Transfer
           NULL;
       END;
    END LOOP;

    -- *******************************************
    -- Handle DNB data in HZ_FINANCIAL_REPORTS
    FOR FROM_FR IN (
       SELECT	financial_report_id,
		type_of_financial_report,
		TO_CHAR(DATE_REPORT_ISSUED, 'DD/MM/YYYY') ||
		DOCUMENT_REFERENCE ||
		ISSUED_PERIOD ||
		TO_CHAR(REPORT_START_DATE, 'DD/MM/YYYY') ||
		TO_CHAR(REPORT_END_DATE, 'DD/MM/YYYY') ||
		actual_content_source con_cat  --for bug 6600935
       FROM HZ_FINANCIAL_REPORTS
       WHERE actual_content_source = 'DNB'
       AND nvl(status, 'A') = 'A'
       AND party_id = p_from_id) LOOP

       BEGIN
         SELECT financial_report_id INTO l_to
         FROM HZ_FINANCIAL_REPORTS
         WHERE actual_content_source = 'DNB'
         AND nvl(status, 'A') = 'A'
         AND type_of_financial_report=FROM_FR.type_of_financial_report
	 AND	TO_CHAR(DATE_REPORT_ISSUED, 'DD/MM/YYYY') ||
		DOCUMENT_REFERENCE ||
		ISSUED_PERIOD ||
		TO_CHAR(REPORT_START_DATE, 'DD/MM/YYYY') ||
		TO_CHAR(REPORT_END_DATE, 'DD/MM/YYYY') ||
		actual_content_source=FROM_FR.con_cat  --for bug 6600935
         AND party_id = x_to_id;

         IF case1 OR (case3 and l_to_is_branch = 'Y') THEN

	   /*Bug 3236556*/
	   DELETE FROM HZ_FINANCIAL_REPORTS
           WHERE financial_report_id = l_to;

	   DELETE FROM HZ_FINANCIAL_NUMBERS
           WHERE financial_report_id = l_to;

	   /*
           UPDATE HZ_FINANCIAL_REPORTS
           SET status = 'I',
             last_update_date = hz_utility_pub.last_update_date,
             last_updated_by = hz_utility_pub.user_id,
             last_update_login = hz_utility_pub.last_update_login,
             request_id =  hz_utility_pub.request_id,
             program_application_id = hz_utility_pub.program_application_id,
             program_id = hz_utility_pub.program_id,
             program_update_date = sysdate
           WHERE financial_report_id = l_to;

           UPDATE HZ_FINANCIAL_NUMBERS
           SET status='I',
             last_update_date = hz_utility_pub.last_update_date,
             last_updated_by = hz_utility_pub.user_id,
             last_update_login = hz_utility_pub.last_update_login,
             request_id =  hz_utility_pub.request_id,
             program_application_id = hz_utility_pub.program_application_id,
             program_id = hz_utility_pub.program_id,
             program_update_date = sysdate
           WHERE financial_report_id = l_to;
	   */
         ELSE
           UPDATE HZ_FINANCIAL_REPORTS
           SET status = 'M',
             last_update_date = hz_utility_pub.last_update_date,
             last_updated_by = hz_utility_pub.user_id,
             last_update_login = hz_utility_pub.last_update_login,
             request_id =  hz_utility_pub.request_id,
             program_application_id = hz_utility_pub.program_application_id,
             program_id = hz_utility_pub.program_id,
             program_update_date = sysdate
           WHERE financial_report_id = FROM_FR.financial_report_id;

           UPDATE HZ_FINANCIAL_NUMBERS
           SET status='M',
             last_update_date = hz_utility_pub.last_update_date,
             last_updated_by = hz_utility_pub.user_id,
             last_update_login = hz_utility_pub.last_update_login,
             request_id =  hz_utility_pub.request_id,
             program_application_id = hz_utility_pub.program_application_id,
             program_id = hz_utility_pub.program_id,
             program_update_date = sysdate
           WHERE financial_report_id = FROM_FR.financial_report_id;  -- Bug 3313609

         END IF;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           -- Transfer
           NULL;
       END;
    END LOOP;
  END IF;



EXCEPTION
  WHEN OTHERS THEN
    log('Error in setup DNB data: '||SQLERRM);
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
END;

PROCEDURE insert_party_site_details (
	p_from_party_id	     IN	NUMBER,
	p_to_party_id	     IN	NUMBER,
	p_batch_party_id     IN	NUMBER
) IS

  --Cursor for inserting Party sites that are non-DNB
  CURSOR c_from_ps_loc IS
    SELECT party_site_id, ps.location_id
    FROM HZ_PARTY_SITES ps
    WHERE ps.party_id = p_from_party_id
    AND ps.actual_content_source <> 'DNB'
    AND nvl(status, 'A') = 'A';

  CURSOR c_dup_to_ps(cp_loc_id NUMBER) IS
    SELECT party_site_id
    FROM HZ_PARTY_SITES ps
    WHERE ps.party_id = p_to_party_id
    AND ps.location_id = cp_loc_id
    AND ps.actual_content_source <> 'DNB'
    AND nvl(status, 'A') = 'A';

l_ps_id NUMBER;
l_loc_id NUMBER;
l_dup_ps_id NUMBER;
l_sqerr VARCHAR2(2000);

BEGIN

  OPEN c_from_ps_loc;
  LOOP
    FETCH c_from_ps_loc INTO l_ps_id, l_loc_id;
    EXIT WHEN c_from_ps_loc%NOTFOUND;
    IF p_from_party_id <> p_to_party_id THEN
      OPEN c_dup_to_ps(l_loc_id);
      FETCH c_dup_to_ps INTO l_dup_ps_id;

      IF c_dup_to_ps%FOUND THEN
       HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
        p_batch_party_id,
  	    'HZ_PARTY_SITES',
	    l_ps_id,
	    l_dup_ps_id,
          'Y',
	    hz_utility_pub.created_by,
	    hz_utility_pub.creation_Date,
	    hz_utility_pub.last_update_login,
	    hz_utility_pub.last_update_date,
	    hz_utility_pub.last_updated_by);
      ELSE
       HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
        p_batch_party_id,
  	    'HZ_PARTY_SITES',
	    l_ps_id,
	    l_ps_id,
          'Y',
	    hz_utility_pub.created_by,
	    hz_utility_pub.creation_Date,
	    hz_utility_pub.last_update_login,
	    hz_utility_pub.last_update_date,
	    hz_utility_pub.last_updated_by);
      END IF;
      CLOSE c_dup_to_ps;
    END IF;
  END LOOP;
  CLOSE c_from_ps_loc;
EXCEPTION
  WHEN OTHERS THEN
  log('Error in DNB insert rel party site details : '||SQLERRM);
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  APP_EXCEPTION.RAISE_EXCEPTION;
END insert_party_site_details;

PROCEDURE check_int_ext_party_type(
    p_dup_set_id  IN NUMBER,
    p_int_party   OUT NOCOPY VARCHAR2,
    p_ext_party   OUT NOCOPY VARCHAR2,
	p_merge_ok    OUT NOCOPY VARCHAR2)
IS
 l_merge_ok  varchar2(1);
 flag        varchar2(1);
 flag_prev   varchar2(1);

 cursor org_c(l_dup_set_id in NUMBER)
     is
select nvl(orgpf.internal_flag, 'N') internal_flag , hp.party_name
 from  HZ_merge_parties dup, hz_parties hp, hz_organization_profiles orgpf
 where dup.batch_id = l_dup_set_id
 and   (hp.party_id = dup.from_party_id or hp.party_id = dup.to_party_id)
 and   hp.party_type = 'ORGANIZATION'
 and   hp.party_id = orgpf.party_id(+)
 and   sysdate between orgpf.effective_start_date(+) and nvl(orgpf.effective_end_date(+),sysdate);

/* select nvl(orgpf.internal_flag, 'N') internal_flag , hp.party_name
 from  HZ_DUP_SET_PARTIES dup, hz_parties hp, hz_organization_profiles orgpf
 where dup.dup_set_id = l_dup_set_id
 and   dup.dup_party_id = hp.party_id
 and   hp.party_type = 'ORGANIZATION'
 and   hp.party_id = orgpf.party_id(+)
 and   sysdate between orgpf.effective_start_date(+) and nvl(orgpf.effective_end_date(+),sysdate)
 and   NVL(dup.MERGE_FLAG,'Y') <> 'N';*/


 party_rec  org_c%rowtype;

 cursor person_c(l_dup_set_id in NUMBER)
     is
select nvl(orgpf.internal_flag, 'N') internal_flag , hp.party_name
 from  HZ_merge_parties dup, hz_parties hp, hz_person_profiles orgpf
 where dup.batch_id = l_dup_set_id
 and   (hp.party_id = dup.from_party_id or hp.party_id = dup.to_party_id)
 and   hp.party_type = 'PERSON'
 and   hp.party_id = orgpf.party_id(+)
 and   sysdate between orgpf.effective_start_date(+) and nvl(orgpf.effective_end_date(+),sysdate);

/* select nvl(orgpf.internal_flag, 'N') internal_flag , hp.party_name
 from  HZ_DUP_SET_PARTIES dup, hz_parties hp, hz_person_profiles orgpf
 where dup.dup_set_id = l_dup_set_id
 and   dup.dup_party_id = hp.party_id
 and   hp.party_type = 'PERSON'
 and   hp.party_id = orgpf.party_id(+)
 and   sysdate between orgpf.effective_start_date(+) and nvl(orgpf.effective_end_date(+),sysdate)
 and   NVL(dup.MERGE_FLAG,'Y') <> 'N';*/

BEGIN
l_merge_ok := 'Y';
flag_prev  := null;

-- check for organizations
open org_c(p_dup_set_id);
fetch org_c into party_rec;
while (org_c%found)
loop
   if(party_rec.internal_flag = 'Y')
   then
     if(p_int_party is null)
     then
        p_int_party := party_rec.party_name;
     else
        p_int_party := p_int_party || ',' ||party_rec.party_name;
     end if;
   else
      if(p_ext_party is null)
     then
        p_ext_party := party_rec.party_name;
     else
        p_ext_party := substr(p_ext_party || ',' ||party_rec.party_name, 1, 4000);
     end if;

   end if;
   if ( flag_prev is null)
   then
      flag_prev := party_rec.internal_flag;
   end if;
   if(flag_prev = party_rec.internal_flag)
   then
       flag_prev := party_rec.internal_flag;
   else
      l_merge_ok := 'N';
   end if;

   fetch org_c into party_rec;
end loop;
close org_c;


-- check for person
flag_prev := null;
open person_c(p_dup_set_id);
fetch person_c into party_rec;
while (person_c%found)
loop
   if(party_rec.internal_flag = 'Y')
   then
     if(p_int_party is null)
     then
        p_int_party := party_rec.party_name;
     else
        p_int_party := p_int_party || ',' ||party_rec.party_name;
     end if;
   else
      if(p_ext_party is null)
     then
        p_ext_party := party_rec.party_name;
     else
        p_ext_party := substr(p_ext_party || ',' ||party_rec.party_name, 1, 4000);
     end if;

   end if;
   if ( flag_prev is null)
   then
      flag_prev := party_rec.internal_flag;
   end if;
   if(flag_prev = party_rec.internal_flag)
   then
       flag_prev := party_rec.internal_flag;
   else
      l_merge_ok := 'N';
   end if;

   fetch person_c into party_rec;
end loop;
close person_c;

p_merge_ok := l_merge_ok;

EXCEPTION
  WHEN OTHERS THEN
    log('Error in check internal/external party type: '||SQLERRM);
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
END check_int_ext_party_type;


END HZ_PARTY_MERGE;

/
