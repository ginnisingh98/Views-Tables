--------------------------------------------------------
--  DDL for Package Body FND_IMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_IMP_PKG" AS
/* $Header: afimpb.pls 120.14.12010000.1 2008/07/25 14:32:06 appldev ship $ */

FUNCTION lastupdate(snapshot_id__ INTEGER, patch_id__ INTEGER)
RETURN DATE IS
  answ__ DATE;
BEGIN
        select max(z.ts) into answ__
        from
                (select max(greatest(adts.snapshot_creation_date, adts.snapshot_update_date, adts.creation_date, adts.last_update_date)) ts
                from ad_snapshots adts where adts.snapshot_id = snapshot_id__
                UNION ALL
                select max(greatest(umsts.last_update_date, umsts.last_definition_date)) ts
                from fnd_ums_bugfixes umsts
                where umsts.bug_number = (select bug_number from ad_pm_patches where patch_id = patch_id__) AND --ang
                umsts.baseline = (select baseline from ad_pm_patches where patch_id = patch_id__)  --ang
                ) z;

        return answ__;
END lastupdate;

PROCEDURE makesingletons(request_id__ INTEGER) IS
  snapshot_id__ NUMBER;
  --buglist ad_patch_impact_api.t_rec_patch; --ang
  patchlist ad_patch_impact_api.t_recomm_patch_tab; --ang
  bug_no INTEGER;
  --baseline VARCHAR2(150); --ang
  patch_id NUMBER; --ang
  i INTEGER;
BEGIN
  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> reading patch list...');
  ad_patch_impact_api.get_global_snapshot_id(snapshot_id__);
  --ad_patch_impact_api.get_recommend_patch_list(buglist);--ang
  ad_patch_impact_api.get_recommend_patch_list(patchlist);--ang

  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> master patch list = '||patchlist.COUNT||' patches');
  for i in 1..patchlist.COUNT
  loop
      bug_no := patchlist(i).bug_number;
      --baseline := patchlist(i).baseline;
      patch_id := patchlist(i).patch_id;
      -- MONITOR: for every patch in the request, create a local singleton record('S')
      insert into fnd_imp_monitor(request_id, snapshot_id, set_type, virtual_bug_no,
				virtual_patch_id, r1_requestor, r1_sync_date, r2_requestor, r2_sync_date, --ang
				creation_date, last_update_date, last_updated_by, created_by)
	    values(request_id__, snapshot_id__, 'S', bug_no,
			patch_id, request_id__, null, request_id__, null, sysdate, sysdate, -1, -1); --ang
  end loop;

  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> reading prereq list...');
  -- ang entire for loop can be commented out as prereq analysis is, at the moment, not supported by AD
  --for i in 1..patchlist.COUNT --ang
  --loop
	--bug_no := patchlist(i).bug_number; --ang
	--ang for now AD Folks are not doing prereq analysis
	--makeprereqs(request_id__, bug_no);
  --end loop;

  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> continuing...');
END makesingletons;

--ang commenting out the below code as prereq analysis is, at the moment, not supported by AD
/*PROCEDURE makeprereqs(request_id__ INTEGER, bug_no__ INTEGER) IS
  snapshot_id__ NUMBER;
  buglist ad_patch_impact_api.t_prereq_patch;
  prereq_bug_no INTEGER;
  patch_order INTEGER;
BEGIN
  ad_patch_impact_api.get_global_snapshot_id(snapshot_id__);
  ad_patch_impact_api.get_prereq_list(bug_no__, buglist);

  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> '||bug_no__||' prereq list = '||buglist.COUNT||' patches');
  for patch_order in 1..buglist.COUNT
  loop
      prereq_bug_no := buglist(patch_order);
      -- BUGSET: for every prereq for patches in the request, create a local prereq record ('m')
      insert into fnd_imp_bugset(request_id, snapshot_id, set_type, virtual_bug_no, bug_no, patch_order,
				creation_date, last_update_date, last_updated_by, created_by)
	    values(request_id__, snapshot_id__, 'm', 0-bug_no__, prereq_bug_no,
		patch_order, sysdate, sysdate, -1, -1);
  end loop;
END makeprereqs;*/

PROCEDURE refresh1M(request_id__ INTEGER, virtual_patch_id__ INTEGER, snapshot_id__ INTEGER) IS --ang
  patch_id__ INTEGER; --ang
BEGIN
  patch_id__ := virtual_patch_id__; --ang
  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> running-refresh1M['||patch_id__||','||snapshot_id__||']...'); --ang
  delete from fnd_imp_bugset_temp;
  delete from FND_IMP_PSMaster2			where patch_id = patch_id__ and snapshot_id = snapshot_id__; --ang
--  delete from FND_IMP_AffectedFiles		where bug_no = bug_no__ and snapshot_id = snapshot_id__;
--  delete from FND_IMP_DiagMap			where bug_no = bug_no__ and snapshot_id = snapshot_id__;
  commit;
  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> after delete');

  insert into fnd_imp_bugset_temp(patch_id)
  (select q1.patch_id from fnd_imp_bugset q1
			 where q1.request_id = request_id__ and q1.snapshot_id = snapshot_id__
			  and q1.virtual_patch_id = virtual_patch_id__ and q1.set_type IN ('M','m','A'));
  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> after insert into fnd_imp_bugset_temp');
--
-- Tuned Performance Fix from Performance Team
--
   INSERT INTO FND_IMP_PSMASTER2(PATCH_ID, SNAPSHOT_ID, APP_SHORT_NAME,
	DIRECTORY, FILENAME, TYPEID, NEW_VERSION, OLD_VERSION, FILES_AFFECTED, TYPE_AFFECTED, FILE_TYPE, TRANS_NAME, IS_FLAGGED_FILE)
SELECT  virtual_patch_id__ PATCH_ID, snapshot_id__ SNAPSHOT_ID, APP_SHORT_NAME,
       DIRECTORY, FILENAME, MAX(TYPEID), MAX(NEW_VERSION), MAX(OLD_VERSION),
       MAX(FILES_AFFECTED), MAX(TYPE_AFFECTED), MAX(FILE_TYPE), MAX(TRANS_NAME),MAX(IS_FLAGGED_FILE)
