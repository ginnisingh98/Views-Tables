--------------------------------------------------------
--  DDL for Package Body HZ_AUTOMERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_AUTOMERGE_PKG" AS
 /*$Header: ARHAMRGB.pls 120.18.12000000.3 2007/05/25 10:09:41 vsegu ship $ */


G_PKG_NAME      CONSTANT VARCHAR2(30)    := 'HZ_AUTOMERGE_PKG' ;

/**
* Procedure to write a message to the out file
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


-----------------------------------------------------------------------
-- Function to fetch messages of the stack and log the error
-----------------------------------------------------------------------
PROCEDURE logerror(SQLERRM VARCHAR2 DEFAULT NULL)
IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;
  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := substr(l_msg_data || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ), 1, 2000) ;
  END LOOP;
  IF (SQLERRM IS NOT NULL) THEN
    l_msg_data := substr(l_msg_data || SQLERRM, 1, 2000);
  END IF;
  log(l_msg_data);
END;


/**
* Procedure to write a message to the out and log files
**/
PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  out(message, newline);
  log(message, newline);
END outandlog;

FUNCTION chk_for_rem_batch( P_DUP_SET_ID IN NUMBER
) RETURN NUMBER
IS
l_count NUMBER;
l_procedure_name VARCHAR2(255) := 'CHK_FOR_REM_BATCH';
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
    select count(*) into l_count
    from hz_dup_set_parties
    where dup_set_id = P_DUP_SET_ID
    and merge_flag = 'N' ;
    RETURN l_count;
END chk_for_rem_batch;

FUNCTION chk_count( P_DUP_SET_ID IN Number,
p_winner_party_id IN Number
) RETURN NUMBER
IS
l_count NUMBER;
l_procedure_name VARCHAR2(255) := 'CHK_COUNT';
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
    select count(*) into l_count
    from hz_dup_set_parties
    where dup_set_id = P_DUP_SET_ID
    and dup_party_id <> p_winner_party_id;
    RETURN l_count;
END chk_count;

-- Creates remainder batch for viewing and manual submission by data librarian.
-- Remainder batch is created during succsfful invocatoin of create_merge_batch
-- api or if expected error occurs. If an expected error occurs create remainder
-- batch with all parties irrespective of merge flag else create remainder batch
-- for all parties which are not being merged by automerge (merge_flag = 'N')
PROCEDURE create_rem_batch( p_dup_batch_id IN NUMBER,
P_DUP_SET_ID IN Number,
P_WINNER_PARTY_ID IN Number,
p_new_dup_batch_id IN NUMBER,
p_state IN VARCHAR2
) IS
TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_dup_party_id NumberList;
l_score NumberList;
l_match_rule_id NUMBER;
l_req_type VARCHAR2(30);
l_w_score NUMBER;
l_new_dup_set_id NUMBER;
l_procedure_name VARCHAR2(255) := 'CREATE_REM_BATCH';
l_merge_type VARCHAR2(30);

CURSOR c1(l_dup_set_id NUMBER, l_winner_party_id NUMBER) is
            select score
            from hz_dup_set_parties
            where dup_set_id = l_dup_set_id
            and dup_party_id = l_winner_party_id;

CURSOR c2(l_dup_set_id NUMBER, l_winner_party_id NUMBER, p_state VARCHAR2) is
            select dup_party_id, score
            from hz_dup_set_parties
            where dup_set_id = l_dup_set_id
            and decode(p_state, 'S', merge_flag, 'E', 'N') = 'N'
            and dup_party_id <> l_winner_party_id;

BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
         SAVEPOINT create_rem_batch;
            select hz_merge_batch_s.nextval into l_new_dup_set_id from dual;
            log (' Creating remainder batch....');
            log (' l_new_dup_set_id = ' || l_new_dup_set_id);
            -- log(' l_winner_party_id = ' || p_winner_party_id);
            -- log (' s_dup_batch_id = ' || p_new_dup_batch_id);
            -- log (' p_state = '|| p_state);
            -- insert row for the dup set
            insert into hz_dup_sets(winner_party_id, dup_batch_id, dup_set_id, status, merge_type,
              object_version_number, created_by, creation_date, last_update_login, last_update_date, last_updated_by)
              values( p_winner_party_id, p_new_dup_batch_id, l_new_dup_set_id, 'SYSBATCH', 'PARTY_MERGE',
              1,
              HZ_UTILITY_V2PUB.CREATED_BY,
              HZ_UTILITY_V2PUB.CREATION_DATE, HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
              HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
              HZ_UTILITY_V2PUB.LAST_UPDATED_BY);
            OPEN c1(p_DUP_SET_ID, p_winner_party_id);
            FETCH c1 into l_w_score;
            -- insert row for the dup set and winner party id.
            insert into hz_dup_set_parties(dup_party_id, dup_set_id, merge_flag, score, created_by,
                creation_date, last_update_login, last_update_date, last_updated_by,dup_set_batch_id) --Bug No: 4244529
                values (p_winner_party_id,  l_new_dup_set_id, 'N', l_w_score, HZ_UTILITY_V2PUB.CREATED_BY,
                HZ_UTILITY_V2PUB.CREATION_DATE, HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
                HZ_UTILITY_V2PUB.LAST_UPDATE_DATE, HZ_UTILITY_V2PUB.LAST_UPDATED_BY,p_new_dup_batch_id) ; --Bug No: 4244529
            CLOSE c1;
            OPEN c2(p_DUP_SET_ID, p_winner_party_id, p_state);
            FETCH c2 bulk collect into l_dup_party_id, l_score;
            log ('  l_dup_party_id.count = ' || l_dup_party_id.count);
            FOR I in l_dup_party_id.FIRST..l_dup_party_id.LAST
            LOOP
                -- log('l_dup_party_id('||I||') = '|| l_dup_party_id(I));
                -- log ('  l_score('||I||') = ' ||  l_score(I));

                -- insert row for a particualr dup set and all its parties which are not being
                -- merged by automerge.
                insert into hz_dup_set_parties(dup_party_id, dup_set_id, merge_flag, score, created_by,
                   creation_date, last_update_login, last_update_date, last_updated_by,dup_set_batch_id) --Bug No: 4244529
                   values (l_dup_party_id(I), l_new_dup_set_id, 'N', l_score(I), HZ_UTILITY_V2PUB.CREATED_BY,
                   HZ_UTILITY_V2PUB.CREATION_DATE, HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
                   HZ_UTILITY_V2PUB.LAST_UPDATE_DATE, HZ_UTILITY_V2PUB.LAST_UPDATED_BY,p_new_dup_batch_id) ; --Bug No: 4244529
            END LOOP;
            CLOSE c2;
            log (' Batch for review created with dup_batch_id = ' ||p_new_dup_batch_id );
EXCEPTION WHEN OTHERS THEN
        ROLLBACK TO create_rem_batch;
        log(SQLERRM);
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE;
END create_rem_batch;

-- bug 4773387, non automerge dup set will be created in rem batch. Delete it from orig. batch
procedure delete_non_am_dup_set(p_dup_set_id number, p_all_cnt number, p_non_am_cnt number) is

begin
	if p_all_cnt = p_non_am_cnt -- no automerge candidates in the set
	then
		DELETE FROM HZ_DUP_SETS
   		where DUP_SET_ID = p_DUP_SET_ID;

		delete from hz_dup_set_parties
		where dup_set_id = p_dup_set_id;
	end if;

end;


-- Program merges the parties which have higher score than threshold (set during
-- match rule definition) and identified as duplicates.
PROCEDURE automerge( retcode   OUT NOCOPY   VARCHAR2,
     err        OUT NOCOPY    VARCHAR2,
     p_dup_batch_id IN VARCHAR2,
     p_no_of_workers IN VARCHAR2)
IS
TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
A_DUP_SET_ID NumberList;
l_winner_party_id NumberList;

l_object_version_number NUMBER;
x_return_status VARCHAR2(1);
x_msg_count NUMBER;
x_msg_data VARCHAR2(2000);
x_request_id NUMBER;
c1 HZ_PARTY_STAGE.StageCurTyp;
l_sql_stmt1 VARCHAR2(4000);
l_prof_value VARCHAR2(30);
l_sub_requests NumberList;
A_MERGE_BATCH_ID NumberList;
l_no_of_workers NUMBER;
l_dup_batch_id NUMBER;
J NUMBER;
req_data VARCHAR2(30);
l_success BOOLEAN := true;
l_new_dup_batch_id NUMBER;
i NUMBER;
l_batch_name VARCHAR2(255);
l_match_rule_id NUMBER;
l_req_type VARCHAR2(30);
l_request_type VARCHAR2(30);
l_count NUMBER;
l_all_count NUMBER;
l_procedure_name VARCHAR2(255) := 'AUTOMERGE';
is_first boolean := true;
l_temp NUMBER;
l_automerge_flag VARCHAR2(1) := 'N';
l_party_name varchar2(360);
l_exist varchar2(1);
l_default_mapping varchar2(1);
l_master_candidate_cnt number;
	cursor sysbatch_exist is
	  select 'Y'
	  from hz_dup_sets
	  where dup_batch_id = p_dup_batch_id
	  and status = 'SYSBATCH'
	  and rownum = 1;

	cursor get_obj_version_csr(cp_dup_set_id number) is
		SELECT object_version_number
  		FROM   hz_dup_sets
  		WHERE  dup_set_id =  cp_dup_set_id;

		cursor get_active_party_count_csr(cp_dup_set_id number) is
		select count(*)
		from hz_parties p, hz_dup_set_parties mp
		where p.party_id = mp.dup_party_id
		and mp.dup_set_id = cp_dup_set_id
		and p.status = 'A'
		and nvl(mp.merge_flag,'Y') = 'Y';

