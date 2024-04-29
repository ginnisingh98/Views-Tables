--------------------------------------------------------
--  DDL for Package Body HZ_BATCH_DUPLICATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_BATCH_DUPLICATE" AS
/*$Header: ARHBDUPB.pls 120.27.12000000.2 2007/05/25 10:04:22 vsegu ship $*/

-- Private procedure forward declaration
FUNCTION check_party_in_dupset (
        p_batch_id      IN      NUMBER,
        p_party_id      IN      NUMBER,
        p_dup_set_id    IN      NUMBER := -1
)  RETURN BOOLEAN;

PROCEDURE remove_non_duplicates (
        p_cur_party_id          IN      NUMBER,
        p_dup_set_id            IN      NUMBER
);

PROCEDURE insert_match_details (
    p_search_ctx_id     IN      NUMBER,
    p_dup_set_id        IN      NUMBER,
    p_dup_party_id      IN      NUMBER
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

FUNCTION logerror RETURN VARCHAR2;

g_print_time_taken NUMBER:=5;
g_print_num_eval NUMBER:=50;


-- VJN INTRODUCED GLOBAL VARIABLES FOR QUICK DUPLICATE IDENTIFICATION
-- These variables which were earlier in find_dup_parties
-- are moved here, in order to make sure that the values of the
-- fetched concurrent request ids are in scope, when find_dup_parties
-- calls itself after the workers are all completed.

TYPE nTable IS TABLE OF NUMBER index by binary_integer;
l_sub_requests nTable;

PROCEDURE find_dup_parties (
        errbuf                  OUT NOCOPY    VARCHAR2,
        retcode                 OUT NOCOPY    VARCHAR2,
        p_rule_id           	IN      VARCHAR2,
        p_num_workers          	IN      VARCHAR2,
        p_batch_name            IN      VARCHAR2,
        p_subset_defn         	IN      VARCHAR2,
        p_match_within_subset   IN      VARCHAR2,
        p_search_merged   	IN      VARCHAR2
) IS

	-- start bug 4773387

  	cursor am_candidates_exist_csr(cp_dup_batch_id NUMBER) is
		select count(*)
    		from hz_dup_set_parties dsp, hz_dup_sets ds
    		where dsp.dup_set_id = ds.dup_set_id
    		and ds.dup_batch_id = cp_dup_batch_id
    		and ds.winner_party_id <> dsp.dup_party_id
    		and merge_flag = 'Y'
		and rownum =1;

	l_am_count NUMBER;
  	-- end bug 4773387

  l_rule_id NUMBER;
  l_batch_id NUMBER;

  -- VJN INTRODUCED VARIABLES FOR QUICK DUPLICATE IDENTIFICATION
  match_rule_purpose varchar2(1) ;
  req_data VARCHAR2(30);
  l_conc_phase            VARCHAR2(80);
  l_conc_status           VARCHAR2(80);
  l_conc_dev_phase        VARCHAR2(30);
  l_conc_dev_status       VARCHAR2(30);
  l_message               VARCHAR2(240);
  call_status             boolean;
  dup_workers_completed   boolean;
  l_sub FND_CONCURRENT.REQUESTS_TAB_TYPE;

  l_owner          VARCHAR2(30);
  l_automerge_flag VARCHAR2(1);
  l_req_id         NUMBER;
  temp             NUMBER ;
  batch_count      NUMBER;
  l_batch_name     VARCHAR2(360);
  l_new_batch_id   NUMBER;
  l_request_id     NUMBER;
  l_staged_var     VARCHAR2(1);

  CURSOR dup_dup_parties(cp_dup_batch_id NUMBER) IS
       select dup_party_id
       from hz_dup_set_parties
       where dup_set_id in (select dup_set_id from hz_dup_sets where dup_batch_id=cp_dup_batch_id)
       group by dup_party_id
       having count(*)>1;

  CURSOR dup_party_sets(cp_dup_batch_id NUMBER, cp_dup_party_id NUMBER) IS
       select ds.dup_set_id
       FROM hz_dup_set_parties dsp, hz_dup_sets ds
       where dsp.dup_set_id=ds.dup_set_id
       and ds.dup_batch_id=cp_dup_batch_id
       and dsp.dup_party_id=cp_dup_party_id
       order by ds.dup_set_id;


  l_dup_dup_set NUMBER;
  l_dup_dup_id NUMBER;
  l_num_left NUMBER;
  l_winner_id NUMBER;
  FIRST BOOLEAN;

BEGIN

  -- Fix for bug 4736139, to display an error message and error out
  -- if staging not being run/complete, before calling SDIB.

  EXECUTE IMMEDIATE 'SELECT HZ_MATCH_RULE_'||p_rule_id||'.check_staged_var from dual' INTO l_staged_var;

  IF l_staged_var='N' THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MATCH_RULE_TX_NOT_STAGED');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- End bug 4736139

  -- req_data will be null the first time, by default
  req_data := fnd_conc_global.request_data;

  -- get the purpose of the match rule first
  select rule_purpose into match_rule_purpose
  from hz_match_rules_vl
  where match_rule_id = p_rule_id ;

  l_batch_id := to_number(p_batch_name);

  -- First Phase
  IF (req_data IS NULL)
  THEN
          l_rule_id := to_number(p_rule_id);
          retcode := 0;

/* Changes for scheduling of SDIB concurrent program. Bug: 4631257*/
    l_batch_id := to_number(p_batch_name);
    select count(*) into batch_count from hz_dup_batch where dup_batch_id=l_batch_id
    and request_id is not null;


  if(batch_count>0) then


          outandlog('batch count= '||batch_count);
          outandlog('l_batch_name= '||l_batch_name);

	 	select nvl(automerge_flag,'N') into l_automerge_flag
	  	from hz_dup_batch
	  	where dup_batch_id = l_batch_id;

        select HZ_DUP_BATCH_S.NEXTVAL into l_new_batch_id from dual;

		insert into hz_dl_selected_criteria
		(select hz_dl_selected_criteria_s.NEXTVAL, 'SDIB', l_new_batch_id, attribute_name,operation,value,fnd_global.user_id,
		sysdate,fnd_global.login_id,fnd_global.user_id,sysdate from hz_dl_selected_criteria
		where batch_id=l_batch_id and batch_type='SDIB');

    	select dup_batch_name into l_batch_name from hz_dup_batch where dup_batch_id = l_batch_id;

        l_batch_name := substr(l_batch_name,0,(instr(l_batch_name,'-')-1));
        l_batch_id := l_new_batch_id;

        HZ_DUP_BATCH_PKG.Insert_Row(l_batch_id,l_batch_name,p_rule_id,fnd_global.resp_appl_id,
	  								'SYSTEM_GENERATED',fnd_global.user_id,sysdate,fnd_global.login_id,
									sysdate,fnd_global.user_id);


		UPDATE HZ_DUP_BATCH set automerge_flag = l_automerge_flag, last_update_date = SYSDATE,
    	last_update_login = FND_GLOBAL.LOGIN_ID,last_updated_by = FND_GLOBAL.USER_ID
    	Where dup_batch_id = l_batch_id;
          outandlog('new batch id = '||l_batch_id);
   end if;

		UPDATE HZ_DUP_BATCH
    	SET REQUEST_ID = hz_utility_v2pub.request_id
    	WHERE dup_batch_id = l_batch_id;


          outandlog('Starting Concurrent Program ''Batch Duplicate Identification''');
          outandlog('Start Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
          outandlog('NEWLINE');


          log('match_rule_purpose is '||match_rule_purpose);

          -- This step is necessary only for Bulk Match Rules :: Refer to Bug 4261835
          IF match_rule_purpose = 'Q'
          THEN
            BEGIN
                log('Beginning to truncate HZ_DUP_RESULTS');
                -- make sure we start on a clean slate for Quick Duplicate Identification
                l_owner := HZ_IMP_DQM_STAGE.get_owner_name('HZ_DUP_RESULTS', 'TABLE');
                execute immediate ' truncate table ' || l_owner || '.HZ_DUP_RESULTS';
                EXCEPTION
                WHEN OTHERS THEN
                    log('-----------------------------------------------------');
                    log('Error while truncating HZ_DUP_RESULTS');
                    log('Error is ' || SQLERRM);
                    IF SQLCODE = -00054 THEN

                        BEGIN
                            log('It appears that another instance of the Batch Duplicate Identification program');
                            log('using a Bulk Match Rule, is running already.');
                            log('Please note that the Batch Duplicate Identification program is incompatible');
                            log('with itself, when using Bulk Match Rules.');

                            -- try to get the request id of the other instance of
                            -- SDIB that may be running, with the hard coded concurrent program id
                            -- from seed data
                            FOR req_cur in
                                (select request_id
                                from fnd_concurrent_requests a
                                where concurrent_program_id = 44445
                                and phase_code = 'R'
                                and substr(argument_text, 1, instr(argument_text,',') -1 )
                                in ( select match_rule_id from hz_match_rules_vl where rule_purpose = 'Q')
                                order by actual_start_date
                                )
                                LOOP
                                      log('Request Id of the concurrent program running already is ' || req_cur.request_id );
                                      exit ;

                                END LOOP ;

                        -- we have the exception block, just in case the above SQL does not return any data
                        EXCEPTION
                        WHEN OTHERS
                        THEN
                            log('Error occurred while trying to find the request id of the other running instance of SDIB.');
                            log('Error is ' || SQLERRM);
                            NULL ;
                        END ;

                    END IF ;

                    log('-----------------------------------------------------');
                    RAISE ;
            END ;
          END IF ;


          -- Initialize return status and message stack
          FND_MSG_PUB.initialize;

          IF l_rule_id IS NULL OR l_rule_id = 0 THEN
            -- Find the match rule
            null;

            -- No MATCH RULE FOUND
            FND_MESSAGE.SET_NAME('AR', 'HZ_NO_MATCH_RULE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF p_batch_name IS NULL OR p_batch_name = '' THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_BATCH_NAME');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          --- VJN INTRODUCED CODE FOR QUICK DUPLICATE IDENTIFICATION

              log('Spawning ' || p_num_workers || ' Workers for duplicate identification');
              FOR I in 1..TO_NUMBER(p_num_workers)
              LOOP
                l_sub_requests(i) := FND_REQUEST.SUBMIT_REQUEST('AR', 'ARHDQBDW',
                              'Batch Duplicate Worker ' || to_char(i),
                              to_char(sysdate,'DD-MON-YY HH24:MI:SS'),
                              TRUE, p_num_workers, TO_CHAR(I), p_rule_id,
                              to_char(l_batch_id),p_subset_defn,p_match_within_subset,p_search_merged);
                IF l_sub_requests(i) = 0 THEN
                  log('Error submitting worker ' || i);
                  log(fnd_message.get);
                  dup_workers_completed := FALSE;
                  retcode := 2;
                ELSE
                  log('Submitted request for Worker ' || TO_CHAR(I) );
                  log('Request ID : ' || l_sub_requests(i));
                END IF;
                EXIT when l_sub_requests(i) = 0;
              END LOOP;

              -- wait for completion of all workers
              fnd_conc_global.set_req_globals(conc_status => 'PAUSED', request_data => 'SYSTEM_PHASE1') ;
  -- Second Phase
  ELSE
              log('***********************************************************');
              log('Post processing Data cleanup for SDIB');
--              l_batch_id := to_number(p_batch_name); bug 6067226

              SELECT dup_batch_id INTO l_batch_id
              FROM   hz_dup_batch
              where request_id = FND_GLOBAL.conc_request_id;

              OPEN dup_dup_parties(l_batch_id);
              LOOP
                FETCH dup_dup_parties into l_dup_dup_id;
                EXIT when dup_dup_parties%NOTFOUND;
                log('Party ' || l_dup_dup_id || ' occurs more than once in batch '||l_batch_id);
                FIRST:=TRUE;
                open dup_party_sets(l_batch_id,l_dup_dup_id);
                LOOP
                  FETCH dup_party_sets INTO l_dup_dup_set;
                  EXIT when dup_party_sets%NOTFOUND;
                  log('Dup set id ' || l_dup_dup_set || ' has party '||l_dup_dup_id);
                  IF NOT FIRST THEN
                    log('Party ' || l_dup_dup_id || ' already found as a dup in another set. Deleting.');
                    DELETE from hz_dup_set_parties
                    WHERE dup_set_id=l_dup_dup_set
                    AND dup_party_id=l_dup_dup_id;
                    log('More than one occurence of party id ' ||l_dup_dup_id || ' in dup set '||l_dup_dup_set);

                    SELECT count(1) INTO l_num_left
                    FROM hz_dup_set_parties
                    WHERE dup_set_id=l_dup_dup_set;
                    log('Total number of parties in dup set ' ||l_dup_dup_set || ' is '||l_num_left);
                    IF l_num_left=1 THEN
                       SELECT DUP_PARTY_ID INTO l_winner_id FROM HZ_DUP_SET_PARTIES
                       WHERE dup_set_id = l_dup_dup_set;
                       log('Winner party '||l_winner_id||' is the only party in dup set '||l_dup_dup_set||' and this party will be deleted frm the current batch ');

                      log('Delete dup sets with one party from hz_dup_set_parties, dup set id'||l_dup_dup_set);
                      DELETE from hz_dup_set_parties
                      WHERE dup_set_id=l_dup_dup_set;

                      log('Delete dup sets with no parties from hz_dup_sets, dup set id'||l_dup_dup_set);
                      DELETE from hz_dup_sets
                      WHERE dup_set_id=l_dup_dup_set;
                    END IF;
                  ELSE
                    FIRST:=FALSE;
                  log('First Occurence of party id ' ||l_dup_dup_id || ' in dup set '||l_dup_dup_set);
                  END IF;
                END LOOP;
                CLOSE dup_party_sets;
              END LOOP;
              CLOSE dup_dup_parties;

              DELETE FROM hz_dup_sets d1 WHERE dup_batch_id = l_batch_id
              AND NOT EXISTS (SELECT 1 FROM hz_dup_set_parties
                             WHERE dup_set_id = d1.dup_set_id);
             log('Delete dup sets with no parties from hz_dup_sets'||SQL%ROWCOUNT);

              log('');
              log('***********************************************************');

          -- AFTER ALL THE WORKERS ARE DONE, SEE IF THEY HAVE ALL COMPLETED NORMALLY

          -- assume that all concurrent dup workers completed normally, unless found otherwise
          dup_workers_completed := TRUE;

          Select request_id BULK COLLECT into l_sub_requests
          from Fnd_Concurrent_Requests R
          Where Parent_Request_Id = FND_GLOBAL.conc_request_id
          and (phase_code<>'C' or status_code<>'C');

          IF  l_sub_requests.count>0 THEN
            dup_workers_completed:=FALSE;
            FOR I in 1..l_sub_requests.COUNT LOOP
              outandlog('Worker with request id ' || l_sub_requests(I) );
              outandlog('did not complete normally');
              retcode := 2;
            END LOOP;
          END IF;
          log('p_rule_id '||p_rule_id);
          --l_batch_id := to_number(p_batch_name);
          l_rule_id := to_number(p_rule_id);
          log('match_rule_purpose '||match_rule_purpose);
          IF dup_workers_completed THEN
            log('dup_workers_completed TRUE');
          ELSE
            log('dup_workers_completed FALSE');
          END IF;
          -- if match rule purpose is Quick Duplicate Identification
          -- call the corresponding API for sanitization,
          -- provided all the dup_workers have completed normally
         IF match_rule_purpose = 'Q' and dup_workers_completed
         THEN
            HZ_DQM_DUP_ID_PKG.tca_sanitize_report(
                         l_batch_id,
                         l_rule_id,
                         p_subset_defn,
                         p_match_within_subset
                         );
            -- make sure we truncate the dup results table after all the workers are done
            l_owner := HZ_IMP_DQM_STAGE.get_owner_name('HZ_DUP_RESULTS', 'TABLE');
            execute immediate ' truncate table ' || l_owner || '.HZ_DUP_RESULTS';

          END IF;

	  select automerge_flag into l_automerge_flag
	  from hz_dup_batch
	  where dup_batch_id = l_batch_id;

	 if nvl(l_automerge_flag,'N') = 'Y'
	 then
		-- start bug 4773387
	       	open am_candidates_exist_csr(l_batch_id);
		fetch am_candidates_exist_csr into l_am_count;
		close am_candidates_exist_csr;
		if l_am_count <> 0 then
		-- end bug 4773387
	       		l_req_id := FND_REQUEST.SUBMIT_REQUEST('AR', 'ARHAMRGP','Automerge', to_char(sysdate,'DD-MON-YY HH24:MI:SS'), TRUE, l_batch_id, p_num_workers);

	       		IF l_req_id = 0 THEN
		  		log('Error submitting Automerge request');
		  		log(fnd_message.get);
	       		ELSE
		  		log('Submitted request ID for Automerge: ' || l_req_id );
	       		END IF;
		-- start bug 4773387
		else
			log('No automerge candidates, therefore only one reviewable batch has been created.');

			update hz_dup_batch
	 		set automerge_flag = 'N',
	 		request_type = 'SYSTEM_AUTOMERGE'
	 		where dup_batch_id = l_batch_id;
		end if;
		-- end bug 4773387


	 end if;


         outandlog('Concurrent Program Execution completed ');
         outandlog('End Time : '|| TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    outandlog('Expected Error section in Parent concurrent program. Aborting duplicate batch.' ||SQLERRM);
    retcode := 2;
    errbuf := errbuf || logerror;
    FND_FILE.close;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    outandlog('UnExpected Error section in Parent concurrent program. Aborting duplicate batch.' ||SQLERRM);
    retcode := 2;
    errbuf := errbuf || logerror;
   FND_FILE.close;
  WHEN OTHERS THEN
    outandlog('Other Error Section in Parent concurrent program. Aborting duplicate batch.' ||SQLERRM);
    retcode := 2;
    errbuf := errbuf || logerror;
    FND_FILE.close;
END;

PROCEDURE find_party_dups (
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
	p_rule_id               IN      NUMBER,
        p_party_id		IN	NUMBER,
        x_party_search_rec      OUT NOCOPY HZ_PARTY_SEARCH.party_search_rec_type,
        x_party_site_list       OUT NOCOPY HZ_PARTY_SEARCH.party_site_list,
        x_contact_list          OUT NOCOPY HZ_PARTY_SEARCH.contact_list,
        x_contact_point_list    OUT NOCOPY HZ_PARTY_SEARCH.contact_point_list,
        x_search_ctx_id         OUT NOCOPY 	NUMBER,
        x_num_matches           OUT NOCOPY 	NUMBER,
        x_return_status         OUT NOCOPY    VARCHAR2,
        x_msg_count             OUT NOCOPY    NUMBER,
        x_msg_data              OUT NOCOPY    VARCHAR2
) IS

  l_return_status VARCHAR2(30);
  L_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  l_rule_id NUMBER;
  l_dup_set_id NUMBER;
  l_num_matches NUMBER;

BEGIN
  l_rule_id := p_rule_id;

  HZ_PARTY_SEARCH.get_party_for_search(
    FND_API.G_FALSE,l_rule_id, p_party_id, x_party_search_rec,
    x_party_site_list, x_contact_list, x_contact_point_list,
    l_return_status, l_msg_count, l_msg_data);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_PARTY_ACQUIRE_ERROR');
      FND_MESSAGE.SET_TOKEN('PARTY_ID', TO_CHAR(p_party_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ELSE
    HZ_PARTY_SEARCH.find_duplicate_parties(
      FND_API.G_FALSE,l_rule_id, p_party_id, NULL,
      NULL, null, null, l_dup_set_id,x_search_ctx_id, l_num_matches,
      l_return_status, l_msg_count, l_msg_data);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.Count_And_Get(
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_SQL_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;

    FND_MSG_PUB.Count_And_Get(
           p_encoded => FND_API.G_FALSE,
           p_count => x_msg_count,
           p_data  => x_msg_data);
END;

PROCEDURE find_party_dups (
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
	p_rule_id               IN      NUMBER,
        p_party_id		IN	NUMBER,
        p_party_site_ids	IN	HZ_PARTY_SEARCH.IDList,
        p_contact_ids		IN	HZ_PARTY_SEARCH.IDList,
        p_contact_pt_ids	IN	HZ_PARTY_SEARCH.IDList,
        x_party_search_rec      OUT NOCOPY HZ_PARTY_SEARCH.party_search_rec_type,
        x_party_site_list       OUT NOCOPY HZ_PARTY_SEARCH.party_site_list,
        x_contact_list          OUT NOCOPY HZ_PARTY_SEARCH.contact_list,
        x_contact_point_list    OUT NOCOPY HZ_PARTY_SEARCH.contact_point_list,
        x_search_ctx_id         OUT NOCOPY 	NUMBER,
        x_num_matches           OUT NOCOPY 	NUMBER,
        x_return_status         OUT NOCOPY    VARCHAR2,
        x_msg_count             OUT NOCOPY    NUMBER,
        x_msg_data              OUT NOCOPY    VARCHAR2
) IS

  l_return_status VARCHAR2(30);
  L_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  l_rule_id NUMBER;


BEGIN
  l_rule_id := p_rule_id;

  HZ_PARTY_SEARCH.get_search_criteria(
    FND_API.G_FALSE,l_rule_id, p_party_id, p_party_site_ids,p_contact_ids,
    p_contact_pt_ids, x_party_search_rec,
    x_party_site_list, x_contact_list, x_contact_point_list,
    l_return_status, l_msg_count, l_msg_data);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_PARTY_ACQUIRE_ERROR');
      FND_MESSAGE.SET_TOKEN('PARTY_ID', TO_CHAR(p_party_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ELSE
    HZ_PARTY_SEARCH.find_parties(
      FND_API.G_FALSE,l_rule_id,
      x_party_search_rec, x_party_site_list,x_contact_list, x_contact_point_list,
      'party_id <> '||p_party_id || ' and ROWNUM < 1000',
      'N', x_search_ctx_id,x_num_matches,x_return_status,
      x_msg_count, x_msg_data);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.Count_And_Get(
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_SQL_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;

    FND_MSG_PUB.Count_And_Get(
           p_encoded => FND_API.G_FALSE,
           p_count => x_msg_count,
           p_data  => x_msg_data);
END;



PROCEDURE find_dup_parties_worker (
        errbuf                  OUT  NOCOPY   VARCHAR2,
        retcode                 OUT  NOCOPY   VARCHAR2,
        p_num_workers          	IN      VARCHAR2,
        p_worker_number        	IN      VARCHAR2,
        p_rule_id           	IN      VARCHAR2,
        p_batch_id              IN      VARCHAR2,
        p_subset_defn         	IN      VARCHAR2,
        p_match_within_subset   IN      VARCHAR2,
        p_search_merged         IN      VARCHAR2
) IS

/*  CURSOR dup_dup_parties(cp_dup_batch_id NUMBER) IS
       select dup_party_id
       from hz_dup_set_parties
       where dup_set_batch_id = cp_dup_batch_id --Bug No: 4244529
       group by dup_party_id
       having count(*)>1;

  CURSOR dup_party_sets(cp_dup_batch_id NUMBER, cp_dup_party_id NUMBER) IS
       select dsp.dup_set_id
       FROM hz_dup_set_parties dsp
       where dsp.dup_set_batch_id = cp_dup_batch_id --Bug No: 4244529
       and dsp.dup_party_id=cp_dup_party_id;*/


  l_rule_id NUMBER;
  l_batch_id NUMBER;
  l_cur_party_id NUMBER;
  l_search_ctx_id NUMBER;

  TYPE PartyCurTyp IS REF CURSOR;
  c_parties PartyCurTyp;

  l_return_status VARCHAR2(30);
  L_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  l_sqlerr VARCHAR2(2000);
  l_subset_defn VARCHAR2(2000);

  l_num_workers NUMBER;
  l_worker_number NUMBER;

  l_num_matches NUMBER;
  l_match_score NUMBER;
  l_auto_merge_score NUMBER;

  l_dup_set_id NUMBER;
  l_dup_dup_set NUMBER;
  l_dup_dup_id NUMBER;
  l_num_left NUMBER;
  l_num_subset NUMBER;
  l_num_evaluated NUMBER;
  l_total_matches NUMBER;
  l_total_dup_sets NUMBER;
  skipped VARCHAR2(32000):=' ';
  skip_line_cnt NUMBER:=0;

  t1 NUMBER;
  t2 NUMBER;

  FIRST BOOLEAN;

  -- VJN INTRODUCED VARIABLES FOR QUICK DUPLICATE IDENTIFICATION
  match_rule_purpose varchar2(1) ;

  -- bug 5393863
  party_count NUMBER ;
  error_count NUMBER ;
  error_limit NUMBER ;
  -- bug 5393863

BEGIN

  l_rule_id := to_number(p_rule_id);
  l_num_workers := to_number(p_num_workers);
  l_worker_number := to_number(p_worker_number);

  -- Initialize return status and message stack
  FND_MSG_PUB.initialize;
  l_batch_id := TO_NUMBER(p_batch_id);
  l_num_subset:=0;
  l_num_evaluated:=0;
  l_total_matches:=0;
  l_total_dup_sets:=0;
  error_limit := 5000 ;--bug 5393863


   --- VJN INTRODUCED CODE FOR QUICK DUPLICATE IDENTIFICATION

  select rule_purpose into match_rule_purpose
  from hz_match_rules_vl
  where match_rule_id = l_rule_id ;


  IF match_rule_purpose = 'Q'
  THEN
    log('Starting Concurrent Program ''Batch Quick Duplicate Identification Worker: '||p_worker_number||'''');
    log('Start Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
    log('subset defn is ' || p_subset_defn );

    IF l_worker_number = l_num_workers THEN
       l_worker_number := 0;
    END IF;
    HZ_DQM_DUP_ID_PKG.tca_dup_id_worker(
                 l_batch_id,
                 l_rule_id,
                 l_worker_number,
                 l_num_workers,
                 p_subset_defn
                 );
    log('End Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
  ELSE

              SELECT match_score, auto_merge_score
              INTO l_match_score, l_auto_merge_score
              FROM hz_match_rules_vl
              WHERE match_rule_id = l_rule_id;

              IF l_auto_merge_score is null OR l_auto_merge_score < l_match_score THEN
                l_auto_merge_score := 999999999;
              END IF;

              IF l_worker_number = l_num_workers THEN
                l_worker_number := 0;
              END IF;

              retcode := 0;

              log('Starting Concurrent Program ''Batch Duplicate Identification Worker: '||p_worker_number||'''');
              log('Start Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
              log('NEWLINE');

              log('------------------------------------------------------');
              log('Start Time before insert to chunk ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));

              --Adding the condition of Status = A, to the 2 OPEN c_parties cursors below to fix bug 4669400.
              --This will make sure that the Merged and Inactive Parties (with status as 'M' and 'I')
              --will not be considered for duplicate idenfication.
               -- bug 5393863
              IF p_subset_defn IS NULL THEN
                execute immediate
                'insert /*+ APPEND */  into hz_dup_worker_chunk_gt
                SELECT  /*+ INDEX(parties HZ_PARTIES_U1) */ parties.PARTY_ID FROM HZ_PARTIES parties WHERE parties.PARTY_TYPE <> ''PARTY_RELATIONSHIP''
                AND NVL(parties.STATUS,''A'') = ''A'' AND mod(parties.PARTY_ID, :num_workers) = :worker_number '
                USING l_num_workers, l_worker_number;
                log('Number of parties inserted into HZ_DUP_WORKER_CHUNK_GT by worker '||l_worker_number||' is '||SQL%ROWCOUNT );
              ELSE
                execute immediate
                'insert /*+ APPEND */  into hz_dup_worker_chunk_gt
                SELECT /*+ INDEX(parties HZ_PARTIES_U1) */ PARTY_ID FROM HZ_PARTIES parties WHERE parties.PARTY_TYPE <> ''PARTY_RELATIONSHIP'' AND NVL(parties.STATUS,''A'') = ''A''
                AND mod(parties.PARTY_ID, :num_workers) = :worker_number AND '||
                p_subset_defn
                 USING l_num_workers, l_worker_number;
                log('Number of parties inserted into HZ_DUP_WORKER_CHUNK_GT by worker '||l_worker_number||' is '||SQL%ROWCOUNT );
              END IF;
                log('End Time after insert to chunk ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
                COMMIT;
                log(' Commit to Chunk complete ');

              -- bug 5393863

          FOR EVALPARTY IN (
            SELECT PARTY_ID
            FROM HZ_DUP_WORKER_CHUNK_GT ORDER BY PARTY_ID)
              LOOP
                l_cur_party_id := EVALPARTY.PARTY_ID;
                party_count := party_count + 1 ;

                log('------------------------------------------------------');
                log('Processing party_id '||l_cur_party_id);

                l_num_subset := l_num_subset+1;

                IF NOT check_party_in_dupset(l_batch_id, l_cur_party_id) THEN
                  BEGIN

                    t1:=to_number(to_char(SYSDATE,'SSSSS'));
                    IF p_match_within_subset = 'Y' AND p_subset_defn IS NOT NULL THEN
                      l_subset_defn := 'EXISTS (select 1 FROM HZ_PARTIES parties '||
                                       'where parties.party_id = stage.party_id ' ||
                                       'and '||p_subset_defn||')';
                      HZ_PARTY_SEARCH.find_duplicate_parties(
                            FND_API.G_TRUE,l_rule_id, l_cur_party_id, l_subset_defn,
                            NULL, l_batch_id, p_search_merged, l_dup_set_id,l_search_ctx_id, l_num_matches,
                            l_return_status, l_msg_count, l_msg_data);
                    ELSE
                      HZ_PARTY_SEARCH.find_duplicate_parties(
                            FND_API.G_TRUE,l_rule_id, l_cur_party_id, NULL,
                            NULL, l_batch_id, p_search_merged, l_dup_set_id,l_search_ctx_id, l_num_matches,
                            l_return_status, l_msg_count, l_msg_data);
                    END IF;

                    -- Search is not Successful
                    -- EXPECTED ERRORS :: continue to the next iteration of the loop, log errors,
                    -- until a threshold of errors.
                    -- UNEXPECTED ERRORS :: log error and exit batch.
                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                    THEN
                        -- Count Errors
                        error_count := error_count+1;
                        IF(error_count = error_limit)
                        THEN
                             log('Errors exceeded the threshold of errors');
                             log('Exiting ..');
                             RAISE FND_API.G_EXC_ERROR ;
	                    END IF;

                        -- Expected Errors
                        IF l_return_status = FND_API.G_RET_STS_ERROR
                        THEN
                          log('Expected Error during party_id '||l_cur_party_id);
			              log('Error is '||l_msg_data);
			              log('Continuing ..');
			            -- UnExpected Errors
                        ELSE
                          log('Unexpected Error during party_id '||l_cur_party_id);
                          log('Error is '||l_msg_data);
                          log('Exiting ..');
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                        END IF;
                    -- Search is Successful
                    ELSE
					  IF l_num_matches>0 THEN
                      	l_total_matches := l_total_matches+l_num_matches;
                      	l_total_dup_sets := l_total_dup_sets+1;
                      	log('Found ' || l_num_matches || ' duplicates for '||l_cur_party_id);
                      	remove_non_duplicates(l_cur_party_id,l_dup_set_id);
                    	COMMIT;
                     ELSE
                     	log('Completed successfully but found no duplicates');
                     END IF;
                    END IF;

                    l_num_evaluated := l_num_evaluated+HZ_DQM_SEARCH_UTIL.get_num_eval;
                    IF HZ_DQM_SEARCH_UTIL.get_num_eval>g_print_num_eval THEN
                      log('******* Evaluated '||HZ_DQM_SEARCH_UTIL.get_num_eval||' for party_id '||l_cur_party_id);
                    END IF;
                    t2:=to_number(to_char(SYSDATE,'SSSSS'));
                    IF (t2-t1)>g_print_time_taken THEN
                      log('******* Time taken to evaluate party_id '||l_cur_party_id||' is: '||(t2-t1));
                    END IF;
                  END;
                ELSE
                    log('l_cur_party_id '||l_cur_party_id||' is not processed ');
                END IF;
              END LOOP;

              log(' All Parties processed successfully. Commencing Sanitization');

              /* Fix non-mutually exclusive sets if any */
              --DELETE FROM hz_dup_set_parties WHERE dup_set_id IN (
                --SELECT dup_set_id FROM hz_dup_sets d1
                --WHERE dup_batch_id = l_batch_id
                --AND EXISTS ( --Bug No: 4244529
                   --SELECT 1
                   --FROM hz_dup_set_parties dp
                   --WHERE dp.DUP_SET_BATCH_ID =  d1.dup_batch_id
                   --AND   dp.DUP_PARTY_ID     =  d1.winner_party_id
                   --AND   dp.DUP_SET_ID       <> d1.dup_set_id));

              --DELETE FROM hz_dup_sets d1 WHERE dup_batch_id = l_batch_id
              --AND NOT EXISTS (SELECT 1 FROM hz_dup_set_parties
                             --WHERE dup_set_id = d1.dup_set_id);

              log('');
              log('Total Number of parties in subset '||l_num_subset);
              log('Total Number of parties scored '||l_num_evaluated);
              log('Total Number of duplicate_sets identified '||l_total_dup_sets);
              log('Total Number of duplicates identified '||l_total_matches);

              log('End Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
              log('THIS WORKER COMPLETED SUCCESSFULLY');

  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    log('--------------------------------');
    log('Expected Error ' || l_cur_party_id);
    log('Error: Aborting duplicate batch');
    log('THIS WORKER ERRORED OUT');
    FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
      log(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
    END LOOP;
    FND_MESSAGE.CLEAR;

    retcode := 2;
    errbuf := 'Expected Error ' || l_cur_party_id;
    FND_FILE.close;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    log('--------------------------------');
    log('Unexpected Error ' || l_cur_party_id);
    log('Error: Aborting duplicate batch');
    log('THIS WORKER ERRORED OUT');
    FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
      log(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
    END LOOP;
    FND_MESSAGE.CLEAR;

    errbuf := 'UnExpected Error ' || l_cur_party_id;
    retcode := 2;
   FND_FILE.close;
  WHEN OTHERS THEN
    log('--------------------------------');
    log('Unknown Error ' || l_cur_party_id || ' : ' || SQLERRM);
    log('Error: Aborting duplicate batch');
    log('THIS WORKER ERRORED OUT');
    FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
      log(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
    END LOOP;

    retcode := 2;
    errbuf := 'UnExpected SQL Error ' || l_cur_party_id;
    FND_FILE.close;
END;

FUNCTION check_party_in_dupset (
	p_batch_id 	IN	NUMBER,
	p_party_id	IN	NUMBER,
        p_dup_set_id	IN	NUMBER := -1
)  RETURN BOOLEAN IS

  CURSOR c_dupset_party IS
	SELECT dup_party_id
	FROM hz_dup_set_parties dp
	WHERE dp.DUP_SET_BATCH_ID = p_batch_id --Bug No: 4244529
	AND dp.DUP_PARTY_ID = p_party_id
        AND dp.DUP_SET_ID <> p_dup_set_id;

  l_dup_party_id NUMBER;

BEGIN
  OPEN c_dupset_party;
  FETCH c_dupset_party INTO l_dup_party_id;
  IF c_dupset_party%FOUND THEN
    CLOSE c_dupset_party;
    RETURN TRUE;
  ELSE
    CLOSE c_dupset_party;
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_BATCH_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'check_party_in_dupset');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

  -- Remove mathes that have been indicated as non-duplicates in the
  -- HZ_DUP_EXCLUSIONS table
PROCEDURE remove_non_duplicates (
        p_cur_party_id          IN      NUMBER,
        p_dup_set_id            IN      NUMBER
) IS
winner_count NUMBER;
dupset_count NUMBER;
BEGIN
  DELETE FROM HZ_DUP_SET_PARTIES p
  WHERE p.dup_set_id = p_dup_set_id
  AND p.dup_party_id <> p_cur_party_id
  AND EXISTS (
	SELECT 1 FROM HZ_DUP_EXCLUSIONS d
        WHERE (
	  (d.PARTY_ID=p_cur_party_id AND d.DUP_PARTY_ID=p.dup_party_id)
           OR
	  (d.PARTY_ID=p.dup_party_id AND d.DUP_PARTY_ID=p_cur_party_id)
        ) AND (d.FROM_DATE IS NULL OR d.FROM_DATE <= SYSDATE)
          AND (d.TO_DATE   IS NULL OR d.TO_DATE   >= SYSDATE)
  );

  SELECT COUNT(*) INTO dupset_count FROM HZ_DUP_SET_PARTIES
  WHERE DUP_SET_ID = p_dup_set_id;

  IF (dupset_count=1) THEN
    SELECT COUNT(*) INTO winner_count FROM HZ_DUP_SET_PARTIES
 	 WHERE DUP_SET_ID = p_dup_set_id
 	 and dup_party_id in
  	(select winner_party_id from hz_dup_sets where dup_set_id=p_dup_set_id);

	if(winner_count=1) then
    	DELETE FROM HZ_DUP_SET_PARTIES WHERE DUP_SET_ID=p_dup_set_id;
    	DELETE FROM HZ_DUP_SETS WHERE DUP_SET_ID=p_dup_set_id;
	end if;

 END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_BATCH_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'remove_non_duplicates');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END remove_non_duplicates;

PROCEDURE insert_match_details (
    p_search_ctx_id 	IN	NUMBER,
    p_dup_set_id 	IN	NUMBER,
    p_dup_party_id 	IN	NUMBER
) IS

BEGIN

  INSERT INTO HZ_DUP_MATCH_DETAILS (
	DUP_SET_ID,
	DUP_PARTY_ID,
	WINNER_PARTY_VALUE,
	MATCHED_PARTY_VALUE,
	MATCHED_ATTRIBUTE,
	ASSIGNED_SCORE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY
  ) SELECT p_dup_set_id,
        p_dup_party_id,
        gt.ENTERED_VALUE,
        gt.MATCHED_VALUE,
        vl.USER_DEFINED_ATTRIBUTE_NAME, -- Bug No: 3820598
        gt.ASSIGNED_SCORE,
        hz_utility_pub.created_by,
        hz_utility_pub.creation_date,
        hz_utility_pub.last_update_login,
        hz_utility_pub.last_update_date,
        hz_utility_pub.user_id
    FROM hz_party_score_dtls_gt gt,hz_trans_attributes_vl vl -- Bug No: 3820598
    WHERE gt.PARTY_ID = p_dup_party_id
    AND gt.SEARCH_CONTEXT_ID = p_search_ctx_id
    AND gt.ENTITY = vl.ENTITY_NAME
    AND gt.ATTRIBUTE=vl.ATTRIBUTE_NAME;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_BATCH_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'create_dup_set');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END insert_match_details;

PROCEDURE get_dup_match_details (
        p_init_msg_list IN     VARCHAR2 := FND_API.G_FALSE,
	p_rule_id	IN	NUMBER,
	p_dup_set_id	IN	NUMBER,
        x_return_status OUT NOCOPY    VARCHAR2,
        x_msg_count     OUT NOCOPY    NUMBER,
        x_msg_data      OUT NOCOPY    VARCHAR2
) IS

  l_rule_id NUMBER;
  l_search_ctx_id NUMBER;
  l_winner_party_id NUMBER;

  l_party_rec HZ_PARTY_SEARCH.party_search_rec_type;
  l_party_site_list HZ_PARTY_SEARCH.party_site_list;
  l_contact_list HZ_PARTY_SEARCH.contact_list;
  l_cpt_list HZ_PARTY_SEARCH.contact_point_list;

  l_return_status VARCHAR2(30);
  L_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

  l_num_matches NUMBER;
  l_count NUMBER;

  l_dup_set_creation_date HZ_DUP_SETS.creation_date%type;
  l_mr_last_updated_date  HZ_MATCH_RULES_VL.last_update_date%type;
  l_mr_comp_flag VARCHAR2(1);

BEGIN
  -- Initialize return status and message stack
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  SELECT count(1)
  INTO l_count
  FROM hz_dup_match_details
  WHERE dup_set_id = p_dup_set_id;

  IF l_count>0 THEN
    RETURN;
  END IF;

  l_rule_id := p_rule_id;
  SELECT winner_party_id,creation_date INTO l_winner_party_id,l_dup_set_creation_date
  FROM HZ_DUP_SETS
  WHERE dup_set_id = p_dup_set_id;

  select last_update_date,compilation_flag INTO l_mr_last_updated_date,l_mr_comp_flag
  from HZ_MATCH_RULES_VL
  where  match_rule_id = p_rule_id;

  IF l_mr_comp_flag <> 'C' OR l_mr_last_updated_date > l_dup_set_creation_date THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_CDL_NO_MATCH_DETAILS');
  FND_MSG_PUB.ADD;
  RAISE FND_API.G_EXC_ERROR;
  END IF;

  HZ_PARTY_SEARCH.get_party_for_search(
                FND_API.G_FALSE,p_rule_id, l_winner_party_id, l_party_rec,
                l_party_site_list, l_contact_list, l_cpt_list,
                l_return_status, l_msg_count, l_msg_data);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_PARTY_ACQUIRE_ERROR');
    FND_MESSAGE.SET_TOKEN('PARTY_ID', TO_CHAR(l_winner_party_id));
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSE

    FOR DUP IN (SELECT DUP_PARTY_ID
                  FROM HZ_DUP_SET_PARTIES
                  WHERE DUP_SET_ID = p_dup_set_id and dup_party_id <> l_winner_party_id) LOOP
        HZ_PARTY_SEARCH.get_score_details (
             FND_API.G_FALSE,p_rule_id, DUP.DUP_PARTY_ID,
             l_party_rec, l_party_site_list,l_contact_list, l_cpt_list,
             l_search_ctx_id, l_return_status, l_msg_count, l_msg_data);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_PARTY_SEARCH_ERROR');
          FND_MESSAGE.SET_TOKEN('PARTY_ID', TO_CHAR(DUP.DUP_PARTY_ID));
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          insert_match_details (l_search_ctx_id, p_dup_set_id, DUP.DUP_PARTY_ID);
        END IF;
    END LOOP;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.Count_And_Get(
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_SQL_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;

    FND_MSG_PUB.Count_And_Get(
           p_encoded => FND_API.G_FALSE,
           p_count => x_msg_count,
           p_data  => x_msg_data);
END;



/**
* Procedure to write a message to the out file
**/
PROCEDURE out(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
/*
  IF message = 'NEWLINE' THEN
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.output,message);
  ELSE
    FND_FILE.put(fnd_file.output,message);
  END IF;
*/
null;
END out;

/**
* Procedure to write a message to the log file
**/
PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put_line(fnd_file.log,message);
  END IF;
END log;

/**
* Procedure to write a message to the out and log files
**/
PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  out(message, newline);
  log(message);
END outandlog;

/**
* Function to fetch messages of the stack and log the error
* Also returns the error
**/
PROCEDURE logerror IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    log(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
  END LOOP;
  FND_MSG_PUB.Delete_Msg;
END logerror;

FUNCTION logerror RETURN VARCHAR2 IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := l_msg_data || ' ' || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
  END LOOP;
  log(l_msg_data);
  RETURN l_msg_data;

END logerror;
END;

/