FROM
    FND_IMP_PSMASTER2 M
WHERE
     M.SNAPSHOT_ID = snapshot_id__
 AND M.PATCH_ID IN ( SELECT PATCH_ID FROM FND_IMP_BUGSET_TEMP)
 AND NOT EXISTS (
                        SELECT /*+  INDEX(X FND_IMP_PSMASTER2_N1) */ 1
                        FROM  FND_IMP_PSMASTER2 X
                        WHERE X.SNAPSHOT_ID = snapshot_id__
                          AND X.PATCH_ID IN  (SELECT PATCH_ID FROM FND_IMP_BUGSET_TEMP where PATCH_ID <> M.PATCH_ID)
                          AND X.APP_SHORT_NAME = M.APP_SHORT_NAME
                          AND X.DIRECTORY = M.DIRECTORY
                          AND X.FILENAME = M.FILENAME
                          and X.NEW_VERSION IS NOT NULL
                          AND ( ( M.NEW_VERSION IS NULL)
                               or ( M.NEW_VERSION IS NOT NULL AND FND_IMP_CONV_PKG.COMPARE_RCSID(M.NEW_VERSION, X.NEW_VERSION) IN (1, 2)) ) )
GROUP BY APP_SHORT_NAME, DIRECTORY,FILENAME;

   fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> after insert into fnd_imp_psmaster2');
    commit;
    fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> completed-refresh1M['||patch_id__||','||snapshot_id__||']...');
END refresh1M;

PROCEDURE logstats(request_id__ INTEGER, stage__ CHAR) IS
  CURSOR stats1 IS
	select virtual_patch_id, r1_requestor --ang
	from fnd_imp_monitor
	where r1_requestor IS NOT NULL and request_id <> r1_requestor
              and psmaster2_sz <> 0 and request_id = request_id__;
  CURSOR stats2 IS
	select virtual_patch_id, r2_requestor --ang
	from fnd_imp_monitor
	where r2_requestor IS NOT NULL and request_id <> r2_requestor
              and psmaster2_sz <> 0 and request_id = request_id__;
  tmp1 stats1%ROWTYPE;
  tmp2 stats2%ROWTYPE;
BEGIN
    if(stage__ = '1') THEN
	OPEN stats1;
	LOOP
	    FETCH stats1 into tmp1;
	    EXIT WHEN stats1%NOTFOUND;
	    -- dbms_output.put_line('Note: Skipped stage1 for: '||tmp1.virtual_bug_no||' since it was already processed with request='||tmp1.r1_requestor);
	    fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> Skipped stage1 for: '||tmp1.virtual_patch_id||' since it was already processed with request='||tmp1.r1_requestor); --ang
	    commit;
	END LOOP;
	CLOSE stats1;
    else
	if(stage__ = '2') THEN
	    OPEN stats2;
	    LOOP
		FETCH stats2 into tmp2;
		EXIT WHEN stats2%NOTFOUND;
		-- dbms_output.put_line('Note: Skipped stage2 for: '||tmp2.virtual_bug_no||' since it was already processed with request='||tmp2.r2_requestor);
		fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> Skipped stage2 for: '||tmp2.virtual_patch_id||' since it was already processed with request='||tmp2.r2_requestor); --ang
		commit;
	    END LOOP;
	    CLOSE stats2;
	end if;
    end if;
END logstats;

PROCEDURE rsync1(request_id__ INTEGER) IS
  CURSOR bugsnaps1 IS
        --select snapshot_id, virtual_bug_no, set_type
        select snapshot_id, virtual_patch_id, set_type --ang
                from fnd_imp_monitor
		where request_id = request_id__ and
                ((set_type IN ('M', 'S', 's') and r1_sync_date IS NULL)
                 or psmaster2_sz = 0)
	order by snapshot_id, set_type desc, virtual_patch_id;
  virtual_patch_id__ INTEGER;
  snapshot_id__ INTEGER;
  set_type__ CHAR;
  time__ DATE;
  stage__ CHAR := '1';
  psmaster2_sz__ NUMBER;