BEGIN
     SAVEPOINT automerge;
    -- Diagnositics
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
     END IF;
     -- log(' p_dup_batch_id = ' || p_dup_batch_id);
     select a.dup_batch_name, a.match_rule_id,
     decode(a.request_type, 'SYSTEM_GENERATED', 'SYSTEM_AUTOMERGE', 'IMPORT', 'IMPORT_AUTOMERGE'), a.request_type, b.automerge_flag
     into l_batch_name, l_match_rule_id, l_req_type, l_request_type, l_automerge_flag
     from hz_dup_batch a, hz_match_rules_b b
     where a.dup_batch_id = p_dup_batch_id
     and a.match_rule_id = b.match_rule_id;
     -- log(' l_automerge_flag = ' || l_automerge_flag);
     IF (upper(l_automerge_flag) <> 'Y') THEN
          fnd_conc_global.set_req_globals(conc_status => 'ERROR',
                                        request_data => 'ERROR') ;
          FND_MESSAGE.SET_NAME('AR', 'HZ_AM_MATCH_RULE_SUPPORT');
          FND_MSG_PUB.ADD;
          logerror;
          err  := fnd_message.get;
          retcode := 2;
     ELSE

     req_data := fnd_conc_global.request_data;
     log(' ');
   --  log(' req_data = ' || req_data);
   --  l_no_of_workers := nvl(to_number(p_no_of_workers),1);
     l_no_of_workers := nvl(fnd_profile.value('HZ_DQM_PM_NUM_OF_WORKERS'), 1);
     l_dup_batch_id := to_number(p_dup_batch_id);


  IF (req_data IS NULL OR req_data = 'SYSTEM_PHASE1') THEN
     log (' l_batch_name = ' || l_batch_name);
     --log (' l_req_type = ' || l_req_type);
     --log(' l_no_of_workers ' || l_no_of_workers);
     log(' l_dup_batch_id ' || l_dup_batch_id);
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     fnd_msg_pub.initialize;

    -- get all dup_set_id's for a particular batch.  this conditions also helps in re-running
    -- the program again for same batch.

  open sysbatch_exist;
  fetch sysbatch_exist into l_exist;
  close sysbatch_exist;
  -- log ('sysbatch exist '|| nvl(l_exist,'N'));
  if nvl(l_exist,'N') = 'Y'
  then
    OPEN c1 FOR SELECT dup_set_id, winner_party_id
    FROM hz_dup_sets
    WHERE dup_batch_id = p_dup_batch_id
    and status = 'SYSBATCH';
    FETCH c1 BULK COLLECT INTO A_DUP_SET_ID, l_winner_party_id ;

    IF (c1%ROWCOUNT > 0) THEN
       /* Using the new master default. Call default_master
        -- based on this profile, winner party is updated if the request type for a batch is 'SYSTEM_GENERATED'
        l_prof_value := nvl(fnd_profile.value('HZ_AUTOMERGE_WINNER_SELECT_RULE'), 'KEEP_EARLIEST_CREATED'); -- creae new profile and change code accordingly
        log (' l_prof_value' || l_prof_value);
        log (' ');
        IF l_prof_value = 'KEEP_EARLIEST_CREATED' THEN
            l_sql_stmt1 := 'select dup_party_id
                from hz_dup_set_parties a, hz_parties b
                where a.dup_set_id = :1
                and a.dup_party_id = b.party_id
                and nvl(merge_flag, ''Y'') = ''Y''
                and rownum = 1
                order by b.creation_date asc ' ;
        ELSIF l_prof_value = 'KEEP_LATEST_CREATED' THEN
            l_sql_stmt1 := 'select dup_party_id
                from hz_dup_set_parties a, hz_parties b
                where a.dup_set_id = :1
                and a.dup_party_id = b.party_id
                and nvl(merge_flag, ''Y'') = ''Y''
                and rownum = 1
                order by b.creation_date desc ' ;
        END IF;    */

	if nvl(fnd_profile.value('HZ_AM_SUGG_GROUPINGS'),'N') = 'Y'
      	then
		l_default_mapping := 'Y';
	else
		l_default_mapping := 'N';
	end if;

      FOR I in A_DUP_SET_ID.FIRST..A_DUP_SET_ID.LAST
      LOOP
          --log(' ');
          --log(' A_DUP_SET_ID('||I||') = '||A_DUP_SET_ID(I));
          --log (' l_request_type = ' || l_request_type);
          l_count := chk_for_rem_batch(A_DUP_SET_ID(I));
          --log (' l_count = ' || l_count);
	  -- prefix AM
          l_all_count := chk_count(A_DUP_SET_ID(I), l_winner_party_id(I));
          --log (' l_all_count = ' || l_all_count);
       IF substr(l_batch_name,0,3) <> 'AM:' THEN    --SDIB scheduling  bug 6067226
	  update hz_dup_batch
	  set dup_batch_name = 'AM: ' ||substr(l_batch_name, 1, 250)
	  where dup_batch_id = p_dup_batch_id;
       END IF;

          IF (( l_count > 0) AND (is_first))THEN
             is_first := false;
             select hz_dup_batch_s.nextval into l_new_dup_batch_id from dual;
             log (' l_new_dup_batch_id = '|| l_new_dup_batch_id);
              -- substring of dup_batch_name as this gets appended and inserted in same column. This way we avoid insertion errors.

             insert into hz_dup_batch(dup_batch_id, dup_batch_name, match_rule_id, request_type,
             created_by, creation_date, last_update_login, last_update_date,
             last_updated_by, application_id)
             values(l_new_dup_batch_id, l_batch_name, l_match_rule_id, l_req_type,
             HZ_UTILITY_V2PUB.CREATED_BY, HZ_UTILITY_V2PUB.CREATION_DATE, HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
             HZ_UTILITY_V2PUB.LAST_UPDATE_DATE, HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
             HZ_UTILITY_V2PUB.APPLICATION_ID);
         END IF;
         -- update winner party id if request_type = 'SYSTEM_GENERATED'
         IF (l_request_type = 'SYSTEM_GENERATED') THEN

            --  execute immediate l_sql_stmt1 into l_winner_party_id(I) using A_DUP_SET_ID(I);

	     open get_active_party_count_csr(A_DUP_SET_ID(I));
	     fetch get_active_party_count_csr into l_master_candidate_cnt;
	     close get_active_party_count_csr;

	     if l_master_candidate_cnt <> 0
             then
	     	hz_dup_pvt.default_master(
 		p_dup_set_id      => A_DUP_SET_ID(I),
 		x_master_party_id => l_winner_party_id(I),
 		x_master_party_name  => l_party_name,
 		x_return_status      => x_return_status,
 		x_msg_count          => x_msg_count,
 		x_msg_data           => x_msg_data );
             -- log(' l_winner_party_id('||I||') =  '|| l_winner_party_id(I));
	     end if;
 	-- The code below is called in default_master
           /*
             update hz_dup_sets c
             set c.winner_party_id = l_winner_party_id(I)
             where c.dup_set_id = A_DUP_SET_ID(I);

             -- update the winner party id to have merge_flag = 'Y'
             update hz_dup_set_parties
             set merge_flag = 'Y'
             where dup_set_id = A_DUP_SET_ID(I)
             and dup_party_id = l_winner_party_id(I);  */
          END IF;

          -- create merge batch
          IF (l_all_count > l_count) THEN
		open get_obj_version_csr(A_DUP_SET_ID(I));
		fetch get_obj_version_csr into l_object_version_number;
	        close get_obj_version_csr;

              HZ_MERGE_DUP_PVT.Create_Merge_Batch(
                A_DUP_SET_ID(I), -- all ids from c1
                l_default_mapping,
                l_object_version_number,
                A_MERGE_BATCH_ID(I),
                x_return_status,
                x_msg_count,
                x_msg_data);
              --log(' A_MERGE_BATCH_ID('|| I ||') = '||A_MERGE_BATCH_ID(I));
              --log(SubStr(' x_return_status from api HZ_MERGE_DUP_PVT.Create_Merge_Batch = '||x_return_status,1,255));
          END IF;
          -- If no 'N', then do not request party merge
          IF (l_count = 0) THEN
              IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 update hz_dup_sets set status = 'AM_QUEUE' where dup_set_id =  A_DUP_SET_ID(I);
              ELSE
                 l_success := FALSE;
                 retcode := 2;
                 err := SQLERRM;
                 fnd_msg_pub.count_and_get(
                      p_encoded                      => fnd_api.g_false,
                      p_count                        => x_msg_count,
                      p_data                         => x_msg_data);
                 ROLLBACK TO automerge;
                 EXIT;
              END IF;
          END IF;
          IF (l_count > 0) THEN
              IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 create_rem_batch( p_dup_batch_id, A_DUP_SET_ID(I), L_WINNER_PARTY_ID(I), l_new_dup_batch_id, 'S');
		 delete_non_am_dup_set(A_DUP_SET_ID(I), l_all_count, l_count);

                 IF (l_all_count > l_count) THEN
                     log (' updating hz_dup_sets status to AM Queue for dup_set_id = ' || A_DUP_SET_ID(I));
                     update hz_dup_sets set status = 'AM_QUEUE' where dup_set_id =  A_DUP_SET_ID(I);
                 END IF;
              ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 -- if unexpected error, then error out the program
                 l_success := FALSE;
                 retcode := 2;
                 err := SQLERRM;
                 fnd_msg_pub.count_and_get(
                      p_encoded                      => fnd_api.g_false,
                      p_count                        => x_msg_count,
                      p_data                         => x_msg_data);
                 ROLLBACK TO automerge;
		 close c1;
                 EXIT;
              -- if expected error, create remainder batch but do not run party merge
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 l_success := FALSE;
                 l_count := chk_for_rem_batch(A_DUP_SET_ID(I));
                 create_rem_batch( p_dup_batch_id, A_DUP_SET_ID(I), L_WINNER_PARTY_ID(I), l_new_dup_batch_id, 'E');
                 update hz_dup_sets set status = 'CREATION_ERROR' where dup_set_id =  A_DUP_SET_ID(I);
                 retcode := 1;
                 err := SQLERRM;
                 log ('Error :: ' || SQLERRM);
              END IF;
           END IF;
      END LOOP;
      close c1;
    COMMIT;
    log (' Commit done.');
    log(' Number of merge requests generated: '|| to_char(A_DUP_SET_ID.count));
   END IF;
  end if; -- if l_exist