BEGIN
  -- MONITOR/BUGSET: clean local records
  delete from fnd_imp_monitor where request_id = request_id__;
  -- todo: would this clear what PW sets!?
  delete from fnd_imp_bugset where request_id = request_id__ and set_type <> 'A';

  makesingletons(request_id__);
  -- BUGSET/MONITOR: for every patch with prereq record(s), create a local multiset record ('M')
  /* ang - not applicable as AD Team, for now, isn't doing prereq analysis
  insert into fnd_imp_bugset(request_id, snapshot_id, set_type, virtual_bug_no, bug_no,
				creation_date, last_update_date, last_updated_by, created_by)
	select request_id__, s.snapshot_id, 'M', s.virtual_bug_no, 0-s.virtual_bug_no, sysdate, sysdate, -1, -1
	from fnd_imp_bugset s
	where s.request_id = request_id__
	group by s.snapshot_id, s.virtual_bug_no;
  insert into fnd_imp_monitor(request_id, snapshot_id, set_type, virtual_bug_no,
				r1_requestor, r1_sync_date, r2_requestor, r2_sync_date,
				creation_date, last_update_date, last_updated_by, created_by)
	select request_id__, s.snapshot_id, 'M' set_type, s.virtual_bug_no,
			request_id__, null, request_id__, null, sysdate, sysdate, -1, -1
	from fnd_imp_bugset s
	where s.request_id = request_id__ and set_type = 'M';
  */
  -- MONITOR: for all prereqs, create a local servant singleton record ('s')
  /* ang - not applicable as AD Team, for now, isn't doing prereq analysis
  insert into fnd_imp_monitor(request_id, snapshot_id, set_type, virtual_bug_no,
				r1_requestor, r1_sync_date, r2_requestor, r2_sync_date,
				creation_date, last_update_date, last_updated_by, created_by)
	select request_id__, s.snapshot_id, 's' set_type, s.bug_no virtual_bug_no,
			request_id__, null, request_id__, null, sysdate, sysdate, -1, -1
		from fnd_imp_bugset s
		where s.request_id = request_id__
		    and s.set_type = 'm'
		    and s.bug_no NOT IN(select m.virtual_bug_no from fnd_imp_monitor m where m.request_id = request_id__)
		group by s.snapshot_id, s.bug_no;
  */
  -- MONITOR: remove any local 'M', 'S' or 's' records that already have an up-to-date global record
  update fnd_imp_monitor x
  set
	r1_requestor =
	    (select DECODE(stage__,'1',n.r1_requestor,n.r2_requestor)
		from fnd_imp_monitor n
		where n.request_id IS NULL
		--and n.snapshot_id = x.snapshot_id and n.virtual_bug_no = x.virtual_bug_no), --ang
		and n.snapshot_id = x.snapshot_id and n.virtual_patch_id = x.virtual_patch_id), --ang
	r1_sync_date =
	    (select DECODE(stage__,'1',n.r1_sync_date,n.r2_sync_date)
		from fnd_imp_monitor n
		where n.request_id IS NULL
		--and n.snapshot_id = x.snapshot_id and n.virtual_bug_no = x.virtual_bug_no), --ang
		and n.snapshot_id = x.snapshot_id and n.virtual_patch_id = x.virtual_patch_id), --ang
	psmaster2_sz =
	    (select n.psmaster2_sz
		from fnd_imp_monitor n
		where n.request_id IS NULL
		--and n.snapshot_id = x.snapshot_id and n.virtual_bug_no = x.virtual_bug_no) --ang
		and n.snapshot_id = x.snapshot_id and n.virtual_patch_id = x.virtual_patch_id) --ang
	where x.request_id = request_id__
	and EXISTS (
		select 1 from fnd_imp_monitor m
		where
			m.request_id IS NULL
			--and m.snapshot_id = x.snapshot_id and m.virtual_bug_no = x.virtual_bug_no --ang
			and m.snapshot_id = x.snapshot_id and m.virtual_patch_id = x.virtual_patch_id
			--and DECODE(stage__,'1',m.r1_sync_date,m.r2_sync_date) >= lastupdate(x.snapshot_id, x.virtual_bug_no) --ang
			and DECODE(stage__,'1',m.r1_sync_date,m.r2_sync_date) >= lastupdate(x.snapshot_id, x.virtual_patch_id) --ang
	);
  commit;
  logstats(request_id__, '1');
  commit;

      OPEN bugsnaps1;
      LOOP
	FETCH bugsnaps1 into snapshot_id__, virtual_patch_id__, set_type__; --ang
	EXIT WHEN bugsnaps1%NOTFOUND;
	select sysdate into time__ from dual;
	if(set_type__ = 'M') then
	  refresh1M(request_id__, virtual_patch_id__, snapshot_id__); --ang
	else
	  refresh1(virtual_patch_id__, snapshot_id__); --ang
	end if;

	select count(*) into psmaster2_sz__
	from fnd_imp_psmaster2
	where snapshot_id = snapshot_id__
		and patch_id = virtual_patch_id__;

        if psmaster2_sz__ = 0 then
           fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> No Patch Metadata found for patch: '||virtual_patch_id__);
        end if;

	if(SIGN(virtual_patch_id__) = 1) THEN
	    wipedata(0-virtual_patch_id__, snapshot_id__);
	end if;

        -- delete global record
	delete from fnd_imp_monitor
		where request_id IS NULL and snapshot_id = snapshot_id__ and virtual_patch_id = virtual_patch_id__;
        -- insert global record
	insert into fnd_imp_monitor(request_id, snapshot_id, set_type, virtual_patch_id,
			r1_requestor, r1_sync_date, r2_requestor, r2_sync_date, psmaster2_sz,
			creation_date, last_update_date, last_updated_by, created_by)
		values(NULL, snapshot_id__, set_type__, virtual_patch_id__,
			request_id__, time__, request_id__, null, psmaster2_sz__,
			sysdate, sysdate, -1, -1);
	if(SIGN(virtual_patch_id__) = -1) then
	    update fnd_imp_monitor set set_type = 'S'
		where	request_id IS NULL and snapshot_id = snapshot_id__
			and set_type = 's' and virtual_patch_id = 0-virtual_patch_id__;
	end if;
        -- update local record
	update fnd_imp_monitor set r1_sync_date = time__, last_update_date = time__, psmaster2_sz = psmaster2_sz__
	where		request_id = request_id__ and snapshot_id = snapshot_id__
			and set_type = set_type__ and virtual_patch_id = virtual_patch_id__;
	commit;
           --fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> Done with patch: '||virtual_bug_no__);
      END LOOP;
      CLOSE bugsnaps1;
           --fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> Done with rsync1');
END rsync1;

PROCEDURE rsync2(request_id__ INTEGER) IS
  CURSOR bugsnaps2 IS
        select snapshot_id, virtual_patch_id, set_type, psmaster2_sz
                from fnd_imp_monitor
		where request_id = request_id__ and
                ((set_type IN ('M', 'S', 's') and r2_sync_date IS NULL)
                 or psmaster2_sz = 0)
	order by snapshot_id, set_type desc, virtual_patch_id;
  virtual_patch_id__ INTEGER;
  snapshot_id__ INTEGER;
  set_type__ CHAR;
  time__ DATE;
  stage__ CHAR := '2';
  psmaster2_sz__ NUMBER;