END IF; -- if req_data is null
    i := 1;
    J := 0;
    select count(*) into J
    from hz_dup_sets
    where status = 'AM_QUEUE'
    and dup_batch_id = p_dup_batch_id;
    IF J <= 0 THEN
        log (' No more records to process -- exiting, J = ' || J);
        l_success := false;
    END IF;

    if not (l_success)
    then log (' l_success is false');
    end if;

    IF (l_success) THEN
        FOR TX IN (select dup_set_id
        from hz_dup_sets
        where status = 'AM_QUEUE'
        and rownum <= l_no_of_workers
        and dup_batch_id = p_dup_batch_id)
        LOOP
           -- call party merge
           -- log(' Calling party merge for following DUP_SET_ID = '|| TX.DUP_SET_ID);
           l_sub_requests(i) := FND_REQUEST.SUBMIT_REQUEST('AR', 'ARHPMERGE',
                        'Party Merge Concurrent Request',
                        to_char(sysdate,'DD-MON-YY HH24:MI:SS'),
                        true, to_char(TX.DUP_SET_ID), 'N');
           -- log ( ' l_sub_requests = ' || l_sub_requests(i));
           IF l_sub_requests(i) = 0 THEN
                log('Error submitting worker ' || i);
                log(fnd_message.get);
          -- ELSE
          --      log(' Submitted request for Worker ' || TO_CHAR(I) );
          --      log(' Request ID : ' || l_sub_requests(i));
           END IF;
           EXIT when l_sub_requests(i) = 0;
           i := i + 1;
        END LOOP;
        fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                        request_data => 'SUBMITTING_MERGE_REQUEST') ;
        err  := 'Concurrent Workers submitted.';
        retcode := 0;
    END IF;
  END IF; --   IF (upper(l_automerge_flag) <> 'Y') THEN
EXCEPTION WHEN OTHERS THEN
        ROLLBACK to automerge;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        retcode := 2;
        err := SQLERRM;
        log ('ERROR :: =' || SQLERRM);
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

        RAISE;
END automerge;

END HZ_AUTOMERGE_PKG;



/