BEGIN
  -- MONITOR: remove any local 'M', 'S' or 's' records that already have an up-to-date global record
  update fnd_imp_monitor x
  set
	r2_requestor =
	    (select DECODE(stage__,'1',n.r1_requestor,n.r2_requestor)
		from fnd_imp_monitor n
		where n.request_id IS NULL
		and n.snapshot_id = x.snapshot_id and n.virtual_patch_id = x.virtual_patch_id),
	r2_sync_date =
	    (select DECODE(stage__,'1',n.r1_sync_date,n.r2_sync_date)
		from fnd_imp_monitor n
		where n.request_id IS NULL
		and n.snapshot_id = x.snapshot_id and n.virtual_patch_id = x.virtual_patch_id)
	where x.request_id = request_id__
	and EXISTS (
		select 1 from fnd_imp_monitor m
		where
			m.request_id IS NULL
			and m.snapshot_id = x.snapshot_id and m.virtual_patch_id = x.virtual_patch_id
			and DECODE(stage__,'1',m.r1_sync_date,m.r2_sync_date) >= lastupdate(x.snapshot_id, x.virtual_patch_id)
	);
  commit;
  logstats(request_id__, '2');
  commit;

      OPEN bugsnaps2;
      LOOP
	FETCH bugsnaps2 into snapshot_id__, virtual_patch_id__, set_type__, psmaster2_sz__;
	EXIT WHEN bugsnaps2%NOTFOUND;
	select sysdate into time__ from dual;
	refresh2(virtual_patch_id__, snapshot_id__);

        if psmaster2_sz__ = 0 then
           fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> No Patch Metadata found for patch: '||virtual_patch_id__);
        end if;

        -- update global record
	update fnd_imp_monitor set r2_requestor = request_id__, r2_sync_date = time__, last_update_date = time__
	where		request_id IS NULL and snapshot_id = snapshot_id__
			and set_type = set_type__ and virtual_patch_id = virtual_patch_id__;
        -- update local record
	update fnd_imp_monitor set r2_sync_date = time__, last_update_date = time__
	where		request_id = request_id__ and snapshot_id = snapshot_id__
			and set_type = set_type__ and virtual_patch_id = virtual_patch_id__;
	commit;
      END LOOP;
      CLOSE bugsnaps2;
end rsync2;

PROCEDURE refresh(request_id__ INTEGER, stage__ CHAR) IS
  patchlist__ ad_patch_impact_api.t_recomm_patch_tab; --todo
BEGIN
  -- dbms_output.put_line(to_char(sysdate,'HH24:MI:SS')||'> master running['||request_id__||' stage='||stage__||']...');
  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> master running['||request_id__||' stage='||stage__||']...');

    if(stage__ = '1') then
	rsync1(request_id__);
    end if;

    if(stage__ = '2') then
	rsync2(request_id__);
    end if;

    -- Aggregate Patch Impact for request_id -- all patches in request
    if(stage__ = '3') then
        ad_patch_impact_api.get_recommend_patch_list(patchlist__);
        set_aggregate_list(request_id__, patchlist__);
	    aggregate_patches(request_id__);
    end if;

  -- dbms_output.put_line(to_char(sysdate,'HH24:MI:SS')||'> master completed '||request_id__||' stage='||stage__);
  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> master completed '||request_id__||' stage='||stage__);
END refresh;

PROCEDURE aggregate_patches(request_id__ INTEGER) IS
  snapshot_id__ NUMBER;
BEGIN
    --compute_prereqs(request_id__); --ang we donot deal w/ prereqs as AD is not supporting prereq analysis at the moment
    ad_patch_impact_api.get_global_snapshot_id(snapshot_id__);
    refresh1M(request_id__, 0-request_id__, snapshot_id__);
    refresh2(0-request_id__, snapshot_id__);
    update fnd_imp_bugset
    set set_type = 'a'
    where request_id = request_id__
          and virtual_patch_id = 0-request_id__;
    commit;
END aggregate_patches;

FUNCTION is_aggregate_running(request_id__ INTEGER)
RETURN VARCHAR2 IS
  is_running__ VARCHAR2(1);
BEGIN
     select 'Y' into is_running__
     from fnd_imp_bugset
     where request_id = request_id__
           and virtual_bug_no = 0-request_id__
           and set_type = 'A'
           and rownum = 1;
     return is_running__;
END;

FUNCTION get_aggregate_list(request_id__ INTEGER)
RETURN VARCHAR2 IS
  CURSOR agg_list IS
    select patch_id
    from fnd_imp_bugset
    where virtual_patch_id = 0-request_id__ and request_id = request_id__
          and set_type = 'a' and patch_order = 1;
  tmp1 agg_list%ROWTYPE;
  --buglist__ VARCHAR2(4000);
  patchlist__ VARCHAR2(4000);
BEGIN
  OPEN agg_list;
    LOOP
      FETCH agg_list into tmp1;
      EXIT WHEN agg_list%NOTFOUND;
      patchlist__ := patchlist__ || tmp1.patch_id || ',';
    END LOOP;
  CLOSE agg_list;
  return patchlist__;
END get_aggregate_list;

PROCEDURE set_aggregate_list(request_id__ INTEGER, buglist__ ad_patch_impact_api.t_rec_patch) IS
  i INTEGER;
  snapshot_id__ NUMBER;
  bug_no INTEGER;
BEGIN
  ad_patch_impact_api.get_global_snapshot_id(snapshot_id__);
  delete from fnd_imp_bugset
         where request_id = request_id__ and (set_type = 'A' or set_type = 'a') and snapshot_id = snapshot_id__;
  for i in 1..buglist__.COUNT
  loop
      bug_no := buglist__(i);
      -- for each top-level patch in request, enter record in bugset
      insert into fnd_imp_bugset(request_id, snapshot_id, set_type, virtual_bug_no, bug_no, patch_order,
				 creation_date, last_update_date, last_updated_by, created_by)
	    values(request_id__, snapshot_id__, 'A', 0-request_id__, bug_no,
		   1, sysdate, sysdate, -1, -1);
  end loop;
  commit;
END set_aggregate_list;

PROCEDURE set_aggregate_list(request_id__ INTEGER, patchlist__ ad_patch_impact_api.t_recomm_patch_tab) IS
  i INTEGER;
  snapshot_id__ NUMBER;
  patch_id INTEGER;
BEGIN
  ad_patch_impact_api.get_global_snapshot_id(snapshot_id__);
  delete from fnd_imp_bugset
         where request_id = request_id__ and (set_type = 'A' or set_type = 'a') and snapshot_id = snapshot_id__;
  for i in 1..patchlist__.COUNT
  loop
      patch_id := patchlist__(i).patch_id;
      -- for each top-level patch in request, enter record in bugset
      insert into fnd_imp_bugset(request_id, snapshot_id, set_type, virtual_patch_id, patch_id, patch_order,
				 creation_date, last_update_date, last_updated_by, created_by)
	    values(request_id__, snapshot_id__, 'A', 0-request_id__, patch_id,
		   1, sysdate, sysdate, -1, -1);
  end loop;
  commit;
END set_aggregate_list;

--ang commenting out the below method as prereq analysis is currently not supported by AD team
/*PROCEDURE compute_prereqs(request_id__ INTEGER) IS
  CURSOR top_level_bug IS
	select bug_no
	from fnd_imp_bugset
	where set_type = 'A' and patch_order = 1 and request_id  = request_id__;
  i INTEGER;
  snapshot_id__ NUMBER;
  prereq_bug_no INTEGER;
  prereq_buglist__ ad_patch_impact_api.t_prereq_patch;
  tmp1 top_level_bug%ROWTYPE;
BEGIN
  ad_patch_impact_api.get_global_snapshot_id(snapshot_id__);
  OPEN top_level_bug;
    LOOP
      FETCH top_level_bug into tmp1;
      EXIT WHEN top_level_bug%NOTFOUND;
        ad_patch_impact_api.get_prereq_list(request_id__, tmp1.bug_no, prereq_buglist__);
        for i in 1..prereq_buglist__.COUNT
        loop
            prereq_bug_no := prereq_buglist__(i);
            -- for each pre-req patch in request, enter record in bugset
            -- todo: avoid duplicates
            insert into fnd_imp_bugset(request_id, snapshot_id, set_type, virtual_bug_no, bug_no, patch_order,
				       creation_date, last_update_date, last_updated_by, created_by)
	          values(request_id__, snapshot_id__, 'A', 0-request_id__, prereq_bug_no,
		         2, sysdate, sysdate, -1, -1);
        end loop;
      commit;
    END LOOP;
  CLOSE top_level_bug;
END compute_prereqs;*/

PROCEDURE wipedata(patch_id__ INTEGER, snapshot_id__ INTEGER) IS
cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO cnt FROM fnd_imp_monitor where request_id IS NULL and snapshot_id = snapshot_id__ and virtual_patch_id = patch_id__;
  delete from fnd_imp_monitor where request_id IS NULL and snapshot_id = snapshot_id__ and virtual_patch_id = patch_id__; commit;
  SELECT COUNT(*) INTO cnt from FND_IMP_PFileInfo		where patch_id = patch_id__;
  delete from FND_IMP_PFileInfo		where patch_id = patch_id__; commit;
  SELECT COUNT(*) INTO cnt from FND_IMP_PFileInfo2	where patch_id = patch_id__;
  delete from FND_IMP_PFileInfo2	where patch_id = patch_id__; commit;
  SELECT COUNT(*) INTO cnt from FND_IMP_PSCommon		where patch_id = patch_id__ and snapshot_id = snapshot_id__;
  delete from FND_IMP_PSCommon		where patch_id = patch_id__ and snapshot_id = snapshot_id__; commit;
  SELECT COUNT(*) INTO cnt from FND_IMP_PSNew		where patch_id = patch_id__ and snapshot_id = snapshot_id__;
  delete from FND_IMP_PSNew		where patch_id = patch_id__ and snapshot_id = snapshot_id__; commit;
  BEGIN
  	SELECT COUNT(*) INTO cnt from fnd_imp_menu_dep_summary2 where patch_id = patch_id__ and snapshot_id = snapshot_id__;
    delete from fnd_imp_menu_dep_summary2 where patch_id = patch_id__ and snapshot_id = snapshot_id__;
    SELECT COUNT(*) INTO cnt from fnd_imp_menu_dep_summary3 where patch_id = patch_id__ and snapshot_id = snapshot_id__;
    delete from fnd_imp_menu_dep_summary3 where patch_id = patch_id__ and snapshot_id = snapshot_id__;
    SELECT COUNT(*) INTO cnt from FND_IMP_PISummary		where patch_id = patch_id__ and snapshot_id = snapshot_id__;
    delete from FND_IMP_PISummary		where patch_id = patch_id__ and snapshot_id = snapshot_id__;
    commit;
    SELECT COUNT(*) INTO cnt from FND_IMP_PSMaster2		where patch_id = patch_id__ and snapshot_id = snapshot_id__;
    delete from FND_IMP_PSMaster2		where patch_id = patch_id__ and snapshot_id = snapshot_id__;
    SELECT COUNT(*) INTO cnt from FND_IMP_AffectedFiles		where patch_id = patch_id__ and snapshot_id = snapshot_id__;
    delete from FND_IMP_AffectedFiles		where patch_id = patch_id__ and snapshot_id = snapshot_id__;
    SELECT COUNT(*) INTO cnt from FND_IMP_DiagMap where patch_id = patch_id__ and snapshot_id = snapshot_id__;
    delete from FND_IMP_DiagMap			where patch_id = patch_id__ and snapshot_id = snapshot_id__;
    commit;
  end;
END wipedata;

PROCEDURE refresh1(patch_id__ INTEGER, snapshot_id__ INTEGER) IS
BEGIN
  -- dbms_output.put_line(to_char(sysdate,'HH24:MI:SS')||'> running['||bug_no__||','||snapshot_id__||']...');
  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> running['||patch_id__||','||snapshot_id__||']...');
  delete from FND_IMP_PFileInfo		where patch_id = patch_id__; commit; --ang
  delete from FND_IMP_PFileInfo2	where patch_id = patch_id__; commit;
  delete from FND_IMP_PSCommon		where patch_id = patch_id__ and snapshot_id = snapshot_id__; commit;
  delete from FND_IMP_PSNew		where patch_id = patch_id__ and snapshot_id = snapshot_id__; commit;

  insert into FND_IMP_PFileInfo		(select * from FND_IMP_PFileInfo_VL 	where patch_id = patch_id__); commit;
  insert into FND_IMP_PFileInfo2	(select * from FND_IMP_PFileInfo2_VL 	where patch_id = patch_id__); commit;
  insert into FND_IMP_PSCommon		(select * from FND_IMP_PSCommon_VL	where patch_id = patch_id__ and snapshot_id = snapshot_id__); commit;
  insert into FND_IMP_PSNew		(select * from FND_IMP_PSNew_VL		where patch_id = patch_id__ and snapshot_id = snapshot_id__); commit;

  begin
    delete from FND_IMP_PSMaster2		where patch_id = patch_id__ and snapshot_id = snapshot_id__;
    -- delete from FND_IMP_AffectedFiles		where bug_no = bug_no__ and snapshot_id = snapshot_id__;
    -- delete from FND_IMP_DiagMap			where bug_no = bug_no__ and snapshot_id = snapshot_id__;
    commit;
    insert into FND_IMP_PSMaster2 	(select * from FND_IMP_PSMaster2_VL		where patch_id = patch_id__ and snapshot_id = snapshot_id__);

-- Moving this logic to Analyze Impact 2 (i.e. refresh2)
/*
    insert into FND_IMP_AffectedFiles	(select * from FND_IMP_AffectedFiles_VL		where bug_no = bug_no__ and snapshot_id = snapshot_id__);
    insert into FND_IMP_DiagMap		(select * from FND_IMP_DiagMap_VL		where bug_no = bug_no__ and snapshot_id = snapshot_id__);
*/
    commit;
  end;
  -- dbms_output.put_line(to_char(sysdate,'HH24:MI:SS')||'> completed');
  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> completed');
END refresh1;

PROCEDURE refresh2(patch_id__ INTEGER, snapshot_id__ INTEGER) IS
BEGIN
  -- dbms_output.put_line(to_char(sysdate,'HH24:MI:SS')||'> running['||bug_no__||','||snapshot_id__||']...');
  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> running['||patch_id__||','||snapshot_id__||']...');

  begin
    -- Adding this from refresh1/refresh1M
    delete from FND_IMP_AffectedFiles		where patch_id = patch_id__ and snapshot_id = snapshot_id__;
    delete from FND_IMP_DiagMap			where patch_id = patch_id__ and snapshot_id = snapshot_id__;

    delete from fnd_imp_menu_dep_summary2 where patch_id = patch_id__ and snapshot_id = snapshot_id__;
    delete from fnd_imp_menu_dep_summary3 where patch_id = patch_id__ and snapshot_id = snapshot_id__;
    delete from FND_IMP_PISummary		where patch_id = patch_id__ and snapshot_id = snapshot_id__;

    -- Adding this from refresh1/refresh1M - Moved it to this stage from
    -- first stage
    insert into FND_IMP_AffectedFiles	(select * from FND_IMP_AffectedFiles_VL		where patch_id = patch_id__ and snapshot_id = snapshot_id__);
    insert into FND_IMP_DiagMap		(select * from FND_IMP_DiagMap_VL		where patch_id = patch_id__ and snapshot_id = snapshot_id__);

    insert into fnd_imp_menu_dep_summary2 (select * from fnd_imp_menu_dep_summary2_vl where patch_id = patch_id__ and snapshot_id = snapshot_id__);
    insert into fnd_imp_menu_dep_summary3 (select * from fnd_imp_menu_dep_summary3_vl where patch_id = patch_id__ and snapshot_id = snapshot_id__);
    insert into FND_IMP_PISummary
		(select * from FND_IMP_PISummary_VL
		 where patch_id = patch_id__ and snapshot_id = snapshot_id__);
    commit;

    update fnd_imp_psmaster2 p
    set files_affected =
    (
      select count(*)
      from fnd_imp_affectedfiles f
      where p.patch_id = f.patch_id
            and p.snapshot_id = f.snapshot_id
            and p.app_short_name = f.patched_app_short_name
            and p.directory = f.patched_directory
            and p.filename = f.patched_filename
    )
    where patch_id=patch_id__
          and snapshot_id=snapshot_id__
          and typeid <> 'not applied'
          and file_type = 'jsp';

    update fnd_imp_psmaster2
    set type_affected='jsp'
    where patch_id=patch_id__
          and snapshot_id=snapshot_id__
          and typeid <> 'not applied'
          and files_affected<>0
          and file_type = 'jsp';

    update fnd_imp_psmaster2 p
    set files_affected=(select count(*)
                        from fnd_imp_menu_dep_summary2 s
                        where p.patch_id=s.patch_id
                              and p.snapshot_id=s.snapshot_id
                              and p.filename=s.form_name)
    where patch_id=patch_id__
          and snapshot_id=snapshot_id__
          and typeid <> 'not applied'
          and file_type = 'fmb';

    update fnd_imp_psmaster2 p
    set type_affected='menu'
    where patch_id=patch_id__
          and snapshot_id=snapshot_id__
          and typeid <> 'not applied'
          and file_type = 'fmb'
          and files_affected <> 0;

    update fnd_imp_psmaster2 p
    set files_affected=(select count(*)
			from jtf_diagnostic_cmap s
			where p.trans_name=s.classname)
    where patch_id=patch_id__
          and snapshot_id=snapshot_id__
          and typeid <> 'not applied'
          and file_type = 'class';

    update fnd_imp_psmaster2 p
    set type_affected='diag'
    where patch_id=patch_id__
          and snapshot_id=snapshot_id__
          and typeid <> 'not applied'
          and file_type = 'class'
          and files_affected <> 0;

    update fnd_imp_affectedfiles p
    set objects_affected=(select count(*)
                          from fnd_imp_menu_dep_summary2 s
                          where p.patch_id=s.patch_id
                                and p.snapshot_id=s.snapshot_id
                                and p.dep_filename=s.form_name)
    where patch_id=patch_id__
          and snapshot_id=snapshot_id__
          and typeid <> 'not applied';

    update fnd_imp_affectedfiles p
    set object_type='menu'
    where patch_id=patch_id__
          and snapshot_id=snapshot_id__
          and typeid <> 'not applied'
          and objects_affected <> 0;

    commit;
  end;
  -- dbms_output.put_line(to_char(sysdate,'HH24:MI:SS')||'> completed');
  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> completed');
END refresh2;

--
-- Procedure to compute language impact
--
PROCEDURE compute_language_impact (
	request_id__ INTEGER)
IS
  snapshot_id__ NUMBER;
  cursor c_bugs(v_req_id number, v_snapshot_id number) IS
	select virtual_bug_no
	  from fnd_imp_monitor
	  where set_type in ('s','S')
	  and request_id = v_req_id
	  and snapshot_id = v_snapshot_id;
  cursor M_bugs(v_req_id number, v_snapshot_id number) IS
	select virtual_patch_id
	  from fnd_imp_monitor
	  where set_type = 'M'
	  and request_id = v_req_id
	  and snapshot_id = v_snapshot_id;
BEGIN
 fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> computing language impact['||request_id__||']...');

 ad_patch_impact_api.get_global_snapshot_id(snapshot_id__);

 fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> snapshot_id['||snapshot_id__||']...');

 -- Cleanup any records associated with this request_id
 delete from fnd_imp_lang_summary l
	where l.snapshot_id = snapshot_id__
	and patch_id in (
	  select m.virtual_patch_id
	  	from fnd_imp_monitor m
	  	where m.set_type in ('s','S','M')
	  	and m.request_id = request_id__
	  	and m.snapshot_id = l.snapshot_id
	  union
	  select 0-request_id__ from dual);

 fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||' cleaned up fnd_imp_lang_summary');


 -- 1) First record for each singletons (top level or pre-reqs)
 -- whether translation patch is required with count as 1.
 for v_bug in c_bugs(request_id__,snapshot_id__) loop
   declare
    v_req_trans number := 0;
   begin
    select decode(count(fcv.file_type),0,0,1) into v_req_trans
	from fnd_imp_filetypecount_vl fcv
	where lower(fcv.file_type) in
	  --('fmb','fmx','rdf','ldt','ildt','jtl','msg','msb','res')
	  (select lower(lu.lookup_code) from fnd_lookups lu
		where lu.lookup_type = 'OAM_PIA_TRANS_FILE_TYPES')
	and ( fcv.upgrade > 0 or fcv.new > 0 )
	and fcv.snapshot_id = snapshot_id__
	and fcv.bug_no = v_bug.virtual_bug_no;
    insert into fnd_imp_lang_summary (
	snapshot_id, patch_id, req_trans_cnt) values
	(snapshot_id__, v_bug.virtual_bug_no, v_req_trans);
   exception
	when no_data_found then
    	  null;
   end;
 end loop;

 fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||' processed top levels and prerequisites (S,s)');

 -- 2) Now aggregate for each Multi-set (M) the sum of singletons
 -- for which translation patch is required.
 for v_bug in M_bugs(request_id__,snapshot_id__) loop
   declare
    v_req_trans number := 0;
   begin
    select sum(req_trans_cnt) into v_req_trans from
    (   -- get all the prequisites
    	select ls.req_trans_cnt req_trans_cnt
	 from fnd_imp_bugset b, fnd_imp_lang_summary ls
	 where ls.patch_id = b.patch_id
	 and ls.snapshot_id = b.snapshot_id
	 and b.virtual_patch_id = v_bug.virtual_patch_id
	 and b.set_type = 'm'
	 and b.snapshot_id = snapshot_id__
    	union all
	-- combine with the top level
	select ls.req_trans_cnt req_trans_cnt
	 from fnd_imp_lang_summary ls
	 where ls.patch_id = (0 - v_bug.virtual_patch_id)
    );
    insert into fnd_imp_lang_summary (
	snapshot_id, patch_id, req_trans_cnt) values
	(snapshot_id__, v_bug.virtual_patch_id, v_req_trans);
   exception
	when no_data_found then
	  null;
   end;
 end loop;

 fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||' processed top level and prerequisite aggregation (M)');

 -- 3) Now aggregate for ad-hoc aggregation (a) to be the sum of
 -- all top-levels (S and M) - and of course avoiding double
 -- counting. This step is only applicable if we're in
 -- aggregate impact mode.
 declare
  v_req_trans number := 0;
 begin
   select sum(ls.req_trans_cnt) into v_req_trans
	from fnd_imp_bugset b, fnd_imp_lang_summary ls
	where ls.patch_id = b.patch_id
	and ls.snapshot_id = b.snapshot_id
	and b.virtual_patch_id = (0-request_id__)
	and b.set_type = 'a'
	and b.snapshot_id = snapshot_id__
	group by b.virtual_patch_id;
    insert into fnd_imp_lang_summary (
	snapshot_id, patch_id, req_trans_cnt) values
	(snapshot_id__, (0-request_id__), v_req_trans);
 exception
  when no_data_found then
  	null;
 end;
 commit;

 fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||' processed  aggregation (M)');

 fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> Done computing language impact['||request_id__||','||snapshot_id__||']...');
END compute_language_impact;

PROCEDURE refreshCP(
	ERRBUF                    OUT NOCOPY VARCHAR2,
	RETCODE                   OUT NOCOPY NUMBER
) IS
  request_id INTEGER;
  no_request_id_found EXCEPTION;
BEGIN
  fnd_file.put_line(fnd_file.log, 'FND_IMP_PKG.refreshCP: running');
  select fcr.request_id into request_id
	from fnd_application fa, fnd_concurrent_requests fcr, fnd_concurrent_programs fcp
	where fcr.priority_request_id = fnd_global.conc_priority_request
	 and fcr.program_application_id = fcp.application_id
	 and fcp.application_id = fa.application_id
	 and fcr.concurrent_program_id = fcp.concurrent_program_id
	 and fa.application_short_name = 'AD'
	 and fcp.concurrent_program_name IN ('PATCHANALYSIS', 'PAANALYSIS', 'PADOWNLOADPATCHES', 'PAANALYZEPATCHES', 'PARECOMMENDPATCHES');
  fnd_file.put_line(fnd_file.log, 'FND_IMP_PKG.refreshCP: request id = '||request_id);
  refresh(request_id, '1');

  EXCEPTION
    WHEN OTHERS
    THEN
	RETCODE := 2;
	ERRBUF := sqlcode||':'||sqlerrm;
	fnd_file.put_line(fnd_file.log, 'FND_IMP_PKG.refreshCP failed ' || sqlcode||':'||sqlerrm);
END refreshCP;

PROCEDURE refreshCP2(
	ERRBUF                    OUT NOCOPY VARCHAR2,
	RETCODE                   OUT NOCOPY NUMBER
) IS
  request_id INTEGER;
  no_request_id_found EXCEPTION;
BEGIN
  fnd_file.put_line(fnd_file.log, 'FND_IMP_PKG.refreshCP2: running');
  select fcr.request_id into request_id
	from fnd_application fa, fnd_concurrent_requests fcr, fnd_concurrent_programs fcp
	where fcr.priority_request_id = fnd_global.conc_priority_request
	 and fcr.program_application_id = fcp.application_id
	 and fcp.application_id = fa.application_id
	 and fcr.concurrent_program_id = fcp.concurrent_program_id
	 and fa.application_short_name = 'AD'
	 and fcp.concurrent_program_name IN ('PATCHANALYSIS', 'PAANALYSIS', 'PADOWNLOADPATCHES', 'PAANALYZEPATCHES', 'PARECOMMENDPATCHES');
  fnd_file.put_line(fnd_file.log, 'FND_IMP_PKG.refreshCP2: request id = '||request_id);
  refresh(request_id, '2');
  compute_language_impact(request_id);
  EXCEPTION
    WHEN OTHERS
    THEN
	RETCODE := 2;
	ERRBUF := sqlcode||':'||sqlerrm;
	fnd_file.put_line(fnd_file.log, 'FND_IMP_PKG.refreshCP2 failed ' || sqlcode||':'||sqlerrm);
END refreshCP2;

PROCEDURE refreshCPAgg(
	ERRBUF                    OUT NOCOPY VARCHAR2,
	RETCODE                   OUT NOCOPY NUMBER,
    request_id__              IN  INTEGER
) IS
  request_id INTEGER;
  no_request_id_found EXCEPTION;
BEGIN
  fnd_file.put_line(fnd_file.log, 'FND_IMP_PKG.refreshCPAgg: running');
  if (request_id__ is null) then
    select fcr.request_id into request_id
	from fnd_application fa, fnd_concurrent_requests fcr, fnd_concurrent_programs fcp
	where fcr.priority_request_id = fnd_global.conc_priority_request
	 and fcr.program_application_id = fcp.application_id
	 and fcp.application_id = fa.application_id
	 and fcr.concurrent_program_id = fcp.concurrent_program_id
	 and fa.application_short_name = 'AD'
	 and fcp.concurrent_program_name IN ('PATCHANALYSIS', 'PAANALYSIS', 'PADOWNLOADPATCHES', 'PAANALYZEPATCHES', 'PARECOMMENDPATCHES');
    fnd_file.put_line(fnd_file.log, 'FND_IMP_PKG.refreshCPAgg: request id = '||request_id);
    refresh(request_id, '3');
    compute_language_impact(request_id);
  else
    if (request_id__ >= 0) then
      aggregate_patches(request_id__);
      compute_language_impact(request_id);
    end if;
  end if;

  EXCEPTION
    WHEN OTHERS
    THEN
	RETCODE := 2;
	ERRBUF := sqlcode||':'||sqlerrm;
	fnd_file.put_line(fnd_file.log, 'FND_IMP_PKG.refreshCPAgg failed ' || sqlcode||':'||sqlerrm);
END refreshCPAgg;

PROCEDURE sync(table_name VARCHAR2) IS
BEGIN
  execute immediate 'truncate table '||table_name;
  -- BVS-OK (never using user-given table_name)
  execute immediate 'insert into '||table_name||' (select * from '||table_name||'_VL)';
  -- dbms_output.put_line(to_char(sysdate,'HH24:MI:SS')||'> synced '||table_name);
END sync;

PROCEDURE wipe(table_name VARCHAR2) IS
BEGIN
  execute immediate 'truncate table '||table_name;
END wipe;

PROCEDURE refreshAll IS
BEGIN
  -- dbms_output.put_line(to_char(sysdate,'HH24:MI:SS')||'> running...');
  wipe('FND_IMP_PFileInfo');
  wipe('FND_IMP_PFileInfo2');
  wipe('FND_IMP_PSCommon');
  wipe('FND_IMP_PSNew');
  wipe('FND_IMP_PSMaster2');
  wipe('FND_IMP_PISummary');
  wipe('FND_IMP_AffectedFiles');
  -- dbms_output.put_line(to_char(sysdate,'HH24:MI:SS')||'> cleaned data');

  sync('FND_IMP_PFileInfo'); commit;
  sync('FND_IMP_PFileInfo2'); commit;
  sync('FND_IMP_PSCommon'); commit;
  sync('FND_IMP_PSNew'); commit;
  sync('FND_IMP_PSMaster2');
  sync('FND_IMP_PISummary'); commit;
  sync('FND_IMP_AffectedFiles'); commit;
  -- dbms_output.put_line(to_char(sysdate,'HH24:MI:SS')||'> completed');
  commit;

END refreshAll;

--
-- API to determine if there is at least one new or modified file of the
-- given type in the set of patches being analyzed in this request.
--
FUNCTION isFileTypeAffected(request_id__ INTEGER, snapshot_id__ INTEGER, filetype__ VARCHAR2)
 RETURN VARCHAR2 IS
 v_return varchar2(1) := 'N';

  cursor c_bugs(v_req_id number, v_snapshot_id number) IS
	select virtual_bug_no
	  from fnd_imp_monitor
	  where set_type in ('s','S')
	  and request_id = v_req_id
	  and snapshot_id = v_snapshot_id;
BEGIN
  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> FND_IMP_PKG.isFileTypeAffected IN');

  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> computing file type affected for file type ' || filetype__ || '['||request_id__||']...');

  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> snapshot_id['||snapshot_id__||']...');

  -- For each top level bug and pre-reqs, determine if the given
  -- file type is affected.
  for v_bug in c_bugs(request_id__,snapshot_id__) loop

   begin
    select 'Y' into v_return
	from fnd_imp_filetypecount_vl fcv
	where lower(fcv.file_type) = lower(filetype__)
	and ( fcv.upgrade > 0 or fcv.new > 0 )
	and fcv.snapshot_id = snapshot_id__
	and fcv.bug_no = v_bug.virtual_bug_no;
    if (v_return = 'Y') then
	exit; -- we're done as soon as we find the first bug
    end if;
   exception
	when no_data_found then
    	  null;
   end;
  end loop;

  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> v_return:'||v_return);

  fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> FND_IMP_PKG.isFileTypeAffected OUT');
  return v_return;
END isFileTypeAffected;

END FND_IMP_PKG;

/
